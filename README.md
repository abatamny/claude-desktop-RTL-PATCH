# Claude Desktop RTL Patch (abatamny fork)

Smart RTL (Right-to-Left) support for **Claude Desktop on Windows**. Adds automatic Hebrew/Arabic text direction detection without breaking English or code blocks.

> **This is a fork of [shraga100/claude-desktop-rtl-patch](https://github.com/shraga100/claude-desktop-rtl-patch).** All the credit for the original patch, the ASAR injection workflow, the executable hash replacement, and the certificate-swap technique goes to the upstream project. This fork **deletes the original direction-detection logic and rewrites it from scratch** as five small, explicit rules so the result is predictable on mixed Hebrew/Arabic + English + math + code content. See [What's different in this fork](#whats-different-in-this-fork) below.

## What it does

* **Auto-detects RTL text** in Claude's responses and input box

* **Keeps code blocks LTR** — no broken formatting

* **Creates backups** of all modified files with full restore support

* **Automated Updates** — Optional background service to automatically re-apply the patch when Claude updates

## What's different in this fork

This fork is built directly on top of [shraga100/claude-desktop-rtl-patch](https://github.com/shraga100/claude-desktop-rtl-patch). The install flow, the ASAR injection, the executable hash patch, and the certificate swap are all unchanged. **The direction-detection logic inside the injected JavaScript has been deleted and rewritten from scratch.**

### Why a rewrite

The original detection chained several heuristics — first-strong character, leading-LTR stripping, per-line splitting, and a final majority-count fallback — and still misbehaved on common mixed content. Examples that came up in practice:

* A mostly-English sentence containing one Hebrew word would flip the whole paragraph to RTL.
* A LaTeX-ish line like `P(X(x) = לכל` would be detected as RTL because the math symbols `( ) =` tipped the count incorrectly.
* English math/code lines containing a single Hebrew variable name lost their LTR layout.

Patching the fallback once, twice, and then again with a math-symbol weight was a clear sign the heuristic stack itself was the problem. So this fork deletes the entire detection layer and replaces it with five small, explicit rules.

### The five rules

**Rule 1 — Direction detection (single source of truth).**
Walk the text. Skip every leading digit, symbol, math character, and whitespace character. The first *strong* character decides direction: Hebrew/Arabic → `rtl`, Latin (A–Z, a–z) → `ltr`. There are no fallbacks, no majority counts, and no per-element heuristics — this function is the only thing that decides direction anywhere in the patch.

**Rule 2 — Math elements.**
Any element whose class contains `math` or `katex` is forced to `dir="ltr"` and is never touched by any other rule. Math formulas always render LTR regardless of what characters they contain.

**Rule 3 — Code elements.**
`<pre>`, `<code>`, and `.code-block` (and `.code-block__code`) are forced to `dir="ltr"` and are never touched by any other rule. Code blocks always render LTR.

**Rule 4 — Inputs.**
Rule 1 is applied to every writable element — `<input>`, `<textarea>`, and `[contenteditable="true"]` — and re-runs on every `input` event. There is no special case for the chat input; writable elements are treated exactly like any other element.

**Rule 5 — Nested LTR inside RTL.**
After Rule 1 flags a container as RTL, the patch scans the container's text nodes for *Latin runs* (a Latin letter and the symbols/digits next to it, ignoring anything inside a math or code element) and wraps each run in `<span dir="ltr">`. This is what keeps things like `P(X(x) = לכל` rendering correctly: the Hebrew flows RTL, the `P(X(x) =` is isolated as LTR.

Rules 2 and 3 are absolute overrides — nothing changes their direction regardless of content. Rules 1, 4, and 5 are deterministic and depend on nothing more than the text itself.

### Other changes

* Repository URLs in `install.ps1` and `patch.ps1` (the elevation re-download, the desktop shortcut, and the auto-update watcher) point at this fork so that re-downloads, the shortcut, and the watcher all stay in sync with the new detection logic.

Everything else — the menu options, the auto-update flow, the disclaimer, the certificate handling — is the original work of [shraga100](https://github.com/shraga100) and the upstream contributors.

## Quick Install

Open **PowerShell** and run:

`irm https://raw.githubusercontent.com/abatamny/claude-desktop-RTL-PATCH/main/install.ps1 | iex`

A UAC prompt will appear — click **Yes** to grant admin privileges.

> **Alternative:** Download `patch.ps1` and right-click → **Run with PowerShell**

## Requirements

* **Windows 10/11** with Claude Desktop installed

  Download Claude Desktop from [claude.ai](https://downloads.claude.ai/releases/win32/ClaudeSetup.exe)

* **Node.js** installed (`npx` must be available in PATH)

* **Administrator privileges** (the script will request elevation automatically)

> ⚠️ **Windows Only:** This specific patch is for Windows.
>
> 🍎 **Mac Users:** Try [toboly's mac patch](https://github.com/toboly/claude-desktop-rtl-patch-mac) or [soguy's mac patch](https://github.com/soguy/claude-desktop-rtl-mac). *(Note: I have not personally tested these Mac versions, use at your own risk).*

## Menu Options

When you run the script, you will see the following interactive menu:

| Option | Description | 
 | ----- | ----- | 
| **1. Install** | Backs up originals and injects RTL support | 
| **2. Restore** | Reverts all changes from backup files | 
| **3. Create Shortcut** | Creates a desktop shortcut for quick 1-click updates | 
| **4. Enable Auto Re-Patch** | Installs a watcher to re-patch Claude automatically after updates | 
| **5. Disable Auto Re-Patch** | Removes the background watcher | 
| **6. Exit** | Close the patcher | 

## 🔄 Keeping the Patch Updated (Automation)

Claude Desktop updates frequently, and each update will overwrite this patch. To make maintaining the RTL support effortless, the patcher includes two helpful features:

1. **Desktop Shortcut (Option 3):** This creates a shortcut on your Desktop named "Update Claude RTL". Double-clicking this will silently fetch and apply the latest patch without making you navigate the menu.

2. **Auto-Updater Service (Option 4):** This sets up a lightweight Windows Scheduled Task. It runs quietly in the background and detects exactly when a new `claude.exe` version is launched. Once it detects an update, it will automatically download and apply the patch, showing you a quick Windows notification when it's done.

## How it works (Technical)

Claude Desktop is an Electron application distributed as a **digitally signed** package. Adding RTL support requires modifying the JavaScript inside the app — but this breaks the integrity checks Anthropic uses to verify the application. The patch handles this in three phases:

### Phase 1 — ASAR Injection

Claude's UI code lives inside `app.asar`, a read-only archive format used by Electron. The script:

1. Extracts the ASAR archive using `npx asar`

2. Injects a small JavaScript snippet into the renderer files — this snippet detects RTL characters in real time and applies the correct text direction

3. Repacks the ASAR and computes the new SHA-256 hash of its header

### Phase 2 — Hash Replacement in `claude.exe`

`claude.exe` contains the original ASAR hash hardcoded as an ASCII string. The script performs a **direct byte-level search-and-replace** inside the binary to update it to the new hash, so the app accepts the modified ASAR.

### Phase 3 — Certificate Swap in `cowork-svc.exe`

`cowork-svc.exe` is a background service that verifies the authenticity of `claude.exe` using Anthropic's embedded certificate. After re-signing `claude.exe` with a new self-signed certificate, the script:

1. Locates the original Anthropic X.509 certificate inside `cowork-svc.exe` using binary pattern matching (searching for `0x30 0x82` near the string `"Anthropic, PBC"`)

2. Generates a self-signed certificate small enough to fit in the same byte slot

3. Replaces the original certificate in-place, padding with `0x00` to preserve file size and binary offsets

4. Re-signs both `claude.exe` and `cowork-svc.exe` with the new certificate

5. Adds the certificate to the Windows trusted root store (`LocalMachine\Root`)

All original files are backed up before any changes. If anything fails, an automatic rollback restores the originals.

## ⚠️ Disclaimer

> **Please read before installing.**

This patch modifies the internal binaries of Claude Desktop in ways that are **not authorized by Anthropic**. Specifically:

* It replaces Anthropic's code-signing certificate inside `cowork-svc.exe` with a self-signed certificate

* It adds that self-signed certificate to your Windows **trusted root certificate store**

* It bypasses the application's integrity verification mechanism

**By installing this patch you accept the following:**

1. **Use at your own risk.** The authors take no responsibility for any damage to your system, data loss, or application instability.

2. **Anthropic may terminate your account** if they detect unauthorized modifications to their software, per their Terms of Service.

3. **Keep the repository trusted.** If this repository were ever compromised, running the install command could execute malicious code with Administrator privileges. Always verify the source before running any `irm | iex` command.

4. **This patch is temporary.** Claude Desktop updates will overwrite the patched files. You may need to re-run the installer after each update (or use the built-in Auto-Updater).

5. **Not a permanent solution.** This exists only until Anthropic adds native RTL support. Please upvote and request this feature through official Anthropic channels.

This project is open source (MIT). Contributions to improve RTL accuracy are welcome — PRs are open. 🙏

## Troubleshooting

**"Node.js (npx) is required"** — Install Node.js from [nodejs.org](https://nodejs.org/) and reopen PowerShell.

**Service won't start after patching** — Run the script again and choose **Restore** (option 2), then **Install** (option 1).

**Claude updated and the patch broke** — Run the "Update Claude RTL" desktop shortcut, or use the Auto-Updater. If doing it manually, delete any `.bak` files in the Claude app directory and run the installer again.

## Uninstall

Run the script and choose option **2 (Restore)**. This restores all original files from backup and removes the self-signed certificate from your Windows certificate store. If you installed the Auto-Updater, choose option **5** to disable it.

## License

MIT
