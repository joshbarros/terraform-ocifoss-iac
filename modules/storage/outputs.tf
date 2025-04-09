output "volume_id" {
  description = "The OCID of the block volume"
  value       = oci_core_volume.volume.id
}

output "volume_attachment_id" {
  description = "The OCID of the volume attachment"
  value       = oci_core_volume_attachment.volume_attachment.id
}

output "volume_size_in_gbs" {
  description = "The size of the block volume in GB"
  value       = oci_core_volume.volume.size_in_gbs
}

output "volume_state" {
  description = "The state of the block volume"
  value       = oci_core_volume.volume.state
}

output "volume_attachment_state" {
  description = "The state of the volume attachment"
  value       = oci_core_volume_attachment.volume_attachment.state
}

output "volume_vpus_per_gb" {
  description = "The VPUs per GB for the block volume"
  value       = oci_core_volume.volume.vpus_per_gb
}

output "attachment_type" {
  description = "The type of volume attachment"
  value       = oci_core_volume_attachment.volume_attachment.attachment_type
}
