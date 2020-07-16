@echo off
rem 
rem Copyright (c) 2020 Robert van den Breemen - released under MIT license - see the end of this file
rem 
rem Version  : 0.0.9
rem 
rem This script updates the version in your boilerplate. Based on the auto-increment output file.
rem Using the format as described by Semantic Version 2.0 format (Read more https://semver.org/)
rem Note: this script does not implement pre-release tagging at this point

setlocal EnableDelayedExpansion

rem ** next line defines file extentions that will be updated.
set ext_list=.ino .h .c .cpp .js .css .html .inc 

rem next line is the pattern for the "version" line, it will find it and update it.
set "sSearch=(?<pre>^\*\*.*Version..:.v)([0-9]\.[0-9]\.[0-9])(?<post>.*$)"
rem the replaced version text = "$[pre}%VERSION_ONLY%${post}"

rem lets check the directory and the filename
set sDirectory=%~1
set aDirectory=%~a1
set sFilenaam=%2

set Debug=
rem remove leading "." and ".." and "\" stick %cd% in front and add trailing "\" 
if defined Debug echo 0 !sDirectory!
if not defined sDirectory (
	set sDirectory=%cd%
	echo Updating current directory: [!sDirectory!]
)
if "%sDirectory%"=="."	set sDirectory=%cd%
if defined Debug echo 1 !sDirectory!
if "%sDirectory%"==".." set sDirectory=%cd%\!sDirectory!
if defined Debug echo 2 !sDirectory!
if "%sDirectory:~0,2%"==".." set sDirectory=%sDirectory:~2%
if defined Debug echo 3 !sDirectory!
if "%sDirectory:~0,1%"=="." set sDirectory=%sDirectory:~1%
if defined Debug echo 4 !sDirectory!
if "%sDirectory:~0,1%"=="\"	set sDirectory=!cd!!sDirectory!
if defined Debug echo 5 !sDirectory!
if not "%sDirectory:~-1%"=="\" set sDirectory=!sDirectory!\
if defined Debug echo 6 !sDirectory!
if not "%sDirectory:~1,1%"==":" set sDirectory=!cd!\!sDirectory!
if defined Debug echo 7 !sDirectory!
if defined Debug pause

call :directory-exist !sDirectory!
if errorlevel 1 (
	echo This [!sDirectory!] is not a directory.
	echo Maybe, you forgot how to use this script.
	echo.
	goto :explain-use
) 
pushd
cd !sDirectory!
rem we have liftoff, the directory exists.
rem next up, lets check if you gave us a version file.

rem :check-version-file 
rem If there is no file given as parameter, then print help text
if defined sFilenaam if not exist "!sDirectory!%sFilenaam%" (
	echo File [%sFilenaam%] does not exist the directory you try to process.
	echo To make this work, you do need a version-file created by my script.
	echo. 
	goto :explain-use
) 
if "!sFilenaam!"=="" set sFilenaam=version.h 
if not exist "!sDirectory!!sFilenaam!" (
	echo Missing a version header file to process in the directory.
	echo This only works if you use the version.h file created by my script.
	echo. 
	goto :explain-use
) else (
	set sFilenaam=version.h 
)

rem yeah, let's hunt for the version information next
call :lets-find-version "!sDirectory!" "!sFilenaam!"
goto :the-end

:explain-use
echo This script updates the version in the boilerplate of all files.
echo Usage: %0 ^<directory update^> [optional:^<filename of version.h^>] 
goto :eof

:lets-find-version 
rem Let's begin with finding the 
rem clear version numbers
set MAJOR=
set MINOR=
set PATCH=
set BUILD=
set PRERELEASE=
set VERSION=

set sFilenaam=%~2
set sDirectory=%~1

rem echo Parse "version file" for major.minor.patch-build values
for /F "usebackq delims=*" %%A in (!sDirectory!!sFilenaam!) do ( 
	call :parse %%A 
) 
goto :next

:parse
rem three parameters, if the second token is version related, then match and put in in the right verion
if [%2]==[_VERSION_MAJOR] set /a MAJOR=%3
if [%2]==[_VERSION_MINOR] set /a MINOR=%3 
if [%2]==[_VERSION_PATCH] set /a PATCH=%3 
if [%2]==[_VERSION_BUILD] set /a BUILD=%3 
if [%2]==[_VERSION_PRERELEASE] set PRERELEASE=%3
exit /b 0

rem continue here, once you have located the version details
:next
rem check if there is a proper version found
if defined MAJOR if defined MINOR if defined PATCH if BUILD goto :found-version

rem Something is wrong, abort abort abort...
echo Oops, failed to find a valid version number. I did find this: [%MAJOR%.%MINOR%.%PATCH%+%BUILD%]
goto :the-end

:found-version
rem this must be it then, next up, find those version boilerplates and update them all to the current version
call :findthem "!sDirectory!" "!sFilenaam!"
goto :the-end


:findthem
rem so now lets loop thru all files, and replace any boilerplate version numbers
rem loop thru all files (not without subdirectories) for %f in (.\*) do @echo %f

set sDirectory=%~1
set sFilenaam=%~2

rem initialize the version string, if prerelease label exists then use it.
set VERSION=%MAJOR%.%MINOR%.%PATCH%+%BUILD%
set _VERSION_ONLY=%MAJOR%.%MINOR%.%PATCH%
if defined PRERELEASE (
	set VERSION=%MAJOR%.%MINOR%.%PATCH%-%PRERELEASE%+%BUILD%
	set _VERSION_ONLY=%MAJOR%.%MINOR%.%PATCH%-%PRERELEASE%
)
echo In version file: [%sDirectory%] the version(/w build) is [%VERSION%] or (/wo build) [%_VERSION_ONLY%]


rem create a checkpoint
echo Commit changes here: [%cd%] 
git add %sDirectory%>nul 2>&1
git commit -a -q -m "before update %_VERSION_ONLY%">nul 2>&1
git tag auto-update-version >nul 2>&1

setlocal enableextensions enabledelayedexpansion

rem let's clear the parameters
set _PAD=
set _FILENAAM=
set _EXTENTION=
set _PAD_FILENAAM=

echo Finding files in [%sDirectory%] with these extentions [%ext_list%]

for /r "%sDirectory%" %%P in ("*") do (
	rem echo 1 %%~dP%%~pP %%~nP%%~xP %%~xP %%P
	set _PAD=!_PAD! "%%~dP%%~pP"
	set _FILENAAM=!_FILENAAM! "%%~nP%%~xP"
	set _EXTENTION=!_EXTENTION! "%%~xP"
	set _PAD_FILENAAM="!%%~dP%%~P!"
	rem echo 2 !_PAD! !_FILENAAM! !_EXTENTION! !_PAD_FILENAAM!
	call :skip_hidden_directory !_PAD!
	if errorlevel 0 call :find-extention !_PAD! !_FILENAAM! !_EXTENTION! !_PAD_FILENAAM!
	rem clean up after youself
	set _PAD=
	set _FILENAAM=
	set _EXTENTION=
	set _PAD_FILENAAM=
    ) 
	rem and put it back to git
	echo Git commit tag [%_VERSION_ONLY%]
	git add !_PAD!>nul 2>&1
	git commit -a -q -m "update version to %_VERSION_ONLY%">nul 2>&1
	git tag %_VERSION_ONLY%>nul 2>&1
	echo Done updating... 
	
	endlocal 
goto :the-end


rem ======= now some routines follow =======
:directory-exist
	set aDirectory=%~a1
	if (%aDirectory:~0,1%) == (d) exit /b 0
	exit /b 1
	
:skip_hidden_directory
	set aDirectory=%~a1
	if (%aDirectory%) == (d--h-------) exit /b 1
	exit /b 0
	
:find-extention
rem echo !_PAD! !_FILENAAM! !_EXTENTION! !_PAD_FILENAAM!
rem find the extensions 
set _PAD=%~1
set _FILENAAM=%~2
set _EXTENTION=%~3
set _PAD_FILENAAM=%~4

rem echo 2 %_PAD% %_FILENAAM% %_EXTENTION% %_PAD_FILENAAM%
rem pause 

if [%_EXTENTION%] == [] exit /b 0 

rem echo check against [%_EXTENTION%] against [%EXT_LIST%]
for %%E in (%EXT_LIST%) do (
	if [%_EXTENTION%] == [%%E] (
		call :replace-version %_PAD% %_FILENAAM% %_EXTENTION% %_PAD_FILENAAM%
	)
)

exit /b 0 


:replace-version 
rem find the extensions 
set _PAD=%~1
set _FILENAAM=%~2
set _EXTENTION=%~3
set _PAD_FILENAAM=%~4
set _line=0
   
rem make backup first
set $src=%_PAD_FILENAAM%
set $dst=%_PAD_FILENAAM%.tmp 

rem ** search and replace expressions **
rem set "search=(?<pre>^\*\*.*Version..:.v)([0-9]\.[0-9]\.[0-9])(?<post>.*$)"
set "search=%sSearch%"
set "replace=${pre}%_VERSION_ONLY%${post}"		

if defined Debug (echo "Updating: [%$src%] [%$dst%] [%search%] [%replace%]") else (echo Updating: %$src%)
rem pause
for /f "delims=" %%a in ('powershell -c "(get-content '%$src%') | foreach-object {$_ -replace '%search%', '%replace%'} | set-content '%$dst%'"') do echo %%a

rem if there is an updates ($dst) then move to ($src)
if exist %$dst% move /y %$dst% %$src% >NUL
exit /b 0 

:LCase
:UCase
rem Lower/Uppercase function for strings by Rob van der Woude
rem https://www.robvanderwoude.com/battech_convertcase.php
rem Converts to upper/lower case variable contents
rem Syntax: CALL :UCase _VAR1 _VAR2
rem Syntax: CALL :LCase _VAR1 _VAR2
rem _VAR1 = Variable NAME whose VALUE is to be converted to upper/lower case
rem _VAR2 = NAME of variable to hold the converted value
rem Note: Use variable NAMES in the CALL, not values (pass "by reference")

SET _UCase=A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
SET _LCase=a b c d e f g h i j k l m n o p q r s t u v w x y z
SET _Lib_UCase_Tmp=!%1!
IF /I "%0"==":UCase" SET _Abet=%_UCase%
IF /I "%0"==":LCase" SET _Abet=%_LCase%
FOR %%Z IN (%_Abet%) DO SET _Lib_UCase_Tmp=!_Lib_UCase_Tmp:%%Z=%%Z!
SET %2=%_Lib_UCase_Tmp%
exit /b 0 

rem Checking directory, found this by Eelco Ligtvoert: 
rem https://www.quora.com/How-can-I-check-if-the-folder-is-empty-or-not-in-batch-script
:ReportFolderState
call :CheckFolder "%~f1"
set RESULT=%ERRORLEVEL%
rem if %RESULT% equ 999 @echo Folder doesn't exist
rem if %RESULT% equ 1   @echo Not empty!
rem if %RESULT% equ 0   @echo Empty!
exit /b %result%
:CheckFolder
if not exist "%~f1" exit /b 999
for %%I in ("%~f1\*.*") do exit /b 1
exit /b 0

:the-end
rem go back to start
popd
rem clear version numbers
set MAJOR=
set MINOR=
set PATCH=
set BUILD=
set PRERELEASE=
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
