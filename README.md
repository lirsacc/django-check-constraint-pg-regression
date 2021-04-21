# Django migration issue reproduction

Trying to confirm and minimally reproduce a Django issues with CheckConstraint in migrations against Postgres 9.6+.

## How to reproduce:

### Starting point

Commit 938f1ba93562 is a boilerplate Django app (using Postgres) with a `prices` app installed but not migrated. I'd run the initial migrations before setting up the `prices` app but that shouldn't impact the rest.

The run was on Python 3.7 and Postgres 11, but I've run into the issue against Postgres 9.6 before.

### Django 2.2 (working state) 

- `pip install -r requirements.django2.2.txt`
- `python manage.py makemigrations prices`
- `python manage.py sqlmigrate prices 0001_initial >| sqlmigrate.sql`
- `python manage.py migrate prices >| migrate.log 2>&1`

This generates correct SQL and the migration works. The state is saved in commit 042f7ad5a2e7.

Before trying this on other version run: `python manage.py migrate prices zero`.

### Django 3.1 (broken state) 

Running the same step as before:

- `pip install -r requirements.django3.1.txt`
- `python manage.py makemigrations prices`
- `python manage.py sqlmigrate prices 0001_initial >| sqlmigrate.sql`
- `python manage.py migrate prices >| migrate.log 2>&1`

We can see the migration fails, the state is saved in commit c9c254bbacae. The core difference can be seen in sqlmigrate:

```
$ git diff 042f7ad5a2e7 c9c254bbacae -- sqlmigrate.sql
diff --git a/sqlmigrate.sql b/sqlmigrate.sql
index 7cd6e04482f2..d686b9efd43b 100644
--- a/sqlmigrate.sql
+++ b/sqlmigrate.sql
@@ -6,9 +6,9 @@ CREATE TABLE "prices_price" ("id" serial NOT NULL PRIMARY KEY, "price" integer N
 --
 -- Create constraint on_sale_check on model price
 --
-ALTER TABLE "prices_price" ADD CONSTRAINT "on_sale_check" CHECK ("on_sale" = ("prices_price"."price" < ("prices_price"."price_previous")));
+ALTER TABLE "prices_price" ADD CONSTRAINT "on_sale_check" CHECK ("on_sale" = "price" < "price_previous");
 --
 -- Create constraint price_lte_price_previous on model price
 --
-ALTER TABLE "prices_price" ADD CONSTRAINT "price_lte_price_previous" CHECK ("price" <= ("price_previous"));
+ALTER TABLE "prices_price" ADD CONSTRAINT "price_lte_price_previous" CHECK ("price" <= "price_previous");
 COMMIT;
```

The SQL for the constraint `on_sale_check` is now invalid. The `price_lte_price_previous` constraint is affected but not to the point of being invalid.


### Django 3.0 and 3.2

Commit c6c231c3e0c7 and 5cfb952d1cb4 do the same with 3.0 and 3.1 and the SQL is slightly different but the core issue is the same. (There are requirements files specifically for this).

### Try a simplified spelling

From our understanding Django >3 supports a simpler spelling, dropping the requirement for `ExpressionWrapper`.

Commit 0116d0a8ed9d runs the same steps as above but using that different spelling (sticking to 3.2). The migration is different but the generated sql is not and migrations still fail.
