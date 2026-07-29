#!/data/data/com.termux/files/usr/bin/env bash
# One-stop terminal setup for Termux (Android)
# zsh + oh-my-zsh, Nerd Font, oh-my-posh, lsd, bat, fzf, zoxide, tmux,
# superfile — pick your font and theme below (10 themes, all Dracula-style
# ecosystems: Dracula, Catppuccin x4, Gruvbox, Nord, Tokyo Night, Rose Pine,
# Everforest).
# Usage: bash setup-termux.sh
set -e

NERD_FONT_NAME="JetBrainsMono"   # default; the picker below can override this
THEME="dracula"                  # default; the picker below can override this

FONT_CHOICES=(JetBrainsMono FiraCode CascadiaCode Hack Meslo SourceCodePro Iosevka UbuntuMono RobotoMono Inconsolata)
THEME_CHOICES=(dracula catppuccin-mocha catppuccin-macchiato catppuccin-frappe catppuccin-latte gruvbox nord tokyonight rosepine everforest)

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
SUPERFILE_THEME=""
TMUX_MODE="custom"   # "dracula-plugin" (official) or "custom" (hand-colored)
C_BG=""; C_FG=""; C_MUTED=""; C_PURPLE=""; C_ORANGE=""; C_CYAN=""; C_BLUE=""; C_PINK=""; C_YELLOW=""; C_RED=""; C_GREEN=""
L_BG=""; L_FG=""; L_MUTED=""; L_PURPLE=""; L_ORANGE=""; L_CYAN=""; L_BLUE=""; L_PINK=""; L_YELLOW=""; L_RED=""; L_GREEN=""

