-- Необходимо получить название товаров, чей цвет совпадает с цветом одного из
-- товаров, чья цена больше 3000.
SELECT [Name]
FROM [Production].[Product]
WHERE [Color] IN
      (SELECT [Color]
       FROM [Production].[Product]
       WHERE [ListPrice] > 3000)

-- 1 Найти название подкатегории с наибольшим количеством продуктов, без учета
-- продуктов, для которых подкатегория не определена (еще одна возможная
-- реализация)

select ps.Name
from Production.ProductSubcategory as ps
where ps.ProductSubcategoryID =
      (select top 1 p.ProductSubcategoryID
       from Production.Product as p
       where p.ProductSubcategoryID is not null
       group by p.[ProductSubcategoryID]
       order by count(*) desc)

SELECT [Name]
FROM [Production].[ProductSubcategory]
WHERE [ProductSubcategoryID] IN
      (SELECT [ProductSubcategoryID]
       FROM [Production].[Product]
       WHERE [ProductSubcategoryID] IS NOT NULL
       GROUP BY [ProductSubcategoryID]
       HAVING COUNT(*) =
              (SELECT TOP 1 COUNT(*)
               FROM [Production].[Product]
               WHERE [ProductSubcategoryID] IS NOT NULL
               GROUP BY [ProductSubcategoryID]
               ORDER BY 1 DESC))

-- 2 Вывести на экран такого покупателя, который каждый раз покупал только одну
-- номенклатуру товаров, не обязательно в одинаковых количествах, т.е. у него
-- всегда был один и тот же «список покупок»

select soh.CustomerID, count(*)
from Sales.SalesOrderHeader as soh
group by soh.CustomerID
having count(*) > 1
   and count(*) = all
       (select count(*)
        from Sales.SalesOrderHeader as soh1
                 join
             Sales.SalesOrderDetail sod
             on soh1.SalesOrderID = sod.SalesOrderID
        group by soh1.CustomerID, sod.ProductID
        having soh1.CustomerID = soh.[CustomerID])

-- 3 Вывести на экран следующую информацию: название товара (первая колонка),
-- количество покупателей, покупавших этот товар (вторая колонка), количество
-- покупателей, совершавших покупки, но не покупавших товар из первой колонки
-- (третья колонка)

select p.ProductID,
       (select count(distinct soh.CustomerID)
        from Sales.SalesOrderDetail as sod
                 join Sales.SalesOrderHeader as soh
                      on sod.SalesOrderID = soh.SalesOrderID
        where p.ProductID = sod.ProductID),
       (select count(distinct soh.CustomerID)
        from Sales.SalesOrderDetail as sod
                 join Sales.SalesOrderHeader as soh
                      on sod.SalesOrderID = soh.SalesOrderID
        where soh.CustomerID not in
              (select distinct soh.CustomerID
               from Sales.SalesOrderDetail as sod
                        join Sales.SalesOrderHeader as soh
                             on sod.SalesOrderID = soh.SalesOrderID
               where p.ProductID = sod.ProductID))
from Production.Product as p

select p.[ProductID],
       (SELECT count(DISTINCT soh.CustomerID)
        FROM [Sales].[SalesORDERDetail] AS sod
                 INner JOIN
             [Sales].[SalesORDERHeader] AS soh
             ON sod.SalesORDERID = soh.SalesORDERID
        WHERE sod.ProductID = p.ProductID),
       (SELECT count(DISTINCT soh.CustomerID)
        FROM [Sales].[SalesORDERDetail] AS sod
                 INner JOIN
             [Sales].[SalesORDERHeader] AS soh
             ON sod.SalesORDERID = soh.SalesORDERID
        WHERE soh.CustomerID NOT IN
              (SELECT DISTINCT soh.CustomerID
               FROM [Sales].[SalesORDERDetail] AS sod
                        INner JOIN
                    [Sales].[SalesORDERHeader] AS soh
                    ON sod.SalesORDERID = soh.SalesORDERID
               WHERE sod.ProductID = p.ProductID))
FROM [Production].[Product] AS p

-- 4 Найти такие товары, которые были куплены более чем одним покупателем, при
-- этом все покупатели этих товаров покупали товары только из одной
-- подкатегории

select sod.ProductID
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID
where soh.CustomerID in
      (select soh1.CustomerID
       from Sales.SalesOrderDetail as sod1
                join Sales.SalesOrderHeader as soh1
                     on sod1.SalesOrderID = soh1.SalesOrderID
                join Production.Product as p
                     on sod1.ProductID = p.ProductID
       group by soh1.CustomerID
       having count(distinct p.ProductSubcategoryID) = 1)
