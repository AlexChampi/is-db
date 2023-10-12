with ProductSalesCounter(productId, cnt) as
         (select sod.ProductID, count(*)
          from Sales.SalesOrderDetail as sod
          group by sod.ProductID),
     ProductCustomersCounter(productId, cnt) as
         (select sod.ProductID, count(distinct soh.CustomerID)
          from Sales.SalesOrderDetail as sod
                   join Sales.SalesOrderHeader as soh
                        on sod.SalesOrderID = soh.SalesOrderID
          group by sod.ProductID),
     CategorySalesCounter(categoryId, cnt) as
         (select ps.ProductCategoryID, count(distinct soh.CustomerID)
          from Sales.SalesOrderHeader as soh
                   join Sales.SalesOrderDetail as sod
                        on soh.SalesOrderID = sod.SalesOrderID
                   join Production.Product as p
                        on sod.ProductID = p.ProductID
                   join Production.ProductSubcategory as ps
                        on p.ProductSubcategoryID = ps.ProductSubcategoryID
          group by ps.ProductCategoryID)
select p.ProductID,
       psc.cnt                                             as "sales counter",
       cast(pcc.cnt as decimal) / cast(csc.cnt as decimal) as "customer counter / category counter "
from Production.Product as p
         join Production.ProductSubcategory as ps
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join CategorySalesCounter as csc
              on ps.ProductCategoryID = csc.categoryId
         join ProductCustomersCounter as pcc
              on p.ProductID = pcc.productId
         join ProductSalesCounter as psc
              on p.ProductID = psc.productId