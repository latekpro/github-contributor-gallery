#!/bin/bash

# Azure deployment script for GitHub Contributor Gallery
# This script deploys the Bicep template to Azure

# Required environment variables:
# AZURE_RESOURCE_GROUP_NAME - Name of the Azure resource group
# AZURE_LOCATION - Azure region to deploy to
# ENVIRONMENT_NAME - Environment name (dev, prod, etc.)

# Exit on any error
set -e

# Print commands for debugging
set -x

echo "Starting Azure deployment for GitHub Contributor Gallery"

# Validate parameters
if [ -z "$AZURE_RESOURCE_GROUP_NAME" ]; then
  echo "Error: AZURE_RESOURCE_GROUP_NAME is not set"
  exit 1
fi

if [ -z "$AZURE_LOCATION" ]; then
  echo "Error: AZURE_LOCATION is not set"
  exit 1
fi

if [ -z "$ENVIRONMENT_NAME" ]; then
  echo "Environment name not specified, using 'dev'"
  ENVIRONMENT_NAME="dev"
fi

# Create resource group if it doesn't exist
echo "Creating resource group $AZURE_RESOURCE_GROUP_NAME if it doesn't exist..."
az group create --name "$AZURE_RESOURCE_GROUP_NAME" --location "$AZURE_LOCATION" --output none

# Run Bicep deployment with what-if (validation only)
echo "Validating Bicep template..."
az deployment group what-if \
  --name "gcg-deployment-$(date +%Y%m%d%H%M%S)" \
  --resource-group "$AZURE_RESOURCE_GROUP_NAME" \
  --template-file ./infra/main.bicep \
  --parameters ./infra/main.parameters.json \
  --parameters environmentName="$ENVIRONMENT_NAME" \
  --output table

# Confirm deployment
echo "Starting deployment..."
DEPLOYMENT_NAME="gcg-deployment-$(date +%Y%m%d%H%M%S)"
az deployment group create \
  --name "$DEPLOYMENT_NAME" \
  --resource-group "$AZURE_RESOURCE_GROUP_NAME" \
  --template-file ./infra/main.bicep \
  --parameters ./infra/main.parameters.json \
  --parameters environmentName="$ENVIRONMENT_NAME" \
  --output json

# Get deployment outputs
echo "Getting deployment outputs..."
FRONTEND_APP_NAME=$(az deployment group show \
  --name "$DEPLOYMENT_NAME" \
  --resource-group "$AZURE_RESOURCE_GROUP_NAME" \
  --query "properties.outputs.frontendWebAppName.value" \
  --output tsv)

BACKEND_APP_NAME=$(az deployment group show \
  --name "$DEPLOYMENT_NAME" \
  --resource-group "$AZURE_RESOURCE_GROUP_NAME" \
  --query "properties.outputs.backendWebAppName.value" \
  --output tsv)

FRONTEND_URL=$(az deployment group show \
  --name "$DEPLOYMENT_NAME" \
  --resource-group "$AZURE_RESOURCE_GROUP_NAME" \
  --query "properties.outputs.frontendWebAppUrl.value" \
  --output tsv)

BACKEND_URL=$(az deployment group show \
  --name "$DEPLOYMENT_NAME" \
  --resource-group "$AZURE_RESOURCE_GROUP_NAME" \
  --query "properties.outputs.backendWebAppUrl.value" \
  --output tsv)

# Save outputs to GitHub environment variables for future steps
echo "FRONTEND_APP_NAME=$FRONTEND_APP_NAME" >> $GITHUB_ENV
echo "BACKEND_APP_NAME=$BACKEND_APP_NAME" >> $GITHUB_ENV
echo "FRONTEND_URL=$FRONTEND_URL" >> $GITHUB_ENV
echo "BACKEND_URL=$BACKEND_URL" >> $GITHUB_ENV

echo "Infrastructure deployment completed successfully!"
echo "Frontend App: $FRONTEND_URL"
echo "Backend App: $BACKEND_URL"