group by sod.ProductID
having count(distinct soh.CustomerID) > 1
order by sod.ProductID

SELECT sod.ProductID
FROM [Sales].[SalesORDERDetail] AS sod
         JOIN
     [Sales].[SalesORDERHeader] AS soh
     ON sod.SalesORDERID = soh.SalesORDERID
WHERE soh.CustomerID IN (SELECT soh.CustomerID
                         FROM [Sales].[SalesORDERDetail] AS sod
                                  JOIN
                              [Sales].[SalesORDERHeader] AS soh
                              ON sod.SalesORDERID = soh.SalesORDERID
                                  JOIN
                              [Production].[Product] AS p ON
                                  sod.ProductID = p.ProductID
                         GROUP BY soh.CustomerID
                         HAVING count(DISTINCT p.ProductSubcategoryID) = 1)
GROUP BY sod.ProductID
HAVING count(DISTINCT soh.CustomerID) > 1
order by sod.ProductID

-- 5 Найти покупателя, который каждый раз имел разный список товаров в чеке (по
-- номенклатуре).

select distinct soh.CustomerID
from Sales.SalesOrderHeader as soh
where soh.CustomerID not in (select soh1.CustomerID
                             from Sales.SalesOrderHeader as soh1
                                      join Sales.SalesOrderDetail as sod1
                                           on soh1.SalesOrderID = sod1.SalesOrderID
                             where exists(select sod2.ProductID
                                          from Sales.SalesOrderHeader as soh2
                                                   join Sales.SalesOrderDetail as sod2
                                                        on soh2.SalesOrderID = sod2.SalesOrderID
                                          where soh1.CustomerID = soh2.CustomerID
                                            and sod1.ProductID = sod2.ProductID
                                            and soh1.SalesOrderID != soh2.SalesOrderID))

SELECT DISTINCT CustomerID
FROM [Sales].[SalesORDERHeader]
WHERE CustomerID NOT IN (SELECT soh.Customerid
                         FROM [Sales].[SalesORDERDetail] AS sod
                                  JOIN
                              [Sales].[SalesORDERHeader] AS soh
                              ON sod.SalesORDERID = soh.SalesORDERID
                         WHERE exists(SELECT ProductID
                                      FROM [Sales].[SalesORDERDetail] AS sod1
                                               JOIN
                                           [Sales].[SalesORDERHeader] AS soh1
                                           ON sod.SalesORDERID = soh.SalesORDERID
                                      WHERE soh1.CustomerID = soh.CustomerID
                                        AND sod1.ProductID = sod.ProductID
                                        AND sod.SalesORDERID != sod1.SalesORDERID
                                   ))

-- 6 Найти такого покупателя, что все купленные им товары были куплены только
-- им и никогда не покупались другими покупателями.


SELECT DISTINCT soh.CustomerID
FROM [Sales].[SalesORDERHeader] AS soh
WHERE soh.CustomerID NOT IN (SELECT DISTINCT soh.CustomerID
                             FROM [Sales].[SalesORDERDetail] AS sod
                                      JOIN
                                  [Sales].[SalesORDERHeader] AS soh
                                  ON sod.SalesORDERID = soh.SalesORDERID
                             WHERE ProductID NOT IN (SELECT sod.ProductID
                                                     FROM [Sales].[SalesORDERDetail] AS sod
                                                              JOIN
                                                          [Sales].[SalesORDERHeader] AS soh
                                                          ON sod.SalesORDERID = soh.SalesORDERID
                                                     GROUP BY sod.ProductID
                                                     HAVING count(DISTINCT soh.CustomerID) = 1))

-- 1 Найти название самого продаваемого продукта
select p.Name
from Production.Product as p
where p.ProductID =
      (select top 1 sod.ProductID
       from Sales.SalesOrderDetail as sod
       group by sod.ProductID
       order by count(*))

SELECT NAME
FROM Production.Product
         AS production
WHERE ProductID IN
      (SELECT TOP 1 ProductID
       FROM Sales.SalesOrderDetail
       GROUP BY ProductID
       ORDER BY COUNT(*))

-- 2 Найти покупателя, совершившего покупку на самую большую сумм, считая
-- сумму покупки исходя из цены товара без скидки (UnitPrice).

select soh.CustomerID
from Sales.SalesOrderHeader as soh
where soh.SalesOrderID =
      (select top 1 sod.SalesOrderID
       from Sales.SalesOrderDetail as sod
       group by sod.SalesOrderID
       having sum(sod.OrderQty * sod.UnitPrice) =
              (select top 1 sum(sod1.UnitPrice * sod1.OrderQty)
               from Sales.SalesOrderDetail as sod1
               group by sod1.SalesOrderID
               order by sum(sod1.UnitPrice * sod1.OrderQty) desc)
       order by sum(sod.OrderQty * sod.UnitPrice) desc)

