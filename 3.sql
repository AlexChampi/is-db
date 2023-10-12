select p.Name, c.Name
from Production.Product as p
         join Production.ProductSubcategory as c
              on p.ProductSubcategoryID = c.ProductSubcategoryID
where p.ListPrice > 100

SELECT P.Name, PSC.Name
FROM [Production].[Product] AS P
         INNER JOIN
     [Production].[ProductSubcategory] AS PSC
     ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
WHERE [ListPrice] > 100

select p.Name, pc.Name
from Production.Product as p
         join Production.ProductSubcategory as c
              on p.ProductSubcategoryID = c.ProductSubcategoryID
         join Production.ProductCategory as pc
              on c.ProductCategoryID = pc.ProductCategoryID

SELECT P.Name, PC.Name
FROM [Production].[Product] AS P
         INNER JOIN
     [Production].[ProductSubcategory] AS PSC
     ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
         INNER JOIN [Production].[ProductCategory] AS PC
                    ON PSC.ProductCategoryID = PC.ProductCategoryID

select product.Name, product.ListPrice, vendor.LastReceiptCost
from Production.Product as product
         join Purchasing.ProductVendor as vendor
              on product.ProductID = vendor.ProductID
where product.ListPrice != 0
  and product.ListPrice < vendor.LastReceiptCost

select count(distinct pr.ProductID)
from Production.Product as pr
         join Purchasing.ProductVendor as pv on pr.ProductID = pv.ProductID
         join Purchasing.Vendor as v on pv.BusinessEntityID = v.BusinessEntityID
where v.CreditRating = 1

select count(distinct pr.ProductID)
from Production.Product as pr
         join Purchasing.ProductVendor as pv on pr.ProductID = pv.ProductID
         join Purchasing.Vendor as v on pv.BusinessEntityID = v.BusinessEntityID
where v.CreditRating = 1

SELECT COUNT(DISTINCT PV.ProductID)
FROM [PurchASINg].[ProductVendor] AS PV
         INNER JOIN
     [PurchASINg].[Vendor] AS V
     ON PV.BusINessEntityID = V.BusINessEntityID
WHERE [CreditRatINg] = 1

select ve.CreditRating, count(distinct pv.ProductID)
from Purchasing.ProductVendor as pv
         join Purchasing.Vendor as ve
              on pv.BusinessEntityID = ve.BusinessEntityID
group by ve.CreditRating

SELECT [CreditRatINg], COUNT(DISTINCT PV.ProductID)
FROM [PurchASINg].[ProductVendor] AS PV
         INNER JOIN
     [PurchASINg].[Vendor] AS V
     ON PV.BusINessEntityID = V.BusINessEntityID
GROUP BY [CreditRatINg]

select top 3 ps.ProductSubcategoryID, count(*)
from Production.ProductSubcategory as ps
         join Production.Product P on ps.ProductSubcategoryID = P.ProductSubcategoryID
group by ps.ProductSubcategoryID
order by count(*) desc

SELECT TOP 3 [ProductSubcategoryID], count(*)
FROM [Production].[Product]
WHERE [ProductSubcategoryID] IS NOT NULL
GROUP BY Production.Product.[ProductSubcategoryID]
order by count(*) desc


select top 3 ps.ProductSubcategoryID, ps.Name, count(*)
from Production.Product as p
         join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
group by ps.ProductSubcategoryID, ps.Name
order by count(*) desc

SELECT top 3 psc.name, count(*)
FROM [Production].[Product] AS p
         INner JOIN
     [Production].[ProductSubcategory] AS psc
     ON p.ProductSubcategoryID = psc.ProductSubcategoryID
WHERE p.ProductSubcategoryID is NOT null
GROUP BY p.ProductSubcategoryID, psc.Name
ORDER BY count(*) desc

select 1.0 * count(*) / count(distinct p.ProductSubcategoryID)
from Production.Product as p
where p.ProductSubcategoryID IS NOT NULL

