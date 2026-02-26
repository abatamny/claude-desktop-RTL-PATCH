# Claude Desktop RTL Patch

Smart RTL (Right-to-Left) support for **Claude Desktop on Windows**. Adds automatic Hebrew/Arabic text direction detection without breaking English or code blocks.

## What it does

- **Auto-detects RTL text** in Claude's responses and input box
- **Keeps code blocks LTR** — no broken formatting
- **Creates backups** of all modified files with full restore support

## Quick Install

Open **PowerShell** and run:
```powershell
irm https://raw.githubusercontent.com/shraga100/claude-desktop-rtl-patch/main/install.ps1 | iex
```

A UAC prompt will appear — click **Yes** to grant admin privileges.

> **Alternative:** Download `patch.ps1` and right-click → **Run with PowerShell**

## Requirements

- **Windows 10/11** with Claude Desktop installed  
  Download Claude Desktop from [claude.ai](https://downloads.claude.ai/releases/win32/ClaudeSetup.exe)
- **Node.js** installed (`npx` must be available in PATH)
- **Administrator privileges** (the script will request elevation automatically)

> ⚠️ This patch supports **Windows only**

## Menu Options

| Option | Description |
|--------|-------------|
| **1. Install** | Backs up originals and injects RTL support |
| **2. Restore** | Reverts all changes from backup files |
| **3. Exit** | Close the patcher |

## Troubleshooting

**"Node.js (npx) is required"** — Install Node.js from [nodejs.org](https://nodejs.org/) and reopen PowerShell.

**Service won't start after patching** — Run the script again and choose **Restore** (option 2), then **Install** (option 1).

**Claude updated and the patch broke** — Delete any `.bak` files in the Claude app directory and run the installer again.

## Uninstall

Run the script and choose option **2 (Restore)**. This restores all original files from backup.

## License

MIT
