$f = Join-Path $env:TEMP "claude_rtl_patch.ps1"
$content = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/shraga100/claude-desktop-rtl-patch/main/patch.ps1"
[System.IO.File]::WriteAllText($f, $content, [System.Text.UTF8Encoding]::new($true))
Start-Process -FilePath PowerShell.exe -Verb RunAs -ArgumentList "-NoProfile -NoExit -ExecutionPolicy Bypass -File `"$f`""
