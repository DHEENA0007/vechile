from rest_framework import generics, status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db.models import Sum, Count, Q
from django.utils import timezone
from .models import Booking, BookingStatusUpdate, Invoice, InvoiceItem, Notification
from .serializers import (
    BookingCreateSerializer, BookingListSerializer, BookingDetailSerializer,
    BookingStatusUpdateSerializer, InvoiceSerializer, InvoiceItemSerializer,
    NotificationSerializer
)
from services.models import ServiceCenter, Mechanic


class IsOwnerOrMechanic(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.role in ['owner', 'mechanic']


# ===== User Booking Views =====

class UserBookingCreateView(generics.CreateAPIView):
    """User: Create a new booking."""
    serializer_class = BookingCreateSerializer

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class UserBookingListView(generics.ListAPIView):
    """User: List all bookings."""
    serializer_class = BookingListSerializer

    def get_queryset(self):
        queryset = Booking.objects.filter(user=self.request.user)
        status_filter = self.request.query_params.get('status', '')
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        return queryset


class UserBookingDetailView(generics.RetrieveAPIView):
    """User: View booking details."""
    serializer_class = BookingDetailSerializer

    def get_queryset(self):
        return Booking.objects.filter(user=self.request.user)


class UserCancelBookingView(APIView):
    """User: Cancel a booking."""
    def post(self, request, pk):
        try:
            booking = Booking.objects.get(id=pk, user=request.user)
        except Booking.DoesNotExist:
            return Response({'error': 'Booking not found'}, status=404)

        if booking.status not in ['pending', 'confirmed']:
            return Response({'error': 'Cannot cancel at this stage'}, status=400)

        booking.status = 'cancelled'
        booking.save()

        BookingStatusUpdate.objects.create(
            booking=booking, status='cancelled',
            notes='Cancelled by user', updated_by=request.user
        )

        # Notify owner
        Notification.objects.create(
            user=booking.service_center.owner,
            notification_type='booking',
            title='Booking Cancelled',
            message=f'Booking {booking.booking_number} has been cancelled by the user.',
            booking=booking
        )
        return Response({'message': 'Booking cancelled successfully'})


class UserApproveEstimateView(APIView):
    """User: Approve or reject estimate after inspection."""
    def post(self, request, pk):
        try:
            booking = Booking.objects.get(id=pk, user=request.user)
        except Booking.DoesNotExist:
            return Response({'error': 'Booking not found'}, status=404)

        if booking.status != 'inspection_done':
            return Response({'error': 'No pending estimate to approve'}, status=400)

        action = request.data.get('action')
        if action not in ['approve', 'reject']:
            return Response({'error': 'Invalid action. Use approve or reject.'}, status=400)

        new_status = 'estimate_approved' if action == 'approve' else 'estimate_rejected'
        booking.status = new_status
        booking.save()

        BookingStatusUpdate.objects.create(
            booking=booking, status=new_status,
            notes=f'Estimate {action}d by user', updated_by=request.user
        )

        # Notify owner
        Notification.objects.create(
            user=booking.service_center.owner,
            notification_type='status',
            title=f'Estimate {action.title()}d',
            message=f'User has {action}d the estimate for booking {booking.booking_number}.',
            booking=booking
        )
        return Response({'message': f'Estimate {action}d successfully'})


class UserDashboardView(APIView):
    """User: Dashboard data."""
    def get(self, request):
        bookings = Booking.objects.filter(user=request.user)
        upcoming = bookings.filter(
            status__in=['pending', 'confirmed'],
            booking_date__gte=timezone.now().date()
        ).order_by('booking_date')[:5]
        active = bookings.filter(
            status__in=['vehicle_received', 'inspection_done', 'in_progress']
        ).first()
        last_completed = bookings.filter(
            status__in=['completed', 'ready_pickup', 'delivered']
        ).first()

        return Response({
            'upcoming_bookings': BookingListSerializer(upcoming, many=True).data,
            'active_service': BookingDetailSerializer(active).data if active else None,
            'last_service': BookingListSerializer(last_completed).data if last_completed else None,
            'total_bookings': bookings.count(),
            'active_count': bookings.filter(
                status__in=['confirmed', 'vehicle_received', 'inspection_done', 'in_progress']
            ).count(),
        })


# ===== Owner Booking Views =====

class OwnerBookingListView(generics.ListAPIView):
    """Owner: List bookings for their service centers."""
    serializer_class = BookingListSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        queryset = Booking.objects.filter(
            service_center__owner=self.request.user
        )
        status_filter = self.request.query_params.get('status', '')
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        date_filter = self.request.query_params.get('date', '')
        if date_filter:
            queryset = queryset.filter(booking_date=date_filter)
        center_id = self.request.query_params.get('center', '')
        if center_id:
            queryset = queryset.filter(service_center__id=center_id)
        return queryset


class OwnerBookingDetailView(generics.RetrieveAPIView):
    """Owner: View booking details."""
    serializer_class = BookingDetailSerializer

    def get_queryset(self):
        return Booking.objects.filter(service_center__owner=self.request.user)


class OwnerBookingActionView(APIView):
    """Owner: Accept/reject/update booking."""
    def post(self, request, pk):
        try:
            booking = Booking.objects.get(
                id=pk, service_center__owner=request.user
            )
        except Booking.DoesNotExist:
            return Response({'error': 'Booking not found'}, status=404)

        action = request.data.get('action')
        notes = request.data.get('notes', '')

        valid_transitions = {
            'accept': ('pending', 'confirmed'),
            'reject': ('pending', 'cancelled'),
            'receive_vehicle': ('confirmed', 'vehicle_received'),
            'inspection_done': ('vehicle_received', 'inspection_done'),
            'start_service': ('estimate_approved', 'in_progress'),
            'complete_service': ('in_progress', 'completed'),
            'ready_pickup': ('completed', 'ready_pickup'),
            'delivered': ('ready_pickup', 'delivered'),
        }

        if action not in valid_transitions:
            return Response({'error': 'Invalid action'}, status=400)

        expected_from, new_status = valid_transitions[action]
        if booking.status != expected_from:
            return Response({'error': f'Cannot {action} from status {booking.status}'}, status=400)

        # Block inspection if no mechanic assigned
        if action == 'inspection_done' and not booking.mechanic:
            return Response({'error': 'Please assign a mechanic before performing inspection'}, status=400)

        booking.status = new_status

        # Handle mechanic assignment
        mechanic_id = request.data.get('mechanic_id')
        if mechanic_id:
            try:
                mechanic = Mechanic.objects.get(id=mechanic_id)
                booking.mechanic = mechanic
            except Mechanic.DoesNotExist:
                pass

        # Handle inspection report
        if action == 'inspection_done':
            booking.inspection_report = request.data.get('inspection_report', '')
            estimated_cost = request.data.get('estimated_cost')
            if estimated_cost:
                booking.estimated_cost = estimated_cost
            if request.data.get('estimate_items'):
                booking.estimate_items = request.data.get('estimate_items')

        # Handle mechanic notes
        if request.data.get('mechanic_notes'):
            booking.mechanic_notes = request.data['mechanic_notes']

        booking.save()

        BookingStatusUpdate.objects.create(
            booking=booking, status=new_status,
            notes=notes, updated_by=request.user
        )

        # Notify user
        Notification.objects.create(
            user=booking.user,
            notification_type='status',
            title=f'Booking {action.replace("_", " ").title()}',
            message=f'Your booking {booking.booking_number} status: {booking.get_status_display()}',
            booking=booking
        )

        return Response({
            'message': f'Booking {action} successfully',
            'booking': BookingDetailSerializer(booking).data
        })


class OwnerAssignMechanicView(APIView):
    """Owner: Assign mechanic to a booking."""
    def post(self, request, pk):
        try:
            booking = Booking.objects.get(id=pk, service_center__owner=request.user)
            mechanic = Mechanic.objects.get(id=request.data.get('mechanic_id'))
        except (Booking.DoesNotExist, Mechanic.DoesNotExist):
            return Response({'error': 'Not found'}, status=404)

        booking.mechanic = mechanic
        booking.save()

        # Notify mechanic
        Notification.objects.create(
            user=mechanic.user,
            notification_type='booking',
            title='New Job Assigned',
            message=f'You have been assigned to booking {booking.booking_number}',
            booking=booking
        )

        return Response({'message': 'Mechanic assigned successfully'})


# ===== Invoice Views =====

class CreateInvoiceView(APIView):
    """Owner: Create an invoice for a booking."""
    def post(self, request, pk):
        try:
            booking = Booking.objects.get(id=pk, service_center__owner=request.user)
        except Booking.DoesNotExist:
            return Response({'error': 'Booking not found'}, status=404)

        if hasattr(booking, 'invoice'):
            return Response({'error': 'Invoice already exists'}, status=400)

        # Create invoice
        invoice = Invoice.objects.create(
            booking=booking,
            subtotal=request.data.get('subtotal', 0),
            tax_percentage=request.data.get('tax_percentage', 18.0),
            discount=request.data.get('discount', 0),
            notes=request.data.get('notes', '')
        )

        # Add invoice items
        items = request.data.get('items', [])
        for item in items:
            InvoiceItem.objects.create(
                invoice=invoice,
                item_type=item.get('item_type', 'service'),
                description=item.get('description', ''),
                quantity=item.get('quantity', 1),
                unit_price=item.get('unit_price', 0)
            )

        # Recalculate subtotal from items
        total_items = InvoiceItem.objects.filter(invoice=invoice).aggregate(
            total=Sum('total_price'))['total'] or 0
        invoice.subtotal = total_items
        invoice.save()

        # Notify user
        Notification.objects.create(
            user=booking.user,
            notification_type='payment',
            title='Invoice Generated',
            message=f'Invoice {invoice.invoice_number} for booking {booking.booking_number}. Total: ₹{invoice.total_amount}',
            booking=booking
        )

        return Response(InvoiceSerializer(invoice).data, status=201)


class InvoiceDetailView(generics.RetrieveAPIView):
    """View invoice details."""
    serializer_class = InvoiceSerializer
    queryset = Invoice.objects.all()


class PayInvoiceView(APIView):
    """User: Mark invoice as paid (cash/manual)."""
    def post(self, request, pk):
        try:
            invoice = Invoice.objects.get(id=pk, booking__user=request.user)
        except Invoice.DoesNotExist:
            return Response({'error': 'Invoice not found'}, status=404)

        invoice.is_paid = True
        invoice.payment_method = request.data.get('payment_method', 'cash')
        invoice.payment_date = timezone.now()
        invoice.save()

        # Notify owner
        Notification.objects.create(
            user=invoice.booking.service_center.owner,
            notification_type='payment',
            title='Payment Received',
            message=f'Payment of ₹{invoice.total_amount} received for {invoice.booking.booking_number}',
            booking=invoice.booking
        )

        return Response({'message': 'Payment recorded successfully'})


class CreateRazorpayOrderView(APIView):
    """User: Create Razorpay order for an invoice."""
    def post(self, request, pk):
        import razorpay
        from django.conf import settings

        try:
            invoice = Invoice.objects.get(id=pk, booking__user=request.user)
        except Invoice.DoesNotExist:
            return Response({'error': 'Invoice not found'}, status=404)

        if invoice.is_paid:
            return Response({'error': 'Invoice is already paid'}, status=400)

        # Create Razorpay client
        client = razorpay.Client(auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET))

        # Amount in paise (Razorpay expects integer paise)
        amount_paise = int(float(invoice.total_amount) * 100)

        # Create Razorpay order
        order_data = {
            'amount': amount_paise,
            'currency': 'INR',
            'receipt': invoice.invoice_number,
            'payment_capture': 1,  # Auto-capture
            'notes': {
                'invoice_id': str(invoice.id),
                'booking_number': invoice.booking.booking_number,
                'user': request.user.get_full_name(),
            }
        }

        try:
            razorpay_order = client.order.create(data=order_data)
        except Exception as e:
            return Response({'error': f'Razorpay error: {str(e)}'}, status=500)

        # Save Razorpay order ID on invoice
        invoice.razorpay_order_id = razorpay_order['id']
        invoice.save()

        return Response({
            'razorpay_order_id': razorpay_order['id'],
            'razorpay_key_id': settings.RAZORPAY_KEY_ID,
            'amount': amount_paise,
            'currency': 'INR',
            'invoice_number': invoice.invoice_number,
            'booking_number': invoice.booking.booking_number,
            'user_name': request.user.get_full_name(),
            'user_email': request.user.email,
            'user_phone': request.user.phone or '',
        })


