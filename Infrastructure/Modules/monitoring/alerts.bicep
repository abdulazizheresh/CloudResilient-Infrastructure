// Alerts for Monitoring
param actionGroupName string
param emailAddress string
param functionAppName string
param functionAppRg string
param sqlServerName string
param sqlServerRg string
param sqlDatabaseName string

param tags object = {
  Project: 'CloudResilient'
  Environment: 'Production'
  ManagedBy: 'Bicep'
}

// Action Group (Email notifications)
resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'global'
  tags: tags
  properties: {
    groupShortName: 'CloudRes'
    enabled: true
    emailReceivers: [
      {
        name: 'Email Admin'
        emailAddress: emailAddress
        useCommonAlertSchema: true
      }
    ]
  }
}

// Function App - High Response Time Alert
resource functionResponseTimeAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-func-response-time'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when Function App response time > 5 seconds'
    severity: 2
    enabled: true
    scopes: [
      resourceId(functionAppRg, 'Microsoft.Web/sites', functionAppName)
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'ResponseTime'
          metricName: 'HttpResponseTime'
          operator: 'GreaterThan'
          threshold: 5000
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

// Function App - HTTP 5xx Errors Alert
resource function5xxAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-func-5xx-errors'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when Function App has 5xx errors'
    severity: 1
    enabled: true
    scopes: [
      resourceId(functionAppRg, 'Microsoft.Web/sites', functionAppName)
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'Http5xxErrors'
          metricName: 'Http5xx'
          operator: 'GreaterThan'
          threshold: 5
          timeAggregation: 'Total'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

// SQL Database - High DTU Usage Alert
resource sqlDtuAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-sql-dtu-high'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when SQL Database DTU > 80%'
    severity: 2
    enabled: true
    scopes: [
      resourceId(sqlServerRg, 'Microsoft.Sql/servers/databases', sqlServerName, sqlDatabaseName)
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'DtuPercentage'
          metricName: 'dtu_consumption_percent'
          operator: 'GreaterThan'
          threshold: 80
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

output actionGroupId string = actionGroup.id
output actionGroupName string = actionGroup.name
