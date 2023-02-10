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

@description('arrangement of Scale out condition')
param args array = [
  {
    direction: 'Increase'
    operator: 'GreaterThan'
    threshold: 70
  }
  {
    direction: 'Decrease'
    operator: 'LessThan'
    threshold: 30
  }
]

var rules = [for arg in args: {
  scaleAction: {
    cooldown: 'PT5M' // 5 minutes
    direction: arg.direction
    type: 'ChangeCount'
    value: '1'
  }
  metricTrigger: {
    metricName: 'CpuPercentage'
    metricResourceUri: asp.id
    operator: arg.operator
    statistic: 'Average'
    threshold: arg.threshold
    timeAggregation: 'Average'
    timeGrain: 'PT1M'
    timeWindow: 'PT10M'
  }
}]

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
        rules: rules
      }
    ]
    targetResourceLocation: location
    targetResourceUri: asp.id
  }
}
