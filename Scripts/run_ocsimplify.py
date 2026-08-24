"""
Automated OCSimplify runner - bypasses interactive prompts
Generates an OpenCore EFI for macOS Sequoia (Darwin 24) using existing SysReport
"""
import os
import sys

# Set working directory to OCSimplify root
OCS_DIR = r"C:\Users\Malik\Documents\Hackintosh\Tools\OpCore-Simplify-main"
os.chdir(OCS_DIR)
sys.path.insert(0, OCS_DIR)

from Scripts.datasets import os_data
from Scripts import acpi_guru
from Scripts import compatibility_checker
from Scripts import config_prodigy
from Scripts import gathering_files
from Scripts import hardware_customizer
from Scripts import kext_maestro
from Scripts import run
from Scripts import smbios
from Scripts import utils
import shutil

# Monkey-patch request_input to auto-respond
_auto_responses = []
_response_idx = [0]

def _auto_request_input(prompt=""):
    """Auto-respond to interactive prompts"""
    print(f"[AUTO] Prompt: {prompt.strip()}")
    
    # GPU kext selection - choose WhateverGreen (option 2) for Sequoia compatibility
    if "Select kext for your AMD" in prompt and "GPU" in prompt:
        print("[AUTO] -> 2 (WhateverGreen)")
        return "2"
    # WiFi kext - skip (we have native BCM94360NG)
    if "Select kext for your Intel WiFi" in prompt:
        print("[AUTO] -> (skip/default)")
        return ""
    # OCLP root patch
    if "Apply OCLP" in prompt:
        print("[AUTO] -> n")
        return "n"
    # Force load on unsupported
    if "force load" in prompt:
        print("[AUTO] -> Y")
        return "Y"
    # Any Y/N prompt - default to Y
    if "(Y/n)" in prompt:
        print("[AUTO] -> Y")
        return "Y"
    if "(y/N)" in prompt:
        print("[AUTO] -> n")
        return "n"
    # Press Enter to continue
    if "Press Enter" in prompt or "continue" in prompt:
        print("[AUTO] -> (enter)")
        return ""
    # Select option prompts
    if "Select" in prompt and "option" in prompt:
        print("[AUTO] -> (enter/default)")
        return ""
    # Default: just press enter
    print("[AUTO] -> (enter/default)")
    return ""

# Patch the Utils class
original_init = utils.Utils.__init__
def patched_init(self, *args, **kwargs):
    original_init(self, *args, **kwargs)
    self.request_input = _auto_request_input

utils.Utils.__init__ = patched_init
utils.Utils.request_input = _auto_request_input

