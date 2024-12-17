output "applicationInsightsId" {
  value = azurerm_application_insights.applicationInsights.id
}

output "logAnalyticsId" {
  value = data.azurerm_log_analytics_workspace.ExistingLAW[count.index].id
}

output "applicationInsightsName" {
  value = azurerm_application_insights.applicationInsights.name
}

output "logAnalyticsName" {
  value = data.azurerm_log_analytics_workspace.ExistingLAW[count.index].id
}

output "applicationInsightsInstrumentationKey" {
  value = azurerm_application_insights.applicationInsights.instrumentation_key
}

output "applicationInsightsConnectionString" {
  value = azurerm_application_insights.applicationInsights.connection_string
}