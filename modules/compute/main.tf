/**
 * Compute Module
 * This module creates compute instance resources:
 * - Instance with cloud-init configuration
 */

# Create the compute instance
resource "oci_core_instance" "instance" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = var.instance_display_name
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = var.vnic_display_name
    assign_public_ip = var.assign_public_ip
  }

  source_details {
    source_type             = "image"
    source_id               = var.source_image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = base64encode(file(var.cloud_init_file_path))
  }

  timeouts {
    create = "20m"
  }
}
