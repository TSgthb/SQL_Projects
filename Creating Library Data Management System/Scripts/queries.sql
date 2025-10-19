/*
------------------------------------------------------------
Task 1: Create a New Book Record
Objective: Insert a new book into the `books` table.
Book Details: 
ISBN: '978-1-60129-456-2'
Title: 'To Kill a Mockingbird'
Category: 'Classic'
Rental Price: 6.00
Status: 'yes'
Author: 'Harper Lee'
Publisher: 'J.B. Lippincott & Co.'
------------------------------------------------------------
*/

SELECT * 
FROM dbo.books;

INSERT INTO dbo.books 
VALUES (
    '978-1-60129-456-2', 
    'To Kill a Mockingbird', 
    'Classic', 
    6.00, 
    'yes', 
    'Harper Lee', 
    'J.B. Lippincott & Co.'
);

SELECT * 
FROM dbo.books;



/* 
------------------------------------------------------------
Task 2: Update an Existing Member's Name
Objective: Update the name of the member with ID 'C119' to 'John Wick'.
------------------------------------------------------------
*/

SELECT * 
FROM dbo.members
WHERE member_id = 'C119';

UPDATE dbo.members
SET member_name = 'John Wick'
WHERE member_id = 'C119';



/* 
------------------------------------------------------------
Task 3: Delete a Record from the Issued Status Table
Objective: Delete the record with issued_id = 'IS107' from the `issued_status` table.
------------------------------------------------------------
*/

SELECT * 
FROM dbo.issued_status
WHERE issued_id = 'IS107';

DELETE FROM dbo.issued_status
WHERE issued_id = 'IS107';



/* 
------------------------------------------------------------
Task 4: Retrieve All Books Issued by a Specific Employee
Objective: List all books issued by the employee with emp_id = 'E101'.
------------------------------------------------------------
*/

SELECT 
    issued_emp_id,
    issued_book_name
FROM dbo.issued_status
WHERE issued_emp_id = 'E101';



/* 
------------------------------------------------------------
Task 5: List Members Who Have Issued More Than One Book
Objective: Identify members who have issued more than one book.
------------------------------------------------------------
*/

SELECT 
    mem.member_name,
    mem.member_id,
    COUNT(iss.issued_book_name) AS count_of_books
FROM dbo.issued_status AS iss
INNER JOIN dbo.members AS mem
    ON iss.issued_member_id = mem.member_id
GROUP BY
    mem.member_name,
    mem.member_id
HAVING COUNT(iss.issued_book_name) > 1
ORDER BY count_of_books DESC;



/* 
------------------------------------------------------------
Task 6: Create Summary Table of Books Issued (CTAS)
Objective: Create a new table `books_issued` showing each book and the total number of times it was issued.
------------------------------------------------------------
*/

SELECT 
    issued_book_name,
    COUNT(issued_book_name) AS book_issued_cnt
INTO books_issued
FROM dbo.issued_status
GROUP BY issued_book_name;

SELECT * 
FROM dbo.books_issued;



/* 
------------------------------------------------------------
Task 7: Retrieve All Books in a Specific Category
Objective: List all books that belong to the 'Classic' category.
------------------------------------------------------------
*/

SELECT 
    book_title 
FROM dbo.books
WHERE category = 'Classic';



/* 
------------------------------------------------------------
Task 8: Find Total Rental Income by Category
Objective: Calculate the total rental income grouped by book category.
------------------------------------------------------------
*/

SELECT 
    category,
    SUM(rental_price) AS tot_rent_income
FROM dbo.books
GROUP BY category;



/* 
------------------------------------------------------------
Task 9: List Members Who Registered in the Last 180 Days
Objective: Identify members who registered within the last 180 days from today.
------------------------------------------------------------
*/

SELECT
    member_id,
    member_name,
    reg_date
FROM dbo.members
WHERE DATEDIFF(DAY, reg_date, GETDATE()) <= 180;



/* 
------------------------------------------------------------
Task 10: List Employees with Their Branch Manager's Name and Branch Details
Objective: Display each employee along with their branch manager's name and branch information.
------------------------------------------------------------
*/

