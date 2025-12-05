#!/bin/bash
#
# Uninstall Dotfiles Script
#
# Cleanly removes all dotfiles configuration from a machine and restores
# the original shell configuration from backups when available.
#
# Usage: ./uninstall-dotfiles.sh [OPTIONS]
#
# Options:
#   -h, --help         Show this help message
#   -f, --force        Skip confirmation prompts (for non-interactive use)
#   -n, --dry-run      Preview what would be done without making changes
#   --keep-backups     Preserve the ~/dotfiles_backups/ directory
#   --keep-repo        Preserve the ~/dotfiles/ repository
#

set -euo pipefail

# Color constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Configuration
DOTFILES_DIR="$HOME/dotfiles"
BACKUPS_DIR="$HOME/dotfiles_backups"
ZSH_COMPLETIONS_DIR="$HOME/.zsh"

# Command-line flags
FORCE=false
DRY_RUN=false
KEEP_BACKUPS=false
KEEP_REPO=false

# All dotfiles that could be symlinked (union of bash and zsh setup scripts)
DOTFILES=(
    ".profile"
    ".bash_profile"
    ".bashrc"
    ".bash_aliases"
    ".bash_prompt"
    ".zshenv"
    ".zsh_profile"
    ".zshrc"
    ".zsh_prompt"
    ".p10k.zsh"
    ".gitconfig"
    ".gitignore"
    ".gitcompletion.bash"
    ".kubecompletion.bash"
)

#
# Logging functions
#

log_info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${RESET} $1"
}

log_dry_run() {
    echo -e "${CYAN}[DRY-RUN]${RESET} Would: $1"
}

#
# Helper functions
#

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Cleanly removes all dotfiles configuration from a machine and restores
the original shell configuration from backups when available.

Options:
  -h, --help         Show this help message and exit
  -f, --force        Skip confirmation prompts (for non-interactive use)
  -n, --dry-run      Preview what would be done without making changes
  --keep-backups     Preserve the ~/dotfiles_backups/ directory
  --keep-repo        Preserve the ~/dotfiles/ repository

Examples:
  $(basename "$0")              # Interactive uninstall with prompts
  $(basename "$0") --dry-run    # Preview changes without executing
  $(basename "$0") --force      # Non-interactive uninstall (for scripts/automation)
  $(basename "$0") -f --keep-repo  # Uninstall but keep the repo for future use

EOF
}

