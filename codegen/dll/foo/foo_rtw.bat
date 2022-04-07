@echo off

call C:\Users\yilik\DOCUME~1\GitHub\emsdk\emsdk activate latest

cd .

if "%1"=="" ("C:\PROGRA~1\MATLAB\R2021b\bin\win64\gmake"  -j32 -f foo_rtw.mk all) else ("C:\PROGRA~1\MATLAB\R2021b\bin\win64\gmake"  -j32 -f foo_rtw.mk %1)
@if errorlevel 1 goto error_exit

exit /B 0

:error_exit
echo The make command returned an error of %errorlevel%
exit /B 1