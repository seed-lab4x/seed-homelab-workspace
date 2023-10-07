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

MORE %current_script_dir%%current_script_name%.ps1 | powershell.exe -noprofile -

PAUSE
