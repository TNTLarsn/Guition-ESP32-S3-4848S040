# Makefile für lokale ESPHome CI-Tests
# Nutze: make test, make validate, make compile, make clean

.PHONY: help test validate compile clean flash monitor

# Standard-Target
help:
	@echo "ESPHome Lokale CI-Tests"
	@echo "======================="
	@echo ""
	@echo "Verfügbare Targets:"
	@echo "  make test       - Führt alle CI-Tests aus (Validierung + Kompilierung)"
	@echo "  make validate   - Validiert nur die YAML-Konfigurationen"
	@echo "  make compile    - Kompiliert die Firmware (ohne Upload)"
	@echo "  make clean      - Löscht Build-Artefakte"
	@echo "  make flash      - Flasht Firmware auf das Gerät (Port: /dev/cu.usbserial-110)"
	@echo "  make monitor    - Öffnet serielle Konsole zum Debugging"
	@echo ""

# Führt alle Tests aus (wie CI)
test:
	@echo "Führe CI-Tests aus..."
	@python3 test_ci.py

# Nur Validierung
validate:
	@echo "Validiere Konfigurationen..."
	@esphome config src/main.yaml
	@esphome config src/main.factory.yaml
	@echo "✓ Alle Konfigurationen sind valide"

# Nur Kompilierung
compile:
	@echo "Kompiliere Firmware..."
	@esphome compile src/main.yaml
	@esphome compile src/main.factory.yaml
	@echo "✓ Firmware erfolgreich kompiliert"

# Build-Artefakte löschen
clean:
	@echo "Lösche Build-Artefakte..."
	@rm -rf src/.esphome/build
	@echo "✓ Build-Verzeichnis gelöscht"

# Firmware flashen
flash:
	@echo "Flashe Firmware auf /dev/cu.usbserial-110..."
	@esphome upload src/main.factory.yaml --device /dev/cu.usbserial-110

# Serielle Konsole öffnen
monitor:
	@echo "Öffne serielle Konsole..."
	@esphome logs src/main.yaml --device /dev/cu.usbserial-110
