#cloud-config

# Set hostname
hostname: safe-haven
preserve_hostname: false

# Update packages
package_update: true
package_upgrade: true

# Install necessary packages
packages:
  - docker.io
  - docker-compose
  - git
  - curl
  - wget
  - unzip
  - htop
  - jq
  - python3-pip
  - apt-transport-https
  - ca-certificates
  - gnupg
  - lsb-release
  - software-properties-common
  - nginx
  - ufw
  - prometheus-node-exporter
  - ctop
  - logrotate

# Add user to docker group
groups:
  - docker

system_info:
  default_user:
    groups: [docker]

# Create directories for data persistence
runcmd:
  # System setup
  - mkdir -p /opt/data
  - mkdir -p /opt/data/mongodb
  - mkdir -p /opt/data/redis
  - mkdir -p /opt/data/qdrant
  - mkdir -p /opt/data/neo4j
  - mkdir -p /opt/data/supabase
  - mkdir -p /opt/docker
  - mkdir -p /opt/scripts
  - mkdir -p /opt/logs
  - mkdir -p /opt/logs/docker
  - mkdir -p /opt/logs/system
  
  # Set permissions
  - chmod -R 755 /opt/data
  - chown -R 1000:1000 /opt/data/mongodb
  - chown -R 1000:1000 /opt/data/qdrant
  - chown -R 1000:1000 /opt/data/redis
  - chown -R 1000:1000 /opt/data/neo4j
  - chown -R 1000:1000 /opt/data/supabase
  - chmod -R 755 /opt/logs
  
  # Configure UFW firewall
  - ufw default deny incoming
  - ufw default allow outgoing
  - ufw allow ssh
  - ufw allow http
  - ufw allow https
  - ufw --force enable
  
  # Create systemd service for graceful shutdown
  - |
    cat > /etc/systemd/system/safe-haven.service << 'EOF'
    [Unit]
    Description=Safe Haven Development Environment
    After=docker.service
    Requires=docker.service

    [Service]
    Type=oneshot
    RemainAfterExit=yes
    ExecStart=/opt/scripts/start-services.sh
    ExecStop=/opt/scripts/stop-services.sh
    TimeoutStartSec=0

    [Install]
    WantedBy=multi-user.target
    EOF

  # Create start script with password generation
  - |
    cat > /opt/scripts/start-services.sh << 'EOF'
    #!/bin/bash
    set -e

    echo "Starting Safe Haven services..."
    
    # Generate secure passwords
    export POSTGRES_PASSWORD=$(openssl rand -base64 32)
    export JWT_SECRET=$(openssl rand -base64 32)
    export ANON_KEY=$(openssl rand -base64 32)
    export SERVICE_ROLE_KEY=$(openssl rand -base64 32)
    export MONGO_PASSWORD=$(openssl rand -base64 32)
    export REDIS_PASSWORD=$(openssl rand -base64 32)
    export NEO4J_PASSWORD=$(openssl rand -base64 32)
    export GRAFANA_PASSWORD=$(openssl rand -base64 32)
    
    # Configure Supabase
    cat > /opt/data/supabase/.env << EOL
    # Postgres
    POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    POSTGRES_PORT=5432

    # API
    KONG_HTTP_PORT=8000
    API_EXTERNAL_URL=http://localhost:8000

    # Studio
    STUDIO_PORT=3001
    SUPABASE_PUBLIC_URL=http://localhost:8000

    # Auth
    JWT_SECRET=${JWT_SECRET}
    ANON_KEY=${ANON_KEY}
    SERVICE_ROLE_KEY=${SERVICE_ROLE_KEY}
    EOL
    
    # Configure docker-compose with generated passwords
    cat > /opt/docker/docker-compose.yml << EOL
    version: '3.8'
    
    services:
      # Node Exporter for system metrics
      node-exporter:
        image: prom/node-exporter:latest
        container_name: node-exporter
        restart: unless-stopped
        ports:
          - "9100:9100"
        volumes:
          - /proc:/host/proc:ro
          - /sys:/host/sys:ro
          - /:/rootfs:ro
        command:
          - '--path.procfs=/host/proc'
          - '--path.sysfs=/host/sys'
          - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
        networks:
          - app-network
    
      # QDrant vector database
      qdrant:
        image: qdrant/qdrant:latest
        container_name: qdrant
        restart: unless-stopped
        ports:
          - "6333:6333"
          - "6334:6334"
        volumes:
          - /opt/data/qdrant:/qdrant/storage
        environment:
          - QDRANT_ALLOW_RECOVERY_MODE=true
        networks:
          - app-network
    
      # MongoDB database
      mongodb:
        image: mongo:6.0
        container_name: mongodb
        restart: unless-stopped
        ports:
          - "27017:27017"
        volumes:
          - /opt/data/mongodb:/data/db
        environment:
          - MONGO_INITDB_ROOT_USERNAME=admin
          - MONGO_INITDB_ROOT_PASSWORD=${MONGO_PASSWORD}
        networks:
          - app-network
    
      # Redis cache
      redis:
        image: redis:7-alpine
        container_name: redis
        restart: unless-stopped
        ports:
          - "6379:6379"
        volumes:
          - /opt/data/redis:/data
        command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
        networks:
          - app-network
    
      # Neo4J graph database
      neo4j:
        image: neo4j:5
        container_name: neo4j
        restart: unless-stopped
        ports:
          - "7474:7474"  # HTTP
          - "7687:7687"  # Bolt
        volumes:
          - /opt/data/neo4j:/data
        environment:
          - NEO4J_AUTH=neo4j/${NEO4J_PASSWORD}
          - NEO4J_dbms_memory_pagecache_size=512M
          - NEO4J_dbms_memory_heap_initial__size=512M
          - NEO4J_dbms_memory_heap_max__size=1G
        networks:
          - app-network
    
      # Monitoring with Prometheus and Grafana
      prometheus:
        image: prom/prometheus:latest
        container_name: prometheus
        restart: unless-stopped
        ports:
          - "9090:9090"
        volumes:
          - /opt/data/prometheus:/etc/prometheus
        command:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus'
          - '--web.console.libraries=/etc/prometheus/console_libraries'
          - '--web.console.templates=/etc/prometheus/consoles'
          - '--web.enable-lifecycle'
        networks:
          - app-network
    
      grafana:
        image: grafana/grafana:latest
        container_name: grafana
        restart: unless-stopped
        ports:
          - "3000:3000"
        volumes:
          - /opt/data/grafana:/var/lib/grafana
        environment:
          - GF_SECURITY_ADMIN_USER=admin
          - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
          - GF_USERS_ALLOW_SIGN_UP=false
        networks:
          - app-network
    
    networks:
      app-network:
        driver: bridge
    EOL
    
    # Start Docker if not running
    if ! systemctl is-active --quiet docker; then
        systemctl start docker
    fi
    
    # Start services
    cd /opt/docker && docker-compose up -d
    
    # Wait for services to be healthy
    echo "Waiting for services to be healthy..."
    for i in {1..30}; do
        if docker ps | grep -q "healthy"; then
            break
        fi
        sleep 2
    done
    
    # Update environment variables
    cat > /etc/profile.d/database-env.sh << EOL
    # Database connection environment variables
    export QDRANT_URL="http://localhost:6333"
    export MONGODB_URI="mongodb://admin:${MONGO_PASSWORD}@localhost:27017"
    export REDIS_URI="redis://:${REDIS_PASSWORD}@localhost:6379"
    export NEO4J_URI="bolt://localhost:7687"
    export NEO4J_USER="neo4j"
    export NEO4J_PASSWORD="${NEO4J_PASSWORD}"
    
    # Supabase environment variables
    export SUPABASE_URL="http://localhost:8000"
    export SUPABASE_ANON_KEY="${ANON_KEY}"
    export SUPABASE_SERVICE_KEY="${SERVICE_ROLE_KEY}"
    export POSTGRES_URI="postgresql://postgres:${POSTGRES_PASSWORD}@localhost:5432/postgres"
    EOL
    
    # Update MOTD with actual passwords
    cat > /etc/motd << EOL
    
    ██████╗  ██████╗██╗    ███████╗██████╗ ███████╗███████╗    ████████╗██╗███████╗██████╗ 
    ██╔═══██╗██╔════╝██║    ██╔════╝██╔══██╗██╔════╝██╔════╝    ╚══██╔══╝██║██╔════╝██╔══██╗
    ██║   ██║██║     ██║    █████╗  ██████╔╝█████╗  █████╗         ██║   ██║█████╗  ██████╔╝
    ██║   ██║██║     ██║    ██╔══╝  ██╔══██╗██╔══╝  ██╔══╝         ██║   ██║██╔══╝  ██╔══██╗
    ╚██████╔╝╚██████╗██║    ██║     ██║  ██║███████╗███████╗       ██║   ██║███████╗██║  ██║
     ╚═════╝  ╚═════╝╚═╝    ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝       ╚═╝   ╚═╝╚══════╝╚═╝  ╚═╝
    
    PAID DEVELOPMENT ENVIRONMENT
    
    Available Services:
    - QDrant Vector DB:  http://localhost:6333 
    - MongoDB:          mongodb://admin:${MONGO_PASSWORD}@localhost:27017
    - Redis:            redis://:${REDIS_PASSWORD}@localhost:6379
    - Neo4J:            http://localhost:7474 (user: neo4j, password: ${NEO4J_PASSWORD})
    - Prometheus:       http://localhost:9090
    - Grafana:          http://localhost:3000 (user: admin, password: ${GRAFANA_PASSWORD})
    
    Supabase OSS:
    - Studio:           http://localhost:3001
    - API/Auth/Storage: http://localhost:8000
    - PostgreSQL:       postgresql://postgres:${POSTGRES_PASSWORD}@localhost:5432
    - Credentials in:   /opt/data/supabase/.env
    
    All data is stored in /opt/data
    Docker Compose file is in /opt/docker
    Supabase is in /opt/data/supabase
    
    EOL
    
    echo "Services started successfully!"
    EOF

  # Create stop script
  - |
    cat > /opt/scripts/stop-services.sh << 'EOF'
    #!/bin/bash
    set -e

    echo "Stopping Safe Haven services..."
    
    # Stop services gracefully
    cd /opt/docker && docker-compose down
    
    # Stop Docker if no other containers are running
    if [ $(docker ps -q | wc -l) -eq 0 ]; then
        systemctl stop docker
    fi
    
    echo "Services stopped successfully!"
    EOF

  # Set permissions for scripts
  - chmod +x /opt/scripts/start-services.sh
  - chmod +x /opt/scripts/stop-services.sh
  
  # Enable and start the service
  - systemctl daemon-reload
  - systemctl enable safe-haven.service
  
  # Clone Supabase Docker repo with error handling
  - |
    if ! git clone https://github.com/supabase/supabase-docker.git /opt/data/supabase; then
        echo "Failed to clone Supabase repository"
        exit 1
    fi
  
  # Create Nginx config for Supabase with security headers
  - |
    cat > /etc/nginx/sites-available/supabase << 'EOF'
    server {
        listen 80;
        
        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
        
        location / {
            proxy_pass http://localhost:3001;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        location /api/ {
            proxy_pass http://localhost:8000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    EOF
  
  # Enable Nginx site and restart
  - ln -s /etc/nginx/sites-available/supabase /etc/nginx/sites-enabled/
  - systemctl restart nginx
  
  # Add prometheus config with node exporter
  - mkdir -p /opt/data/prometheus
  - |
    cat > /opt/data/prometheus/prometheus.yml << 'EOF'
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
      
      - job_name: 'node'
        static_configs:
          - targets: ['node-exporter:9100']
      
      - job_name: 'docker'
        static_configs:
          - targets: ['host.docker.internal:9323']
    EOF
  
  # Configure logrotate for Docker logs
  - |
    cat > /etc/logrotate.d/docker << 'EOF'
    /opt/logs/docker/*.log {
        daily
        rotate 7
        compress
        delaycompress
        missingok
        notifempty
        create 0640 root root
    }
    EOF
  
  # Configure logrotate for system logs
  - |
    cat > /etc/logrotate.d/system << 'EOF'
    /opt/logs/system/*.log {
        daily
        rotate 7
        compress
        delaycompress
        missingok
        notifempty
        create 0640 root root
    }
    EOF
  
  # Set up automatic shutdown/startup
  - |
    cat > /etc/cron.d/safe-haven-schedule << 'EOF'
    # Shutdown at midnight
    0 0 * * * root /opt/scripts/stop-services.sh && shutdown -h now
    # Start at 8 AM (if supported by cloud provider)
    0 8 * * * root systemctl start safe-haven.service
    EOF
  
  # Restart Docker to apply changes
  - systemctl restart docker

final_message: "The Safe Haven development environment is now installed and ready for configuration! Access the server using 'ssh opc@$HOSTNAME' with your private key." 