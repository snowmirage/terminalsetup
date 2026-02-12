-- Version: v1.0
-- Date: 2026-02-12
-- ==========================================================================
-- WezTerm Cross-Platform Configuration
-- Works on macOS, Windows 11, and Linux
-- Optimized for: Python/venv, SSH, AWS, GitHub
-- ==========================================================================
local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

-- ==========================================================================
-- PLATFORM DETECTION
-- ==========================================================================
local is_windows = wezterm.target_triple:find("windows") ~= nil
local is_macos = wezterm.target_triple:find("darwin") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil

-- Modifier key abstraction: CMD on mac, CTRL on Windows/Linux
-- With macOS keyboard remap (physical Ctrl→Cmd), this means the same
-- physical key triggers these shortcuts on both platforms.
local mod = {
  SUPER = is_macos and "SUPER" or "CTRL",
  SUPER_SHIFT = is_macos and "SUPER|SHIFT" or "CTRL|SHIFT",
}

-- ==========================================================================
-- GPU / RENDERING
-- ==========================================================================
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
config.max_fps = 120
config.animation_fps = 60

-- ==========================================================================
-- DEFAULT SHELL
-- ==========================================================================
if is_windows then
  -- Use PowerShell 7 (pwsh) if available, fall back to Windows PowerShell
  local pwsh_found = false
  local success, stdout, stderr = wezterm.run_child_process({ "where.exe", "pwsh.exe" })
  if success then
    pwsh_found = true
  end
  if pwsh_found then
    config.default_prog = { "pwsh.exe", "-NoLogo" }
  else
    config.default_prog = { "powershell.exe", "-NoLogo" }
  end
  -- Uncomment the next line if you prefer Git Bash:
  -- config.default_prog = { "C:\\Program Files\\Git\\bin\\bash.exe", "-l" }
elseif is_macos then
  config.default_prog = { "/bin/zsh", "-l" }
end
-- Linux uses the default login shell automatically

-- ==========================================================================
-- APPEARANCE
-- ==========================================================================
-- Color scheme - Tokyo Night is excellent for long coding sessions
-- WezTerm ships with 700+ schemes; change to your preference
config.color_scheme = "Tokyo Night"
-- Other great options:
-- "Catppuccin Mocha"
-- "Dracula (Official)"
-- "Gruvbox Dark (Gogh)"
-- "Nord (Gogh)"
-- "Solarized Dark (Gogh)"

-- Automatically switch light/dark with system appearance
local function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "Tokyo Night"
  else
    return "Tokyo Night Day"
  end
end

wezterm.on("window-config-reloaded", function(window, _)
  local overrides = window:get_config_overrides() or {}
  local appearance = window:get_appearance()
  local scheme = scheme_for_appearance(appearance)
  if overrides.color_scheme ~= scheme then
    overrides.color_scheme = scheme
    window:set_config_overrides(overrides)
  end
end)

-- ==========================================================================
-- FONTS
-- ==========================================================================
-- JetBrains Mono is bundled with WezTerm; Nerd Font symbols also bundled
-- If you install a Nerd Font, put it first in the fallback chain
config.font = wezterm.font_with_fallback({
  { family = "JetBrainsMono Nerd Font", weight = "Medium" },
  { family = "JetBrains Mono", weight = "Medium" },  -- fallback if Nerd Font not installed
  "Noto Color Emoji",
})

config.font_size = is_macos and 14.0 or 11.0
config.line_height = 1.1
config.cell_width = 1.0
config.freetype_load_flags = "NO_HINTING"
config.warn_about_missing_glyphs = false

-- ==========================================================================
-- WINDOW SETTINGS
-- ==========================================================================
config.window_decorations = is_macos and "RESIZE|INTEGRATED_BUTTONS" or "RESIZE"
config.window_background_opacity = is_macos and 0.96 or 1.0
config.macos_window_background_blur = 20
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.initial_cols = 140
config.initial_rows = 40

config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 4,
}

