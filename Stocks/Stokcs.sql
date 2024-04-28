Create Database InventoryDetails
use InventoryDetails
CREATE TABLE Vendors (
    VendorID INT PRIMARY KEY IDENTITY(1,1),
    VendorName VARCHAR(255),
    VendorAddress VARCHAR(255),
    IsActive BIT
);
CREATE TABLE Fabrics (
    FabricID INT PRIMARY KEY IDENTITY(1,1),
    FabricName VARCHAR(255),
    IsActive BIT
);
CREATE TABLE Machines (
    MachineID INT PRIMARY KEY IDENTITY(1,1),
    MachineNumber VARCHAR(255),
    IsActive BIT
);

select * from Vendors
CREATE TABLE Stocks (
    StockID INT PRIMARY KEY IDENTITY(1,1),
    VendorID INT,
    BillNo VARCHAR(255),
    BillDate DATE,
    StockInDate DATE,
    StockOutDate DATE,
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID)
);
CREATE TABLE StockDetails (
    DetailID INT PRIMARY KEY IDENTITY(1,1),
    StockID INT,
    FabricID INT,
    Weight DECIMAL(10, 2),
    MachineID INT,
    InOut BIT,
    FOREIGN KEY (StockID) REFERENCES Stocks(StockID),
    FOREIGN KEY (FabricID) REFERENCES Fabrics(FabricID),
    FOREIGN KEY (MachineID) REFERENCES Machines(MachineID)
);

INSERT INTO Vendors (VendorName, VendorAddress, IsActive)
VALUES ('KeshavPVT', 'New Delhi', 1),
       ('Kamal', 'Ghaziabad', 1),
       ('Rohan', 'Hapur', 1);

INSERT INTO Fabrics (FabricName, IsActive)
VALUES ('Cotton', 1),
       ('Silk', 1),
       ('Wool', 1);

select * from Machines
INSERT INTO Machines (MachineNumber, IsActive)
VALUES ('Weaving 1', 1),
       ('Weaving 2', 1),
       ('Weaving 3', 1);
select * from Stocks
INSERT INTO Stocks (VendorID, BillNo, BillDate, StockInDate, StockOutDate)
VALUES 
(1, 'Bill001', '2022-01-01', '2022-01-02', '2022-01-02'),
(2, 'Bill002', '2022-01-02', '2022-01-03', '2022-01-03'),
(3, 'Bill003', '2022-01-03', '2022-01-04', '2022-01-04'),
(1, 'Bill003', '2022-01-04', '2022-01-05', '2022-01-05'),
(2, 'Bill005', '2022-01-05', '2022-01-06', '2022-01-06'),
(3, 'Bill006', NULL, '2022-01-07', NULL),
(1, 'Bill007', NULL, '2022-01-08', NULL),
(2, 'Bill008', NULL, '2022-01-09', NULL),
(3, 'Bill009', NULL, '2022-01-10', NULL),
(1, 'Bill010', NULL, '2022-01-11', NULL);

INSERT INTO StockDetails (StockID, FabricID, Weight, MachineID, InOut)
VALUES
(1, 1, 100.0, 1, 0),
(2, 2, 200.0, 2, 0),
(3, 3, 300.0, 3, 0),
(4, 1, 150.0, 1, 0),
(5, 2, 250.0, 2, 0),
(6, 3, 350.0, 3, 1),
(7, 1, 120.0, 1, 1),
(8, 2, 220.0, 2, 1),
(9, 3, 320.0, 3, 1),
(10, 1, 180.0, 1, 1);

-- Index for Stocks table
CREATE INDEX IX_Stocks_VendorID ON Stocks (VendorID);
CREATE INDEX IX_Stocks_BillNo ON Stocks (BillNo);
CREATE INDEX IX_Stocks_BillDate ON Stocks (BillDate);
CREATE INDEX IX_Stocks_StockInDate ON Stocks (StockInDate);
CREATE INDEX IX_Stocks_StockOutDate ON Stocks (StockOutDate);

-- Index for StockDetails table
CREATE INDEX IX_StockDetails_StockID ON StockDetails (StockID);
CREATE INDEX IX_StockDetails_FabricID ON StockDetails (FabricID);
CREATE INDEX IX_StockDetails_MachineID ON StockDetails (MachineID);

