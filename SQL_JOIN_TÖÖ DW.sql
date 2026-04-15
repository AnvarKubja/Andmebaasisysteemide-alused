-- CROSS JOIN
-- kuvab kõik read mõlemast tabelist.
SELECT CurrencyName, OrganizationName
FROM dbo.DimCurrency
CROSS JOIN dbo.DimOrganization

-- INNER JOIN
-- tagastab ainult read, kus mõlemas tabelis on vaste
SELECT AccountDescription, AccountType, Amount
FROM dbo.DimAccount
INNER JOIN dbo.FactFinance
ON dbo.DimAccount.AccountKey = dbo.FactFinance.AccountKey

-- LEFT JOIN
-- tagastab kõik esimesest tabelist read ja lisab teise tabeli andmed, kui vaste olemas, muidu NULL
SELECT FirstName, LastName, EnglishCountryRegionName
FROM dbo.DimCustomer
LEFT JOIN dbo.DimGeography
ON dbo.DimCustomer.GeographyKey = dbo.DimGeography.GeographyKey

-- RIGHT JOIN
-- tagastab kõik teisest tabelist read ja lisab esimesest tabelist andmed, kui vaste olemas, muidu NULL
SELECT FirstName, LastName, Title, SalesOrderNumber
FROM dbo.FactResellerSales
RIGHT JOIN dbo.DimEmployee
ON dbo.DimEmployee.EmployeeKey = dbo.FactResellerSales.EmployeeKey

-- FULL OUTER JOIN
-- tagastab kõik read mõlemast tabelist, ühendades need, kus võimalik, ja muudes kohtades näidates NULL
SELECT SalesOrderNumber, EnglishProductName
FROM dbo.FactInternetSales
FULL OUTER JOIN dbo.DimProduct
ON dbo.FactInternetSales.ProductKey = dbo.DimProduct.ProductKey