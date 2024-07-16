USE BikeStores
GO
-- PROBLEM
/*
Question:
- What is the condition of the sales activity within the company? 
- Provide insights related to sales volume over 2016 to 2018 period?
- Revenue per region? per store? per category? per brand?
*/
GO

-- COLLECT THE DATA BY SUMMARIZING THE SALE FIGURES AND CREATE A VIEW TO STORE IT
-- DROP VIEW IF EXISTS Data_for_analysis
CREATE VIEW Data_for_analysis AS
SELECT 
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS Customer,
    c.city,
    c.state,
    o.order_date,
    p.product_name,
    cat.category_name,
    s.store_name,
    CONCAT(st.first_name, ' ', st.last_name) AS Employee,
    SUM(oi.quantity) AS Total_unit,
    SUM(oi.quantity * oi.list_price) AS Revenue
FROM sales.orders o
JOIN sales.customers c ON o.customer_id = c.customer_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
JOIN production.products p ON oi.product_id = p.product_id
JOIN production.categories cat ON p.category_id = cat.category_id
JOIN sales.stores s ON s.store_id = o.store_id
JOIN sales.staffs st ON o.staff_id = st.staff_id
GROUP BY
    o.order_id,
    c.first_name,
    c.last_name,
    c.city,
    c.state,
    o.order_date,
    p.product_name,
    cat.category_name,
    s.store_name,
    st.first_name,
    st.last_name;
GO


-- DATA CLEANING 

-- Check for data types
SELECT COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='Data_for_analysis'


-- Check for null values
--- Get all column names in the data
DECLARE @columns NVARCHAR(255)
SET @columns = (
	SELECT STRING_AGG(COLUMN_NAME,',')
	FROM information_schema.columns 
	where table_name = 'Data_for_analysis')

--- Find rows containing null values
SELECT *
FROM Data_for_analysis
WHERE COALESCE(@columns, null) IS NULL

/* If there were null values
DELETE FROM Data_for_analysis
WHERE COALESCE(@columns, null) IS NULL
*/

-- Check for duplicates


-- Change TX, NY, CA into Texas, New York and California in sales.customers table


SELECT *, ROW_NUMBER() OVER (PARTITION BY customer, city, state, order_date, product_name, category_name ORDER BY order_id)
FROM Data_for_analysis

SELECT *
from sales.customers