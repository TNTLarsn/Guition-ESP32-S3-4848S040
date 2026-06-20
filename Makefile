# Makefile for local ESPHome CI tests
# Usage: make test, make validate, make compile, make clean

.PHONY: help test validate compile clean flash monitor update localupdate localcleanup local-release-test esphome-current esphome-install-stable esphome-install-beta esphome-install-dev esphome-use-stable esphome-use-beta esphome-use-dev

ESPHOME ?= ./scripts/dev/esphome
ESPHOME_ENV ?= ./scripts/dev/esphome-env
USB_PORT ?= /dev/cu.usbserial-110

# Default target
help:
	@echo "ESPHome Local CI Tests"
	@echo "======================="
	@echo ""
	@echo "Available targets:"
	@echo "  make test            - Runs all CI tests (validation + compilation)"
	@echo "  make validate        - Only validates the YAML configurations"
	@echo "  make compile         - Compiles the firmware (without upload)"
	@echo "  make clean           - Deletes build artifacts"
	@echo "  make flash           - Flashes firmware to the device (port: /dev/cu.usbserial-110)"
	@echo "  make monitor         - Opens serial console for debugging"
	@echo "  make update          - Updates firmware via USB"
	@echo ""
	@echo "Local Dev Mode (OTA Testing ohne GitHub):"
	@echo "  make local-release-test [IP] - 🚀 Gerät in Local Dev Mode versetzen"
	@echo "  make localupdate             - 📦 Neue Firmware bereitstellen"
	@echo "  make localcleanup            - 🧹 Zurück zum Normalzustand"
	@echo ""
	@echo "ESPHome Versionen (workspace-lokal):"
	@echo "  make esphome-install-stable  - Stable-Umgebung installieren"
	@echo "  make esphome-install-beta    - Beta-Umgebung installieren"
	@echo "  make esphome-install-dev     - Dev-Umgebung installieren"
	@echo "  make esphome-use-stable      - Stable aktivieren"
	@echo "  make esphome-use-beta        - Beta aktivieren"
	@echo "  make esphome-use-dev         - Dev aktivieren"
	@echo "  make esphome-current         - Aktive ESPHome-Version anzeigen"
	@echo ""

# Runs all tests (like CI)
test:
	@echo "Running CI tests..."
	@python3 scripts/test_ci.py

# Validation only
validate:
	@echo "Validating configurations..."
	@$(ESPHOME) config src/main.yaml
	@$(ESPHOME) config src/main.factory.yaml
	@echo "✓ All configurations are valid"

# Compilation only
compile:
	@echo "Compiling firmware..."
	@$(ESPHOME) compile src/main.yaml
	@$(ESPHOME) compile src/main.factory.yaml
	@echo "✓ Firmware successfully compiled"

# Delete build artifacts
clean:
	@echo "Deleting build artifacts..."
	@rm -rf src/.esphome/build
	@echo "✓ Build directory deleted"

# Flash firmware
flash:
	@echo "Erasing flash via esptool..."
	@esptool.py --chip esp32s3 --port $(USB_PORT) erase_flash
	@echo "Flashing firmware to $(USB_PORT)..."
	@$(ESPHOME) upload src/main.factory.yaml --device $(USB_PORT)

# Update firmware
update:
	@echo "Updating firmware on $(USB_PORT)..."
	@$(ESPHOME) run src/main.yaml --device $(USB_PORT)

# Open serial console
monitor:
	@echo "Opening serial console..."
	@$(ESPHOME) logs src/main.yaml --device $(USB_PORT)

# ============================================================================
# Local OTA Testing (scripts in scripts/local-testing/)
# ============================================================================

# Full local OTA test setup
localupdate:
	@echo "Starting local OTA update..."
	@bash scripts/local-testing/local_ota_test.sh

# Initial setup for local dev mode (first time)
local-release-test:
	@echo "Starting full local release test..."
	@bash scripts/local-testing/full_local_release_test.sh $(filter-out $@,$(MAKECMDGOALS))

# Cleanup after local OTA test
localcleanup:
	@echo "Cleaning up local OTA test..."
	@bash scripts/local-testing/cleanup_ota_test.sh

esphome-install-stable:
	@$(ESPHOME_ENV) install stable

esphome-install-beta:
	@$(ESPHOME_ENV) install beta

esphome-install-dev:
	@$(ESPHOME_ENV) install dev

esphome-use-stable:
	@$(ESPHOME_ENV) use stable

esphome-use-beta:
	@$(ESPHOME_ENV) use beta

esphome-use-dev:
	@$(ESPHOME_ENV) use dev

esphome-current:
	@$(ESPHOME_ENV) current

# Catch-all für Device-IP als Argument:
# Any additional non-target argument (e.g. an IP address) is captured here
# so it can be passed via $(MAKECMDGOALS). This will also catch mistyped
# targets, but we print a message to make that behavior visible.
%:
	@echo "Note: Treating '$@' as a device IP argument, not as a Make target."
