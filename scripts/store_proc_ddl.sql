
create or alter procedure gold_layer_tables_ddl as 
begin
	if object_id('dim_customer', 'U') is not null
		drop table dim_customer;

	create table dim_customer(
		customer_key int,
		customer_id int,
		customer_number nvarchar(50),
		first_name  nvarchar(50),
		last_name  nvarchar(50),
		country  nvarchar(50),
		marital_status  nvarchar(10),
		gender  nvarchar(10),
		birth_date  date,
		create_date  date
	);

	-- ddl for dim_products
	if object_id('dim_products', 'U') is not null
		drop table dim_products;

	create table dim_products(
		product_key  int,
		product_id  int,
		product_number nvarchar(50),
		product_name nvarchar(50),
		category_id nvarchar(50),
		category nvarchar(50),
		subcategory nvarchar(50),
		maintenance nvarchar(5),
		cost int,
		product_line nvarchar(50),
		start_date date
	);

	-- ddl for fact_sales
	if object_id('fact_sales', 'U') is not null
		drop table fact_sales;

	create table fact_sales(
		order_number nvarchar(50),
		product_key int,
		customer_key int,
		order_date date,
		shipment_date date,
		due_date date,
		sales int,
		quantity int,
		price int
	);

end

exec gold_layer_tables_ddl
