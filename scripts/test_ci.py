#!/usr/bin/env python3
"""
Lokales CI-Test-Skript für ESPHome-Projekt
Führt die gleichen Schritte wie .github/workflows/ci.yml aus
"""

import subprocess
import sys
from pathlib import Path
from typing import List, Tuple

# Farben für Terminal-Output
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

def print_header(text: str):
    """Druckt farbige Header"""
    print(f"\n{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.BLUE}{text}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.RESET}\n")

def print_success(text: str):
    """Druckt Erfolgs-Nachricht"""
    print(f"{Colors.GREEN}✓ {text}{Colors.RESET}")

def print_error(text: str):
    """Druckt Fehler-Nachricht"""
    print(f"{Colors.RED}✗ {text}{Colors.RESET}")

def print_warning(text: str):
    """Druckt Warnung"""
    print(f"{Colors.YELLOW}⚠ {text}{Colors.RESET}")

def run_command(cmd: List[str], description: str) -> Tuple[bool, str]:
    """
    Führt einen Befehl aus und gibt Erfolg/Fehler zurück
    """
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=False
        )
        
        if result.returncode == 0:
            return True, result.stdout
        else:
            return False, result.stderr
    except Exception as e:
        return False, str(e)

def check_esphome_installed() -> bool:
    """Prüft, ob ESPHome installiert ist"""
    success, output = run_command(['esphome', 'version'], 'ESPHome Version Check')
    if success:
        version = output.strip()
        print_success(f"ESPHome gefunden: {version}")
        return True
    else:
        print_error("ESPHome nicht gefunden!")
        print_warning("Installiere mit: pip install esphome")
        return False

def validate_yaml(yaml_file: str) -> bool:
    """Validiert eine ESPHome YAML-Datei"""
    print(f"\n  Validiere {yaml_file}...")
    success, output = run_command(
        ['esphome', 'config', yaml_file],
        f'Validate {yaml_file}'
    )
    
    if success:
        print_success(f"{yaml_file} ist valide")
        return True
    else:
        print_error(f"{yaml_file} hat Fehler:")
        print(output)
        return False

def compile_yaml(yaml_file: str) -> bool:
    """Kompiliert eine ESPHome YAML-Datei"""
    print(f"\n  Kompiliere {yaml_file}...")
    print(f"  {Colors.YELLOW}Befehl: esphome compile {yaml_file}{Colors.RESET}")
    
    # Führe Kompilierung mit Live-Ausgabe aus
    try:
        print(f"  {Colors.BLUE}[DEBUG] Starte Kompilierung...{Colors.RESET}")
        result = subprocess.run(
            ['esphome', 'compile', yaml_file],
            text=True,
            check=False
        )
        
        if result.returncode == 0:
            print_success(f"{yaml_file} erfolgreich kompiliert")
            print(f"  {Colors.BLUE}[DEBUG] Exit Code: {result.returncode}{Colors.RESET}")
            return True
        else:
            print_error(f"{yaml_file} Kompilierung fehlgeschlagen")
            print(f"  {Colors.RED}[DEBUG] Exit Code: {result.returncode}{Colors.RESET}")
            return False
    except Exception as e:
        print_error(f"Fehler beim Ausführen: {str(e)}")
        return False

def main():
    """Hauptfunktion - führt alle CI-Tests aus"""
    print_header("ESPHome CI Tests (Lokal)")
    
    # Prüfe ob ESPHome installiert ist
    if not check_esphome_installed():
        sys.exit(1)
    
    # YAML-Dateien aus ci.yml
    yaml_files = [
        'src/main.yaml',
        'src/main.factory.yaml'
    ]
    
    # Prüfe ob alle Dateien existieren
    print_header("Prüfe YAML-Dateien")
    missing_files = []
    for yaml_file in yaml_files:
        if Path(yaml_file).exists():
            print_success(f"{yaml_file} gefunden")
        else:
            print_error(f"{yaml_file} nicht gefunden!")
            missing_files.append(yaml_file)
    
    if missing_files:
        print_error(f"Fehlende Dateien: {', '.join(missing_files)}")
        sys.exit(1)
    
    # Validiere alle YAML-Dateien
    print_header("Validiere Konfigurationen")
    validation_results = []
    for yaml_file in yaml_files:
        result = validate_yaml(yaml_file)
        validation_results.append((yaml_file, result))
    
    # Kompiliere alle YAML-Dateien
    print_header("Kompiliere Firmware")
    compile_results = []
    for idx, yaml_file in enumerate(yaml_files, 1):
        print(f"{Colors.BLUE}[DEBUG] Kompilierung {idx}/{len(yaml_files)}: {yaml_file}{Colors.RESET}")
        result = compile_yaml(yaml_file)
        compile_results.append((yaml_file, result))
        print(f"{Colors.BLUE}[DEBUG] Ergebnis für {yaml_file}: {'✓ Erfolg' if result else '✗ Fehler'}{Colors.RESET}")
    
    # Zusammenfassung
    print_header("Zusammenfassung")
    
    all_passed = True
    
    print("\nValidierung:")
    for yaml_file, result in validation_results:
        if result:
            print_success(f"{yaml_file}")
        else:
            print_error(f"{yaml_file}")
            all_passed = False
    
    print("\nKompilierung:")
    for yaml_file, result in compile_results:
        if result:
            print_success(f"{yaml_file}")
        else:
            print_error(f"{yaml_file}")
            all_passed = False
    
    # Exit Code
    if all_passed:
        print(f"\n{Colors.GREEN}{Colors.BOLD}✓ Alle Tests bestanden!{Colors.RESET}\n")
        sys.exit(0)
    else:
        print(f"\n{Colors.RED}{Colors.BOLD}✗ Einige Tests sind fehlgeschlagen{Colors.RESET}\n")
        sys.exit(1)

if __name__ == '__main__':
    main()
