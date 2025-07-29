WITH cte AS (
    SELECT 
        s.StudentName, 
        c.CourseName, 
        e.ExamName, 
        se.Normalized_Score,
        AVG(se.Normalized_Score) OVER (
            PARTITION BY s.StudentName, c.CourseName
        ) AS Avg_Normalized_Score_Per_Course
    FROM Students s
    JOIN student_exams se ON s.StudentID = se.StudentID
    JOIN exams e ON se.ExamID = e.ExamID
    JOIN Courses c ON e.CourseID = c.CourseID
),

ranked AS (
    SELECT 
        StudentName, 
        CourseName, 
        ROUND(Avg_Normalized_Score_Per_Course, 2) AS AvgScore,
        DENSE_RANK() OVER (
            PARTITION BY CourseName 
            ORDER BY Avg_Normalized_Score_Per_Course DESC
        ) AS Ranking
    FROM cte
    GROUP BY StudentName, CourseName, Avg_Normalized_Score_Per_Course
)

SELECT 
    StudentName, 
    CourseName, 
    AvgScore,
    Ranking
FROM ranked
WHERE Ranking BETWEEN 1 AND 3
ORDER BY CourseName, Ranking;