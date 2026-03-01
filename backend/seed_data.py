"""
Seed data script for Vehicle Service Management.
Run with: python3 manage.py shell < seed_data.py
"""
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'vehicle_service.settings')
django.setup()

from accounts.models import User, Vehicle
from services.models import ServiceCenter, ServiceType, ServiceCenterService, TimeSlot, Mechanic
from rest_framework.authtoken.models import Token

print("🌱 Seeding database...")

# Create Service Types
service_types_data = [
    {'name': 'General Service', 'description': 'Regular maintenance and checkup', 'icon': 'build'},
    {'name': 'Oil Change', 'description': 'Engine oil and filter replacement', 'icon': 'oil_barrel'},
    {'name': 'Brake Service', 'description': 'Brake pad and disc inspection/replacement', 'icon': 'warning'},
    {'name': 'Engine Repair', 'description': 'Engine diagnostics and repair', 'icon': 'engineering'},
    {'name': 'Tire Service', 'description': 'Tire rotation, alignment, replacement', 'icon': 'trip_origin'},
    {'name': 'AC Service', 'description': 'Air conditioning repair and recharge', 'icon': 'ac_unit'},
    {'name': 'Electrical Work', 'description': 'Battery, wiring, lights repair', 'icon': 'bolt'},
    {'name': 'Body Work', 'description': 'Dent removal, painting, body repair', 'icon': 'format_paint'},
    {'name': 'Wheel Alignment', 'description': 'Wheel alignment and balancing', 'icon': 'settings'},
    {'name': 'Clutch Service', 'description': 'Clutch plate and assembly service', 'icon': 'swap_vert'},
]

service_types = []
for data in service_types_data:
    st, _ = ServiceType.objects.get_or_create(name=data['name'], defaults=data)
    service_types.append(st)
    print(f"  ✅ Service Type: {st.name}")

# Create Users
# 1. Vehicle Owner
user1 = User.objects.create_user(
    username='user1', email='user1@test.com', password='password123',
    first_name='Rajesh', last_name='Kumar', role='user',
    phone='9876543210', city='Chennai', state='Tamil Nadu', pincode='600001',
    latitude=13.0827, longitude=80.2707
)
Token.objects.get_or_create(user=user1)
print(f"  ✅ User: {user1.username}")

user2 = User.objects.create_user(
    username='user2', email='user2@test.com', password='password123',
    first_name='Priya', last_name='Sharma', role='user',
    phone='9876543211', city='Chennai', state='Tamil Nadu', pincode='600002',
    latitude=13.0500, longitude=80.2500
)
Token.objects.get_or_create(user=user2)
print(f"  ✅ User: {user2.username}")

# 2. Service Center Owners
owner1 = User.objects.create_user(
    username='owner1', email='owner1@test.com', password='password123',
    first_name='Suresh', last_name='Mechanics', role='owner',
    phone='9876543220', city='Chennai', state='Tamil Nadu', pincode='600001'
)
Token.objects.get_or_create(user=owner1)
print(f"  ✅ Owner: {owner1.username}")

owner2 = User.objects.create_user(
    username='owner2', email='owner2@test.com', password='password123',
    first_name='Vijay', last_name='Auto', role='owner',
    phone='9876543221', city='Chennai', state='Tamil Nadu', pincode='600003'
)
Token.objects.get_or_create(user=owner2)
print(f"  ✅ Owner: {owner2.username}")

# 3. Mechanics
mech1_user = User.objects.create_user(
    username='mechanic1', email='mech1@test.com', password='password123',
    first_name='Arjun', last_name='Rajan', role='mechanic',
    phone='9876543230'
)
Token.objects.get_or_create(user=mech1_user)

mech2_user = User.objects.create_user(
    username='mechanic2', email='mech2@test.com', password='password123',
    first_name='Karthik', last_name='Venkat', role='mechanic',
    phone='9876543231'
)
Token.objects.get_or_create(user=mech2_user)

