/* In this projectI will be creating 7 tables namely
1. Calendar 
2. Customer Table
3. Product 
4. Product Category
5. Product sub-category
6. Returns Data
7. Sales Data (2020, 2021, 2022)
8. territory data

I will start off with the first table which i the calendar table.The calendar table consist of only 1 column which is the date*/

CREATE TABLE  calendar(
	OrderDate 	DATE PRIMARY KEY
);

SELECT * FROM calendar

DROP TABLE calendar;
/* The next table is the customer table. This table contains 13 columns*/

CREATE TABLE  customer_lookup(
	
	customerKey		VARCHAR(20) PRIMARY KEY,
	prefix		    VARCHAR(2),
	first_name 	    VARCHAR(50),
    last_name 	    VARCHAR(50),
	birthDate		DATE,
    maritalstatus   VARCHAR(50),
	gender          VARCHAR(50),
	emailAddress    VARCHAR(50),
    annualIncome    INT,
    totalAnnual     INT,
    educationlevel	VARCHAR(50),
    Occupation      VARCHAR(50),
    HomeOwner       VARCHAR(50)
	
);

SELECT * FROM customer_lookup;

ALTER TABLE customer_lookup
ALTER COLUMN prefix TYPE VARCHAR(20); -- This was done to eliminate the error thrown back when importing the data

ALTER TABLE customer_lookup
RENAME COLUMN totalannual TO totalChildren;

SELECT datname, pg_encoding_to_char(encoding) FROM pg_database WHERE datname = 'miniProject';




/* The other table is the product category. The product category table has 2 columns*/

CREATE TABLE  Product_Category(

	ProductCategoryKey		    VARCHAR(20) PRIMARY KEY,
	ProductCategoryName			VARCHAR(20)
)

SELECT * FROM product_category;


/*Product lookup table. Contains 11 columns */

CREATE TABLE product_lookup(

	productkey 			VARCHAR(20) PRIMARY KEY,
	productSKU 		    VARCHAR (20), 
    productName			VARCHAR(150),
    modelName			VARCHAR(50),
	productDescription 	VARCHAR(300),
	productColour		VARCHAR(15),
	productSize			VARCHAR(10),
	productCost		    DECIMAL(4,2),
	productPrice		DECIMAL(4,2)
	
);

SELECT * FROM product_lookup

ALTER TABLE product_lookup
ALTER COLUMN productprice TYPE DECIMAL(10,4)



ALTER TABLE product_lookup
ADD COLUMN productSubcategoryKey VARCHAR(20)  REFERENCES ProductsubCategory(productSubcategorykey);


 -- This column wass dropped because it was irrelevant to the analysis.
-- also the values in this column cannot be defined and are inconsistent.

CREATE TABLE ProductsubCategory(
	productSubcategorykey 	VARCHAR(50) PRIMARY KEY,
	subCategoryName 	    VARCHAR(50)
	
)

-- Added another column to the Subcategory table.
ALTER TABLE productsubCategory
ADD COLUMN productCategorykey VARCHAR(20)  REFERENCES Product_Category(ProductCategoryKey)

SELECT * FROM productsubcategory;

CREATE TABLE  returns_lookup(

	returns_date 	DATE,
	territorykey	VARCHAR(20) REFERENCES territory(territoryKey),
	productKey		VARCHAR(20) REFERENCES product_lookup,
	returnQuantity  INT 

)

ALTER TABLE returns_lookup
ADD COLUMN productkey  VARCHAR (20) REFERENCES product_lookup(productkey)

select * from returns_lookup

/*ERROR:  insert or update on table "returns_lookup" violates foreign key constraint "returns_lookup_productkey_fkey"
DETAIL:  Key (productkey)=(312) is not present in table "product_lookup".*/

CREATE TABLE  territory(

	territoryKey	VARCHAR(20) PRIMARY KEY,
	region 			VARCHAR(20),
	country 		VARCHAR(20),
	continent 		VARCHAR(20)
)

SELECT * FROM territory


