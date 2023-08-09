@echo off

set putty=putty.exe
set port=""
set default_port=""

:cmd_colors
color 17
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set _red=%ESC%[31m
set _green=%ESC%[32m
set _yellow=%ESC%[33m
set _blue=%ESC%[34m
set _megenta=%ESC%[35m
set _invert=%ESC%[7m
set _bg=%ESC%[44m
set _bold=%ESC%[1m
set _whitebg=%ESC%[47m
set _white=%ESC%[37m
set _reset=%ESC%[0m%_bg%%_white%

:menu
cls
echo %_green%%_whitebg%Serial Helper %_reset%%_yellow%%_whitebg%1.2%_reset%%_invert% by Franklin Senseney%_reset%
echo ===================================================
echo %_yellow%1%_reset% - Start a serial session
echo %_yellow%2%_reset% - Start a serial session with logging enabled
echo %_yellow%3%_reset% - View active COM ports
echo %_yellow%4%_reset% - View CM/RM commands reference
echo %_yellow%q%_reset% - Quit
echo ===================================================
set "option"=""
set /p option="Enter an option: "
if "%option%" == "" goto menu
if %option% == 1 goto serial
if %option% == 2 goto serial_logging
if %option% == 3 goto view_com_ports
if %option% == 4 goto cmd_ref_menu
if /i "%option%" == "q" goto end
if /i "%option%" == "d" goto debug
echo %option% is not a valid option
echo/
pause
goto menu

:view_com_ports
cls
echo %_invert%View active COM ports%_reset%
echo ===================================================
wmic path CIM_LogicalDevice where "Description LIKE '%%Prolific%%' OR Description LIKE 'USB Serial Port%'" get Name
echo/
pause
goto default_port_prompt

:default_port_prompt
set "option4"=""
set /p option4="Would you like to set a default port for this session? (y)es or (n)o: "
if /i "%option4%" == "y" goto set_default_port
if /i "%option4%" == "n" goto menu
echo Please only enter (y)es or (n)o
goto default_port_prompt

:set_default_port
set "option3"=""
set /p option3="Enter a port number to set it as the default, or q to cancel: "
if "%option3%" == "" goto set_default_port
if /i "%option3%" == "q" goto menu
set default_port=%option3%
echo Default port has been set to '%default_port%'.
pause
goto menu


:serial
cls
echo %_invert%Start a serial session%_reset%
if %default_port% NEQ "" echo Default port is set to %_green%%default_port%%_reset% & set port=%default_port%
echo ===================================================
set /p port="Enter a port number to start, or q to go back: "
if "%port%" == "q" goto menu
%putty% -serial COM%port% -sercfg 115200,8,n,1,N
goto menu

:serial_logging
cls
echo %_invert%Start a serial session with logging to a file enabled%_reset%
echo Output will be saved to "putty.log"
if %default_port% NEQ "" echo Default port is set to %default_port% & set port=%default_port%
echo ===================================================
set /p port="Enter a port number to start, or q to go back: "
if "%port%" == "q" goto menu
%putty% -serial COM%port% -sessionlog putty.log -sercfg 115200,8,n,1,N
goto menu

:debug
cls
%putty% telnet://towel.blinkenlights.nl
pause
goto menu

:cm_ref
cls
echo %_invert%Chassis Manager commands%_reset%
echo You must first authenticate yourself with -establishcmconnection before using other commands.
echo/
echo Title                          ^|      Command
echo ===================================================
echo Esblish connection with CM     ^|      wcscli -establishcmconnection -s 1 -u %_yellow%USERNAME%_reset% -x %_yellow%PASSWORD%_reset%
echo Start serial session           ^|      wsccli -starbladeserialsession -i %_yellow%BLADE_INDEX%_reset%
echo View info on DIMMS in blade    ^|      wsccli -getbladehealth -i %_yellow%BLADE_INDEX%_reset% -m
echo/
pause
goto cmd_ref_menu

:rm_ref
cls
echo %_invert%Rack Manager commands%_reset%
echo You will be met with a login prompt, login first to use commands.
echo/
echo Title                          ^|      Command
echo ===================================================
echo Start serial session           ^|      ^start serial session -i %_yellow%BLADE_INDEX%_reset%
echo CM Commands                    ^|      wcscli -command %_yellow%Most commands work%_reset%
echo/
pause
goto cmd_ref_menu

:cmd_ref_menu
cls
echo %_invert%Command Reference%_reset%
echo ===================================================
echo %_yellow%1%_reset% - Chassis Manager commands
echo %_yellow%2%_reset% - Rack Manager commands
echo %_yellow%q%_reset% - Back to main menu
echo %_yellow%qq%_reset% - Quit
echo ===================================================
set /p option2="Enter an option: "
if "%option2%" == "" goto cmd_ref_menu
if %option2% == 1 goto cm_ref
if %option2% == 2 goto rm_ref
if /i "%option2%" == "q" goto menu
if /i "%option2%" == "qq" goto end
echo %option2% is not a valid option
echo/
pause
goto cmd_ref_menu

:end
