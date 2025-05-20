#!/bin/bash

# Script to update API URL in the frontend environment file
# This script can be run locally before deployment or within a CI/CD pipeline

# Default values
API_URL=${1:-"http://localhost:5000/api"}
ENV_FILE="./frontend/.env"

# Create or update .env file with the API URL
echo "Setting API URL to: $API_URL"
echo "VITE_API_URL=$API_URL" > "$ENV_FILE"

echo "Environment file updated successfully"
cat "$ENV_FILE"
