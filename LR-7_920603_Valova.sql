
use bs;

-- ??? - Что такое транзакция? Как работает транзакция? Когда и для чего используют транзакции?
/*Транзакция — это совокупность операций над базой данных, которые
вместе образуют логически целостную процедуру, и могут быть либо
выполнены все вместе, либо не будет выполнена ни одна из них.
Транзакции являются одним из средств обеспечения согласованности
(непротиворечивости) базы данных. Транзакция может иметь два исхода: первый — изменения данных,
произведенные в ходе ее выполнения, успешно зафиксированы в
базе данных, а второй исход таков — транзакция отменяется, и
отменяются все изменения, выполненные в ее рамках.
Отмена транзакции называется откатом (rollback).
Транзакции используются для обеспечения целостности данных, в случаях, когда какие-либо операции логически связаны между собой.
*/

-- ??? - Что такое индексы? Как работают индексы? Какие бывают индексы?
/*
 Индекс (англ. index) — объект базы данных, создаваемый с целью повышения производительности поиска данных.
 Индекс ускоряет процесс запроса, предоставляя быстрый доступ к строкам данных в таблице.
 Когда вы формируете запрос на индексированный столбец, подсистема запросов начинает идти сверху от корневого узла 
 и постепенно двигается вниз через промежуточные узлы, при этом каждый слой промежуточного уровня содержит более детальную
 информацию о данных. Подсистема запросов продолжает двигаться по узлам индекса до тех пор, пока не достигнет
 нижнего уровня с листьями индекса.
 Индекс может быть либо кластеризованным, либо некластеризованным, 
 возможно его дополнительно сконфигурировать как составной индекс,
 уникальный индекс или покрывающий индекс.
*/
-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№1	Привести пример с использованием транзакций.*/

-- у каждого пользователя, открывшего счет в этом месяце, сделать вычет 1% средств в банк.

/*drop table Users_;
drop table Bank ;
truncate Users_;
truncate Bank;

select*from Users_;
select*from Bank;

create table Users_(
id int primary key auto_increment,
balance int,
dat date,
bank_id int);

create table Bank(
id int primary key,
balance int); 

insert into Users_(balance, dat, bank_id)
values 
(500, '2020-11-12',1), (100, '2021-07-06',1), (200, '2021-11-12',1),(400, '2021-11-19',1),(600, '2020-10-14',1),(400, '2021-11-17',1),(300, '2021-11-12',1),(100, '2021-07-12',1),(100, '2021-11-04',1);

insert into Bank
values(1,0);*/

delimiter //

CREATE PROCEDURE trans()
BEGIN
Declare accrual decimal;
select sum(users_.balance/100) into accrual from users_
where month(users_.dat) = month(now()) and year(users_.dat) = year(now());
start transaction;

update bank
set balance = accrual;

update users_
set 
users_.balance = users_.balance - users_.balance/100
where month(users_.dat) = month(now()) and year(users_.dat) = year(now());

commit;
END //

delimiter ;

-- Решение:
call trans();
-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№2 Вывести статистику: количество купленных разных книг по каждому дню. */

-- Решение:

select date(bubuy.dat), count(distinct bubuy.idb) as kol from bubuy
group by date(bubuy.dat);

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№3 Создать таблицу "Buy", которая состоит из полей: ID - первичный ключ, авто заполняемое. IDB, IDU, TimeBuy
. Создать уникальный составной индекс для IDB, IDU. Создать обычный индекс TimeBuy, обратный порядок. 
*/

-- Решение:

create table Buy(
id int primary key auto_increment,
idb int,
idu int,
TimeBuy datetime
);

create unique index indexComposite on Buy(idb,idu);
create index indexTimeBuy on Buy(TimeBuy desc);

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№4  Модифицировать таблицу "Buy", добавить поле для хранения стоимости покупки "Cost".*/

-- Решение:

alter table Buy
add column Cost decimal (8,3);

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№5	Изменить триггер для таблицы USERS, который теперь должен срабатывать при изменении адреса почтового ящика.*/ 

-- Решение:
-- drop trigger trigBeforeUpdateUsers;

delimiter //
create trigger trigBeforeUpdateMail before update on users
for each row begin

if new.mail <> old.mail then 
if not exists(select * from ArchiveUsers where IDU=OLD.IDU) then
insert into ArchiveUsers values (OLD.IDU,  OLD.mail, OLD.login, OLD.pass);
else
update ArchiveUsers
set ArchiveUsers.mail=OLD.mail
where ArchiveUsers.idu=OLD.IDU;
end if;
end if;
end//    

delimiter ;  

/*-- checkout
truncate ArchiveUsers;      

select * from users 
where idu = 1;
-- Denis@rocketmail.com
-- 98337

update users
set mail = "DDD"
where idu = 1;

select * from ArchiveUsers;

update users
set mail = "D@lol"
where idu = 1;

-- rollback
update users
set pass = 98337, mail = "Denis@rocketmail.com"
where idu = 1;
*/

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№6	Для таблицы пользователей заменить пароль, который хранится в открытом виде, на тот же, но захешированный методом md5.*/
-- MD5 возвращает 32-х символьную шестнадцатеричную строку.
-- Решение:
alter table users
modify pass char(32);

