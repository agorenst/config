#!/bin/bash

# ==============================================================================
# Linux Environment Setup Script (setup.sh)
# Designed for Idempotency and Fault Tolerance.
# ==============================================================================

# --- SCRIPT SETUP AND ERROR HANDLING ---
set -e          # Exit immediately if a command exits with a non-zero status.
set -u          # Treat unset variables as an error.
set -o pipefail # Use the return value of the last command in a pipeline that failed.

# IFS=$'\n\t'  # Set internal field separator to handle file names with spaces

USER_HOME="/home/$(whoami)"

# --- LOGGING AND ERROR FUNCTIONS ---

# Function to print a success message
log_success() {
  echo -e "\n✅ SUCCESS: $1"
}

# Function to print an informational message
log_info() {
  echo -e "\n💡 INFO: $1"
}

# Add a function for critical error logging specific to directory checks
log_error_action() {
  echo -e "\n🛑 CRITICAL ACTION REQUIRED: $2" >&2
}

# Function to handle errors and exit
handle_error() {
  echo -e "\n❌ ERROR on line $1: $2" >&2 # Output error to stderr
  # Add any specific cleanup steps here if needed
  exit 1
}

# Trap errors (non-zero exit status) and call the error handler
trap 'handle_error $LINENO "$BASH_COMMAND"' ERR

# --- CORE IDEMPOTENT FUNCTIONS ---

install_packages() {
  PACKAGES=("$@")
  log_info "Starting package installation... ${PACKAGES[*]}"

  # Check for package manager
  if command -v apt >/dev/null 2>&1; then
    PACKAGE_MANAGER="apt"
    log_info "Using apt for package management (Debian/Ubuntu)."
    # Update once before installing
    sudo apt update
  else
    handle_error "$LINENO" "No supported package manager found (apt, dnf, pacman)."
  fi

  # List of packages you want installed
  for pkg in "${PACKAGES[@]}"; do
    if ! dpkg -l | grep -q "^ii.*$pkg"; then
      log_info "Installing package: $pkg"
      sudo apt install -y "$pkg"
    else
      log_info "Package $pkg is already installed. Skipping."
    fi
  done

  log_success "All packages installed."
}

setup_config() {
  CONFIG_CLONE_DIR=~/config
  CONFIG_TARGET_PATH=~/.config
  CONFIG_REPO=https://github.com/agorenst/config

  # 1. Clone or pull the 'config' repository
  if [ ! -d "$CONFIG_CLONE_DIR" ]; then
    log_info "Cloning config repo from $CONFIG_REPO into $CONFIG_CLONE_DIR"
    git clone "$CONFIG_REPO" "$CONFIG_CLONE_DIR"
  else
    log_info "Config clone directory already exists. Updating/Pulling latest changes."
    (cd "$CONFIG_CLONE_DIR" && git pull)
  fi

  # 2. Check and create the ~/.config symlink
  if [ -L "$CONFIG_TARGET_PATH" ]; then
    log_info "$CONFIG_TARGET_PATH is already a symbolic link. Assuming setup is complete. Skipping."
  elif [ -d "$CONFIG_TARGET_PATH" ]; then
    # If it's a directory, we need to check if it's empty
    if [ -z "$(ls -A "$CONFIG_TARGET_PATH" 2>/dev/null)" ]; then
      log_info "$CONFIG_TARGET_PATH exists but is empty. Deleting directory and creating symlink."
      rmdir "$CONFIG_TARGET_PATH"
      ln -s "$CONFIG_CLONE_DIR" "$CONFIG_TARGET_PATH"
    else
      # CRITICAL: Directory exists and is NOT empty. This requires user intervention or a forced backup.
      log_error_action "$LINENO" "$CONFIG_TARGET_PATH is a non-empty directory. Cannot create symlink."
      handle_error "$LINENO" "Critical: $CONFIG_TARGET_PATH is not empty. Please manually move/backup existing files."
    fi
  elif [ ! -e "$CONFIG_TARGET_PATH" ]; then
    # The path does not exist (most likely scenario on a clean install)
    log_info "$CONFIG_TARGET_PATH does not exist. Creating symlink."
    ln -s "$CONFIG_CLONE_DIR" "$CONFIG_TARGET_PATH"
  else
    # Catch any other weird file type that might be there
    handle_error "$LINENO" "$CONFIG_TARGET_PATH exists as an unexpected file type. Manual intervention required."
  fi

  log_success "$CONFIG_TARGET_PATH symlink setup complete."
}

