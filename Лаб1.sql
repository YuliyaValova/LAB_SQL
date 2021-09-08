
create database if not exists Открытия;

use Открытия;

create table if not exists Изобретатель (
Имя varchar(20),
Фамилия varchar(20),
Страна_рождения varchar(20)
);

create table if not exists Изобретение (
Код INT primary key auto_increment,
Название varchar(50),
Дата_изобретения year,
Описание varchar(250)
);

alter table Изобретатель
add Код INT primary key auto_increment;

create table if not exists Изобретатель_Изобретение (
Код_изобретателя INT,
Код_изобретения INT,
primary key (Код_изобретателя, Код_изобретения),
foreign key (Код_изобретателя) references Изобретатель(Код),
foreign key (Код_изобретения) references Изобретение (Код)
);

alter table Изобретатель
rename column Страна_рождения to Страна;

alter table Изобретение
modify column Описание text;

alter table Изобретение
drop column Дата_изобретения;

drop table Изобретатель_Изобретение;

drop database Открытия;

