with productSales(productId, salesCounter)
         as (select distinct sod.ProductID, count(sod.SalesOrderID) over (partition by sod.ProductID)
             from Sales.SalesOrderDetail as sod),
     productCustomers(productId, customerCounter)
         as (select sod.ProductID, count(distinct soh.CustomerID)
             from Sales.SalesOrderHeader as soh
                      join Sales.SalesOrderDetail as sod
                           on soh.SalesOrderID = sod.SalesOrderID
             group by sod.ProductID),
     categorySales(categoryId, salesCounter)
         as (select distinct ps.ProductCategoryID, count(soh.CustomerID) over ( partition by ps.ProductCategoryID)
             from Sales.SalesOrderHeader as soh
                      join Sales.SalesOrderDetail as sod
                           on soh.SalesOrderID = sod.SalesOrderID
                      join Production.Product as p
                           on p.ProductID = sod.ProductID
                      join Production.ProductSubcategory as ps
                           on p.ProductSubcategoryID = ps.ProductSubcategoryID)
select ps.productId, ps.salesCounter, cast (pc.customerCounter as decimal) / (select cast (cs.salesCounter as decimal)
                                                                  from categorySales as cs
                                                                  where cs.categoryId = ps1.ProductCategoryID) as "ratio of buyers"
from productSales as ps
         join productCustomers as pc
              on ps.productId = pc.productId
         join Production.Product as p
              on p.ProductID = pc.productId
         join Production.ProductSubcategory as ps1
              on p.ProductSubcategoryID = ps1.ProductSubcategoryID;
