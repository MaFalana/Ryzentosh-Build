# Skill Observations Log

<!-- Observations are appended below. Each new observation increments the number by 1. -->

### Observation 1: Project organization preferences emerge through iteration

**Status:** OPEN
**Date:** 2026-08-22
**Disposition:** AGENT-ACTION
**Session context:** Reorganizing the Ryzentosh-Build repository structure
**Skill:** New skill candidate: Project scaffolding from user preferences
**Phase/Area:** Structure negotiation

**Issue:** The final folder structure required 4-5 rounds of back-and-forth to nail down. User had clear opinions about naming (`Archive` not `EFI-Archive`, `In Development` not `EFI-Dev`, datestamp-only unless collisions, macOS version subfolders) but these emerged one at a time rather than upfront.

**Suggested improvement:** When proposing a project structure, present naming conventions as explicit decision points rather than baking in assumptions. Ask about nesting/grouping strategy early.

**Principle:** Let the user define naming conventions — propose structure, but present names as choices rather than defaults.

---

### Observation 2: Full EFI partition dumps have value beyond just the OC config

**Status:** OPEN
**Date:** 2026-08-22
**Disposition:** USER-ACTION
**Session context:** Discussing where the "complete" EFI lives
**Skill:** New skill candidate: Hackintosh EFI management workflow
**Phase/Area:** Understanding user's mental model

**Issue:** Initially proposed separating the Microsoft boot manager from the OC config. User corrected this — the full partition dump (including Microsoft/) is valuable because it preserves the boot priority chain they spent time configuring. The dump IS the working state.

**Suggested improvement:** For Hackintosh projects, treat EFI partition dumps as atomic units. Don't suggest decomposing them unless asked.

**Principle:** Respect the user's investment in configuration state — don't propose splitting things that work as a unit.

---

### Observation 3: GitHub file size limits require proactive gitignore for driver folders

**Status:** OPEN
**Date:** 2026-08-22
**Disposition:** AGENT-ACTION
**Session context:** Git push failed due to UM560-XT driver files exceeding 100MB
**Skill:** New skill candidate: Repository hygiene for hardware projects
**Phase/Area:** Pre-commit checks

**Issue:** The push failed because AMD GPU drivers contain files >100MB. This was predictable — driver packages are always large binaries. Should have added the gitignore before staging.

**Suggested improvement:** When reorganizing repos that contain hardware drivers or large binaries, check file sizes and add gitignore entries BEFORE committing, not after a failed push.

**Principle:** Anticipate size constraints before pushing. Large binary folders (drivers, installers, firmware) should be gitignored proactively.

---

### Observation 4: SecureBootModel is the most common Sequoia boot failure on Hackintosh

**Status:** OPEN
**Date:** 2026-08-22
**Disposition:** AGENT-ACTION
**Session context:** Diagnosing boot failure from verbose boot screenshots
**Skill:** New skill candidate: Hackintosh boot debugging
**Phase/Area:** Error pattern recognition

**Issue:** The `Err(0xE)` at `OS.dmg.root_hash` is a well-known failure when SecureBootModel doesn't match the installer signing. This should be one of the first things checked in any Sequoia/Sonoma+ boot failure.

**Suggested improvement:** Build a decision tree for Hackintosh boot failures: if error is at EB|LD.OFS or EB.RH.LRH → check SecureBootModel first.

**Principle:** Common failure modes should be checked first, before auditing complex configurations.

---

### Observation 5: Task observer needs enforcement mechanism, not just instructions

**Status:** OPEN
**Date:** 2026-08-22
**Disposition:** AGENT-ACTION
**Session context:** User noticed skill-observations/log.md was empty after a full session
**Skill:** Task Observer (self-improvement)
**Phase/Area:** Enforcement / reliability

**Issue:** The task observer steering file says "log immediately" but provides no enforcement. During a task-heavy session (reorganizing repo, debugging boot, pushing to git), observations were never logged until the user explicitly called it out at the end. The "observe silently" instruction got completely ignored under task focus.

