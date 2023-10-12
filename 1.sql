/*1. Найти и вывести на экран названия продуктов, их цвет и размер*/
SELECT p.Name, p.Color, p.Size
FROM Production.Product AS p
/*2. Найти и вывести на экран названия, цвет и размер таких продуктов, у которых
цена более 100.*/
SELECT p.Name, p.Color, p.Size
FROM Production.Product AS p
WHERE p.ListPrice > 100
/*3. Найти и вывести на экран название, цвет и размер таких продуктов, у которых
цена менее 100 и цвет Black.*/
SELECT p.Name, p.Color, p.Size
FROM Production.Product AS p
WHERE p.ListPrice < 100
  AND p.Color = 'Black'
/*4. Найти и вывести на экран название, цвет и размер таких продуктов, у которых
цена менее 100 и цвет Black, упорядочив вывод по возрастанию стоимости
продуктов.*/
SELECT p.Name, p.Color, p.Size
FROM Production.Product AS p
WHERE p.ListPrice < 100
  AND p.Color = 'Black'
ORDER BY p.ListPrice
/*5. Найти и вывести на экран название и размер первых трех самых дорогих
товаров с цветом Black.*/
SELECT TOP 3 WITH TIES p.Name, p.Size
FROM Production.Product AS p
WHERE p.Color = 'Black'
ORDER BY p.ListPrice DESC
/*6. Найти и вывести на экран название и цвет таких продуктов, для которых
определен и цвет, и размер.*/
SELECT p.Color, p.ListPrice
FROM Production.Product AS p
WHERE p.Color IS NOT NULL
  AND p.Size IS NOT NULL

SELECT DISTINCT p.Color
FROM Production.Product AS p
WHERE p.ListPrice BETWEEN 10 AND 50


SELECT DISTINCT p.Color
FROM Production.Product AS p
WHERE p.Name LIKE 'l_n%'


SELECT p.Name
FROM Production.Product AS p
WHERE p.Name LIKE '[d,m]%'
  AND len(p.Name) > 3

SELECT p.Name
FROM Production.Product AS p
WHERE datepart(YEAR, p.SellStartDate) < 2012

SELECT ps.Name
FROM Production.ProductSubcategory AS ps

SELECT pc.Name
FROM Production.ProductCategory AS pc


SELECT *
FROM Production.ProductSubcategory as pc

SELECT p.FirstName
FROM Person.Person AS p
WHERE p.Title='Mr.'

SELECT p.FirstName
FROM Person.Person AS p
WHERE p.Title IS NULL


SELECT pc.Name
FROM Production.ProductSubcategory as pc
WHERE pc.ProductSubcategoryID in (1, 3, 5)