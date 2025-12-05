# dotfiles
All my dotfiles and environment sync/setup scripts.

## Setup

```shell
# Bash
cd ~ && curl -L https://raw.githubusercontent.com/spraguehouse/dotfiles/main/scripts/setup-dotfiles.bash -o setup-dotfiles.bash && source setup-dotfiles.bash

# Zsh
cd ~ && curl -L https://raw.githubusercontent.com/spraguehouse/dotfiles/main/scripts/setup-dotfiles.zsh -o setup-dotfiles.zsh && source setup-dotfiles.zsh
```

## Uninstall

Removes all dotfiles configuration and restores original shell files from backup.

```shell
# Interactive uninstall (with confirmation prompts)
~/dotfiles/scripts/uninstall-dotfiles.sh

# Preview what would be removed (no changes made)
~/dotfiles/scripts/uninstall-dotfiles.sh --dry-run

# Non-interactive uninstall (for scripts/automation)
~/dotfiles/scripts/uninstall-dotfiles.sh --force

# Uninstall but keep the repository for future use
~/dotfiles/scripts/uninstall-dotfiles.sh --force --keep-repo
```

Options:
- `-h, --help` - Show help message
- `-f, --force` - Skip confirmation prompts
- `-n, --dry-run` - Preview changes without executing
- `--keep-backups` - Preserve `~/dotfiles_backups/` directory
- `--keep-repo` - Preserve `~/dotfiles/` repository
