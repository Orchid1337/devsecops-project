#!/bin/bash

echo "========================================="
echo "   TEST: DevSecOps Environment"
echo "========================================="

echo "1. Container Status:"
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "2. Testing Services (ACTUAL PORTS):"
services=(
    "nginx:8080:Vulnerable Nginx"
    "juice-shop:3001:OWASP Juice Shop"
    "grafana:3002:Grafana Dashboard"      # POPRAWIONE: 3002 zamiast 3000
    "prometheus:9091:Prometheus Metrics"  # POPRAWIONE: 9091 zamiast 9090
)

all_ok=true
for service in "${services[@]}"; do
    port=$(echo $service | cut -d: -f2)
    desc=$(echo $service | cut -d: -f3)
    
    if curl -s -f --max-time 5 http://localhost:$port > /dev/null; then
        echo "   ✅ $desc (port $port): ONLINE"
    else
        echo "   ❌ $desc (port $port): OFFLINE"
        all_ok=false
    fi
done

echo ""
echo "3. Security Scanning Demo:"
if command -v trivy &> /dev/null; then
    echo "   ✅ Trivy installed locally"
    echo "   Run: ./scan.sh  (shows 35 vulnerabilities in nginx:1.18.0)"
else
    echo "   ⚠️  Trivy not installed locally"
fi

echo ""
echo "4. Quick Access URLs:"
echo "   🔓 Nginx (vulnerable):     http://localhost:8080"
echo "   🎯 Juice Shop:             http://localhost:3001"
echo "   📊 Grafana:               http://localhost:3002  (admin/admin)"
echo "   📈 Prometheus:            http://localhost:9091"
echo "   📁 Reports:               ./reports/"

echo ""
if [ "$all_ok" = true ]; then
    echo "========================================="
    echo "   ✅ ALL SERVICES OPERATIONAL!"
    echo "========================================="
else
    echo "========================================="
    echo "   ⚠️  SOME SERVICES OFFLINE"
    echo "   Check: docker-compose logs"
    echo "========================================="
fi