SELECT SOH.CustomerID,
       SOD.OrderQty * SOD.UnitPrice AS 'Total Cost'
FROM Sales.SalesOrderHeader AS SOH
         JOIN
     Sales.SalesOrderDetail AS SOD
     ON
         SOH.SalesOrderID = SOD.SalesOrderID
WHERE SOD.OrderQty * SOD.UnitPrice =
      (SELECT MAX(SOD.OrderQty * SOD.UnitPrice)
       FROM Sales.SalesOrderHeader AS SOH
                JOIN
            Sales.SalesOrderDetail AS SOD
            ON
                SOH.SalesOrderID = SOD.SalesOrderID)


select sum(sod.OrderQty * sod.UnitPrice), soh.SalesOrderID
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID
where CustomerID = 29641
group by soh.SalesOrderID;

select *
from Sales.SalesOrderHeader
where SalesOrderID = 51131


select sod.SalesOrderID, sum(sod.OrderQty * sod.UnitPrice)
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID
group by soh.CustomerID, sod.SalesOrderID
order by sum(sod.OrderQty * sod.UnitPrice) desc

-- 3 Найти такие продукты, которые покупал только один покупатель.
select p.Name
from Production.Product as p
where p.ProductID in
      (select sod1.ProductID
       from Sales.SalesOrderHeader as soh1
                join
            Sales.SalesOrderDetail as sod1
            on soh1.SalesOrderID = sod1.SalesOrderID
       group by sod1.ProductID
       having count(distinct soh1.CustomerID) = 1)
SELECT SSOD.ProductID
FROM Sales.SalesOrderDetail
         AS SSOD
WHERE SSOD.ProductID IN (SELECT COUNT(SSOH.CustomerID)
                         FROM Sales.SalesOrderHeader as SSOH
                         GROUP BY SSOH.CustomerID
                         HAVING COUNT(DISTINCT SSOH.CustomerID) = 1)

SELECT ProductID
FROM Sales.SalesOrderDetail
WHERE ProductID IN
      (SELECT SOD.ProductID
       FROM Sales.SalesOrderDetail AS SOD
                JOIN
            Sales.SalesOrderHeader AS SOH
            ON
                SOD.SalesOrderID = SOH.SalesOrderID
       GROUP BY SOD.ProductID
       HAVING COUNT(DISTINCT SOH.CustomerID) = 1)

-- 4 Вывести список продуктов, цена которых выше средней цены товаров в
-- подкатегории, к которой относится товар


select p1.ProductID, p1.Name
from Production.Product as p1
where p1.ListPrice >
      (select avg(p2.ListPrice)
       from Production.Product as p2
       where p2.ProductSubcategoryID = p1.ProductSubcategoryID)

SELECT Name,
       ProductID,
       ListPrice
FROM Production.Product as p1
WHERE ListPrice > ALL
      (SELECT AVG(P.ListPrice)
       FROM Production.Product AS P
       WHERE p1.ProductSubcategoryID = P.ProductSubcategoryID)

SELECT product.Name
FROM Production.Product
         AS product
WHERE product.ListPrice > ALL (SELECT AVG(product.ListPrice)
                               FROM Production.Product
                               WHERE ProductSubcategoryID = product.ProductSubcategoryID)

-- 5 Найти такие товары, которые были куплены более чем одним покупателем, при
-- этом все покупатели этих товаров покупали товары только одного цвета и товары
-- не входят в список покупок покупателей, купивших товары только двух цветов.

select sod0.Name
from Production.Product as sod0
where sod0.ProductID in (select sod.ProductID
                         from Sales.SalesOrderDetail as sod
                                  join Sales.SalesOrderHeader as soh
                                       on sod.SalesOrderID = soh.SalesOrderID
                         where soh.CustomerID in
                               (select soh1.CustomerID
                                from Sales.SalesOrderHeader as soh1
                                         join
                                     Sales.SalesOrderDetail as sod1
                                     on soh1.SalesOrderID = sod1.SalesOrderID
                                         join
                                     Production.Product as p
                                     on sod1.ProductID = p.ProductID
                                where p.Color is not null
                                group by soh1.CustomerID
                                having count(distinct p.Color) = 1)
                         group by sod.ProductID
                         having count(distinct soh.CustomerID) > 1)

