# Ryzentosh Build

Hackintosh configuration for a custom AMD desktop. Triple-boot: Windows 11, SteamOS, and macOS (each on separate NVMe drives). OpenCore is the primary bootloader, chainloading Windows and SteamOS.

## Status

**macOS Sequoia:** In progress — kernel loads and EXITBS reached, but panics during kernel init (post-EXITBS). Testing with `ProvideCurrentCpuInfo=false` and `npci=0x2000`. EFI-20260822 deployed to internal NVMe.

## Hardware

| Component   | Model                                               |
| ----------- | --------------------------------------------------- |
| Motherboard | ASUS ROG STRIX B850-A Gaming WiFi                   |
| CPU         | AMD Ryzen 9 7950X (16-core, Zen 4)                  |
| GPU         | AMD Radeon RX 6600 (Navi 23, 8GB)                   |
| RAM         | 2x32GB Crucial DDR5 Pro 5600MHz (64GB)              |
| Audio       | AMD High Definition Audio (HDMI), Realtek USB Audio |
| Ethernet    | Intel I226-V                                        |
| WiFi/BT     | BCM94360NG with FV-HB1200 adapter (native macOS)    |
| Storage     | 3x NVMe (Windows, SteamOS, macOS — separate drives) |
| Bluetooth   | Apple Broadcom Built-In (via BCM94360NG)            |

## Project Structure

```
Machines/Custom-PC/
├── EFI-20260627/          Full EFI partition dump (boots OC → Windows/SteamOS)
├── In Development/        Current EFI attempt for macOS Sequoia
├── Archive/               Previous EFI attempts
├── USB-Map/               USB port mapping kexts
└── Screenshots/           Boot logs, system info
```

## Required BIOS Settings

| Setting           | Value    |
| ----------------- | -------- |
| Above 4G Decoding | Enabled  |
| Resizable BAR     | Disabled |
| CSM               | Disabled |
| Secure Boot       | Disabled |
| IOMMU             | Disabled |
| XHCI Hand-off     | Enabled  |
| Serial Port       | Disabled |

## Working

*Pending successful boot*

## Not Working

*Pending successful boot*

## Kexts

| Kext                     | Purpose                                     |
| ------------------------ | ------------------------------------------- |
| Lilu                     | Patching framework (required by all others) |
| VirtualSMC               | SMC emulation                               |
| WhateverGreen            | GPU patching (RX 6600)                      |
| AppleIGC                 | Intel I226-V Ethernet (disabled for now)    |
| AppleMCEReporterDisabler | Prevents MCE crashes on AMD                 |
| NVMeFix                  | NVMe power management                       |
| RestrictEvents           | CPU name display, SB patches                |
| SMCRadeonSensors         | GPU temp monitoring                         |
| USBToolBox + USBMap      | USB port mapping                            |

## ACPI Patches

| SSDT                      | Purpose                                        |
| ------------------------- | ---------------------------------------------- |
| SSDT-EC                   | Fake Embedded Controller                       |
| SSDT-PLUG-ALT             | AMD CPU power management                       |
| SSDT-USB-Reset            | USB controller reset                           |
| SSDT-USBX                 | USB power properties                           |
| SSDT-Disable_Network_GPP7 | Disables onboard Intel WiFi (using BCM94360NG) |

## Acknowledgements

- [Dortania OpenCore Guide](https://dortania.github.io/OpenCore-Install-Guide/)
- [AMD OS X Vanilla Patches](https://github.com/AMD-OSX/AMD_Vanilla) (algrey, Shaneee, CaseySJ, XLNC, Visual, Goldfish64, Zormeister)
- [AppleIGC](https://github.com/SongXiaoXi/AppleIGC) for Intel I226-V support
