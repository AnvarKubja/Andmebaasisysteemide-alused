-- ============================================================
--  SQL ABIMATERJAL
--  Teemad: Stored Procedure, Funktsioon, Temp Tabel,
--          Indeks, View
-- ============================================================


-- ============================================================
-- 1. TEMP TABELID
-- ============================================================

-- Lokaalne temp tabel (kehtib ainult praeguses sessioonis)
CREATE TABLE #TempTabel (
    ID          INT,
    Nimi        NVARCHAR(100),
    Summa       DECIMAL(10, 2)
);

-- Globaalne temp tabel (kehtib kõigis sessioonides)
CREATE TABLE ##GlobalTempTabel (
    ID          INT,
    Nimi        NVARCHAR(100)
);

-- Andmete lisamine temp tabelisse
INSERT INTO #TempTabel (ID, Nimi, Summa)
VALUES (1, 'Esimene', 100.50),
       (2, 'Teine',   200.75);

-- Andmete lisamine SELECT-iga
INSERT INTO #TempTabel (ID, Nimi, Summa)
SELECT KlientID, KlientNimi, TellimusteSumma
FROM Kliendid
WHERE AktiivsusFlag = 1;

-- Temp tabeli loomine otse SELECT INTO-ga
SELECT KlientID, KlientNimi
INTO #AjutineKlientide
FROM Kliendid
WHERE Riik = 'Eesti';

-- Temp tabeli kustutamine (hea tava)
DROP TABLE IF EXISTS #TempTabel;
DROP TABLE IF EXISTS #AjutineKlientide;


-- ============================================================
-- 2. INDEKSID
-- ============================================================

-- Mitteunikaalne indeks (kiirendab otsinguid)
CREATE INDEX IX_Kliendid_Nimi
    ON Kliendid (KlientNimi);

-- Unikaalne indeks (tagab unikaalsuse + kiirus)
CREATE UNIQUE INDEX UX_Kliendid_Email
    ON Kliendid (Email);

-- Komposiitindeks (mitu veergu)
CREATE INDEX IX_Tellimused_Kuupaev_Klient
    ON Tellimused (TellimisKuupaev, KlientID);

-- Indeks koos INCLUDE veergudega (covering index)
CREATE INDEX IX_Tellimused_KlientID
    ON Tellimused (KlientID)
    INCLUDE (TellimisteSumma, Staatus);

-- Klasterindeks (määrab füüsilise järjestuse, tabelil saab olla ainult 1)
CREATE CLUSTERED INDEX CIX_Tellimused_ID
    ON Tellimused (TellimusID);

-- Mitteklasterindeks
CREATE NONCLUSTERED INDEX NCIX_Tellimused_Staatus
    ON Tellimused (Staatus);

-- Indeksi kustutamine
DROP INDEX IF EXISTS IX_Kliendid_Nimi ON Kliendid;

-- Olemasolevate indeksite vaatamine
SELECT  i.name          AS IndeksiNimi,
        i.type_desc     AS IndeksiTyyp,
        c.name          AS VeerguNimi
FROM    sys.indexes i
JOIN    sys.index_columns ic ON i.object_id = ic.object_id
                             AND i.index_id  = ic.index_id
JOIN    sys.columns c        ON ic.object_id = c.object_id
                             AND ic.column_id = c.column_id
WHERE   OBJECT_NAME(i.object_id) = 'Tellimused';


-- ============================================================
-- 3. VIEW-D (VAATED)
-- ============================================================

-- Lihtne view
CREATE VIEW vw_AktiivsedKliendid
AS
    SELECT  KlientID,
            KlientNimi,
            Email,
            Telefon
    FROM    Kliendid
    WHERE   AktiivsusFlag = 1;
GO

-- View koos JOIN-iga
CREATE VIEW vw_TellimustegaKliendid
AS
    SELECT  k.KlientID,
            k.KlientNimi,
            t.TellimusID,
            t.TellimisKuupaev,
            t.TellimisteSumma
    FROM    Kliendid    k
    JOIN    Tellimused  t ON k.KlientID = t.KlientID;
GO

-- View koos agregeerimisega
CREATE VIEW vw_KlientideStatistika
AS
    SELECT  k.KlientID,
            k.KlientNimi,
            COUNT(t.TellimusID)     AS TellimusteArv,
            SUM(t.TellimisteSumma)  AS KoguSumma,
            AVG(t.TellimisteSumma)  AS KeskmineSumma
    FROM    Kliendid   k
    LEFT JOIN Tellimused t ON k.KlientID = t.KlientID
    GROUP BY k.KlientID, k.KlientNimi;
