create database TARge25

--db valimine
use TARge25DB

--db kustutamine
drop database TARge25DB

--tabeli tegemine
create table Gender
(
Id int not null primary key,
Gender nvarchar(10) not null
)

--andmete sisestamine
insert into Gender (Id, Gender)
values (2, 'Male'),
(1, 'Female'),
(3, 'Unknown')

--tabeli sisu vaatamine
select * from Gender

--tehke tabel nimega Person
--id int, not null, primary key
--Name nvarchar 30
--Email nvarchar 30
--GenderId int
create table Person
(
Id int not null primary key,
Name nvarchar(30),
Email nvarchar(30),
GenderId int
)

--andmete sisestamine
insert into Person (Id, Name, Email, GenderId)
values (1, 'Superman', 's@s.com', 2),
(2, 'Wonderwoman', 'w@w.com', 1),
(3, 'Batman', 'b@b.com', 2),
(4, 'Aquaman', 'a@a.com', 2),
(5, 'Catwoman', 'cat@cat.com', 1),
(6, 'Antman', 'ant@ant.com', 2),
(8, NULL, NULL, 2)

--soovime näha Person tabeli sisu
select * from Person

--võõrvõtme ühenduse loomine kahe tabeli vahel
alter table Person add constraint tblPerson_GenderId_FK
foreign key (GenderId) references Gender(Id)

--kui sisestad uue rea andmeid ja ei ole sisestanud genderId alla väärtust, siis
-- see automaatselt sisestab sellele reale väärtuse 3 ehk mis meil on unknown
alter table Person
add constraint DF_Persons_GenderId
default 3 for GenderId

insert into Person (Id, Name, Email, GenderId)
values (7, 'Flash', 'f@f.com', NULL)

insert into Person (Id, Name, Email)
values (9, 'Black Panther', 'p@p.com')

select * from Person

--kustutada DF_Persons_GenderId piirang koodiga
alter table Person
drop constraint DF_Persons_GenderId

--lisame koodiga veeru
alter table Person
add Age nvarchar(10)

--lisame nr piirangu vanuse sisestamisel
alter table Person
add constraint CK_Person_Age check (Age > 0 and Age < 155)

--kui sa tead veergude järjekorda peast
--siis ei pea neid sisestama
insert into Person 
values (10, 'Green Arrow', 'g@g.com', 2, 154)

--constrainti kustutamine
alter table Person
drop constraint CK_Person_Age

alter table Person
add constraint CK_Person_Age check (Age > 0 and Age < 130)

--kustutame rea
delete from Person where Id = 10

--kuidas uuendada andmeid koodiga
--Id 3 uus vanus on 50
update Person
set Age = 50
where Id = 3

--lisame Person tabelisse veeru City ja nvarchar 50
alter table Person
add City nvarchar(50)

--kõik kes elavad Gothami linnas
select * from Person where City = 'Gotham'

--kõik kes ei ela Gothamis
select * from Person where City != 'Gotham'
select * from Person where City <> 'Gotham'
select * from Person where not City = 'Gotham'

--näitab teatud vanusega inimesi
--35, 42, 23
select * from Person where Age = 35 or Age = 42 or Age = 23
select * from Person where Age in (35, 42, 23)

--näitab teatud vanusevahemikus olevaid isikuid 22 kuni 39
select * from Person where Age between 22 and 39

--wildcardi kasutamine
--näitab kõik g-tähega algavad linnad
select * from Person where City like 'g%'

--email, kus on @ märk sees
select * from Person where Email like '%@%'

--näitab, kellel on emailis ees ja peale @-märki ainult üks täht ja omakorda .com
select * from Person where Email like '_@_.com'

--kõik, kellel on nimes esimene täht w, a, s
--katusega välistab
select * from Person where Name like '[^was]%'
select * from Person where Name like '[was]%'

--kes elavad Gothamis ja New Yorkis
select * from Person where City = 'Gotham' or City = 'New York'

--kes elavad Gothamis ja New Yorkis ja on vanemad, kui 29
select * from Person where (City = 'Gotham' or City = 'New York') and Age > 29

--kuvab tähetikulises järjekorras inimesi ja võtab aluseks nime
select * from Person order by Name

--kuvab vastupidises järjestuses nimed
select * from Person order by  Name DESC

--võtab kolm esimest rida person tabelist
select top 3 * from Person

--kolm esimest aga tabeli järjestus on Age ja siis name
select top 3 Age, Name from Person order by cast(Age as int)

--näita esimesed 50% tabelist
select top 50 percent * from Person

--kõikide isikute koondvanus
select sum(cast(Age as int)) from Person

--näitab kõige nooremat isikut
select min(cast(Age as int)) from Person

--näitab kõige vanemat isikut
select max(cast(Age as int)) from Person

--muudame Age veeru int andmetüübiks
alter table Person
alter column Age int;

--näeme konkreetsetes linnades olevate isikute koondvanust
select sum(Age) from Person where city = 'New York'
select City, sum(Age) as TotalAge from Person group by City