# Check if a file is a symlink pointing to the dotfiles directory
is_dotfiles_symlink() {
    local file="$1"
    if [ -L "$file" ]; then
        local target
        target=$(readlink "$file")
        if [[ "$target" == "$DOTFILES_DIR/"* ]] || [[ "$target" == "dotfiles/"* ]] || [[ "$target" == ~/dotfiles/* ]]; then
            return 0
        fi
    fi
    return 1
}

# Get backup file path for a dotfile
get_backup_path() {
    local dotfile="$1"
    echo "${BACKUPS_DIR}/${dotfile}.bak"
}

# Check if backup exists for a dotfile
has_backup() {
    local dotfile="$1"
    local backup_path
    backup_path=$(get_backup_path "$dotfile")
    [ -f "$backup_path" ]
}

#
# Detection functions
#

detect_installed_dotfiles() {
    local installed=()
    for dotfile in "${DOTFILES[@]}"; do
        local file_path="$HOME/$dotfile"
        if is_dotfiles_symlink "$file_path"; then
            installed+=("$dotfile")
        fi
    done
    echo "${installed[@]}"
}

detect_available_backups() {
    local backups=()
    if [ -d "$BACKUPS_DIR" ]; then
        for dotfile in "${DOTFILES[@]}"; do
            if has_backup "$dotfile"; then
                backups+=("$dotfile")
            fi
        done
    fi
    echo "${backups[@]}"
}

#
# Removal and restoration functions
#

remove_symlink() {
    local dotfile="$1"
    local file_path="$HOME/$dotfile"

    if [ ! -e "$file_path" ] && [ ! -L "$file_path" ]; then
        return 0  # File doesn't exist, nothing to do
    fi

    if ! is_dotfiles_symlink "$file_path"; then
        if [ -L "$file_path" ]; then
            log_warn "Skipping $dotfile: symlink points elsewhere ($(readlink "$file_path"))"
        else
            log_warn "Skipping $dotfile: regular file, not a symlink"
        fi
        return 0
    fi

    if $DRY_RUN; then
        log_dry_run "Remove symlink $file_path"
    else
        rm "$file_path"
        log_success "Removed symlink: $dotfile"
    fi
}

restore_from_backup() {
    local dotfile="$1"
    local file_path="$HOME/$dotfile"
    local backup_path
    backup_path=$(get_backup_path "$dotfile")

    if [ ! -f "$backup_path" ]; then
        return 0  # No backup to restore
    fi

    # Don't restore if target still exists (wasn't removed or isn't our symlink)
    if [ -e "$file_path" ]; then
        log_warn "Cannot restore $dotfile: target file still exists"
        return 0
    fi

    if $DRY_RUN; then
        log_dry_run "Restore $dotfile from backup"
    else
        mv "$backup_path" "$file_path"
        log_success "Restored from backup: $dotfile"
    fi
}

remove_zsh_completions() {
    if [ -d "$ZSH_COMPLETIONS_DIR" ]; then
        if $DRY_RUN; then
            log_dry_run "Remove zsh completions directory: $ZSH_COMPLETIONS_DIR"
        else
            rm -rf "$ZSH_COMPLETIONS_DIR"
            log_success "Removed zsh completions directory"
        fi
    fi

    # Remove zsh completion cache
    local zcompdump="$HOME/.zcompdump"
    if [ -f "$zcompdump" ]; then
        if $DRY_RUN; then
            log_dry_run "Remove zsh completion cache: $zcompdump"
        else
            rm -f "$zcompdump"
            log_success "Removed zsh completion cache"
        fi
    fi

    # Remove any .zcompdump* files (there can be versioned ones)
    for zcomp in "$HOME"/.zcompdump*; do
        if [ -f "$zcomp" ]; then
            if $DRY_RUN; then
                log_dry_run "Remove: $zcomp"
            else
                rm -f "$zcomp"
                log_success "Removed: $(basename "$zcomp")"
            fi
        fi
    done
}

remove_dotfiles_repo() {
    if [ -d "$DOTFILES_DIR" ]; then
        if $DRY_RUN; then
            log_dry_run "Remove dotfiles repository: $DOTFILES_DIR"
        else
            rm -rf "$DOTFILES_DIR"
            log_success "Removed dotfiles repository"
        fi
    fi
}

remove_backups_dir() {
    if [ -d "$BACKUPS_DIR" ]; then
        if $DRY_RUN; then
            log_dry_run "Remove backups directory: $BACKUPS_DIR"
        else
            rm -rf "$BACKUPS_DIR"
            log_success "Removed backups directory"
        fi
    fi
}

#
# Main execution
#

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            --keep-backups)
                KEEP_BACKUPS=true
                shift
                ;;
            --keep-repo)
                KEEP_REPO=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

show_summary() {
    echo ""
    echo "======================================"
    echo "  Dotfiles Uninstall Summary"
    echo "======================================"
    echo ""

    # Check what's installed
    local installed
    installed=($(detect_installed_dotfiles))
    if [ ${#installed[@]} -gt 0 ]; then
        log_info "Symlinks to remove:"
        for dotfile in "${installed[@]}"; do
            echo "    - ~/$dotfile"
        done
    else
        log_info "No dotfile symlinks found"
    fi
    echo ""

    # Check what backups exist
    local backups
    backups=($(detect_available_backups))
    if [ ${#backups[@]} -gt 0 ]; then
        log_info "Files to restore from backup:"
        for dotfile in "${backups[@]}"; do
            echo "    - ~/$dotfile"
        done
    else
        log_info "No backup files found"
    fi
    echo ""

    # Additional cleanup
    log_info "Additional cleanup:"
    if [ -d "$ZSH_COMPLETIONS_DIR" ]; then
        echo "    - Remove ~/.zsh/ directory"
    fi
    if ls "$HOME"/.zcompdump* &>/dev/null 2>&1; then
        echo "    - Remove zsh completion cache"
    fi
    if [ -d "$DOTFILES_DIR" ] && ! $KEEP_REPO; then
        echo "    - Remove ~/dotfiles/ repository"
    elif $KEEP_REPO; then
        echo "    - Keep ~/dotfiles/ repository (--keep-repo)"
    fi
    if [ -d "$BACKUPS_DIR" ] && ! $KEEP_BACKUPS; then
        echo "    - Remove ~/dotfiles_backups/ directory (after restoration)"
    elif $KEEP_BACKUPS; then
        echo "    - Keep ~/dotfiles_backups/ directory (--keep-backups)"
    fi
    echo ""
}

confirm_uninstall() {
    if $FORCE; then
        return 0
    fi

    if $DRY_RUN; then
        log_info "Dry-run mode: No changes will be made"
        return 0
    fi

    echo -e "${YELLOW}This will remove your dotfiles configuration.${RESET}"
    echo -n "Are you sure you want to continue? [y/N] "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
}

execute_uninstall() {
    echo ""
    if $DRY_RUN; then
        log_info "=== Dry-run: Showing what would be done ==="
    else
        log_info "=== Starting uninstall ==="
    fi
    echo ""

    # Step 1: Remove symlinks and restore backups
    log_info "Processing dotfile symlinks..."
    for dotfile in "${DOTFILES[@]}"; do
        remove_symlink "$dotfile"
        restore_from_backup "$dotfile"
    done
    echo ""

    # Step 2: Remove zsh completions
    log_info "Cleaning up zsh completions..."
    remove_zsh_completions
    echo ""

    # Step 3: Remove dotfiles repository (unless --keep-repo)
    if ! $KEEP_REPO; then
        log_info "Removing dotfiles repository..."
        remove_dotfiles_repo
    else
        log_info "Keeping dotfiles repository (--keep-repo)"
    fi
    echo ""

    # Step 4: Remove backups directory (unless --keep-backups)
    if ! $KEEP_BACKUPS; then
        log_info "Removing backups directory..."
        remove_backups_dir
    else
        log_info "Keeping backups directory (--keep-backups)"
    fi
    echo ""

    # Summary
    if $DRY_RUN; then
        log_info "=== Dry-run complete. No changes were made. ==="
    else
        log_success "=== Uninstall complete! ==="
        echo ""
        echo "Your shell configuration has been restored to the original state."
        echo "Start a new terminal session to use the default shell configuration."
    fi
}

main() {
    parse_args "$@"

    # Check if anything is installed
    local installed
    installed=($(detect_installed_dotfiles))
    local has_dotfiles_dir=false
    local has_backups_dir=false
    [ -d "$DOTFILES_DIR" ] && has_dotfiles_dir=true
    [ -d "$BACKUPS_DIR" ] && has_backups_dir=true

    if [ ${#installed[@]} -eq 0 ] && ! $has_dotfiles_dir && ! $has_backups_dir; then
        log_info "No dotfiles installation detected. Nothing to uninstall."
        exit 0
    fi

    show_summary
    confirm_uninstall
    execute_uninstall
}

main "$@"
