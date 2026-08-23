#!/usr/bin/env zsh
set -euo pipefail

###############################################################################
# macOS Silicon Dev Setup Script
# - Installs Homebrew + CLI tools + GUI apps
# - Sets up Python via pyenv (multiple versions)
# - Configures global git identity
###############################################################################

###############################################################################
# 0. Helper functions
###############################################################################

log() {
  printf "\n[%s] %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$1"
}

###############################################################################
# 1. Homebrew installation and environment
###############################################################################

if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  log "Homebrew already installed. Skipping installation."
fi

# Ensure Homebrew is on PATH for this script
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

BREW_BIN="$(command -v brew)"
log "Using Homebrew at: $BREW_BIN"

###############################################################################
# 2. Git configuration (global)
###############################################################################

log "Configuring git global identity..."

git config --global user.name "Malik Falana"
git config --global user.email "malikfalana@icloud.com"

# Optional but recommended defaults
git config --global init.defaultBranch main
git config --global core.editor "code --wait"

log "Git global configuration set."

###############################################################################
# 3. Core CLI tools
###############################################################################

log "Installing core CLI tools..."

brew install mas                    # Mac App Store CLI
brew install git                    # Ensure latest git
brew install node                   # Node / NPM for JS / web dev
brew install azure-cli              # Azure CLI
brew install ffmpeg                 # Media conversion tools
brew install gdal                   # GIS formats
brew install proj                   # Coordinate transformations
brew install laszip                 # LiDAR compression
brew install pyenv                  # Python version manager
brew install docker-compose         # Docker Compose (v2+ usually bundled, but this is fine)
brew install java                   # Java (for tools that require it)
brew install altserver              # AltServer CLI

log "Core CLI tools installed."

###############################################################################
# 4. GUI applications (casks)
###############################################################################

log "Installing GUI applications..."

# Development
brew install --cask visual-studio-code
brew install --cask docker
brew install --cask azure-data-studio
brew install --cask qgis
brew install --cask cloudcompare

# Browsers
brew install --cask opera-gx
brew install --cask microsoft-edge

# Microsoft Office / Remote Desktop
brew install --cask microsoft-remote-desktop
brew install --cask microsoft-excel
brew install --cask microsoft-word

# Productivity / Notes / Communication
brew install --cask obsidian
brew install --cask slack
brew install --cask discord

# Other apps (leave as-is from your list)
brew install --cask kiro

log "GUI applications installed."

###############################################################################
# 5. Mac App Store installs (via mas)
###############################################################################

log "Installing Mac App Store apps..."

# Xcode (full IDE)
mas install 497799835  # Xcode
Mas install 899247664  # TestFlight

log "Mac App Store apps installed."

###############################################################################
# 6. Python setup with pyenv (multiple versions + pip)
###############################################################################

log "Setting up Python with pyenv..."

# Ensure pyenv is available in this script
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT/bin" ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
fi

# Initialize pyenv for this script run
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
else
  log "pyenv not found on PATH after installation; check Homebrew setup."
  exit 1
fi

# Python versions to install and manage
PYTHON_VERSIONS=(
  "3.12.7"
  "3.11.9"
)

for ver in "${PYTHON_VERSIONS[@]}"; do
  if pyenv versions --bare | grep -qx "$ver"; then
    log "Python $ver already installed via pyenv. Skipping."
  else
    log "Installing Python $ver via pyenv..."
    pyenv install "$ver"
  fi
done

# Set a default global Python version
DEFAULT_PYTHON_VERSION="${PYTHON_VERSIONS[1]}"
log "Setting global Python version to $DEFAULT_PYTHON_VERSION..."
pyenv global "$DEFAULT_PYTHON_VERSION"

# Upgrade pip for each installed Python version
log "Upgrading pip for all managed Python versions..."
for ver in "${PYTHON_VERSIONS[@]}"; do
  log "Activating Python $ver and upgrading pip..."
  pyenv shell "$ver"
  python -m pip install --upgrade pip
done

# Reset pyenv shell
pyenv shell --unset || true

log "Python and pip setup complete."

###############################################################################
# 7. Add pyenv initialization to .zshrc
###############################################################################

ZSHRC="$HOME/.zshrc"

log "Ensuring pyenv initialization is present in $ZSHRC..."

if ! grep -q 'pyenv init' "$ZSHRC" 2>/dev/null; then
  {
    echo ""
    echo "# pyenv initialization"
    echo 'export PYENV_ROOT="$HOME/.pyenv"'
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
    echo 'eval "$(pyenv init -)"'
  } >> "$ZSHRC"
  log "Added pyenv initialization to $ZSHRC."
else
  log "pyenv initialization already present in $ZSHRC. Skipping."
fi

###############################################################################
# 8. Final message
###############################################################################

log "Setup complete. You may need to open a new terminal window for all changes to take effect."