--kuvab esimeses reas väljatoodud järjestuses ja kuvab Age TotalAge-ks
--järjestab City-s olevate nimede järgi ja siis GenderId järgi
select City, GenderId, sum(Age) as TotalAge from Person
group by City, GenderId order by City

--näitab mitu rida on selles tabelis
select count(*) from Person

--näitab tulemust mitu inimest on GenderId väärtusega 2 konkreetses linnas
--arvutab vanuse kokku konkreetses linnas
select GenderId, City, sum(Age) as TotalAge, count(Id) as [Total Person(s)]
from Person
where GenderId = '2'
group by GenderId, City

--näitab ära inimeste koondvanuse mis on üle 41 a ja
--kui palju neid igas linnas elab
--eristab soo järgi
select GenderId, City, sum(Age) as TotalAge, count(Id) as [Total Person(s)]
from Person
group by GenderId, City having sum(Age) > 41

--loome tabelid Employees ja Department
create table Department
(
Id int not null primary key,
DepartmentName nvarchar(50) null,
Location nvarchar(50) null,
DepartmentHead nvarchar(50) null
)

create table Employees
(
Id int not null primary key,
Name nvarchar(50) null,
Gender nvarchar(50) null,
Salary nvarchar(50) null,
DepartmentId int null
)

insert into Employees (Id, Name, Gender, Salary, DepartmentId)
values (1, 'Tom', 'Male', '4000', 1),
(2, 'Pam', 'Female', '3000', 3),
(3, 'John', 'Male', '3500', 1),
(4, 'Sam', 'Male', '4500', 2),
(5, 'Todd', 'Male', '2800', 2),
(6, 'Ben', 'Male', '7000', 1),
(7, 'Sara', 'Female', '4800', 3),
(8, 'Valarie', 'Female', '5500', 1),
(9, 'James', 'Male', '6500', null),
(10, 'Rusell', 'Male', '8800', null)

insert into Department(Id, DepartmentName, Location, DepartmentHead)
values (1, 'IT', 'London', 'Rick'),
(2, 'Payroll', 'Delhi', 'Ron'),
(3, 'HR', 'New York', 'Christie'),
(4, 'Other Department', 'Sydney', 'Cindrella')

select Name, Gender, Salary, DepartmentName
from Employees
left join Department
on Employees.DepartmentId = Department.Id

--arvutame kõikide palgad kokku
select sum(cast(Salary as int)) from Employees

--miinimum palga saaja
select min(cast(Salary as int)) from Employees

--teeme left join päringu
select Location, sum(cast(Salary as int)) as TotalSalary
from Employees
left join Department
on Employees.DepartmentId = Department.Id
group by Location --ühe kuu palgafond linnade lõikes

--teeme veeru nimega City Employees tabelisse
--nvarchar 30
alter table Employees
add City nvarchar(30)

select * from Employees

--peale selecti tulevad veergude nimed
select City, Gender, sum(cast(Salary as int)) as TotalSalary
--tabelist nimega Employees ja mis on grupitatud City ja Gender järgi
from Employees group by City, Gender

--oleks vaja et linnad oleksid tähestikulises järjekorras
select City, Gender, sum(cast(Salary as int)) as TotalSalary
from Employees group by City, Gender
order by City
--order by järjestab linnad tähestikuliselt
--aga kui on nullid, siis need tulevad kõige ette

--loeb ära, mitu rida on tabelis Employees
--* asemele võib panna ka veeru nime
-- aga siis loeb ainult selle veeru väärtused, mis ei ole nullid
select COUNT(*) from Employees

--mitu töötajat on soo ja linna kaupa
select City, Gender, sum(cast(Salary as int)) as Totalsalary, count(Id) as TotalEmployees
from Employees group by City, Gender

--kuvab ainult kõik mehed linnade kaupa
select City, Gender, sum(cast(Salary as int)) as Totalsalary, 
count(Id) as TotalEmployees
from Employees
where Gender = 'Male'
group by City, Gender

--sama tulemus, aga kasutage having klauslit
select City, Gender, sum(cast(Salary as int)) as Totalsalary, 
count(Id) as TotalEmployees
from Employees
group by City, Gender
having Gender = 'Male'

--näitab meile ainult need töötajad kellel on palga summa üle 4000
select * from Employees
where sum(cast(salary as int)) > 4000

select City, sum(cast(Salary as int)) as Totalsalary, Name,
count(Id) as TotalEmployees
from Employees
group by Salary, City, Name
having sum(cast(Salary as int)) > 4000

--loo´me tabeli, milles hakatakse automaatselt nummerdama Id-d
create table Test1
(
Id int identity(1,1) primary key,
Value nvarchar(30)
)

insert into Test1 values('X')
select * from Test1

--kustutame veeru nimega City Employees tabelist
alter table Employees
drop column City

--inner join
--kuvab neid kellel on DepartmentName all olemas väärtus
select Name, Gender, Salary, DepartmentName
from Employees
inner join Department
on Employees.DepartmentId = Department.Id

