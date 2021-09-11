create database if not exists Космос;
use Космос;
create table if not exists Звезды(
Код int primary key,
Название_звезды varchar(30),
Созвездие varchar(30),
Класс_спектра varchar(3),
Температура int, 
Масса real, 
Радиуc real,
Расстояние real	, 
АбсВеличина real,
ВидВеличина real
);
INSERT Звезды(Код, Название_звезды, Созвездие, Класс_спектра,Температура, Масса, Радиуc, Расстояние, АбсВеличина, ВидВеличина)
VALUES (1,'Альдебаран', 'Телец', 'M', 3500, 5, 45, 68, -0.63, 0.85);

select * FROM Звезды;

INSERT  Звезды(Код, Название_звезды, Созвездие, Класс_спектра,Температура, Масса, Радиуc, Расстояние, АбсВеличина, ВидВеличина)
VALUES
(2,'Гакрукс','Южный_крест', 'M',	3400, 3, 113, 88, -0.56, 1.59),
(3,'Полярная',	'Малая_Медведица',	'F',	7000,	6,	30,	430	, -3.6,	1.97),
(4,'Беллатрикс',	'Орион',	'B',	22000,	8.4,	6,	240,	-2.8,	1.64),
(5,'Арктур',	'Волопас',	'K',	4300,	1.25,	26,	37,	-0.28,	-0.05),
(6,'Альтаир',	'Орел',	'A',	8000,	1.7, 1.7,	360,	2.22,	0.77),
(7,'Антарес',	'Скорпион',	'K',	4000,	10,	880,	600,	-5.28,	0.96),
(8,'Ригель',	'Орион',	'B',	11000,	18,	75,	864,	-7.84,	0.12),
(9,'Бетельгейзе',	'Орион',	'M',	3100,	20,	900,	650,	-5.14,	1.51);

INSERT Звезды(Код, Название_звезды, Созвездие, Класс_спектра,Температура, Масса, Радиуc)
VALUES (10,	'Сириус', 	'Большой_Пес',	'A',	9900,	2,	1.7);

UPDATE Звезды
SET ВидВеличина = 1.4
WHERE Код = 10;

DELETE FROM Звезды
WHERE Код = 1;

-- 8 Изменить запись одним запросом. Для звезды Сириус установить значение Абсолютной звёздной величины = -1,46 и Расстояние до звезды = 8,6 (для успешного выполнения должен быть выключен safe mode).
UPDATE Звезды
SET АбсВеличина = -1.46, Расстояние = 8.6
WHERE Название_звезды = 'Сириус';


-- 9 Удалить запись, где название звезды Сириус (для успешного выполнения должен быть выключен safe mode).
DELETE FROM Звезды
WHERE Название_звезды = 'Сириус';

-- 10 Вывести поля: название звезды и температура, отсортировав по алфавиту “Название звезды”
SELECT Название_звезды, Температура FROM Звезды
ORDER BY Название_звезды;

-- 11 Вывести список звезд из созвездия Ориона
SELECT Название_звезды FROM Звезды
WHERE Созвездие = 'Орион';

-- 12 Вывести список звезд спектрального класса В из созвездия Ориона
SELECT Название_звезды FROM Звезды
WHERE Созвездие = 'Орион' and Класс_спектра = 'B';

-- 13 Вывести самую далекую звезду
SELECT Название_звезды FROM Звезды
WHERE Расстояние = (SELECT MAX(Расстояние) FROM Звезды);

-- 14 Вывести звезду с наименьшим радиусом
SELECT Название_звезды FROM Звезды
WHERE Радиуc = (SELECT MIN(Радиуc) FROM Звезды);

-- 15 Вывести среднюю температуру для каждого класса спектра
SELECT Класс_спектра, AVG(Температура) as AverageTemp FROM Звезды
GROUP BY Класс_спектра;

-- 16 Подсчитать количество звезд в каждом спектральном классе
SELECT Класс_спектра, COUNT(*) as Количество FROM Звезды
GROUP BY Класс_спектра;

-- 17 Какая суммарная масса звезд в таблице
SELECT SUM(Масса) as Суммарная_Масса FROM Звезды;

-- 18 Вывести минимальную температуру звезды спектрального класса “К”
select MIN(Температура) as Минимальная_темп from Звезды
where Класс_спектра ='K';

drop database if exists Космос;


