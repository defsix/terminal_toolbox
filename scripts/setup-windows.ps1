# One-stop terminal setup for Windows (PowerShell)
# oh-my-posh, Nerd Font, lsd, bat, fzf, zoxide, superfile — pick your font and
# theme below (10 themes, all Dracula-style ecosystems: Dracula, Catppuccin x4,
# Gruvbox, Nord, Tokyo Night, Rose Pine, Everforest).
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

$NerdFontName = "JetBrainsMono"   # default; the picker below can override this
$Theme = "dracula"                # default; the picker below can override this

$FontChoices = @("JetBrainsMono", "FiraCode", "CascadiaCode", "Hack", "Meslo", "SourceCodePro", "Iosevka", "UbuntuMono", "RobotoMono", "Inconsolata")
$ThemeChoices = @("dracula", "catppuccin-mocha", "catppuccin-macchiato", "catppuccin-frappe", "catppuccin-latte", "gruvbox", "nord", "tokyonight", "rosepine", "everforest")

function Section($msg) { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }

# Prints a numbered menu, reads a choice from stdin, returns the selected
# option (or the default on empty/invalid input).
function Choose-FromList($Heading, $Default, $Options) {
  Write-Host $Heading
  for ($i = 0; $i -lt $Options.Length; $i++) {
    Write-Host "  $($i + 1)) $($Options[$i])"
  }
  $ans = Read-Host "Choice [1-$($Options.Length), Enter for '$Default']"
  if ([string]::IsNullOrWhiteSpace($ans)) {
    return $Default
  }
  $idx = 0
  if ([int]::TryParse($ans, [ref]$idx) -and $idx -ge 1 -and $idx -le $Options.Length) {
    return $Options[$idx - 1]
  }
  Write-Host "Didn't recognize that, using default: $Default"
  return $Default
}

# Only prompt when actually run interactively (a real console on stdin) —
# piped/non-interactive runs (CI, automation) keep the defaults above.
if ([Environment]::UserInteractive -and -not ([Console]::IsInputRedirected)) {
  Write-Host "=== Pick your setup (before anything installs) ==="
  $NerdFontName = Choose-FromList "Nerd Font:" $NerdFontName $FontChoices
  $Theme = Choose-FromList "Theme:" $Theme $ThemeChoices
  Write-Host "Using font=$NerdFontName theme=$Theme"
}

# --- per-theme asset sources and role colors -------------------------------
# OmpThemeUrl / BatThemeUrl: official upstream file when one exists for this
# palette; left empty when it doesn't, in which case the corresponding
# install step below generates one instead (oh-my-posh: recolor the proven
# dracula.omp.json template).
$OmpThemeUrl = ""
$BatThemeName = ""
$BatThemeUrl = ""
$SuperfileTheme = ""
$C = @{}

