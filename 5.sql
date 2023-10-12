-- 1 Найти покупателя, который каждый раз имел разный список товаров в чеке (по
-- номенклатуре)
SELECT tmp.c
FROM (SELECT soh.CustomerID              AS c
           , soh.SalesORDERID            AS o
           , CHECKSUM_AGG(sod.ProductID) AS ch
      FROM [Sales].[SalesORDERDetail] AS sod
               JOIN
           [Sales].[SalesORDERHeader] AS soh
           ON sod.SalesORDERID = soh.SalesORDERID
      GROUP BY soh.CustomerID, soh.SalesORDERID) tmp
GROUP BY tmp.c
HAVING count(tmp.ch) = count(DISTINCT tmp.ch)
   AND count(tmp.ch) > 1

-- 2 Найти пары таких покупателей, что список названий товаров, которые они
-- когда-либо покупали, не пересекается ни в одной позиции.

SELECT distinct top 3 t1.c, t2.c
FROM (SELECT soh.CustomerID AS c,
             sod.ProductID  AS p
      FROM [Sales].[SalesORDERDetail] AS sod
               JOIN
           [Sales].[SalesORDERHeader] AS soh
           ON sod.SalesORDERID = soh.SalesORDERID) t1,
     (SELECT soh.CustomerID AS c,
             sod.ProductID  AS p
      FROM [Sales].[SalesORDERDetail] AS sod
               JOIN
           [Sales].[SalesORDERHeader] AS soh
           ON sod.SalesORDERID = soh.SalesORDERID) t2
WHERE t1.p != all (SELECT sod.ProductID AS p
                   FROM [Sales].[SalesORDERDetail] AS sod
                            JOIN
                        [Sales].[SalesORDERHeader] AS soh
                        ON sod.SalesORDERID = soh.SalesORDERID
                   WHERE soh.CustomerID = t2.c)


-- 3 Вывести номера продуктов, таких, что их цена выше средней цены продукта в
-- подкатегории, к которой относится продукт. Запрос реализовать двумя
-- способами. В одном из решений допускается использование обобщенного
-- табличного выражения.

select p.ProductID
from Production.Product as p
where p.ListPrice > (select avg(p1.ListPrice)
                     from Production.Product as p1
                     where p1.ProductSubcategoryID = p.ProductSubcategoryID)

with tmp (pscid, acgLP) AS
         (SELECT p.ProductSubcategoryID, avg([ListPrice])
          FROM [Production].[Product] AS p
          GROUP BY p.ProductSubcategoryID)
SELECT p.ProductID
FROM [Production].[Product] AS p
         JOIN
     tmp ON p.ProductSubcategoryID = tmp.pscid
WHERE [ListPrice] > tmp.acgLP

-- 1 Найти среднее количество покупок на чек для каждого покупателя (2 способа).
with orderCount (c, s, p) as
         (select soh.CustomerID, soh.SalesOrderID, count(sod.ProductID)
          from Sales.SalesOrderHeader as soh
                   join Sales.SalesOrderDetail as sod
                        on soh.SalesOrderID = sod.SalesOrderID
          group by soh.CustomerID, soh.SalesOrderID)
select c, avg(p), sum(p) / sum(s)
from orderCount
group by c;
-- 2 Найти для каждого продукта и каждого покупателя соотношение количества
-- фактов покупки данного товара данным покупателем к общему количеству
-- фактов покупки товаров данным покупателем

WITH totalOrder (c, cnt) as
         (select CustomerID, count(*)
          from Sales.SalesOrderHeader as soh
                   join Sales.SalesOrderDetail as sod
                        on soh.SalesOrderID = sod.SalesOrderID
          group by CustomerID),
     productCount (c, p, cnt) as
         (select soh.CustomerID, sod.ProductID, count(*)
          from Sales.SalesOrderDetail as sod
                   join Sales.SalesOrderHeader as soh
                        on sod.SalesOrderID = soh.SalesOrderID
          group by soh.CustomerID, sod.ProductID)
