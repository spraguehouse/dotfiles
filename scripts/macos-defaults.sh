#!/bin/bash
# macos-defaults.sh - idempotent macOS system preferences
# Safe to re-run at any time. All commands are idempotent.

echo "Configuring macOS defaults..."

# Finder
defaults write com.apple.finder AppleShowAllExtensions -bool true      # show all file extensions
defaults write com.apple.finder AppleShowAllFiles -bool true           # show hidden files
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"   # search current folder by default
defaults write com.apple.finder ShowPathbar -bool true                 # show path bar
defaults write com.apple.finder ShowStatusBar -bool true               # show status bar

# Dock
defaults write com.apple.dock tilesize -int 48                        # icon size 48px
defaults write com.apple.dock autohide -bool true                     # auto-hide dock
defaults write com.apple.dock autohide-delay -float 0                 # no delay on show
defaults write com.apple.dock autohide-time-modifier -float 0.3       # faster show animation
defaults write com.apple.dock mineffect -string "scale"               # scale minimize effect
defaults write com.apple.dock show-recents -bool false                 # no recent apps in dock

# Keyboard
defaults write NSGlobalDomain KeyRepeat -int 2                        # fast key repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15                # short delay before repeat
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false  # no autocorrect
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false   # no smart quotes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false    # no smart dashes
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false      # no auto-capitalize
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false  # no double-space period

# Trackpad
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true           # tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Screenshots
defaults write com.apple.screencapture location -string "$HOME/Desktop"  # save to Desktop
defaults write com.apple.screencapture type -string "png"                # png format
defaults write com.apple.screencapture disable-shadow -bool true         # no window shadow

# Security
defaults write com.apple.screensaver askForPassword -int 1               # require password after screensaver
defaults write com.apple.screensaver askForPasswordDelay -int 0          # immediately

# General
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"         # dark mode
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2          # medium sidebar icons

# Apply Finder and Dock changes
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

echo "macOS defaults configured."
