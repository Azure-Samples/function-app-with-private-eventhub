@description('The Azure region for the specified resources.')
param location string = resourceGroup().location

@description('The base name to be appended to all provisioned resources.')
@maxLength(13)
param resourceBaseName string = uniqueString(resourceGroup().id)

@description('The name of the Function App to provision.')
param azureFunctionAppName string

@description('Specifies if the Azure Function app is accessible via HTTPS only.')
param httpsOnly bool = false

@description('Set to true to cause all outbound traffic to be routed into the virtual network (traffic subjet to NSGs and UDRs). Set to false to route only private (RFC1918) traffic into the virtual network.')
param vnetRouteAllEnabled bool = false

@description('Specify the Azure Resource Manager ID of the virtual network and subnet to be joined by regional vnet integration.')
param virtualNetworkSubnetId string

resource azureFunctionPlan 'Microsoft.Web/serverfarms@2021-01-01' = {
  name: 'plan-${resourceBaseName}'
  location: location
  kind: 'elastic'
  sku: {
    name: 'EP1'
    tier: 'ElasticPremium'
    size: 'EP1'
  }
  properties: {
    maximumElasticWorkerCount: 20
    reserved: false
  }
}

resource azureFunction 'Microsoft.Web/sites@2020-12-01' = {
  name: azureFunctionAppName
  location: location
  kind: 'functionapp'
  properties: {
    httpsOnly: httpsOnly
    serverFarmId: azureFunctionPlan.id
    reserved: false
    virtualNetworkSubnetId: virtualNetworkSubnetId
    siteConfig: {
      vnetRouteAllEnabled: vnetRouteAllEnabled
      functionsRuntimeScaleMonitoringEnabled: true
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned'
  }

  resource config 'config' = {
    name: 'web'
    properties: {
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }
}

output azureFunctionTenantId string = azureFunction.identity.tenantId
output azureFunctionPrincipalId string = azureFunction.identity.principalId