select CAST(productCount.cnt as decimal) / cast(totalOrder.cnt as decimal)
from totalOrder
         join productCount
              on totalOrder.c = productCount.c;

WITH ProductsByPerson(CustomerID, ProductId, OrdersCount)
         AS (SELECT soh.CustomerID, sod.ProductId, COUNT(1) as OrdersCount
             FROM [Sales].[SalesOrderHeader] soh
                      JOIN [Sales].[SalesOrderDetail] sod
                           ON soh.SalesOrderId = sod.SalesOrderId
             GROUP BY soh.CustomerID, sod.ProductId),
     TotalOrdersByPerson(CustomerID, TotalOrders) AS (SELECT CustomerID, COUNT(1) as TotalOrders
                                                      FROM [Sales].[SalesOrderHeader] soh
                                                      GROUP BY CustomerID)
SELECT CAST(OrdersCount as decimal) / CAST(TotalOrders as decimal) as O
FROM ProductsByPerson
         JOIN TotalOrdersByPerson
              ON ProductsByPerson.CustomerID = TotalOrdersByPerson.CustomerID;


-- 3 Вывести на экран следящую информацию: Название продукта, Общее
-- количество фактов покупки этого продукта, Общее количество покупателей
-- этого продукта
with productInfo (p, cnt)
         as (select sod.ProductID, count(soh.CustomerID)
             from Sales.SalesOrderHeader as soh
                      join Sales.SalesOrderDetail as sod
                           on soh.SalesOrderID = sod.SalesOrderID
             group by soh.CustomerID, sod.ProductID)
select pi.p, p.Name, count(*), sum(pi.cnt)
from productInfo as pi
         join Production.Product as p
              on pi.p = p.ProductID
group by pi.p, p.Name;


WITH ProductsByPerson(CustomerID, ProductId, OrdersCount)
         AS (SELECT soh.CustomerID, sod.ProductId, COUNT(1) as OrdersCount
             FROM [Sales].[SalesOrderHeader] soh
                      JOIN [Sales].[SalesOrderDetail] sod
                           ON soh.SalesOrderId = sod.SalesOrderId
             GROUP BY soh.CustomerID, sod.ProductId)
SELECT p.Name,
       COUNT(1)         as CustomerCount,
       SUM(OrdersCount) as OrdersCount
FROM ProductsByPerson pbp
         JOIN [Production].[Product] P
              ON pbp.ProductId = p.ProductID
GROUP BY pbp.ProductId, p.Name
ORDER BY 3 DESC;


-- 4 Вывести для каждого покупателя информацию о максимальной и минимальной
-- стоимости одной покупки, чеке, в виде таблицы: номер покупателя,
-- максимальная сумма, минимальная сумма.
with personInfo (customerId, productId)
         as (select soh.CustomerID, sod.ProductID
             from Sales.SalesOrderHeader as soh
                      join Sales.SalesOrderDetail as sod
                           on soh.SalesOrderID = sod.SalesOrderID
             group by soh.CustomerID, sod.ProductID)
select pi.customerId, max(p.ListPrice) as "max", min(p.ListPrice) as "min"
from personInfo as pi
         join Production.Product as p
              on pi.productId = p.ProductID
group by pi.customerId
order by 1;

WITH ProductsByPerson(CustomerID, ProductId, OrdersCount)
         AS (SELECT soh.CustomerID, sod.ProductId, COUNT(1) as OrdersCount
             FROM [Sales].[SalesOrderHeader] soh
                      JOIN [Sales].[SalesOrderDetail] sod
                           ON soh.SalesOrderId = sod.SalesOrderId
             GROUP BY soh.CustomerID, sod.ProductId)