CREATE TABLE sales(

	productKey		VARCHAR(20) REFERENCES product_lookup(productkey),
	customerKey		VARCHAR(20) REFERENCES customer_lookup(customerKey),
	territoryKey 	VARCHAR(20) REFERENCES territory(territoryKey),
	orderlineItem 	VARCHAR(20),
	orderQuantity 	INT,
	StockDate		DATE,
	OrderNumber	    VARCHAR(20),
	OrderDate		DATE REFERENCES calendar(OrderDate)
);

SELECT * FROM sales
select * from customer_lookup
select * from product_category
select * from product_lookup
select * from productsubcategory
select * from returns_lookup
select * from calendar
select * from territory




SELECT COUNT(ordernumber) FROM sales 

SELECT COUNT(ordernumber) FROM sales
WHERE DATE_PART('YEAR',orderdate
) = 2020 
/* In 2020 the company recorded 2,630 orders*/

SELECT COUNT(ordernumber) FROM sales
WHERE  DATE_PART('year',orderdate) = 2021;
/* There were 23,935 orders placed in 2021*/

SELECT COUNT(orderNumber) FROM sales
WHERE EXTRACT('year' FROM orderdate) = 2022

-- customer_table EDA

SELECT COUNT(customerkey) FROM customer_lookup -- There are 18148 Distinct rowa in the customer data set. This indicates that there are no duplictes
SELECT DISTINCT(COUNT(*)) FROM customer_lookup -- 18148

/* Adventure works has  customers 18,148*/
SELECT  * FROM customer_lookup;

SELECT MAX(annualIncome) FROM customer_lookup; -- Highest paid customers earn 170,000

SELECT MIN(annualIncome) FROM customer_lookup; -- Lowest amount of money earned by customers is 10000

SELECT

	COUNT(CASE WHEN gender = 'M' THEN 1 END) AS male_count,
	COUNT(CASE WHEN gender ='F'THEN 1 END) AS female_count,
	COUNT(CASE WHEN gender NOT IN('F','M')THEN 1 END) AS unknown_count

FROM customer_lookup;

-- from the dataset, there are 9126 males, 8892 females and 130 unknown gender customers

SELECT customerkey, 
		annualIncome,
CASE
	 WHEN annualIncome >= 150000 THEN 'High'
	 WHEN annualIncome BETWEEN 50000 AND 150000 THEN 'Mid'
	 WHEN annualIncome <= 50000 THEN 'Low'
	 ELSE 'no range'
	 
END AS Salary_category

FROM customer_lookup -- This syntax categorizes the annual income into low, high and mid

SELECT
	COUNT(CASE WHEN annualIncome >= 150000 THEN 1 END) AS count_higherIncome,
	COUNT(CASE WHEN annualIncome BETWEEN 50000 AND 150000 THEN 1 END) AS count_midIncome,
	COUNT(CASE WHEN annualIncome <= 50000 THEN 1 END) AS count_lowIncome

FROM customer_lookup -- From the dataset, there are 300 High income earners, 10,144 Mid income earners and 8465 low income earners

SELECT 

  COUNT(CASE  WHEN homeowner = 'Y' THEN 1 END) AS count_homeowner,
  COUNT(CASE  WHEN homeowner = 'N'THEN 1 END) AS count_nothomeowner,
  COUNT(CASE  WHEN homeowner NOT IN ('Y','N') THEN 1 END) AS not_specifield
  
FROM customer_lookup

-- 12260 customers are home owners and 5888 are not homeowners

SELECT DATE_PART('year',AGE(birthdate)) AS customer_age, birthdate
FROM customer_lookup

SELECT MIN(DATE_PART('year',AGE(birthdate))) 
FROM customer_lookup

/* There were 29,481 orders placed in 2022*/

-- From the analysis made above we can conculude that the company recorded the least orders in 2020 and the highest orders in 2022

-- Find the territory that recorded the highest orders

SELECT territory.region,territory.country, SUM(orderquantity) AS TotalOrders
FROM sales
INNER JOIN territory
ON sales.territorykey = territory.territorykey
GROUP BY territory.region,territory.country 
ORDER BY SUM(orderquantity) DESC;

/* Australia recorded 17,951 orders. Central, United States recorded the least which was 30*/

/* Doing this year by year from 2020 to 2022.*/

SELECT territory.region,territory.country, SUM(orderquantity)AS TotalOrders
FROM sales
INNER JOIN territory
ON sales.territorykey = territory.territorykey
WHERE DATE_PART('year',sales.orderdate) = 2020
GROUP BY territory.region,territory.country 
ORDER BY SUM(orderquantity) DESC;

