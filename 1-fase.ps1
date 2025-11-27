# Ativar Administrador Local (independente do idioma)
$adminUser = Get-LocalUser | Where-Object { $_.SID -like "S-1-5-21-*-500" }
if ($adminUser.Enabled -eq $false) {
    Enable-LocalUser -Name $adminUser.Name
}

$key = [IO.File]::ReadAllBytes(".\ky.bin")
$encrypted = Get-Content ".\sec.enc"
$secure = ConvertTo-SecureString -String $encrypted -Key $key
$plain = [System.Net.NetworkCredential]::new("", $secure).Password

$ky = $plain # Altere para a senha desejada
Set-LocalUser -Name $adminUser.Name -Password (ConvertTo-SecureString $ky -AsPlainText -Force)

Start-ScheduledTask -TaskName "Microsoft\Windows\Storage\StorageSense"

chkntfs /D
chkntfs /C
chkdsk C: /F /R

DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase

# Remover Sophos (antivírus)
$uninstallSophos = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE 'Sophos%'"
foreach ($app in $uninstallSophos) {
    $app.Uninstall()
}

# Remover estação do domínio
Remove-Computer -UnjoinDomaincredential (Get-Credential) -PassThru -Verbose -Restart

# Reiniciar (caso não tenha reiniciado pelo Remove-Computer)
Restart-Computer -Force