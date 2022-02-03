use bs;
-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№1 Создать таблицу для хранения просмотров книг зарегистрированными пользователями. BUView - состоит из двух полей IDB, IDU. 
	При создании таблицы прописать FOREIGN KEY */
-- Решение:
create table BUView(
IDB int,
IDU int,
foreign key (idb) references books(idb),
foreign key (idu) references users(idu)
);

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№2 Создать таблицу для хранения закладок "BUMark", где пользователь может пометить страницу в купленной книге и оставить короткое 
	текстовое описание, важно также знать время создания закладки.		*/
    drop table BUMark;
-- Решение:
   create table BUMark(
    id int primary key auto_increment,
    idb int,
    idu int,
    page int,
    mark varchar(150),
    time datetime
    );
    
/*	№3 Создать хранимую процедуру для добавления записей в таблицу "BUMark".
	Предусмотреть защиту от появления ошибок при заполнения данных*/

-- Решение:

delimiter //

CREATE PROCEDURE addToBUMark(idBook int, idUser int, page int, mark varchar(150), time datetime)
BEGIN
if exists(
select * from bubuy
join books on books.idb = bubuy.idb
join users on users.idu = bubuy.idu
where books.idb = idBook and users.idu = idUser)
then
insert into BUMark (idb, idu, page, mark, time)
values (idBook, idUser, page, mark, time);
end if;
END //

delimiter ;

-- call addToBUMark(2048, 1, 15, "Helo", now());
-- truncate table BUMark;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№4 Добавить в таблицу "BUMark" по 3 записи для пользователей: 'Denis', 'Dunn', 'Dora'.*/
-- idBook int, idUser int, page int, mark varchar(150), time datetime)

delimiter //

CREATE PROCEDURE addMarkToRandomBook(idUser int, bookIndex int, page int, mark varchar(150), time datetime)
BEGIN
Declare idBook int;

select books.idb as id into idBook from bubuy
join users on users.idu = bubuy.idu
join books on books.idb = bubuy.idb
where users.idu = idUser
order by id limit bookIndex,1;

call addToBUMark(idBook, idUser, page, mark, time);

END //

delimiter ;

-- Решение:
call addMarkToRandomBook((select idu from users where login = 'Denis'), 0, 15, "FirstBook", now());
call addMarkToRandomBook((select idu from users where login = 'Denis'), 1, 25, "SecondBook",  now());
call addMarkToRandomBook((select idu from users where login = 'Denis'), 2, 35, "ThirdBook", now());

call addMarkToRandomBook((select idu from users where login = 'Dunn'), 0, 55, "FirstBook", now());
call addMarkToRandomBook((select idu from users where login = 'Dunn'), 1, 35, "SecondBook",now());
call addMarkToRandomBook((select idu from users where login = 'Dunn'), 2, 75, "ThirdBook", now());

call addMarkToRandomBook((select idu from users where login = 'Dora'), 0, 45, "FirstBook",now());
call addMarkToRandomBook((select idu from users where login = 'Dora'), 1, 85, "SecondBook", now());
call addMarkToRandomBook((select idu from users where login = 'Dora'), 2, 95, "ThirdBook", now());

-- select * from BUMark;
-- truncate BUMark;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№5 Для каждого покупателя посчитать скидку в зависимости от количества купленных книг:
	+------------------------+------+-------+-------+-------+-------+
	| Количество книг, более |	0   |	3	|	5	|	7	|	10	|
    +------------------------+------+-------+-------+-------+-------+
    | Скидка, %		    	 |	0	|	1	|	2	|	3	|	5	|
	+------------------------+------+-------+-------+-------+-------+
	Решение этой задачи должно быть таким, чтобы потом им можно было воспользоваться для подсчета стоимости при покупке книги.*/
    
-- Решение:
DELIMITER //
CREATE FUNCTION calcDiscount(userId int) RETURNS INT deterministic
BEGIN
DECLARE discount INT;
DECLARE kol INT;
select count(*) into kol from bubuy
join users on users.idu = bubuy.idu
join books on books.idb = bubuy.idb
where users.idu = userId;
select CASE
    WHEN kol < 3
        THEN  0
    WHEN kol < 5
        THEN  1
    WHEN kol < 7
        THEN 2
	WHEN kol < 10
        THEN  3
    ELSE 5
END into discount;
RETURN discount;
END//
DELIMITER ;

-- drop function calcDiscount;

select calcDiscount(235);
-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№6 Создать представление, которое будет выводить список 10 самых покупаемых книг за предыдущий месяц 
(при одинаковом значении проданных книг, сортировать по алфавиту) */

/*with t as(
select books.idb as id, count(*) as kol from bubuy
join books on books.idb = bubuy.idb
where month(now())-month(bubuy.dat) = 1 and year(bubuy.dat) = year(now())
or month(now())-month(bubuy.dat) = -11 and year(bubuy.dat) = year(now())-1
group by books.idb
order by kol desc, books.TitleBooks asc limit 10
)
select t.id, books.TitleBooks, books.Price, books.EAN, books.BookPage, books.Weight, books.ProductCode, books.AgeRestriction, books.Cover from t
join books on t.id = books.idb;*/
select * from v;
drop view v;
drop view v1;

