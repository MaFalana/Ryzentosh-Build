# Current Status — macOS Sequoia Boot Attempt

**Date:** 2026-08-24
**Machine:** Custom PC (Ryzen 9 7950X / B850-A / RX 6600)
**Working from:** Target PC (Windows)

---

## Current State

Kernel panic immediately after EXITBS on every attempt. Tested 8+ config variations AND a completely fresh OCSimplify-generated EFI — all produce the same failure. This confirms the issue is NOT config-related.

## What's Been Ruled Out

- ProvideCurrentCpuInfo (on/off)
- npci=0x2000 boot-arg
- SMBIOS (iMacPro1,1 and MacPro7,1)
- PAT patches (algrey, Shaneee, both disabled + mtrr_update_action=0)
- IOPCIIsHotplugPort patch (on/off)
- CSM (was enabled — now disabled)
- Fresh OCSimplify config (OC 1.0.8, fresh kexts, fresh patches)

## What Still Needs Testing

1. **BIOS update to version 1685** (AGESA ComboAM5 PI 1.3.0.1b Patch A, July 2026) — most likely fix
2. Different USB port — tried, didn't help
3. Different macOS version — tried Monterey, same issue
4. Confirmed NOT a config issue (OCSimplify fresh config also fails)

## EFI On Internal Drive

Fresh OCSimplify-generated config (OpenCore 1.0.8):
- SMBIOS: iMacPro1,1
- boot-args: `-v debug=0x100 keepsyms=1 agdpmod=pikera`
- SecureBootModel: Disabled
- DmgLoading: Any
- PickerMode: Builtin
- Target: 67 (file logging)
- Kexts: Lilu 1.7.3, VirtualSMC 1.3.8, WhateverGreen 1.7.1, AppleIGC, NVMeFix, RestrictEvents, AppleMCEReporterDisabler

## Key Files

- `W:\EFI\OC\config.plist` — live OCSimplify config
- `Machines/Custom-PC/In Development/Sequoia/EFI-20260822/` — previous manual config
- `Scripts/run_ocsimplify.py` — automated OCSimplify runner
- OpenCore logs: `W:\opencore-2026-08-24-*.txt`
