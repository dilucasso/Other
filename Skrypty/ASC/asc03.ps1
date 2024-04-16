#tworzymy grupy zasobow
New-AzResourceGroup -name 'asc3_1' -Location 'westeurope'
New-AzResourceGroup -name 'asc3_2' -Location 'westeurope'


#zapisujemy informacje o grupach zasobów do zmiennych
$rg1 = Get-AzResourceGroup -name "asc3_1"
$rg2 = Get-AzResourceGroup -name "asc3_2"


#zapisujemy liste dozwolonych lokalizacji oraz zasobow do zmiennych
$allowed_locations = `
    (Get-AzLocation | Where-Object {$PSItem.Location -match 'europe'}).Location

$allowed_locations #wylistowanie lokalizacji

$allowed_resources = 'Microsoft.Storage/storageAccounts'
    

#zapisujemy informacje o definicjach polityk do zmiennych
$policy_allowed_locations = Get-AzPolicyDefinition | where {
    $_.Properties.DisplayName -like "Allowed locations"}

$policy_allowed_resources = Get-AzPolicyDefinition | where {
    $_.Properties.DisplayName -like "Allowed resource types"}


#wykonujemy przypisanie polityk
New-AzPolicyAssignment `
    -Name "PolicyAllowedLocations" `
    -PolicyDefinition $policy_allowed_locations `
    -Scope $rg1.ResourceId `
    -listOfAllowedLocations $allowed_locations

New-AzPolicyAssignment `
    -Name "PolicyAllowedResources" `
    -PolicyDefinition $policy_allowed_resources `
    -Scope $rg2.ResourceId `
    -listOfResourceTypesAllowed $allowed_resources


#weryfikujemyu przypisane ograniczenia
(Get-AzPolicyAssignment -Scope $rg1.ResourceId).Properties.Parameters.listOfAllowedLocations
(Get-AzPolicyAssignment -Scope $rg2.ResourceId).Properties.Parameters.listOfResourceTypesAllowed

############################################
#testy polityk

#test polityki Allowed locations
New-AzStorageAccount -name 'lp09122023sa1' -ResourceGroupName asc3_1 `
    -Location 'polandcentral' -SkuName Standard_LRS
New-AzStorageAccount -name 'lp09122023sa1' -ResourceGroupName asc3_1 `
    -Location 'westeurope' -SkuName Standard_LRS

#test polityki Allowed resource types
New-AzVirtualNetwork -name 'lp09122023vnet2' -ResourceGroupName asc3_2 `
    -Location 'polandcentral' -AddressPrefix 192.168.0.1/24
New-AzStorageAccount -name 'lp09122023sa2' -ResourceGroupName asc3_2 `
    -Location 'polandcentral' -SkuName Standard_LRS
