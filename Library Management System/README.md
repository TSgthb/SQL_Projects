# Library Management System

## Project Overview

This project demonstrates the implementation of a library management system using SQL Server. It includes creating the database and schema, loading data from CSV sources, performing CRUD operations, creating summary tables using CTAS patterns, and developing advanced queries and stored procedures for operational reporting and data maintenance.

## Objectives

1. **Set up the library management system database and create tables for branches, employees, members, books, issue tracking and return tracking.**
2. **Load data efficiently into tables using bulk import utilities and supplement with manual inserts where necessary.**
3. **Perform CRUD operations and create summary tables using CTAS (create table as select).**
4. **Implement advanced SQL queries and stored procedures to support reporting, overdue detection and automated status updates.**

## Project Structure

### 1. Database Setup

- **ERD creation:** Create an entity-relationship diagram for the database showing how different tables connect

![ERD](https://github.com/TSgthb/SQL_Projects/blob/0993ba6ce763580622b16ec4df5c437809a9b6d4/Library%20Management%20System/Documents/entity_relationship_diagram.png)
*Note: The above diagram only shows the primary and foreign keys of the table.*
  
- **Database creation:** Create a database named `library_mgmt_sys`.
- **Table creation:** Create tables for branch, employees, members, books, issued_status and return_status.
```sql
/*
 Script for creating the database and necessary tables for library management system.
 The script creates the schema used across the project and ensures foreign keys are defined.
*/

-- ==========================================
-- Create Database: library_mgmt_sys
-- ==========================================
CREATE DATABASE library_mgmt_sys;
GO

USE library_mgmt_sys;
GO

-- ==========================================
-- Table: Branch Information
-- ==========================================
IF OBJECT_ID('branch', 'U') IS NOT NULL
    DROP TABLE branch;
GO

CREATE TABLE branch
(
    branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10),
    branch_address VARCHAR(30),
    contact_no VARCHAR(15)
);
GO

-- ==========================================
-- Table: Employee Directory
-- ==========================================
IF OBJECT_ID('employees', 'U') IS NOT NULL
    DROP TABLE employees;
GO

CREATE TABLE employees
(
    emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(30),
    position VARCHAR(30),
    salary DECIMAL(10,2),
    branch_id VARCHAR(10),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);
GO

-- ==========================================
-- Table: Library Members Registry
-- ==========================================
IF OBJECT_ID('members', 'U') IS NOT NULL
    DROP TABLE members;
GO

CREATE TABLE members
(
    member_id VARCHAR(10) PRIMARY KEY,
    member_name VARCHAR(30),
    member_address VARCHAR(30),
    reg_date DATE
);
GO

-- ==========================================
-- Table: Book Catalog
-- ==========================================
IF OBJECT_ID('books', 'U') IS NOT NULL
    DROP TABLE books;
GO

CREATE TABLE books
(
    isbn VARCHAR(50) PRIMARY KEY,
    book_title VARCHAR(80),
    category VARCHAR(30),
    rental_price DECIMAL(10,2),
    status VARCHAR(10),
    author VARCHAR(30),
    publisher VARCHAR(30)
);
GO

-- ==========================================
-- Table: Book Issue Tracking
-- ==========================================
IF OBJECT_ID('issued_status', 'U') IS NOT NULL
    DROP TABLE issued_status;
GO

CREATE TABLE issued_status
(
    issued_id VARCHAR(10) PRIMARY KEY,
    issued_member_id VARCHAR(30),
    issued_book_name VARCHAR(80),
    issued_date DATE,
    issued_book_isbn VARCHAR(50),
    issued_emp_id VARCHAR(10),
    FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
    FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
    FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn)
);
GO

-- ==========================================
-- Table: Book Return Records
-- ==========================================
IF OBJECT_ID('return_status', 'U') IS NOT NULL
    DROP TABLE return_status;
GO

CREATE TABLE return_status
(
    return_id VARCHAR(10) PRIMARY KEY,
    issued_id VARCHAR(30),
    return_book_name VARCHAR(80),
    return_date DATE,
    return_book_isbn VARCHAR(50),
    FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
GO
```

### 2. Data Loading

- **Bulk import:** Use BULK INSERT to load source CSVs into corresponding tables for performance. The working script here uses FIRSTROW = 2 to skip headers, FIELDTERMINATOR = ',' and TABLOCK for speed.
- **Supplemental inserts:** After bulk loading, scripts insert supplemental rows not loaded (due to special characters in fields) from CSVs and add corresponding issued records as needed.

### 3. CRUD Operations

- **Create:** Insert new book records and other sample data.
- **Read:** Select queries used to validate data after load.
- **Update:** Update member or book information as required.
- **Delete:** Remove specific records with care and verification.

**1. Create a new book record**

```sql
/*
------------------------------------------------------------
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
```

**2. Update an existing member's name**

```sql
/* 
------------------------------------------------------------
Objective: Update the name of the member with ID 'C119' to 'John Wick'.
------------------------------------------------------------
*/

SELECT * 
FROM dbo.members
WHERE member_id = 'C119';

UPDATE dbo.members
SET member_name = 'John Wick'
WHERE member_id = 'C119';
```

**3. Delete a record from the issued_status table**

```sql
/* 
------------------------------------------------------------
Objective: Delete the record with issued_id = 'IS107' from the `issued_status` table.
------------------------------------------------------------
*/

SELECT * 
FROM dbo.issued_status
WHERE issued_id = 'IS107';

DELETE FROM dbo.issued_status
WHERE issued_id = 'IS107';
```

**4. retrieve all books issued by a specific employee**

```sql
------------------------------------------------------------
Objective: List all books issued by the employee with emp_id = 'E101'.
------------------------------------------------------------
*/

SELECT 
    issued_emp_id,
    issued_book_name
FROM dbo.issued_status
WHERE issued_emp_id = 'E101';
```

**5. List members who have issued more than one book**

```sql
/* 
------------------------------------------------------------
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
```

### 4. CTAS (create table as select)

Following summary tables have been created to accelerate reporting and analytics:

**6. Create summary table of books issued**

```sql
/* 
------------------------------------------------------------
Objective: Create a new table `books_issued` showing each book and the total number of times it was issued.
------------------------------------------------------------
*/

SELECT
    issued_book_name,
    COUNT(issued_book_name) AS book_issued_cnt
INTO books_issued
FROM dbo.issued_status
GROUP BY issued_book_name;

SELECT * FROM dbo.books_issued;
```

**7. Create a table of active members**

```sql
------------------------------------------------------------
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
```

**8. Create a table of books with high rental price**

```sql
/* 
------------------------------------------------------------
Objective: Create a new table `high_val_books` containing books with rental price greater than 7.00.
------------------------------------------------------------
*/

SELECT *
INTO high_val_books
FROM dbo.books
WHERE rental_price > 7.00;
```

### 5. Data Analysis & Findings

The below scripts include a variety of reporting queries to support operations and analytics:

**9. Retrieve all books in a specific category**

```sql
/* 
------------------------------------------------------------
Objective: List all books that belong to the 'Classic' category.
------------------------------------------------------------
*/

SELECT 
    book_title 
FROM dbo.books
WHERE category = 'Classic';
```

**10. Find total rental income by category**

```sql
/* 
------------------------------------------------------------
Objective: Calculate the total rental income grouped by book category.
------------------------------------------------------------
*/

SELECT 
    category,
    SUM(rental_price) AS tot_rent_income
FROM dbo.books
GROUP BY category;
```

**11. List members who registered in the last 180 days**

```sql
/* 
------------------------------------------------------------
Objective: Identify members who registered within the last 180 days from today.
------------------------------------------------------------
*/

SELECT
    member_id,
    member_name,
    reg_date
FROM dbo.members
WHERE DATEDIFF(DAY, reg_date, GETDATE()) <= 180;
```

**12. List employees with their branch manager's name and branch details**

```sql
/* 
------------------------------------------------------------
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
```

**13. Retrieve the list of books not yet returned**

```sql
/* 
------------------------------------------------------------
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
```

**14. Identify members with overdue books**

```sql
/*
------------------------------------------------------------
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
```

### 6. Advanced SQL Operations

The following scripts include stored procedures and more complex reporting:

**15. Update book status on return**

```sql
/* 
------------------------------------------------------------
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
```

**16. Branch performance report**

```sql
/* 
------------------------------------------------------------
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
```

**17. Find employees with the most book issues processed**

```sql
/* 
------------------------------------------------------------
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
```

**18. Identify members issuing high-risk books**

```sql
/* 
------------------------------------------------------------
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
```

**19. Stored procedure – Manage book status on issuance**

```sql
/* 
------------------------------------------------------------
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
```

**20. CTAS – Identify overdue books and calculate fines**

```sql
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
```

## Conclusion 

- **Database schema:** Detailed table structures and foreign keys are defined in the DDL above.
- **Data analysis:** The queries provide insights into book categories, member activity, employee performance and branch-level metrics.
- **Summary reports:** CTAS outputs (books_issued, branch_reports, active_members, overdue_fines) support operational decision making and reporting.