--left join 
-- kuvab kõik read Employees tabelist,
--aga DepartmentName näitab ainult siis, kui on olemas
-- kui DepartmentId on null, siis DepartmentName näitab nulli
select Name, Gender, Salary, DepartmentName
from Employees
left join Department
on Employees.DepartmentId = Department.Id

--right join
--kuvab kõik read Department tabelist
--aga Name näitab ainult siis, kui on olemas väärtus DepartmentId, mis on sama,
--Department tabeli Id-ga
select Name, Gender, Salary, DepartmentName
from Employees
right join Department
on Employees.DepartmentId = Department.Id

--full outer join ja full join on sama asi
--kuvab kõik read mõlemast tabelist,
--aga kui ei ole vastet, siis näitab nulli
select Name, Gender, Salary, DepartmentName
from Employees
full outer join Department
on Employees.DepartmentId = Department.Id

--cross join
--kuvab kõik read mõlemast tabelist, aga ei võta aluseks mingit veergu,
--vaid lihtsalt kombineerib kõik read omavahel
--kasutatakse harva, aga kui on vaja kombineerida kõiki
--võimalikke kombinatsioone kahe tabeli vahel, siis võib kasutada cross joini
select Name, Gender, Salary, DepartmentName
from Employees
cross join Department

--päringu sisu
select ColumnList
from LeftTable
joinType RightTable
on JoinCondition

select Name, Gender, Salary, DepartmentName
from Employees
inner join Department
on DepartmentId = Employees.DepartmentId

--kuidas kuvada ainult need isikud, kellel on DepartmentName NULL
select Name, Gender, Salary, DepartmentName
from Employees
left join Department
on Employees.DepartmentId = Department.Id
where Employees.DepartmentId is null

--teine variant
select Name, Gender, Salary, DepartmentName
from Employees
left join Department
on Employees.DepartmentId = Department.Id
where Department.Id is null

--kuidas saame department tabelis oleva rea, kus on NULL
select Name, Gender, Salary, DepartmentName
from Employees
right join Department
on Employees.DepartmentId = Department.Id
where Employees.DepartmentId is null

--full join
--kus on vaja kuvada kõik read mõlemast tabelist,
--millel ei ole vastet
select Name, Gender, Salary, DepartmentName
from Employees
full join Department
on Employees.DepartmentId = Department.Id
where Employees.DepartmentId is null
or Department.Id is null

--tabeli nimetuse muutmine koodiga
sp_rename 'Employees1', 'Employees'

--kasutame Employees tabeli asemel lühendit E ja M
--aga enne seda lisame uue veeru nimega ManagerId ja see on int
alter table Employees
add ManagerId int

--antud juhul E on Employees tabeli lühend ja M
--on samuti Employees tabeli lühend, aga me kasutame
--seda, et näidata, et see on manageri tabel
select E.Name as Employee, M.Name as Manager
from Employees E
left join Employees M
on E.ManagerId = M.Id

--inner join ja kasutame lühendeid
select E.Name as Employee, M.Name as Manager
from Employees E
inner join Employees M
on E.ManagerId = M.Id

--cross join ja kasutame lühendeid
select E.Name as Employee, M.Name as Manager
from Employees E
cross join Employees M

select FirstName, LastName, Phone, AddressID, AddressType
from SalesLT.CustomerAddress
left join SalesLT.Customer
on SalesLT.CustomerAddress.CustomerID = SalesLT.Customer.CustomerID

--teha päring, kus kasutate ProductModelit ja Product tabelit
--et näha, millised tooted on millise mudeliga seotud
select PM.Name as ProductModel, P.Name as Product
from SalesLT.Product P
left join SalesLT.ProductModel PM
on PM.ProductModelId = P.ProductModelId


---JOIN päringud
---CROSS JOIN
---Loob ühendused kahest tabelist. Employee tabelis on kümme rida ja Departments tabelis neli rida.
---See tingimus tekitab päringu, mis kuvab 40 rida. Sellel JOIN-l ei tohiks olla ON tingimust.
select Name, Gender, Salary, DepartmentName
FROM dbo.Employees
CROSS JOIN dbo.Department

---JOIN VÕI INNER JOIN
---INNER JOIN tagastab ainult kahes tabelis olevate ridade tabelid. Mitte kattuvad read on eemaldatud.
select Name, Gender, Salary, DepartmentName
from dbo.Employees
INNER JOIN dbo.Department
ON dbo.Employees.DepartmentId = dbo.Department.Id

---LEFT VÕI LEFT OUTER JOIN
---OUTER märksõna on vabatahtlik
Select Name, Gender, Salary, DepartmentName
from dbo.Employees
LEFT OUTER JOIN dbo.Department
ON dbo.Employees.DepartmentId = dbo.Department.Id

---RIGHT JOIN või RIGHT OUTER JOIN
select Name, Gender, Salary, DepartmentName
from dbo.Employees
RIGHT JOIN dbo.Department
ON dbo.Employees.DepartmentId = dbo.Department.Id

