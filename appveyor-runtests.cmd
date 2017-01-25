@chcp 65001

oscript -encoding=utf-8 main.os -runall tests xddReportPath tests

@if %ERRORLEVEL%==2 GOTO good_exit
@if %ERRORLEVEL%==0 GOTO good_exit

dir .\tests\

exit /B 1

:good_exit
dir .\tests\

exit /B 0