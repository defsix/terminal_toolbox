#!/usr/bin/env bash
# One-stop terminal setup for Ubuntu / Debian / Raspberry Pi OS
# zsh + oh-my-zsh, Nerd Font, oh-my-posh (Dracula), lsd, bat, fzf, zoxide,
# tmux (Dracula), superfile (Dracula)
# Usage: bash setup-ubuntu.sh
set -e

NERD_FONT_NAME="JetBrainsMono"   # change to Meslo, FiraCode, Hack, etc. if you prefer
FONT_DIR="$HOME/.local/share/fonts"

echo "=== 1/10: base packages ==="
sudo apt update
sudo apt install -y zsh curl wget git unzip fontconfig

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

echo "=== 4/10: oh-my-posh ==="
if ! command -v oh-my-posh &> /dev/null; then
  mkdir -p "$HOME/.local/bin"
  # Piping straight into `bash` hides failures two ways: if the fetch fails
  # outright, bash gets an empty script and exits 0 (silently "succeeding"
  # at installing nothing — set -e never fires); if the connection is
  # blocked at a proxy that returns an error body over the tunnel, that
  # body can get executed as garbage shell commands instead. Download to a
  # file and check it explicitly instead of trusting the pipe's exit code.
  if curl -fsSL https://ohmyposh.dev/install.sh -o /tmp/ohmyposh-install.sh && [ -s /tmp/ohmyposh-install.sh ]; then
    bash /tmp/ohmyposh-install.sh -d "$HOME/.local/bin" || echo "oh-my-posh's installer failed — skipping. Install manually from https://ohmyposh.dev"
    rm -f /tmp/ohmyposh-install.sh
  else
    echo "Couldn't fetch the oh-my-posh installer from ohmyposh.dev — skipping. Install manually from https://ohmyposh.dev once reachable."
  fi
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
  sudo apt install -y lsd || {
    echo "apt package unavailable, falling back to .deb release"
    cd /tmp
    DEB_ARCH=$(dpkg --print-architecture)   # amd64 / arm64 / armhf — covers Raspberry Pi too
    # The GitHub API is unauthenticated here and rate-limited per IP. A prior
    # version let a failed lookup (empty LSD_TAG) fall through to `wget`,
    # which, combined with `set -e`, silently killed the rest of the script.
    LSD_TAG=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest | grep -oP '"tag_name": "\K[^"]+') || true
    if [ -z "$LSD_TAG" ]; then
      echo "Couldn't determine the latest lsd release (GitHub API unreachable or rate-limited) — skipping. Install manually from https://github.com/lsd-rs/lsd"
    else
      LSD_VER="${LSD_TAG#v}"
      if wget -q "https://github.com/lsd-rs/lsd/releases/download/${LSD_TAG}/lsd_${LSD_VER}_${DEB_ARCH}.deb"; then
        sudo dpkg -i "lsd_${LSD_VER}_${DEB_ARCH}.deb"
      else
        echo "Couldn't download lsd ${LSD_TAG} for ${DEB_ARCH} — skipping. Install manually from https://github.com/lsd-rs/lsd"
      fi
    fi
  }
else
  echo "already installed, skipping"
fi

echo "=== 6/10: bat ==="
if ! command -v bat &> /dev/null && ! command -v batcat &> /dev/null; then
  sudo apt install -y bat
else
  echo "already installed, skipping"
fi

echo "=== 7/10: fzf ==="
if ! command -v fzf &> /dev/null; then
  sudo apt install -y fzf
else
  echo "already installed, skipping"
fi

echo "=== 8/10: zoxide ==="
if ! command -v zoxide &> /dev/null; then
  sudo apt install -y zoxide
else
  echo "already installed, skipping"
fi

echo "=== 9/10: tmux ==="
if ! command -v tmux &> /dev/null; then
  sudo apt install -y tmux
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
  # Same reasoning as the oh-my-posh step above: a bare `curl | bash` (or
  # `bash -c "$(curl ...)"`) silently masks a failed fetch instead of
  # tripping set -e, so download to a file and check it explicitly first.
  if curl -fsSL https://superfile.dev/install.sh -o /tmp/superfile-install.sh && [ -s /tmp/superfile-install.sh ]; then
    bash /tmp/superfile-install.sh || echo "Superfile's installer failed — skipping. Install manually from https://superfile.dev"
    rm -f /tmp/superfile-install.sh
  else
    echo "Couldn't fetch the Superfile installer from superfile.dev — skipping. Install manually from https://superfile.dev once reachable."
  fi
else
  echo "already installed, skipping"
fi

echo "--- setting superfile theme to Dracula ---"
SPF_CONFIG_DIR="$HOME/.config/superfile"
SPF_CONFIG="$SPF_CONFIG_DIR/config.toml"
if [ ! -f "$SPF_CONFIG" ]; then
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
export PATH="\$HOME/.local/bin:\$PATH"
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
  5. bat is set to the Dracula theme (`cat` is aliased to it); fzf uses the
     Dracula palette via FZF_DEFAULT_OPTS; zoxide replaces `cd` habits with
     `z`/`zi` (learns your most-used directories).
  6. tmux is set to the Dracula theme (~/.tmux.conf) — start a session with
     tmux, prefix + I is not needed since the theme's already cloned in.
EOF
