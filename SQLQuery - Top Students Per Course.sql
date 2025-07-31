with cte as (
	SELECT DISTINCT
		s.StudentName,
		c.CourseName,
		avg(se.Normalized_Score) OVER(PARTITION BY StudentName, CourseName) as avg_per_course
	FROM student_exams se
	INNER JOIN students s 
		on se.StudentID = s.StudentID
	INNER JOIN exams e
		on se.ExamID = e.ExamID
	INNER JOIN courses c
		on e.CourseID = c.CourseID
),

cte2 as (
	SELECT 
		StudentName,
		CourseName, 
		avg_per_course,
		DENSE_RANK() OVER(PARTITION BY CourseName ORDER BY avg_per_course desc) as ranking
	FROM cte
)

SELECT 
	StudentName, 
	CourseName, 
	avg_per_course, 
	ranking
FROM cte2 
WHERE ranking = 1