---CROSS JOIN
---Tagastab kõik omavahel olevad read
SELECT DepartmentGroupName, Firstname, Lastname
FROM dbo.DimDepartmentGroup
CROSS JOIN dbo.DimEmployee

---INNER JOIN
---Tagastab ainult kahes tabelis olevate ridade tabelid. Mitte kattuvad read on eemaldatud.
SELECT ProductKey, ProductAlternateKey, EnglishProductName
FROM dbo.DimProduct
INNER JOIN dbo.DimProductCategory
ON dbo.DimProduct.ProductKey = dbo.DimProductCategory.ProductCategoryKey

---LEFT JOIN
---Tagastab kattuvad read ja kõik mitte-kattuvad read vasakust tabelist
SELECT SalesReasonName, SalesReasonReasonType, SalesTerritoryRegion
FROM dbo.DimSalesReason
LEFT JOIN dbo.DimSalesTerritory
ON dbo.DimSalesReason.SalesReasonKey = dbo.DimSalesTerritory.SalesTerritoryKey

---RIGHT JOIN
---Tagastab kõik kattuvad read ja kõik mitte-kaatuvad read paremast tabelist
SELECT AccountDescription, AccountType, CurrencyAlternateKey
FROM dbo.DimAccount
RIGHT JOIN dbo.DimCurrency
ON dbo.DimAccount.AccountKey = dbo.DimCurrency.CurrencyKey

---FULL JOIN
---Tagastab vasakust ja paremast tabelist ja kõik mitte kattuvad read
SELECT City, StateProvinceCode, StateProvinceName, OrganizationName
FROM dbo.DimGeography
FULL JOIN dbo.DimOrganization
ON dbo.DimGeography.GeographyKey = dbo.DimOrganization.OrganizationKey

---TABLE
CREATE TABLE School
(
Id int primary key,
FirstName nvarchar(50),
LastName nvarchar(50),
Subject nvarchar(50),
Grade int,
PhoneNr nvarchar(50)
)

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