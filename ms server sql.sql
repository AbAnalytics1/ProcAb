
-- CREATE A DATABASE

CREATE DATABASE AnalystWork;

USE AnalystWork;

-- CREATE THE CALENDAR TABLE

CREATE TABLE  calendar(
	OrderDate 	DATE PRIMARY KEY
);

SELECT * FROM calendar

-- CREATE THE CUSTOMER TABLE

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
    totalChildren     INT,
    educationlevel	VARCHAR(50),
    Occupation      VARCHAR(50),
    HomeOwner       VARCHAR(50)
	
);

SELECT * FROM customer_lookup;

CREATE TABLE  Product_Category(

	ProductCategoryKey		    VARCHAR(20) PRIMARY KEY,
	ProductCategoryName			VARCHAR(20)
)

SELECT * FROM product_category;

CREATE TABLE ProductsubCategory(
	productSubcategorykey 	VARCHAR(50) PRIMARY KEY,
	subCategoryName 	    VARCHAR(50),
	productCategorykey VARCHAR(20)  REFERENCES Product_Category(ProductCategoryKey)
	
)

SELECT * FROM ProductsubCategory

-- CREATE THE PRODUCT TABLE


CREATE TABLE product_lookup(

	productkey 				VARCHAR(20) PRIMARY KEY,
	productSKU 				VARCHAR (20), 
    productName				VARCHAR(150),
    modelName				VARCHAR(50),
	productDescription 		VARCHAR(300),
	productColour			VARCHAR(15),
	productSize				VARCHAR(10),
	productCost				DECIMAL(10,4),
	productPrice			DECIMAL(10,4),
	productSubcategorykey VARCHAR(50)  REFERENCES ProductsubCategory(productSubcategorykey)
);

SELECT * FROM product_lookup


CREATE TABLE  returnslookup(

	returns_date 	DATE,
	territorykey	VARCHAR(20) REFERENCES territory(territoryKey),
	productkey  	VARCHAR (20) REFERENCES product_lookup(productkey),
	returnQuantity  INT

)


CREATE TABLE  territory(

	territoryKey	VARCHAR(20) PRIMARY KEY,
	region 			VARCHAR(20),
	country 		VARCHAR(20),
	continent 		VARCHAR(20)
);


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

-- DATA DEFINED LANGUAGE 

-- ALTER THE PRODUCT TABLE

ALTER TABLE product_lookup
DROP COLUMN productSize

-- ALTER THE PRODUCT SUBCATEGORY TABLE

ALTER TABLE productsubCategory
	ADD productCategorykey VARCHAR(20),
	ADD CONSTRAINT FOREIGN KEY (productCategorykey) REFERENCES Product_Category(productCategorykey);

-- PERFORMING EXPLORATORY DATA ANALYSIS ON THE DATASET

--HOW MANY RECORDS ARE FOUND IN THE CUSTOMERS TABLE

SELECT COUNT(*) FROM customer_lookup;

SELECT *FROM customer_lookup
-- REPLACING VALUES IN THE CUSTOMER TABLE. 

--REPLACE M & S IN MARITAL STATUS IN THE MARITAL STATUS COLUMN WITH MARRIED AND SINGLE RESPECTIVELY


UPDATE customer_lookup
SET maritalstatus = 'Married'
WHERE maritalstatus ='M';

UPDATE customer_lookup
SET maritalstatus = 'Single'
WHERE maritalstatus ='S';

-- A MORE EFFICIENT WAY TO DO THIS IS TO USE THE SYNTAX OR QUERY BELOW

UPDATE customer_lookup
SET gender =
	CASE
		WHEN gender = 'M' THEN 'Male'
		WHEN gender = 'F' THEN 'Female'
		ELSE 'Undefined'
	END;

UPDATE customer_lookup
SET HomeOwner =
	CASE
		WHEN HomeOwner = 'Y' THEN 'Yes'
		WHEN HomeOwner = 'N' THEN 'No'
		ELSE 'Undefined'
	END;

-- CONVERT THE VALUES IN THE FIRST AND LAST NAME COLUMN INTO A PROPERCASE.

UPDATE customer_lookup
SET first_name = CONCAT(UPPER(SUBSTRING(first_name, 1, 1)), LOWER(SUBSTRING(first_name, 2, LEN(first_name) - 1)))

-- LAST NAME

UPDATE customer_lookup
SET last_name = CONCAT(UPPER(SUBSTRING(last_name, 1, 1)), LOWER(SUBSTRING(last_name, 2, LEN(last_name) - 1)))

--CHECK IF THERE ARE ANY DUPLICATE IN THE CUSTOMER KEY COLUMN

SELECT customerKey, COUNT(customerKey) AS count_of_duplicates
FROM customer_lookup
GROUP BY customerKey
HAVING COUNT(customerKey) > 1;