GO

-- View kasutamine
SELECT * FROM vw_AktiivsedKliendid;
SELECT * FROM vw_KlientideStatistika WHERE KoguSumma > 1000;

-- View muutmine
ALTER VIEW vw_AktiivsedKliendid
AS
    SELECT  KlientID,
            KlientNimi,
            Email
    FROM    Kliendid
    WHERE   AktiivsusFlag = 1
      AND   Riik = 'Eesti';
GO

-- View kustutamine
DROP VIEW IF EXISTS vw_AktiivsedKliendid;


-- ============================================================
-- 4. FUNKTSIOONID
-- ============================================================

-- ── 4a. Skalaarfunktsioon (tagastab ühe väärtuse) ──────────
CREATE FUNCTION fn_KaibemaksugaSumma
(
    @Summa      DECIMAL(10, 2),
    @KMProtsent DECIMAL(5, 2)
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    RETURN @Summa * (1 + @KMProtsent / 100);
END;
GO

-- Kasutamine
SELECT dbo.fn_KaibemaksugaSumma(100.00, 22) AS SummaKMga;

SELECT  TellimusID,
        TellimisteSumma,
        dbo.fn_KaibemaksugaSumma(TellimisteSumma, 22) AS SummaKMga
FROM    Tellimused;

-- ── 4b. Tabelifunktsioon – inline (kiire, nagu view parameetriga) ──
CREATE FUNCTION fn_KlientidePiirkonnast
(
    @Riik NVARCHAR(50)
)
RETURNS TABLE
AS
RETURN
(
    SELECT  KlientID,
            KlientNimi,
            Email
    FROM    Kliendid
    WHERE   Riik = @Riik
      AND   AktiivsusFlag = 1
);
GO

-- Kasutamine
SELECT * FROM dbo.fn_KlientidePiirkonnast('Eesti');

-- ── 4c. Mitme-lauseline tabelifunktsioon ──────────────────
CREATE FUNCTION fn_TellimusteAruanne
(
    @AlgusKuupaev DATE,
    @LopuKuupaev  DATE
)
RETURNS @Tulemus TABLE
(
    TellimusID      INT,
    KlientNimi      NVARCHAR(100),
    TellimisKuupaev DATE,
    Summa           DECIMAL(10, 2),
    Kategooria      NVARCHAR(50)
)
AS
BEGIN
    INSERT INTO @Tulemus (TellimusID, KlientNimi, TellimisKuupaev, Summa, Kategooria)
    SELECT  t.TellimusID,
            k.KlientNimi,
            t.TellimisKuupaev,
            t.TellimisteSumma,
            CASE
                WHEN t.TellimisteSumma >= 1000 THEN 'Suur'
                WHEN t.TellimisteSumma >= 500  THEN 'Keskmine'
                ELSE 'Väike'
            END
    FROM    Tellimused  t
    JOIN    Kliendid    k ON t.KlientID = k.KlientID
    WHERE   t.TellimisKuupaev BETWEEN @AlgusKuupaev AND @LopuKuupaev;

    RETURN;
END;
GO

-- Kasutamine
SELECT * FROM dbo.fn_TellimusteAruanne('2024-01-01', '2024-12-31');

-- Funktsiooni kustutamine
DROP FUNCTION IF EXISTS dbo.fn_KaibemaksugaSumma;


-- ============================================================
-- 5. STORED PROCEDURE-D (SALVESTATUD PROTSEDUURID)
-- ============================================================

-- ── 5a. Lihtne SP ilma parameetriteta ─────────────────────
CREATE PROCEDURE sp_KoikAktiivsedKliendid
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  KlientID,
            KlientNimi,
            Email
    FROM    Kliendid
    WHERE   AktiivsusFlag = 1
    ORDER BY KlientNimi;
END;
GO

EXEC sp_KoikAktiivsedKliendid;

-- ── 5b. SP sisendparameetritega ───────────────────────────
CREATE PROCEDURE sp_KlientidePiirkonnast
    @Riik       NVARCHAR(50),
    @AktiivsusFlag BIT = 1          -- vaikeväärtus
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  KlientID,
            KlientNimi,
            Email
    FROM    Kliendid
    WHERE   Riik           = @Riik
      AND   AktiivsusFlag  = @AktiivsusFlag;
END;
GO

EXEC sp_KlientidePiirkonnast @Riik = 'Eesti';
EXEC sp_KlientidePiirkonnast @Riik = 'Läti', @AktiivsusFlag = 0;

-- ── 5c. SP väljundparameetriga ────────────────────────────
CREATE PROCEDURE sp_KlientideSumma
    @KlientID   INT,
    @Kogusumma  DECIMAL(10, 2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  @Kogusumma = SUM(TellimisteSumma)
    FROM    Tellimused
    WHERE   KlientID = @KlientID;
END;
GO

-- Kasutamine väljundparameetriga
DECLARE @Summa DECIMAL(10, 2);
EXEC sp_KlientideSumma @KlientID = 1, @Kogusumma = @Summa OUTPUT;
SELECT @Summa AS KlientideSumma;

-- ── 5d. SP temp tabeli + veakäsitlusega ──────────────────
CREATE PROCEDURE sp_TellimusteAruanne
    @AlgusKuupaev DATE,
    @LopuKuupaev  DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Temp tabel vahetulemuste hoidmiseks
    CREATE TABLE #AjutineTellimused (
        TellimusID      INT,
        KlientNimi      NVARCHAR(100),
        TellimisKuupaev DATE,
        Summa           DECIMAL(10, 2)
    );

    BEGIN TRY
        INSERT INTO #AjutineTellimused
        SELECT  t.TellimusID,
                k.KlientNimi,
                t.TellimisKuupaev,
                t.TellimisteSumma
        FROM    Tellimused  t
        JOIN    Kliendid    k ON t.KlientID = k.KlientID
        WHERE   t.TellimisKuupaev BETWEEN @AlgusKuupaev AND @LopuKuupaev;

        -- Kokkuvõte
        SELECT  KlientNimi,
                COUNT(*)        AS TellimusteArv,
                SUM(Summa)      AS KoguSumma
        FROM    #AjutineTellimused
        GROUP BY KlientNimi
        ORDER BY KoguSumma DESC;

    END TRY
    BEGIN CATCH
        SELECT
            ERROR_NUMBER()    AS VeaNumber,
            ERROR_MESSAGE()   AS VeaSõnum,
            ERROR_LINE()      AS VeaRida;
    END CATCH;

    DROP TABLE IF EXISTS #AjutineTellimused;
END;
GO

EXEC sp_TellimusteAruanne
    @AlgusKuupaev = '2024-01-01',
    @LopuKuupaev  = '2024-12-31';

-- ── 5e. SP transaktsiooniga ───────────────────────────────
CREATE PROCEDURE sp_ViiaUleTellimus
    @TellimusID     INT,
    @UusKlientID    INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE Tellimused
        SET    KlientID = @UusKlientID
        WHERE  TellimusID = @TellimusID;

        -- Kontrolli, et klient eksisteerib
        IF NOT EXISTS (SELECT 1 FROM Kliendid WHERE KlientID = @UusKlientID)
            THROW 50001, 'Klienti ei leitud!', 1;

        COMMIT TRANSACTION;
        PRINT 'Tellimus edukalt üle viidud.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Viga: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

-- SP muutmine
ALTER PROCEDURE sp_KoikAktiivsedKliendid
AS
BEGIN
    SET NOCOUNT ON;
    SELECT KlientID, KlientNimi, Email, Telefon
    FROM   Kliendid
    WHERE  AktiivsusFlag = 1
    ORDER BY KlientNimi;
END;
GO

-- SP kustutamine
DROP PROCEDURE IF EXISTS sp_KoikAktiivsedKliendid;


-- ============================================================
-- 6. KASULIKUD PÄRINGUD ANDMEBAASI UURIMISEKS
-- ============================================================

-- Kõik tabelid andmebaasis
SELECT TABLE_NAME
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- Tabeli veergude info
SELECT  COLUMN_NAME,
        DATA_TYPE,
        CHARACTER_MAXIMUM_LENGTH,
        IS_NULLABLE
FROM    INFORMATION_SCHEMA.COLUMNS
WHERE   TABLE_NAME = 'Kliendid';

-- Kõik SP-d andmebaasis
SELECT  name, create_date, modify_date
FROM    sys.procedures
ORDER BY name;

-- Kõik funktsioonid
SELECT  name, type_desc, create_date
FROM    sys.objects
WHERE   type IN ('FN', 'IF', 'TF')   -- skalaar, inline, multi-statement
ORDER BY name;

-- Kõik view-d
SELECT  name, create_date
FROM    sys.views
ORDER BY name;

-- SP lähtekoodi vaatamine
EXEC sp_helptext 'sp_TellimusteAruanne';

-- Kõik indeksid tabelil
EXEC sp_helpindex 'Tellimused';


-- ============================================================
-- 7. KIIRVIITED – SÜNTAKS LÜHIDALT
-- ============================================================

/*
TEMP TABEL         CREATE TABLE #Nimi (...);   |  SELECT ... INTO #Nimi FROM ...
INDEKS             CREATE [UNIQUE] [CLUSTERED] INDEX IxNimi ON Tabel (Veerg);
VIEW               CREATE VIEW vw_Nimi AS SELECT ...;
FUNKTSIOON         CREATE FUNCTION fn_Nimi (@p TYP) RETURNS TYP AS BEGIN RETURN ...; END
TABEL-FUNKTSIOON   CREATE FUNCTION fn_Nimi (@p TYP) RETURNS TABLE AS RETURN (SELECT ...)
SP                 CREATE PROCEDURE sp_Nimi @p TYP = default AS BEGIN ... END
SP KÄIVITAMINE     EXEC sp_Nimi @p = väärtus;
OUTPUT PARAM       @Muutuja TYP OUTPUT  →  EXEC sp @p = val, @out = @var OUTPUT
TRANSAKTS.         BEGIN TRANSACTION; ... COMMIT; / ROLLBACK;
VEAKÄSITLUS        BEGIN TRY ... END TRY BEGIN CATCH ... END CATCH
*/


-- ============================================================
-- 8. AdventureWorksDW2019 – PRAKTILISED NÄITED
-- ============================================================
-- NB! Käivita kõigepealt:  USE AdventureWorksDW2019;
-- Peamised tabelid:
--   dbo.DimCustomer          – kliendid
--   dbo.DimProduct           – tooted
--   dbo.DimProductCategory   – tootekategooriad
--   dbo.DimProductSubcategory– alamkategooriad
--   dbo.DimDate              – kuupäevadimensioon
--   dbo.DimSalesTerritory    – müügiterritooriumid
--   dbo.DimEmployee          – töötajad
--   dbo.FactInternetSales    – internetimüük (faktitabel)
--   dbo.FactResellerSales    – edasimüüjate müük (faktitabel)
-- ============================================================

USE AdventureWorksDW2019;
GO


-- ── 8a. TEMP TABELID AdventureWorksDW2019-ga ──────────────

-- Näide 1: Internetimüügi kokkuvõte temp tabelisse
DROP TABLE IF EXISTS #InternetMyygiKokkuvote;

SELECT  p.EnglishProductName       AS Toode,
        pc.EnglishProductCategoryName AS Kategooria,
        SUM(f.SalesAmount)          AS KoguMyyk,
        COUNT(f.SalesOrderNumber)   AS TellimusteArv
INTO    #InternetMyygiKokkuvote
FROM    dbo.FactInternetSales       f
JOIN    dbo.DimProduct              p  ON f.ProductKey        = p.ProductKey
JOIN    dbo.DimProductSubcategory   ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN    dbo.DimProductCategory      pc ON ps.ProductCategoryKey   = pc.ProductCategoryKey
GROUP BY p.EnglishProductName, pc.EnglishProductCategoryName;

-- Vaata tulemust
SELECT TOP 10 *
FROM   #InternetMyygiKokkuvote
ORDER BY KoguMyyk DESC;

-- Näide 2: Aktiivsed kliendid temp tabelisse + liitmine müügiga
DROP TABLE IF EXISTS #AktiivsedKliendid;

SELECT  CustomerKey,
        FirstName + ' ' + LastName  AS TaisNimi,
        EmailAddress,
        EnglishEducation            AS Haridus,
        YearlyIncome
INTO    #AktiivsedKliendid
FROM    dbo.DimCustomer
WHERE   Status = 'Active';

-- Liida müügiga
SELECT TOP 10
        k.TaisNimi,
        k.YearlyIncome,
        SUM(f.SalesAmount)  AS OstudeKogusumma
FROM    #AktiivsedKliendid      k
JOIN    dbo.FactInternetSales   f ON k.CustomerKey = f.CustomerKey
GROUP BY k.TaisNimi, k.YearlyIncome
ORDER BY OstudeKogusumma DESC;

DROP TABLE IF EXISTS #AktiivsedKliendid;
DROP TABLE IF EXISTS #InternetMyygiKokkuvote;


-- ── 8b. INDEKSID AdventureWorksDW2019-ga ──────────────────

-- Vaata olemasolevaid indekseid FactInternetSales tabelil
SELECT  i.name          AS IndeksiNimi,
        i.type_desc     AS Tyyp,
        c.name          AS Veerg
FROM    sys.indexes         i
JOIN    sys.index_columns   ic ON i.object_id = ic.object_id
                               AND i.index_id  = ic.index_id
JOIN    sys.columns         c  ON ic.object_id = c.object_id
                               AND ic.column_id = c.column_id
WHERE   OBJECT_NAME(i.object_id) = 'FactInternetSales'
ORDER BY i.name, ic.key_ordinal;

-- Lisa mitteklasterindeks müügikuupäeva järgi otsimise kiirendamiseks
CREATE NONCLUSTERED INDEX IX_FactInternetSales_OrderDate
    ON dbo.FactInternetSales (OrderDateKey)
    INCLUDE (SalesAmount, TaxAmt, ProductKey);

-- Lisa komposiitindeks kliendi + toote järgi
CREATE NONCLUSTERED INDEX IX_FactInternetSales_Klient_Toode
    ON dbo.FactInternetSales (CustomerKey, ProductKey)
    INCLUDE (SalesAmount, OrderDateKey);

-- Kustuta testindeksid
DROP INDEX IF EXISTS IX_FactInternetSales_OrderDate      ON dbo.FactInternetSales;
DROP INDEX IF EXISTS IX_FactInternetSales_Klient_Toode   ON dbo.FactInternetSales;


-- ── 8c. VIEW-D AdventureWorksDW2019-ga ────────────────────

-- View 1: Internetimüügi koondvaade koos dimensioonidega
DROP VIEW IF EXISTS vw_AW_InternetMyyk;
GO
CREATE VIEW vw_AW_InternetMyyk
AS
    SELECT  f.SalesOrderNumber,
            d.FullDateAlternateKey                      AS TellimisKuupaev,
            c.FirstName + ' ' + c.LastName              AS Klient,
            c.EnglishOccupation                         AS Amet,
            p.EnglishProductName                        AS Toode,
            pc.EnglishProductCategoryName               AS Kategooria,
            st.SalesTerritoryCountry                    AS Riik,
            f.SalesAmount,
            f.TaxAmt,
            f.Freight,
            f.SalesAmount + f.TaxAmt + f.Freight        AS KoguSumma
    FROM    dbo.FactInternetSales       f
    JOIN    dbo.DimCustomer             c  ON f.CustomerKey         = c.CustomerKey
    JOIN    dbo.DimProduct              p  ON f.ProductKey          = p.ProductKey
    JOIN    dbo.DimProductSubcategory   ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    JOIN    dbo.DimProductCategory      pc ON ps.ProductCategoryKey  = pc.ProductCategoryKey
    JOIN    dbo.DimDate                 d  ON f.OrderDateKey         = d.DateKey
    JOIN    dbo.DimSalesTerritory       st ON f.SalesTerritoryKey    = st.SalesTerritoryKey;
GO

-- View kasutamine
SELECT TOP 10 * FROM vw_AW_InternetMyyk ORDER BY TellimisKuupaev DESC;
SELECT Riik, SUM(SalesAmount) AS KoguMyyk FROM vw_AW_InternetMyyk GROUP BY Riik ORDER BY KoguMyyk DESC;

-- View 2: Iga-aastane müügistatistika kategooria järgi
DROP VIEW IF EXISTS vw_AW_AastaMyykKategooriate;
GO
CREATE VIEW vw_AW_AastaMyykKategooriate
AS
    SELECT  d.CalendarYear                          AS Aasta,
            pc.EnglishProductCategoryName           AS Kategooria,
            COUNT(DISTINCT f.SalesOrderNumber)      AS TellimusteArv,
            COUNT(DISTINCT f.CustomerKey)           AS UnikaalsedKliendid,
            SUM(f.SalesAmount)                      AS KoguMyyk,
            AVG(f.SalesAmount)                      AS KeskmineTellimusSumma
    FROM    dbo.FactInternetSales       f
    JOIN    dbo.DimDate                 d  ON f.OrderDateKey         = d.DateKey
    JOIN    dbo.DimProduct              p  ON f.ProductKey           = p.ProductKey
    JOIN    dbo.DimProductSubcategory   ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    JOIN    dbo.DimProductCategory      pc ON ps.ProductCategoryKey   = pc.ProductCategoryKey
    GROUP BY d.CalendarYear, pc.EnglishProductCategoryName;
GO

SELECT * FROM vw_AW_AastaMyykKategooriate ORDER BY Aasta, KoguMyyk DESC;

DROP VIEW IF EXISTS vw_AW_InternetMyyk;
DROP VIEW IF EXISTS vw_AW_AastaMyykKategooriate;
GO


-- ── 8d. FUNKTSIOONID AdventureWorksDW2019-ga ──────────────

-- Funktsioon 1: Skalaarfunktsioon – kliendi kogumüük
DROP FUNCTION IF EXISTS dbo.fn_AW_KlientideKoguMyyk;
GO
CREATE FUNCTION dbo.fn_AW_KlientideKoguMyyk
(
    @CustomerKey INT
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @Kogusumma DECIMAL(18, 2);

    SELECT  @Kogusumma = SUM(SalesAmount)
    FROM    dbo.FactInternetSales
    WHERE   CustomerKey = @CustomerKey;

    RETURN ISNULL(@Kogusumma, 0);
END;
GO

-- Kasutamine
SELECT  CustomerKey,
        FirstName + ' ' + LastName          AS Klient,
        dbo.fn_AW_KlientideKoguMyyk(CustomerKey) AS KoguMyyk
FROM    dbo.DimCustomer
WHERE   Status = 'Active'
ORDER BY KoguMyyk DESC;

-- Funktsioon 2: Inline tabelifunktsioon – tooted kategoorias
DROP FUNCTION IF EXISTS dbo.fn_AW_TootedKategoorias;
GO
CREATE FUNCTION dbo.fn_AW_TootedKategoorias
(
    @KategooriaId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT  p.ProductKey,
            p.EnglishProductName    AS Toode,
            p.Color                 AS Varv,
            p.ListPrice             AS Hind,
            ps.EnglishProductSubcategoryName AS Alamkategooria
    FROM    dbo.DimProduct              p
    JOIN    dbo.DimProductSubcategory   ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    WHERE   ps.ProductCategoryKey = @KategooriaId
      AND   p.Status = 'Current'
);
GO

-- Kasutamine (1=Bikes, 2=Components, 3=Clothing, 4=Accessories)
SELECT * FROM dbo.fn_AW_TootedKategoorias(1) ORDER BY Hind DESC;

-- Funktsioon 3: Mitme-lauseline tabelifunktsioon – müügiaruanne perioodi järgi
DROP FUNCTION IF EXISTS dbo.fn_AW_MyykPerioodil;
GO
CREATE FUNCTION dbo.fn_AW_MyykPerioodil
(
    @AlgusAasta INT,
    @LopuAasta  INT
)
RETURNS @Tulemus TABLE
(
    Aasta           INT,
    Kvartal         INT,
    Kategooria      NVARCHAR(50),
    KoguMyyk        DECIMAL(18, 2),
    TellimusteArv   INT,
    Kasvuprotsent   NVARCHAR(20)
)
AS
BEGIN
    INSERT INTO @Tulemus (Aasta, Kvartal, Kategooria, KoguMyyk, TellimusteArv, Kasvuprotsent)
    SELECT  d.CalendarYear,
            d.CalendarQuarter,
            pc.EnglishProductCategoryName,
            SUM(f.SalesAmount),
            COUNT(DISTINCT f.SalesOrderNumber),
            CASE
                WHEN SUM(f.SalesAmount) >= 1000000 THEN 'Kõrge (>1M)'
                WHEN SUM(f.SalesAmount) >= 500000  THEN 'Keskmine (500K-1M)'
                ELSE 'Madal (<500K)'
            END
    FROM    dbo.FactInternetSales       f
    JOIN    dbo.DimDate                 d  ON f.OrderDateKey         = d.DateKey
    JOIN    dbo.DimProduct              p  ON f.ProductKey           = p.ProductKey
    JOIN    dbo.DimProductSubcategory   ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    JOIN    dbo.DimProductCategory      pc ON ps.ProductCategoryKey   = pc.ProductCategoryKey
    WHERE   d.CalendarYear BETWEEN @AlgusAasta AND @LopuAasta
    GROUP BY d.CalendarYear, d.CalendarQuarter, pc.EnglishProductCategoryName;

    RETURN;
END;
GO

-- Kasutamine
SELECT * FROM dbo.fn_AW_MyykPerioodil(2012, 2014) ORDER BY Aasta, Kvartal, KoguMyyk DESC;

DROP FUNCTION IF EXISTS dbo.fn_AW_KlientideKoguMyyk;
DROP FUNCTION IF EXISTS dbo.fn_AW_TootedKategoorias;
DROP FUNCTION IF EXISTS dbo.fn_AW_MyykPerioodil;
GO


-- ── 8e. STORED PROCEDURE-D AdventureWorksDW2019-ga ────────

-- SP 1: Müügiaruanne riigi ja aastaga (sisendparameetrid)
DROP PROCEDURE IF EXISTS dbo.sp_AW_MyygiAruanne;
GO
CREATE PROCEDURE dbo.sp_AW_MyygiAruanne
    @Riik   NVARCHAR(50) = 'United States',
    @Aasta  INT          = 2013
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  c.FirstName + ' ' + c.LastName      AS Klient,
            c.EnglishOccupation                 AS Amet,
            p.EnglishProductName                AS Toode,
            pc.EnglishProductCategoryName       AS Kategooria,
            f.SalesAmount,
            d.FullDateAlternateKey              AS TellimisKuupaev
    FROM    dbo.FactInternetSales       f
    JOIN    dbo.DimCustomer             c  ON f.CustomerKey         = c.CustomerKey
    JOIN    dbo.DimProduct              p  ON f.ProductKey          = p.ProductKey
    JOIN    dbo.DimProductSubcategory   ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    JOIN    dbo.DimProductCategory      pc ON ps.ProductCategoryKey  = pc.ProductCategoryKey
    JOIN    dbo.DimDate                 d  ON f.OrderDateKey         = d.DateKey
    JOIN    dbo.DimSalesTerritory       st ON f.SalesTerritoryKey    = st.SalesTerritoryKey
    WHERE   st.SalesTerritoryCountry = @Riik
      AND   d.CalendarYear           = @Aasta
    ORDER BY f.SalesAmount DESC;
END;
GO

EXEC dbo.sp_AW_MyygiAruanne @Riik = 'United States', @Aasta = 2013;
EXEC dbo.sp_AW_MyygiAruanne @Riik = 'Australia',     @Aasta = 2012;

-- SP 2: Väljundparameetriga – kliendi statistika
DROP PROCEDURE IF EXISTS dbo.sp_AW_KlientStatistika;
GO
CREATE PROCEDURE dbo.sp_AW_KlientStatistika
    @CustomerKey    INT,
    @KoguMyyk       DECIMAL(18, 2) OUTPUT,
    @TellimusteArv  INT            OUTPUT,
    @EsimeneOst     DATE           OUTPUT,
    @ViimaneOst     DATE           OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  @KoguMyyk      = SUM(f.SalesAmount),
            @TellimusteArv = COUNT(DISTINCT f.SalesOrderNumber),
            @EsimeneOst    = MIN(d.FullDateAlternateKey),
            @ViimaneOst    = MAX(d.FullDateAlternateKey)
    FROM    dbo.FactInternetSales   f
    JOIN    dbo.DimDate             d ON f.OrderDateKey = d.DateKey
    WHERE   f.CustomerKey = @CustomerKey;
END;
GO

-- Kasutamine
DECLARE @Summa     DECIMAL(18,2),
        @Arv       INT,
        @Esimene   DATE,
        @Viimane   DATE;

EXEC dbo.sp_AW_KlientStatistika
    @CustomerKey   = 11000,
    @KoguMyyk      = @Summa    OUTPUT,
    @TellimusteArv = @Arv      OUTPUT,
    @EsimeneOst    = @Esimene  OUTPUT,
    @ViimaneOst    = @Viimane  OUTPUT;

SELECT  @Summa   AS KoguMyyk,
        @Arv     AS TellimusteArv,
        @Esimene AS EsimeneOst,
        @Viimane AS ViimaneOst;

-- SP 3: Temp tabel + TRY/CATCH – tootekategooria müügiraport
DROP PROCEDURE IF EXISTS dbo.sp_AW_KategooriaRaport;
GO
CREATE PROCEDURE dbo.sp_AW_KategooriaRaport
    @AlgusKuupaev DATE = '2013-01-01',
    @LopuKuupaev  DATE = '2013-12-31'
AS
BEGIN
    SET NOCOUNT ON;

    DROP TABLE IF EXISTS #KategooriaMyyk;
    CREATE TABLE #KategooriaMyyk (
        Kategooria      NVARCHAR(50),
        Alamkategooria  NVARCHAR(50),
        KoguMyyk        DECIMAL(18, 2),
        TellimusteArv   INT,
        UnikaalsedKliendid INT
    );

    BEGIN TRY
        INSERT INTO #KategooriaMyyk
        SELECT  pc.EnglishProductCategoryName,
                ps.EnglishProductSubcategoryName,
                SUM(f.SalesAmount),
                COUNT(DISTINCT f.SalesOrderNumber),
                COUNT(DISTINCT f.CustomerKey)
        FROM    dbo.FactInternetSales       f
        JOIN    dbo.DimDate                 d  ON f.OrderDateKey          = d.DateKey
        JOIN    dbo.DimProduct              p  ON f.ProductKey            = p.ProductKey
        JOIN    dbo.DimProductSubcategory   ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
        JOIN    dbo.DimProductCategory      pc ON ps.ProductCategoryKey   = pc.ProductCategoryKey
        WHERE   d.FullDateAlternateKey BETWEEN @AlgusKuupaev AND @LopuKuupaev
        GROUP BY pc.EnglishProductCategoryName, ps.EnglishProductSubcategoryName;

        -- Lõpptulemus
        SELECT  Kategooria,
                Alamkategooria,
                TellimusteArv,
                UnikaalsedKliendid,
                KoguMyyk,
                RANK() OVER (PARTITION BY Kategooria ORDER BY KoguMyyk DESC) AS Koht
        FROM    #KategooriaMyyk
        ORDER BY Kategooria, KoguMyyk DESC;

    END TRY
    BEGIN CATCH
        SELECT  ERROR_NUMBER()  AS VeaNumber,
                ERROR_MESSAGE() AS VeaSonum,
                ERROR_LINE()    AS VeaRida;
    END CATCH;

    DROP TABLE IF EXISTS #KategooriaMyyk;
END;
GO

EXEC dbo.sp_AW_KategooriaRaport
    @AlgusKuupaev = '2013-01-01',
    @LopuKuupaev  = '2013-12-31';

-- Koristus
DROP PROCEDURE IF EXISTS dbo.sp_AW_MyygiAruanne;
DROP PROCEDURE IF EXISTS dbo.sp_AW_KlientStatistika;
DROP PROCEDURE IF EXISTS dbo.sp_AW_KategooriaRaport;
GO


-- ── 8f. KASULIKUD KIIRPÄRINGUD AdventureWorksDW2019-s ─────

-- Müük aasta ja riigi kaupa
SELECT  d.CalendarYear              AS Aasta,
        st.SalesTerritoryCountry    AS Riik,
        SUM(f.SalesAmount)          AS KoguMyyk
FROM    dbo.FactInternetSales   f
JOIN    dbo.DimDate             d  ON f.OrderDateKey    = d.DateKey
JOIN    dbo.DimSalesTerritory   st ON f.SalesTerritoryKey = st.SalesTerritoryKey
GROUP BY d.CalendarYear, st.SalesTerritoryCountry
ORDER BY Aasta, KoguMyyk DESC;

-- Top 10 müüdud tooted
SELECT TOP 10
        p.EnglishProductName        AS Toode,
        SUM(f.SalesAmount)          AS KoguMyyk,
        SUM(f.OrderQuantity)        AS KogusMyydud
FROM    dbo.FactInternetSales   f
JOIN    dbo.DimProduct          p ON f.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY KoguMyyk DESC;

-- Kliendid kes on ostnud üle 10 000 eest
SELECT  c.FirstName + ' ' + c.LastName  AS Klient,
        c.EnglishEducation              AS Haridus,
        c.YearlyIncome,
        SUM(f.SalesAmount)              AS KoguOstud
FROM    dbo.DimCustomer         c
JOIN    dbo.FactInternetSales   f ON c.CustomerKey = f.CustomerKey
GROUP BY c.FirstName, c.LastName, c.EnglishEducation, c.YearlyIncome
HAVING  SUM(f.SalesAmount) > 10000
ORDER BY KoguOstud DESC;

-- Müük kvartali kaupa (PIVOT-laadne aggregatsioon)
SELECT  d.CalendarYear  AS Aasta,
        SUM(CASE WHEN d.CalendarQuarter = 1 THEN f.SalesAmount ELSE 0 END) AS K1,
        SUM(CASE WHEN d.CalendarQuarter = 2 THEN f.SalesAmount ELSE 0 END) AS K2,
        SUM(CASE WHEN d.CalendarQuarter = 3 THEN f.SalesAmount ELSE 0 END) AS K3,
        SUM(CASE WHEN d.CalendarQuarter = 4 THEN f.SalesAmount ELSE 0 END) AS K4,
        SUM(f.SalesAmount)                                                  AS Aastakokku
FROM    dbo.FactInternetSales   f
JOIN    dbo.DimDate             d ON f.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear
ORDER BY Aasta;
