from rest_framework import serializers
from .models import Review


class ReviewSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source='user.get_full_name', read_only=True)
    service_center_name = serializers.CharField(source='service_center.name', read_only=True)

    class Meta:
        model = Review
        fields = ['id', 'user', 'user_name', 'service_center', 'service_center_name',
                  'booking', 'rating', 'comment', 'owner_reply', 'owner_reply_date',
                  'created_at']
        read_only_fields = ['id', 'user', 'owner_reply', 'owner_reply_date', 'created_at']


class ReviewReplySerializer(serializers.Serializer):
    reply = serializers.CharField()
