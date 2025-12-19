#export all csv files in C drive ->program data->mysql->MySQL Server 8.0->Uploads(in uploads copy all 10 dataset csv files coz csv direct cannot 
#be imported from data import in administrartive
#then run then below all qurys line by line to give pemisson or modify data
#yellow doesnt means error its just warning


SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
SET SESSION sql_mode='';
SHOW VARIABLES LIKE "secure_file_priv";

create database EcommerceProject;

use ecommerceproject; 


#1

CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    purchase_date DATETIME,
    order_approved_at DATETIME,
    delivered_carrier_date DATETIME,
    delivered_date DATETIME,
    estimated_date DATETIME
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_status, purchase_date, order_approved_at, delivered_carrier_date, delivered_date, estimated_date);

select * from orders;


#2
CREATE TABLE customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(50),
    customer_state VARCHAR(5)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


select * from customers;


#3
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DOUBLE,
    geolocation_lng DOUBLE,
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(5)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/geolocation.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from geolocation;

#4

CREATE TABLE sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix INT,
    seller_city VARCHAR(50),
    seller_state VARCHAR(5)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/seller.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#5

CREATE TABLE products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    products_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

# 6
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from order_items;


#7

CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/payments.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#8

CREATE TABLE reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATE,
    review_answer_timestamp DATETIME
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/reviews.csv'
INTO TABLE reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from reviews;


