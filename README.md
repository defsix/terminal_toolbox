# terminal-setup

One-stop scripts to provision a terminal with zsh (or PowerShell), a Nerd
Font, [Oh My Zsh](https://ohmyz.sh), [Oh My Posh](https://ohmyposh.dev),
[lsd](https://github.com/lsd-rs/lsd), and [Superfile](https://superfile.dev)
— themed in Dracula throughout.

> Screenshots below are real captures, not mockups: taken by actually running
> `scripts/setup-ubuntu.sh` end-to-end, then recording the resulting shell
> with [VHS](https://github.com/charmbracelet/vhs) — same Dracula
> `dracula.omp.json`/`dracula.toml` configs this repo installs, plus the
> official [dracula/lsd](https://github.com/dracula/lsd) `colors.yaml` for
> the `lsd` shot. What you see is what you get.

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

- zsh + **Oh My Zsh**, with the `zsh-autosuggestions` and
  `zsh-syntax-highlighting` plugins enabled alongside the default `git`
  plugin (PowerShell profile on Windows, since zsh isn't native there)
- A Nerd Font (JetBrainsMono by default — edit the variable at the top of
  each script to change it)
- Oh My Posh, Dracula theme, drawing the prompt (Oh My Zsh's own theme is
  disabled so the two don't fight over the prompt)
- lsd as a drop-in `ls` replacement (`ll`, `la`, `lt` aliases included)
- Superfile (`spf`), Dracula theme

## Walkthrough

1. **Run the script for your platform** (see [Usage](#usage)). Each step
   prints `=== n/6: ... ===` as it goes, and prints `already installed,
   skipping` for anything a previous run already handled.

2. **Prompt.** Once it's done, restart your shell (`exec zsh`, or log
   out/in). Oh My Posh draws the prompt — directory, git branch, shell,
   clock — in the Dracula theme, on top of Oh My Zsh's `zsh-autosuggestions`
   (ghost-text completions from history) and `zsh-syntax-highlighting`
   (a command turns green once it resolves to something real, red if it
   doesn't):

   ![Oh My Zsh + Oh My Posh, Dracula theme](docs/screenshots/oh-my-zsh-dracula.png)
   *Top to bottom: a valid command in green, a typo (`gti`) in red, and
   `atus` shown as a greyed-out autosuggestion after typing `git st`.*

3. **File listing.** `ls`/`ll`/`la`/`lt` now resolve to `lsd`, which adds
   icons and per-file-type coloring — shown here with the official
   [dracula/lsd](https://github.com/dracula/lsd) `colors.yaml`:

   ![lsd -la, Dracula colors](docs/screenshots/lsd-dracula.png)

4. **Superfile.** Launch the TUI file manager with `spf` — it opens with
   the `dracula` theme already set in its `config.toml`:

   ![Superfile, Dracula theme](docs/screenshots/superfile-dracula.png)

5. **Re-running is safe.** Every step is guarded by an existence check
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
