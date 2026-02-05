use Lone;
			-- Data Cleaning --

			-- Find the Dublicates values --
select id, address_state, application_type, emp_length, emp_title, grade, home_ownership, 
		issue_date, last_credit_pull_date, last_payment_date, loan_status, next_payment_date, 
		member_id, purpose, sub_grade, term, verification_status, annual_income, dti, 
		installment, int_rate, loan_amount, total_acc, total_payment, count(*) as 'count_of_rows'
		from loan_data
group by id, address_state, application_type, emp_length, emp_title, grade, home_ownership, 
		issue_date, last_credit_pull_date, last_payment_date, loan_status, next_payment_date, 
		member_id, purpose, sub_grade, term, verification_status, annual_income, dti, 
		installment, int_rate, loan_amount, total_acc, total_payment
having count(*) > 1	 -- No Dublicate values found --

		-- Remove null income records
DELETE FROM loan_data
WHERE annual_income IS NULL;

		-- Standardize loan status
UPDATE loan_data
SET loan_status = TRIM(loan_status);

		-- Remove invalid DTI
DELETE FROM loan_data
WHERE dti < 0;

		-- Kpi_Metrics --
-- Total Number of loans
select count(id) as 'Total_number_of_loans' from loan_data;

-- Total Amount of loans
select sum(loan_amount) as 'Total_loan_amount' from loan_data;

-- Default Rate
select 
sum(case when loan_status = 'Charged Off' then 1 else 0 end)*100/count(id) as 'default_rate'
from loan_data;

-- Fully Paid
select 
sum(case when loan_status = 'Fully Paid' then 1 else 0 end)*100/count(*) as 'Fully_Paid_rate'
from loan_data;

-- Default Rate by Grade
select grade,
sum(case when loan_status = 'Charged Off' then 1 else 0 end) as 'Default',
round(sum(case when loan_status = 'Charged Off' then 1 else 0 end)*100/count(*) ,2)
as 'default_rate'
from loan_data
group by grade
order By grade;

-- Home Ownership Risk
SELECT home_ownership,
COUNT(*) AS loans,
SUM(CASE WHEN loan_status='Charged Off' THEN 1 ELSE 0 END) AS defaults
FROM loan_data
GROUP BY home_ownership;

-- Income vs Default
SELECT
CASE
    WHEN annual_income < 40000 THEN 'Low Income'
    WHEN annual_income BETWEEN 40000 AND 80000 THEN 'Mid Income'
    ELSE 'High Income'
END AS income_group,
COUNT(id) AS loans,
SUM(CASE WHEN loan_status='Charged Off' THEN 1 ELSE 0 END) AS defaults
FROM loan_data
GROUP BY CASE
    WHEN annual_income < 40000 THEN 'Low Income'
    WHEN annual_income BETWEEN 40000 AND 80000 THEN 'Mid Income'
    ELSE 'High Income'
END ;

-- State-wise Default
SELECT address_state,
    COUNT(id) AS loans,
    SUM(CASE WHEN loan_status='Charged Off' THEN 1 ELSE 0 END) AS defaults
    FROM loan_data
GROUP BY
    address_state
ORDER BY
    defaults DESC;

-- LOAN STATUS
	SELECT
        loan_status,
        COUNT(id) AS LoanCount,
        SUM(total_payment) AS Total_Amount_Received,
        SUM(loan_amount) AS Total_Funded_Amount,
        AVG(int_rate * 100) AS Interest_Rate,
        AVG(dti * 100) AS DTI
    FROM
        loan_data
    GROUP BY
        loan_status;

--MONTHWISE OVERVIEW
SELECT 
	MONTH(issue_date) AS Month_Munber, 
	DATENAME(MONTH, issue_date) AS Month_name, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM loan_data
GROUP BY MONTH(issue_date), DATENAME(MONTH, issue_date)
ORDER BY MONTH(issue_date);

-- STATEWISE OVERVIEW
SELECT 
	address_state AS State, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM loan_data
GROUP BY address_state
ORDER BY address_state;

-- TERMWISE OVERVIEW
SELECT 
	term AS Term, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM loan_data
GROUP BY term
ORDER BY term;

-- PURPOSEWISE OVERVIEW
SELECT 
	purpose AS PURPOSE, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM loan_data
GROUP BY purpose
ORDER BY purpose;













































