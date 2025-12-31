#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}=========================================${NC}"
    echo -e "${BLUE}   $1${NC}"
    echo -e "${BLUE}=========================================${NC}"
}

print_step() {
    echo -e "\n${YELLOW}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

check_dependencies() {
    print_header "Checking Dependencies"
    
    # Check Docker
    if command -v docker &> /dev/null; then
        print_success "Docker is installed"
    else
        print_error "Docker is not installed"
        echo "Install Docker with: sudo apt install docker.io"
        exit 1
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        print_success "Docker Compose is installed"
    else
        print_error "Docker Compose is not installed"
        echo "Install Docker Compose with: sudo apt install docker-compose"
        exit 1
    fi
    
    # Check Trivy
    if command -v trivy &> /dev/null; then
        print_success "Trivy is installed"
    else
        print_error "Trivy is not installed"
        echo "Please install Trivy manually:"
        echo "wget https://github.com/aquasecurity/trivy/releases/download/v0.49.1/trivy_0.49.1_Linux-64bit.deb"
        echo "sudo dpkg -i trivy_0.49.1_Linux-64bit.deb"
        exit 1
    fi
}

build_images() {
    print_header "Building Docker Images"
    
    print_step "Building vulnerable Nginx image..."
    docker build -t devsecops-nginx:latest ./applications/nginx
    if [ $? -eq 0 ]; then
        print_success "Nginx image built successfully"
    else
        print_error "Failed to build Nginx image"
        exit 1
    fi
}

start_environment() {
    print_header "Starting DevSecOps Environment"
    
    print_step "Starting containers with Docker Compose..."
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        print_success "Containers started successfully"
    else
        print_error "Failed to start containers"
        exit 1
    fi
    
    # Wait for services to be ready
    print_step "Waiting for services to be ready..."
    sleep 30
    
    # Check container status
    print_step "Checking container status..."
    docker-compose ps
}

run_security_scans() {
    print_header "Running Security Scans"
    
    print_step "Scanning Nginx image with Trivy..."
    ./scanners/trivy-scan.sh devsecops-nginx:latest
    
    print_step "Scanning Nginx:1.18.0 (for comparison)..."
    ./scanners/trivy-scan.sh nginx:1.18.0
    
    print_step "Scanning latest Nginx (for comparison)..."
    ./scanners/trivy-scan.sh nginx:latest
}

show_access_info() {
    print_header "Access Information"
    
    echo -e "${GREEN}Services are now running:${NC}"
    echo ""
    echo -e "${YELLOW}📊 Monitoring:${NC}"
    echo -e "  Grafana Dashboard: ${GREEN}http://localhost:3000${NC}"
    echo -e "     Username: admin"
    echo -e "     Password: admin"
    echo -e "  Prometheus: ${GREEN}http://localhost:9090${NC}"
    echo -e "  Loki: ${GREEN}http://localhost:3100${NC}"
    echo ""
    echo -e "${YELLOW}🚀 Applications:${NC}"
    echo -e "  Vulnerable Nginx: ${GREEN}http://localhost:8080${NC}"
    echo -e "  OWASP Juice Shop: ${GREEN}http://localhost:3001${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Tools:${NC}"
    echo -e "  Nginx Metrics: ${GREEN}http://localhost:9113/metrics${NC}"
    echo ""
    echo -e "${YELLOW}📁 Reports:${NC}"
    echo -e "  Security reports: ${GREEN}./reports/${NC}"
    echo ""
    echo -e "${BLUE}To stop the environment: ./scripts/setup.sh stop${NC}"
}

stop_environment() {
    print_header "Stopping Environment"
    
    print_step "Stopping containers..."
    docker-compose down
    
    print_step "Removing volumes..."
    docker volume rm -f devsecops-project_prometheus-data 2>/dev/null || true
    docker volume rm -f devsecops-project_grafana-data 2>/dev/null || true
    docker volume rm -f devsecops-project_loki-data 2>/dev/null || true
    docker volume rm -f devsecops-project_trivy-cache 2>/dev/null || true
    
    print_success "Environment stopped and cleaned up"
}

# Main execution
case "$1" in
    "start")
        check_dependencies
        build_images
        start_environment
        run_security_scans
        show_access_info
        ;;
    "stop")
        stop_environment
        ;;
    "scan")
        run_security_scans
        ;;
    "info")
        show_access_info
        ;;
    *)
        echo "Usage: $0 {start|stop|scan|info}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the complete DevSecOps environment"
        echo "  stop    - Stop and clean up the environment"
        echo "  scan    - Run security scans only"
        echo "  info    - Show access information"
        exit 1
        ;;
esac
