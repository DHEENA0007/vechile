from rest_framework import generics, status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes
from django.db.models import Q, Count, Sum
from django.db import models
import math
from .models import ServiceCenter, ServiceType, ServiceCenterService, TimeSlot, Mechanic
from .serializers import (
    ServiceCenterListSerializer, ServiceCenterDetailSerializer,
    ServiceCenterCreateUpdateSerializer, ServiceTypeSerializer,
    ServiceCenterServiceSerializer, TimeSlotSerializer, MechanicSerializer
)
from accounts.models import User
from accounts.serializers import UserRegistrationSerializer


class IsOwner(permissions.BasePermission):
    """Only service center owners."""
    def has_permission(self, request, view):
        return request.user.role == 'owner'


class ServiceTypeListView(generics.ListAPIView):
    """List all service types."""
    queryset = ServiceType.objects.filter(is_active=True)
    serializer_class = ServiceTypeSerializer
    permission_classes = [permissions.AllowAny]


class ServiceCenterSearchView(generics.ListAPIView):
    """Search service centers with filters."""
    serializer_class = ServiceCenterListSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        queryset = ServiceCenter.objects.filter(is_active=True)

        # Search by name/city
        search = self.request.query_params.get('search', '')
        if search:
            queryset = queryset.filter(
                Q(name__icontains=search) | Q(city__icontains=search) |
                Q(address__icontains=search)
            )

        # Filter by service type
        service_type = self.request.query_params.get('service_type', '')
        if service_type:
            queryset = queryset.filter(
                offered_services__service_type__id=service_type,
                offered_services__is_available=True
            )

        # Filter by rating
        min_rating = self.request.query_params.get('min_rating', '')
        if min_rating:
            queryset = queryset.filter(average_rating__gte=float(min_rating))

        # Filter by city
        city = self.request.query_params.get('city', '')
        if city:
            queryset = queryset.filter(city__icontains=city)

        # Location-based sorting
        lat = self.request.query_params.get('latitude', '')
        lng = self.request.query_params.get('longitude', '')
        if lat and lng:
            lat, lng = float(lat), float(lng)
            # Calculate approximate distance using Haversine-like formula
            centers = list(queryset)
            for center in centers:
                if center.latitude and center.longitude:
                    dlat = math.radians(center.latitude - lat)
                    dlng = math.radians(center.longitude - lng)
                    a = (math.sin(dlat/2)**2 +
                         math.cos(math.radians(lat)) *
                         math.cos(math.radians(center.latitude)) *
                         math.sin(dlng/2)**2)
                    c = 2 * math.asin(math.sqrt(a))
                    center.distance = round(6371 * c, 2)  # km
                else:
                    center.distance = 9999
            centers.sort(key=lambda x: x.distance)
            return centers

        return queryset.distinct()


class ServiceCenterDetailView(generics.RetrieveAPIView):
    """Get service center details."""
    queryset = ServiceCenter.objects.filter(is_active=True)
    serializer_class = ServiceCenterDetailSerializer
    permission_classes = [permissions.AllowAny]


# ===== Service Center Owner Views =====

class OwnerServiceCenterListCreateView(generics.ListCreateAPIView):
    """Owner: List and create service centers."""
    permission_classes = [IsOwner]

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return ServiceCenterCreateUpdateSerializer
        return ServiceCenterDetailSerializer

    def get_queryset(self):
        return ServiceCenter.objects.filter(owner=self.request.user)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)


class OwnerServiceCenterDetailView(generics.RetrieveUpdateDestroyAPIView):
    """Owner: Update and delete service center."""
    serializer_class = ServiceCenterCreateUpdateSerializer
    permission_classes = [IsOwner]

    def get_queryset(self):
        return ServiceCenter.objects.filter(owner=self.request.user)


class OwnerServiceManageView(generics.ListCreateAPIView):
    """Owner: Manage services offered."""
    serializer_class = ServiceCenterServiceSerializer
    permission_classes = [IsOwner]

    def get_queryset(self):
        center_id = self.kwargs['center_id']
        return ServiceCenterService.objects.filter(
            service_center__id=center_id,
            service_center__owner=self.request.user
        )

    def perform_create(self, serializer):
        center = ServiceCenter.objects.get(
            id=self.kwargs['center_id'],
            owner=self.request.user
        )
        serializer.save(service_center=center)


class OwnerServiceDetailView(generics.RetrieveUpdateDestroyAPIView):
    """Owner: Update/delete a service."""
    serializer_class = ServiceCenterServiceSerializer
    permission_classes = [IsOwner]

    def get_queryset(self):
        return ServiceCenterService.objects.filter(
            service_center__owner=self.request.user
        )