case "$THEME" in
  dracula)
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/dracula.omp.json"
    LSD_COLORS_URL="https://raw.githubusercontent.com/dracula/lsd/main/colors.yaml"
    BAT_THEME_NAME="Dracula"
    SUPERFILE_THEME="dracula"
    TMUX_MODE="dracula-plugin"
    C_BG="#282a36"; C_FG="#f8f8f2"; C_MUTED="#6272a4"; C_PURPLE="#bd93f9"; C_ORANGE="#ffb86c"; C_CYAN="#8be9fd"; C_BLUE="#8be9fd"; C_PINK="#ff79c6"; C_YELLOW="#f1fa8c"; C_RED="#ff5555"; C_GREEN="#50fa7b"
    ;;
  catppuccin-mocha)
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_mocha.omp.json"
    # catppuccin/lsd's official colors.yaml uses hex strings, which the
    # apt-packaged lsd (1.0.0) silently ignores (numeric 256-color indices
    # only, confirmed by testing) — generate our own like the rest below.
    BAT_THEME_NAME="Catppuccin Mocha"
    BAT_THEME_URL="https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme"
    SUPERFILE_THEME="catppuccin-mocha"
    C_BG="#1e1e2e"; C_FG="#cdd6f4"; C_MUTED="#6c7086"; C_PURPLE="#cba6f7"; C_ORANGE="#fab387"; C_CYAN="#94e2d5"; C_BLUE="#89b4fa"; C_PINK="#f5c2e7"; C_YELLOW="#f9e2af"; C_RED="#f38ba8"; C_GREEN="#a6e3a1"
    L_BG=235; L_FG=189; L_MUTED=243; L_PURPLE=183; L_ORANGE=216; L_CYAN=116; L_BLUE=111; L_PINK=218; L_YELLOW=223; L_RED=211; L_GREEN=151
    ;;
  catppuccin-macchiato)
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_macchiato.omp.json"
    BAT_THEME_NAME="Catppuccin Macchiato"
    BAT_THEME_URL="https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Macchiato.tmTheme"
    SUPERFILE_THEME="catppuccin-macchiato"
    C_BG="#24273a"; C_FG="#cad3f5"; C_MUTED="#6e738d"; C_PURPLE="#c6a0f6"; C_ORANGE="#f5a97f"; C_CYAN="#8bd5ca"; C_BLUE="#8aadf4"; C_PINK="#f5bde6"; C_YELLOW="#eed49f"; C_RED="#ed8796"; C_GREEN="#a6da95"
    L_BG=236; L_FG=189; L_MUTED=243; L_PURPLE=183; L_ORANGE=216; L_CYAN=116; L_BLUE=111; L_PINK=218; L_YELLOW=223; L_RED=210; L_GREEN=150
    ;;
  catppuccin-frappe)
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_frappe.omp.json"
    BAT_THEME_NAME="Catppuccin Frappe"
    BAT_THEME_URL="https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Frappe.tmTheme"
    SUPERFILE_THEME="catppuccin-frappe"
    C_BG="#303446"; C_FG="#c6d0f5"; C_MUTED="#737994"; C_PURPLE="#ca9ee6"; C_ORANGE="#ef9f76"; C_CYAN="#81c8be"; C_BLUE="#8caaee"; C_PINK="#f4b8e4"; C_YELLOW="#e5c890"; C_RED="#e78284"; C_GREEN="#a6d189"
    L_BG=237; L_FG=189; L_MUTED=244; L_PURPLE=182; L_ORANGE=216; L_CYAN=115; L_BLUE=111; L_PINK=218; L_YELLOW=186; L_RED=174; L_GREEN=150
    ;;
  catppuccin-latte)
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_latte.omp.json"
    BAT_THEME_NAME="Catppuccin Latte"
    BAT_THEME_URL="https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Latte.tmTheme"
    SUPERFILE_THEME="catppuccin-latte"
    C_BG="#eff1f5"; C_FG="#4c4f69"; C_MUTED="#9ca0b0"; C_PURPLE="#8839ef"; C_ORANGE="#fe640b"; C_CYAN="#179299"; C_BLUE="#1e66f5"; C_PINK="#ea76cb"; C_YELLOW="#df8e1d"; C_RED="#d20f39"; C_GREEN="#40a02b"
    L_BG=255; L_FG=240; L_MUTED=248; L_PURPLE=99; L_ORANGE=202; L_CYAN=30; L_BLUE=27; L_PINK=176; L_YELLOW=172; L_RED=161; L_GREEN=70
    ;;
  gruvbox)
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/gruvbox.omp.json"
    BAT_THEME_NAME="gruvbox-dark"
    SUPERFILE_THEME="gruvbox"
    C_BG="#282828"; C_FG="#ebdbb2"; C_MUTED="#928374"; C_PURPLE="#d3869b"; C_ORANGE="#fe8019"; C_CYAN="#8ec07c"; C_BLUE="#83a598"; C_PINK="#d3869b"; C_YELLOW="#fabd2f"; C_RED="#fb4934"; C_GREEN="#b8bb26"
    L_BG=235; L_FG=187; L_MUTED=244; L_PURPLE=174; L_ORANGE=208; L_CYAN=108; L_BLUE=108; L_PINK=174; L_YELLOW=214; L_RED=203; L_GREEN=142
    ;;
  nord)
    BAT_THEME_NAME="Nord"
    SUPERFILE_THEME="nord"
    C_BG="#2e3440"; C_FG="#d8dee9"; C_MUTED="#4c566a"; C_PURPLE="#b48ead"; C_ORANGE="#d08770"; C_CYAN="#88c0d0"; C_BLUE="#81a1c1"; C_PINK="#bf616a"; C_YELLOW="#ebcb8b"; C_RED="#bf616a"; C_GREEN="#a3be8c"
    L_BG=237; L_FG=254; L_MUTED=240; L_PURPLE=139; L_ORANGE=173; L_CYAN=110; L_BLUE=109; L_PINK=131; L_YELLOW=186; L_RED=131; L_GREEN=144
    ;;
  tokyonight)
    BAT_THEME_NAME="tokyonight_night"
    BAT_THEME_URL="https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme"
    SUPERFILE_THEME="tokyonight"
    C_BG="#1a1b26"; C_FG="#c0caf5"; C_MUTED="#565f89"; C_PURPLE="#bb9af7"; C_ORANGE="#ff9e64"; C_CYAN="#7dcfff"; C_BLUE="#7aa2f7"; C_PINK="#bb9af7"; C_YELLOW="#e0af68"; C_RED="#f7768e"; C_GREEN="#9ece6a"
    L_BG=234; L_FG=153; L_MUTED=60; L_PURPLE=141; L_ORANGE=215; L_CYAN=117; L_BLUE=111; L_PINK=141; L_YELLOW=179; L_RED=210; L_GREEN=149
    ;;
  rosepine)
    BAT_THEME_NAME="Rose Pine"
    BAT_THEME_URL="https://raw.githubusercontent.com/rose-pine/tm-theme/main/dist/rose-pine.tmTheme"
    SUPERFILE_THEME="rose-pine"
    C_BG="#191724"; C_FG="#e0def4"; C_MUTED="#6e6a86"; C_PURPLE="#c4a7e7"; C_ORANGE="#ebbcba"; C_CYAN="#9ccfd8"; C_BLUE="#9ccfd8"; C_PINK="#eb6f92"; C_YELLOW="#f6c177"; C_RED="#eb6f92"; C_GREEN="#31748f"
    L_BG=234; L_FG=189; L_MUTED=60; L_PURPLE=182; L_ORANGE=181; L_CYAN=152; L_BLUE=152; L_PINK=168; L_YELLOW=216; L_RED=168; L_GREEN=66
    ;;
  everforest)
    BAT_THEME_NAME="Everforest Dark"
    BAT_THEME_URL="https://raw.githubusercontent.com/mhanberg/everforest-textmate/main/Everforest%20Dark/Everforest%20Dark.tmTheme"
    SUPERFILE_THEME="everforest-dark-medium"
    C_BG="#2d353b"; C_FG="#d3c6aa"; C_MUTED="#7a8478"; C_PURPLE="#d699b6"; C_ORANGE="#e69875"; C_CYAN="#83c092"; C_BLUE="#7fbbb3"; C_PINK="#d699b6"; C_YELLOW="#dbbc7f"; C_RED="#e67e80"; C_GREEN="#a7c080"
    L_BG=236; L_FG=187; L_MUTED=244; L_PURPLE=175; L_ORANGE=174; L_CYAN=108; L_BLUE=109; L_PINK=175; L_YELLOW=180; L_RED=174; L_GREEN=144
    ;;
  *)
    echo "Unknown theme '$THEME' — falling back to dracula" >&2
    THEME="dracula"
    OMP_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/dracula.omp.json"
    LSD_COLORS_URL="https://raw.githubusercontent.com/dracula/lsd/main/colors.yaml"
    BAT_THEME_NAME="Dracula"
    SUPERFILE_THEME="dracula"
    TMUX_MODE="dracula-plugin"
    C_BG="#282a36"; C_FG="#f8f8f2"; C_MUTED="#6272a4"; C_PURPLE="#bd93f9"; C_ORANGE="#ffb86c"; C_CYAN="#8be9fd"; C_BLUE="#8be9fd"; C_PINK="#ff79c6"; C_YELLOW="#f1fa8c"; C_RED="#ff5555"; C_GREEN="#50fa7b"
    ;;
