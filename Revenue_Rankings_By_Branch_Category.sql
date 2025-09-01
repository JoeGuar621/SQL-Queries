WITH CTE_CategoryRevenue AS (
    SELECT  
        b.branch_name,
        e.category, 
        SUM(rt.total_amount) AS total_revenue,
        AVG(DATEDIFF(DAY, rt.rental_start_date, rt.rental_end_date) + 1) AS avg_rental_length
    FROM Equipment e
    JOIN Branches b
        ON e.branch_id = b.branch_id
    JOIN Rental_Transactions rt
        ON e.equipment_id = rt.equipment_id
    GROUP BY 
        b.branch_name, 
        e.category
),

CTE_RankedCategories AS (
    SELECT 
        c.branch_name,
        c.category,
        c.total_revenue,
        c.avg_rental_length,
        SUM(c.total_revenue) OVER (PARTITION BY c.branch_name) AS total_branch_revenue,
        DENSE_RANK() OVER (
            PARTITION BY c.branch_name 
            ORDER BY c.total_revenue DESC
        ) AS category_ranking
    FROM CTE_CategoryRevenue c
)

SELECT 
    c2.branch_name,
    c2.category,
    c2.total_revenue,
    c2.total_revenue * 1.0 / c2.total_branch_revenue AS share_branch_revenue
FROM CTE_RankedCategories c2
WHERE c2.category_ranking <= 3
ORDER BY 
    c2.branch_name, 
    c2.category_ranking DESC;
