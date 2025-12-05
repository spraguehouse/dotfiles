# Feature: Uninstall Dotfiles Script

## Feature Description
Create a shell script that cleanly removes all dotfiles configuration from a machine and restores it to a base operational state. This script will be particularly useful for headless Kubernetes nodes and virtual machines where the dotfiles were installed but are now causing issues with programmatic and interactive shell sessions (SSH automation, kubectl exec, etc.).

## User Story
As a system administrator
I want to cleanly uninstall my dotfiles from remote servers
So that programmatic shells and SSH sessions work without interference from custom shell configurations

## Problem Statement
The user has been installing their personal dotfiles on Kubernetes cluster nodes and headless VMs because they prefer the custom prompt when working interactively. However, these dotfiles are causing issues with:
- Programmatic shell sessions (scripts, automation)
- Interactive SSH sessions used by other tools
- kubectl exec and similar remote shell operations
- Any shell session that expects a clean, default environment

The dotfiles installation creates symlinks and backups, but there's no corresponding uninstall mechanism to reverse this process and restore the original shell configuration.

## Solution Statement
Create an `uninstall-dotfiles.sh` script that:
1. Works in both bash and zsh environments (unified script)
2. Removes all symlinks created by the setup scripts
3. Restores original files from the `~/dotfiles_backups/` directory if available
4. Removes the `~/dotfiles/` repository clone
5. Cleans up any downloaded completion files
6. Optionally cleans up the backup directory
7. Provides clear output about what was removed/restored
8. Handles edge cases gracefully (missing files, broken symlinks, etc.)

## Relevant Files
Use these files to implement the feature:

- `scripts/setup-dotfiles.bash` - The bash installation script; defines which files get symlinked for bash environments
- `scripts/setup-dotfiles.zsh` - The zsh installation script; defines which files get symlinked for zsh environments and downloads additional completion files
- `CLAUDE.md` - Documents the dotfiles architecture and symlink deployment mechanism
- `README.md` - Documents the setup process; should be updated to include uninstall instructions

### Files Created by Installation Scripts

**Bash setup creates symlinks for:**
- `~/.profile`
- `~/.bash_profile`
- `~/.bashrc`
- `~/.bash_aliases`
- `~/.bash_prompt`
- `~/.gitconfig`
- `~/.gitignore`
- `~/.gitcompletion.bash`
- `~/.kubecompletion.bash`

**Zsh setup creates symlinks for:**
- `~/.profile`
- `~/.zshenv`
- `~/.zsh_profile`
- `~/.zshrc`
- `~/.bash_aliases`
- `~/.zsh_prompt`
- `~/.p10k.zsh`
- `~/.gitconfig`
- `~/.gitignore`

**Zsh setup also creates:**
- `~/.zsh/` directory with git completions
- `~/.zcompdump` (completion cache, removed on install)

**Both scripts create:**
- `~/dotfiles/` - Git clone of the repository
- `~/dotfiles_backups/` - Backups of original files (with `.bak` extension)

### New Files
- `scripts/uninstall-dotfiles.sh` - The new uninstall script (unified for both bash/zsh)

## Implementation Plan

### Phase 1: Foundation
- Create the base script structure with proper shebang and shell compatibility
- Implement utility functions for colored output and logging
- Implement detection of which environment (bash/zsh/both) was installed
- Add safety checks for non-interactive vs interactive execution

### Phase 2: Core Implementation
- Implement symlink detection and removal logic
- Implement backup restoration logic (restore from `~/dotfiles_backups/*.bak`)
- Implement cleanup of downloaded files (`~/.zsh/` directory, completion files)
- Implement removal of `~/dotfiles/` repository
- Add confirmation prompts for destructive operations
- Implement `--force` flag for non-interactive use

### Phase 3: Integration
- Update README.md with uninstall instructions
- Test the script on different scenarios (full install, partial install, missing backups)

## Step by Step Tasks

### Step 1: Create the base script structure
- Create `scripts/uninstall-dotfiles.sh` with `#!/bin/bash` shebang (portable)
- Add header comments explaining the script purpose
- Implement color constants for output formatting
- Implement helper functions: `log_info`, `log_warn`, `log_error`, `log_success`

