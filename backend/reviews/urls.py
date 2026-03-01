from django.urls import path
from . import views

urlpatterns = [
    path('create/', views.ReviewCreateView.as_view(), name='review-create'),
    path('center/<uuid:center_id>/', views.ServiceCenterReviewListView.as_view(), name='center-reviews'),
    path('user/', views.UserReviewListView.as_view(), name='user-reviews'),
    path('owner/', views.OwnerReviewListView.as_view(), name='owner-reviews'),
    path('owner/<uuid:pk>/reply/', views.OwnerReplyReviewView.as_view(), name='owner-reply-review'),
]
