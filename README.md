# terminal-setup

One-stop scripts to provision a terminal with zsh (or PowerShell), a Nerd
Font, [Oh My Zsh](https://ohmyz.sh), [Oh My Posh](https://ohmyposh.dev),
[lsd](https://github.com/lsd-rs/lsd), [bat](https://github.com/sharkdp/bat),
[fzf](https://github.com/junegunn/fzf), [zoxide](https://github.com/ajeetdsouza/zoxide),
[tmux](https://github.com/tmux/tmux), and [Superfile](https://superfile.dev).

Run one interactively and it opens with a picker — 10 Nerd Fonts, 7 themes
(Dracula, Catppuccin, Gruvbox, Nord, Tokyo Night, Rose Pine, Everforest) —
before anything installs. Piped/CI runs skip the prompt and keep the
Dracula + JetBrainsMono defaults.

> Screenshots below are real captures, not mockups: taken by actually running
> `scripts/setup-ubuntu.sh` end-to-end, then recording the resulting shell
> with [VHS](https://github.com/charmbracelet/vhs) — same Dracula
> `dracula.omp.json`/`dracula.toml` configs this repo installs, plus the
> official [dracula/lsd](https://github.com/dracula/lsd) `colors.yaml` for
> the `lsd` shot. What you see is what you get.

## Usage

Clone the repo and run the script for your platform, or install directly
with the one-liner below (uses process substitution / `iex`, not a plain
pipe, so the interactive font/theme picker still works — a straight
`curl | bash` pipe would consume stdin with the script itself and silently
force the non-interactive defaults).

**Ubuntu / Debian / Raspberry Pi OS**
```
bash scripts/setup-ubuntu.sh
```
```
bash <(curl -fsSL https://raw.githubusercontent.com/defsix/terminal_toolbox/main/scripts/setup-ubuntu.sh)
```

**Termux (Android)**
```
bash scripts/setup-termux.sh
```
```
bash <(curl -fsSL https://raw.githubusercontent.com/defsix/terminal_toolbox/main/scripts/setup-termux.sh)
```

**Windows (PowerShell, run as Administrator)**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\setup-windows.ps1
```
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex (irm https://raw.githubusercontent.com/defsix/terminal_toolbox/main/scripts/setup-windows.ps1)
```

All scripts are idempotent — safe to re-run after a partial failure or to
pick up changes.

## What you get

- zsh + **Oh My Zsh**, with the `zsh-autosuggestions` and
  `zsh-syntax-highlighting` plugins enabled alongside the default `git`
  plugin (PowerShell profile on Windows, since zsh isn't native there)
- An interactive picker — run the script from a real terminal and it asks
  for your Nerd Font and theme before installing anything; piped/CI runs
  keep the JetBrainsMono + Dracula defaults. Rerun anytime to switch: the
  script replaces its managed config instead of duplicating it.
- 10 Nerd Fonts to choose from: JetBrainsMono, FiraCode, CascadiaCode, Hack,
  Meslo, SourceCodePro, Iosevka, UbuntuMono, RobotoMono, Inconsolata
- 7 themes, applied consistently across every tool below: Dracula,
  Catppuccin, Gruvbox, Nord, Tokyo Night, Rose Pine, Everforest
- Oh My Posh drawing the prompt (Oh My Zsh's own theme is disabled so the
  two don't fight over the prompt)
- lsd as a drop-in `ls` replacement (`ll`, `la`, `lt` aliases included)
- bat (`cat` replacement), aliased over `cat`
- fzf, fuzzy search wired into Oh My Zsh (history search, file/completion
  widgets) via its bundled `fzf` plugin, themed via `FZF_DEFAULT_OPTS`
- zoxide, a learning `cd` — `z`/`zi` jump to frecently-used directories
- tmux, themed status bar (Linux/Termux only — no native Windows port; use WSL)
- Superfile (`spf`), themed to match

## Walkthrough

1. **Run the script for your platform** (see [Usage](#usage)). From a real
   terminal it asks you to pick a Nerd Font and a theme first — press Enter
   at either prompt to keep the default (JetBrainsMono / Dracula). Each
   install step then prints `=== n/10: ... ===` as it goes, and prints
   `already installed, skipping` for anything a previous run already
   handled.

2. **Prompt.** Once it's done, restart your shell (`exec zsh`, or log
   out/in). Oh My Posh draws the prompt — directory, git branch, shell,
   clock — in your chosen theme, on top of Oh My Zsh's `zsh-autosuggestions`
   (ghost-text completions from history) and `zsh-syntax-highlighting`
   (a command turns green once it resolves to something real, red if it
   doesn't). Screenshots below are from a Dracula run — the other 6 themes
   recolor the same prompt/icons/status bar, not a different layout:

   ![Oh My Zsh + Oh My Posh, Dracula theme](docs/screenshots/oh-my-zsh-dracula.png)
   *Top to bottom: a valid command in green, a typo (`gti`) in red, and
   `atus` shown as a greyed-out autosuggestion after typing `git st`.*

3. **File listing.** `ls`/`ll`/`la`/`lt` now resolve to `lsd`, which adds
   icons and per-file-type coloring — shown here with the official
   [dracula/lsd](https://github.com/dracula/lsd) `colors.yaml`:

   ![lsd -la, Dracula colors](docs/screenshots/lsd-dracula.png)

4. **bat / fzf / zoxide.** `cat` resolves to `bat` in your chosen theme,
   `Ctrl+R`/tab completion get fzf's fuzzy picker (same palette via
   `FZF_DEFAULT_OPTS`, wired in through Oh My Zsh's own `fzf` plugin so it
   finds the right integration files regardless of platform), and
   `z <partial-name>` jumps to a frecently-used directory via zoxide.

5. **tmux.** Start a session with `tmux` — the status bar comes up themed
   immediately, no `prefix + I` plugin-manager step needed. Dracula uses the
   official [dracula/tmux](https://github.com/dracula/tmux) plugin (cloned
   in directly by the script); the other 6 themes use a compact hand-colored
   status bar built from that theme's own palette, since not every theme has
   a maintained standalone (non-TPM) tmux port:

   ![tmux, Dracula theme](docs/screenshots/tmux-dracula.png)

6. **Superfile.** Launch the TUI file manager with `spf` — it opens with
   your chosen theme already set in its `config.toml`:

   ![Superfile, Dracula theme](docs/screenshots/superfile-dracula.png)

7. **Re-running is safe.** Every step is guarded by an existence check
   (directory, binary, or config line), so re-running after a failed step,
   or to pick up a new version of the script, only does the work that's
   still missing.

See `CLAUDE.md` for implementation notes and known platform quirks.

## Changelog

### 2026-07-29
- Enabled `zsh-autosuggestions` and `zsh-syntax-highlighting` as Oh My Zsh
  plugins on Ubuntu and Termux (previously Oh My Zsh was installed but left
  on its stock config with no extra plugins).
- Disabled Oh My Zsh's own `ZSH_THEME` on install so it no longer loads a
  theme that Oh My Posh immediately overwrites.
- **Fixed:** on a machine that already has a `.zshrc`, Oh My Zsh's installer
  (`KEEP_ZSHRC=yes`) leaves it untouched and never adds its own
  `source .../oh-my-zsh.sh` line — so the plugin patches above were silently
  becoming no-ops (found by actually dogfooding the script). Both scripts
  now detect this and bootstrap Oh My Zsh into the existing `.zshrc`
  themselves instead of assuming its stock template is present.
- **Fixed:** Superfile's `spf path-list` no longer initializes the config
  file as of v1.6.0 (it just prints paths now) — `spf --fix-config-file` is
  the current way to generate `config.toml`/`hotkeys.toml` non-interactively.
  Also switched the patched `theme = "dracula"` line to double quotes to
  match Superfile's own generated format.
- Added this Walkthrough section and this Changelog.
- Replaced the placeholder screenshots under `docs/screenshots/` with real
  captures: `scripts/setup-ubuntu.sh` was actually run end-to-end in a clean
  container, then the resulting shell, `lsd -la`, and `spf` were recorded
  with [VHS](https://github.com/charmbracelet/vhs) using each tool's real
  Dracula theme/colors (Superfile's bundled `dracula.toml`, the official
  [dracula/lsd](https://github.com/dracula/lsd) `colors.yaml`).
- **Fixed:** `setup-windows.ps1`'s PowerShell-profile step silently did
  nothing on a genuinely fresh machine. `Get-Content -Raw` on a brand-new
  `$PROFILE` returns `$null`, and `$null -notmatch <pattern>` evaluates to
  an empty (falsy) array rather than `$true` — so the script always hit the
  "profile already configured, skipping" branch and never actually wrote
  the Oh My Posh/lsd config, while still reporting success. Found and fixed
  by actually running the script end-to-end under PowerShell Core, with
  `winget` mocked to wire up real oh-my-posh/lsd/superfile binaries so the
  rest of the script's logic — theme download, config patch, profile
  patch, and idempotency on a second run — executed for real. (`winget`
  itself and Windows font installation can't be exercised outside real
  Windows, so those two steps are still unverified beyond a syntax check.)
- **Fixed (critical):** `setup-termux.sh`'s Superfile install was completely
  broken, 100% reproducible. The release tarball nests the binary under
  `dist/superfile-linux-v<tag>-<arch>/spf`, but the script did `cp ./spf`,
  which never exists at that path — every real run of this step would fail.
  Since Superfile has no Termux package, this fallback is the *only* install
  path on Termux, so this had never actually worked.
- **Fixed:** the same script's oh-my-posh Android fallback mapped
  `aarch64` → `posh-android-arm64`, an asset that doesn't exist (verified
  against the actual release — oh-my-posh publishes exactly one Android
  build, `posh-android-arm`). Combined with `set -e`, a 404 here silently
  killed the rest of the script on **the most common real Android
  architecture**, with zero remaining steps run. Now hardcoded to the one
  asset that actually exists, with a graceful message instead of a bare
  `wget` failure if that ever changes again.
- **Fixed:** Superfile's latest-release lookup on Termux shells out to
  `api.github.com` unauthenticated with no error handling — a rate limit
  or network hiccup (realistic on a shared mobile/carrier IP) left `SPF_TAG`
  empty and, again via `set -e`, silently killed the rest of the script.
  Now checked explicitly with a clear fallback message.
- All of the above found by actually running `setup-termux.sh` end-to-end
  on a real (non-Termux) Linux box, with `pkg` mocked as a thin wrapper
  around `apt` (mirroring what `pkg` really is in Termux) so the rest of
  the script's logic — Oh My Zsh + plugins, font fetch, Dracula theme,
  Superfile install/theme-patch, `.zshrc` config, and idempotency across a
  second run — executed for real, including genuinely downloading and
  running the real Android `posh-android-arm` binary and Linux `spf`
  binary produced by the fixes above.
- **Fixed (both silent-death classes at once):** `setup-ubuntu.sh` piped
  the oh-my-posh and Superfile installers straight into `bash`
  (`curl ... | bash`, `bash -c "$(curl ...)"`) with no error handling.
  Reproduced live against `ohmyposh.dev`/`superfile.dev` (blocked by this
  environment's egress policy, which made for genuine failure-path
  testing): when the fetch fails outright, `bash` gets an empty script and
  exits 0 — under `set -e` that reads as success, so the step silently
  installed nothing with no indication anything went wrong. In another
  run, the proxy's rejection body got fed to `bash` as literal commands
  (`bash: line 1: Host: command not found`), which did trip `set -e` and
  silently killed the rest of the script instead. Both steps now download
  to a file, check it explicitly, then run it — either failure mode now
  produces a clear message and the script continues. Also fixed the same
  unguarded-`api.github.com` issue in the `lsd` fallback (same bug as the
  Termux fix above, same fix). Confirmed the actual vendor Superfile
  installer (fetched from its GitHub mirror, not the blocked domain) still
  installs correctly end-to-end when the fetch succeeds, using its
  `SPF_INSTALL_VERSION` override to bypass just the API-lookup call.
- **Final cross-platform re-verification pass**, run after all of the above
  fixes landed: all three scripts re-run fresh end-to-end (isolated
  `$HOME`/`$PREFIX`/`$env:APPDATA` and mocked package managers/`winget`, as
  described above) and again for idempotency, confirming every earlier fix
  still holds together as a whole and nothing regressed. Turned up one
  small leftover: a dead `alias spf='spf'` (aliasing a command to itself)
  in `setup-ubuntu.sh`'s `.zshrc` block — removed.
- **Added bat, fzf, zoxide, and tmux** (Linux/Termux only for tmux — no
  native Windows port) to all three scripts, each idempotent and
  Dracula-themed: bat via its own built-in "Dracula" theme, fzf via the
  official `dracula/fzf` `FZF_DEFAULT_OPTS` colors and wired into zsh
  through Oh My Zsh's bundled `fzf` plugin (rather than hand-rolling
  per-distro shell-integration path detection — it already knows the
  Debian/apt doc-examples path, Termux's `$PREFIX` path, and the modern
  `fzf --zsh` flag), zoxide via `zoxide init`, and tmux via the official
  `dracula/tmux` plugin cloned directly (no plugin-manager step needed).
  Verified fresh-install and idempotent-rerun for all three platforms,
  including a genuine `apt remove` of all four tools beforehand so the
  install branches actually ran rather than short-circuiting on
  already-present binaries; confirmed the real Dracula colors in `tmux`'s
  status bar (`show-options -g status-style`) and bat's `--list-themes`
  output. One real, environment-specific gap found along the way: a
  minimized/`nodoc`-stripped Ubuntu (common in slim Docker base images,
  not a real Desktop/Pi install — this repo's actual target) is missing
  `/usr/share/doc/fzf/examples/*.zsh`, which the Oh My Zsh `fzf` plugin
  needs on Debian/Ubuntu; harmless (the rest of the shell still loads
  fine) but worth knowing if this is ever run inside a slim container.
- **Added an interactive Nerd Font + theme picker, and 9 themes beyond
  Dracula** (Catppuccin Mocha/Macchiato/Frappe/Latte, Gruvbox, Nord, Tokyo
  Night, Rose Pine, Everforest — 10 total) to all three scripts. Run from a
  real terminal, each script now opens with a numbered menu for font and
  theme before installing anything; piped/CI runs (`[ -t 0 ]` in bash,
  `[Console]::IsInputRedirected` in PowerShell) skip the prompt and keep the
  JetBrainsMono + Dracula defaults. Rerunning with a different choice
  replaces the previously-installed theme's config instead of layering on
  top of it — `.zshrc`, `.tmux.conf`, and the PowerShell `$PROFILE` all
  strip their old managed block before appending the new one.
  - Only 6 of the 10 themes have an official upstream oh-my-posh theme
    (Dracula + the 4 Catppuccin flavors + Gruvbox); the other 4 (Nord, Tokyo
    Night, Rose Pine, Everforest) are produced by recoloring the proven
    `dracula.omp.json` template in place (two-pass placeholder swap, so a
    target color can never collide with a source color still waiting to be
    replaced) — same schema, guaranteed to render, just repainted.
  - **Found and fixed a real lsd bug along the way:** Debian/Ubuntu's
    apt-packaged lsd (1.0.0) only honors *numeric* xterm-256 color indices
    in `colors.yaml` — it silently ignores hex color strings, even though
    both `dracula/lsd` and `catppuccin/lsd` publish their official
    `colors.yaml` in hex. Confirmed by A/B testing: the official numeric
    Dracula file rendered correctly, the official hex Catppuccin file
    rendered identically to *no file at all* (proving it was dropped, not
    partially applied). lsd's own theming had actually never been wired up
    by this repo before this pass — no `config.yaml`/`colors.yaml`
    generation existed at all, despite the walkthrough screenshot above
    showing themed `lsd` output (that screenshot's config was hand-created
    outside the script). Fixed by generating both files for real, with
    numeric xterm-256 values (precomputed as the nearest match to each
    theme's real hex colors) for every theme except Dracula, which keeps
    using the official numeric upstream file.
  - Verified end-to-end on all three platforms: default Dracula fresh
    install, an interactive-picker-driven switch to Catppuccin Mocha
    (exercising the official-asset-fetch path and the lsd numeric fix), an
    interactive-picker-driven switch to a fully-recolored theme (Nord on
    Ubuntu/Termux, Nord and Tokyo Night on Windows), idempotency on a
    same-theme rerun (config regenerated but unchanged in substance, no
    duplicated marker blocks), and — on Windows — that pre-existing
    unrelated `$PROFILE` content survives a theme switch untouched.
  - Testing `setup-windows.ps1`'s interactive picker outside real Windows
    needed one non-obvious PTY fix: PSReadLine blocks `Read-Host` on a
    cursor-position query (`ESC[6n`) it sends on startup, which a plain
    pseudo-tty never answers — looks exactly like a hang with no error.
    The test driver now answers it (`ESC[1;1R`); this is a test-harness
    requirement, not a script issue — a real terminal answers it itself.
- **Replaced the 4 Catppuccin flavors with a single `catppuccin` theme,
  10 themes → 7.** Found the reason the walkthrough's Catppuccin prompt
  never actually looked like the other themes' powerline color-bar style:
  oh-my-posh's official per-flavor files (`catppuccin_mocha`/`_macchiato`/
  `_frappe`/`_latte.omp.json`) all set `"style": "plain"` on every segment
  — flat text, no color blocks, unlike Dracula's and Gruvbox's official
  themes or this repo's own recolored Nord/Tokyo Night/Rose Pine/Everforest
  templates. `catppuccin.omp.json` (the single "core" theme upstream,
  contributed by IrwinJuice) is the one file that actually uses
  `powerline`/`diamond` segments with real background colors — it
  hardcodes the Macchiato palette, so bat/lsd/superfile/tmux for the
  `catppuccin` choice now all match Macchiato too, for one consistent
  look instead of 4 flavors where only 1 in 4 (Latte's numeric lsd colors
  aside) actually rendered the intended style. Verified end-to-end on all
  three platforms: the picker now lists 7 themes, selecting `catppuccin`
  fetches the real color-bar `.omp.json` and matching Macchiato bat/lsd/
  superfile/tmux config, and idempotency still holds (no duplicated
  marker blocks on a same-theme rerun).
