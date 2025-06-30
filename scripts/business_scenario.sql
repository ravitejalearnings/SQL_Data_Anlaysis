use [datawarehouse_analytics]

select top 10 * from dim_customer

select top 10 * from dim_products

select top 10 * from fact_sales

=========================================================================
-- Trends & change over time 
-- Analayze sales over years
=========================================================================

select
	year(order_date) as year,
	sum(sales) as total_sales,
	count(distinct customer_key) as total_customers,
	sum(quantity) as total_qty
from fact_sales
where order_date is not null
group by year(order_date)
order by year(order_date)

------------------------------------------------------------------------------------------------------------------------
-- Analayze sales over month
-- understanding seasonality/patterns over months in our data

select
	month(order_date) as month,
	sum(sales) as total_sales,
	count(distinct customer_key) as total_customers,
	sum(quantity) as total_qty
from fact_sales
where order_date is not null
group by month(order_date)
order by month(order_date)

------------------------------------------------------------------------------------------------------------------------

select
	year(order_date) as year,
	month(order_date) as month,
	sum(sales) as total_sales,
	count(distinct customer_key) as total_customers,
	sum(quantity) as total_qty
from fact_sales
where order_date is not null and 
group by year(order_date), month(order_date)
order by year(order_date), month(order_date)


=========================================================================
-- Cummulative Analysis
=========================================================================
-- cummulative sales over date

select
	order_date,
	sales,
	sum(sales) over(order by order_date) as cum_sales
from fact_sales
where order_date is not null


------------------------------------------------------------------------------------------------------------------------
-- cummulative sales over month

with cte1 as (
select
	cast(year(order_date) as varchar)+ '-' + cast(month(order_date) as varchar) as year_month,
	sum(sales) as sales
from fact_sales
where order_date is not null
group by cast(year(order_date) as varchar)+ '-' + cast(month(order_date) as varchar)
)
select 
	*,
	sum(sales) over(order by year_month ) as cumm_sales
from cte1



=========================================================================
-- performance Analysis
=========================================================================

-- Analyze yearly performance of products by comparing their sales to both avg sales performance of products & prev year sales

with cte as (
	select
		year(order_date) as year,
		p.product_name as product_name,
		sum(s.sales) as sales
	from fact_sales as s
	join dim_products as p
	on s.product_key = p.product_id
	where order_date is not null
	group by year(order_date), p.product_name
)
select 
	year, 
	product_name, 
	sales ,
	avg(sales) over(partition by product_name) as avg_sales,
	case
		when (sales - avg(sales) over(partition by product_name)) > 0 then 'above avg'
		when (sales - avg(sales) over(partition by product_name)) < 0 then 'below avg'
		else 'avg'
	end as diff_avg_sales,
	lag(sales,1) over(partition by product_name order by year ) as py_sales,
	case
		when (sales - lag(sales,1) over(partition by product_name order by year )) > 0 then 'increase'
		when (sales - lag(sales,1) over(partition by product_name order by year )) < 0 then 'decrease'
		when (sales - lag(sales,1) over(partition by product_name order by year )) is null then 'n/a'
		else 'no change'
	end as diff_sales
from cte


=========================================================================
-- Part-to_whole analysis
=========================================================================

-- which category contribute the most to overall sales

with cte as (
select
	p.category,
	sum(s.sales) as sales
from fact_sales as s
join dim_products as p
on p.product_id = s.product_key
group by p.category
)
select 
	*, 
	sum(sales) over() as total_sales,
	(cast(sales as float)/ sum(sales) over(partition by category)) as sales_contribution
from cte
	
=========================================================================
-- Data Segmentation analysis
=========================================================================

-- segment products into sales ranges and count how many products fall into each segment.

with cte as (
select
	s.product_key,
	p.product_name,
	s.sales,
	case 
		when s.sales > 3500 then 'High'
		when s.sales >= 1000 and s.sales <= 3500 then 'Medium'
		when s.sales < 1000 then 'Low'
	end as sales_category
from fact_sales as s
left join dim_products as p
on s.product_key = p.product_key
)
select 
	sales_category, 
	count(product_key) as product_count
from cte
group by sales_category
order by product_count desc


------------------------------------------------------------------------------------------------------------------------


-- segment customers into 3 categories VIP, Regular, New
--		VIP: customers with atleast 12 months of lifespan & spending > 5000
--		Regular: customers with atleast 12 months of lifespan & spending < 5000
--		New: customers with lifespan less than 12 months
-- also find total number of customers

with cte1 as (
select
	c.customer_key,
	sum(s.sales) as sales,
	min(s.order_date) as first_order,
	max(s.order_date) as last_order,
	datediff(month, min(s.order_date), max(s.order_date)) as lifespan

from fact_sales as s
left join dim_customer as c
on s.customer_key = c.customer_key
where s.order_date is not null
group by c.customer_key
)
select 
	case
		when lifespan < 12 then 'New'
		when lifespan >= 12 and sales <= 5000 then 'Regular'
		when lifespan > 12 and sales > 5000 then 'VIP'
	end as lifespan_category,
	count(customer_key) as total_customers
from cte1
group by
	case
		when lifespan < 12 then 'New'
		when lifespan >= 12 and sales <= 5000 then 'Regular'
		when lifespan > 12 and sales > 5000 then 'VIP'
	end 
