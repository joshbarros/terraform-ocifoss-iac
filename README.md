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
- **Boot Volume**: 100GB
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

## Infrastructure Management

### Production Environment

```bash
# Navigate to production environment
cd environments/prod

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Deploy infrastructure
terraform apply
# OR for automatic approval
terraform apply --auto-approve

# Destroy infrastructure
terraform destroy
# OR for automatic approval
terraform destroy --auto-approve
```

### Development Environment

```bash
# Navigate to development environment
cd environments/dev

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Deploy infrastructure
terraform apply
# OR for automatic approval
terraform apply --auto-approve

# Destroy infrastructure
terraform destroy
# OR for automatic approval
terraform destroy --auto-approve
```

## Post-Deployment Configuration

After successfully deploying the infrastructure, follow these steps to make the environment production-ready:

### 1. SSH into the instance

```bash
# Use the SSH connection string from Terraform output
ssh ubuntu@<instance_public_ip> -i <path_to_private_key>

# Example:
# ssh ubuntu@64.181.162.139 -i ~/.ssh/ssh-key-2025-04-09.key
```

### 2. Format and mount the 16TB data volume

The data volume should be automatically formatted and mounted during cloud-init, but if not:

```bash
# Check if volume is already formatted
sudo file -s /dev/sdb

# Format the volume if needed (shows 'data' output above)
sudo mkfs.ext4 /dev/sdb

# Create mount point
sudo mkdir -p /data

# Mount the volume
sudo mount /dev/sdb /data

# Add to fstab for persistence across reboots
echo '/dev/sdb /data ext4 defaults 0 0' | sudo tee -a /etc/fstab
```

### 3. Verify Kubernetes (K3s) Installation

```bash
# Check node status
sudo kubectl get nodes

# Check running pods
sudo kubectl get pods -A

# Deploy test application
sudo kubectl run nginx --image=nginx
sudo kubectl expose pod nginx --port=80 --type=NodePort
sudo kubectl get svc
```

### 4. Configure Additional Services

#### MinIO Setup
```bash
# Navigate to docker directory
cd /opt/docker

# Start MinIO service
sudo docker-compose -f minio-docker-compose.yml up -d

# Access MinIO console at: http://<instance_public_ip>:9001
# Default credentials: admin/<generated_password>
```

#### NGINX Proxy Manager
```bash
# Start NGINX Proxy Manager
sudo docker-compose -f nginx-proxy-manager-docker-compose.yml up -d

# Access admin interface at: http://<instance_public_ip>:8080
# Default credentials: admin@example.com / changeme
```

#### Keycloak Identity Server
```bash
# Start Keycloak
sudo docker-compose -f keycloak-docker-compose.yml up -d

# Access admin console at: http://<instance_public_ip>:8090
# Use credentials from environment variable
```

### 5. Security Hardening

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Verify firewall status
sudo ufw status

# Check system logs for any issues
sudo journalctl -n 100

# Set up automatic security updates
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure unattended-upgrades
```

### 6. Backup Configuration

```bash
# Create backup script
sudo nano /opt/scripts/backup.sh

# Add commands to backup critical data (example):
# #!/bin/bash
# TIMESTAMP=$(date +%Y%m%d_%H%M%S)
# sudo restic -r /opt/backups backup /opt/data/

# Make executable
sudo chmod +x /opt/scripts/backup.sh

# Set up cron job for regular backups
echo "0 2 * * * root /opt/scripts/backup.sh" | sudo tee -a /etc/cron.d/backups
```

## Updating Infrastructure

To update your infrastructure configuration:

1. Modify the appropriate Terraform files
2. Run `terraform plan` to review changes
3. Run `terraform apply` to apply changes

For major updates requiring full recreation:

1. Run `terraform destroy --auto-approve` to destroy the current infrastructure
2. Make your configuration changes
3. Run `terraform apply --auto-approve` to apply the new configuration

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
- Kubernetes resources protected by RBAC

## Troubleshooting

### Common Issues

1. **Cloud-init failures**: Check `/var/log/cloud-init.log` for errors.
2. **Service failures**: Use `systemctl status <service>` to check service status.
3. **Disk mounting issues**: Verify with `lsblk` and check `/etc/fstab` entries.
4. **Kubernetes problems**: Run `sudo kubectl get events` to see cluster events.

### Getting Support
For assistance with this infrastructure, please create an issue in the repository or contact the infrastructure team.

## License
This project is licensed under the terms of the MIT license.