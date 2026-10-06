# Gruvbar

**A Gruvbox-inspired Waybar configuration for Linux.**

A warm, minimal status bar built around the Gruvbox color palette. Designed for a clean Hyprland desktop with a focus on readable modules, consistent colors, and a distraction-free workflow.

## Features

* Gruvbox-inspired colors
* Custom Waybar styling with CSS
* Modular configuration
* Managed with GNU Stow
* Easy to install and customize

## Preview

*Add a screenshot of your desktop here.*

## Requirements

* Linux
* Waybar
* GNU Stow
* A compatible Wayland compositor

## Installation

Clone the repository:

```bash
git clone https://github.com/hyprwizrd/waybar-gruvbox.git
cd waybar-gruvbox
```

Back up any existing Waybar configuration, then remove or move it out of `~/.config/waybar` before stowing.

Create the symlink:

```bash
stow waybar
```

Restart Waybar to apply the configuration.

## Customization

Edit the configuration and stylesheet under `waybar/.config/waybar/`.

## License

Choose a license if you want others to reuse and redistribute your configuration.

