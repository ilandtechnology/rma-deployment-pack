$destFolder = "$env:SystemDrive\Temp\provisioning"

# Path to the provisioning package
$ppkgPath = "$destFolder\rma-deployment-pack-main\intune-rma.ppkg"

# Register computer in Microsoft Intune & Entra ID
Install-ProvisioningPackage -PackagePath $ppkgPath -ForceInstall -QuietInstall

Start-Process -FilePath "$destFolder\rma-deployment-pack-main\profwiz.exe" -WorkingDirectory "$destFolder\rma-deployment-pack-main" -Wait

Restart-Computer -Force