-- ==========================================================================
-- TAB BAR
-- ==========================================================================
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.show_tab_index_in_tab_bar = true
config.tab_max_width = 32
config.switch_to_last_active_tab_when_closing_tab = true

-- Custom tab title: show process name + working directory
wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
  local pane = tab.active_pane
  local title = pane.title
  -- Show the active process name
  if pane.foreground_process_name then
    local process = pane.foreground_process_name:match("([^/\\]+)$") or ""
    if process ~= "" then
      title = process
    end
  end
  -- Truncate if needed
  if #title > max_width - 4 then
    title = title:sub(1, max_width - 6) .. "…"
  end
  local index = tab.tab_index + 1
  return string.format(" %d: %s ", index, title)
end)

-- ==========================================================================
-- STATUS BAR (right side) - shows useful context
-- ==========================================================================
wezterm.on("update-status", function(window, pane)
  local cells = {}

  -- Current working directory
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    local cwd = cwd_uri.file_path or ""
    -- Shorten home directory
    local home = os.getenv("HOME") or os.getenv("USERPROFILE") or ""
    if home ~= "" and cwd:sub(1, #home) == home then
      cwd = "~" .. cwd:sub(#home + 1)
    end
    -- Truncate long paths
    if #cwd > 40 then
      cwd = "…" .. cwd:sub(-38)
    end
    table.insert(cells, cwd)
  end

  -- Hostname (useful for SSH sessions)
  local hostname = wezterm.hostname()
  if hostname then
    hostname = hostname:gsub("%.local$", "")
    table.insert(cells, hostname)
  end

  -- Date/time
  table.insert(cells, wezterm.strftime("%H:%M"))

  -- Build the status text
  local text = table.concat(cells, "  │  ")
  window:set_right_status(wezterm.format({
    { Foreground = { Color = "#7aa2f7" } },
    { Text = " " .. text .. " " },
  }))
end)

-- ==========================================================================
-- SEARCH
-- ==========================================================================
config.enable_scroll_bar = false

-- ==========================================================================
-- LEADER KEY (tmux-style multiplexer)
-- ==========================================================================
-- Leader: physical Ctrl+\ on both platforms (unused by anything else)
--   macOS:   Cmd+\  (physical Ctrl+\ because Ctrl is remapped to Cmd)
--   Windows: Ctrl+\ (physical Ctrl+\ standard)
-- Press Leader, release, then press action key within 2 seconds.
config.leader = {
  key = "\\",
  mods = is_macos and "SUPER" or "CTRL",
  timeout_milliseconds = 2000,
}

-- ==========================================================================
-- KEYBINDINGS
-- ==========================================================================
config.keys = {
  -- ===== Pane Management (Leader-based, works everywhere) =====
  -- Split panes
  { key = "|",  mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "-",  mods = "LEADER",       action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "x",  mods = "LEADER",       action = act.CloseCurrentPane({ confirm = false }) },

  -- Navigate panes with Leader + arrow keys
  { key = "h",         mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j",         mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k",         mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l",         mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "LeftArrow", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "DownArrow", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "UpArrow",   mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "RightArrow",mods = "LEADER", action = act.ActivatePaneDirection("Right") },

  -- Resize panes (Leader + r enters resize mode)
  { key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },

  -- Zoom/maximize current pane
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

  -- Rotate panes
  { key = "]", mods = "LEADER", action = act.RotatePanes("Clockwise") },

  -- ===== Tab Management =====
  { key = "c", mods = "LEADER",       action = act.SpawnTab("CurrentPaneDomain") },
  { key = "n", mods = "LEADER",       action = act.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER",       action = act.ActivateTabRelative(-1) },
  { key = "&", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },

  -- Quick tab switching: Leader + number
  { key = "1", mods = "LEADER", action = act.ActivateTab(0) },
  { key = "2", mods = "LEADER", action = act.ActivateTab(1) },
  { key = "3", mods = "LEADER", action = act.ActivateTab(2) },
  { key = "4", mods = "LEADER", action = act.ActivateTab(3) },
  { key = "5", mods = "LEADER", action = act.ActivateTab(4) },
  { key = "6", mods = "LEADER", action = act.ActivateTab(5) },
  { key = "7", mods = "LEADER", action = act.ActivateTab(6) },
  { key = "8", mods = "LEADER", action = act.ActivateTab(7) },
  { key = "9", mods = "LEADER", action = act.ActivateTab(8) },

  -- ===== Platform-Agnostic Shortcuts (Super = CMD on mac, CTRL on win) =====
  -- Smart Copy: if text selected → copy, otherwise → send Ctrl+C (SIGINT)
  -- On macOS Cmd+C always copies (SIGINT is Ctrl+C which is a different signal)
  -- On Windows/Linux we need the smart behavior since Ctrl+C does double duty
  { key = "c", mods = mod.SUPER, action = is_macos
    and act.CopyTo("Clipboard")
    or wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ""
      if has_selection then
        window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act.SendKey({ key = "c", mods = "CTRL" }), pane)
      end
    end),
  },
  -- Smart Paste: on Windows Ctrl+V needs to paste instead of sending literal ^V
  { key = "v", mods = mod.SUPER, action = act.PasteFrom("Clipboard") },

  -- Font size
  { key = "+", mods = mod.SUPER_SHIFT, action = act.IncreaseFontSize },
  { key = "-", mods = mod.SUPER,       action = act.DecreaseFontSize },
  { key = "0", mods = mod.SUPER,       action = act.ResetFontSize },

  -- Quick actions
  { key = "f", mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = "" }) },
  { key = "k", mods = mod.SUPER, action = act.ClearScrollback("ScrollbackAndViewport") },

  -- Command palette
  { key = "p", mods = mod.SUPER_SHIFT, action = act.ActivateCommandPalette },

  -- ===== Workspaces (session management - like tmux sessions) =====
  { key = "s", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "WORKSPACES" }) },
  { key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },

  -- ===== Quick Select (like tmux copy-mode URLs) =====
  { key = "Space", mods = "LEADER", action = act.QuickSelect },

  -- ===== SSH Quick Connect (from known_hosts) =====
  { key = "S", mods = "LEADER|SHIFT", action = act.ShowLauncherArgs({ flags = "FUZZY|DOMAINS" }) },

  -- ===== Copy Mode (vim-style text selection) =====
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },

  -- ===== Reload Config =====
  { key = "R", mods = "LEADER|SHIFT", action = act.ReloadConfiguration },
}

