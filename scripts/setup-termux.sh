#!/data/data/com.termux/files/usr/bin/env bash
# One-stop terminal setup for Termux (Android)
# zsh + oh-my-zsh, Nerd Font, oh-my-posh, lsd, bat, fzf, zoxide, tmux,
# superfile, nerdfetch — pick your font and theme below (8 themes, all real premade
# oh-my-posh prompts fetched unmodified from upstream: Dracula, M365Princess,
# Atomic, Catppuccin, Catppuccin Mocha, JanDeDobbeleer, Marcduiker, Neko).
# Usage: bash setup-termux.sh
set -e

NERD_FONT_NAME="JetBrainsMono"   # default; the picker below can override this
THEME="dracula"                  # default; the picker below can override this

FONT_CHOICES=(JetBrainsMono FiraCode CascadiaCode Hack Meslo SourceCodePro Iosevka UbuntuMono RobotoMono Inconsolata)
THEME_CHOICES=(dracula m365princess atomic catppuccin catppuccin_mocha jandedobbeleer marcduiker neko)

# Prints a numbered menu to stderr, reads a choice from stdin, echoes the
# selected option to stdout (or the default on empty/invalid input).
choose_from_list() {
  local heading="$1" default="$2"
  shift 2
  local options=("$@")
  echo "$heading" >&2
  local i=1
  for o in "${options[@]}"; do
    echo "  $i) $o" >&2
    i=$((i + 1))
  done
  printf "Choice [1-%d, Enter for '%s']: " "${#options[@]}" "$default" >&2
  read -r ans
  if [ -z "$ans" ]; then
    printf '%s' "$default"
  elif [ "$ans" -eq "$ans" ] 2>/dev/null && [ "$ans" -ge 1 ] && [ "$ans" -le "${#options[@]}" ]; then
    printf '%s' "${options[$((ans - 1))]}"
  else
    echo "Didn't recognize that, using default: $default" >&2
    printf '%s' "$default"
  fi
}

# Only prompt when actually run interactively (a real terminal on stdin) —
# piped/non-interactive runs (CI, automation) keep the defaults above.
if [ -t 0 ]; then
  echo "=== Pick your setup (before anything installs) ==="
  NERD_FONT_NAME=$(choose_from_list "Nerd Font:" "$NERD_FONT_NAME" "${FONT_CHOICES[@]}")
  THEME=$(choose_from_list "Theme:" "$THEME" "${THEME_CHOICES[@]}")
  echo "Using font=$NERD_FONT_NAME theme=$THEME"
fi

# --- per-theme asset sources and role colors -------------------------------
# OMP_THEME_URL / LSD_COLORS_URL / BAT_THEME_URL: official upstream file when
# one exists for this palette; left empty when it doesn't, in which case the
# corresponding install step below generates one instead (oh-my-posh: recolor
# the proven dracula.omp.json template; lsd: write colors.yaml directly from
# the L_* xterm-256 indices, precomputed as the nearest-match to each
# palette's real hex colors).
OMP_THEME_URL=""
LSD_COLORS_URL=""
BAT_THEME_NAME=""
BAT_THEME_URL=""
TMUX_MODE="custom"   # "dracula-plugin" (official) or "custom" (hand-colored)
C_BG=""; C_FG=""; C_MUTED=""; C_PURPLE=""; C_ORANGE=""; C_CYAN=""; C_BLUE=""; C_PINK=""; C_YELLOW=""; C_RED=""; C_GREEN=""
L_BG=""; L_FG=""; L_MUTED=""; L_PURPLE=""; L_ORANGE=""; L_CYAN=""; L_BLUE=""; L_PINK=""; L_YELLOW=""; L_RED=""; L_GREEN=""

