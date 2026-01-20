# Local Testing Guide

Dieser Guide beschreibt alle lokalen Test-Methoden für das Guition ESP32-S3-4848S040 Projekt.

---

## 📁 Projektstruktur

```text
scripts/
├── test_ci.py              # Python CI-Test Script
├── test_ci.sh              # Bash CI-Test Script
└── local-testing/          # Local Dev Mode Scripts
    ├── full_local_release_test.sh   # Gerät in Local Dev Mode versetzen
    ├── local_ota_test.sh            # Iterative Firmware-Updates
    └── cleanup_ota_test.sh          # Zurück zum Normalzustand
```

---

## 🖥️ VS Code Integration

### Tasks ausführen

**`Cmd + Shift + P`** → **"Tasks: Run Task"** → Task auswählen

Oder: **Terminal** → **Run Task...**

### Verfügbare Tasks

| Task | Shortcut | Beschreibung |
|------|----------|--------------|
| 🚀 Local Dev Mode aktivieren | - | Gerät in lokalen Modus versetzen |
| 📦 Local Update | `Cmd+Shift+B` | Neue Firmware kompilieren & bereitstellen |
| 🧹 Local Cleanup | - | Zurück zum Normalzustand |
| 🧪 CI Tests ausführen | - | Alle CI-Tests |
| ✅ YAML Validieren | - | Nur Validierung |
| 🔨 Firmware Kompilieren | - | Nur kompilieren |
| ⚡ Flash Firmware (USB) | - | USB Flash mit Erase |
| 🔄 Update Firmware (USB) | - | USB Update |
| 📺 Monitor (Logs) | - | Serielle Konsole |
| 🗑️ Build Clean | - | Build löschen |

### Run and Debug (F5)

Im **Run & Debug** Panel (Sidebar) findest du Launch-Konfigurationen:

- 🚀 Local Dev Mode starten
- 📦 Local Update
- 🧹 Local Cleanup
- 📺 Monitor (Logs)

---

## 🚀 Local Dev Mode

Teste Firmware-Updates **lokal ohne GitHub Release** mit deinem PC als HTTP-Server.

### Workflow-Übersicht

```text
┌─────────────────────────────────────────────────────────────────┐
│  1. EINMALIG: Local Dev Mode aktivieren                         │
│     VS Code: Task "🚀 Local Dev Mode aktivieren"                │
│     Terminal: make local-release-test 192.168.178.150           │
│     → Patcht core.yaml mit lokaler URL                          │
│     → Flasht Firmware automatisch via OTA                       │
│     → Startet HTTP-Server (Port 8000)                           │
├─────────────────────────────────────────────────────────────────┤
│  2. ITERATIV: Code ändern & testen                              │
│     vim src/pages/home.yaml                                     │
│     VS Code: Task "📦 Local Update" (Cmd+Shift+B)               │
│     Terminal: make localupdate                                  │
│     → Home Assistant → ESPHome → display01 → "Update"           │
│     → Wiederholen...                                            │
├─────────────────────────────────────────────────────────────────┤
│  3. CLEANUP: Zurück zum Normalzustand                           │
│     VS Code: Task "🧹 Local Cleanup"                            │
│     Terminal: make localcleanup                                 │
│     → Stellt nur update.source URL wieder her                   │
│     → Andere Änderungen in core.yaml bleiben erhalten!          │
│     → Flasht Original-Firmware                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Quick Start (VS Code)

1. **`Cmd + Shift + P`** → "Tasks: Run Task" → **"🚀 Local Dev Mode aktivieren"**
2. Code ändern (z.B. `src/pages/home.yaml`)
3. **`Cmd + Shift + B`** (Default Build Task = **📦 Local Update**)
4. Home Assistant → ESPHome → display01 → "Firmware aktualisieren"
5. Nach dem Testen: Task **"🧹 Local Cleanup"**

### Quick Start (Terminal)

```bash
# 1. Gerät in Local Dev Mode versetzen (einmalig)
make local-release-test 192.168.178.150

# 2. Code ändern
vim src/pages/home.yaml

# 3. Neue Firmware bereitstellen
make localupdate

# 4. Update im Home Assistant Dashboard durchführen
#    → ESPHome → display01 → "Firmware aktualisieren"