**Suggested improvement:** Added an `agentStop` hook (`log-skill-observations`) that prompts observation review at session end. This provides a structural backstop rather than relying on self-discipline during flow. Consider whether this hook should be global (across all workspaces) rather than workspace-specific.

**Principle:** Behavioral instructions that lack structural enforcement will be dropped under cognitive load. Add hooks/triggers for behaviors that must happen reliably.

---

### Observation 6: Enable debug logging proactively in development EFIs

**Status:** OPEN
**Date:** 2026-08-22
**Disposition:** AGENT-ACTION
**Session context:** User asked if EFI has error log reporting; it wasn't enabled
**Skill:** Hackintosh EFI management workflow
**Phase/Area:** Debug configuration

**Issue:** The In Development EFI had `Target=3` (screen only) and `AppleDebug/ApplePanic=false`. This means after a failed boot, the only diagnostic is a photo of the screen. The user had to ask about log files — this should have been enabled by default when building a troubleshooting EFI.

**Suggested improvement:** Any EFI in "In Development" should always have file logging enabled (Target=67, AppleDebug=true, ApplePanic=true). Only disable verbose output when moving to a "working" state.

**Principle:** Development/debug configurations should maximize diagnostic output by default. Reduce logging when promoting to production, not the other way around.

---

### Observation 7: User shares context from other AI sessions as knowledge transfer

**Status:** OPEN
**Date:** 2026-08-22
**Disposition:** AGENT-ACTION
**Session context:** User pasted a full ChatGPT conversation about SteamOS boot picker configuration
**Skill:** New skill candidate: Cross-session context ingestion
**Phase/Area:** Information synthesis

**Issue:** User dumped a long ChatGPT conversation covering SteamOS OpenCore picker setup, custom icons, .contentFlavour attempts, and BlessOverride suggestions. The key information needed to be extracted and synthesized — not treated as instructions to follow blindly.

**Suggested improvement:** When receiving context from other AI sessions, extract: (1) what was tried, (2) what worked, (3) what failed, (4) what's still pending. Summarize back to the user concisely and ask which threads to pick up.

**Principle:** Treat cross-session AI context as a research dump, not a conversation to continue. Extract facts and status, discard the back-and-forth.

---

### Observation 8: User prefers short file names

**Status:** OPEN
**Date:** 2026-08-22
**Disposition:** AGENT-ACTION
**Session context:** Created a doc file named `multi-boot-installer-usb.md`, user said "I hate the long file names you use for docs"
**Skill:** General file naming conventions
**Phase/Area:** File creation

**Issue:** Defaulted to a verbose, descriptive filename (`multi-boot-installer-usb.md`) when a shorter name (`installer-usb.md`) communicates the same thing within context. The folder (`docs/`) already provides context — the filename doesn't need to repeat it.

**Suggested improvement:** Keep filenames to 1-2 words max. Let folder hierarchy provide context. Prefer `installer-usb.md` over `multi-boot-installer-usb-guide.md`. Same applies to folders — already got this right with `Archive/`, `Scripts/`, `Configs/`.

**Principle:** Short filenames. Context comes from the folder, not the filename.

---

### Observation 9: softwareupdate requires exact point release versions

**Status:** OPEN
**Date:** 2026-08-22
**Disposition:** AGENT-ACTION
**Session context:** User ran `softwareupdate --fetch-full-installer --full-installer-version 15.0` and got "Update not found"
**Skill:** Hackintosh EFI management workflow / installer-usb doc
**Phase/Area:** macOS installer download instructions

**Issue:** The doc uses `--full-installer-version 15.0` as an example, but Apple removes older point releases from the catalog. The user hit this immediately. Should have documented `--list-full-installers` as the first step to find available versions.

**Suggested improvement:** Update the installer-usb doc to show `--list-full-installers` first, then use the exact version from the output. Don't hardcode version numbers that may go stale.

**Principle:** Documentation that references versioned resources should include a discovery step, not hardcoded values that go stale.

---

### Observation 10: USB boot priority not addressed in test instructions