class AutomatedOCSimplify:
    def __init__(self):
        self.u = utils.Utils()
        self.ac = acpi_guru.ACPIGuru()
        self.c = compatibility_checker.CompatibilityChecker()
        self.co = config_prodigy.ConfigProdigy()
        self.o = gathering_files.gatheringFiles()
        self.h = hardware_customizer.HardwareCustomizer()
        self.k = kext_maestro.KextMaestro()
        self.s = smbios.SMBIOS()
        self.r = run.Run()
        self.result_dir = os.path.join(OCS_DIR, "Results")

    def run(self):
        report_path = os.path.join(OCS_DIR, "SysReport", "Report.json")
        acpitables_dir = os.path.join(OCS_DIR, "SysReport", "ACPI")
        
        print(f"Loading hardware report from: {report_path}")
        hardware_report = self.u.read_file(report_path)
        
        if not hardware_report:
            print("ERROR: Could not read Report.json")
            return False
        
        if os.path.exists(acpitables_dir):
            self.ac.read_acpi_tables(acpitables_dir)
            print(f"Loaded ACPI tables from: {acpitables_dir}")
        
        print("Checking hardware compatibility...")
        hardware_report, native_macos_version, ocl_patched_macos_version = self.c.check_compatibility(hardware_report)
        print(f"Native macOS support: {native_macos_version}")
        
        macos_version = "24.99.99"
        print(f"Target macOS: {os_data.get_macos_name_by_darwin(macos_version)} (Darwin {macos_version})")
        
        print("Applying hardware customization...")
        customized_hardware, disabled_devices, needs_oclp = self.h.hardware_customization(hardware_report, macos_version)
        print(f"Disabled devices: {disabled_devices}")
        print(f"Needs OCLP: {needs_oclp}")
        
        smbios_model = self.s.select_smbios_model(customized_hardware, macos_version)
        print(f"SMBIOS model: {smbios_model}")
        
        print("Determining ACPI patches...")
        if self.ac.ensure_dsdt():
            print("DSDT loaded successfully")
        self.ac.select_acpi_patches(customized_hardware, disabled_devices)
        # Debug: show what patches look like
        if hasattr(self.ac, 'patches'):
            print(f"ACPI patches type: {type(self.ac.patches)}")
            if self.ac.patches:
                print(f"First patch type: {type(self.ac.patches[0])}")
                print(f"First patch: {self.ac.patches[0]}")
        
        print("Selecting required kexts...")
        self.k.select_required_kexts(customized_hardware, macos_version, needs_oclp, self.ac.patches)
        
        self.s.smbios_specific_options(customized_hardware, smbios_model, macos_version, self.ac.patches, self.k)
        
        print("Gathering bootloader and kext files...")
        self.o.gather_bootloader_kexts(self.k.kexts, macos_version)
        
        print("Building OpenCore EFI...")
        self.build_opencore_efi(customized_hardware, disabled_devices, smbios_model, macos_version, needs_oclp)
        
        print(f"\nDone! Results in: {self.result_dir}")
        return True

    def build_opencore_efi(self, hardware_report, disabled_devices, smbios_model, macos_version, needs_oclp):
        self.u.create_folder(self.result_dir, remove_content=True)

        if not os.path.exists(self.k.ock_files_dir):
            raise Exception(f"Directory '{self.k.ock_files_dir}' does not exist.")

        source_efi_dir = os.path.join(self.k.ock_files_dir, "OpenCorePkg")
        shutil.copytree(source_efi_dir, self.result_dir, dirs_exist_ok=True)

        config_file = os.path.join(self.result_dir, "EFI", "OC", "config.plist")
        config_data = self.u.read_file(config_file)

        if not config_data:
            raise Exception(f"Error: The file {config_file} does not exist.")
        
        print("  1. Applying ACPI patches...")
        config_data["ACPI"]["Add"] = []
        config_data["ACPI"]["Delete"] = []
        config_data["ACPI"]["Patch"] = []
        
        if self.ac.ensure_dsdt():
            self.ac.hardware_report = hardware_report
            self.ac.disabled_devices = disabled_devices
            self.ac.acpi_directory = os.path.join(self.result_dir, "EFI", "OC", "ACPI")
            self.ac.smbios_model = smbios_model
            self.ac.lpc_bus_device = self.ac.get_lpc_name()

            for patch in self.ac.patches:
                if hasattr(patch, 'checked') and patch.checked:
                    if hasattr(patch, 'name') and patch.name == "BATP":
                        continue
                    acpi_load = getattr(self.ac, patch.function_name, lambda: None)()
                    if not isinstance(acpi_load, dict):
                        continue
                    config_data["ACPI"]["Add"].extend(acpi_load.get("Add", []))
                    config_data["ACPI"]["Delete"].extend(acpi_load.get("Delete", []))
                    config_data["ACPI"]["Patch"].extend(acpi_load.get("Patch", []))

        if hasattr(self.ac, 'dsdt_patches'):
            config_data["ACPI"]["Patch"].extend(self.ac.dsdt_patches)
        config_data["ACPI"]["Patch"] = self.ac.apply_acpi_patches(config_data["ACPI"]["Patch"])

        print("  2. Installing kexts...")
        kexts_directory = os.path.join(self.result_dir, "EFI", "OC", "Kexts")
        self.k.install_kexts_to_efi(macos_version, kexts_directory)
        config_data["Kernel"]["Add"] = self.k.load_kexts(hardware_report, macos_version, kexts_directory)

        print("  3. Generating config.plist...")
        self.co.genarate(hardware_report, disabled_devices, smbios_model, macos_version, needs_oclp, self.k.kexts, config_data)
        
        print("  4. Applying SMBIOS...")
        smbios_data = self.s.generate_smbios(smbios_model)
        if smbios_data and isinstance(smbios_data, dict):
            config_data["PlatformInfo"]["Generic"].update(smbios_data)

        self.u.write_file(config_file, config_data)
        print(f"  Config written to: {config_file}")


if __name__ == "__main__":
    try:
        auto = AutomatedOCSimplify()
        auto.run()
    except Exception as e:
        import traceback
        print(f"\nERROR: {e}")
        traceback.print_exc()
