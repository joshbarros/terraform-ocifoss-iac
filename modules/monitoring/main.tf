/**
 * Monitoring Module
 * This module creates monitoring resources:
 * - CPU, memory, and disk usage alarms
 */

# Create CPU usage alarm
resource "oci_monitoring_alarm" "cpu_alarm" {
  compartment_id        = var.compartment_id
  display_name          = var.cpu_alarm_display_name
  destinations          = var.alarm_destinations
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = var.alarm_namespace
  query                 = "CpuUtilization[${var.metric_interval_in_seconds}].mean() > ${var.cpu_threshold_percentage}"
  severity              = var.alarm_severity
  body                  = var.alarm_body
  resource_group        = "compute-${var.instance_id}"
  
  pending_duration = "PT${var.alarm_pending_duration_in_seconds}S"
}

# Create memory usage alarm
resource "oci_monitoring_alarm" "memory_alarm" {
  compartment_id        = var.compartment_id
  display_name          = var.memory_alarm_display_name
  destinations          = var.alarm_destinations
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = var.alarm_namespace
  query                 = "MemoryUtilization[${var.metric_interval_in_seconds}].mean() > ${var.memory_threshold_percentage}"
  severity              = var.alarm_severity
  body                  = var.alarm_body
  resource_group        = "compute-${var.instance_id}"
  
  pending_duration = "PT${var.alarm_pending_duration_in_seconds}S"
}

# Create disk usage alarm
resource "oci_monitoring_alarm" "disk_alarm" {
  compartment_id        = var.compartment_id
  display_name          = var.disk_alarm_display_name
  destinations          = var.alarm_destinations
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = var.alarm_namespace
  query                 = "DiskUtilization[${var.metric_interval_in_seconds}].mean() > ${var.disk_threshold_percentage}"
  severity              = var.alarm_severity
  body                  = var.alarm_body
  resource_group        = "compute-${var.instance_id}"
  
  pending_duration = "PT${var.alarm_pending_duration_in_seconds}S"
}
