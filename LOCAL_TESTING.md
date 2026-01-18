# Lokale CI-Tests ohne Docker

Dieses Projekt enthält drei verschiedene Möglichkeiten, um die GitHub
CI-Pipeline lokal auszuführen:

## 🐍 Python-Skript (empfohlen)

Am vollständigsten mit farbiger Ausgabe und detailliertem Fehler-Handling:

```bash
python3 test_ci.py
```

**Vorteile:**

- Farbige, übersichtliche Ausgabe
- Detaillierte Fehlerbehandlung
- Funktioniert auf allen Plattformen (macOS, Linux, Windows)
- Zeigt Build-Zeiten und Firmware-Größen

---

## 🔨 Makefile (schnellste Variante)

Bequeme Shortcuts für häufige Aufgaben:

```bash
# Alle Tests ausführen (validate + compile)
make test

# Nur Validierung
make validate

# Nur Kompilierung
make compile

# Firmware auf Gerät flashen
make flash

# Logs vom Gerät anzeigen
make monitor

# Build-Verzeichnis aufräumen
make clean
```

**Vorteile:**

- Sehr schnell und einfach zu nutzen
- Direkt Flash- und Monitor-Befehle enthalten
- Standard-Tool auf Unix-Systemen

---

## 🐚 Bash-Skript

Alternative für Bash-Fans:

```bash
bash test_ci.sh
```

**Vorteile:**

- Keine Python-Abhängigkeiten
- Farbige Ausgabe
- Fehlerbehandlung mit `set -e`

---

## Voraussetzungen

Alle Skripte benötigen:

- ESPHome CLI installiert und im PATH
- Python 3.x (für Python-Skript)
- Make (für Makefile, meist vorinstalliert)

### ESPHome installieren

Falls noch nicht vorhanden:

```bash
# Via pip (empfohlen)
python3 -m venv .venv
source .venv/bin/activate
pip install esphome

# Oder via Homebrew (macOS)
brew install esphome
```

---

## Was wird getestet?

Alle Skripte führen die gleichen Tests aus:

1. **Validierung**: Prüft beide YAML-Dateien auf Syntax-Fehler
   - `src/main.yaml`
   - `src/main.factory.yaml`

2. **Kompilierung**: Baut die Firmware für beide Konfigurationen
   - Erzeugt `.bin`-Dateien in `src/.esphome/build/`
   - Zeigt Speichernutzung und Firmware-Größe

---

## Gerät flashen

Nach erfolgreicher Kompilierung:

```bash
# Via Makefile (schnellste Methode)
make flash

# Oder manuell mit ESPHome
esphome upload src/main.factory.yaml --device /dev/cu.usbserial-110

# Logs anzeigen
make monitor
# oder
esphome logs src/main.yaml --device /dev/cu.usbserial-110
```

**Hinweis**: Das Gerät ist an `/dev/cu.usbserial-110` angeschlossen.

---

## Troubleshooting

### "esphome: command not found"

ESPHome ist nicht im PATH. Aktiviere die Python-Umgebung:

```bash
source .venv/bin/activate
```

### Validierung schlägt fehl

Prüfe die YAML-Syntax:

```bash
esphome config src/main.yaml
```

### Kompilierung schlägt fehl

- Stelle sicher, dass alle Pakete installiert sind
- Prüfe die ESPHome-Version: `esphome version` (sollte 2025.12.7 sein)
- Säubere Build-Cache: `make clean`

### Flash-Fehler

- Prüfe, ob das Gerät angeschlossen ist: `ls /dev/cu.*`
- Ändere den Port im Makefile, falls anders
- Reduziere die Baudrate: `--baud-rate 115200`

---

## Vergleich mit GitHub CI

Die lokalen Tests führen **exakt die gleichen Schritte** aus wie `.github/workflows/ci.yaml`:

| CI-Schritt | Lokales Äquivalent                |
| ---------- | --------------------------------- |
| `validate` | `esphome config src/main.yaml`    |
| `compile`  | `esphome compile src/main.yaml`   |

**Einziger Unterschied**: GitHub CI testet mit `stable`, `beta` und `dev`
ESPHome-Versionen. Lokal nutzen wir nur die installierte Version.

---

## Entwickler-Workflow

```bash
# 1. Code ändern
vim src/common/core.yaml

# 2. Lokal testen
make test

# 3. Falls erfolgreich: Auf Gerät flashen
make flash

# 4. Logs prüfen
make monitor

# 5. Commit & Push
git add .
git commit -m "Feature XY hinzugefügt"
git push
```

---

## Weitere Informationen

- **ESPHome-Docs**: [https://esphome.io](https://esphome.io)
- **Projekt-README**: [README.md](README.md)
- **Copilot-Instruktionen**: [.github/copilot-instructions.md](.github/copilot-instructions.md)
