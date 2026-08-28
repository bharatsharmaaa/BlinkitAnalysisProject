-- Blinkit Grocery Sales Analysis
-- Import the CSV into a table named blinkit_grocery_data before running the queries.
-- The table below uses normalized snake_case column names.

CREATE TABLE IF NOT EXISTS blinkit_grocery_data (
    item_fat_content VARCHAR(20),
    item_identifier VARCHAR(20),
    item_type VARCHAR(80),
    outlet_establishment_year INTEGER,
    outlet_identifier VARCHAR(20),
    outlet_location_type VARCHAR(20),
    outlet_size VARCHAR(20),
    outlet_type VARCHAR(40),
    item_visibility DECIMAL(12, 8),
    item_weight DECIMAL(10, 2),
    total_sales DECIMAL(12, 4),
    rating DECIMAL(3, 1)
);

-- 1. Data-quality checks
SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT item_identifier) AS unique_items,
    COUNT(DISTINCT outlet_identifier) AS unique_outlets,
    SUM(CASE WHEN total_sales IS NULL THEN 1 ELSE 0 END) AS missing_sales,
    SUM(CASE WHEN item_weight IS NULL THEN 1 ELSE 0 END) AS missing_item_weight,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS missing_rating
FROM blinkit_grocery_data;

SELECT
    MIN(total_sales) AS minimum_sales,
    MAX(total_sales) AS maximum_sales,
    ROUND(AVG(total_sales), 2) AS average_sales,
    ROUND(AVG(item_visibility), 4) AS average_item_visibility,
    ROUND(AVG(rating), 2) AS average_rating
FROM blinkit_grocery_data;

-- 2. Overall KPIs
SELECT
    COUNT(*) AS total_records,
    ROUND(SUM(total_sales), 2) AS total_sales,
    ROUND(AVG(total_sales), 2) AS average_sales_per_record,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(item_visibility), 4) AS average_item_visibility
FROM blinkit_grocery_data;

-- 3. Sales and KPIs by outlet type
SELECT
    outlet_type,
    COUNT(*) AS records,
    ROUND(SUM(total_sales), 2) AS total_sales,
    ROUND(AVG(total_sales), 2) AS average_sales,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(item_visibility), 4) AS average_visibility
FROM blinkit_grocery_data
GROUP BY outlet_type
ORDER BY total_sales DESC;

-- 4. Sales by location tier and outlet size
SELECT
    outlet_location_type,
    outlet_size,
    COUNT(*) AS records,
    ROUND(SUM(total_sales), 2) AS total_sales,
    ROUND(AVG(total_sales), 2) AS average_sales
FROM blinkit_grocery_data
GROUP BY outlet_location_type, outlet_size
ORDER BY total_sales DESC;

-- 5. Product-category performance
SELECT
    item_type,
    COUNT(*) AS records,
    ROUND(SUM(total_sales), 2) AS total_sales,
    ROUND(AVG(total_sales), 2) AS average_sales,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(item_visibility), 4) AS average_visibility
FROM blinkit_grocery_data
GROUP BY item_type
ORDER BY total_sales DESC;

-- 6. Normalize inconsistent fat-content capitalization before grouping
WITH cleaned_data AS (
    SELECT
        CASE
            WHEN LOWER(TRIM(item_fat_content)) = 'low fat' THEN 'Low Fat'
            WHEN LOWER(TRIM(item_fat_content)) = 'regular' THEN 'Regular'
            ELSE 'Unknown'
        END AS normalized_fat_content,
        total_sales,
        rating
    FROM blinkit_grocery_data
)
SELECT
    normalized_fat_content,
    COUNT(*) AS records,
    ROUND(SUM(total_sales), 2) AS total_sales,
    ROUND(AVG(total_sales), 2) AS average_sales,
    ROUND(AVG(rating), 2) AS average_rating
FROM cleaned_data
GROUP BY normalized_fat_content
ORDER BY total_sales DESC;

-- 7. Outlet establishment-year trend
SELECT
    outlet_establishment_year,
    COUNT(DISTINCT outlet_identifier) AS outlets,
    COUNT(*) AS records,
    ROUND(SUM(total_sales), 2) AS total_sales,
    ROUND(AVG(total_sales), 2) AS average_sales
FROM blinkit_grocery_data
GROUP BY outlet_establishment_year
ORDER BY outlet_establishment_year;

-- 8. Top 10 items by sales within each outlet type
WITH ranked_items AS (
    SELECT
        outlet_type,
        item_identifier,
        item_type,
        total_sales,
        rating,
        RANK() OVER (
            PARTITION BY outlet_type
            ORDER BY total_sales DESC
        ) AS sales_rank
    FROM blinkit_grocery_data
)
SELECT
    outlet_type,
    sales_rank,
    item_identifier,
    item_type,
    total_sales,
    rating
FROM ranked_items
WHERE sales_rank <= 10
ORDER BY outlet_type, sales_rank, total_sales DESC;

-- 9. High-sales and high-rated items
SELECT
    item_identifier,
    item_type,
    outlet_identifier,
    outlet_type,
    total_sales,
    rating
FROM blinkit_grocery_data
WHERE total_sales >= (SELECT AVG(total_sales) FROM blinkit_grocery_data)
  AND rating >= 4
ORDER BY total_sales DESC, rating DESC;