WITH CTE AS 
(
    SELECT 
        br.manager_id,
        emp.emp_name AS man_name,
        br.branch_id,
        br.branch_address,
        br.contact_no
    FROM dbo.branch AS br 
    INNER JOIN dbo.employees AS emp 
        ON br.manager_id = emp.emp_id
)
SELECT
    emp2.emp_id,
    emp2.emp_name,
    man_det.manager_id,
    man_det.man_name,
    man_det.branch_id,
    man_det.branch_address,
    man_det.contact_no
FROM dbo.employees AS emp2
INNER JOIN CTE AS man_det
    ON emp2.branch_id = man_det.branch_id;



/* 
------------------------------------------------------------
Task 11: Create a Table of Books with High Rental Price (CTAS)
Objective: Create a new table `high_val_books` containing books with rental price greater than 7.00.
------------------------------------------------------------
*/

SELECT *
INTO high_val_books
FROM dbo.books
WHERE rental_price > 7.00;



/* 
------------------------------------------------------------
Task 12: Retrieve the List of Books Not Yet Returned
Objective: List all books that have not been returned yet.
------------------------------------------------------------
*/

SELECT 
    b.book_title,
    b.category,
    b.rental_price
FROM dbo.books AS b
LEFT JOIN dbo.return_status AS rb
    ON b.isbn = rb.return_book_isbn
WHERE rb.return_book_isbn IS NULL;



/*
------------------------------------------------------------
Task 13: Identify Members with Overdue Books
Objective: Identify members who have overdue books (not returned within 30 days).
Display: Member name, book title, issue date, and days overdue.
------------------------------------------------------------
*/

WITH CTE AS
(
    SELECT
        iss.issued_member_id,
        iss.issued_book_name,
        iss.issued_date,
        DATEADD(DAY, 30, iss.issued_date) AS due_date,
        DATEDIFF(DAY, DATEADD(DAY, 30, iss.issued_date), GETDATE()) AS days_passed
    FROM dbo.issued_status AS iss
    LEFT JOIN dbo.return_status AS rs
        ON iss.issued_id = rs.issued_id
    WHERE rs.issued_id IS NULL
)
SELECT 
    mem.member_name,
    CTE.issued_book_name,
    CTE.issued_date,
    CTE.days_passed AS days_overdue
FROM dbo.members AS mem
INNER JOIN CTE
    ON mem.member_id = CTE.issued_member_id
WHERE CTE.days_passed > 0;



/* 
------------------------------------------------------------
Task 14: Update Book Status on Return
Objective: Update the status of books to "yes" (available) when they are returned.
------------------------------------------------------------
*/

CREATE PROCEDURE sp_update_returned_book
@ret_id VARCHAR(10),
@iss_id VARCHAR(30),
@ret_date DATE = GETDATE()
AS
BEGIN
    DECLARE @temp_isbn VARCHAR(50);
    DECLARE @temp_book_name VARCHAR(80);
    
    SELECT 
        @temp_isbn = issued_book_isbn,
        @temp_book_name = issued_book_name
    FROM dbo.issued_status AS iss
    WHERE iss.issued_id = @iss_id;
        
    INSERT INTO dbo.return_status
    VALUES
    (
        @ret_id,
        @iss_id,
        @temp_book_name,
        @ret_date,
        @temp_isbn
    );
        
    UPDATE dbo.books
    SET status = 'yes'
    WHERE isbn = @temp_isbn;
END;



/* 
------------------------------------------------------------
Task 15: Branch Performance Report
Objective: Generate a report showing books issued, books returned, and total rental revenue per branch.
------------------------------------------------------------
*/

SELECT 
    br.branch_id,
    COUNT(DISTINCT iss.issued_id) AS books_issued,
    COUNT(DISTINCT ret.return_id) AS books_returned,
    SUM(bo.rental_price) AS tot_rent
FROM dbo.branch AS br
INNER JOIN dbo.employees AS emp
    ON br.branch_id = emp.branch_id
INNER JOIN dbo.issued_status AS iss
    ON emp.emp_id = iss.issued_emp_id
INNER JOIN dbo.books AS bo
    ON iss.issued_book_isbn = bo.isbn
LEFT JOIN dbo.return_status AS ret
    ON iss.issued_id = ret.issued_id
GROUP BY br.branch_id;



/* 
------------------------------------------------------------
Task 16: CTAS – Create a Table of Active Members
Objective: Create a table `active_members` containing members who issued at least one book in the last 60 days.
------------------------------------------------------------
*/

