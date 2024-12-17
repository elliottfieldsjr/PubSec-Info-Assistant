output "applicationInsightsId" {
  value = azurerm_application_insights.applicationInsights.id
}

output "applicationInsightsName" {
  value = azurerm_application_insights.applicationInsights.name
}

output "applicationInsightsInstrumentationKey" {
  value = azurerm_application_insights.applicationInsights.instrumentation_key
}

output "applicationInsightsConnectionString" {
  value = azurerm_application_insights.applicationInsights.connection_string
}