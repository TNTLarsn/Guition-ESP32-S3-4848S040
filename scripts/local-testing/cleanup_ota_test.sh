#!/bin/bash

##############################################################################
# Local Dev Cleanup - Zurück zum Normalzustand
# 
# Workflow:
# 1. HTTP-Server stoppen
# 2. core.yaml wiederherstellen
# 3. Firmware mit GitHub-URL kompilieren
# 4. Finales OTA-Update zurück zu GitHub-URL
# 5. State-Datei löschen
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
CORE_YAML="${PROJECT_DIR}/src/common/core.yaml"
MAIN_YAML="${PROJECT_DIR}/src/main.yaml"
HTTP_PORT=8000
ESPHOME="${ESPHOME_CMD:-$PROJECT_DIR/scripts/dev/esphome}"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          🧹 Local Dev Cleanup                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# State laden falls vorhanden
DEVICE_IP=""
if [ -f "$STATE_FILE" ]; then
    source "$STATE_FILE"
    echo -e "${GREEN}✅ State geladen${NC}"
    echo "   • Device: $DEVICE_IP"
    echo ""
fi

# ============================================================================
# 1. HTTP-Server stoppen
# ============================================================================
echo -e "${YELLOW}📍 Schritt 1: HTTP-Server stoppen...${NC}"

HTTP_PID=$(lsof -Pi :$HTTP_PORT -sTCP:LISTEN -t 2>/dev/null || true)
if [ -n "$HTTP_PID" ]; then
    kill $HTTP_PID 2>/dev/null || true
    sleep 1
    echo -e "${GREEN}✅ HTTP-Server gestoppt (PID: $HTTP_PID)${NC}"
else
    echo "   → Kein HTTP-Server aktiv"
fi
echo ""

# ============================================================================
# 2. core.yaml und main.yaml wiederherstellen
# ============================================================================
echo -e "${YELLOW}📍 Schritt 2: Konfigurationsdateien wiederherstellen...${NC}"

if [ -n "${ORIGINAL_SOURCE_URL:-}" ]; then
    # Nur die URL ersetzen, Rest der Datei bleibt unverändert
    sed -i '' "s|source: http://[^/]*/manifest.json|source: $ORIGINAL_SOURCE_URL|g" "$CORE_YAML"
    echo -e "${GREEN}✅ update.source wiederhergestellt${NC}"
    echo "   → URL: $ORIGINAL_SOURCE_URL"
else
    # Fallback: Standard GitHub-URL verwenden
    GITHUB_URL='https://github.com/tntlarsn/guition-esp32-s3-4848s040/releases/latest/download/\${display_name}.manifest.json'
    sed -i '' "s|source: http://[^/]*/manifest.json|source: $GITHUB_URL|g" "$CORE_YAML"
    echo -e "${GREEN}✅ update.source auf GitHub-URL zurückgesetzt${NC}"
fi

# Wechsle homeassistant include zurück zur normalen Version
if grep -q "homeassistant: !include common/homeassistant_dev.yaml" "$MAIN_YAML"; then
    sed -i '' "s|homeassistant: !include common/homeassistant_dev.yaml|homeassistant: !include common/homeassistant.yaml|g" "$MAIN_YAML"
    echo -e "${GREEN}✅ main.yaml → homeassistant.yaml${NC}"
else
    echo "   → homeassistant bereits auf Normalzustand"
fi
echo ""

# ============================================================================
# 3. Firmware mit GitHub-URL kompilieren
# ============================================================================
echo -e "${YELLOW}📍 Schritt 3: Firmware kompilieren (GitHub-URL)...${NC}"

cd "$PROJECT_DIR"
if ! "$ESPHOME" compile src/main.yaml > /tmp/compile.log 2>&1; then
    echo -e "${RED}❌ Build fehlgeschlagen${NC}"
    tail -20 /tmp/compile.log
    exit 1
fi
echo -e "${GREEN}✅ Firmware kompiliert${NC}"
echo ""

# ============================================================================
# 4. Finales OTA-Update (zurück zu GitHub-URL)
# ============================================================================
if [ -n "$DEVICE_IP" ]; then
    echo -e "${YELLOW}📍 Schritt 4: Firmware auf Gerät flashen...${NC}"
    echo "   → $ESPHOME upload src/main.yaml --device $DEVICE_IP"
    echo ""
    
    if "$ESPHOME" upload src/main.yaml --device "$DEVICE_IP"; then
        echo ""
        echo -e "${GREEN}✅ Firmware geflasht${NC}"
    else
        echo -e "${YELLOW}⚠️  Flash fehlgeschlagen, manuell ausführen:${NC}"
        echo "   $ESPHOME upload src/main.yaml --device $DEVICE_IP"
    fi
else
    echo -e "${YELLOW}📍 Schritt 4: Manuelles Flash erforderlich${NC}"
    echo "   $ESPHOME upload src/main.yaml --device <DEVICE_IP>"
fi
echo ""

# ============================================================================
# 5. State-Datei löschen
# ============================================================================
echo -e "${YELLOW}📍 Schritt 5: Aufräumen...${NC}"

if [ -f "$STATE_FILE" ]; then
    rm "$STATE_FILE"
    echo "   → State-Datei gelöscht"
fi

# Temporäre Dateien
rm -f /tmp/compile.log /tmp/http_server.log 2>/dev/null || true

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         ✅ Cleanup abgeschlossen!                          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Das Gerät ist wieder im Normalzustand.${NC}"
echo "   • Update-URL: GitHub Releases"
echo ""