CREATE PROCEDURE GetStockReport
AS
BEGIN
    SELECT
        S.StockID,
        V.VendorName,
        S.BillNo,
        F.FabricName,
        S.BillDate,
        SD.Weight,
        S.StockInDate,
        S.StockOutDate,
        MD.MachineNumber AS Lot
    FROM
        Stocks S
        JOIN Vendors V ON S.VendorID = V.VendorID 
        JOIN StockDetails SD ON S.StockID = SD.StockID
        JOIN Fabrics F ON SD.FabricID = F.FabricID
        JOIN Machines MD ON SD.MachineID = MD.MachineID
	--WHERE
      --  S.VendorID = @VendorID;
END;


Alter VIEW GetViewStockReports as
SELECT
    S.StockID,
    V.VendorName,
    S.BillNo,
    S.BillDate,
	S.StockInDate,
	S.StockOutDate,
    SD.FabricID,
    F.FabricName,
    SD.Weight,
    SD.MachineID,
    M.MachineNumber,
    SD.InOut
FROM
    Stocks S
    INNER JOIN StockDetails SD ON S.StockID = SD.StockID
    INNER JOIN Vendors V ON S.VendorID = V.VendorID
    INNER JOIN Fabrics F ON SD.FabricID = F.FabricID
    INNER JOIN Machines M ON SD.MachineID = M.MachineID;


Alter PROCEDURE GetStockInDetails
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT *
    FROM GetViewStockReports
    WHERE InOut = 0  -- 0 for stock in, 1 for stock out
    AND StockInDate BETWEEN @StartDate AND @EndDate;
END


Alter PROCEDURE GetStockOutDetails
	@StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT *
    FROM GetViewStockReports
    WHERE InOut = 1 -- 0 for stock in, 1 for stock out
	 AND StockOutDate BETWEEN @StartDate AND @EndDate;
END

--when user click on StouchOut checkbox
CREATE PROCEDURE MakeStockOut
    @StockID INT
AS
BEGIN
    DECLARE @StockOutDate DATE = GETDATE();

    UPDATE StockDetails
    SET InOut = 1
    WHERE StockID = @StockID;

    UPDATE Stocks
    SET StockOutDate = @StockOutDate
    WHERE StockID = @StockID;
END


--ctrl +L
Create PROCEDURE GetActiveVendors
AS
BEGIN
    SELECT VendorID,VendorName, VendorAddress
    FROM Vendors
    WHERE isActive = 1;
END;
select * from Vendors

ALTER PROCEDURE AddVendor
    @VendorName NVARCHAR(255),
    @VendorAddress NVARCHAR(255),
    @Message NVARCHAR(255) OUTPUT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Vendors (VendorName, VendorAddress, isActive)
        VALUES (@VendorName, @VendorAddress, 1);
        SET @Message = 'success';
    END TRY
    BEGIN CATCH
        SET @Message = ERROR_MESSAGE();
    END CATCH
END;

CREATE TABLE VendorBackup (
    VendorId INT PRIMARY KEY,
    VendorName VARCHAR(255),
    VendorAddress VARCHAR(255),
    DeletedDateTime DATETIME
);
Alter PROCEDURE DeleteVendor
    @VendorId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VendorName VARCHAR(255), @VendorAddress VARCHAR(255);

    -- Get vendor details before deleting
    SELECT @VendorName = VendorName, @VendorAddress = VendorAddress
    FROM Vendors
    WHERE VendorId = @VendorId;

    -- Insert deleted vendor into backup table
    INSERT INTO VendorBackup (VendorId, VendorName, VendorAddress, DeletedDateTime)
    VALUES (@VendorId, @VendorName, @VendorAddress, GETDATE());

    -- inactive vendor from original table
    Update  Vendors
	set IsActive=0
	WHERE VendorId = @VendorId;

    SELECT 'Vendor deleted successfully' AS Result;
END;

CREATE TRIGGER trg_DeleteVendor
ON Vendors
FOR DELETE
AS
BEGIN
    DECLARE @VendorId INT;
    SELECT @VendorId = VendorId FROM DELETED;
    EXEC DeleteVendor @VendorId;
END;

CREATE TRIGGER trg_DeleteVendo_new
ON Vendors
FOR DELETE
AS
BEGIN
   --delete from VendorBackup where VendorId in (select VendorId from deleted)
   insert into VendorBackup  (select * from  deleted)
    
END;


select * from Vendors
update Vendors
set IsActive=1
where VendorID=6
select * from VendorBackup
delete from VendorBackup



select * from StockDetails
select * from Stocks



