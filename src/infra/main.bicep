param location string = resourceGroup().location

resource exampleAppServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'mlflow-ASP'
  location: location
  kind: 'Linux'
  properties: {
    reserved: true
  }
  sku: {
    tier: 'Basic'
    name: 'B1'
  }
}

resource exampleAppService 'Microsoft.Web/sites@2022-09-01' = {
  name: 'mlflow-appservice' // must be globally unique
  location: location
  kind: 'linux'
  properties: {
    serverFarmId: exampleAppServicePlan.id
    siteConfig: {
      appCommandLine: ''
      pythonVersion: '3.10'

    }
  }
}