setup_zsh_config() {
  OH_MY_ZSH_DIR="$USER_HOME/.oh-my-zsh"
  OH_MY_ZSH_INSTALL_CMD='curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh'
  PERSONAL_ZSH_CONFIG="zshrc.personal" # The filename inside your ~/.config repo
  ZSHRC_PATH="$USER_HOME/.zshrc"       # The actual file path created by OMZ
  log_info "Setting up Oh My Zsh and personal configurations..."

  # 1. Install Oh My Zsh (Idempotent Check)
  if [ ! -d "$OH_MY_ZSH_DIR" ]; then
    log_info "Installing Oh My Zsh..."

    # Run OMZ installer non-interactively. This creates the $USER_HOME/.zshrc file.
    # We rely on set -e to catch any failure here.
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    # If OMZ install succeeds, the default ~/.zshrc now exists.
    log_info "Oh My Zsh installed and created default $ZSHRC_PATH."
  else
    log_info "Oh My Zsh directory already exists ($OH_MY_ZSH_DIR). Skipping installation."
  fi

  # Check if the file exists before proceeding to modification
  if [ ! -f "$ZSHRC_PATH" ]; then
    handle_error "$LINENO" "Oh My Zsh installation failed to create the default $ZSHRC_PATH."
  fi

  # 2. Ensure personal config is sourced in the main .zshrc file
  # The line we want to add to the *end* of the OMZ-created ~/.zshrc
  SOURCE_LINE="source $USER_HOME/.config/$PERSONAL_ZSH_CONFIG"
  if ! grep -q "$SOURCE_LINE" "$ZSHRC_PATH"; then
    log_info "Appending line to $ZSHRC_PATH to source your personal configuration."
    # Append the source command to the OMZ-created zshrc file
    echo -e "\n# Sourced personal configurations from setup script\n$SOURCE_LINE" >>"$ZSHRC_PATH"
  else
    log_info "Personal config source line already present in $ZSHRC_PATH. Skipping."
  fi

  INVOCATION_LINE="tmux_attach"
  if ! grep -q "$INVOCATION_LINE" "$ZSHRC_PATH"; then
    log_info "Appending line to $ZSHRC_PATH to call tmux invocation."
    # Append the source command to the OMZ-created zshrc file
    echo -e "$INVOCATION_LINE" >>"$ZSHRC_PATH"
  else
    log_info "tmux invocation line already present in $ZSHRC_PATH. Skipping."
  fi

  log_success "Zsh and Oh My Zsh configured."
}

setup_default_shell() {
  log_info "Setting Zsh as the default shell."

  # Use 'command -v zsh' to reliably get the full path to the zsh executable
  ZSH_PATH="$(command -v zsh)"

  if [ -z "$ZSH_PATH" ]; then
    handle_error "$LINENO" "Zsh executable not found. Cannot set default shell."
  fi

  # Check the current user's default shell entry in /etc/passwd
  # getent passwd reads the system user database (reliable). cut gets the 7th field (the shell).
  CURRENT_SHELL="$(getent passwd "$(whoami)" | cut -d: -f7)"

  if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
    log_info "Changing user shell from $CURRENT_SHELL to $ZSH_PATH."
    # chsh requires sudo to update the user database.
    # The user will likely be prompted for a password here.
    sudo chsh -s "$ZSH_PATH" "$(whoami)"
    log_info "Shell change successful. You will use Zsh on your next login."
  else
    log_info "Default shell is already set to Zsh ($ZSH_PATH). Skipping."
  fi

  log_success "Default shell configuration complete."
}
setup_neovim() {
  log_info "Starting Neovim setup from source."

  local NEOVIM_REPO="https://github.com/neovim/neovim.git"
  local NEOVIM_DIR="$USER_HOME/neovim"

  if command -v nvim >/dev/null 2>&1; then
    log_info "Neovim already installed."
    return 0
  fi

  # 1. Install Dependencies
  log_info "Installing Neovim build dependencies."
  install_packages "ninja-build" "gettext" "cmake" "curl" "build-essential" "git"

  # 2. Clone Repository (Idempotent Check)
  if [ ! -d "$NEOVIM_DIR" ]; then
    log_info "Cloning Neovim repository to $NEOVIM_DIR."
    git clone "$NEOVIM_REPO" "$NEOVIM_DIR"
  else
    log_info "Neovim source directory already exists. Updating and building."
  fi

  # 3. Build and Install Process (Isolated and Fault-Tolerant Subshell)
  log_info "Starting build and installation."

  # The subshell isolates directory change (cd) and ensures set -e handles errors
  (
    # Enter the source directory and update the code
    cd "$NEOVIM_DIR"
    git pull # Update source code idempotently

    # Build commands (set -e ensures immediate exit on failure)
    log_info "Running make clean, build, and install..."
    make clean 2>/dev/null || true # Optional: clean up previous builds
    make CMAKE_BUILD_TYPE=RelWithDebInfo

    # Install to system (requires sudo)
    sudo make install -j
  ) # Subshell ends. If any command above fails, the script will exit via the ERR trap.

  # 4. Final Verification
  if command -v nvim >/dev/null 2>&1; then
    log_success "Neovim successfully built and installed."
  else
    handle_error "$LINENO" "Neovim build succeeded, but the 'nvim' command is not found in PATH."
  fi
}