-- ADD A NEW COLUMN AND POPULATE THE COLUMN USING A CONDITION fROM ANOTHER COLUMN

SELECT * FROM customer_lookup

-- FIRST STEP IS TO ADD A NEW COLUMN

ALTER TABLE customer_lookup
ADD Parent VARCHAR(5);

-- SECOND STEP IS TO UPDATE THE COLUMN USING THE CASE FOR THE CONDITION

UPDATE customer_lookup
SET Parent =
	CASE
		WHEN totalChildren > 0 THEN 'Yes'
		WHEN totalChildren = 0 THEN 'No'
	END;

--CATEGORIZE THE ANNUAL INCOME INTO HIGH, MID AND LOW.

ALTER TABLE customer_lookup
ADD IncomeLevel VARCHAR(20);

UPDATE customer_lookup
SET IncomeLevel =
	CASE 
		WHEN annualIncome >= 150000 THEN 'High'
        WHEN annualIncome BETWEEN 50000 AND 149999 THEN 'Mid'
        WHEN annualIncome < 50000 THEN 'Low'
	END;


-- EDA
-- HOW MANY CLIENTS ARE PARENTS 
-- ANSWER - THERE ARE 13,068 CLIENTS WHO ARE PARENTS AND 5,080 ARE NOT PARENTS

SELECT
	COUNT(CASE WHEN Parent ='Yes' THEN 1 END) AS Parent,
	COUNT(CASE WHEN Parent = 'No' THEN 1 END) AS Not_Parent
FROM customer_lookup;

-- HOW MANY CLIENTS ARE HIGH, MID,AND LOW INCOME EARNERS 

SELECT 
    COUNT(CASE WHEN IncomeLevel ='Mid' THEN 1 END) AS MidIncome,
    COUNT(CASE WHEN IncomeLevel ='low'THEN 1 END) AS LowImcome,
    COUNT(CASE WHEN IncomeLevel ='High' THEN 1 END) AS HighIncome
FROM customer_lookup;

-- PRODUCT LOOKUP 
SELECT * FROM product_lookup

-- CHECK FOR ANY DUPLICATE

SELECT productkey, COUNT(productkey) AS Number_of_Duplicate
FROM product_lookup
GROUP BY productkey
HAVING COUNT(productkey) > 1;

UPDATE  product_lookup
SET productSKU = TRIM(LEFT(productSKU,2));

UPDATE product_lookup
SET productCost = ROUND(productCost,2), 
    productPrice = ROUND(ProductPrice,2);

-- PROVIDE THE LIST OF PRODUCTS THAT HAVE THE HIGHEST PRICE

SELECT productName
FROM product_lookup
WHERE productPrice = ( SELECT MAX(productPrice) FROM product_lookup);

-- PROVIDE THE LIST OF PRODUCTS THAT HAVE THE HIGHEST COST OF PRODUCTION

SELECT productName
FROM product_lookup
WHERE productCost = ( SELECT MAX(productCost) FROM product_lookup);


-- PRODUCT Sub-CATEGORY

--CHECK FOR ANY DUPLICATE AND REMOVE THEM IF ANY

SELECT ProductSubcategorykey, COUNT(ProductSubcategorykey) AS Number_of_Duplicates
FROM ProductsubCategory
GROUP BY ProductSubcategorykey
HAVING COUNT(ProductSubcategorykey) > 1;

-- ANALYSING THE SALES DATA
-- BEGIN FROM THE CUSTOMER CONTRIBUTIONS TO COMPANY SALES 

-- HOW MANY ORDERS WHERE MADE

SELECT * FROM product_lookup;

-- REVENUE GENERATED FROM CUSTOMERS

 SELECT CONCAT(customer_lookup.first_name, ' ' , customer_lookup.last_name), ROUND(SUM(sales.orderQuantity * product_lookup.productPrice),2) AS Revenue
 FROM sales
 LEFT JOIN customer_lookup
 ON sales.customerKey = customer_lookup.customerKey
 INNER JOIN product_lookup 
 ON sales.productKey = product_lookup.productkey
 GROUP BY CONCAT(customer_lookup.first_name, ' ' ,customer_lookup.last_name)
 ORDER BY ROUND(SUM(sales.orderQuantity * product_lookup.productPrice),2) DESC;

-- WHO WHERE OUR TOP 10 CUSTOMERS

 SELECT TOP (10)CONCAT(customer_lookup.first_name, ' ' , customer_lookup.last_name) AS FullName, ROUND(SUM(sales.orderQuantity * product_lookup.productPrice),2) AS Revenue
 FROM sales
 LEFT JOIN customer_lookup
 ON sales.customerKey = customer_lookup.customerKey
 INNER JOIN product_lookup 
 ON sales.productKey = product_lookup.productkey
 GROUP BY CONCAT(customer_lookup.first_name, ' ' ,customer_lookup.last_name)
 ORDER BY ROUND(SUM(sales.orderQuantity * product_lookup.productPrice),2) DESC
 

