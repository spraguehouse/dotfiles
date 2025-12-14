# Powerlevel10k configuration for spraguehouse dotfiles
# Preserves original prompt information: user@host, k8s context, azure subscription, directory, git

# Instant prompt mode (loaded from .zshenv)
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Prompt layout: left side elements
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  context                  # user@host
  k8s_context              # custom kubernetes context/namespace segment
  azure_subscription       # custom azure subscription segment
  dir                      # current directory
  vcs                      # git status
  newline                  # move to new line
  prompt_char              # λ character
)

# No right prompt (keep it clean like original)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

# Character set (use Unicode for better symbols)
typeset -g POWERLEVEL9K_MODE=nerdfont-complete

# Prompt colors and style
typeset -g POWERLEVEL9K_BACKGROUND=none
typeset -g POWERLEVEL9K_FOREGROUND=white

#############################################
# Context (user@host)
#############################################
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=208      # orange for regular user
typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=red # red for root
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
# Always show context (even when not in SSH)
typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_CONTENT_EXPANSION='%n@%m'
typeset -g POWERLEVEL9K_CONTEXT_VISUAL_IDENTIFIER_EXPANSION=''
# Show context in all conditions
typeset -g POWERLEVEL9K_ALWAYS_SHOW_CONTEXT=true

#############################################
# Kubernetes Context (custom segment)
#############################################
function prompt_k8s_context() {
  local ctx=$(kubectl config current-context 2>/dev/null)
  if [[ ! -z "$ctx" ]]; then
    local ns=$(kubectl config view --minify --output jsonpath={..namespace} 2>/dev/null)
    p10k segment -f 168 -t "(${ctx}/${ns})"  # 168 is pink color
  fi
}
typeset -g POWERLEVEL9K_K8S_CONTEXT_FOREGROUND=168  # pink
typeset -g POWERLEVEL9K_K8S_CONTEXT_BACKGROUND=none

#############################################
# Azure Subscription (custom segment)
#############################################
function prompt_azure_subscription() {
  local subscription=$(az account show --query 'name' -o tsv 2>/dev/null)
  if [[ ! -z "$subscription" ]]; then
    # Remove "LZ - " prefix like in original prompt
    local s="${subscription/LZ - /""}"
    p10k segment -f 73 -t "(${s})"  # 73 is cyan color
  fi
}
typeset -g POWERLEVEL9K_AZURE_SUBSCRIPTION_FOREGROUND=73  # cyan
typeset -g POWERLEVEL9K_AZURE_SUBSCRIPTION_BACKGROUND=none

#############################################
# Directory
#############################################
typeset -g POWERLEVEL9K_DIR_FOREGROUND=green
typeset -g POWERLEVEL9K_DIR_BACKGROUND=none
# Don't shorten directory - show full path like original prompt
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=green
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=green
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_PREFIX=':'
typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

#############################################
# Git / VCS
#############################################
typeset -g POWERLEVEL9K_VCS_FOREGROUND=blue
typeset -g POWERLEVEL9K_VCS_BACKGROUND=none
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=blue
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=blue
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=blue

# Git status symbols (matching original prompt)
typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='!'
typeset -g POWERLEVEL9K_VCS_STAGED_ICON='+'
typeset -g POWERLEVEL9K_VCS_STASH_ICON='$'
typeset -g POWERLEVEL9K_VCS_COMMITS_AHEAD_ICON=''
typeset -g POWERLEVEL9K_VCS_COMMITS_BEHIND_ICON=''

# Show git status
typeset -g POWERLEVEL9K_VCS_LOADING_TEXT=
typeset -g POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=0.05

#############################################
# Prompt Character (λ)
#############################################
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=blue
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=red
typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=none
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='λ'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='λ'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='λ'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='λ'

#############################################
# Transient Prompt (clean history)
#############################################
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=same-dir

#############################################
# General styling
#############################################
typeset -g POWERLEVEL9K_ICON_PADDING=none
typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=
typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=
typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_FIRST_SEGMENT_END_SYMBOL=
typeset -g POWERLEVEL9K_EMPTY_LINE_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=

# Enable instant prompt
(( ! $+functions[p10k] )) || p10k finalize
