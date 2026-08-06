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
- **Multi-Page UI** - Home, Switches, Temperaturen mit Navigation
- **Dynamische Jahreszeiten-Hintergrundbilder** - Automatische Bildwechsel basierend auf Jahreszeit
- **Automatische Domain-Icons** - Icons basierend auf Home Assistant Entity-Domain
- **Dynamische MDI Icons** - Automatische Icon-Konvertierung (~190 unterstützte Icons)
- **Deutsche Lokalisierung** - Datum, Wochentage, Monate in Deutsch
- **Home Assistant Integration** - Dynamische Labels, Icons und States via Native API
- **OTA Updates** via HTTP Request und ESPHome Dashboard
- **WiFi Provisioning** über Improv Serial (USB) und Captive Portal
- **Web-basierte Installation** mit ESP Web Tools
- **Integriertes 240V Relais** - Schaltbarer Relaisausgang

## 📦 Hardware-Spezifikationen

| Komponente | Details |
| ---------- | ------- |
| **MCU** | ESP32-S3 (Dual-Core, 240 MHz) |
| **Flash** | 16 MB |
| **PSRAM** | Octal PSRAM @ 80 MHz |
| **Display** | 4.8" RGB LCD, 480x480 px |
| **Touch** | GT911 (I2C, 100 kHz) |
| **Backlight** | LEDC PWM @ 100 Hz |
| **Relais** | 240V, GPIO40 |

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
│   ├── assets/
│   │   ├── fonts/             # Custom Fonts
│   │   └── images/            # Jahreszeiten-Hintergrundbilder
│   ├── common/
│   │   ├── core.yaml          # Hardware-Konfiguration
│   │   ├── substitutions.yaml # Projekt-Variablen
│   │   ├── fonts.yaml         # Font-Definitionen inkl. MDI Icons
│   │   ├── homeassistant.yaml # Home Assistant Entity-Definitionen
│   │   ├── image.yaml         # Bild-Definitionen
│   │   └── colors.yaml        # Farbdefinitionen
│   ├── helper/
│   │   ├── mdi_icon_map.h     # MDI Icon zu Unicode Konverter
│   │   └── datetime_helper.h  # Deutsche Datums-/Zeitformatierung
│   ├── pages/
│   │   ├── boot.yaml          # Boot-Screen
│   │   ├── home.yaml          # Hauptseite mit Wetter
│   │   ├── switches.yaml      # Schalter-Seite
│   │   ├── temperatures.yaml  # Temperatur-Übersicht
│   │   ├── navigation.yaml    # Navigationsleiste
│   │   └── ota.yaml           # OTA-Update Seite
│   ├── templates/             # Wiederverwendbare YAML-Templates
│   │   ├── ha_button.yaml     # Template: LVGL Button Widget
│   │   ├── ha_button_entity.yaml # Template: Button mit HA Entity
│   │   ├── ha_entity.yaml     # Template: HA Entity Sensoren
│   │   ├── ha_season_sensor.yaml # Template: Jahreszeit-Sensor
│   │   ├── ha_sensor.yaml     # Template: HA Sensor
│   │   ├── ha_temp.yaml       # Template: Temperatur-Anzeige
│   │   ├── ha_temp_sensor.yaml # Template: Temperatur-Sensor
│   │   └── ha_weather.yaml    # Template: Wetter-Entity
│   └── themes/
│       ├── modern.yaml        # Modernes Theme (Standard)
│       └── homeassistant.yaml # Home Assistant Theme
├── tests/
│   └── simulator/             # SDL-Simulator für UI-Testing
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
python3 scripts/test_ci.py

# Makefile (schnellste Option)
make test

# Bash-Skript
bash scripts/test_ci.sh
```

Details siehe [LOCAL_TESTING.md](LOCAL_TESTING.md).

### SDL Simulator (UI-Testing ohne Hardware)

```bash
# Simulator kompilieren und starten
esphome run tests/simulator/main.simulator.yaml

# Oder via VS Code Task: "🖥️ Simulator starten"
```

### Häufige Änderungen

| Änderung | Datei |
| --------- | ------- |
| Display-Parameter | [core.yaml](src/common/core.yaml) (ST7701S-Config) |
| Touch-Kalibrierung | [core.yaml](src/common/core.yaml) (GT911 transform) |
| Backlight-Timeout | [core.yaml](src/common/core.yaml) (Number-Component) |
| Projektversion | [substitutions.yaml](src/common/substitutions.yaml) |
| Home Assistant Entities | [homeassistant.yaml](src/common/homeassistant.yaml) |

### Build & Flash

```bash
# Firmware kompilieren
make compile

# Auf Gerät flashen (USB, mit Flash-Erase)
make flash

# Firmware updaten (USB, ohne Erase)
make update

# Logs anzeigen
make monitor

# Build-Cache löschen
make clean
```

### Local Dev Mode

Für iterative Entwicklung ohne GitHub Release:

```bash
# Gerät in Local Dev Mode versetzen
make local-release-test [DEVICE-IP]

# Nach Code-Änderungen: Neue Firmware bereitstellen
make localupdate

