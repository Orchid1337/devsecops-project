#!/bin/bash

echo "Setting up monitoring..."

# 1. Sprawdź połączenie Prometheus -> Nginx
echo "1. Testing Prometheus scrape targets..."
curl -s http://localhost:9091/targets | grep -A5 -B5 "nginx"

# 2. Utwórz prosty dashboard ręcznie
echo ""
echo "2. Manual Grafana setup instructions:"
echo "====================================="
echo "1. Go to http://localhost:3002"
echo "2. Login with admin/admin"
echo "3. Go to Configuration -> Data Sources"
echo "4. Add Prometheus:"
echo "   - URL: http://prometheus:9090"
echo "   - Click 'Save & Test'"
echo ""
echo "5. Create dashboard:"
echo "   - Click '+' -> Dashboard"
echo "   - Add panel with query: up"
echo "   - Save dashboard as 'DevSecOps Monitoring'"