---FULL JOIN või FULL OUTER JOIN
select Name, Gender, Salary, DepartmentName
from dbo.Employees
FULL JOIN dbo.Department
ON dbo.Employees.DepartmentId = dbo.Department.Id

---CROSS JOIN: tagastab kõik omavahel olevad read
--- JOIN: Tagastab kattuvad read ja kõik mitte-kattuvad read vasakust tabelist
---RIGHT JOIN: Tagastab kõik kattuvad read ja kõik mitte-kaatuvad read paremast tabelist
---FULL JOIN: Tagastab vasakust ja paremast tabelist ja kõik mitte kattuvad read

---Keerulisemad JOIN-d
Select Name, Gender, Salary, DepartmentName
from dbo.Employees E
LEFT JOIN dbo.Department D
ON E.DepartmentId = D.Id

---Kuidas saada andmeid mitte-kattuvatelt ridadelt paremast tabelist.
Select Name, Gender, Salary, DepartmentName
from dbo.Employees E
RIGHT JOIN dbo.Department D
ON E.DepartmentId = D.Id
WHERE E.DepartmentId IS NULL

---Kuidas saada mõlemast tabelist ainult mitte-kattuvad read. 
Select Name, Gender, Salary, DepartmentName
from dbo.Employees E
FULL JOIN dbo.Department D
ON e.DepartmentId = D.Id
WHERE E.DepartmentId IS NULL
OR D.Id IS NULL

---SELF JOIN
---Tabeli iseendaga ühendamist nimetatakse SELF JOIN-ks. 
Select E.Name as Employee, M.Name as Manager
from dbo.Employees E
LEFT JOIN dbo.Employees M
ON E.ManagerId = M.Id

---INNER Self ja CROSS self koodinäide
Select E.Name as Employee, M.Name as Manager
from dbo.Employees E
INNER JOIN dbo.Employees M
ON E.ManagerId = M.Id

Select E.Name as Employee, M.Name as Manager
from dbo.Employees E
CROSS JOIN dbo.Employees M

--
select isnull('Sinu Nimi', 'No Manager') as Manager

select COALESCE(null, 'No Manager') as Manager

--neil kellel ei ole ülemust, siis paneb neile No Manager teksti
Select E.Name as Employee, isnull(M.Name, 'No Manager') as Manager
from Employees E
left join Employees M
on E.ManagerId = M.Id

--kui Expression on õige, siis paneb väärtuse, mida soovid või
--vastasel juhul paneb No Manager teksti
--case when Expression Then '' else '' end

--teeme päringu, kus kasutame case-i
--tuleb kasutada ka left join
Select E.Name as Employee, case when M.Name is null then 'No Manager'
else M.Name end as Manager
from Employees E
left join Employees M
on E.ManagerId = M.Id

--lisame tabelisse uued veerud
alter table employees
add MiddleName nvarchar(30)
alter table employees
add LastName nvarchar(30)

--muudame veeru nime koodiga
sp_rename 'Employees.MiddleName', 'Middlename1'
select * from Employees

--
UPDATE Employees
SET MiddleName = 'Nick', LastName = 'Jones'
WHERE Id = 1
UPDATE Employees
SET LastName = 'Anderson'
WHERE Id = 2
UPDATE Employees
SET LastName = 'Smith'
WHERE Id = 4
UPDATE Employees
SET FirstName = NULL, Middlename = 'Todd', LastName = 'Someone'
WHERE Id = 5
UPDATE Employees
SET MiddleName = 'Ten', LastName = 'Sven'
WHERE Id = 6
UPDATE Employees
SET LastName = 'Connor'
WHERE Id = 7
UPDATE Employees
SET MiddleName = 'Balerine'
WHERE Id = 8
UPDATE Employees
SET MiddleName = '007', LastName = 'Bond'
WHERE Id = 9
UPDATE Employees
SET FirstName = NULL, LastName = 'Crowe'
WHERE Id = 10

--igast reast võtab esimesena mitte nulli väärtuse ja paneb selle Name veergu
--kasutada coalsece
SELECT Id, COALESCE(FirstName, MiddleName, LastName) As Name
from Employees

create table IndianCustomers
(
Id int identity(1,1),
Name nvarchar(25),
Email nvarchar(25)
)

create table UKCustomers
(
Id int identity(1,1),
Name nvarchar(25),
Email nvarchar(25)
)

insert into IndianCustomers (Name, Email)
values ('Raj', 'R@R.com'),
('Sam', 'S@S.com')

insert into UKCustomers (Name, Email)
values ('Ben', 'B@B.com'),
('Sam', 'S@S.com')

SELECT * from IndianCustomers
SELECT * from UKCustomers

--kasutate union all
--kahe tabeli andmete vaatamiseks
--näitab kõik read mõlemast tabelist
SELECT Id, Name, Email FROM IndianCustomers
UNION ALL
SELECT Id, Name, Email FROM UKCustomers

--korduvate väärtuste eemaldamiseks kasutame unionit
SELECT Id, Name, Email FROM IndianCustomers
UNION
SELECT Id, Name, Email FROM UKCustomers