class VerifyRazorpayPaymentView(APIView):
    """User: Verify Razorpay payment signature and mark invoice paid."""
    def post(self, request, pk):
        import razorpay
        from django.conf import settings

        try:
            invoice = Invoice.objects.get(id=pk, booking__user=request.user)
        except Invoice.DoesNotExist:
            return Response({'error': 'Invoice not found'}, status=404)

        razorpay_payment_id = request.data.get('razorpay_payment_id')
        razorpay_order_id = request.data.get('razorpay_order_id')
        razorpay_signature = request.data.get('razorpay_signature')

        if not all([razorpay_payment_id, razorpay_order_id, razorpay_signature]):
            return Response({'error': 'Missing payment details'}, status=400)

        # Verify signature
        client = razorpay.Client(auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET))

        try:
            client.utility.verify_payment_signature({
                'razorpay_order_id': razorpay_order_id,
                'razorpay_payment_id': razorpay_payment_id,
                'razorpay_signature': razorpay_signature,
            })
        except razorpay.errors.SignatureVerificationError:
            return Response({'error': 'Payment verification failed. Invalid signature.'}, status=400)

        # Mark invoice as paid
        invoice.is_paid = True
        invoice.payment_method = 'razorpay'
        invoice.payment_date = timezone.now()
        invoice.razorpay_payment_id = razorpay_payment_id
        invoice.razorpay_order_id = razorpay_order_id
        invoice.razorpay_signature = razorpay_signature
        invoice.save()

        # Notify owner
        Notification.objects.create(
            user=invoice.booking.service_center.owner,
            notification_type='payment',
            title='Online Payment Received',
            message=f'Online payment of ₹{invoice.total_amount} received for {invoice.booking.booking_number}',
            booking=invoice.booking
        )

        return Response({
            'message': 'Payment verified and recorded successfully',
            'invoice': InvoiceSerializer(invoice).data,
        })