update users
set pass = md5(pass);

select idu, pass from users;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№7	Вывести количество и среднее значение стоимости книг, которые были просмотрены, но не разу не были куплены.*/

-- Решение:
select count(*) as count, avg(price) as average_price from books
join buview on buview.idb = books.idb
left join bubuy on bubuy.idb = books.idb
where bubuy.idb is null;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№8	Вывести количество купленных книг, а также суммарную их стоимость для тем с кодом с 1 по 6 включительно.*/

-- Решение:

select count(books.idb) as count, sum(price) as sumPrice from books
join tb on tb.idb = books.idb
join bubuy on bubuy.idb = books.idb
join theme on theme.idt = tb.idt
where theme.idt between 1 and 6;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№9	Вывести Название книги, Имя автора, Логин покупателя для книг, которые были куплены в период с июня по август 2018 года включительно, написаны
 в тематике 'фэнтези' и 'классика', при условии, что число страниц должно быть от 700 до 800 включительно и цена книги меньше 500.*/

-- Решение:

select books.TitleBooks, author.AuthorName, users.login, bubuy.dat from books
join bubuy on bubuy.idu = books.idb
join users on users.idu = bubuy.idu 
join tb on tb.idb = books.idb
join theme on theme.idt = tb.idt
join ba on ba.idb = books.idb
join author on author.ida = ba.ida
where
(bubuy.dat between '2018-06-01' and '2018-08-31')
and 
(books.BookPage between 700 and 800)
and
(theme.Title regexp 'фэнтези' or theme.Title regexp 'классика')
and 
(books.Price < 500);

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№10	Создать новую таблицу «Theme» избавив её от нарушения правил нормализации */

update theme
set Title = "Государственное, конституционное, административное право России"
where Title = "Государственное. конституционное. административное право России";

update theme
set Title = "КОНСТИТУЦИОННОЕ ПРАВО. ГОСУДАРСТВЕННОЕ ПРАВО. ИЗБИРАТЕЛЬНОЕ ПРАВО. СИСТЕМА ОРГАНОВ ГОСУДАРСТВА"
where Title = "КОНСТИТУЦИОННОЕ .ГОС.. ПРАВО. ИЗБИРАТЕЛЬНОЕ ПРАВО. СИСТЕМА ОРГАНОВ ГОСУДАРСТВА";

update theme
set Title = "БУХГАЛТЕРСКИЙ УЧЕТ. АУДИТ. НАЛОГИ И НАЛОГООБЛОЖЕНИЕ"
where Title = "БУХ. УЧЕТ. АУДИТ. НАЛОГИ И НАЛОГООБЛОЖЕНИЕ";

select * from theme;
-- лишние темы: 9-11 кл, 0-3 лет и тп :/

-- Решение:

drop table newTheme;
CREATE TABLE newTheme (
	IDT INT PRIMARY KEY AUTO_INCREMENT,
	title VARCHAR(70)
);

truncate table newTheme;
DROP PROCEDURE split;

DELIMITER //
CREATE PROCEDURE split()
BEGIN

	DECLARE done BOOLEAN DEFAULT FALSE;
	DECLARE Arr VARCHAR(150);
	DECLARE indexx INT;
	DECLARE theme VARCHAR(75);
	DECLARE themes CURSOR FOR SELECT Title FROM Theme;  --  ссылка на контекстную область памяти
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE; -- для обработки исключения "Error: 1329 SQLSTATE: 02000 (ER_SP_FETCH_NO_DATA)" когда курсор будет пустым 
	
    OPEN themes; -- открываем курсор 
    
	getstr: LOOP
		FETCH themes INTO Arr;-- считываем по курсору
		        
        split: LOOP

			SET indexx = POSITION("." IN Arr) + 1;
            if (indexx = 1) then
            set theme = TRIM(Arr);  -- выедляем тему
            IF theme NOT IN (SELECT Title FROM newTheme) THEN  -- если такой темы нет 
				INSERT INTO newTheme(title) VALUE (theme); -- добавляем
            END IF;
            leave split;
            else
			SET Arr = TRIM(substring(Arr, indexx)); 
            SET theme =TRIM(SUBSTRING_INDEX(Arr, ".", 1)); -- выделяем тему
            IF theme NOT IN (SELECT Title FROM newTheme) THEN  -- если такой темы нет 
				INSERT INTO newTheme(title) VALUE (theme); -- добавляем
            END IF;
            end if;
            
		END LOOP;
        
        IF done THEN    -- если курсор пуст
			LEAVE getstr;  -- выходим из цикла
		END IF;
    END LOOP;
    
    CLOSE themes; -- закрываем курсор
END //
DELIMITER ;

call split();
select * from newTheme;


-- ----------------------------------------------------------------------------------------------------------------------------------------
