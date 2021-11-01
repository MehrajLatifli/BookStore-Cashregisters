create database BookStore


use BookStore




create table Books
(
IdBook int primary key IDENTITY (1,1) NOT NULL,
BookName nvarchar(max) NOT NULL,
BookPrice money NOT NULL,
BookQuantity bigint NOT NULL,

Constraint CK_BookName Check(BookName <>' '),
)


insert into BookStore.dbo.Books(BookStore.dbo.Books.BookName, BookStore.dbo.Books.BookPrice, BookStore.dbo.Books.BookQuantity)
values
(N'BookName_1', 5, 5),
(N'BookName_2', 15, 15),
(N'BookName_3', 25, 5),
(N'BookName_4', 45, 15),
(N'BookName_5', 50, 10),
(N'BookName_6', 5, 15),
(N'BookName_7', 10, 15),
(N'BookName_8', 15, 20),
(N'BookName_9', 20, 25),
(N'BookName_10',25, 10)




create table Press
(
IdPress int primary key IDENTITY (1,1) NOT NULL,
PressName nvarchar(max) NOT NULL,
PressYear nvarchar(max) NOT NULL,

BookId_forPress int NOT NULL,

Constraint CK_PressName Check(PressName <>' '),
Constraint CK_PressYear Check(PressYear <>' '),

Constraint FK_BookId Foreign key (BookId_forPress) References Books(IdBook) On Delete CASCADE On Update CASCADE
)


Insert into BookStore.dbo.Press(BookStore.dbo.Press.PressName, BookStore.dbo.Press.PressYear, BookStore.dbo.Press.BookId_forPress)
values
(N'Press_1',N'2015',1),
(N'Press_1',N'2010',10),
(N'Press_2',N'2012',2),
(N'Press_3',N'2018',3),
(N'Press_4',N'2020',4),
(N'Press_5',N'2015',5),
(N'Press_6',N'2011',6),
(N'Press_7',N'2015',7),
(N'Press_8',N'2021',8),
(N'Press_8',N'2020',9)




create table Authors
(
IdAuthor int primary key IDENTITY (1,1) NOT NULL,
AuthorFirtName nvarchar(max) NOT NULL,
AuthorLastName nvarchar(max) NOT NULL,

Constraint CK_AuthorFirtName Check(AuthorFirtName <>' '),
Constraint CK_AuthorLastName Check(AuthorLastName <>' ')
)


Insert into BookStore.dbo.Authors(BookStore.dbo.Authors.AuthorFirtName, BookStore.dbo.Authors.AuthorLastName)
values
(N'AuthorFirtName_1', N'AuthorLastName_1'),
(N'AuthorFirtName_2', N'AuthorLastName_2'),
(N'AuthorFirtName_3', N'AuthorLastName_3'),
(N'AuthorFirtName_4', N'AuthorLastName_4'),
(N'AuthorFirtName_5', N'AuthorLastName_5'),
(N'AuthorFirtName_6', N'AuthorLastName_6'),
(N'AuthorFirtName_7', N'AuthorLastName_7'),
(N'AuthorFirtName_8', N'AuthorLastName_8')




create table BookandAuthors
(
IdBookandAuthor int primary key IDENTITY (1,1) NOT NULL,

BookId_forBookandAuthor int NOT NULL,
AuthorId_forBookandAuthor int NOT NULL,


Constraint FK_BookId_forBA Foreign key (BookId_forBookandAuthor) References Books(IdBook) On Delete CASCADE On Update CASCADE,
Constraint FK_AuthorId_forBA Foreign key (AuthorId_forBookandAuthor) References Authors(IdAuthor) On Delete CASCADE On Update CASCADE
)


Insert into BookStore.dbo.BookandAuthors(BookStore.dbo.BookandAuthors.BookId_forBookandAuthor, BookStore.dbo.BookandAuthors.AuthorId_forBookandAuthor)
values
(1,1),
(1,2),
(2,1),
(2,2),
(3,3),
(3,4),
(3,5),
(4,1),
(4,6),
(5,8),
(6,2),
(7,7),
(8,7),
(9,8),
(10,8)




create table Cashregisters
(
IdCashregister int primary key IDENTITY (1,1) NOT NULL,
Profit money,
BookId_forCashregister int NOT NULL,

Constraint FK_BookId_forC Foreign key (BookId_forCashregister) References Books(IdBook) On Delete CASCADE On Update CASCADE,
)



-- sp_SellBooks


Create OR Alter Procedure sp_SellBooks
@IdBook as int
AS
BEGIN
  DECLARE @BookQuantity as bigint
  DECLARE @BookPrice as money
  DECLARE @BookName as nvarchar(max)
  BEGIN Transaction sp_SellBooks_TR
  select
  @BookQuantity=BookStore.dbo.Books.BookQuantity,
  @BookName=BookStore.dbo.Books.BookName,
  @BookPrice=BookStore.dbo.Books.BookPrice
  from
  BookStore.dbo.Books
  where
  @IdBook=BookStore.dbo.Books.IdBook
  if(Not EXISTS
  (
   select
   *from
   BookStore.dbo.Books
   where
   @IdBook=BookStore.dbo.Books.IdBook
  )
  )
  BEGIN
    print 'Can not find this book'
    rollback TRANSACTION sp_SellBooks_TR
  END
  else
  BEGIN
	  if(@BookQuantity>0)
	  BEGIN
        INSERT INTO   BookStore.dbo.Cashregisters(Cashregisters.Profit,Cashregisters.BookId_forCashregister)
        values(@BookPrice,@IdBook)

		print 'The checkout process is correct.'

        Update BookStore.dbo.Books
        Set BookStore.dbo.Books.BookQuantity=BookStore.dbo.Books.BookQuantity-1
        where @IdBook=BookStore.dbo.Books.IdBook

		print 'A book was bought from a bookstore.'

		SELECT SUM(Profit)
        FROM Cashregisters

        COMMIT TRANSACTION sp_SellBooks_TR
	  END
	  else
	  BEGIN
		print 'The book called '+@BookName+ ' is no longer available in the store.'
        rollback TRANSACTION sp_SellBooks_TR
	  END
  END
END




select *from Books
select *from Cashregisters

exec sp_SellBooks 1


select *from Books
select *from Cashregisters



SELECT SUM(Profit)
FROM Cashregisters













-- GetAll


select 
BookStore.dbo.BookandAuthors.IdBookandAuthor,
BookStore.dbo.Books.BookName,
BookStore.dbo.Books.BookPrice,
BookStore.dbo.Books.BookQuantity,
BookStore.dbo.Authors.AuthorFirtName,
BookStore.dbo.Authors.AuthorLastName
from 
BookStore.dbo.Books
Inner Join
BookStore.dbo.BookandAuthors
On
BookStore.dbo.Books.IdBook=BookStore.dbo.BookandAuthors.BookId_forBookandAuthor
Inner Join
BookStore.dbo.Authors
On
BookStore.dbo.Authors.IdAuthor=BookStore.dbo.BookandAuthors.AuthorId_forBookandAuthor




select 
BookStore.dbo.BookandAuthors.IdBookandAuthor,
BookStore.dbo.BookandAuthors.BookId_forBookandAuthor,
BookStore.dbo.BookandAuthors.AuthorId_forBookandAuthor
from BookStore.dbo.BookandAuthors 




select 
*
from 
BookStore.dbo.Press
Inner Join
BookStore.dbo.Books
On
BookStore.dbo.Books.IdBook=BookStore.dbo.Press.IdPress




select 
*
from 
BookStore.dbo.Press





