USE [db_21.04]
GO

-- all data from the Goods table
SELECT * FROM Goods;

-- all data from the Employees table
SELECT * FROM Employees;

-- all data from the Customers table
SELECT * FROM Customers;

-- all data from the Sales table
SELECT * FROM Sales;

-- columns from the Goods table
SELECT Name, Type, Quantity FROM Goods;

-- columns from the Employees table
SELECT FullName, Position FROM Employees;

-- columns from the Customers table
SELECT Name, Email, ContactPhone FROM Customers;

-- columns from the Sales table
SELECT SaleID, SalePrice, SaleDate FROM Sales;

-- joining tables to retrieve related data
SELECT Sales.SaleID, Goods.Name AS GoodsName, Sales.SalePrice, Employees.FullName AS SellerName, Customers.Name AS BuyerName
FROM Sales
JOIN Goods ON Sales.GoodsID = Goods.GoodsID
JOIN Employees ON Sales.SellerID = Employees.EmployeeID
JOIN Customers ON Sales.BuyerID = Customers.CustomerID;

-- filtering data using WHERE clause
SELECT * FROM Goods WHERE Quantity > 20;

-- aggregating data using GROUP BY clause
SELECT Gender, COUNT(*) AS TotalEmployees FROM Employees GROUP BY Gender;
