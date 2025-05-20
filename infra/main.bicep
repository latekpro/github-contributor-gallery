/*
  Main Bicep template for GitHub Contributor Gallery
  
  This template deploys the following resources:
  - App Service Plan for hosting the frontend and backend
  - Frontend Web App (React)
  - Backend Web App (Node.js)
  - Application Insights for monitoring
  - Log Analytics Workspace for logs
  - User Assigned Managed Identity for secure operations
*/

// Parameters
@description('The environment name, used for generating resource names')
param environmentName string = 'dev'

@description('The Azure region for all resources')
param location string = resourceGroup().location

@description('The SKU for App Service Plan')
param appServicePlanSku object = {
  name: 'B1'
  tier: 'Basic'
  capacity: 1
}

@description('Optional GitHub token for higher API rate limits')
@secure()
param githubToken string = ''

// Variables - Naming Convention: [resource]-[app]-[env]-[region]
var prefix = 'gcg' // GitHub Contributor Gallery
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)
var frontendAppName = '${prefix}-frontend-${environmentName}-${uniqueSuffix}'
var backendAppName = '${prefix}-backend-${environmentName}-${uniqueSuffix}'
var appServicePlanName = '${prefix}-asp-${environmentName}-${uniqueSuffix}'
var logAnalyticsName = '${prefix}-log-${environmentName}-${uniqueSuffix}'
var appInsightsName = '${prefix}-ai-${environmentName}-${uniqueSuffix}'
var managedIdentityName = '${prefix}-id-${environmentName}-${uniqueSuffix}'

// Create Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
  tags: {
    displayName: 'Log Analytics Workspace'
    environment: environmentName
  }
}

// Create Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  tags: {
    displayName: 'Application Insights'
    environment: environmentName
  }
}

// Create User Assigned Managed Identity
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
  tags: {
    displayName: 'User Assigned Managed Identity'
    environment: environmentName
  }
}

// Create App Service Plan (shared by both apps)
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: appServicePlanSku
  properties: {
    reserved: false // true for Linux, false for Windows
  }
  tags: {
    displayName: 'App Service Plan'
    environment: environmentName
  }
}

// Create Backend App Service (Node.js)
resource backendApp 'Microsoft.Web/sites@2022-03-01' = {
  name: backendAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'PORT'
          value: '5000'
        }
        {
          name: 'GITHUB_TOKEN'
          value: githubToken
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~18'
        }
      ]
      nodeVersion: '~18'
      alwaysOn: true
      cors: {
        allowedOrigins: [
          'https://${frontendApp.properties.defaultHostName}'
        ]
        supportCredentials: false
      }
    }
  }
  tags: {
    displayName: 'Backend Web App'
    'azd-service-name': 'backend'
    environment: environmentName
  }
}

// Create Frontend App Service (React)
resource frontendApp 'Microsoft.Web/sites@2022-03-01' = {
  name: frontendAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'BACKEND_URL'
          value: 'https://${backendApp.properties.defaultHostName}'
        }
        {
          name: 'REACT_APP_API_URL'
          value: 'https://${backendApp.properties.defaultHostName}/api'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~18'
        }
      ]
      nodeVersion: '~18'
      alwaysOn: true
    }
  }
  tags: {
    displayName: 'Frontend Web App'
    'azd-service-name': 'frontend'
    environment: environmentName
  }
}

// Configure diagnostic settings for both apps
resource backendAppDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'appServiceDiagnostics'
  scope: backendApp
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource frontendAppDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'appServiceDiagnostics'
  scope: frontendApp
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Output values 
output frontendWebAppName string = frontendApp.name
output frontendWebAppDefaultHostName string = frontendApp.properties.defaultHostName
output frontendWebAppResourceId string = frontendApp.id
output frontendWebAppUrl string = 'https://${frontendApp.properties.defaultHostName}'

output backendWebAppName string = backendApp.name
output backendWebAppDefaultHostName string = backendApp.properties.defaultHostName
output backendWebAppResourceId string = backendApp.id
output backendWebAppUrl string = 'https://${backendApp.properties.defaultHostName}'

output appServicePlanName string = appServicePlan.name
output appServicePlanId string = appServicePlan.id

output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
output applicationInsightsName string = applicationInsights.name
output managedIdentityName string = managedIdentity.name
output managedIdentityId string = managedIdentity.id
