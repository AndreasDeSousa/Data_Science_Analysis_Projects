/*

CTE (Common Table Expression)

*/
------------------------------------------------------------------------------------------------------------------------

WITH CTE_Employee AS ( SELECT FirstName, LastName, gender, Salary,
                        COUNT(gender) OVER(PARTITION by GENDER) as TotalGender,
                        AVG(Salary) OVER(PARTITION BY  GENDER) AS AvgSalary,
                       FROM SQLDB..EmployeeDemographics Emp
                       JOIN SQLDB..EmployeeSalary Sal
                            ON emp.EmployeeID = sal.EmployeeID
                        WHERE Salary > '45000'
)
SELECT *
FROM CTE_Employee;

