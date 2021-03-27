:: small script for build and run projects automation
:: usage: build <number>.<title>
:: E.g. : build 0.hello-world

@echo off
if NOT EXIST "%~1" goto __PATH_NOT_FOUND__
echo Building %1
cd %1
echo :: rgbasm -o main.o main.asm
rgbasm -o main.o main.asm
if %ERRORLEVEL% NEQ 0 goto __PATH_EXIT__

:__LINK__
echo Linking...
echo :: rgblink -o %1.gb main.o
rgblink -o %1.gb main.o
echo Fixing ROM...
echo :: rgbfix -v -p 0 %1.gb
rgbfix -v -p 0 %1.gb
echo Cleaning...
del main.o
echo Launching...
bgb64 %1.gb
echo Done.
goto __PATH_EXIT__

:__PATH_NOT_FOUND__

echo Path ./%1 was not found.
goto __END__

:__PATH_EXIT__

cd ..
 
:__END__
