﻿//////////////////////////////////////////////////////////////////
// 
// Объект-помощник для приемочного и юнит-тестирования
//
//////////////////////////////////////////////////////////////////

#Использовать asserts
#Использовать tempfiles
#Использовать delegate

#Использовать "src"

Перем Пути;
Перем КомандаЗапуска;
Перем НаборТестов;
Перем РезультатТестирования;

Перем ПутьЛогФайлаJUnit;

Перем НомерТестаДляЗапуска;
Перем НаименованиеТестаДляЗапуска;

Перем Рефлектор;

Перем ЗначенияСостоянияТестов;
Перем СтруктураПараметровЗапуска;

Перем	НаборОшибок;
Перем	НаборНереализованныхТестов;

Перем	ВсегоТестов;
Перем	ВыводитьОшибкиПодробно;

Перем	Лог;

Перем МенеджерВременныхФайлов;

// Для поддержки добавления тестов при помощи метода ДобавитьТест()
Перем ВремМассивТестовыхСлучаев;

//////////////////////////////////////////////////////////////////////////////
// Программный интерфейс
//

// Получаю версию продукта
//
//  Возвращаемое значение:
//   Строка - номер версии в формате "1.2"
//
Функция Версия() Экспорт
	Возврат Константы_1testrunner.ВерсияПродукта;	
КонецФункции // Версия()

// Получить имя лога продукта
//
// Возвращаемое значение:
//  Строка   - имя лога продукта
//
Функция ИмяЛога() Экспорт
	Возврат "oscript.lib.1testrunner";
КонецФункции

Процедура ПодробныеОписанияОшибок(Знач ВключитьПодробноеОписание) Экспорт
	ВыводитьОшибкиПодробно = ВключитьПодробноеОписание;
КонецПроцедуры

Процедура ТестПройден() Экспорт
КонецПроцедуры

Процедура ТестПровален(ДопСообщениеОшибки) Экспорт
	СообщениеОшибки = "Тест провален." + ФорматДСО(ДопСообщениеОшибки);
	ВызватьИсключение(СообщениеОшибки);
КонецПроцедуры

//}

// { временные файлы
Функция ИмяВременногоФайла(Знач Расширение = "tmp") Экспорт
	Возврат МенеджерВременныхФайлов.НовоеИмяФайла(Расширение);
КонецФункции

Процедура УдалитьВременныеФайлы() Экспорт
	МенеджерВременныхФайлов.Удалить();
КонецПроцедуры
// }

//{ Выполнение тестов - экспортные методы

// Выполняет команду продукта по параметрам командной строки
//
// Параметры:
//   МассивПараметров - Массив - массив аргументов командной строки, аналогично АргументыКоманднойСтроки
//
Процедура ВыполнитьКоманду(Знач МассивПараметров) Экспорт
	Сообщить("1testrunner, ver. " + Версия());
	
	РезультатТестирования = ЗначенияСостоянияТестов.НеВыполнялся;
	
	Если Не ОбработатьПараметрыЗапуска(МассивПараметров) Тогда
		РезультатТестирования = ЗначенияСостоянияТестов.НеВыполнялся;
	КонецЕсли; 
	УдалитьВременныеФайлы();
КонецПроцедуры 

// Тестировать единичный файл теста
//
// Параметры:
//   ФайлТеста - Файл
//   ЛогФайлJUnit - Файл
//   НаименованиеТестаДляЗапуска - Строка - для запуска единственного теста из указанного файла
//   НомерТестаДляЗапуска - Число или Неопределено - для запуска единственного теста из указанного файла
//
//  Возвращаемое значение:
//   Строка - Результат тестирования
//
Функция ТестироватьФайл(Знач ФайлТеста, Знач ЛогФайлJUnit = Неопределено, Знач НаименованиеТестаДляЗапуска = Неопределено, 
		Знач НомерТестаДляЗапуска = Неопределено) Экспорт
	
	ПутьФайлаТеста = ФайлТеста.ПолноеИмя;
	УстановитьПутьЛогФайлаJUnit(ЛогФайлJUnit);

	ПроверитьСуществованиеФайла(ПутьФайлаТеста);

	КомандаЗапуска = СтруктураПараметровЗапуска.Запустить;

	Пути.Добавить(ПутьФайлаТеста);
	Лог.Отладка("Файл теста %1", ПутьФайлаТеста);
	
	ЗагрузитьТесты();

	ВыполнитьВсеТесты();

	СообщитьСтатусТестирования();
	
	Возврат РезультатТестирования;

КонецФункции // ТестироватьФайл

// Тестировать каталог тестов
//
// Параметры:
//   КаталогТестов - Файл
//   ЛогФайлJUnit - Файл
//
//  Возвращаемое значение:
//   Строка - Результат тестирования
//
Функция ТестироватьКаталог(Знач КаталогТестов, Знач ЛогФайлJUnit = Неопределено) Экспорт
	
	ПутьКаталогаТестов = КаталогТестов.ПолноеИмя;
	УстановитьПутьЛогФайлаJUnit(ЛогФайлJUnit);

	ПроверитьСуществованиеФайла(ПутьКаталогаТестов);

	КомандаЗапуска = СтруктураПараметровЗапуска.ЗапуститьКаталог;

	Лог.Отладка("Каталог тестов %1", ПутьКаталогаТестов);
	
	Файлы = НайтиФайлы(ПутьКаталогаТестов, "*.os");
	Для Каждого Файл Из Файлы Цикл
		Если Файл.ИмяБезРасширения <> "testrunner" Тогда
			Пути.Добавить(Файл.ПолноеИмя);
			Лог.Отладка("Файл теста %1", Файл.ПолноеИмя);
		КонецЕсли;
	КонецЦикла;
	
	ЗагрузитьТесты();

	ВыполнитьВсеТесты();
	
	СообщитьСтатусТестирования();
	
	Возврат РезультатТестирования;

