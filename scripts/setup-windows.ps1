# One-stop terminal setup for Windows (PowerShell)
# oh-my-posh (Dracula), Nerd Font, lsd, bat, fzf, zoxide, superfile (Dracula)
#
# Note: zsh / Oh My Zsh, and tmux, are Linux/macOS tools and don't run
# natively on Windows. This script sets up the equivalent shell experience
# in PowerShell instead, minus tmux. If you specifically want those, either:
#   - use WSL and run setup-ubuntu.sh inside it, or
#   - install Git Bash / MSYS2, which can run zsh (but not tmux)
#
# Usage: run PowerShell as Administrator, then:
#   Set-ExecutionPolicy Bypass -Scope Process -Force
#   .\setup-windows.ps1

$NerdFontName = "JetBrainsMono"   # change if you prefer Meslo, FiraCode, Hack, etc.

function Section($msg) { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }

Section "1/8: winget check"
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Host "winget not found. Install 'App Installer' from the Microsoft Store, then re-run this script." -ForegroundColor Red
  exit 1
}

Section "2/8: oh-my-posh"
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
  winget install --id JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements
  # winget installs to a versioned folder; refresh PATH for the rest of this session
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
  Write-Host "already installed, skipping"
}

Write-Host "--- installing Nerd Font ($NerdFontName) ---"
oh-my-posh font install $NerdFontName

Write-Host "--- fetching Dracula theme for oh-my-posh ---"
$PoshThemesDir = "$HOME\.poshthemes"
New-Item -ItemType Directory -Force -Path $PoshThemesDir | Out-Null
$DraculaThemePath = "$PoshThemesDir\dracula.omp.json"
if (-not (Test-Path $DraculaThemePath)) {
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/dracula.omp.json" -OutFile $DraculaThemePath
} else {
  Write-Host "already present, skipping"
}

Section "3/8: lsd"
if (-not (Get-Command lsd -ErrorAction SilentlyContinue)) {
  winget install --id lsd-rs.lsd -e --accept-source-agreements --accept-package-agreements
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
  Write-Host "already installed, skipping"
}

Section "4/8: bat"
if (-not (Get-Command bat -ErrorAction SilentlyContinue)) {
  winget install --id sharkdp.bat -e --accept-source-agreements --accept-package-agreements
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
  Write-Host "already installed, skipping"
}

Section "5/8: fzf"
if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
  winget install --id junegunn.fzf -e --accept-source-agreements --accept-package-agreements
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
  Write-Host "already installed, skipping"
}

Section "6/8: zoxide"
if (-not (Get-Command zoxide -ErrorAction SilentlyContinue)) {
  winget install --id ajeetdsouza.zoxide -e --accept-source-agreements --accept-package-agreements
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
  Write-Host "already installed, skipping"
}

Section "7/8: superfile"
if (-not (Get-Command spf -ErrorAction SilentlyContinue)) {
  winget install --id yorukot.superfile -e --accept-source-agreements --accept-package-agreements
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
  Write-Host "already installed, skipping"
}

Write-Host "--- setting superfile theme to Dracula ---"
$SpfConfig = "$env:APPDATA\superfile\config.toml"
if (-not (Test-Path $SpfConfig) -and (Get-Command spf -ErrorAction SilentlyContinue)) {
  # --fix-config-file writes the default config/hotkeys files as a side
  # effect, then exits non-zero because there's no TTY to open the TUI in
  # (fine — we only care about the files it wrote before failing).
  spf --fix-config-file *> $null
}
if (Test-Path $SpfConfig) {
  $content = Get-Content $SpfConfig
  if ($content -match "^theme = ") {
    $content = $content -replace "^theme = .*", 'theme = "dracula"'
    Set-Content -Path $SpfConfig -Value $content
  } else {
    Add-Content -Path $SpfConfig -Value 'theme = "dracula"'
  }
} else {
  Write-Host "Couldn't find/generate $SpfConfig — run 'spf' once yourself, then set theme = `"dracula`" in its config.toml (run 'spf path-list' to find the exact path)."
}

Section "8/8: PowerShell profile"
if (-not (Test-Path $PROFILE)) {
  New-Item -Path $PROFILE -Type File -Force | Out-Null
}
$Mark = "# >>> custom terminal setup >>>"
$ProfileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
# Get-Content -Raw on a brand-new/empty file returns $null, and $null -notmatch
# <pattern> comes back as an empty array (falsy) rather than $true — so on a
# fresh machine (no pre-existing profile) this would silently skip adding the
# config below. Check for empty content explicitly first.
if ([string]::IsNullOrEmpty($ProfileContent) -or $ProfileContent -notmatch [regex]::Escape($Mark)) {
@"

$Mark
oh-my-posh init pwsh --config "$DraculaThemePath" | Invoke-Expression
zoxide init powershell | Out-String | Invoke-Expression

Remove-Item alias:ls -ErrorAction SilentlyContinue
Remove-Item alias:dir -ErrorAction SilentlyContinue
function ls  { lsd @args }
function ll  { lsd -l @args }
function la  { lsd -la @args }
function lt  { lsd --tree @args }

`$env:BAT_THEME = "Dracula"
`$env:FZF_DEFAULT_OPTS = "--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
# <<< custom terminal setup <<<
"@ | Add-Content -Path $PROFILE
} else {
  Write-Host "profile already configured, skipping"
}

Write-Host "`nAll done. Next steps:" -ForegroundColor Green
Write-Host "  1. In Windows Terminal settings, set the font face to '$NerdFontName Nerd Font Mono' for your PowerShell profile."
Write-Host "  2. Restart PowerShell (or run: . `$PROFILE) to load oh-my-posh and the lsd aliases."
Write-Host "  3. Oh My Posh is set to the Dracula theme ($DraculaThemePath)."
Write-Host "  4. Superfile is set to the Dracula theme. Launch it with: spf"
Write-Host "  5. bat is set to the Dracula theme (`$env:BAT_THEME); fzf uses the Dracula palette via `$env:FZF_DEFAULT_OPTS; zoxide replaces cd habits with z/zi (learns your most-used directories)."
Write-Host "  6. tmux doesn't run natively on Windows. Want it (with its Dracula theme)? Use WSL (wsl --install) and run setup-ubuntu.sh inside it."
Write-Host "  7. Want real zsh too? Same answer: WSL (wsl --install) and run setup-ubuntu.sh inside it."
