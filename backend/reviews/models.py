from django.db import models
from accounts.models import User
from services.models import ServiceCenter
from bookings.models import Booking
import uuid


class Review(models.Model):
    """User reviews for service centers."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='reviews')
    service_center = models.ForeignKey(ServiceCenter, on_delete=models.CASCADE,
                                        related_name='reviews')
    booking = models.OneToOneField(Booking, on_delete=models.CASCADE, related_name='review',
                                    null=True, blank=True)
    rating = models.IntegerField(choices=[(i, i) for i in range(1, 6)])
    comment = models.TextField(blank=True)
    owner_reply = models.TextField(blank=True)
    owner_reply_date = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        unique_together = ('user', 'booking')

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        # Update service center average rating
        reviews = Review.objects.filter(service_center=self.service_center)
        avg = reviews.aggregate(models.Avg('rating'))['rating__avg'] or 0
        self.service_center.average_rating = round(avg, 1)
        self.service_center.total_reviews = reviews.count()
        self.service_center.save(update_fields=['average_rating', 'total_reviews'])

    def __str__(self):
        return f"{self.user.get_full_name()} - {self.service_center.name} ({self.rating}⭐)"
