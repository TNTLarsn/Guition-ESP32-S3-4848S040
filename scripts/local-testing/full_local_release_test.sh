#!/bin/bash

##############################################################################
# Local Dev Mode - Gerät in lokalen Entwicklungsmodus versetzen
# 
# Workflow:
# 1. PC-IP erkennen
# 2. Device-IP ermitteln
# 3. core.yaml mit lokaler URL patchen
# 4. Firmware kompilieren
# 5. Erstes OTA-Update durchführen (esphome run)
# 6. HTTP-Server starten
# 7. Fertig! Gerät ist im lokalen Modus
#
# Usage: bash full_local_release_test.sh [device-ip]
# Beispiel: bash full_local_release_test.sh 192.168.178.150
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
HTTP_PORT=8000
DEVICE_IP="${1:-}"
CORE_YAML="${PROJECT_DIR}/src/common/core.yaml"
MAIN_YAML="${PROJECT_DIR}/src/main.yaml"
STATE_FILE="${PROJECT_DIR}/.local_dev_state"
ESPHOME="${ESPHOME_CMD:-$PROJECT_DIR/scripts/dev/esphome}"
ESPHOME_PROFILE_OVERRIDE="${ESPHOME_PROFILE:-}"

run_esphome() {
    if [ -n "$ESPHOME_PROFILE_OVERRIDE" ]; then
        ESPHOME_PROFILE="$ESPHOME_PROFILE_OVERRIDE" "$ESPHOME" "$@"
    else
        "$ESPHOME" "$@"
    fi
}

