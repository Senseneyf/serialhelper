@echo off
color 0a

set putty=putty.exe
set port=""

:menu
cls
echo Serial Helper 1.1 by Franklin Senseney
echo ===================================================
echo 1 - Start a serial session
echo 2 - Start a serial session with logging enabled
echo 3 - View all active COM ports
echo 4 - View CM/RM command reference
echo q - Quit
echo ===================================================
set "option"=""
set /p option="Enter an option: "
if "%option%" == "" goto menu
if %option% == 1 goto serial
if %option% == 2 goto serial_logging
if %option% == 3 goto view_com_ports
if %option% == 4 goto cmd_ref_menu
if /i "%option%" == "q" goto end
echo %option% is not a valid option
pause
goto menu

:view_com_ports
cls
wmic path CIM_LogicalDevice where "Description like 'USB Serial Port%'" get Name
goto menu

:serial
cls
echo Start a serial session
echo ===================================================
set /p port="Enter a port number to start, or q to go back: "
if "%port%" == "q" goto menu
%putty% -serial COM%port% -sercfg 115200,8,n,1,N
goto menu

:serial_logging
cls
echo Start a serial session with logging to a file enabled
echo Output will be saved to "putty.log"
echo ===================================================
set /p port="Enter a port number to start, or q to go back: "
if "%port%" == "q" goto menu
%putty% -serial COM%port% -sessionlog putty.log -sercfg 115200,8,n,1,N
goto menu

:cm_ref
cls
echo Chassis Manager commands
echo/
echo Title                          ^|      Command
echo ===================================================
echo Esblish connection with CM     ^|      wcscli -establishcmconnection -s 1 -u USERNAME -x PASSWORD
echo Start serial session           ^|      wsccli -starbladeserialsession -i BLADE_INDEX
echo View memory present in blade   ^|      wsccli -getbladehealth -i BLADE_INDEX -m
echo/
pause
goto cmd_ref_menu

:rm_ref
cls
echo Rack Manager commands
echo/
echo Title                          ^|      Command
echo ===================================================
echo Start serial session           ^|      ^start serial session -i BLADE_INDEX
echo/
pause
goto cmd_ref_menu

:cmd_ref_menu
cls
echo Command Reference
echo ===================================================
echo 1 - Chassis Manager commands
echo 2 - Rack Manager commands
echo q - Back to main menu
echo qq - Quit
echo ===================================================
set /p option2="Enter an option: "
if "%option2%" == "" goto cmd_ref_menu
if %option2% == 1 goto cm_ref
if %option2% == 2 goto rm_ref
if /i "%option2%" == "q" goto menu
if /i "%option2%" == "qq" goto end
echo %option2% is not a valid option
pause
goto cmd_ref_menu

:end