-- QUANTITIES ORDERED BY THE CUSTOMERS
SELECT TOP (10) CONCAT(customer_lookup.first_name, ' ', customer_lookup.last_name) AS FullName, SUM(sales.orderQuantity) AS TotalQuantity
FROM sales
 LEFT JOIN customer_lookup
 ON sales.customerKey = customer_lookup.customerKey
LEFT JOIN product_lookup
ON sales.productKey = product_lookup.productkey
GROUP BY CONCAT(customer_lookup.first_name, ' ', customer_lookup.last_name)
ORDER BY SUM(sales.orderQuantity) DESC;

-- PRODUCT ANALYSIS.
-- FIND THE PROFIT GENERATED FORM THE PRODUCT

SELECT TOP (10) ProductsubCategory.subCategoryName, SUM(sales.orderQuantity * product_lookup.productPrice) AS Revenue
FROM sales
LEFT JOIN product_lookup
ON sales.productKey = product_lookup.productkey
LEFT JOIN ProductsubCategory 
ON product_lookup.productSubcategorykey = productsubCategory.productSubcategorykey
GROUP BY ProductsubCategory.subCategoryName
ORDER BY SUM(sales.orderQuantity * product_lookup.productPrice) DESC;



SELECT  Product_Category.ProductCategoryName, SUM(sales.orderQuantity * product_lookup.productPrice) AS Revenue
FROM sales
LEFT JOIN product_lookup
ON sales.productKey = product_lookup.productkey
LEFT JOIN ProductsubCategory 
ON product_lookup.productSubcategorykey = productsubCategory.productSubcategorykey
LEFT JOIN Product_Category 
ON productsubCategory.productCategorykey = Product_Category.ProductCategoryKey
GROUP BY Product_Category.ProductCategoryName
ORDER BY SUM(sales.orderQuantity * product_lookup.productPrice) DESC;

-- TERRITORY ANALYSIS
SELECT territory.country, ROUND(SUM(product_lookup.productPrice * sales.orderQuantity),2) AS Revenue
FROM sales 
LEFT JOIN territory
ON sales.territoryKey = territory.territoryKey
LEFT JOIN product_lookup
ON sales.productKey = product_lookup.productkey
GROUP BY territory.country
ORDER BY ROUND(SUM(product_lookup.productPrice * sales.orderQuantity),2) DESC;

-- FIND THE REVENUE GENERATED FROM 2020 TO 2022
SELECT

    SUM(CASE WHEN YEAR(sales.OrderDate) = 2020 THEN product_lookup.productPrice * sales.orderQuantity ELSE 0 END) AS TotalRevenue2020,
    SUM(CASE WHEN YEAR(sales.OrderDate) = 2021 THEN product_lookup.productPrice * sales.orderQuantity ELSE 0 END) AS TotalRevenue2021,
    SUM(CASE WHEN YEAR(sales.OrderDate) = 2022 THEN product_lookup.productPrice * sales.orderQuantity ELSE 0 END) AS TotalRevenue2022
FROM sales
LEFT JOIN product_lookup 
ON sales.productKey = product_lookup.productkey
WHERE
    YEAR(sales.OrderDate) IN (2020, 2021, 2022)

--FIND THE  TOTAL PROFIT FOR THE COMPANY

SELECT SUM(product_lookup.productPrice * sales.orderQuantity - product_lookup.productCost)
FROM sales
LEFT JOIN product_lookup
ON sales.productKey = product_lookup.productkey;

-- FIND THE PROFIT GENERATED BY THE COMPANY OVER THE LAST THREEE YEARS AND LET US FOR US TO COMPARE


SELECT 
    SUM(CASE WHEN YEAR(sales.orderDate) = 2020 THEN (product_lookup.productPrice * sales.orderQuantity - product_lookup.productCost) ELSE 0 END) AS TotalProfit2020,
    SUM(CASE WHEN YEAR(sales.orderDate) = 2021 THEN (product_lookup.productPrice * sales.orderQuantity - product_lookup.productCost) ELSE 0 END) AS TotalProfit2021,
    SUM(CASE WHEN YEAR(sales.orderDate) = 2022 THEN (product_lookup.productPrice * sales.orderQuantity - product_lookup.productCost) ELSE 0 END) AS TotalProfit2022
FROM 
    sales
LEFT JOIN 
    product_lookup ON sales.productKey = product_lookup.productkey
WHERE
    YEAR(sales.OrderDate) IN (2020, 2021, 2022);

