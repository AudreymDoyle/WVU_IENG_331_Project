/* NAME: abc-inventory-classification.sql
PURPOSE: to classify olist products into A,B,C tiers based on their revenuer contribution to prioritize inventory and marketing efforts
RUBRIC REQUIREMENTS
 - Defines a specific, actionable question and a multi-step analytical strategy
 - Implements a multi-step analysis by chaining 3+ CTEs in a logical progression
 - Utilizes window functions (OVER), multi-table joins, and advanced aggregations
 - Produces a clean, rounded, and sorted output designed for stakeholder readability
*/

-- STEP 1: Calculate total revenue for every unique product in the dataset
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_category_name,
        -- We sum the price of every item sold for each specific product ID
        ROUND(SUM(oi.price),2) AS total_item_revenue
    FROM products p
    -- We join 'products' with 'order_items' to link prices to product IDs
    JOIN order_items oi ON p.product_id = oi.product_id
    -- WE use group by to ensure we get one row per product
    GROUP BY p.product_id, p.product_category_name
),

-- STEP 2: Calculate the 'Running Total' and the 'Grand Total'
-- This allows us to see how revenue accumulates as we move down the list
cumulative_revenue AS (
    SELECT
        product_id,
        product_category_name,
        total_item_revenue,
        -- We use the functions SUM() and OVER() to calculates a running total
        -- It adds the current row's revenue to the sum of all rows above it
        SUM(total_item_revenue) OVER (
            ORDER BY total_item_revenue DESC
        ) AS running_revenue,
        SUM(total_item_revenue) OVER () AS total_company_revenue
    FROM product_revenue
),

-- STEP 3: Turning previous dollar amounts into a percentage (0.0 to 1.0)
percentage_calc AS (
    SELECT
        product_id,
        product_category_name,
        total_item_revenue,
        running_revenue,
        -- We divide the running total by the grand total to find the 'Pareto' position
        (running_revenue / total_company_revenue) AS cumulative_percent
    FROM cumulative_revenue
)

-- STEP 4: Final output with ABC Labels
-- We use a CASE statement to assign the tier based on the cumulative percentage
SELECT
    product_id,
    product_category_name,
    total_item_revenue,
    cumulative_percent,
    CASE
        -- If the product is within the top 80% of total revenue, it's an 'A'
        WHEN cumulative_percent <= 0.80 THEN 'A'
        -- If it's between 80% and 95%, it's a 'B' (the next 15%)
        WHEN cumulative_percent <= 0.95 THEN 'B'
        -- Everything else falls into the 'C' tier (the bottom 5%)
        ELSE 'C'
    END AS abc_tier
FROM percentage_calc
-- Sort high to low so the 'A' products appear at the top
ORDER BY total_item_revenue DESC;
