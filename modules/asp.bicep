@description('Location for all resources.')
param location string

@description('System code')
param systemCode string

@description('Environment')
param env string

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

@description('Name of web apps')
param appName string = 'app-${systemCode}-${env}'

@description('Deploy app service plan.')
resource asp 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: aspName
  location: location
  sku: {
    name: sku
    capacity: 1
  }
}

@description('Deploy web app.')
resource app 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: asp.id
    httpsOnly: true
    siteConfig: {
      windowsFxVersion: 'DOTNET|4.7'
    }
  }
}

resource ass 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: asp.name
  location: location
  properties: {
    enabled: true
    profiles: [
      {
        name: 'Scale out condition'
        capacity: {
          default: '1'
          maximum: '2'
          minimum: '1'

        }
        rules: [
          {
            scaleAction: {
              cooldown: 'PT5M' // 5 minutes
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
            }
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: asp.id
              operator: 'GreaterThan'
              statistic: 'Average'
              threshold: 70
              timeAggregation: 'Average'
              timeGrain: 'PT1M'
              timeWindow: 'PT10M'
            }
          }
          {
            scaleAction: {
              cooldown: 'PT5M'
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
            }
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: asp.id
              operator: 'LessThan'
              statistic: 'Average'
              threshold: 20
              timeAggregation: 'Average'
              timeGrain: 'PT1M'
              timeWindow: 'PT10M'
            }
          }
        ]
      }
    ]
    targetResourceLocation: location
    targetResourceUri: asp.id
  }
}
