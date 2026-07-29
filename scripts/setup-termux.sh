#!/data/data/com.termux/files/usr/bin/env bash
# One-stop terminal setup for Termux (Android)
# zsh + oh-my-zsh, Nerd Font, oh-my-posh (Dracula), lsd, bat, fzf, zoxide,
# tmux (Dracula), superfile (Dracula)
# Usage: bash setup-termux.sh
set -e

NERD_FONT_NAME="JetBrainsMono"   # change if you prefer Meslo, FiraCode, Hack, etc.

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

echo "--- fetching Dracula theme for oh-my-posh ---"
mkdir -p "$HOME/.poshthemes"
if [ ! -f "$HOME/.poshthemes/dracula.omp.json" ]; then
  curl -sLo "$HOME/.poshthemes/dracula.omp.json" \
    https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/dracula.omp.json
else
  echo "already present, skipping"
fi

echo "=== 5/10: lsd ==="
if ! command -v lsd &> /dev/null; then
  pkg install -y lsd
else
  echo "already installed, skipping"
fi

echo "=== 6/10: bat ==="
if ! command -v bat &> /dev/null && ! command -v batcat &> /dev/null; then
  pkg install -y bat
else
  echo "already installed, skipping"
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

echo "--- fetching Dracula theme for tmux ---"
TMUX_DRACULA_DIR="$HOME/.tmux/plugins/dracula"
if [ ! -d "$TMUX_DRACULA_DIR" ]; then
  git clone --depth=1 https://github.com/dracula/tmux "$TMUX_DRACULA_DIR"
else
  echo "already present, skipping"
fi
TMUX_CONF="$HOME/.tmux.conf"
TMUX_MARK="# >>> custom terminal setup >>>"
if ! grep -qF "$TMUX_MARK" "$TMUX_CONF" 2>/dev/null; then
  cat >> "$TMUX_CONF" << EOF

$TMUX_MARK
run-shell $TMUX_DRACULA_DIR/dracula.tmux
# <<< custom terminal setup <<<
EOF
else
  echo ".tmux.conf already configured, skipping"
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

echo "--- setting superfile theme to Dracula ---"
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
    sed -i 's/^theme = .*/theme = "dracula"/' "$SPF_CONFIG"
  else
    echo 'theme = "dracula"' >> "$SPF_CONFIG"
  fi
else
  echo "Couldn't find/generate $SPF_CONFIG — run 'spf' once yourself, then set theme = \"dracula\" in it."
fi

echo "=== configuring .zshrc ==="
MARK="# >>> custom terminal setup >>>"
if ! grep -qF "$MARK" "$HOME/.zshrc" 2>/dev/null; then
  cat >> "$HOME/.zshrc" << EOF

$MARK
eval "\$(oh-my-posh init zsh --config \$HOME/.poshthemes/dracula.omp.json)"
eval "\$(zoxide init zsh)"

alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -la'
alias lt='lsd --tree'

if ! command -v bat &> /dev/null && command -v batcat &> /dev/null; then
  alias bat='batcat'
fi
export BAT_THEME="Dracula"
alias cat='bat'

export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
# <<< custom terminal setup <<<
EOF
else
  echo ".zshrc already configured, skipping"
fi

echo "=== setting zsh as default shell ==="
chsh -s zsh || echo "chsh failed — you can instead add 'exec zsh' to the end of ~/.bashrc"

cat << 'EOF'

All done. Next steps:
  1. Restart Termux (fully close and reopen the app) to apply the font.
  2. Oh My Posh is set to the Dracula theme (~/.poshthemes/dracula.omp.json).
  3. Superfile is set to the Dracula theme (~/.config/superfile/config.toml).
     Launch it with: spf
  4. If oh-my-posh or superfile weren't available as Termux packages on your
     device/architecture, the script fell back to a GitHub binary — if that
     also failed, check https://ohmyposh.dev and https://superfile.dev manually.
  5. bat is set to the Dracula theme (`cat` is aliased to it); fzf uses the
     Dracula palette via FZF_DEFAULT_OPTS; zoxide replaces `cd` habits with
     `z`/`zi` (learns your most-used directories).
  6. tmux is set to the Dracula theme (~/.tmux.conf) — start a session with
     tmux, prefix + I is not needed since the theme's already cloned in.
EOF
