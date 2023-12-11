#!/bin/bash

set -e

# Ensure shell is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Define help message
help_message="
Usage: "$0" [OPTIONS]

Options:
  --help                 Display this help message
  --version              Display version information
  --install-homebrew     Install homebrew when it's a macOS system
  --config-passwd        Sync private password configs into system
"

version="v0.1.0"
install_homebrew=false
config_passwd=false

while [ $# -gt 0 ]; do
  case "$1" in
    --help)
      echo "$help_message"
      exit 0
      ;;
    --version)
      echo "$version"
      exit 0
      ;;
    --install-homebrew)
      install_homebrew=true
      ;;
    --config-passwd)
      config_passwd=true
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

# Get the name of the current shell
default_shell="$(echo $SHELL)"
echo "Default shell is $default_shell"

clone_repo() {
  repo_url=$1
  local_dir=$2

  # Check if the local directory already exists
  if [ ! -d "$local_dir" ]; then
    # Clone the GitHub repository to the specified local directory
    git clone "$repo_url" "$local_dir"
  else
    echo "Repository already cloned. Skipping..."
  fi
}

clone_repo "https://github.com/arctan95/codespaces.git" "$HOME/codespaces"

echo "Installing Nix..."
# Check if Nix is already installed
if [ -e "/nix" ]; then
  echo "Nix already installed. Skipping..."
else
  # Install Nix
  curl -L https://nixos.org/nix/install | sh -s -- --daemon
fi

echo "Configuring Nix experimental features..."
# Check if experimental features are already configured
if ! grep -q "experimental-features = nix-command flakes" /etc/nix/nix.conf; then
  # Configure Nix experimental features
  echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
else
  echo "Experimental features already configured. Skipping..."
fi

# Ensure nix commnad is available in current shell session
source /etc/bashrc

echo "Installing home-manager and switching into a new generation..."
# Run Home Manager with experimental features
nix run nixpkgs#home-manager -- switch --impure --flake github:arctan95/codespaces

# Check if it's a macOS system
if [ "$install_homebrew" = "true" ] && [ "$(uname)" = "Darwin" ]; then
  echo "Installing Homebrew..."
  # Check if Homebrew is already installed
  if ! command -v brew >/dev/null 2>&1; then
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew is already installed. Skipping..."
  fi

  # Ensure brew command is available in currnet shell session
  if [ "$default_shell" = "/bin/zsh" ]; then
    config_file="$HOME/.zprofile"
  elif [ "$default_shell" = "/bin/bash" ]; then
    config_file="$HOME/.bashprofile"
  else
    config_file="$HOME/.profile"
  fi

  # Check if the brew shellenv is already configured
  if ! grep -q "brew shellenv" "$config_file"; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' | tee -a "$config_file" && eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "Successfully configure brew shellenv in $config_file"
  else
    echo "The brew shellenv is already configured in $config_file. Skipping..."
  fi

  # Restore softwares from brewfile
  echo "Restoring softwares from Brewfile..."
  brew bundle install --file="$HOME/codespaces/.config/homebrew/Brewfile"
fi

# Check if the --config-password parameter is specified
if [ "$config_passwd" = "true" ]; then
  echo "Configurating passwords..."
  clone_repo "https://github.com/arctan95/password-store.git" "$HOME/.password-store"
  /bin/bash "$HOME/.password-store/setup.sh"
fi

echo "Installing asdf plugins and packages..."
# Install asdf plugins and packages from .tool-versions file
cd "$HOME/codespaces"
cut -d ' ' -f1 .tool-versions | xargs -I {} sh -c 'echo "Installing {}..."; asdf plugin add {} && asdf install {}'