КонецФункции // ТестироватьКаталог

// Получить результат тестирования
//
//  Возвращаемое значение:
//   Строка - Результат тестирования
//
Функция ПолучитьРезультатТестирования() Экспорт
	Возврат РезультатТестирования;
КонецФункции

//}

Функция ПолучитьПараметрыЗапуска(МассивПараметров)
	Перем ПутьЛогФайла;
	
	Если МассивПараметров.Количество() = 0 Тогда
		Лог.Отладка("Не заданы параметры запуска 1testrunner.");
		Возврат Неопределено;
	КонецЕсли;
	
	НомерТестаДляЗапуска = Неопределено;
	НаименованиеТестаДляЗапуска = Неопределено;
	ПутьЛогФайла = Неопределено;
	
	НомерПараметраПутьКТестам = -1;
	
	КомандаЗапуска = НРег(МассивПараметров[0]);
	Если КомандаЗапуска = СтруктураПараметровЗапуска.ПоказатьСписок Тогда
		ПутьКТестам = МассивПараметров[1];
	ИначеЕсли КомандаЗапуска = СтруктураПараметровЗапуска.Запустить Тогда
		НомерПараметраПутьКТестам = 1;
	ИначеЕсли КомандаЗапуска = СтруктураПараметровЗапуска.ЗапуститьКаталог Тогда
		НомерПараметраПутьКТестам = 1;
		
	Иначе
		КомандаЗапуска = СтруктураПараметровЗапуска.Запустить;
		НомерПараметраПутьКТестам = 0;
	КонецЕсли;

	НомерОчередногоПараметра = НомерПараметраПутьКТестам;
	
	Если КомандаЗапуска = СтруктураПараметровЗапуска.Запустить Тогда
		ПутьКТестам = МассивПараметров[НомерПараметраПутьКТестам];
		НомерОчередногоПараметра = НомерОчередногоПараметра + 1;
		Если МассивПараметров.Количество() > НомерОчередногоПараметра Тогда
			НомерОчередногоПараметра = НомерПараметраПутьКТестам+1;
			ИД_Теста = МассивПараметров[НомерОчередногоПараметра];

			Если НРег(ИД_Теста) <> СтруктураПараметровЗапуска.Режим_ПутьЛогФайла Тогда
				Если ВСтрокеСодержатсяТолькоЦифры(ИД_Теста) Тогда
					НомерТестаДляЗапуска = Число(ИД_Теста);
				Иначе
					НаименованиеТестаДляЗапуска = ИД_Теста;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли КомандаЗапуска = СтруктураПараметровЗапуска.ЗапуститьКаталог Тогда
		ПутьКТестам = МассивПараметров[НомерПараметраПутьКТестам];
		НомерОчередногоПараметра = НомерОчередногоПараметра + 1;
	КонецЕсли;
	
	Если МассивПараметров.Количество() > НомерОчередногоПараметра и (КомандаЗапуска = СтруктураПараметровЗапуска.Запустить или КомандаЗапуска = СтруктураПараметровЗапуска.ЗапуститьКаталог ) Тогда
		Режим = НРег(МассивПараметров[НомерОчередногоПараметра]);
		Если Режим = СтруктураПараметровЗапуска.Режим_ПутьЛогФайла Тогда
			Если МассивПараметров.Количество() > НомерОчередногоПараметра+1 Тогда
				НомерОчередногоПараметра = НомерОчередногоПараметра+1;
				ПутьЛогФайла = МассивПараметров[НомерОчередногоПараметра];
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	ПараметрыЗапуска = Новый Структура;
	ПараметрыЗапуска.Вставить("Команда", КомандаЗапуска);
	ПараметрыЗапуска.Вставить("ПутьКТестам", ПутьКТестам);
	ПараметрыЗапуска.Вставить("НаименованиеТестаДляЗапуска", НаименованиеТестаДляЗапуска);
	ПараметрыЗапуска.Вставить("НомерТестаДляЗапуска", НомерТестаДляЗапуска);
	ПараметрыЗапуска.Вставить("ПутьЛогФайлаJUnit", ПутьЛогФайла);

	Лог.Отладка("Команда %1", КомандаЗапуска);
	Лог.Отладка("ПутьКТестам %1", ПутьКТестам);
	Лог.Отладка("НаименованиеТестаДляЗапуска %1", НаименованиеТестаДляЗапуска);
	Лог.Отладка("НомерТестаДляЗапуска %1", НомерТестаДляЗапуска);
	Лог.Отладка("ПутьЛогФайлаJUnit %1", ПутьЛогФайлаJUnit);
	
	Возврат ПараметрыЗапуска;
КонецФункции

Функция ОбработатьПараметрыЗапуска(МассивПараметров)
	
	ПараметрыЗапуска = ПолучитьПараметрыЗапуска(МассивПараметров);
	Если Не ЗначениеЗаполнено(МассивПараметров) Тогда
		Возврат Ложь;
	КонецЕсли;
	КомандаЗапуска = ПараметрыЗапуска.Команда;
	ПутьКТестам = ПараметрыЗапуска.ПутьКТестам;
	НомерТестаДляЗапуска = ПараметрыЗапуска.НомерТестаДляЗапуска;
	НаименованиеТестаДляЗапуска = ПараметрыЗапуска.НаименованиеТестаДляЗапуска;
	ПутьЛогФайлаJUnit = ПараметрыЗапуска.ПутьЛогФайлаJUnit;
	
	Если КомандаЗапуска = СтруктураПараметровЗапуска.Запустить Тогда
		ТестироватьФайл(Новый Файл(ПутьКТестам), Новый Файл(ПутьЛогФайлаJUnit), НаименованиеТестаДляЗапуска, НомерТестаДляЗапуска);
		Возврат Истина;
	КонецЕсли;
	Если КомандаЗапуска = СтруктураПараметровЗапуска.ЗапуститьКаталог Тогда
		ТестироватьКаталог(Новый Файл(ПутьКТестам), Новый Файл(ПутьЛогФайлаJUnit));
		Возврат Истина;
	КонецЕсли;
	
	ПроверитьСуществованиеФайла(ПутьКТестам);

	Если КомандаЗапуска = СтруктураПараметровЗапуска.ПоказатьСписок Тогда
		Пути.Добавить(ПутьКТестам);
		Лог.Отладка("Файл теста %1", ПутьКТестам);
	КонецЕсли;
	
	Если КомандаЗапуска = СтруктураПараметровЗапуска.ПоказатьСписок Тогда
		Сообщить("Список тестов:");
	КонецЕсли;

	ЗагрузитьТесты();
	
	Возврат Истина;
