targetScope = 'subscription'

// Parameters for common
param location string = 'japaneast'
param systemCode string = 'hawk'
param env string = 'dev'

// Parameters for resorce group
param resourceGroupName string = 'rg-${systemCode}-${env}'

// Parameters for app service plan
param sku string = 'F1'

// deploy resource groups.
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

// deploy app service plan.
module asp 'modules/asp.bicep' = {
  scope: rg
  name: 'Deploy_app_service_plan'
  params: {
    location: location
    systemCode: systemCode
    env: env
    sku: sku
  }
}
