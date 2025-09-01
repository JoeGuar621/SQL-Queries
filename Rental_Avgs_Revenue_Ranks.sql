WITH cte AS (
    SELECT 
        e.branch_id, 
        e.category,
        COUNT(DISTINCT rt.rental_id) AS num_rentals,
        SUM(ISNULL(rt.total_amount, 0)) AS total_revenue, 
        DATEDIFF(day, rt.rental_start_date, rt.rental_end_date) + 1 AS rental_days
    FROM Equipment e
    LEFT JOIN Rental_Transactions rt
        ON e.equipment_id = rt.equipment_id
    GROUP BY e.branch_id, e.category
),

cte2 AS ( 
    SELECT 
        c.branch_id, 
        c.category,
        c.total_revenue,
        c.num_rentals, 
        AVG(c.rental_days) AS avg_rental, 
        c.total_revenue * 1.0 / NULLIF(c.num_rentals, 0) AS avg_revenue_per_rental,
        DENSE_RANK() OVER (
            PARTITION BY c.branch_id 
            ORDER BY c.total_revenue DESC
        ) AS ranking
    FROM cte c
    GROUP BY c.branch_id, c.category, c.total_revenue, c.num_rentals
)

SELECT 
    b.branch_name,
    c2.category,
    c2.num_rentals,
    c2.avg_rental,
    c2.avg_revenue_per_rental,
    c2.ranking
FROM cte2 c2
JOIN Branches b
    ON c2.branch_id = b.branch_id
ORDER BY b.branch_name, c2.ranking DESC;
