#!/bin/bash

# Tynan's Dotfiles Installation Script
# This script installs tmux, neovim, and sets up configuration files

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS and distribution
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$ID
        else
            OS="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
    log_info "Detected OS: $OS"
}

# Install packages based on OS
install_packages() {
    log_info "Installing required packages..."

    case "$OS" in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y tmux neovim curl
            ;;
        fedora|rhel|centos)
            sudo dnf install -y tmux neovim curl
            ;;
        arch|manjaro)
            sudo pacman -Sy --noconfirm tmux neovim curl
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                log_warn "Homebrew not found. Please install it from https://brew.sh/"
                log_warn "Skipping package installation..."
                return
            fi
            brew install tmux neovim curl
            ;;
        *)
            log_warn "Unknown OS. Please install tmux and neovim manually."
            return
            ;;
    esac

    log_info "Packages installed successfully!"
}

# Check if packages are already installed
check_dependencies() {
    local missing=()

    if ! command -v tmux &> /dev/null; then
        missing+=("tmux")
    fi

    if ! command -v nvim &> /dev/null; then
        missing+=("neovim")
    fi

    if [ ${#missing[@]} -eq 0 ]; then
        log_info "All dependencies are already installed."
        return 0
    else
        log_warn "Missing dependencies: ${missing[*]}"
        return 1
    fi
}

# Install configuration files
install_configs() {
    log_info "Installing configuration files..."

    # GitHub raw content base URL
    GITHUB_RAW_URL="https://raw.githubusercontent.com/TynanWilke/bash_configs/main"

    # Determine if running locally or via curl
    if [ -d "$(dirname "$0")" ] && [ -f "$(dirname "$0")/bash/.bashrc.tynan" ]; then
        # Running locally
        SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
        USE_LOCAL=true
    else
        # Running via curl
        USE_LOCAL=false
    fi

    # Backup existing configs
    backup_dir="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    [ -f "$HOME/.bashrc.tynan" ] && cp "$HOME/.bashrc.tynan" "$backup_dir/"
    [ -f "$HOME/.tmux.conf" ] && cp "$HOME/.tmux.conf" "$backup_dir/"
    [ -f "$HOME/.config/nvim/init.lua" ] && cp "$HOME/.config/nvim/init.lua" "$backup_dir/"

    if [ "$(ls -A $backup_dir)" ]; then
        log_info "Existing configs backed up to: $backup_dir"
    else
        rmdir "$backup_dir"
    fi

    # Install .bashrc.tynan
    log_info "Installing .bashrc.tynan..."
    if [ "$USE_LOCAL" = true ]; then
        cp "$SCRIPT_DIR/bash/.bashrc.tynan" "$HOME/.bashrc.tynan"
    else
        curl -fsSL "$GITHUB_RAW_URL/bash/.bashrc.tynan" -o "$HOME/.bashrc.tynan" || {
            log_error "Failed to download .bashrc.tynan"
            exit 1
        }
    fi

    # Add sourcing to .bashrc if not already present
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q ".bashrc.tynan" "$HOME/.bashrc"; then
            log_info "Adding .bashrc.tynan sourcing to .bashrc..."
            echo "" >> "$HOME/.bashrc"
            echo "# Source Tynan's custom bash configuration" >> "$HOME/.bashrc"
            echo "if [ -f ~/.bashrc.tynan ]; then" >> "$HOME/.bashrc"
            echo "    . ~/.bashrc.tynan" >> "$HOME/.bashrc"
            echo "fi" >> "$HOME/.bashrc"
        else
            log_info ".bashrc already sources .bashrc.tynan"
        fi
    else
        log_warn ".bashrc not found, creating one..."
        echo "# Bash configuration" > "$HOME/.bashrc"
        echo "" >> "$HOME/.bashrc"
        echo "# Source Tynan's custom bash configuration" >> "$HOME/.bashrc"
        echo "if [ -f ~/.bashrc.tynan ]; then" >> "$HOME/.bashrc"
        echo "    . ~/.bashrc.tynan" >> "$HOME/.bashrc"
        echo "fi" >> "$HOME/.bashrc"
    fi

    # Install .tmux.conf
    log_info "Installing .tmux.conf..."
    if [ "$USE_LOCAL" = true ]; then
        cp "$SCRIPT_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    else
        curl -fsSL "$GITHUB_RAW_URL/tmux/.tmux.conf" -o "$HOME/.tmux.conf" || {
            log_error "Failed to download .tmux.conf"
            exit 1
        }
    fi

    # Install neovim config
    log_info "Installing neovim configuration..."
    mkdir -p "$HOME/.config/nvim"
    if [ "$USE_LOCAL" = true ]; then
        cp "$SCRIPT_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"
    else
        curl -fsSL "$GITHUB_RAW_URL/nvim/init.lua" -o "$HOME/.config/nvim/init.lua" || {
            log_error "Failed to download init.lua"
            exit 1
        }
    fi

    # Create neovim undo directory
    mkdir -p "$HOME/.config/nvim/undo"

    log_info "Configuration files installed successfully!"
}

# Main installation process
main() {
    log_info "Starting dotfiles installation..."
    echo ""

    detect_os
    echo ""

    if ! check_dependencies; then
        read -p "Install missing dependencies? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_packages
        else
            log_warn "Skipping package installation. Some features may not work."
        fi
        echo ""
    fi

    install_configs
    echo ""

    log_info "Installation complete!"
    log_info "Please restart your terminal or run: source ~/.bashrc"
    log_info ""
    log_info "Next steps:"
    log_info "  - For tmux: Run 'tmux' to start a session"
    log_info "  - For neovim: Run 'nvim' to start editing"
}

# Run main function
main