SELECT Name
FROM Production.Product
WHERE ProductID IN
      (SELECT SOD.ProductID
       FROM Sales.SalesOrderDetail AS SOD
                JOIN
            Sales.SalesOrderHeader AS SOH
            ON
                SOD.SalesOrderID = SOH.SalesOrderID
       WHERE SOH.CustomerID IN
             (SELECT SOH.CustomerID
              FROM Sales.SalesOrderDetail AS SOD
                       JOIN
                   Sales.SalesOrderHeader AS SOH
                   ON
                       SOD.SalesOrderID = SOH.SalesOrderID
                       JOIN
                   Production.Product AS P
                   ON
                       SOD.ProductID = P.ProductID
              GROUP BY SOH.CustomerID
              HAVING COUNT(DISTINCT P.Color) = 1
                 and COUNT(DISTINCT P.Color) != 2)
       GROUP BY SOD.ProductID
       HAVING COUNT(DISTINCT SOH.CustomerID) > 1)

-- 6 Найти такие товары, которые были куплены такими покупателями, у которых
-- они присутствовали в каждой их покупке.

select soh.CustomerID
from Sales.SalesOrderDetail as sod
         join Sales.SalesOrderHeader as soh
              on sod.SalesOrderID = soh.SalesOrderID
group by sod.ProductID, soh.CustomerID
having count(distinct soh.SalesOrderID) =
       (select count(distinct soh1.SalesOrderID)
        from Sales.SalesOrderHeader as soh1
                 join Sales.SalesOrderDetail as sod1
                      on soh1.SalesOrderID = sod1.SalesOrderID
        where soh1.CustomerID = soh.CustomerID
        group by soh1.CustomerID)
order by sod.ProductID

SELECT SOH.CustomerID
       FROM Sales.SalesOrderDetail AS SOD
                JOIN
            Sales.SalesOrderHeader AS SOH
            ON
                SOD.SalesOrderID = SOH.SalesOrderID
       WHERE EXISTS
                 (
                     SELECT _SOH.CustomerID
                     FROM Sales.SalesOrderDetail as _SOD
                              JOIN
                          Sales.SalesOrderHeader as _SOH
                          ON
                              _SOD.SalesOrderID = _SOH.SalesOrderID
                     WHERE SOH.CustomerID = _SOH.CustomerID
                       and SOD.ProductID = _SOD.ProductID
                       and SOD.SalesOrderID != _SOD.SalesOrderID
                     GROUP BY _SOH.CustomerID, _SOD.ProductID
                     HAVING COUNT(DISTINCT _SOD.ProductID) =
                            (SELECT COUNT(DISTINCT __SOD.ProductID)
                             FROM Sales.SalesOrderDetail AS __SOD
                             WHERE SOD.ProductID = __SOD.ProductID
                             GROUP BY __SOD.ProductID)
                 )


select count(soh.CustomerID)
from Sales.SalesOrderDetail as sod
         join Sales.SalesOrderHeader as soh
              on sod.SalesOrderID = soh.SalesOrderID
where sod.ProductID = 710

select count(sod.SalesOrderID)
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID
where soh.CustomerID in
      (select soh.CustomerID
       from Sales.SalesOrderDetail as sod
                join Sales.SalesOrderHeader as soh
                     on sod.SalesOrderID = soh.SalesOrderID
       where sod.ProductID = 710)
group by CustomerID
order by count(sod.SalesOrderID) desc

-- 7 Найти покупателей, у которых есть товар, присутствующий в каждой
-- покупке/чеке.
select distinct CustomerID
from Sales.SalesOrderHeader
where CustomerID in (select CustomerID
                     from Sales.SalesOrderHeader as soh
                              join
                          Sales.SalesOrderDetail as sod
                          on soh.SalesOrderID = sod.SalesOrderID
                     where exists(select soh.CustomerID
                                  from Sales.SalesOrderDetail as sod1
                                           join
                                       Sales.SalesOrderHeader as soh1
                                       on sod1.SalesOrderID = soh1.SalesOrderID
                                  where soh1.CustomerID = soh.CustomerID
                                    and sod1.ProductID = sod.ProductID
                                    and soh1.SalesOrderID != soh.SalesOrderID
                               ))

SELECT DISTINCT CustomerID
FROM Sales.SalesOrderHeader
WHERE CustomerID IN
      (SELECT SOH.CustomerID
       FROM Sales.SalesOrderDetail as SOD
                JOIN
            Sales.SalesOrderHeader as SOH
            ON
                SOD.SalesOrderID = SOH.SalesOrderID
       WHERE EXISTS
                 (
                     SELECT _SOD.ProductID
                     FROM Sales.SalesOrderDetail AS _SOD
                              JOIN
                          Sales.SalesOrderHeader AS _SOH
                          ON
                              _SOD.SalesOrderID = _SOH.SalesOrderID
                     WHERE SOH.CustomerID = _SOH.CustomerID
                       AND SOD.ProductID = _SOD.ProductID
                       AND SOD.SalesOrderID != _SOD.SalesOrderID
                 ))