class OwnerTimeSlotManageView(generics.ListCreateAPIView):
    """Owner: Manage time slots."""
    serializer_class = TimeSlotSerializer
    permission_classes = [IsOwner]

    def get_queryset(self):
        center_id = self.kwargs['center_id']
        return TimeSlot.objects.filter(
            service_center__id=center_id,
            service_center__owner=self.request.user
        )

    def perform_create(self, serializer):
        center = ServiceCenter.objects.get(
            id=self.kwargs['center_id'],
            owner=self.request.user
        )
        serializer.save(service_center=center)


class OwnerTimeSlotDetailView(generics.RetrieveUpdateDestroyAPIView):
    """Owner: Update/delete a time slot."""
    serializer_class = TimeSlotSerializer
    permission_classes = [IsOwner]

    def get_queryset(self):
        return TimeSlot.objects.filter(
            service_center__owner=self.request.user
        )


class OwnerMechanicListCreateView(generics.ListCreateAPIView):
    """Owner: List and add mechanics."""
    serializer_class = MechanicSerializer
    permission_classes = [IsOwner]

    def get_queryset(self):
        center_id = self.kwargs['center_id']
        return Mechanic.objects.filter(
            service_center__id=center_id,
            service_center__owner=self.request.user
        )

    def create(self, request, *args, **kwargs):
        center_id = self.kwargs['center_id']
        center = ServiceCenter.objects.get(id=center_id, owner=request.user)

        # Create mechanic user account
        user_data = {
            'username': request.data.get('username'),
            'email': request.data.get('email', ''),
            'password': request.data.get('password', 'mechanic123'),
            'password_confirm': request.data.get('password', 'mechanic123'),
            'first_name': request.data.get('first_name', ''),
            'last_name': request.data.get('last_name', ''),
            'phone': request.data.get('phone', ''),
            'role': 'mechanic',
        }
        user_serializer = UserRegistrationSerializer(data=user_data)
        user_serializer.is_valid(raise_exception=True)
        user = user_serializer.save()

        mechanic = Mechanic.objects.create(
            user=user,
            service_center=center,
            specialization=request.data.get('specialization', ''),
            experience_years=int(request.data.get('experience_years', 0))
        )
        return Response(
            MechanicSerializer(mechanic).data,
            status=status.HTTP_201_CREATED
        )


class OwnerMechanicDetailView(generics.RetrieveUpdateDestroyAPIView):
    """Owner: Update/remove mechanic."""
    serializer_class = MechanicSerializer
    permission_classes = [IsOwner]

    def get_queryset(self):
        return Mechanic.objects.filter(
            service_center__owner=self.request.user
        )


class OwnerDashboardView(APIView):
    """Owner: Dashboard statistics."""
    permission_classes = [IsOwner]

    def get(self, request):
        from bookings.models import Booking, Invoice
        from django.utils import timezone
        from datetime import timedelta

        centers = ServiceCenter.objects.filter(owner=request.user)
        today = timezone.now().date()

        today_bookings = Booking.objects.filter(
            service_center__in=centers, booking_date=today
        ).count()
        active_services = Booking.objects.filter(
            service_center__in=centers,
            status__in=['confirmed', 'vehicle_received', 'inspection_done', 'in_progress']
        ).count()
        completed_today = Booking.objects.filter(
            service_center__in=centers,
            status__in=['completed', 'ready_pickup', 'delivered'],
            updated_at__date=today
        ).count()
        pending_bookings = Booking.objects.filter(
            service_center__in=centers, status='pending'
        ).count()

        # Revenue
        daily_revenue = Invoice.objects.filter(
            booking__service_center__in=centers,
            is_paid=True, payment_date__date=today
        ).aggregate(total=models.Sum('total_amount'))['total'] or 0

        monthly_revenue = Invoice.objects.filter(
            booking__service_center__in=centers,
            is_paid=True,
            payment_date__month=today.month,
            payment_date__year=today.year
        ).aggregate(total=models.Sum('total_amount'))['total'] or 0

        return Response({
            'today_bookings': today_bookings,
            'active_services': active_services,
            'completed_today': completed_today,
            'pending_bookings': pending_bookings,
            'daily_revenue': str(daily_revenue),
            'monthly_revenue': str(monthly_revenue),
            'total_centers': centers.count(),
            'total_mechanics': Mechanic.objects.filter(service_center__in=centers).count(),
        })