SELECT PP.CustomerID, MIN(P.ListPrice) AS 'MIN', MAX(P.ListPrice) AS 'MAX'
FROM Production.Product AS P
         JOIN ProductsByPerson AS PP ON P.ProductID = PP.ProductId
GROUP BY PP.CustomerID
order by 1;


-- 5 Найти номера покупателей, у которых не было нет ни одной пары чеков с
-- одинаковым количеством наименований товаров.
with cousotmerSales (c, s, cnt)
         as (select soh.CustomerID, soh.SalesOrderID, count(*)
             from Sales.SalesOrderHeader as soh
                      join Sales.SalesOrderDetail as sod
                           on soh.SalesOrderID = sod.SalesOrderID
             group by soh.CustomerID, soh.SalesOrderID)
select distinct cs1.c
from cousotmerSales as cs1
where cs1.c in (select cs2.c
                from cousotmerSales as cs2
                where cs1.c = cs2.c
                  and cs1.s != cs2.s
                  and cs1.cnt != cs2.cnt);

WITH Orders(CustomerID, SalesOrderID, ProductName) AS (SELECT soh.CustomerID, soh.SalesOrderID, p.Name as ProductName
                                                       FROM [Sales].[SalesOrderHeader] soh
                                                                JOIN [Sales].[SalesOrderDetail] sod
                                                                     ON soh.SalesOrderId = sod.SalesOrderId
                                                                JOIN [Production].[Product] p
                                                                     ON p.ProductID = sod.ProductID),
     Customers(CustomerID) AS (SELECT DISTINCT CustomerID
                               FROM [Sales].[SalesOrderHeader])
SELECT CustomerID
FROM Customers
WHERE CustomerID NOT IN (SELECT DISTINCT o1.CustomerID
                         FROM Orders o1
                                  JOIN Orders o2
                                       ON o1.CustomerID = o2.CustomerID
                                           AND o1.SalesOrderID <> o2.SalesOrderID
                                           AND o1.ProductName = o2.ProductName)

-- 6 Найти номера покупателей, у которых все купленные ими товары были
-- куплены как минимум дважды, т.е. на два разных чека.

with orders(c, s, p)
         as (select soh.CustomerID, sod.SalesOrderID, sod.ProductID
             from Sales.SalesOrderHeader as soh
                      join Sales.SalesOrderDetail as sod
                           on soh.SalesOrderID = sod.SalesOrderID)
select distinct o.c
from orders as o
group by o.c, o.p
having count(*) >= 2

-- Вывести на экран, для каждого продукта, количество его продаж,
-- и соотношение числа покупателей этого продукта, к числу покупателей, купивших товары из категории,
-- к которой относится данный товар (2 запроса)

with productProductiCatCnt (pid, pcid, cnt) as
         (select sod.ProductID, ps.ProductCategoryID, count(*)
          from Sales.SalesOrderDetail as sod
                   join Production.Product as p
                        on sod.ProductID = p.ProductID
                   join Production.ProductSubcategory as ps
                        on p.ProductSubcategoryID = ps.ProductSubcategoryID
          group by sod.ProductID, ps.ProductCategoryID),
     productCatCnt (pcid, cnt) as
         (select ps.ProductCategoryID, count(*)
          from Sales.SalesOrderDetail as sod
                   join Production.Product as p
                        on sod.ProductID = p.ProductID
                   join Production.ProductSubcategory as ps
                        on p.ProductSubcategoryID = ps.ProductSubcategoryID
          group by ps.ProductCategoryID)
select p1.pid, cast(p1.cnt as decimal) / cast(p2.cnt as decimal), p1.cnt, p2.cnt
from productProductiCatCnt as p1
         join productCatCnt as p2
              on p1.pcid = p2.pcid;

