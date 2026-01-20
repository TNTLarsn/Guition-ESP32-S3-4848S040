# Makefile for local ESPHome CI tests
# Usage: make test, make validate, make compile, make clean

.PHONY: help test validate compile clean flash monitor update localupdate localcleanup releases-list releases-create releases-current

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
	@echo "Local OTA Testing:"
	@echo "  make localupdate     - Full local OTA test (compile + HTTP server)"
	@echo "  make localcleanup    - Cleanup after local OTA test"
	@echo ""
	@echo "Release Management:"
	@echo "  make releases-list   - List all local releases"
	@echo "  make releases-create - Create a new local release"
	@echo "  make releases-current- Show current active release"
	@echo ""

# Runs all tests (like CI)
test:
	@echo "Running CI tests..."
	@python3 test_ci.py

# Validation only
validate:
	@echo "Validating configurations..."
	@esphome config src/main.yaml
	@esphome config src/main.factory.yaml
	@echo "✓ All configurations are valid"

# Compilation only
compile:
	@echo "Compiling firmware..."
	@esphome compile src/main.yaml
	@esphome compile src/main.factory.yaml
	@echo "✓ Firmware successfully compiled"

# Delete build artifacts
clean:
	@echo "Deleting build artifacts..."
	@rm -rf src/.esphome/build
	@echo "✓ Build directory deleted"

# Flash firmware
flash:
	@echo "Erasing flash via esptool..."
	@esptool.py --chip esp32s3 --port /dev/cu.usbserial-110 erase_flash
	@echo "Flashing firmware to /dev/cu.usbserial-110..."
	@esphome upload src/main.factory.yaml --device /dev/cu.usbserial-110

# Update firmware
update:
	@echo "Updating firmware on /dev/cu.usbserial-110..."
	@esphome run src/main.yaml --device /dev/cu.usbserial-110

# Open serial console
monitor:
	@echo "Opening serial console..."
	@esphome logs src/main.yaml --device /dev/cu.usbserial-110

# ============================================================================
# Local OTA Testing
# ============================================================================

# Full local OTA test setup
localupdate:
	@echo "Starting local OTA update..."
	@bash local_ota_test.sh

# Initial setup for local dev mode (first time)
local-release-test:
	@echo "Starting full local release test..."
	@bash full_local_release_test.sh

# Cleanup after local OTA test
localcleanup:
	@echo "Cleaning up local OTA test..."
	@bash cleanup_ota_test.sh

# ============================================================================
# Release Management
# ============================================================================

# List all local releases
releases-list:
	@bash local_release_manager.sh list

# Create a new local release
releases-create:
	@bash local_release_manager.sh create

# Show current active release
releases-current:
	@bash local_release_manager.sh current

# Use a specific release (usage: make releases-use VERSION=2026.1.3-local)
releases-use:
	@bash local_release_manager.sh use $(VERSION)