setup_cudastuff() {
  local CUDA_PACKAGE="cuda-toolkit-12-6"

  # 1. Check for Final Installed Package (Idempotency Guard)
  if dpkg -l | awk '$1 == "ii" && $2 == "'"$CUDA_PACKAGE"'" {found=1} END {exit !found}'; then
    log_success "$CUDA_PACKAGE is already installed. Skipping CUDA setup."
    return 0 # Exit the function successfully
  fi
  wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
  sudo dpkg -i cuda-keyring_1.1-1_all.deb
  sudo apt-get update
  sudo apt-get -y install $CUDA_PACKAGE
}

setup_llamacpp() {
  log_info "Starting strict idempotent llama.cpp setup from source."

  local REPO_URL="https://github.com/ggerganov/llama.cpp.git"
  local REPO_DIR="llama.cpp"

  # --- 1. Idempotency Check: Exit if source directory exists ---
  if [ -d "$REPO_DIR" ]; then
    log_success "llama.cpp source directory already exists. Skipping clone and build."
    return 0
  fi

  # --- Proceed only if the source directory does not exist ---
  log_info "llama.cpp source directory not found. Beginning first-time installation."

  # 2. Install Dependencies
  log_info "Ensuring dependencies are installed."
  install_packages "libcurl4-openssl-dev"

  # 3. Clone Repository (Fault-Tolerant)
  log_info "Cloning llama.cpp repository."
  git clone "$REPO_URL" "$REPO_DIR"

  # 4. Build Process (Isolated and Fault-Tolerant Subshell)
  log_info "Starting build process for llama.cpp."

  (
    cd "$REPO_DIR"
    mkdir -p build

    log_info "Running cmake configuration and build..."
    # set -e handles errors here
    cmake -B build -DGGML_CUDA=ON
    cmake --build build --config Release -j
  )

  # 5. Final Verification
  if [ -f "$REPO_DIR/build/bin/main" ]; then
    log_success "llama.cpp successfully built."
  else
    handle_error "$LINENO" "llama.cpp build failed, executable not found."
  fi
}

setup_whispercpp() {
  log_info "Starting strict idempotent whisper.cpp setup from source."

  local REPO_URL="https://github.com/ggerganov/whisper.cpp.git"
  local REPO_DIR="whisper.cpp"

  # --- 1. Idempotency Check: Exit if source directory exists ---
  if [ -d "$REPO_DIR" ]; then
    log_success "whisper.cpp source directory already exists. Skipping clone and build."
    return 0
  fi

  # --- Proceed only if the source directory does not exist ---
  log_info "whisper.cpp source directory not found. Beginning first-time installation."

  # 2. Clone Repository (Fault-Tolerant)
  log_info "Cloning whisper.cpp repository."
  git clone "$REPO_URL" "$REPO_DIR"

  # 3. Build Process (Isolated and Fault-Tolerant Subshell)
  log_info "Starting build process for whisper.cpp."

  (
    cd "$REPO_DIR"
    mkdir -p build

    log_info "Running cmake configuration and build..."
    # set -e handles errors here
    cmake -B build -DGGML_CUDA=1
    cmake --build build --config Release -j
  )

  # 4. Final Verification
  if [ -f "$REPO_DIR/build/bin/main" ]; then
    log_success "whisper.cpp successfully built."
  else
    handle_error "$LINENO" "whisper.cpp build failed, executable not found."
  fi
}

setup_rust() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -q -y
  # Requires shell restart, think about it.
}

setup_typst() {
  cargo install --locked typst-cli
}

setup_bashlsp() { # used in neovim?
  # install npm
  # npm install -g bash-language-server
  # sudo apt install shellcheck
  # sudo apt install shfmt
}

# --- MAIN EXECUTION ---

# install_packages "git" "htop" "tmux" "zsh" "curl" "xclip" "python" "graphviz"
#
# install_packages "fzf" "python3-pylsp" # for neovim and lsp stuff
#
# setup_config
#
# setup_zsh_config
#
# setup_default_shell
#
# # TODO: early-out if we're not in ZSH at this point
#
# setup_neovim
#
# install_packages "texlive-full"
#
# install_packages "clangd" "clang" "racket" "gdb"
#
# setup_cudastuff
#
# setup_llamacpp
#
# setup_whispercpp

# Things to think about: sudo snap install bash-language-server --classic; sudo apt install shellcheck                                                                                                                                                                17.45s ✓
#setup_rust

setup_typst # requires rust, and apt install pkg-config libssl-dev
