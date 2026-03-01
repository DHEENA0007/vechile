from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from django.utils import timezone
from .models import Review
from .serializers import ReviewSerializer, ReviewReplySerializer
from services.models import ServiceCenter


class ReviewCreateView(generics.CreateAPIView):
    """User: Create a review."""
    serializer_class = ReviewSerializer

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class ServiceCenterReviewListView(generics.ListAPIView):
    """List reviews for a service center."""
    serializer_class = ReviewSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        return Review.objects.filter(service_center_id=self.kwargs['center_id'])


class UserReviewListView(generics.ListAPIView):
    """User: List their reviews."""
    serializer_class = ReviewSerializer

    def get_queryset(self):
        return Review.objects.filter(user=self.request.user)


class OwnerReviewListView(generics.ListAPIView):
    """Owner: List reviews for their service centers."""
    serializer_class = ReviewSerializer

    def get_queryset(self):
        return Review.objects.filter(
            service_center__owner=self.request.user
        )


class OwnerReplyReviewView(APIView):
    """Owner: Reply to a review."""
    def post(self, request, pk):
        try:
            review = Review.objects.get(
                id=pk, service_center__owner=request.user
            )
        except Review.DoesNotExist:
            return Response({'error': 'Review not found'}, status=404)

        serializer = ReviewReplySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        review.owner_reply = serializer.validated_data['reply']
        review.owner_reply_date = timezone.now()
        review.save()

        return Response(ReviewSerializer(review).data)
