from rest_framework import serializers
from .models import Booking, BookingStatusUpdate, Invoice, InvoiceItem, Notification
from accounts.serializers import UserSerializer, VehicleSerializer
from services.serializers import ServiceCenterListSerializer, MechanicSerializer


class BookingStatusUpdateSerializer(serializers.ModelSerializer):
    updated_by_name = serializers.CharField(source='updated_by.get_full_name', read_only=True)

    class Meta:
        model = BookingStatusUpdate
        fields = ['id', 'status', 'notes', 'updated_by', 'updated_by_name',
                  'images', 'created_at']
        read_only_fields = ['id', 'updated_by', 'created_at']


class InvoiceItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = InvoiceItem
        fields = ['id', 'item_type', 'description', 'quantity', 'unit_price', 'total_price']
        read_only_fields = ['id', 'total_price']


class InvoiceSerializer(serializers.ModelSerializer):
    items = InvoiceItemSerializer(many=True, read_only=True)

    class Meta:
        model = Invoice
        fields = ['id', 'invoice_number', 'subtotal', 'tax_percentage', 'tax_amount',
                  'discount', 'total_amount', 'is_paid', 'payment_method', 'payment_date',
                  'razorpay_order_id', 'razorpay_payment_id',
                  'notes', 'items', 'created_at']
        read_only_fields = ['id', 'invoice_number', 'tax_amount', 'total_amount', 'created_at']


class BookingCreateSerializer(serializers.ModelSerializer):
    service_ids = serializers.ListField(child=serializers.UUIDField(), write_only=True)

    class Meta:
        model = Booking
        fields = ['vehicle', 'service_center', 'service_ids', 'time_slot',
                  'booking_date', 'problem_description', 'vehicle_images']
        read_only_fields = ['id']

    def create(self, validated_data):
        service_ids = validated_data.pop('service_ids', [])
        booking = Booking.objects.create(**validated_data)
        from services.models import ServiceCenterService
        services = ServiceCenterService.objects.filter(id__in=service_ids)
        booking.services.set(services)
        # Calculate estimated cost
        total = sum(s.price for s in services)
        booking.estimated_cost = total
        booking.save()
        # Create initial status update
        BookingStatusUpdate.objects.create(
            booking=booking,
            status='pending',
            notes='Booking created',
            updated_by=booking.user
        )
        # Notify service center owner
        Notification.objects.create(
            user=booking.service_center.owner,
            notification_type='booking',
            title='New Booking',
            message=f'New booking {booking.booking_number} from {booking.user.get_full_name()}',
            booking=booking
        )
        return booking


class BookingListSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source='user.get_full_name', read_only=True)
    vehicle_info = serializers.SerializerMethodField()
    service_center_name = serializers.CharField(source='service_center.name', read_only=True)
    mechanic_name = serializers.SerializerMethodField()
    services_list = serializers.SerializerMethodField()
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Booking
        fields = ['id', 'booking_number', 'user', 'user_name', 'vehicle', 'vehicle_info',
                  'service_center', 'service_center_name', 'mechanic', 'mechanic_name',
                  'booking_date', 'status', 'status_display', 'estimated_cost',
                  'services_list', 'estimate_items', 'created_at']

    def get_vehicle_info(self, obj):
        return f"{obj.vehicle.make} {obj.vehicle.model} ({obj.vehicle.registration_number})"

    def get_mechanic_name(self, obj):
        return obj.mechanic.user.get_full_name() if obj.mechanic else None

    def get_services_list(self, obj):
        return [s.service_type.name for s in obj.services.all()]


class BookingDetailSerializer(serializers.ModelSerializer):
    user_details = UserSerializer(source='user', read_only=True)
    vehicle_details = VehicleSerializer(source='vehicle', read_only=True)
    service_center_details = ServiceCenterListSerializer(source='service_center', read_only=True)
    mechanic_details = MechanicSerializer(source='mechanic', read_only=True)
    status_updates = BookingStatusUpdateSerializer(many=True, read_only=True)
    invoice = InvoiceSerializer(read_only=True)
    services_list = serializers.SerializerMethodField()
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Booking
        fields = ['id', 'booking_number', 'user', 'user_details', 'vehicle',
                  'vehicle_details', 'service_center', 'service_center_details',
                  'mechanic', 'mechanic_details', 'services', 'services_list',
                  'time_slot', 'booking_date', 'problem_description', 'vehicle_images',
                  'status', 'status_display', 'estimated_cost', 'estimated_completion',
                  'mechanic_notes', 'inspection_report', 'estimate_items', 'status_updates', 'invoice',
                  'created_at', 'updated_at']

    def get_services_list(self, obj):
        return [
            {'name': s.service_type.name, 'price': str(s.price)}
            for s in obj.services.all()
        ]


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'notification_type', 'title', 'message', 'booking',
                  'is_read', 'created_at']
        read_only_fields = ['id', 'created_at']
