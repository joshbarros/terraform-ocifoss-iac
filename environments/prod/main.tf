/**
 * Production Environment
 * This is the main Terraform configuration for the production environment
 */

# Configure the OCI provider
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Fetch available ADs
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Get latest Ubuntu image
data "oci_core_images" "ubuntu_images" {
  compartment_id           = var.tenancy_ocid
  operating_system         = var.operating_system
  operating_system_version = var.operating_system_version
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Create a compartment for resources
resource "oci_identity_compartment" "compartment" {
  name          = var.compartment_name
  description   = var.compartment_description
  enable_delete = var.enable_delete
}

# Create networking resources
module "network" {
  source = "../../modules/network"

  compartment_id                = oci_identity_compartment.compartment.id
  vcn_display_name              = var.vcn_display_name
  vcn_cidr_blocks               = var.vcn_cidr_blocks
  subnet_display_name           = var.subnet_display_name
  subnet_cidr_block             = var.subnet_cidr_block
  internet_gateway_display_name = "${var.vcn_display_name}-ig"
  route_table_display_name      = "${var.vcn_display_name}-rt"
  security_list_display_name    = "${var.vcn_display_name}-sl"
  open_ports                    = [22, 80, 443, 6443, 8080, 9000, 9001, 3000, 3100, 5678, 8090, 31208]
  prohibit_public_ip_on_vnic    = false
}

# Create compute instance
module "compute" {
  source = "../../modules/compute"

  compartment_id          = oci_identity_compartment.compartment.id
  availability_domain     = data.oci_identity_availability_domains.ads.availability_domains[0].name
  subnet_id               = module.network.subnet_id
  instance_display_name   = var.instance_display_name
  instance_shape          = var.instance_shape
  source_image_id         = data.oci_core_images.ubuntu_images.images[0].id
  boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  cloud_init_file_path    = "../../config/cloud-init/foss-stack.yml"
  ssh_public_key_path     = var.ssh_public_key_path
  vnic_display_name       = "${var.instance_display_name}-vnic"
  assign_public_ip        = true
}

# Create storage resources
module "storage" {
  source = "../../modules/storage"

  compartment_id                 = oci_identity_compartment.compartment.id
  availability_domain            = data.oci_identity_availability_domains.ads.availability_domains[0].name
  instance_id                    = module.compute.instance_id
  volume_display_name            = var.volume_display_name
  volume_size_in_gbs             = var.volume_size_in_gbs
  volume_vpus_per_gb             = var.volume_vpus_per_gb
  volume_attachment_display_name = "${var.volume_display_name}-attachment"
  attachment_type                = "paravirtualized"
  is_read_only                   = false
  is_auto_tune_enabled           = true
}

# Create budget and alerts
module "budget" {
  source = "../../modules/budget"

  tenancy_ocid        = var.tenancy_ocid
  compartment_id      = var.tenancy_ocid
  budget_display_name = var.budget_display_name
  budget_description  = "Budget to monitor credit usage before expiration (US$${var.budget_amount})"
  budget_amount       = var.budget_amount
  budget_reset_period = "MONTHLY"
  alert_email         = var.alert_email
}

# Create alarms topic for notifications
resource "oci_ons_notification_topic" "alarms_topic" {
  compartment_id = oci_identity_compartment.compartment.id
  name           = "foss-stack-alarms"
  description    = "Topic for FOSS stack monitoring alarms"
}

# Create monitoring resources
module "monitoring" {
  source = "../../modules/monitoring"

  compartment_id                    = oci_identity_compartment.compartment.id
  instance_id                       = module.compute.instance_id
  alarm_namespace                   = "oci_computeagent"
  cpu_alarm_display_name            = "FOSS-Stack-CPU-Alarm"
  memory_alarm_display_name         = "FOSS-Stack-Memory-Alarm"
  disk_alarm_display_name           = "FOSS-Stack-Disk-Alarm"
  cpu_threshold_percentage          = var.cpu_threshold_percentage
  memory_threshold_percentage       = var.memory_threshold_percentage
  disk_threshold_percentage         = var.disk_threshold_percentage
  metric_interval_in_seconds        = 300
  alarm_pending_duration_in_seconds = 600
  alarm_severity                    = "CRITICAL"
  alarm_body                        = "The FOSS Stack instance has exceeded the resource usage threshold"
  alarm_destinations                = [oci_ons_notification_topic.alarms_topic.id]
}