case "$THEME" in
  dracula)
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/dracula.omp.json"
    LSD_COLORS_URL="https://raw.githubusercontent.com/dracula/lsd/main/colors.yaml"
    BAT_THEME_NAME="Dracula"
    TMUX_MODE="dracula-plugin"
    C_BG="#282a36"; C_FG="#f8f8f2"; C_MUTED="#6272a4"; C_PURPLE="#bd93f9"; C_ORANGE="#ffb86c"; C_CYAN="#8be9fd"; C_BLUE="#8be9fd"; C_PINK="#ff79c6"; C_YELLOW="#f1fa8c"; C_RED="#ff5555"; C_GREEN="#50fa7b"
    ;;
  m365princess)
    # Microsoft 365-branded theme — its colors are declared through the
    # file's own named "palette" block (p:tan, p:plum, p:blush, etc.), not
    # inline hex on each segment. Resolved every p:name reference against
    # that palette table to get the real hex below, rather than guessing.
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/M365Princess.omp.json"
    BAT_THEME_NAME="Visual Studio Dark+"
    C_BG="#2b1331"; C_FG="#ffffff"; C_MUTED="#86bbd8"; C_PURPLE="#9a348e"; C_ORANGE="#cc3802"; C_CYAN="#047e84"; C_BLUE="#33658a"; C_PINK="#da627d"; C_YELLOW="#fca17d"; C_RED="#cc3802"; C_GREEN="#047e84"
    L_BG=235; L_FG=15; L_MUTED=110; L_PURPLE=96; L_ORANGE=166; L_CYAN=30; L_BLUE=60; L_PINK=168; L_YELLOW=216; L_RED=166; L_GREEN=30
    ;;
  catppuccin)
    # The official per-flavor files (catppuccin_mocha/_macchiato/_frappe/_latte
    # .omp.json) all use "style": "plain" — no powerline color-bar segments at
    # all. catppuccin.omp.json (the single "core" theme) is the one upstream
    # file that actually uses powerline/diamond segments with real background
    # colors; it hardcodes the Macchiato palette, so bat/lsd/superfile below
    # match Macchiato too for visual consistency.
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin.omp.json"
    BAT_THEME_NAME="Catppuccin Macchiato"
    BAT_THEME_URL="https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Macchiato.tmTheme"
    C_BG="#24273a"; C_FG="#cad3f5"; C_MUTED="#6e738d"; C_PURPLE="#c6a0f6"; C_ORANGE="#f5a97f"; C_CYAN="#8bd5ca"; C_BLUE="#8aadf4"; C_PINK="#f5bde6"; C_YELLOW="#eed49f"; C_RED="#ed8796"; C_GREEN="#a6da95"
    L_BG=236; L_FG=189; L_MUTED=243; L_PURPLE=183; L_ORANGE=216; L_CYAN=116; L_BLUE=111; L_PINK=218; L_YELLOW=223; L_RED=210; L_GREEN=150
    ;;
  atomic)
    # Pill/capsule segments (shell name, then folder+home path, then
    # execution time, left-aligned; OS icon + clock, right-aligned, with a
    # gap instead of a touching powerline chevron between the two blocks) —
    # confirmed by actually rendering atomic.omp.json in a real terminal and
    # comparing screenshots pixel-for-pixel, not by name alone. This used to
    # be the jandedobbeleer slot, but upstream jandedobbeleer.omp.json's
    # current released form is a totally different diamond session/path/git
    # layout — it never looked like this pill style at all.
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/atomic.omp.json"
    BAT_THEME_NAME="1337"
    C_BG="#0e0e0e"; C_FG="#ffffff"; C_MUTED="#b2bec3"; C_PURPLE="#83769c"; C_ORANGE="#ff9248"; C_CYAN="#40c4ff"; C_BLUE="#0077c2"; C_PINK="#ef5350"; C_YELLOW="#fffb38"; C_RED="#ef5350"; C_GREEN="#66bb6a"
    L_BG=233; L_FG=15; L_MUTED=250; L_PURPLE=103; L_ORANGE=209; L_CYAN=81; L_BLUE=31; L_PINK=203; L_YELLOW=227; L_RED=203; L_GREEN=71
    ;;
  catppuccin_mocha)
    # Same "core" vs "per-flavor" split as the catppuccin (Macchiato) entry
    # above, but here the real per-flavor Mocha file is used as-is on
    # purpose: every per-flavor catppuccin_*.omp.json upstream sets
    # "style": "plain" on every segment — flat colored text, no powerline/
    # diamond pill segments at all. That's genuinely how this theme looks
    # upstream, unmodified; it's not a bug to fix the way the general
    # "Catppuccin" pick above was. Colors are read from the file's own
    # "palette" block plus the rest of the well-known official Catppuccin
    # Mocha palette; the bat theme is the real official catppuccin/bat
    # Mocha asset, same mechanism as Macchiato above.
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_mocha.omp.json"
    BAT_THEME_NAME="Catppuccin Mocha"
    BAT_THEME_URL="https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme"
    C_BG="#1e1e2e"; C_FG="#cdd6f4"; C_MUTED="#acb0be"; C_PURPLE="#b4befe"; C_ORANGE="#fab387"; C_CYAN="#89dceb"; C_BLUE="#89b4fa"; C_PINK="#f5c2e7"; C_YELLOW="#f9e2af"; C_RED="#f38ba8"; C_GREEN="#a6e3a1"
    L_BG=235; L_FG=189; L_MUTED=249; L_PURPLE=147; L_ORANGE=216; L_CYAN=116; L_BLUE=111; L_PINK=218; L_YELLOW=223; L_RED=211; L_GREEN=151
    ;;
  jandedobbeleer)
    # oh-my-posh's own flagship theme, kept in step with upstream main —
    # its segment set has already changed more than once within this
    # repo's own lifetime (conditional per-language segments, a second
    # shell/time block, etc.), so it's always fetched fresh rather than
    # assumed stable; whatever upstream currently ships is what renders.
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json"
    BAT_THEME_NAME="Sublime Snazzy"
    C_BG="#1a1b26"; C_FG="#c0caf5"; C_MUTED="#565f89"; C_PURPLE="#c386f1"; C_ORANGE="#f36943"; C_CYAN="#2e9599"; C_BLUE="#0077c2"; C_PINK="#ff479c"; C_YELLOW="#fffb38"; C_RED="#ae1401"; C_GREEN="#1bd760"
    L_BG=234; L_FG=153; L_MUTED=60; L_PURPLE=141; L_ORANGE=203; L_CYAN=30; L_BLUE=31; L_PINK=205; L_YELLOW=227; L_RED=124; L_GREEN=41
    ;;
  marcduiker)
    # Retro pixel-art palette (orange/yellow/navy/blue) — the path and
    # status segments are genuine diamond/pill segments upstream, just
    # fewer of them than the busier themes above.
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/marcduiker.omp.json"
    BAT_THEME_NAME="gruvbox-dark"
    C_BG="#262b44"; C_FG="#ffffff"; C_MUTED="#5a6988"; C_PURPLE="#7a4fc9"; C_ORANGE="#feae34"; C_CYAN="#2ce8f5"; C_BLUE="#0095e9"; C_PINK="#e43b44"; C_YELLOW="#fee761"; C_RED="#e43b44"; C_GREEN="#38b764"
    L_BG=236; L_FG=15; L_MUTED=60; L_PURPLE=98; L_ORANGE=215; L_CYAN=45; L_BLUE=32; L_PINK=167; L_YELLOW=221; L_RED=167; L_GREEN=71
    ;;
  neko)
    # Whimsical, minimal theme: plain colored text and emoji, no
    # powerline/diamond segments upstream at all — left that way rather
    # than forcing a pill look it was never designed to have.
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/neko.omp.json"
    BAT_THEME_NAME="Nord"
    C_BG="#1a415d"; C_FG="#d8dee9"; C_MUTED="#5faae8"; C_PURPLE="#8d72e1"; C_ORANGE="#ff8000"; C_CYAN="#56b6c2"; C_BLUE="#5faae8"; C_PINK="#d0666f"; C_YELLOW="#e8c547"; C_RED="#d0666f"; C_GREEN="#6fae5f"
    L_BG=23; L_FG=254; L_MUTED=74; L_PURPLE=98; L_ORANGE=208; L_CYAN=73; L_BLUE=74; L_PINK=167; L_YELLOW=185; L_RED=167; L_GREEN=71
    ;;
  *)
    echo "Unknown theme '$THEME' — falling back to dracula" >&2
    THEME="dracula"
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/dracula.omp.json"
    LSD_COLORS_URL="https://raw.githubusercontent.com/dracula/lsd/main/colors.yaml"
    BAT_THEME_NAME="Dracula"
    TMUX_MODE="dracula-plugin"
    C_BG="#282a36"; C_FG="#f8f8f2"; C_MUTED="#6272a4"; C_PURPLE="#bd93f9"; C_ORANGE="#ffb86c"; C_CYAN="#8be9fd"; C_BLUE="#8be9fd"; C_PINK="#ff79c6"; C_YELLOW="#f1fa8c"; C_RED="#ff5555"; C_GREEN="#50fa7b"
    ;;
