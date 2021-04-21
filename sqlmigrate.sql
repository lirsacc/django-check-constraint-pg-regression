BEGIN;
--
-- Create model Price
--
CREATE TABLE "prices_price" ("id" bigserial NOT NULL PRIMARY KEY, "price" integer NOT NULL, "price_previous" integer NOT NULL, "on_sale" boolean NOT NULL);
--
-- Create constraint on_sale_check on model price
--
ALTER TABLE "prices_price" ADD CONSTRAINT "on_sale_check" CHECK ("on_sale" = "price" < "price_previous");
--
-- Create constraint price_lte_price_previous on model price
--
ALTER TABLE "prices_price" ADD CONSTRAINT "price_lte_price_previous" CHECK ("price" <= "price_previous");
COMMIT;
