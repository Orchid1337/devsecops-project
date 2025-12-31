#!/bin/bash

echo "========================================="
echo "   START: DevSecOps Environment"
echo "========================================="

# Zatrzymaj jeśli działa
echo "1. Cleaning up..."
docker-compose down 2>/dev/null || true

# Zbuduj Nginx
echo "2. Building vulnerable Nginx..."
docker build -t devsecops-nginx:latest ./applications/nginx

# Uruchom
echo "3. Starting services (this may take a minute)..."
docker-compose up -d

# Daj czas na startup
echo "4. Waiting for services to initialize..."
sleep 40

# Status
echo "5. Current status:"
docker-compose ps

echo ""
echo "========================================="
echo "   ACCESS INSTRUCTIONS:"
echo "========================================="
echo ""
echo "If ALL services show 'Up':"
echo "--------------------------"
echo "🌐 Nginx (vulnerable):     http://localhost:8080"
echo "🎯 OWASP Juice Shop:       http://localhost:3001"
echo "📊 Grafana Dashboard:      http://localhost:3002"
echo "     Login: admin"
echo "     Password: admin"
echo "📈 Prometheus Metrics:     http://localhost:9091"
echo ""
echo "If some services failed:"
echo "------------------------"
echo "Check logs: docker-compose logs [service_name]"
echo "Try different ports if conflicts exist"
echo ""
echo "Basic test:"
echo "-----------"
echo "./test.sh"
echo ""
echo "Security scan:"
echo "--------------"
echo "./scan.sh"
echo ""
echo "========================================="
