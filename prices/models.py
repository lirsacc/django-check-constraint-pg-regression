from django.db import models


class Price(models.Model):
    price = models.IntegerField(null=False)
    price_previous = models.IntegerField(null=False)
    on_sale = models.BooleanField(null=False)

    class Meta:
        constraints = (
            models.CheckConstraint(
                check=models.Q(on_sale=models.Q(price__lt=models.F('price_previous'))),
                name='on_sale_check',
            ),
            models.CheckConstraint(
                check=models.Q(price__lte=models.F('price_previous')),
                name='price_lte_price_previous',
            ),
        )
