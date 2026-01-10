USE magist;

--  How many months of data are included in the magist database?
-- Approach 1
 SELECT 
    *
FROM
    orders;
SELECT 
    TIMESTAMPDIFF(MONTH,
        MIN(order_purchase_timestamp),
        MAX(order_purchase_timestamp)) AS month_diff
FROM
    orders;


-- Approach 2    
SELECT 
    COUNT(DISTINCT DATE_FORMAT(order_purchase_timestamp, '%Y-%m')) AS month_count
FROM
    orders; 
    
   -- How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?    
   -- Number of sellers
 SELECT 
    COUNT(seller_id)
FROM
    sellers;
    
  -- number of Tech sellers  
   SELECT 
    COUNT(DISTINCT oi.seller_id) AS tech_sellers_count
FROM products p
JOIN product_category_name_translation pc
    ON p.product_category_name = pc.product_category_name
JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE pc.product_category_name_english IN (
    'computers_accessories',
    'computers',
    'tablets_impressao_imagem',
    'telephony',
    'electronics'
); 

-- %tage of overall Tech Sellers
 SELECT 
    ROUND(
        100.0 * tech.tech_sellers / total.total_sellers,
        2
    ) AS tech_seller_percentage
FROM
    (
        SELECT COUNT(DISTINCT oi.seller_id) AS tech_sellers
        FROM products p
        JOIN product_category_name_translation pc
            ON p.product_category_name = pc.product_category_name
        JOIN order_items oi
            ON p.product_id = oi.product_id
        WHERE pc.product_category_name_english IN (
            'computers_accessories',
            'computers',
            'tablets_impressao_imagem',
            'telephony',
            'electronics'
        )
    ) tech,
    (
        SELECT COUNT(*) AS total_sellers
        FROM sellers
    ) total;
    
    What is the total amount earned by all sellers? 
 SELECT 
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_amount_earned
FROM order_items oi;   
 
 -- What is the total amount earned by all Tech sellers?
 SELECT 
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_tech_earnings
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN product_category_name_translation pc
    ON p.product_category_name = pc.product_category_name
WHERE pc.product_category_name_english IN (
    'computers_accessories',
    'computers',
    'tablets_impressao_imagem',
    'telephony',
    'electronics'
);


-- Average montly income of ALL sellers
SELECT 
    ROUND(AVG(monthly_revenue), 2) AS avg_monthly_income_all_sellers
FROM (
    SELECT 
        oi.seller_id,
        SUM(oi.price + oi.freight_value) AS monthly_revenue
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    GROUP BY 
        oi.seller_id,
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
) seller_months;

-- Average montly income of TECH sellers
SELECT 
    ROUND(AVG(monthly_revenue), 2) AS avg_monthly_income_tech_sellers
FROM (
    SELECT 
        oi.seller_id,
        SUM(oi.price + oi.freight_value) AS monthly_revenue
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    JOIN product_category_name_translation pc
        ON p.product_category_name = pc.product_category_name
    WHERE pc.product_category_name_english IN (
        'computers_accessories',
        'computers',
        'tablets_impressao_imagem',
        'telephony',
        'electronics'
    )
    GROUP BY 
        oi.seller_id,
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
) tech_seller_months;
  