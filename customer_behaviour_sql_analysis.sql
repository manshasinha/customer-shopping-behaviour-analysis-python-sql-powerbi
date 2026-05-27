
USE customer_behaviour;
SELECT * FROM customer_behaviour_analysis;


-- 1. FINDING CATEGORY GENERATAING HIGHEST REVENUE
SELECT 
    category,
    ROUND(SUM(purchase_amount),2) AS highest_revenue
FROM 
    customer_behaviour_analysis
GROUP BY 
    category
    ORDER BY highest_revenue DESC;
--  Problem:
-- To identify the revenue contribution of each product category 
-- to determine key drivers of business performance.

-- Impact:
-- Helps highlight top-performing categories 
-- Optimizes inventory allocation and demand planning
-- helps enhance marketing efficiency by targeting high-revenue categories


-- 2. IMPACT OF DISCOUNTS ON PURCHASE VALUE
SELECT 
    discount_applied,
    ROUND(SUM(purchase_amount), 2) AS highest_revenue,
    ROUND(AVG(purchase_amount), 2) AS avg_revenue
FROM 
    customer_behaviour_analysis
GROUP BY 
    discount_applied;

-- Problem:
-- Discounts may reduce profits without significantly increasing sales.

-- Impact:
-- Helps evaluate the effectiveness of discounts
-- Reduces unnecessary discount-related costs
-- Improves overall profit margins

-- 3. TOTAL REVENUE SPLIT BETWEEN MALE AND FEMALE CUSTOMERS
SELECT 
    gender,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer_behaviour_analysis
GROUP BY gender
ORDER BY total_revenue DESC;

-- Business Problem:
-- Limited understanding of how revenue is distributed across different gender segments.

-- Impact:
-- Helps in designing more targeted and effective marketing campaigns
-- Improves and helps in customer segmentation strategies
-- Enables better personalization of products and services

-- 3.1. GENDER-WISE SEGMENTATION OF REVENUE SPLIT AMONG ALL CATEGORIES
SELECT 
    gender,
    category,
    ROUND(SUM(purchase_amount), 2) AS revenue
FROM 
    customer_behaviour_analysis
GROUP BY 
    gender, category
ORDER BY 
    gender, category;
    
-- Problem:
-- The company does not understand how revenue varies across product categories for different genders.

-- Impact:
-- Helps identify top categories for each gender
-- Enables more targeted marketing strategies
-- Supports better inventory and product planning


-- 4.CUSTOMERS THAT USE DISCOUNT BUT STILL SPEND MORE THAN AVERAGE PURCHASE AMOUNT
SELECT 
    customer_id,
    purchase_amount,
    discount_applied
FROM 
    customer_behaviour_analysis
WHERE 
    discount_applied = 'Yes'
    AND purchase_amount > (
        SELECT AVG(purchase_amount)
        FROM customer_behaviour_analysis
    )
ORDER BY purchase_amount DESC 
LIMIT 10;

-- Problem:
-- The company is unable to clearly identify high-spending customers who also use discounts.

-- Impact:
-- Helps identify high-value customers who are sensitive to discounts
-- Supports more targeted and effective discount strategies
-- Improves customer retention and overall revenue

-- 5. TOP AND BOTTOM 5 PRODUCTS WITH HIGHEST/LOWEST AVERAGE REVIEW RATING
-- TOP 5
SELECT 
    item_purchased,
    ROUND(AVG(review_rating), 2) AS Avg_ratings
FROM 
    customer_behaviour_analysis
GROUP BY 
    item_purchased
ORDER BY 
    Avg_ratings DESC
LIMIT 5;
-- BOTTOM 5
SELECT 
    item_purchased,
    ROUND(AVG(review_rating), 2) AS Avg_ratings
FROM 
    customer_behaviour_analysis
GROUP BY 
    item_purchased
ORDER BY 
    Avg_ratings ASC
LIMIT 5;

--  Problem:
-- There is limited visibility into product performance based on customer satisfaction.

-- Impact:
-- Helps identify high-performing products
-- Supports improvement of low-rated products
-- Enhances overall customer experience

-- 6. AVERAGE PURCHASE: STANDARD VS EXPRESS SHIPPING
SELECT 
    shipping_type,
    COUNT(customer_id) AS orders_placed,
    ROUND(AVG(purchase_amount), 2) AS avg_purchase,
    ROUND(SUM(purchase_amount),2) AS revenue
FROM 
    customer_behaviour_analysis
-- WHERE 
    -- shipping_type IN ('Standard', 'Express')
GROUP BY 
    shipping_type
ORDER BY
	revenue DESC ;

-- Business Problem:
-- It is unclear whether faster shipping options lead to higher customer spending.

