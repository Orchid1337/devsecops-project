#!/bin/bash

# Kolory
CZERWONY='\033[0;31m'
ZIELONY='\033[0;32m'
ZOLTY='\033[1;33m'
NIEBIESKI='\033[0;34m'
FIOLETOWY='\033[0;35m'
CYJAN='\033[0;36m'
BIALY='\033[1;37m'
NC='\033[0m'

echo -e "${NIEBIESKI}=========================================${NC}"
echo -e "${NIEBIESKI}   🔒 SKANOWANIE BEZPIECZEŃSTWA${NC}"
echo -e "${NIEBIESKI}=========================================${NC}"

# SPRAWDZENIE TRIVY
if ! command -v trivy &> /dev/null; then
    echo -e "${ZOLTY}⚠️  Używam Trivy z Docker (lokalne nie znalezione)${NC}"
    TRIVY_CMD="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:0.49.1"
else
    TRIVY_CMD="trivy"
fi

# Tworzenie katalogu na raporty
mkdir -p reports
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
echo -e "${ZOLTY}🕐 Czas skanowania: $(date)${NC}"
echo ""

# OGRANICZENIA DLA DEMONSTRACJI (mniej danych) - WSZYSTKIE POZIOMY
TRIVY_OPTS="--format table --timeout 5m --no-progress"

# 1. SKANOWANIE OBRAZÓW (TYLKO NAJWAŻNIEJSZE)
IMAGES=(
    "nginx:1.18.0-alpine"
    "bkimminich/juice-shop:latest"
    "node:14-alpine"
    "python:3.7-alpine"
    "postgres:9.6"
    "php:5.6-apache"
)

echo -e "${FIOLETOWY}[1/3] 🔍 SKANOWANIE OBRAZÓW BAZOWYCH${NC}"
echo ""

TOTAL_CRITICAL=0
TOTAL_HIGH=0
TOTAL_MEDIUM=0
TOTAL_LOW=0
TOTAL_UNKNOWN=0

for IMAGE in "${IMAGES[@]}"; do
    echo -e "${CYJAN}📦 $IMAGE:${NC}"
    
    # Nazwa pliku bez specjalnych znaków
    FILENAME=$(echo "$IMAGE" | tr '/:' '_')
    
    # Skanuj i zapisz
    $TRIVY_CMD image $TRIVY_OPTS "$IMAGE" 2>&1 | tee "reports/scan-$FILENAME-$TIMESTAMP.txt"
    
    # Zlicz podatności dla wszystkich poziomów
    CRITICAL=$(grep -c "CRITICAL" "reports/scan-$FILENAME-$TIMESTAMP.txt" 2>/dev/null || echo "0")
    HIGH=$(grep -c "HIGH" "reports/scan-$FILENAME-$TIMESTAMP.txt" 2>/dev/null || echo "0")
    MEDIUM=$(grep -c "MEDIUM" "reports/scan-$FILENAME-$TIMESTAMP.txt" 2>/dev/null || echo "0")
    LOW=$(grep -c "LOW" "reports/scan-$FILENAME-$TIMESTAMP.txt" 2>/dev/null || echo "0")
    UNKNOWN=$(grep -c "UNKNOWN" "reports/scan-$FILENAME-$TIMESTAMP.txt" 2>/dev/null || echo "0")
    
    TOTAL_CRITICAL=$((TOTAL_CRITICAL + CRITICAL))
    TOTAL_HIGH=$((TOTAL_HIGH + HIGH))
    TOTAL_MEDIUM=$((TOTAL_MEDIUM + MEDIUM))
    TOTAL_LOW=$((TOTAL_LOW + LOW))
    TOTAL_UNKNOWN=$((TOTAL_UNKNOWN + UNKNOWN))
    
    echo -e "  ${CZERWONY}Critical: $CRITICAL${NC} | ${ZOLTY}High: $HIGH${NC} | ${CYJAN}Medium: $MEDIUM${NC} | ${ZIELONY}Low: $LOW${NC}"
    echo ""
