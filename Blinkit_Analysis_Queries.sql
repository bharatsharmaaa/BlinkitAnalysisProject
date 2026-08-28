-- Blinkit Grocery Sales Analysis
-- The CSV has already been imported into analytics.blinkit_grocery_data.
-- Because the imported columns contain spaces and capital letters, PostgreSQL
-- requires double quotes around every column name used below.

CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS analytics.blinkit_grocery_data (
    "Item Fat Content" VARCHAR(50),
    "Item Identifier" VARCHAR(50),
    "Item Type" VARCHAR(50),
    "Outlet Establishment Year" INTEGER,
    "Outlet Identifier" VARCHAR(50),
    "Outlet Location Type" VARCHAR(50),
    "Outlet Size" VARCHAR(50),
    "Outlet Type" VARCHAR(50),
    "Item Visibility" REAL,
    "Item Weight" REAL,
    "Total Sales" REAL,
    "Rating" INTEGER
);

-- 1. Data-quality checks
SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT "Item Identifier") AS unique_items,
    COUNT(DISTINCT "Outlet Identifier") AS unique_outlets,
    SUM(CASE WHEN "Total Sales" IS NULL THEN 1 ELSE 0 END) AS missing_sales,
    SUM(CASE WHEN "Item Weight" IS NULL THEN 1 ELSE 0 END) AS missing_item_weight,
    SUM(CASE WHEN "Rating" IS NULL THEN 1 ELSE 0 END) AS missing_rating
FROM analytics.blinkit_grocery_data;

SELECT
    MIN("Total Sales") AS minimum_sales,
    MAX("Total Sales") AS maximum_sales,
    ROUND(AVG("Total Sales")::numeric, 2) AS average_sales,
    ROUND(AVG("Item Visibility")::numeric, 4) AS average_item_visibility,
    ROUND(AVG("Rating")::numeric, 2) AS average_rating
FROM analytics.blinkit_grocery_data;

-- 2. Overall KPIs
SELECT
    COUNT(*) AS total_records,
    ROUND(SUM("Total Sales")::numeric, 2) AS total_sales,
    ROUND(AVG("Total Sales")::numeric, 2) AS average_sales_per_record,
    ROUND(AVG("Rating")::numeric, 2) AS average_rating,
    ROUND(AVG("Item Visibility")::numeric, 4) AS average_item_visibility
FROM analytics.blinkit_grocery_data;

-- 3. Sales and KPIs by outlet type
SELECT
    "Outlet Type" AS outlet_type,
    COUNT(*) AS records,
    ROUND(SUM("Total Sales")::numeric, 2) AS total_sales,
    ROUND(AVG("Total Sales")::numeric, 2) AS average_sales,
    ROUND(AVG("Rating")::numeric, 2) AS average_rating,
    ROUND(AVG("Item Visibility")::numeric, 4) AS average_visibility
FROM analytics.blinkit_grocery_data
GROUP BY "Outlet Type"
ORDER BY total_sales DESC;

-- 4. Sales by location tier and outlet size
SELECT
    "Outlet Location Type" AS outlet_location_type,
    "Outlet Size" AS outlet_size,
    COUNT(*) AS records,
    ROUND(SUM("Total Sales")::numeric, 2) AS total_sales,
    ROUND(AVG("Total Sales")::numeric, 2) AS average_sales
FROM analytics.blinkit_grocery_data
GROUP BY "Outlet Location Type", "Outlet Size"
ORDER BY total_sales DESC;

-- 5. Product-category performance
SELECT
    "Item Type" AS item_type,
    COUNT(*) AS records,
    ROUND(SUM("Total Sales")::numeric, 2) AS total_sales,
    ROUND(AVG("Total Sales")::numeric, 2) AS average_sales,
    ROUND(AVG("Rating")::numeric, 2) AS average_rating,
    ROUND(AVG("Item Visibility")::numeric, 4) AS average_visibility
FROM analytics.blinkit_grocery_data
GROUP BY "Item Type"
ORDER BY total_sales DESC;

-- 6. Normalize inconsistent fat-content capitalization before grouping
WITH cleaned_data AS (
    SELECT
        CASE
            WHEN LOWER(TRIM("Item Fat Content")) = 'low fat' THEN 'Low Fat'
            WHEN LOWER(TRIM("Item Fat Content")) = 'regular' THEN 'Regular'
            ELSE 'Unknown'
        END AS normalized_fat_content,
        "Total Sales" AS total_sales,
        "Rating" AS rating
    FROM analytics.blinkit_grocery_data
)
SELECT
    normalized_fat_content,
    COUNT(*) AS records,
    ROUND(SUM(total_sales)::numeric, 2) AS total_sales,
    ROUND(AVG(total_sales)::numeric, 2) AS average_sales,
    ROUND(AVG(rating)::numeric, 2) AS average_rating
FROM cleaned_data
GROUP BY normalized_fat_content
ORDER BY total_sales DESC;

-- 7. Outlet establishment-year trend
SELECT
    "Outlet Establishment Year" AS outlet_establishment_year,
    COUNT(DISTINCT "Outlet Identifier") AS outlets,
    COUNT(*) AS records,
    ROUND(SUM("Total Sales")::numeric, 2) AS total_sales,
    ROUND(AVG("Total Sales")::numeric, 2) AS average_sales
FROM analytics.blinkit_grocery_data
GROUP BY "Outlet Establishment Year"
ORDER BY "Outlet Establishment Year";

-- 8. Top 10 items by sales within each outlet type
WITH ranked_items AS (
    SELECT
        "Outlet Type" AS outlet_type,
        "Item Identifier" AS item_identifier,
        "Item Type" AS item_type,
        "Total Sales" AS total_sales,
        "Rating" AS rating,
        RANK() OVER (
            PARTITION BY "Outlet Type"
            ORDER BY "Total Sales" DESC
        ) AS sales_rank
    FROM analytics.blinkit_grocery_data
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
        "Item Identifier" AS item_identifier,
        "Item Type" AS item_type,
        "Outlet Identifier" AS outlet_identifier,
        "Outlet Type" AS outlet_type,
        "Total Sales" AS total_sales,
        "Rating" AS rating
FROM analytics.blinkit_grocery_data
WHERE "Total Sales" >= (SELECT AVG("Total Sales") FROM analytics.blinkit_grocery_data)
    AND "Rating" >= 4
ORDER BY "Total Sales" DESC, "Rating" DESC;
