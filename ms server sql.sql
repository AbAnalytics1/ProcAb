
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
	
);

ALTER TABLE productsubCategory
ADD productCategorykey VARCHAR(20)  REFERENCES Product_Category(ProductCategoryKey)