-- 8 Найти такой товар или товары, которые были куплены не более чем тремя
-- различными покупателями.
select distinct ProductID
from Sales.SalesOrderDetail
where ProductID in
      (select ProductID
       from Sales.SalesOrderDetail as sod
                join
            Sales.SalesOrderHeader as soh
            on sod.SalesOrderID = soh.SalesOrderID
       group by sod.ProductID
       having count(distinct soh.CustomerID) <= 3)

SELECT product.ProductID
FROM Production.Product as product
         INNER JOIN Sales.SalesOrderDetail as detail
                    ON product.ProductID = detail.ProductID
         INNER JOIN Sales.SalesOrderHeader as header
                    ON detail.SalesOrderID = header.SalesOrderID
WHERE header.CustomerID = ANY (SELECT CustomerID
                               FROM Sales.SalesOrderHeader
                               GROUP BY CustomerID
                               HAVING COUNT(CustomerId) <= 3)
GROUP BY product.ProductID

select distinct CustomerID
from Sales.SalesOrderHeader as soh
         join
     Sales.SalesOrderDetail as sod
     on soh.SalesOrderID = sod.SalesOrderID
where ProductID = 897

-- 9 Найти все товары, такие что их покупали всегда с товаром, цена которого
-- максимальна в своей категории.
select distinct ProductID
from Sales.SalesOrderDetail
where ProductID in
      (select ProductID
       from Sales.SalesOrderDetail)


select pc.ProductCategoryID, max(p.ListPrice)
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory as pc
              on ps.ProductCategoryID = pc.ProductCategoryID
group by pc.ProductCategoryID

-- 10 Найти номера тех покупателей, у которых есть как минимум два чека, и
-- каждый из этих чеков содержит как минимум три товара, каждый из которых как
-- минимум был куплен другими покупателями три раза.

select distinct CustomerID
from Sales.SalesOrderHeader as soh
where CustomerID in
      (select soh1.CustomerID
       from Sales.SalesOrderHeader as soh1
                join
            Sales.SalesOrderDetail as sod1
            on soh1.SalesOrderID = sod1.SalesOrderID
       where soh1.SalesOrderID in
             (select sod3.SalesOrderID
              from Sales.SalesOrderHeader as soh3
                       join Sales.SalesOrderDetail as sod3
                            on soh3.SalesOrderID = sod3.SalesOrderID
              where sod3.SalesOrderID in (select distinct sod2.SalesOrderID
                                          from Sales.SalesOrderDetail as sod2
                                                   join
                                               Sales.SalesOrderHeader as soh2
                                               on sod2.SalesOrderID = soh2.SalesOrderID
                                          group by sod2.SalesOrderID
                                          having count(sod2.SalesOrderID) >= 2)
                and exists(select count(*)
                           from Sales.SalesOrderDetail as sod4
                                    join Sales.SalesOrderHeader as soh4
                                         on sod4.SalesOrderID = soh4.SalesOrderID
                           where sod4.ProductID = sod3.ProductID
                           group by sod4.ProductID
                           having count(*) >= 3))
       group by soh1.CustomerID
       having count(distinct soh1.SalesOrderID) >= 2)
-- 11 Найти все чеки, в которых каждый товар был куплен дважды этим же
-- покупателем.

-- select count(*)
-- from Sales.SalesOrderDetail as sod
--          join
--      Sales.SalesOrderHeader as soh
--      on sod.SalesOrderID = soh.SalesOrderID
-- group by soh.CustomerID, soh.SalesOrderID, sod.ProductID
-- having sod.OrderQty > 1

-- 12 Найти товары, которые были куплены минимум три раза различными
-- покупателями.


select distinct ProductID
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID
group by ProductID
having count(distinct CustomerID) >= 3

-- 13 Найти такую подкатегорию или подкатегории товаров, которые содержат
-- более трех товаров, купленных более трех раз.
select p.ProductSubcategoryID
from Production.Product as p
where p.ProductID in (select distinct ProductID
                      from Sales.SalesOrderHeader as soh
                               join Sales.SalesOrderDetail as sod
                                    on soh.SalesOrderID = sod.SalesOrderID
                      group by sod.ProductID
                      having count([soh].CustomerID) >= 3)
