-- CROSS JOIN kombineerib kõik read esimesest tabelist kõigi ridadega teisest tabelist
SELECT c.CustomerID, c.FirstName, s.SalesOrderID
FROM SalesLT.Customer c
CROSS JOIN SalesLT.SalesOrderHeader s;

-- INNER JOIN tagastab ainult read, kus mõlemas tabelis on vaste
SELECT h.SalesOrderID, h.OrderDate, d.ProductID
FROM SalesLT.SalesOrderHeader h
INNER JOIN SalesLT.SalesOrderDetail d
ON h.SalesOrderID = d.SalesOrderID;

-- LEFT JOIN tagastab kõik esimesest tabelist read ja lisab teise tabeli andmed, kui vaste olemas, muidu NULL
SELECT c.CustomerID, c.FirstName, s.SalesOrderID
FROM SalesLT.Customer c
LEFT JOIN SalesLT.SalesOrderHeader s
ON c.CustomerID = s.CustomerID;

-- RIGHT JOIN tagastab kõik teisest tabelist read ja lisab esimesest tabelist andmed, kui vaste olemas, muidu NULL
SELECT p.ProductID, p.Name, d.SalesOrderID
FROM SalesLT.Product p
RIGHT JOIN SalesLT.SalesOrderDetail d
ON p.ProductID = d.ProductID;

-- FULL OUTER JOIN tagastab kõik read mõlemast tabelist, ühendades need, kus võimalik, ja muudes kohtades näidates NULL
SELECT c.CustomerID, c.FirstName, ca.AddressID
FROM SalesLT.Customer c
FULL OUTER JOIN SalesLT.CustomerAddress ca
ON c.CustomerID = ca.CustomerID

insert into School(Id, FirstName, LastName, Subject, Grade, PhoneNr)
values (1, 'Pets', 'Kuusk', 'IT', 5, '5869439'),
(2, 'Albert', 'Puu', 'Art', 4, '5657456'),
(3, 'Mari', 'Kask', 'Math', 3, '5889439'),
(4, 'Kati', 'Kaubik', 'IT', 4, '5885444'),
(5, 'Peeter', 'Oja', 'Acting', 5, '5213323'),
(6, 'Toomas', 'Auto', 'PE', 5, '57685211'),
(7, 'Paul', 'Mesi', 'Art', 2, '58444331'),
(8, 'Madis', 'Jõgi', 'Math', 5, '51654433'),
(9, 'Jaagup', 'Ilves', 'IT', 4, '52211214'),
(10, 'Hendrik', 'Mänd', 'PE', 4, '5826343')

SELECT * FROM School