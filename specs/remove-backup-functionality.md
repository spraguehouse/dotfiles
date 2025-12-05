# Feature: Remove Backup Functionality from Setup Scripts

## Feature Description
Simplify the dotfiles setup process by removing the `.bak` file backup mechanism. The current setup scripts create backups of existing dotfiles in `~/dotfiles_backups/` before symlinking, which was a safety measure during early development. Now that the setup process is stable and proven, this backup functionality adds unnecessary complexity without providing meaningful value.

## User Story
As a dotfiles user
I want a simpler setup process that doesn't create backup files
So that my home directory stays cleaner and the setup scripts are easier to understand and maintain

## Problem Statement
The current setup scripts (both bash and zsh) create a `~/dotfiles_backups/` directory and move any existing dotfiles there with a `.bak` extension before creating symlinks. This was implemented as a paranoid safety measure early in development, but:

1. The dotfiles system is now stable and well-tested
2. The backup directory accumulates old files that are rarely (if ever) used
3. The backup logic adds complexity to both setup scripts
4. The uninstall script has significant code dedicated to restoring from backups
5. Users who need their original dotfiles back can simply delete the symlinks (the original files are gone anyway after setup)

## Solution Statement
Remove all backup-related functionality from the codebase:
1. Simplify the `symlink()` function in both setup scripts to directly create symlinks without backup logic
2. Update the uninstall script to remove backup-related functionality
3. Update documentation to reflect the simplified behavior
4. The setup scripts will now forcefully overwrite existing files with symlinks (using `ln -sf`)

## Relevant Files
Use these files to implement the feature:

- `scripts/setup-dotfiles.zsh` - Zsh setup script containing the `symlink()` function with backup logic (lines 84-91)
- `scripts/setup-dotfiles.bash` - Bash setup script containing the `symlink()` function with backup logic (lines 57-64)
- `scripts/uninstall-dotfiles.sh` - Uninstall script with backup restoration logic and `--keep-backups` flag
- `README.md` - Contains `--keep-backups` option in uninstall documentation
- `CLAUDE.md` - Documents the backup mechanism ("Existing dotfiles are backed up to `~/dotfiles_backups/*.bak` before symlinking")

### No New Files
This is a simplification/removal feature - no new files are needed.

## Implementation Plan

### Phase 1: Foundation
- Understand the current backup flow in both setup scripts
- Identify all references to backup functionality across the codebase

### Phase 2: Core Implementation
- Simplify the `symlink()` function in `setup-dotfiles.zsh`
- Simplify the `symlink()` function in `setup-dotfiles.bash`
- Remove backup restoration and `--keep-backups` handling from `uninstall-dotfiles.sh`

### Phase 3: Integration
- Update README.md to remove backup-related documentation
- Update CLAUDE.md to remove backup references
- Test the simplified scripts

## Step by Step Tasks

### Step 1: Simplify setup-dotfiles.zsh symlink function
- Remove the backup directory creation logic
- Remove the `mv` command that moves existing files to backup
- Keep only the `ln -sf` command which already handles overwriting
- The simplified function should be:
  ```zsh
  symlink() {
    ln -sf ~/dotfiles/$1 ~/$1;
  }
  ```

### Step 2: Simplify setup-dotfiles.bash symlink function
- Apply the same simplification as the zsh script
- The simplified function should be:
  ```bash
  symlink() {
    ln -sf ~/dotfiles/$1 ~/$1;
  }
  ```

### Step 3: Update uninstall-dotfiles.sh - Remove backup constants and flags
- Remove `BACKUPS_DIR` constant
- Remove `KEEP_BACKUPS` flag variable
- Remove `--keep-backups` from argument parsing

### Step 4: Update uninstall-dotfiles.sh - Remove backup-related functions
- Remove `get_backup_path()` function
- Remove `has_backup()` function
- Remove `detect_available_backups()` function
- Remove `restore_from_backup()` function
- Remove `remove_backups_dir()` function

### Step 5: Update uninstall-dotfiles.sh - Simplify main execution
- Remove backup detection from summary display
- Remove backup restoration calls from execute flow
- Remove `--keep-backups` from help text and examples
- Update final success message to not mention restoration

### Step 6: Update README.md
- Remove `--keep-backups` option from the options list
- Update the description to not mention "restores original shell files from backup"

### Step 7: Update CLAUDE.md (dotfiles directory)
- Remove the line about existing dotfiles being backed up
- Update recovery instructions to not reference backups

## Testing Strategy

### Unit Tests
Not applicable for shell scripts. Testing will be manual.

### Integration Tests
- Run `setup-dotfiles.zsh` with `-n` (dry-run simulation) on a system with existing dotfiles
- Verify symlinks are created without backup directory being created
- Run `uninstall-dotfiles.sh --dry-run` and verify no backup restoration is attempted
- Run `uninstall-dotfiles.sh --help` and verify `--keep-backups` is not shown

### Edge Cases
- Setup script run when `~/dotfiles_backups/` already exists from previous runs (should be ignored, not deleted)
- Uninstall script run when `~/dotfiles_backups/` exists (should be ignored, not deleted - this is now orphaned data the user can manually clean)
- Setup script run when target dotfile exists as a regular file (should be overwritten by symlink)
- Setup script run when target dotfile exists as a symlink to something else (should be overwritten)

## Acceptance Criteria
- [ ] `setup-dotfiles.zsh` creates symlinks without creating backups
- [ ] `setup-dotfiles.bash` creates symlinks without creating backups
- [ ] `uninstall-dotfiles.sh` no longer references backups in any way
- [ ] `uninstall-dotfiles.sh --help` does not show `--keep-backups` option
- [ ] README.md does not mention backups or `--keep-backups`
- [ ] CLAUDE.md does not mention the backup mechanism
- [ ] All scripts pass syntax validation

## Validation Commands
Execute every command to validate the feature works correctly with zero regressions.

- Verify zsh setup script syntax: `zsh -n scripts/setup-dotfiles.zsh`
- Verify bash setup script syntax: `bash -n scripts/setup-dotfiles.bash`
- Verify uninstall script syntax: `bash -n scripts/uninstall-dotfiles.sh`
- Verify uninstall help doesn't mention backups: `./scripts/uninstall-dotfiles.sh --help | grep -i backup && echo "FAIL: backup still mentioned" || echo "PASS: no backup references"`
- Run uninstall dry-run: `./scripts/uninstall-dotfiles.sh --dry-run`
- Verify shellcheck passes (if installed): `shellcheck scripts/uninstall-dotfiles.sh scripts/setup-dotfiles.bash || echo "shellcheck not installed or warnings found"`

## Notes
- Users who have existing `~/dotfiles_backups/` directories from previous setup runs will need to manually delete them if desired. The scripts will not touch this directory.
- The `ln -sf` command already handles the case where the target file exists - it will overwrite/replace it with the symlink. This is why the backup was never strictly necessary for the setup to succeed.
- This change makes the setup slightly more "destructive" in that it will overwrite any existing dotfiles without preserving them. Users should be aware of this if they have custom dotfiles they want to keep - they should back them up manually before running setup.
- Consider adding a note to the README warning users to manually backup any custom dotfiles before running setup.