SELECT 1.0 * COUNT(*) / COUNT(DISTINCT [ProductSubcategoryID])
FROM [Production].[Product]
WHERE [ProductSubcategoryID] IS NOT NULL


SELECT COUNT(DISTINCT [Color])
FROM [Production].[Product] AS P
         INNER JOIN
     [Production].[ProductSubcategory] AS PSC
     ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
         JOIN [Production].[ProductCategory] AS PC
              ON PSC.ProductCategoryID = PC.ProductCategoryID
GROUP BY PC.ProductCategoryID


SELECT COUNT(DISTINCT [Color])
FROM [Production].[Product] AS P
         INNER JOIN
     [Production].[ProductSubcategory] AS PSC
     ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
         RIGHT JOIN [Production].[ProductCategory] AS PC
                    ON PSC.ProductCategoryID = PC.ProductCategoryID
GROUP BY PC.ProductCategoryID


-- 1 Найти и вывести на экран название продуктов и название категорий товаров, к
-- которым относится этот продукт, с учетом того, что в выборку попадут только
-- товары с цветом Red и ценой не менее 100

select p.Name, pc.Name
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
where p.Color = 'Red'
  and p.ListPrice >= 100

-- 2 Вывести на экран названия подкатегорий с совпадающими именами.

select ps.Name
from Production.ProductCategory as ps
group by ps.Name
having count(*) > 1

select ps.Name
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.Name = ps.Name
         join Production.ProductCategory as pc
              on ps.Name = pc.Name

-- 3 Вывести на экран название категорий и количество товаров в данной
-- категории.

select pc.Name, count(*)
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory as pc
              on ps.ProductCategoryID = pc.ProductCategoryID
group by pc.Name

-- 4 Вывести на экран название подкатегории, а также количество товаров в данной
-- подкатегории с учетом ситуации, что могут существовать подкатегории с
-- одинаковыми именами.

select ps.Name, count(*)
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
group by ps.Name


-- 5 Вывести на экран название первых трех подкатегорий с небольшим
-- количеством товаров.

select top 3 ps.Name, count(*)
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
group by ps.Name
order by count(*) desc

SELECT TOP 3 productSubcategory.Name, COUNT(product.ProductID) as 'Количество'
FROM Production.Product as product
         INNER JOIN
     Production.ProductSubcategory as productSubcategory
     ON
         product.ProductSubcategoryID = productSubcategory.ProductSubcategoryID
GROUP BY productSubcategory.Name
ORDER BY COUNT(product.ProductID) DESC


-- 6 Вывести на экран название подкатегории и максимальную цену продукта с
-- цветом Red в этой подкатегории.
select ps.Name, max(p.ListPrice)
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
where p.Color = 'Red'
group by ps.Name

select ListPrice
from Production.Product
where Color = 'Red'
order by ListPrice desc

SELECT productSubcategory.Name, MAX(product.ListPrice) as 'Максимальная цена'
FROM Production.Product as product
         INNER JOIN
     Production.ProductSubcategory as productSubcategory
     ON
         product.ProductSubcategoryID = productSubcategory.ProductSubcategoryID
WHERE product.Color = 'Red'
GROUP BY productSubcategory.Name
ORDER BY MAX(product.ListPrice)
-- 7 Вывести на экран название поставщика и количество товаров, которые он
-- поставляет.
select v.Name, count(p.ProductID)
from Production.Product as p
         join Purchasing.ProductVendor as pv
              on p.ProductID = pv.ProductID
         join Purchasing.Vendor as v on pv.BusinessEntityID = v.BusinessEntityID
group by v.Name
-- 8 Вывести на экран название товаров, которые поставляются более чем одним
-- поставщиком.
select p.Name, count(pv.BusinessEntityID)
from Production.Product as p
         join Purchasing.ProductVendor as pv
              on p.ProductID = pv.ProductID