-- ===== Resize Pane Key Table =====
config.key_tables = {
  resize_pane = {
    { key = "h",         action = act.AdjustPaneSize({ "Left", 2 }) },
    { key = "j",         action = act.AdjustPaneSize({ "Down", 2 }) },
    { key = "k",         action = act.AdjustPaneSize({ "Up", 2 }) },
    { key = "l",         action = act.AdjustPaneSize({ "Right", 2 }) },
    { key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 2 }) },
    { key = "DownArrow", action = act.AdjustPaneSize({ "Down", 2 }) },
    { key = "UpArrow",   action = act.AdjustPaneSize({ "Up", 2 }) },
    { key = "RightArrow",action = act.AdjustPaneSize({ "Right", 2 }) },
    -- Escape or Enter to exit resize mode
    { key = "Escape", action = "PopKeyTable" },
    { key = "Enter",  action = "PopKeyTable" },
  },
}

-- ==========================================================================
-- MOUSE BINDINGS
-- ==========================================================================
config.mouse_bindings = {
  -- Ctrl+Click to open URLs
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },
  -- Triple-click selects semantic zones (command output blocks)
  {
    event = { Down = { streak = 3, button = "Left" } },
    action = act.SelectTextAtMouseCursor("SemanticZone"),
    mods = "NONE",
  },
  -- Right-click: copy selected text to clipboard (no paste)
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ""
      if has_selection then
        window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
        window:perform_action(act.ClearSelection, pane)
      end
    end),
  },
}

