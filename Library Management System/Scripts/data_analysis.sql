-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'"

SELECT * FROM dbo.books

INSERT INTO dbo.books 
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

SELECT * FROM dbo.books

-- Task 2: Update an Existing Member's Name

SELECT * FROM dbo.members
WHERE member_id = 'C119'

UPDATE dbo.members
SET member_name = 'John Wick'
WHERE member_id = 'C119'

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS107' from the issued_status table.

SELECT * 
FROM dbo.issued_status
WHERE issued_id = 'IS107'

DELETE FROM dbo.issued_status
WHERE issued_id = 'IS107'

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT 
    issued_emp_id,
    issued_book_name
FROM dbo.issued_status
WHERE issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
    mem.member_name,
    mem.member_id,
    COUNT(iss.issued_book_name) AS count_of_books
FROM dbo.issued_status iss
    INNER JOIN dbo.members AS mem
    ON  iss.issued_member_id = mem.member_id
GROUP BY
    mem.member_name,
    mem.member_id
HAVING COUNT(iss.issued_book_name) > 1
ORDER BY count_of_books DESC

-- ### 3. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

SELECT 
    issued_book_name,
    COUNT(issued_book_name) AS book_issued_cnt
INTO books_issued
FROM dbo.issued_status
GROUP BY issued_book_name

SELECT *
FROM dbo.books_issued


-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:

SELECT book_title 
FROM dbo.books
WHERE category = 'Classic'

-- Task 8: Find Total Rental Income by Category:

SELECT 
    category,
    SUM(rental_price) AS tot_rent_income
FROM dbo.books
GROUP BY category

-- Task 9. **List Members Who Registered in the Last 180 Days**:

-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold

-- Task 12: Retrieve the List of Books Not Yet Returned

    
/*
### Advanced SQL Operations

Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.


Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table).



Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.


Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.



Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.


Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    


Task 19: Stored Procedure
Objective: Create a stored procedure to manage the status of books in a library system.
    Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
    If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.

Task 20: Create Table As Select (CTAS)
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
