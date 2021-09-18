CREATE DATABASE L3;
USE L3;
CREATE TABLE `manuf` (
`IDM` int PRIMARY KEY,  
`name` varchar(20),  
`city` varchar(20));
INSERT INTO `manuf` VALUES 
(1,'Intel','Santa Clara'),
(2,'AMD','Santa Clara'),
(3,'WD','San Jose'),
(4,'seagete','Cupertino'),
(5,'Asus','Taipei'),
(6,'Dell','Round Rock');
CREATE TABLE `cpu` (
`IDC` int PRIMARY KEY ,
`IDM` int,
`Name` varchar(20),
`clock` decimal(5,2));
INSERT INTO `cpu` VALUES 
(1,1,'i5',3.20),
(2,1,'i7',4.70),
(3,2,'Ryzen 5',3.20),
(4,2,'Ryzen 7',4.70),
(5,NULL,'Power9',3.50);
CREATE TABLE `hdisk` (
`IDD` int PRIMARY KEY,
`IDM` int,
`Name` varchar(20),
`type` varchar(20),
`size` int);
INSERT INTO `hdisk` VALUES 
(1,3,'Green','hdd',1000),
(2,3,'Black','ssd',256),
(3,1,'6000p','ssd',256),
(4,1,'Optane','ssd',16);
CREATE TABLE `nb` (
`IDN` int PRIMARY KEY,
`IDM` int,
`Name` varchar(20),
`IDC` int,
`IDD` int);
INSERT INTO `nb` VALUES 
(1,5,'Zenbook',2,2),
(2,6,'XPS',2,2),
(3,9,'Pavilion',2,2),
(4,6,'Inspiron',3,4),
(5,5,'Vivobook',1,1),
(6,6,'XPS',4,1);

-- 3	Соединить таблицы Manuf и CPU через запятую без условия (Неявное соединение таблиц)
-- Решение:
select * from Manuf, cpu;

-- 4	Соединить таблицы Manuf и CPU через запятую с условием (Неявное соединение таблиц)
-- Решение:
select * from Manuf, Cpu
where Manuf.IDM = cpu.IDM;

-- 5	Соединить таблицы Manuf и CPU используя  INNER JOIN
-- Решение:
select * from Manuf
join Cpu on Manuf.IDM = cpu.IDM;

-- 6	Соединить таблицы Manuf и CPU используя  LEFT JOIN
-- Решение:
select * from Manuf
left join Cpu on Manuf.IDM = cpu.IDM;
 
-- 7	Соединить таблицы Manuf и CPU используя  RIGHT JOIN
-- Решение:
select * from Manuf
left join Cpu on Manuf.IDM = cpu.IDM;

-- 8	Соединить таблицы Manuf и CPU используя  CROSS  JOIN
-- Решение:
select * from Manuf
cross join Cpu;

-- ? Провести анализ  результатов соединения таблиц 3-8 заданий?
-- без where - сведение всех строк из двух таблиц
-- с where - логически связанное сведение строк в соответствии с условием
-- inner join явное связывание при определенном условии
-- left join - сопоставление строк двух таблиц, добавление всех строк левой таблицы, недостающие поля для правой таблицы заполняются NULL
-- right join - сопоставление строк двух таблиц, добавление всех строк правой таблицы, недостающие поля для левой таблицы заполняются NULL
-- cross join - каждая строка левой таблицы сопоставляется с каждой строкой правой таблицы

-- 9	Вывести название фирмы и модель диска. Список не должен содержать пустых значений (NULL)
-- Решение:
select Manuf.name, hdisk.name from Manuf
cross join hdisk on Manuf.IDM=hdisk.IDM;

-- 10	Вывести модель процессора и, если есть информация в БД, название фирмы
-- Решение:
select Cpu.Name, Manuf.name from Cpu
left join Manuf on cpu.IDM = Manuf.IDM;

-- 11	Вывести модели ноутбуков, у которых нет информации в базе данных о фирме изготовителе
-- Решение:
select nb.name from nb
left join Manuf on nb.IDM = Manuf.IDM
where Manuf.name is NULL and Manuf.city is NULL;

-- 12	Вывести модель ноутбука и название производителя ноутбука, название модели процессора, название модели диска
-- Решение:
select nb.name as NBname, Manuf.name as MANUFname, Cpu.name as CPUname, hdisk.name as DISKname from nb
left join Manuf on nb.IDM = Manuf.IDM
left join Cpu on nb.IDC = cpu.IDC
left join hdisk on nb.IDD = hdisk.IDD;

-- 13	Вывести модель ноутбука, фирму производителя ноутбука, а также для этой модели:	модель и название фирмы производителя процессора, модель и название фирмы производителя диска
-- Решение:
select nb.name as NBname, Manuf.name as MANUFname, cpu.name as CPUname, 
(select Manuf.name from Manuf where Manuf.IDM = cpu.IDM ) as CPUManuf, 
hdisk.name as DISKname, (select Manuf.name from Manuf where Manuf.IDM = hdisk.IDM )  as DiskManuf from nb
left join Manuf on nb.IDM = Manuf.IDM
left join Cpu on nb.IDC = cpu.IDC
left join hdisk on nb.IDD = hdisk.IDD;

-- 14	Вывести абсолютно все названия фирм в первом поле и все моделей процессоров во втором
-- Решение:
select Manuf.name, cpu.name from Manuf
left join cpu on Manuf.IDM = cpu.IDM
union
select Manuf.name, cpu.name from Manuf
right join cpu on Manuf.IDM = cpu.IDM;

 -- 15 Вывести название фирмы, которая производит несколько типов товаров
-- Решение:

select Manuf.name from Manuf
where ((select count(*) from cpu where IDM = Manuf.IDM)>0 and  (select count(*) from hdisk where IDM = Manuf.IDM)>0)
 or ((select count(*) from cpu where IDM = Manuf.IDM)>0 and  (select count(*) from nb where IDM = Manuf.IDM)>0)
 or ((select count(*) from hdisk where IDM = Manuf.IDM)>0 and  (select count(*) from nb where IDM = Manuf.IDM)>0);





