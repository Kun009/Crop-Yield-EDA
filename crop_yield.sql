1. –CREATE THE TABLE
CREATE SCHEMA IF NOT EXISTS crop_yield_data;
-- Create table with appropriate data types and constraints
CREATE TABLE IF NOT EXISTS crop_yield_data.crop_yield (
    rainfall_mm NUMERIC(8),
    soil_quality_index NUMERIC(8),
    farm_size_hectares NUMERIC(8),
    sunlight_hours NUMERIC(8),
    fertilizer_kg NUMERIC(8),
    crop_yield NUMERIC(8) 
);


2. --BASIC STATISTICS SUMMARY
SELECT 
    round(avg(crop_yield)::numeric, 2) as avg_yield,
    round(stddev(crop_yield)::numeric, 2) as std_yield,
    round(min(crop_yield)::numeric, 2) as min_yield,
    round(max(crop_yield)::numeric, 2) as max_yield,
    round(percentile_cont(0.5) WITHIN GROUP (ORDER BY crop_yield)::numeric, 2) as median_yield
FROM crop_yield_data.crop_yield;

3. –CORRELATION ANALYSIS 
SELECT 
    round(corr(rainfall_mm, crop_yield)::numeric, 3) as rainfall_correlation,
    round(corr(soil_quality_index, crop_yield)::numeric, 3) as soil_correlation,
    round(corr(farm_size_hectares, crop_yield)::numeric, 3) as farm_size_correlation,
    round(corr(sunlight_hours, crop_yield)::numeric, 3) as sunlight_correlation,
    round(corr(fertilizer_kg, crop_yield)::numeric, 3) as fertilizer_correlation
FROM crop_yield_data.crop_yield;
4. -- Distribution Analysis using WIDTH_BUCKET for each variable
-- Rainfall Distribution
SELECT 
    width_bucket(rainfall_mm, 
        (SELECT min(rainfall_mm) FROM crop_yield_data.crop_yield), 
        (SELECT max(rainfall_mm) FROM crop_yield_data.crop_yield), 
        5) as bucket,
    count(*) as count,
    round(min(rainfall_mm), 2) as min_value,
    round(max(rainfall_mm), 2) as max_value,
    round(avg(crop_yield), 2) as avg_yield
FROM crop_yield_data.crop_yield
GROUP BY bucket
ORDER BY bucket;

b. -- Soil Quality Distribution
SELECT 
    width_bucket(soil_quality_index, 
        (SELECT min(soil_quality_index) FROM crop_yield_data.crop_yield), 
        (SELECT max(soil_quality_index) FROM crop_yield_data.crop_yield), 
        5) as bucket,
    count(*) as count,
    round(avg(crop_yield), 2) as avg_yield
FROM crop_yield_data.crop_yield
GROUP BY bucket
ORDER BY bucket;

5. -- High Yield Analysis 
WITH top_yields AS (
    SELECT *
    FROM crop_yield_data.crop_yield
    WHERE crop_yield >= (
        SELECT percentile_cont(0.9) WITHIN GROUP (ORDER BY crop_yield)
        FROM crop_yield_data.crop_yield
    )
)
SELECT 
    round(avg(rainfall_mm), 2) as avg_rainfall,
    round(avg(soil_quality_index), 2) as avg_soil_quality,
    round(avg(farm_size_hectares), 2) as avg_farm_size,
    round(avg(sunlight_hours), 2) as avg_sunlight,
    round(avg(fertilizer_kg), 2) as avg_fertilizer,
    round(avg(crop_yield), 2) as avg_yield
FROM top_yields;

6. -- Farm Size Categories Analysis
SELECT 
    CASE 
        WHEN farm_size_hectares < (SELECT percentile_cont(0.33) WITHIN GROUP (ORDER BY farm_size_hectares) FROM crop_yield_data.crop_yield) THEN 'Small'
        WHEN farm_size_hectares < (SELECT percentile_cont(0.67) WITHIN GROUP (ORDER BY farm_size_hectares) FROM crop_yield_data.crop_yield) THEN 'Medium'
        ELSE 'Large'
    END as farm_category,
    count(*) as count,
    round(avg(farm_size_hectares), 2) as avg_size,
    round(avg(crop_yield), 2) as avg_yield,
    round(avg(fertilizer_kg), 2) as avg_fertilizer
FROM crop_yield_data.crop_yield
GROUP BY farm_category
ORDER BY avg_size;

7. -- Summary Statistics by Farm Size Category
WITH farm_categories AS (
    SELECT *,
        CASE 
            WHEN farm_size_hectares < (SELECT percentile_cont(0.33) WITHIN GROUP (ORDER BY farm_size_hectares) FROM crop_yield_data.crop_yield) THEN 'Small'
            WHEN farm_size_hectares < (SELECT percentile_cont(0.67) WITHIN GROUP (ORDER BY farm_size_hectares) FROM crop_yield_data.crop_yield) THEN 'Medium'
            ELSE 'Large'
        END as farm_category
    FROM crop_yield_data.crop_yield
)
SELECT 
    farm_category,
    round(avg(rainfall_mm), 2) as avg_rainfall,
    round(avg(soil_quality_index), 2) as avg_soil_quality,
    round(avg(sunlight_hours), 2) as avg_sunlight,
    round(avg(fertilizer_kg), 2) as avg_fertilizer,
    round(avg(crop_yield), 2) as avg_yield
FROM farm_categories
GROUP BY farm_category
ORDER BY avg_yield DESC;




