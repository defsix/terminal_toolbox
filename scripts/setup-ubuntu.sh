#!/usr/bin/env bash
# One-stop terminal setup for Ubuntu / Debian / Raspberry Pi OS
# zsh + oh-my-zsh, Nerd Font, oh-my-posh (Dracula), lsd, superfile (Dracula)
# Usage: bash setup-ubuntu.sh
set -e

NERD_FONT_NAME="JetBrainsMono"   # change to Meslo, FiraCode, Hack, etc. if you prefer
FONT_DIR="$HOME/.local/share/fonts"

echo "=== 1/6: base packages ==="
sudo apt update
sudo apt install -y zsh curl wget git unzip fontconfig

echo "=== 2/6: Oh My Zsh ==="
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "already installed, skipping"
fi

echo "=== 3/6: Nerd Font ($NERD_FONT_NAME) ==="
mkdir -p "$FONT_DIR"
if ! fc-list | grep -qi "$NERD_FONT_NAME Nerd Font"; then
  cd /tmp
  wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${NERD_FONT_NAME}.zip" -O nerdfont.zip
  unzip -o -q nerdfont.zip -d "$FONT_DIR/${NERD_FONT_NAME}NerdFont"
  fc-cache -f "$FONT_DIR" >/dev/null
  echo "Font installed. Set your terminal emulator's font to '${NERD_FONT_NAME} Nerd Font'."
else
  echo "already installed, skipping"
fi

echo "=== 4/6: oh-my-posh ==="
if ! command -v oh-my-posh &> /dev/null; then
  mkdir -p "$HOME/.local/bin"
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
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
  sudo apt install -y lsd || {
    echo "apt package unavailable, falling back to .deb release"
    cd /tmp
    DEB_ARCH=$(dpkg --print-architecture)   # amd64 / arm64 / armhf — covers Raspberry Pi too
    LSD_TAG=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest | grep -oP '"tag_name": "\K[^"]+')
    LSD_VER="${LSD_TAG#v}"
    wget -q "https://github.com/lsd-rs/lsd/releases/download/${LSD_TAG}/lsd_${LSD_VER}_${DEB_ARCH}.deb"
    sudo dpkg -i "lsd_${LSD_VER}_${DEB_ARCH}.deb"
  }
else
  echo "already installed, skipping"
fi

echo "=== 6/6: superfile ==="
if ! command -v spf &> /dev/null; then
  bash -c "$(curl -sLo- https://superfile.dev/install.sh)"
else
  echo "already installed, skipping"
fi

echo "--- setting superfile theme to Dracula ---"
SPF_CONFIG_DIR="$HOME/.config/superfile"
SPF_CONFIG="$SPF_CONFIG_DIR/config.toml"
if [ ! -f "$SPF_CONFIG" ]; then
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
export PATH="\$HOME/.local/bin:\$PATH"
eval "\$(oh-my-posh init zsh --config \$HOME/.poshthemes/dracula.omp.json)"

alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -la'
alias lt='lsd --tree'
alias spf='spf'
# <<< custom terminal setup <<<
EOF
else
  echo ".zshrc already configured, skipping"
fi

echo "=== setting zsh as default shell ==="
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
  echo "Default shell changed to zsh — log out/in (or reboot) for it to take effect."
fi

cat << 'EOF'

All done. Next steps:
  1. Open your terminal emulator's font settings and pick "JetBrainsMono Nerd Font"
     (or whichever font you set NERD_FONT_NAME to at the top of this script).
  2. Log out and back in, or run: exec zsh
  3. Oh My Posh is set to the Dracula theme (~/.poshthemes/dracula.omp.json).
  4. Superfile is set to the Dracula theme (~/.config/superfile/config.toml).
     Launch it with: spf
EOF
