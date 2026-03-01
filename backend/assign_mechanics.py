import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'vehicle_service.settings')
django.setup()

from accounts.models import User
from services.models import ServiceCenter, Mechanic

mechanics_users = User.objects.filter(role='mechanic', mechanic_profile__isnull=True)
if not mechanics_users.exists():
    print("No orphaned mechanics found.")
else:
    center = ServiceCenter.objects.first()
    if not center:
        print("No service centers exist. Cannot assign orphaned mechanics.")
    else:
        for user in mechanics_users:
            Mechanic.objects.create(
                user=user,
                service_center=center,
                specialization="General Services",
                experience_years=3
            )
            print(f"Assigned orphan mechanic '{user.username}' to center '{center.name}'")