esac

echo "=== 1/11: base packages ==="
# `pkg` is a thin wrapper around apt (see the oh-my-posh step below), so it
# inherits the same failure mode: `pkg update -y` returns nonzero if even
# one configured mirror/repo is unreachable, even when the one we actually
# need refreshed fine — with `set -e` that silently kills the rest of this
# script at step 1 of 10. Don't let one broken mirror block everything
# downstream.
pkg update -y || true
pkg install -y zsh curl wget git unzip

echo "=== 2/11: Oh My Zsh ==="
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "already installed, skipping"
fi

echo "--- Oh My Zsh plugins (zsh-autosuggestions, zsh-syntax-highlighting, fzf) ---"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi
if [ -f "$HOME/.zshrc" ] && grep -q "oh-my-zsh.sh" "$HOME/.zshrc"; then
  # Oh My Zsh's own template is present (fresh install) — patch its lines directly.
  if grep -q "^plugins=(git)$" "$HOME/.zshrc"; then
    sed -i 's/^plugins=(git)$/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf)/' "$HOME/.zshrc"
  fi
  # oh-my-posh (below) draws the prompt, so the Oh My Zsh theme is just dead weight if left on.
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME=""/' "$HOME/.zshrc"
elif [ -f "$HOME/.zshrc" ]; then
  # KEEP_ZSHRC left an existing .zshrc untouched, so Oh My Zsh was never
  # actually wired in (no `source .../oh-my-zsh.sh` line) — bootstrap it
  # ourselves instead of silently no-op'ing the plugin patches above.
  MARK_OMZ="# >>> custom terminal setup (oh-my-zsh) >>>"
  if ! grep -qF "$MARK_OMZ" "$HOME/.zshrc"; then
    cat >> "$HOME/.zshrc" << EOF