**Status:** OPEN
**Date:** 2026-08-23
**Disposition:** AGENT-ACTION
**Session context:** User booted from internal EFI (with custom ASUS ROG theme) instead of the USB's OpenCore
**Skill:** Hackintosh EFI management workflow / installer-usb doc
**Phase/Area:** Test instructions

**Issue:** The test checklist said "Boot → OpenCore picker should appear" but didn't address that an existing OpenCore install on the internal drive will take priority over the USB. User ended up booting the wrong OpenCore. Should have explicitly said "enter BIOS boot menu (F8) and select the USB drive" or explained how to distinguish which OpenCore is running.

**Suggested improvement:** Test instructions and the installer-usb doc should always include: (1) how to force-boot from USB via BIOS boot menu key, (2) how to tell which OpenCore is running (Builtin=text vs External=graphical). Add ASUS-specific boot key (F8) to the doc.

**Principle:** When multiple bootloaders exist, test instructions must specify which one to boot from and how to verify you're running the right one.

---

### Observation 11: DmgLoading=Signed causes silent boot failure back to picker

**Status:** OPEN
**Date:** 2026-08-23
**Disposition:** AGENT-ACTION
**Session context:** User selected macOS installer from OpenCore picker and it silently returned to the picker with no error
**Skill:** Hackintosh boot debugging
**Phase/Area:** Silent failure diagnosis

**Issue:** When `DmgLoading=Signed` rejects an installer DMG, OpenCore doesn't show an error — it just returns to the picker. This is a different symptom than the `Err(0xE)` from before (which showed verbose errors). I focused only on SecureBootModel initially and missed that the internal EFI's `DmgLoading` was also `Signed`. Both settings need to be fixed together.

**Suggested improvement:** When fixing SecureBootModel issues, always check DmgLoading at the same time — they're related. Both `SecureBootModel=Disabled` AND `DmgLoading=Any` should be set together for troubleshooting. A silent return-to-picker is the telltale sign of DmgLoading rejection.

**Principle:** Silent failures need documented symptoms. "Returns to picker with no error" = check DmgLoading. Build a symptom→cause mapping for Hackintosh debugging.


---

### Observation 12: NVRAM reset instructions must specify which OpenCore to boot from

**Status:** OPEN
**Date:** 2026-08-23
**Disposition:** AGENT-ACTION
**Session context:** Advising user to reset NVRAM to fix stale boot-args
**Skill:** Hackintosh boot debugging
**Phase/Area:** Multi-EFI awareness

**Issue:** Told user to "Reset NVRAM from the picker" without considering that they have TWO OpenCore installations (internal NVMe + USB). Resetting NVRAM from the wrong OpenCore repopulates with the wrong config's values. User had already mentioned in a prior session that they can't boot the USB because the BIOS always grabs the internal NVMe's OpenCore first. Had to be corrected.

**Suggested improvement:** When advising NVRAM reset in a multi-OC setup, always: (1) identify which OC the user can actually boot, (2) confirm that OC has the correct config, (3) if it doesn't, pivot to "update the accessible config first" rather than insisting on NVRAM reset from the unreachable one.

**Principle:** In multi-bootloader setups, never assume the user can boot from a specific EFI. Always verify which one is actually reachable before giving instructions.

---

### Observation 13: Cross-machine handoff docs are a recurring workflow

**Status:** OPEN
**Date:** 2026-08-23
**Disposition:** USER-ACTION
**Session context:** User switching from Mac (remote) to the target PC to continue EFI work
**Skill:** New skill candidate: Cross-machine session continuity
**Phase/Area:** Context transfer

**Issue:** User explicitly asked to "make a file to get the other machine up to speed" — they work across multiple machines on the same repo and need a structured way to hand off in-progress state between Kiro sessions on different devices. Created `docs/current-status.md` as an ad-hoc solution.

**Suggested improvement:** Consider a standardized "handoff" doc pattern for multi-machine workflows: current state, what needs to happen next, which files matter, and key decisions already made. Could live at a predictable path like `docs/current-status.md` or `.kiro/steering/current-status.md` (auto-included).

**Principle:** When work spans multiple machines/sessions, make the transfer state explicit and machine-readable rather than relying on conversation history.


---