-- Impact:
-- Helps optimize shipping pricing strategies
-- Encourages adoption of premium shipping options
-- Increases average order value

-- 7. SPENDING HABITS OF SUBSCRIBED CUSTOMERS; COMPARING AVG AND TOTAL REVENUES OF SUBSCRIBED VS UNSUBSCRIEBD CUSTOMERS
SELECT 
    subscription_status,
    COUNT(customer_id) as users,
    ROUND(AVG(purchase_amount), 2) AS avg_revenue,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM 
    customer_behaviour_analysis
GROUP BY 
    subscription_status
ORDER BY total_revenue DESC;

-- Problem:
-- The effectiveness of subscription programs is not clearly understood.

-- Impact:
-- Helps evaluate the performance of subscription models
-- Improves customer loyalty programs
-- Increases customer lifetime value (CLV)

-- 8. TOP 5 PRODUCTS WITH HIGHEST DISCOUNT USAGE
SELECT 
    item_purchased,
    COUNT(item_purchased) AS total_number_of_times_sold,
    
    COUNT(CASE 
            WHEN discount_applied = 'Yes' THEN 1 
         END) AS number_of_times_sold_when_discount_applied,

    ROUND(
        COUNT(CASE 
                WHEN discount_applied = 'Yes' THEN 1 
             END) * 100.0 / COUNT(*), 
        2
    ) AS discount_percent
FROM 
    customer_behaviour_analysis
GROUP BY 
    item_purchased
ORDER BY 
    discount_percent DESC
LIMIT 5;

-- Business Problem:
-- Some products may be highly dependent on discounts for sales.

-- Impact:
-- Helps identify products driven by discounts
-- Supports optimization of pricing strategies
-- Reduces potential loss in profit margins

-- 9. CUSTOMER SEGMENTATION BY PURCHASE FREQUENCY: NEW, RETURNING,LOYAL
SELECT 
CASE 
	WHEN previous_purchases = 0 THEN 'New Customer'
	WHEN previous_purchases BETWEEN 1 AND 15 THEN 'Returning Customer'
	ELSE 'Loyal Customer'
END AS customer_segment,
    
COUNT(*) AS customer_count
FROM 
    customer_behaviour_analysis
GROUP BY 
    customer_segment;
    
-- Problem:
-- The absence of proper customer segmentation leads to overly generic business strategies.

-- Impact:
-- Enables more personalized and targeted marketing efforts
-- Strengthens customer retention strategies
-- Improves overall conversion rates

-- 10. TOP 3 MOST PURCHASED PRODUCTS IN EACH CATEGORY
WITH cte AS (
    SELECT 
        category,
        item_purchased,
        COUNT(item_purchased) AS most_purchased,

        RANK() OVER (PARTITION BY category 
        ORDER BY COUNT(item_purchased) DESC
        ) AS rnk
    FROM 
        customer_behaviour_analysis
    GROUP BY 
        category, item_purchased
)
SELECT 
    category,
    item_purchased,
    most_purchased,
    rnk
FROM 
    cte
WHERE 
    rnk <= 3
ORDER BY 
    category,
    rnk;
    
-- Business Problem:
-- The company lacks clear insight into top-performing products within each category.

-- Impact:
-- Improves product placement and recommendation strategies
-- Supports better inventory optimization
-- Increases sales by promoting best-selling products

-- 11.ARE CUSTOMERS WHO ARE REPEAT BUYERS(>5 PREVIOUS PURCHASES) LIKELY TO SUBSCRIBE
SELECT 
    CASE 
        WHEN previous_purchases > 5 THEN 'Repeat Buyers'
        ELSE 'Normal Buyers'
    END AS customer_type,
    subscription_status,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY CASE 
                    WHEN previous_purchases > 5 THEN 'Repeat Buyers'
                    ELSE 'Normal Buyers'
                END), 2) AS percents
FROM customer_behaviour_analysis
GROUP BY CASE 
        WHEN previous_purchases > 5 THEN 'Repeat Buyers'
        ELSE 'Normal Buyers'
    END,
    subscription_status
ORDER BY 
    customer_type,
    subscription_status;
 
--  Problem:
-- The relationship between customer loyalty and subscription usage is unclear

-- Impact:
-- Improves targeting of subscription programs
-- Increases conversion to paid plans
-- Strengthens customer retention strategies


-- 12.AGE-WISE REVENUE CONTRIBUTION
SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '35-50'
        ELSE '51+'
    END AS age_group,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM 
    customer_behaviour_analysis
GROUP BY 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '35-50'
        ELSE '51+'
    END
ORDER BY 
    total_revenue DESC;
    
--  Problem:
-- There is limited visibility into which age group contributes the most to revenue.

-- Impact:
-- Enables targeted marketing based on age groups
-- Improves overall marketing efficiency