$MARK_OMZ
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf)
source "\$ZSH/oh-my-zsh.sh"
# <<< custom terminal setup (oh-my-zsh) <<<
EOF
  fi
fi

echo "=== 3/11: Nerd Font ($NERD_FONT_NAME) ==="
# Termux doesn't use fontconfig — a single ~/.termux/font.ttf is the terminal font.
mkdir -p "$HOME/.termux"
if [ ! -f "$HOME/.termux/font.ttf" ]; then
  cd /tmp
  wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${NERD_FONT_NAME}.zip" -O nerdfont.zip
  unzip -o -q nerdfont.zip -d nerdfont_extracted
  # Grab a single regular, non-mono-windows-compatible ttf for the terminal
  FONT_FILE=$(find nerdfont_extracted -iname "*Regular*.ttf" ! -iname "*Windows*" | head -n 1)
  cp "$FONT_FILE" "$HOME/.termux/font.ttf"
  termux-reload-settings 2>/dev/null || true
  echo "Font installed as ~/.termux/font.ttf and applied."
else
  echo "already installed, skipping"
fi

echo "=== 4/11: oh-my-posh ==="
# `command -v` only proves a file exists on PATH, not that it actually runs.
# A binary left behind by a bad `pkg` mirror, an interrupted GitHub fetch, or
# (very commonly on Termux) restoring $PREFIX from a backup taken on a
# different Termux install/build can be present but non-functional — e.g.
# Android's linker outright refusing a non-PIE ELF ("has unexpected e_type").
# Trusting presence alone means a broken binary gets silently accepted once
# and then "already installed, skipping" forever after, with no way to
# recover short of the user noticing and deleting it by hand. Check that it
# actually runs before deciding to skip.
if command -v oh-my-posh &> /dev/null && oh-my-posh --version &> /dev/null; then
  echo "already installed, skipping"
