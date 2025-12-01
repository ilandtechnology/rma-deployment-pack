# Ativar Administrador Local (independente do idioma)
$adminUser = Get-LocalUser | Where-Object { $_.SID -like "S-1-5-21-*-500" }
if ($adminUser.Enabled -eq $false) {
    Enable-LocalUser -Name $adminUser.Name
}

$key = [IO.File]::ReadAllBytes("$PSScriptRoot\ky.bin")
$encrypted = Get-Content "$PSScriptRoot\sec.enc"
$secure = ConvertTo-SecureString -String $encrypted -Key $key
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

# Remover Softwares
$uninstallSoftwares = @(
    "7-Zip",
    "SonicWall NetExtender",
    "TreeSize Free"
)
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

# Remover estação do domínio
Remove-Computer -UnjoinDomaincredential (Get-Credential -UserName "RANGELADV\iland.infra" -Message "Entre a senha para remover a máquina do domínio.") -PassThru -Verbose -Restart -Force

# Reiniciar (caso não tenha reiniciado pelo Remove-Computer)
Restart-Computer -Force