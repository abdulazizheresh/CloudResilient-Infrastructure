// Static Web App with GitHub Integration
param location string = 'centralus'
param staticWebAppName string = 'swa-cloudres-centralus-prod'
param repositoryUrl string = '[GITHUB_REPO_URL]'  // e.g., '
param branch string = 'main'

@secure()
param repositoryToken string

param tags object = {
  Project: 'CloudResilient'
  Environment: 'Production'
  ManagedBy: 'Bicep'
}

resource staticWebApp 'Microsoft.Web/staticSites@2023-01-01' = {
  name: staticWebAppName
  location: location
  tags: tags
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {
    repositoryUrl: repositoryUrl
    repositoryToken: repositoryToken
    branch: branch
    provider: 'GitHub'
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    buildProperties: {
      appLocation: '/'
      apiLocation: ''
      outputLocation: ''
      skipGithubActionWorkflowGeneration: false  // Azure ينشئ GitHub Actions workflow
    }
  }
}

output staticWebAppId string = staticWebApp.id
output staticWebAppName string = staticWebApp.name
output staticWebAppUrl string = staticWebApp.properties.defaultHostname
output staticWebAppDeploymentToken string = listSecrets(staticWebApp.id, staticWebApp.apiVersion).properties.apiKey
