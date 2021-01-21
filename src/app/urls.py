from django.conf.urls import include
from django.urls import path

urlpatterns = [
    path('healthcheck/', include('healthcheck.urls')),
]
