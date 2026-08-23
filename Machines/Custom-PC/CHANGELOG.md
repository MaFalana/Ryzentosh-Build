# EFI Changelog — Custom PC (Ryzen 9 7950X / B850-A / RX 6600)

## In Development (2026-08-22)

**Base:** EFI-20250907-sequoia  
**Target:** macOS Sequoia 15.x  
**Status:** Pending test

### Changes from EFI-20250907

| Setting | Before | After | Reason |
|---------|--------|-------|--------|
| SecureBootModel | Default | Disabled | Fix `Err(0xE)` — j137ap manifest validation failing |
| HideAuxiliary | true | false | Show Reset NVRAM in picker |
| PickerMode | External | Builtin | Eliminate OpenCanopy as failure point during debug |
| DmgLoading | Signed | Any | More permissive installer DMG loading |

### Test Instructions

1. Copy `In Development/` contents to USB EFI partition (replace BOOT/ and OC/)
2. Boot to OpenCore picker
3. Select **Reset NVRAM**
4. After reboot, select **Install macOS Sequoia**
5. Photo the screen if it fails at a new point

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
