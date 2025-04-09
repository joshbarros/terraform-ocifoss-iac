/**
 * Budget Module
 * This module creates budget and alert resources:
 * - Budget
 * - Budget alert rules at various thresholds
 */

# Create budget to monitor spending
resource "oci_budget_budget" "budget" {
  compartment_id = var.compartment_id
  amount         = var.budget_amount
  reset_period   = var.budget_reset_period
  target_type    = "COMPARTMENT"
  targets        = [var.tenancy_ocid]
  display_name   = var.budget_display_name
  description    = var.budget_description
}

# Create budget alert rules at various thresholds using count
resource "oci_budget_alert_rule" "alert_rules" {
  count          = length(var.alert_thresholds)
  budget_id      = oci_budget_budget.budget.id
  threshold      = var.alert_thresholds[count.index]
  threshold_type = "PERCENTAGE"
  type           = "ACTUAL"
  display_name   = var.alert_display_names[count.index]
  description    = var.alert_threshold_descriptions[count.index]
  message        = var.alert_messages[count.index]
  recipients     = var.alert_email
}
