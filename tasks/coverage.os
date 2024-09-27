#Использовать ".."
#Использовать 1commands
#Использовать fs
#Использовать coverage

ИмяКаталогаФайловПокрытия = "coverage";
ИмяОбщегоФайлаПокрытия = "stat.json";
ШаблонИменФайловПокрытия = "*.json";

ФС.ОбеспечитьПустойКаталог(ИмяКаталогаФайловПокрытия);
ПутьКСтат = ОбъединитьПути(ИмяКаталогаФайловПокрытия, ИмяОбщегоФайлаПокрытия);

СистемнаяИнформация = Новый СистемнаяИнформация;
ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;

Команда = Новый Команда;
Команда.УстановитьКоманду("oscript");
Если НЕ ЭтоWindows Тогда
	Команда.ДобавитьПараметр("-encoding=utf-8");
КонецЕсли;
Команда.ДобавитьПараметр(СтрШаблон("-codestat=%1", ПутьКСтат));
Команда.ДобавитьПараметр("tasks/test.os coverage");
Команда.ПоказыватьВыводНемедленно(Истина);

КодВозврата = Команда.Исполнить();

Файл_Стат = Новый Файл(ПутьКСтат);

ПроцессорГенерации = Новый ГенераторОтчетаПокрытия();

ПроцессорГенерации.ОтносительныеПути()
				.РабочийКаталог(ИмяКаталогаФайловПокрытия)
				.ИмяФайлаСтатистики(ШаблонИменФайловПокрытия)
				.ФайлСтатистики(Файл_Стат.ПолноеИмя)
				.GenericCoverage()
				.Cobertura()
				.Сформировать();

ЗавершитьРаботу(КодВозврата);
