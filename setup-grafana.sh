#!/bin/bash

echo "========================================="
echo "   Setting up Grafana Dashboard"
echo "========================================="

echo "1. Creating dashboard directory..."
mkdir -p monitoring/grafana/dashboards

echo "2. Creating datasource configuration..."
cat > monitoring/grafana/datasources.yaml << 'DS_EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
DS_EOF

echo "3. Creating dashboard configuration..."
cat > monitoring/grafana/dashboard.yaml << 'DASH_EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    editable: true
    options:
      path: /etc/grafana/provisioning/dashboards
DASH_EOF

echo "4. Creating DevSecOps dashboard..."
cat > monitoring/grafana/dashboards/devsecops.json << 'JSON_EOF'
{
  "dashboard": {
    "title": "DevSecOps Monitoring",
    "panels": [
      {
        "title": "Services Status",
        "type": "stat",
        "targets": [{"expr": "up"}]
      }
    ]
  }
}
JSON_EOF

echo "5. Restarting Grafana..."
docker-compose restart grafana

echo ""
echo "✅ Grafana configuration updated!"
echo "   Access at: http://localhost:3002"
echo "   Username: admin"
echo "   Password: admin"
