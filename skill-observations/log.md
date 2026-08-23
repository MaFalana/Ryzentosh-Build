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
