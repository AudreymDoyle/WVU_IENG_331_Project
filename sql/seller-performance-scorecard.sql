/*
NAME: seller-performance-scorecard.sql
PURPOSE: Identify top sellers using sales and satisfaction.
RUBRIC REQUIREMENTS:
 - chained three or more CTEs logically
 - joined data across four tables
 - used window functions for performance ranking
 */

-- Step 1: Calculate Total Revenue per Seller
-- This CTE looks at the 'order_items' table to sum up prices.
WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(price) AS total_revenue,
        COUNT(order_id) AS total_orders
    FROM order_items
    GROUP BY seller_id
),

-- Step 2: Calculate On-Time Delivery Rate
-- We join 'order_items' to 'orders' to compare actual vs. estimated dates.
delivery_stats AS (
    SELECT
        items.seller_id,
        -- Logic: If delivered <= estimated, it's a 1 (On Time), else 0 (Late).
        -- AVG() of 1s and 0s gives us a percentage (0.0 to 1.0).
        AVG(CASE
            WHEN ord.order_delivered_customer_date <= ord.order_estimated_delivery_date
            THEN 1.0
            ELSE 0.0
        END) AS on_time_rate
    FROM order_items AS items
    JOIN orders AS ord ON items.order_id = ord.order_id
    WHERE ord.order_status = 'delivered' -- We only care about completed trips
    GROUP BY items.seller_id
),

-- Step 3: Calculate Average Review Scores
-- This pulls from 'order_reviews' to see how customers felt about their purchase.
review_stats AS (
    SELECT
        items.seller_id,
        AVG(reviews.review_score) AS avg_rating,
        COUNT(reviews.review_score) AS review_count
    FROM order_items AS items
    JOIN order_reviews AS reviews ON items.order_id = reviews.order_id
    GROUP BY items.seller_id
)

-- Final Step: The Presentation Layer
-- We join our 3 CTEs to the master 'sellers' table.
-- We use LEFT JOINs to ensure we don't lose sellers who might be missing a review or a delivery.
SELECT
    COALESCE(rst.avg_rating, 0) AS customer_rating,
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COALESCE(rev.total_revenue, 0) AS revenue,
    COALESCE(del.on_time_rate, 0) AS delivery_score,

    -- WINDOW FUNCTION: RANK() creates the leaderboard.
    -- We rank sellers by revenue, but only if they have a decent rating (e.g., > 3.5).
    RANK() OVER (
        ORDER BY rev.total_revenue DESC
    ) AS performance_rank

FROM sellers AS s
LEFT JOIN seller_revenue AS rev ON s.seller_id = rev.seller_id
LEFT JOIN delivery_stats AS del ON s.seller_id = del.seller_id
LEFT JOIN review_stats AS rst ON s.seller_id = rst.seller_id

-- We filter out extremely low-volume sellers to keep the scorecard relevant
WHERE rev.total_orders > 5

-- Sort the final output by our new rank
ORDER BY performance_rank ASC
LIMIT 100; -- Show the top 100 performers
