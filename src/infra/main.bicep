param location string = resourceGroup().location
param keyVaultName string = 'myworkspkeyvault43303873'
param API_KEY string
param AZURE_ML_ENDPOINT_URL string

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
  resource apiKey 'secrets' = {
    name: 'API_KEY'
    properties: {
      contentType: 'text/plain'
      value: API_KEY
    }
  }
  resource Url 'secrets' = {
    name: 'AZURE_ML_ENDPOINT_URL'
    properties: {
      contentType: 'text/plain'
      value: AZURE_ML_ENDPOINT_URL
    }
  }
}

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
        value: '@Microsoft.KeyVault(VaultName=${kv.name};SecretName=${kv::apiKey.name})'
      }
      {
        name: 'AZURE_ML_ENDPOINT_URL'
        value: '@Microsoft.KeyVault(VaultName=${kv.name};SecretName=${kv::Url.name})'
      }
      {
        name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
        value: '1'
      }
    ]
  }
}
