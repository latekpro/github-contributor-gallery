#!/bin/bash

# Script to verify Azure App Services health after deployment
# Usage: ./verify-deployment.sh <resource-group-name>

set -e

# Default resource group
RESOURCE_GROUP=${1:-"rg-github-contributor-gallery-dev"}

echo "Verifying deployment in resource group: $RESOURCE_GROUP"

# Get web app names
echo "Finding web apps..."
FRONTEND_APP=$(az webapp list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[?tags.\"azd-service-name\"=='frontend'].name" \
  --output tsv)

BACKEND_APP=$(az webapp list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[?tags.\"azd-service-name\"=='backend'].name" \
  --output tsv)

if [ -z "$FRONTEND_APP" ] || [ -z "$BACKEND_APP" ]; then
  echo "Error: Could not find web apps in resource group $RESOURCE_GROUP"
  exit 1
fi

echo "Found apps:"
echo "  Frontend: $FRONTEND_APP"
echo "  Backend: $BACKEND_APP"

# Get hostnames
FRONTEND_URL=$(az webapp show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$FRONTEND_APP" \
  --query "defaultHostName" \
  --output tsv)

BACKEND_URL=$(az webapp show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$BACKEND_APP" \
  --query "defaultHostName" \
  --output tsv)

echo "Checking backend health..."
HEALTH_ENDPOINT="https://$BACKEND_URL/api/health"
HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_ENDPOINT" || echo "failed")

if [ "$HEALTH_STATUS" == "200" ]; then
  echo "✓ Backend health check successful"
else
  echo "✗ Backend health check failed: $HEALTH_STATUS"
  echo "  URL: $HEALTH_ENDPOINT"
fi

echo "Checking frontend..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://$FRONTEND_URL" || echo "failed")

if [ "$FRONTEND_STATUS" == "200" ]; then
  echo "✓ Frontend is accessible"
else
  echo "✗ Frontend check failed: $FRONTEND_STATUS"
  echo "  URL: https://$FRONTEND_URL"
fi

echo "Full URLs:"
echo "  Frontend: https://$FRONTEND_URL"
echo "  Backend API: https://$BACKEND_URL/api"
echo "  Backend Health: $HEALTH_ENDPOINT"
