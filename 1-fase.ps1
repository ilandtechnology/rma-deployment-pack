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

# Remover Sophos (antivírus)
$uninstallSophos = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE 'XSophos%'"
foreach ($app in $uninstallSophos) {
    $app.Uninstall()
}

# Remover estação do domínio
Remove-Computer -UnjoinDomaincredential (Get-Credential -UserName "RANGELADV\iland.infra") -PassThru -Verbose -Restart

# Reiniciar (caso não tenha reiniciado pelo Remove-Computer)
Restart-Computer -Force