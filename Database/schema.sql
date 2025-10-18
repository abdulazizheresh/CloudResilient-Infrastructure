-- Create Visitors Table
CREATE TABLE Visitors (
    Id INT PRIMARY KEY IDENTITY(1,1),
    VisitorCount INT NOT NULL DEFAULT 0,
    LastUpdated DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    Region NVARCHAR(50) NOT NULL
);

-- Insert initial data
INSERT INTO Visitors (VisitorCount, Region)
VALUES (0, 'West US');

-- Create stored procedure to increment
CREATE PROCEDURE sp_IncrementVisitor
AS
BEGIN
    UPDATE Visitors 
    SET VisitorCount = VisitorCount + 1,
        LastUpdated = GETUTCDATE()
    WHERE Region = 'West US';
    
    SELECT VisitorCount, LastUpdated, Region 
    FROM Visitors 
    WHERE Region = 'West US';
END;
GO

-- Create stored procedure to get count
CREATE PROCEDURE sp_GetVisitors
AS
BEGIN
    SELECT VisitorCount, LastUpdated, Region 
    FROM Visitors 
    WHERE Region = 'West US';
END;
GO