# macOS runs path_helper from /etc/zprofile after ~/.zshenv, which pushes the
# system directories ahead of ours. Apply ours again for login shells.
source ~/.zshenv
