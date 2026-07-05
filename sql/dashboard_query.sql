/*
===============================================================================
Project: Real-Time Operations Analytics Dashboard
Author : Vijay Sharma

Description:
This query demonstrates the SQL design used to build an Operations Analytics
Dashboard.

The original production query has been simplified for portfolio purposes.

Technology:
- PostgreSQL
- Advanced SQL
- Metabase

Key Features:
✔ Common Table Expressions (CTEs)
✔ Window Functions
✔ Forecast vs Actual Analysis
✔ Hourly KPI Calculations
✔ Product Deactivation Monitoring
✔ Cumulative Metrics
✔ Business Rule Based Aggregations

===============================================================================
*/

------------------------------------------------------------
-- Step 1 : Daily Orders
------------------------------------------------------------

WITH daily_orders AS (

SELECT

    order_date,
    order_hour,
    city,
    dark_store,
    COUNT(order_id) AS delivered_orders

FROM orders

WHERE order_date = CURRENT_DATE

GROUP BY

    order_date,
    order_hour,
    city,
    dark_store

),

------------------------------------------------------------
-- Step 2 : Forecast Data
------------------------------------------------------------

forecast AS (

SELECT

    order_hour,
    city,
    dark_store,
    forecast_orders

FROM forecast_master

WHERE forecast_date = CURRENT_DATE

),

------------------------------------------------------------
-- Step 3 : Hourly KPI Calculation
------------------------------------------------------------

hourly_kpi AS (

SELECT

    d.city,

    d.dark_store,

    d.order_hour,

    f.forecast_orders,

    d.delivered_orders,

    (f.forecast_orders - d.delivered_orders) AS gap,

    ROUND(

        d.delivered_orders * 100.0 /

        NULLIF(f.forecast_orders,0),

        2

    ) AS achievement_percentage

FROM daily_orders d

LEFT JOIN forecast f

ON d.city=f.city
AND d.dark_store=f.dark_store
AND d.order_hour=f.order_hour

),

------------------------------------------------------------
-- Step 4 : Product Deactivation
------------------------------------------------------------

product_deactivation AS (

SELECT

    city,

    dark_store,

    COUNT(CASE WHEN product_rank <=50 THEN 1 END) AS c0,

    COUNT(CASE WHEN product_rank BETWEEN 51 AND 100 THEN 1 END) AS c1,

    COUNT(CASE WHEN product_rank BETWEEN 101 AND 200 THEN 1 END) AS c2,

    COUNT(CASE WHEN product_rank >200 THEN 1 END) AS c3

FROM inactive_products

GROUP BY

city,
dark_store

),

------------------------------------------------------------
-- Step 5 : Final Dashboard Output
------------------------------------------------------------

SELECT

    h.city,

    h.dark_store,

    h.order_hour,

    h.forecast_orders,

    h.delivered_orders,

    h.gap,

    h.achievement_percentage,

    p.c0,

    p.c1,

    p.c2,

    p.c3

FROM hourly_kpi h

LEFT JOIN product_deactivation p

ON h.city=p.city
AND h.dark_store=p.dark_store

ORDER BY

h.city,
h.dark_store,
h.order_hour;





/*
===============================================================================

Business Logic Summary

Forecast
---------
Expected customer orders.

Delivered Orders
----------------
Actual completed orders.

Gap
---
Forecast - Delivered

Achievement %
-------------
Delivered Orders / Forecast × 100

Product Deactivation

C0 = Top 50 ranked products

C1 = Rank 51–100

C2 = Rank 101–200

C3 = Rank 201+

===============================================================================
*/