else
  if command -v oh-my-posh &> /dev/null; then
    echo "oh-my-posh is on PATH but doesn't run (broken binary?) — reinstalling"
    # Remove it first: if this broken file isn't tracked by dpkg at all (e.g.
    # it came from the GitHub-fallback fetch below on a previous run, not
    # from the pkg below), `pkg install` can fail outright trying to
    # overwrite an untracked path instead of cleanly replacing it.
    rm -f "$(command -v oh-my-posh)"
  fi
  # --reinstall matters here: if the file we just rm -f'd was dpkg-tracked,
  # dpkg's database still says the package is installed at its current
  # version. A plain `pkg install -y` only compares version numbers, sees
  # nothing to do ("already the newest version"), and leaves the file
  # missing forever — every future run repeats the same no-op. --reinstall
  # forces apt/dpkg to redeploy the package's files regardless of the
  # version already recorded as installed, correctly repairing that desync.
  pkg install --reinstall -y oh-my-posh || true
  if ! oh-my-posh --version &> /dev/null; then
    echo "termux package unavailable or non-functional, falling back to GitHub binary"
    # oh-my-posh publishes exactly one Android build (posh-android-arm) —
    # unlike its Linux targets, there's no separate arm64/amd64 asset. An
    # earlier arch-mapped URL (posh-android-arm64/amd64) 404'd on every real
    # aarch64 device — the most common real Android architecture — which,
    # combined with `set -e`, silently killed the rest of this script with
    # zero remaining steps run. Don't arch-map this one; there's only one URL.
    if wget -q "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-android-arm" \
         -O "$PREFIX/bin/oh-my-posh"; then
      chmod +x "$PREFIX/bin/oh-my-posh"
      if ! oh-my-posh --version &> /dev/null; then
        rm -f "$PREFIX/bin/oh-my-posh"
        echo "Fetched oh-my-posh but it still doesn't run on this device — skipping. Install manually from https://ohmyposh.dev once a compatible build is available."
      fi
    else
      rm -f "$PREFIX/bin/oh-my-posh"
      echo "Couldn't fetch the posh-android-arm binary — skipping oh-my-posh install. Install manually from https://ohmyposh.dev once it's available for your device."
    fi
  fi
fi

echo "--- fetching $THEME theme for oh-my-posh ---"
mkdir -p "$HOME/.poshthemes"
POSH_THEME_FILE="$HOME/.poshthemes/${THEME}.omp.json"
if [ ! -f "$POSH_THEME_FILE" ]; then
  if [ -n "$OMP_THEME_URL" ]; then
    curl -sLo "$POSH_THEME_FILE" "$OMP_THEME_URL"
  else
    # No official oh-my-posh theme exists for this palette — recolor the
    # proven Dracula template (same schema, guaranteed to render) instead
    # of hand-writing a new prompt config from scratch. Two-pass placeholder
    # swap so a target color can never collide with a not-yet-replaced
    # source color.
    curl -sLo /tmp/omp-base.omp.json \
      https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/dracula.omp.json
    cp /tmp/omp-base.omp.json "$POSH_THEME_FILE"
    sed -i \
      -e 's/#282a36/@@BG@@/g' -e 's/#f8f8f2/@@FG@@/g' -e 's/#6272a4/@@MUTED@@/g' \
      -e 's/#bd93f9/@@PURPLE@@/g' -e 's/#ffb86c/@@ORANGE@@/g' -e 's/#8be9fd/@@CYAN@@/g' \
      -e 's/#ff79c6/@@PINK@@/g' -e 's/#f1fa8c/@@YELLOW@@/g' \
      "$POSH_THEME_FILE"
    sed -i \
      -e "s/@@BG@@/${C_BG}/g" -e "s/@@FG@@/${C_FG}/g" -e "s/@@MUTED@@/${C_MUTED}/g" \
      -e "s/@@PURPLE@@/${C_PURPLE}/g" -e "s/@@ORANGE@@/${C_ORANGE}/g" -e "s/@@CYAN@@/${C_CYAN}/g" \
      -e "s/@@PINK@@/${C_PINK}/g" -e "s/@@YELLOW@@/${C_YELLOW}/g" \
      "$POSH_THEME_FILE"
    rm -f /tmp/omp-base.omp.json
  fi
else
  echo "already present, skipping"
fi

echo "=== 5/11: lsd ==="
if ! command -v lsd &> /dev/null; then
  pkg install -y lsd
else
  echo "already installed, skipping"
fi

echo "--- setting lsd theme to $THEME ---"
mkdir -p "$HOME/.config/lsd"
cat > "$HOME/.config/lsd/config.yaml" << 'EOF'
color:
  when: auto
  theme: custom
EOF
LSD_COLORS="$HOME/.config/lsd/colors.yaml"
if [ ! -f "$LSD_COLORS" ] || ! head -1 "$LSD_COLORS" | grep -qF "$THEME"; then
  if [ -n "$LSD_COLORS_URL" ]; then
    { echo "# $THEME"; curl -sL "$LSD_COLORS_URL"; } > "$LSD_COLORS"
  else
    cat > "$LSD_COLORS" << EOF
# $THEME
user: $L_CYAN
group: $L_FG
permission:
  read: $L_BLUE
  write: $L_PURPLE
  exec: $L_CYAN
  exec-sticky: $L_CYAN
  no-access: $L_RED
date:
  hour-old: $L_MUTED
  day-old: $L_MUTED
  older: $L_MUTED