# Zurück zum Normalzustand
make localcleanup
```

Detaillierte Anleitung: [LOCAL_TESTING.md](LOCAL_TESTING.md)

## 🔧 Konfiguration

### YAML-Hierarchie (Package-System)

```yaml
main.factory.yaml          # Factory mit improv_serial & dashboard_import
  └── includes main.yaml   # Basis-Config mit allen Pages
        └── includes common/core.yaml      # Hardware-Config
        └── includes common/homeassistant.yaml  # HA Entities
        └── includes pages/*.yaml          # UI Pages
        └── includes themes/modern.yaml    # Theme
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

- Timeout: Konfigurierbar über `display_timeout_backlight` (-1-720 Minuten, `-1` deaktiviert Idle-Handling)
- Bei Idle (Wert >= 0): Backlight aus + LVGL pausiert nach Ablauf des Timeouts
- Bei Touch: LVGL resume + Backlight ein
- Antiburn-Modus: Automatisch jeweils von 2:05–2:35, 3:05–3:35, 4:05–4:35 und 5:05–5:35 Uhr aktiv

## 🏠 Home Assistant Integration

### Template-basierte Architektur

Das Projekt nutzt ESPHome's "Packages as Templates" Pattern für maximale
Wiederverwendbarkeit:

```text
templates/
├── ha_entity.yaml        # Binary Sensor + Text Sensoren für Entities
├── ha_button.yaml        # LVGL Button Widget
├── ha_sensor.yaml        # Sensor-Template (ohne UI-Button)
├── ha_temp_sensor.yaml   # Temperatur-Sensor mit dynamischer Icon-Farbe
├── ha_weather.yaml       # Wetter-Entity Template
└── ha_season_sensor.yaml # Jahreszeit-Sensor (steuert Hintergrundbilder)
```

### Entity-Template (`ha_entity.yaml`)

Jedes Template-Include erstellt automatisch:

- **binary_sensor**: State der Entität (für Button checked-State)
- **text_sensor (friendly_name)**: Dynamisches Label aus Home Assistant
- **text_sensor (icon)**: Dynamisches Icon aus HA oder Domain-Default

**Icon-Priorität:**

1. Custom Icon aus Home Assistant (wenn manuell gesetzt)
2. Domain-Default Icon (automatisch basierend auf Entity-Domain)
3. Fallback: `help-circle`

### Konfigurierbare Entitäten

Ändere die Home Assistant Entitäten in [homeassistant.yaml](src/common/homeassistant.yaml):

```yaml
packages:
  ha_entity_1: !include
    file: ../templates/ha_entity.yaml
    vars:
      num: "1"
      entity_id: switch.wohnzimmer_licht  # → Icon: toggle-switch-variant
  ha_sensor_9: !include
    file: ../templates/ha_temp_sensor.yaml
    vars:
      num: "9"
      entity_id: sensor.temperatur_bad
```

### MDI Icon Konvertierung

Der `MdiIconHelper` in [mdi_icon_map.h](src/helper/mdi_icon_map.h) konvertiert
Home Assistant Icon-Namen zu Unicode-Codepoints:

**Unterstützte Icons**: ~190 häufig verwendete MDI Icons (Lichter, Schalter, Heizung,
Jalousien, Sensoren, Media, Wetter, etc.)

### Dynamische Jahreszeiten-Hintergrundbilder

Das System wechselt automatisch das Hintergrundbild basierend auf der aktuellen Jahreszeit:

| Jahreszeit | Bild |
| ---------- | ------ |
| Frühling | `see_spring.png` |
| Sommer | `see_summer.png` |
| Herbst | `see_autumn.png` |
| Winter | `see_winter.png` |

Gesteuert durch `sensor.jahreszeit` aus Home Assistant.

## 📝 Release-Prozess

1. Version in [substitutions.yaml](src/common/substitutions.yaml) erhöhen
2. Tag erstellen: `git tag v2026.7.4 && git push --tags`
3. GitHub Actions baut automatisch die Firmware
4. Manifest-Datei wird zum Release hochgeladen
5. Web-Installation aktualisiert sich automatisch

## 🔗 Integration

- **Home Assistant**: Native API (verschlüsselt)
- **OTA-Updates**: Dual-Path (ESPHome Dashboard + HTTP Request für externe Updates)
- **WiFi-Provisioning**: Improv Serial (USB, Web-Flash) + Captive Portal (AP-Modus)
- **Web-Flash**: ESP Web Tools via GitHub Pages

## 📚 Dokumentation

- [Local Testing Guide](LOCAL_TESTING.md) - Lokale Test-Optionen & Dev Mode
- [Makefile Guide](static/MAKEFILE_GUIDE.md) - Alle Make-Targets
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
Empfohlene ESPHome-Version: 2026.7.4 oder neuer.

<!-- markdownlint-disable-next-line MD013 -->
[ci-badge]: https://github.com/TNTLarsn/Guition-ESP32-S3-4848S040/actions/workflows/ci.yml/badge.svg
<!-- markdownlint-disable-next-line MD013 -->
[ci-workflow]: https://github.com/TNTLarsn/Guition-ESP32-S3-4848S040/actions/workflows/ci.yml
<!-- markdownlint-disable-next-line MD013 -->
[publish-badge]: https://github.com/TNTLarsn/Guition-ESP32-S3-4848S040/actions/workflows/publish-firmware.yml/badge.svg
<!-- markdownlint-disable-next-line MD013 -->
[publish-workflow]: https://github.com/TNTLarsn/Guition-ESP32-S3-4848S040/actions/workflows/publish-firmware.yml
[web-installer]: https://TNTLarsn.github.io/Guition-ESP32-S3-4848S040/
