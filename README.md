# OCI FOSS Infrastructure

This repository contains a modular Terraform implementation for provisioning a complete FOSS software agency stack on Oracle Cloud Infrastructure.

## Project Structure

```
.
├── README.md
├── modules                  # Reusable infrastructure components
│   ├── budget              # Budget and alert rules
│   ├── compute             # Compute instance resources
│   ├── monitoring          # Monitoring and alarms
│   ├── network             # Network resources (VCN, subnet, etc.)
│   └── storage             # Block storage resources
├── environments            # Environment-specific configurations
│   ├── dev                 # Development environment
│   └── prod                # Production environment
├── config                  # Configuration files
│   └── cloud-init          # Cloud-init configurations
└── utils                   # Utility functions and locals
```

## Infrastructure Overview

### Compute Instance
- **Shape**: VM.Standard.E2.8
- **OS**: Ubuntu 22.04.5 LTS
- **CPU**: 16 vCPUs (AMD EPYC 7551)
- **Memory**: 62GB
- **Boot Volume**: 50GB
- **Data Volume**: 16TB (mounted at /data)
- **Auto-shutdown**: Daily at midnight (0 0 * * *)
- **Auto-startup**: Daily at 8 AM (0 8 * * *)

### Full FOSS Stack
- **Kubernetes**: K3s lightweight Kubernetes
- **Databases**: 
  - QDrant Vector DB
  - MongoDB
  - Redis
  - Neo4J
  - PostgreSQL (via Supabase)
- **Storage**:
  - MinIO S3-compatible storage
- **Identity**:
  - Keycloak SSO
- **Automation**:
  - n8n workflow automation
- **Monitoring**:
  - Prometheus
  - Grafana
  - Loki
- **Networking**:
  - NGINX Proxy Manager

### Budget & Monitoring
- Comprehensive budget alerts at multiple thresholds
- CPU, memory, and disk usage alarms
- Notification system via ONS

## Usage

### Production Environment

```bash
# Initialize
cd environments/prod
terraform init

# Plan
terraform plan -var-file=terraform.tfvars

# Apply
terraform apply -var-file=terraform.tfvars

# Destroy
terraform destroy -var-file=terraform.tfvars
```

### Development Environment

```bash
# Initialize
cd environments/dev
terraform init

# Plan
terraform plan -var-file=terraform.tfvars

# Apply
terraform apply -var-file=terraform.tfvars

# Destroy
terraform destroy -var-file=terraform.tfvars
```

## Modules

### Network Module
Creates all networking resources including VCN, subnet, internet gateway, route tables, and security lists.

### Compute Module
Provisions the compute instance with cloud-init configuration for the FOSS stack.

### Storage Module
Creates and attaches a block volume to the compute instance.

### Budget Module
Sets up a budget with various alert thresholds to monitor spending.

### Monitoring Module
Creates alarms for CPU, memory, and disk usage to monitor the health of the instance.

## Security
- SSH key authentication required
- Public IP access restricted to necessary ports
- Budget monitoring in place to prevent unexpected charges

## License
This project is licensed under the terms of the MIT license.