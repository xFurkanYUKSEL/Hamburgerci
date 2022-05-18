CREATE DATABASE HAMBURGER
GO
USE HAMBURGER
GO
CREATE TABLE Menus
(
	ID SMALLINT IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(20) NOT NULL UNIQUE,
	Price MONEY NOT NULL,
	CONSTRAINT CHK_Price
	CHECK(Price>0),
	CONSTRAINT PK_Menus PRIMARY KEY(ID)
)
GO
CREATE OR ALTER PROCEDURE AddNewMenu @Name NVARCHAR(20),@Price MONEY
AS
BEGIN
	INSERT INTO Menus
	VALUES(@Name,@Price)
END
GO
EXEC AddNewMenu 'HAMBURGER',35
EXEC AddNewMenu 'CHEESEBURGER',30
EXEC AddNewMenu 'CHICKENBURGER',40
GO
CREATE TABLE Extras
(
	ID SMALLINT IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(20) NOT NULL UNIQUE,
	Price MONEY NOT NULL,
	CONSTRAINT CHK_ExtraPrice
	CHECK(Price>=0),
	CONSTRAINT PK_Extras 
	PRIMARY KEY(ID)
)
GO
CREATE OR ALTER PROCEDURE AddNewExtra @Name NVARCHAR(20),@Price MONEY
AS
BEGIN
	INSERT INTO Extras
	VALUES(@Name,@Price)
END
GO
EXEC AddNewExtra 'KETCHUP',3
EXEC AddNewExtra 'MAYONNAISE',3
EXEC AddNewExtra 'MUSTARD',7
EXEC AddNewExtra 'PICKLE',4
GO
CREATE TABLE Sizes
(
	ID TINYINT IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(10) NOT NULL UNIQUE,
	Value FLOAT NOT NULL UNIQUE,
	CONSTRAINT PK_Sizes PRIMARY KEY(ID),
	CONSTRAINT CHK_Value
	CHECK(Value>0)
)
GO
CREATE PROCEDURE NewSize @Name NVARCHAR(10),@Value FLOAT
AS
BEGIN
	INSERT INTO Sizes
	VALUES(@Name,@Value)
END
GO
EXEC NewSize 'SMALL',0.8
EXEC NewSize 'MIDDLE',1
EXEC NewSize 'BIG',1.1
GO
CREATE TABLE States
(
ID TINYINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
State NVARCHAR(20) UNIQUE NOT NULL,
)
GO
CREATE PROCEDURE NewState @State NVARCHAR(20)
AS
BEGIN
	INSERT INTO States
	VALUES(@State)
