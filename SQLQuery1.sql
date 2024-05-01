USE [db_21.04]
GO

CREATE TRIGGER trg_CheckBuyerSurname
ON Buyers
AFTER INSERT
AS
BEGIN
    INSERT INTO MatchingSurnames(OriginalBuyerID, MatchedBuyerID, Surname)
    SELECT i.BuyerID, b.BuyerID, b.Surname
    FROM inserted i
    INNER JOIN Buyers b ON b.Surname = i.Surname AND b.BuyerID != i.BuyerID;
END;
GO

CREATE TRIGGER trg_ArchivePurchaseHistory
ON Buyers
AFTER DELETE
AS
BEGIN
    INSERT INTO PurchaseHistory(BuyerID, Surname, SaleID)
    SELECT d.BuyerID, d.Surname, s.SaleID
    FROM deleted d
    LEFT JOIN Sales s ON s.BuyerID = d.BuyerID;
END;
GO

CREATE TRIGGER trg_CheckSellerIsBuyer
ON Sellers
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Buyers b JOIN inserted i ON b.Surname = i.Surname AND b.FirstName = i.FirstName)
    BEGIN
        RAISERROR('This person is already registered as a buyer.', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO Sellers(Surname, FirstName)
        SELECT Surname, FirstName FROM inserted;
    END
END;
GO

CREATE TRIGGER trg_CheckBuyerIsSeller
ON Buyers
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Sellers s JOIN inserted i ON s.Surname = i.Surname AND s.FirstName = i.FirstName)
    BEGIN
        RAISERROR('This person is already registered as a seller.', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO Buyers(Surname, FirstName)
        SELECT Surname, FirstName FROM inserted;
    END
END;
GO

CREATE TRIGGER trg_PreventCertainSales
ON Sales
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Product IN ('apples', 'pears', 'plums', 'cilantro'))
    BEGIN
        RAISERROR('Sales of apples, pears, plums, and cilantro are not allowed.', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO Sales(Product, BuyerID, SellerID, Date)
        SELECT Product, BuyerID, SellerID, Date FROM inserted;
    END
END;
GO
