USE BANK;
GO;

declare @suspicious_transaction_id int;

SELECT TOP 1 t.TransactionID, t.AccountID, t.Amount, t.Type, t.Timestamp
FROM Transactions t
WHERE t.Amount > (SELECT AVG(Amount) * 3 FROM Transactions)
    AND (t.Type = 'Withdrawal' OR t.Type = 'Transfer')
ORDER BY t.Amount DESC;

SELECT t.TransactionID, c.Name AS CustomerName, a.AccountID, t.Amount, t.Type, t.Timestamp
FROM Transactions t
         JOIN Accounts a ON t.AccountID = a.AccountID
         JOIN Customers c ON a.CustomerID = c.CustomerID
WHERE t.TransactionID = @suspicious_transaction_id;