КонецФункции

Процедура ПроверитьСуществованиеФайла(Знач ПутьКТестам)
	Файл = Новый Файл(ПутьКТестам);
	Если Не Файл.Существует() Тогда
		ВызватьИсключение "Не найден файл/каталог "+ПутьКТестам;
	КонецЕсли;
КонецПроцедуры

Функция СоздатьСтруктуруПараметровЗапуска()
	СтруктураПараметровЗапуска = Новый Структура;
	СтруктураПараметровЗапуска.Вставить("Запустить", НРег("-run"));
	СтруктураПараметровЗапуска.Вставить("ЗапуститьКаталог", НРег("-runall"));
	СтруктураПараметровЗапуска.Вставить("ПоказатьСписок", НРег("-show"));
	СтруктураПараметровЗапуска.Вставить("Режим_ПутьЛогФайла", НРег("xddReportPath"));
	Возврат СтруктураПараметровЗапуска;
КонецФункции

Функция ЗагрузитьТесты()
	Перем НомерТестаСохр;
	Перем Рез;
	
	Рез = Истина;
	
	Для Каждого ПутьТеста Из Пути Цикл
		Файл = Новый Файл(ПутьТеста);
		Если Файл.ЭтоКаталог() Тогда
			ВызватьИсключение "Пока не умею обрабатывать каталоги тестов";
		Иначе
			ПолноеИмяТестовогоСлучая = Файл.ПолноеИмя;
			ИмяКлассаТеста = СтрЗаменить(Файл.ИмяБезРасширения,"-","")+СтрЗаменить(Строка(Новый УникальныйИдентификатор),"-","");
			Если КомандаЗапуска = СтруктураПараметровЗапуска.ПоказатьСписок Тогда
				Сообщить("  Файл теста "+ПолноеИмяТестовогоСлучая);
			КонецЕсли;
			Попытка
				ПодключитьСценарий(Файл.ПолноеИмя, ИмяКлассаТеста);
				Тест = Новый(ИмяКлассаТеста);
			Исключение
				ИнфоОшибки = ИнформацияОбОшибке();
				Если ВыводитьОшибкиПодробно Тогда
					текстОшибки = ИнфоОшибки.ПодробноеОписаниеОшибки();
				Иначе
					текстОшибки = ОписаниеОшибки();
				КонецЕсли;
				Сообщить("Не удалось загрузить тест "+ПолноеИмяТестовогоСлучая+Символы.ПС+
					текстОшибки);
				Рез = Ложь;
				РезультатТестирования = ЗначенияСостоянияТестов.Сломался;
				Продолжить;
			КонецПопытки;
			Лог.Отладка("Подключили сценарий теста %1", ПолноеИмяТестовогоСлучая);

			МассивТестовыхСлучаев = ПолучитьТестовыеСлучаи(Тест, ПолноеИмяТестовогоСлучая);
			Если МассивТестовыхСлучаев = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			
			Для Каждого ТестовыйСлучай Из МассивТестовыхСлучаев Цикл
				Если ЭтоСтрока(ТестовыйСлучай) Тогда
					ИмяТестовогоСлучая = ТестовыйСлучай;
					ПараметрыТеста = Неопределено;
					ПредставлениеТеста = ИмяТестовогоСлучая;
				ИначеЕсли ТипЗнч(ТестовыйСлучай) = Тип("Структура")Тогда
					ИмяТестовогоСлучая = ТестовыйСлучай.ИмяТеста;
					ПараметрыТеста = ТестовыйСлучай.Параметры;
					ПредставлениеТеста = ТестовыйСлучай.Представление;
				Иначе
					ВызватьИсключение "Не умею обрабатывать описание тестового случая из ПолучитьСписокТестов, отличный от строки или структуры";
				КонецЕсли;
				
				Делегат = Делегаты.Создать(Тест, ИмяТестовогоСлучая, ПараметрыТеста);

				ОписаниеТеста = Новый Структура;
				ОписаниеТеста.Вставить("ТестОбъект", Тест);
				ОписаниеТеста.Вставить("Делегат", Делегат);
				ОписаниеТеста.Вставить("ИмяКласса", ИмяКлассаТеста);
				ОписаниеТеста.Вставить("ПолноеИмя", ПолноеИмяТестовогоСлучая);
				ОписаниеТеста.Вставить("ИмяМетода", ИмяТестовогоСлучая);
				ОписаниеТеста.Вставить("Представление", ПредставлениеТеста);

				НаборТестов.Добавить(ОписаниеТеста);
				
				НомерТеста = НаборТестов.Количество()-1;
				Если КомандаЗапуска = СтруктураПараметровЗапуска.ПоказатьСписок Тогда
					Сообщить("    Имя теста <"+ПредставлениеТеста+">, №теста <"+НомерТеста+">");

				ИначеЕсли КомандаЗапуска = СтруктураПараметровЗапуска.Запустить или КомандаЗапуска = СтруктураПараметровЗапуска.ЗапуститьКаталог Тогда
					Если НаименованиеТестаДляЗапуска = Неопределено Тогда
						Если НомерТеста = НомерТестаДляЗапуска Тогда
							НомерТестаСохр = НомерТеста;
						КонецЕсли;
					Иначе
						Если НРег(НаименованиеТестаДляЗапуска) = НРег(ИмяТестовогоСлучая) Тогда
							НомерТестаСохр = НомерТеста;
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;			
		КонецЕсли;
	КонецЦикла;
	
	Если НомерТестаСохр <> Неопределено Тогда
		ОписаниеТеста = НаборТестов[НомерТестаСохр];
		НаборТестов.Очистить();
		НаборТестов.Добавить(ОписаниеТеста);
	КонецЕсли;
	
	Возврат Рез;