### Observation 14: NVRAM reset wipes custom UEFI boot entries

**Status:** OPEN
**Date:** 2026-08-23
**Disposition:** AGENT-ACTION
**Session context:** Deploying EFI-20260822 to internal NVMe, advised NVRAM reset
**Skill:** Hackintosh boot debugging
**Phase/Area:** NVRAM reset side effects

**Issue:** Advised user to reset NVRAM without warning that it would wipe the custom "OpenCore" UEFI boot entry from the firmware. Result: system stuck on ROG logo because BIOS had no boot entry pointing to OpenCore.efi. Had to boot into Windows via BIOS menu and recreate the entry with bcdedit. This is the second time (obs #12) that NVRAM reset instructions failed to account for the full consequences.

**Suggested improvement:** Always warn that NVRAM reset will wipe custom UEFI boot entries. Before advising it, confirm: (1) user knows they'll need to re-add the boot entry, or (2) the fallback BOOTx64.efi path will work. Better yet: document the bcdedit restore command alongside any NVRAM reset instruction.

**Principle:** NVRAM reset is not scoped to just OpenCore variables — it affects firmware-level boot entries. Always document the recovery path alongside destructive reset instructions.

---

### Observation 15: EFI partition space constraints require awareness before operations

**Status:** OPEN
**Date:** 2026-08-23
**Disposition:** AGENT-ACTION
**Session context:** Attempted to back up EFI to the same partition, ran out of space
**Skill:** Hackintosh EFI management workflow
**Phase/Area:** Pre-operation checks

**Issue:** Tried to xcopy the existing EFI as a backup to the same 100MB EFI partition. Predictably failed with "Insufficient disk space." Should have checked free space first and recognized the repo already contains the backup (EFI-20260627).

**Suggested improvement:** Before any EFI partition write operation: (1) check free space, (2) check if a backup already exists in the repo, (3) never write backups to the same partition unless confirmed there's room.

**Principle:** On constrained storage (EFI partitions), always check available space before write operations. Use the repo as the backup, not the partition itself.

---

### Observation 16: Elevated access required for EFI partition on Windows — non-obvious failure mode

**Status:** OPEN
**Date:** 2026-08-23
**Disposition:** AGENT-ACTION
**Session context:** Trying to read W:\ after user mounted it with diskpart
**Skill:** Hackintosh EFI management workflow
**Phase/Area:** Windows EFI access

**Issue:** User mounted the EFI partition to W: with diskpart (elevated), but the Kiro terminal couldn't read it — showed empty. Required `Start-Process -Verb RunAs` wrapper for every command. This added complexity to every operation and wasn't immediately obvious.

**Suggested improvement:** When working with EFI partitions on Windows, always use the elevated wrapper pattern from the start. Don't try non-elevated access first.

**Principle:** EFI partition access on Windows always requires elevation, even if the mount was done elevated. Assume elevation is needed from the start.



---

### Observation 17: Memory allocation errors masquerade as kernel panics when OC debug logging is incomplete

**Status:** OPEN
**Date:** 2026-08-24
**Disposition:** AGENT-ACTION
**Session context:** OCSimplify-generated config revealed the real boot failure was EB.MM.AKMR (memory allocation), not a kernel panic
**Skill:** Hackintosh boot debugging
**Phase/Area:** Error diagnosis

**Issue:** Spent ~8 attempts tweaking kernel patches, SMBIOS, PAT patches, and BIOS settings believing the crash was a post-EXITBS kernel panic. The old config reached EXITBS (showing "success") but the OCSimplify config — with different Booter quirks — exposed that the real issue was a memory allocation failure (EB.MM.AKMR Err(0xE), STOP 0x15). The old config's SetupVirtualMap/Booter settings were masking or working around this differently, making it appear like a kernel issue.

**Suggested improvement:** When encountering "reaches EXITBS then crashes with no output," check Booter memory quirks FIRST before blaming kernel patches. The EB.MM.AKMR error only appeared because OCSimplify used SetupVirtualMap=true (wrong for AM5). A fresh config from a generator can expose issues the hand-tuned config was accidentally working around.

**Principle:** When iterative config changes produce identical failures, the problem is likely in a section you haven't touched. Fresh baselines from generators expose assumptions baked into hand-tuned configs.

---

### Observation 18: SetupVirtualMap must be false on AM5 with AGESA 1.2.0.2+

**Status:** OPEN
**Date:** 2026-08-24
**Disposition:** AGENT-ACTION
**Session context:** B850-A with AGESA ComboAM5PI_1202 failing with memory allocation error
**Skill:** Hackintosh EFI management workflow
**Phase/Area:** Platform-specific quirks

**Issue:** OCSimplify set SetupVirtualMap=true by default, but AM5 boards with AGESA 1.2.0.2+ handle virtual memory mapping in firmware. The combination of SetupVirtualMap=true + the AM5 memory map caused boot.efi to fail allocating kernel memory. DevirtualiseMmio=true also needed to free MMIO regions.

**Suggested improvement:** For any AM5/B850/B650/X670 board, SetupVirtualMap should always be false and DevirtualiseMmio should be true. Add this to a hardware-specific checklist.

**Principle:** Platform-era-specific Booter quirks (AM5 vs AM4 vs Intel) should be treated as hard requirements, not optional tweaks.



---

### Observation 17: Exhaustive config changes with identical symptoms indicate non-config root cause

**Status:** OPEN
**Date:** 2026-08-24
**Disposition:** AGENT-ACTION
**Session context:** 8+ config iterations all producing identical EXITBS → kernel panic
**Skill:** Hackintosh boot debugging
**Phase/Area:** Root cause analysis

**Issue:** Spent an entire session iterating on config tweaks (SMBIOS, PAT patches, PCI patches, ProvideCurrentCpuInfo, npci, CSM, IOPCIIsHotplugPort) plus a full OCSimplify fresh config — all producing the exact same failure. Should have recognized after 3 identical failures that the problem is outside the config (hardware, USB, BIOS, or installer corruption).

**Suggested improvement:** After 3 identical post-EXITBS failures with different configs: stop changing config. The issue is either (1) corrupted installer media, (2) BIOS/firmware incompatibility, (3) hardware fault, or (4) USB port/controller issue. Switch to testing those before more config changes.

**Principle:** When multiple fundamentally different configs produce identical symptoms, the cause is upstream of the config. Stop tweaking and look at the environment.

---

### Observation 18: OCSimplify automation script is reusable

**Status:** OPEN
**Date:** 2026-08-24
**Disposition:** USER-ACTION
**Session context:** Built run_ocsimplify.py to automate the interactive OCSimplify tool
**Skill:** New skill candidate: Hackintosh tool automation
**Phase/Area:** Tool integration

**Issue:** OCSimplify is a useful tool but requires interactive input at every step. Built a Python wrapper (`Scripts/run_ocsimplify.py`) that monkey-patches the input function and drives the tool non-interactively. This makes it rerunnable from Kiro without manual intervention.

**Suggested improvement:** Keep the automation script in the repo. Consider extending it to accept CLI args (macOS version, GPU kext choice) for different build targets. Could also add a diff step to compare generated config against the current one.

**Principle:** Interactive CLI tools can be automated by monkey-patching their input functions. Useful for reproducible builds.



---

### Observation 19: OC log files aren't always the most recent by filename — check ALL recent timestamps

**Status:** OPEN
**Date:** 2026-08-24
**Disposition:** AGENT-ACTION
**Session context:** Missed log files because only checked the 2-3 newest by sort order
**Skill:** Hackintosh boot debugging
**Phase/Area:** Log retrieval

**Issue:** Was checking only the top 2-3 files by date, missing that some "empty" files were newer while files with content had slightly older timestamps. Should scan ALL files from the session window and check each for content rather than assuming the newest file has the data.

**Suggested improvement:** When checking OC logs: list ALL files, then check each for content (non-null). Don't assume the latest file has the boot log — OC creates the file at boot start but only writes content from boot.efi, not from the OC picker phase.

**Principle:** Log filenames/timestamps don't always correlate with content. Check all candidates for actual data.

