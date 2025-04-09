/**
 * Storage Module
 * This module creates block storage resources:
 * - Block volume
 * - Volume attachment
 */

# Create a block volume
resource "oci_core_volume" "volume" {
  availability_domain  = var.availability_domain
  compartment_id       = var.compartment_id
  display_name         = var.volume_display_name
  size_in_gbs          = var.volume_size_in_gbs
  vpus_per_gb          = var.volume_vpus_per_gb
  is_auto_tune_enabled = var.is_auto_tune_enabled
}

# Attach the volume to the instance
resource "oci_core_volume_attachment" "volume_attachment" {
  attachment_type = var.attachment_type
  instance_id     = var.instance_id
  volume_id       = oci_core_volume.volume.id
  display_name    = var.volume_attachment_display_name
  is_read_only    = var.is_read_only
}
