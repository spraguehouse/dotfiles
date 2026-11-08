# dotfiles
All my dotfiles and environment sync/setup scripts.

## Setup

Pass the machine's profile, `home` or `work`. Without one, setup keeps the
profile already linked, or asks.

```shell
# Bash
cd ~ && curl -L https://raw.githubusercontent.com/spraguehouse/dotfiles/main/scripts/setup-dotfiles.bash -o setup-dotfiles.bash && source setup-dotfiles.bash home

# Zsh
cd ~ && curl -L https://raw.githubusercontent.com/spraguehouse/dotfiles/main/scripts/setup-dotfiles.zsh -o setup-dotfiles.zsh && source setup-dotfiles.zsh work
```

## Profiles

The files at the repository root are the core every machine shares. A profile
in `profiles/<name>/` adds what differs per machine. Setup links the chosen
profile at `~/.config/dotfiles/profile`, and the core loads these files from it
when present:

| File | Loaded by | Holds |
| --- | --- | --- |
| `gitconfig` | `~/.gitconfig` (`[include]`) | Git identity and machine git settings |
| `zshenv` | `~/.zshenv` | Environment and PATH for every zsh |
| `zshrc` | `~/.zshrc` | Interactive settings |
| `secrets.example` | `scripts/link-profile.sh` | Names of the secrets the profile needs |

Secrets live in `~/.config/shell/secrets.env`, which is never committed.
`~/.zshrc` exports everything in it. To switch profiles, run
`~/dotfiles/scripts/link-profile.sh <name>`.

## Uninstall

Removes all dotfiles configuration.

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
- `--keep-repo` - Preserve `~/dotfiles/` repository