END
GO
EXEC NewState 'WAITING'
EXEC NewState 'COMPLETED'
EXEC NewState 'CANCELLED'
GO
CREATE TABLE Users
(
ID INT IDENTITY(1,1) NOT NULL,
CONSTRAINT PK_Users
PRIMARY KEY(ID),
FirstName NVARCHAR(20) NOT NULL,
LastName NVARCHAR(20)  NOT NULL,
Username NVARCHAR(20)  NOT NULL,
CONSTRAINT UQ_Username
UNIQUE(Username),
Password NVARCHAR(20) NOT NULL
)
GO
CREATE OR ALTER PROCEDURE AddNewUser @FirstName NVARCHAR(20),@LastName NVARCHAR(20),@Username NVARCHAR(20),@Password NVARCHAR(20)
AS
BEGIN
INSERT INTO Users(FirstName,LastName,Username,Password)
VALUES(@FirstName,@LastName,@Username,@Password)
END
GO
EXEC AddNewUser 'FURKAN','Y�KSEL','xnatsud','22081996'
EXEC AddNewUser 'MURAT CAN','��MEN','ahmet','564789'
EXEC AddNewUser 'FAHRETT�N','YILMAZ','tolunayy','56497'
EXEC AddNewUser 'SEL�N','�ZEN�','ba�tav��n','6'
GO
CREATE TABLE [Current User]
(
Username NVARCHAR(20) NULL,
Password NVARCHAR(20) NULL
)
INSERT INTO [Current User]
VALUES('','')
GO
CREATE TABLE [Orders]
(
	ID INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK_Orders PRIMARY KEY(ID),
	[User ID] INT NOT NULL,
	CONSTRAINT FK_Users_Orders
	FOREIGN KEY([User ID]) REFERENCES Users(ID),
	[Order Date] DATETIME NOT NULL DEFAULT(GETDATE()),
	[Total Price] MONEY DEFAULT 0,
	[Order State ID] TINYINT NOT NULL DEFAULT 1,
	CONSTRAINT FK_States_Orders
	FOREIGN KEY([Order State ID]) REFERENCES States(ID)
)
GO
CREATE TABLE [Order Details]
(
	[Order ID] INT NOT NULL,
	[Menu ID] SMALLINT NOT NULL,
	[Size ID] TINYINT NOT NULL,
	[Extra ID] SMALLINT NULL,
	Amount TINYINT NOT NULL,
	CONSTRAINT FK_Orders_OrderDetails
	FOREIGN KEY([Order ID]) REFERENCES [Orders](ID),
	CONSTRAINT FK_Menus_OrderDetails
	FOREIGN KEY([Menu ID]) REFERENCES [Menus](ID),
	CONSTRAINT FK_Extras_OrderDetails
	FOREIGN KEY([Extra ID]) REFERENCES [Extras](ID),
	CONSTRAINT FK_Sizes_OrderDetails
	FOREIGN KEY([Size ID]) REFERENCES [Sizes](ID),
	CONSTRAINT CHK_Amount
	CHECK(Amount>0)
)
GO
CREATE OR ALTER PROCEDURE AddNewOrder @UserID INT,@OrderID INT OUTPUT
AS
BEGIN
INSERT INTO Orders([User ID])
VALUES(@UserID)
SELECT @OrderID=@@IDENTITY
END
GO
DECLARE @OrderID INT
EXEC AddNewOrder 1,@OrderID OUTPUT
SELECT @OrderID 'Order ID'
GO
CREATE OR ALTER PROCEDURE NewOrder
@OrderID INT,
@MenuName NVARCHAR(20),
@SizeName NVARCHAR(10),
@ExtraName NVARCHAR(20),
@Amount TINYINT
AS
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO [Order Details]([Order ID],[Menu ID],[Size ID],[Extra ID],Amount)
VALUES(@OrderID,(SELECT ID FROM Menus WHERE Name=@MenuName),(SELECT ID FROM Sizes WHERE Name=@SizeName),(SELECT ID FROM Extras WHERE Name=@ExtraName),@Amount)
UPDATE Orders
SET [Total Price]=(SELECT (M.Price*S.Value+SUM(E.Price))*OD.Amount  FROM [Order Details] OD JOIN Menus M ON M.ID=OD.[Menu ID] JOIN Extras E ON E.ID=OD.[Extra ID] JOIN Sizes S ON S.ID=OD.[Size ID] WHERE OD.[Order ID]=@OrderID GROUP BY M.Price,S.Value,OD.Amount,OD.[Menu ID],OD.[Size ID])
WHERE ID=@OrderID
COMMIT
END TRY
BEGIN CATCH
ROLLBACK
END CATCH
GO
ALTER TABLE Users
ADD Title NVARCHAR(20)
GO
UPDATE Users
SET Title='Member'
UPDATE Users
SET Title='Admin'
WHERE Username='ba�tav��n'
GO
ALTER TABLE Users
ALTER COLUMN Title NVARCHAR(20) NOT NULL
GO
CREATE OR ALTER TRIGGER Admin
ON Users
FOR INSERT
AS
BEGIN
IF ((SELECT Title FROM inserted)='Admin')
BEGIN
PRINT 'CANT INSERT A USER THAT TITLE="ADMIN"'
ROLLBACK
END
END
GO
INSERT INTO Users(FirstName,LastName,Username,Password,Title)
VALUES('','','','','Admin')
GO
CREATE VIEW [Orders Last 30 Days]
AS
SELECT * FROM Orders
WHERE [Order Date] BETWEEN DATEADD(DAY,-30,GETDATE()) AND GETDATE()
GO