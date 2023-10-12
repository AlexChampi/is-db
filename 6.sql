SELECT SalesORDERID
     , ProductID
     , ORDERQty
     , SUM(ORDERQty)
           OVER (PARTITION BY SalesORDERID)             AS Total
     , AVG(ORDERQty) OVER (PARTITION BY SalesORDERID)   AS "Avg"
     , COUNT(ORDERQty) OVER (PARTITION BY SalesORDERID) AS "Count"
     , MIN(ORDERQty) OVER (PARTITION BY SalesORDERID)   AS "MIN"
     , MAX(ORDERQty) OVER (PARTITION BY SalesORDERID)   AS "Max"
FROM Sales.SalesORDERDetail
WHERE SalesORDERID IN (43659, 43664)

SELECT BusINessEntityID
     , TerritoryID
     , CONVERT(varchar(20), SalesYTD, 1)           AS SalesYTD
     , DATEPART(yy, ModifiedDate)                  AS SalesYear
     , CONVERT(varchar(20), SUM(SalesYTD) OVER (PARTITION BY TerritoryID
    ORDER BY DATEPART(yy, ModifiedDate)
    ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING ), 1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL
   OR TerritoryID < 5


SELECT Name,
       ListPrice,
       FIRST_VALUE(Product.Name) OVER (ORDER BY ListPrice ASC) AS LeAStExpensive
FROM Production.Product
WHERE ProductSubcategoryID = 37


-- 1 Найти долю затрат каждого покупателя на каждый купленный им продукт
-- среди общих его затрат в данной сети магазинов. Можно использовать
-- обобщенное табличное выражение

SELECT [SalesORDERID],
       p.[ProductID],
       [ProductSubcategoryID],
       [ORDERQty] * [UnitPrice],
       [ORDERQty] * [UnitPrice] / sum([ORDERQty] * [UnitPrice])
                                      OVER (partitiON BY [SalesORDERID]
                                          , [ProductSubcategoryID])
FROM [Sales].[SalesORDERDetail] AS SOD
         INner JOIN
     [Production].[Product] AS p
     ON SOD.ProductID = p.ProductID

-- Для одного выбранного покупателя вывести, для каждой покупки (чека),
-- разницу в деньгах между этой и следующей покупкой.
-- 3 Вывести следующую информацию: номер покупателя, номер чека этого
-- покупателя, отсортированные по покупателям, номерам чека (по возрастанию).
-- Третья колонка должна содержать в каждой своей строке сумму текущего чека
-- покупателя со всеми предыдущими чеками этого покупателя.

with tmp (cId, oId, s) as (select soh.CustomerID, sod.ProductID, sum(sod.OrderQty * sod.UnitPrice)
                           from Sales.SalesOrderDetail as sod
                                    join Sales.SalesOrderHeader as soh on sod.SalesOrderID = soh.SalesOrderID
                           group by soh.CustomerID, sod.ProductID)
select cId,
       oId,
       s,
       sum(s) over (partition by cId order by oId desc
           range between current row and unbounded following )
from tmp;


-- 1 Найти долю продаж каждого продукта (цена продукта * количество продукта),
-- на каждый чек, в денежном выражении.
with tmp(oId, pId, pr) as
         (select sod.SalesOrderID, ProductID, UnitPrice * OrderQty
          from Sales.SalesOrderDetail as sod)

select oId, pId, sum(pr) over ( partition by oId, pId)
from tmp;

SELECT Name,
       SalesOrderID,
       (SUM(OrderQty) OVER (PARTITION BY Name, SalesOrderID) * UnitPrice)
FROM Sales.SalesOrderDetail AS SSOD
         JOIN
     Production.Product AS PP
     ON
         SSOD.ProductID = PP.ProductID

-- 2 Вывести на экран список продуктов, их стоимость, а также разницу между
-- стоимостью этого продукта и стоимостью самого дешевого продукта в той же
-- подкатегории, к которой относится продукт.

select p.ProductID, p.StandardCost, p.StandardCost - min(StandardCost) over (partition by ProductSubcategoryID)
from Production.Product as p

-- 3 Вывести три колонки: номер покупателя, номер чека покупателя
-- (отсортированный по возрастанию даты чека) и искусственно введенный
-- порядковый номер текущего чека, начиная с 1, для каждого покупателя.

select soh.CustomerID, soh.SalesOrderID, ROW_NUMBER() over (partition by CustomerID order by OrderDate)
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID

-- 4 Вывести номера продуктов, таких что их цена выше средней цены продукта в
-- подкатегории, к которой относится продукт. Запрос реализовать двумя
-- способами. В одном из решений допускается использование обобщенного
-- табличного выражения.
with tem(oId, subId, pr, avP) as
         (select p.ProductID, ProductSubcategoryID, ListPrice, avg(ListPrice) over ( partition by ProductSubcategoryID)
          from Production.Product as p)
select *
from tem
where tem.pr > tem.avP;

WITH ProductsAndAvg (ProductID, StandardCost, ProductSubcategoryID, AvgCostSubcategory) AS
         (SELECT ProductID,
                 StandardCost,
                 ProductSubcategoryID,
                 (AVG(StandardCost) OVER (PARTITION BY ProductSubcategoryID))
          FROM Production.Product)
SELECT ProductID
FROM ProductsAndAvg
WHERE StandardCost > AvgCostSubcategory;


-- 5 Вывести на экран номер продукта, название продукта, а также информацию о
-- среднем количестве этого продукта, приходящихся на три последних по дате
-- чека, в которых был этот продукт.

--  Найти для каждого чека его номер, количество категорий и подкатегорий
with tmp(oId, subCatId, catId, scatC, catC) as
         (select sod.SalesOrderID,
                 p.ProductSubcategoryID,
                 ps.ProductCategoryID,
                 dense_rank() over (partition by SalesOrderID order by p.ProductSubcategoryID),
                 dense_rank() over (partition by SalesOrderID order by ps.ProductCategoryID)
          from Sales.SalesOrderDetail as sod
                   join Production.Product as p
                        on p.ProductID = sod.ProductID
                   join Production.ProductSubcategory as ps
                        on p.ProductSubcategoryID = ps.ProductSubcategoryID)
select oId, max(scatC), max(catId)
from tmp
group by oId
order by oId;

with z (orderid, subcat, c)
         as (SELECT sod.SalesOrderID,
                    DENSE_RANK() OVER (PARTITION BY SalesOrderID ORDER BY sc.ProductSubcategoryID) as subcat,
                    DENSE_RANK() OVER (PARTITION BY SalesOrderID ORDER BY cat.ProductCategoryID)   as c
             FROM Sales.SalesOrderDetail sod
                      join Production.Product p
                           on p.ProductID = sod.ProductID
                      join Production.ProductSubcategory sc
                           on p.ProductSubcategoryID = sc.ProductSubcategoryID
                      join Production.ProductCategory cat
                           on sc.ProductCategoryID = cat.ProductCategoryID)

SELECT distinct orderid,
                MAX(subcat) OVER (PARTITION BY orderid) as 'SubCategory amount',
                MAX(c) OVER (PARTITION BY orderid)      as 'Category amount'
FROM z
order by orderid


-- Название товара, название категории, к которой относится и общее кол-во товаров в категории (НЕ ПОВЫШ)
select p.Name, pc.Name, count(p.ProductID) over (partition by pc.ProductCategoryID)
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory as pc
              on ps.ProductCategoryID = pc.ProductCategoryID


-- Найти для каждого товара соотношения количества покупателей, купивших товар, к общему количеству покупателей, совершавших когда-либо покупки!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

select distinct sod.ProductID,
                count(soh.CustomerID) over ( partition by ProductID) * 1.0 /
                (select count(distinct sod1.CustomerID) from Sales.SalesOrderHeader as sod1)
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID;

-- Вывести на экран, для каждого продукта, количество его продаж, и соотношение числа покупателей этого продукта, !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- к числу покупателей, купивших товары из категории, к которой относится данный товар
select sod.ProductID, soh.CustomerID, soh.SalesOrderID
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID
order by sod.ProductID

select sod.ProductID, count(distinct sod.SalesOrderID), count(distinct soh.CustomerID)
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID
group by sod.ProductID
having count(distinct sod.SalesOrderID) != count(distinct soh.CustomerID)
order by sod.ProductID
-- Вывести на экран следующую информацию: название товара, название подкатегории к которой он относится и общее количество товаров в этой подкатегории
select p.Name, ps.Name, count(p.ProductID) over ( partition by ps.ProductSubcategoryID)
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID

-- Вывести на экран следующую информацию: название товара, название категории к которой он относится и общее количество товаров в этой категории
select p.Name, pc.Name, count(p.ProductID) over ( partition by pc.ProductCategoryID)
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID

-- Найти для каждого покупателя все чеки, и для каждого чека вывести информацию: номер покупателя, номер чека, и сумма всех затрат этого покупателя с момента первой покупки и до данного чека
select soh.CustomerID,
       sod.SalesOrderID,
       sum(OrderQty * UnitPrice) over ( partition by CustomerID order by OrderDate ),
       sum(OrderQty * UnitPrice) over ( partition by CustomerID, sod.SalesOrderID order by OrderDate ),
       sum(OrderQty * UnitPrice)
           over ( partition by CustomerID order by OrderDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID
order by soh.CustomerID;

SELECT SalesOrderId,
       CustomerId,
       SUM(SubTotal)
           OVER (
               PARTITION BY CustomerId
               ORDER BY OrderDate ASC ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
               )
FROM Sales.SalesOrderHeader;

-- Вывести на экран для каждого продукта количество его продаж, и соотношение
-- числа покупателей этого продукта, к числу покупателей, купивших товары из категории, к которой относится данный товар с использованием OVER.
with tmp(pId, cCnt, sCnt) as
         (select sod.ProductID, count(soh.CustomerID), count(soh.SalesOrderID)
          from Sales.SalesOrderDetail as sod
                   join Sales.SalesOrderHeader as soh
                        on sod.SalesOrderID = soh.SalesOrderID
          group by sod.ProductID),
     tmp2(pcId, cnt) as
         (select distinct ps.ProductCategoryID, count(soh.CustomerID) over ( partition by ps.ProductCategoryID)
          from Sales.SalesOrderHeader as soh
                   join Sales.SalesOrderDetail as sod
                        on soh.SalesOrderID = sod.SalesOrderID
                   join Production.Product as p
                        on p.ProductID = sod.ProductID
                   join Production.ProductSubcategory as ps
                        on ps.ProductSubcategoryID = p.ProductSubcategoryID)
select distinct p.ProductID,
                t.sCnt,
                t.sCnt * 1.0 / t2.cnt
from tmp as t
         join Production.Product as p
              on p.ProductID = t.pId
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join tmp2 as t2
              on t2.pcId = ps.ProductCategoryID;

select ps.ProductCategoryID, count(CustomerID)
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID
         join Production.Product as p
              on p.ProductID = sod.ProductID
         join Production.ProductSubcategory as ps
              on ps.ProductSubcategoryID = p.ProductSubcategoryID
group by ps.ProductCategoryID;

with tmp(ProductID, CustomerID, CategoryID)
         as
         (select distinct p.ProductID, soh.CustomerID, psc.ProductCategoryID
          from [Production].[Product] as p
                   join [Sales].[SalesOrderDetail] as sod
                        on p.ProductID = sod.ProductID
                   join [Sales].[SalesOrderHeader] as soh
                        on sod.SalesOrderID = soh.SalesOrderID
                   join [Production].[ProductSubcategory] as psc
                        on p.ProductSubcategoryID = psc.ProductSubcategoryID)
select distinct tmp.ProductID,
                (select count(distinct sod.SalesOrderID)
                 from [Sales].[SalesOrderDetail] as sod
                 where sod.ProductID = tmp.ProductID) as total,
                count(tmp.CustomerID) over (partition by tmp.ProductID) * 1.0 /
                (select count(distinct soh.CustomerID)
                 from [Production].[Product] as p
                          join [Sales].[SalesOrderDetail] as sod
                               on p.ProductID = sod.ProductID
                          join [Sales].[SalesOrderHeader] as soh
                               on sod.SalesOrderID = soh.SalesOrderID
                          join [Production].[ProductSubcategory] as psc
                               on p.ProductSubcategoryID = psc.ProductSubcategoryID
                 where psc.ProductCategoryID = tmp.CategoryID)
from tmp;


-- Для каждого покупателя соотношение количества купленных им товаров из каждой категории
-- к количеству не купленных им товаров из той же категории (через Over)
with tmp(a, b) as
         (select distinct ps.ProductCategoryID, count(p.ProductID) over ( partition by ps.ProductCategoryID)
          from Production.Product as p
                   join Production.ProductSubcategory as ps
                        on p.ProductSubcategoryID = ps.ProductSubcategoryID)
select soh.CustomerID, t.a, count(distinct p.ProductID) * 1.0 / t.b
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID
         join Production.Product as p
              on p.ProductID = sod.ProductID
         join Production.ProductSubcategory as ps
              on ps.ProductSubcategoryID = p.ProductSubcategoryID
         join tmp as t
              on t.a = ps.ProductCategoryID
group by soh.CustomerID, t.a, t.b
order by soh.CustomerID, t.a;

select distinct soh.CustomerID,
                ps.ProductCategoryID,
                count(sod.ProductID) over ( partition by soh.CustomerID, ps.ProductCategoryID),
                count(sod.ProductID) over ( partition by ps.ProductCategoryID)
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID
         join Production.Product as p
              on p.ProductID = sod.ProductID
         join Production.ProductSubcategory as ps
              on ps.ProductSubcategoryID = p.ProductSubcategoryID
order by soh.CustomerID, ps.ProductCategoryID;

select distinct ps.ProductCategoryID, count(p.ProductID) over ( partition by ps.ProductCategoryID)
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID

select distinct ps.ProductCategoryID, count(p.ProductID)
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
group by ps.ProductCategoryID;


with res1 (ProductCategoryID, Number) as
         (select psc.ProductCategoryID, count(distinct p.ProductID)
          from Production.Product as p
                   inner join
               Production.ProductSubcategory as psc
               on p.ProductSubcategoryID = psc.ProductSubcategoryID
          group by ProductCategoryID),
     res2 (CustomerID, ProductCategoryID, Number) as
         (select soh.CustomerID,
                 psc.ProductCategoryID,
                 DENSE_RANK() over (partition by soh.CustomerID, psc.ProductCategoryID order by p.ProductID) as Number
          from Sales.SalesOrderDetail as sod
                   join Sales.SalesOrderHeader as soh
                        on sod.SalesOrderID = soh.SalesOrderID
                   join Production.Product as p
                        on p.ProductID = sod.ProductID
                   join Production.ProductSubcategory as psc
                        on psc.ProductSubcategoryID = p.ProductSubcategoryID),
     res3 (CustomerID, ProductCategoryID, Number) as
         (select CustomerID, ProductCategoryID, Max(Number)
          from res2
          group by CustomerID, ProductCategoryID)
select r3.CustomerID, r1.ProductCategoryID, 1.0 * r3.Number / (r1.Number - r3.Number)
from res1 as r1
         inner join
     res3 as r3
     on r1.ProductCategoryID = r3.ProductCategoryID
order by CustomerID

