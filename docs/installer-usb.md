# Multi-Boot Installer USB

Create a single 256GB USB drive with multiple OS installers, partitioned and ready to boot via OpenCore or UEFI firmware.

**Created from:** macOS (Apple Silicon M4 Mac)  
**USB Drive:** 256GB SanDisk (shows as ~250GB)  
**Partition Scheme:** GUID (GPT)

---

## Layout

| Partition | Name | Format | Size | Contents |
|-----------|------|--------|------|----------|
| 1 | EFI | FAT32 | 200MB | OpenCore (for macOS installers) |
| 2 | Sequoia | Mac OS Extended (Journaled) | 16GB | macOS Sequoia installer |
| 3 | (future) | Mac OS Extended (Journaled) | 16GB | Additional macOS version |
| 4 | (future) | Mac OS Extended (Journaled) | 16GB | Additional macOS version |
| 5 | WINDOWS11 | FAT32 | 8GB | Windows 11 installer (split WIM) |
| 6 | (free space) | — | remainder | For future use |

> **Note on SteamOS:** The SteamOS recovery image uses `dd` to write a raw disk image, which expects the entire USB drive. It cannot be cleanly placed as a partition alongside other installers. Keep a separate small USB for SteamOS, or store the `.img` file on the Windows partition for later `dd` writing.

---

## Prerequisites

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install wimlib (for splitting Windows install.wim)
brew install wimlib
```

---

## Step 1: Identify Your USB Drive

```bash
diskutil list
```

Find your USB (e.g., `disk4`). **Double-check the disk number — erasing the wrong disk is irreversible.**

---

## Step 2: Partition the USB Drive

```bash
# Replace disk4 with your actual disk number
sudo diskutil partitionDisk /dev/disk4 GPT \
  FAT32 EFI 200MB \
  JHFS+ Sequoia 16GB \
  FAT32 WINDOWS11 8GB \
  Free Free 0
```

This creates:
- A 200MB FAT32 EFI partition
- A 16GB HFS+ partition for macOS Sequoia
- An 8GB FAT32 partition for Windows 11
- Remaining space left free (add more macOS partitions later with Disk Utility)

> **To add more macOS partitions later**, use Disk Utility or:
> ```bash
> sudo diskutil addPartition disk4s4 JHFS+ Sonoma 16GB
> ```

---

## Step 3: Create the macOS Sequoia Installer

### Download Sequoia

```bash
softwareupdate --fetch-full-installer --full-installer-version 15.0
```

This downloads to `/Applications/Install macOS Sequoia.app` (~14GB).

> **Other versions:**
> ```bash
> softwareupdate --fetch-full-installer --full-installer-version 14.0  # Sonoma
> softwareupdate --fetch-full-installer --full-installer-version 13.0  # Ventura
> softwareupdate --fetch-full-installer --full-installer-version 12.0  # Monterey
> ```

### Write to USB

```bash
sudo /Applications/Install\ macOS\ Sequoia.app/Contents/Resources/createinstallmedia \
  --volume /Volumes/Sequoia \
  --nointeraction
```

Wait for it to finish (~15-20 min). The volume will be renamed to "Install macOS Sequoia".

---

## Step 4: Copy OpenCore EFI to USB

### Mount the USB's EFI partition

Using [MountEFI](https://github.com/corpnewt/MountEFI):
```bash
# If you have MountEFI installed
python3 ~/path/to/MountEFI/MountEFI.command
```

Or manually:
```bash
# Find the EFI partition (usually disk4s1)
diskutil list /dev/disk4

# Mount it
sudo diskutil mount /dev/disk4s1
```

### Copy the EFI files

```bash
# Copy from In Development to the mounted EFI partition
cp -R "/path/to/Ryzentosh-Build/Machines/Custom-PC/In Development/Sequoia/EFI-20260822/"* /Volumes/EFI/
```

Verify the structure looks like:
```
/Volumes/EFI/
├── BOOT/
│   └── BOOTx64.efi
└── OC/
    ├── config.plist
    ├── ACPI/
    ├── Drivers/
    ├── Kexts/
    └── Resources/
