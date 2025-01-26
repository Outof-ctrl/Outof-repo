@echo off
REM Afficher un message pour confirmer que le script a été exécuté
echo Le bouton fonctionne ! > %TEMP%\test_button_result.txt
echo Le fichier batch a été exécuté correctement.
pause

REM Ouvrir le fichier texte créé pour confirmer visuellement
start notepad %TEMP%\test_button_result.txt
pause
