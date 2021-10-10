-- 1. Выполнить данные запросы:
Create database B1;
use b1;
CREATE TABLE Basic (
    SongTitle VARCHAR(35),
    Quality varchar(1),
    Duration INT,
    DateRecord DATE,
    AlbumTitle varchar(35), 
    price decimal (5,2),
    ArtistName varchar(35),
    `e-mail` varchar(35)
    );
insert into Basic (SongTitle, Quality, Duration, DateRecord, AlbumTitle, price, ArtistName, `e-mail`) values 
('Sing Me To Sleep', 'H', 176, '2018-08-29',null, null, 'Alan Walke', 'AlanWalker@mail.com'),
('The Greatest', 'L', 88, '2019-10-24', 'The Greatest', 2.38, 'Sia', null),
('Cheap Thrills', 'M', 115, '2016-07-16', 'The Greatest', 2.38, 'Sia', null),
('Ocean Drive', 'M', 101,	'2015-12-04', null, null, 'Duke Dumont', null),
('No Money', 'M',	126, '2018-05-11', 'In The Lonely Hour', 3.63, null, null),
('Thinking About It', 'L', 170, '2016-01-14', 'Evolution', 1.88, 'Nathan Goshen', null),
('Perfect Strangers', 'L', 189, '2018-09-06', 'Runway', 2.75, 'Jonas Blue', null),
('Perfect Strangers', 'L', 189, '2018-09-06', 'Runway', 2.75, 'Jp Cooper', null),
('Thinking About It', 'M', 179, '2017-10-25','In The Lonely Hour',3.25, 'Alan Walke', 'AlanWalker@mail.com'),
('Thinking About It', 'M', 179, '2017-10-25','In The Lonely Hour',3.25, 'Jp Cooper', null),
('My Way', 'H', 163, '2018-07-26','My Way', 1.63, 'Frank Sinatra', null),	
('My Way', 'H', 157,	'1985-01-11','The Christmas', 3.63, 'Frank Sinatra', null),
('Let It Snow!', 'M', 158, '1984-03-05','World On A String', 3.38, 'Frank Sinatra', null);

truncate Basic;

select * from Basic;

-- 2. Нормальзвать базу данных. Создать новые таблицы (назания полей взять из таблицы Basic).
-- ----------------------------------------------------------------------
-- Решение:
create table Song_Artist(
Song_ID int, 
Artist_ID int,
primary key (Song_ID, Artist_ID),
foreign key (Song_ID) references Songs (Song_ID) on delete cascade,
foreign key (Artist_ID) references Artist (Artist_ID) on delete cascade
);

create table Songs(
Song_ID int primary key auto_increment, 
SongTitle VARCHAR(35),
Quality varchar(1),
Duration INT,
DateRecord DATE,
Album_ID int,
foreign key (Album_ID) references Albums(Album_ID) on delete set null
);

create table Albums(
Album_ID int primary key auto_increment,
AlbumTitle varchar(35),
price decimal (5,2)
);

create table Artists(
Artist_ID int primary key auto_increment,
ArtistName varchar(35),
`e-mail` varchar(35)
);

-- ----------------------------------------------------------------------
-- 3. Заполнить полученые таблицы с помощью запросов из таблицы Basic
-- ----------------------------------------------------------------------
-- Решение:

insert into Artists (ArtistName, `e-mail`)
select distinct ArtistName, `e-mail` from Basic where ArtistName is not null;

insert into Albums (AlbumTitle, price)
select distinct AlbumTitle, price from Basic where AlbumTitle is not null;

insert into Songs(SongTitle, Quality, Duration, DateRecord, Album_ID)
select distinct SongTitle, Quality, Duration, DateRecord, Albums.Album_ID from Basic
left join Albums on Albums.AlbumTitle = Basic.AlbumTitle and Albums.price = Basic.price;
-- truncate Songs;