### Step 2: Implement environment detection
- Create function to detect if running in bash or zsh
- Create function to check what dotfiles are currently installed (symlinks present)
- Create function to check what backups exist in `~/dotfiles_backups/`

### Step 3: Implement symlink removal logic
- Create array of all possible dotfile symlinks (union of bash and zsh)
- Implement function to check if file is a symlink pointing to `~/dotfiles/`
- Implement function to remove a single symlink safely

### Step 4: Implement backup restoration logic
- Implement function to restore a single file from backup
- Handle case where backup doesn't exist (leave file removed)
- Handle case where backup exists but target isn't a symlink (skip with warning)

### Step 5: Implement additional cleanup
- Remove `~/.zsh/` directory (git completions)
- Remove `~/.zcompdump` (zsh completion cache)
- Optionally remove `~/dotfiles/` repository
- Optionally remove `~/dotfiles_backups/` directory

### Step 6: Implement command-line argument parsing
- Add `--help` flag to show usage
- Add `--force` or `-f` flag to skip confirmation prompts
- Add `--keep-backups` flag to preserve backup directory
- Add `--keep-repo` flag to preserve the dotfiles repository
- Add `--dry-run` flag to preview what would be done without making changes

### Step 7: Implement main execution flow
- Parse command-line arguments
- Show summary of what will be removed/restored
- Prompt for confirmation (unless `--force` is used)
- Execute removal and restoration
- Print summary of actions taken

### Step 8: Update documentation
- Update README.md to include uninstall instructions
- Add inline comments in the script for maintainability

### Step 9: Test the script
- Run with `--dry-run` to verify detection logic
- Test on a system with dotfiles installed
- Verify original files are properly restored from backup

## Testing Strategy

### Unit Tests
Not applicable for a shell script of this nature. Testing will be manual/integration.

### Integration Tests
- Test on a fresh VM with bash setup installed, verify clean removal
- Test on a fresh VM with zsh setup installed, verify clean removal
- Test with `--dry-run` flag to verify no changes are made
- Test with `--force` flag for non-interactive execution
- Test restoration when backups exist vs when they don't

### Edge Cases
- Symlink exists but points somewhere other than `~/dotfiles/` - should skip with warning
- File exists but is not a symlink - should skip with warning
- Backup file doesn't exist - should remove symlink but not create empty file
- `~/dotfiles/` directory doesn't exist - should continue gracefully
- Script run on a machine that never had dotfiles installed - should exit cleanly
- Script run via SSH where shell might restart unexpectedly
- Running as root vs regular user

## Acceptance Criteria
- [ ] Script removes all dotfile symlinks created by setup scripts
- [ ] Script restores original files from backups when available
- [ ] Script works in both bash and zsh environments
- [ ] Script provides clear output about each action taken
- [ ] Script supports `--dry-run` to preview changes
- [ ] Script supports `--force` for non-interactive execution
- [ ] Script handles edge cases gracefully without crashing
- [ ] Script can be run multiple times without errors (idempotent)
- [ ] README.md updated with uninstall instructions

## Validation Commands
Execute every command to validate the feature works correctly with zero regressions.

- Verify script syntax: `bash -n scripts/uninstall-dotfiles.sh`
- Verify script is executable: `ls -la scripts/uninstall-dotfiles.sh | grep -E '^-rwxr'`
- Run with help flag: `./scripts/uninstall-dotfiles.sh --help`
- Run with dry-run flag on current system: `./scripts/uninstall-dotfiles.sh --dry-run`
- Verify shellcheck passes (if installed): `shellcheck scripts/uninstall-dotfiles.sh || echo "shellcheck not installed, skipping"`

## Notes
- The script uses bash as the shebang for maximum portability since it needs to work on servers that may only have bash, but the logic handles cleaning up both bash and zsh configurations
- Git configuration (`~/.gitconfig`, `~/.gitignore`) is shared between bash and zsh setups, so it only needs to be removed once
- The Powerlevel10k cache file (`~/.cache/p10k-instant-prompt-*.zsh`) could be cleaned up but is user-specific and regenerates automatically - not critical to remove
- The script should NOT uninstall software packages (like those installed via `brew install` in the zsh setup) as those may be needed for other purposes and their removal could be destructive
- Consider adding a `--restore-shell` option that could optionally reset the user's default shell back to `/bin/bash` if it was changed, but this is out of scope for initial implementation