# ===== Mechanic Views =====

class MechanicJobListView(generics.ListAPIView):
    """Mechanic: View assigned jobs."""
    serializer_class = BookingListSerializer

    def get_queryset(self):
        queryset = Booking.objects.filter(
            mechanic__user=self.request.user
        )
        status_filter = self.request.query_params.get('status', '')
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        return queryset


class MechanicJobDetailView(generics.RetrieveAPIView):
    """Mechanic: View job details."""
    serializer_class = BookingDetailSerializer

    def get_queryset(self):
        return Booking.objects.filter(mechanic__user=self.request.user)


class MechanicUpdateStatusView(APIView):
    """Mechanic: Update job status."""
    def post(self, request, pk):
        try:
            booking = Booking.objects.get(id=pk, mechanic__user=request.user)
        except Booking.DoesNotExist:
            return Response({'error': 'Job not found'}, status=404)

        new_status = request.data.get('status')
        notes = request.data.get('notes', '')
        images = request.data.get('images', [])

        mechanic_transitions = {
            'vehicle_received': ['inspection_done'],
            'estimate_approved': ['in_progress'],
            'in_progress': ['completed'],
        }

        allowed = mechanic_transitions.get(booking.status, [])
        if new_status not in allowed:
            return Response({'error': f'Cannot change to {new_status} from {booking.status}'}, status=400)

        booking.status = new_status
        if notes:
            booking.mechanic_notes += f"\n{notes}" if booking.mechanic_notes else notes
        if request.data.get('inspection_report'):
            booking.inspection_report = request.data['inspection_report']
        if request.data.get('estimate_items'):
            booking.estimate_items = request.data['estimate_items']
        if request.data.get('estimated_cost'):
            booking.estimated_cost = request.data['estimated_cost']
        booking.save()

        BookingStatusUpdate.objects.create(
            booking=booking, status=new_status,
            notes=notes, updated_by=request.user,
            images=images
        )

        # Notify owner and user
        for user in [booking.service_center.owner, booking.user]:
            Notification.objects.create(
                user=user,
                notification_type='status',
                title='Service Status Updated',
                message=f'Booking {booking.booking_number}: {booking.get_status_display()}',
                booking=booking
            )

        return Response({
            'message': 'Status updated successfully',
            'booking': BookingDetailSerializer(booking).data
        })


