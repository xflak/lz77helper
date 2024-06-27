@echo off
setlocal
pushd "%~dp0"
chcp 437>nul

::one way to get some compressed files to test, unpack a Wii system menu wad, then take it's largest content file and unpack further using "sharpii u8 -u", then in the html folder find the iplsetting.ash file and unpack again using the same command.

::Sourecode of Lz77Mii-OK.exe can be found in the following 3 lines (excluding colons), saved to au3 filetype then converted to exe using autoit v3's Aut2exe.exe; not used anymore
::WinWait ("Information","compressed file")
::WinActivate ("Information","compressed file")
::ControlClick ("Information","compressed file","Button1")


title LZ77 Helper
if exist MultiDrop.txt (attrib -h -r -s MultiDrop.txt) & (del MultiDrop.txt)
if exist queue.txt (attrib -h -r -s queue.txt) & (del queue.txt)
set mode=
set AutoExit=

if "%~1"=="" goto:error

::primary method, doesn't always work, need secondary method to fall back on later
setlocal enableDelayedExpansion
set "cmdinput=!cmdcmdline!"

::check for -args (if passed can only process 1 file\folder per command)
if /i "%~1" EQU "-D" goto:skipone
if /i "%~1" NEQ "-C" goto:skipargs
:skipone

::if %~1 is a function and not a dropped file, then revert to secondary method [set cmdinput=%*] primary method only works if calling the exe, not the bat
set cmdinput=%*
set "mode=%~1"
set choice=%mode:~1%
if /i "%choice%" EQU "C" set folderadd=-Compressed
if /i "%choice%" EQU "D" set folderadd=-Decompressed
set "cmdinput=%cmdinput:~3%"
::AutoExit=K default when in cmd line mode to keep running, if changed to E will exit
set AutoExit=K

if /i "%~2" NEQ "-E" goto:skipargs
set AutoExit=Y
set "cmdinput=%cmdinput:~3%"
:skipargs


::echo mode "%mode%"
::echo AutoExit "%AutoExit%"
::echo "%cmdinput%"



::remove bat name from cmdinput, appears sometimes depending how it's launched
set "cmdinput=!cmdinput:*%~f0=!"
::strip out unnecessary chars at start
set "cmdinput=!cmdinput:*" =!"
::remove quotes
set "cmdinput=!cmdinput:"=!"

::this fixes gibberish args, but maybe breaks other stuff?
if /i "%cmdinput:~1,1%" EQU "=" goto:error

setlocal DISABLEDELAYEDEXPANSION
::in some cases above method will yield "C:\Windows\System32\cmd.exe", for these fall back on secondary method
if /i "%cmdinput%" NEQ "%homedrive%\Windows\System32\cmd.exe" goto:skipfix
set cmdinput=%*
set "cmdinput=%cmdinput:"=%"
:skipfix


if "%cmdinput%"=="" goto:error

::add back missing title for -C and -K modes
if not "%mode%"=="" sfk echo [Red]LZ77 Helper, by XFlak


::multidrop support, insert line breaks to split different dragged files arguments

