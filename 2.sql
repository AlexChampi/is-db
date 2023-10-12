SELECT [Color], count(*)
FROM [Production].[Product] as p
WHERE p.SafetyStockLevel = 1000
GROUP BY [Color]

SELECT [Color], [Style], COUNT(*) AS 'Amount'
FROM [Production].[Product]
WHERE [Color] IS NOT NULL
  AND [Style] IS NOT NULL
GROUP BY [Color], [Style]

SELECT [Color], [Style], [Class], COUNT(*) as 'Count'
FROM [Production].[Product]
GROUP BY [Color], [Style], [Class]

SELECT [Color], [Style], [Class], COUNT(*) as 'Count'
FROM [Production].[Product]
GROUP BY ROLLUP ([Color], [Style], [Class])

SELECT Color, Size, COUNT(*)
FROM [Production].[Product]
GROUP BY GROUPING SETS (([Color]), ([Size]))

-- 1. Найти и вывести на экран количество товаров каждого цвета, исключив из
-- поиска товары, цена которых меньше 30
SELECT Color, Count(*) as 'Price'
FROM Production.Product as p
WHERE Color IS not null
  and ListPrice >= 30
GROUP BY Color

-- 2. Найти и вывести на экран список, состоящий из цветов товаров, таких, что
-- минимальная цена товара данного цвета более 100.
SELECT Color, Count(*) as 'Price'
FROM Production.Product as p
GROUP BY Color
HAVING MIN(p.ListPrice) > 100

-- 3. Найти и вывести на экран номера подкатегорий товаров и количество товаров
-- в каждой категории.
select ProductSubcategoryID, count(*)
from Production.Product
where ProductSubcategoryID is not null
group by ProductSubcategoryID
-- 4. Найти и вывести на экран номера товаров и количество фактов продаж данного
-- товара (используется таблица SalesORDERDetail).
select ProductID, count(*)
from Sales.SalesOrderDetail
group by ProductID
-- 5. Найти и вывести на экран номера товаров, которые были куплены более пяти
-- раз.
select ProductID, count(*)
from Sales.SalesOrderDetail
group by ProductID
having count(*) > 5
-- 6. Найти и вывести на экран номера покупателей, CustomerID, у которых
-- существует более одного чека, SalesORDERID, с одинаковой датой
select CustomerID
from Sales.SalesOrderHeader
group by CustomerID, OrderDate
having count(SalesOrderID) > 1

-- 7. Найти и вывести на экран все номера чеков, на которые приходится более трех
-- продуктов.
select SalesOrderDetail.SalesOrderID, count(ProductID)
from Sales.SalesOrderDetail
group by SalesOrderID
having count(ProductID) > 3

-- 8. Найти и вывести на экран все номера продуктов, которые были куплены более
-- трех раз.
select ProductID, count(ProductID)
from Sales.SalesOrderDetail
group by ProductID
having count(ProductID) > 3

select ProductID
from Sales.SalesOrderDetail
group by ProductID
having sum(OrderQty) > 3
-- 9. Найти и вывести на экран все номера продуктов, которые были куплены или
-- три или пять раз.
select ProductID, count(ProductID)
from Sales.SalesOrderDetail
group by ProductID
having count(ProductID) = 3
    or count(ProductID) = 5

SELECT ProductID,
       COUNT(*) as 'ProductCount'
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING COUNT(*) IN (3, 5)
-- 10. Найти и вывести на экран все номера подкатегорий, в которым относится
-- более десяти товаров.
select ProductSubcategoryID
from Production.Product
group by ProductSubcategoryID
having count(*) > 10
-- 11. Найти и вывести на экран номера товаров, которые всегда покупались в
-- одном экземпляре за одну покупку.
select ProductID
from Sales.SalesOrderDetail
group by ProductID
having max(OrderQty) = 1

-- 12 Найти и вывести на экран номер чека, SalesORDERID, на который приходится
-- с наибольшим разнообразием товаров купленных на этот чек.
select top 1 SalesOrderID, count(distinct ProductID)
from Sales.SalesOrderDetail
group by SalesOrderID
order by count(distinct ProductID) DESC


-- 13 Найти и вывести на экран номер чека, SalesORDERID с наибольшей суммой
-- покупки, исходя из того, что цена товара – это UnitPrice, а количество
-- конкретного товара в чеке – это ORDERQty.
select top 1 SalesOrderID, sum(UnitPrice * OrderQty)
from Sales.SalesOrderDetail
group by SalesOrderID
order by sum(UnitPrice * OrderQty) desc

select top 1 sod.SalesOrderID
from Sales.SalesOrderDetail as sod
group by sod.SalesOrderID
order by sum(sod.UnitPrice * sod.OrderQty) desc
-- 14 Определить количество товаров в каждой подкатегории, исключая товары,
-- для которых подкатегория не определена, и товары, у которых не определен цвет.
select ProductSubcategoryID, count(*) as count
from Production.Product
where ProductSubcategoryID is not null
  and Color is not null
group by ProductSubcategoryID

select p.ProductSubcategoryID, count(*) as count
from Production.Product as p
where p.ProductSubcategoryID is not null
  and p.Color is not null
group by p.ProductSubcategoryID
-- 15 Получить список цветов товаров в порядке убывания количества товаров
-- данного цвета
select Color, count(*) as count
from Production.Product
where Color is not null
group by Color
order by count(*) desc

-- 16 Вывести на экран ProductID тех товаров, что всегда покупались в количестве
-- более 1 единицы на один чек, при этом таких покупок было более двух
select ProductID
from Sales.SalesOrderDetail
group by ProductID
having min(OrderQty) = 2
   and count(*) > 2

select sod.ProductID
from Sales.SalesOrderDetail as sod
group by sod.ProductID
having count(*) > 2
   and min(sod.OrderQty) = 2


select p.Color
from Production.Product as p
where p.Color is not null
group by p.Color
having count(*) >= 2
   and count(*) <= 5