--kuidas tulemust sorteerida nime järgi
--kasutada union all-i
SELECT Id, Name, Email FROM IndianCustomers
UNION ALL
SELECT Id, Name, Email FROM UKCustomers
ORDER BY Name

--stored procedure
--salvestatud protseduurid on SQL-i koodid, mis on salvestatud
--andmebaasis ja mida saab käivitada,
--et teha mingi kindel töö ära
create procedure spGetEmployees
as begin
	select FirstName, Gender from Employees
end

--nüüd saame kasutada spGetEmployees-i
spGetEmployees
exec spGetEmployees
execute spGetEmployees

--
create proc spGetEmployeesByGenderAndDepartment
@Gender nvarchar(10),
@DepartmentId int
as begin
	select FirstName, Gender, DepartmentId from Employees 
	where Gender = @Gender and DepartmentId = @DepartmentId 
end

--miks annab veateate
spGetEmployeesByGenderAndDepartment
--õige variant
exec spGetEmployeesByGenderAndDepartment 'Male', 1
--kuidas minna sp järjekorrast mööda
exec spGetEmployeesByGenderAndDepartment @DepartmentId = 1, @Gender = 'Male'

sp_helptext spGetEmployeesByGenderAndDepartment

--muudame sp-d ja võti peale, et keegi teine peale teie ei saaks seda muuta
alter proc spGetEmployeesByGenderAndDepartment
@Gender nvarchar(10),
@DepartmentId int
with encryption --paneb võtme peale
as begin
	select FirstName, Gender, DepartmentId from Employees
	where Gender = @Gender and DepartmentId = @DepartmentId
end

--
create proc spGetEmployeeCountByGender
@Gender nvarchar(10),
--output on parameeter, mis võimaldab meil salvestada protseduuri
--sees tehtud arvutuse tulemuse ja kasutada seda väljaspool protseduuri
@EmployeeCount int output
as begin
	select @EmployeeCount = count(id) from Employees
	where Gender = @Gender
end

--annab tulemuse, kus loendab ära vastavad read
--prindib tulemuse, mis on parameetris @EmployeeCount
declare @TotalCount int
exec spGetEmployeeCountByGender 'Male', @TotalCount out
if(@TotalCount = 0)
	print '@TotalCount is null'
else
	print '@TotalCount is not null'
print @TotalCount

--näitab ära, et mitu rida vastab nõuetele
declare @TotalCount int
exec spGetEmployeeCountByGender @EmployeeCount = @TotalCount out, @Gender = 'Male'
print @TotalCount

--sp sisu vaatamine
sp_help spGetEmployeeCountByGender
--tabeli info
sp_help Employees
--kui soovid sp teksti näha
sp_helptext spGetEmployeeCountByGender

--vaatame, millest sõltub see sp
sp_depends spGetEmployeeCountByGender
--vaatame tabelit sp_depends-ga
sp_depends Employees

---
create proc spGetNameById
@Id int,
@Name nvarchar(30) output
as begin
	select @Id = Id, @Name = FirstName from Employees
end

--tahame näha kogu tabelite ridade arvu
--count kasutada
create proc spTotalCount2
@TotalCount int output
as begin
	select @TotalCount = count(Id) from Employees
end

--saame teada, et mitu rida on tabelis
declare @TotalEmployees int
execute spTotalCount2 @TotalEmployees output
select @TotalEmployees

--mis id all on keegi nime järgi
create proc spGetIdByName1
@Id int,
@FirstName nvarchar(30) output
as begin
	select @FirstName = FirstName from Employees where @Id = Id
end

--annab tulemuse, kus id 1 real on keegi koos nimega 
declare @FirstName nvarchar(30)
exec spGetIdByName1 9, @FirstName output
print 'Name of the employee = ' + @FirstName

---ei anna tulemust, sest sp-s on loogika viga
/* sp-s on viga sest @id on peremeeter, mis on mõeldud selleks, et me saaksime sisestada id-d
ja saada nime- aga sp-s on loogika viga, sest see üritab määrata @Id väärtuseks Id veeru väärtust,
mis on vale */
declare @FirstName nvarchar(30)
exec spGetNameById 1, @FirstName output
print 'Name of the employee = ' + @FirstName

--tund 5
--07.04.26
declare @FirstName nvarchar(30)
exec spGetNameById 1, @FirstName out
print 'Name of the employee = ' + @FirstName

sp_help spGetNameById


create proc spGetNameById2
@Id int
as begin
	return (select FirstName from Employees where Id = @Id)
end

--------------------------------------------------------------
ALTER PROCEDURE spGetNameById2
    @Id INT,
    @EmployeeName NVARCHAR(30) OUTPUT
AS
BEGIN
    SELECT @EmployeeName = FirstName
    FROM Employees
    WHERE Id = @Id
END

DECLARE @FirstName NVARCHAR(30)
EXEC spGetNameById2 
    @Id = 3,
    @EmployeeName = @FirstName OUTPUT

PRINT 'Name of the employee = ' + @FirstName

