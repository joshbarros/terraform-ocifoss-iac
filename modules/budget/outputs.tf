output "budget_id" {
  description = "The OCID of the budget"
  value       = oci_budget_budget.budget.id
}

output "budget_display_name" {
  description = "The display name of the budget"
  value       = oci_budget_budget.budget.display_name
}

output "budget_amount" {
  description = "The amount of the budget"
  value       = oci_budget_budget.budget.amount
}

output "budget_reset_period" {
  description = "The reset period of the budget"
  value       = oci_budget_budget.budget.reset_period
}

output "alert_rule_ids" {
  description = "The OCIDs of the alert rules"
  value       = oci_budget_alert_rule.alert_rules[*].id
}

output "alert_rule_thresholds" {
  description = "The thresholds of the alert rules"
  value       = oci_budget_alert_rule.alert_rules[*].threshold
}

output "alert_rule_display_names" {
  description = "The display names of the alert rules"
  value       = oci_budget_alert_rule.alert_rules[*].display_name
}