group by p.ProductSubcategoryID
having count(distinct p.ProductID) >= 3

-- 14 Найти те товары, которые не были куплены более трех раз, и как минимум
-- дважды одним и тем же покупателем.

-- 1.найти название и айдишники продуктов, у которых цвет совпадает
-- с такими товарами цена на которые была меньше 5000
select p.Name, p.ProductID
from Production.Product as p
where p.Color in (select p1.Color
                  from Production.Product as p1
                  where p1.ListPrice < 5000)

-- 2.вывести на экран товары и ид у которых цвет совпадает с цветом самого
-- дорогого товара
select p.Name, p.ProductID
from Production.Product as p
where p.Color in (select top 1 p1.Color
                  from Production.Product as p1
                  order by p1.ListPrice desc)

-- SELECT Name, ProductID
-- FROM Production.Product
-- WHERE Color IN (
--     SELECT Color
--     FROM Production.Product
--     WHERE ListPrice = (
--         SELECT MAX(ListPrice)
--         FROM Production.Product
--     )
-- )


-- 3.Вывести названия товаров, чей цвет совпадает с цветом одного из товаров,
-- чья цена меньше 4000

select Name
from Production.Product as p
where p.Color in (select Color
                  from Production.Product as p1
                  where p1.ListPrice < 4000)

-- 4.найти название подкатегории где содержится самый дорогой товар с
-- красным цветом
select Name
from Production.ProductSubcategory as ps
where ps.ProductSubcategoryID = (select top 1 p.ProductSubcategoryID
                                 from Production.Product as p
                                 where p.Color = 'RED'
                                 order by p.ListPrice desc)

SELECT Name
FROM Production.ProductSubcategory
WHERE ProductSubcategoryID IN (SELECT ProductSubcategoryID
                               FROM Production.Product
                               WHERE Color = 'Red'
                                 AND ListPrice = (SELECT MAX(ListPrice)
                                                  FROM Production.Product
                                                  WHERE Color = 'Red'))

-- 5.Найти название категории с наибольшим количеством товаров (с
-- подзапросом)
select pc.Name
from Production.ProductCategory as pc
where pc.ProductCategoryID = (select ps.ProductCategoryID
                              from Production.ProductSubcategory as ps
                              where ps.ProductSubcategoryID = (select top 1 p.ProductSubcategoryID
                                                               from Production.Product as p
                                                               where p.ProductSubcategoryID is not null
                                                               group by p.ProductSubcategoryID
                                                               order by count(p.ProductID) desc))

-- SELECT Name
-- FROM Production.ProductCategory
-- WHERE ProductCategoryID IN (SELECT TOP 1 ProductCategoryID
--                             FROM Production.ProductSubcategory ps
--                                      JOIN Production.Product p
--                                           ON ps.ProductSubcategoryID = p.ProductSubcategoryID
--                             GROUP BY ProductCategoryID
--                             ORDER BY COUNT(*) DESC)
--
-- SELECT PC.Name
-- FROM Production.ProductCategory AS PC
-- WHERE PC.ProductCategoryID =
--       (SELECT PSC.ProductCategoryID
--        FROM Production.ProductSubCategory AS PSC
--        WHERE PSC.ProductSubcategoryID =
--              (SELECT TOP 1 P.ProductSubCategoryID
--               FROM Production.Product AS P
--               WHERE P.ProductSubcategoryID IS NOT NULL
--               GROUP BY P.ProductSubcategoryID
--               ORDER BY COUNT(*) DESC))

--6 Название товаров, чей цвет совпадает с товаром, чья цена больше 2000

SELECT Name
FROM Production.Product
WHERE Color IN (
    SELECT Color
    FROM Production.Product
    WHERE ListPrice > 2000
)

-- 7.Найти номер покупателя и самый дорогой купленный им товар для
-- каждого покупателя

select distinct CustomerID,
                (select top 1 sod1.ProductID
                 from Sales.SalesOrderDetail as sod1
                          join Sales.SalesOrderHeader as soh1
                               on sod1.SalesOrderID = soh1.SalesOrderID
                 where soh.CustomerID = soh1.CustomerID
                 order by sod1.UnitPrice desc)
from Sales.SalesOrderHeader as soh

-- SELECT DISTINCT soh.CustomerID,
--                 (SELECT TOP 1 sod.ProductId
--                  FROM Sales.SalesOrderDetail sod
--                  WHERE sod.UnitPrice = (SELECT MAX(d.UnitPrice)
--                                         FROM Sales.SalesOrderDetail d
--                                                  JOIN Sales.SalesOrderHeader h
--                                                       ON d.SalesOrderID = h.SalesOrderID
--                                         WHERE h.CustomerID = soh.CustomerID)) AS ExpensiveProduct
-- FROM Sales.SalesOrderHeader soh