КонецФункции

Функция ВыполнитьВсеТесты()
	Если НаборТестов.Количество() > 0 Тогда
		НаборОшибок = Новый Соответствие;
		НаборНереализованныхТестов = Новый Соответствие;
		ДатаНачала = ТекущаяДата();
		
		СоздаватьОтчетТестированияВФорматеJUnitXML = ЗначениеЗаполнено(ПутьЛогФайлаJUnit);
		Если СоздаватьОтчетТестированияВФорматеJUnitXML Тогда
			ЗаписьXML = Неопределено;
			НачатьЗаписьВФайлОтчетаТестированияВФорматеJUnitXML(ЗаписьXML);
		КонецЕсли;
		
		Для Сч = 0 По НаборТестов.Количество() - 1 Цикл
			ОписаниеТеста = НаборТестов[Сч];
			НовыйРезультатТестирования = ВыполнитьТест(ОписаниеТеста, Сч);		
			РезультатТестирования = ЗапомнитьСамоеХудшееСостояние(РезультатТестирования, НовыйРезультатТестирования);			
		КонецЦикла;
		
		ВывестиЛогТестирования();
		
		Если СоздаватьОтчетТестированияВФорматеJUnitXML Тогда
			ЗавершитьЗаписьВФайлОтчетаТестированияВФорматеJUnitXML(ЗаписьXML, ДатаНачала);
		КонецЕсли;
	КонецЕсли;
КонецФункции

Процедура СообщитьСтатусТестирования()
	Сообщить(" ");

	Если РезультатТестирования > ЗначенияСостоянияТестов.НеРеализован Тогда
		Сообщить("ОШИБКА: Есть непрошедшие тесты. Красная полоса", СтатусСообщения.Важное);
	ИначеЕсли РезультатТестирования > ЗначенияСостоянияТестов.Прошел Тогда
		Сообщить("ОШИБКА: Есть нереализованные тесты. Желтая полоса", СтатусСообщения.Внимание);
	Иначе
		Сообщить("ОК. Зеленая полоса", СтатусСообщения.Информация);
	КонецЕсли;
КонецПроцедуры

Процедура ВывестиЛогТестирования()
	пройденоТестов = НаборТестов.Количество() - НаборОшибок.Количество() - НаборНереализованныхТестов.Количество();
	
	Сообщить(" ");	
	Сообщить("------------------------------------------------------------");
	Сообщить("                       Общая статистика                     ");
	Сообщить("------------------------------------------------------------");
	
	Сообщить(" ");
	Сообщить("Тестов пройдено: " + пройденоТестов, СтатусСообщения.Информация);

	Сообщить(" ");
	Сообщить("Тестов не пройдено: " + НаборОшибок.Количество(), СтатусСообщения.Важное);
	Если НаборОшибок.Количество() > 0 Тогда
		Сч = 0;
		Для Каждого КлючЗначение Из НаборОшибок Цикл
			Сч = Сч + 1;
			ОписаниеТеста = КлючЗначение.Ключ;
			// СтруктураОшибки = КлючЗначение.Значение;
			Сообщить("    * " + ОписаниеТеста.Представление + " : <" + ОписаниеТеста.ПолноеИмя + ">");
		КонецЦикла;
	КонецЕсли;

	Сообщить(" ");
	Сообщить("Тестов не реализовано \ пропущено: " + НаборНереализованныхТестов.Количество(), СтатусСообщения.Внимание);		
	Если НаборНереализованныхТестов.Количество() > 0 Тогда
		Сч = 0;
		Для Каждого КлючЗначение Из НаборНереализованныхТестов Цикл
			Сч = Сч + 1;
			ОписаниеТеста = КлючЗначение.Ключ;
			Сообщить("    * " + ОписаниеТеста.ИмяМетода + " : <" + ОписаниеТеста.ПолноеИмя + ">");
		КонецЦикла;
	КонецЕсли;
		// .Вставить(ОписаниеТеста, СтруктураОшибки);
КонецПроцедуры

Процедура НачатьЗаписьВФайлОтчетаТестированияВФорматеJUnitXML(ЗаписьXML)
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.УстановитьСтроку("UTF-8");
	ЗаписьXML.ЗаписатьОбъявлениеXML();
	
КонецПроцедуры

