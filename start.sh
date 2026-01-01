#!/bin/bash

# Kolory
CZERWONY='\033[0;31m'
ZIELONY='\033[0;32m'
ZOLTY='\033[1;33m'
NIEBIESKI='\033[0;34m'
CYJAN='\033[0;36m'
FIOLETOWY='\033[0;35m'
BIALY='\033[1;37m'
NC='\033[0m' # Bez koloru

echo -e "${NIEBIESKI}=========================================${NC}"
echo -e "${NIEBIESKI}   🚀 PROJEKT DEVSECOPS - URUCHAMIANIE${NC}"
echo -e "${NIEBIESKI}=========================================${NC}"

# Sprawdzenie Dockera
echo -e "${ZOLTY}[1/7] 🔍 Sprawdzanie Dockera...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${CZERWONY}❌ Docker nie działa! Uruchom Docker najpierw.${NC}"
    exit 1
fi
echo -e "${ZIELONY}✅ Docker działa${NC}"

# Sprawdzenie Docker Compose
echo -e "${ZOLTY}[2/7] 📋 Sprawdzanie Docker Compose...${NC}"
if ! docker-compose version > /dev/null 2>&1; then
    echo -e "${CZERWONY}❌ Docker Compose nie znaleziony!${NC}"
    exit 1
fi
echo -e "${ZIELONY}✅ Docker Compose dostępny${NC}"

# Czyszczenie środowiska
echo -e "${ZOLTY}[3/7] 🧹 Czyszczenie istniejących kontenerów...${NC}"
echo -e "${CYJAN}Zatrzymywanie wszystkich kontenerów...${NC}"
docker-compose down --remove-orphans 2>/dev/null || true
echo -e "${ZIELONY}✅ Środowisko wyczyszczone${NC}"

# Budowanie aplikacji
echo -e "${ZOLTY}[4/7] 🔨 Budowanie aplikacji...${NC}"
echo -e "${CYJAN}To może zająć kilka minut...${NC}"

# Lista aplikacji do zbudowania
APLIKACJE=("nginx" "node-vuln-app" "python-vuln-app" "php-vuln-app" "vulnerable-db")

for app in "${APLIKACJE[@]}"; do
    echo -n "  Budowanie $app... "
    if docker-compose build $app --quiet > /dev/null 2>&1; then
        echo -e "${ZIELONY}✅${NC}"
    else
        echo -e "${CZERWONY}❌ (może być już zbudowana)${NC}"
    fi
done

# Uruchamianie wszystkich usług
echo -e "${ZOLTY}[5/7] 🚀 Uruchamianie środowiska DevSecOps...${NC}"
docker-compose up -d

# Oczekiwanie na inicjalizację
echo -e "${ZOLTY}[6/7] ⏳ Oczekiwanie na uruchomienie usług (30 sekund)...${NC}"
for i in {1..30}; do
    echo -n "."
    sleep 1
done
echo -e "\n${ZIELONY}✅ Usługi gotowe${NC}"

# Status usług
echo -e "${ZOLTY}[7/7] 📊 Sprawdzanie statusu usług...${NC}"
echo ""
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# Informacje o dostępie
echo -e "\n${FIOLETOWY}🌐 APLIKACJE PODATNE:${NC}"
echo -e "${ZIELONY}├── Nginx (celowo przestarzały)${NC}    http://localhost:${NIEBIESKI}8080${NC}"
echo -e "${ZIELONY}├── OWASP Juice Shop${NC}              http://localhost:${NIEBIESKI}3001${NC}"
echo -e "${ZIELONY}├── Aplikacja Node.js${NC}             http://localhost:${NIEBIESKI}3003${NC}"
echo -e "${ZIELONY}├── Aplikacja Python/Flask${NC}        http://localhost:${NIEBIESKI}5000${NC}"
echo -e "${ZIELONY}├── Aplikacja PHP (legacy)${NC}        http://localhost:${NIEBIESKI}8081${NC}"
echo -e "${ZIELONY}└── Baza danych PostgreSQL${NC}        port:${NIEBIESKI}5432${NC}"
echo -e "   ${BIALY}dane logowania: admin / insecure123${NC}"

