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
- **Command-Specific Options**: Enforced argument validation for different operations

## 📦 What's Included

### Shell Configuration
- **Zsh** with Oh My Zsh framework
- **Starship** prompt with custom configuration
- Custom aliases and shell functions
- Syntax highlighting and autosuggestions

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
```

### Available Options

#### Global Options
- `-h, --help` - Show help message
- `-v, --verbose` - Enable verbose output

#### Install Options
- `--only-configs` - Install only configuration files
- `--env <ENV>` - Override environment detection (omarchy, local, codespace)

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

# Force specific environment
./setup.sh install --env local
```

## 🐛 Troubleshooting

### Common Issues

**Permission errors**: Ensure you have write access to your home directory and the ability to install packages (if doing full install).

**Stow conflicts**: Existing dotfiles may conflict. The script will remove conflicting files, so make sure to backup any important configurations manually if needed.

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