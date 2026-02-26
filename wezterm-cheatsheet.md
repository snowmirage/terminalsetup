# WezTerm Cheat Sheet
## Leader key: Cmd+Space (macOS) / Ctrl+Space (Windows/Linux)
## Press then release, then press action key within 2 sec

> KEYBOARD NOTE (macOS remap): Physical Ctrl→Cmd, Windows/Globe→Ctrl, Alt→Option
> This makes copy/paste the same physical keys on Mac and Windows.
> Leader key: same physical key on both platforms (physical Ctrl+Space).

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
  Cmd+Alt+V / Ctrl+Alt+V      Paste clipboard image as file path
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
  Ctrl+Space [         Enter copy mode
                    Then use vim keys: h/j/k/l to move,
                    v to start selection, y to copy, Esc to exit

  **Quick Select** (grab specific patterns from output):
  Ctrl+Space Space     Highlights all IPs, ARNs, git hashes, UUIDs,
                    file paths on screen. Press the letter shown
                    next to the one you want — it copies to clipboard.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## PANES

  Ctrl+Space |         Split horizontally (left | right)
  Ctrl+Space -         Split vertically (top / bottom)
  Ctrl+Space x         Close current pane
  Ctrl+Space z         Zoom pane (toggle fullscreen/restore)

  Navigate between panes:
  Ctrl+Space h          Move to left pane       (or ← arrow)
  Ctrl+Space j          Move to pane below      (or ↓ arrow)
  Ctrl+Space k          Move to pane above      (or ↑ arrow)
  Ctrl+Space l          Move to right pane      (or → arrow)

  Resize panes:
  Ctrl+Space r          Enter resize mode
                     Then h/j/k/l to resize, Esc when done

  Ctrl+Space ]          Rotate panes clockwise

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## TABS

  Ctrl+Space c          New tab
  Ctrl+Space n          Next tab
  Ctrl+Space p          Previous tab
  Ctrl+Space 1-9        Jump to tab by number
  Ctrl+Space &          Close tab (with confirmation)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## WORKSPACES

  Ctrl+Space s          List all workspaces (switch between them)
  Ctrl+Space w          Fuzzy-find workspaces

  Create a new workspace:
    Open command palette (Cmd+Shift+P / Alt+Shift+P)
    Type "workspace" → select "Switch to Workspace"
    Type a new name → Enter (creates it and switches to it)

  Workspaces persist until you close WezTerm.
  Each workspace has its own set of tabs and panes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## SSH

  Ctrl+Space Shift+S    Fuzzy-search SSH hosts and connect
                     (reads from ~/.ssh/known_hosts and ssh_domains in config)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## PLATFORM SHORTCUTS (same physical key on both platforms)

  With macOS remap (physical Ctrl→Cmd), these are the SAME physical key:

  Cmd+C / Ctrl+C             Copy (on Windows: copies if selected, SIGINT if not)
  Cmd+V / Ctrl+V             Paste from clipboard
  Cmd+F / Ctrl+F             Search scrollback
  Cmd+K / Ctrl+K             Clear scrollback
  Cmd+Shift+P / Ctrl+Shift+P  Command palette (search all actions)
  Cmd+Alt+V / Ctrl+Alt+V        Paste clipboard image as file path
  Cmd++/-/0 / Ctrl++/-/0     Font size: bigger / smaller / reset

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## OTHER

  Ctrl+Space Shift+R    Force reload config
  Ctrl+Space [          Copy mode (vim selection)
  Ctrl+Space Space      Quick Select (grab IPs, hashes, paths)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## QUICK REFERENCE: LEADER COMBOS

  Ctrl+Space then...    Action
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
