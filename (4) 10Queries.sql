--10 Queries
USE FinalProjectCineMoFie
GO

/* Nomor 1
Display Staffs (Obtained from StaffName in uppercase), PurchaseDate, and Total Food Purchase
(Obtained from counting all the Transaction) for every Purchase made by male staff and happenned in 2019.
*/
DECLARE @startTime DATETIME = GETDATE();

SELECT UPPER(StaffName) AS 'Staffs',
	PurchaseDate,
	COUNT(PD.PurchaseID) AS 'Total Food Purchase'
FROM MsStaff MS
JOIN PurchaseHeader PH ON MS.StaffID = PH.StaffID
JOIN PurchaseDetail PD ON PH.PurchaseID = PD.PurchaseID
WHERE StaffGender LIKE 'Male' AND YEAR(PurchaseDate) = 2019
GROUP BY UPPER(StaffName), PurchaseDate;

DECLARE @endTime DATETIME = GETDATE();
DECLARE @executionTime VARCHAR(50) = CAST(DATEDIFF(MILLISECOND, @startTime, @endTime) AS VARCHAR) + ' ms';
PRINT CAST(@@ROWCOUNT AS VARCHAR) + ' row(s) fetched - ' + @executionTime + ', on ' + CONVERT(VARCHAR, GETDATE(), 120);

/*
Nomor 2
Display PurchaseID, Supplier Name (Obtained from SupplierName in lowercase), and Total Drink Purchase 
(Obtained from total sum of DrinkQuantity) for every Total Drink Purchase that less than 5 and PurchaseID is even number.
*/
SELECT PH.PurchaseID, 
LOWER(SupplierName) AS 'Supplier Name',
SUM(PD.DrinkQty) AS 'Total Drink Purchase'
FROM PurchaseHeader PH
JOIN MsSupplier MS ON PH.SupplierID = MS.SupplierID
JOIN PurchaseDetail PD ON PH.PurchaseID = PD.PurchaseID
WHERE CONVERT(INT, RIGHT(PH.PurchaseID,3)) % 2 = 0
GROUP BY PH.PurchaseID, SupplierName
HAVING SUM(PD.DrinkQty) < 5

/*
Nomor 3
Display Transaction Date (Obtained from Converting the TransactionDate format to 'Mon dd. yyyy' example 'Oct 01. 2000'), 
Highest Food Price Sold (Obtained from getting the maximum food price), 
Lowest Drink Price Sold (Obtained from getting the minimum drink price) for every transaction that happenned before June 2023.
*/
SELECT REPLACE(CONVERT(VARCHAR, TransactionDate, 107), ',', '.') AS 'Transaction Date',
MAX(FoodPrice) AS 'Highest Food Price Sold',
MIN(DrinkPrice) AS 'Lowest Drink Price Sold'
FROM TransactionHeader TH
JOIN TransactionDetail TD ON TH.TransactionID = TD.TransactionID
JOIN MsFood MF ON TD.FoodSoldID = MF.FoodID
JOIN MsDrink MD ON TD.DrinkSoldID = MD.DrinkID
WHERE YEAR(TransactionDate) = 2023 AND MONTH(TransactionDate) < 6
GROUP BY TransactionDate

/*
Nomor 4
Display Staff's First Name (Obtained from getting the first staff name in lowercase format), 
FoodCategory, and Average Total Food Purchased (Obtained from the purchased food quantity average), and 
Total Food Purchased (Obtained from total sum of FoodQuantity) for every purchase that has average food quantity 
is more than 2 and the FoodCategory is 'Fried'.
*/
SELECT LOWER(LEFT(StaffName, CHARINDEX(' ', StaffName)-1)) AS 'Staff‘s First Name',
FoodCategory,
AVG(PD.FoodQty) AS 'Average Total Food Purchased',
SUM(PD.FoodQty) AS 'Total Food Purchased'
FROM PurchaseHeader PH 
JOIN PurchaseDetail PD ON PH.PurchaseID = PD.PurchaseID
JOIN MsStaff MS ON MS.StaffID = PH.StaffID
JOIN MsFood MF ON PD.FoodID = MF.FoodID
WHERE FoodCategory LIKE 'Fried'
GROUP BY StaffName, FoodCategory
HAVING AVG(PD.FoodQty) > 2