# Create Vehicles
v1 = Vehicle.objects.create(
    owner=user1, vehicle_type='car', make='Maruti Suzuki', model='Swift',
    year=2022, registration_number='TN01AB1234', fuel_type='petrol', color='White'
)
v2 = Vehicle.objects.create(
    owner=user1, vehicle_type='bike', make='Royal Enfield', model='Classic 350',
    year=2023, registration_number='TN01CD5678', fuel_type='petrol', color='Black'
)
v3 = Vehicle.objects.create(
    owner=user2, vehicle_type='car', make='Hyundai', model='i20',
    year=2021, registration_number='TN02EF9012', fuel_type='diesel', color='Red'
)
print(f"  ✅ Created {Vehicle.objects.count()} vehicles")

# Create Service Centers
center1 = ServiceCenter.objects.create(
    owner=owner1, name='Suresh Auto Care',
    description='Premium multi-brand car service center with latest diagnostic equipment.',
    phone='9876543220', email='suresh@autocare.com',
    address='123 Anna Salai, T Nagar', city='Chennai', state='Tamil Nadu', pincode='600017',
    latitude=13.0418, longitude=80.2341, average_rating=4.5, total_reviews=120,
    opening_time='08:00', closing_time='20:00', working_days='Mon,Tue,Wed,Thu,Fri,Sat'
)

center2 = ServiceCenter.objects.create(
    owner=owner2, name='Vijay Speed Motors',
    description='Expert bike and car servicing with quick turnaround time.',
    phone='9876543221', email='vijay@speedmotors.com',
    address='456 Mount Road, Guindy', city='Chennai', state='Tamil Nadu', pincode='600032',
    latitude=13.0067, longitude=80.2206, average_rating=4.2, total_reviews=85,
    opening_time='09:00', closing_time='19:00', working_days='Mon,Tue,Wed,Thu,Fri,Sat,Sun'
)
print(f"  ✅ Created {ServiceCenter.objects.count()} service centers")

# Add services to centers
import random
for center in [center1, center2]:
    for st in service_types:
        ServiceCenterService.objects.create(
            service_center=center, service_type=st,
            price=random.randint(500, 5000),
            estimated_duration=random.randint(30, 180),
            description=f'{st.name} at {center.name}'
        )

# Create Time Slots
from datetime import time
for center in [center1, center2]:
    slots = [
        (time(8, 0), time(9, 0)),
        (time(9, 0), time(10, 0)),
        (time(10, 0), time(11, 0)),
        (time(11, 0), time(12, 0)),
        (time(14, 0), time(15, 0)),
        (time(15, 0), time(16, 0)),
        (time(16, 0), time(17, 0)),
        (time(17, 0), time(18, 0)),
    ]
    for start, end in slots:
        TimeSlot.objects.create(
            service_center=center, start_time=start, end_time=end, max_bookings=3
        )

# Create Mechanics
mech1 = Mechanic.objects.create(
    user=mech1_user, service_center=center1,
    specialization='Engine Specialist', experience_years=8
)
mech2 = Mechanic.objects.create(
    user=mech2_user, service_center=center2,
    specialization='Electrical & AC Expert', experience_years=5
)
print(f"  ✅ Created {Mechanic.objects.count()} mechanics")

# Create superuser
if not User.objects.filter(is_superuser=True).exists():
    admin = User.objects.create_superuser(
        username='admin', email='admin@test.com', password='admin123',
        first_name='Admin', last_name='User', role='owner'
    )
    Token.objects.get_or_create(user=admin)
    print(f"  ✅ Superuser: admin / admin123")

print("\n🎉 Seed data created successfully!")
print("\n📋 Login Credentials:")
print("  User 1:    user1 / password123")
print("  User 2:    user2 / password123")
print("  Owner 1:   owner1 / password123")
print("  Owner 2:   owner2 / password123")
print("  Mechanic1: mechanic1 / password123")
print("  Mechanic2: mechanic2 / password123")
print("  Admin:     admin / admin123")
