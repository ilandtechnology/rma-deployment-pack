$repoUrl = "https://github.com/ilandtechnology/rma-deployment-pack"
$destFolder = "$env:SystemDrive\Temp\provisioning"
$zipPath = "$destFolder\repo.zip"

# Ensure the script is running with elevated permissions
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    throw "Este script deve ser executado com permissões elevadas (Administrador)."
}

if (!(Test-Path $destFolder)) { 
    New-Item -ItemType Directory -Path $destFolder -Force | Out-Null
} elseif ((Get-ChildItem $destFolder).Count -gt 0) {
    Remove-Item "$destFolder\*" -Recurse -Force
}

Invoke-WebRequest -Uri "$repoUrl/archive/refs/heads/main.zip" -OutFile $zipPath

Expand-Archive -Path $zipPath -DestinationPath $destFolder -Force
Remove-Item $zipPath -ErrorAction SilentlyContinue -Force

& "$destFolder\rma-deployment-pack-main\1-fase.ps1"