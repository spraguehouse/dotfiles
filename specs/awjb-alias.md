# Feature: Add `awjb` Alias for JetBrains Rider Window Arrangement

## Feature Description
Add a new shell alias `awjb` that calls the `arrange-windows` command with `"JetBrains Rider"` as a preset argument. This provides a quick shortcut for arranging JetBrains Rider windows without needing to type the full application name each time.

## User Story
As a developer
I want a short alias to arrange my JetBrains Rider windows
So that I can quickly organize my IDE windows without typing the full command

## Problem Statement
The user frequently needs to arrange JetBrains Rider windows using the `arrange-windows` command. Currently, this requires typing `arrange-windows "JetBrains Rider"` each time, which is verbose and slower than a simple alias.

## Solution Statement
Add a single-line alias `awjb` (arrange windows JetBrains) to the `.bash_aliases` file that expands to `arrange-windows "JetBrains Rider"`. This follows the existing alias naming conventions in the repository (short, memorable abbreviations) and uses the shared `.bash_aliases` file which works in both bash and zsh environments.

## Relevant Files
Use these files to implement the feature:

- `.bash_aliases` - The shared aliases file sourced by both bash and zsh; this is where the new alias should be added. Contains existing aliases organized by prefix/category with comment headers.

## Implementation Plan

### Phase 1: Foundation
No foundational work needed - the `.bash_aliases` infrastructure already exists and works in both shells.

### Phase 2: Core Implementation
Add the `awjb` alias to `.bash_aliases` with an appropriate comment header following the existing conventions.

### Phase 3: Integration
The alias will automatically be available in both bash and zsh since `.bash_aliases` is sourced by both shell configurations.

## Step by Step Tasks

### Step 1: Add the alias to `.bash_aliases`
- Add a new comment section `# aw*` for arrange-windows aliases (following the pattern of other alias groups like `# az*`, `# cd(n)`, `# d*`, etc.)
- Add the alias: `alias awjb='arrange-windows "JetBrains Rider"'`
- Place it in alphabetical order among the alias groups (after `az*` section, before `cd` section)

### Step 2: Update live version for immediate testing
- Apply the same change to `~/dotfiles/.bash_aliases` (which is symlinked to `~/.bash_aliases`) so it can be tested immediately

### Step 3: Validate the alias works correctly
- Run the validation commands below

## Testing Strategy

### Unit Tests
Not applicable for shell alias configuration.

### Integration Tests
- Source the updated `.bash_aliases` and verify the `awjb` alias is defined
- Execute `awjb` and confirm it arranges JetBrains Rider windows correctly

### Edge Cases
- JetBrains Rider not running: `arrange-windows` should handle this gracefully (not the alias's responsibility)
- Multiple JetBrains products running: The alias specifically targets "JetBrains Rider" so only Rider windows will be affected

## Acceptance Criteria
- [ ] The alias `awjb` is defined in `.bash_aliases`
- [ ] Running `awjb` executes `arrange-windows "JetBrains Rider"`
- [ ] The alias works in both bash and zsh shells
- [ ] The alias follows existing naming conventions and file organization

## Validation Commands
Execute every command to validate the feature works correctly with zero regressions.

- Verify alias is syntactically correct: `bash -c "source /Users/Shared/source/spraguehouse/dotfiles/.bash_aliases && type awjb"`
- Verify alias expands correctly: `bash -c "source /Users/Shared/source/spraguehouse/dotfiles/.bash_aliases && alias awjb"`
- Verify zsh compatibility: `zsh -c "source /Users/Shared/source/spraguehouse/dotfiles/.bash_aliases && type awjb"`
- Run the alias (requires JetBrains Rider to be running): `awjb` (manual test)

## Notes
- The naming convention `awjb` follows the pattern of existing aliases: short prefix (`aw` for arrange-windows) + specific identifier (`jb` for JetBrains)
- If additional arrange-windows aliases are needed in the future (e.g., for Visual Studio Code, Safari, etc.), they can be added under the same `# aw*` comment section
- The `arrange-windows` command is located at `/Users/josh/.local/bin/arrange-windows` and is a native macOS binary that uses the Accessibility API
