# WezTerm Cheat Sheet
## Leader key: Ctrl+\ (press then release, then press action key within 2 sec)

> KEYBOARD NOTE (macOS remap): Physical Ctrl→Cmd, Windows/Globe→Ctrl, Alt→Option
> This makes copy/paste the same physical keys on Mac and Windows.
> Leader key (Ctrl+\): same physical key on both platforms.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## HOW WEZTERM IS ORGANIZED

  Window  →  Workspace  →  Tabs  →  Panes

  **Panes**       Split views INSIDE a single tab. Like tmux splits.
                Run a task on the right, your shell on the left.
                Each pane is its own independent shell.

  **Tabs**        Like browser tabs across the top bar. Each tab holds
                one or more panes. Use tabs for separate tasks:
                one for coding, one for SSH, one for logs.

  **Workspaces**  Named groups of ALL your tabs. Switching workspaces
                swaps everything visible at once. Think of them as
                virtual desktops for your terminal.
                Example: "bytesec" workspace with client tabs,
                "homelab" workspace with server tabs.

  Typical setup:
    Workspace "project-x"
      ├── Tab 1: editor (left pane) + task (right pane)
      ├── Tab 2: SSH to staging server
      └── Tab 3: docker logs

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## COPY & PASTE

  Cmd+C / Ctrl+Shift+C       Copy selected text
  Cmd+V / Ctrl+Shift+V       Paste from clipboard
  Select text + Right-click   Copy selected text to clipboard
  Click and drag               Select text (auto-highlights)
  Double-click                 Select word
  Triple-click                 Select a single command's output (block)
  Ctrl+Click on URL            Open link in browser

  **Command Blocks** (like Warp's blocks):
  Triple-click inside any command's output to select ONLY that
  output — not the whole terminal history. This works because the
  .zshrc sends OSC 133 markers that tell WezTerm where each
  command's prompt, input, and output start and end.

  Example: if you ran `ls`, then `git status`, then `ps aux`,
  triple-clicking inside the `git status` output selects only
  that output — not ls or ps aux.

  **Copy Mode** (vim-style precise selection):
  Ctrl+\ [         Enter copy mode
                    Then use vim keys: h/j/k/l to move,
                    v to start selection, y to copy, Esc to exit

  **Quick Select** (grab specific patterns from output):
  Ctrl+\ Space     Highlights all IPs, ARNs, git hashes, UUIDs,
                    file paths on screen. Press the letter shown
                    next to the one you want — it copies to clipboard.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## PANES

  Ctrl+\ |         Split horizontally (left | right)
  Ctrl+\ -         Split vertically (top / bottom)
  Ctrl+\ x         Close current pane
  Ctrl+\ z         Zoom pane (toggle fullscreen/restore)

  Navigate between panes:
  Ctrl+\ h          Move to left pane       (or ← arrow)
  Ctrl+\ j          Move to pane below      (or ↓ arrow)
  Ctrl+\ k          Move to pane above      (or ↑ arrow)
  Ctrl+\ l          Move to right pane      (or → arrow)

  Resize panes:
  Ctrl+\ r          Enter resize mode
                     Then h/j/k/l to resize, Esc when done

  Ctrl+\ ]          Rotate panes clockwise

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## TABS

  Ctrl+\ c          New tab
  Ctrl+\ n          Next tab
  Ctrl+\ p          Previous tab
  Ctrl+\ 1-9        Jump to tab by number
  Ctrl+\ &          Close tab (with confirmation)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## WORKSPACES

  Ctrl+\ s          List all workspaces (switch between them)
  Ctrl+\ w          Fuzzy-find workspaces

  Create a new workspace:
    Open command palette (Cmd+Shift+P / Alt+Shift+P)
    Type "workspace" → select "Switch to Workspace"
    Type a new name → Enter (creates it and switches to it)

  Workspaces persist until you close WezTerm.
  Each workspace has its own set of tabs and panes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## SSH

  Ctrl+\ Shift+S    Fuzzy-search SSH hosts and connect
                     (reads from ~/.ssh/known_hosts and ssh_domains in config)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## PLATFORM SHORTCUTS (same physical key on both platforms)

  With macOS remap (physical Ctrl→Cmd), these are the SAME physical key:

  Cmd+C / Ctrl+C             Copy (on Windows: copies if selected, SIGINT if not)
  Cmd+V / Ctrl+V             Paste from clipboard
  Cmd+F / Ctrl+F             Search scrollback
  Cmd+K / Ctrl+K             Clear scrollback
  Cmd+Shift+P / Ctrl+Shift+P  Command palette (search all actions)
  Cmd++/-/0 / Ctrl++/-/0     Font size: bigger / smaller / reset

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## OTHER

  Ctrl+\ Shift+R    Force reload config
  Ctrl+\ [          Copy mode (vim selection)
  Ctrl+\ Space      Quick Select (grab IPs, hashes, paths)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## QUICK REFERENCE: LEADER COMBOS

  Ctrl+\ then...    Action
  ──────────────    ──────────────────────────
  |                 Split right
  -                 Split down
  x                 Close pane
  z                 Zoom pane
  h/j/k/l           Navigate panes
  r                 Resize mode
  ]                 Rotate panes
  c                 New tab
  n / p             Next / prev tab
  1-9               Jump to tab
  &                 Close tab
  s                 List workspaces
  w                 Find workspace
  Shift+S           SSH launcher
  Shift+R           Reload config
  Space             Quick Select
  [                 Copy mode

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Config: ~/.config/wezterm/wezterm.lua (hot-reloads on save)
  Command Palette: Cmd+Shift+P — search all 700+ actions and themes
