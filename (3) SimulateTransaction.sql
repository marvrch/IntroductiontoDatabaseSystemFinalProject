--Simulate Transaction Process
--This is the query to simulate the daily operation (day-to-day) of CineMoFie
USE FinalProjectCineMoFie
GO

-- Staff ST001 and ST002 made food and beverage purchases from suppliers for restocking purposes.
INSERT INTO PurchaseHeader
VALUES
	('PU021', 'ST001', 'SU005', '2023-11-09'),
	('PU022', 'ST002', 'SU010', '2023-12-01')

-- Restocked food and beverage details
INSERT INTO PurchaseDetail
VALUES
	 ('PU021', 'FO001', 'DR002', 20, 5),
	 ('PU022', 'FO005', 'DR004', 10, 10),
	 ('PU022', 'FO006', 'DR015', 20, 25)

-- Staff wants to update the quantity of drink DR004 purchased in purchaseID PU022 to 12
UPDATE PurchaseDetail
SET DrinkQty = 12 
WHERE PurchaseID = 'PU022'
AND DrinkID = 'DR004'

-- Staff wants to delete records from PurchaseDetail with PurchaseID PU022 that include drinks named "Skim Milk"
-- due to low sales, including food items in the same record
DELETE PurchaseDetail
WHERE PurchaseID = 'PU022'
AND DrinkID IN (
	SELECT DrinkID
	FROM MsDrink
	WHERE DrinkName LIKE 'Skim Milk'
	)
	
-- Staff ST003, ST005, and ST006 served customers CU001, CU011, and CU013
INSERT INTO TransactionHeader
VALUES
	 ('TR021', 'ST003', 'CU001', '2024-01-15'),
	 ('TR022', 'ST005', 'CU011', '2024-02-08'),
	 ('TR023', 'ST006', 'CU013', '2024-03-05')

-- Details of movies, food, and drinks purchased in the three transactions
INSERT INTO TransactionDetail
VALUES 
	('TR021', 'MO018', 'FO013', 'DR003', 3, 5, 3),
	('TR022', 'MO007', 'FO011', 'DR001', 3, 6, 2),
	('TR023', 'MO010', 'FO009', 'DR005', 1, 2, 1)

-- For transaction TR022, the quantity of movie ticket M007 purchased by the customer was corrected to 2
UPDATE TransactionDetail
SET TicketSoldQty = 2
WHERE TransactionID = 'TR022'
AND TicketSoldID = 'MO007'

-- Staff removed transaction TR023 from both the header and detail tables
DELETE TransactionDetail
WHERE TransactionID = 'TR023'

DELETE TransactionHeader
WHERE TransactionID = 'TR023'