insert into Song_Artist
select Song_ID, Artist_ID from Basic
join Artists on Basic.ArtistName = Artists.ArtistName
join Songs on Basic.SongTitle = Songs.SongTitle and Basic.DateRecord = Songs.DateRecord;

-- select * from Song_Artist;
-- select * from Songs;
-- select * from Artists;
-- select * from Albums;

-- ----------------------------------------------------------------------
-- далее работать с таблицей basic не допускается!
-- ----------------------------------------------------------------------

-- 4. Вывести поля: SongTitle, Quality, Duration, DateRecord, AlbumTitle, 
-- price, ArtistName, `e-mail` из полученных в ходе нормализации таблиц
-- ----------------------------------------------------------------------
-- Решение:
select SongTitle, Quality, Duration, DateRecord, Albums.AlbumTitle, Albums.price, Artists.ArtistName, Artists. `e-mail` from Songs
left join Song_Artist on Songs.Song_ID = Song_Artist.Song_ID
left join Albums on Albums.Album_ID = Songs.Album_ID
left join Artists on Artists.Artist_ID = Song_Artist.Artist_ID;

-- ----------------------------------------------------------------------
-- 5. Добавить новую композицию - назание: "Can't Stop The Feeling", исполнителя: "Jonas Blue", 
-- продолжительностью 253 секунды, качество - "M", в "DateRecord" указать текущию дату.
-- ----------------------------------------------------------------------
-- Решение:
insert into Songs (SongTitle, Quality, Duration, DateRecord)
values ("Can't Stop The Feeling", "M", 253, current_date());

insert into Song_Artist 
values
((select Song_ID from Songs where SongTitle = "Can't Stop The Feeling"), (select Artist_ID from Artists where ArtistName = "Jonas Blue"));

-- ----------------------------------------------------------------------
-- 6. Переименовать аудио запись "Thinking About It" исполнителя "Nathan Goshen" в "Let It Go"
-- ----------------------------------------------------------------------
-- Решение:
update Songs
left join Song_Artist on Song_Artist.Song_ID = Songs.Song_ID
left join Artists on Artists.Artist_ID = Song_Artist.Artist_ID
set SongTitle = "Let It Go"
where SongTitle = "Thinking About It" and ArtistName = "Nathan Goshen";

-- ----------------------------------------------------------------------
-- 7. Удалить колонку "e-mail", создать колонку "Сайт", задав по умолчанию значение «нет»
-- ----------------------------------------------------------------------
-- Решение:
alter table Artists
drop column `e-mail`;

alter table Artists
add Site varchar(30) default "no";

-- chechout:
select SongTitle, Quality, Duration, DateRecord, Albums.AlbumTitle, Albums.price, Artists.ArtistName, Artists.Site from Songs
left join Song_Artist on Songs.Song_ID = Song_Artist.Song_ID
left join Albums on Albums.Album_ID = Songs.Album_ID
left join Artists on Artists.Artist_ID = Song_Artist.Artist_ID;


-- ----------------------------------------------------------------------
-- 8. Вывести все аудио записи, отобразив, если имеется, имя исполнится и альбом
-- ----------------------------------------------------------------------
-- Решение:
select SongTitle, Artists.ArtistName, Albums.AlbumTitle from Songs
left join Song_Artist on Songs.Song_ID = Song_Artist.Song_ID
left join Artists on Artists.Artist_ID = Song_Artist.Artist_ID
left join Albums on Albums.Album_ID = Songs.Album_ID;

-- ----------------------------------------------------------------------
-- 9. Вывести все аудио записи, у которых в названии альбома есть «way» 
-- ----------------------------------------------------------------------
-- Решение:
select SongTitle,  Albums.AlbumTitle from Songs
left join Albums on Albums.Album_ID = Songs.Album_ID
where AlbumTitle regexp ('way');

