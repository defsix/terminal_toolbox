#!/data/data/com.termux/files/usr/bin/env bash
# One-stop terminal setup for Termux (Android)
# zsh + oh-my-zsh, Nerd Font, oh-my-posh (Dracula), lsd, superfile (Dracula)
# Usage: bash setup-termux.sh
set -e

NERD_FONT_NAME="JetBrainsMono"   # change if you prefer Meslo, FiraCode, Hack, etc.

echo "=== 1/6: base packages ==="
pkg update -y
pkg install -y zsh curl wget git unzip

echo "=== 2/6: Oh My Zsh ==="
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "already installed, skipping"
fi

echo "=== 3/6: Nerd Font ($NERD_FONT_NAME) ==="
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

echo "=== 4/6: oh-my-posh ==="
if ! command -v oh-my-posh &> /dev/null; then
  pkg install -y oh-my-posh || {
    echo "termux package unavailable, falling back to GitHub binary"
    ARCH=$(uname -m)
    case "$ARCH" in
      aarch64) POSH_ARCH="arm64" ;;
      armv7l|armv8l) POSH_ARCH="arm" ;;
      x86_64) POSH_ARCH="amd64" ;;
      *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    wget -q "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-android-${POSH_ARCH}" \
      -O "$PREFIX/bin/oh-my-posh"
    chmod +x "$PREFIX/bin/oh-my-posh"
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

echo "=== 5/6: lsd ==="
if ! command -v lsd &> /dev/null; then
  pkg install -y lsd
else
  echo "already installed, skipping"
fi

echo "=== 6/6: superfile ==="
if ! command -v spf &> /dev/null; then
  ARCH=$(uname -m)
  case "$ARCH" in
    aarch64) SPF_ARCH="arm64" ;;
    x86_64) SPF_ARCH="amd64" ;;
    *) echo "Unsupported architecture for superfile: $ARCH"; SPF_ARCH="" ;;
  esac
  if [ -n "$SPF_ARCH" ]; then
    cd /tmp
    SPF_TAG=$(curl -s https://api.github.com/repos/yorukot/superfile/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
    wget -q "https://github.com/yorukot/superfile/releases/download/v${SPF_TAG}/superfile-linux-v${SPF_TAG}-${SPF_ARCH}.tar.gz"
    tar -xzf "superfile-linux-v${SPF_TAG}-${SPF_ARCH}.tar.gz"
    cp ./spf "$PREFIX/bin/spf"
    chmod +x "$PREFIX/bin/spf"
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
  # First run generates the default config files; path-list is a no-op
  # command that still triggers config initialization.
  spf path-list >/dev/null 2>&1 || true
fi
if [ -f "$SPF_CONFIG" ]; then
  if grep -q "^theme = " "$SPF_CONFIG"; then
    sed -i "s/^theme = .*/theme = 'dracula'/" "$SPF_CONFIG"
  else
    echo "theme = 'dracula'" >> "$SPF_CONFIG"
  fi
else
  echo "Couldn't find/generate $SPF_CONFIG — run 'spf' once yourself, then set theme = 'dracula' in it."
fi

echo "=== configuring .zshrc ==="
MARK="# >>> custom terminal setup >>>"
if ! grep -qF "$MARK" "$HOME/.zshrc" 2>/dev/null; then
  cat >> "$HOME/.zshrc" << EOF

$MARK
eval "\$(oh-my-posh init zsh --config \$HOME/.poshthemes/dracula.omp.json)"

alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -la'
alias lt='lsd --tree'
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
EOF