#9
CREATE TABLE products_dataset (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_dataset.csv'
INTO TABLE products_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#10

CREATE TABLE product_name_translation (
    product_category_name VARCHAR(255),
    product_category_name_english VARCHAR(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_name_translation.csv'
INTO TABLE product_name_translation
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


#SQL QUERIES FOR REQUIREMENTS
#1 WEEKEND VS WEEKDAY
SELECT 
    CASE 
        WHEN WEEKDAY(o.purchase_date) IN (5,6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    COUNT(DISTINCT o.order_id) AS Total_Orders,
    SUM(p.payment_value) AS Total_Payment
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY Day_Type;


#2 NUM OF ORDERS REVIEW WITH REVIEW 5 SCORE

SELECT COUNT(DISTINCT r.order_id) AS Total_Orders
FROM reviews r
JOIN payments p ON r.order_id = p.order_id
WHERE r.review_score = 5
  AND p.payment_type = 'credit_card';

#3 AVG NO DAY TAKEN FOR ORDER DELIVERED CUSTOMER DATE PET SHOP

SELECT 
    ROUND(AVG(DATEDIFF(o.delivered_date, o.purchase_date)),2) AS Avg_Delivery_Days
FROM orders o
JOIN orderS_item oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN product_name_translation pt ON p.product_category_name = pt.product_category_name
WHERE pt.product_category_name_english LIKE '%pet_shop%';

#4 AVG PRICE AND PAYMENT values FOR FROM CUSTOMERS OF SAO PAULO CITY
SELECT 
    c.customer_city,
    ROUND(AVG(oi.price), 2) AS avg_price,
    ROUND(AVG(p.payment_value), 2) AS avg_payment_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN orders_item oi ON o.order_id = oi.order_id
JOIN payments p ON o.order_id = p.order_id
WHERE LOWER(c.customer_city) = 'sao paulo'
GROUP BY c.customer_city;

SELECT 
    ROUND(AVG(oi.price),2) AS Avg_Product_Price,
    ROUND(AVG(p.payment_value),2) AS Avg_Payment_Value
FROM orders o
JOIN orders_item oi ON o.order_id = oi.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN payments p ON o.order_id = p.order_id
WHERE c.customer_city = 'sao paulo';


#5 RELATIONSHIP BETWEEN REVIEWS SCORE VS SHIPPING DAYS

SELECT 
    r.review_score,
    ROUND(AVG(DATEDIFF(o.delivered_date, o.purchase_date)),2) AS Avg_Shipping_Days
FROM reviews r
JOIN orders o ON r.order_id = o.order_id
GROUP BY r.review_score
ORDER BY r.review_score DESC;

#other extra insights what we can get

#6 FAST VS SLOW DELIVERIES

SELECT 
    p.product_category_name AS Category,
    ROUND(AVG(DATEDIFF(o.delivered_date, o.purchase_date)),2) AS Avg_Delivery_Days,
    CASE 
        WHEN AVG(DATEDIFF(o.delivered_date, o.purchase_date)) <= 
             (SELECT AVG(DATEDIFF(delivered_date, purchase_date)) FROM orders)
        THEN 'Fast Delivery'
        ELSE 'Slow Delivery'
    END AS Delivery_Speed
FROM orders o
JOIN orders_item oi 
    ON o.order_id = oi.order_id
JOIN products p 
    ON oi.product_id = p.product_id
WHERE 
    o.delivered_date IS NOT NULL
    AND o.purchase_date IS NOT NULL
GROUP BY 
    p.product_category_name
ORDER BY 
    Avg_Delivery_Days ASC;

#7- TOP 10 PRODUCTS
SELECT 
    t.product_category_name_english AS category,
    SUM(oi.price + oi.freight_value) AS total_revenue
FROM 
    orders_item oi
JOIN 
    products p ON oi.product_id = p.product_id
JOIN 
    product_name_translation t 
    ON p.product_category_name = t.product_category_name
GROUP BY 
    t.product_category_name_english
ORDER BY 
    total_revenue DESC
LIMIT 10;

 #8 HIGHEST REVENUE PRODUCTS CATEGORIES
 SELECT 
    COALESCE(pt.product_category_name_english, p.product_category_name) AS category,
    ROUND(SUM(oi.price * pay.payment_installments), 2) AS total_revenue
FROM orders_item oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_name_translation pt 
       ON p.product_category_name = pt.product_category_name
JOIN payments pay ON oi.order_id = pay.order_id
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 5;

 #9 TOP 5 CITITES WITH MOST ORDERS
SELECT 
    c.customer_city,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_city
ORDER BY total_orders DESC
LIMIT 5; 
 
 #10 TOTAL REVENUE 
 SELECT 
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM payments;
  
#11 SHIPPING DELAY IMPACT ON RATING
SELECT 
    CASE 
        WHEN DATEDIFF(o.delivered_date, o.estimated_date) <= 0 THEN 'On Time or Early'
        ELSE 'Late Delivery'
    END AS delivery_status,
    ROUND(AVG(r.review_score), 2) AS avg_rating,
    COUNT(*) AS total_orders
FROM orders o
JOIN reviews r ON o.order_id = r.order_id
WHERE o.delivered_date IS NOT NULL AND o.estimated_date IS NOT NULL
GROUP BY delivery_status;


#12 ORDER CANCELLATION RATE
SELECT 
    ROUND(
        (SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) / 
         COUNT(*)) * 100, 2
    ) AS cancellation_rate_percent
FROM orders o;

#13 REPEATED CUSTOMERS
SELECT 
    CASE WHEN order_count > 1 THEN 'Repeat Customer' ELSE 'One-time Customer' END AS customer_type,
    COUNT(*) AS customer_count
FROM (
    SELECT customer_id, COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
) AS t
GROUP BY customer_type;


#14 REPEAT CUSTOMER PERCENTGE
SELECT 
    ROUND(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) 
    AS repeat_customer_percentage
FROM (
    SELECT customer_id, COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
) AS t;


#14 TOP 5 BEST VS 5 WORST REVENUE BASED

WITH category_revenue AS (
    SELECT 
        t.product_category_name_english AS category,
        SUM(oi.price + oi.freight_value) AS total_revenue
    FROM orders_item oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN product_name_translation t ON p.product_category_name = t.product_category_name
    GROUP BY t.product_category_name_english
),

ranked_categories AS (
    SELECT 
        category,
        total_revenue,
        RANK() OVER (ORDER BY total_revenue DESC) AS rev_desc_rank,
        RANK() OVER (ORDER BY total_revenue ASC) AS rev_asc_rank
    FROM category_revenue
)

SELECT 
    category,
    total_revenue,
    CASE
        WHEN rev_desc_rank <= 5 THEN 'Best'
        WHEN rev_asc_rank <= 5 THEN 'Worst'
        ELSE 'Average'
    END AS performance
FROM ranked_categories
WHERE rev_desc_rank <= 5 OR rev_asc_rank <= 5
ORDER BY total_revenue DESC;


#15 REVENUE BY PAYMENT TYPE WHICH METHOD GENERATES HIGHER SALES
SELECT 
    p.payment_type,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.price + oi.freight_value) AS total_revenue,
    AVG(r.review_score) AS avg_rating
FROM orders_item oi
JOIN payments p ON oi.order_id = p.order_id
JOIN reviews r ON oi.order_id = r.order_id
GROUP BY p.payment_type
ORDER BY total_revenue DESC;


