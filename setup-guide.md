# WezTerm Setup Guide

**Cross-Platform Terminal Configuration**
macOS • Windows 11 • WSL (Ubuntu) • Linux

Optimized for: SSH • WezTerm • Starship prompt

---

## Files in This Package

| File | Deploy To | Purpose |
|------|-----------|---------|
| `wezterm.lua` | `~/.config/wezterm/wezterm.lua` | Terminal config (cross-platform) |
| `zshrc` | `~/.zshrc` | Shell config (macOS, Linux, WSL) |
| `starship.toml` | `~/.config/starship.toml` | Prompt config (cross-platform) |
| `powershell_profile.ps1` | `$PROFILE` | PowerShell config (Windows only) |
| `wezterm-cheatsheet.md` | Wherever you like | Quick reference |
| `setup-guide.md` | This file | Full documentation |

---

## Table of Contents

1. Overview
2. macOS Setup
3. Windows 11 Setup
4. WSL (Ubuntu) Setup
5. Configuration Reference
6. Keybinding Reference
7. Workflow Tips
8. Syncing Configs Across Machines
9. Customization
10. Troubleshooting

---

## 1. Overview

### What You Get

- GPU-accelerated terminal with 100,000-line scrollback
- Tmux-style pane/tab multiplexer with Leader key (Cmd+Space on macOS / Ctrl+Space on Windows) — no need for tmux
- Color-coded prompt: directory, git status, Python venv, AWS profile, command duration
- Syntax highlighting as you type (valid = green, invalid = red)
- Gray autosuggestions from history (press → to accept)
- Triple-click selects a single command's output (like Warp's "blocks")
- Quick Select grabs AWS ARNs, instance IDs, IPs, git hashes, UUIDs
- Auto light/dark theme switching with system appearance
- Platform-adaptive keybindings (CMD on Mac ↔ ALT on Windows)
- SSH domain launcher for quick server connections

---

## 2. macOS Setup

**Time: ~5 minutes**

### Keyboard Remap Note

I've rebound the following keys on macOS so the physical keyboard matches Windows:

| Physical Key | macOS Signal |
|-------------|-------------|
| Ctrl | Cmd |
| Windows/Globe | Ctrl |
| Alt | Option |

This means copy/paste, the leader key, and all shortcuts are the same physical keys on both platforms. If you don't use this remap, everything still works — just use the standard Mac key positions.

### Prerequisites

