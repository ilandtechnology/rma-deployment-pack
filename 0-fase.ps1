$repoUrl = "https://github.com/ilandtechnology/rma-deployment-pack"
$destFolder = "$env:SystemDrive\Temp\provisioning"
$zipPath = "$destFolder\repo.zip"

if (!(Test-Path $destFolder)) { 
    New-Item -ItemType Directory -Path $destFolder -Force | Out-Null
}

Invoke-WebRequest -Uri "$repoUrl/archive/refs/heads/main.zip" -OutFile $zipPath

Expand-Archive -Path $zipPath -DestinationPath $destFolder -Force
Remove-Item $zipPath -ErrorAction SilentlyContinue -Force

& "$destFolder\rma-deployment-pack\1-fase.ps1"