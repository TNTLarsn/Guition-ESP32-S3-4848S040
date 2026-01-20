#!/bin/bash
# Lokales CI-Test-Skript für ESPHome-Projekt (Bash-Version)
# Führt die gleichen Schritte wie .github/workflows/ci.yml aus

set -e

# Farben für Terminal-Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Funktionen
print_header() {
    echo -e "\n${BOLD}${BLUE}============================================================${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}============================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Prüfe ESPHome
print_header "ESPHome Version Check"
if command -v esphome &> /dev/null; then
    ESPHOME_VERSION=$(esphome version)
    print_success "ESPHome gefunden: $ESPHOME_VERSION"
else
    print_error "ESPHome nicht gefunden!"
    print_warning "Installiere mit: pip install esphome"
    exit 1
fi

# YAML-Dateien aus ci.yml
YAML_FILES=(
    "src/main.yaml"
    "src/main.factory.yaml"
)

# Prüfe ob alle Dateien existieren
print_header "Prüfe YAML-Dateien"
for yaml_file in "${YAML_FILES[@]}"; do
    if [ -f "$yaml_file" ]; then
        print_success "$yaml_file gefunden"
    else
        print_error "$yaml_file nicht gefunden!"
        exit 1
    fi
done

# Validiere alle YAML-Dateien
print_header "Validiere Konfigurationen"
VALIDATION_FAILED=0
for yaml_file in "${YAML_FILES[@]}"; do
    echo -e "\n  Validiere $yaml_file..."
    if esphome config "$yaml_file" > /dev/null 2>&1; then
        print_success "$yaml_file ist valide"
    else
        print_error "$yaml_file hat Fehler"
        esphome config "$yaml_file"
        VALIDATION_FAILED=1
    fi
done

if [ $VALIDATION_FAILED -eq 1 ]; then
    print_error "Validierung fehlgeschlagen"
    exit 1
fi

# Kompiliere alle YAML-Dateien
print_header "Kompiliere Firmware"
COMPILE_FAILED=0
for yaml_file in "${YAML_FILES[@]}"; do
    echo -e "\n  Kompiliere $yaml_file..."
    if esphome compile "$yaml_file"; then
        print_success "$yaml_file erfolgreich kompiliert"
    else
        print_error "$yaml_file Kompilierung fehlgeschlagen"
        COMPILE_FAILED=1
    fi
done

# Zusammenfassung
print_header "Zusammenfassung"
if [ $COMPILE_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}${BOLD}✓ Alle Tests bestanden!${NC}\n"
    exit 0
else
    echo -e "\n${RED}${BOLD}✗ Einige Tests sind fehlgeschlagen${NC}\n"
    exit 1
fi