switch ($Theme) {
  "dracula" {
    $OmpThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/dracula.omp.json"
    $BatThemeName = "Dracula"
    $SuperfileTheme = "dracula"
    $C = @{ BG="#282a36"; FG="#f8f8f2"; MUTED="#6272a4"; PURPLE="#bd93f9"; ORANGE="#ffb86c"; CYAN="#8be9fd"; PINK="#ff79c6"; YELLOW="#f1fa8c"; RED="#ff5555"; GREEN="#50fa7b" }
  }
  "catppuccin-mocha" {
    $OmpThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_mocha.omp.json"
    $BatThemeName = "Catppuccin Mocha"
    $BatThemeUrl = "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme"
    $SuperfileTheme = "catppuccin-mocha"
    $C = @{ BG="#1e1e2e"; FG="#cdd6f4"; MUTED="#6c7086"; PURPLE="#cba6f7"; ORANGE="#fab387"; CYAN="#94e2d5"; PINK="#f5c2e7"; YELLOW="#f9e2af"; RED="#f38ba8"; GREEN="#a6e3a1" }
  }
  "catppuccin-macchiato" {
    $OmpThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_macchiato.omp.json"
    $BatThemeName = "Catppuccin Macchiato"
    $BatThemeUrl = "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Macchiato.tmTheme"
    $SuperfileTheme = "catppuccin-macchiato"
    $C = @{ BG="#24273a"; FG="#cad3f5"; MUTED="#6e738d"; PURPLE="#c6a0f6"; ORANGE="#f5a97f"; CYAN="#8bd5ca"; PINK="#f5bde6"; YELLOW="#eed49f"; RED="#ed8796"; GREEN="#a6da95" }
  }
  "catppuccin-frappe" {
    $OmpThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_frappe.omp.json"
    $BatThemeName = "Catppuccin Frappe"
    $BatThemeUrl = "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Frappe.tmTheme"
    $SuperfileTheme = "catppuccin-frappe"
    $C = @{ BG="#303446"; FG="#c6d0f5"; MUTED="#737994"; PURPLE="#ca9ee6"; ORANGE="#ef9f76"; CYAN="#81c8be"; PINK="#f4b8e4"; YELLOW="#e5c890"; RED="#e78284"; GREEN="#a6d189" }
  }
  "catppuccin-latte" {
    $OmpThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_latte.omp.json"
    $BatThemeName = "Catppuccin Latte"
    $BatThemeUrl = "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Latte.tmTheme"
    $SuperfileTheme = "catppuccin-latte"
    $C = @{ BG="#eff1f5"; FG="#4c4f69"; MUTED="#9ca0b0"; PURPLE="#8839ef"; ORANGE="#fe640b"; CYAN="#179299"; PINK="#ea76cb"; YELLOW="#df8e1d"; RED="#d20f39"; GREEN="#40a02b" }
  }
  "gruvbox" {
    $OmpThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/gruvbox.omp.json"
    $BatThemeName = "gruvbox-dark"
    $SuperfileTheme = "gruvbox"
    $C = @{ BG="#282828"; FG="#ebdbb2"; MUTED="#928374"; PURPLE="#d3869b"; ORANGE="#fe8019"; CYAN="#8ec07c"; PINK="#d3869b"; YELLOW="#fabd2f"; RED="#fb4934"; GREEN="#b8bb26" }
  }
  "nord" {
    $BatThemeName = "Nord"
    $SuperfileTheme = "nord"
    $C = @{ BG="#2e3440"; FG="#d8dee9"; MUTED="#4c566a"; PURPLE="#b48ead"; ORANGE="#d08770"; CYAN="#88c0d0"; PINK="#bf616a"; YELLOW="#ebcb8b"; RED="#bf616a"; GREEN="#a3be8c" }
  }
  "tokyonight" {
    $BatThemeName = "tokyonight_night"
    $BatThemeUrl = "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme"
    $SuperfileTheme = "tokyonight"
    $C = @{ BG="#1a1b26"; FG="#c0caf5"; MUTED="#565f89"; PURPLE="#bb9af7"; ORANGE="#ff9e64"; CYAN="#7dcfff"; PINK="#bb9af7"; YELLOW="#e0af68"; RED="#f7768e"; GREEN="#9ece6a" }
  }
  "rosepine" {
    $BatThemeName = "Rose Pine"
    $BatThemeUrl = "https://raw.githubusercontent.com/rose-pine/tm-theme/main/dist/rose-pine.tmTheme"
    $SuperfileTheme = "rose-pine"
    $C = @{ BG="#191724"; FG="#e0def4"; MUTED="#6e6a86"; PURPLE="#c4a7e7"; ORANGE="#ebbcba"; CYAN="#9ccfd8"; PINK="#eb6f92"; YELLOW="#f6c177"; RED="#eb6f92"; GREEN="#31748f" }
  }
  "everforest" {
    $BatThemeName = "Everforest Dark"
    $BatThemeUrl = "https://raw.githubusercontent.com/mhanberg/everforest-textmate/main/Everforest%20Dark/Everforest%20Dark.tmTheme"
    $SuperfileTheme = "everforest-dark-medium"
    $C = @{ BG="#2d353b"; FG="#d3c6aa"; MUTED="#7a8478"; PURPLE="#d699b6"; ORANGE="#e69875"; CYAN="#83c092"; PINK="#d699b6"; YELLOW="#dbbc7f"; RED="#e67e80"; GREEN="#a7c080" }
  }
  default {
    Write-Host "Unknown theme '$Theme' — falling back to dracula"
    $Theme = "dracula"
    $OmpThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/dracula.omp.json"
    $BatThemeName = "Dracula"
    $SuperfileTheme = "dracula"
    $C = @{ BG="#282a36"; FG="#f8f8f2"; MUTED="#6272a4"; PURPLE="#bd93f9"; ORANGE="#ffb86c"; CYAN="#8be9fd"; PINK="#ff79c6"; YELLOW="#f1fa8c"; RED="#ff5555"; GREEN="#50fa7b" }
  }
}

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