Процедура ЗавершитьЗаписьВФайлОтчетаТестированияВФорматеJUnitXML(ЗаписьXML, ДатаНачала)
	Утверждения.ПроверитьНеРавенство(НаборТестов.Количество(), 0);
	
	ВсегоТестов = НаборТестов.Количество();
	КоличествоОшибок = НаборОшибок.Количество();
	КоличествоНереализованныхТестов = НаборНереализованныхТестов.Количество();
	
	ВремяВыполнения = ТекущаяДата() - ДатаНачала;
	
	ЗаписьXML.ЗаписатьНачалоЭлемента("testsuites");
	ЗаписьXML.ЗаписатьАтрибут("tests", XMLСтрока(ВсегоТестов));
	ЗаписьXML.ЗаписатьАтрибут("name", XMLСтрока("xUnitFor1C")); //TODO: указывать путь к набору тестов. 
	ЗаписьXML.ЗаписатьАтрибут("time", XMLСтрока(ВремяВыполнения));
	ЗаписьXML.ЗаписатьАтрибут("failures", XMLСтрока(КоличествоОшибок));
	ЗаписьXML.ЗаписатьАтрибут("skipped", XMLСтрока(КоличествоНереализованныхТестов)); // или disabled

	ЗаписьXML.ЗаписатьНачалоЭлемента("testsuite");	

	ФайлТестаВрем = Новый Файл(НаборТестов[0].ПолноеИмя);
	Если КомандаЗапуска = СтруктураПараметровЗапуска.Запустить Тогда
		ПутьНабора = ФайлТестаВрем.Имя;
	Иначе
		ПутьНабора = ФайлТестаВрем.Путь;
	КонецЕсли;
	ИмяНабора = ИмяТекущегоТеста(ПутьНабора);
	ФайлТеста = Новый Файл(ПутьНабора);
	
	ЗаписьXML.ЗаписатьАтрибут("name", ИмяНабора);
	
	ЗаписьXML.ЗаписатьНачалоЭлемента("properties");	
	ЗаписьXML.ЗаписатьКонецЭлемента();

	Для Каждого ОписаниеТеста Из НаборТестов Цикл
		ЗаполнитьРезультатТестовогоСлучая(ЗаписьXML, ОписаниеТеста, НаборОшибок, НаборНереализованныхТестов);
	КонецЦикла;	

	ЗаписьXML.ЗаписатьКонецЭлемента();
	
	СтрокаХМЛ = ЗаписьXML.Закрыть();

	ПутьОтчетаВФорматеJUnitxml = Новый Файл(ПутьФайлаОтчетаТестированияВФорматеJUnitXML()+"/"+ФайлТеста.Имя+".xml");
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.ОткрытьФайл(ПутьОтчетаВФорматеJUnitxml.ПолноеИмя);
	ЗаписьXML.ЗаписатьБезОбработки(СтрокаХМЛ);// таким образом файл будет записан всего один раз, и не будет проблем с обработкой на билд-сервере TeamCity
	ЗаписьXML.Закрыть();
	Сообщить(" ");
	Сообщить("Путь к лог-файлу проверки в формате Ant.JUnit <"+ПутьОтчетаВФорматеJUnitxml.ПолноеИмя+">");
	
КонецПроцедуры

Процедура ЗаполнитьРезультатТестовогоСлучая(ЗаписьXML, ОписаниеТеста, НаборОшибок, НаборНереализованныхТестов)
		
	ЗаписьXML.ЗаписатьНачалоЭлемента("testcase");
	ЗаписьXML.ЗаписатьАтрибут("classname", ИмяТекущегоТеста(ОписаниеТеста.ПолноеИмя));
	ЗаписьXML.ЗаписатьАтрибут("name", ОписаниеТеста.ИмяМетода);
	
	СтруктураОшибки		= НаборОшибок.Получить(ОписаниеТеста);
	
	Если СтруктураОшибки = Неопределено Тогда
		СтруктураОшибки		= НаборНереализованныхТестов.Получить(ОписаниеТеста);
	КонецЕсли;
	
	Если СтруктураОшибки <> Неопределено Тогда
		СтрокаРезультат = ?(СтруктураОшибки.СостояниеВыполнения = ЗначенияСостоянияТестов.Сломался, "failure", "skipped");
		
		ЗаписьXML.ЗаписатьАтрибут("status", СтрокаРезультат);
		ЗаписьXML.ЗаписатьНачалоЭлемента(СтрокаРезультат);

		СтрокаОписание = СтруктураОшибки.Описание;
		// TODO: НайтиНедопустимыеСимволыXML()
		XMLОписание = XMLСтрока(СтрокаОписание); 
		ЗаписьXML.ЗаписатьАтрибут("message", XMLОписание);
		
		ЗаписьXML.ЗаписатьКонецЭлемента();
	Иначе
		ЗаписьXML.ЗаписатьАтрибут("status", "passed");
	КонецЕсли;
	
	ЗаписьXML.ЗаписатьКонецЭлемента();
	
КонецПроцедуры

Функция ПутьФайлаОтчетаТестированияВФорматеJUnitXML()
	Возврат ?(ЗначениеЗаполнено(ПутьЛогФайлаJUnit), ПутьЛогФайлаJUnit, ТекущийКаталог());
КонецФункции

Функция ИмяТекущегоТеста(ПолныйПуть)
	Файл = Новый Файл(ПолныйПуть);
	Возврат Файл.ИмяБезРасширения;
КонецФункции

Функция ВыполнитьТест(ОписаниеТеста, Сч)
	Перем Рез;
	
	Тест = ОписаниеТеста.ТестОбъект;
	ИмяМетода = ОписаниеТеста.ИмяМетода;
	
	Успешно = ВыполнитьПроцедуруТестовогоСлучая(Делегаты.Создать(Тест, "ПередЗапускомТеста"), ИмяМетода, ОписаниеТеста);
	Если Не Успешно Тогда
		Рез = ЗначенияСостоянияТестов.Сломался;
	Иначе
		Если Не Рефлектор.МетодСуществует(Тест, ИмяМетода) Тогда
			ПоказатьИнформациюПоТесту(ОписаниеТеста, Сч, ИмяМетода);
			Рез = ВывестиОшибкуВыполненияТеста(ЗначенияСостоянияТестов.НеРеализован, "Не найден тестовый метод "+ ИмяМетода, ОписаниеТеста, "", Неопределено);
			Сообщить("  ");
		Иначе
			Попытка
				ОписаниеТеста.Делегат.Исполнить();
				
				Рез = ЗначенияСостоянияТестов.Прошел;
			Исключение
				ПоказатьИнформациюПоТесту(ОписаниеТеста, Сч, ИмяМетода);
				ИнфоОшибки = ИнформацияОбОшибке();
				текстОшибки = ПодробноеПредставлениеОшибки(ИнфоОшибки);
				Если ВыводитьОшибкиПодробно Тогда
					текстОшибки = ИнфоОшибки.ПодробноеОписаниеОшибки();
				КонецЕсли;
				Рез = ВывестиОшибкуВыполненияТеста(ЗначенияСостоянияТестов.Сломался, "", ОписаниеТеста, текстОшибки, ИнфоОшибки);
				Сообщить("  ");
			КонецПопытки;
		КонецЕсли;
		
		Успешно = ВыполнитьПроцедуруТестовогоСлучая(Делегаты.Создать(Тест, "ПослеЗапускаТеста"), ИмяМетода, ОписаниеТеста);
		Если Не Успешно Тогда
			Рез = ЗначенияСостоянияТестов.Сломался;
		КонецЕсли;
	КонецЕсли;

	Возврат Рез;	
