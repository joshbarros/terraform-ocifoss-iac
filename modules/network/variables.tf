variable "compartment_id" {
  description = "The OCID of the compartment where network resources will be created"
  type        = string
}

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

variable "internet_gateway_display_name" {
  description = "The display name for the internet gateway"
  type        = string
  default     = "foss-stack-ig"
}

variable "route_table_display_name" {
  description = "The display name for the route table"
  type        = string
  default     = "foss-stack-rt"
}

variable "security_list_display_name" {
  description = "The display name for the security list"
  type        = string
  default     = "foss-stack-sl"
}

variable "open_ports" {
  description = "List of ports to open in the security list"
  type        = list(number)
  default     = [22, 80, 443, 6443, 8080, 9000, 9001, 3000, 3100, 5678, 8090]
}

variable "prohibit_public_ip_on_vnic" {
  description = "Whether to prohibit public IPs on the VNIC"
  type        = bool
  default     = false
}
