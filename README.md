# Function App with Private Event Hub

Integration between Event Hubs and Azure Virtual Networks creates a secure messaging layer that can be accessed from other services within the network. Azure Functions can be similarly integrated with services inside virtual networks, enabling creation of workloads that execute on message ingestion, through input bindings.

## Features

This project framework provides the following features:

* An Azure Event Hub used to ingest messages.
* A Function App with an Event Hub triggered Azure Function.
* An Azure Key Vault instance used to securely store all secret values.
* An Azure Virtual Network, Private Endpoints, and network access controls that restrict access to the Event Hub, Storage Account, and Key Vault.
* All components are deployable via Bicep or Terraform.

## Architecture

![Architecture diagram](./media/architectureDiagram.svg)

## Getting Started

### Prerequisites

* [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
* [Azure Functions Core Tools](https://docs.microsoft.com/azure/azure-functions/functions-run-local?tabs=windows%2Ccsharp%2Cbash#install-the-azure-functions-core-tools)
* [.NET](https://docs.microsoft.com/dotnet/core/install/)
* [Bicep](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install) or [Terraform](https://www.terraform.io/downloads.html)

### Deploy the Infrastructure

The project can be deployed using _either_ Bicep _or_ Terraform.

#### Bicep

1. Create a new Azure resource group to deploy the Bicep template to, passing in a location and name - `az group create --location <LOCATION> --name <RESOURCE_GROUP_NAME>`
2. The [azuredeploy.parameters.json](./IaC/bicep/azuredeploy.parameters.json) file contains the necessary variables to deploy the Bicep project. Update the file with appropriate values. Descriptions for each parameter can be found in the [main.bicep](./IaC/bicep/main.bicep) file.
3. Optionally, verify what Bicep will deploy, passing in the name of the resource group created earlier and the necessary parameters for the Bicep template - `az deployment group what-if --resource-group <RESOURCE_GROUP_NAME> --template-file .\main.bicep --parameters .\azuredeploy.parameters.json`
4. Deploy the template, passing in the name of the resource group created earlier and the necessary parameters for the Bicep template - `az deployment group create --resource-group <RESOURCE_GROUP_NAME> --template-file .\main.bicep --parameters .\azuredeploy.parameters.json`

#### Terraform

1. The [terraform.tfvars](./IaC/terraform/terraform.tfvars) file contains the necessary variables to apply the Terraform configuration. Update the file with appropriate values. Descriptions for each variable can be found in the [variables.tf](./IaC/terraform/variables.tf) file.
2. Initialize Terraform - `terraform init`
3. Optionally, verify what Terraform will deploy - `terraform plan`
4. Deploy the configuration - `terraform apply`

### Deploy the Function App Code

The project provides sample Azure Functions code to verify that the solution is working correctly. It contains an Event Hub triggered Azure Function used to process incoming messages and a second, disabled, timer triggered Azure Function that sends messages to the Event Hub using output bindings and is used to test that the processor is operating properly.

1. Navigate to the [./src/eventhub-trigger](./src/eventhub-trigger) directory.
2. Deploy the code to the function app provisioned by Bicep or Terraform - `func azure functionapp publish <FUNCTION_APP_NAME> --dotnet`

### Test the Event Hub and Function App

1. Navigate to the [Azure Portal](https://portal.azure.com) and find the Function App that was provisioned.
2. Open the **Configuration** blade.
3. Find the `AzureWebJobs.Tester.Disabled` application setting and edit the value to `false`.
4. Save the changes.
5. Find the Application Insights resource that was provisioned.
6. Open the **Logs** blade.
7. Query for the results from the `requests` table.
8. Observe the successful `EventHubProcessor` runs.

## Resources

* [Tutorial: Integrate Azure Functions with an Azure virtual network by using private endpoints](https://docs.microsoft.com/azure/azure-functions/functions-create-vnet)
* [Integrate your app with an Azure virtual network](https://docs.microsoft.com/azure/app-service/overview-vnet-integration)
* [Azure Functions networking options](https://docs.microsoft.com/azure/azure-functions/functions-networking-options)
* [Network security for Azure Event Hubs](https://docs.microsoft.com/azure/event-hubs/network-security)
* [Configure Azure Storage firewalls and virtual networks](https://docs.microsoft.com/azure/storage/common/storage-network-security)
* [Configure Azure Key Vault firewalls and virtual networks](https://docs.microsoft.com/en-us/azure/key-vault/general/network-security)
* [Analyze Azure Functions telemetry in Application Insights](https://docs.microsoft.com/azure/azure-functions/analyze-telemetry-data)
