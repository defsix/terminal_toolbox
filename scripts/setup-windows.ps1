# One-stop terminal setup for Windows (PowerShell)
# oh-my-posh (Dracula), Nerd Font, lsd, superfile (Dracula)
#
# Note: zsh / Oh My Zsh are Linux/macOS shells and don't run natively on
# Windows. This script sets up the equivalent experience in PowerShell
# instead. If you specifically want zsh, either:
#   - use WSL and run setup-ubuntu.sh inside it, or
#   - install Git Bash / MSYS2, which can run zsh
#
# Usage: run PowerShell as Administrator, then:
#   Set-ExecutionPolicy Bypass -Scope Process -Force
#   .\setup-windows.ps1

$NerdFontName = "JetBrainsMono"   # change if you prefer Meslo, FiraCode, Hack, etc.

function Section($msg) { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }

Section "1/5: winget check"
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Host "winget not found. Install 'App Installer' from the Microsoft Store, then re-run this script." -ForegroundColor Red
  exit 1
}

Section "2/5: oh-my-posh"
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

Section "3/5: lsd"
if (-not (Get-Command lsd -ErrorAction SilentlyContinue)) {
  winget install --id lsd-rs.lsd -e --accept-source-agreements --accept-package-agreements
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
  Write-Host "already installed, skipping"
}

Section "4/5: superfile"
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

Section "5/5: PowerShell profile"
if (-not (Test-Path $PROFILE)) {
  New-Item -Path $PROFILE -Type File -Force | Out-Null
}
$Mark = "# >>> custom terminal setup >>>"
$ProfileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($ProfileContent -notmatch [regex]::Escape($Mark)) {
@"

$Mark
oh-my-posh init pwsh --config "$DraculaThemePath" | Invoke-Expression

Remove-Item alias:ls -ErrorAction SilentlyContinue
Remove-Item alias:dir -ErrorAction SilentlyContinue
function ls  { lsd @args }
function ll  { lsd -l @args }
function la  { lsd -la @args }
function lt  { lsd --tree @args }
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
Write-Host "  5. Want real zsh? Use WSL (wsl --install) and run setup-ubuntu.sh inside it."
