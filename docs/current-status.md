# Current Status — macOS Sequoia Boot Attempt

**Date:** 2026-08-24
**Machine:** Custom PC (Ryzen 9 7950X / B850-A / RX 6600)
**Working from:** Mac (remote) — instructions for PC side

---

## Current State

Kernel panic immediately after EXITBS on every attempt. BIOS updated to v1685 (AGESA 1.3.0.1b) — no change. Tested 8+ config variations AND a fresh OCSimplify EFI. This is NOT a config issue and NOT a BIOS issue.

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

## Next Step: DebugEnhancer.kext

The problem is we can't see what the kernel is doing after EXITBS. DebugEnhancer extends kernel logging past that point.

### Instructions (on PC / Windows side)

1. **Download** DebugEnhancer v1.1.1 RELEASE from:
   https://github.com/acidanthera/DebugEnhancer/releases/tag/1.1.1

2. **Extract** and copy `DebugEnhancer.kext` to `W:\EFI\OC\Kexts\`

3. **Add to config.plist** under `Kernel → Add` (after Lilu):
   ```xml
   <dict>
       <key>Arch</key>
       <string>x86_64</string>
       <key>BundlePath</key>
       <string>DebugEnhancer.kext</string>
       <key>Comment</key>
       <string>V1.1.1 - Kernel debug output</string>
       <key>Enabled</key>
       <true/>
       <key>ExecutablePath</key>
       <string>Contents/MacOS/DebugEnhancer</string>
       <key>MaxKernel</key>
       <string></string>
       <key>MinKernel</key>
       <string></string>
       <key>PlistPath</key>
       <string>Contents/Info.plist</string>
   </dict>
   ```

4. **Update boot-args** to:
   ```
   -v debug=0x100 keepsyms=1 agdpmod=pikera npci=0x2000 -dbgenhdbg -dbgenhiolog
   ```

5. **Boot** and watch — you should now get visible kernel panic text on screen, or at minimum a much more detailed log file on the EFI partition.

### What DebugEnhancer Does

- Lilu plugin that enables kernel debug output after EXITBS
- `-dbgenhdbg` turns on debug output
- `-dbgenhiolog` redirects IOLog to screen (kernel vprintf)
- Supports macOS 26 (Tahoe) — fully compatible with Sequoia

### After This Test

If we get a readable panic, likely suspects are:
- **GPU (RX 6600 / WhateverGreen)** — framebuffer init crash
- **NVMe controller** — incompatible drive during early kernel init
- **Memory mapping** — even post-BIOS-update

If GPU is the culprit, next steps would be:
- Disable WhateverGreen (native Navi 23 support in Sequoia)
- Try NootRX instead
- Test with `-wegnoegpu` (black screen but confirms GPU is the issue)

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
