@echo off
rem 
rem Copyright (c) 2020 Robert van den Breemen - released under MIT license -
rem 
rem This script auto increment a header file, that can be included in your projects
rem Using the format as described by Semantic Version 2.0 format (Read more https://semver.org/)
rem Note: this script does not implement pre-release tagging at this point

setlocal EnableDelayedExpansion
set FILE=%1

rem If there is no file given as parameter, then print help text
if [%1]==[] (
	echo To auto increment build number and date stamp, just give filename
	echo Usage: %0 ^<filename^>
	goto end
)

rem Create timestamp
for /f %%x in ('wmic path win32_utctime get /format:list ^| findstr "="') do set %%x

set Month=0%Month%
set Month=%Month:~-2%
set Day=0%Day%
set Day=%Day:~-2%
set Hour=0%Hour%
set Hour=%Hour:~-2%
set Minute=0%Minute%
set Minute=%Minute:~-2%
set Second=0%Second%
set Second=%Second:~-2%

set TIMESTAMP=%Day%-%Month%-%Year%

rem clear version numbers
set MAJOR=
set MINOR=
set PATCH=
set BUILD=
set VERSION=

rem echo Parse %1 for major.minor.patch-build values
for /F "usebackq delims=*" %%A in (%file%) do ( 
	call :parse %%A 
) 
goto :next

:parse
rem three parameters, if the second token is version related, then match and put in in the right verion
if [%2]==[_VERSION_MAJOR] set /a MAJOR=%3
if [%2]==[_VERSION_MINOR] set /a MINOR=%3 
if [%2]==[_VERSION_PATCH] set /a PATCH=%3 
if [%2]==[_VERSION_BUILD] set /a BUILD=%3 
exit /b 0

:next
rem if there is no major.minor.patch set, then just setup the defaults
set VERSION=%MAJOR%.%MINOR%.%PATCH%+%BUILD%
echo Found version: %VERSION%
if [%VERSION%]==[..+] (
  echo Initializing %_file% to default values:
  set /a MAJOR=0
  set /a MINOR=0
  set /a PATCH=0
  set /a BUILD=0
  set VERSION=!MAJOR!.!MINOR!.!PATCH!+!BUILD!
  echo %VERSION%
)

rem now auto increment build number by 1
set /a BUILD=BUILD+1
set VERSION=%MAJOR%.%MINOR%.%PATCH%+%BUILD%
echo Increment build %BUILD%
echo Version is: %VERSION% 
  
rem write the version numbers out to the file
echo //The version number conforms to semver.org format>!FILE!
echo #define _VERSION_MAJOR !MAJOR!>>!FILE!
echo #define _VERSION_MINOR !MINOR!>>!FILE!  
echo #define _VERSION_PATCH !PATCH!>>!FILE!
echo #define _VERSION_BUILD !BUILD!>>!FILE!
echo #define _VERSION_DATE %TIMESTAMP%>>!FILE!
echo #define _VERSION_TIME %Hour%:%Minute%:%Second%>>!FILE!
echo #define _VERSION_ONLY %MAJOR%.%MINOR%.%PATCH%>>%FILE%
echo #define _VERSION_NOBUILD %MAJOR%.%MINOR%.%PATCH% (%TIMESTAMP%)>>%FILE%
echo #define _VERSION %VERSION% (%TIMESTAMP%)>>%FILE%

rem clear version numbers
set MAJOR=
set MINOR=
set PATCH=
set BUILD=
set VERSION=
set TIMESTAMP=

goto :eof

rem =================================================================================
rem MIT License
rem 
rem Copyright (c) 2020 Robert van den Breemen
rem 
rem Permission is hereby granted, free of charge, to any person obtaining a copy
rem of this software and associated documentation files (the "Software"), to deal
rem in the Software without restriction, including without limitation the rights
rem to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
rem copies of the Software, and to permit persons to whom the Software is
rem furnished to do so, subject to the following conditions:
rem 
rem The above copyright notice and this permission notice shall be included in all
rem copies or substantial portions of the Software.
rem 
rem THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
rem IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
rem FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
rem AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
rem LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
rem OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
rem SOFTWARE.
rem =================================================================================
