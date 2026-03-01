from django.contrib import admin
from .models import Booking, BookingStatusUpdate, Invoice, InvoiceItem, Notification


class InvoiceItemInline(admin.TabularInline):
    model = InvoiceItem
    extra = 0


class BookingStatusUpdateInline(admin.TabularInline):
    model = BookingStatusUpdate
    extra = 0
    readonly_fields = ['created_at']


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ['booking_number', 'user', 'service_center', 'vehicle', 'status', 'booking_date']
    list_filter = ['status', 'booking_date']
    search_fields = ['booking_number']
    inlines = [BookingStatusUpdateInline]


@admin.register(Invoice)
class InvoiceAdmin(admin.ModelAdmin):
    list_display = ['invoice_number', 'booking', 'total_amount', 'is_paid', 'payment_date']
    list_filter = ['is_paid']
    inlines = [InvoiceItemInline]


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ['title', 'user', 'notification_type', 'is_read', 'created_at']
    list_filter = ['notification_type', 'is_read']
