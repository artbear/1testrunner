[![Статус Порога Качества](https://sonar.openbsl.ru/api/project_badges/measure?project=1testrunner&metric=alert_status)](https://sonar.openbsl.ru/dashboard?id=1testrunner) [![Покрытие](https://sonar.openbsl.ru/api/project_badges/measure?project=1testrunner&metric=coverage)](https://sonar.openbsl.ru/dashboard?id=1testrunner) [![Строки кода](https://sonar.openbsl.ru/api/project_badges/measure?project=1testrunner&metric=ncloc)](https://sonar.openbsl.ru/dashboard?id=1testrunner) [![GitHub release](https://img.shields.io/github/release/artbear/1testrunner.svg)](https://github.com/artbear/1testrunner/releases) [![Build Status](http://build.oscript.io/buildStatus/icon?job=oscript-library/1testrunner/develop)](http://build.oscript.io/job/oscript-library/job/1testrunner/job/develop/) [![Build status](https://ci.appveyor.com/api/projects/status/7sgdu30u1yqbot4m?svg=true)](https://ci.appveyor.com/project/artbear/1testrunner) [![Build Status](https://travis-ci.org/artbear/1testrunner.svg)](https://travis-ci.org/artbear/1testrunner)

Организовано приемочное тестирование, аналогичное тестированию 1C в проекте [xUnitFor1C](https://github.com/xDrivenDevelopment/xUnitFor1C/wiki)

Основные принципы работы с тестами для скриптов OneScript описаны в [официальной документации OneScript](http://oscript.io/docs/page/testing)

# Использование тестирования (выдержка из документации OneScript)

## Пример запуска всех приемочных тестов ###

Проверить все файлы текущего каталога из командной строки (с паузой, если есть упавшие тесты):

    cmd /c C:\Projects\1script\tests\start-all.cmd .

Проверить все файлы текущего каталога из командной строки (без паузы, если есть упавшие тесты):

    1testrunner -runall "ТекущийКаталог" xddReportPath "ТекущийКаталог"

или

    cmd /c C:\Projects\1script\tests\start-all.cmd . notpause

## Запуск тестов ###

### Формат командной строки:

    1testrunner [-command] testfile|testdir [test-id|test-number] [-option [optionData]]

или

    oscript <каталог 1testrunner>/main.os [-command] testfile|testdir [test-id|test-number] [-option [optionData]]

### Виды команд

* `-show` - вывод доступных тестов с именами тестов и номерами тестов по порядку объявления
* `-run` - прогон всех тестов из файла теста или одного конкретного теста, уточненного по номеру или наименованию
* `-runall` - прогон всех тестов из каталога, в т.ч. и из вложенных каталогов

### Виды режимов

* `xddReportPath` - формировать отчет тестирования в формате junit-xml
* * [optionData] - полный или относительный путь к каталогу, где формировать файл *.xml

### Примеры:

* `1testrunner -show testfile` - вывод списка тестов
* `1testrunner testfile` или `1testrunner -run testfile` - запуск всех тестов из файла
* `1testrunner -run testfile 5` или `1testrunner testfile 5` - запуск теста №5
* `1testrunner -run testfile "Тест1"` или `1testrunner testfile "Тест1"`- запуск теста с именем Тест1

* `1testrunner -runall tests` - запуск всех тестов из каталога tests
* `1testrunner -runall tests xddReportPath .` - запуск всех тестов из каталога tests и формирование отчета тестирования в формате  junit-xml

### Формат скриптов-тестов

Тесты находятся в каталоге `tests`

Пример скрипта-теста находится в `tests\example-test.os` :

```bsl
#Использовать asserts

Перем юТест;

// основной метод для тестирования
Функция ПолучитьСписокТестов(ЮнитТестирование) Экспорт

	юТест = ЮнитТестирование;

	ВсеТесты = Новый Массив;

	ВсеТесты.Добавить("ТестДолжен_ПроверитьВерсию");

	Возврат ВсеТесты;
КонецФункции

Процедура ТестДолжен_ПроверитьВерсию() Экспорт
	Утверждения.ПроверитьРавенство("0.1", Версия());
КонецПроцедуры

Функция Версия() Экспорт
	Возврат "0.1";
КонецФункции
```

### Механизм работы с временными файлами

В `1testrunner` встроен механизм работы с временными файлами.
Удобен для автосоздания и автоудаления файлов после выполнения тестов.
Вызывать через `юТест`.

Методы:

* **ИмяВременногоФайла**() - возвращается имя временного файла и имя фиксируется для дальнейшего удаления
* **УдалитьВременныеФайлы**() - удаляются все зарегистрированные ранее временные файлы
* * Удобно этот метод использовать в 'ПослеЗапускаТеста'

Пример использования методов находятся в тесте temp-files.os

## Запуск тестирования из Notepad++

### Для прогона тестов из текущего открытого файла скрипта

в Notepad++ (в т.ч. и для плагина NppExec) можно использовать следующую команду:

    cmd.exe /c C:\Projects\1script\tests\start.cmd "$(FULL_CURRENT_PATH)"

или

    1testrunner -run "$(FULL_CURRENT_PATH)"

В случае ошибок в тестах/файле будет выдано окно консоли с описанием ошибки.

### Пример запуска всех приемочных тестов ###

    1testrunner -runall "$(CURRENT_DIRECTORY)"