КонецФункции

Функция ВывестиОшибкуВыполненияТеста(СостояниеВыполнения, ПредставлениеОшибки, ОписаниеТеста, текстОшибки, ИнфоОшибки)
	ИмяМетода = ОписаниеТеста.ИмяМетода;

	сообщение = ?(ПредставлениеОшибки="", "", ПредставлениеОшибки + Символы.ПС) + 
		"Тест: <" + ИмяМетода + ">"  + Символы.ПС +
		"Файл: <" + ОписаниеТеста.ПолноеИмя + "> " + Символы.ПС + 
		"Сообщение: " + текстОшибки;
	Если СостояниеВыполнения = ЗначенияСостоянияТестов.НеРеализован Тогда
		ВывестиПредупреждение(сообщение);
	Иначе
		ВывестиОшибку(сообщение);
	КонецЕсли;
	
	СтруктураОшибки = Новый Структура();
	
	СтруктураОшибки.Вставить("ИмяТестовогоНабора", ИмяМетода);
	
	стИнфоОшибки = Новый Структура("СостояниеВыполнения,ИмяМодуля,ИсходнаяСтрока,НомерСтроки,Описание");
	Если ИнфоОшибки <> Неопределено Тогда
		ЗаполнитьЗначенияСвойств(стИнфоОшибки, ИнфоОшибки);
	КонецЕсли;
	стИнфоОшибки.Вставить("Причина",  Неопределено);
	
	стИнфоОшибкиЦикл = стИнфоОшибки;
	Если ИнфоОшибки <> Неопределено Тогда
		ИнфоОшибки = ИнфоОшибки.Причина;
	КонецЕсли;
	Пока ИнфоОшибки <> Неопределено Цикл
		стИнфоОшибкиЦикл.Причина = Новый Структура("ИмяМодуля,ИсходнаяСтрока,НомерСтроки,Описание");
		стИнфоОшибкиЦикл = стИнфоОшибкиЦикл.Причина;
		ЗаполнитьЗначенияСвойств(стИнфоОшибкиЦикл, ИнфоОшибки);
		стИнфоОшибкиЦикл.Вставить("Причина",  Неопределено);

		ИнфоОшибки = ИнфоОшибки.Причина;
	КонецЦикла;
	
	ИмяТестовогоСлучаяДляОписанияОшибки = ИмяМетода;
	
	СтруктураОшибки.Вставить("ИмяТестовогоСлучая", ИмяТестовогоСлучаяДляОписанияОшибки);
	СтруктураОшибки.Вставить("СостояниеВыполнения",  СостояниеВыполнения);
	
	СтруктураОшибки.Вставить("Описание",              текстОшибки);
	СтруктураОшибки.Вставить("ИнфоОшибки",            стИнфоОшибки);
	СтруктураОшибки.Вставить("ПолныйПуть",            ОписаниеТеста.ПолноеИмя);
	
	Если СостояниеВыполнения = ЗначенияСостоянияТестов.Сломался Тогда
		НаборОшибок.Вставить(ОписаниеТеста, СтруктураОшибки);
	Иначе
		НаборНереализованныхТестов.Вставить(ОписаниеТеста, СтруктураОшибки);
	КонецЕсли;
	
	Возврат СостояниеВыполнения;
	
КонецФункции

Функция ВыполнитьПроцедуруТестовогоСлучая(Делегат, ИмяТестовогоСлучая, ОписаниеТеста)
	Успешно = Ложь;

	ИмяПроцедуры = Делегат.ИмяМетода();
	
	ПолноеИмя = ОписаниеТеста.ПолноеИмя;
	Попытка
		Делегат.Исполнить();
		Успешно = Истина;
	Исключение
		ИнфоОшибки = ИнформацияОбОшибке();
		текстОшибки = ОписаниеОшибки();
		
		Если ЕстьОшибка_МетодОбъектаНеОбнаружен(текстОшибки, ИмяПроцедуры) Тогда
			Успешно = Истина;
		Иначе
			Рез = ВывестиОшибкуВыполненияТеста(ЗначенияСостоянияТестов.Сломался, "Упал метод "+ИмяПроцедуры, ОписаниеТеста, текстОшибки, ИнфоОшибки);
		КонецЕсли;
	КонецПопытки;

	Возврат Успешно;
КонецФункции

Функция ПолучитьПредставлениеТестовогоСлучая(ИмяТеста, СтруктураПараметров)
	Если ТипЗнч(СтруктураПараметров) <> Тип("Структура") Тогда
		Возврат ИмяТеста;
	КонецЕсли;
	СтрПараметры = "";
	Разделитель = "";
	Для каждого ЭлементСтруктуры из СтруктураПараметров Цикл
		СтрПараметры = СтрПараметры + Разделитель + СтрШаблон("%1:""%2""", ЭлементСтруктуры.Ключ, Строка(ЭлементСтруктуры.Значение));
		Разделитель = ", ";
	КонецЦикла;
	Если СтрДлина(СтрПараметры) > 100 Тогда
		СтрПараметры = Лев(СтрПараметры, 97) + "...";
	КонецЕсли;
	Возврат СтрШаблон("%1{%2}", ИмяТеста, СтрПараметры);
