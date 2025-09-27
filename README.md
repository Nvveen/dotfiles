# Neal's Dotfiles

A comprehensive dotfiles setup with automatic environment detection and configuration management using GNU Stow.

## ⚡ Quick Install

Get started instantly with one command:

```bash
curl -fsSL https://tinyurl.com/nealdotfiles | bash
```

## 🎯 Features

- **Multi-Environment Support**: Automatically detects and configures for:
  - 🏠 Local development environments
  - 🐳 GitHub Codespaces
  - 🔧 Omarchy Linux setups
- **Smart Configuration Management**: Uses GNU Stow for clean symlink management
- **Automatic Backups**: Creates timestamped backups of existing configurations
- **Update Checking**: Automatically checks for and applies updates from GitHub
- **Safe Uninstall**: Complete removal with backup restoration options
- **Command-Specific Options**: Enforced argument validation for different operations

## 📦 What's Included

### Shell Configuration
- **Zsh** with Oh My Zsh framework
- **Starship** prompt with custom configuration
- Custom aliases and shell functions
- Syntax highlighting and autosuggestions

### Development Tools
- **Neovim** configuration with custom plugins
- **Git** configuration and aliases
- **Hyprland** window manager settings (Linux)

## 🚀 Installation

### Method 1: One-liner (Recommended)
```bash
curl -fsSL https://tinyurl.com/nealdotfiles | bash
```

### Method 2: Manual Clone
```bash
git clone --recurse-submodules https://github.com/Nvveen/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh install
```

## 📖 Usage

### Basic Commands

```bash
# Full installation (OS setup + configurations)
./setup.sh install

# Install only configuration files (skip OS-specific setup)
./setup.sh install --only-configs

# Install with verbose output
./setup.sh --verbose install

# Install for specific environment
./setup.sh install --env omarchy

# Skip update checking
./setup.sh --no-update install
```

### Uninstall

```bash
# Uninstall with automatic backup restoration
./setup.sh uninstall

# Uninstall and restore specific backup
./setup.sh uninstall --restore 2023-10-15T14:30:22

# List available backups
./setup.sh list-backups
```

### Available Options

#### Global Options
- `-h, --help` - Show help message
- `-v, --verbose` - Enable verbose output
- `--no-update` - Skip checking for updates from GitHub

#### Install Options
- `--only-configs` - Install only configuration files
- `--env <ENV>` - Override environment detection (omarchy, local, codespace)

#### Uninstall Options
- `--restore <DATE>` - Restore specific backup during uninstall

## 🏗️ Environment-Specific Setup

### Local Environment
- Basic shell configuration
- Development tool setup

### GitHub Codespaces
- Optimized for containerized development
- Automatic Oh My Zsh installation
- Lightweight configuration

### Omarchy Linux
- Full system package management
- Theme configuration
- Window manager setup
- Package installation/removal

## 🔧 Configuration Structure

```
configs/
├── .config/
│   ├── hypr/           # Hyprland window manager
│   ├── nvim/           # Neovim configuration
│   └── starship.toml   # Starship prompt
├── .oh-my-zsh/
│   └── custom/         # Custom Oh My Zsh plugins
├── .vimrc              # Vim configuration
├── .zprofile           # Zsh profile
└── .zshrc              # Zsh configuration
```

## 💾 Backup System

The setup automatically creates timestamped backups in `.backups/` before making changes:

```
.backups/
├── 2025-09-27T14:30:22/    # Backup from install
├── 2025-09-27T15:45:10/    # Backup from update
└── ...
```

Use `./setup.sh list-backups` to see all available backups.

## 🔄 Updates

The setup script automatically checks for updates from GitHub before each run. You can:

- **Skip update checking**: Use `--no-update` flag
- **Manual update**: Simply run any command; updates are applied automatically
- **View changes**: Check commit history on GitHub

## 🛠️ Customization

1. **Fork the repository** to your GitHub account
2. **Modify configurations** in the `configs/` directory
3. **Update the curl URL** to point to your fork
4. **Customize environment detection** in `detect_environment()`

## 📝 Examples

```bash
# First-time setup
curl -fsSL https://tinyurl.com/nealdotfiles | bash

# Update existing installation
./setup.sh install

# Install only configs (skip system packages)
./setup.sh install --only-configs

# Uninstall everything
./setup.sh uninstall

# Restore from specific backup
./setup.sh uninstall --restore 2025-09-27T14:30:22

# List all backups
./setup.sh list-backups

# Force specific environment
./setup.sh install --env local
```

## 🐛 Troubleshooting

### Common Issues

**Update loops**: If you see infinite update loops, you may have local uncommitted changes. Either commit them or use `--no-update`.

**Permission errors**: Ensure you have write access to your home directory and the ability to install packages (if doing full install).

**Stow conflicts**: Existing dotfiles may conflict. The script will backup originals, but you may need to resolve conflicts manually.

### Getting Help

```bash
./setup.sh --help
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is open source. Feel free to use, modify, and distribute as needed.

---

*Made with ❤️ for consistent development environments across all platforms.*