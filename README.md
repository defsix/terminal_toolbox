# terminal-setup

One-stop scripts to provision a terminal with zsh (or PowerShell), a Nerd
Font, [Oh My Posh](https://ohmyposh.dev), [lsd](https://github.com/lsd-rs/lsd),
and [Superfile](https://superfile.dev) — themed in Dracula throughout.

## Usage

**Ubuntu / Debian / Raspberry Pi OS**
```
bash scripts/setup-ubuntu.sh
```

**Termux (Android)**
```
bash scripts/setup-termux.sh
```

**Windows (PowerShell, run as Administrator)**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\setup-windows.ps1
```

All scripts are idempotent — safe to re-run after a partial failure or to
pick up changes.

## What you get

- zsh + Oh My Zsh (PowerShell profile on Windows, since zsh isn't native there)
- A Nerd Font (JetBrainsMono by default — edit the variable at the top of
  each script to change it)
- Oh My Posh, Dracula theme
- lsd as a drop-in `ls` replacement (`ll`, `la`, `lt` aliases included)
- Superfile (`spf`), Dracula theme

See `CLAUDE.md` for implementation notes and known platform quirks.
