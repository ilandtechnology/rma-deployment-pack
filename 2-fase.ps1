$destFolder = "$env:SystemDrive\Temp\provisioning"

# Path to the provisioning package
$ppkgPath = "$destFolder\rma-deployment-pack\intune-RMA.ppkg"

# Register computer in Microsoft Intune & Entra ID
Install-ProvisioningPackage -PackagePath $ppkgPath -ForceInstall -QuietInstall

Start-Process -FilePath "$destFolder\rma-deployment-pack\profwiz.exe" -WorkingDirectory "$destFolder\rma-deployment-pack" -Wait

Restart-Computer -Force