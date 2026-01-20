#!/bin/bash

##############################################################################
# Local Update - Iterativ neue Firmware bereitstellen
# 
# Voraussetzung: Device bereits im Local Dev Mode (make local-release-test)
# 
# Workflow:
# 1. Firmware neu kompilieren
# 2. manifest.json aktualisieren
# 3. Fertig! Update im Home Assistant Dashboard verfügbar
##############################################################################

set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Konfiguration - PROJECT_DIR ist das Git-Root (2 Ebenen hoch)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
STATE_FILE="${PROJECT_DIR}/.local_dev_state"
HTTP_PORT=8000

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          📦 Local Update - Neue Firmware                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# Prüfe ob Local Dev Mode aktiv ist
# ============================================================================
if [ ! -f "$STATE_FILE" ]; then
    echo -e "${RED}❌ Local Dev Mode nicht aktiv!${NC}"
    echo ""
    echo "   Starte zuerst: make local-release-test"
    exit 1
fi

# State laden
source "$STATE_FILE"

echo -e "${GREEN}✅ Local Dev Mode aktiv${NC}"
echo "   • Device: $DEVICE_IP"
echo "   • HTTP-Server: http://$PC_IP:$HTTP_PORT"
echo ""

# ============================================================================
# 1. Firmware kompilieren
# ============================================================================
echo -e "${YELLOW}📍 Schritt 1: Firmware kompilieren...${NC}"

cd "$PROJECT_DIR"
if ! esphome compile src/main.yaml > /tmp/compile.log 2>&1; then
    echo -e "${RED}❌ Build fehlgeschlagen${NC}"
    tail -20 /tmp/compile.log
    exit 1
fi
echo -e "${GREEN}✅ Firmware kompiliert${NC}"
echo ""

# ============================================================================
# 2. Firmware-Dateien kopieren & manifest.json aktualisieren
# ============================================================================
echo -e "${YELLOW}📍 Schritt 2: Firmware-Dateien aktualisieren...${NC}"

BUILD_DIR="${PROJECT_DIR}/src/.esphome/build/display01"
PIOENV_DIR="${BUILD_DIR}/.pioenvs/display01"
mkdir -p "$BUILD_DIR"

# Firmware-Dateien aus dem PlatformIO Build-Verzeichnis kopieren
# WICHTIG: Die neuste kompilierte Firmware liegt in .pioenvs/display01/
if [ -f "${PIOENV_DIR}/firmware.ota.bin" ]; then
    cp "${PIOENV_DIR}/firmware.ota.bin" "${BUILD_DIR}/firmware.ota.bin"
    echo "   → firmware.ota.bin aktualisiert"
else
    echo -e "${RED}❌ firmware.ota.bin nicht gefunden!${NC}"
    exit 1
fi

if [ -f "${PIOENV_DIR}/firmware.factory.bin" ]; then
    cp "${PIOENV_DIR}/firmware.factory.bin" "${BUILD_DIR}/firmware.factory.bin"
    echo "   → firmware.factory.bin aktualisiert"
fi

# Checksummen berechnen
OTA_MD5=$(md5sum "${BUILD_DIR}/firmware.ota.bin" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
OTA_SHA256=$(shasum -a 256 "${BUILD_DIR}/firmware.ota.bin" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
FACTORY_MD5=$(md5sum "${BUILD_DIR}/firmware.factory.bin" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
FACTORY_SHA256=$(shasum -a 256 "${BUILD_DIR}/firmware.factory.bin" 2>/dev/null | cut -d' ' -f1 || echo "unknown")

# Timestamp für Version
TIMESTAMP=$(date +%H%M%S)

# manifest.json erstellen
cat > "${BUILD_DIR}/manifest.json" << EOF
{
  "name": "tnt_larsn.esphome_display",
  "version": "LOCAL_DEV_$TIMESTAMP",
  "home_assistant_domain": "esphome",
  "new_install_prompt_erase": false,
  "builds": [
    {
      "chipFamily": "ESP32-S3",
      "ota": {
        "path": "firmware.ota.bin",
        "md5": "$OTA_MD5",
        "sha256": "$OTA_SHA256",
        "summary": "🧪 Local Dev Build ($TIMESTAMP)",
        "release_url": "http://$PC_IP:$HTTP_PORT/firmware.ota.bin"
      },
      "parts": [
        {
          "path": "firmware.factory.bin",
          "offset": 0,
          "md5": "$FACTORY_MD5",
          "sha256": "$FACTORY_SHA256"
        }
      ]
    }
  ]
}
EOF

echo -e "${GREEN}✅ manifest.json aktualisiert (Version: LOCAL_DEV_$TIMESTAMP)${NC}"
echo ""

# ============================================================================
# Fertig!
# ============================================================================
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         🎉 Update bereit!                                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Nächster Schritt:${NC}"
echo "   Home Assistant → ESPHome → display01 → 'Firmware aktualisieren'"
echo ""
echo -e "${YELLOW}📊 Infos:${NC}"
echo "   • Version: LOCAL_DEV_$TIMESTAMP"
echo "   • Manifest: http://$PC_IP:$HTTP_PORT/manifest.json"
echo ""
