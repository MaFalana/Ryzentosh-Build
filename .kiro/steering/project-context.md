---
inclusion: auto
---

# Project Context: Ryzentosh Build

> Last Updated: 2026-08-22
> Last Scanned: 2026-08-22

## Project Overview

A Hackintosh (Ryzentosh) build configuration repository for running macOS Sequoia on an AMD Ryzen 9 7950X system with an ASUS ROG STRIX B850-A Gaming WiFi motherboard and AMD Radeon RX 6600 GPU. Uses OpenCore bootloader with AMD kernel patches. The repo stores versioned EFI configurations, setup automation scripts, and remote connection profiles for managing the custom PC alongside other devices.

## Tech Stack

- **Bootloader:** OpenCore (latest EFI dated 2026-06-27)
- **Target OS:** macOS Sequoia (15.x) → macOS Tahoe (26.x, upgrade in progress)
- **CPU Architecture:** AMD Zen 4 (Ryzen 9 7950X, 16-core)
- **Platform:** AM5 / B850 chipset
- **SMBIOS:** iMacPro1,1
- **Kernel Patches:** AMD Vanilla (algrey, CaseySJ, Visual, Shaneee/Zormeister patches)
- **Setup Automation:** Zsh shell scripts (Homebrew, pyenv, CLI/GUI apps)
- **Remote Access:** Microsoft Remote Desktop (.rdp), FileZilla (SFTP/FTP)
- **Version Control:** Git (hosted on GitHub/remote)

## Architecture

```
Ryzentosh-Build/
├── _EFI (20260627)/                  # Latest EFI partition backup (June 2026, active)
│   ├── BOOT/
│   ├── Microsoft/                    # Windows Boot Manager (dual-boot)
│   └── OC/
│       ├── config.plist              # Current OpenCore config
│       ├── oldConfig.plist           # Previous config (kept for reference)
│       ├── Drivers/
│       ├── Resources/
│       └── Tools/
├── Tahoe/                            # macOS Tahoe (26.x) EFI — upgrade in progress
│   └── EFI/
│       ├── BOOT/
│       └── OC/
│           ├── config.plist
│           ├── ACPI/                 # Same SSDTs as Sequoia
│           ├── Drivers/
│           ├── Kexts/                # NootRX replaces WhateverGreen; SMCRadeonSensors dropped
│           └── Resources/
├── Sequioa/                          # macOS Sequoia EFI configurations (historical)
│   ├── EFI 20250802/                 # Earlier EFI snapshot
│   └── EFI 20250907/                 # Working Sequoia config
├── UM560 XT Drivers/                 # Drivers/BIOS for Minisforum UM560 XT (secondary machine)
│   ├── Bios/
│   ├── Drivers/
│   └── amd-software-adrenalin-edition-26.1.1-*.exe
├── Remote Connections/               # RDP files for remote access
├── Programming Setup - Mac (Silicoln) 2025.command  # Dev environment bootstrap script
├── macOS Install Prompts.command     # createinstallmedia commands reference
├── FileZilla Script.command          # FileZilla install + app organization script
├── FileZilla.xml                     # FTP/SFTP server bookmarks
├── README.md                         # Hardware specs (this build)
└── README 2.md                       # Reference: minisforum U820 hackintosh guide
```

The project follows a date-based EFI versioning pattern (`EFI YYYYMMDD`) — each snapshot is a complete, standalone EFI partition backup. The `_EFI` prefix with underscore indicates the currently active EFI partition backup.

## Key Files & Entry Points

| Path | Description |
|------|-------------|
| `_EFI (20260627)/OC/config.plist` | **Active config** — currently deployed EFI partition (June 2026) |
| `_EFI (20260627)/OC/oldConfig.plist` | Previous config backup |
| `Tahoe/EFI/OC/config.plist` | macOS Tahoe EFI config (upgrade target) |
| `Sequioa/EFI 20250907/OC/config.plist` | Sequoia config (historical, working) |
| `Sequioa/EFI 20250907/OC/ACPI/` | SSDT patches: EC, PLUG-ALT, USB Reset, USBX, Network disable |
| `README.md` | Hardware specification table for this build |
| `Programming Setup - Mac (Silicoln) 2025.command` | Full dev environment setup (Homebrew, apps, Python, Git) |
| `macOS Install Prompts.command` | createinstallmedia commands (reference for USB installers) |
| `Remote Connections/Custom PC.rdp` | RDP connection to this machine (hostname: DESKTOP-HNJ2RAT) |

## Hardware Specification

