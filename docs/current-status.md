# Current Status — macOS Sequoia Boot Attempt

**Date:** 2026-08-23
**Machine:** Custom PC (Ryzen 9 7950X / B850-A / RX 6600)
**Working from:** This session is on the target PC (Windows/SteamOS)

---

## What Happened

1. Booted from USB EFI (`EFI-20260822`) with fixes: SecureBootModel=Disabled, DmgLoading=Any, PickerMode=Builtin
2. Boot log (`opencore-2026-08-23-134404.txt`) shows kernel collection loaded successfully, EXITBS reached — this is progress
3. Screen showed Apple logo, then rebooted back to picker (kernel panic)
4. **Root cause:** NVRAM has stale boot-args from the internal (June) EFI. The actual boot used wrong args — missing `agdpmod=pikera` (needed for RX 6600) and `-v` (verbose)
5. Can't boot from USB directly — BIOS always grabs the internal NVMe's OpenCore first regardless of boot order

## What Needs to Happen

**Update the internal drive's EFI config.plist** with the macOS boot fixes. The internal EFI is at `EFI-20260627/` in the repo (just a picker shell for Windows/SteamOS — no ACPI/Kexts folders).

### Option A: Replace internal OC entirely
Copy the full USB EFI (`In Development/Sequoia/EFI-20260822/`) to the internal drive's EFI partition, preserving the `Microsoft/` folder. This gives you the kexts, ACPI, drivers, and correct config all in one shot.

### Option B: Merge settings into internal config
Less ideal since the internal EFI lacks kexts/ACPI needed for macOS boot.

### Steps (from Windows):

1. Mount EFI partition:
   ```cmd
   mountvol S: /s
   ```
   Or use DiskGenius / Explorer++ with admin rights

2. Back up current internal EFI:
   ```cmd
   xcopy S:\EFI S:\EFI-backup /E /I
   ```

3. Copy the development EFI over (keep Microsoft/ intact):
   - Delete `S:\EFI\BOOT\` and `S:\EFI\OC\`
   - Copy `EFI-20260822\BOOT\` → `S:\EFI\BOOT\`
   - Copy `EFI-20260822\OC\` → `S:\EFI\OC\`
   - Leave `S:\EFI\Microsoft\` untouched

4. Reset NVRAM on next boot (from the picker)

5. Select macOS installer — should now boot verbose with correct args

## Key Config Settings (EFI-20260822)

| Setting | Value |
|---------|-------|
| SecureBootModel | Disabled |
| DmgLoading | Any |
| PickerMode | Builtin |
| HideAuxiliary | false |
| boot-args | `-v debug=0x100 keepsyms=1 agdpmod=pikera` |
| SMBIOS | iMacPro1,1 |
| Target | 67 (file logging enabled) |
| AppleDebug | true |
| ApplePanic | true |

## Files in This Repo

- `opencore-2026-08-23-134404.txt` — boot log from today's attempt (shows EXITBS success)
- `Machines/Custom-PC/In Development/Sequoia/EFI-20260822/` — the fixed EFI to deploy
- `Machines/Custom-PC/EFI-20260627/` — dump of current internal EFI (picker-only, no kexts)
- `Machines/Custom-PC/CHANGELOG.md` — change history
