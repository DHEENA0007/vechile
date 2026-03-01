from django.db import models
from accounts.models import User
import uuid


class ServiceCenter(models.Model):
    """Service center managed by an owner."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='service_centers')
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    phone = models.CharField(max_length=15)
    email = models.EmailField(blank=True)
    address = models.TextField()
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=100)
    pincode = models.CharField(max_length=10)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    image = models.ImageField(upload_to='service_centers/', blank=True, null=True)
    is_active = models.BooleanField(default=True)
    opening_time = models.TimeField(default='09:00')
    closing_time = models.TimeField(default='18:00')
    working_days = models.CharField(max_length=100, default='Mon,Tue,Wed,Thu,Fri,Sat',
                                     help_text="Comma-separated working days")
    average_rating = models.FloatField(default=0.0)
    total_reviews = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-average_rating', '-created_at']

    def __str__(self):
        return self.name


class ServiceType(models.Model):
    """Types of services offered."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    icon = models.CharField(max_length=50, blank=True, help_text="Icon name for frontend")
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return self.name


class ServiceCenterService(models.Model):
    """Services offered by a specific service center with pricing."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    service_center = models.ForeignKey(ServiceCenter, on_delete=models.CASCADE,
                                        related_name='offered_services')
    service_type = models.ForeignKey(ServiceType, on_delete=models.CASCADE)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    estimated_duration = models.IntegerField(help_text="Duration in minutes")
    description = models.TextField(blank=True)
    is_available = models.BooleanField(default=True)

    class Meta:
        unique_together = ('service_center', 'service_type')

    def __str__(self):
        return f"{self.service_center.name} - {self.service_type.name}"


class TimeSlot(models.Model):
    """Available time slots for a service center."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    service_center = models.ForeignKey(ServiceCenter, on_delete=models.CASCADE,
                                        related_name='time_slots')
    start_time = models.TimeField()
    end_time = models.TimeField()
    max_bookings = models.IntegerField(default=3)
    is_active = models.BooleanField(default=True)

    class Meta:
        ordering = ['start_time']

    def __str__(self):
        return f"{self.service_center.name}: {self.start_time}-{self.end_time}"


class Mechanic(models.Model):
    """Mechanic associated with a service center."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='mechanic_profile')
    service_center = models.ForeignKey(ServiceCenter, on_delete=models.CASCADE,
                                        related_name='mechanics')
    specialization = models.CharField(max_length=200, blank=True)
    experience_years = models.IntegerField(default=0)
    is_available = models.BooleanField(default=True)
    joined_date = models.DateField(auto_now_add=True)

    class Meta:
        ordering = ['-joined_date']

    def __str__(self):
        return f"{self.user.get_full_name()} - {self.service_center.name}"

    @property
    def active_jobs_count(self):
        return self.assigned_bookings.filter(
            status__in=['confirmed', 'vehicle_received', 'inspection_done', 'in_progress']
        ).count()
