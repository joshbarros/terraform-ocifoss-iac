/**
 * Production Environment Variables
 * These variables are used to configure the production environment
 */

# OCI Provider Variables
variable "tenancy_ocid" {
  description = "The OCID of the tenancy"
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the user"
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint of the API key"
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key"
  type        = string
}

variable "region" {
  description = "The region to deploy to"
  type        = string
  default     = "sa-saopaulo-1"
}

# Compartment Variables
variable "compartment_name" {
  description = "The name of the compartment"
  type        = string
  default     = "foss-stack-compartment"
}

variable "compartment_description" {
  description = "The description of the compartment"
  type        = string
  default     = "Compartment for FOSS stack resources"
}

variable "enable_delete" {
  description = "Whether to enable deletion of the compartment"
  type        = bool
  default     = true
}

# Network Variables
variable "vcn_display_name" {
  description = "The display name for the VCN"
  type        = string
  default     = "foss-stack-vcn"
}

variable "vcn_cidr_blocks" {
  description = "CIDR blocks for the VCN"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_display_name" {
  description = "The display name for the subnet"
  type        = string
  default     = "foss-stack-subnet"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Compute Variables
variable "instance_display_name" {
  description = "The display name for the compute instance"
  type        = string
  default     = "foss-stack-instance"
}

variable "instance_shape" {
  description = "The shape of the compute instance"
  type        = string
  default     = "VM.Standard.E2.8"
}

variable "operating_system" {
  description = "The operating system for the instance"
  type        = string
  default     = "Canonical Ubuntu"
}

variable "operating_system_version" {
  description = "The operating system version for the instance"
  type        = string
  default     = "22.04"
}

variable "boot_volume_size_in_gbs" {
  description = "The size of the boot volume in GB"
  type        = number
  default     = 50
}

variable "ssh_public_key_path" {
  description = "The path to the SSH public key"
  type        = string
  default     = "~/.ssh/ssh-key-2025-04-09.key.pub"
}

# Storage Variables
variable "volume_display_name" {
  description = "The display name for the block volume"
  type        = string
  default     = "foss-stack-volume"
}

variable "volume_size_in_gbs" {
  description = "The size of the block volume in GB"
  type        = number
  default     = 16384 # 16TB
}

variable "volume_vpus_per_gb" {
  description = "The VPUs per GB for the block volume"
  type        = number
  default     = 20
}

# Budget Variables
variable "budget_display_name" {
  description = "The display name for the budget"
  type        = string
  default     = "Credit-Usage-Alert"
}

variable "budget_amount" {
  description = "The amount for the budget in USD"
  type        = number
  default     = 250
}

variable "alert_email" {
  description = "The email address to send budget alerts to"
  type        = string
}

# Monitoring Variables
variable "cpu_threshold_percentage" {
  description = "The threshold percentage for CPU usage"
  type        = number
  default     = 80
}

variable "memory_threshold_percentage" {
  description = "The threshold percentage for memory usage"
  type        = number
  default     = 80
}

variable "disk_threshold_percentage" {
  description = "The threshold percentage for disk usage"
  type        = number
  default     = 80
}