--sisseehitatud string funktsioonid
--see konverteerib ASCII tähe väärtuse numbriks
select ascii('A')
-- kuvab A-tähe
select char(65)

--prindime kogu tähestiku välja A-st Z-ni
--kasutame while tsüklit
declare @Start int
set @Start = 65
while @Start <= ASCII('Z')
begin
	print char(@Start)
	set @Start = @Start + 1
end

--eemaldame tühjad kohad sulgudes
select ltrim('                    Hello')

--tühikute eemaldamine sõnas
select ltrim(FirstName) as FirstName, MiddleName, LastName
from Employees

select rtrim('          Hello          ')

--keera kooloni sees olevad andmed vastupidiseks
--vastavalt upper ja lower-ga saan muuta märkide suurust
--reverse funktsioon keerab stringi tagurpidi
select reverse(upper(ltrim(Firstname))) as FirstName,
MiddleName, lower(LastName), rtrim(ltrim(FirstName)) + ' ' +
MiddleName + ' ' + LastName as FullName
from Employees

--left, right, substring
--left võtab stringi vasakult poolt neli esimest tähte
select left('ABCDEF', 4)
--right võtab stringi paremalt poolt neli esimest tähte
select right('ABCDEF', 4)

--kuvab @tähemärgi asetust
select CHARINDEX('@', 'sara@aaa.com')

--alates viiendast tähemärgist võtab kaks tähte
select substring('leo@bbb.com', 5, 2)

--@-märgist kuvab kolm tähemärki. Viimase nr saab
--määrata pikkust
select substring('leo@bbb.com', CHARINDEX('@', 'leo@bbb.com')
+ 1, 3)

--peale @-märki reguleerin tähemärkide pikkuse näitamist
select SUBSTRING('leo@bbb.com', CHARINDEX('@', 'leo@bbb.com') + 2,
len('leo@bbb.com') - charindex('@', 'leo@bbb.com'))

--saame teada domeeninimed emailides
--kasutame person tabelit ja substringi, len ja charindexi
select SUBSTRING(Email, charindex('@', Email) + 1,
len(Email) - charindex('@', Email)) as DomainName
from Person

alter table Employees
add Email nvarchar(20)

UPDATE Employees
SET Email = 'Tom@aaa.com'
WHERE Id = 1
UPDATE Employees
SET Email = 'Pam@bbb.com'
WHERE Id = 2
UPDATE Employees
SET Email = 'John@aaa.com'
WHERE Id = 3
UPDATE Employees
SET Email = 'Sam@bbb.com'
WHERE Id = 4
UPDATE Employees
SET Email = 'Todd@bbb.com'
WHERE Id = 5
UPDATE Employees
SET Email = 'Ben@ccc.com'
WHERE Id = 6
UPDATE Employees
SET Email = 'Sara@ccc.com'
WHERE Id = 7
UPDATE Employees
SET Email = 'Valarie@aaa.com'
WHERE Id = 8
UPDATE Employees
SET Email = 'James@bbb.com'
WHERE Id = 9
UPDATE Employees
SET Email = 'Russel@bbb.com'
WHERE Id = 10


--lisame *-märgi alates teatud kohast
select FirstName, LastName,
	substring(Email, 1, 2) + replicate('*', 5) +
	--peale teist tähemärki paneb viis tärni
	substring(Email, charindex('@', Email), len(Email)
	- charindex('@', Email) + 1) as MaskedEmail
	--kuni @-märgini paneb tärnid ja siis jätkab emaili näitamist
	--on dünaamiline, sest kui emaili pikkus on erinev,
	--siis paneb vastavalt tärne
from Employees

--kolm korda näitab stringis olevat väärtust
select REPLICATE('Hello', 3)

--kuidas sisestada tühikut kahe nime vahele
--kasutada funktsiooni
select SPACE(5)

--võtame tabeli Employees ja kuvame eesnime ja perekonnanime vahele tühikut
select FirstName + space(25) + LastName as FullName from Employees

--PATINDEX
--sama, mis charindex aga patindex võimaldab kasutada wildcardi
--kasutame tabelit Employees ja leiame kõik read, kus emaili lõpus on aaa.com
select Email, PATINDEX('%aaa.com', Email) as Position
from Employees
where PATINDEX('%aaa.com', Email) > 0
--leiame kõik read, kus emaili lõpus on aaa.com või bbb.com

--asendame emaili lõpus olevat domeeninimed
--.com asemel .net-iga
select FirstName, LastName, Email, 
replace(Email, '.com', '.net') as NewEmail
from Employees

--soovin asendada peale esimest märki olevad tähed viie tärniga
Select FirstName, LastName, Email,
	STUFF(Email, 2, 3, '*****') as StuffedEmail
from Employees

--ajaga seotud andmetüübid
create table DateTest
(
c_time time,
c_date date,
c_smalldatetime smalldatetime,
c_datetime datetime,
c_datetime2 datetime2,
c_datetimeoffset datetimeoffset
)

select * from DateTest

--sinu masina kellaaeg
select getdate() as currentDateTime

