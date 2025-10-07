# WALL3N dotfiles

My personal dotfiles configuration for macOS. This repository contains configuration files for various tools and applications I use in my development environment.

## Overview

- **Shell**: ZSH with custom configurations
- **Terminal Multiplexer**: tmux with various plugins
- **Terminal Emulator**: Ghostty
- **Text Editor**: Neovim (LazyVim configuration)
- **Prompt**: Starship

## Components

### Zsh Configuration
- Custom aliases and functions
- Environment variables
- Key bindings
- Custom initialization scripts

### Tmux Configuration
Includes several plugins for enhanced functionality:
- Catppuccin theme
- tmux-floax (floating windows)
- tmux-fzf (fuzzy finder integration)
- tmux-fzf-url (URL management)
- tmux-sensible (sensible defaults)
- tmux-sessionx (session management)
- tpm (plugin manager)

### Neovim Setup
LazyVim-based configuration with:
- Custom keymaps
- Autocommands
- Plugin configurations
- Custom options

### Ghostty
Terminal emulator configuration

### Starship
Modern, minimal and customizable prompt

## Installation

1. Clone this repository:
```bash
git clone https://github.com/wall3n/dotfiles.git ~/.dotfiles
```

2. Install stow if you haven't already:
```bash
brew install stow
```

3. From the dotfiles directory, run:
```bash
stow .
```

4. Edit your `/etc/zshenv` file to set the ZDOTDIR value:
```bash
ZDOTDIR=$HOME/.dotfiles/zsh
```

## Prerequisites

- Git
- GNU Stow
- Zsh
- tmux
- Neovim
- Ghostty
- Starship

## Notes

- The configurations use stow for managing symlinks
- The `.stowrc` file is configured to target `~/.config`
- Certain files and directories are ignored (see `.stowrc`)
