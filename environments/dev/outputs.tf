/**
 * Development Environment Outputs
 * These outputs provide information about the created resources
 */

output "compartment_id" {
  description = "The OCID of the compartment"
  value       = oci_identity_compartment.compartment.id
}

output "compartment_name" {
  description = "The name of the compartment"
  value       = oci_identity_compartment.compartment.name
}

output "vcn_id" {
  description = "The OCID of the VCN"
  value       = module.network.vcn_id
}

output "subnet_id" {
  description = "The OCID of the subnet"
  value       = module.network.subnet_id
}

output "instance_id" {
  description = "The OCID of the compute instance"
  value       = module.compute.instance_id
}

output "instance_public_ip" {
  description = "The public IP address of the compute instance"
  value       = module.compute.instance_public_ip
}

output "instance_state" {
  description = "The state of the compute instance"
  value       = module.compute.instance_state
}

output "volume_id" {
  description = "The OCID of the block volume"
  value       = module.storage.volume_id
}

output "volume_size_in_gbs" {
  description = "The size of the block volume in GB"
  value       = module.storage.volume_size_in_gbs
}

output "budget_id" {
  description = "The OCID of the budget"
  value       = module.budget.budget_id
}

output "budget_amount" {
  description = "The amount of the budget"
  value       = module.budget.budget_amount
}

output "alarm_topic_id" {
  description = "The OCID of the alarms topic"
  value       = oci_ons_notification_topic.alarms_topic.id
}

output "cpu_alarm_id" {
  description = "The OCID of the CPU alarm"
  value       = module.monitoring.cpu_alarm_id
}

output "memory_alarm_id" {
  description = "The OCID of the memory alarm"
  value       = module.monitoring.memory_alarm_id
}

output "disk_alarm_id" {
  description = "The OCID of the disk alarm"
  value       = module.monitoring.disk_alarm_id
}

output "ssh_connection_string" {
  description = "The SSH connection string for the compute instance"
  value       = "ssh ubuntu@${module.compute.instance_public_ip} -i ${replace(var.ssh_public_key_path, ".pub", "")}"
}