size:
  none: $L_MUTED
  small: $L_GREEN
  medium: $L_ORANGE
  large: $L_RED
inode:
  valid: $L_FG
  invalid: $L_RED
links:
  valid: $L_CYAN
  invalid: $L_RED
tree-edge: $L_BLUE
EOF
  fi
else
  echo "already present, skipping"
fi

echo "=== 6/11: bat ==="
if ! command -v bat &> /dev/null && ! command -v batcat &> /dev/null; then
  pkg install -y bat
else
  echo "already installed, skipping"
fi

echo "--- setting bat theme to $THEME ---"
BAT_CMD="bat"; command -v bat &> /dev/null || BAT_CMD="batcat"
if command -v "$BAT_CMD" &> /dev/null && [ -n "$BAT_THEME_URL" ]; then
  BAT_THEME_DIR="$("$BAT_CMD" --config-dir)/themes"
  mkdir -p "$BAT_THEME_DIR"
  BAT_THEME_FILE="$BAT_THEME_DIR/${BAT_THEME_NAME}.tmTheme"
  if [ ! -f "$BAT_THEME_FILE" ]; then
    curl -sLo "$BAT_THEME_FILE" "$BAT_THEME_URL"
    "$BAT_CMD" cache --build > /dev/null 2>&1 || true
  else
    echo "already present, skipping"
  fi
fi

echo "=== 7/11: fzf ==="
if ! command -v fzf &> /dev/null; then
  pkg install -y fzf
else
  echo "already installed, skipping"
fi

echo "=== 8/11: zoxide ==="
if ! command -v zoxide &> /dev/null; then
  pkg install -y zoxide
else
  echo "already installed, skipping"
fi

echo "=== 9/11: tmux ==="
if ! command -v tmux &> /dev/null; then
  pkg install -y tmux
else
  echo "already installed, skipping"
fi

echo "--- setting tmux theme to $THEME ---"
TMUX_MARK="# >>> custom terminal setup >>>"
TMUX_MARK_END="# <<< custom terminal setup <<<"
TMUX_CONF="$HOME/.tmux.conf"
touch "$TMUX_CONF"
if grep -qF "$TMUX_MARK" "$TMUX_CONF"; then
  sed -i "/^${TMUX_MARK}\$/,/^${TMUX_MARK_END}\$/d" "$TMUX_CONF"
fi
if [ "$TMUX_MODE" = "dracula-plugin" ]; then
  TMUX_DRACULA_DIR="$HOME/.tmux/plugins/dracula"
  if [ ! -d "$TMUX_DRACULA_DIR" ]; then
    git clone --depth=1 https://github.com/dracula/tmux "$TMUX_DRACULA_DIR"
  fi
  cat >> "$TMUX_CONF" << EOF

$TMUX_MARK
run-shell $TMUX_DRACULA_DIR/dracula.tmux
$TMUX_MARK_END
EOF
else
  # No official standalone (non-TPM) tmux port for every palette, and
  # community ones vary too much in structure/conventions to clone
  # reliably — hand-color a compact status bar directly instead, using
  # this theme's own role colors.
  cat >> "$TMUX_CONF" << EOF

$TMUX_MARK
set -g status-style "bg=$C_BG,fg=$C_FG"
set -g window-status-current-style "bg=$C_PURPLE,fg=$C_BG"
set -g window-status-style "bg=$C_BG,fg=$C_MUTED"
set -g pane-border-style "fg=$C_MUTED"
set -g pane-active-border-style "fg=$C_PURPLE"
set -g message-style "bg=$C_PURPLE,fg=$C_BG"
set -g status-left "#[bg=$C_GREEN,fg=$C_BG,bold] #S #[bg=$C_BG,fg=$C_GREEN]"
set -g status-right "#[fg=$C_MUTED]#[bg=$C_MUTED,fg=$C_BG] %H:%M #[bg=$C_BG,fg=$C_MUTED]"
$TMUX_MARK_END
EOF
fi