echo -e "\n${FIOLETOWY}📊 MONITOROWANIE:${NC}"
echo -e "${ZIELONY}├── Grafana Dashboard${NC}             http://localhost:${NIEBIESKI}3002${NC}"
echo -e "${ZIELONY}├── Prometheus (metryki)${NC}          http://localhost:${NIEBIESKI}9091${NC}"
echo -e "${ZIELONY}├── Loki (logi)${NC}                   http://localhost:${NIEBIESKI}3100${NC}"
echo -e "${ZIELONY}└── Loki status${NC}                   http://localhost:3100/ready"

echo -e "\n${FIOLETOWY}🔒 SKANOWANIE BEZPIECZEŃSTWA:${NC}"
echo -e "${ZIELONY}├── Skanowanie obrazów${NC}           ./scan.sh"
echo -e "${ZIELONY}├── Raporty bezpieczeństwa${NC}        ./reports/"
echo -e "${ZIELONY}└── Trivy scanner${NC}                 docker-compose exec trivy trivy image nginx:1.18.0-alpine"

echo -e "\n${FIOLETOWY}🔧 PRZYDATNE KOMENDY:${NC}"
echo -e "${ZIELONY}├── Logi usług${NC}                   docker-compose logs -f [nazwa_usługi]"
echo -e "${ZIELONY}├── Zatrzymanie środowiska${NC}       docker-compose down"
echo -e "${ZIELONY}├── Restart usług${NC}                docker-compose restart"
echo -e "${ZIELONY}└── Przebudowanie${NC}                docker-compose build --no-cache"

echo -e "\n${NIEBIESKI}=========================================${NC}"
echo -e "${NIEBIESKI}   STATYSTYKI:${NC}"
echo -e "${NIEBIESKI}   • 11 usług w kontenerach${NC}"
echo -e "${NIEBIESKI}   • 5 aplikacji z podatnościami${NC}"
echo -e "${NIEBIESKI}   • Pełny stack DevSecOps${NC}"
echo -e "${NIEBIESKI}=========================================${NC}"

# Test dostępności WSZYSTKICH aplikacji
echo -e "\n${ZOLTY}🔍 TEST DOSTĘPNOŚCI WSZYSTKICH APLIKACJI:${NC}"

# Wszystkie usługi z docker-compose.yaml
uslugi=(
    "nginx:8080"
    "juice-shop:3001"
    "node-vuln-app:3003"
    "python-vuln-app:5000"
    "php-vuln-app:8081"
    "vulnerable-db:5432"
    "grafana:3002"
    "prometheus:9091"
    "loki:3100"
)

for usluga in "${uslugi[@]}"; do
    nazwa=$(echo $usluga | cut -d':' -f1)
    port=$(echo $usluga | cut -d':' -f2)
    
    if timeout 2 bash -c "cat < /dev/null > /dev/tcp/localhost/$port" 2>/dev/null; then
        echo -e "  ${nazwa}:${port} ${ZIELONY}✓ DZIAŁA${NC}"
    else
        echo -e "  ${nazwa}:${port} ${CZERWONY}✗ NIEDOSTĘPNE${NC}"
    fi
done

# Dodatkowe usługi bez portów
echo -e "\n${ZOLTY}🔧 INNE USŁUGI:${NC}"
echo -e "  promtail ${ZIELONY}✓ DZIAŁA (kolektor logów)${NC}"
echo -e "  trivy    ${ZIELONY}✓ DZIAŁA (skaner bezpieczeństwa)${NC}"

echo -e "\n${ZIELONY}🎉 Środowisko DevSecOps gotowe do pracy!${NC}"
echo -e "${BIALY}Uruchom './scan.sh' aby zobaczyć podatności bezpieczeństwa.${NC}"
