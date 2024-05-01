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


-- Trigger to insert information about the sale into the History table
CREATE TRIGGER trg_InsertSaleHistory
ON Sales
AFTER INSERT
AS
BEGIN
    INSERT INTO History (SaleID, GoodsID, SalePrice, Quantity, SaleDate, SellerID, BuyerID)
    SELECT SaleID, GoodsID, SalePrice, Quantity, SaleDate, SellerID, BuyerID
    FROM inserted;
END;
GO

-- Trigger to transfer fully sold goods to the Archive table
CREATE TRIGGER trg_TransferToArchive
ON Sales
AFTER DELETE
AS
BEGIN
    INSERT INTO Archive (GoodsID, SalePrice, Quantity, SaleDate, SellerID, BuyerID)
    SELECT GoodsID, SalePrice, Quantity, SaleDate, SellerID, BuyerID
    FROM deleted
    WHERE NOT EXISTS (
        SELECT 1
        FROM Goods
        WHERE Goods.GoodsID = deleted.GoodsID
    );
END;
GO

-- Trigger to check for existing customers before insertion
CREATE TRIGGER trg_CheckExistingCustomer
ON Customers
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Customers c
        JOIN inserted i ON c.Name = i.Name OR c.Email = i.Email
    )
    BEGIN
        RAISERROR ('Existing customer. Insertion aborted.', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO Customers (Name, Email, ContactPhone, Gender, OrderHistory, DiscountPercentage, SignedForMailing)
        SELECT Name, Email, ContactPhone, Gender, OrderHistory, DiscountPercentage, SignedForMailing
        FROM inserted;
    END
END;
GO

-- Trigger to prevent deletion of existing customers
CREATE TRIGGER trg_PreventCustomerDeletion
ON Customers
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR ('Deleting existing customers is prohibited.', 16, 1);
END;
GO

-- Trigger to prevent deletion of employees hired before 2015
CREATE TRIGGER trg_PreventEmployeeDeletion
ON Employees
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM deleted
        WHERE EmploymentDate < '2015-01-01'
    )
    BEGIN
        RAISERROR ('Deleting employees hired before 2015 is prohibited.', 16, 1);
    END
    ELSE
    BEGIN
        DELETE FROM Employees WHERE EmployeeID IN (SELECT EmployeeID FROM deleted);
    END
END;
GO

-- Trigger to set discount percentage for customers with purchase amount exceeding UAH 50,000
CREATE TRIGGER trg_SetDiscountForHighPurchase
ON Sales
AFTER INSERT
AS
BEGIN
    DECLARE @TotalPurchase DECIMAL(10, 2);
    SELECT @TotalPurchase = SUM(SalePrice * Quantity)
    FROM Sales
    WHERE BuyerID IN (SELECT BuyerID FROM inserted);

    IF @TotalPurchase > 50000
    BEGIN
        UPDATE Customers
        SET DiscountPercentage = 15
        WHERE CustomerID IN (SELECT BuyerID FROM inserted);
    END;
END;
GO

-- Trigger to prohibit addition of goods from a particular company
CREATE TRIGGER trg_ProhibitGoodsFromSpecificCompany
ON Goods
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE Manufacturer = 'Sport, Sun and Barbell'
    )
    BEGIN
        RAISERROR ('Adding goods from Sport, Sun and Barbell is prohibited.', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO Goods (Name, Type, Quantity, CostPrice, Manufacturer, SalePrice)
        SELECT Name, Type, Quantity, CostPrice, Manufacturer, SalePrice
        FROM inserted;
    END
END;
GO

-- Trigger to insert information about the last unit of a product
CREATE TRIGGER trg_LastUnit
ON Sales
AFTER INSERT
AS
BEGIN
    DECLARE @LastUnit INT;
    SELECT @LastUnit = Quantity
    FROM inserted
    WHERE Quantity = 1;

    IF @LastUnit = 1
    BEGIN
        INSERT INTO LastUnit (GoodsID, SalePrice, SaleDate)
        SELECT GoodsID, SalePrice, SaleDate
        FROM inserted;
    END;
END;
GO

-- Trigger to check if a product already exists and update its quantity if so
CREATE TRIGGER trg_CheckExistingProduct
ON Goods
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Goods g ON i.Name = g.Name AND i.Type = g.Type AND i.Manufacturer = g.Manufacturer
    )
    BEGIN
        UPDATE g
        SET g.Quantity = g.Quantity + i.Quantity
        FROM Goods g
        JOIN inserted i ON i.Name = g.Name AND i.Type = g.Type AND i.Manufacturer = g.Manufacturer;
    END
    ELSE
    BEGIN
        INSERT INTO Goods (Name, Type, Quantity, CostPrice, Manufacturer, SalePrice)
        SELECT Name, Type, Quantity, CostPrice, Manufacturer, SalePrice
        FROM inserted;
    END
END;
GO

-- Trigger to transfer information about a dismissed employee to the "ArchiveEmployees" table
CREATE TRIGGER trg_TransferToArchiveEmployees
ON Employees
AFTER DELETE
AS
BEGIN
    INSERT INTO ArchiveEmployees (FullName, Position, EmploymentDate, Gender, Salary)
    SELECT FullName, Position, EmploymentDate, Gender, Salary
    FROM deleted;
END;
GO

-- Trigger to prevent adding a new seller if the number of existing sellers exceeds 6
CREATE TRIGGER trg_PreventAddingSeller
ON Employees
INSTEAD OF INSERT
AS
BEGIN
    IF (SELECT COUNT(*) FROM Employees WHERE Position = 'Seller') >= 6
    BEGIN
        RAISERROR ('Adding a new seller is prohibited. Maximum seller limit reached.', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO Employees (FullName, Position, EmploymentDate, Gender, Salary)
        SELECT FullName, Position, EmploymentDate, Gender, Salary
        FROM inserted;
    END
END;
GO
