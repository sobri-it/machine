if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# This script setup all useful tools on Windows to work
# This script should be run with Administrator priviledge

# This command might be required before running this script
Write-Host "🛂 Setting Execution policy to Unrestricted"
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine

Write-Host "🌒 Set Dark theme"
& "C:\Windows\Resources\Themes\dark.theme"

Write-Host "🖼️ Set Wallpaper"
$Wallpaper = Join-Path "$PSScriptRoot" -Child ".\lama_linux_4k_dark.png"
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value "$Wallpaper"
Stop-Process -processname explorer

Write-Host "🗂️ Configure Explorer to show hidden files"
$explorerKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $explorerKey Hidden 1
Set-ItemProperty $explorerKey HideFileExt 0
Set-ItemProperty $explorerKey ShowSuperHidden 1
Stop-Process -processname explorer

Write-Host "🖥️ Install windows subsystem for linux"
# Enable WSL features
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

Write-Host "✔️ Enable chocolatey source"
choco sources enable -n=chocolatey

Write-Host "🛠️ Install tools and applications"
choco install 1password -y
choco install bitwarden -y
choco install vscode -y
choco install postman -y
choco install openjdk -y
choco install zap -y
choco install openvpn-connect -y
choco install nerd-fonts-comicshannsmono -y

Write-Host "📟 Install Powershell 7"
winget install --id Microsoft.PowerShell --source winget

Write-Host "🦾 Setting up automatic updates"
# Create automatic choco update all task
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -Command "choco upgrade all -y"'
$trigger = New-ScheduledTaskTrigger -AtStartup

# Create a folder for the scheduled task
$taskFolder = "\MagicleturCustomTasks"
if (-not (Test-Path "C:\Windows\System32\Tasks$taskFolder")) {
    New-Item -Path "C:\Windows\System32\Tasks$taskFolder" -ItemType Directory
}

# Register the scheduled task in the dedicated folder
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "ChocoUpdateAll" -TaskPath $taskFolder -RunLevel Highest

Write-Host "🚀 Setting up Post-Restart Script RunOnce setup"
$postRestartScript = Join-Path $PSScriptRoot -Child "PostRestartSetup.ps1"

New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "PostRebootScript" -Value "PowerShell.exe -File `"$postRestartScript`"" -PropertyType String

Write-Host "🔄 Restarting Computer"
Start-Sleep -Seconds 5
Restart-Computer