::add check for multiple files by searching for more 2 or more colons ":"
set "string=%cmdinput%"
set /a filecount=0
setlocal EnableDelayedExpansion
if defined string (set ^"strtmp=!string::=^
%= empty string =%
!^") else set "strtmp="
for /F %%C in ('cmd /V /C echo(^^!strtmp^^!^| find /C /V ""') do set /A "filecount=%%C-1"
setlocal DISABLEDELAYEDEXPANSION
::echo "!string!" contains %filecount% files
if %filecount% LSS 2 goto:notmulti

echo "%cmdinput%">"MultiDrop.txt"

sfk -spat filter "MultiDrop.txt" -rep _\x22__ -rep _" A:"_"\nA:"_ -rep _" B:"_"\nB:"_ -rep _" C:"_"\nC:"_ -rep _" D:"_"\nD:"_ -rep _" E:"_"\nE:"_ -rep _" F:"_"\nF:"_ -rep _" G:"_"\nG:"_ -rep _" H:"_"\nH:"_ -rep _" I:"_"\nI:"_ -rep _" J:"_"\nJ:"_ -rep _" K:"_"\nK:"_ -rep _" L:"_"\nL:"_ -rep _" M:"_"\nM:"_ -rep _" N:"_"\nN:"_ -rep _" O:"_"\nO:"_ -rep _" P:"_"\nP:"_ -rep _" Q:"_"\nQ:"_ -rep _" R:"_"\nR:"_ -rep _" S:"_"\nS:"_ -rep _" T:"_"\nT:"_ -rep _" U:"_"\nU:"_ -rep _" V:"_"\nV:"_ -rep _" W:"_"\nW:"_ -rep _" X:"_"\nX:"_ -rep _" Y:"_"\nY:"_ -rep _" Z:"_"\nZ:"_ -rep _"^^"_"^"_ -write -yes>nul
if exist MultiDrop.txt (attrib +h MultiDrop.txt) else (goto:notmulti)
set /p testme= <MultiDrop.txt
if not exist "%testme%" goto:error
::start support\subscripts\MultiDrop.exe

:multiprompt
set /a Item=0
::cls
sfk echo [Red]LZ77 Helper, by XFlak
echo.
echo Multiple items:
echo.

setlocal ENABLEDELAYEDEXPANSION
set /a TotalItems=0
for /F "tokens=*" %%A in (MultiDrop.txt) do call :process "%%A"

goto:skip
:process
set command=%*
set "command=!command:^^=^!"
set "command=!command:~1,-1!"
set /a TotalItems=%TotalItems%+1
echo %TotalItems%: "!command!"
goto:EOF
:skip


echo.
echo Would you like to save compressed or decompressed copies of these items (including subfolders if applicable)?
echo.
echo           C = Compress
echo           D = Decompress
echo           E = Exit
echo.
set choice=?
set /p choice=     Enter Selection Here: 


if /i "%choice%" EQU "E" exit
if /i "%choice%" EQU "C" (set folderadd=-Compressed) & (goto:next)
if /i "%choice%" EQU "D" (set folderadd=-Decompressed) & (goto:next)

echo You Have Entered an Incorrect Key
@ping 127.0.0.1 -n 2 -w 1000> nul
goto:multiprompt


:next

if /i "%Item%" NEQ "%TotalItems%" goto:skip
if exist MultiDrop.txt (attrib -h -r -s MultiDrop.txt) & (del MultiDrop.txt)
goto:fin
:skip

set /a Item=%Item%+1
sfk filter MultiDrop.txt -line=%Item% -+"?">"%temp%\LZ77temp.txt"
set /p cmdinput= <"%temp%\LZ77temp.txt"

echo.
sfk echo [Blue]Item %Item% of %TotalItems%: "!cmdinput!"
::goto:notmulti

:notmulti

::remove slash at the end of folder path if applicable
if /i "%cmdinput:~-1%" EQU "\" set "cmdinput=%cmdinput:~0,-1%"

set "cmdinputRaw=%cmdinput%"
set droptype=file
if exist "%cmdinput%\" set droptype=folder

set "file=%cmdinput:*\=%"
set "filepath=%cmdinput%"
:stripfile
set "file=%file:*\=%"
echo "%file%">"%temp%\LZ77temp.txt"
findStr \\ "%temp%\LZ77temp.txt">nul
IF NOT ERRORLEVEL 1 goto:stripfile

echo set "filepath=%%filepath:%file%=%%">"%temp%\LZ77temp.bat"
call "%temp%\LZ77temp.bat"

set "filepath=%cmdinput%"
echo set "filepathback=%%filepath:\%file%=%%">"%temp%\LZ77temp.bat"
call "%temp%\LZ77temp.bat"

::echo file: "%file%"
::echo filepath: "%filepath%"
::echo filepathback: "%filepathback%"



if /i "%droptype%" EQU "folder" goto:folderprompt


::file


:fileprompt

::if MultiDrop.txt exists it means in multimode
if exist MultiDrop.txt goto:filemagic
if not "%mode%"=="" goto:filemagic

::sanity check for LZ77
set start=
if exist "%temp%\LZ77hexdump.txt" del "%temp%\LZ77hexdump.txt">nul
sfk hexdump -pure -nofile -offlen 0x00 0x04 "%cmdinputRaw%">"%temp%\LZ77hexdump.txt"
set /p start= <"%temp%\LZ77hexdump.txt"
::4C5A3737 is LZ77 in hex
::echo if "%start%" is 4C5A3737 it is already compressed

:fileprompt2

::cls
sfk echo [Red]LZ77 Helper, by XFlak
echo.
echo File input: "%cmdinputRaw%"
echo.
If /i "%start%" EQU "4C5A3737" sfk echo File is compressed; would you like to save a [Cyan]decompressed[def] copy of it?
If /i "%start%" NEQ "4C5A3737" sfk echo File is decompressed; would you like to save a [Cyan]compressed[def] copy of it?
echo.

If /i "%start%" EQU "4C5A3737" echo           Y = Yes; or "D" to Decompress
If /i "%start%" NEQ "4C5A3737" echo           Y = Yes; or "C" to Compress

echo           E = Exit
echo.
set choice=?
set /p choice=     Enter Selection Here: 

if /i "%choice%" EQU "E" exit

If /i "%start%" NEQ "4C5A3737" goto:skip
if /i "%choice%" EQU "D" (set folderadd=-Decompressed) & (goto:filemagic)
:skip

If /i "%start%" EQU "4C5A3737" goto:skip
if /i "%choice%" EQU "C" (set folderadd=-Compressed) & (goto:filemagic)
:skip

if /i "%choice%" NEQ "Y" goto:badkey
If /i "%start%" EQU "4C5A3737" (set choice=D) & (set folderadd=-Decompressed)
If /i "%start%" NEQ "4C5A3737" (set choice=C) & (set folderadd=-Compressed)
goto:filemagic


:badkey
echo You Have Entered an Incorrect Key
@ping 127.0.0.1 -n 2 -w 1000> nul
goto:fileprompt2


:filemagic
::cls
::sfk echo [Red]LZ77 Helper, by XFlak
::echo.
::echo File input: "%cmdinputRaw%"
echo.
if /i "%choice%" EQU "C" echo Saving Compressed copy to:
if /i "%choice%" EQU "D" echo Saving Decompressed copy to:


::support for extensions with 4, 3 and 2, largest on top and smallest on the bottom to properly capture files like test....js should they ever be encountered
set newfile=%cmdinputRaw%%folderadd%
If /i "%cmdinputRaw:~-5,1%" EQU "." set "newfile=%cmdinputRaw:~0,-5%%folderadd%%cmdinputRaw:~-5%"
If /i "%cmdinputRaw:~-4,1%" EQU "." set "newfile=%cmdinputRaw:~0,-4%%folderadd%%cmdinputRaw:~-4%"
If /i "%cmdinputRaw:~-3,1%" EQU "." set "newfile=%cmdinputRaw:~0,-3%%folderadd%%cmdinputRaw:~-3%"
::set "newfile=%filepathback%%folderadd%\%file%"
::if not exist "%filepathback%%folderadd%" mkdir "%filepathback%%folderadd%"
echo   "%newfile%"
echo.


if /i "%choice%" NEQ "C" goto:decompressfile
::---compress---
::start Lz77Mii-OK.exe
::Lz77Mii.exe -in "%cmdinputRaw%" -out "%newfile%" -compress


::sanity check for LZ77
set start=
if exist "%temp%\LZ77hexdump.txt" del "%temp%\LZ77hexdump.txt">nul
sfk hexdump -pure -nofile -offlen 0x00 0x04 "%cmdinputRaw%">"%temp%\LZ77hexdump.txt"
set /p start= <"%temp%\LZ77hexdump.txt"
::4C5A3737 is LZ77 in hex
::echo "%start%" should NOT be 4C5A3737
If /i "%start%" EQU "4C5A3737" (sfk echo [Yellow]File already LZ77 compressed, skipping...) & (goto:fin)

:skip

::To encode (compress): `LZ77` magic word needs to be added back at the start, `lzss -evn [filename]`
copy /y "%cmdinputRaw%" "%newfile%.part">nul


::pipe output and findstr "', WARNING:" without quotes to confirm
lzss.exe -evn "%newfile%.part">"%temp%\LZ77hexdump.txt"
findStr /I /C:"', WARNING:" "%temp%\LZ77hexdump.txt" >nul
IF not ERRORLEVEL 1 (sfk echo [Red]lzss.exe error...) & (echo.) & (del "%newfile%.part">nul) & (goto:fin)


::add back LZ77 magicword
sfk echo 4C5A3737 +hextobin "%temp%\LZ77LZ77.bin">nul

set pass=
copy /b /y "%temp%\LZ77LZ77.bin"+"%newfile%.part" "%newfile%">nul
If /i "%ERRORLEVEL%" EQU "0" set pass=Y

del "%newfile%.part">nul

If /i "%pass%" EQU "Y" goto:pass
::fail
if exist "%newfile%" del "%newfile%">nul
sfk echo [Red]Error: failed to add back LZ77
echo.
goto:fin

:pass
sfk echo [Green]Successfully compressed
echo.
goto:fin


:decompressfile
::---decompress---

::::while the below Lz77Mii.exe command also works for both compressing and decompressing, it's not as fast as GBAmdc.exe
::start Lz77Mii-OK.exe
::Lz77Mii.exe -in "%cmdinputRaw%" -out "%newfile%"

::::GBAmdc.exe deprecated too
::::GBAmdc -e [input file] [destination file] 4 (4 is an offset so it is cutting off magicword LZ77)
::GBAmdc.exe -e "%cmdinputRaw%" "%newfile%" 4


::Lzss.exe for LZ77 https://www.romhacking.net/utilities/826/
::`LZ77` needs to get removed first from the start of the file


::sanity check for LZ77
set start=
if exist "%temp%\LZ77hexdump.txt" del "%temp%\LZ77hexdump.txt">nul
sfk hexdump -pure -nofile -offlen 0x00 0x04 "%cmdinputRaw%">"%temp%\LZ77hexdump.txt"
set /p start= <"%temp%\LZ77hexdump.txt"
::4C5A3737 is LZ77 in hex
::echo "%start%" should be 4C5A3737
If /i "%start%" NEQ "4C5A3737" (sfk echo [Yellow]File not LZ77 compressed, skipping...) & (goto:fin)

:skip

::trim off first 4 bytes
sfk partcopy "%cmdinputRaw%" -allfrom 4 "%newfile%" -yes>nul
If /i "%ERRORLEVEL%" EQU "0" goto:afterTrim
::failed trim
sfk echo [Red]Error: failed to trim LZ77 from start of file
if exist "%newfile%" del "%newfile%">nul
goto:fin

:afterTrim

::pipe output and findstr "', WARNING:" without quotes to confirm
lzss.exe -d "%newfile%">"%temp%\LZ77hexdump.txt"

findStr /I /C:"', WARNING:" "%temp%\LZ77hexdump.txt" >nul
IF ERRORLEVEL 1 (sfk echo [Green]Successfully decompressed) & (echo.) & (goto:fin)

sfk echo [Red]lzss.exe error...
echo.
if exist "%newfile%" del "%newfile%">nul

goto:fin


:folderprompt

if exist queue.txt attrib -h -r -s queue.txt
dir /s /b /a-d "%filepath%">queue.txt
if exist queue.txt attrib +h queue.txt
set /p firstfile= <queue.txt

::if MultiDrop.txt exists it means in multimode
if exist MultiDrop.txt goto:foldermagic
if not "%mode%"=="" goto:foldermagic

::sanity check for LZ77 (just for first file)
set start=
if exist "%temp%\LZ77hexdump.txt" del "%temp%\LZ77hexdump.txt">nul
sfk hexdump -pure -nofile -offlen 0x00 0x04 "%firstfile%">"%temp%\LZ77hexdump.txt"
set /p start= <"%temp%\LZ77hexdump.txt"
::4C5A3737 is LZ77 in hex
::echo if "%start%" is 4C5A3737 it is already compressed

:folderprompt2
::cls
sfk echo [Red]LZ77 Helper, by XFlak
echo.
echo Folder input: "%cmdinputRaw%"
echo.

::If /i "%start%" EQU "4C5A3737" sfk echo Folder contents appear compressed; would you like to save a [Cyan]decompressed[def] copy of this folder (including subfolders)?
::If /i "%start%" NEQ "4C5A3737" sfk echo Folder contents appear decompressed; would you like to save a [Cyan]compressed[def] copy of this folder (including subfolders)?
::echo.
::echo           Y = Yes
::echo           E = Exit
echo Would you like to save a compressed or decompressed copy of this folder (including subfolders)?
echo.
If /i "%start%" EQU "4C5A3737" sfk echo Note: a file from this folder was sampled and looks [Cyan]compressed
If /i "%start%" NEQ "4C5A3737" sfk echo Note: a file from this folder was sampled and looks [Cyan]decompressed

echo.
echo           C = Compress
echo           D = Decompress
echo           E = Exit


echo.
set choice=?
set /p choice=     Enter Selection Here: 

if /i "%choice%" EQU "E" exit

if /i "%choice%" EQU "C" (set folderadd=-Compressed) & (goto:foldermagic)
if /i "%choice%" EQU "D" (set folderadd=-Decompressed) & (goto:foldermagic)

::if /i "%choice%" NEQ "Y" goto:badkey
::If /i "%start%" EQU "4C5A3737" (set choice=D) & (set folderadd=-Decompressed)
::If /i "%start%" NEQ "4C5A3737" (set choice=C) & (set folderadd=-Compressed)
::goto:foldermagic


:badkey
echo You Have Entered an Incorrect Key
@ping 127.0.0.1 -n 2 -w 1000> nul
goto:folderprompt2


:foldermagic
::cls
::sfk echo [Red]LZ77 Helper, by XFlak
::echo.
::echo Folder input: "%cmdinputRaw%"
echo.
if /i "%choice%" EQU "C" echo Saving Compressed copy to:
if /i "%choice%" EQU "D" echo Saving Decompressed copy to:
echo   "%filepath%%folderadd%"
echo.
if not exist "%filepath%%folderadd%" mkdir "%filepath%%folderadd%"

::create LZ77 magicword bin file just once instead of for each file
sfk echo 4C5A3737 +hextobin "%temp%\LZ77LZ77.bin">nul

::::queue.txt created previously
::if exist queue.txt attrib -h -r -s queue.txt
::dir /s /b /a-d "%filepath%">queue.txt
::if exist queue.txt attrib +h queue.txt


::line count
set /a TotalFiles=0
for /f %%a in (queue.txt) do set /a TotalFiles+=1

::echo %TotalFiles%

set /a counter=0

::Loop through the the following once for EACH line in *.txt, but respecting & ^ using !!
setlocal ENABLEDELAYEDEXPANSION
for /F "tokens=*" %%A in (queue.txt) do call :folderprocess "%%A"
goto:fin

:folderprocess
set CurrentFile=%*
set "CurrentFile=!CurrentFile:^^=^!"
set "CurrentFile=!CurrentFile:~1,-1!"
set /a counter=%counter%+1

echo set "filenameX=!!CurrentFile:%filepath%\=!!">"%temp%\LZ77temp.bat"
call "%temp%\LZ77temp.bat"
::echo filenameX: "!filenameX!"

sfk echo [Cyan]File %counter% of %TotalFiles%: "%filenameX%"




set "fileX=%filenameX:*\=%"
set "fileXpath=%filenameX%"
:stripfileX
set "fileX=%fileX:*\=%"
echo "%fileX%">"%temp%\LZ77temp.txt"
findStr \\ "%temp%\LZ77temp.txt">nul
IF NOT ERRORLEVEL 1 goto:stripfileX

echo set "fileXpath=%%fileXpath:%fileX%=%%">"%temp%\LZ77temp.bat"
call "%temp%\LZ77temp.bat"

set "fileXpath=%filenameX%"
echo set "fileXpathback=%%fileXpath:\%fileX%=%%">"%temp%\LZ77temp.bat"
call "%temp%\LZ77temp.bat"

::echo fileX: "%fileX%"
::echo fileXpath: "%fileXpath%"
::echo fileXpathback: "%fileXpathback%"

if /i "%fileXpathback%" EQU "%fileX%" goto:skip
if not exist "%filepath%%folderadd%\%fileXpathback%" mkdir "%filepath%%folderadd%\%fileXpathback%"
:skip


if /i "%choice%" NEQ "C" goto:decompressfolder
::---compress---
::start Lz77Mii-OK.exe
::Lz77Mii.exe -in "%filepath%\!filenameX!" -out "%filepath%%folderadd%\!filenameX!" -compress
::goto:EOF

::sanity check for LZ77
set start=
if exist "%temp%\LZ77hexdump.txt" del "%temp%\LZ77hexdump.txt">nul
sfk hexdump -pure -nofile -offlen 0x00 0x04 "%filepath%\!filenameX!">"%temp%\LZ77hexdump.txt"
set /p start= <"%temp%\LZ77hexdump.txt"
::4C5A3737 is LZ77 in hex
::echo "%start%" should NOT be 4C5A3737
If /i "%start%" EQU "4C5A3737" (sfk echo [Yellow]File already LZ77 compressed, copying original...) & (copy /y "%filepath%\!filenameX!" "%filepath%%folderadd%\!filenameX!">nul) & (echo.) & (goto:EOF)


::To encode (compress): `LZ77` magic word needs to be added back at the start, `lzss -evn [filename]`
copy /y "%filepath%\!filenameX!" "%filepath%%folderadd%\!filenameX!.part">nul


::pipe output and findstr "', WARNING:" without quotes to confirm
lzss.exe -evn "%filepath%%folderadd%\!filenameX!.part">"%temp%\LZ77hexdump.txt"
findStr /I /C:"', WARNING:" "%temp%\LZ77hexdump.txt" >nul
IF not ERRORLEVEL 1 (sfk echo [Red]lzss.exe error, skipping...) & (echo.) & (del "%filepath%%folderadd%\!filenameX!.part">nul) & (goto:EOF)



::add back LZ77 magicword
if not exist "%temp%\LZ77LZ77.bin" sfk echo 4C5A3737 +hextobin "%temp%\LZ77LZ77.bin">nul

set pass=
copy /b /y "%temp%\LZ77LZ77.bin"+"%filepath%%folderadd%\!filenameX!.part" "%filepath%%folderadd%\!filenameX!">nul
If /i "%ERRORLEVEL%" EQU "0" set pass=Y

del "%filepath%%folderadd%\!filenameX!.part">nul

If /i "%pass%" EQU "Y" goto:pass
::fail
if exist "%filepath%%folderadd%\!filenameX!" del "%filepath%%folderadd%\!filenameX!">nul
sfk echo [Red]Error: failed to add back LZ77
echo.
goto:EOF

:pass
sfk echo [Green]Successfully compressed
echo.
goto:EOF






:decompressfolder

::---decompress---

::if /i "%choice%" EQU "D" GBAmdc.exe -e "%filepath%\!filenameX!" "%filepath%%folderadd%\!filenameX!" 4

::sanity check for LZ77
set start=
if exist "%temp%\LZ77hexdump.txt" del "%temp%\LZ77hexdump.txt">nul
sfk hexdump -pure -nofile -offlen 0x00 0x04 "%filepath%\!filenameX!">"%temp%\LZ77hexdump.txt"
set /p start= <"%temp%\LZ77hexdump.txt"
::4C5A3737 is LZ77 in hex
::echo "%start%" should be 4C5A3737
If /i "%start%" NEQ "4C5A3737" (sfk echo [Yellow]File not LZ77 compressed, assuming it is already properly decompressed and copying original...) & (copy /y "%filepath%\!filenameX!" "%filepath%%folderadd%\!filenameX!">nul) & (echo.) & (goto:EOF)


::trim off first 4 bytes
sfk partcopy "%filepath%\!filenameX!" -allfrom 4 "%filepath%%folderadd%\!filenameX!" -yes>nul
If /i "%ERRORLEVEL%" EQU "0" goto:afterTrim

::failed trim
sfk echo [Red]Error: failed to trim LZ77 from start of file, skipping...
if exist "%filepath%%folderadd%\!filenameX!" del "%filepath%%folderadd%\!filenameX!">nul
goto:EOF

:afterTrim

::pipe output and findstr "', WARNING:" without quotes to confirm
lzss.exe -d "%filepath%%folderadd%\!filenameX!">"%temp%\LZ77hexdump.txt"

findStr /I /C:"', WARNING:" "%temp%\LZ77hexdump.txt" >nul
IF ERRORLEVEL 1 (sfk echo [Green]Successfully decompressed) & (echo.) & (goto:EOF)

sfk echo [Red]lzss.exe error, skipping...
echo.
if exist "%filepath%%folderadd%\!filenameX!" del "%filepath%%folderadd%\!filenameX!">nul

goto:EOF



:fin
::setlocal DISABLEDELAYEDEXPANSION

::if MultiDrop.txt exists in means still in multimode
if exist MultiDrop.txt goto:next


if exist MultiDrop.txt (attrib -h -r -s MultiDrop.txt) & (del MultiDrop.txt)
if exist queue.txt (attrib -h -r -s queue.txt) & (del queue.txt)
if exist "%temp%\LZ77temp.txt" del "%temp%\LZ77temp.txt">nul
if exist "%temp%\LZ77temp.bat" del "%temp%\LZ77temp.bat">nul

if /i "%AutoExit%" EQU "K" goto:bottom
if /i "%AutoExit%" EQU "Y" (echo Exiting...) & (@ping 127.0.0.1 -n 2 -w 1000> nul) & (exit)

echo.
echo Finished, press any key to exit...
pause> nul
exit


:error
::cls
if exist MultiDrop.txt (attrib -h -r -s MultiDrop.txt) & (del MultiDrop.txt)
if exist queue.txt (attrib -h -r -s queue.txt) & (del queue.txt)
if exist "%temp%\LZ77temp.txt" del "%temp%\LZ77temp.txt">nul
if exist "%temp%\LZ77temp.bat" del "%temp%\LZ77temp.bat">nul
if exist "%temp%\LZ77hexdump.txt" del "%temp%\LZ77hexdump.txt">nul

sfk echo [Red]LZ77 Helper, by XFlak
echo.
echo Drag and drop multiple files\folders onto LZ77Helper.bat to compress or decompress with LZ77
echo.
echo   Command Line Usage:
echo.
echo   LZ77Helper [-C^|-D] [-E; optional] [Input File^|Folder]
echo.
echo   -C     Compress
echo   -D     Decompress
echo   -E     Exits upon completion (optional)
echo.
echo   Examples:
sfk -spat echo \x20 \x20 [Cyan]LZ77Helper \x2DC file.gif
echo       Saves a compressed copy of file.gif
sfk -spat echo \x20 \x20 [Cyan]LZ77Helper \x2DD "C:\Users\XFlak\Desktop\New Folder"
echo       Saves a decompressed copy of the files in the path specified
sfk -spat echo \x20 \x20 [Cyan]LZ77Helper \x2DC \x2DE "C:\Users\XFlak\Desktop\New Folder\"
echo       Saves a compressed copy of the files in the path specified and exits
echo.
if /i "%AutoExit%" EQU "K" goto:bottom
if /i "%AutoExit%" EQU "Y" (echo Exiting...) & (@ping 127.0.0.1 -n 2 -w 1000> nul) & (exit)
echo Press any key to exit...
pause> nul
exit

:bottom