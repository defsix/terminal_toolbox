# terminal-setup

One-stop shell provisioning scripts: zsh + Oh My Zsh, a Nerd Font, Oh My Posh,
lsd, bat, fzf, zoxide, tmux, and Superfile. Run interactively, each script
opens with a picker for one of 10 Nerd Fonts and one of 7 themes (Dracula,
Catppuccin, JanDeDobbeleer, Paradox, Aliens, Montys, Unicorn — all genuine
premade oh-my-posh prompts, not palette knockoffs) before anything installs;
non-interactive/CI runs keep the Dracula + JetBrainsMono defaults (tmux is
Linux/Termux only — no native Windows port).

## Platforms

| Script                | Target                                    |
|-----------------------|--------------------------------------------|
| `scripts/setup-ubuntu.sh`  | Ubuntu / Debian / Raspberry Pi OS (apt-based) |
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
  read. All 7 themes and 10 fonts are plain arrays up top
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
- Oh My Posh theme: every one of the 7 themes is a genuine premade upstream
  `.omp.json` fetched as-is (Dracula, Catppuccin, JanDeDobbeleer, Paradox,
  Aliens, Montys, Unicorn) — none are recolored from a template. Earlier
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
  instead of left in place.
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
