if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

Write-Host "🛠️ Running Post Restart Setup script"

Write-Host "⚙️ Setup WSL"
choco install wsl2 -y

$wslDistro = Resolve-Path (Join-Path $PSScriptRoot -ChildPath .\MagicDebian.wsl)

wsl --set-default-version 2
wsl --update
wsl --install --from-file $wslDistro

Write-Host "⚙️ Setup Podman"
choco install podman-desktop -y

Write-Host "🧩 Install Windows VSCode extensions"
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode.powershell

Write-Host "🧩 Install WSL VSCode extensions"
wsl code --install-extension ms-vscode.powershell
wsl code --install-extension github.copilot
wsl code --install-extension hashicorp.terraform
wsl code --install-extension ms-python.python
wsl code --install-extension timonwong.shellcheck
wsl code --install-extension redhat.ansible

Write-Host "🔄 Restarting Computer for the last time"
Start-Sleep -Seconds 5
# Restart-Computer
