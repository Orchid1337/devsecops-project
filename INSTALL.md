# INSTALACJA - 3 KROKI

## 1. Zainstaluj zależności:
```bash
sudo apt update
sudo apt install -y docker.io docker-compose

# Trivy (security scanner)
wget https://github.com/aquasecurity/trivy/releases/download/v0.49.1/trivy_0.49.1_Linux-64bit.deb
sudo dpkg -i trivy_0.49.1_Linux-64bit.deb

# Uprawnienia Dockera
sudo usermod -aG docker $USER
# Wyloguj się i zaloguj ponownie
