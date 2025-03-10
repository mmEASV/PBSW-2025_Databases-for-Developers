-- Task 1: Stored Procedure: Parameterized Query
-- Create a stored procedure that retrieves all orders for a specific customer. The stored procedure should take a CustomerID as a parameter and return all orders for that customer.
--
-- Hint for Task 1
-- Use a SELECT statement with a WHERE clause to filter the orders based on the input parameter.

CREATE PROCEDURE sp_GetOrdersByCustomer
@CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT OrderID, CustomerID, OrderDate, Amount
    FROM Orders
    WHERE CustomerID = @CustomerID;
END;
GO;

-- Task 2: Stored Procedure: Parameterized Query
-- Create a stored procedure that retrieves all orders placed within a specific date range. The stored procedure should take two parameters, StartDate and EndDate, and return all orders placed between those dates.
--
-- Hint for Task 2
-- Use a SELECT statement with a WHERE clause to filter the orders based on the input parameters.

CREATE PROCEDURE sp_GetOrdersByDateRange
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT OrderID, CustomerID, OrderDate, Amount
    FROM Orders
    WHERE OrderDate BETWEEN @StartDate AND @EndDate;
END;
GO;

-- Task 3: Stored Procedure: CRUD
-- Create stored procedures for the following CRUD operations on the Customers table:
--
-- CreateCustomer: Inserts a new customer into the Customers table.
-- UpdateCustomer: Updates the information of an existing customer.
-- DeleteCustomer: Deletes a customer from the Customers table.
-- Hint for Task 3
-- Use INSERT, UPDATE, and DELETE statements to perform the respective operations on the Customers table.

CREATE PROCEDURE sp_CreateCustomer
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @RegistrationDate DATETIME,
    @Status NVARCHAR(50) = 'Regular'
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Customers (Name, Email, RegistrationDate, [Status])
    VALUES (@Name, @Email, @RegistrationDate, @Status);
END;
GO;

-- Task 4: User-Defined Function: Scaler
-- Develop a scalar user-defined function named CalculateTotalAmount that calculates the total amount spent by a specific customer. The function should take a CustomerID as a parameter and return the total amount spent by that customer.
--
-- Hint for Task 4
-- Use a SELECT statement with a SUM function to calculate the total amount spent by the customer.

CREATE OR ALTER FUNCTION dbo.CalculateTotalAmount(@CustomerID INT)
    RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Total DECIMAL(10,2);

    SELECT @Total = SUM(Amount)
    FROM Orders
    WHERE CustomerID = @CustomerID;

    -- In case the customer has no orders, return 0 instead of NULL
    RETURN ISNULL(@Total, 0);
END;
GO;

-- Task 5: User-defined Function: Scalar
-- Implement a scalar user-defined function named GetCustomerStatus that returns the status of a customer based on the total amount spent. The function should take a CustomerID as a parameter and return the status as a string (e.g., 'Bronze', 'Silver', 'Gold').
--
-- Hint for Task 5
-- Use a SELECT statement. Lookup if you can use a CASE expression to determine the status based on the total amount spent by the customer.

CREATE FUNCTION dbo.GetCustomerStatus(@CustomerID INT)
    RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @Status NVARCHAR(50);
    DECLARE @Total DECIMAL(10,2);

    -- Calculate total amount spent by the customer
    SET @Total = dbo.CalculateTotalAmount(@CustomerID);

    SET @Status = CASE
                      WHEN @Total < 500 THEN 'Bronze'
                      WHEN @Total BETWEEN 500 AND 1500 THEN 'Silver'
                      ELSE 'Gold'
        END;

    RETURN @Status;
END;
GO;

-- Task 6: Trigger
-- Create a trigger that changes the status of a customer whenever a new order is placed. The trigger should update the status of the customer based on the total amount spent.
--
-- Hint for Task 6
-- Can you use the user-defined function GetCustomerStatus to determine the new status of the customer?

CREATE TRIGGER trg_UpdateCustomerStatus
    ON Orders
    AFTER INSERT
    AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Customers
    SET [Status] = dbo.GetCustomerStatus(i.CustomerID)
    FROM Customers c
             INNER JOIN (SELECT DISTINCT CustomerID FROM inserted) i
                        ON c.CustomerID = i.CustomerID;
END;
GO;

-- Task 7: Trigger
-- Create a trigger that prevents the deletion of a customer if the customer has placed orders. The trigger should raise an error if an attempt is made to delete a customer with associated orders.
--
-- Hint for Task 7
-- Use the DELETE trigger to check if the customer has placed orders and raise an error if necessary.

CREATE TRIGGER trg_PreventCustomerDeletion
    ON Customers
    AFTER DELETE
    AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM deleted d
                 INNER JOIN Orders o ON d.CustomerID = o.CustomerID
    )
        BEGIN
            RAISERROR('Cannot delete a customer who has placed orders.', 16, 1);
            ROLLBACK TRANSACTION;
        END
END;
GO;
