from django.contrib import admin
from .models import ServiceCenter, ServiceType, ServiceCenterService, TimeSlot, Mechanic


@admin.register(ServiceCenter)
class ServiceCenterAdmin(admin.ModelAdmin):
    list_display = ['name', 'owner', 'city', 'phone', 'average_rating', 'is_active']
    list_filter = ['is_active', 'city']
    search_fields = ['name', 'city']


@admin.register(ServiceType)
class ServiceTypeAdmin(admin.ModelAdmin):
    list_display = ['name', 'is_active']


@admin.register(ServiceCenterService)
class ServiceCenterServiceAdmin(admin.ModelAdmin):
    list_display = ['service_center', 'service_type', 'price', 'estimated_duration', 'is_available']


@admin.register(TimeSlot)
class TimeSlotAdmin(admin.ModelAdmin):
    list_display = ['service_center', 'start_time', 'end_time', 'max_bookings', 'is_active']


@admin.register(Mechanic)
class MechanicAdmin(admin.ModelAdmin):
    list_display = ['user', 'service_center', 'specialization', 'experience_years', 'is_available']
