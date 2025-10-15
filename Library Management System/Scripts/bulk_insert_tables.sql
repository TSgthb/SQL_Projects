/*
===================================================
Script for importing data from csv files into tables
====================================================
1. This script performs bulk data imports from CSV files into the library database. 
2. It uses SQL Server's BULK INSERT feature for efficient loading and includes direct inserts for supplemental records. 
======================================================================================================
*/

-- ==========================================
-- Import Branch Data
-- ==========================================
BULK INSERT dbo.branch
FROM 'C:\Users\Admin\Documents\OneDrive\Desktop\SQL\Projects\Library Managment System\Sources\branch.csv'
WITH
(
    FIRSTROW = 2,              -- Skip header row
    FIELDTERMINATOR = ',',     -- CSV delimiter
    TABLOCK                    -- Lock table during insert for performance
);
GO

SELECT * FROM dbo.branch;
GO

-- ==========================================
-- Import Employee Records
-- ==========================================
BULK INSERT dbo.employees
FROM 'C:\Users\Admin\Documents\OneDrive\Desktop\SQL\Projects\Library Managment System\Sources\employees.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

SELECT * FROM dbo.employees;
GO

-- ==========================================
-- Import Member Registry
-- ==========================================
BULK INSERT dbo.members
FROM 'C:\Users\Admin\Documents\OneDrive\Desktop\SQL\Projects\Library Managment System\Sources\members.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

SELECT * FROM dbo.members;
GO

-- ==========================================
-- Import Book Catalog
-- ==========================================
BULK INSERT dbo.books
FROM 'C:\Users\Admin\Documents\OneDrive\Desktop\SQL\Projects\Library Managment System\Sources\books.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

SELECT * FROM dbo.books;
GO

-- Add supplemental book entry not present in CSV
INSERT INTO dbo.books(isbn, book_title, category, rental_price, status, author, publisher) 
VALUES
('978-0-393-91257-8', 'Guns, Germs, and Steel: The Fates of Human Societies', 'History', 7.00, 'yes', 'Jared Diamond', 'W. W. Norton & Company');
GO

-- ==========================================
-- Import Issued Book Records
-- ==========================================
BULK INSERT dbo.issued_status
FROM 'C:\Users\Admin\Documents\OneDrive\Desktop\SQL\Projects\Library Managment System\Sources\issued_status.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

SELECT * FROM dbo.issued_status;
GO

-- Add manual issue record for newly inserted book
INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id) 
VALUES
('IS116', 'C110', 'Guns, Germs, and Steel: The Fates of Human Societies', '2024-03-20', '978-0-393-91257-8', 'E107');
GO

-- ==========================================
-- Import Return Records
-- ==========================================
BULK INSERT dbo.return_status
FROM 'C:\Users\Admin\Documents\OneDrive\Desktop\SQL\Projects\Library Managment System\Sources\return_status.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

SELECT * FROM dbo.return_status;
GO
