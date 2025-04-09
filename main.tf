/**
 * OCI Paid VM using credits
 * Temporary infrastructure until Free Tier capacity becomes available
 */

# Configure the OCI provider
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Create a compartment for paid resources
resource "oci_identity_compartment" "paid_compartment" {
  name          = "temp-paid-resources"
  description   = "Temporary compartment for paid resources until Free Tier capacity is available"
  enable_delete = true
}

# Fetch available ADs
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Create a VCN
resource "oci_core_vcn" "vcn" {
  compartment_id = oci_identity_compartment.paid_compartment.id
  display_name   = "temp-paid-vcn"
  cidr_blocks    = ["10.0.0.0/16"]
}

# Create an internet gateway
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = oci_identity_compartment.paid_compartment.id
  display_name   = "temp-paid-ig"
  vcn_id         = oci_core_vcn.vcn.id
}

# Create a route table
resource "oci_core_route_table" "route_table" {
  compartment_id = oci_identity_compartment.paid_compartment.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "temp-paid-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

# Create a security list
resource "oci_core_security_list" "security_list" {
  compartment_id = oci_identity_compartment.paid_compartment.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "temp-paid-sl"

  # Allow SSH ingress
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow HTTP ingress
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 80
      max = 80
    }
  }

  # Allow HTTPS ingress
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 443
      max = 443
    }
  }

  # Allow all egress
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }
}

# Create a subnet
resource "oci_core_subnet" "subnet" {
  compartment_id             = oci_identity_compartment.paid_compartment.id
  vcn_id                     = oci_core_vcn.vcn.id
  display_name               = "temp-paid-subnet"
  cidr_block                 = "10.0.1.0/24"
  route_table_id             = oci_core_route_table.route_table.id
  security_list_ids          = [oci_core_security_list.security_list.id]
  prohibit_public_ip_on_vnic = false
}

# Get Latest Oracle Linux 8 Image
data "oci_core_images" "ol8_images" {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.E2.8"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Get Latest Ubuntu 22.04 Image
data "oci_core_images" "ubuntu_images" {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.E2.8"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Create the compute instance
resource "oci_core_instance" "safe_haven" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.paid_compartment.id
  display_name        = "safe-haven"
  shape               = "VM.Standard.E2.8"

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    display_name     = "safe-haven-vnic"
    assign_public_ip = true
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ubuntu_images.images[0].id
    boot_volume_size_in_gbs = 50
  }

  metadata = {
    ssh_authorized_keys = file("~/.ssh/ssh-key-2025-04-09.key.pub")
    user_data = base64encode(file("scripts/cloud-init.yml"))
  }

  timeouts {
    create = "20m"
  }
}

# Create a 16TB block volume
resource "oci_core_volume" "data_volume" {
  availability_domain  = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id       = oci_identity_compartment.paid_compartment.id
  display_name         = "safe-haven-16tb-volume"
  size_in_gbs          = "16384"
  vpus_per_gb          = "20"
  is_auto_tune_enabled = true
}

# Attach the volume to the instance
resource "oci_core_volume_attachment" "data_volume_attachment" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.safe_haven.id
  volume_id       = oci_core_volume.data_volume.id
  display_name    = "safe-haven-30tb-volume-attachment"
  is_read_only    = false
}

# Update the null_resource to include volume mounting
resource "null_resource" "setup_cron_jobs" {
  depends_on = [oci_core_instance.safe_haven, oci_core_volume_attachment.data_volume_attachment]

  connection {
    type        = "ssh"
    host        = oci_core_instance.safe_haven.public_ip
    user        = "ubuntu"
    private_key = file("~/.ssh/ssh-key-2025-04-09.key")
  }

  provisioner "remote-exec" {
    inline = [
      # Set up the volume
      "sudo parted /dev/sdb mklabel gpt",
      "sudo parted -a optimal /dev/sdb mkpart primary 0% 100%",
      "sudo mkfs.xfs /dev/sdb1",
      "sudo mkdir -p /data",
      "echo '/dev/sdb1 /data xfs defaults,noatime 0 2' | sudo tee -a /etc/fstab",
      "sudo mount /data",
      "sudo chown ubuntu:ubuntu /data",

      # Set up cron jobs
      "echo '0 0 * * * /usr/sbin/shutdown -h now' | sudo tee /etc/cron.d/auto-shutdown",
      "echo '0 8 * * * /usr/sbin/shutdown -r now' | sudo tee /etc/cron.d/auto-startup",
      "sudo chmod 644 /etc/cron.d/auto-shutdown",
      "sudo chmod 644 /etc/cron.d/auto-startup"
    ]
  }
}

