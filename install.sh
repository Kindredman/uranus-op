#!/bin/bash

# Uranus-OP Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/Kindredman/uranus-op/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Node.js is installed
    if ! command_exists node; then
        print_error "Node.js is not installed. Please install Node.js 20 or higher."
        print_status "You can install Node.js from: https://nodejs.org/"
        exit 1
    fi
    
    # Check Node.js version
    NODE_VERSION=$(node --version | cut -d'v' -f2)
    MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1)
    
    if [ "$MAJOR_VERSION" -lt 20 ]; then
        print_error "Node.js version $NODE_VERSION is too old. Please install Node.js 20 or higher."
        exit 1
    fi
    
    print_success "Node.js version $NODE_VERSION is compatible"
    
    # Check if npm is installed
    if ! command_exists npm; then
        print_error "npm is not installed. Please install npm."
        exit 1
    fi
    
    print_success "npm is available"
    
    # Check if git is installed
    if ! command_exists git; then
        print_error "git is not installed. Please install git."
        exit 1
    fi
    
    print_success "git is available"
}

# Function to clone repository
clone_repository() {
    print_status "Cloning uranus-op repository..."
    
    # Set repository URL and directory
    REPO_URL="https://github.com/Kindredman/uranus-op.git"
    INSTALL_DIR="$HOME/.uranus-op"
    
    # Remove existing directory if it exists
    if [ -d "$INSTALL_DIR" ]; then
        print_status "Removing existing installation directory..."
        rm -rf "$INSTALL_DIR"
    fi
    
    # Clone the repository
    if git clone "$REPO_URL" "$INSTALL_DIR"; then
        print_success "Repository cloned successfully"
    else
        print_error "Failed to clone repository"
        exit 1
    fi
    
    cd "$INSTALL_DIR"
}

# Function to install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    
    if npm install; then
        print_success "Dependencies installed successfully"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
}

# Function to build the project
build_project() {
    print_status "Building the project..."
    
    if npm run build; then
        print_success "Project built successfully"
    else
        print_error "Failed to build project"
        exit 1
    fi
}

# Function to bundle the project
bundle_project() {
    print_status "Bundling the project..."
    
    if npm run bundle; then
        print_success "Project bundled successfully"
    else
        print_error "Failed to bundle project"
        exit 1
    fi
}

# Function to install globally
install_globally() {
    print_status "Installing uranus-op globally..."
    
    # Check if we need sudo
    if command_exists sudo && [ "$EUID" -ne 0 ]; then
        print_warning "Installing globally requires sudo privileges"
        if sudo npm install -g .; then
            print_success "uranus-op installed globally"
        else
            print_error "Failed to install globally with sudo"
            exit 1
        fi
    else
        if npm install -g .; then
            print_success "uranus-op installed globally"
        else
            print_error "Failed to install globally"
            print_warning "You might need to run this script with sudo privileges"
            exit 1
        fi
    fi
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    # Check if uranus command is available
    if command_exists uranus; then
        VERSION=$(uranus --version 2>/dev/null || echo "unknown")
        print_success "uranus-op is installed and available (version: $VERSION)"
        print_success "You can now run 'uranus' to start using the tool"
    else
        print_warning "uranus command not found in PATH"
        print_status "You may need to restart your terminal or add npm global bin to your PATH"
        print_status "Try running: export PATH=\$PATH:\$(npm config get prefix)/bin"
    fi
}

# Function to cleanup (no-op since we keep the installation directory)
cleanup() {
    print_status "Installation directory preserved at $INSTALL_DIR"
    print_status "You can update uranus-op by running: cd $INSTALL_DIR && git pull && npm run build && npm install -g ."
}

# Main installation process
main() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                   Uranus-OP Installation                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Run installation steps
    check_prerequisites
    clone_repository
    install_dependencies
    build_project
    bundle_project
    install_globally
    verify_installation
    cleanup
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 Installation Complete!                      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    print_success "uranus-op has been successfully installed!"
    echo ""
    print_status "Next steps:"
    echo "  1. Run 'uranus --version' to verify the installation"
    echo "  2. Run 'uranus' to start using the tool"
    echo "  3. Check the README at https://github.com/Kindredman/uranus-op for usage instructions"
    echo "  4. Source code is preserved at: $HOME/.uranus-op"
    echo "  5. To update: cd $HOME/.uranus-op && git pull && npm run build && npm install -g ."
    echo ""
}

# Handle script interruption
trap cleanup INT TERM

# Run main function
main "$@"