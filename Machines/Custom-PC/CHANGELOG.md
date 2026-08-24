# EFI Changelog — Custom PC (Ryzen 9 7950X / B850-A / RX 6600)

## In Development (2026-08-23)

**Base:** EFI-20250907-sequoia  
**Target:** macOS Sequoia 15.x  
**Status:** Kernel panic after EXITBS — testing fixes

### Changes from EFI-20250907

| Setting               | Before                                     | After                                                  | Reason                                              |
| --------------------- | ------------------------------------------ | ------------------------------------------------------ | --------------------------------------------------- |
| SecureBootModel       | Default                                    | Disabled                                               | Fix `Err(0xE)` — j137ap manifest validation failing |
| HideAuxiliary         | true                                       | false                                                  | Show Reset NVRAM in picker                          |
| PickerMode            | External                                   | Builtin                                                | Eliminate OpenCanopy as failure point during debug  |
| DmgLoading            | Signed                                     | Any                                                    | More permissive installer DMG loading               |
| ProvideCurrentCpuInfo | true                                       | false                                                  | Suspected Zen 4 + Sequoia kernel panic cause        |
| boot-args             | `-v debug=0x100 keepsyms=1 agdpmod=pikera` | `-v debug=0x100 keepsyms=1 agdpmod=pikera npci=0x2000` | AM5/B850 PCI config space fix                       |

### Progress

- 2026-08-22: SecureBootModel+DmgLoading fix → kernel loads, EXITBS reached
- 2026-08-23: Deployed to internal NVMe EFI partition (replaces EFI-20260627 OC/BOOT)
- 2026-08-23: Boot-args confirmed correct via OC debug logs (agdpmod=pikera present)
- 2026-08-23: Kernel panic immediately after EXITBS (no verbose output visible — GPU dies)
- 2026-08-23: Disabled ProvideCurrentCpuInfo + added npci=0x2000 — testing

### Test Instructions

1. EFI is deployed to internal NVMe (W:\EFI\OC on Disk 1)
2. Boot to OpenCore picker (text mode)
3. Select **Install macOS Sequoia (external)**
4. Should boot verbose — watch for kernel panic text
5. If crash with no output: GPU failing before console init

---

## EFI-20250907-sequoia

**Status:** Failed — `Err(0xE)` at Secure Boot validation  
**Error:** `EB|LD.OFS|OPEN| Err(0xE) <"usr\standalone\OS.dmg.root_hash">`  
**Root cause:** SecureBootModel=Default with newer installer signing

---

## EFI-20250802-sequoia

**Status:** Failed  
**Notes:** Earlier attempt, same general issue

---

## EFI-tahoe (undated)

**Status:** Failed  
**Notes:** macOS Tahoe attempt with NootRX instead of WhateverGreen. Same SecureBootModel issue likely present.
