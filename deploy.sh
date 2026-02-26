#!/usr/bin/env bash
# ==========================================================================
# Terminal Setup — Deployment Script (macOS / Linux / WSL)
# Deploys: zshrc, starship.toml, wezterm.lua
# Repeatable: re-run after pulling updates to refresh configs
# ==========================================================================
set -euo pipefail

if [ -z "${BASH_VERSION:-}" ]; then
  echo "Error: This script requires bash. Run with: bash deploy.sh"
  exit 1
fi

# ========================= CONFIGURATION =========================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$HOME/.config-backups/terminalsetup/$TIMESTAMP"
BACKUPS_MADE=false

# ========================= COLORS =========================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ========================= HELPERS =========================

info()    { printf "${BLUE}[INFO]${NC} %s\n" "$*"; }
success() { printf "${GREEN}[ OK ]${NC} %s\n" "$*"; }
warn()    { printf "${YELLOW}[WARN]${NC} %s\n" "$*"; }
err()     { printf "${RED}[ERR ]${NC} %s\n" "$*"; }
header()  { printf "\n${BOLD}${CYAN}━━━ %s ━━━${NC}\n\n" "$*"; }

prompt_continue() {
  local msg="${1:-Press Enter to continue, or Ctrl+C to abort...}"
  printf "\n  ${DIM}%s${NC} " "$msg"
  read -r
}

prompt_yn() {
  local msg="$1"
  local answer
  printf "  ${YELLOW}%s [y/N]: ${NC}" "$msg"
  read -r answer
  [[ "$answer" =~ ^[Yy] ]]
}

check_command() {
  command -v "$1" &>/dev/null
}

# ========================= PLATFORM DETECTION =========================

detect_platform() {
  PLATFORM="unknown"
  IS_WSL=false

  case "$(uname -s)" in
    Darwin) PLATFORM="macos" ;;
    Linux)
      PLATFORM="linux"
      if grep -qi microsoft /proc/version 2>/dev/null; then
        IS_WSL=true
      fi
      ;;
  esac

  if [[ "$PLATFORM" == "unknown" ]]; then
    err "Unsupported platform: $(uname -s)"
    err "For Windows, use deploy.ps1 in PowerShell instead."
    exit 1
  fi

  info "Platform: $PLATFORM$($IS_WSL && echo ' (WSL)' || echo '')"
}

# ========================= PREREQUISITES =========================

check_prerequisites() {
  header "Checking Prerequisites"

  if [[ "$PLATFORM" == "macos" ]]; then
    check_prerequisites_macos
  else
    check_prerequisites_linux
  fi
}

