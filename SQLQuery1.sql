CREATE DATABASE [db_21.04]
GO
USE [db_21.04]
GO 

CREATE TABLE Goods (
    GoodsID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(255),
    Type VARCHAR(50),
    Quantity INT,
    CostPrice DECIMAL(10, 2),
    Manufacturer VARCHAR(100),
    SalePrice DECIMAL(10, 2)
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FullName VARCHAR(255),
    Position VARCHAR(100),
    EmploymentDate DATE,
    Gender VARCHAR(10),
    Salary DECIMAL(10, 2)
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(255),
    Email VARCHAR(255),
    ContactPhone VARCHAR(20),
    Gender VARCHAR(10),
    OrderHistory TEXT,
    DiscountPercentage DECIMAL(5, 2),
    SignedForMailing BIT
);

CREATE TABLE Sales (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    GoodsID INT,
    SalePrice DECIMAL(10, 2),
    Quantity INT,
    SaleDate DATE,
    SellerID INT,
    BuyerID INT,
    FOREIGN KEY (GoodsID) REFERENCES Goods(GoodsID),
    FOREIGN KEY (SellerID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (BuyerID) REFERENCES Customers(CustomerID)
);
