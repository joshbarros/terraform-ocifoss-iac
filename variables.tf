/**
 * Variables for OCI Infrastructure
 */

# OCI Authentication
variable "tenancy_ocid" {
  description = "OCID of your tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the user"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the API private key"
  type        = string
}

variable "private_key_path" {
  description = "Path to the API private key"
  type        = string
}

variable "region" {
  description = "OCI region for resources"
  type        = string
  default     = "sa-saopaulo-1"
}

# VM Configuration
variable "vm_shape" {
  description = "Shape of the VM"
  type        = string
  default     = "VM.Standard.E2.8"
}

variable "boot_volume_size_in_gbs" {
  description = "Size of the boot volume in GBs"
  type        = number
  default     = 50
}

# SSH Key
variable "ssh_public_key" {
  description = "Public SSH key for instance access"
  type        = string
}

# Budget Alerts
variable "alert_email" {
  description = "Email address to receive budget alerts"
  type        = string
  default     = "goldenglowitsolutions@gmail.com"
} 