-- ----------------------------------------------------------------------
-- 10. Вывести: название, стоимость альбома и его исполнителя при условии, 
-- что он будет самым дорогим для каждого исполнителя.
-- ----------------------------------------------------------------------
-- Решение:
select distinct Albums.AlbumTitle, Albums.price, ArtistName from Artists as A
join  Song_Artist on A.Artist_ID = Song_Artist.Artist_ID
join Songs on Song_Artist.Song_ID = Songs.Song_ID
join Albums on Albums.Album_ID = Songs.Album_ID
where Albums.price = (select max(Albums.price) from Artists
join  Song_Artist on Artists.Artist_ID = Song_Artist.Artist_ID
join Songs on Song_Artist.Song_ID = Songs.Song_ID
join Albums on Albums.Album_ID = Songs.Album_ID
where Artists.ArtistName = A.ArtistName);
-- ----------------------------------------------------------------------
-- 11. Удалить запись "Can't Stop The Feeling" исполнителя "Jonas Blue".
-- ----------------------------------------------------------------------
-- Решение:
delete Songs from Songs
join Song_Artist on Song_Artist.Song_ID = Songs.Song_ID
join Artists on Artists.Artist_ID = Song_Artist.Artist_ID
where Songs.SongTitle = "Can't Stop The Feeling" and Artists.ArtistName = "Jonas Blue";
-- ----------------------------------------------------------------------
-- 12.	Вывести название и качество записи трека отсортировав 
-- сначала по качеству, затем по названию (обратный порядок), не включая плохие записи.
-- ----------------------------------------------------------------------
-- Решение:
select SongTitle, Quality from Songs 
where Quality != 'L' 
order by Quality desc, SongTitle desc;
-- ----------------------------------------------------------------------
-- 13.	Создать хранимую процедуру для вывода названия и цены трех самых дешевых альбомов.
-- ----------------------------------------------------------------------
-- Решение:
delimiter //
CREATE PROCEDURE findCheapAlbums()
BEGIN
select AlbumTitle, price from Albums 
order by price limit 3;
END //
delimiter ;

-- drop procedure findCheapAlbums;
call findCheapAlbums();
-- ----------------------------------------------------------------------
-- 14.	Вывести альбом второй по стоимости после самого дорогого альбома.
-- ----------------------------------------------------------------------
-- Решение:
select AlbumTitle, price from Albums 
where price != (select max(price)from Albums)
order by price desc limit 1;
-- ----------------------------------------------------------------------
-- 15.	Найти альбом, у которого нет исполнителя.
-- ----------------------------------------------------------------------
-- Решение:
select AlbumTitle from Albums
left join Songs on Songs.Album_ID = Albums.Album_ID
left join  Song_Artist on Songs.Song_ID = Song_Artist.Song_ID
left join Artists on Artists.Artist_ID = Song_Artist.Artist_ID
where Artists.Artist_ID is null;
-- ----------------------------------------------------------------------
-- 16.	Найти треки, у которых название начинается не с букв.
-- ----------------------------------------------------------------------
-- Решение:
-- insert into songs(SongTitle) values (".hhh");
-- delete from songs 
-- where SongTitle = ".hhh";

select SongTitle from songs 
where SongTitle not regexp '^[a-z]';
-- ----------------------------------------------------------------------
-- 17.	Найти все треки, которые начинаются на гласные буквы.
-- ----------------------------------------------------------------------
-- Решение:
select SongTitle from songs 
where SongTitle regexp '^[aouie]';
-- ----------------------------------------------------------------------
-- 18.	Создать хранимую процедуру для вывода названия альбома которые начинаются на указанную букву 
-- ----------------------------------------------------------------------
-- Решение:
delimiter //
CREATE PROCEDURE findAlbumsByLetter(in letter varchar(1) )
BEGIN
select AlbumTitle from Albums 
where AlbumTitle regexp concat("^", letter);
END //
delimiter ;

-- drop procedure findAlbumsByLetter;
call findAlbumsByLetter('E');

