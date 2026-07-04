# Run ONCE locally to create the storage account that holds Terraform state
# for ALL THREE environments (each env uses a different blob key).
$STATE_RG  = "tfstate-rg"
$LOCATION  = "southafricanorth"
$STATE_SA  = "tfstateamangena$(Get-Random -Minimum 1000 -Maximum 9999)"
$CONTAINER = "tfstate"

Write-Host "Creating state resource group + storage account..." -ForegroundColor Cyan
az group create --name $STATE_RG --location $LOCATION | Out-Null
az storage account create --name $STATE_SA --resource-group $STATE_RG --location $LOCATION `
  --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2 --allow-blob-public-access false | Out-Null
az storage account blob-service-properties update --account-name $STATE_SA --resource-group $STATE_RG `
  --enable-versioning true | Out-Null
az storage container create --name $CONTAINER --account-name $STATE_SA --auth-mode login | Out-Null

$ME    = az ad signed-in-user show --query id -o tsv
$SA_ID = az storage account show --name $STATE_SA --resource-group $STATE_RG --query id -o tsv
az role assignment create --assignee $ME --role "Storage Blob Data Owner" --scope $SA_ID | Out-Null

Write-Host ""
Write-Host "DONE. Put this name into the backend.tf of EACH environment:" -ForegroundColor Green
Write-Host "    storage_account_name = `"$STATE_SA`"" -ForegroundColor Yellow
