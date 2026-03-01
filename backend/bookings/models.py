from django.db import models
from accounts.models import User, Vehicle
from services.models import ServiceCenter, ServiceCenterService, TimeSlot, Mechanic
import uuid


class Booking(models.Model):
    """Service booking by a vehicle owner."""
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('vehicle_received', 'Vehicle Received'),
        ('inspection_done', 'Inspection Completed (Pending Approval)'),
        ('estimate_approved', 'Estimate Approved'),
        ('estimate_rejected', 'Estimate Rejected'),
        ('in_progress', 'Service In Progress'),
        ('completed', 'Service Completed'),
        ('ready_pickup', 'Ready for Pickup'),
        ('delivered', 'Delivered'),
        ('cancelled', 'Cancelled'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    booking_number = models.CharField(max_length=20, unique=True, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='bookings')
    vehicle = models.ForeignKey(Vehicle, on_delete=models.CASCADE, related_name='bookings')
    service_center = models.ForeignKey(ServiceCenter, on_delete=models.CASCADE,
                                        related_name='bookings')
    services = models.ManyToManyField(ServiceCenterService, related_name='bookings')
    mechanic = models.ForeignKey(Mechanic, on_delete=models.SET_NULL, null=True, blank=True,
                                  related_name='assigned_bookings')
    time_slot = models.ForeignKey(TimeSlot, on_delete=models.SET_NULL, null=True, blank=True)
    booking_date = models.DateField()
    problem_description = models.TextField(blank=True)
    vehicle_images = models.JSONField(default=list, blank=True,
                                       help_text="List of image paths uploaded by user")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    estimated_cost = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    estimated_completion = models.DateTimeField(null=True, blank=True)
    mechanic_notes = models.TextField(blank=True)
    inspection_report = models.TextField(blank=True)
    estimate_items = models.JSONField(default=list, blank=True,
                                      help_text="Detailed items for the cost estimate")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def save(self, *args, **kwargs):
        if not self.booking_number:
            import random
            self.booking_number = f"BK{random.randint(100000, 999999)}"
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.booking_number} - {self.user.get_full_name()}"


class BookingStatusUpdate(models.Model):
    """Track status updates for a booking."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    booking = models.ForeignKey(Booking, on_delete=models.CASCADE, related_name='status_updates')
    status = models.CharField(max_length=20, choices=Booking.STATUS_CHOICES)
    notes = models.TextField(blank=True)
    updated_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    images = models.JSONField(default=list, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f"{self.booking.booking_number} - {self.status}"


class Invoice(models.Model):
    """Invoice generated for a completed service."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    invoice_number = models.CharField(max_length=20, unique=True, editable=False)
    booking = models.OneToOneField(Booking, on_delete=models.CASCADE, related_name='invoice')
    subtotal = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    tax_percentage = models.DecimalField(max_digits=5, decimal_places=2, default=18.0)
    tax_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    discount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    is_paid = models.BooleanField(default=False)
    payment_method = models.CharField(max_length=50, blank=True)
    payment_date = models.DateTimeField(null=True, blank=True)
    razorpay_order_id = models.CharField(max_length=100, blank=True)
    razorpay_payment_id = models.CharField(max_length=100, blank=True)
    razorpay_signature = models.CharField(max_length=200, blank=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        if not self.invoice_number:
            import random
            self.invoice_number = f"INV{random.randint(100000, 999999)}"
        # Calculate totals
        from decimal import Decimal
        self.tax_percentage = Decimal(str(self.tax_percentage))
        self.tax_amount = (self.subtotal * self.tax_percentage / Decimal('100')).quantize(Decimal('0.01'))
        self.total_amount = (self.subtotal + self.tax_amount - self.discount).quantize(Decimal('0.01'))
        super().save(*args, **kwargs)

    def __str__(self):
        return self.invoice_number


class InvoiceItem(models.Model):
    """Individual items in an invoice."""
    ITEM_TYPES = [
        ('service', 'Service Charge'),
        ('parts', 'Spare Parts'),
        ('labor', 'Labor Charge'),
        ('other', 'Other'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    invoice = models.ForeignKey(Invoice, on_delete=models.CASCADE, related_name='items')
    item_type = models.CharField(max_length=10, choices=ITEM_TYPES)
    description = models.CharField(max_length=300)
    quantity = models.IntegerField(default=1)
    unit_price = models.DecimalField(max_digits=10, decimal_places=2)
    total_price = models.DecimalField(max_digits=10, decimal_places=2)

    def save(self, *args, **kwargs):
        self.total_price = self.quantity * self.unit_price
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.description} - ₹{self.total_price}"


class Notification(models.Model):
    """Notifications for users."""
    NOTIFICATION_TYPES = [
        ('booking', 'Booking Update'),
        ('status', 'Status Update'),
        ('payment', 'Payment'),
        ('review', 'Review'),
        ('general', 'General'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    notification_type = models.CharField(max_length=10, choices=NOTIFICATION_TYPES)
    title = models.CharField(max_length=200)
    message = models.TextField()
    booking = models.ForeignKey(Booking, on_delete=models.CASCADE, null=True, blank=True)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} - {self.user.get_full_name()}"
