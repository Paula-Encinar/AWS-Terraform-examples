#datagateway.ps1
<powershell>

$ENVIRONMENT = "${environment}"

if ($ENVIRONMENT -eq "staging")
{
  Invoke-WebRequest -Uri https://github.com/PowerShell/PowerShell/releases/download/v7.3.1/PowerShell-7.3.1-win-x64.msi -OutFile PowerShell.msi
  Start-Process msiexec.exe -ArgumentList '/i PowerShell.msi /quiet' -Wait
  cd "C:\Program Files\PowerShell\7\"


  # Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
  .\pwsh.exe -Command {Install-Module -Name DataGateway -Force}

  New-Item ".\myScript.ps1"
  Set-Content .\myScript.ps1 '

  $securePassword = "${azurePowerBI}:AzureClientSecret::" | ConvertTo-SecureString  -AsPlainText -Force;
  $ApplicationId ="${azurePowerBI}:AzureApplicationId::";
  $Tenant = "${azurePowerBI}:AzureTenant::";
  $GatewayName = "DataGateway_${environment}";
  $RecoverKey = "${datagateway_recovery_key}:recovery_key::" | ConvertTo-SecureString -AsPlainText -Force;
  $userIDToAddasAdmin = "${azurePowerBI}:AzureObjectID::"

  #Gateway Login

  Login-DataGatewayServiceAccount -ApplicationId $ApplicationId -ClientSecret $securePassword  -Tenant $Tenant

  #Installing Gateway
  Install-DataGateway -AcceptConditions

  net stop PBIEgwService
  net start PBIEgwService
  #Configuring Gateway
  $GatewayDetails = Add-DataGatewayCluster -Name $GatewayName -RecoveryKey  $RecoverKey
  #Add User as Admin
  Add-DataGatewayClusterUser -GatewayClusterId $GatewayDetails.GatewayObjectId -PrincipalObjectId $userIDToAddasAdmin -AllowedDataSourceTypes $null -Role Admin'

  .\pwsh.exe .\myScript.ps1

}else{
  New-Item -Path "C:\" -Name "Paula" -ItemType Directory
}

</powershell>
