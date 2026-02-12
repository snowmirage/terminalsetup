# Version: v1.0
# Date: 2026-02-12
# ==========================================================================
# ~/.zshrc — Cross-platform friendly (macOS + Linux)
# Shell environment: colors, history, completion, SSH, WezTerm integration
# ==========================================================================

# --------------------------------------------------------------------------
# COLORS EVERYWHERE
# --------------------------------------------------------------------------
export CLICOLOR=1                          # macOS: color ls output
export LSCOLORS="GxFxCxDxBxegedabagaced"   # macOS ls color scheme
export LS_COLORS="di=1;36:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=34;43"

# Colorize common tools
# macOS ships BSD ls which uses -G for color; GNU ls uses --color=auto
if ls --color=auto / &>/dev/null; then
  alias ls='ls --color=auto'    # GNU ls (Linux, or brew install coreutils)
else
  alias ls='ls -G'              # BSD ls (macOS default)
fi
alias ll='ls -lah'
alias la='ls -la'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto 2>/dev/null || ip'

# --------------------------------------------------------------------------
# HISTORY
# --------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS       # no duplicate entries
setopt HIST_IGNORE_ALL_DUPS   # remove older dups
setopt HIST_FIND_NO_DUPS      # no dups in search
setopt HIST_REDUCE_BLANKS     # trim blanks
setopt SHARE_HISTORY          # share across sessions
setopt APPEND_HISTORY         # append, don't overwrite

# --------------------------------------------------------------------------
# COMPLETION
# --------------------------------------------------------------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"   # colored completions
zstyle ':completion:*' menu select                         # menu selection

# --------------------------------------------------------------------------
# KEY BINDINGS
# --------------------------------------------------------------------------
bindkey -e                           # emacs mode
bindkey '^[[A' history-search-backward   # Up arrow searches history
bindkey '^[[B' history-search-forward    # Down arrow searches history

# --------------------------------------------------------------------------
# SSH AGENT (auto-start)
# --------------------------------------------------------------------------
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null 2>&1
fi

# --------------------------------------------------------------------------
# PATH ADDITIONS
# --------------------------------------------------------------------------
# Homebrew (macOS)
if [ -d "/opt/homebrew/bin" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Local binaries
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# macOS: user-installed Python packages (pip install --user)
if [ -d "$HOME/Library/Python" ]; then
  for pydir in "$HOME"/Library/Python/*/bin; do
    [ -d "$pydir" ] && export PATH="$pydir:$PATH"
  done
fi

# --------------------------------------------------------------------------
# STARSHIP PROMPT (install: brew install starship)
# --------------------------------------------------------------------------
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# --------------------------------------------------------------------------
# ZSH SYNTAX HIGHLIGHTING & AUTOSUGGESTIONS (if installed)
# --------------------------------------------------------------------------
# Install: brew install zsh-syntax-highlighting zsh-autosuggestions
if [ -f "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
if [ -f "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Linux paths for the same plugins
if [ -f "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
if [ -f "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# --------------------------------------------------------------------------
# WEZTERM SHELL INTEGRATION
# --------------------------------------------------------------------------
if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
  # Enable OSC 7 — tells WezTerm the current directory (for tab titles, status bar)
  __wezterm_osc7() {
    printf "\033]7;file://%s%s\033\\" "${HOSTNAME}" "${PWD}"
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook chpwd __wezterm_osc7
  __wezterm_osc7  # fire once at startup

  # Enable OSC 133 — marks prompt/command/output boundaries (semantic zones)
  # This is what makes triple-click select ONLY a single command's output,
  # just like Warp's "blocks" feature.
  #
  # Zone markers:
  #   A = start of prompt
  #   B = end of prompt (start of user input)
  #   C = start of command output
  #   D = end of command output (with exit code)

  __wezterm_semantic_precmd() {
    # Mark: end of previous command output (D) + start of new prompt (A)
    printf "\033]133;D;%s\007" "$?"
    printf "\033]133;A\007"
  }

  __wezterm_semantic_preexec() {
    # Mark: end of prompt / start of command output (C)
    printf "\033]133;C\007"
  }

  add-zsh-hook precmd __wezterm_semantic_precmd
  add-zsh-hook preexec __wezterm_semantic_preexec

  # Mark the very first prompt (B = end of prompt, user can type)
  # Starship handles the B marker automatically if shell integration is detected,
  # but we add a fallback just in case
  if ! command -v starship &> /dev/null; then
    PROMPT="${PROMPT}%{\033]133;B\007%}"
  fi
fi