select p1.ProductID, p1.c1, p10.c3 / p2.c2
from (select p4.ProductID, p8.ProductCategoryID, count(*) as c1
      from Sales.SalesOrderHeader as p3
               join
           Sales.SalesOrderDetail as p4
           on p3.SalesOrderID = p4.SalesOrderID
               join
           Production.Product as p7
           on p4.ProductID = p7.ProductID
               join
           Production.ProductSubcategory as p8
           on p7.ProductSubcategoryID = p8.ProductSubcategoryID
      group by p4.ProductID, p8.ProductCategoryID) as p1
         join
     (select p6.ProductID, count(distinct p5.CustomerID) as c2
      from Sales.SalesOrderHeader as p5
               join
           Sales.SalesOrderDetail as p6
           on p5.SalesOrderID = p6.SalesOrderID
      group by p6.ProductID) as p2
     on p1.ProductID = p2.ProductID
         join
     (select p8.ProductCategoryID, count(distinct p5.CustomerID) as c3
      from Sales.SalesOrderHeader as p5
               join
           Sales.SalesOrderDetail as p6
           on p5.SalesOrderID = p6.SalesOrderID
               join
           Production.Product as p7
           on p6.ProductID = p7.ProductID
               join
           Production.ProductSubcategory as p8
           on p7.ProductSubcategoryID = p8.ProductSubcategoryID
      group by p8.ProductCategoryID) as p10
     on p1.ProductCategoryID = p10.ProductCategoryID

-- Найти для каждого покупателя количество чеков, где присутствуют товары минимум из двух подкатегорий товаров
select distinct soh.CustomerID, count(soh.SalesOrderID)
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID
         join Production.Product as p
              on sod.ProductID = p.ProductID
group by soh.CustomerID, soh.SalesOrderID
having count(distinct p.ProductSubcategoryID) >= 2

with sale(id) as
         (select sod.SalesOrderID
          from Sales.SalesOrderDetail as sod
                   join Production.Product as p
                        on sod.ProductID = p.ProductID
          group by sod.SalesOrderID
          having count(p.ProductSubcategoryID) > 1)
select soh.CustomerID, count(*)
from Sales.SalesOrderHeader as soh
         join sale as s
              on soh.SalesOrderID = s.id
group by soh.CustomerID;

with SSales(SaleID) as
         (Select SalesOrderID
          From Sales.SalesOrderDetail as SOD
                   join Production.Product as PP on SOD.ProductID = PP.ProductID
          Group by SalesOrderID
          Having count(DISTINCT PP.ProductSubcategoryID) > 1)
Select SOH.CustomerID, count(*)
From Sales.SalesOrderHeader as SOH
         join SSales as s on SOH.SalesOrderID = s.SaleID
group by CustomerID;


with t1(Productid, ProductSubcatID) as
         (select p.ProductID, psc.ProductSubcategoryID
          from Production.Product as p
                   join Production.ProductSubcategory as psc
                        on p.ProductSubcategoryID = psc.ProductSubcategoryID),
     T(SalesOrder, Subcat) as
         (select sod.SalesOrderID, t1.ProductSubcatID
          from Sales.SalesOrderDetail as sod
                   join t1
                        on sod.ProductID = t1.Productid)
select soh.CustomerID, count(soh.SalesOrderID) as "Count"
from Sales.SalesOrderHeader as soh
where soh.SalesOrderID in
      (select A.SalesOrder
       from T as A
                join T as B
                     on A.SalesOrder = B.SalesOrder
       group by A.SalesOrder
       having count(A.Subcat) >= 2)
group by soh.CustomerID;


with t1(Productid, ProductSubcatID) as
         (select p.ProductID, psc.ProductSubcategoryID
          from Production.Product as p
                   join Production.ProductSubcategory as psc
                        on p.ProductSubcategoryID = psc.ProductSubcategoryID),
     T(SalesOrder, Subcat) as
         (select sod.SalesOrderID, t1.ProductSubcatID
          from Sales.SalesOrderDetail as sod
                   join t1
                        on sod.ProductID = t1.Productid)
