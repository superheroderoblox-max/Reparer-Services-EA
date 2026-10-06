@echo off
setlocal EnableExtensions

title Verification et reactivation des services EA
color 0A

echo ============================================
echo   EA - Verification des services Windows
echo ============================================
echo.

:: Verifie les droits administrateur
net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo [ERREUR] Ce fichier doit etre lance en tant qu'administrateur.
    echo.
    echo Faites clic droit sur le fichier puis "Executer en tant qu'administrateur".
    pause
    exit /b 1
)

echo Recherche des services EA...
echo.

set "FOUND=0"

for /f "tokens=1,2,*" %%A in ('sc query state^= all ^| findstr /I "EA"') do (
    echo %%A %%B %%C
)

echo.
echo --- EA Background Service ---

sc query "EABackgroundService" >nul 2>&1
if "%errorlevel%"=="0" (
    set "FOUND=1"
    echo Service trouve : EABackgroundService
    sc config "EABackgroundService" start= auto
    sc start "EABackgroundService"
) else (
    echo Service EABackgroundService non trouve.
)

echo.
echo --- Autres services EA detectes ---

for /f "tokens=2 delims=:" %%S in ('sc query state^= all ^| findstr /I "SERVICE_NAME.*EA"') do (
    set "SVC=%%S"
    call :clean_and_start
)

echo.
echo ============================================
echo Operation terminee.
echo ============================================
echo.
echo Si EA affiche encore le meme message :
echo 1. Redemarrez Windows.
echo 2. Relancez EA App en administrateur.
echo 3. Si le service EA Background Service est absent,
echo    une reparation/reinstallation de EA App peut etre necessaire.
echo.
pause
exit /b 0

:clean_and_start
set "SVC=%SVC: =%"
if not defined SVC exit /b 0
if /I "%SVC%"=="EABackgroundService" exit /b 0
echo Verification : %SVC%
sc config "%SVC%" start= auto >nul 2>&1
sc start "%SVC%" >nul 2>&1
exit /b 0
