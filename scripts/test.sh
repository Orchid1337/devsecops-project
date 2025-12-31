#!/bin/bash

echo "========================================="
echo "   Testing DevSecOps Environment"
echo "========================================="

echo "1. Checking which environment is running..."
echo ""

# Check Docker Compose
if docker-compose ps | grep -q "Up"; then
    echo "✅ Docker Compose environment detected"
    echo "   Services running:"
    docker-compose ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}"
    
    echo ""
    echo "Testing Docker Compose services..."
    for port in 8080 3001 3002 9091; do
        if timeout 2 curl -s http://localhost:$port > /dev/null; then
            echo "   ✅ Port $port: Service responding"
        else
            echo "   ❌ Port $port: No response"
        fi
    done
fi

echo ""
# Check Kubernetes
if kubectl cluster-info &> /dev/null; then
    echo "✅ Kubernetes environment detected"
    echo "   Cluster info:"
    kubectl cluster-info | head -2
    
    echo ""
    echo "Kubernetes resources:"
    kubectl get deployments -A 2>/dev/null | grep -E "(nginx|prometheus|grafana)" || echo "   No deployments found"
else
    echo "ℹ️  Kubernetes not running (optional)"
fi

echo ""
echo "2. Docker images check:"
docker images | grep -E "(devsecops-nginx|grafana|prometheus|juice-shop)" | head -5

echo ""
echo "3. Security tools check:"
which trivy && echo "   ✅ Trivy installed" || echo "   ❌ Trivy not installed"

echo ""
echo "4. Quick access:"
echo "   If Docker Compose is running:"
echo "   - Nginx:      http://localhost:8080"
echo "   - Grafana:    http://localhost:3002 (admin/admin)"
echo "   - Prometheus: http://localhost:9091"
echo "   - Juice Shop: http://localhost:3001"
echo ""
echo "   If Kubernetes is running:"
echo "   - Nginx:      http://localhost:30080"
echo "   - Grafana:    http://localhost:30080/grafana (admin/admin)"
echo "   - Prometheus: http://localhost:30080/prometheus"

echo ""
echo "========================================="
echo "   Test completed!"
echo "========================================="
