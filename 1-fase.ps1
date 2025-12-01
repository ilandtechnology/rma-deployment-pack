# Ensure the script is running with elevated permissions
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    throw "Este script deve ser executado com permissões elevadas (Administrador)."
}

# Enable Local Administrator account and set its password
$adminUser = Get-LocalUser | Where-Object { $_.SID -like "S-1-5-21-*-500" }
if ($adminUser.Enabled -eq $false) {
    Enable-LocalUser -Name $adminUser.Name
}

$key = [IO.File]::ReadAllBytes("$PSScriptRoot\ky.bin")
$encrypted = Get-Content "$PSScriptRoot\sec.enc"
$secure = ConvertTo-SecureString -String $encrypted -Key $key
Remove-Item -Path $PSScriptRoot -Include *.bin,*.enc -Recurse -Force
$plain = [System.Net.NetworkCredential]::new("", $secure).Password

try {
    Set-LocalUser -Name $adminUser.Name -Password (ConvertTo-SecureString $plain -AsPlainText -Force)
}
catch {
    Write-Error "Erro ao definir a senha do Administrador Local: $_"
    exit 1
}

chkntfs /D
chkntfs /C $env:SystemDrive
fsutil dirty set $env:SystemDrive
DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase
& "$PSScriptRoot\delprof.exe" /Q /I /D:190

# Remove unwanted software
$uninstallSoftwares = @(
    "SonicWall NetExtender",
    "TreeSize Free"
)

$wave = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
if ($wave.DisplayVersion -like "24H2" -or $wave.DisplayVersion -like "25H2") {
    $uninstallSoftwares += "7-Zip"
}

foreach ($software in $uninstallSoftwares) {
    $apps = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '$software%'"
    Write-Host "Removendo $software..." -ForegroundColor Yellow
    foreach ($app in $apps) {
        $app.Uninstall()
    }
}

Set-Culture -CultureInfo pt-BR
Set-WinSystemLocale -SystemLocale pt-BR
Set-TimeZone -Id "SA Eastern Standard Time"

Start-Sleep -Seconds 15

# Remove computer from domain
Remove-Computer -UnjoinDomaincredential (Get-Credential -UserName "RANGELADV\iland.infra" -Message "Entre a senha para remover a máquina do domínio.") -PassThru -Verbose -Restart -Force

Start-Sleep -Seconds 5

# Restart (in case it hasn't restarted from Remove-Computer)
Restart-Computer -ErrorAction SilentlyContinue -Force