check_prerequisites_macos() {
  # Homebrew
  if ! check_command brew; then
    err "Homebrew is required but not installed."
    info "Install from: https://brew.sh"
    info 'Run: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    prompt_continue "Press Enter after installing Homebrew..."
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
  else
    success "Homebrew is installed"
  fi

  # WezTerm
  if ! check_command wezterm; then
    warn "WezTerm is not installed"
    if prompt_yn "Install WezTerm via Homebrew?"; then
      brew install --cask wezterm
    else
      info "Install later with: brew install --cask wezterm"
    fi
  else
    success "WezTerm is installed"
  fi

  # Starship
  if ! check_command starship; then
    warn "Starship is not installed"
    if prompt_yn "Install Starship via Homebrew?"; then
      brew install starship
    else
      info "Install later with: brew install starship"
    fi
  else
    success "Starship is installed"
  fi

  # Zsh plugins
  if [ ! -f "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    warn "zsh-syntax-highlighting not found"
    if prompt_yn "Install via Homebrew?"; then
      brew install zsh-syntax-highlighting
    fi
  else
    success "zsh-syntax-highlighting is installed"
  fi

  if [ ! -f "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    warn "zsh-autosuggestions not found"
    if prompt_yn "Install via Homebrew?"; then
      brew install zsh-autosuggestions
    fi
  else
    success "zsh-autosuggestions is installed"
  fi

  # pngpaste (for image clipboard paste in WezTerm)
  if ! check_command pngpaste; then
    warn "pngpaste is not installed (needed for Ctrl+Alt+V image paste)"
    if prompt_yn "Install pngpaste via Homebrew?"; then
      brew install pngpaste
    else
      info "Install later with: brew install pngpaste"
    fi
  else
    success "pngpaste is installed"
  fi

  # Nerd Font
  echo ""
  info "JetBrainsMono Nerd Font is required for icons."
  if prompt_yn "Install JetBrainsMono Nerd Font via Homebrew?"; then
    brew install --cask font-jetbrains-mono-nerd-font
  else
    info "Install later with: brew install --cask font-jetbrains-mono-nerd-font"
  fi
}

check_prerequisites_linux() {
  # zsh
  if ! check_command zsh; then
    warn "zsh is not installed"
    if prompt_yn "Install zsh via apt?"; then
      sudo apt update && sudo apt install -y zsh
    else
      info "Install later with: sudo apt install -y zsh"
    fi
  else
    success "zsh is installed"
  fi

  # Set zsh as default shell
  if check_command zsh && [ "$(basename "$SHELL")" != "zsh" ]; then
    warn "zsh is installed but not your default shell (current: $SHELL)"
    if prompt_yn "Set zsh as default shell? (requires password)"; then
      chsh -s "$(which zsh)"
      success "Default shell changed to zsh (takes effect on next login)"
    fi
  fi

  # git and curl
  if ! check_command git; then
    warn "git is not installed"
    if prompt_yn "Install git via apt?"; then
      sudo apt update && sudo apt install -y git
    fi
  else
    success "git is installed"
  fi

  if ! check_command curl; then
    warn "curl is not installed"
    if prompt_yn "Install curl via apt?"; then
      sudo apt install -y curl
    fi
  else
    success "curl is installed"
  fi

  # Starship
  if ! check_command starship; then
    warn "Starship is not installed"
    if prompt_yn "Install Starship via official install script?"; then
      curl -sS https://starship.rs/install.sh | sh
    else
      info "Install later: curl -sS https://starship.rs/install.sh | sh"
    fi
  else
    success "Starship is installed"
  fi

  # Zsh plugins
  if [ ! -f "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    warn "zsh-syntax-highlighting not found"
    if prompt_yn "Install via apt?"; then
      sudo apt install -y zsh-syntax-highlighting
    fi
  else
    success "zsh-syntax-highlighting is installed"
  fi

  if [ ! -f "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    warn "zsh-autosuggestions not found"
    if prompt_yn "Install via apt?"; then
      sudo apt install -y zsh-autosuggestions
    fi
  else
    success "zsh-autosuggestions is installed"
  fi

  # xclip (for image clipboard paste in WezTerm — not needed on WSL)
  if ! $IS_WSL; then
    if ! check_command xclip; then
      warn "xclip is not installed (needed for Ctrl+Alt+V image paste)"
      if prompt_yn "Install xclip via apt?"; then
        sudo apt install -y xclip
      fi
    else
      success "xclip is installed"
    fi
  fi

  # Font reminder
  echo ""
  if $IS_WSL; then
    info "WSL uses fonts installed on Windows."
    info "Ensure JetBrainsMono Nerd Font is installed on your Windows system."
    info "Download from: https://www.nerdfonts.com/font-downloads"
  else
    info "JetBrainsMono Nerd Font is required for icons."
    info "Download from: https://www.nerdfonts.com/font-downloads"
    info "Install all .ttf files to your system fonts."
  fi
  prompt_continue
}

# ========================= BACKUP & CUSTOM DETECTION =========================

detect_custom_additions() {
  local project_file="$1"
  local existing_file="$2"
  local display_name="$3"

  if [ ! -f "$existing_file" ]; then
    return
  fi

  # Find lines in existing file that don't exist in our project file.
  # These are potential custom additions made outside this project.
  local custom_lines
  custom_lines=$(grep -Fxvf "$project_file" "$existing_file" \
    | grep -v '^[[:space:]]*$' \
    || true)

  if [ -z "$custom_lines" ]; then
    return
  fi

  local line_count
  line_count=$(echo "$custom_lines" | wc -l | tr -d ' ')

  echo ""
  warn "════════════════════════════════════════════════════════════════"
  warn " $line_count line(s) in existing $display_name NOT in this project"
  warn "════════════════════════════════════════════════════════════════"
  echo ""
  info "These may be custom additions from other programs or manual edits:"
  echo ""
  echo "$custom_lines" | head -50 | while IFS= read -r line; do
    printf "  ${DIM}│${NC} %s\n" "$line"
  done

  if [ "$line_count" -gt 50 ]; then
    info "  ... and $((line_count - 50)) more lines (see backup for full file)"
  fi

  echo ""
  info "If any of these are important (e.g., PATH additions, tool integrations),"
  info "re-add them to the new config after deployment."
  info "Your backup is at: ${BOLD}$BACKUP_DIR/$(basename "$existing_file")${NC}"
  prompt_continue
}

backup_and_deploy() {
  local src_name="$1"
  local dest="$2"
  local display_name="$3"

  local src="$SCRIPT_DIR/$src_name"

  if [ ! -f "$src" ]; then
    err "Source file not found: $src"
    return 1
  fi

  # Create destination directory
  mkdir -p "$(dirname "$dest")"

  # Backup existing file if it exists
  if [ -f "$dest" ]; then
    mkdir -p "$BACKUP_DIR"
    cp "$dest" "$BACKUP_DIR/$(basename "$dest")"
    BACKUPS_MADE=true
    info "Backed up existing $display_name"
    info "  Backup location: ${BOLD}$BACKUP_DIR/$(basename "$dest")${NC}"

    # Check for custom additions
    detect_custom_additions "$src" "$dest" "$display_name"
  else
    info "No existing $display_name found (first-time deployment)"
  fi

  # Deploy
  cp "$src" "$dest"
  success "Deployed: $display_name → $dest"
}

# ========================= MAIN =========================

main() {
  printf "\n${BOLD}${CYAN}"
  printf "╔══════════════════════════════════════════════════╗\n"
  printf "║       Terminal Setup — Deployment Script         ║\n"
  printf "║       macOS • Linux • WSL                        ║\n"
  printf "╚══════════════════════════════════════════════════╝\n"
  printf "${NC}\n"

  detect_platform
  check_prerequisites

  header "Deploying Configuration Files"

  # zshrc (macOS, Linux, WSL)
  if check_command zsh; then
    backup_and_deploy "zshrc" "$HOME/.zshrc" ".zshrc (shell config)"
  else
    warn "Skipping .zshrc (zsh not installed)"
  fi
  echo ""

  # starship.toml (all platforms)
  backup_and_deploy "starship.toml" "$HOME/.config/starship.toml" "starship.toml (prompt config)"
  echo ""

  # wezterm.lua (skip on WSL — WezTerm runs on the Windows side)
  if $IS_WSL; then
    warn "Skipping wezterm.lua (WezTerm runs on the Windows side)"
    info "Run deploy.ps1 in PowerShell on Windows to deploy wezterm.lua"
  else
    backup_and_deploy "wezterm.lua" "$HOME/.config/wezterm/wezterm.lua" "wezterm.lua (terminal config)"
  fi

  # ===== Summary =====
  header "Deployment Complete"

  if $BACKUPS_MADE; then
    info "Backups saved to: ${BOLD}$BACKUP_DIR${NC}"
    echo ""
    ls -la "$BACKUP_DIR/" 2>/dev/null | tail -n +2
    echo ""
  fi

  success "Configuration files deployed successfully!"
  echo ""
  info "Next steps:"
  info "  1. Restart WezTerm (or open a new tab) to apply changes"
  info "  2. Verify: starship --version"
  info "  3. Verify: echo \$TERM_PROGRAM  (should print WezTerm)"

  if $IS_WSL; then
    echo ""
    info "WSL reminder: Run deploy.ps1 in PowerShell on Windows to deploy:"
    info "  - wezterm.lua       → \$HOME\\.config\\wezterm\\wezterm.lua"
    info "  - starship.toml     → \$HOME\\.config\\starship.toml"
    info "  - PowerShell profile → \$PROFILE"
  fi

  echo ""
}

main "$@"
