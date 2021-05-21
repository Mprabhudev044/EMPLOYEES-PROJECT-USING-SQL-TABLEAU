# COMBINING SQL+TABLEAU 

-- Q1 Create a visualization that provides a breakdown between the male and female employees working in the company each year, starting from 1990. 


USE employees_mod;  -- to use the employees mod database

SELECT 
    YEAR(d.from_date) AS Calender_year,
    e.gender,
    COUNT(e.emp_no) AS no_of_employees
FROM
    t_employees e
        JOIN
    t_dept_emp d ON e.emp_no = d.emp_no
GROUP BY Calender_year , e.gender
HAVING calender_year >= 1990
ORDER BY Calender_year ASC;

-- Q2  Compare the number of male managers to the number of female managers from different departments for each year, starting from 1990.

SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN
            YEAR(dm.to_date) >= e.calendar_year
                AND YEAR(dm.from_date) <= e.calendar_year  -- we dont know weather the employee is acting as a manager or not as per the question.
        THEN
            1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees 
    GROUP BY calendar_year) e -- this subquery is renamed as e.
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
        JOIN
    t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no , calendar_year;

-- Q3 average salary of female versus male employees in the entire company till 2002 per each department

SELECT 
    e.gender,
    d.dept_name,
    ROUND(AVG(s.salary), 2) AS salary,
    YEAR(s.from_date) AS calendar_year
FROM
    t_salaries s
        JOIN
    t_employees e ON s.emp_no = e.emp_no
        JOIN
    t_dept_emp de ON de.emp_no = e.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_no , e.gender , calendar_year
HAVING calendar_year <= 2002
ORDER BY d.dept_no;

-- Q4 Create an SQL stored procedure to obtain the average male and female salary per department within 50000 and 90000.

DELIMITER $$
CREATE PROCEDURE filter_salary (IN p_min_salary FLOAT, IN p_max_salary FLOAT)
BEGIN
SELECT 
    e.gender, d.dept_name, AVG(s.salary) as avg_salary
FROM
    t_salaries s
        JOIN
    t_employees e ON s.emp_no = e.emp_no
        JOIN
    t_dept_emp de ON de.emp_no = e.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no
    WHERE s.salary BETWEEN p_min_salary AND p_max_salary
GROUP BY d.dept_no, e.gender;
END$$

DELIMITER ;

CALL filter_salary(50000, 90000);
