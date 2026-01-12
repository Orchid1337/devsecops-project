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

echo -e "${ZOLTY}🕐 Czas skanowania: $(date)${NC}"
echo ""

# Tworzenie katalogu na raporty
mkdir -p reports
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Używaj Trivy z Docker
TRIVY_CMD="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:0.49.1 image"

# 1. PRZYGOTOWANIE
echo -e "${FIOLETOWY}[1/3] 📋 LISTA OBRAZÓW${NC}"
echo ""

LOCAL_IMAGES=(
    "devsecops-project-nginx"
    "devsecops-project-node-vuln-app"
    "devsecops-project-python-vuln-app"
    "devsecops-project-php-vuln-app"
    "devsecops-project-vulnerable-db"
)

REMOTE_IMAGES=(
    "bkimminich/juice-shop:latest"
)

echo -e "${BIALY}Obrazy do skanowania:${NC}"
echo -e "${ZIELONY}Lokalne (5):${NC}"
for img in "${LOCAL_IMAGES[@]}"; do
    echo "  • $img:latest"
done
echo -e "${ZIELONY}Zdalny (1):${NC}"
echo "  • bkimminich/juice-shop:latest"
echo ""

# 2. SKANOWANIE
echo -e "${FIOLETOWY}[2/3] 🔍 SKANOWANIE${NC}"
echo ""

TOTAL_CRITICAL=0
TOTAL_HIGH=0
TOTAL_MEDIUM=0
TOTAL_LOW=0

scan_single_image() {
    local IMAGE_NAME=$1
    
    echo -e "${CYJAN}Skanowanie: $IMAGE_NAME${NC}"
    
    # Nazwa pliku raportu
    FILENAME=$(echo "$IMAGE_NAME" | tr '/:' '_')
    REPORT_FILE="reports/scan-$FILENAME-$TIMESTAMP.txt"
    
    # Skanuj
    $TRIVY_CMD --format table --no-progress "$IMAGE_NAME" 2>&1 | tee "$REPORT_FILE" > /dev/null
    
    # Znajdź i sparsuj linię z Total
    local TOTAL_LINE=$(grep -i "total:" "$REPORT_FILE" | tail -1)
    
    local CRITICAL=0
    local HIGH=0
    local MEDIUM=0
    local LOW=0
    
    if [[ -n "$TOTAL_LINE" ]]; then
        # Wyciągnij liczby używając awk
        CRITICAL=$(echo "$TOTAL_LINE" | awk -F'CRITICAL: ' '{print $2}' | awk -F'[^0-9]*' '{print $1}' | grep -o '[0-9]\+' || echo "0")
        HIGH=$(echo "$TOTAL_LINE" | awk -F'HIGH: ' '{print $2}' | awk -F'[^0-9]*' '{print $1}' | grep -o '[0-9]\+' || echo "0")
        MEDIUM=$(echo "$TOTAL_LINE" | awk -F'MEDIUM: ' '{print $2}' | awk -F'[^0-9]*' '{print $1}' | grep -o '[0-9]\+' || echo "0")
        LOW=$(echo "$TOTAL_LINE" | awk -F'LOW: ' '{print $2}' | awk -F'[^0-9]*' '{print $1}' | grep -o '[0-9]\+' || echo "0")
    fi
    
    echo -e "  Wynik: ${CZERWONY}Critical: $CRITICAL${NC} | ${ZOLTY}High: $HIGH${NC} | ${CYJAN}Medium: $MEDIUM${NC} | ${ZIELONY}Low: $LOW${NC}"
    echo ""
    
    # Zapamiętaj
    SCAN_RESULT_CRITICAL=$CRITICAL
    SCAN_RESULT_HIGH=$HIGH
    SCAN_RESULT_MEDIUM=$MEDIUM
    SCAN_RESULT_LOW=$LOW
}

# Skanuj wszystkie obrazy
ALL_IMAGES=()
for img in "${LOCAL_IMAGES[@]}"; do
    ALL_IMAGES+=("$img:latest")
done
for img in "${REMOTE_IMAGES[@]}"; do
    ALL_IMAGES+=("$img")
done

for IMG in "${ALL_IMAGES[@]}"; do
    scan_single_image "$IMG"
    TOTAL_CRITICAL=$((TOTAL_CRITICAL + SCAN_RESULT_CRITICAL))
    TOTAL_HIGH=$((TOTAL_HIGH + SCAN_RESULT_HIGH))
    TOTAL_MEDIUM=$((TOTAL_MEDIUM + SCAN_RESULT_MEDIUM))
    TOTAL_LOW=$((TOTAL_LOW + SCAN_RESULT_LOW))
done

# 3. PODSUMOWANIE
echo -e "${FIOLETOWY}[3/3] 📊 PODSUMOWANIE${NC}"
echo ""

echo -e "${BIALY}Raporty zapisane w:${NC}"
REPORT_COUNT=$(ls -1 reports/*-$TIMESTAMP.txt 2>/dev/null | wc -l)
echo -e "${ZIELONY}  ⮕  $REPORT_COUNT plików raportów${NC}"
if [ $REPORT_COUNT -gt 0 ]; then
    ls -la reports/*-$TIMESTAMP.txt | head -10
fi
echo ""

echo -e "${BIALY}Statystyki podatności:${NC}"
echo -e "${CYJAN}────────────────────────────────${NC}"
echo -e "  ${CZERWONY}KRYTYCZNE: $TOTAL_CRITICAL${NC}"
echo -e "  ${ZOLTY}WYSOKIE:    $TOTAL_HIGH${NC}"
echo -e "  ${CYJAN}ŚREDNIE:    $TOTAL_MEDIUM${NC}"
echo -e "  ${ZIELONY}NISKIE:     $TOTAL_LOW${NC}"
echo -e "${CYJAN}────────────────────────────────${NC}"
TOTAL_ALL=$((TOTAL_CRITICAL + TOTAL_HIGH + TOTAL_MEDIUM + TOTAL_LOW))
echo -e "  ${NIEBIESKI}RAZEM:      $TOTAL_ALL podatności${NC}"
echo ""

echo -e "${ZIELONY}📈 Aktualizacja dashboardu Grafana...${NC}"
if curl -s http://localhost:8083/update >/dev/null 2>&1; then
    echo -e "${ZIELONY}✅ Metryki zaktualizowane${NC}"
else
    echo -e "${ZOLTY}⚠️  Eksporter nie odpowiada${NC}"
fi

echo ""
echo -e "${FIOLETOWY}📊 Dashboard: http://localhost:3002${NC}"
echo -e "${FIOLETOWY}📁 Raporty: ./reports/${NC}"

echo -e "${NIEBIESKI}=========================================${NC}"
echo -e "${NIEBIESKI}   ✅ SKANOWANIE ZAKOŃCZONE${NC}"
echo -e "${NIEBIESKI}=========================================${NC}"
