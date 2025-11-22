-- total revenue
select 
	round(sum(oi.total_value)) as revenue
from order_items oi 
join orders o on oi.order_id = o.order_id 
where order_status = 'delivered';

-- total order dan total customer
select 
	count(distinct order_id) as total_order,
	count(distinct customer_id) as total_customer
from orders o 
where order_status = 'delivered';

-- revenue per kategori
select 
	p.product_category_name,
	round(sum(oi.total_value)) as revenue_per_category
from products p 
join order_items oi on oi.product_id = p.product_id
join orders o on o.order_id = oi.order_id 
where order_status = 'delivered'
group by p.product_category_name
order by revenue_per_category desc;

-- revenue per product_id
select 
	p.product_id,
	p.product_category_name,
	round(sum(oi.total_value)) as revenue_per_product
from products p 
join order_items oi on oi.product_id = p.product_id 
join orders o on o.order_id = oi.order_id 
where o.order_status = 'delivered'
group by p.product_id, p.product_category_name
order by revenue_per_product desc;

-- revenue per bulan
select 
	date_trunc('month', o.order_purchase_timestamp) as month,
	round(sum(oi.total_value)) as revenue_per_month
from orders o 
join order_items oi on oi.order_id = o.order_id
where order_status = 'delivered'
group by month
order by month;

-- pelanggan dengan pengeluaran terbanyak
select 
	c.customer_id,
	c.customer_city,
	c.customer_state,
	round(sum(oi.total_value)) as customers_spent
from customers c  
join orders o on o.customer_id = c.customer_id 
join order_items oi on oi.order_id = o.order_id
where order_status = 'delivered'
group by c.customer_id, c.customer_city, c.customer_state 
order by customers_spent desc
limit 10;

-- revenue per month + count distinct orders, untuk lihat bulan mana yang kecil
select
  date_trunc('month', o.order_purchase_timestamp)::date as month,
  count(distinct o.order_id) as order_count,
  round(sum(oi.total_value)) as revenue_per_month
from order_items oi
join orders o on oi.order_id = o.order_id
where o.order_status = 'delivered'
group by date_trunc('month', o.order_purchase_timestamp)
order by month;

-- periksa semua order di bulan 2016-09
select
  o.order_id,
  o.order_purchase_timestamp::date as purchase_date,
  o.order_status,
  sum(oi.total_value) as order_total,
  count(*) as items_count
from order_items oi
join orders o on oi.order_id = o.order_id
where date_trunc('month', o.order_purchase_timestamp)::date = '2016-09-01'
group by o.order_id, o.order_purchase_timestamp, o.order_status
order by order_total desc;
