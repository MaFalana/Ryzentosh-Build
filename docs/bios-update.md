# BIOS Update — ROG STRIX B850-A Gaming WiFi

**From:** Version 0806 (AGESA ComboAM5PI_1202, Oct 2024)
**To:** Version 1685 Beta (AGESA ComboAM5 PI 1.3.0.1b Patch A, July 2026)

---

## Method: EZ Flash (through BIOS)

This is the safest method since you're already able to boot into BIOS.

### What You Need

- A USB flash drive (any size, formatted as FAT32)
- The BIOS file downloaded from ASUS

### Steps

1. **Download** the BIOS from the ASUS support page
2. **Extract** the ZIP file — you'll get a .CAP file
3. **Rename** the file to `AS597.CAP` using BIOSRenamer (included in the ZIP) or manually
4. **Copy** `AS597.CAP` to the root of a FAT32-formatted USB drive
5. **Plug** the USB drive into one of the rear USB ports on your motherboard
6. **Reboot** into BIOS (press DEL on startup)
7. Go to **Tool** tab → **ASUS EZ Flash 3 Utility**
8. Select your USB drive and find `AS597.CAP`
9. Select the file and confirm when prompted
10. **Wait** — the update takes 3-5 minutes. The system will reboot automatically
11. **Do NOT** power off or unplug during the update

### After Update

1. BIOS settings will be reset to defaults
2. Re-enter BIOS and re-apply your settings:
   - CSM: **Disabled**
   - Secure Boot: OS Type → **Other OS**
   - Above 4G Decoding: **Enabled**
   - Resize BAR: **Disabled**
   - SR-IOV: **Disabled**
3. Save and exit
4. Boot into Windows to confirm everything works
5. Then try OpenCore → macOS installer again

### Important Notes

- This is a **Beta** BIOS — it should be stable but isn't fully validated by ASUS
- The AGESA jump from 1.2.0.2 → 1.3.0.1b is significant and may fix memory mapping issues affecting macOS
- If anything goes wrong, you can use **BIOS Flashback** (physical button on rear I/O) to recover without CPU/RAM installed
- Your Windows and SteamOS installations will NOT be affected by a BIOS update

---

## Alternative Method: BIOS Flashback (USB button)

Use this only if you can't get into BIOS at all.

1. Rename the BIOS file to `AS597.CAP`
2. Copy to root of FAT32 USB drive
3. Power off the PC completely
4. Plug the USB into the **BIOS Flashback USB port** (check manual — usually marked with a label on the rear I/O)
5. Press and hold the **BIOS Flashback button** for 3 seconds until the LED starts flashing
6. Wait until the LED stops flashing (3-5 minutes)
7. Done — power on and enter BIOS to configure settings