insert into DateTest
values (getdate(), getdate(), getdate(), getdate(), getdate(), getdate())

update DateTest set c_datetimeoffset = '2026-04-07 12:00:08.3766667 +02:00'
where c_datetimeoffset = '2026-04-07 17:13:08.3766667 +00:00'

select CURRENT_TIMESTAMP, 'CURRENT_TIMESTAMP' --aja päring
select SYSDATETIME(), 'SYSDATETIME' --veel täpsem aja päring
select SYSDATETIMEOFFSET(), 'SYSDATETIMEOFFSET' --täpne aja ja ajavööndi päring
select GETUTCDATE(), 'GETUTCDATE' --UTC aja päring

select ISDATE('asdasd') --tagastab 0, sest see ei ole kehtiv kuupäev
select ISDATE(getdate()) --tagastab 1, sest on kuupäev
select isdate('2026-04-07 17:13:08.3766667') --tagastab 0 kuna max kolm komakohta võib olla
select isdate('2026-04-07 17:13:08.376') --tagastab 1
select day(getdate()) --annab tänase päeva numbri
select day('01/30/2026') --annab stringis oleva kp ja järjestus peab olema õige
select month(getdate()) -- annab jooksva kuu nr
select month('01/30/2026') -- annab stringis oleva kuu
select year(getdate()) -- annab jooksva aasta nr 
select year('01/30/2022') -- annab stringis oleva aasta nr


--14.04.2026
select DATENAME(day, '2026-04-07 12:00:05.056') --annab stringis oleva päeva nime numbrina
select DATENAME(weekday, '2026-04-07 12:00:05.056') --annab stringis oleva päeva nime
select DATENAME(month, '2026-04-07 12:00:05.056') -- annab stringis oleva kuu nime

create table EmployeesWithDates
(
	Id nvarchar(2),
	Name nvarchar(20),
	DateOfBirth datetime
)

insert into EmployeesWithDates(Id, Name, DateOfBirth)
values (1, 'Sam', '1980-12-30 00:00:00.000'),
(2, 'Pam', '1982-09-01 12:02:36.260'),
(3, 'John', '1985-09-22 12:03:30.370'),
(4, 'Sara', '1979-11-29 12:59:30.670'),
(5, 'Todd', '1978-11-29 12:59:30.670')

--kuidas võtta ühest veerust andmeid ja selle abil luua uued veerud
select Name, DateOfBirth, Datename(weekday, DateOfBirth) as [Day],
	MONTH(DateOfBirth) as [Month],
	DATENAME(month, DateOfBirth) as [MonthName],
	YEAR(DateOfBirth) as [Year]
from EmployeesWithDates

--
select DATEPART(weekday, '2026-04-07 12:00:05.056') -- annab stringis oleva päeva nr, kus 1 on pühapäev
select DATEPART(MONTH, '2026-04-07 12:00:05.056') -- annab stringis oleva kuu nr
select DATENAME(week, '2026-04-07 12:00:05.056')
select Dateadd(day, 20,'2026-04-07 12:00:05.056') -- annab stringis oleva kuupäeva, mis on 20 päeva pärast
select Dateadd(day, -20,'2026-04-07 12:00:05.056') -- annab stringis oleva kuupäeva, mis on 20 päeva enne
select datediff(month, '04/30/2025', '01/31/2026')
select datediff(year, '04/30/2025', '01/31/2026')


--
create function fnComputeAge(@DOB datetime)
returns nvarchar(50)
as begin
	declare @tempdate datetime, @years int, @months int, @days int
	select @tempdate = @DOB

	select @years = datediff(year, @tempdate, getdate()) - case when (month(@DOB) > month(getdate())) or (month(@DOB))
	= month(getdate()) and day(@DOB) > day(getdate()) then 1 else 0 end
	select @tempdate = dateadd(year, @years, @tempdate)

	select @months = datediff(month, @tempdate, getdate()) - case when day(@DOB) > day(getdate()) then 1 else 0 end
	select @tempdate = dateadd(month, @months, @tempdate)

	select @days = datediff(day, @tempdate, getdate())

	declare @Age nvarchar(50)
		set @Age = cast(@years as nvarchar(10)) + ' years, ' 
		+ cast(@months as nvarchar(10)) + ' months, ' 
		+ cast(@days as nvarchar(10)) + ' days old'
	return @Age
end

--saame vanuse välja arvutada, kui kasutame fnComputeAge funktsiooni
select Name, DateOfBirth, dbo.fnComputeAge(DateOfBirth) as Age
from EmployeesWithDates

--kui kasutame seda funktsiooni, siis saame teada tänase päeva vahet
--stringis olevaga
select dbo.fnComputeAge('03/23/2008')

--nr peale DOB muutujat näitab, et missuguses järjestuses me tahame näidata veeru sisu
select Id, Name, DateOfBirth,
convert(nvarchar, DateOfBirth, 126) as ConvertedDOB
from EmployeesWithDates

select Id, Name, Name + ' - ' + cast(Id as nvarchar) as [Name-Id]
from EmployeesWithDates