select soh.CustomerID, count(soh.SalesOrderID) as "Count"
from Sales.SalesOrderHeader as soh
where soh.SalesOrderID in
      (select A.SalesOrder
       from T as A
                join T as B
                     on A.SalesOrder = B.SalesOrder
       where A.Subcat != B.Subcat
       group by A.SalesOrder)
group by soh.CustomerID;

-- Вывести на экран следующую информацию:
-- название товара, название категории к которой он относится и общее количество товаров в этой категории
with catCount(categoryId, name, cnt) as
         (select pc.ProductCategoryID, pc.Name, count(distinct p.ProductID)
          from Production.Product as p
                   join Production.ProductSubcategory as ps
                        on p.ProductSubcategoryID = ps.ProductSubcategoryID
                   join Production.ProductCategory as pc
                        on ps.ProductCategoryID = pc.ProductCategoryID
          group by pc.ProductCategoryID, pc.Name)
select p.Name, c.name, c.cnt
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join catCount as c
              on c.categoryId = ps.ProductCategoryID;

select pc.ProductCategoryID, pc.Name, count(distinct p.ProductID)
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory as pc
              on ps.ProductCategoryID = pc.ProductCategoryID
group by pc.ProductCategoryID, pc.Name;

WITH Category(ProductCategoryID, Cnt) AS
         (SELECT s.ProductCategoryID as ProductCategoryID,
                 COUNT(*)            AS Cnt
          FROM Production.ProductSubcategory AS s
                   JOIN
               Production.Product AS p
               ON
                   s.ProductSubcategoryID = p.ProductSubcategoryID
          GROUP BY s.ProductCategoryID)

SELECT p.Name,
       c.Name,
       Category.Cnt as [Category products count]
FROM Production.Product AS p
         JOIN
     Production.ProductSubcategory AS s
     ON
         p.ProductSubcategoryID = s.ProductSubcategoryID
         JOIN
     Production.ProductCategory AS c
     ON
         s.ProductCategoryID = c.ProductCategoryID
         JOIN
     Category
     ON
         c.ProductCategoryID = Category.ProductCategoryID

-- Вывести на экран название товара, название подкатегории к которой он относится и общее количество товаров в этой подкатегории
with subcategoryCnt(subCatId, subCatName, cnt) as
         (select ps.ProductSubcategoryID, ps.Name, count(*)
          from Production.Product as p
                   join Production.ProductSubcategory as ps
                        on p.ProductSubcategoryID = ps.ProductSubcategoryID
          group by ps.ProductSubcategoryID, ps.Name)
select p.Name, s.subCatName, s.cnt
from Production.Product as p
         join subcategoryCnt as s
              on p.ProductSubcategoryID = s.subCatId;

with t1 (cid, cn, cnt)
         as
         (select psc.ProductSubcategoryID, psc.Name, count(distinct p.ProductID)

          from Production.Product as p
                   join Production.ProductSubcategory as psc
                        on
                            p.ProductSubcategoryID = psc.ProductSubcategoryID
          group by psc.ProductSubcategoryID, psc.Name)
select p.Name, t1.cn, cnt
from Production.Product as p
         join t1 on p.ProductSubcategoryID = t1.cid;

-- Найти для каждого чека его номер, количество категорий и подкатегорий, товары из которых есть в чеке
with productiSubCatAndCat(pId, subCatId, catId)
         as (select p.ProductID, ps.ProductSubcategoryID, pc.ProductCategoryID
             from Production.Product as p
                      join Production.ProductSubcategory as ps
                           on p.ProductSubcategoryID = ps.ProductSubcategoryID
                      join Production.ProductCategory as pc
                           on ps.ProductCategoryID = pc.ProductCategoryID)
select sod.SalesOrderID, count(distinct p.subCatId) as "subcat", count(distinct p.catId) as "catId"
from Sales.SalesOrderDetail as sod
         join productiSubCatAndCat as p
              on sod.ProductID = p.pId
