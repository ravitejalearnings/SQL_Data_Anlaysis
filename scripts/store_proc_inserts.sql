
======================================================================
--			loading data into dim_customer, dim_products, fact_sales
======================================================================

-- loading data into dim_customer

create or alter procedure gold_layer_tables_inserts as 

begin

	Truncate table dim_customer;
	insert into dim_customer 
	select * from [datawarehouse].[gold].[dim_customer]

	-- loading data into dim_products

	Truncate table dim_products;

	insert into dim_products 
	select * from [datawarehouse].[gold].[dim_products]

	-- loading data into fact_sales

	Truncate table fact_sales;
	insert into fact_sales 
	select * from [datawarehouse].[gold].[fact_sales]
end

exec gold_layer_tables_inserts
