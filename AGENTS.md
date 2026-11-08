# dotfiles

Shell, git, and macOS setup for every machine. This repository is public:
secrets and company endpoints never land here. They go in
`~/.config/shell/secrets.env`, and a profile's `secrets.example` lists the key
names.

## Layout

- Root dotfiles are the shared core, symlinked into `~` by
  `scripts/setup-dotfiles.zsh` (macOS) and `scripts/setup-dotfiles.bash` (Linux).
- `profiles/<name>/` holds only what differs per machine. `README.md` lists the
  files a profile can carry. Anything both machines need goes in the core.
- `scripts/link-profile.sh` picks and links the profile for both installers.

## Applying a change

Root files are symlinked, so an edit takes effect in the next shell. A new
linked file or a new installer step means re-running setup:
`source ~/dotfiles/scripts/setup-dotfiles.zsh` keeps the linked profile.
Check a shell change with `zsh -ilc 'echo ok'` and `zsh -c 'echo ok'`; both must
print only `ok`.

## Delivery

Commit and push to `main`. There is no pipeline or versioning.