done

# 2. AKTUALIZUJ METRYKI W EXPORTERZE
echo -e "${FIOLETOWY}[2/3] 📊 AKTUALIZACJA METRYK${NC}"
echo ""

# Wysyłanie metryk do eksportera (jeśli działa)
if curl -s http://localhost:8083/update >/dev/null 2>&1; then
    echo -e "${ZIELONY}✅ Metryki zaktualizowane${NC}"
else
    echo -e "${ZOLTY}⚠️  Eksporter nie obsługuje aktualizacji przez HTTP${NC}"
    echo -e "${BIALY}Eksporter sam odczyta raporty za 30 sekund${NC}"
fi

# 3. PODSUMOWANIE
echo -e "${FIOLETOWY}[3/3] 📈 PODSUMOWANIE${NC}"
echo ""

echo -e "${BIALY}Raporty zapisane w:${NC}"
ls -la reports/*-$TIMESTAMP.txt 2>/dev/null | wc -l | xargs echo -e "${ZIELONY}  ⮕  Plików:${NC}"
echo ""

echo -e "${BIALY}Statystyki podatności:${NC}"
echo -e "${CYJAN}────────────────────────────────${NC}"
echo -e "  ${CZERWONY}KRYTYCZNE: $TOTAL_CRITICAL${NC}"
echo -e "  ${ZOLTY}WYSOKIE:    $TOTAL_HIGH${NC}"
echo -e "  ${CYJAN}ŚREDNIE:    $TOTAL_MEDIUM${NC}"
echo -e "  ${ZIELONY}NISKIE:     $TOTAL_LOW${NC}"
echo -e "  ${BIALY}NIEZNANE:   $TOTAL_UNKNOWN${NC}"
echo -e "${CYJAN}────────────────────────────────${NC}"
TOTAL_ALL=$((TOTAL_CRITICAL + TOTAL_HIGH + TOTAL_MEDIUM + TOTAL_LOW + TOTAL_UNKNOWN))
echo -e "  ${NIEBIESKI}RAZEM:      $TOTAL_ALL${NC}"
echo ""

echo -e "${BIALY}Dla pracy inżynierskiej:${NC}"
echo "✅ Zeskanowano ${#IMAGES[@]} obrazów"
echo "✅ Znaleziono $TOTAL_ALL podatności"
echo "✅ Pełne dane dla dashboardu Grafana"
echo "✅ Perfekcyjne dla demonstracji DevSecOps"
echo ""

echo -e "${NIEBIESKI}=========================================${NC}"
echo -e "${NIEBIESKI}   ✅ SKANOWANIE ZAKOŃCZONE${NC}"
echo -e "${NIEBIESKI}=========================================${NC}"

# 4. WYŚWIETL KILKA PRZYKŁADÓW (różne poziomy)
echo -e "${BIALY}Przykładowe znaleziska:${NC}"
if [ -f "reports/scan-nginx_1.18.0-alpine-$TIMESTAMP.txt" ]; then
    echo -e "${CZERWONY}Critical:${NC}"
    grep "CRITICAL" "reports/scan-nginx_1.18.0-alpine-$TIMESTAMP.txt" | head -2
    echo -e "${ZOLTY}High:${NC}"
    grep "HIGH" "reports/scan-nginx_1.18.0-alpine-$TIMESTAMP.txt" | head -2
    echo -e "${CYJAN}Medium:${NC}"
    grep "MEDIUM" "reports/scan-nginx_1.18.0-alpine-$TIMESTAMP.txt" | head -2
fi

echo ""
echo -e "${FIOLETOWY}📊 Dashboard dostępny pod: http://localhost:3002${NC}"
echo -e "${FIOLETOWY}🔍 Eksporter metryk: http://localhost:8083/metrics${NC}"
echo -e "${FIOLETOWY}📈 Prometheus: http://localhost:9091${NC}"
