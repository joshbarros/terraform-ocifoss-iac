variable "compartment_id" {
  description = "The OCID of the compartment where monitoring resources will be created"
  type        = string
}

variable "instance_id" {
  description = "The OCID of the instance to monitor"
  type        = string
}

variable "alarm_namespace" {
  description = "The namespace for the alarm"
  type        = string
  default     = "oci_computeagent"
}

variable "cpu_alarm_display_name" {
  description = "The display name for the CPU alarm"
  type        = string
  default     = "HighCPUAlarm"
}

variable "memory_alarm_display_name" {
  description = "The display name for the memory alarm"
  type        = string
  default     = "HighMemoryAlarm"
}

variable "disk_alarm_display_name" {
  description = "The display name for the disk alarm"
  type        = string
  default     = "HighDiskUsageAlarm"
}

variable "cpu_threshold_percentage" {
  description = "The threshold percentage for CPU usage"
  type        = number
  default     = 80
}

variable "memory_threshold_percentage" {
  description = "The threshold percentage for memory usage"
  type        = number
  default     = 80
}

variable "disk_threshold_percentage" {
  description = "The threshold percentage for disk usage"
  type        = number
  default     = 80
}

variable "metric_interval_in_seconds" {
  description = "The interval in seconds for metrics"
  type        = number
  default     = 300
}

variable "alarm_pending_duration_in_seconds" {
  description = "The pending duration in seconds for alarms"
  type        = number
  default     = 600
}

variable "alarm_severity" {
  description = "The severity of the alarm"
  type        = string
  default     = "CRITICAL"
}

variable "alarm_body" {
  description = "The body of the alarm notification"
  type        = string
  default     = "The FOSS Stack instance has exceeded the threshold for resource usage."
}

variable "alarm_destinations" {
  description = "The destinations for alarm notifications (e.g., email, topic)"
  type        = list(string)
}