echo "=== 10/11: superfile ==="
if ! command -v spf &> /dev/null; then
  ARCH=$(uname -m)
  case "$ARCH" in
    aarch64) SPF_ARCH="arm64" ;;
    x86_64) SPF_ARCH="amd64" ;;
    *) echo "Unsupported architecture for superfile: $ARCH"; SPF_ARCH="" ;;
  esac
  if [ -n "$SPF_ARCH" ]; then
    cd /tmp
    # The GitHub API is unauthenticated here and rate-limited per IP — on a
    # shared mobile/carrier connection that's a real way for this to fail.
    # A prior version let a failed lookup (empty SPF_TAG) or failed download
    # fall through to `wget`/`tar`, which, combined with `set -e`, silently
    # killed the rest of the script with zero remaining steps run.
    SPF_TAG=$(curl -s https://api.github.com/repos/yorukot/superfile/releases/latest | grep -oP '"tag_name": "v\K[^"]+') || true
    if [ -z "$SPF_TAG" ]; then
      echo "Couldn't determine the latest Superfile release (GitHub API unreachable or rate-limited) — skipping. Install manually from https://superfile.dev"
    elif ! wget -q "https://github.com/yorukot/superfile/releases/download/v${SPF_TAG}/superfile-linux-v${SPF_TAG}-${SPF_ARCH}.tar.gz"; then
      echo "Couldn't download Superfile v${SPF_TAG} for ${SPF_ARCH} — skipping. Install manually from https://superfile.dev"
    else
      tar -xzf "superfile-linux-v${SPF_TAG}-${SPF_ARCH}.tar.gz"
      # The tarball nests the binary under dist/<name>/spf, not at the top level.
      cp "./dist/superfile-linux-v${SPF_TAG}-${SPF_ARCH}/spf" "$PREFIX/bin/spf"
      chmod +x "$PREFIX/bin/spf"
    fi
  else
    echo "Skipping superfile — install manually from https://superfile.dev"
  fi
else
  echo "already installed, skipping"
fi

echo "--- setting superfile theme to $THEME ---"
SPF_CONFIG_DIR="$HOME/.config/superfile"
SPF_CONFIG="$SPF_CONFIG_DIR/config.toml"
if [ ! -f "$SPF_CONFIG" ]; then
  # `spf --fix-config-file` looks like the natural way to generate this, but
  # it opens the real controlling terminal directly (like /dev/tty) rather
  # than respecting redirected stdin/stdout, so on an actual interactive
  # terminal (i.e. every real run of this script) it launches the full TUI
  # and hangs instead of writing the config and exiting — confirmed live,
  # not just suspected. Superfile fills in every field it doesn't find with
  # a built-in default (that's what --fix-config-file itself is documented
  # to do: "adds any *missing* fields"), so a minimal file with just the
  # theme line is sufficient and has no TTY risk at all.
  mkdir -p "$SPF_CONFIG_DIR"
  echo "theme = \"$THEME\"" > "$SPF_CONFIG"
fi
# Superfile supports fully custom theme files (not just its bundled names) —
# https://superfile.dev/configure/custom-theme/ — so write our own using this
# theme's own role colors instead of guessing at the closest bundled name.
mkdir -p "$SPF_CONFIG_DIR/theme"
cat > "$SPF_CONFIG_DIR/theme/${THEME}.toml" << EOF
code_syntax_highlight = "dracula"

full_screen_fg = "$C_FG"
full_screen_bg = "$C_BG"

gradient_color = ["$C_GREEN", "$C_RED"]

file_panel_fg = "$C_FG"
file_panel_bg = "$C_BG"
file_panel_border = "$C_MUTED"
file_panel_border_active = "$C_MUTED"
file_panel_top_directory_icon = "$C_GREEN"
file_panel_top_path = "$C_CYAN"
file_panel_item_selected_fg = "$C_ORANGE"
file_panel_item_selected_bg = "$C_BG"

footer_fg = "$C_FG"
footer_bg = "$C_BG"
footer_border = "$C_MUTED"
footer_border_active = "$C_MUTED"

sidebar_fg = "$C_FG"
sidebar_bg = "$C_BG"
sidebar_title = "$C_PURPLE"
sidebar_border = "$C_BG"
sidebar_border_active = "$C_MUTED"
sidebar_item_selected_fg = "$C_ORANGE"
sidebar_item_selected_bg = "$C_BG"
sidebar_divider = "$C_MUTED"

modal_fg = "$C_FG"
modal_bg = "$C_BG"
modal_border_active = "$C_MUTED"
modal_cancel_fg = "$C_FG"
modal_cancel_bg = "$C_MUTED"
modal_confirm_fg = "$C_FG"
modal_confirm_bg = "$C_ORANGE"

help_menu_hotkey = "$C_ORANGE"
help_menu_title = "$C_PURPLE"

cursor = "$C_PINK"
correct = "$C_GREEN"
error = "$C_RED"
hint = "$C_CYAN"
cancel = "$C_MUTED"
EOF
if [ -f "$SPF_CONFIG" ]; then
  if grep -q "^theme = " "$SPF_CONFIG"; then
    sed -i "s/^theme = .*/theme = \"$THEME\"/" "$SPF_CONFIG"
  else
    echo "theme = \"$THEME\"" >> "$SPF_CONFIG"
  fi
else
  echo "Couldn't find/generate $SPF_CONFIG — run 'spf' once yourself, then set theme = \"$THEME\" in it."
fi

echo "=== 11/11: nerdfetch ==="
# No Termux/apt package exists for this (only Arch/Homebrew/Nix/Gentoo) —
# it's a single POSIX shell script, so there's no per-architecture binary
# to match either, just a straight fetch to a file.
if ! command -v nerdfetch &> /dev/null; then
  if curl -fsSL https://raw.githubusercontent.com/ThatOneCalculator/NerdFetch/main/nerdfetch \
       -o "$PREFIX/bin/nerdfetch" && [ -s "$PREFIX/bin/nerdfetch" ]; then
    chmod +x "$PREFIX/bin/nerdfetch"
  else
    rm -f "$PREFIX/bin/nerdfetch"
    echo "Couldn't fetch nerdfetch — skipping. Install manually from https://github.com/ThatOneCalculator/NerdFetch"
  fi
else
  echo "already installed, skipping"
fi

echo "=== configuring .zshrc ==="
MARK="# >>> custom terminal setup >>>"
MARK_END="# <<< custom terminal setup <<<"
touch "$HOME/.zshrc"
if grep -qF "$MARK" "$HOME/.zshrc"; then
  sed -i "/^${MARK}\$/,/^${MARK_END}\$/d" "$HOME/.zshrc"
fi
# Belt-and-suspenders: the managed block above (regenerated in full every
# run) already covers a nerdfetch line added inside it, but strip any bare
# `nerdfetch` invocation line left outside that block too, in case one was
# ever added by hand — so re-running never ends up with two calls to it.
sed -i '/^[[:space:]]*nerdfetch[[:space:]]*$/d' "$HOME/.zshrc"
cat >> "$HOME/.zshrc" << EOF

$MARK
eval "\$(oh-my-posh init zsh --config \$HOME/.poshthemes/${THEME}.omp.json)"
eval "\$(zoxide init zsh)"

alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -la'
alias lt='lsd --tree'

if ! command -v bat &> /dev/null && command -v batcat &> /dev/null; then
  alias bat='batcat'
fi
export BAT_THEME="$BAT_THEME_NAME"
alias cat='bat'

export FZF_DEFAULT_OPTS='--color=fg:$C_FG,bg:$C_BG,hl:$C_PURPLE --color=fg+:$C_FG,bg+:$C_MUTED,hl+:$C_PURPLE --color=info:$C_ORANGE,prompt:$C_GREEN,pointer:$C_PINK --color=marker:$C_PINK,spinner:$C_ORANGE,header:$C_MUTED'

command -v nerdfetch &> /dev/null && nerdfetch
$MARK_END
EOF

echo "=== setting zsh as default shell ==="
chsh -s zsh || echo "chsh failed — you can instead add 'exec zsh' to the end of ~/.bashrc"

cat << EOF

All done. Next steps:
  1. Restart Termux (fully close and reopen the app) to apply the font.
  2. Oh My Posh is set to the $THEME theme (~/.poshthemes/${THEME}.omp.json).
  3. Superfile is set to the $THEME theme (~/.config/superfile/config.toml).
     Launch it with: spf
  4. If oh-my-posh or superfile weren't available as Termux packages on your
     device/architecture, the script fell back to a GitHub binary — if that
     also failed, check https://ohmyposh.dev and https://superfile.dev manually.
  5. bat is set to the $THEME theme (\`cat\` is aliased to it); fzf uses the
     $THEME palette via FZF_DEFAULT_OPTS; zoxide replaces \`cd\` habits with
     \`z\`/\`zi\` (learns your most-used directories).
  6. tmux is set to the $THEME theme (~/.tmux.conf) — start a session with
     tmux.
  7. nerdfetch runs automatically at the end of a new shell (uses your
     Nerd Font icons — install it manually from
     https://github.com/ThatOneCalculator/NerdFetch if the fetch above failed).
  8. Want a different font or theme? Just rerun this script — it'll prompt
     again and replace the old config.
EOF
