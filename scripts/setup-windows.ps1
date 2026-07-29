# One-stop terminal setup for Windows (PowerShell)
# oh-my-posh, Nerd Font, lsd, bat, fzf, zoxide, superfile — pick your font and
# theme below (7 themes, all real premade oh-my-posh prompts with genuine
# powerline color-bar segments: Dracula, Catppuccin, JanDeDobbeleer, Paradox,
# Aliens, Montys, Unicorn).
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
$ThemeChoices = @("dracula", "catppuccin", "jandedobbeleer", "paradox", "aliens", "montys", "unicorn")

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
$C = @{}

switch ($Theme) {
  "dracula" {
    $OmpThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/dracula.omp.json"
    $BatThemeName = "Dracula"
    $C = @{ BG="#282a36"; FG="#f8f8f2"; MUTED="#6272a4"; PURPLE="#bd93f9"; ORANGE="#ffb86c"; CYAN="#8be9fd"; PINK="#ff79c6"; YELLOW="#f1fa8c"; RED="#ff5555"; GREEN="#50fa7b" }
  }
  "catppuccin" {
    # The official per-flavor files (catppuccin_mocha/_macchiato/_frappe/_latte
    # .omp.json) all use "style": "plain" — no powerline color-bar segments at
    # all. catppuccin.omp.json (the single "core" theme) is the one upstream
    # file that actually uses powerline/diamond segments with real background
    # colors; it hardcodes the Macchiato palette, so bat/superfile below match
    # Macchiato too for visual consistency.
    $OmpThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin.omp.json"
    $BatThemeName = "Catppuccin Macchiato"
    $BatThemeUrl = "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Macchiato.tmTheme"
    $C = @{ BG="#24273a"; FG="#cad3f5"; MUTED="#6e738d"; PURPLE="#c6a0f6"; ORANGE="#f5a97f"; CYAN="#8bd5ca"; PINK="#f5bde6"; YELLOW="#eed49f"; RED="#ed8796"; GREEN="#a6da95" }
  }
  "jandedobbeleer" {
    # oh-my-posh's own flagship default theme — real powerline segments,
    # well-tested, vibrant lavender/pink/yellow/teal.
    $OmpThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json"
    $BatThemeName = "Sublime Snazzy"
    $C = @{ BG="#1a1b26"; FG="#c0caf5"; MUTED="#565f89"; PURPLE="#c386f1"; ORANGE="#f36943"; CYAN="#2e9599"; PINK="#ff479c"; YELLOW="#fffb38"; RED="#f7768e"; GREEN="#1bd760" }
  }
  "paradox" {
    $OmpThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/paradox.omp.json"
    $BatThemeName = "OneHalfDark"
    $C = @{ BG="#1e1e2e"; FG="#cdd6f4"; MUTED="#6c7086"; PURPLE="#906cff"; ORANGE="#ffe9aa"; CYAN="#91ddff"; PINK="#ff8080"; YELLOW="#ffe9aa"; RED="#ff8080"; GREEN="#95ffa4" }
  }
  "aliens" {
    # Atom One Dark-inspired accents — bat's built-in TwoDark theme is the
    # same palette family, so it's an authentic pairing, not just a guess.
    $OmpThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/aliens.omp.json"
    $BatThemeName = "TwoDark"
    $C = @{ BG="#282c34"; FG="#abb2bf"; MUTED="#5c6370"; PURPLE="#c678dd"; ORANGE="#e5c07b"; CYAN="#61afef"; PINK="#ff6471"; YELLOW="#e5c07b"; RED="#ff6471"; GREEN="#95ffa4" }
  }
  "montys" {
    $OmpThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/montys.omp.json"
    $BatThemeName = "Coldark-Dark"
    $C = @{ BG="#22333b"; FG="#eae0d5"; MUTED="#5e6472"; PURPLE="#83769c"; ORANGE="#fca17d"; CYAN="#33658a"; PINK="#da627d"; YELLOW="#fca17d"; RED="#da627d"; GREEN="#76b367" }
  }
  "unicorn" {
    $OmpThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/unicorn.omp.json"
    $BatThemeName = "Monokai Extended"
    $C = @{ BG="#0f2027"; FG="#d8e9eb"; MUTED="#4c6b73"; PURPLE="#83769c"; ORANGE="#d2ff5e"; CYAN="#0087d8"; PINK="#ff6f91"; YELLOW="#d2ff5e"; RED="#ff6f91"; GREEN="#d2ff5e" }
  }
  default {
    Write-Host "Unknown theme '$Theme' — falling back to dracula"
    $Theme = "dracula"
    $OmpThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/dracula.omp.json"
    $BatThemeName = "Dracula"
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
# Superfile supports fully custom theme files (not just its bundled names) —
# https://superfile.dev/configure/custom-theme/ — so write our own using this
# theme's own role colors instead of guessing at the closest bundled name.
$SpfThemeDir = "$env:APPDATA\superfile\theme"
New-Item -ItemType Directory -Force -Path $SpfThemeDir | Out-Null
@"
code_syntax_highlight = "dracula"

full_screen_fg = "$($C.FG)"
full_screen_bg = "$($C.BG)"

gradient_color = ["$($C.GREEN)", "$($C.RED)"]

file_panel_fg = "$($C.FG)"
file_panel_bg = "$($C.BG)"
file_panel_border = "$($C.MUTED)"
file_panel_border_active = "$($C.MUTED)"
file_panel_top_directory_icon = "$($C.GREEN)"
file_panel_top_path = "$($C.CYAN)"
file_panel_item_selected_fg = "$($C.ORANGE)"
file_panel_item_selected_bg = "$($C.BG)"

footer_fg = "$($C.FG)"
footer_bg = "$($C.BG)"
footer_border = "$($C.MUTED)"
footer_border_active = "$($C.MUTED)"

sidebar_fg = "$($C.FG)"
sidebar_bg = "$($C.BG)"
sidebar_title = "$($C.PURPLE)"
sidebar_border = "$($C.BG)"
sidebar_border_active = "$($C.MUTED)"
sidebar_item_selected_fg = "$($C.ORANGE)"
sidebar_item_selected_bg = "$($C.BG)"
sidebar_divider = "$($C.MUTED)"

modal_fg = "$($C.FG)"
modal_bg = "$($C.BG)"
modal_border_active = "$($C.MUTED)"
modal_cancel_fg = "$($C.FG)"
modal_cancel_bg = "$($C.MUTED)"
modal_confirm_fg = "$($C.FG)"
modal_confirm_bg = "$($C.ORANGE)"

help_menu_hotkey = "$($C.ORANGE)"
help_menu_title = "$($C.PURPLE)"

cursor = "$($C.PINK)"
correct = "$($C.GREEN)"
error = "$($C.RED)"
hint = "$($C.CYAN)"
cancel = "$($C.MUTED)"
"@ | Set-Content -Path "$SpfThemeDir\$Theme.toml"

if (Test-Path $SpfConfig) {
  $content = Get-Content $SpfConfig
  if ($content -match "^theme = ") {
    $content = $content -replace "^theme = .*", "theme = `"$Theme`""
    Set-Content -Path $SpfConfig -Value $content
  } else {
    Add-Content -Path $SpfConfig -Value "theme = `"$Theme`""
  }
} else {
  Write-Host "Couldn't find/generate $SpfConfig — run 'spf' once yourself, then set theme = `"$Theme`" in its config.toml (run 'spf path-list' to find the exact path)."
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
