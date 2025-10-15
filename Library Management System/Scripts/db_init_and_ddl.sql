/*
===================================================================================
Sript for creating the database and neccessary tables for library management system
====================================================================================

This script creates the schema for a library management system in SQL Server. It includes tables for branches, employees, members, books, issue tracking and return tracking. 
Key features:
1. Uses IF OBJECT_ID(...) IS NOT NULL to check for table existence.
2. Ensures foreign key constraints are properly defined.
===========================================================
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
