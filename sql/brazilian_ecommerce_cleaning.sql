-- cek kolom penting di tabel orders
select 
  count(*) filter (where order_id is null) as missing_order_id,
  count(*) filter (where customer_id is null) as missing_customer_id,
  count(*) filter (where order_status is null) as missing_order_status,
  count(*) filter (where order_purchase_timestamp is null) as missing_purchase_date,
  count(*) filter (where order_approved_at is null) as missing_approved_at,
  count(*) filter (where order_delivered_carrier_date is null) as missing_carrier_date,
  count(*) filter (where order_delivered_customer_date is null) as missing_delivered_date,
  count(*) filter (where order_estimated_delivery_date is null) as missing_estimated_date
from orders;

-- cek kolom penting di tabel customers
select 
  count(*) filter (where customer_id is null) as missing_customer_id,
  count(*) filter (where customer_unique_id is null) as missing_unique_id,
  count(*) filter (where customer_zip_code_prefix is null) as missing_zip,
  count(*) filter (where customer_city is null) as missing_city,
  count(*) filter (where customer_state is null) as missing_state
from customers;

-- cek kolom penting di tabel order_items
select 
  count(*) filter (where order_id is null) as missing_order_id,
  count(*) filter (where order_item_id is null) as missing_item_id,
  count(*) filter (where product_id is null) as missing_product_id,
  count(*) filter (where seller_id is null) as missing_seller_id,
  count(*) filter (where shipping_limit_date is null) as missing_shipping_limit_date,
  count(*) filter (where price is null) as missing_price,
  count(*) filter (where freight_value is null) as missing_freight_value
from order_items;

-- cek kolom penting di tabel products
select 
  count(*) filter (where product_id is null) as missing_product_id,
  count(*) filter (where product_category_name is null) as missing_category,
  count(*) filter (where product_name_lenght is null) as missing_name_length,
  count(*) filter (where product_description_lenght is null) as missing_description_length,
  count(*) filter (where product_photos_qty is null) as missing_photo_qty,
  count(*) filter (where product_weight_g is null) as missing_weight,
  count(*) filter (where product_length_cm is null) as missing_length,
  count(*) filter (where product_height_cm is null) as missing_height,
  count(*) filter (where product_width_cm is null) as missing_width
from products;

-- isi kategori yang kosong jadi 'unknown'
update products
set product_category_name = 'unknown'
where product_category_name is null;

-- hapus baris yang punya data dimensi/berat kosong
delete from products
where product_weight_g is null
   or product_length_cm is null
   or product_height_cm is null
   or product_width_cm is null;

-- rapihin kategori biar konsisten (huruf besar di awal, tanpa spasi)
update products
set product_category_name = initcap(trim(product_category_name));

-- rapihin status order, ubah ke huruf kecil dan hapus spasi
update orders
set order_status = lower(trim(order_status));

-- ubah kolom timestamp jadi format date
alter table orders
alter column order_purchase_timestamp type timestamp using order_purchase_timestamp::timestamp,
alter column order_approved_at type timestamp using order_approved_at::timestamp,
alter column order_delivered_carrier_date type timestamp using order_delivered_carrier_date::timestamp,
alter column order_delivered_customer_date type timestamp using order_delivered_customer_date::timestamp,
alter column order_estimated_delivery_date type timestamp using order_estimated_delivery_date::timestamp;

-- ubah nilai kosong di kolom tanggal jadi null
update orders
set order_approved_at = null
where trim(order_approved_at::text) = '';

update orders
set order_delivered_carrier_date = null
where trim(order_delivered_carrier_date::text) = '';

update orders
set order_delivered_customer_date = null
where trim(order_delivered_customer_date::text) = '';

update orders
set order_estimated_delivery_date = null
where trim(order_estimated_delivery_date::text) = '';

-- ubah kolom tanggal ke tipe date
alter table orders
alter column order_purchase_timestamp type date using order_purchase_timestamp::date,
alter column order_approved_at type date using order_approved_at::date,
alter column order_delivered_carrier_date type date using order_delivered_carrier_date::date,
alter column order_delivered_customer_date type date using order_delivered_customer_date::date,
alter column order_estimated_delivery_date type date using order_estimated_delivery_date::date;

-- cek range tanggal untuk validasi
select 
  min(order_purchase_timestamp) as first_order,
  max(order_purchase_timestamp) as last_order
from orders;

-- rapihin data kota dan state
update customers
set 
  customer_city = lower(trim(customer_city)),
  customer_state = upper(trim(customer_state));

-- ubah kolom zip code jadi text (biar gak error kalau ada angka 0 di depan)
alter table customers
alter column customer_zip_code_prefix type text using trim(customer_zip_code_prefix::text);

-- ubah tipe data harga dan ongkir ke numeric
alter table order_items
alter column price type numeric(10,2) using price::numeric(10,2),
alter column freight_value type numeric(10,2) using freight_value::numeric(10,2);

-- tambahkan kolom baru 'total_value' (harga + ongkir)
alter table order_items
add column total_value numeric(10,2);

-- isi nilai kolom total_value
update order_items
set total_value = price + freight_value;

-- cek total baris dan id unik di tiap tabel
select count(*) as total_orders, count(distinct order_id) as unique_orders from orders;
select count(*) as total_items, count(distinct order_id) as unique_orders_in_items from order_items;
select count(*) as total_customers, count(distinct customer_id) as unique_customers from customers;
select count(*) as total_products, count(distinct product_id) as unique_products from products;