/*
Nomor 5
Display TransactionID, Drink Transaction Forecast (Obtained from adding one year to the TransactionDate),
and Drink Quantity (Obtained from adding ' Cup' at the end of DrinkQuantity) for every 'Soft Drink' or 'Herbal' 
drink category in a single transaction that has more than 1 quantity sold.
(ALIAS SUB QUERY)
*/
SELECT alias.TransactionID,
DATEADD(YEAR, 1, TransactionDate) AS 'Drink Transaction Forecast',
CONCAT(alias.DrinkSoldQty, ' Cup') AS 'Drink Quantity'
FROM TransactionHeader TH,
	(SELECT TD.TransactionID,
	SUM(TD.DrinkSoldQty) AS 'DrinkSoldQty'
	FROM TransactionDetail TD
	JOIN MsDrink MD ON TD.DrinkSoldID = MD.DrinkID
	WHERE MD.DrinkCategory IN ('Soft Drink', 'Herbal')
	GROUP BY TransactionID
	HAVING SUM(TD.DrinkSoldQty) > 1) AS alias
WHERE TH.TransactionID = alias.TransactionID


/*
Nomor 6
Display StaffID, Transaction Date (Obtained from Converting the TransactionDate to 'dd Mon yyyy' format, ex: 31 Jan 2023), 
Movie Identification (Obtained from change the first 2 letter from MovieID to ‘Movie ‘), 
Movie Name (Obtained from adding 'Film ' in front of the MovieName), 
and MovieCategory for every Movie that has duration higher than the average duration and the MovieID is 'MO003'
(ALIAS SUB QUERY)
*/
SELECT StaffID,
CONVERT(VARCHAR, TransactionDate, 106) AS 'Transaction Date',
STUFF(MovieID, 1, 2, 'Movie ') AS 'Movie Identification',
CONCAT('Film ', MovieName) AS 'Movie Name',
MovieCategory
FROM TransactionHeader TH
JOIN TransactionDetail TD ON TH.TransactionID = TD.TransactionID
JOIN MsMovie MM ON TD.TicketSoldID = MM.MovieID,
	(SELECT AVG(MovieDuration) AS 'avg'
	FROM MsMovie MM
	) AS alias
WHERE MovieID LIKE 'MO003' AND MovieDuration > alias.avg


/*
Nomor 7 
Display Last Name (Obtained from getting the last name of the CustomerName) and Total Movie Sold 
(Obtained from the total multiplication of TicketQuantity and Movie Price) for every first quarter of a year 
which Total Movie Sold is above the Average of all Total Movie Sold.
(ALIAS SUB QUERY)
*/
--(Average dari All Total Movie Sold, artinya tidak hanya pada quarter pertama saja)
SELECT RIGHT(alias1.CustomerName, CHARINDEX(' ', REVERSE(alias1.CustomerName))-1) AS 'Last Name',
alias1.TotalMovieSold AS 'Total Movie Sold'
FROM
	(SELECT CustomerName,
	TH.TransactionID,
	SUM(TD.TicketSoldQty*MoviePrice) AS 'TotalMovieSold'
	FROM TransactionHeader TH
	JOIN MsCustomer MC ON MC.CustomerID = TH.CustomerID
	JOIN TransactionDetail TD ON TH.TransactionID = TD.TransactionID
	JOIN MsMovie MM ON TD.TicketSoldID = MM.MovieID
	WHERE DATEPART(QUARTER, TransactionDate) = 1 
	GROUP BY CustomerName, TH.TransactionID) AS alias1,
	(SELECT AVG(alias2.TotalMovieSold) AS 'AverageTotalMovieSold' 
	FROM 
		(
		SELECT TH.TransactionID,
		SUM(TD.TicketSoldQty*MoviePrice) AS 'TotalMovieSold'
		FROM TransactionHeader TH
		JOIN TransactionDetail TD ON TH.TransactionID = TD.TransactionID
		JOIN MsMovie MM ON TD.TicketSoldID = MM.MovieID
		GROUP BY TH.TransactionID) AS alias2
		) AS alias3 
WHERE alias1.TotalMovieSold > alias3.AverageTotalMovieSold


/*
Nomor 8
Display Transaction (Obtained from changing the first two character from TransactionID to 'Transaction ' in Uppercase format), 
StaffName, Customer Name (Obtained from adding 'Ms/Mrs. ' in front of the CustomerName), and Transaction Date 
(Obtained from getting the year of TransactionDate) for every female customer and total transaction is higher than the average total transaction
(ALIAS SUB QUERY)
*/
--(Average dari total Transaction (tidak terkecuali pada wanita))

