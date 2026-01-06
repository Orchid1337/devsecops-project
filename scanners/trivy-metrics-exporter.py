#!/usr/bin/env python3
# Trivy metrics exporter

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

def parse_report(report_file):
    """Liczy podatności w raporcie"""
    counts = {'CRITICAL': 0, 'HIGH': 0, 'MEDIUM': 0, 'LOW': 0, 'UNKNOWN': 0}
    
    try:
        with open(report_file, 'r') as f:
            for line in f:
                if 'CVE-' in line:
                    if 'CRITICAL' in line.upper():
                        counts['CRITICAL'] += 1
                    elif 'HIGH' in line.upper():
                        counts['HIGH'] += 1
                    elif 'MEDIUM' in line.upper():
                        counts['MEDIUM'] += 1
                    elif 'LOW' in line.upper():
                        counts['LOW'] += 1
                    elif 'UNKNOWN' in line.upper():
                        counts['UNKNOWN'] += 1
    except:
        pass
    
    return counts

def get_image_name(filename):
    """Wyciąga nazwę obrazu z nazwy pliku"""
    # np. scan-nginx_1.18.0-alpine-20260106_133101.txt
    name = os.path.basename(filename).replace('scan-', '').replace('.txt', '')
    # Usuń timestamp
    name = re.sub(r'-\d{8}_\d{6}$', '', name)
    
    # SPECJALNY PRZYPADEK dla juice-shop
    if name == 'bkimminich_juice-shop_latest':
        return 'bkimminich/juice-shop:latest'
    
    # Zamień _ na : dla tagu
    return name.replace('_', ':', 1)

def update_metrics():
    """Główna funkcja aktualizująca"""
    reports_dir = '/reports'
    
    if not os.path.exists(reports_dir):
        print("⚠️  Brak katalogu /reports")
        return
    
    # Znajdź najnowsze raporty
    reports = {}
    for file in glob.glob(f"{reports_dir}/scan-*.txt"):
        image = get_image_name(file)
        reports[image] = file
    
    # Ustaw metryki
    for image, file in reports.items():
        counts = parse_report(file)
        for severity, count in counts.items():
            TRIVY_VULN_TOTAL.labels(severity=severity, image=image).set(count)
        
        # Pokaż podsumowanie
        if any(counts.values()):
            c = counts
            print(f"📊 {image}: {c['CRITICAL']}C {c['HIGH']}H {c['MEDIUM']}M {c['LOW']}L")

def main():
    # Start serwera
    start_http_server(8000)
    print("🚀 Trivy exporter na porcie 8000")
    print("📊 Pobiera dane z /reports/")
    
    # Główna pętla
    while True:
        try:
            update_metrics()
            TRIVY_LAST_SCAN.set(time.time())
        except Exception as e:
            print(f"❌ Błąd: {e}")
        
        time.sleep(30)

if __name__ == '__main__':
    main()