create view v as 
select books.*, count(*) as kol from bubuy
join books on books.idb = bubuy.idb
where month(now())-month(bubuy.dat) = 1 and year(bubuy.dat) = year(now())
or month(now())-month(bubuy.dat) = -11 and year(bubuy.dat) = year(now())-1
group by books.idb
order by kol desc, books.TitleBooks asc limit 10;

create view v1 as 
with t as(
select books.idb as id, count(*) as kol from bubuy
join books on books.idb = bubuy.idb
where month(now())-month(bubuy.dat) = 1 and year(bubuy.dat) = year(now())
or month(now())-month(bubuy.dat) = -11 and year(bubuy.dat) = year(now())-1
group by books.idb
order by kol desc, books.TitleBooks asc limit 10
)
select t.id, books.TitleBooks, books.Price, books.EAN, books.BookPage, books.Weight, books.ProductCode, books.AgeRestriction, books.Cover from t
join books on t.id = books.idb;

drop function check_out;
-- Решение:


DELIMITER //
CREATE FUNCTION check_out() RETURNS boolean deterministic
BEGIN
declare first int;
declare second int;

select count(*)from (
select v1.id from v1
join v on v.idb = v1.id
where 
 v.TitleBooks = v1.TitleBooks and
 v.Price = v1.Price and
 v.EAN = v1.EAN and
 v.BookPage = v1.BookPage and 
 v.Weight = v1.Weight and
 v.ProductCode = v1.ProductCode and
 v.AgeRestriction = v1.AgeRestriction and
 v.Cover = v1.Cover
) as kol into second;

select count(*) into first from v;

if (second = first) then
return 1;
else return 0;
end if;

END//
DELIMITER ;

select check_out();



-- drop view v;

select * from v;

-- -----------------------------------------------------------------------------------------------------------------------------------------
/*	№7 Написать хранимую процедуру. Для книг (если название и автор совпадает) вывести количество изданий, минимальную и максимальную стоимость. 
Отобразить только те записи, у которых есть несколько упоминаний.*/

-- Решение:
delimiter //

CREATE PROCEDURE izdaniya()
BEGIN
select books.TitleBooks as b, author.AuthorName as a, count(*)as kol, min(price) as min_pr, max(price) as max_pr from books
join ba on ba.idb = books.idb
join author on author.ida = ba.ida
group by b, a
having kol>1;
END //

delimiter ;

call izdaniya();
-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№8 Создать триггер который будет копировать исходную строку в "новую архивную таблицу" при редактирование данных в таблице "USERS".	*/
CREATE TABLE ArchiveUsers (
  IDU int,
  mail varchar(45), 
  login varchar(45), 
  pass int
  );
  
  drop trigger trigBeforeUpdateUsers;
  -- Решение:
  -- save last change
  
delimiter //
create trigger trigBeforeUpdateUsers before update on users
for each row begin

if not exists(select * from ArchiveUsers where IDU=OLD.IDU) then
insert into ArchiveUsers values (OLD.IDU,  OLD.mail, OLD.login, OLD.pass);
else
update ArchiveUsers
set ArchiveUsers.mail=OLD.mail, ArchiveUsers.login=OLD.login, ArchiveUsers.pass=old.pass
where ArchiveUsers.idu=OLD.IDU;
end if;
end//    

delimiter ;  

truncate ArchiveUsers;      

 /*-- checkout
select * from users 
where idu = 1;
-- Denis@rocketmail.com
-- 98337

update users
set mail = "DDD"
where idu = 1;

select * from ArchiveUsers;
-- 1	Denis@rocketmail.com	Denis	98337 -archieve
-- 1	DDD	Denis	98337						 -users

update users
set pass = 9999
where idu = 1;
-- 1	DDD	Denis	98337 - archieve
-- 1	DDD	Denis	9999 - users

update users
set pass = 98337, mail = "Denis@rocketmail.com"
where idu = 1;*/



-- save all changes
delimiter //
create trigger trigBeforeUpdateUsersAll before update on users
for each row begin
insert into ArchiveUsers values (OLD.IDU,  OLD.mail, OLD.login, OLD.pass);
end//    

delimiter ;        
                         
-- ----------------------------------------------------------------------------------------------------------------------------------------
/* №9 Написать хранимую процедуру. Какая книга или книги, самая популярная как первая купленная.*/
drop procedure popularFirstBuyBook;
drop view v8;
-- Решение:

delimiter //

CREATE PROCEDURE popularFirstBuyBook()
BEGIN
Declare max_count int;

create view v8 as

with user_min as(
select users.idu as id, min(bubuy.dat) as date from books
join bubuy on bubuy.idb = books.idb
join users on users.idu = bubuy.idu
group by users.IDU)

select books.idb as id, count(*) as kol from user_min
join users on users.idu=user_min.id
join bubuy on bubuy.idu = user_min.id and bubuy.dat = user_min.date
join books on bubuy.idb=books.idb
group by id;

select max(kol) into max_count from v8;
select books.TitleBooks, kol from v8
join books on books.idb = v8.id
where kol = max_count;

END //

delimiter ;

call popularFirstBuyBook();

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№10 Вывести пользователей которые не проявили никакой активности (не просматривали книги, ничего не покупали)*/
-- Решение:

select users.idu, users.login from users
left join bubuy on bubuy.idu = users.idu
left join BUView on BUView.idu = users.idu
where bubuy.idu is null and BUView.idu is null;

-- ----------------------------------------------------------------------------------------------------------------------------------------