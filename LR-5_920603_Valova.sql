-- Переименовать название файла. Вместо "x" - номер группы. Фамилию указать латиницей. (shift + ctrl + S -> сохранить как)
-- Все решения должны быть оформлены в виде запросов, и записаны в этот текстовый файл (в том числе создание хранимых процедур, функций и т.д.).
-- Задания рекомендуется выполнять по порядку.  
-- Задания **{} - выполнять по желанию.
use bs;
-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№0 Создать базу данных: Открыть SQL скрипт 'DB for 5,6,7', выполнить запросы для создания и заполнения таблиц */
-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№1 Для всех таблиц прописать создание первичных и вторичных ключей */

-- Решение:
alter table books
add constraint PK_books PRIMARY KEY (IDB);

alter table users
add constraint PK_users PRIMARY KEY (IDU);

alter table author
add constraint PK_author PRIMARY KEY (IDA);

alter table theme
add constraint PK_theme PRIMARY KEY (IDT, Title);

alter table bubuy
add constraint PK_bubuy PRIMARY KEY (id);

alter table ba
add constraint FK_ba primary key(idb,ida);

alter table tb
add constraint FK_tb primary key(idb,idt);

alter table ba
add constraint FK_ba_books
foreign key (idb) references bs.books(IDB),
add constraint FK_ba_author
foreign key (ida) references bs.author(IDA);

alter table tb
add constraint FK_tb_books
foreign key (idb) references books(IDB),
add constraint FK_tb_theme
foreign key (idt) references theme(IDT);

-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№2 Найти все книги автора – Леонида Алексеевича Филатова. Учесть все возможные комбинации записи имени в БД. */

/*select books.TitleBooks, author.AuthorName from ba
join books on ba.idb = books.IDB
join author on ba.ida = author.IDA
where  author.AuthorName regexp 'Филатов ';*/

-- Решение:
select books.TitleBooks, author.AuthorName from ba
join books on ba.idb = books.IDB
join author on ba.ida = author.IDA
where  author.AuthorName regexp 'Филатов (Л. |Л.|Леонид)(А. |А.|Алексеевич|)' or author.AuthorName regexp '(Л. |Л.|Леонид)(А. |А.|Алексеевич|)Филатов';

-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№3 Найти самую дорогую книгу или книги.*/
-- Решение №1 (только одну самую дорогую книгу):
select books.TitleBooks from books
order by price desc limit 1;

-- Решение №2 (Все самые дорогие книги):
select books.TitleBooks from books
where price = (select max(Price) from books);

-- Решение №3 (одну самую дорогую книгу, которая стоит больше, чем все остальные. Если такой книги нет – вывести null):

with max_price as (
select price from books
where price = (select max(Price) from books)
group by price
having count(*)=1)
select books.TitleBooks from books
where price = (select price from max_price);

-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№4 Найти тему, в которой было выпущено больше всего книг. */
-- Решение:

/*select theme.Title as title, count(*)as kol from theme
join tb on tb.idt = theme.idt
join books on tb.idb = books.idb
group by theme.Title
order by kol desc limit 1;*/

with th_count as
(select theme.Title as title, count(*)as kol from theme
join tb on tb.idt = theme.idt
join books on tb.idb = books.idb
group by theme.Title)

select title from th_count
where kol = (select max(kol) from th_count);
-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№5 Для каждого автора вывести все жанры, в которых он публиковался, объединить все значения жанров в один столбец. */
-- Решение:
select distinct author.AuthorName as name, group_concat(distinct theme.Title, '  ') from author
join ba on ba.ida = author.IDA
join books on books.IDB = ba.idb
join tb on tb.idb = books.idb
join theme on theme.IDT = tb.idt
group by name;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№6 Найти все разные почтовые домены (например: gmail.com, mail.ru и т.д.) */
-- Решение:
select distinct substring(mail, position('@' in mail)+1)as domen from users;
-- ----------------------------------------------------------------------------------------------------------------------------------------
/*  №7 Найти самый часто встречающийся почтовый домен */
-- Решение:
with domen_count as(
select substring(mail, position('@' in mail)+1)as domen, count(*)as kol from users
group by domen)
select domen from domen_count
where kol = (select max(kol) from domen_count);
-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№8 Найти самого покупаемого автора. */

-- Решение:
with a_b as(
select author.AuthorName as name, count(*) as kol from author
join ba on ba.ida = author.ida
join books on ba.idb = books.idb
group by author.AuthorName
)
select name from a_b
where kol = (select max(kol) from a_b);

/* 	№9 Найти первую книгу приобретенную читателем. */
-- Решение:
-- одна из первых по дате
select books.TitleBooks, bubuy.dat from books
join bubuy on bubuy.idb = books.idb
where bubuy.dat = (select min(dat) from bubuy)
order by books.TitleBooks limit 1;

-- первая книга пользователя с указанным логином
delimiter //

CREATE PROCEDURE findFirstBuyDate(in login varchar(45))
BEGIN
with user_books as
(select books.TitleBooks as title, bubuy.dat as date from books
join bubuy on bubuy.idb = books.idb
join users on users.idu = bubuy.idu
where users.login = login)
select title, date from user_books
where date = (select min(date) from user_books);
END //

delimiter ;

call findFirstBuyDate('Alesya'); 

-- первые книги всех пользователей
with user_min as(
select users.idu as id, min(bubuy.dat) as date from books
join bubuy on bubuy.idb = books.idb
join users on users.idu = bubuy.idu
group by users.IDU)
select users.login, books.TitleBooks, date from user_min
join users on users.idu=user_min.id
join bubuy on bubuy.idu = user_min.id and bubuy.dat = user_min.date
join books on bubuy.idb=books.idb;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№10 Вывести статистику: количество купленных книг по каждому дню. */

-- Решение:
select DATE(bubuy.dat), count(*) from bubuy
group by DATE(bubuy.dat)
order by DATE(bubuy.dat);
-- ----------------------------------------------------------------------------------------------------------------------------------------