ALTER PROCEDURE AddVendor
    @Action int,
    @VendorId int = 0,
    @VendorName NVARCHAR(255),
    @VendorAddress NVARCHAR(255),
    @Message NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 1  -- Add
    BEGIN
        INSERT INTO Vendors (VendorName, VendorAddress,IsActive)
        VALUES (@VendorName, @VendorAddress,1);

        SET @Message = 'success';
    END
    ELSE IF @Action = 0  -- Edit
    BEGIN
        UPDATE Vendors
        SET VendorName = @VendorName,
            VendorAddress = @VendorAddress
        WHERE VendorId = @VendorId;

        SET @Message = 'success';
    END
    ELSE
    BEGIN
        SET @Message = 'Invalid action';
        RETURN;
    END
END;





DECLARE @Action int = 1;  -- Add
DECLARE @VendorId int = 0;
DECLARE @VendorName NVARCHAR(255) = 'Rohan1';
DECLARE @VendorAddress NVARCHAR(255) = 'Hapur';
DECLARE @Message NVARCHAR(255);

EXEC AddVendor @Action, @VendorId, @VendorName, @VendorAddress, @Message OUTPUT;
SELECT @Message AS Result;


Alter PROCEDURE AddStockProcedure
    @VendorID INT,
    @BillNo VARCHAR(255),
    @BillDate DATE,
    @FabricID INT,
    @Weight DECIMAL(10, 2),
    @MachineID INT,
    @Message NVARCHAR(100) OUTPUT
AS
BEGIN
    DECLARE @StockID INT;

    -- Add stock to Stocks table
    INSERT INTO Stocks (VendorID, BillNo, BillDate, StockInDate)
    VALUES (@VendorID, @BillNo, @BillDate, GETDATE());

    -- Get the newly inserted StockID
    SET @StockID = SCOPE_IDENTITY();

    IF @StockID IS NOT NULL
    BEGIN
        -- Add stock detail to StockDetails table
        INSERT INTO StockDetails (StockID, FabricID, Weight, MachineID, InOut)
        VALUES (@StockID, @FabricID, @Weight, @MachineID, 0);
        SET @Message = 'Success';
    END
    ELSE
    BEGIN
        SET @Message = 'Fail';
    END
END;

select * from StockDetails
select * from Stocks


Alter PROCEDURE StockOut
    @StockID INT,
    @Result VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE StockDetails
    SET InOut = 1
    WHERE StockID = @StockID;

    UPDATE Stocks
    SET StockOutDate = GETDATE()
    WHERE StockID = @StockID;

    IF @@ROWCOUNT > 0
        SET @Result = 'Success'; -- Success
    ELSE
        SET @Result = 'Fail'; -- Fail
END;

select * from Names
delete from Names



-------------------------------
--BackUp Data base

Create Database InventoryDetailsBackUp
use InventoryDetailsBackUp
CREATE TABLE Vendors (
    VendorID INT PRIMARY KEY IDENTITY(1,1),
    VendorName VARCHAR(255),
    VendorAddress VARCHAR(255),
    IsActive BIT
);
CREATE TABLE Fabrics (
    FabricID INT PRIMARY KEY IDENTITY(1,1),
    FabricName VARCHAR(255),
    IsActive BIT
);
CREATE TABLE Machines (
    MachineID INT PRIMARY KEY IDENTITY(1,1),
    MachineNumber VARCHAR(255),
    IsActive BIT
);

select * from Vendors
CREATE TABLE Stocks (
    StockID INT PRIMARY KEY IDENTITY(1,1),
    VendorID INT,
    BillNo VARCHAR(255),
    BillDate DATE,
    StockInDate DATE,
    StockOutDate DATE,
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID)
);
CREATE TABLE StockDetails (
    DetailID INT PRIMARY KEY IDENTITY(1,1),
    StockID INT,
    FabricID INT,
    Weight DECIMAL(10, 2),
    MachineID INT,
    InOut BIT,
    FOREIGN KEY (StockID) REFERENCES Stocks(StockID),
    FOREIGN KEY (FabricID) REFERENCES Fabrics(FabricID),
    FOREIGN KEY (MachineID) REFERENCES Machines(MachineID)
);


use InventoryDetails

CREATE TRIGGER BackupVendorsTrigger
ON Vendors
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO InventoryDetailsBackup.dbo.Vendors (VendorName, VendorAddress, IsActive)
    SELECT VendorName, VendorAddress, IsActive
    FROM inserted;
END;


use InventoryDetailsBackUp
select * from Vendors


use InventoryDetails
select * from Vendors



update Vendors
set IsActive=1
where VendorID=12