SELECT UPPER(STUFF(alias1.TransactionID, 1, 2, 'Transaction ')) AS 'Transaction',
alias1.StaffName,
CONCAT('Ms/Mrs. ', alias1.CustomerName) AS 'Customer Name',
alias1.[Transaction Date]
FROM (
	SELECT TH.TransactionID,
	StaffName,
	CustomerName,
	YEAR(TransactionDate) AS 'Transaction Date',
	COUNT(TH.TransactionID) AS 'Total Transaction'
	FROM TransactionHeader TH
	JOIN MsStaff MS ON MS.StaffID = TH.StaffID
	JOIN MsCustomer MC ON MC.CustomerID = TH.CustomerID
	JOIN TransactionDetail TD ON TH.TransactionID = TD.TransactionID
	JOIN MsMovie MM ON MM.MovieID = TD.TicketSoldID
	JOIN MsFood MF ON MF.FoodID = TD.FoodSoldID
	JOIN MsDrink MD ON MD.DrinkID = TD.DrinkSoldID
	WHERE CustomerGender LIKE 'Female'
	GROUP BY TH.TransactionID, StaffName, CustomerName, YEAR(TransactionDate)
) AS alias1,
(SELECT AVG(alias2.[Total Transaction]) AS 'Average Total Transaction' 
FROM 
	(
	SELECT TH.TransactionID,
	COUNT(TH.TransactionID) AS 'Total Transaction'
	FROM TransactionHeader TH
	JOIN MsStaff MS ON MS.StaffID = TH.StaffID
	JOIN MsCustomer MC ON MC.CustomerID = TH.CustomerID
	JOIN TransactionDetail TD ON TH.TransactionID = TD.TransactionID
	JOIN MsMovie MM ON MM.MovieID = TD.TicketSoldID
	JOIN MsFood MF ON MF.FoodID = TD.FoodSoldID
	JOIN MsDrink MD ON MD.DrinkID = TD.DrinkSoldID
	GROUP BY TH.TransactionID
	) AS alias2
) AS alias3
WHERE alias1.[Total Transaction]> alias3.[Average Total Transaction]

/*
Nomor 9
Create a view named 'TotalPurchase' to display Staff (Obtained from changing first staff name with 'Staff ') 
MovieName, MovieRating, Average Ticket Bought (Obtained from average of TicketQuantity), and Total Ticket Bought 
(Obtained from total sum of the TicketQuantity) for every movie that has 5 star rating and the total sum of 
TicketQuantity is higher than the Average Ticket Bought
*/

CREATE VIEW [TotalPurchase] AS
SELECT STUFF(StaffName, 1, CHARINDEX(' ', StaffName), 'Staff ') AS 'Staff',
MovieName,
MovieRating,
AVG(TicketSoldQty) AS 'Average Ticket Bought',
SUM(TicketSoldQty) AS 'Total Ticket Bought'
FROM MsStaff MS
JOIN TransactionHeader TH ON TH.StaffID = MS.StaffID
JOIN TransactionDetail TD ON TD.TransactionID = TH.TransactionID
JOIN MsMovie MM ON MM.MovieID = TD.TicketSoldID
WHERE MovieRating = 5
GROUP BY StaffName, MovieName, MovieRating
HAVING SUM(TicketSoldQty) > AVG(TicketSoldQty)

/* 
Nomor 10
Create a view named 'Food Sales' to display FoodName, Total Quantity Sold (Obtained from total sum of FoodQuantity sold), 
and Average Food Price (Obtained average of FoodPrice) for every food which category is 'Sandwich' 
and the Transaction is happenned in current Year.
*/

CREATE VIEW [Food Sales] AS
SELECT FoodName,
SUM(FoodSoldQty) AS 'Total Quantity Sold',
AVG(FoodPrice) AS 'Average Food Price'
FROM MsFood MF
JOIN TransactionDetail TD ON MF.FoodID = TD.FoodSoldID
JOIN TransactionHeader TH ON TH.TransactionID = TD.TransactionID
WHERE FoodCategory LIKE 'Sandwich' 
AND YEAR(TransactionDate) = YEAR(GETDATE())
GROUP BY FoodName






