# Local CI Tests Without Docker

This project includes three different ways to run the GitHub CI pipeline locally:

## 🐍 Python Script (Recommended)

Most comprehensive with colored output and detailed error handling:

```bash
python3 test_ci.py
```

**Benefits:**

- Colored, clear output
- Detailed error handling
- Works on all platforms (macOS, Linux, Windows)
- Shows build times and firmware sizes

---

## 🔨 Makefile (Fastest Option)

Convenient shortcuts for common tasks:

```bash
# Run all tests (validate + compile)
make test

# Validation only
make validate

# Compilation only
make compile

# Flash firmware to device
make flash

# Show device logs
make monitor

# Clean build directory
make clean
```

**Benefits:**

- Very fast and easy to use
- Includes direct flash and monitor commands
- Standard tool on Unix systems

---

## 🐚 Bash Script

Alternative for Bash enthusiasts:

```bash
bash test_ci.sh
```

**Benefits:**

- No Python dependencies
- Colored output
- Error handling with `set -e`

---

## Prerequisites
### Flash Erase Behavior

- Das Makefile-Target `make flash` löscht den Flash-Speicher vor dem Upload mit `esptool.py erase_flash` (Chip: ESP32-S3, Port: `/dev/cu.usbserial-110`).
- Voraussetzung: `esptool.py` ist installiert (z. B. via `pip install esptool`).
- Falls dein Gerät einen anderen Port nutzt, passe den Port im [Makefile](Makefile) an.

All scripts require:

- ESPHome CLI installed and in PATH
- Python 3.x (for Python script)
- Make (for Makefile, usually pre-installed)

### Installing ESPHome

If not already installed:

```bash
### "esptool.py: command not found"

`esptool.py` ist nicht installiert. Bitte installiere es z. B. via pip:

```bash
pip install esptool
```

# Via pip (recommended)
python3 -m venv .venv
source .venv/bin/activate
pip install esphome

# Or via Homebrew (macOS)
brew install esphome
```

---

## What Gets Tested?

All scripts run the same tests:

1. **Validation**: Checks both YAML files for syntax errors
   - `src/main.yaml`
   - `src/main.factory.yaml`

2. **Compilation**: Builds firmware for both configurations
   - Generates `.bin` files in `src/.esphome/build/`
   - Shows memory usage and firmware size

---

## Flashing Device

After successful compilation:

```bash
# Via Makefile (fastest method)
make flash

# Or manually with ESPHome
esphome upload src/main.factory.yaml --device /dev/cu.usbserial-110

# Show logs
make monitor
# or
esphome logs src/main.yaml --device /dev/cu.usbserial-110
```

**Note**: The device is connected at `/dev/cu.usbserial-110`.

---

## Troubleshooting

### "esphome: command not found"

ESPHome is not in PATH. Activate the Python environment:

```bash
source .venv/bin/activate
```

### Validation Fails

Check YAML syntax:

```bash
esphome config src/main.yaml
```

### Compilation Fails

- Ensure all packages are installed
- Check ESPHome version: `esphome version` (should be 2025.12.7)
- Clean build cache: `make clean`

### Flash Errors

- Check if device is connected: `ls /dev/cu.*`
- Change the port in Makefile if different
- Reduce baud rate: `--baud-rate 115200`

---

## Comparison with GitHub CI

Local tests run **exactly the same steps** as `.github/workflows/ci.yaml`:

| CI Step    | Local Equivalent                  |
| ---------- | --------------------------------- |
| `validate` | `esphome config src/main.yaml`    |
| `compile`  | `esphome compile src/main.yaml`   |

**Only difference**: GitHub CI tests with `stable`, `beta`, and `dev`
ESPHome versions. Locally we only use the installed version.

---

## Developer Workflow

```bash
# 1. Change code
vim src/common/core.yaml

# 2. Test locally
make test

# 3. If successful: Flash to device
make flash

# 4. Check logs
make monitor

# 5. Commit & Push
git add .
git commit -m "Added feature XY"
git push
```

---

## Additional Information

- **ESPHome Docs**: [https://esphome.io](https://esphome.io)
- **Project README**: [README.md](README.md)
- **Copilot Instructions**: [.github/copilot-instructions.md](.github/copilot-instructions.md)
