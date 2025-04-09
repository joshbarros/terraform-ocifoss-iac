output "cpu_alarm_id" {
  description = "The OCID of the CPU alarm"
  value       = oci_monitoring_alarm.cpu_alarm.id
}

output "memory_alarm_id" {
  description = "The OCID of the memory alarm"
  value       = oci_monitoring_alarm.memory_alarm.id
}

output "disk_alarm_id" {
  description = "The OCID of the disk alarm"
  value       = oci_monitoring_alarm.disk_alarm.id
}

output "cpu_alarm_display_name" {
  description = "The display name of the CPU alarm"
  value       = oci_monitoring_alarm.cpu_alarm.display_name
}

output "memory_alarm_display_name" {
  description = "The display name of the memory alarm"
  value       = oci_monitoring_alarm.memory_alarm.display_name
}

output "disk_alarm_display_name" {
  description = "The display name of the disk alarm"
  value       = oci_monitoring_alarm.disk_alarm.display_name
}

output "cpu_threshold_percentage" {
  description = "The threshold percentage for CPU usage"
  value       = var.cpu_threshold_percentage
}

output "memory_threshold_percentage" {
  description = "The threshold percentage for memory usage"
  value       = var.memory_threshold_percentage
}

output "disk_threshold_percentage" {
  description = "The threshold percentage for disk usage"
  value       = var.disk_threshold_percentage
}
