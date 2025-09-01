WITH last_year_rentals AS (
    SELECT 
        rt.equipment_id,
        rt.rental_id,
        rt.customer_id,
        rt.rental_start_date,
        rt.rental_end_date,
        DATEDIFF(day, rt.rental_start_date, rt.rental_end_date) + 1 AS rental_days,
        rt.total_amount
    FROM Rental_Transactions rt
    WHERE rt.rental_start_date >= DATEADD(year, -1, GETDATE())
),

utilization AS (
    SELECT
        e.branch_id,
        e.category, 
        COUNT(DISTINCT e.equipment_id) AS total_units,
        COUNT(DISTINCT CASE WHEN r.equipment_id IS NOT NULL THEN e.equipment_id END) AS rented_units,
        SUM(ISNULL(r.rental_days, 0)) * 1.0 
            / COUNT(DISTINCT e.equipment_id) 
            / 365 AS avg_utilization_rate,
        SUM(ISNULL(r.total_amount, 0)) AS total_revenue
    FROM Equipment e
    LEFT JOIN last_year_rentals r
        ON e.equipment_id = r.equipment_id
    GROUP BY e.branch_id, e.category
),

industry_revenue AS (
    SELECT
        e.branch_id,
        e.category,
        c.industry,
        SUM(r.total_amount) AS industry_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY e.branch_id, e.category 
            ORDER BY SUM(r.total_amount) DESC
        ) AS rn
    FROM last_year_rentals r
    JOIN Equipment e
        ON r.equipment_id = e.equipment_id
    JOIN Customers c
        ON c.customer_id = r.customer_id
    GROUP BY e.branch_id, e.category, c.industry
)

SELECT 
    b.branch_name, 
    u.category,
    u.total_units, 
    u.rented_units, 
    u.avg_utilization_rate,
    u.total_revenue,
    ROUND(u.total_revenue * 1.0 / NULLIF(u.total_units, 0), 2) AS revenue_per_unit,
    ir.industry AS top_industry
FROM utilization u
JOIN Branches b
    ON u.branch_id = b.branch_id
LEFT JOIN industry_revenue ir
    ON u.branch_id = ir.branch_id 
    AND u.category = ir.category 
    AND ir.rn = 1
ORDER BY revenue_per_unit DESC;
