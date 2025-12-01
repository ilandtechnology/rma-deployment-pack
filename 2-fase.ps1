$destFolder = "$env:SystemDrive\Temp\provisioning"
$ppkgPath = "$destFolder\rma-deployment-pack-main\intune-rma.ppkg"

# Ensure the script is running with elevated permissions
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    throw "Este script deve ser executado com permissões elevadas (Administrador)."
}

# Register computer in Microsoft Intune & Entra ID
Install-ProvisioningPackage -PackagePath $ppkgPath -ForceInstall -QuietInstall