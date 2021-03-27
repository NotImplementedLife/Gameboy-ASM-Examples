:: small script for run only projects automation
:: usage: run <number>.<title>
:: E.g. : run 0.hello-world

@echo off
if NOT EXIST "%~1" goto __PATH_NOT_FOUND__
echo Launching...
bgb64 %1/%1.gb
echo Done.

goto __END__

:__PATH_NOT_FOUND__
echo Path ./%1 was not found.

:__END__
 