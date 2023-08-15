@echo off
set putty=putty.exe
set ver=1.3
set port=""
set default_port=0

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

if exist config.cmd ( call config.cmd && call :waiting_for "5" 1) else ( call :create_config "0" && call :waiting_for "5" 0)
:menu
cls
echo %_green%%_whitebg%Serial Helper %_reset%%_yellow%%_whitebg%%ver%%_reset%%_invert% by Franklin Senseney%_reset%
echo ===================================================
echo %_yellow%1%_reset%   - Start a serial session
echo %_yellow%2%_reset%   - Start a serial session with logging enabled
echo %_yellow%3%_reset%   - View active COM ports
echo %_yellow%?%_reset%/%_yellow%h%_reset% - Help/more options
echo %_yellow%q%_reset%   - Quit
echo ===================================================
set "option"=""
set /p option="Enter an option: "
if "%option%" == "" goto menu
if %option% == 1 goto serial
if %option% == 2 goto serial_logging
if %option% == 3 goto view_com_ports
if /i "%option%" == "q" goto end
if /i "%option%" == "d" goto serial_default_speed
if /i "%option%" == "create_config" call :create_config "0" && call config.cmd && call :waiting_for "5" && goto menu
if /i "%option%" == "rm_config" del config.cmd && echo config.cmd deleted.. && call :waiting_for "5" && goto menu
if /i "%option%" == "update_config" call :create_config "1" && echo updating... config.cmd && call :waiting_for "10" && goto menu
if /i "%option%" == "cm" call :cm_ref "1"
if /i "%option%" == "rm" call :rm_ref "1"
if /i "%option%" == "cmds" goto :cmd_ref_menu
if /i "%option%" == "?" goto :help
if /i "%option%" == "h" goto :help
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
call :create_config "1"
pause
goto menu

:serial
cls
echo %_invert%Start a serial session%_reset%
if %default_port% NEQ "" echo Default port is set to %_green%%default_port%%_reset% & set port=%default_port%
echo ===================================================
set /p port="Enter a port number to start, blank for default, or q to go back: "
if "%port%" == "q" goto menu
%putty% -serial COM%port% -sercfg 115200,8,n,1,N
goto menu

:serial_logging
cls
echo %_invert%Start a serial session with logging to a file enabled%_reset%
echo Output will be saved to %_bold%"putty.log"%_reset%
if %default_port% NEQ "" echo Default port is set to %_green%%default_port%%_reset% & set port=%default_port%
echo ===================================================
set /p port="Enter a port number to start, blank for default, or q to go back: "
if "%port%" == "q" goto menu
%putty% -serial COM%port% -sessionlog putty.log -sercfg 115200,8,n,1,N
goto menu

:serial_default_speed
cls
echo %_invert%Start a serial session with default speed%_reset%
if %default_port% NEQ "" echo Default port is set to %_green%%default_port%%_reset% & set port=%default_port%
echo ===================================================
set /p port="Enter a port number to start, or q to go back: "
if "%port%" == "q" goto menu
%putty% -serial COM%port% -sercfg 9600,8,n,1,N
goto menu

:cm_ref
cls
setlocal
set i=%~1
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
if %i% equ 0 goto :cmd_ref_menu
goto :menu

:rm_ref
cls
setlocal
set i=%~1
echo %_invert%Rack Manager commands%_reset%
echo You will be met with a login prompt, login first to use commands.
echo/
echo Title                          ^|      Command
echo ===================================================
echo Start serial session           ^|      ^start serial session -i %_yellow%BLADE_INDEX%_reset%
::echo CM Commands                    ^|      wcscli -command %_yellow%Most commands work%_reset%
echo/
pause
if %i% equ 0 goto :cmd_ref_menu
goto :menu

:help
cls
echo %_invert%Help/additonal options%_reset%
echo ===================================================
echo %_yellow%cm%_reset% - View Chassis Manager commands
echo %_yellow%rm%_reset% - View Rack Manager commands
echo %_yellow%cmds%_reset% - View RM/CM commands menu
echo %_yellow%default%_reset% - Start a serial session with default speeds
echo/
echo %_green%Debug Stuff%_reset%
echo ===================================================
echo %_yellow%config%_reset% - Create config file
echo %_yellow%rm_config%_reset% - Delete config file
echo %_yellow%update_config%_reset% - Update config file
echo/
pause
goto menu

:cmd_ref_menu
cls
echo %_invert%CM/RM Commands%_reset%
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

:create_config
setlocal
if %~1 neq 1 echo %_yellow%No config file found, creating config.cmd...%_reset%
(echo @echo off)>config.cmd
(echo :: Serial Helper Config)>>config.cmd
(echo echo config.cmd loaded successfully)>>config.cmd
(echo set /A default_port=%default_port% && echo echo The default port was set to %_green%%%default_port%%%_reset%)>>config.cmd
(echo exit /b)>>config.cmd
if %1 equ 1 echo %_green%config.cmd has been updated.%_reset%
exit /back

:waiting_for
setlocal
if %~2 neq 1 echo Continuing in %~1 seconds...
set n=%~1+1
ping -n %n% 127.0.0.1>nul
exit /back

:end
