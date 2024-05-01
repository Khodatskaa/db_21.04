USE [db_21.04]
GO

INSERT INTO Goods (Name, Type, Quantity, CostPrice, Manufacturer, SalePrice)
VALUES ('Tennis Shoes', 'Shoes', 50, 30.00, 'Nike', 60.00),
       ('Basketball Jersey', 'Clothes', 100, 20.00, 'Adidas', 40.00),
       ('Football', 'Equipment', 30, 15.00, 'Wilson', 25.00);

INSERT INTO Employees (FullName, Position, EmploymentDate, Gender, Salary)
VALUES ('John Smith', 'Sales Associate', '2023-01-15', 'Male', 30000.00),
       ('Emily Brown', 'Manager', '2022-11-20', 'Female', 50000.00);

INSERT INTO Customers (Name, Email, ContactPhone, Gender, OrderHistory, DiscountPercentage, SignedForMailing)
VALUES ('Alice Johnson', 'alice@example.com', '123-456-7890', 'Female', NULL, 5.00, 1),
       ('Bob Miller', 'bob@example.com', '987-654-3210', 'Male', NULL, 0.00, 0);

INSERT INTO Sales (GoodsID, SalePrice, Quantity, SaleDate, SellerID, BuyerID)
VALUES (1, 60.00, 2, '2024-04-28', 1, 1),
       (2, 40.00, 1, '2024-04-29', 2, 2);
