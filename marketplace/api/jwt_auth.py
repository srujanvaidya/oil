import jwt
from django.conf import settings
from django.contrib.auth.models import User
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed

class JWTAuthentication(BaseAuthentication):
    def authenticate(self,request):
        token=request.headers.get('Authorization')

        if not token:
            return None

        try:
            token = token.split(" ")[1]
            payload=jwt.decode(token,settings.SECRET_KEY,algorithms=["HS256"])
        except Exception:
            raise AuthenticationFailed("Invalid or expired token")

        try:
            user=User.objects.get(id=payload["id"])
        except User.DoesNotExist:
            raise AuthenticationFailed("user not found")

        return(user,None)
