WITH cte AS (
    SELECT 
        s.StudentID, 
        s.StudentName, 
        c.CourseName, 
        e.ExamName, 
        CASE 
            WHEN e.TotalPoints > 0 THEN (se.Score * 100.0 / e.TotalPoints)
            ELSE NULL
        END AS Score
    FROM Students s
    INNER JOIN student_exams se -- Linking Table needed due to many-many relationship between Students and Exams
        ON s.StudentID = se.StudentID
    INNER JOIN exams e 
        ON se.ExamID = e.ExamID
    INNER JOIN Courses c 
        ON e.CourseID = c.CourseID
),

course_average_cte AS (
    SELECT 
        StudentName, 
        CourseName, 
        Score, 
        AVG(Score) OVER (PARTITION BY StudentName, CourseName) AS course_avg
    FROM cte
    GROUP BY StudentName, CourseName, Score
),

global_cte AS (
    SELECT 
        CourseName, 
        AVG(Score) AS global_course_avg
    FROM cte
    GROUP BY CourseName
)

SELECT 
    DISTINCT StudentName, 
    course_avg, 
    global_course_avg 
FROM course_average_cte c
INNER JOIN global_cte g 
    ON c.CourseName = g.CourseName
WHERE 
    c.CourseName LIKE '%Pharmacology%' 
    AND c.course_avg > g.global_course_avg;
