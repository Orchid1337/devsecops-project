#!/usr/bin/env python3
# Trivy metrics exporter with all severity levels

from prometheus_client import start_http_server, Gauge, Counter
import time
import os
import re
import glob

# METRYKI
TRIVY_VULN_TOTAL = Gauge('trivy_vulnerabilities_total', 
                        'Total vulnerabilities found', 
                        ['severity', 'image'])
TRIVY_LAST_SCAN = Gauge('trivy_last_scan_timestamp', 
                       'Timestamp of last scan')
TRIVY_SCAN_COUNT = Counter('trivy_scans_total',
                          'Total number of scans performed')

def parse_trivy_report(report_file):
    """Parsuje raport Trivy i zwraca liczbę podatności dla wszystkich poziomów"""
    counts = {
        'CRITICAL': 0,
        'HIGH': 0,
        'MEDIUM': 0,
        'LOW': 0,
        'UNKNOWN': 0
    }
    
    try:
        with open(report_file, 'r') as f:
            content = f.read()
            
        # Szukamy linii z podatnościami
        lines = content.split('\n')
        for line in lines:
            if 'CRITICAL' in line:
                counts['CRITICAL'] += 1
            elif 'HIGH' in line:
                counts['HIGH'] += 1
            elif 'MEDIUM' in line:
                counts['MEDIUM'] += 1
            elif 'LOW' in line:
                counts['LOW'] += 1
            elif 'UNKNOWN' in line:
                counts['UNKNOWN'] += 1
                
    except Exception as e:
        print(f"❌ Błąd parsowania {report_file}: {e}")
    
    return counts

def update_metrics_from_reports():
    """Aktualizuje metryki na podstawie najnowszych raportów"""
    reports_dir = '/reports'
    
    if not os.path.exists(reports_dir):
        print(f"⚠️  Brak katalogu {reports_dir}")
        return
    
    # Znajdź najnowsze raporty dla każdego obrazu
    report_files = glob.glob(f"{reports_dir}/scan-*.txt")
    
    # Mapowanie obrazów do metryk
    images_metrics = {}
    
    for report in report_files:
        filename = os.path.basename(report)
        
        # Parsuj nazwę pliku (np. scan-nginx_1.18.0-alpine-20260101_120000.txt)
        match = re.search(r'scan-(.+?)-\d{8}_\d{6}', filename)
        if match:
            image_name = match.group(1).replace('_', ':')
            counts = parse_trivy_report(report)
            
            if image_name not in images_metrics:
                images_metrics[image_name] = counts.copy()
            else:
                # Zachowaj najwyższe wartości
                for severity in counts:
                    images_metrics[image_name][severity] = max(
                        images_metrics[image_name][severity], 
                        counts[severity]
                    )
    
    # Ustaw metryki
    for image, counts in images_metrics.items():
        for severity, count in counts.items():
            TRIVY_VULN_TOTAL.labels(severity=severity, image=image).set(count)
        
        print(f"📊 {image}: {counts['CRITICAL']}C {counts['HIGH']}H {counts['MEDIUM']}M {counts['LOW']}L")

def set_demo_metrics():
    """Ustaw demo metryki dla pokazania wszystkich poziomów"""
    # nginx
    TRIVY_VULN_TOTAL.labels(severity="CRITICAL", image="nginx:1.18.0-alpine").set(6)
    TRIVY_VULN_TOTAL.labels(severity="HIGH", image="nginx:1.18.0-alpine").set(29)
    TRIVY_VULN_TOTAL.labels(severity="MEDIUM", image="nginx:1.18.0-alpine").set(15)
    TRIVY_VULN_TOTAL.labels(severity="LOW", image="nginx:1.18.0-alpine").set(8)
    
    # juice-shop  
    TRIVY_VULN_TOTAL.labels(severity="CRITICAL", image="bkimminich/juice-shop:latest").set(3)
    TRIVY_VULN_TOTAL.labels(severity="HIGH", image="bkimminich/juice-shop:latest").set(12)
    TRIVY_VULN_TOTAL.labels(severity="MEDIUM", image="bkimminich/juice-shop:latest").set(20)
    TRIVY_VULN_TOTAL.labels(severity="LOW", image="bkimminich/juice-shop:latest").set(5)
    
    # node
    TRIVY_VULN_TOTAL.labels(severity="CRITICAL", image="node:14-alpine").set(2)
    TRIVY_VULN_TOTAL.labels(severity="HIGH", image="node:14-alpine").set(15)
    TRIVY_VULN_TOTAL.labels(severity="MEDIUM", image="node:14-alpine").set(25)
    TRIVY_VULN_TOTAL.labels(severity="LOW", image="node:14-alpine").set(10)

def main():
    # Start serwera metryk
    start_http_server(8000)
    print("🚀 Trivy exporter started on port 8000")
    
    # Ustaw timestamp
    TRIVY_LAST_SCAN.set(time.time())
    TRIVY_SCAN_COUNT.inc()
    
    # Ustaw demo metryki dla dashboardu
    set_demo_metrics()
    
    print("✅ Demo metrics set for dashboard")
    print(f"📊 Metrics available at: http://localhost:8000/metrics")
    
    # Główna pętla - co 30 sekund sprawdza nowe raporty
    while True:
        try:
            update_metrics_from_reports()
            TRIVY_LAST_SCAN.set(time.time())
        except Exception as e:
            print(f"❌ Error updating metrics: {e}")
        
        time.sleep(30)

if __name__ == '__main__':
    main()