| Component | Model |
|-----------|-------|
| Motherboard | ASUS ROG STRIX B850-A Gaming WiFi |
| CPU | AMD Ryzen 9 7950X (16-core, Zen 4) |
| GPU | AMD Radeon RX 6600 |
| RAM | 2x32GB Crucial DDR5 Pro 5600MHz (64GB total) |
| Audio | AMD High Definition Audio Device |
| Ethernet | Intel I226-V |
| WiFi/BT | BCM94360NG with FV-HB1200 adapter (native macOS support) |
| Storage | 500GB NVMe SSD |
| Bluetooth | Apple Broadcom Built-In Bluetooth (via BCM94360NG) |

## Kexts (Kernel Extensions)

### Sequoia Config (EFI 20250907)

| Kext | Version | Purpose | Enabled |
|------|---------|---------|---------|
| Lilu | 1.7.2 | Patching framework (required by all other kexts) | ✅ |
| VirtualSMC | 1.3.8 | SMC emulation (required for macOS boot) | ✅ |
| WhateverGreen | 1.7.1 | GPU patching and fixes | ✅ |
| AppleIGC | 1.6d1 | Intel I226-V Ethernet driver | ❌ (disabled) |
| AppleMCEReporterDisabler | 1.2 | Prevents MCE crashes on AMD | ✅ |
| NVMeFix | 1.1.4 | NVMe power management fix | ✅ |
| RestrictEvents | 1.1.7 | CPU name, memory warnings, SB patches | ✅ |
| SMCRadeonSensors | 2.4.0 | GPU temperature monitoring | ✅ |
| USBToolBox | 1.1.1 | USB port mapping tool | ✅ |
| USBMap | 1.1 | Custom USB port map | ✅ |
| XHCI-unsupported | — | XHCI controller support (present in EFI) | — |

### Tahoe Config (new)

| Kext | Purpose | Notes |
|------|---------|-------|
| Lilu | Patching framework | Carried over |
| VirtualSMC | SMC emulation | Carried over |
| **NootRX** | RDNA GPU driver (replaces WhateverGreen) | **New** — required for Tahoe GPU support |
| AppleIGC | Intel I226-V Ethernet | Present (status TBD) |
| AppleMCEReporterDisabler | Prevents MCE crashes | Carried over |
| NVMeFix | NVMe power management | Carried over |
| RestrictEvents | CPU name, SB patches | Carried over |
| USBToolBox | USB port mapping tool | Carried over |
| USBMap | Custom USB port map | Carried over |

**Dropped from Tahoe:** WhateverGreen (replaced by NootRX), SMCRadeonSensors, XHCI-unsupported

## ACPI Patches (SSDTs)

| SSDT | Purpose |
|------|---------|
| SSDT-Disable_Network_GPP7 | Disables onboard Intel network controller (replaced by BCM94360NG) |
| SSDT-EC | Fake Embedded Controller for macOS |
| SSDT-PLUG-ALT | CPU power management (AMD alternative) |
| SSDT-USB-Reset | USB controller reset |
| SSDT-USBX | USB power properties |

## Boot Arguments

```
-v debug=0x100 keepsyms=1 agdpmod=pikera
```

- `-v` — Verbose boot (shows text log during boot)
- `debug=0x100` — Prevent reboot on panic (shows crash info)
- `keepsyms=1` — Keep symbols for panic logs
- `agdpmod=pikera` — Disable board-id check for AMD GPUs (required for RX 6600)

## NVRAM Notable Settings

- **CPU Name Display:** `AMD Ryzen 9 7950X 16-Core Processor` (via RestrictEvents + revcpuname)
- **Patches:** `sbvmm,cpuname` (RestrictEvents: bypass SB VM check, rename CPU)
- **SIP:** Partially disabled (`csr-active-config` = `030A0000`)
- **EFI Updater:** Disabled (`run-efi-updater` = No)

## Active Work Streams

- **macOS Tahoe upgrade in progress** — New `Tahoe/` EFI with NootRX replacing WhateverGreen (key GPU kext change for Tahoe compatibility)
- Active EFI is dated June 27, 2026 (`_EFI (20260627)`) — confirms ongoing maintenance
- `_EFI` includes Microsoft boot manager — dual-boot with Windows is active
- Tahoe EFI drops SMCRadeonSensors and XHCI-unsupported (likely no longer needed)
- UM560 XT Drivers folder added — secondary machine (Minisforum mini PC) being managed
- Build appears functional with macOS Sequoia (screenshots from Sep 2025)
- README "Working" and "Not Working" sections still empty