-- 8.Самый дорогой товар красного цвета в каждой подкатегории
select ProductID
from Production.Product as p
where p.Color = 'RED'
  and p.ListPrice = (select max(ListPrice)
                     from Production.Product
                     where ProductSubcategoryID = p.ProductSubcategoryID)

-- 10.Найти номера чеков, таких что покупатели, к которым относятся эти чеки,
-- ходили в магазин более трех раз, т.е. имеют более трех чеков
select SalesOrderID
from Sales.SalesOrderHeader as soh
where soh.CustomerID in (select distinct CustomerID
                         from Sales.SalesOrderHeader as soh1
                         group by soh1.CustomerID
                         having count(distinct soh1.SalesOrderID) > 3)
-- SELECT SalesOrderID
-- FROM Sales.SalesOrderHeader
-- WHERE CustomerID IN (
--     SELECT CustomerID
--     FROM Sales.SalesOrderHeader
--     GROUP BY CustomerID
--     HAVING COUNT(*) > 3
-- )

-- 11.Найти номера категорий товаров, такие что в них товаров с красным цветом
-- больше, чем с черным. Решить с помощью подзапроса
select pc.Name
from Production.ProductCategory as pc
where pc.ProductCategoryID in (select pc1.ProductCategoryID
                               from Production.ProductCategory as pc1
                               where (select count(*)
                                      from Production.Product as p1
                                      where p1.Color = 'RED'
                                        and p1.ProductSubcategoryID in (select ps2.ProductSubcategoryID
                                                                        from Production.ProductSubcategory as ps2
                                                                        where ps2.ProductCategoryID = pc1.ProductCategoryID))
                                         >
                                     (select count(*)
                                      from Production.Product as p1
                                      where p1.Color = 'BLACK'
                                        and p1.ProductSubcategoryID in (select ps2.ProductSubcategoryID
                                                                        from Production.ProductSubcategory as ps2
                                                                        where ps2.ProductCategoryID = pc1.ProductCategoryID)))

SELECT pc.Name
FROM Production.ProductCategory as pc
WHERE (
    SELECT COUNT(product.ProductID)
    FROM Production.Product as product
    INNER JOIN Production.ProductSubcategory as subcategory
    ON product.ProductSubcategoryID = subcategory.ProductSubcategoryID
    WHERE product.Color = 'Red'AND pc.ProductCategoryID = subcategory.ProductCategoryID
    ) <
    (
    SELECT COUNT(product.ProductID)
    FROM Production.Product as product
    INNER JOIN Production.ProductSubcategory as subcategory
    ON product.ProductSubcategoryID = subcategory.ProductSubcategoryID
    WHERE product.Color = 'Black'AND pc.ProductCategoryID = subcategory.ProductCategoryID
    )
-- 12.Найти название категории самого продаваемого товара (по количеству чеков на которые он был продан)

select pc.Name
from Production.ProductCategory as pc
where ProductCategoryID =
      (select ProductCategoryID
       from Production.ProductSubcategory as ps
       where ps.ProductSubcategoryID = (select p3.ProductSubcategoryID
                                        from Production.Product as p3
                                        where p3.ProductID = (select top 1 sod.ProductID
                                                              from Sales.SalesOrderHeader as soh
                                                                       join Sales.SalesOrderDetail as sod
                                                                            on soh.SalesOrderID = sod.SalesOrderID
                                                              group by sod.ProductID
                                                              order by count(distinct sod.SalesOrderID) desc)))

-- Найти все товары, названия, которые куплены более трех раз, и которые имеют более трех покупателей
select p.Name
from Production.Product as p
where p.ProductID in (select sod.ProductID
                      from Sales.SalesOrderDetail as sod
                               join Sales.SalesOrderHeader as soh
                                    on sod.SalesOrderID = soh.SalesOrderID
                      group by sod.ProductID
                      having count(distinct sod.SalesOrderID) > 3
                         and count(distinct soh.CustomerID) > 3)

SELECT Name
FROM Production.Product
WHERE ProductID IN (SELECT ProductID
                    FROM Sales.SalesOrderDetail sod
                             JOIN Sales.SalesOrderHeader soh
                                  ON sod.SalesOrderID = soh.SalesOrderID
                    GROUP BY ProductID
                    HAVING COUNT(*) > 3
                       AND COUNT(DISTINCT soh.CustomerID) > 3)

-- 13) Найти название подкатегории с наибольшим количеством товаров (с подзапросом)