-- ==========================================================================
-- LAUNCH MENU (quick access to common environments)
-- ==========================================================================
local launch_menu = {}

if is_windows then
  -- Windows-specific launch menu items
  launch_menu = {
    { label = "  PowerShell 7",   args = { "pwsh.exe", "-NoLogo" } },
    { label = "  Windows PowerShell", args = { "powershell.exe", "-NoLogo" } },
    { label = "  Command Prompt", args = { "cmd.exe" } },
    { label = "  Git Bash",       args = { "C:\\Program Files\\Git\\bin\\bash.exe", "-l" } },
    { label = "  WSL (Ubuntu)",   args = { "wsl.exe", "-d", "Ubuntu-24.04" } },
  }
elseif is_macos then
  launch_menu = {
    { label = "  Zsh",  args = { "/bin/zsh", "-l" } },
    { label = "  Bash", args = { "/bin/bash", "-l" } },
  }
end

config.launch_menu = launch_menu

-- ==========================================================================
-- SSH DOMAINS (add your frequently-used SSH hosts here)
-- ==========================================================================
-- These let you connect via the launcher (Leader+Shift+S)
-- They also show up in the command palette
config.ssh_domains = {
  -- Example: uncomment and customize for your servers
  -- {
  --   name = "homelab",
  --   remote_address = "192.168.1.100",
  --   username = "your-user",
  -- },
  -- {
  --   name = "aws-bastion",
  --   remote_address = "bastion.example.com",
  --   username = "ec2-user",
  -- },
}

-- ==========================================================================
-- QUICK SELECT PATTERNS (for URLs, IPs, file paths, etc.)
-- ==========================================================================
config.quick_select_patterns = {
  -- AWS ARNs
  "arn:[a-zA-Z0-9:/_-]+",
  -- AWS instance IDs
  "i%-[0-9a-f]+",
  -- AWS account IDs (12-digit)
  "%f[%d]%d%d%d%d%d%d%d%d%d%d%d%d%f[%D]",
  -- IP addresses
  "%d+%.%d+%.%d+%.%d+",
  -- Git commit hashes (short and long)
  "%f[%x][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+%f[^%x]",
  -- File paths (unix)
  "[~/][%w%.%-_/]+",
  -- Python virtual env paths
  "[%w_%-%.]+/bin/python[%d%.]*",
  -- UUIDs
  "[0-9a-f]+-[0-9a-f]+-[0-9a-f]+-[0-9a-f]+-[0-9a-f]+",
}

-- ==========================================================================
-- HYPERLINK RULES (clickable links in terminal output)
-- ==========================================================================
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Add GitHub shorthand: org/repo
table.insert(config.hyperlink_rules, {
  regex = [[["]?([\w\d]{1}[-\w\d]+)(/)([-\w\d\.]+)["]?]],
  format = "https://github.com/$1/$3",
})

-- ==========================================================================
-- MISC
-- ==========================================================================
config.automatically_reload_config = true
config.check_for_updates = true
config.enable_kitty_graphics = true
config.scrollback_lines = 100000
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_function = "EaseIn",
  fade_in_duration_ms = 50,
  fade_out_function = "EaseOut",
  fade_out_duration_ms = 50,
}
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.term = "xterm-256color"

-- Detect and handle Python virtual environments in tab titles
-- (venv activation is handled by your shell, but this helps visibility)
config.set_environment_variables = {}
if is_windows then
  -- Ensure Python venv works well in PowerShell
  config.set_environment_variables["VIRTUAL_ENV_DISABLE_PROMPT"] = "0"
end

-- ==========================================================================
-- SHELL INTEGRATION
-- ==========================================================================
-- WezTerm supports OSC 133 shell integration for semantic zones.
-- Shift+Enter works natively for multi-line input.
--
-- POWERSHELL ($PROFILE) — add for Windows:
--   if ($env:TERM_PROGRAM -eq "WezTerm") {
--     # WezTerm integrates via OSC sequences automatically
--   }

return config
