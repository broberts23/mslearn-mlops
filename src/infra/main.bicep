param location string = resourceGroup().location
param keyVaultName string = 'myworkspkeyvault43303873'

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

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

resource exampleAppService 'Microsoft.Web/sites@2022-09-01' = {
  name: 'mlflow-appservice' // must be globally unique
  location: location
  kind: 'linux'
  properties: {
    serverFarmId: exampleAppServicePlan.id
    reserved: true
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
    }
  }
}

resource exampleAppServiceConfig 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'web'
  parent: exampleAppService
  properties: {
    appSettings: [
      {
        name: 'API_KEY'
        value: '@Microsoft.KeyVault(VaultName=${kv.name};SecretName=apiKey'
      }
      {
        name: 'AZURE_ML_ENDPOINT_URL'
        value: '@Microsoft.KeyVault(VaultName=${kv.name};SecretName=endpointUrl'
      }
      {
        name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
        value: '1'
      }
    ]
  }
}
