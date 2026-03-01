from django.urls import path
from . import views

urlpatterns = [
    # User bookings
    path('user/create/', views.UserBookingCreateView.as_view(), name='user-booking-create'),
    path('user/', views.UserBookingListView.as_view(), name='user-booking-list'),
    path('user/<uuid:pk>/', views.UserBookingDetailView.as_view(), name='user-booking-detail'),
    path('user/<uuid:pk>/cancel/', views.UserCancelBookingView.as_view(), name='user-booking-cancel'),
    path('user/<uuid:pk>/approve-estimate/', views.UserApproveEstimateView.as_view(), name='user-approve-estimate'),
    path('user/dashboard/', views.UserDashboardView.as_view(), name='user-dashboard'),

    # Owner bookings
    path('owner/', views.OwnerBookingListView.as_view(), name='owner-booking-list'),
    path('owner/<uuid:pk>/', views.OwnerBookingDetailView.as_view(), name='owner-booking-detail'),
    path('owner/<uuid:pk>/action/', views.OwnerBookingActionView.as_view(), name='owner-booking-action'),
    path('owner/<uuid:pk>/assign-mechanic/', views.OwnerAssignMechanicView.as_view(), name='owner-assign-mechanic'),

    # Mechanic
    path('mechanic/', views.MechanicJobListView.as_view(), name='mechanic-job-list'),
    path('mechanic/<uuid:pk>/', views.MechanicJobDetailView.as_view(), name='mechanic-job-detail'),
    path('mechanic/<uuid:pk>/update-status/', views.MechanicUpdateStatusView.as_view(), name='mechanic-update-status'),
    path('mechanic/dashboard/', views.MechanicDashboardView.as_view(), name='mechanic-dashboard'),

    # Invoice
    path('invoice/create/<uuid:pk>/', views.CreateInvoiceView.as_view(), name='create-invoice'),
    path('invoice/<uuid:pk>/', views.InvoiceDetailView.as_view(), name='invoice-detail'),
    path('invoice/<uuid:pk>/pay/', views.PayInvoiceView.as_view(), name='pay-invoice'),
    path('invoice/<uuid:pk>/razorpay/create-order/', views.CreateRazorpayOrderView.as_view(), name='razorpay-create-order'),
    path('invoice/<uuid:pk>/razorpay/verify/', views.VerifyRazorpayPaymentView.as_view(), name='razorpay-verify'),

    # Notifications
    path('notifications/', views.NotificationListView.as_view(), name='notification-list'),
    path('notifications/<uuid:pk>/read/', views.MarkNotificationReadView.as_view(), name='mark-notification-read'),
    path('notifications/read-all/', views.MarkAllNotificationsReadView.as_view(), name='mark-all-read'),

    # Revenue
    path('revenue/', views.RevenueReportView.as_view(), name='revenue-report'),
]