group by sod.SalesOrderID;

with sub_ctgr (SalesOrderID, ProductSubcategoryID)
         as
         (select sod.SalesOrderID, ProductSubcategoryID
          from Sales.SalesOrderDetail as sod
                   join
               Production.Product as P
               on
                   sod.ProductID = P.ProductID),

     sub_ctgr_count(SalesOrderID, cnt)
         as
         (select SalesOrderID, count(distinct ProductSubcategoryID) as 'cnt'
          from sub_ctgr
          group by SalesOrderID),

     ctgr_count (SalesOrderID, cnt)
         as
         (select SalesOrderID, count(distinct ProductCategoryID)
          from sub_ctgr
                   join
               Production.ProductSubCategory as PS
               on
                   PS.ProductSubcategoryID = sub_ctgr.ProductSubcategoryID
          group by SalesOrderID)

select sc.SalesOrderID, sc.cnt, cc.cnt
from sub_ctgr_count as sc
         join
     ctgr_count as cc
     on
         cc.SalesOrderID = sc.SalesOrderID;

-- Вывести на экран для каждого продукта название, кол-во его продаж, общее число покупателей этого продукта,
-- название подкатегории, к которой данный продукт относится
with productSales(pId, saleCnt, costumerCnt) as
         (select sod.ProductID, count(sod.SalesOrderID), count(distinct soh.CustomerID)
          from Sales.SalesOrderDetail as sod
                   join Sales.SalesOrderHeader as soh
                        on sod.SalesOrderID = soh.SalesOrderID
          group by sod.ProductID)
select p.ProductID, p.Name, pSales.saleCnt, pSales.costumerCnt, ps.Name
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join productSales as pSales
              on p.ProductID = pSales.pId;

WITH tmp1 (ProductId, CustomerCnt, OrderCnt) as (SELECT pp.ProductID,
                                                        COUNT(ssoh.CustomerID) as CustomerCnt,
                                                        SUM(OrderQty)          as OrderCnt
                                                 FROM Production.Product as pp
                                                          JOIN Sales.SalesOrderDetail as ssod
                                                               ON pp.ProductID = ssod.ProductID
                                                          JOIN Sales.SalesOrderHeader as ssoh
                                                               ON ssod.SalesOrderID = ssoh.SalesOrderID
                                                 GROUP BY pp.ProductID)

SELECT pp.ProductID, pp.Name, tmp1.OrderCnt, tmp1.CustomerCnt, pps.ProductSubcategoryID
FROM Production.Product as pp
         JOIN Production.ProductSubcategory as pps
              ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
         JOIN tmp1
              ON pp.ProductID = tmp1.ProductId;


-- Вывести на экран имена покупателей(ФИО), кол-во купленных ими товаров, и кол-во чеков, которые у них были

WITH t1 (id, cnt) AS (SELECT soh.CustomerID, COUNT(*)
                      FROM Sales.SalesOrderHeader AS soh
                      GROUP BY soh.CustomerID),
     t2 (id, cnt) AS (SELECT soh.CustomerID, COUNT(*)
                      FROM Sales.SalesOrderHeader AS soh
                               JOIN Sales.SalesOrderDetail AS sod
                                    ON soh.SalesOrderID = sod.SalesOrderID
                      GROUP BY soh.CustomerID)
SELECT p.FirstName, p.LastName, t1.cnt, t2.cnt
FROM Sales.Customer AS c
         JOIN Person.Person AS p
              ON c.PersonID = p.BusinessEntityID
         JOIN t1
              ON t1.id = c.CustomerID
         JOIN t2
              ON t2.id = c.CustomerID


-- Название товара, название подкатегории, общее кол-во товаров в подкатегории общее кол-во товаров того же цвета


-- Вывести на экран следующую информацию: название товара,
-- название подкатегории к которой он относится и общее количество товаров в этой подкатегории, общее количество товаров того же цвета