КонецФункции

Процедура ДобавитьТест(ИмяТестовогоСлучая, СтруктураПараметров=Неопределено, Представление="") Экспорт
	ВремМассивТестовыхСлучаев.Добавить(Новый Структура("ИмяТеста,Параметры,Представление", 
		ИмяТестовогоСлучая, 
		СтруктураПараметров, 
		?(ПустаяСтрока(Представление), ПолучитьПредставлениеТестовогоСлучая(ИмяТестовогоСлучая, СтруктураПараметров), Представление)
	));
КонецПроцедуры

Функция ПолучитьТестовыеСлучаи(ТестОбъект, ПолноеИмяОбъекта)

	Попытка

		МассивТестовыхСлучаев = ПрочитатьТестовыеСлучаиОбъекта(ТестОбъект, ЭтотОбъект);

	Исключение
		ВывестиОшибку("Набор тестов не загружен: " + ПолноеИмяОбъекта + "
		|	Ошибка получения списка тестовых случаев: " + ОписаниеОшибки());	
		Возврат Неопределено;			
	КонецПопытки;

	Лог.Отладка("Получили массив тестовых случаев теста %1", ПолноеИмяОбъекта);

	Если ТипЗнч(МассивТестовыхСлучаев) <> Тип("Массив") Тогда
		
		ВывестиОшибку("Набор тестов не загружен: " + ПолноеИмяОбъекта + "
				|	Ошибка получения списка тестовых случаев: вместо массива имен тестовых случаев получен объект <" + Строка(ТипЗнч(МассивТестовыхСлучаев)) + ">");
		ТестОбъект = Неопределено;
		Возврат Неопределено;			
		
	КонецЕсли;
	
	Если НЕ ПроверитьМассивТестовыхСлучаев(МассивТестовыхСлучаев, ТестОбъект, ПолноеИмяОбъекта) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат МассивТестовыхСлучаев;
		
КонецФункции

Функция ПроверитьМассивТестовыхСлучаев(МассивТестовыхСлучаев, ТестОбъект, ПолноеИмяОбъекта)
	Для каждого данныеТеста из МассивТестовыхСлучаев Цикл
		Если ТипЗнч(данныеТеста) = Тип("Строка") Тогда
			Лог.Отладка("Имя теста: %1", данныеТеста);
			Продолжить;
		КонецЕсли;
		
		Если ТипЗнч(данныеТеста) <> Тип("Структура") Тогда
			ВывестиОшибку("Набор тестов не загружен: " + ПолноеИмяОбъекта + "
			|	Ошибка получения структуры описания тестового случая: " + ОписаниеОшибки());
			Возврат Ложь;
		КонецЕсли;
		Если НЕ данныеТеста.Свойство("ИмяТеста") Тогда
			ВывестиОшибку("Набор тестов не загружен: " + ПолноеИмяОбъекта + "
			|	Не задано имя теста в структуре описания тестового случая: " + ОписаниеОшибки());
			Возврат Ложь;
		КонецЕсли;
		Лог.Отладка("Имя теста: %1", данныеТеста.ИмяТеста);
	КонецЦикла;
	Возврат Истина;
КонецФункции

Функция ЕстьОшибка_МетодОбъектаНеОбнаружен(текстОшибки, имяМетода)
	Результат = Ложь;
	Если Найти(текстОшибки, "Метод объекта не обнаружен ("+имяМетода+")") > 0 
		ИЛИ Найти(текстОшибки, "Object method not found ("+имяМетода+")") > 0  Тогда
		Результат = Истина;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

Процедура ПоказатьИнформациюПоТесту(ОписаниеТеста, Знач Номер, Знач Тест)
	Сообщить("---------------------------------------------------------");
	Сообщить(" ");
	Сообщить("Тест №" + Строка(Номер) + ": " + Тест);
	Сообщить(" ");
КонецПроцедуры

// Устанавливает новое текущее состояние выполнения тестов
// в соответствии с приоритетами состояний:
// 		Красное - заменяет все другие состояния
// 		Желтое - заменяет только зеленое состояние
// 		Зеленое - заменяет только серое состояние (тест не выполнялся ни разу).
Функция ЗапомнитьСамоеХудшееСостояние(ТекущееСостояние, НовоеСостояние)
	
	ТекущееСостояние = Макс(ТекущееСостояние, НовоеСостояние);
	Возврат ТекущееСостояние;
	
КонецФункции

Функция ПредставлениеПериода(ДатаНачала, ДатаОкончания, ФорматнаяСтрока = Неопределено)
	Возврат "с "+ДатаНачала+" по "+ДатаОкончания;
КонецФункции

Функция ЭтоСтрока(Значение)
	Возврат Строка(Значение) = Значение;
КонецФункции

Функция ФорматДСО(ДопСообщениеОшибки)
	Если ДопСообщениеОшибки = "" Тогда
		Возврат "";
	КонецЕсли;
	
	Возврат Символы.ПС + ДопСообщениеОшибки;
КонецФункции

Функция ВСтрокеСодержатсяТолькоЦифры(Знач ИсходнаяСтрока)
	
	рез = Ложь;
	ДлинаСтроки = СтрДлина(ИсходнаяСтрока);
	Для Сч = 1 По ДлинаСтроки Цикл
		ТекущийСимвол = КодСимвола(Сред(ИсходнаяСтрока, Сч, 1));
		Если 48 <= ТекущийСимвол И ТекущийСимвол <= 57 Тогда
			рез = Истина;
		Иначе
			рез = Ложь;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	Возврат рез;	
КонецФункции

Процедура УстановитьПутьЛогФайлаJUnit(Знач ЛогФайлJUnit)
	Если ЛогФайлJUnit = Неопределено Тогда
		ПутьЛогФайлаJUnit = Неопределено;
	Иначе
		ПутьЛогФайлаJUnit = ЛогФайлJUnit.ПолноеИмя;
	КонецЕсли;
КонецПроцедуры

// Возвращает фикс.структуру состояния тестовё
//
// Состояния тестов - ВАЖЕН порядок заполнения в мЗначенияСостоянияТестов, используется в ЗапомнитьСамоеХудшееСостояние
//
//  Возвращаемое значение:
// 		Ключ/Значение - "НеВыполнялся"		, -1; // код 0 используется в командной строке для показа нормального завершения
// 		Ключ/Значение - "Прошел"		, 0; // код 0 используется в командной строке для показа нормального завершения
// 		Ключ/Значение - "НеРеализован", 2;
// 		Ключ/Значение - "Сломался"	, 3;
//
Функция ЗначенияСостоянияТестов() Экспорт
	Если ЗначенияСостоянияТестов = Неопределено Тогда
		ЗначенияСостоянияТестов = Новый Структура;
		ЗначенияСостоянияТестов.Вставить("НеВыполнялся", -1);
		ЗначенияСостоянияТестов.Вставить("Прошел"		, 0); // код 0 используется в командной строке для показа нормального завершения
		ЗначенияСостоянияТестов.Вставить("НеРеализован", 2);
		ЗначенияСостоянияТестов.Вставить("Сломался"	, 3);
		
		ЗначенияСостоянияТестов = Новый ФиксированнаяСтруктура(ЗначенияСостоянияТестов);
	КонецЕсли;
	Возврат ЗначенияСостоянияТестов;
	//} Состояния тестов
КонецФункции

// Выводит сообщение. В тестах ВСЕГДА должна использоваться ВМЕСТО метода Сообщить().
// 

Функция ВывестиПредупреждение(Ошибка) Экспорт	
	
	НужныйТекстОшибки = Ошибка;
	
	ВывестиСообщение("ПРЕДУПРЕЖДЕНИЕ: " + НужныйТекстОшибки, СтатусСообщения.Внимание);

	Возврат НужныйТекстОшибки;	
КонецФункции

Функция ВывестиСообщение(ТекстСообщения, Статус = Неопределено) Экспорт	
	Если Статус = Неопределено Тогда
		Статус = СтатусСообщения.Обычное;
	КонецЕсли;
	
	Сообщить(ТекстСообщения, Статус);	
КонецФункции

// Вызывает исключение с заданным текстом ошибки для прерывания выполнения тестового случая.
// 
Функция ПрерватьТест(ТекстОшибки) Экспорт
	
	ВызватьИсключение ТекстОшибки;
	
КонецФункции

Функция ВывестиОшибку(Ошибка) Экспорт
	
	НужныйТекстОшибки = Ошибка;
	
	ВывестиСообщение("ОШИБКА: " + НужныйТекстОшибки, СтатусСообщения.Важное);

	Возврат НужныйТекстОшибки;
КонецФункции

// <Описание функции>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//
// Возвращаемое значение:
//   <Тип.Вид>   - <описание возвращаемого значения>
//
Функция ПрочитатьТестовыеСлучаиОбъекта(Знач ТестОбъект, Знач МенеджерТестирования)
	МассивТестовыхСлучаев = ПрочитатьТестовыеСлучаиОбъектаВызовомМетода(ТестОбъект, МенеджерТестирования);
	Если Неопределено <> МассивТестовыхСлучаев Тогда
		Возврат МассивТестовыхСлучаев;
	КонецЕсли;

	Возврат Неопределено;
КонецФункции

// <Описание функции>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//
// Возвращаемое значение:
//   <Тип.Вид>   - <описание возвращаемого значения>
//
Функция ПрочитатьТестовыеСлучаиОбъектаВызовомМетода(Знач ТестОбъект, Знач МенеджерТестирования)
	
	Если НЕ Рефлектор.МетодСуществует(ТестОбъект, "ПолучитьСписокТестов") Тогда
		Возврат Неопределено;
	КонецЕсли;

	// С помощью ПолучитьСписокТестов() можно определять список тестов двумя способами:
	//     * вернуть массив тестов из ПолучитьСписокТестов()
	//     * внутри ПолучитьСписокТестов() использовать ДобавитьТест() менеджера тестирования, который передается методу как параметр
	// Мы хотим получить единый список тестов, которые были установлены обоими способами
	// Объединим в один список тесты, установленные с помощью ДобавитьТест(), с возвращенными из ПолучитьСписокТестов()
	ВремМассивТестовыхСлучаев = Новый Массив;
	МассивТестовыхСлучаев = ТестОбъект.ПолучитьСписокТестов(МенеджерТестирования);
	Если ТипЗнч(МассивТестовыхСлучаев) = Тип("Массив") Тогда
		Для каждого ТестовыйСлучай из МассивТестовыхСлучаев Цикл
			ВремМассивТестовыхСлучаев.Добавить(ТестовыйСлучай);
		КонецЦикла;
	КонецЕсли;
	МассивТестовыхСлучаев = ВремМассивТестовыхСлучаев;
	ВремМассивТестовыхСлучаев = Неопределено;
	
	Возврат МассивТестовыхСлучаев;
КонецФункции

Процедура Инициализация()
    Лог = Логирование.ПолучитьЛог(ИмяЛога());

	ВыводитьОшибкиПодробно = Ложь;
	
	МенеджерВременныхФайлов = Новый МенеджерВременныхФайлов;

	Пути = Новый Массив;
	НаборТестов = Новый Массив;
	Рефлектор = Новый Рефлектор;

	ЗначенияСостоянияТестов();
	СоздатьСтруктуруПараметровЗапуска();
	
	РезультатТестирования = ЗначенияСостоянияТестов.НеВыполнялся;
КонецПроцедуры

Инициализация();
// Лог.УстановитьУровень(УровниЛога.Отладка);