from django.shortcuts import render
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
import jwt, datetime
from django.conf import settings
from rest_framework.decorators import api_view,permission_classes

#Registration
@api_view(['POST'])
def register(request):
    username=request.data.get("username")
    email=request.data.get("email")
    password=request.data.get("password")

    if not username or not email or not password:
        return Response({"error":"All fields required "},status=400)

    if User.objects.filter(username=username).exists():
        return Response({"error":"Username already exists"},status=400)

    if User.objects.filter(email=email).exists():
        return Response({"error":"email already exists"},status=400)

    user=User.objects.create_user(username=username,email=email,password=password)

    return Response({"message":"User registered successfully"})

#Login
@api_view(['POST'])
def login(request):
    email=request.data.get("email")
    password=request.data.get("password")
    #email
    try:
        user=User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({"error":"Invalid credentials"},status=400)
    #password
    user_auth=authenticate(username=user.username,password=password)
    if not user_auth:
        return Response({"error":"Invalid credentials"},status=400)

    #JWT token
    payload={
        "id": user.id,
        "exp": datetime.datetime.utcnow()+datetime.timedelta(days=1),
        "iat": datetime.datetime.utcnow()
    }
    token = jwt.encode(payload,settings.SECRET_KEY,algorithm="HS256")

    return Response({"token":token,"username":user.username})

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def profile(request):
    user = request.user
    return Response({
        "username":user.username,
        "email":user.email,
    })

#LOGOUT
@api_view(['POST'])
def logout(request):
    return Response({"message":"Logout handled on client side"})






