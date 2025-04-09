# FULL-FOSS Software Agency Stack

This repository contains the complete infrastructure and deployment configuration for a FOSS-first software agency development environment. This stack provides a comprehensive set of tools and services for modern software development, all using free and open-source software.

## 🚀 Infrastructure Overview

### Compute Resources
- Configured for OCI but adaptable to AWS and Hetzner
- Automated deployment via Terraform and cloud-init
- Configurable VM sizes based on workload requirements
- Daily auto-shutdown/startup for cost optimization

### Core Components

#### 🧠 Core Technologies
- **Linux (Ubuntu 22.04 LTS)**: Enterprise-grade OS foundation
- **Docker + Compose**: Multi-service containerized application stacks
- **Kubernetes (K3s)**: Lightweight production-grade orchestration
- **Ansible**: Automated server provisioning & updates
- **Terraform**: Infrastructure as code across multiple cloud providers
- **NGINX Proxy Manager**: Reverse proxy with SSL and routing

#### 📊 Monitoring & Observability
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization dashboards
- **Loki**: Log aggregation
- **Promtail**: Log collection agent

#### 💾 Databases & Storage
- **MongoDB**: Document database
- **PostgreSQL** (via Supabase): Relational database
- **Redis**: In-memory cache
- **Neo4j**: Graph database
- **QDrant**: Vector database
- **MinIO**: S3-compatible object storage

#### 🔐 Security & Access
- **Keycloak**: Identity and access management with SSO
- **OAuth2**: Standard authentication flows
- **UFW Firewall**: Preconfigured with secure defaults
- **Automatic SSL/TLS**: Via NGINX Proxy Manager

#### 🤖 Automation & Workflow
- **n8n**: Workflow automation engine
- **Restic + Rclone**: Encrypted, 3-2-1 backups with GDrive support
- **Scheduled maintenance**: Automatic updates and backups

## 🚢 Deployment & Setup

### Quick Start

1. **Clone this repository**:
   ```bash
   git clone https://github.com/your-org/foss-stack.git
   cd foss-stack
   ```

2. **Configure infrastructure**:
   ```bash
   # Copy example configs
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   
   # Edit with your cloud credentials and preferences
   nano terraform/terraform.tfvars
   ```

3. **Deploy infrastructure**:
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

4. **Access your environment**:
   ```bash
   ssh ubuntu@<instance_public_ip> -i ~/.ssh/your-ssh-key.key
   ```

### Component Access

Once deployed, access your services:

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| Grafana | http://your-ip:3000 | admin / (generated) |
| NGINX Proxy Manager | http://your-ip:8080 | admin@example.com / changeme |
| Keycloak | http://your-ip:8090 | admin / (generated) |
| n8n | http://your-ip:5678 | admin / (generated) |
| MinIO Console | http://your-ip:9001 | admin / (generated) |
| Neo4j Browser | http://your-ip:7474 | neo4j / (generated) |
| Supabase Studio | http://your-ip:3001 | (see motd) |

All generated credentials are displayed in the MOTD (Message of the Day) when you log in to the server.

## 🛠️ Customization

### Adding Services

1. Create a new Docker Compose file in `/opt/docker/`:
   ```bash
   sudo nano /opt/docker/your-service-docker-compose.yml
   ```

2. Add your service configuration:
   ```yaml
   version: '3'
   services:
     your-service:
       image: your-image:tag
       container_name: your-service
       restart: unless-stopped
       ports:
         - "your-port:container-port"
       volumes:
         - /opt/data/your-service:/data
       environment:
         - ENV_VAR=value
       networks:
         - app-network
   
   networks:
     app-network:
       external: true
   ```

3. Start your service:
   ```bash
   cd /opt/docker
   docker-compose -f your-service-docker-compose.yml up -d
   ```

### Kubernetes Deployments

For services that need Kubernetes:

1. Create a Helm chart or manifest:
   ```bash
   mkdir -p /opt/k8s/your-app
   nano /opt/k8s/your-app/deployment.yaml
   ```

2. Apply using kubectl:
   ```bash
   kubectl apply -f /opt/k8s/your-app/deployment.yaml
   ```

## 📚 Documentation

Each component has detailed documentation:

- [Infrastructure Management](docs/infrastructure.md)
- [Database Setup & Migration](docs/databases.md)
- [Authentication & Authorization](docs/auth.md)
- [Monitoring & Alerts](docs/monitoring.md)
- [Backup & Disaster Recovery](docs/backup.md)
- [CI/CD Integration](docs/cicd.md)

## 🛡️ Security Features

- UFW firewall configured for minimal exposure
- Automatic security updates
- Encrypted backups with Restic
- Keycloak SSO for centralized authentication
- Secure credential generation and management

## 👥 Contributing

We welcome contributions to improve this stack:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add some amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📅 Roadmap

- [ ] ArgoCD for GitOps-based Kubernetes management
- [ ] Vault for secrets management
- [ ] KEDA for autoscaling
- [ ] Knative for serverless workloads
- [ ] OpenSearch as Elasticsearch alternative
- [ ] GitLab self-hosted option

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- All the amazing FOSS projects that make this stack possible
- The cloud-native community for inspiration and best practices
- Contributors who help improve and maintain this stack