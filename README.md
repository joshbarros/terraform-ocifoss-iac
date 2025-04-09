# OCI Paid Infrastructure

This repository contains Terraform configurations for managing Oracle Cloud Infrastructure (OCI) resources using paid credits. This is a temporary setup until Free Tier capacity becomes available.

## Infrastructure Overview

### Compute Instance
- **Name**: safe-haven
- **Shape**: VM.Standard.E2.8
- **OS**: Ubuntu 22.04.5 LTS
- **CPU**: 16 vCPUs (AMD EPYC 7551)
- **Memory**: 62GB
- **Boot Volume**: 50GB
- **Data Volume**: 16TB (mounted at /data)
- **Auto-shutdown**: Daily at midnight (0 0 * * *)
- **Auto-startup**: Daily at 8 AM (0 8 * * *)

### Networking
- **VCN**: temp-paid-vcn (10.0.0.0/16)
- **Subnet**: temp-paid-subnet (10.0.1.0/24)
- **Internet Gateway**: temp-paid-ig
- **Security Rules**:
  - SSH (22)
  - HTTP (80)
  - HTTPS (443)
  - All egress traffic

### Budget Monitoring
- **Total Budget**: US$250
- **Alert Thresholds**:
  - 10% (US$25): Initial monitoring
  - 25% (US$62.5): Usage review
  - 50% (US$125): Usage check
  - 75% (US$187.5): Resource review
  - 90% (US$225): Consider shutdown
  - 95% (US$237.5): Critical shutdown

## Access Information
- **SSH Access**: `ssh ubuntu@<instance_public_ip> -i ~/.ssh/ssh-key-2025-04-09.key`
- **Current Public IP**: 167.234.227.216

## Resource Management
- **Compartment**: temp-paid-resources
- **Region**: sa-saopaulo-1
- **Budget Expiration**: April 23rd

## Usage Notes
1. The infrastructure is automatically shut down at midnight and started at 8 AM daily
2. Budget alerts are sent to goldenglowitsolutions@gmail.com
3. The 16TB data volume is mounted at /data
4. All resources are in a dedicated compartment for easy management

## Terraform Commands
```bash
# Initialize Terraform
terraform init

# Format configuration
terraform fmt

# Validate configuration
terraform validate

# Create execution plan
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

## Security
- SSH key authentication required
- Public IP access restricted to necessary ports
- Budget monitoring in place to prevent unexpected charges

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