$destFolder = "$env:SystemDrive\Temp\provisioning"

# Path to the provisioning package
$ppkgPath = "$destFolder\rma-deployment-pack-main\intune-rma.ppkg"

# Register computer in Microsoft Intune & Entra ID
Install-ProvisioningPackage -PackagePath $ppkgPath -ForceInstall -QuietInstall