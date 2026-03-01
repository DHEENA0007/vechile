from django.contrib import admin
from .models import User, Vehicle


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ['username', 'email', 'first_name', 'last_name', 'role', 'phone', 'is_active']
    list_filter = ['role', 'is_active']
    search_fields = ['username', 'email', 'first_name', 'last_name', 'phone']


@admin.register(Vehicle)
class VehicleAdmin(admin.ModelAdmin):
    list_display = ['registration_number', 'make', 'model', 'vehicle_type', 'owner']
    list_filter = ['vehicle_type', 'fuel_type']
    search_fields = ['registration_number', 'make', 'model']
