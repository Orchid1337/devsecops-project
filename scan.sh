#!/bin/bash

echo "========================================="
echo "   SCAN: Security Vulnerability Check"
echo "========================================="

mkdir -p reports
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "1. Scanning base image (nginx:1.18.0-alpine)..."
echo "   This shows WHY we need security scanning:"
trivy image --format table --severity HIGH,CRITICAL nginx:1.18.0-alpine | tee reports/scan-base-$TIMESTAMP.txt

echo ""
echo "2. Scanning our vulnerable app..."
trivy image --format table --severity HIGH,CRITICAL devsecops-nginx:latest | tee reports/scan-app-$TIMESTAMP.txt

echo ""
echo "3. Scanning OWASP Juice Shop..."
trivy image --format table --severity HIGH,CRITICAL bkimminich/juice-shop:latest | tee reports/scan-juice-$TIMESTAMP.txt

echo ""
echo "========================================="
echo "   SCAN RESULTS SUMMARY:"
echo "========================================="

echo "Reports saved in: ./reports/"
ls -la reports/*.txt

echo ""
echo "To view critical vulnerabilities:"
echo "  grep -i 'critical' reports/scan-base-$TIMESTAMP.txt"
echo ""
echo "This demonstrates the need for automated"
echo "security scanning in CI/CD pipelines!"
