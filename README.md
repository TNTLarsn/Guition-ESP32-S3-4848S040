# Guition ESP32-S3-4848S040 Display - ESPHome Firmware

ESPHome-Firmware für das Guition ESP32-S3-4848S040 Display-Board mit 480x480
Pixel LCD und kapazitivem Touchscreen.

[![CI][ci-badge]][ci-workflow]
[![Publish Firmware][publish-badge]][publish-workflow]

## 🎯 Features

- **ESP32-S3 Mikrocontroller** mit ESP-IDF Framework
- **4.8" LCD Display** (480x480 Pixel, ST7701S Treiber)
- **Kapazitiver Touchscreen** (GT911, I2C)
- **LVGL Integration** für moderne Benutzeroberflächen
- **OTA Updates** via HTTP Request und ESPHome Dashboard
- **WiFi Provisioning** über Bluetooth LE oder Captive Portal
- **Home Assistant Integration** via Native API
- **Web-basierte Installation** mit ESP Web Tools (kein Tool-Download nötig)

## 📦 Hardware-Spezifikationen

| Komponente | Details |
| ---------- | ------- |
| **MCU** | ESP32-S3 (Dual-Core, 240 MHz) |
| **Flash** | 16 MB |
| **PSRAM** | Octal PSRAM @ 80 MHz |
| **Display** | 4.8" RGB LCD, 480x480 px |
| **Touch** | GT911 (I2C, 100 kHz) |
| **Backlight** | LEDC PWM @ 100 Hz |

## 🚀 Schnellstart

### Option 1: Web-Installation (empfohlen)

1. Besuche die Installations-Webseite ([Web-Installer][web-installer])
2. Verbinde das Display per USB mit deinem Computer
3. Klicke auf "Install" und folge den Anweisungen
4. Konfiguriere WiFi über das Captive Portal

### Option 2: ESPHome Dashboard

```bash
# YAML-Datei validieren
esphome config src/main.factory.yaml

# Firmware kompilieren und flashen
esphome run src/main.factory.yaml
```

### Option 3: Home Assistant Add-on

1. Öffne ESPHome im Home Assistant
2. Klicke auf "+ NEW DEVICE"
3. Wähle "Install from URL"
4. Gib ein:
      `github://tntlarsn/Guition-ESP32-S3-4848S040/src/main.yaml@main`

## 📁 Projekt-Struktur

```text
├── src/
│   ├── main.yaml              # Basis-Konfiguration (nach Adoption)
│   ├── main.factory.yaml      # Factory-Version mit Provisioning
│   └── common/
│       ├── core.yaml          # Hardware-Konfiguration
│       └── substitutions.yaml # Projekt-Variablen
├── .github/workflows/
│   ├── ci.yml                 # Automatische Tests bei PRs
│   ├── publish-firmware.yml   # Release-Builds
│   └── publish-pages.yml      # GitHub Pages Deployment
└── static/                    # Web-Installation (ESP Web Tools)
```

## 🛠️ Entwicklung

### Lokale Tests

```bash
# Python-Skript (empfohlen)
python3 test_ci.py

# Makefile (schnellste Option)
make test

# Bash-Skript
bash test_ci.sh
```

Details siehe [LOCAL_TESTING.md](LOCAL_TESTING.md).

### Häufige Änderungen

