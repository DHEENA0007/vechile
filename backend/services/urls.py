from django.urls import path
from . import views

urlpatterns = [
    # Public
    path('types/', views.ServiceTypeListView.as_view(), name='service-types'),
    path('search/', views.ServiceCenterSearchView.as_view(), name='service-center-search'),
    path('centers/<uuid:pk>/', views.ServiceCenterDetailView.as_view(), name='service-center-detail'),

    # Owner management
    path('owner/dashboard/', views.OwnerDashboardView.as_view(), name='owner-dashboard'),
    path('owner/centers/', views.OwnerServiceCenterListCreateView.as_view(), name='owner-centers'),
    path('owner/centers/<uuid:pk>/', views.OwnerServiceCenterDetailView.as_view(), name='owner-center-detail'),
    path('owner/centers/<uuid:center_id>/services/', views.OwnerServiceManageView.as_view(), name='owner-services'),
    path('owner/services/<uuid:pk>/', views.OwnerServiceDetailView.as_view(), name='owner-service-detail'),
    path('owner/centers/<uuid:center_id>/timeslots/', views.OwnerTimeSlotManageView.as_view(), name='owner-timeslots'),
    path('owner/timeslots/<uuid:pk>/', views.OwnerTimeSlotDetailView.as_view(), name='owner-timeslot-detail'),
    path('owner/centers/<uuid:center_id>/mechanics/', views.OwnerMechanicListCreateView.as_view(), name='owner-mechanics'),
    path('owner/mechanics/<uuid:pk>/', views.OwnerMechanicDetailView.as_view(), name='owner-mechanic-detail'),
]
