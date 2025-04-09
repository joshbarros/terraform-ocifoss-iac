output "instance_id" {
  description = "The OCID of the compute instance"
  value       = oci_core_instance.instance.id
}

output "instance_public_ip" {
  description = "The public IP address of the compute instance"
  value       = oci_core_instance.instance.public_ip
}

output "instance_private_ip" {
  description = "The private IP address of the compute instance"
  value       = oci_core_instance.instance.private_ip
}

output "instance_state" {
  description = "The state of the compute instance"
  value       = oci_core_instance.instance.state
}

output "instance_shape" {
  description = "The shape of the compute instance"
  value       = oci_core_instance.instance.shape
}

output "instance_availability_domain" {
  description = "The availability domain of the compute instance"
  value       = oci_core_instance.instance.availability_domain
}

output "boot_volume_id" {
  description = "The OCID of the boot volume"
  value       = oci_core_instance.instance.boot_volume_id
}
