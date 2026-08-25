# Current Status — macOS Sequoia Boot Attempt

**Date:** 2026-08-24
**Machine:** Custom PC (Ryzen 9 7950X / B850-A / RX 6600)
**Working from:** Mac (remote) — instructions for PC side

---

## Current State

Kernel panic immediately after EXITBS on every attempt. BIOS updated to v1685 — no change. DebugEnhancer loaded — no output (crash is pre-kext-load). 

**BREAKTHROUGH:** Found a forum thread where someone with an MSI B850 + RX 6800 had the EXACT same EXITBS problem and solved it. The fix was **disabling WhateverGreen** + BIOS tweaks + proper MMIO handling.

Source: https://forum.amd-osx.com/threads/tahoe-installation-on-b850.6337/

## What's Been Ruled Out

- ProvideCurrentCpuInfo (on/off)
- npci=0x2000 boot-arg
- SMBIOS (iMacPro1,1 and MacPro7,1)
- PAT patches (algrey, Shaneee, both disabled + mtrr_update_action=0)
- IOPCIIsHotplugPort patch (on/off)
- CSM (was enabled — now disabled)
- Fresh OCSimplify config (OC 1.0.8, fresh kexts, fresh patches)
- BIOS update v0806 → v1685 (AGESA 1.2.0.2 → 1.3.0.1b) — no change
- Different USB port
- Different macOS version (Monterey) — same issue
- DebugEnhancer.kext — no output (crash too early for Lilu plugins)

## Next Step: Disable WhateverGreen + BIOS Changes

A confirmed working B850 build (MSI MAG B850 Tomahawk + 9800X3D + RX 6800) got past EXITBS by:
1. Disabling WhateverGreen (RDNA2 GPUs have native support)
2. Enabling Resizable BAR
3. Using `DisableVariableWrite=true` in Booter quirks
4. Disabling WiFi/Ethernet in BIOS during testing

### Instructions (on PC / Windows side)

#### BIOS Changes

1. **Enable Resizable BAR** (currently disabled — change to Enabled)
2. **Disable WiFi** (onboard Intel — not macOS compatible anyway)
3. **Disable Ethernet** (Intel I226-V — temporarily for testing)
4. **Confirm Fast Boot is OFF**
5. Keep Above 4G Decoding Enabled, CSM Disabled

#### Config.plist Changes

1. **Disable WhateverGreen:**
   - Find WhateverGreen.kext entry under `Kernel → Add`
   - Change `<true/>` to `<false/>` for its `Enabled` key

2. **Add `DisableVariableWrite=true`:**
   - Under `Booter → Quirks`
   - Change `DisableVariableWrite` from `<false/>` to `<true/>`

3. **Update boot-args:**
   ```
   -v debug=0x100 keepsyms=1 npci=0x2000
   ```
   - REMOVED: `agdpmod=pikera` (this is a WhateverGreen arg, does nothing without WEG)
   - iMacPro1,1 SMBIOS has native dGPU support, so board-id check shouldn't trigger

4. **Keep these Booter quirks as-is:**
   - `DevirtualiseMmio=true` (should already be set from OCSimplify fix)
   - `SetupVirtualMap=false` (required for AM5)
   - `RebuildAppleMemoryMap=true`
   - `SyncRuntimePermissions=true`

#### Boot Test

1. Save config.plist
2. Reboot → OpenCore picker
3. Reset NVRAM (to clear old boot-args with agdpmod)
4. After reboot, select macOS installer
5. Watch for verbose text — you should get further than EXITBS now

### What to Expect

- **If it works:** You'll see verbose scrolling text, possibly a 30-second black screen (this is normal for RDNA2 without WEG), then either installer or a readable kernel panic
- **If same crash:** The GPU isn't the issue — would need to look at NVMe or get fabiosun's actual EFI config from the forum thread

### Reference: Working B850 Config (from forum)

The user `fabiosun` (runs ASUS X870E Hero + 9950X + dual 6950XT on Tahoe) provided configs that worked. Key differences from standard Dortania guide:
- No WhateverGreen
- `DisableVariableWrite=true` alongside `DevirtualiseMmio=true`
- Resizable BAR enabled (not disabled like Dortania suggests for AMD)
- WiFi/LAN disabled in BIOS during initial boot
- Fresh USB installer (not cloned drive)

## EFI On Internal Drive

Fresh OCSimplify-generated config (OpenCore 1.0.8):
- SMBIOS: iMacPro1,1
- boot-args: `-v debug=0x100 keepsyms=1 agdpmod=pikera npci=0x2000`
- SecureBootModel: Disabled
- DmgLoading: Any
- PickerMode: Builtin
- Target: 67 (file logging)
- Kexts: Lilu 1.7.3, VirtualSMC 1.3.8, WhateverGreen 1.7.1, AppleIGC, NVMeFix, RestrictEvents, AppleMCEReporterDisabler

## Key Files

- `W:\EFI\OC\config.plist` — live config on internal NVMe
- `Machines/Custom-PC/In Development/Sequoia/EFI-20260822/` — previous manual config
- `Scripts/run_ocsimplify.py` — automated OCSimplify runner
- OpenCore logs: `W:\opencore-2026-08-24-*.txt`
