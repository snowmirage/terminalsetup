# Terminal Setup

Cross-platform terminal configuration for **macOS**, **Windows 11**, and **WSL/Linux**.

GPU-accelerated terminal (WezTerm) with tmux-style multiplexing, a color-coded prompt (Starship), syntax highlighting, autosuggestions, and semantic command blocks.

---

## What's Included

| File | Deploys To | Description |
|------|-----------|-------------|
| `wezterm.lua` | `~/.config/wezterm/wezterm.lua` | Terminal emulator config — GPU rendering, keybindings, pane/tab multiplexing, auto light/dark theme |
| `starship.toml` | `~/.config/starship.toml` | Prompt config — directory, git status, Python venv, AWS profile, command duration |
| `zshrc` | `~/.zshrc` | Zsh shell config — colors, history, completion, SSH agent, WezTerm integration (macOS/Linux/WSL) |
| `powershell_profile.ps1` | `$PROFILE` | PowerShell config — Starship init, PSReadLine autocomplete (Windows only) |
| `deploy.sh` | — | Deployment script for macOS, Linux, and WSL |
| `deploy.ps1` | — | Deployment script for Windows 11 |
| `setup-guide.md` | — | Full documentation, keybinding reference, customization guide |
| `wezterm-cheatsheet.md` | — | Quick-reference card for WezTerm keybindings |

---

## Quick Start

### macOS

```bash
git clone https://github.com/snowmirage/terminalsetup.git
cd terminalsetup
bash deploy.sh
```

The script will:
1. Check for and offer to install prerequisites (Homebrew, WezTerm, Starship, zsh plugins, Nerd Font)
2. Back up any existing config files to `~/.config-backups/terminalsetup/<timestamp>/`
3. Alert you to any custom lines in your existing configs that aren't part of this project
4. Deploy all three config files (`.zshrc`, `starship.toml`, `wezterm.lua`)

Restart WezTerm after deployment.

### Windows 11

```powershell
git clone https://github.com/snowmirage/terminalsetup.git
cd terminalsetup
.\deploy.ps1
```

The script will:
1. Check for and offer to install prerequisites (PowerShell 7, WezTerm, Starship, Git, Nerd Font)
2. Back up any existing config files to `$HOME\.config-backups\terminalsetup\<timestamp>\`
3. Alert you to any custom lines in your existing configs that aren't part of this project
4. Deploy `wezterm.lua`, `starship.toml`, and the PowerShell profile

Restart WezTerm after deployment.

### WSL (Ubuntu)

WezTerm runs on the Windows side — run `deploy.ps1` on Windows first to deploy `wezterm.lua` and `starship.toml` there.

Inside your WSL session, run `deploy.sh` to set up zsh and Starship:

```bash
git clone https://github.com/snowmirage/terminalsetup.git
cd terminalsetup
bash deploy.sh
```

This deploys `.zshrc` and `starship.toml` inside WSL. It skips `wezterm.lua` since WezTerm runs natively on Windows.

---

## Updating

After pulling changes from this repo, re-run the deploy script for your platform. It will back up your current configs and replace them with the latest versions.

```bash
cd terminalsetup && git pull && bash deploy.sh    # macOS / WSL
```

```powershell
cd terminalsetup; git pull; .\deploy.ps1          # Windows
```

---

## Key Features

- **WezTerm** — GPU-accelerated terminal with 100k-line scrollback, tmux-style pane splitting (Leader: `Ctrl+\`), workspaces, Quick Select for IPs/ARNs/hashes, and auto light/dark theme switching
- **Starship** — Fast cross-platform prompt showing git branch/status, Python venv, AWS profile, Docker context, command duration, and more
- **Zsh** (macOS/Linux/WSL) — 50k-line shared history, case-insensitive completion, syntax highlighting, autosuggestions, OSC 133 semantic zones (triple-click selects command output)
- **PowerShell** (Windows) — Starship prompt with PSReadLine history-based autocomplete

See `setup-guide.md` for the full configuration reference, keybindings, workflow tips, and customization options.

See `wezterm-cheatsheet.md` for a printable keybinding quick-reference.

---

## Known Issues

### macOS Dictation (Voice-to-Text) Does Not Work in WezTerm

macOS built-in Dictation does not activate in WezTerm regardless of which shortcut is configured (Fn key, Ctrl+H, etc.). This is a [known WezTerm bug](https://github.com/wezterm/wezterm/issues/5180), not a configuration issue.

**Root cause:** macOS Dictation requires apps to implement the `NSTextInputClient` protocol and return a valid cursor position from `selectedRange()`. WezTerm returns `NSRange(NSNotFound, 0)`, which tells macOS there is no valid insertion point, so Dictation refuses to activate. The fix is a one-line change to return `NSRange(0, 0)` instead. This same bug previously affected Emacs, Kitty, and Ghostty — all have since fixed it.

**Fix status:** [PR #7453](https://github.com/wezterm/wezterm/pull/7453) has the fix but has not been merged yet (as of February 2026).

**Other terminals for comparison:**

| Terminal | Dictation Works? |
|---|---|
| Terminal.app | Yes |
| Ghostty | Yes (fixed) |
| Kitty | Yes (fixed Jan 2026) |
| iTerm2 | No |
| Alacritty | No (wontfix) |
| WezTerm | No (fix pending) |

**Workarounds:**

- **Third-party dictation tools** that bypass the native macOS system and inject text via simulated keystrokes:
  - [Superwhisper](https://superwhisper.com/) — commercial, uses Whisper AI
  - [OpenWhispr](https://github.com/OpenWhispr/openwhispr) — open source, recognizes 20+ terminals including WezTerm
  - [stt](https://github.com/bokan/stt) — hold a key, speak, release, works system-wide
- **Build WezTerm from source** with [PR #7453](https://github.com/wezterm/wezterm/pull/7453) applied
- **Use Ghostty or Kitty** for dictation-heavy workflows — both have this fixed