group by p.Name
having count(pv.BusinessEntityID) > 1

SELECT P.Name,
       COUNT(*)
FROM Purchasing.ProductVendor as PV
         JOIN
     Production.Product as P
     ON
         P.ProductID = PV.ProductID
GROUP BY P.Name
HAVING COUNT(*) > 1
-- 9 Вывести на экран название самого продаваемого товара.
select top 1 p.Name, count(*)
from Production.Product as p
         join Purchasing.PurchaseOrderDetail as pod
              on p.ProductID = pod.ProductID
group by p.Name
order by count(*) desc

SELECT TOP 1 P.Name,
             COUNT(*)
FROM Purchasing.ProductVendor as PV
         JOIN
     Production.Product as P
     ON
         P.ProductID = PV.ProductID
GROUP BY P.Name
ORDER BY COUNT(*) DESC
-- 10 Вывести на экран название категории, товары из которой продаются наиболее
-- активно.
select pc.Name, count(*)
from Production.Product as p
         join Purchasing.PurchaseOrderDetail as pod on p.ProductID = pod.ProductID
         join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
group by pc.Name
order by count(*) desc

SELECT PC.Name,
       count(*)
FROM Production.Product AS P
         JOIN
     Production.ProductSubcategory AS PSC
     ON
         P.ProductSubcategoryID = PSC.ProductSubcategoryID
         JOIN
     Production.ProductCategory AS PC
     ON
         PSC.ProductCategoryID = PC.ProductCategoryID
         JOIN
     Purchasing.PurchaseOrderDetail AS PPV
     ON
         P.ProductID = PPV.ProductID
GROUP BY PC.Name
ORDER BY COUNT(*) DESC
-- 11 Вывести на экран названия категорий, количество подкатегорий и количество
-- товаров в них.
select pc.Name, count(distinct ps.ProductSubcategoryID), count(*)
from Production.Product as p
         join Production.ProductSubcategory ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
group by pc.Name
-- 12 Вывести на экран номер кредитного рейтинга и количество товаров,
-- поставляемых компаниями, имеющими этот кредитный рейтинг.
select v.CreditRating, count(pv.ProductID)
from Purchasing.ProductVendor as pv
         join Purchasing.Vendor as v on pv.BusinessEntityID = v.BusinessEntityID
group by v.CreditRating

SELECT CreditRating,
       COUNT(ProductID)
FROM Purchasing.ProductVendor AS PV
         JOIN
     Purchasing.Vendor AS V
     ON
         PV.BusinessEntityID = V.BusinessEntityID
GROUP BY CreditRating

-- 1 Вывести названия категорий товаров, количество продуктов в которых больше 20
select pc.Name, count(*)
from Production.Product as p
         join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
group by pc.Name
having count(*) > 20

select pc.name, count(*)
from Production.Product as p
         INNER JOIN Production.ProductSubcategory as psc
                    on p.ProductSubcategoryID = psc.ProductSubcategoryID
         INNER JOIN Production.ProductCategory as pc
                    on psc.ProductCategoryID = PC.ProductCategoryID
group by PC.Name
having count(*) > 20

-- 2 Получить названия первых двух категорий товаров из упорядоченного по возрастанию количества товаров в категории списка
select top 2 pc.Name, count(*)
from Production.Product as p
         join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
group by pc.Name
having count(*) > 20
order by count(*) asc

select top 2 pc.name
from Production.ProductCategory as pc
         join production.ProductSubcategory as psc
              on psc.ProductCategoryID = pc.ProductCategoryID
         join production.Product as p
              on psc.ProductSubcategoryID = p.ProductSubcategoryID
group by pc.name
order by count(*) asc

-- 3  Найти названия товаров, которые были проданы хотя бы один раз
select p.Name
from Production.Product as p
         join Sales.SalesOrderDetail as pod
              on p.ProductID = pod.ProductID
group by p.Name