- macOS Ventura or later
- Homebrew installed (https://brew.sh)
- Node.js 18+: `brew install node`

### Step 1: Install WezTerm

```bash
brew install --cask wezterm
```

### Step 2: Install Dependencies

```bash
brew install starship zsh-syntax-highlighting zsh-autosuggestions pngpaste
brew install --cask font-jetbrains-mono-nerd-font
```

### Step 3: Place Config Files

Back up existing configs first:

```bash
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d)
```

Create directories and copy:

```bash
mkdir -p ~/.config/wezterm
cp wezterm.lua   ~/.config/wezterm/wezterm.lua
cp starship.toml ~/.config/starship.toml
cp zshrc         ~/.zshrc
```

### Step 4: Activate

1. Quit WezTerm completely (Cmd+Q)
2. Reopen WezTerm — config auto-loads on startup
3. You should immediately see the Tokyo Night theme, Starship prompt, and syntax highlighting

### Step 5: Verify

```bash
ls -la                    # Colored output
cd /tmp && git init test  # Prompt shows git branch
echo $TERM_PROGRAM        # Should print: WezTerm
starship --version        # Should print version
```

---

## 3. Windows 11 Setup

The same `wezterm.lua` and `starship.toml` work on Windows. The shell config differs because Windows uses PowerShell instead of zsh.

### Prerequisites

- Windows 11 (build 22000+)
- Git for Windows: `winget install Git.Git`
- Node.js 18+ (optional): `winget install OpenJS.NodeJS.LTS`

### Step 1: Install PowerShell 7

Windows ships with PowerShell 5.1 (`powershell.exe`). You need PowerShell 7 (`pwsh.exe`) for the best experience:

```powershell
winget install Microsoft.PowerShell
```

After installation, close and reopen your terminal. Verify with:

```powershell
pwsh --version
```

> **Note:** The wezterm.lua config auto-detects whether PowerShell 7 is installed and falls back to Windows PowerShell 5.1 if it isn't found. But PS7 is strongly recommended.

### Step 2: Install WezTerm

```powershell
winget install wez.wezterm
```

### Step 3: Install Starship

```powershell
winget install Starship.Starship
```

### Step 4: Install Nerd Font

Download **JetBrains Mono Nerd Font** from https://www.nerdfonts.com/font-downloads and install all `.ttf` files system-wide (right-click → Install for all users).

### Step 5: Place Config Files

```powershell
New-Item -ItemType Directory -Force -Path "$HOME\.config\wezterm"
Copy-Item wezterm.lua "$HOME\.config\wezterm\wezterm.lua"

New-Item -ItemType Directory -Force -Path "$HOME\.config"
Copy-Item starship.toml "$HOME\.config\starship.toml"
```

### Step 6: Configure PowerShell Profile

The `powershell_profile.ps1` file in this package configures Starship and PSReadLine for your PowerShell environment. Deploy it to your `$PROFILE` path:

```powershell
Copy-Item powershell_profile.ps1 $PROFILE -Force
```

If the profile directory doesn't exist:

```powershell
New-Item -Path (Split-Path $PROFILE) -ItemType Directory -Force
Copy-Item powershell_profile.ps1 $PROFILE -Force
```

### Step 7: Activate

1. Close and reopen WezTerm
2. The config auto-detects Windows and uses PowerShell 7 as the default shell
3. Keybindings automatically use ALT instead of CMD (same muscle memory)

---

## 4. WSL (Ubuntu) Setup

WSL runs inside WezTerm as a tab or pane. The `wezterm.lua` launch menu already includes a WSL Ubuntu entry. Inside WSL you get the full zsh + Starship experience, identical to macOS.

### Step 1: Open WSL in WezTerm

From inside WezTerm, launch WSL Ubuntu any of these ways:

- Command palette (Alt+Shift+P) → type "WSL" → select it from the launch menu
- Right-click the + tab button → select "WSL (Ubuntu)" from the launcher
- Or run directly: `wsl.exe -d Ubuntu-24.04`

### Step 2: Install zsh and Dependencies Inside WSL

```bash
sudo apt update && sudo apt install -y zsh git curl
```

Install Starship:

```bash
curl -sS https://starship.rs/install.sh | sh
```

Install zsh plugins:

```bash
sudo apt install -y zsh-syntax-highlighting zsh-autosuggestions
```

For native Linux (not WSL), install `xclip` for image clipboard paste support:

```bash
sudo apt install -y xclip
```

> **Note on fonts:** WSL uses the Windows-installed fonts. If you already installed JetBrainsMono Nerd Font on Windows (Step 4 above), no additional font install is needed.

### Step 3: Set zsh as Default Shell

```bash
chsh -s $(which zsh)
```

Close and reopen the WSL tab for this to take effect.

### Step 4: Deploy Config Files Inside WSL

Copy from your Windows Downloads folder:

```bash
mkdir -p ~/.config
cp /mnt/c/Users/YOUR_USERNAME/Downloads/zshrc ~/.zshrc
cp /mnt/c/Users/YOUR_USERNAME/Downloads/starship.toml ~/.config/starship.toml
```

Or if you have a dotfiles repo:

```bash
git clone https://github.com/YOUR_USER/dotfiles.git ~/dotfiles
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.config/starship.toml ~/.config/starship.toml
```

### Step 5: Verify

```bash
echo $SHELL              # Should show /usr/bin/zsh or /bin/zsh
starship --version       # Should print version
echo $TERM_PROGRAM       # Should print WezTerm
ls -la                   # Colored output
```

### WSL Tips

- The WezTerm config auto-detects that WSL is Linux, so keybindings use ALT (same as native Windows)
- You can split a pane with PowerShell on one side and WSL on the other
- Access Windows files from WSL at `/mnt/c/Users/YOUR_USERNAME/`
- Access WSL files from Windows at `\\wsl$\Ubuntu-24.04\home\YOUR_USERNAME\`
- Triple-click blocks and Starship prompt work identically to macOS
- To make WSL your default shell in WezTerm instead of PowerShell, change in `wezterm.lua`:

```lua
config.default_prog = { "wsl.exe", "-d", "Ubuntu-24.04", "--cd", "~" }
```

---

## 5. Configuration Reference

### wezterm.lua

Location: `~/.config/wezterm/wezterm.lua` | Language: Lua | Hot-reloads on save

| Section | What It Does |
|---------|-------------|
| Platform Detection | Auto-detects macOS/Windows/Linux via `wezterm.target_triple`; adapts shell, fonts, keybindings |
| GPU / Rendering | WebGPU backend, 120fps, high-performance GPU preference |
| Default Shell | PowerShell 7 on Windows (auto-fallback to 5.1), zsh on Mac, default on Linux |
| Appearance | Tokyo Night theme with automatic light/dark switching based on system appearance |
| Fonts | JetBrainsMono Nerd Font (14pt Mac, 11pt Windows) with emoji fallback |
| Window Settings | Integrated title bar buttons (Mac), 140x40 initial size, subtle transparency on Mac |
| Tab Bar | Fancy tab bar showing process name per tab, numbered tabs |
| Status Bar | Right-side status: current directory, hostname (for SSH), time |
| Leader Key | Ctrl+Space prefix (2-second timeout) for all pane/tab operations |
| Keybindings | Pane splits, navigation (vim + arrows), resize mode, tab switching, copy mode, search, workspaces |
| Mouse Bindings | Ctrl+Click URLs, triple-click semantic zones, right-click copy |
| Launch Menu | Platform-specific shells (pwsh, cmd, Git Bash, WSL on Windows; zsh, bash on Mac) |
| Quick Select | Patterns for AWS ARNs, instance IDs, IPs, git hashes, UUIDs, file paths |

### zshrc

Location: `~/.zshrc` (macOS, Linux, and WSL)

| Section | What It Does |
|---------|-------------|
| Colors | CLICOLOR, LSCOLORS, LS_COLORS exports; color aliases for ls, grep, diff |
| History | 50,000-line shared history with dedup, Up/Down arrow prefix search |
| Completion | Case-insensitive tab completion with colored output and menu selection |
| SSH Agent | Auto-starts ssh-agent if not running |
| PATH | Homebrew, ~/.local/bin, ~/bin, macOS Python Library paths (auto-detected) |
| Plugins | Auto-sources zsh-syntax-highlighting and zsh-autosuggestions (Homebrew + Linux paths) |
| Shell Integration | OSC 7 directory tracking + OSC 133 semantic zones (command blocks for triple-click) |

### starship.toml

Location: `~/.config/starship.toml` (works on all platforms)

| Module | Display |
|--------|---------|
| Directory | Bold cyan, truncated to 4 levels, truncates to git repo root |
| Git Branch | Bold purple with icon, shows remote branch if tracking |
| Git Status | Bold yellow: modified(!), staged(+), untracked(?), ahead/behind arrows |
| Python | Bold yellow with 🐍, shows version and active virtualenv name |
| AWS | Bold orange (#ff9900) with ☁️, shows profile and region (abbreviated) |
| Username/Host | Bold green, only visible during SSH sessions or as root |
| Docker | Bold blue with 🐳, only when Dockerfile/compose present |
| Node.js | Bold green with ⬢, detects package.json |
| Cmd Duration | Bold red, appears when commands take 3+ seconds |
| Character | Green ❯ on success, red ❯ on error |
| Time | Dimmed white, right-aligned, HH:MM format |

---

## 6. Keybinding Reference

Leader key: **Cmd+Space** (macOS) / **Ctrl+Space** (Windows/Linux)
Press and release, then press the action key within 2 seconds.
> On macOS with the keyboard remap (physical Ctrl→Cmd), it's the same physical key on both platforms. Tables below show the Windows/Linux modifier.

### Pane Management

| Shortcut | Action |
|----------|--------|
| `Ctrl+Space \|` | Split pane horizontally (side by side) |
| `Ctrl+Space -` | Split pane vertically (top/bottom) |
| `Ctrl+Space x` | Close current pane |
| `Ctrl+Space h/j/k/l` | Navigate panes (vim-style) |
| `Ctrl+Space ←↓↑→` | Navigate panes (arrow keys) |
| `Ctrl+Space z` | Toggle zoom (maximize/restore pane) |
| `Ctrl+Space r` | Enter resize mode (h/j/k/l, Esc to exit) |
| `Ctrl+Space ]` | Rotate panes clockwise |

### Tab Management

| Shortcut | Action |
|----------|--------|
| `Ctrl+Space c` | New tab |
| `Ctrl+Space n / p` | Next / previous tab |
| `Ctrl+Space 1-9` | Jump to tab by number |
| `Ctrl+Space &` | Close tab (with confirmation) |

### Platform Shortcuts (same physical key on both platforms)

With the macOS keyboard remap (physical Ctrl → Cmd), these use the **same physical key** on both:

| macOS (signal) | Windows (signal) | Action |
|-------|---------|--------|
| `Cmd+C` | `Ctrl+C` | Copy (Windows: copies if selected, sends SIGINT if not) |
| `Cmd+V` | `Ctrl+V` | Paste from clipboard |
| `Cmd+F` | `Ctrl+F` | Search scrollback |
| `Cmd+K` | `Ctrl+K` | Clear scrollback |
| `Cmd+Shift+P` | `Ctrl+Shift+P` | Command palette |
| `Cmd++/-/0` | `Ctrl++/-/0` | Font size |

### Other

| Shortcut | Action |
|----------|--------|
| `Ctrl+Space Space` | Quick Select (grab IPs, ARNs, hashes, paths) |
| `Ctrl+Space [` | Copy mode (vim-style selection) |
| `Ctrl+Space s` | List workspaces |
| `Ctrl+Space w` | Fuzzy-find workspaces |
| `Ctrl+Space Shift+S` | SSH domain launcher |
| `Ctrl+Space Shift+R` | Force reload config |
| `Ctrl+Alt+V` / `Cmd+Alt+V` | Paste clipboard image as file path |
| `Ctrl+Click` | Open URL in browser |
| `Triple-click` | Select single command's output block |

---

## 7. Workflow Tips

### SSH

- **Ctrl+Space Shift+S** fuzzy-searches and connects to SSH hosts from known_hosts
- Add frequent hosts to `ssh_domains` in wezterm.lua for one-click connections
- Starship shows username@hostname in green during SSH sessions
- Status bar shows remote hostname on the right

---

## 8. Syncing Configs Across Machines

### Recommended: Git Dotfiles Repository

Repository structure:

```
dotfiles/
  .config/
    wezterm/
      wezterm.lua           # Shared (cross-platform)
    starship.toml           # Shared (cross-platform)
  .zshrc                    # macOS/Linux/WSL
  powershell/
    Microsoft.PowerShell_profile.ps1  # Windows only
```

macOS setup (first machine):

```bash
cd ~/dotfiles && git init
git add -A && git commit -m "wezterm config"
# Push to GitHub

# Symlink into place
ln -sf ~/dotfiles/.config/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
ln -sf ~/dotfiles/.config/starship.toml ~/.config/starship.toml
ln -sf ~/dotfiles/.zshrc ~/.zshrc
```

Windows setup (PowerShell as Administrator):

```powershell
git clone https://github.com/YOUR_USER/dotfiles.git ~/dotfiles

New-Item -ItemType SymbolicLink `
  -Path "$HOME\.config\wezterm\wezterm.lua" `
  -Target "$HOME\dotfiles\.config\wezterm\wezterm.lua"

New-Item -ItemType SymbolicLink `
  -Path "$HOME\.config\starship.toml" `
  -Target "$HOME\dotfiles\.config\starship.toml"
```

WSL setup:

```bash
git clone https://github.com/YOUR_USER/dotfiles.git ~/dotfiles
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.config/starship.toml ~/.config/starship.toml
```

---

## 9. Customization

### Change Color Scheme

WezTerm ships with 700+ color schemes. Browse live:

- Command palette: `Cmd+Shift+P` (Mac) or `Alt+Shift+P` (Windows)
- Type "color" and scroll through previews
- Or edit the `color_scheme` line in wezterm.lua — hot-reloads instantly

Popular alternatives:

```lua
config.color_scheme = "Catppuccin Mocha"
config.color_scheme = "Dracula (Official)"
config.color_scheme = "Gruvbox Dark (Gogh)"
config.color_scheme = "Nord (Gogh)"
```

### Change Font

List available system fonts:

```bash
wezterm ls-fonts --list-system
```

Then update the `font_with_fallback` call in wezterm.lua.

### Add SSH Hosts

Edit the `ssh_domains` section in wezterm.lua:

```lua
config.ssh_domains = {
  { name = "homelab", remote_address = "192.168.1.100", username = "your-user" },
  { name = "aws-prod", remote_address = "bastion.example.com", username = "ec2-user" },
}
```

### Make WSL the Default Shell on Windows

```lua
config.default_prog = { "wsl.exe", "-d", "Ubuntu-24.04", "--cd", "~" }
```

### Image Paste (Ctrl+Alt+V)

When you copy a screenshot to your clipboard (e.g., Win+Shift+S on Windows, Cmd+Shift+4 on macOS), pressing **Ctrl+Alt+V** (or **Cmd+Alt+V** on macOS) saves the clipboard image to a temp file and sends the file path to the terminal. This is useful for pasting screenshots into CLI tools that accept image file paths (e.g., Claude Code).

- **Windows/WSL**: Uses PowerShell `Get-Clipboard -Format Image`. Auto-detects WSL panes and converts the path to `/mnt/c/...` format.
- **macOS**: Uses `pngpaste` (install with `brew install pngpaste`).
- **Linux**: Uses `wl-paste` (Wayland) or `xclip` (X11). Install with `sudo apt install xclip`.

If no image is on the clipboard, falls back to normal text paste.

### Disable Transparency on Mac

```lua
config.window_background_opacity = 1.0  -- was 0.96
```

---

## 10. Troubleshooting

### Config not loading

- Verify file location: `~/.config/wezterm/wezterm.lua` (not `.config/wezterm.lua`)
- Check for Lua syntax errors — WezTerm shows an error dialog on launch
- Force reload: `Cmd+Space Shift+R` (macOS) / `Ctrl+Space Shift+R` (Windows/Linux)

### Font icons showing as squares/boxes

- Install JetBrainsMono Nerd Font (see Step 2/4 in platform setup)
- macOS: restart WezTerm after font installation
- Windows: install fonts "for all users" (right-click → Install for all users)
- Verify: `wezterm ls-fonts --list-system | grep -i jetbrains`

### Colors not showing in shell

- Verify .zshrc is loaded: `echo $CLICOLOR` should print `1`
- Verify Starship is running: `starship --version`
- Open a new tab if you just changed .zshrc

### ls -l not showing long format (macOS)

- This was fixed in this config. The `ls` alias detects BSD vs GNU ls at startup.
- If still broken: `source ~/.zshrc` and try again in a new tab.

### Triple-click not selecting command blocks

- OSC 133 semantic zones only work for commands run AFTER the shell integration loads
- Open a new tab, run a few commands, then try triple-click
- Won't work in SSH sessions unless the remote shell also has OSC 133 integration

### Cmd+Space / Ctrl+Space conflict

**macOS — Spotlight conflict:** Cmd+Space is Spotlight search by default. Disable it in System Settings → Keyboard → Shortcuts → Spotlight, or reassign Spotlight to a different key.

**Zsh — set-mark-command conflict:** Ctrl+Space is `set-mark-command` in zsh's emacs mode. WezTerm intercepts it as the leader key before it reaches the shell, so this shouldn't be an issue. If you need `set-mark-command`, rebind it in your `.zshrc`:

```zsh
bindkey '^@' undefined-key   # free Ctrl+Space for WezTerm leader
```

To change the leader key entirely, edit `wezterm.lua`:

```lua
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 2000 }
```

### Windows: "pwsh.exe didn't exit cleanly"

- Install PowerShell 7: `winget install Microsoft.PowerShell`
- The config auto-detects and falls back to `powershell.exe` if pwsh isn't found
- Close and reopen WezTerm after installing

