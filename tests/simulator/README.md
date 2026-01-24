# 🖥️ ESPHome SDL Simulator

Schnelles LVGL UI-Testing **ohne Hardware-Upload**!

## Vorteile

| Hardware-Workflow | Simulator-Workflow |
|-------------------|-------------------|
| Code ändern | Code ändern |
| `make localupdate` (~2-3 Min) | `esphome run tests/simulator/main.simulator.yaml` (Erst-Build ~30–60 Sek, danach ~3–5 Sek) |
| Zu Home Assistant wechseln | ⚡ SDL-Fenster öffnet sich direkt |
| Update klicken | - |
| Warten auf Reboot | - |
| Testen | Testen (Mausklicks = Touch) |
| **~5 Minuten pro Iteration** | **Erste Iteration ~1 Minute, danach ~5–10 Sekunden** |

## Quick Start

### VS Code (empfohlen)

1. **`Cmd + Shift + P`** → "Tasks: Run Task" → **"🖥️ Simulator starten"**
2. Ein SDL-Fenster mit dem Display öffnet sich
3. Mausklicks simulieren Touch-Events
4. Navigation-Buttons unten ermöglichen Seitenwechsel
5. Zum Beenden: **Ctrl+C** im Terminal oder Fenster schließen

### Terminal

```bash
# Kompilieren + Starten
esphome run tests/simulator/main.simulator.yaml

# Nur kompilieren
esphome compile tests/simulator/main.simulator.yaml
```

## Struktur

```
tests/simulator/
├── main.simulator.yaml     # Komplette Simulator-Konfiguration
├── README.md               # Diese Datei
├── .gitignore              # Ignoriert Build-Artefakte
└── .esphome/               # Build-Artefakte
```

## Enthaltene Features

### Pages (simuliert die echten Projekt-Pages)

- **home_page**: Wetter, Uhrzeit, Datum, Temperatur
- **switches_page**: 6 Button-Grid mit MDI-Icons

### Mock-Daten

- **Home Assistant Entities**: 7 simulierte Entitäten (Lichter, Steckdosen, etc.)
- **Zeit**: Simulierte Uhrzeit die jede Minute hochzählt
- **MDI-Icons**: Helper aus `src/helper/mdi_icon_map.h` wird verwendet

### Navigation

Die Navigation-Bar am unteren Rand ermöglicht das Wechseln zwischen Pages:

- Linker Button: Vorherige Seite
- Rechter Button: Nächste Seite

## Anpassungen

### Neue Pages testen

Füge deine Page-Widgets direkt in `main.simulator.yaml` unter `lvgl.pages` hinzu:

```yaml
lvgl:
  pages:
    - id: my_new_page
      widgets:
        - label:
            text: "Meine neue Seite"
            align: CENTER
```

Vergiss nicht `total_pages` in globals zu erhöhen und die Navigation in `show_current_page` anzupassen!

### Mock-Entitäten anpassen

Die Mock-Entitäten sind als `text_sensor` definiert:

```yaml
text_sensor:
  - platform: template
    id: ha_entity_1_icon
    lambda: |-
      static MdiIconHelper helper;
      return helper.convert_mdi_icon("mdi:dein-icon");
```

## Einschränkungen

1. **Home Assistant Services** funktionieren nicht (Button-Clicks loggen nur). Fonts, MDI-Icons und Images werden dagegen wie in `tests/simulator/main.simulator.yaml` konfiguriert und im Simulator angezeigt.

## Workflow-Empfehlung

```
1. Layout im Simulator designen (~5 Sek pro Iteration)
2. Grid/Padding/Positions anpassen
3. Wenn Layout stimmt → In src/pages/ übertragen
4. Final auf Hardware testen (Fonts, Icons, Images)
```

## Warum dieser Ansatz?

Der Simulator spiegelt die **Struktur** der echten Pages wider:

- Gleiche Widget-IDs (homeassistant_btn_1, display_time, etc.)
- Gleiches Grid-Layout
- Gleiche Navigation-Logik

Dadurch können Layout-Änderungen 1:1 in die Produktions-YAML übertragen werden!

Dies beschleunigt die UI-Entwicklung um **~50x**! 🚀