class MechanicDashboardView(APIView):
    """Mechanic: Dashboard data."""
    def get(self, request):
        jobs = Booking.objects.filter(mechanic__user=request.user)
        today = timezone.now().date()

        return Response({
            'assigned_jobs': jobs.filter(
                status__in=['confirmed', 'vehicle_received']
            ).count(),
            'in_progress': jobs.filter(status='in_progress').count(),
            'completed_today': jobs.filter(
                status__in=['completed', 'ready_pickup', 'delivered'],
                updated_at__date=today
            ).count(),
            'total_completed': jobs.filter(
                status__in=['completed', 'ready_pickup', 'delivered']
            ).count(),
            'todays_tasks': BookingListSerializer(
                jobs.filter(
                    status__in=['confirmed', 'vehicle_received', 'inspection_done', 'in_progress'],
                    booking_date=today
                ), many=True
            ).data,
        })


# ===== Notification Views =====

class NotificationListView(generics.ListAPIView):
    """List user notifications."""
    serializer_class = NotificationSerializer

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)


class MarkNotificationReadView(APIView):
    """Mark notification as read."""
    def post(self, request, pk):
        try:
            notification = Notification.objects.get(id=pk, user=request.user)
            notification.is_read = True
            notification.save()
            return Response({'message': 'Marked as read'})
        except Notification.DoesNotExist:
            return Response({'error': 'Not found'}, status=404)