```

---

## Step 5: Create Windows 11 Installer Partition

### Download Windows 11 ISO

Download from [Microsoft](https://www.microsoft.com/en-us/software-download/windows11) — get the x64 ISO.

### Mount the ISO

```bash
hdiutil mount ~/Downloads/Win11_*.iso
```

It'll mount to something like `/Volumes/CCCOMA_X64FRE_EN-US_DV9`.

### Copy files to USB (excluding install.wim)

```bash
# Copy everything except the large install.wim
rsync -avh --progress --exclude='sources/install.wim' \
  /Volumes/CCCOMA_X64FRE_EN-US_DV9/ /Volumes/WINDOWS11/
```

### Split install.wim and copy

```bash
wimlib-imagex split \
  /Volumes/CCCOMA_X64FRE_EN-US_DV9/sources/install.wim \
  /Volumes/WINDOWS11/sources/install.swm \
  3800
```

This splits the >4GB file into ~3.8GB chunks that fit on FAT32. Windows Setup recognizes `.swm` files automatically during installation.

### Unmount the ISO

```bash
hdiutil unmount /Volumes/CCCOMA_X64FRE_EN-US_DV9
```

---

## Step 6: SteamOS (Separate USB)

SteamOS recovery uses a raw disk image that overwrites the entire USB, so it needs its own drive.

### Download

Get the recovery image from [Steam Support](https://store.steampowered.com/steamos/download/?ver=steamdeck&snr=):
- File: `steamdeck-recovery-*.img.bz2`

### Decompress

```bash
bunzip2 steamdeck-recovery-*.img.bz2
```

### Write to a separate USB

```bash
# Identify your SteamOS USB (e.g., disk5)
diskutil list

# Unmount it
diskutil unmountDisk /dev/disk5

# Write the image (BE VERY CAREFUL with disk number)
sudo dd if=steamdeck-recovery-*.img of=/dev/rdisk5 bs=4M status=progress

# Eject
diskutil eject /dev/disk5
```

---

## Booting

| OS | Boot method |
|----|-------------|
| macOS Sequoia | Boot USB → OpenCore picker → "Install macOS Sequoia" |
| Windows 11 | Boot USB → UEFI firmware boot menu → select "WINDOWS11" partition |
| SteamOS | Boot separate SteamOS USB → select from UEFI boot menu |

> **Tip:** For macOS installs on Hackintosh, always boot through OpenCore (it applies the AMD patches). For Windows/SteamOS installs, you can boot directly from UEFI firmware if preferred.

---

## Adding More macOS Versions Later

```bash
# Add a new 16GB partition
sudo diskutil addPartition disk4sX JHFS+ Sonoma 16GB

# Download and write
softwareupdate --fetch-full-installer --full-installer-version 14.0
sudo /Applications/Install\ macOS\ Sonoma.app/Contents/Resources/createinstallmedia \
  --volume /Volumes/Sonoma \
  --nointeraction
```

---

## Quick Reference

| Task | Command |
|------|---------|
| List disks | `diskutil list` |
| Mount EFI | `sudo diskutil mount /dev/diskXs1` |
| Download macOS | `softwareupdate --fetch-full-installer --full-installer-version XX.X` |
| Split WIM | `wimlib-imagex split <src> <dst> 3800` |
| Write raw image | `sudo dd if=<img> of=/dev/rdiskX bs=4M status=progress` |

---

## References

- [Apple: Create a bootable installer for macOS](https://support.apple.com/en-us/101578)
- [Microsoft: Download Windows 11](https://www.microsoft.com/en-us/software-download/windows11)
- [Steam Support: SteamOS Recovery](https://store.steampowered.com/steamos/download/?ver=steamdeck&snr=)
- [wimlib documentation](https://wimlib.net/)
- [MountEFI by corpnewt](https://github.com/corpnewt/MountEFI)
