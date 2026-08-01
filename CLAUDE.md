# terminal-setup

One-stop shell provisioning scripts: zsh + Oh My Zsh, a Nerd Font, Oh My Posh,
lsd, bat, fzf, zoxide, tmux, Superfile, and a system-info fetch tool
(nerdfetch on Linux/Termux, fastfetch on Windows — nerdfetch itself has no
Windows support at all). Run interactively, each script opens with a
picker for one of 10 Nerd Fonts and one of 8 themes (Dracula, M365Princess,
Atomic, Catppuccin, Catppuccin Mocha, JanDeDobbeleer, Marcduiker, Neko —
all genuine premade oh-my-posh prompts fetched unmodified from upstream)
before anything installs; non-interactive/CI runs keep the Dracula +
JetBrainsMono defaults (tmux and nerdfetch are Linux/Termux only — no
native Windows port).

## Platforms

| Script                | Target                                    |
|-----------------------|--------------------------------------------|
| `scripts/setup-ubuntu.sh`  | Ubuntu / Debian / Raspberry Pi OS (apt-based) |
| `scripts/setup-cachyos.sh` | CachyOS, Arch Linux-based (pacman-based)      |
| `scripts/setup-termux.sh`  | Termux on Android (pkg-based, no sudo)        |
| `scripts/setup-windows.ps1`| Windows PowerShell (winget-based)             |

Windows has no native zsh — that script configures the PowerShell profile
with the same tools/theme instead, and suggests WSL + `setup-ubuntu.sh` for
anyone who wants real zsh on Windows.

## Conventions

- Each script is idempotent — safe to re-run, skips anything already installed.
- Package manager first, GitHub release binary as fallback, matched to
  architecture (`dpkg --print-architecture` on Debian/Pi, `uname -m` on Termux).
- Theme/font picker: a `choose_from_list` helper (bash) / `Choose-FromList`
  function (PowerShell) prints a numbered menu and reads one line from
  stdin, falling back to the default on empty/invalid input. It only runs
  when actually interactive — `[ -t 0 ]` in bash, `[Environment]::UserInteractive
  -and -not ([Console]::IsInputRedirected)` in PowerShell — so piped/CI runs
  silently keep the Dracula + JetBrainsMono defaults instead of hanging on a
  read. All 8 themes and 10 fonts are plain arrays up top
  (`THEME_CHOICES`/`FONT_CHOICES` in bash, `$ThemeChoices`/`$FontChoices` in
  PowerShell) so adding one is a one-line change plus a new `case`/`switch` arm.
- Theme data table: each theme is one `case "$THEME" in ... esac` arm (bash)
  or `switch ($Theme) { ... }` block (PowerShell) setting the same fields —
  an official asset URL when upstream publishes one for that tool/theme
  combo (`OMP_THEME_URL`, `LSD_COLORS_URL`, `BAT_THEME_URL`), plus role
  colors (`C_BG`/`C_FG`/`C_PURPLE`/etc., hex) used everywhere no official
  asset exists. Switching the installed theme is "edit `$THEME`, rerun the
  script" — every managed config block is regenerated from scratch each run
  (see the strip-and-reappend note below), not hand-edited in place.
