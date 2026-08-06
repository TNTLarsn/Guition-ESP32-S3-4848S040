# 🚀 Makefile - Lokale OTA-Update Commands

## Neuen Makefile-Targets

### 🧪 Lokale OTA-Updates (ohne GitHub Release)

#### `make localupdate` - Vollständiger OTA-Test

**Was es tut:**

1. ✅ Kompiliert Firmware mit `main.yaml`
2. ✅ Berechnet MD5 & SHA256 Checksummen
3. ✅ Erstellt `manifest.json` automatisch
4. ✅ Passt `core.yaml` mit lokaler Update-URL an
5. ✅ Kompiliert Firmware erneut mit lokaler URL
6. ✅ Startet HTTP-Server (Port 8000)

**Verwendung:**

```bash
make localupdate
```

**Output:**

```
╔════════════════════════════════════════════════════════════╗
║              🎉 Alles bereit zum OTA-Test! 🎉              ║
╚════════════════════════════════════════════════════════════╝

✅ FERTIG - Das brauchst du jetzt:
1️⃣  Starte das Update auf deinem Gerät:
    Home Assistant → ESPHome → [display01] → Firmware aktualisieren
...
```

#### `make localcleanup` - Aufräumen nach dem Test

**Was es tut:**

1. ✅ Stoppt HTTP-Server
2. ✅ Restauriert `core.yaml` aus Backup
3. ✅ Bereinigt temporäre Dateien

**Verwendung:**

```bash
make localcleanup
```

---

### 📦 Release-Management (lokale Versionen)

Verwalte mehrere lokale Firmware-Releases für verschiedene Test-Szenarien.

#### `make releases-list` - Zeige alle Releases

```bash
make releases-list
```

**Output Beispiel:**

```
═══════════════════════════════════════════════════
  Lokale Firmware-Releases
═══════════════════════════════════════════════════

✓ 2026.2.0-local
  └─ Erstellt: 2026-01-20T14:32:10Z
  └─ MD5: 9d9896a0a45a7c8627...
  └─ Notizen: Version mit neuer LVGL UI

  2026.1.3-local
  └─ Erstellt: 2026-01-20T13:15:00Z
  └─ MD5: 24351e744cf605a13ca...
```

#### `make releases-create` - Neues Release erstellen

```bash
make releases-create
```

**Workflow:**

```
Erstelle Release: 2026.2.0-local
Berechne Checksummen...

Gib Release-Notizen ein (optional, oder Enter zum Überspringen):
> Version mit neuer LVGL UI und Performance-Optimierungen

✅ Release erstellt:
   Version: 2026.2.0-local
   OTA MD5: 9d9896a0a45a7c862793e872a2ee2c6d
   Dieses Release jetzt aktivieren? (j/n): j
```

#### `make releases-use <version>` - Release aktivieren

Aktiviere ein bestehendes Release für Tests.

```bash
bash local_release_manager.sh use 2026.7.4-local
```

**Was passiert:**

- manifest.json wird mit Checksummen des Releases aktualisiert
- Versionsnummer wird auf das alte Release gesetzt
- Bereit für OTA-Tests mit dieser alten Version

#### `make releases-current` - Zeige aktuelles Release

```bash
make releases-current
```

**Output:**

```
Aktuelles aktives Release:
2026.2.0-local

  "version": "2026.2.0-local",
  "timestamp": "2026-01-20T14:32:10Z",
  "notes": "Version mit neuer LVGL UI",
  "ota_md5": "9d9896a0a45a7c862793e872a2ee2c6d",
  ...
```

---

## 🔄 Beispiel-Workflow

### Szenario: "Alte Version testen, dann auf neue upgraden"

```bash
# 1. Starte lokales OTA-Setup
make localupdate

# 2. (Im ESPHome Dashboard) Update durchführen
# ... Gerät upgraded auf LOCAL_DEV ...

# 3. Nach dem Test: Cleanup
make localcleanup

# 4. Später: Neues Release erstellen
make releases-create
# Gib Version "2026.2.0-local" ein
# Gib Notizen ein: "Performance-Optimierungen"
# Aktiviere sofort

# 5. HTTP-Server starten (für neue Version)
make localupdate

# 6. Im Dashboard: Erneut Update starten
# ... Gerät upgraded auf 2026.7.4-local ...

# 7. Falls zu Problem führt: Zurück zur alten Version
bash local_release_manager.sh use 2026.7.4-local
make localupdate
# Dashboard → Update → Upgrade auf 2026.7.4-local
```

---

## 📂 Dateien & Verzeichnisse

```
src/.esphome/build/display01/
├── manifest.json                    ← Auto-generiert
├── build/firmware.ota.bin           ← OTA-Firmware
├── build/firmware.factory.bin       ← Factory-Firmware
└── .active_release                  ← Aktuelles Release

src/common/
├── core.yaml                        ← Angepasst mit lokaler URL
└── core.yaml.ota-backup            ← Backup für Cleanup
```

---

## 🛠️ Unter der Haube

### `local_ota_test.sh`

- Hauptscript für OTA-Setup
- Bauprozess, Checksummen-Berechnung, Server-Start
- Akzeptiert sowohl das aktuelle ESPHome-Dev-Layout unter `build/` als auch das ältere `.pioenvs/display01/`
- Erstellt auch automatisch `cleanup_ota_test.sh`

### `local_release_manager.sh`

- Verwaltet lokale Release-Versionen
- Speichert Metadaten (Timestamp, Notes, Checksummen)
- Aktualisiert automatisch manifest.json bei Release-Aktivierung

### `cleanup_ota_test.sh` (Auto-generiert)

- Stoppt HTTP-Server
- Restauriert `core.yaml` aus Backup
- Bereinigt Temp-Dateien

---

## 💡 Tipps & Tricks

### Multi-Version Testing

```bash
# Teste unterschiedliche Versionen ohne GitHub
make releases-list
make releases-use 2026.7.4-local
make localupdate
# ... Update durchführen ...
make localcleanup

make releases-use 2026.2.0-local
make localupdate
# ... Upgrade durchführen ...
```

### Release-Notizen dokumentieren

Nutze beschreibende Notizen um zu tracken, welche Features getestet wurden:

```bash
make releases-create
# "OTA-Update-Mechanismus mit LVGL Progress - funktioniert ✓"
# "MD5-Checksummen-Validierung - OK"
```

### Netzwerk-Fehler debuggen

```bash
# Während localupdate läuft:
tail -f /tmp/http_server.log

# Oder (in separatem Terminal):
curl -I http://192.168.178.185:8000/manifest.json
curl -I http://192.168.178.185:8000/firmware.ota.bin
```

### Server läuft noch?

```bash
lsof -i :8000
```

---

## ⚠️ Wichtige Hinweise

1. **core.yaml Backup**: Wird automatisch erstellt als `core.yaml.ota-backup`
   - Cleanup restauriert diese automatisch
   - Falls something goes wrong: `cp src/common/core.yaml.ota-backup src/common/core.yaml`

2. **Firewall**: macOS Firewall kann HTTP-Zugriff blockieren

   ```bash
   sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
   # Nach Test: --setglobalstate on
   ```

3. **HTTP-Server Port 8000**: Prüfe Verfügbarkeit

   ```bash
   lsof -i :8000
   # Falls belegt: Ändere PORT in local_ota_test.sh
   ```

4. **Keine Online-Releases**: Das ist nur für lokale Tests!
   - Production-Releases gehen weiterhin über GitHub
   - Push, Tag, Release → GitHub Actions buildet automatisch

---

**Frohes Testen! 🚀**