| Änderung | Datei | Zeilen |
| --------- | ------- | -------- |
| Display-Parameter | [core.yaml](src/common/core.yaml#L87-L124) | 87-124 |
| Touch-Kalibrierung | [core.yaml](src/common/core.yaml#L56-L63) | 56-63 |
| Backlight-Timeout | [core.yaml](src/common/core.yaml#L171-L183) | 171-183 |
| Projektversion | [substitutions.yaml](src/common/substitutions.yaml) | 2-5 |

### Build & Flash

```bash
# Firmware kompilieren
make compile

# Auf Gerät flashen (Port: /dev/cu.usbserial-110)
make flash

# Logs anzeigen
make monitor

# Build-Cache löschen
make clean
```

Hinweise zum Flash:

- Beim Target `make flash` wird der Chipspeicher vor dem Upload mit `esptool.py` vollständig gelöscht (`erase_flash`).
- Voraussetzung: `esptool.py` ist installiert (z. B. via `pip install esptool`).
- Standard-Port: `/dev/cu.usbserial-110` (Passe ihn im [Makefile](Makefile) an, falls dein Gerät einen anderen Port nutzt.)

## 🔧 Konfiguration

### YAML-Hierarchie (Package-System)

```yaml
main.factory.yaml          # Factory mit improv_serial
  └── includes main.yaml   # Basis-Config
        └── includes common/core.yaml  # Hardware-Config
              └── includes common/substitutions.yaml
```

### Wichtige Einstellungen

#### Display (ST7701S)

- PCLK-Frequenz: 12 MHz (optimal, höhere Werte verursachen Flackern)
- Update-Intervall: `never` (LVGL übernimmt Rendering)
- 16-Bit RGB-Parallelbus

#### Touchscreen (GT911)

- I2C-Frequenz: 100 kHz (reduziert Ghost-Touches)
- Direkt mit LVGL verknüpft

#### LVGL Idle Handling

- Timeout: Konfigurierbar über `display_timeout_backlight`
- Bei Idle: Backlight aus + LVGL pausiert
- Bei Touch: LVGL resume + Backlight ein

## 📝 Release-Prozess

1. Tag erstellen: `git tag v1.0.0 && git push --tags`
2. GitHub Actions baut automatisch die Firmware
3. Manifest-Datei wird zum Release hochgeladen
4. Web-Installation aktualisiert sich automatisch

## 🔗 Integration

- **Home Assistant**: Native API (verschlüsselt)
- **OTA-Updates**: Dual-Path (ESPHome + HTTP Request)
- **WiFi-Provisioning**: Improv Serial + Captive Portal
- **Web-Flash**: ESP Web Tools via GitHub Pages

## 📚 Dokumentation

- [Local Testing Guide](LOCAL_TESTING.md) - Lokale Test-Optionen
- [ESPHome Documentation](https://esphome.io) - Offizielle ESPHome-Docs

## 🤝 Beiträge

Contributions sind willkommen! Bitte:

1. Forke das Repository
2. Erstelle einen Feature-Branch (`git checkout -b feature/amazing-feature`)
3. Teste lokal mit `make test`
4. Commit deine Änderungen (`git commit -m 'Add amazing feature'`)
5. Push zum Branch (`git push origin feature/amazing-feature`)
6. Öffne einen Pull Request

## 📄 Lizenz

Dieses Projekt ist Open Source. Details zur Lizenzierung findest du in der
LICENSE-Datei.

## 🙏 Danksagungen

- [ESPHome](https://esphome.io) - Das Framework hinter diesem Projekt
- [ESP Web Tools](https://esphome.github.io/esp-web-tools/) - Web-basierte
      Installation
- Guition für das Hardware-Design

## 🐛 Probleme melden

Probleme oder Feature-Requests? Bitte öffne ein
[Issue](https://github.com/tntlarsn/Guition-ESP32-S3-4848S040/issues).

---

**Hinweis**: Dieses Projekt nutzt das ESP-IDF Framework (nicht Arduino).
Stelle sicher, dass deine ESPHome-Version mindestens 2025.12.7 ist.

<!-- markdownlint-disable-next-line MD013 -->
[ci-badge]: https://github.com/TNTLarsn/Guition-ESP32-S3-4848S040/actions/workflows/ci.yml/badge.svg
<!-- markdownlint-disable-next-line MD013 -->
[ci-workflow]: https://github.com/TNTLarsn/Guition-ESP32-S3-4848S040/actions/workflows/ci.yml
<!-- markdownlint-disable-next-line MD013 -->
[publish-badge]: https://github.com/TNTLarsn/Guition-ESP32-S3-4848S040/actions/workflows/publish-firmware.yml/badge.svg
<!-- markdownlint-disable-next-line MD013 -->
[publish-workflow]: https://github.com/TNTLarsn/Guition-ESP32-S3-4848S040/actions/workflows/publish-firmware.yml
[web-installer]: https://TNTLarsn.github.io/Guition-ESP32-S3-4848S040/
