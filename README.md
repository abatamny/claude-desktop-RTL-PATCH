# Claude Desktop RTL Patch

**Fix Arabic and Hebrew text direction in Claude Desktop for Windows.**  
A small PowerShell patch that improves RTL/LTR rendering in Claude Desktop while keeping English, code, math, and file names readable.

> This repository is a fork of [`shraga100/claude-desktop-rtl-patch`](https://github.com/shraga100/claude-desktop-rtl-patch).  
> The original patching workflow belongs to the upstream project. This fork rewrites the RTL direction-detection logic from scratch using five explicit rules.

---

## Why this exists

Claude Desktop does not always handle Arabic and Hebrew text direction correctly, especially when RTL text is mixed with:

- English words
- code snippets
- file names like `README.md`
- PowerShell commands like `install.ps1`
- math expressions like `P(X = x)`

This patch improves the writing direction so Arabic/Hebrew messages feel natural without breaking technical LTR content.

---

## What it does

- Detects Arabic and Hebrew text automatically
- Applies RTL direction only where it is needed
- Keeps code blocks and commands LTR
- Keeps math and KaTeX expressions LTR
- Handles mixed RTL/LTR text more predictably
- Supports Claude Desktop input boxes and responses
- Creates backups before modifying files
- Includes restore support
- Optional auto re-patch after Claude Desktop updates

---

## Quick install

Open **PowerShell as Administrator** and run:

```powershell
irm https://raw.githubusercontent.com/abatamny/claude-desktop-RTL-PATCH/main/install.ps1 | iex
```

A Windows UAC prompt may appear. Click **Yes** to continue.

> Prefer not to use `irm | iex`?  
> Download `patch.ps1` manually, inspect it, then run it with PowerShell.

---

## Requirements

- Windows 10 or Windows 11
- Claude Desktop installed
- Node.js installed, so `npx` is available in PATH
- Administrator privileges

> This patch is for **Windows only**.

For macOS, see:
- [`toboly/claude-desktop-rtl-patch-mac`](https://github.com/toboly/claude-desktop-rtl-patch-mac)
- [`soguy/claude-desktop-rtl-mac`](https://github.com/soguy/claude-desktop-rtl-mac)

I have not personally tested these macOS versions.

---

## What is different in this fork?

This fork keeps the original patching workflow but replaces the direction-detection logic.

The upstream project already handled the difficult patching work:

- ASAR injection
- executable hash replacement
- certificate swap
- backup and restore flow
- update workflow

This fork focuses on one thing:

> Make RTL detection simpler, more predictable, and safer for mixed Arabic/Hebrew + English + code + math content.

---

## The five RTL rules

### Rule 1 — First strong character decides direction

The patch scans the text and skips leading spaces, numbers, symbols, and math characters.

The first strong language character decides the direction:

- Arabic or Hebrew → `rtl`
- English letter → `ltr`

There is no majority voting and no fallback guessing.

---

### Rule 2 — Math is always LTR

Elements related to math, such as `math` or `katex`, are forced to:

```html
dir="ltr"
```

Math should stay LTR even when it appears inside Arabic or Hebrew text.

---

### Rule 3 — Code is always LTR

The following elements are forced to LTR:

```html
<pre>
<code>
.code-block
.code-block__code
```

This prevents code blocks, commands, and technical snippets from being visually reversed.

---

### Rule 4 — Inputs update while typing

The patch applies direction detection to writable elements:

```html
<input>
<textarea>
[contenteditable="true"]
```

The direction is recalculated on every `input` event, so the text box adapts while you type.

---

### Rule 5 — English runs inside RTL stay LTR

When a container is RTL, the patch looks for Latin/English runs inside it and wraps them with:

```html
<span dir="ltr">
```

This keeps examples like this readable:

```text
افتح README.md ثم شغّل install.ps1
```

Arabic stays RTL, while `README.md` and `install.ps1` stay LTR.

---

## Menu options

When running the script, you will see this menu:

| Option | Description |
|---|---|
| **1. Install** | Back up original files and apply the RTL patch |
| **2. Restore** | Restore Claude Desktop from backup |
| **3. Create Shortcut** | Create a desktop shortcut for quick updates |
| **4. Enable Auto Re-Patch** | Re-apply the patch automatically after Claude updates |
| **5. Disable Auto Re-Patch** | Remove the background watcher |
| **6. Exit** | Close the patcher |

---

## Keeping the patch updated

Claude Desktop updates may overwrite the patch.

You have two options:

### Desktop shortcut

Use menu option **3** to create a shortcut named:

```text
Update Claude RTL
```

Double-click it whenever Claude updates.

### Auto re-patch

Use menu option **4** to install a lightweight Windows Scheduled Task.

It watches for Claude Desktop updates and reapplies the patch automatically when needed.

---

## How it works

Claude Desktop is an Electron app. Its UI code is packaged inside an `app.asar` archive.

The patch works in three phases.

### Phase 1 — ASAR injection

The script:

1. Extracts Claude Desktop's `app.asar`
2. Injects JavaScript that applies RTL/LTR direction rules
3. Repackages the ASAR archive
4. Calculates the new ASAR header hash

### Phase 2 — Hash replacement

Claude Desktop checks the ASAR hash.

After modifying `app.asar`, the script updates the expected hash inside `claude.exe` so Claude accepts the modified archive.

### Phase 3 — Certificate swap

Because the executable changes, the script handles signing and certificate replacement so the related Claude service can still validate the modified executable.

Backups are created before changes are applied.

---

## Safety notice

Please read before installing.

This patch modifies local Claude Desktop application files. It is not an official Anthropic feature.

By using it, you understand that:

- You run it at your own risk
- It modifies Claude Desktop internals
- It requires Administrator privileges
- It adds a self-signed certificate to the Windows trusted root store
- Claude Desktop updates may overwrite the patch
- You should only run scripts from repositories you trust

This project exists as a temporary workaround until Claude Desktop supports RTL languages natively.

---

## Troubleshooting

### `Node.js (npx) is required`

Install Node.js, reopen PowerShell, and run the script again.

### Claude updated and RTL stopped working

Run the desktop shortcut created by option **3**, or run the installer again.

### Claude does not start after patching

Run the script again and choose:

```text
2. Restore
```

Then run:

```text
1. Install
```

### I want to remove the patch

Run the script and choose:

```text
2. Restore
```

If you enabled the auto re-patch watcher, also choose:

```text
5. Disable Auto Re-Patch
```

---

## Feedback and contributions

If the patch does not work for your Claude Desktop version, please open an issue and include:

- Windows version
- Claude Desktop version
- Screenshot of the RTL problem
- Error message, if any
- Whether you used manual install or auto re-patch

Pull requests are welcome.

---

## Attribution

This project is a fork of [`shraga100/claude-desktop-rtl-patch`](https://github.com/shraga100/claude-desktop-rtl-patch).

Original patching workflow, ASAR injection, executable hash replacement, certificate-swap technique, backup/restore flow, and menu system belong to the upstream project.

RTL direction detection in this fork was rewritten by [`abatamny`](https://github.com/abatamny).

---

## License

MIT License. See [`LICENSE`](LICENSE).

If this project helped you use Claude Desktop with Arabic or Hebrew, a star would be appreciated.
