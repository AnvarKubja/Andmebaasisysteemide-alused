-- CROSS JOIN
-- 
SELECT AddressLine1, AddressType
FROM SalesLT.Address
CROSS JOIN SalesLT.CustomerAddress


--LEFT JOIN
--
SELECT FirstName, MiddleName, Lastname, SalesOrderNumber
FROM SalesLT.Customer
LEFT JOIN SalesLT.SalesOrderHeader
ON SalesLT.Customer.CustomerID = SalesLT.SalesOrderHeader.CustomerID


--RIGHT JOIN
--
SELECT Name, Size, UnitPrice
FROM SalesLT.Product
RIGHT JOIN SalesLT.SalesOrderDetail
ON SalesLT.Product.ProductID = SalesLT.SalesOrderDetail.ProductID


--INNER JOIN
--
Select c.Name as CategoryName, p.Name, p.Weight
FROM SalesLT.ProductCategory c
INNER JOIN SalesLT.Product p
ON c.ProductCategoryID = p.ProductCategoryID


--FULL OUTER JOIN
--
SELECT p.Name, m.Culture
FROM SalesLt.ProductModel p
FULL OUTER JOIN SalesLT.ProductModelProductDescription m
ON p.ProductModelID = m.ProductModelID