SELECT territory.region,territory.country, SUM(orderquantity) AS TotalOrders
FROM sales
INNER JOIN territory
ON sales.territorykey = territory.territorykey
WHERE DATE_PART('year',sales.orderdate) = 2021
GROUP BY territory.region,territory.country 
ORDER BY SUM(orderquantity) DESC;


-- territory
SELECT territory.region,territory.country, SUM(orderquantity) AS TotalOrders
FROM sales
INNER JOIN territory
ON sales.territorykey = territory.territorykey
WHERE DATE_PART('year',sales.orderdate) = 2022
GROUP BY territory.region,territory.country 
ORDER BY SUM(orderquantity) DESC;

SELECT territory.region,territory.country, SUM(orderquantity) AS TotalOrders
FROM sales
INNER JOIN territory
ON sales.territorykey = territory.territorykey
WHERE DATE_PART('year',sales.orderdate) IN (2020,2021)
GROUP BY territory.region,territory.country 
ORDER BY SUM(orderquantity) DESC;

/*first 10 customers with the highest quantity ordered*/

SELECT CONCAT(customer_lookup.first_name,' ',customer_lookup.last_name)AS customer_fullname,SUM(sales.orderquantity)
FROM customer_lookup
INNER JOIN sales
ON customer_lookup.customerkey = sales.customerkey
GROUP BY CONCAT(customer_lookup.first_name,' ',customer_lookup.last_name)
ORDER BY SUM(sales.orderquantity) DESC
LIMIT 10;


SELECT CONCAT(customer_lookup.first_name,' ',customer_lookup.last_name)AS customer_fullname, COUNT(sales.ordernumber)
FROM customer_lookup
INNER JOIN sales
ON customer_lookup.customerkey = sales.customerkey
GROUP BY CONCAT(customer_lookup.first_name,' ',customer_lookup.last_name)
ORDER BY COUNT(sales.ordernumber) DESC
LIMIT 10;


-- Building the order table. Here I will be using joins to get the a new table.

SELECT * FROM productsubcategory;


SELECT sales.ordernumber, CONCAT(customer_lookup.first_name,' ',customer_lookup.last_name)AS customer_fullname,
product_category.productcategoryname, productsubcategory.subCategoryName, territory.region,
territory.country, territory.continent, sales.orderquantity, ROUND(product_lookup.productprice,2), calendar.orderdate
FROM sales
INNER JOIN
customer_lookup ON sales.customerkey = customer_lookup.customerkey
INNER JOIN product_lookup ON sales.productkey = product_lookup.productkey
INNER JOIN productsubcategory ON product_lookup.productsubcategorykey = productsubcategory.productsubcategorykey
INNER JOIN territory ON sales.territorykey = territory.territorykey
INNER JOIN product_category ON productsubcategory.productcategorykey = product_category.productcategorykey
INNER JOIN calendar ON sales.orderdate = calendar.orderdate; 



-- what was the total sales generated from each customers

SELECT CONCAT(customer_lookup.first_name,' ',customer_lookup.last_name), SUM(ROUND((product_lookup.productprice * sales.orderquantity),2)) As Total_sales
FROM sales
INNER JOIN customer_lookup
ON customer_lookup.customerkey = sales.customerkey
INNER JOIN product_lookup
ON product_lookup.productkey = sales.productkey
GROUP BY CONCAT(customer_lookup.first_name,' ',customer_lookup.last_name)

-- who are the top 10 customers and their total sales

SELECT CONCAT(customer_lookup.first_name,' ',customer_lookup.last_name), SUM(ROUND((product_lookup.productprice * sales.orderquantity),2)) As Total_sales
FROM sales
INNER JOIN customer_lookup
ON customer_lookup.customerkey = sales.customerkey
INNER JOIN product_lookup
ON product_lookup.productkey = sales.productkey
GROUP BY CONCAT(customer_lookup.first_name,' ',customer_lookup.last_name)
ORDER BY SUM(ROUND((product_lookup.productprice * sales.orderquantity),2)) DESC
LIMIT 10;
-- Give your life to Jesus


-- The analysis ends here


