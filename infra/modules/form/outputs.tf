output "form_recognizer_name" {
  value = azurerm_cognitive_account.form.name
}

output "form_recognizer_endpoint" {
  value = azurerm_cognitive_account.form.endpoint
}

output "form_recognizer_key" {
  value = azurerm_cognitive_account.form.primary_access_key
}