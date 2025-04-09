# OCI Infrastructure Setup

This repository contains the Terraform configuration for setting up a temporary paid infrastructure in Oracle Cloud Infrastructure (OCI) until Free Tier capacity becomes available.

## Infrastructure Overview

### Compute Instance
- **Name**: safe-haven
- **Shape**: VM.Standard.E2.8
- **Operating System**: Oracle Linux 8.10
- **Boot Volume**: 50GB
- **Public IP**: 144.22.220.8
- **SSH Access**: `ssh opc@144.22.220.8`

### Block Volume
- **Name**: safe-haven-16tb-volume
- **Size**: 16TB
- **Performance**: 20 VPUs per GB
- **File System**: XFS
- **Mount Point**: /data
- **Auto-tune**: Enabled

### Networking
- **VCN Name**: temp-paid-vcn
- **CIDR Block**: 10.0.0.0/16
- **Subnet CIDR**: 10.0.1.0/24
- **Internet Gateway**: temp-paid-ig
- **Route Table**: temp-paid-rt
- **Security List**: temp-paid-sl

#### Open Ports
- SSH (22)
- HTTP (80)
- HTTPS (443)

### Budget Monitoring
- **Total Budget**: $250
- **Alert Thresholds**:
  - 10% ($25) - Initial monitoring
  - 25% ($62.5) - Usage review
  - 50% ($125) - Usage check
  - 75% ($187.5) - Resource review
  - 90% ($225) - Resource shutdown consideration
  - 95% ($237.5) - Immediate shutdown required

### Automated Scheduling
- **Daily Shutdown**: 00:00 (midnight)
- **Daily Startup**: 08:00 (8 AM)

## Directory Structure
```
terraform/
├── main.tf           # Main Terraform configuration
├── variables.tf      # Variable definitions
├── terraform.tfvars.example  # Example variables file
└── README.md        # This documentation
```

## Prerequisites
- OCI CLI configured with appropriate credentials
- Terraform installed
- SSH key pair for instance access

## Sensitive Information
This repository is configured to protect sensitive information:

1. Create a `terraform.tfvars` file with your actual values (this file is gitignored)
2. Use `terraform.tfvars.example` as a template
3. Never commit sensitive information like:
   - OCI credentials (tenancy_ocid, user_ocid, etc.)
   - SSH private keys
   - API keys
   - Email addresses
   - Any other credentials

## Usage
1. Copy `terraform.tfvars.example` to `terraform.tfvars`:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your actual values

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Plan the infrastructure:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Important Notes
- This infrastructure is set up in a temporary compartment named "temp-paid-resources"
- The instance is configured with automatic shutdown/startup to optimize costs
- All resources are monitored with budget alerts to prevent unexpected charges
- The data volume is mounted at /data and formatted with XFS for optimal performance

## Maintenance
- Regular system updates are handled automatically
- The instance will automatically reboot at 8 AM daily
- The instance will automatically shut down at midnight daily
- Budget alerts will notify via email at various spending thresholds

## Security
- SSH access is restricted to key-based authentication
- Only necessary ports (22, 80, 443) are open
- The instance runs with minimal required permissions
- Regular security updates are applied automatically

## Monitoring
- Budget monitoring is configured with multiple alert thresholds
- System metrics are available through OCI Console
- Resource utilization can be monitored through standard Linux tools

## Cost Optimization
- Automatic shutdown/startup schedule
- Budget alerts at multiple thresholds
- Efficient resource allocation
- Regular monitoring of resource utilization 