- Oh My Posh theme: every one of the 8 themes is a genuine premade upstream
  `.omp.json` fetched as-is (Dracula, M365Princess, Atomic, Catppuccin,
  Catppuccin Mocha, JanDeDobbeleer, Marcduiker, Neko) — none are recolored
  from a template, no exceptions (see the theme-roster bullet further down
  for the current exact list and how each one's role colors were sourced).
  Earlier
  versions of this repo recolored Dracula's template with Nord/Tokyo
  Night/Rose Pine/Everforest's real ecosystem palettes, which technically
  matched those palettes but looked muddy and too similar to each other:
  those 4 palettes are all, by deliberate design philosophy, muted/pastel
  (that's their whole aesthetic identity), so no role-color reassignment
  within the recolor mechanism could make them pop the way a genuinely
  vibrant premade prompt does — and oh-my-posh has no official Nord/Rose
  Pine/Everforest theme upstream anyway (confirmed by cloning the full
  themes directory: 122 files, none of those three exist, and the closest
  Tokyo Night-ish ones use flat `"style": "plain"`, not color-bar segments).
  Swapped those 4 for real vibrant premade themes instead — bat/lsd/tmux/
  Superfile colors are then derived from that same prompt's own segment
  colors (see below), so the whole terminal matches, it just isn't a
  "real Nord" anymore. The result is saved per-theme as
  `~/.poshthemes/<theme>.omp.json` (or `$HOME\.poshthemes\<theme>.omp.json`
  on Windows) and referenced by local path in the shell init line — remote
  `--config` URLs work but re-fetch on every new shell, which is slower.
- Catppuccin is a single theme, not 4 flavors: upstream oh-my-posh publishes
  per-flavor files (`catppuccin_mocha`/`_macchiato`/`_frappe`/`_latte
  .omp.json`), but every one of them sets `"style": "plain"` on every
  segment — no powerline/diamond blocks, no background colors, just flat
  text. `catppuccin.omp.json` (the single "core" theme, contributed by
  IrwinJuice) is the one upstream file that actually uses
  `"style": "powerline"`/`"diamond"` with real segment backgrounds; it
  hardcodes Catppuccin Macchiato's palette. The script uses that one file
  for the `catppuccin` theme choice, and matches bat/superfile/lsd/tmux to
  Macchiato too so every tool agrees on the same flavor.
- The theme-3 slot was originally `jandedobbeleer.omp.json` but got swapped
  to `atomic.omp.json`: someone had reference screenshots of a prompt they
  liked (pill/capsule segments — shell-name capsule, folder+home-icon path
  capsule, execution-time capsule on the left; OS-icon + clock capsules on
  the right, with a gap instead of a touching powerline chevron between the
  two blocks) that didn't match what upstream `jandedobbeleer.omp.json`
  currently ships at all — its real released form is a diamond
  session/path/git/language-version layout, nothing like that pill style.
  Don't trust a theme's JSON structure alone to judge what it visually
  renders as (icon glyphs, `style: folder` path options that print icons
  instead of text, diamond-vs-powerline framing, etc. are easy to misread
  from the raw file). Confirmed the actual match by rendering candidates
  for real: `oh-my-posh print primary --config <file>.omp.json --shell zsh`
  piped into a `ttyd`-served zsh session (`ttyd -p 7681 -W -t
  'fontFamily=<nerd font>' zsh --login`, needs the client-option flag or
  the web client won't have Nerd Font glyphs), screenshotted with
  Playwright (`/opt/pw-browsers/chromium-*/chrome-linux/chrome`, `--no-sandbox`
  in this sandboxed environment) — `atomic.omp.json` matched pixel-for-pixel,
  including the `folder_icon`/`home_icon` path style (prints icons only, no
  path text at all, when at `$HOME`) and the exact segment background
  colors. Note `api.github.com` and `codeload.github.com` are blocked by
  this environment's proxy for repos outside the session's scope (can't
  list a directory or fetch a tarball for a repo like
  `JanDeDobbeleer/oh-my-posh` that isn't the working repo) but plain
  `raw.githubusercontent.com` file fetches for known theme filenames still
  work fine — that's how every theme file in this repo is actually fetched
  anyway.
- **Current theme roster (8, explicitly specified by the repo owner, not
  picked by Claude):** Dracula, M365Princess, Atomic, Catppuccin, Catppuccin
  Mocha, JanDeDobbeleer, Marcduiker, Neko — replacing Paradox/Aliens/Montys/
  Unicorn entirely (dropped, not kept alongside). Every `OMP_THEME_URL`
  points at the theme's real, current `.omp.json` on
  `JanDeDobbeleer/oh-my-posh` main, fetched unmodified — including
  Catppuccin Mocha (a genuine per-flavor file, flat `"style": "plain"`, no
  pill segments — see the Catppuccin bullet above; this isn't a bug to
  "fix" the way the general Catppuccin pick already was) and Neko (an
  emoji/plain-text novelty theme with no powerline/diamond segments at
  all). Where a theme declares colors through a named `palette` block
  (`p:name` references resolved elsewhere in the JSON) instead of inline
  hex — M365Princess, Catppuccin, Catppuccin Mocha — the real hex values
  were read from that file's own palette table, plus (for both Catppuccin
  flavors) the rest of the well-known official Catppuccin palette for
  roles the file's own small palette object doesn't cover. Every other
  `C_*`/`L_*` role color was cross-checked against the theme's actual
  fetched JSON — not just `background`/`foreground` fields but inline hex
  embedded in `template`/`background_templates`/`leading_diamond` strings
  too (e.g. Neko's `<#5FAAE8>` git-bracket color, easy to miss with a naive
  field-only scan) — and only invented where a role has no real equivalent
  in that specific theme at all (an overall background/foreground, for
  prompt-only themes that don't define one; a hue like purple or green
  that a small/minimalist palette like Marcduiker's or Neko's simply
  doesn't have — invented ones were picked to harmonize with the theme's
  actual family, e.g. Marcduiker's invented green matches real Sweetie-16-
  style retro-palette greens even though it's not literally in that file).
  `BAT_THEME_NAME` picks were verified against a real `bat --list-themes`
  output, not assumed: `1337`, `Visual Studio Dark+`, `Sublime Snazzy`,
  `gruvbox-dark`, `Nord` are all real built-in names. Catppuccin Mocha
  gets the same official-asset treatment as Macchiato — a real
  `catppuccin/bat` `Catppuccin Mocha.tmTheme` fetch, not a built-in
  approximation. Screenshots for all 8 were regenerated the same way as
  the Atomic swap (ttyd + Playwright), rendering the shell's very first
  prompt line (no command run, no Enter pressed) rather than pressing
  Enter first — pressing Enter re-renders the whole prompt a second time
  immediately below the first with no blank row between them for several
  of these themes, so a naive "first contiguous content block" crop
  grabbed both lines as one. Fixed by cropping a fixed one-line-height
  window (23px at the fontSize/font used here) from the first content row
  instead, verified against each theme's actual per-row pixel density
  (a real second line still has some content — the input cursor block —
  just much lower density, not zero, so a pure blank-row gap check alone
  doesn't reliably separate the two lines either).
- lsd theme: **numeric xterm-256 color indices only** — Debian/Ubuntu's
  apt-packaged lsd (1.0.0) silently ignores hex color strings in
  `colors.yaml` even though upstream `dracula/lsd` and `catppuccin/lsd`
  both publish hex-format files (confirmed by A/B testing: the official
  numeric Dracula file renders correctly, the official hex Catppuccin file
  renders identically to no file at all — proving it's silently dropped,
  not partially applied). Dracula still uses the official
  `dracula/lsd` `colors.yaml` fetch since it happens to already be numeric;
  every other theme's `L_*` values (a parallel numeric xterm-256 palette,
  precomputed as the nearest match to that theme's real hex colors via the
  6x6x6-cube-plus-grayscale-ramp distance formula) are written directly into
  a generated `colors.yaml`, not fetched. If a future lsd release adds hex
  support, this generation step can go — but don't assume it already has.
- Superfile `config.toml`: **never shell out to `spf --fix-config-file`
  from these scripts.** It looks like the natural way to generate a default
  config, and it does write one as a side effect — but it opens the real
  controlling terminal directly (like `/dev/tty` on Linux, `CONIN$`/
  `CONOUT$` on Windows) rather than respecting redirected stdin/stdout, so
  on an actual interactive terminal (i.e. every real run of this script,
  confirmed live on real Windows and reproduced locally with a proper PTY
  test that separates session-leader from script-process) it launches the
  full TUI and hangs waiting for the user to quit it, instead of writing
  the config and exiting. A prior version of this script assumed the
  observed "writes file then exits non-zero" behavior was universal — it
  only held in non-interactive test harnesses that genuinely have no tty
  at all, not in the primary real-world case of a user running the script
  in their own terminal. Fixed by never invoking it: if `config.toml`
  doesn't exist, write a minimal one ourselves with just the `theme = "..."`
  line — Superfile fills in every field it doesn't find with a built-in
  default (that's literally what `--fix-config-file` documents itself as
  doing: "adds any *missing* fields"), so this is sufficient and has no
  console/tty risk at all.
- Superfile also supports fully custom theme files, not just its
  bundled names (https://superfile.dev/configure/custom-theme/ — confirmed
  by dropping a hand-edited `.toml` into `~/.config/superfile/theme/` under
  a name Superfile never shipped, and it loaded without error), so the
  script writes `~/.config/superfile/theme/<theme>.toml` directly from this
  theme's own `C_*` role colors (same field set as the official
  `dracula.toml`: `full_screen_*`, `file_panel_*`, `footer_*`, `sidebar_*`,
  `modal_*`, `help_menu_*`, `cursor`/`correct`/`error`/`hint`/`cancel`)
  instead of mapping to the closest bundled name — every theme gets an
  exact-match file this way, not an approximation. The `theme = "..."` line
  in `config.toml` is then patched to `$THEME` via `sed` (or PowerShell
  equivalent). Note: `spf path-list` looked like it also triggered config
  init on older Superfile releases, but as of v1.6.0 it only prints paths
  and creates nothing — don't revert to it.
- Switchable-but-idempotent config blocks: `.zshrc`/`.tmux.conf`/the
  PowerShell `$PROFILE` all use a strip-then-reappend pattern — if the
  `# >>> custom terminal setup >>>` / `# <<< ... <<<` marker pair is
  present, delete that whole range first (`sed` range-delete in bash,
  `[regex]::Replace` with a non-greedy `[\s\S]*?` span in PowerShell), then
  always append a fresh block. This is what makes "rerun with a different
  theme" replace the old config instead of duplicating it, while a
  same-theme rerun is still a no-op in substance (old block out, identical
  new block in). lsd's `colors.yaml` uses a first-line `# <theme-name>`
  comment as its marker instead, since it's one file with no per-theme name
  to hang a managed-block pair on; oh-my-posh's per-theme-named
  `<theme>.omp.json` files and Superfile's existing `sed -i
  's/^theme = .../'` line-replace already avoid the problem entirely.
- Oh My Zsh: `zsh-autosuggestions` and `zsh-syntax-highlighting` are cloned
  into `$ZSH_CUSTOM/plugins/` and appended to the `plugins=(...)` line via
  `sed`, guarded so it only patches the stock `plugins=(git)` line once.
  `ZSH_THEME` is blanked out on install since Oh My Posh draws the prompt —
  leaving Oh My Zsh's own theme on just means it renders once and gets
  overwritten by the `eval "$(oh-my-posh init zsh ...)"` line appended later
  in `.zshrc`.
- ES5-equivalent shell style: plain POSIX/bash, no bashisms that would break
  under Termux's `bash`, no external dependencies beyond curl/wget/git/unzip.
- PowerShell profile patch: never compare `Get-Content -Raw` output to a
  pattern with bare `-notmatch`/`-match` — on a brand-new/empty file it
  returns `$null`, and `$null -notmatch <pattern>` comes back as an empty
  array (falsy in an `if`), not `$true`. Always guard with
  `[string]::IsNullOrEmpty($content) -or ...` first, or a fresh `$PROFILE`
  silently skips getting configured while the script reports success.
- oh-my-posh's Android fallback binary comes in exactly one build,
  `posh-android-arm` — there is no `posh-android-arm64` or `-amd64` asset
  (confirmed against actual release assets, not assumed). Don't arch-map
  this one the way the Linux/Windows targets are mapped; hardcode `arm`.
- `command -v oh-my-posh` only proves a file exists on PATH, not that it
  actually runs. A binary can be present but non-functional — a bad `pkg`
  mirror, an interrupted GitHub fetch, or (very commonly on Termux)
  restoring `$PREFIX` from a backup taken on a *different* Termux
  install/build (Play Store vs. F-Droid vs. GitHub — different signing
  keys, not guaranteed binary-compatible) can all leave a file that Android's
  linker refuses to run (`... has unexpected e_type: 2` — a non-PIE ELF,
  which modern Android rejects outright). Found via a real device hitting
  exactly this after a backup restore. Trusting presence alone means the
  broken binary gets silently accepted once and then "already installed,
  skipping" forever after, with no way to recover short of the user
  deleting it by hand. Fixed by verifying `oh-my-posh --version` actually
  succeeds before treating it as installed; if not, remove the broken file
  first (an untracked file at that path can make `pkg install` itself fail
  trying to overwrite it), reinstall, and fall through to the GitHub
  binary if the package is still broken or unavailable — verified again
  after the fetch, so a fetched-but-non-functional binary gets cleaned up
  instead of left in place. That `rm -f` step introduced its own follow-on
  bug: if the file being removed *was* dpkg-tracked, dpkg's database still
  records the package as installed at its current version after the file
  is gone, and a plain `pkg install -y` is a version-compare no-op —
  apt sees "already the newest version" and redeploys nothing, so the
  reinstall silently does not happen and the missing binary persists on
  every subsequent run. Confirmed live: `command -v oh-my-posh` returned
  exit 1 while the script's own `pkg install -y oh-my-posh` output read
  "oh-my-posh is already the newest version (30.0.0)" / "0 upgraded, 0
  newly installed". Fixed with `pkg install --reinstall -y oh-my-posh`,
  which forces apt/dpkg to redeploy the package's files regardless of the
  version already recorded as installed. Reproduced and verified with a
  PTY-driven test using a mock `pkg` that models real dpkg bookkeeping
  (plain `install` on an "installed" package no-ops without touching
  files; `--reinstall` redeploys) — confirmed the old code left the binary
  missing while the fixed code redeployed and passed `oh-my-posh --version`.
- Superfile's release tarball nests the binary under
  `dist/superfile-linux-v<tag>-<arch>/spf`, not at the top level — `cp` the
  full nested path, not `./spf`.
- Any script step that shells out to `api.github.com` unauthenticated (e.g.
  Superfile's latest-tag lookup on Termux) must treat a failure as
  recoverable, not fatal: it's rate-limited per IP, real on a shared
  mobile/carrier connection, and a bare `set -e` script dies silently with
  zero remaining steps run if the failure isn't checked explicitly.
- Never pipe a vendor installer straight into `bash` (`curl ... | bash`, or
  `bash -c "$(curl ...)"`) without checking the fetch on its own first. If
  the fetch fails outright, `bash` gets an empty script and exits 0 — under
  `set -e` that reads as success, so the step silently installs nothing
  with zero indication anything went wrong. Worse, if whatever's in the
  middle (a proxy, a captive portal) returns an error body over the
  connection instead of failing cleanly, that body can get executed as
  shell commands. Download to a file with `curl -fsSL ... -o file`, check
  `[ -s file ]`, then run it — that way a failure is always visible and
  never silently masked either way.
- bat: Debian/Ubuntu ships the binary as `batcat` (name conflict with an
  older `bacula-console` package), so scripts check for both `bat` and
  `batcat` and alias `bat='batcat'` in `.zshrc` when only the latter exists.
  Dracula is one of bat's *built-in* themes — no external theme file to
  fetch, just `export BAT_THEME="Dracula"`.
- fzf: don't hand-roll per-distro shell-integration detection (Debian/apt's
  doc-examples path vs. Termux's `$PREFIX` path vs. the newer `fzf --zsh`
  flag — Ubuntu 24.04's apt-packaged fzf (0.44.1) predates that flag
  entirely). Add `fzf` to the Oh My Zsh `plugins=(...)` line instead —
  its bundled `fzf` plugin already covers all of the above. Dracula colors
  still need setting manually: `FZF_DEFAULT_OPTS` per the official
  `dracula/fzf` install docs.
- tmux: dracula/tmux is installed by git-cloning the theme repo directly to
  `~/.tmux/plugins/dracula` and adding a single `run-shell
  <absolute-path>/dracula.tmux` line to `.tmux.conf` — no TPM (tmux plugin
  manager) needed, which would require an interactive `prefix + I` step
  this repo can't script non-interactively anyway.
- zoxide: `zoxide init zsh` / `zoxide init powershell`, both first-party
  and stable — no version-compatibility concerns like fzf's `--zsh` flag.
- nerdfetch (Linux/Termux only — its own project explicitly excludes
  Windows entirely, even under Git Bash): no Debian/Ubuntu/Termux package
  exists at all, only Arch/Homebrew/Nix/Gentoo, so it's always a straight
  `curl` of the single POSIX shell script — no package-manager-first/
  binary-fallback split like the other tools, and no architecture matching
  since it's a shell script, not a compiled binary. Installed to
  `$HOME/.local/bin/nerdfetch` on Ubuntu (`$PREFIX/bin/nerdfetch` on
  Termux, already on PATH by default there) and invoked as the last line
  of the managed `.zshrc` block, guarded by
  `command -v nerdfetch &> /dev/null &&` so a failed fetch doesn't leave
  every new shell printing a "command not found" error. That managed
  block is regenerated in full every run, which already makes the
  invocation idempotent; a bare `nerdfetch` line left outside the block
  from an older run is additionally stripped by its own `sed` pass, so
  re-running never accumulates a second call to it however it got there.
- fastfetch on `setup-windows.ps1`: nerdfetch's own Windows exclusion means
  Windows needs a different tool entirely, not just a "use WSL" carve-out
  like tmux/zsh — fastfetch has a real winget package
  (`Fastfetch-cli.Fastfetch`, confirmed against the actual winget-pkgs
  manifest path rather than assumed), installed and invoked at the end of
  `$PROFILE` the same way nerdfetch is invoked at the end of `.zshrc`
  (`if (Get-Command fastfetch -ErrorAction SilentlyContinue) { fastfetch }`
  guard, same idempotency reasoning: the managed block is regenerated in
  full every run, plus a `[regex]::Replace` pass strips any bare
  `fastfetch` line left outside it).
- **All three scripts comment out (never delete) a pre-existing
  fastfetch/neofetch invocation** found in the shell config, so it doesn't
  print its own system-info banner alongside the new one on every prompt.
  This is deliberately different from how the script handles its own
  tool's stray lines (nerdfetch on Linux/Termux, fastfetch on Windows) —
  those get fully stripped and regenerated since they're just this
  script's own mechanism; a genuinely pre-existing *other* fetch tool from
  the user's own prior setup gets prefixed with `# ` instead, preserving
  it in case they want it back. The regex
  (`^([ \t]*)(fastfetch|neofetch)([ \t].*)?$` → `\1# \2\3` in bash,
  `(?m)^([ \t]*)neofetch([ \t].*)?$` → `` $1# neofetch$2 `` in PowerShell)
  matches only when the tool name is the first token on the line, so it
  correctly skips `alias fastfetch=...` and `command -v neofetch && ...`
  lines rather than mangling them, and is naturally idempotent — a line
  already commented no longer starts with the bare command name, so a
  rerun won't double-comment it. Verified end-to-end with a pre-seeded
  `neofetch`/`fastfetch` line in `.zshrc`/`$PROFILE` on all three scripts,
  confirming it gets commented (or, for the script's own tool, stripped)
  on the first run and stays that way — not re-commented, not
  duplicated — across reruns with a different theme.
- **Found and fixed a real bug while testing the nerdfetch addition**:
  every tool this repo installs to `$HOME/.local/bin` on Ubuntu
  (oh-my-posh, Superfile, nerdfetch) uses `command -v <tool>` to decide
  whether to skip a reinstall — but `setup-ubuntu.sh`'s own process never
  had `~/.local/bin` on `PATH`; only the *generated* `.zshrc` did. The
  check only ever succeeded by accident, inherited from whatever `PATH`
  the caller's own shell already had (which on a real interactive login
  shell usually already includes `~/.local/bin`, since Ubuntu's stock
  `.profile` adds it — masking the bug in the most common case). On a
  truly fresh account, or under the "curl the script into `bash <(...)`"
  one-liner this repo's own README recommends, every rerun would silently
  re-download instead of skipping. Fixed with `export PATH="$HOME/.local/bin:$PATH"`
  near the top of the script, for its own process. Reproduced by driving
  the PTY test harness with a minimal, non-inherited `PATH` (deliberately
  excluding `~/.local/bin` rather than letting it leak in from the host)
  and confirming via the installed file's mtime that a rerun no longer
  redownloads it, with "already installed, skipping" printing correctly.
- `setup-cachyos.sh` (Arch Linux-based, `pacman`): a real `-Syu`, never a
  bare `-Sy` — Arch explicitly does not support "partial upgrades", so
  syncing the package database without also upgrading everything already
  installed can leave shared libraries mismatched across packages and
  break the system. `--needed` skips already-up-to-date packages instead
  of reinstalling them; `--noconfirm` for the same non-interactive reason
  every other script avoids prompts. Same apt/pkg-style tolerance for one
  unreachable repo (`|| true` on the initial sync, since CachyOS adds its
  own repos alongside the standard Arch ones — more than one thing that
  can be briefly down). Nerd Fonts don't need Ubuntu/Termux's manual
  download-and-unzip dance at all: Arch's official `extra` repo packages
  every one of the 10 font choices directly as `ttf-<name>-nerd`
  (confirmed against the actual archlinux.org package pages one at a time,
  not assumed — the naming isn't perfectly mechanical, e.g.
  `ttf-ubuntu-mono-nerd`/`ttf-roboto-mono-nerd` are hyphenated but
  `ttf-sourcecodepro-nerd` isn't). oh-my-posh, Superfile, and nerdfetch all
  skip `pacman`/AUR entirely and reuse the exact same official cross-distro
  installers (or, for nerdfetch, the same direct `curl` fetch) the
  Ubuntu/Termux scripts already use — none of the three have an official
  Arch package (oh-my-posh and Superfile are AUR-only, with documented
  issues on some variants; nerdfetch does have a real AUR package, but
  it's just a single-file POSIX script with no build step, so fetching it
  directly is simpler than adding a `paru` dependency — CachyOS ships
  `paru` by default, but this repo otherwise never needs an AUR helper for
  anything, so it stays that way here too). `bat`'s binary is genuinely
  named `bat` on Arch (no Debian-style `batcat` rename), so the
  `batcat`-fallback alias dance from the other Linux scripts is dropped
  entirely rather than kept as unreachable dead code. `unzip` is dropped
  from the base package list too — nothing in this script actually needs
  it, unlike Ubuntu where it's required to extract the font archive.
  CachyOS defaults to `fish`, not `bash` or `zsh` — the script still
  installs and switches to zsh like every other platform here (this repo
  is fundamentally "zsh + Oh My Zsh", not "whatever the distro defaults
  to"), just with a one-line note in the shell-switch message explaining
  what it's actually switching *from*, since that's a real departure from
  what Ubuntu/Debian users would expect as their prior default. That same
  fish default broke the README's one-liner for this platform in
  practice: fish doesn't understand bash's `<(...)` process substitution
  at all and fails immediately with "Invalid redirection target" before
  `curl` ever runs — found via a real CachyOS run, reproduced locally by
  actually installing fish rather than assuming, and fixed by using
  fish's own equivalent, `psub` (`bash (curl -fsSL <url> | psub)`), as the
  primary form in the README for this platform. Tested
  with a PTY harness mocking `pacman` (and `sudo`, wrapped to just `exec`
  the command directly through the test's own isolated `PATH` rather than
  fighting sudo's `secure_path`, which would otherwise ignore the mock)
  across two font/theme combinations, confirming the exact expected
  `pacman` invocations (`-Syu` once, then per-tool `-S --needed` calls
  only for tools not already present) and full idempotency on rerun.
- **`setup-cachyos.sh`'s `pacman` calls needed retry logic, found via a
  real run that hit a genuinely concurrent update:** `pacman` fails
  immediately with "unable to lock database" if any other pacman/paru
  transaction is already running (a background updater, a software-center
  app, or occasionally a stale lock left behind by a killed process).
  Every install step except the very first (`base packages`, which
  already had a bare `|| true`) had no handling for this at all, so
  `set -e` killed the script partway through on the first lock contention
  it hit. Fixed with a `pacman_run` helper that retries a few times with a
  short, increasing wait (3s, 6s, 9s, 12s, 15s) before giving up — this
  class of contention is normally transient, so silently failing on the
  very first attempt wastes a setup run over what's often just a few
  seconds of waiting. After exhausting retries, it prints a message
  pointing at `/var/lib/pacman/db.lck` to check/remove if nothing else is
  actually running, rather than leaving the user with a bare pacman error.
  Verified with a mock `pacman` that fails a controlled number of times
  before succeeding (confirmed both the eventually-succeeds path and the
  gives-up-after-5-attempts path in isolation), plus a full script run
  where every install step hit one transient failure before succeeding.

## Testing notes

- PTY-driving `setup-windows.ps1`'s interactive picker (to verify it without
  real Windows) needs more than piping keystrokes to a pseudo-tty: PSReadLine
  sends a cursor-position query (`ESC[6n`, Device Status Report) on startup
  and blocks `Read-Host` until something answers it. A raw PTY harness that
  doesn't reply hangs forever, with no error — it looks exactly like the
  script itself is stuck. Fix on the test-harness side only: whenever the
  driver sees `\x1b[6n` in the child's output, write back a fake
  `\x1b[1;1R` (row 1, col 1) immediately. Once that's wired in, `Read-Host`
  unblocks and answers normally. This is a test-driver requirement, not a
  script bug — a real terminal emulator answers this query automatically.
- A plain non-interactive test (piped stdin, or the Bash tool's own shell,
  which has no tty at all — check with `tty` / `ps -o tty`) is not
  sufficient to validate anything that touches a subprocess capable of
  opening a real terminal itself (like `spf`/bubbletea — see the Superfile
  `config.toml` note above). Those subprocesses can behave completely
  differently once a real controlling terminal exists, even if *this
  script's own* stdin/stdout look redirected from the outside. To actually
  reproduce that class of bug, the test harness needs a PTY where the
  session-leader (simulating the user's real shell) is a **different**
  process from the one running the script under test (simulating `bash
  setup-ubuntu.sh` as an ordinary, non-session-leader child) — a single
  process calling `os.setsid()` on itself and then running the script
  in-process does not reproduce it, since nested `setsid`-based detachment
  attempts silently no-op when the caller is already a session/process-group
  leader.

## Known gaps / open questions

- Claude Code itself is not officially supported on Termux (bionic libc,
  not glibc) — worth checking before assuming this repo can be worked on
  from Termux directly. Desktop (CachyOS) or a proot-distro Ubuntu inside
  Termux are more reliable ways to run Claude Code on the phone.
- Superfile has no Termux package; `setup-termux.sh` pulls the
  `linux-arm64` release tarball directly, which works but isn't officially
  documented as Termux-compatible by upstream.
- oh-my-posh versions newer than a certain point have had issues running
  under Termux in the past (see `posh-android-*` binaries used as the
  fallback) — if it breaks, check the JanDeDobbeleer/oh-my-posh GitHub
  discussions for the current state.
- Termux itself ships through three channels that are not interchangeable:
  the Play Store build is officially deprecated by the Termux project
  (frozen on an old release, Play policies made it unmaintainable) and
  shouldn't be recommended to users; F-Droid re-signs APKs with its own
  key, which breaks compatibility with the official add-ons (Termux:API,
  Termux:Styling, etc.) and has historically lagged behind releases;
  GitHub releases (`termux/termux-app`) is what the project now points
  people to. All three share the package name `com.termux`, so switching
  channels needs an uninstall first — and per the point above, only
  restore `$HOME` afterward, never `$PREFIX`.
- On a minimized/`nodoc`-stripped Ubuntu (apt configured with
  `path-exclude=/usr/share/doc/*`, common in slim Docker base images but
  not a real Desktop/Pi install), Oh My Zsh's `fzf` plugin can't find
  `/usr/share/doc/fzf/examples/*.zsh` since those files get stripped at
  install time even though `dpkg -L fzf` still lists them. Harmless — the
  rest of `.zshrc` still loads fine, fzf's key bindings/completion just
  don't get wired up — but worth knowing if this is ever run inside a slim
  container rather than a real machine.

## Owner context

Part of defsix's tooling alongside the 076.io ecosystem. Primary dev
environment is Termux on Android; desktop is CachyOS. GitHub handle: defsix.
