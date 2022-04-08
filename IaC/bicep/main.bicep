@description('The Azure region for the specified resources.')
param location string = resourceGroup().location

@description('The username to use for the virtual machine.')
@secure()
param vmAdminUsername string

@description('The password to use for the virtual machine.')
@secure()
param vmAdminPassword string

// Ensure that a user-provided value is lowercase.
var baseName = toLower(uniqueString(resourceGroup().id))

var vnetName = 'vnet-${baseName}'
var subnetAppServiceIntName = 'snet-${baseName}-ase'
var subnetPrivateEndpointName = 'snet-${baseName}-pe'
var subnetVmName = 'snet-${baseName}-vm'
var fileShareName = 'fileshare'
var keyVaultName = 'kv-${baseName}'
var azureFunctionAppName = 'func-${baseName}'

module network './modules/network.bicep' = {
  name: 'networkDeploy'
  params: {
    location: location
    resourceBaseName: baseName
    virtualNetworkName: vnetName
    subnetVmName: subnetVmName
    subnetAppServiceIntName: subnetAppServiceIntName
    subnetPrivateEndpointName: subnetPrivateEndpointName
    subnetAppServiceIntServiceEndpointTypes: [
      'Microsoft.EventHub'
    ]
  }
}

module bastion './modules/bastion.bicep' = {
  name: 'bastionDeploy'
  params: {
    location: location
    resourceBaseName: baseName
    bastionHostName: 'bas-${baseName}'
    bastionSubnetId: network.outputs.subnetBastionId
  }
}

module vm './modules/windows-vm.bicep' = {
  name: 'windowsVmDeploy'
  params: {
    location: location
    resourceBaseName: baseName
    adminPassword: vmAdminPassword
    adminUserName: vmAdminUsername
    vmSubnetId: network.outputs.subnetVmId
  }
}

module eventHub './modules/private-event-hub.bicep' = {
  name: 'eventHubDeploy'
  params: {
    location: location
    resourceBaseName: baseName
    virtualNetworkId: network.outputs.virtualNetworkId
    subnetPrivateEndpointId: network.outputs.subnetPrivateEndpointId
    subnetPrivateEndpointName: subnetPrivateEndpointName
    keyVaultName: keyVault.outputs.keyVaultName
    keyVaultConnectionStringSecretName: 'kvs-${baseName}-evhconn'
  }
}

module applicationInsights './modules/app-insights.bicep' = {
  name: 'appInsightsDeploy'
  params: {
    location: location
    resourceBaseName: baseName
  }
}

module storageAccount './modules/private-storage.bicep' = {
  name: 'storageDeploy'
  params: {
    location: location
    resourceBaseName: baseName
    subnetPrivateEndpointId: network.outputs.subnetPrivateEndpointId
    subnetPrivateEndpointName: subnetPrivateEndpointName
    fileShareName: fileShareName
    virtualNetworkId: network.outputs.virtualNetworkId
    keyVaultConnectionStringSecretName: 'kvs-${baseName}-stconn'
    keyVaultName: keyVault.outputs.keyVaultName
  }
}

module keyVault './modules/private-key-vault.bicep' = {
  name: 'keyVaultDeploy'
  params: {
    location: location
    resourceBaseName: baseName
    virtualNetworkId: network.outputs.virtualNetworkId
    subnetPrivateEndpointId: network.outputs.subnetPrivateEndpointId
    subnetPrivateEndpointName: subnetPrivateEndpointName
    keyVaultName: keyVaultName
    keyVaultAccessPolicies: [
      {
        tenantId: azureFunctions.outputs.azureFunctionTenantId
        objectId: azureFunctions.outputs.azureFunctionPrincipalId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}

module azureFunctions './modules/azure-functions.bicep' = {
  name: 'azureFunctionsDeploy'
  params: {
    location: location
    virtualNetworkSubnetId: network.outputs.subnetAppServiceIntId
    vnetRouteAllEnabled: false
    resourceBaseName: baseName
    azureFunctionAppName: azureFunctionAppName
  }
}

resource appInsightsInstrumentationKeyKeyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVaultName}/kvs-${baseName}-aikey'
  dependsOn: [
    keyVault
  ]
  properties: {
    value: applicationInsights.outputs.instrumentationKey
  }
}

resource additionalAppSettings 'Microsoft.Web/sites/config@2021-01-15' = {
  name: '${azureFunctionAppName}/appsettings'
  dependsOn: [
    keyVault
    azureFunctions
  ]
  properties: {
    AzureWebJobsStorage: '@Microsoft.KeyVault(SecretUri=${storageAccount.outputs.storageAccountConnectionStringSecretUriWithVersion})'
    APPINSIGHTS_INSTRUMENTATIONKEY: '@Microsoft.KeyVault(SecretUri=${appInsightsInstrumentationKeyKeyVaultSecret.properties.secretUriWithVersion})'
    EventHubConnectionString: '@Microsoft.KeyVault(SecretUri=${eventHub.outputs.eventHubConnectionStringSecretUriWithVersion})'
    EventHubName: eventHub.outputs.eventHubName
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(SecretUri=${storageAccount.outputs.storageAccountConnectionStringSecretUriWithVersion})'
    WEBSITE_CONTENTSHARE: fileShareName
    FUNCTIONS_EXTENSION_VERSION: '~3'
    FUNCTIONS_WORKER_RUNTIME: 'dotnet'
    WEBSITE_CONTENTOVERVNET: '1'
    WEBSITE_SKIP_CONTENTSHARE_VALIDATION: '1'
    'AzureWebJobs.Tester.Disabled': true
  }
}
