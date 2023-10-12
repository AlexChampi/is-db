select soh1.CustomerID
from Sales.SalesOrderDetail as sod1
         join Sales.SalesOrderHeader as soh1
              on sod1.SalesOrderID = soh1.SalesOrderID
where exists(select soh2.CustomerID
             from Sales.SalesOrderHeader as soh2
                      join Sales.SalesOrderDetail as sod2
                           on soh2.SalesOrderID = sod2.SalesOrderID
             where soh1.CustomerID = soh2.CustomerID
               and sod1.ProductID = sod2.ProductID
               and soh1.SalesOrderID != soh2.SalesOrderID
             group by soh2.CustomerID)
group by soh1.CustomerID
having count(distinct soh1.SalesOrderID) > 1;

