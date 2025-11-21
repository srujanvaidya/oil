from django.db import models
from django.contrib.auth.models import User

class Product(models.Model):
    TYPE_CHOICES=(
    ("seeds","Seeds"),
    ("byproduct","Byproduct"),
    )
    owner=models.ForeignKey(User , on_delete=models.CASCADE)
    type = models.CharField(max_length=20,choices=TYPE_CHOICES)
    product_name=models.CharField(max_length=100)
    date_of_listing=models.DateField()
    certificate=models.FileField(upload_to="certificates/", null=True, blank=True)
    amount_kg=models.DecimalField(max_digits=10,decimal_places=2)

    market_price_per_kg_inr=models.DecimalField(max_digits=10,decimal_places=2,null=True,blank=True)
    created_at=models.DateTimeField(auto_now_add=True)

