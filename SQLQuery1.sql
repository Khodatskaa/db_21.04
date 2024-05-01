USE [db_21.04]
GO 

CREATE TRIGGER trg_PreventDuplicateAlbum
ON Albums
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Albums a
        INNER JOIN inserted i ON a.AlbumName = i.AlbumName AND a.ArtistID = i.ArtistID
    )
    BEGIN
        RAISERROR('An album with this name by the same artist already exists in the collection.', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO Albums(AlbumName, ArtistID, ReleaseYear)
        SELECT AlbumName, ArtistID, ReleaseYear FROM inserted;
    END
END;
GO

CREATE TRIGGER trg_PreventDeleteBeatles
ON Albums
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM deleted d
        INNER JOIN Artists a ON d.ArtistID = a.ArtistID AND a.ArtistName = 'The Beatles'
    )
    BEGIN
        RAISERROR('You cannot delete albums by The Beatles.', 16, 1);
    END
    ELSE
    BEGIN
        DELETE FROM Albums WHERE AlbumID IN (SELECT AlbumID FROM deleted);
    END
END;
GO

CREATE TRIGGER trg_ArchiveDeletedAlbums
ON Albums
AFTER DELETE
AS
BEGIN
    INSERT INTO Archive(AlbumID, AlbumName, ArtistID, ReleaseYear)
    SELECT AlbumID, AlbumName, ArtistID, ReleaseYear FROM deleted;
END;
GO

CREATE TRIGGER trg_PreventDarkPowerPop
ON Albums
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Styles s ON i.StyleID = s.StyleID AND s.StyleName = 'Dark Power Pop'
    )
    BEGIN
        RAISERROR('Adding albums of Dark Power Pop style is not allowed.', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO Albums(AlbumName, ArtistID, ReleaseYear, StyleID)
        SELECT AlbumName, ArtistID, ReleaseYear, StyleID FROM inserted;
    END
END;
GO