SELECT *
INTO active_members 
FROM dbo.members AS mem2
INNER JOIN 
(
    SELECT 
        mem.member_id,
        mem.member_name,
        MAX(iss.issued_date) AS last_issue
    FROM dbo.members AS mem
    INNER JOIN dbo.issued_status AS iss
        ON mem.member_id = iss.issued_member_id
    GROUP BY 
        mem.member_id,
        mem.member_name
) AS ij
    ON mem2.member_id = ij.member_id
WHERE DATEDIFF(DAY, last_issue, GETDATE()) < 60;



/* 
------------------------------------------------------------
Task 17: Find Employees with the Most Book Issues Processed
Objective: Find the top 3 employees who processed the most book issues.
Display: Employee name, number of books processed, and their branch.
------------------------------------------------------------
*/

SELECT TOP 3
    emp.emp_id,
    emp.emp_name,
    br.branch_id,
    COUNT(iss.issued_emp_id) AS tot_books_issued
FROM dbo.employees AS emp
INNER JOIN dbo.branch AS br
    ON emp.branch_id = br.branch_id
INNER JOIN dbo.issued_status AS iss
    ON emp.emp_id = iss.issued_emp_id
GROUP BY 
    emp.emp_id,
    emp.emp_name,
    br.branch_id
ORDER BY tot_books_issued DESC;



/* 
------------------------------------------------------------
Task 18: Identify Members Issuing High-Risk Books
Objective: Identify members who issued books with status "damaged" more than twice.
Display: Member name, book title, and number of times issued.
------------------------------------------------------------
*/

SELECT
    mem.member_id,
    mem.member_name,
    bo.book_title,
    COUNT(iss.issued_book_isbn) AS times_issued
FROM dbo.members AS mem
INNER JOIN dbo.issued_status AS iss
    ON mem.member_id = iss.issued_member_id
INNER JOIN dbo.books AS bo
    ON iss.issued_book_isbn = bo.isbn
WHERE bo.status = 'damaged'
GROUP BY 
    mem.member_id,
    mem.member_name,
    bo.book_title
HAVING COUNT(iss.issued_book_isbn) > 2;



/* 
------------------------------------------------------------
Task 19: Stored Procedure – Manage Book Status on Issuance
Objective: Create a stored procedure to update book status when issued.
Logic:
- If the book is available (status = 'yes'), update to 'no'.
- If not available, raise an error message.
------------------------------------------------------------
*/

CREATE OR ALTER PROCEDURE sp_issue_return_book
@book_num VARCHAR(30)
AS
BEGIN
    DECLARE @status_of_book VARCHAR(20);

    SELECT @status_of_book = status
    FROM dbo.books
    WHERE isbn = @book_num;

    IF @status_of_book = 'yes'
    BEGIN
        UPDATE dbo.books
        SET status = 'no'
        WHERE isbn = @book_num;

        PRINT('Book issued successfully!');
    END
    ELSE
    BEGIN
        RAISERROR('No books with the given number is available for renting', 16, 1);
    END
END;



/* 
------------------------------------------------------------
Task 20: CTAS – Identify Overdue Books and Calculate Fines
Objective: Create a table `overdue_and_fines` listing:
- Member ID
- Number of overdue books (not returned within 30 days)
- Total fines (0.50 per day overdue)
------------------------------------------------------------
*/

SELECT 
    sq.member_id,
    COUNT(sq.issued_book_isbn) AS total_overdue_books,
    SUM(sq.part_fine) AS tot_fine
INTO overdue_and_fines
FROM
(
    SELECT
        mem.member_id,
        iss.issued_book_isbn,
        DATEDIFF(DAY, DATEADD(DAY, 30, iss.issued_date), GETDATE()) AS days_passed,
        DATEDIFF(DAY, DATEADD(DAY, 30, iss.issued_date), GETDATE()) * 0.50 AS part_fine
    FROM dbo.members AS mem
    INNER JOIN dbo.issued_status AS iss
        ON mem.member_id = iss.issued_member_id
    LEFT JOIN dbo.return_status AS res
        ON iss.issued_id = res.issued_id
    WHERE res.issued_id IS NULL
        AND DATEDIFF(DAY, DATEADD(DAY, 30, iss.issued_date), GETDATE()) > 30
) AS sq
GROUP BY sq.member_id;
