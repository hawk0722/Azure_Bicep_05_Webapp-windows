@description('Location for all resources.')
param location string

@description('System code')
param systemCode string

@description('Environment')
param env string

@description('Name of web apps')
param appName string = 'app-${systemCode}-${env}'

@description('Name of app service plan')
param aspName string = 'asp-${systemCode}-${env}'

@description('Usage tiers of app service plan')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param sku string

@description('App Service プラン のデプロイ')
resource asp 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: aspName
  location: location
  sku: {
    name: sku
  }
}

@description('App Service のデプロイ')
resource app 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: asp.id
    httpsOnly: true
  }
}
