# Claude Desktop RTL Patch

Smart RTL (Right-to-Left) support for **Claude Desktop on Windows**. Adds automatic Hebrew/Arabic text direction detection without breaking English or code blocks.

## What it does

- **Auto-detects RTL text** in Claude's responses and input box
- **Keeps code blocks LTR** — no broken formatting
- **Creates automatic backups** of all modified files so you can easily and safely restore them

## Quick Install

Open **PowerShell** and run:

```powershell
irm [https://raw.githubusercontent.com/shraga100/claude-desktop-rtl-patch/main/install.ps1](https://raw.githubusercontent.com/shraga100/claude-desktop-rtl-patch/main/install.ps1) | iex