## Decisions Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-06-27 | Active EFI backup includes Microsoft boot loader | Dual-boot Windows + macOS confirmed |
| 2026-06 | NootRX replaces WhateverGreen for Tahoe | NootRX is the successor GPU kext for RDNA GPUs on newer macOS versions |
| 2026-06 | Drop SMCRadeonSensors in Tahoe | Likely integrated into NootRX or no longer compatible |
| 2026-06 | Drop XHCI-unsupported in Tahoe | USB controllers properly supported in newer macOS |
| 2025-09-07 | Use iMacPro1,1 SMBIOS | Best match for AMD + dGPU (no iGPU) configurations |
| 2025-09-07 | BCM94360NG WiFi/BT card | Native macOS support — no kext needed for AirDrop, Handoff, Continuity |
| 2025-09-07 | Disable onboard Intel network via SSDT | Replaced by BCM94360NG; prevents conflicts |
| 2025-09-07 | Shaneee PAT patch over algrey | `_mtrr_update_action` — Shaneee variant enabled for both ≤13 and 15.0+ |
| 2025-09-07 | CaseySJ PCI patches for AM5 | Fix PCI bus enumeration + disable 10-bit tags (required for B850/AM5) |
| 2025-09-07 | Verbose boot (`-v`) kept enabled | Still in active development/troubleshooting phase |
| 2025-09-07 | SecureBootModel = Default | Allows OTA updates while maintaining SB compatibility |
| 2025-09-07 | DummyPowerManagement = true | Required for AMD CPUs — prevents XCPM crashes |

## Open Questions

- What is currently working vs. not working? (README sections are blank)
- Is macOS Tahoe booting successfully with the new EFI? (Tahoe folder exists but status unknown)
- Is the `_EFI (20260627)` running Sequoia or Tahoe?
- Is Intel I226-V Ethernet functional? (AppleIGC kext present in Tahoe EFI)
- Is sleep/wake working properly on this AM5 platform?
- Audio setup — no audio kext (AppleALC) present; is AMD HDMI audio sufficient?
- Should verbose boot be disabled for daily use?
- What's the role of UM560 XT mini PC — secondary Hackintosh or Windows-only?
- Has the SMBIOS changed for Tahoe (iMacPro1,1 may need updating)?

## Conventions & Patterns

- **EFI Versioning:** Date-stamped folders (`EFI YYYYMMDD`) — complete snapshots, not incremental diffs
- **macOS Spelling:** Directory uses "Sequioa" (typo preserved from folder name)
- **Setup Scripts:** `.command` extension for double-click execution on macOS
- **Remote Connections:** Stored as `.rdp` files in a dedicated folder
- **Reference Material:** `README 2.md` is a reference from another hackintosh project (daliansky/minisforum-u820), not this build's documentation

## Dependencies & Integrations

- **OpenCore:** Primary bootloader — all EFI structure follows OC conventions
- **Acidanthera ecosystem:** Lilu, VirtualSMC, WhateverGreen, NVMeFix, RestrictEvents
- **AMD OS X patches:** algrey/Shaneee/CaseySJ/Visual/XLNC/Goldfish64/Zormeister kernel patches
- **Dortania Guide:** Architecture follows Dortania's OpenCore Install Guide for AMD
- **Remote Desktop:** Windows RDP to `DESKTOP-HNJ2RAT` (likely dual-boot or separate Windows install)
- **FileZilla connections:** CSCI server (tesla.cs.iupui.edu), Nintendo Switch, PS3 Slim, Steam Deck
- **Dev Environment (Mac):** Homebrew, VS Code, Docker, Azure CLI, Node, pyenv (Python 3.11.9/3.12.7), QGIS, CloudCompare

## Notes

- The `README 2.md` file is a complete reference guide from the daliansky/minisforum-u820-hackintosh project — useful for OC configuration patterns but documents a completely different (Intel-based) machine
- The build uses the "Custom" UpdateSMBIOSMode — important for AMD systems to prevent SMBIOS injection issues with Windows dual-boot
- Kernel patches support macOS versions from 10.13 through 25.99.99 (future-proofed through macOS Tahoe)
- The `Programming Setup - Mac (Silicoln) 2025.command` script is designed for Apple Silicon Macs (uses `/opt/homebrew`) — may need adaptation if used on this Hackintosh (Intel path: `/usr/local`)
- Git identity: Malik Falana (malikfalana@icloud.com)
- **UM560 XT Drivers** folder contains BIOS and GPU drivers (Adrenalin 26.1.1) for a Minisforum UM560 XT mini PC — likely a secondary machine in the setup
- **`_EFI (20260627)`** is a full EFI partition dump including the Windows boot manager — confirms active dual-boot
- The `macOS Install Prompts.command` stores `createinstallmedia` commands for reference (currently only has Monterey commands — may be outdated)
- **NootRX** in the Tahoe config is a significant change — it's the ChefKissInc successor to WhateverGreen for RDNA GPUs, providing native-like GPU acceleration
