# Feature: Add `svp` Alias for Standard Version with Push

## Feature Description
Add a new shell alias `svp` that runs `standard-version` followed by `git push --follow-tags origin main`. This combines the existing `sv` and `gp` aliases into a single command for a streamlined release workflow - bump the version and push in one step.

## User Story
As a developer
I want a single command to version and push my code
So that I can release new versions with one command instead of two

## Problem Statement
The current workflow for releasing a new version requires running two separate commands: `sv` (standard-version) to bump the version and create the changelog, then `gp` (git push with tags) to push to the remote. This two-step process is repetitive and easy to forget the second step after versioning.

## Solution Statement
Add a compound alias `svp` (standard-version + push) that executes `sv; git push --follow-tags origin main`. Using `;` instead of `&&` ensures the push is attempted regardless of standard-version's exit code, though in practice `sv` should succeed before pushing. This follows the existing alias naming convention (short, memorable abbreviations built from component commands).

## Relevant Files
Use these files to implement the feature:

- `.bash_aliases` - The shared aliases file sourced by both bash and zsh. Contains the existing `sv` alias on line 82 and `gp` alias on line 43. The new `svp` alias should be added in the `# sv` section near the existing `sv` alias.

## Implementation Plan

### Phase 1: Foundation
No foundational work needed - the `.bash_aliases` infrastructure already exists. The `sv` and `gp` aliases are already defined, and this new alias simply combines their functionality.

### Phase 2: Core Implementation
Add the `svp` alias to `.bash_aliases` directly after the existing `sv` alias, keeping related functionality grouped together.

### Phase 3: Integration
The alias will automatically be available in both bash and zsh since `.bash_aliases` is sourced by both shell configurations. No additional integration work required.

## Step by Step Tasks

### Step 1: Add the alias to `.bash_aliases`
- Add the new alias `svp` directly after the existing `sv` alias (line 82)
- Use the exact command specified: `alias svp='sv; git push --follow-tags origin main'`
- This groups the two related `sv*` aliases together for better organization

### Step 2: Update live version for immediate testing
- Apply the same change to `~/dotfiles/.bash_aliases` (which is symlinked to `~/.bash_aliases`) so it can be tested immediately without re-running the setup script

### Step 3: Validate the alias works correctly
- Run the validation commands below to confirm the alias is properly defined and works in both shells

## Testing Strategy

### Unit Tests
Not applicable for shell alias configuration.

### Integration Tests
- Source the updated `.bash_aliases` and verify the `svp` alias is defined
- Verify the alias expands to the correct command string
- Test in both bash and zsh to confirm cross-shell compatibility

### Edge Cases
- standard-version not installed: The `sv` command will fail, but this is expected behavior and not the alias's responsibility to handle
- Not in a git repository: The git push will fail gracefully with a git error message
- No remote named 'origin': Git push will fail with an appropriate error message
- Branch is not 'main': Git push will fail if the current branch doesn't match; this is intentional for this workflow

## Acceptance Criteria
- [ ] The alias `svp` is defined in `.bash_aliases`
- [ ] Running `svp` executes `sv; git push --follow-tags origin main`
- [ ] The alias works in both bash and zsh shells
- [ ] The alias follows existing naming conventions and is placed near the related `sv` alias

## Validation Commands
Execute every command to validate the feature works correctly with zero regressions.

- Verify alias is syntactically correct in bash: `bash -c "source /Users/Shared/source/spraguehouse/dotfiles/.bash_aliases && type svp"`
- Verify alias expands correctly in bash: `bash -c "source /Users/Shared/source/spraguehouse/dotfiles/.bash_aliases && alias svp"`
- Verify alias is syntactically correct in zsh: `zsh -c "source /Users/Shared/source/spraguehouse/dotfiles/.bash_aliases && type svp"`
- Verify alias expands correctly in zsh: `zsh -c "source /Users/Shared/source/spraguehouse/dotfiles/.bash_aliases && alias svp"`
- Verify all existing aliases still work: `bash -c "source /Users/Shared/source/spraguehouse/dotfiles/.bash_aliases && alias sv && alias gp"`

## Notes
- The alias name `svp` follows the pattern of the existing `sv` alias with `p` for "push", making it intuitive and memorable
- Using `;` instead of `&&` means the push will be attempted even if standard-version exits with a non-zero code; this could be changed to `&&` if strict error handling is preferred
- The explicit `git push --follow-tags origin main` is used rather than referencing `$gp` or the `gp` alias to ensure the alias is self-contained and doesn't depend on other aliases being defined
