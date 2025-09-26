FROM archlinux:latest

# Install sudo
RUN pacman -Syu --noconfirm sudo zsh starship git curl neovim otf-droid-nerd stow \
    openssh

# Create vscode user with sudo privileges
RUN useradd -m -s /bin/bash vscode && \
    usermod -aG wheel vscode && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel && \
    chsh -s /usr/bin/zsh vscode

# Fix machine-id for systemd
RUN touch /etc/machine-id

# Switch to vscode user
USER vscode

RUN touch /home/vscode/.zshrc
RUN mkdir -p /home/vscode/.ssh/

WORKDIR /workspaces/dotfiles