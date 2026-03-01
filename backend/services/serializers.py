from rest_framework import serializers
from .models import ServiceCenter, ServiceType, ServiceCenterService, TimeSlot, Mechanic
from accounts.serializers import UserSerializer


class ServiceTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = ServiceType
        fields = ['id', 'name', 'description', 'icon', 'is_active']


class ServiceCenterServiceSerializer(serializers.ModelSerializer):
    service_type_name = serializers.CharField(source='service_type.name', read_only=True)

    class Meta:
        model = ServiceCenterService
        fields = ['id', 'service_type', 'service_type_name', 'price',
                  'estimated_duration', 'description', 'is_available']
        read_only_fields = ['id']


class TimeSlotSerializer(serializers.ModelSerializer):
    class Meta:
        model = TimeSlot
        fields = ['id', 'start_time', 'end_time', 'max_bookings', 'is_active']
        read_only_fields = ['id']


class MechanicSerializer(serializers.ModelSerializer):
    user_details = UserSerializer(source='user', read_only=True)
    active_jobs = serializers.IntegerField(source='active_jobs_count', read_only=True)

    class Meta:
        model = Mechanic
        fields = ['id', 'user', 'user_details', 'service_center', 'specialization',
                  'experience_years', 'is_available', 'joined_date', 'active_jobs']
        read_only_fields = ['id', 'joined_date']


class ServiceCenterListSerializer(serializers.ModelSerializer):
    owner_name = serializers.CharField(source='owner.get_full_name', read_only=True)
    services_count = serializers.IntegerField(source='offered_services.count', read_only=True)
    distance = serializers.FloatField(read_only=True, required=False)

    class Meta:
        model = ServiceCenter
        fields = ['id', 'name', 'description', 'phone', 'address', 'city', 'state',
                  'image', 'is_active', 'opening_time', 'closing_time', 'working_days',
                  'average_rating', 'total_reviews', 'owner_name', 'services_count',
                  'latitude', 'longitude', 'distance']


class ServiceCenterDetailSerializer(serializers.ModelSerializer):
    owner_name = serializers.CharField(source='owner.get_full_name', read_only=True)
    offered_services = ServiceCenterServiceSerializer(many=True, read_only=True)
    time_slots = TimeSlotSerializer(many=True, read_only=True)
    mechanics_count = serializers.IntegerField(source='mechanics.count', read_only=True)

    class Meta:
        model = ServiceCenter
        fields = ['id', 'owner', 'name', 'description', 'phone', 'email', 'address',
                  'city', 'state', 'pincode', 'latitude', 'longitude', 'image',
                  'is_active', 'opening_time', 'closing_time', 'working_days',
                  'average_rating', 'total_reviews', 'owner_name', 'offered_services',
                  'time_slots', 'mechanics_count', 'created_at']
        read_only_fields = ['id', 'owner', 'average_rating', 'total_reviews', 'created_at']


class ServiceCenterCreateUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = ServiceCenter
        fields = ['name', 'description', 'phone', 'email', 'address', 'city', 'state',
                  'pincode', 'latitude', 'longitude', 'image', 'opening_time',
                  'closing_time', 'working_days']
