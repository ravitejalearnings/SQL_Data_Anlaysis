
=========================================================================
-- Product summary report
=========================================================================

-- Gather neccessary feilds required for creating of Product summary report
	-- segment products by revenue to identify High-performers, Mid-range, Low-performers
	-- aggregate product-level metrics
		-- total orders
		-- total sales
		-- total quantity sold
		-- total customers
		-- lifespan
	--	calculate other KPI's
		-- recency
		-- avg order value
		-- avg monthly revenue

create view VW_product_report as 
with base_query as (
	select 
		p.product_key,
		p.product_number,
		p.product_name,
		p.category,
		p.subcategory,
		s.order_number,
		s.sales,
		s.quantity,
		s.order_date

	from 
	fact_sales as s
	left join dim_products as p
	on p.product_key = s.product_key
	where s.order_date is not null
)
select 
	product_key,
	product_number,
	product_name,
	category,
	subcategory,
	count(distinct order_number) as total_orders,
	sum(sales) as total_sales,
	sum(quantity) as total_qty,
	datediff(month,max(order_date),getdate()) as lifespan,
	max(order_date) as last_sale_date
from base_query
group by product_key,
	product_number,
	product_name,
	category,
	subcategory

SELECT * FROM [dbo].[VW_product_report]
