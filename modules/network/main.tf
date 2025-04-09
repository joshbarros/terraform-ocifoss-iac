/**
 * Network Module
 * This module creates all network-related resources:
 * - VCN
 * - Internet Gateway
 * - Route Table
 * - Security List
 * - Subnet
 */

# Create a VCN
resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_id
  display_name   = var.vcn_display_name
  cidr_blocks    = var.vcn_cidr_blocks
}

# Create an internet gateway
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_id
  display_name   = var.internet_gateway_display_name
  vcn_id         = oci_core_vcn.vcn.id
}

# Create a route table
resource "oci_core_route_table" "route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = var.route_table_display_name

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

# Create a security list
resource "oci_core_security_list" "security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = var.security_list_display_name

  # Allow ingress for specified ports
  dynamic "ingress_security_rules" {
    for_each = toset(var.open_ports)
    content {
      protocol  = "6" # TCP
      source    = "0.0.0.0/0"
      stateless = false

      tcp_options {
        min = ingress_security_rules.value
        max = ingress_security_rules.value
      }
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
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.vcn.id
  display_name               = var.subnet_display_name
  cidr_block                 = var.subnet_cidr_block
  route_table_id             = oci_core_route_table.route_table.id
  security_list_ids          = [oci_core_security_list.security_list.id]
  prohibit_public_ip_on_vnic = var.prohibit_public_ip_on_vnic
}
