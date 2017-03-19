#Использовать logos
#Использовать asserts
#Использовать 1commands

Перем юТест;
Перем Лог;

Перем ТекКаталогСохр;
Перем ИмяПакета;

Функция ПолучитьСписокТестов(ЮнитТестирование) Экспорт
	
	юТест = ЮнитТестирование;
	
	ВсеТесты = Новый Массив;
	
	ВсеТесты.Добавить("ТестДолжен_ПроверитьЗапускТестовЧерезСобранныйПакетБиблиотеки");

	Возврат ВсеТесты;
КонецФункции

Процедура ПередЗапускомТеста() Экспорт
	// ВключитьПоказОтладки();
	ТекКаталогСохр = ТекущийКаталог();
КонецПроцедуры

Процедура ПослеЗапускаТеста() Экспорт
	УстановитьТекущийКаталог(ТекКаталогСохр);
	ВременныеФайлы.Удалить();
КонецПроцедуры

Процедура ТестДолжен_ПроверитьЗапускТестовЧерезСобранныйПакетБиблиотеки() Экспорт
	ИмяПакета = "1testrunner";

	Константы = ЗагрузитьСценарий("src\Модули\Константы_1testrunner.os");
	ИмяСоздаваемогоПакета = СтрШаблон("%1-%2.ospx", ИмяПакета, Константы.ВерсияПродукта);
	ИмяВременногоКаталога = ВременныеФайлы.СоздатьКаталог();
	
	СобратьПакетВКаталоге(ИмяВременногоКаталога);
	
	УстановитьТекущийКаталог(ИмяВременногоКаталога);

	ФайлСобранногоПакета = НайтиФайлСобранногоПакета(ИмяСоздаваемогоПакета);
	КаталогУстановки = ВыполнитьЛокальнуюУстановкуСобранногоПакета(ФайлСобранногоПакета);

	УдалитьКопиюТекущегоТеста(КаталогУстановки);
	ВыполнитьТестированиеИзУстановленногоПакета(КаталогУстановки);
КонецПроцедуры

Процедура СобратьПакетВКаталоге(Знач ИмяВременногоКаталога)
	КодВозврата = ВыполнитьКоманду(СтрШаблон("call opm build %1 -out %2", ТекущийКаталог(), ИмяВременногоКаталога));
	Ожидаем.Что(КодВозврата, "СобратьПакетВКаталоге КодВозврата").Равно(0);
КонецПроцедуры

Функция НайтиФайлСобранногоПакета(Знач ИмяСоздаваемогоПакета)
	МассивФайлов = НайтиФайлы(".", ИмяСоздаваемогоПакета);
	Ожидаем.Что(МассивФайлов, СтрШаблон("Должны были найти созданный пакет %1, но не нашли", ИмяСоздаваемогоПакета)).ИмеетДлину(1);
	Файл = МассивФайлов[0];
	Ожидаем.Что(Файл.Существует(), СтрШаблон("Созданный пакет %1 должен существовать, а это не так", ИмяСоздаваемогоПакета)).ЭтоИстина();
	Возврат Файл;
КонецФункции // НайтиФайлСобранногоПакета()

Функция ВыполнитьЛокальнуюУстановкуСобранногоПакета(Знач ФайлСобранногоПакета)
	ПутьКаталогаУстановки = "oscript_modules";
	ПутьИсполнителя = ОбъединитьПути(ПутьКаталогаУстановки, ИмяПакета, "testrunner.os");
	
	КодВозврата = ВыполнитьКоманду(СтрШаблон("call opm install -f %1 -l", ФайлСобранногоПакета.Имя));
	Ожидаем.Что(КодВозврата, "ВыполнитьЛокальнуюУстановкуСобранногоПакета КодВозврата").Равно(0);

	ФайлИсполнитель = Новый Файл(ПутьИсполнителя);
	Ожидаем.Что(ФайлИсполнитель.Существует(), СтрШаблон("Файл-исполнитель %1 должен существовать, а это не так", ПутьИсполнителя)).ЭтоИстина();
	Возврат Новый Файл(ПутьКаталогаУстановки);
КонецФункции

Процедура УдалитьКопиюТекущегоТеста(Знач КаталогУстановки)
	ФайлТекущегоТеста = Новый Файл(ТекущийСценарий().Источник);
	ФайлТекущегоТеста = Новый Файл(ОбъединитьПути(КаталогУстановки.ПолноеИмя, ИмяПакета, "tests", ФайлТекущегоТеста.Имя));
	ПутьТекущегоТеста = ФайлТекущегоТеста.ПолноеИмя;

	Ожидаем.Что(ФайлТекущегоТеста.Существует(), СтрШаблон("Файл текущего теста %1 должен существовать, а это не так", ПутьТекущегоТеста))
		.ЭтоИстина();
	
	УдалитьФайлы(ПутьТекущегоТеста);
	
	Ожидаем.Что(ФайлТекущегоТеста.Существует(), СтрШаблон("Файл текущего теста %1 не должен существовать, а он есть", ПутьТекущегоТеста))
		.ЭтоЛожь();
КонецПроцедуры

Процедура ВыполнитьТестированиеИзУстановленногоПакета(Знач КаталогУстановки)
	ТекстВывода = "";
	КодВозврата = ВыполнитьКоманду(СтрШаблон("call %1\bin\%2 -runall %1\%2\tests", КаталогУстановки.ПолноеИмя, ИмяПакета), ТекстВывода);
	Ожидаем.Что(КодВозврата, "ВыполнитьТестированиеИзУстановленногоПакета КодВозврата").Равно(0);
КонецПроцедуры

Функция ВыполнитьКоманду(Знач СтрокаКоманды, ТекстВывода = "")
	Команда = Новый Команда;
	
	Команда.УстановитьСтрокуЗапуска(СтрокаКоманды);

	КодВозврата = Команда.Исполнить();
	ТекстВывода = Команда.ПолучитьВывод();

	Если КодВозврата <> 0 Тогда
		Лог.Информация(ТекстВывода);
	КонецЕсли;
	Возврат КодВозврата;
КонецФункции

Процедура ВключитьПоказОтладки()
	Лог.УстановитьУровень(УровниЛога.Отладка);
КонецПроцедуры

Процедура ВыключитьПоказОтладки()
	Лог.УстановитьУровень(УровниЛога.Информация);
КонецПроцедуры

Функция КаталогТестовыхФикстур() Экспорт
	Возврат ОбъединитьПути(КаталогТестов(), "fixtures");
КонецФункции // КаталогИсходников()

Функция КаталогТестов() Экспорт
	Возврат ОбъединитьПути(КаталогИсходников(), "tests");
КонецФункции // КаталогИсходников()

Функция КаталогИсходников() Экспорт
	Возврат ОбъединитьПути(ТекущийСценарий().Каталог, "..");
КонецФункции // КаталогИсходников()

Лог = Логирование.ПолучитьЛог("1testrunner.tests");