Write-Host "--- fetching $Theme theme for oh-my-posh ---"
$PoshThemesDir = "$HOME\.poshthemes"
New-Item -ItemType Directory -Force -Path $PoshThemesDir | Out-Null
$ThemePath = "$PoshThemesDir\$Theme.omp.json"
if (-not (Test-Path $ThemePath)) {
  if ($OmpThemeUrl) {
    Invoke-WebRequest -Uri $OmpThemeUrl -OutFile $ThemePath
  } else {
    # No official oh-my-posh theme exists for this palette — recolor the
    # proven Dracula template (same schema, guaranteed to render) instead of
    # hand-writing a new prompt config from scratch. Two-pass placeholder
    # swap so a target color can never collide with a not-yet-replaced
    # source color.
    $BaseFile = "$env:TEMP\omp-base.omp.json"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/dracula.omp.json" -OutFile $BaseFile
    $content = Get-Content $BaseFile -Raw
    $content = $content -replace [regex]::Escape("#282a36"), "@@BG@@"
    $content = $content -replace [regex]::Escape("#f8f8f2"), "@@FG@@"
    $content = $content -replace [regex]::Escape("#6272a4"), "@@MUTED@@"
    $content = $content -replace [regex]::Escape("#bd93f9"), "@@PURPLE@@"
    $content = $content -replace [regex]::Escape("#ffb86c"), "@@ORANGE@@"
    $content = $content -replace [regex]::Escape("#8be9fd"), "@@CYAN@@"
    $content = $content -replace [regex]::Escape("#ff79c6"), "@@PINK@@"
    $content = $content -replace [regex]::Escape("#f1fa8c"), "@@YELLOW@@"
    $content = $content -replace "@@BG@@", $C.BG
    $content = $content -replace "@@FG@@", $C.FG
    $content = $content -replace "@@MUTED@@", $C.MUTED
    $content = $content -replace "@@PURPLE@@", $C.PURPLE
    $content = $content -replace "@@ORANGE@@", $C.ORANGE
    $content = $content -replace "@@CYAN@@", $C.CYAN
    $content = $content -replace "@@PINK@@", $C.PINK
    $content = $content -replace "@@YELLOW@@", $C.YELLOW
    Set-Content -Path $ThemePath -Value $content -NoNewline
    Remove-Item -Force $BaseFile -ErrorAction SilentlyContinue
  }
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

Write-Host "--- setting bat theme to $Theme ---"
if ((Get-Command bat -ErrorAction SilentlyContinue) -and $BatThemeUrl) {
  $BatThemeDir = "$(bat --config-dir)\themes"
  New-Item -ItemType Directory -Force -Path $BatThemeDir | Out-Null
  $BatThemeFile = "$BatThemeDir\$BatThemeName.tmTheme"
  if (-not (Test-Path $BatThemeFile)) {
    Invoke-WebRequest -Uri $BatThemeUrl -OutFile $BatThemeFile
    bat cache --build *> $null
  } else {
    Write-Host "already present, skipping"
  }
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

Write-Host "--- setting superfile theme to $Theme ---"
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
    $content = $content -replace "^theme = .*", "theme = `"$SuperfileTheme`""
    Set-Content -Path $SpfConfig -Value $content
  } else {
    Add-Content -Path $SpfConfig -Value "theme = `"$SuperfileTheme`""
  }
} else {
  Write-Host "Couldn't find/generate $SpfConfig — run 'spf' once yourself, then set theme = `"$SuperfileTheme`" in its config.toml (run 'spf path-list' to find the exact path)."
}

Section "8/8: PowerShell profile"
if (-not (Test-Path $PROFILE)) {
  New-Item -Path $PROFILE -Type File -Force | Out-Null
}
$Mark = "# >>> custom terminal setup >>>"
$MarkEnd = "# <<< custom terminal setup <<<"
$ProfileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
# Get-Content -Raw on a brand-new/empty file returns $null, and $null -notmatch
# <pattern> comes back as an empty array (falsy) rather than $true — so on a
# fresh machine (no pre-existing profile) this would silently skip adding the
# config below. Check for empty content explicitly first.
if (-not [string]::IsNullOrEmpty($ProfileContent) -and $ProfileContent -match [regex]::Escape($Mark)) {
  # Strip the previously-managed block so re-running with a different
  # theme/font replaces it instead of appending a duplicate.
  $ProfileContent = [regex]::Replace($ProfileContent, [regex]::Escape($Mark) + "[\s\S]*?" + [regex]::Escape($MarkEnd) + "\r?\n?", "")
  Set-Content -Path $PROFILE -Value $ProfileContent -NoNewline
}
@"

$Mark
oh-my-posh init pwsh --config "$ThemePath" | Invoke-Expression
zoxide init powershell | Out-String | Invoke-Expression

Remove-Item alias:ls -ErrorAction SilentlyContinue
Remove-Item alias:dir -ErrorAction SilentlyContinue
function ls  { lsd @args }
function ll  { lsd -l @args }
function la  { lsd -la @args }
function lt  { lsd --tree @args }

`$env:BAT_THEME = "$BatThemeName"
`$env:FZF_DEFAULT_OPTS = "--color=fg:$($C.FG),bg:$($C.BG),hl:$($C.PURPLE) --color=fg+:$($C.FG),bg+:$($C.MUTED),hl+:$($C.PURPLE) --color=info:$($C.ORANGE),prompt:$($C.GREEN),pointer:$($C.PINK) --color=marker:$($C.PINK),spinner:$($C.ORANGE),header:$($C.MUTED)"
$MarkEnd
"@ | Add-Content -Path $PROFILE

Write-Host "`nAll done. Next steps:" -ForegroundColor Green
Write-Host "  1. In Windows Terminal settings, set the font face to '$NerdFontName Nerd Font Mono' for your PowerShell profile."
Write-Host "  2. Restart PowerShell (or run: . `$PROFILE) to load oh-my-posh and the lsd aliases."
Write-Host "  3. Oh My Posh is set to the $Theme theme ($ThemePath)."
Write-Host "  4. Superfile is set to the $Theme theme. Launch it with: spf"
Write-Host "  5. bat is set to the $Theme theme (`$env:BAT_THEME); fzf uses the $Theme palette via `$env:FZF_DEFAULT_OPTS; zoxide replaces cd habits with z/zi (learns your most-used directories)."
Write-Host "  6. tmux doesn't run natively on Windows. Want it (with a Dracula theme)? Use WSL (wsl --install) and run setup-ubuntu.sh inside it."
Write-Host "  7. Want real zsh too? Same answer: WSL (wsl --install) and run setup-ubuntu.sh inside it."
Write-Host "  8. Want a different font or theme? Just rerun this script — it'll prompt again and replace the old config."
