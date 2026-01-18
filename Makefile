# Makefile for local ESPHome CI tests
# Usage: make test, make validate, make compile, make clean

.PHONY: help test validate compile clean flash monitor

# Default target
help:
	@echo "ESPHome Local CI Tests"
	@echo "======================="
	@echo ""
	@echo "Available targets:"
	@echo "  make test       - Runs all CI tests (validation + compilation)"
	@echo "  make validate   - Only validates the YAML configurations"
	@echo "  make compile    - Compiles the firmware (without upload)"
	@echo "  make clean      - Deletes build artifacts"
	@echo "  make flash      - Flashes firmware to the device (port: /dev/cu.usbserial-110)"
	@echo "  make monitor    - Opens serial console for debugging"
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