select cast(getdate() as date) --tänane kuupäev
select convert(date, getdate()) --tänane kuupäev

---matemaatilised funktsioonid
select abs(-101.5) --absoluutväärtus, tagastab 101.5
select CEILING(101.5) --ümbardab üles
select CEILING(-101.5)
select FLOOR(101.5) --ümardab alla
select power(2, 4) -- tagastab 16, 2 astmes 4
select square(5) -- tagastab 25, võtab arvu ja korrutab iseendaga
select sqrt(25) --tagastab 5, võtab arvu ja leiab selle ruutjuure

select rand() --suvaline nr 0-1

--oleks vaja, et igakord annab rand meile ühe täisarvu vahemikus 1 kuni 100
select ceiling(rand()*100)

--annab juhusliku numbri vahemikus 1 kuni 1000 ja teeb seda 10 korda, et näha erinevaid numbreid
declare @count int
set @count = 1
while (@count <11)
begin
	set @count = @count + 1
	print ceiling(rand()*1000)
end


select round(850.556, 2) --ümardab kahe komakohani
select round(850.556, 2, 1)
select round(850.556, 1) -- ümardab ühe komakohani
select round(850.556, 1, 1)
select round(850.556, -2)
select round(850.556, -1)

create function dbo.CalculateAge (@DOB date)
returns int
as begin
declare @Age int

set @Age = datediff(year, @DOB, getdate()) - 
	case
		when (month(@DOB) > month(getdate())) or
		(month(@DOB) = month(getdate()) and day(@DOB) > day(getdate()))
		then 1
		else 0
		end
	return @Age
end
-----
exec CalculateAge '10/25/1980'

--arvutab välja, kui vana on isik ja võtab arvesse, kas isiku sünnipäev on juba sel aastal olnud või mitte
--antud juhul näitab, kes on üle 40 aasta vanad
select Id, dbo.CalculateAge(DateOfBirth) As Age
from EmployeesWithDates
where dbo.CalculateAge(DateOfBirth) > 40

--inline table valued functions
--teha EmployeedWithDates tabelisse
--uus veer nimega DepartmentId int, mis arvutab vanuse välja
-- ja teine veerg on Gender nvarchar(10)
alter table EmployeesWithDates
add DepartmentId int,
Gender nvarchar(10)

Update EmployeesWithDates set Gender = 'Male', DepartmentId = 1
where Id = 1
Update EmployeesWithDates set Gender = 'Female', DepartmentId = 2
where Id = 2
Update EmployeesWithDates set Gender = 'Male', DepartmentId = 1
where Id = 3
Update EmployeesWithDates set Gender = 'Female', DepartmentId = 3
where Id = 4
Update EmployeesWithDates set Gender = 'Male', DepartmentId = 1
where Id = 5

--scalar function e skaleeritav funktsioon annab mingis vahemikus olevaid
--väärtusi, aga inline table valued function tagastab tabeli,
-- ja seal ei kasutata begin ja endi vahele kirjutamist,
-- vaid lihtsalt kirjutad selecti
create function fn_EmployeesByGender(@Gender nvarchar(10))
returns table
as 
return (select Id, Name, DateOfBirth, DepartmentId, Gender
		from EmployeesWithDates
		where Gender = @Gender)

--soovime vaadata kõiki naisi EmployeesWithDates tabelist
select * from fn_EmployeesByGender('Female')

--soovin ainult näha Pam ja kasutan funktsiooni fn_EmployeesByGender
select * from fn_EmployeesByGender('Female')
where Name = 'Pam'

--kahest erinevast tabelist andmete võtmine ja koos kuvmaine
--esimene on funktsioon ja teine on Department tabel
select Name, Gender, DepartmentName
from fn_EmployeesByGender('Male') E
join Department D on D.Id = E.DepartmentId

--inline funktsioon
create function fn_GetEmployees()
returns table as 
return (select Id, Name, cast(DateOfBirth as date)
		as DOB
		from EmployeesWithDates)

select * from fn_GetEmployees()

--multi statement table valued functon
create function fn_MS_GetEmployees()
returns @Table Table (Id int, Name nvarchar(20), DOB date)
as begin
	insert into @Table
	select Id, Name, cast(DateOfBirth as date) from EmployeesWithDates

	return 
end

select * from fn_MS_GetEmployees()

--inline tabeli funktsioonid on paremini töötamas
--kuna käsitletakse vaatena
--multi statement table valued funktsioonid on nagu tavalised funktsioonid,
--pm on tegemist stored procedurega ja see võib olla aeglasem,
--sest see ei saa kasutada vaate optimeerimist e kulutab rohkem ressurssi
select * from EmployeesWithDates
update fn_GetEmployees() set Name = 'Sara' where Id = 4 -- saab muuta andmeid
select * from EmployeesWithDates
update fn_MS_GetEmployees() set Name = 'Sara' where Id = 4 
-- ei saa muuta andmeid multistate table valued funktsioonis,
--sest see on nagu stored procedure