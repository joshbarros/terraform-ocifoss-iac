variable "compartment_id" {
  description = "The OCID of the compartment where storage resources will be created"
  type        = string
}

variable "availability_domain" {
  description = "The availability domain for the block volume"
  type        = string
}

variable "instance_id" {
  description = "The OCID of the instance to attach the volume to"
  type        = string
}

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

variable "volume_attachment_display_name" {
  description = "The display name for the volume attachment"
  type        = string
  default     = "foss-stack-volume-attachment"
}

variable "attachment_type" {
  description = "The type of volume attachment"
  type        = string
  default     = "paravirtualized"
}

variable "is_read_only" {
  description = "Whether the volume attachment is read-only"
  type        = bool
  default     = false
}

variable "is_auto_tune_enabled" {
  description = "Whether auto-tuning is enabled for the volume"
  type        = bool
  default     = true
}