with colorCount(color, cnt) as
         (select p.Color, count(p.ProductID)
          from Production.Product as p
          where p.Color is not null
          group by p.Color),
     subCatCount(subCatId, cnt) as
         (select p.ProductSubcategoryID, count(p.ProductID)
          from Production.Product as p
          where p.ProductSubcategoryID is not null
          group by p.ProductSubcategoryID)
select p.Name,
       ps.Name,
       (select s.cnt from subCatCount as s where s.subCatId = ps.ProductSubcategoryID),
       (select s.cnt from colorCount as s where p.Color = s.color)
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
where p.Color is not null;

WITH t (subID, cnt) AS (SELECT p1.ProductSubcategoryID, COUNT(*)
                        FROM Production.Product AS p1
                        GROUP BY p1.ProductSubcategoryID),
     t2 (color, cnt) AS (SELECT p1.Color, COUNT(*)
                         FROM Production.Product AS p1
                         GROUP BY p1.Color)
SELECT p.Name, sub.Name, t.cnt, t2.cnt
FROM Production.Product AS p
         JOIN t
              ON p.ProductSubcategoryID = t.subID
         JOIN t2
              ON p.Color = t2.color
         JOIN Production.ProductSubcategory AS sub
              ON p.ProductSubcategoryID = sub.ProductSubcategoryID


-- Вывести на экран следующую информацию:
-- название товара, название подкатегории к которой он относится и общее количество товаров в этой подкатегории


-- Найти для каждого чека количество категорий и подкатегорий товаров, которые встречаются в этом чеке


-- Найти номера покупателей, которые покупали товары из более чем половины подкатегорий товаров,
-- и для них вывести информацию: номер покупателя, количество чеков, средняя сумма на один чек


-- Найти для каждого чека вывести его номер, количество категорий и подкатегорий, товары из которых есть в чеке


-- Найти для каждого товара соотношение количества покупателей купивших товар к
-- общему количеству покупателей совершавших когда-либо покупки


-- Вывести на экран следующую информацию: название товара, название категории к которой он относится,
-- общее количество товаров в этой категории количество покупателей данного товара.


-- Номера покупателей, кол-во категорий товаров которые их купили больше половины
-- и для них вывести количество чеков, номер покупателя и сумму чека.

-- Найти для каждого товара соотношение количества покупателей купивших товар к общему
-- количеству покупателей совершавших когда-либо покупки


-- Найти номера покупателей, которые покупали товары из более чем половины подкатегорий товаров,
-- и для них вывести информацию: номер покупателя, количество чеков, средняя сумма на один чек.

with subcategoryCounter(cnt) as (select count(ps.ProductSubcategoryID)
                                 from Production.ProductSubcategory as ps),
     customerSubCatCounter(cId, cnt) as
         (select soh.CustomerID, count(distinct p.ProductSubcategoryID)
          from Sales.SalesOrderHeader as soh
                   join Sales.SalesOrderDetail as sod
                        on soh.SalesOrderID = sod.SalesOrderID
                   join Production.Product as p
                        on sod.ProductID = p.ProductID
          group by soh.CustomerID),
     customerInfo(cId, salesCnt, avgSum) as
         (select soh.CustomerID, count(soh.SalesOrderID), avg(p.ListPrice)
          from Sales.SalesOrderHeader as soh
                   join Sales.SalesOrderDetail as sod
                        on soh.SalesOrderID = sod.SalesOrderID
                   join Production.Product as p
                        on sod.ProductID = p.ProductID
          group by soh.CustomerID)
select ci.cId, ci.salesCnt, ci.avgSum
from customerSubCatCounter as c
         join customerInfo as ci
              on c.cId = ci.cId
where c.cnt > (select *
               from subcategoryCounter) / 2;


-- Найти номера покупателей, у которых все купленные ими товары были куплены как минимум дважды, т.е на два разных чека