is_valid_ipv4() {
    local ip="$1"
    local IFS='.'
    local -a octets

    # Schnellcheck fuer Format n.n.n.n
    [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1

    read -r -a octets <<< "$ip"
    [ "${#octets[@]}" -eq 4 ] || return 1

    for octet in "${octets[@]}"; do
        # Keine negativen Werte, keine >255
        [ "$octet" -ge 0 ] 2>/dev/null || return 1
        [ "$octet" -le 255 ] || return 1
    done

    return 0
}

# ============================================================================
# Sicherheits-Guard: Local Dev Mode nicht erneut starten
# ============================================================================
if [ -f "$STATE_FILE" ] && [ "${FORCE:-0}" != "1" ]; then
    echo -e "${RED}❌ Local Dev Mode ist bereits aktiv (State-Datei vorhanden).${NC}"
    echo "   Datei: $STATE_FILE"
    echo ""
    echo "   Bitte zuerst Cleanup ausführen:"
    echo "     make localcleanup"
    echo ""
    echo "   Falls du es wirklich erzwingen willst (nicht empfohlen):"
    echo "     FORCE=1 make local-release-test <DEVICE_IP>"
    exit 2
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          🚀 Local Dev Mode - Setup                         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# 1. PC-IP automatisch erkennen
# ============================================================================
echo -e "${YELLOW}📍 Schritt 1: PC-IP erkennen...${NC}"
PC_IP=$(ifconfig | grep -E "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')

if [ -z "$PC_IP" ]; then
    echo -e "${RED}❌ Konnte PC-IP nicht erkennen${NC}"
    read -p "   Gib deine PC-IP ein: " PC_IP
fi

if [ -z "$PC_IP" ]; then
    echo -e "${RED}❌ PC-IP erforderlich!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ PC-IP: $PC_IP${NC}"
echo ""

# ============================================================================
# 2. Device-IP ermitteln
# ============================================================================
echo -e "${YELLOW}📍 Schritt 2: Device-IP ermitteln...${NC}"

if [ -z "$DEVICE_IP" ]; then
    # Versuche mDNS
    DEVICE_IP=$(timeout 2 ping -c 1 display01.local 2>/dev/null | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1 || true)
fi

# Falls kein valider mDNS-Treffer vorliegt, interaktiv sauber abfragen
while ! is_valid_ipv4 "$DEVICE_IP"; do
    if [ -n "$DEVICE_IP" ]; then
        echo -e "${RED}❌ Ungueltige Device-IP: '$DEVICE_IP'${NC}"
        echo "   Bitte eine IPv4-Adresse im Format 192.168.x.x eingeben."
    fi
    read -p "   Gib die Device-IP ein (z.B. 192.168.178.150): " DEVICE_IP
done

echo -e "${GREEN}✅ Device-IP: $DEVICE_IP${NC}"
echo ""

# ============================================================================
# 3. core.yaml und main.yaml patchen
# ============================================================================
echo -e "${YELLOW}📍 Schritt 3: Konfigurationsdateien patchen...${NC}"

# Originale URL extrahieren und speichern (nur beim ersten Mal)
if [ -z "${ORIGINAL_SOURCE_URL:-}" ]; then
    ORIGINAL_SOURCE_URL=$(grep -E '^\s+source:' "$CORE_YAML" | head -1 | sed 's/.*source: //')
    echo "   → Originale update.source URL: $ORIGINAL_SOURCE_URL"
fi

# Ersetze URL mit lokaler URL
if ! grep -q "source: http://$PC_IP:$HTTP_PORT/manifest.json" "$CORE_YAML"; then
    sed -i '' "s|source: .*manifest.json|source: http://$PC_IP:$HTTP_PORT/manifest.json|g" "$CORE_YAML"
    echo -e "${GREEN}✅ core.yaml → lokale update.source URL${NC}"
else
    echo "   → update.source bereits konfiguriert"
fi

# Prüfe ob homeassistant_dev.yaml existiert, sonst erstellen
HA_DEV_YAML="${PROJECT_DIR}/src/common/homeassistant_dev.yaml"
HA_YAML="${PROJECT_DIR}/src/common/homeassistant.yaml"

if [ ! -f "$HA_DEV_YAML" ]; then
    cp "$HA_YAML" "$HA_DEV_YAML"
    echo -e "${GREEN}✅ homeassistant_dev.yaml erstellt (Kopie von homeassistant.yaml)${NC}"
else
    echo "   → homeassistant_dev.yaml existiert bereits"
fi

# Wechsle homeassistant include zu dev-Version
if grep -q "homeassistant: !include common/homeassistant.yaml" "$MAIN_YAML"; then
    sed -i '' "s|homeassistant: !include common/homeassistant.yaml|homeassistant: !include common/homeassistant_dev.yaml|g" "$MAIN_YAML"
    echo -e "${GREEN}✅ main.yaml → homeassistant_dev.yaml${NC}"
else
    echo "   → homeassistant_dev bereits konfiguriert"
fi
echo ""

# ============================================================================
# 4. Firmware kompilieren
# ============================================================================
echo -e "${YELLOW}📍 Schritt 4: Firmware kompilieren...${NC}"

cd "$PROJECT_DIR"
if ! run_esphome compile src/main.yaml > /tmp/compile.log 2>&1; then
    if grep -q "esp_hal_ieee802154.*unknown name" /tmp/compile.log && [ -z "$ESPHOME_PROFILE_OVERRIDE" ] && [ -x "$PROJECT_DIR/.esphome-venvs/beta/bin/esphome" ]; then
        echo -e "${YELLOW}⚠️  Stable-Profil Build-Bug erkannt (esp_hal_ieee802154). Wechsle automatisch auf ESPHome Beta...${NC}"
        ESPHOME_PROFILE_OVERRIDE="beta"
        if ! run_esphome compile src/main.yaml > /tmp/compile.log 2>&1; then
            echo -e "${RED}❌ Build fehlgeschlagen (auch mit Beta-Fallback)${NC}"
            tail -20 /tmp/compile.log
            exit 1
        fi
        echo -e "${GREEN}✅ Firmware kompiliert (Beta-Fallback aktiv)${NC}"
    else
        echo -e "${RED}❌ Build fehlgeschlagen${NC}"
        tail -20 /tmp/compile.log
        exit 1
    fi
else
    echo -e "${GREEN}✅ Firmware kompiliert${NC}"
fi
echo ""

# ============================================================================
# 5. Erstes OTA-Update durchführen
# ============================================================================
echo -e "${YELLOW}📍 Schritt 5: Firmware auf Gerät flashen...${NC}"
echo "   → $ESPHOME upload src/main.yaml --device $DEVICE_IP"
echo ""

if ! run_esphome upload src/main.yaml --device "$DEVICE_IP"; then
    echo -e "${RED}❌ Flash fehlgeschlagen${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Firmware geflasht, warte auf Reboot...${NC}"
sleep 10
echo ""

# ============================================================================
# 6. HTTP-Server starten + manifest.json erstellen
# ============================================================================
echo -e "${YELLOW}📍 Schritt 6: HTTP-Server starten...${NC}"

# Build-Verzeichnis
BUILD_DIR="${PROJECT_DIR}/src/.esphome/build/display01"
PIOENV_DIR="${BUILD_DIR}/.pioenvs/display01"
mkdir -p "$BUILD_DIR"

# Firmware-Dateien aus dem Build-Verzeichnis kopieren
# ESPHome nutzt je nach Version entweder build/ oder .pioenvs/display01/
OTA_SOURCE=""
FACTORY_SOURCE=""

for candidate in \
    "${BUILD_DIR}/firmware.ota.bin" \
    "${BUILD_DIR}/build/firmware.ota.bin" \
    "${PIOENV_DIR}/firmware.ota.bin"; do
    if [ -f "$candidate" ]; then
        OTA_SOURCE="$candidate"
        break
    fi
done

for candidate in \
    "${BUILD_DIR}/firmware.factory.bin" \
    "${BUILD_DIR}/build/firmware.factory.bin" \
    "${PIOENV_DIR}/firmware.factory.bin"; do
    if [ -f "$candidate" ]; then
        FACTORY_SOURCE="$candidate"
        break
    fi
done

if [ -n "$OTA_SOURCE" ]; then
    cp "$OTA_SOURCE" "${BUILD_DIR}/firmware.ota.bin"
    echo "   → firmware.ota.bin kopiert"
fi
if [ -n "$FACTORY_SOURCE" ]; then
    cp "$FACTORY_SOURCE" "${BUILD_DIR}/firmware.factory.bin"
    echo "   → firmware.factory.bin kopiert"
fi

# Checksummen berechnen
OTA_MD5=$(md5sum "${BUILD_DIR}/firmware.ota.bin" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
OTA_SHA256=$(shasum -a 256 "${BUILD_DIR}/firmware.ota.bin" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
FACTORY_MD5=$(md5sum "${BUILD_DIR}/firmware.factory.bin" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
FACTORY_SHA256=$(shasum -a 256 "${BUILD_DIR}/firmware.factory.bin" 2>/dev/null | cut -d' ' -f1 || echo "unknown")

# manifest.json erstellen
cat > "${BUILD_DIR}/manifest.json" << EOF
{
  "name": "tnt_larsn.esphome_display",
  "version": "LOCAL_DEV",
  "home_assistant_domain": "esphome",
  "new_install_prompt_erase": false,
  "builds": [
    {
      "chipFamily": "ESP32-S3",
      "ota": {
        "path": "firmware.ota.bin",
        "md5": "$OTA_MD5",
        "sha256": "$OTA_SHA256",
        "summary": "🧪 Local Dev Build",
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

# HTTP-Server starten (falls nicht bereits läuft)
if ! lsof -Pi :$HTTP_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    cd "$BUILD_DIR"
    python3 -m http.server $HTTP_PORT > /tmp/http_server.log 2>&1 &
    HTTP_PID=$!
    sleep 2
    echo -e "${GREEN}✅ HTTP-Server gestartet (PID: $HTTP_PID)${NC}"
else
    HTTP_PID=$(lsof -Pi :$HTTP_PORT -sTCP:LISTEN -t | head -1)
    echo "   → HTTP-Server läuft bereits (PID: $HTTP_PID)"
fi

# State speichern (inkl. originaler URL für Cleanup)
# WICHTIG: Einfache Anführungszeichen für ORIGINAL_SOURCE_URL um ${display_name} literal zu erhalten!
echo "PC_IP=$PC_IP" > "$STATE_FILE"
echo "DEVICE_IP=$DEVICE_IP" >> "$STATE_FILE"
echo "HTTP_PID=$HTTP_PID" >> "$STATE_FILE"
echo "HTTP_PORT=$HTTP_PORT" >> "$STATE_FILE"
echo 'ORIGINAL_SOURCE_URL='"'$ORIGINAL_SOURCE_URL'" >> "$STATE_FILE"

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         🎉 Local Dev Mode AKTIV!                           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Das Gerät ist jetzt im lokalen Entwicklungsmodus!${NC}"
echo ""
echo -e "${YELLOW}📝 Iterativer Workflow:${NC}"
echo "   1. Code ändern (z.B. src/pages/home.yaml)"
echo "   2. make localupdate"
echo "   3. Home Assistant → ESPHome → display01 → 'Update'"
echo "   4. Wiederholen..."
echo ""
echo -e "${YELLOW}📊 Infos:${NC}"
echo "   • Device: $DEVICE_IP"
echo "   • HTTP-Server: http://$PC_IP:$HTTP_PORT"
echo "   • Manifest: http://$PC_IP:$HTTP_PORT/manifest.json"
echo ""
echo -e "${YELLOW}🧹 Cleanup (zurück zum Normalzustand):${NC}"
echo "   make localcleanup"
echo ""