select ps.Name
from Production.ProductSubcategory as ps
where ps.ProductSubcategoryID = (select top 1 p.ProductSubcategoryID
                                 from Production.Product as p
                                 where p.ProductSubcategoryID is not null
                                 group by p.ProductSubcategoryID
                                 order by count(*) desc)

SELECT Name
FROM Production.ProductSubcategory
WHERE ProductSubcategoryID IN (SELECT TOP 1 ProductSubcategoryID
                               FROM Production.Product
                               WHERE ProductSubcategoryID IS NOT NULL
                               GROUP BY ProductSubcategoryID
                               ORDER BY COUNT(*) DESC)

-- 14) Найти название категорий, где есть минимум три товара красного цвета. Использовать подзапрос.
select Name
from Production.ProductCategory as pc
where pc.ProductCategoryID in (select pc.ProductCategoryID
                               from Production.ProductSubcategory as pc
                               where (select count(*)
                                      from Production.Product as p
                                      where Color = 'RED'
                                        and p.ProductSubcategoryID in (select ProductSubcategoryID
                                                                       from Production.ProductSubcategory as ps1
                                                                       where ps1.ProductCategoryID = pc.ProductCategoryID)) >
                                     3)
SELECT Name
FROM Production.ProductCategory
WHERE ProductCategoryID IN (SELECT ProductCategoryID
                            FROM Production.ProductSubcategory subcat
                                     JOIN Production.Product p
                                          ON subcat.ProductSubcategoryID = p.ProductSubcategoryID
                            WHERE p.Color = 'Red'
                            GROUP BY ProductCategoryID
                            HAVING COUNT(*) >= 3)

-- 15) Найти номера покупателей, покупавших товары минимум двух подкатегорий.
select distinct soh1.CustomerID
from Sales.SalesOrderHeader as soh1
where soh1.CustomerID in (select soh.CustomerID
                          from Sales.SalesOrderDetail as sod
                                   join Sales.SalesOrderHeader as soh
                                        on sod.SalesOrderID = soh.SalesOrderID
                                   join Production.Product as p
                                        on sod.ProductID = p.ProductID
                          group by soh.CustomerID
                          having count(distinct p.ProductSubcategoryID) > 1)


select distinct CustomerID
from Sales.SalesOrderHeader
where CustomerID in (select soh1.CustomerID
                     from Sales.SalesOrderHeader as SOH1
                              join Sales.SalesOrderDetail as SOD1
                                   on SOH1.SalesOrderID = SOD1.SalesOrderID
                              join Production.Product as SOD2
                                   on SOD1.ProductID = SOD2.ProductID
                     group by SOH1.CustomerID
                     having count(SOD2.ProductSubcategoryID) >= 2)
-- 16) Найти номер покупателя и чек с наибольшим количеством товаров (по наименованию) для каждого покупателя
select distinct soh.CustomerID,
                (select top 1 SalesOrderID
                 from Sales.SalesOrderDetail as sod
                 group by sod.SalesOrderID
                 order by count(*) desc)
from Sales.SalesOrderHeader as soh

SELECT soh.CustomerID, soh.SalesOrderID
FROM Sales.SalesOrderHeader soh
WHERE soh.SalesOrderID = (SELECT TOP 1 _soh.SalesOrderID
                          FROM Sales.SalesOrderHeader _soh
                                   JOIN Sales.SalesOrderDetail sod
                                        ON _soh.SalesOrderID = sod.SalesOrderID
                          WHERE _soh.CustomerID = soh.CustomerID
                          GROUP BY _soh.SalesOrderID
                          ORDER BY COUNT(*) DESC)


-- 17) Найти покупателей которые никогда не покупали один и тот же товар дважды
select soh.CustomerID
from Sales.SalesOrderDetail as sod
         join Sales.SalesOrderHeader as soh
              on sod.SalesOrderID = soh.SalesOrderID
group by soh.CustomerID
having count(distinct sod.ProductID) < 2

select distinct ssoh.CustomerID
from Sales.SalesOrderHeader as ssoh
where ssoh.CustomerID not in (select CustomerID
                              from Sales.SalesOrderHeader as soh
                                       join Sales.SalesOrderDetail as sod
                                            on sod.SalesOrderID = soh.SalesOrderID
                              where exists(
                                            select ProductID
                                            from Sales.SalesOrderDetail as sod1
                                                     join Sales.SalesOrderHeader as soh1
                                                          on sod1.SalesOrderID = soh1.SalesOrderID
                                            where soh1.CustomerID = soh.CustomerID
                                            group by ProductID
                                            having count(distinct ProductID) >= 2
                                        ))