with CustometProductCount(cId, pId)
         as (select soh.CustomerID, sod.ProductID
             from Sales.SalesOrderHeader as soh
                      join Sales.SalesOrderDetail as sod
                           on soh.SalesOrderID = sod.SalesOrderID
             group by soh.CustomerID, sod.ProductID
             having count(sod.ProductID) >= 2)
select soh.CustomerID
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID
group by soh.CustomerID
having count(distinct sod.ProductID) = (select count(*)
                                        from CustometProductCount as c
                                        where c.cId = soh.CustomerID
                                        group by c.cId);


with CustometProductCount(cId, pId, cnt)
         as (select soh.CustomerID, sod.ProductID, count(sod.ProductID)
             from Sales.SalesOrderHeader as soh
                      join Sales.SalesOrderDetail as sod
                           on soh.SalesOrderID = sod.SalesOrderID
             group by soh.CustomerID, sod.ProductID
             having count(sod.ProductID) >= 2),
     r(cId, pId, cnt)
         as (select soh.CustomerID, sod.ProductID, count(sod.ProductID)
             from Sales.SalesOrderHeader as soh
                      join Sales.SalesOrderDetail as sod
                           on soh.SalesOrderID = sod.SalesOrderID
             group by soh.CustomerID, sod.ProductID
             having count(sod.ProductID) < 2)
select distinct r1.cId
from CustometProductCount as r1
where r1.cId not in (select r2.cId from r as r2);

select sod.SalesOrderDetailID, sod.ProductID
from Sales.SalesOrderHeader as soh
         join Sales.SalesOrderDetail as sod
              on soh.SalesOrderID = sod.SalesOrderID
where soh.CustomerID = 11284;

-- Вывести на экран номера покупателей, количество купленных ими товаров, и количество чеков, которые у них были


-- Вывести на экран следующую информацию: название товара,
-- название категории к которой он относится и общее количество товаров в этой категории


-- Найти всех покупателей, их номера, для которых верно утверждение --
-- они ни разу не покупали товары более чем из трех подкатегорий на один чек.
-- Для данных покупателей вывести следующую информацию: номер покупателя,
-- номер чека, количество подкатегорий к которым относятся товары данного чека, и количество подкатегорий,
-- из которых покупатель приобретал товары за все покупки
with SalesLess4SubCat (salesOrderId, subcatCounter) as
         (select sod.SalesOrderID, count(distinct p.ProductSubcategoryID)
          from Sales.SalesOrderDetail as sod
                   join Production.Product as p
                        on sod.ProductID = p.ProductID
          group by sod.SalesOrderID
          having count(distinct p.ProductSubcategoryID) < 4),
--     customerInfo()
     customers(cId) as (select distinct soh.CustomerID
                        from Sales.SalesOrderHeader as soh
                        group by soh.CustomerID
                        having count(distinct soh.SalesOrderID) = (select count(distinct soh1.SalesOrderID)
                                                                   from Sales.SalesOrderHeader as soh1
                                                                   where soh.CustomerID = soh1.CustomerID
                                                                     and soh1.SalesOrderID in (select s4.salesOrderId
                                                                                               from SalesLess4SubCat as s4)
                                                                   group by soh1.CustomerID))
select c.cId,
       soh.SalesOrderID,
       s4.subcatCounter,
       (select count(distinct p.ProductSubcategoryID)
        from Sales.SalesOrderHeader as soh
                 join Sales.SalesOrderDetail as sod
                      on soh.SalesOrderID = sod.SalesOrderID
                 join Production.Product as p
                      on p.ProductID = sod.ProductID
        where soh.CustomerID = c.cId
        group by soh.CustomerID) as "totalSubCat"
from customers as c
         join Sales.SalesOrderHeader as soh
              on soh.CustomerID = c.cId
         join SalesLess4SubCat s4
              on soh.SalesOrderID = s4.salesOrderId;


