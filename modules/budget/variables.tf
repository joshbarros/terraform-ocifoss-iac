variable "tenancy_ocid" {
  description = "The OCID of the tenancy"
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment where budget resources will be created"
  type        = string
}

variable "budget_display_name" {
  description = "The display name for the budget"
  type        = string
  default     = "Credit-Usage-Alert"
}

variable "budget_description" {
  description = "The description for the budget"
  type        = string
  default     = "Budget to monitor credit usage before expiration on April 23rd (US$250)"
}

variable "budget_amount" {
  description = "The amount for the budget in USD"
  type        = number
  default     = 250
}

variable "budget_reset_period" {
  description = "The reset period for the budget"
  type        = string
  default     = "MONTHLY"
}

variable "alert_email" {
  description = "The email address to send budget alerts to"
  type        = string
}

variable "alert_thresholds" {
  description = "The thresholds for budget alerts (percentage)"
  type        = list(number)
  default     = [10, 25, 50, 75, 90, 95]
}

variable "alert_threshold_descriptions" {
  description = "Descriptions for each alert threshold"
  type        = list(string)
  default = [
    "Alert when spending reaches 10% of credits (US$25)",
    "Alert when spending reaches 25% of credits (US$62.5)",
    "Alert when spending reaches 50% of credits (US$125)",
    "Alert when spending reaches 75% of credits (US$187.5)",
    "Alert when spending reaches 90% of credits (US$225)",
    "Alert when spending reaches 95% of credits (US$237.5)"
  ]
}

variable "alert_messages" {
  description = "Messages for each alert threshold"
  type        = list(string)
  default = [
    "INITIAL: You have used 10% of your OCI credits. Monitoring usage.",
    "NOTIFICATION: You have used 25% of your OCI credits. Review your usage.",
    "ATTENTION: You have used 50% of your OCI credits. Consider checking your usage.",
    "WARNING: You have used 75% of your OCI credits. Review your resources soon.",
    "URGENT: You have used 90% of your OCI credits. Consider shutting down resources.",
    "CRITICAL: You have used 95% of your OCI credits. Shut down paid resources immediately."
  ]
}

variable "alert_display_names" {
  description = "Display names for each alert threshold"
  type        = list(string)
  default     = ["10-Percent-Alert", "25-Percent-Alert", "50-Percent-Alert", "75-Percent-Alert", "90-Percent-Alert", "95-Percent-Alert"]
}
