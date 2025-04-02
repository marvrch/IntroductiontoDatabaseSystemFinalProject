--Simulate Transaction Process
--This is the query to simulate the daily operation (day-to-day) of CineMoFie
USE FinalProjectCineMoFie
GO

-- Staff ST001 dan ST002 melakukan pembelian makanan dan minuman dari supplier untuk restock 
INSERT INTO PurchaseHeader
VALUES
	('PU021', 'ST001', 'SU005', '2023-11-09'),
	('PU022', 'ST002', 'SU010', '2023-12-01')

-- Detail makanan dan minuman yang direstock
INSERT INTO PurchaseDetail
VALUES
	 ('PU021', 'FO001', 'DR002', 20, 5),
	 ('PU022', 'FO005', 'DR004', 10, 10),
	 ('PU022', 'FO006', 'DR015', 20, 25)

-- Staff ingin memperbarui jumlah minuman DR004 yang dibeli menjadi 12 pada purchase PU022
UPDATE PurchaseDetail
SET DrinkQty = 12 
WHERE PurchaseID = 'PU022'
AND DrinkID = 'DR004'

-- Staff ingin menghapus record PurchaseDetail pada purchaseID PU022 yang memiliki nama minuman "Skim Milk" dikarenakan kurang laku terjual, termasuk makanan dalam record yang sama
DELETE PurchaseDetail
WHERE PurchaseID = 'PU022'
AND DrinkID IN (
	SELECT DrinkID
	FROM MsDrink
	WHERE DrinkName LIKE 'Skim Milk'
	)
	
-- Staff ST003 dan ST005 melayani Customer CU001, CU011, dan CU013
INSERT INTO TransactionHeader
VALUES
	 ('TR021', 'ST003', 'CU001', '2024-01-15'),
	 ('TR022', 'ST005', 'CU011', '2024-02-08'),
	 ('TR023', 'ST006', 'CU013', '2024-03-05')

-- Detail film, makanan, dan minuman yang dibeli pada kedua transaksi tersebut
INSERT INTO TransactionDetail
VALUES 
	('TR021', 'MO018', 'FO013', 'DR003', 3, 5, 3),
	('TR022', 'MO007', 'FO011', 'DR001', 3, 6, 2),
	('TR023', 'MO010', 'FO009', 'DR005', 1, 2, 1)

-- Pada Transaksi TR022, Ticket MO007 yang dibeli Customer ternyata hanya 2
UPDATE TransactionDetail
SET TicketSoldQty = 2
WHERE TransactionID = 'TR022'
AND TicketSoldID = 'MO007'

-- Staff menghapus transaksi TR023 pada kedua tabel (baik itu tabel header dan detail)
DELETE TransactionDetail
WHERE TransactionID = 'TR023'

DELETE TransactionHeader
WHERE TransactionID = 'TR023'


