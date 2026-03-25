/*
NAME: cohort-retention-analysis.sql
PURPOSE: Track repeat purchase rates within different intervals
RUBRIC REQUIREMENTS:
 - chained 3+ CTEs
 - join multiple tables to track users
 - specific business-driven question
*/

-- STEP 1: Find the first purchase date for every unique customer
WITH first_purchases AS (
    SELECT
        customer_unique_id,
        MIN(order_purchase_timestamp) AS first_order_date
    FROM orders
    JOIN customers ON orders.customer_id = customers.customer_id
    GROUP BY 1 -- Group by the first column (customer_unique_id)
),

-- STEP 2: Find all orders and link them to that "first_order_date"
all_purchases_with_birthdays AS (
    SELECT
        f.customer_unique_id,
        f.first_order_date,
        o.order_purchase_timestamp AS subsequent_order_date
    FROM first_purchases f
    -- Join back to orders to see EVERY order that customer ever made
    JOIN customers c ON f.customer_unique_id = c.customer_unique_id
    JOIN orders o ON c.customer_id = o.customer_id
    -- We only care about orders that happened AFTER the first one
    WHERE o.order_purchase_timestamp > f.first_order_date
),

-- STEP 3: Calculate the day difference for each follow-up order
order_deltas AS (
    SELECT
        customer_unique_id,
        -- date_diff is a DuckDB function to find the days between two dates
        date_diff('day', first_order_date, subsequent_order_date) AS days_since_first
    FROM all_purchases_with_birthdays
),

-- STEP 4: Put them into buckets (30, 60, 90 days)
retention_flags AS (
    SELECT
        customer_unique_id,
        -- If they ordered within 30 days, mark them with a 1 (flag)
        MAX(CASE WHEN days_since_first <= 30 THEN 1 ELSE 0 END) AS retained_30,
        MAX(CASE WHEN days_since_first <= 60 THEN 1 ELSE 0 END) AS retained_60,
        MAX(CASE WHEN days_since_first <= 90 THEN 1 ELSE 0 END) AS retained_90
    FROM order_deltas
    GROUP BY customer_unique_id
)

-- STEP 5: Final calculation of percentages
SELECT
    (SELECT COUNT(DISTINCT customer_unique_id) FROM first_purchases) AS total_customers,
    SUM(retained_30) AS returned_30_days,
    -- Calculate the rate: (Part / Total) * 100
    ROUND(SUM(retained_30) * 100.0 / (SELECT COUNT(*) FROM first_purchases), 2) || '%' AS retention_rate_30,
    ROUND(SUM(retained_60) * 100.0 / (SELECT COUNT(*) FROM first_purchases), 2) || '%' AS retention_rate_60,
    ROUND(SUM(retained_90) * 100.0 / (SELECT COUNT(*) FROM first_purchases), 2) || '%' AS retention_rate_90
FROM retention_flags;

-- retention rate slightly increases from 30 to 60 to 90 days
-- the biggest portion of returns happen within 0 to 30 days