# Create budget alerts to monitor spending
resource "oci_budget_budget" "credit_usage_budget" {
  compartment_id = var.tenancy_ocid
  amount         = 250
  reset_period   = "MONTHLY"
  target_type    = "COMPARTMENT"
  targets        = [var.tenancy_ocid]
  display_name   = "Credit-Usage-Alert"
  description    = "Budget to monitor credit usage before expiration on April 23rd (US$250)"
}

# Create budget alert rule at 10% of budget (US$25)
resource "oci_budget_alert_rule" "alert_rule_10_percent" {
  budget_id      = oci_budget_budget.credit_usage_budget.id
  threshold      = 10
  threshold_type = "PERCENTAGE"
  type           = "ACTUAL"
  display_name   = "10-Percent-Alert"
  description    = "Alert when spending reaches 10% of credits (US$25)"
  message        = "INITIAL: You have used 10% of your OCI credits. Monitoring usage."
  recipients     = var.alert_email
}

# Create budget alert rule at 25% of budget (US$62.5)
resource "oci_budget_alert_rule" "alert_rule_25_percent" {
  budget_id      = oci_budget_budget.credit_usage_budget.id
  threshold      = 25
  threshold_type = "PERCENTAGE"
  type           = "ACTUAL"
  display_name   = "25-Percent-Alert"
  description    = "Alert when spending reaches 25% of credits (US$62.5)"
  message        = "NOTIFICATION: You have used 25% of your OCI credits. Review your usage."
  recipients     = var.alert_email
}

# Create budget alert rule at 50% of budget (US$125)
resource "oci_budget_alert_rule" "alert_rule_50_percent" {
  budget_id      = oci_budget_budget.credit_usage_budget.id
  threshold      = 50
  threshold_type = "PERCENTAGE"
  type           = "ACTUAL"
  display_name   = "50-Percent-Alert"
  description    = "Alert when spending reaches 50% of credits (US$125)"
  message        = "ATTENTION: You have used 50% of your OCI credits. Consider checking your usage."
  recipients     = var.alert_email
}

# Create budget alert rule at 75% of budget (US$187.5)
resource "oci_budget_alert_rule" "alert_rule_75_percent" {
  budget_id      = oci_budget_budget.credit_usage_budget.id
  threshold      = 75
  threshold_type = "PERCENTAGE"
  type           = "ACTUAL"
  display_name   = "75-Percent-Alert"
  description    = "Alert when spending reaches 75% of credits (US$187.5)"
  message        = "WARNING: You have used 75% of your OCI credits. Review your resources soon."
  recipients     = var.alert_email
}

# Create budget alert rule at 90% of budget (US$225)
resource "oci_budget_alert_rule" "alert_rule_90_percent" {
  budget_id      = oci_budget_budget.credit_usage_budget.id
  threshold      = 90
  threshold_type = "PERCENTAGE"
  type           = "ACTUAL"
  display_name   = "90-Percent-Alert"
  description    = "Alert when spending reaches 90% of credits (US$225)"
  message        = "URGENT: You have used 90% of your OCI credits. Consider shutting down resources."
  recipients     = var.alert_email
}

# Create budget alert rule at 95% of budget (US$237.5)
resource "oci_budget_alert_rule" "alert_rule_95_percent" {
  budget_id      = oci_budget_budget.credit_usage_budget.id
  threshold      = 95
  threshold_type = "PERCENTAGE"
  type           = "ACTUAL"
  display_name   = "95-Percent-Alert"
  description    = "Alert when spending reaches 95% of credits (US$237.5)"
  message        = "CRITICAL: You have used 95% of your OCI credits. Shut down paid resources immediately."
  recipients     = var.alert_email
}

# Output the instance details
output "instance_public_ip" {
  value = oci_core_instance.safe_haven.public_ip
}

output "instance_state" {
  value = oci_core_instance.safe_haven.state
}

output "ssh_connection_string" {
  value = "ssh opc@${oci_core_instance.safe_haven.public_ip}"
} 