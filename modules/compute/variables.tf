variable "compartment_id" {
  description = "The OCID of the compartment where compute resources will be created"
  type        = string
}

variable "availability_domain" {
  description = "The availability domain for the compute instance"
  type        = string
}

variable "subnet_id" {
  description = "The OCID of the subnet where the compute instance will be created"
  type        = string
}

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

variable "source_image_id" {
  description = "The OCID of the image to use for the compute instance"
  type        = string
}

variable "boot_volume_size_in_gbs" {
  description = "The size of the boot volume in GB"
  type        = number
  default     = 50
}

variable "cloud_init_file_path" {
  description = "The path to the cloud-init file"
  type        = string
  default     = "config/cloud-init/foss-stack.yml"
}

variable "ssh_public_key_path" {
  description = "The path to the SSH public key"
  type        = string
  default     = "~/.ssh/ssh-key-2025-04-09.key.pub"
}

variable "vnic_display_name" {
  description = "The display name for the VNIC"
  type        = string
  default     = "foss-stack-vnic"
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to the compute instance"
  type        = bool
  default     = true
}
