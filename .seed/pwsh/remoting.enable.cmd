@ECHO OFF
SETLOCAL EnableDelayedExpansion


SET current_script_dir=%~dp0
SET current_script_name=%~n0

:uac

WHOAMI /GROUPS | FIND "12288" >nul
IF ERRORLEVEL 1 (
    ECHO Auto requires elevated privileges...
    SET script_file=%~f0
    ( mshta "vbscript:CreateObject("shell.Application").ShellExecute("%~f0","","","runas",1)(window.close)" ) & GOTO:EOF
)
ECHO Now runas root.

:run

ECHO Run script '%current_script_dir%%current_script_name%.ps1'

ECHO NOTE: Change pwsh ExecutionPolicy to 'Unrestricted'
ECHO Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force | powershell.exe -noprofile -

powershell.exe -noprofile %current_script_dir%%current_script_name%.ps1

ECHO Set-ExecutionPolicy -ExecutionPolicy Restricted -Force | powershell.exe -noprofile -
ECHO NOTE: Change pwsh ExecutionPolicy to 'Restricted'

PAUSE