# 5. Nach dem Testen: Cleanup
make localcleanup
```

### Was passiert bei jedem Schritt?

#### Schritt 1: Local Dev Mode aktivieren

```bash
make local-release-test [DEVICE-IP]
```

**Hinweis:** Wenn bereits eine `.local_dev_state` existiert, wird der erneute Start absichtlich verhindert. Bitte zuerst `make localcleanup` ausführen. Optional (nicht empfohlen): erzwingen mit `FORCE=1 make local-release-test [DEVICE-IP]`.

1. ✅ PC-IP wird automatisch erkannt
2. ✅ Device-IP wird ermittelt (oder abgefragt)
3. ✅ Originale `update.source` URL wird gespeichert
4. ✅ `core.yaml` wird mit lokaler Update-URL gepatcht
5. ✅ Firmware wird kompiliert
6. ✅ Firmware wird automatisch via OTA geflasht
7. ✅ HTTP-Server startet (Port 8000)
8. ✅ State wird in `.local_dev_state` gespeichert

#### Schritt 2: Local Update

```bash
make localupdate
```

1. ✅ Prüft ob Local Dev Mode aktiv ist
2. ✅ Kompiliert Firmware neu
3. ✅ Kopiert neue Firmware ins HTTP-Server-Verzeichnis
4. ✅ Aktualisiert `manifest.json` mit neuer Version
5. ✅ Update ist im Home Assistant Dashboard verfügbar

#### Schritt 3: Cleanup

```bash
make localcleanup
```

1. ✅ HTTP-Server wird gestoppt
2. ✅ Nur die `update.source` URL in `core.yaml` wird wiederhergestellt
3. ✅ **Alle anderen Änderungen an `core.yaml` bleiben erhalten!**
4. ✅ Firmware mit GitHub-URL wird kompiliert
5. ✅ Original-Firmware wird automatisch geflasht
6. ✅ State-Datei wird gelöscht

---

## 🧪 CI Tests

Lokale Tests um den GitHub CI-Workflow zu simulieren.

### VS Code

**`Cmd + Shift + P`** → "Tasks: Run Task" → **"🧪 CI Tests ausführen"**

### Terminal

```bash
# Python Script (Empfohlen)
python3 scripts/test_ci.py

# Makefile
make test

# Bash Script
bash scripts/test_ci.sh
```

### Was wird getestet?

1. **Validierung**: Prüft YAML-Syntax
   - `src/main.yaml`
   - `src/main.factory.yaml`

2. **Kompilierung**: Baut Firmware
   - Generiert `.bin` Dateien in `src/.esphome/build/`
   - Zeigt Speichernutzung und Firmware-Größe

---

## 🔧 Device Management

### Firmware flashen (USB)

```bash
# Via VS Code Task: "⚡ Flash Firmware (USB)"
# Oder Terminal:
make flash
```

### Firmware updaten (USB)

```bash
# Via VS Code Task: "🔄 Update Firmware (USB)"
# Oder Terminal:
make update
```

### Device-Logs anzeigen

```bash
# Via VS Code Task: "📺 Monitor (Logs)"
# Oder Terminal:
make monitor
```

---

## 📋 Voraussetzungen

### ESPHome installieren

```bash
# Via pip (empfohlen)
python3 -m venv .venv
source .venv/bin/activate
pip install esphome

# Oder via Homebrew (macOS)
brew install esphome
```

### esptool.py installieren

```bash
pip install esptool
```

### Version prüfen

```bash
esphome version  # Sollte 2025.12.7 sein
```

---

## 📝 Makefile-Targets Übersicht

### CI & Testing

| Target | Beschreibung |
|--------|--------------|
| `make test` | Alle CI-Tests (Validierung + Kompilierung) |
| `make validate` | Nur YAML-Validierung |
| `make compile` | Nur Firmware-Kompilierung |
| `make clean` | Build-Verzeichnis löschen |

### Device Management

| Target | Beschreibung |
|--------|--------------|
| `make flash` | Firmware flashen (USB, mit Flash-Erase) |
| `make update` | Firmware via USB updaten |
| `make monitor` | Serielle Konsole öffnen |

### Local Dev Mode

| Target | Beschreibung |
|--------|--------------|
| `make local-release-test [IP]` | 🚀 Gerät in Local Dev Mode versetzen |
| `make localupdate` | 📦 Neue Firmware bereitstellen |
| `make localcleanup` | 🧹 Zurück zum Normalzustand |

---

## 🐛 Troubleshooting

### "esphome: command not found"

ESPHome ist nicht im PATH. Aktiviere die Python-Umgebung:

```bash
source .venv/bin/activate
```

### "Local Dev Mode nicht aktiv!"

Starte zuerst den Local Dev Mode:

```bash
make local-release-test 192.168.178.150
```

### Kein Update im Home Assistant sichtbar

1. Prüfe ob HTTP-Server läuft: `lsof -i :8000`
2. Prüfe manifest.json: `curl http://192.168.178.185:8000/manifest.json`
3. Stelle sicher, dass das Gerät die PC-IP erreichen kann

### Build fehlgeschlagen

```bash
# Logs prüfen
cat /tmp/compile.log

# Build-Cache löschen
make clean

# ESPHome-Version prüfen
esphome version
```

### Flash fehlgeschlagen (USB)

```bash
# Prüfe ob Gerät verbunden ist
ls /dev/cu.*

# Ändere Port im Makefile falls abweichend
```

### OTA fehlgeschlagen

```bash
# Prüfe Gerät-Erreichbarkeit
ping 192.168.178.150

# Prüfe ESPHome-Logs
esphome logs src/main.yaml --device 192.168.178.150
```

---

## 🔄 Vergleich mit GitHub CI

Lokale Tests führen **exakt die gleichen Schritte** aus wie `.github/workflows/ci.yaml`:

| CI-Schritt | Lokales Äquivalent |
|------------|-------------------|
| `validate` | `esphome config src/main.yaml` |
| `compile` | `esphome compile src/main.yaml` |

**Einziger Unterschied**: GitHub CI testet mit `stable`, `beta` und `dev` ESPHome-Versionen. Lokal wird nur die installierte Version verwendet.

---

## 📚 Weitere Ressourcen

- [ESPHome Dokumentation](https://esphome.io)
- [Projekt README](README.md)
- [Copilot Instructions](.github/copilot-instructions.md)

---

**Viel Erfolg beim Testen! 🚀**
