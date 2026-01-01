# 🛡️ DevSecOps - Kompletne środowisko bezpieczeństwa

## 📋 Opis projektu
Pełne środowisko DevSecOps demonstrujące zasady bezpieczeństwa w praktyce. Projekt zawiera celowo podatne aplikacje, pełny stack monitoringu oraz automatyczne skanowanie bezpieczeństwa.

## 🏗️ Architektura

### 📦 Aplikacje (celowo podatne)
- **Nginx** - wersja 1.18.0-alpine z znanymi CVE
- **Node.js App** - Node 14 z przestarzałymi zależnościami
- **Python App** - Flask na Python 3.7
- **PHP App** - PHP 5.6 z podatnościami
- **PostgreSQL** - baza danych wersja 9.6
- **OWASP Juice Shop** - aplikacja szkoleniowa

### 🔒 Bezpieczeństwo
- **Trivy** - skanowanie podatności kontenerów
- **Automatyczne raporty** - w folderze `reports/`
- **Dashboard bezpieczeństwa** - wizualizacja w Grafanie

### 📊 Monitoring
- **Grafana** - dashboardy i wizualizacja
- **Prometheus** - zbieranie metryk
- **Loki** - agregacja logów
- **Promtail** - kolekcja logów z Docker

## 🚀 Szybki start

### 1. Uruchom całe środowisko

./start.sh

### 2. Uruchom skanowanie bezpieczeństwa

./scan.sh

### 3. Wyczyść stare raporty (opcjonalnie)

🌐 Adresy dostępu
Usługa	URL	Port
Nginx	http://localhost:8080	8080
Juice Shop	http://localhost:3001	3001
Node.js App	http://localhost:3003	3003
Python App	http://localhost:5000	5000
PHP App	http://localhost:8081	8081
Grafana	http://localhost:3002	3002
Prometheus	http://localhost:9091	9091
Loki	http://localhost:3100	3100
🔒 Bezpieczeństwo
Skanowanie podatności
Projekt zawiera zintegrowane skanowanie podatności:

Automatyczne skanowanie 6 obrazów Dockera

Raporty w formacie tekstowym

Dashboard w Grafanie

Integracja z CI/CD

Celowe podatności
Wszystkie aplikacje używają przestarzałych wersji:

Nginx 1.18.0-alpine

Node.js 14-alpine

Python 3.7-alpine

PHP 5.6-apache

PostgreSQL 9.6

📊 Monitoring
Stack observability
Grafana - wizualizacja metryk i logów

Prometheus - zbieranie metryk z kontenerów

Loki - agregacja logów w czasie rzeczywistym

Promtail - kolektor logów z Docker

⚙️ CI/CD Pipeline
GitHub Actions
Plik: .github/workflows/walidacja-projektu.yml

Pipeline wykonuje:
✅ Walidacja struktury projektu
✅ Sprawdzenie wymaganych plików
✅ Automatyczne uruchamianie przy każdym pushu

🏗️ Struktura projektu

devsecops-project/
├── applications/          # Podatne aplikacje
├── monitoring/           # Stack monitoringu
├── scanners/            # Narzędzia skanujące
├── reports/             # Raporty skanów
├── .github/workflows/   # CI/CD pipeline
├── start.sh            # Uruchomienie środowiska
├── scan.sh             # Skanowanie bezpieczeństwa
├── clean-reports.sh    # Czyszczenie raportów
├── docker-compose.yaml # Konfiguracja usług
└── README.md          # Dokumentacja

🛠️ Wymagania systemowe
Docker 20.10+

Docker Compose 2.0+

4GB RAM minimum

10GB wolnego miejsca

📄 Projekt edukacyjny stworzony do celów demonstracyjnych i naukowych.