class MarkAllNotificationsReadView(APIView):
    """Mark all notifications as read."""
    def post(self, request):
        Notification.objects.filter(user=request.user, is_read=False).update(is_read=True)
        return Response({'message': 'All marked as read'})


# ===== Revenue Report =====

class RevenueReportView(APIView):
    """Owner: Revenue report."""
    def get(self, request):
        centers = ServiceCenter.objects.filter(owner=request.user)
        today = timezone.now().date()

        invoices = Invoice.objects.filter(
            booking__service_center__in=centers, is_paid=True
        )

        daily = invoices.filter(payment_date__date=today).aggregate(
            total=Sum('total_amount'))['total'] or 0
        monthly = invoices.filter(
            payment_date__month=today.month, payment_date__year=today.year
        ).aggregate(total=Sum('total_amount'))['total'] or 0

        # Service-wise breakdown
        from services.models import ServiceCenterService
        service_revenue = []
        for center in centers:
            for svc in center.offered_services.all():
                rev = invoices.filter(
                    booking__services=svc
                ).aggregate(total=Sum('total_amount'))['total'] or 0
                if rev > 0:
                    service_revenue.append({
                        'service': svc.service_type.name,
                        'center': center.name,
                        'revenue': str(rev)
                    })

        # Mechanic productivity
        mechanic_stats = []
        for mech in Mechanic.objects.filter(service_center__in=centers):
            completed = Booking.objects.filter(
                mechanic=mech,
                status__in=['completed', 'ready_pickup', 'delivered']
            ).count()
            mechanic_stats.append({
                'name': mech.user.get_full_name(),
                'completed_jobs': completed,
                'active_jobs': mech.active_jobs_count
            })

        return Response({
            'daily_revenue': str(daily),
            'monthly_revenue': str(monthly),
            'service_revenue': service_revenue,
            'mechanic_productivity': mechanic_stats,
        })
