# Azure Deployment Guide for GitHub Contributor Gallery

This document provides instructions on how to set up and run the GitHub Actions workflows to deploy the GitHub Contributor Gallery application to Azure.

## Prerequisites

Before you can deploy the application to Azure, you need to have:

1. An Azure account with an active subscription
2. A GitHub account
3. The application code pushed to a GitHub repository named `github-contributor-gallery-vd`

## Azure Setup

### 1. Create an Azure Service Principal

You need to create an Azure Service Principal to allow GitHub Actions to access your Azure resources.

```bash
# Login to Azure
az login

# Set your subscription (if you have multiple)
az account set --subscription "<subscription-id>"

# Create a service principal with Contributor role
az ad sp create-for-rbac --name "github-contributor-gallery" --role contributor \
    --scopes /subscriptions/<subscription-id> \
    --sdk-auth
```

The command will output a JSON object like this:

```json
{
  "clientId": "<client-id>",
  "clientSecret": "<client-secret>",
  "subscriptionId": "<subscription-id>",
  "tenantId": "<tenant-id>",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

Copy this entire JSON object for the next step.

### 2. Set Up GitHub Secrets

To allow the GitHub Actions workflows to authenticate with Azure, you need to set up the following secrets in your GitHub repository:

1. Go to your repository on GitHub
2. Navigate to "Settings" > "Secrets and variables" > "Actions"
3. Click on "New repository secret" and add the following secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AZURE_CREDENTIALS` | The entire JSON output from the previous step | Used for Azure authentication |
| `AZURE_LOCATION` | e.g., `eastus`, `westeurope` | The Azure region where resources will be deployed |
| `GITHUB_TOKEN` | (Optional) Your GitHub personal access token | For higher API rate limits |

## GitHub Actions Workflows

The repository contains the following GitHub Actions workflows located in the `.github/workflows` directory at the **repository root**:

1. **Deploy Infrastructure** (`deploy-infrastructure.yml`) - Deploys Azure resources using Bicep templates
2. **Deploy Backend** (`deploy-backend.yml`) - Builds and deploys the backend Node.js application
3. **Deploy Frontend** (`deploy-frontend.yml`) - Builds and deploys the frontend React application
4. **Full Deployment** (`full-deployment.yml`) - Combines all the above workflows in a single workflow with proper ordering

> **Note:** GitHub Actions workflows must be located in the `.github/workflows` directory at the root of your repository, not inside the project directory.

### Order of Execution

You can either:

#### Option 1: Run Individual Workflows

Run the workflows separately in the following order:

1. First, run the "Deploy Infrastructure" workflow to create all required Azure resources
2. Then, run the "Deploy Backend" workflow to deploy the backend API
3. Finally, run the "Deploy Frontend" workflow to deploy the React frontend

#### Option 2: Run Full Deployment Workflow

Alternatively, run the "Full Deployment" workflow which will:

1. Deploy all Azure infrastructure resources
2. Build and deploy the backend
3. Build and deploy the frontend
4. Verify the deployment by checking both services are accessible

## Running the Workflows

To run each workflow:

1. Go to your repository on GitHub
2. Navigate to the "Actions" tab
3. Select the workflow you want to run from the left sidebar
4. Click on "Run workflow" button
5. Select the environment (dev, test, or prod) from the dropdown
6. Click on "Run workflow" button to start the deployment

### Deploy Infrastructure

This workflow creates all required Azure resources:
- Resource Group (if it doesn't exist)
- App Service Plan
- Frontend Web App
- Backend Web App
- Application Insights
- Log Analytics Workspace
- User-Assigned Managed Identity

After running this workflow, you'll see the URLs for the frontend and backend in the workflow summary.

### Deploy Backend

This workflow builds and deploys the backend Node.js application:
- Installs dependencies
- Finds the backend web app created by the infrastructure workflow
- Deploys the code to Azure App Service
- Sets environment variables

### Deploy Frontend

This workflow builds and deploys the frontend React application:
- Installs dependencies
- Finds both frontend and backend web apps
- Configures the API URL to point to the backend
- Builds the React application with Vite
- Deploys the compiled code to Azure App Service

## Application URLs

After all workflows have run successfully, you can access the application at:

- Frontend: `https://<frontend-app-name>.azurewebsites.net`
- Backend API: `https://<backend-app-name>.azurewebsites.net`

The exact URLs will be displayed in the workflow logs after each deployment.

## Troubleshooting

If you encounter any issues during deployment:

1. Check the workflow logs for detailed error messages
2. Verify that all GitHub secrets are correctly set
3. Ensure that the Azure Service Principal has the required permissions
4. Check the Azure Portal for any resource-specific errors

For application-specific issues:

1. Check the Application Insights logs in Azure Portal
2. Look for error messages in the browser console for frontend issues
3. Test the backend API endpoints directly to isolate any problems

## Clean Up Resources

To avoid unnecessary charges, you can delete the resources when they're no longer needed:

```bash
az group delete --name rg-github-contributor-gallery-<environment> --yes --no-wait
```

Replace `<environment>` with the environment name you used (dev, test, or prod).

## Additional Notes

- The infrastructure is designed to be deployable to multiple environments (dev, test, prod)
- All resources are tagged with environment names for easier management
- App Service deployments use the ZIP deploy method for reliable and fast deployments
- The backend API has CORS configured to only allow requests from the frontend domain