select p.name
from Production.Product as p
         join Sales.SalesOrderDetail as sod on p.ProductID = sod.ProductID
group by p.name

-- Найти названия товаров, которые не были проданы ни разу
select p.Name
from Production.Product as p
         left join Sales.SalesOrderDetail as sod
                   on p.ProductID = sod.ProductID
where sod.ProductID is null
group by p.Name

-- Вывести на экран список товаров, названия, упорядоченный по количеству продаж, по возрастанию
select p.Name, count(*)
from Production.Product as p
         join Sales.SalesOrderDetail as sod
              on p.ProductID = sod.ProductID
group by p.Name
order by count(*) asc

SELECT p.Name
FROM Production.Product AS p
         join Sales.SalesOrderDetail as sod
              on p.ProductID = sod.ProductID
GROUP BY p.Name
ORDER BY COUNT(*)

-- Вывести на экран первых три товара с наибольшим количеством продаж
select top 3 p.Name, count(*)
from Production.Product as p
         join Sales.SalesOrderDetail as sod
              on p.ProductID = sod.ProductID
group by p.Name
order by count(*) desc

SELECT top 3 p.Name
FROM Production.Product as p
         join Sales.SalesOrderDetail as sod
              on p.ProductID = sod.ProductID
GROUP BY p.Name
ORDER BY COUNT(*) desc

-- Вывести на экран список категорий, названия, упорядоченный по количеству продаж товаров этих категорий, по возрастанию
select top 3 pc.Name, count(*)
from Production.Product as p
         join Sales.SalesOrderDetail as sod
              on p.ProductID = sod.ProductID
         join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
group by pc.Name
order by count(*) desc

select v.Name
from Production.Product as p
         join Purchasing.ProductVendor as pv on p.ProductID = pv.ProductID
         join Purchasing.Vendor as v on pv.BusinessEntityID = v.BusinessEntityID
group by v.Name
order by count(*)
select v.name
from Purchasing.Vendor as v
         join Purchasing.ProductVendor as pv
              on pv.BusinessEntityID = v.BusinessEntityID
         join Production.Product as p
              on p.ProductID = pv.ProductID
group by v.name
order by count(*) asc

-- 9 Получить названия первых двух категорий товаров из упорядоченного по возрастанию количества товаров в категории списка
select top 2 pc.name
from Production.ProductCategory as pc
         join production.ProductSubcategory as psc
              on psc.ProductCategoryID = pc.ProductCategoryID
         join production.Product as p
              on psc.ProductSubcategoryID = p.ProductSubcategoryID
group by pc.name
order by count(*) asc
-- 10 Найти сколько различных размеров товаров приходится на каждую категорию товаров
select pc.Name, count(distinct p.Size)
from Production.Product as p
         join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
group by pc.Name

select pc.Name, count(distinct p.Size)
from Production.Product as p
         join Production.ProductSubcategory as psc
              on p.ProductSubcategoryID = psc.ProductSubcategoryID
         join Production.ProductCategory as pc
              on psc.ProductCategoryID = pc.ProductCategoryID
group by pc.Name

-- 12. Найти названия тех категорий товаров, где количество товаров более 20
select pc.Name, count(*)
from Production.Product as p
         join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
group by pc.Name
having count(*) > 20

SELECT PC.Name, count(*)
FROM [Production].[Product] AS P
         INNER JOIN [Production].[ProductSubcategory] AS PSC
                    ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
         INNER JOIN [Production].[ProductCategory] AS PC
                    ON PSC.ProductCategoryID = PC.ProductCategoryID
group by PC.Name
having count(*) > 20












select top 2 pc.Name
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory as pc
              on ps.ProductCategoryID = pc.ProductCategoryID
group by pc.Name
order by count(p.ProductID)


select p.name, pc.Name, count(*)
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory as pc
              on ps.ProductCategoryID = pc.ProductCategoryID
where p.Color = 'Blue'
group by p.name, pc.Name
having count(*) = 2