esac

echo "=== 1/10: base packages ==="
pkg update -y
pkg install -y zsh curl wget git unzip

echo "=== 2/10: Oh My Zsh ==="
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

echo "=== 3/10: Nerd Font ($NERD_FONT_NAME) ==="
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

echo "=== 4/10: oh-my-posh ==="
if ! command -v oh-my-posh &> /dev/null; then
  pkg install -y oh-my-posh || {
    echo "termux package unavailable, falling back to GitHub binary"
    # oh-my-posh publishes exactly one Android build (posh-android-arm) —
    # unlike its Linux targets, there's no separate arm64/amd64 asset. An
    # earlier arch-mapped URL (posh-android-arm64/amd64) 404'd on every real
    # aarch64 device — the most common real Android architecture — which,
    # combined with `set -e`, silently killed the rest of this script with
    # zero remaining steps run. Don't arch-map this one; there's only one URL.
    if wget -q "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-android-arm" \
         -O "$PREFIX/bin/oh-my-posh"; then
      chmod +x "$PREFIX/bin/oh-my-posh"
    else
      rm -f "$PREFIX/bin/oh-my-posh"
      echo "Couldn't fetch the posh-android-arm binary — skipping oh-my-posh install. Install manually from https://ohmyposh.dev once it's available for your device."
    fi
  }
else
  echo "already installed, skipping"
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

echo "=== 5/10: lsd ==="
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

echo "=== 6/10: bat ==="
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

echo "=== 7/10: fzf ==="
if ! command -v fzf &> /dev/null; then
  pkg install -y fzf
else
  echo "already installed, skipping"
fi

echo "=== 8/10: zoxide ==="
if ! command -v zoxide &> /dev/null; then
  pkg install -y zoxide
else
  echo "already installed, skipping"
fi

echo "=== 9/10: tmux ==="
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

echo "=== 10/10: superfile ==="
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
if [ ! -f "$SPF_CONFIG" ] && command -v spf &> /dev/null; then
  # --fix-config-file writes the default config/hotkeys files as a side
  # effect, then exits non-zero because there's no TTY to open the TUI in
  # (fine — we only care about the files it wrote before failing).
  spf --fix-config-file >/dev/null 2>&1 || true
fi
if [ -f "$SPF_CONFIG" ]; then
  if grep -q "^theme = " "$SPF_CONFIG"; then
    sed -i "s/^theme = .*/theme = \"$SUPERFILE_THEME\"/" "$SPF_CONFIG"
  else
    echo "theme = \"$SUPERFILE_THEME\"" >> "$SPF_CONFIG"
  fi
else
  echo "Couldn't find/generate $SPF_CONFIG — run 'spf' once yourself, then set theme = \"$SUPERFILE_THEME\" in it."
fi

echo "=== configuring .zshrc ==="
MARK="# >>> custom terminal setup >>>"
MARK_END="# <<< custom terminal setup <<<"
touch "$HOME/.zshrc"
if grep -qF "$MARK" "$HOME/.zshrc"; then
  sed -i "/^${MARK}\$/,/^${MARK_END}\$/d" "$HOME/.zshrc"
fi
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
  7. Want a different font or theme? Just rerun this script — it'll prompt
     again and replace the old config.
EOF
