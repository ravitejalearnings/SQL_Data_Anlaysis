
=========================================================================
-- Customer report
=========================================================================

-- Highlight;-
	-- gather essientail fields such as names, ages and transaction details
	-- segment customer into VIP/Regular/New & age groups
	-- Aggregate customer level details
		-- total orders
		-- total sales
		-- total quantity purchased
		-- total products
		-- lifespan in months
	-- calculate KPI like
		-- recency
		-- avgerage order value
		-- average monthly spend

create view vw_customer_report as 
	with base_query as (
		select
			s.order_number,
			s.order_date,
			s.price,
			s.quantity,
			s.sales,
			c.customer_key,
			c.customer_number,
			concat(c.first_name,' ', c.last_name) as customer_name,
			datediff(year,c.birth_date,getdate()) as age

		from fact_sales as s
		left join dim_customer as c
			on s.customer_key = c.customer_key
		where s.order_date is not null
	),

	customer_segmentation as (
		select 
			customer_key,
			customer_number,
			customer_name,
			age,
			count(distinct (order_number)) as total_orders,
			sum(quantity) as total_qty,
			sum(sales) as total_sales,
			max(order_date) as last_order_date,
			datediff(month,min(order_date),max(order_date)) as lifespan
		from base_query
		group by 
			customer_key,
			customer_number,
			customer_name,age
	)

	select 
		customer_key,
		customer_number,
		customer_name,
		age,
		total_orders,
		total_qty,
		total_sales,
		last_order_date,
		case
			when lifespan < 12 then 'New'
			when lifespan >= 12 and total_sales <= 5000 then 'Regular'
			when lifespan > 12 and total_sales > 5000 then 'VIP'
		end as lifespan_category,
		case
			when age < 20 then 'under 20'
			when age between 20 and 29 then '20-29'
			when age between 30 and 39 then '30-39'
			when age between 40 and 49 then '40-49'
			else '50 +'
 		end as age_group,
		datediff(month,last_order_date,getdate()) as receny,
		case
			when total_orders = 0 then 0
			else (total_sales/total_orders)
		end as avg_order_value,
	
		case
			when lifespan = 0 then total_sales
			else total_sales/lifespan
		end as avg_monthly_spend

	from customer_segmentation

select * from [dbo].[vw_customer_report]
