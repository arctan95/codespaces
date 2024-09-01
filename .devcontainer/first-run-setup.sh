#!/bin/bash
set -e

# Ensure shell is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

help_message="
Usage: "$0" [OPTIONS]

Options:
  --help                 Display this help message
  --version              Display version information
  --restore_passwd       Sync private passwords into system
  --restore_homebrew     Restore homebrew softwares into macOS system
  --enable_tunnel        Enable vscode tunnel for remote development
"

version="v0.1.0"
restore_homebrew=false
restore_passwd=false
enable_tunnel=false

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --help)
      echo "$help_message"
      exit 0
      ;;
    --version)
      echo "$version"
      exit 0
      ;;
    --restore_homebrew)
      restore_homebrew=true
      ;;
    --restore_passwd)
      restore_passwd=true
      ;;
    --enable_tunnel)
      enable_tunnel=true
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

# Get system information
current_shell="$(ps -p $$ -o comm= | sed 's/^-//')"
platform="$(uname)"
architecture="$(uname -m)"
echo "Current platform: $platform-$architecture, current shell: $current_shell"

clone_repo() {
  repo_url="$1"
  local_dir="$2"

  # Check if the local directory already exists
  if [ ! -d "$local_dir" ]; then
    # Clone the GitHub repository to the specified local directory
    git clone "$repo_url" "$local_dir"
  else
    echo "Repository already cloned. Skipping..."
  fi
}

clone_repo "https://github.com/arctan95/codespaces.git" "$HOME/.codespaces"

# Fix up github codespaces
if [ "${CODESPACES}" = true ]; then
  # Github codespaces set default permissions on /tmp.
  # These will produce invalid permissions on files built with nix.
  # This fix removes default permissions set on /tmp
  echo "Github codespaces detected..."
  sudo setfacl --remove-default /tmp
fi

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
if [ "$current_shell" = "zsh" ]; then
  source /etc/zshrc
elif [ "$current_shell" = "bash" ]; then
  source /etc/bashrc
else
  echo "Nix won't work in current shell session! You should restart terminal and run this script again!"
  exit 0
fi

echo "Installing home-manager and switching into a new generation..."
# Run Home Manager with experimental features
nix run nixpkgs#home-manager -- switch --impure --flake github:arctan95/codespaces

# Check if it's a macOS system
if [ "$platform" = "Darwin" ]; then
  echo "Installing Homebrew..."
  # Check if Homebrew is already installed
  if ! command -v brew >/dev/null 2>&1; then
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew is already installed. Skipping..."
  fi

  if [ "$current_shell" = "zsh" ]; then
    config_file="$HOME/.zprofile"
  elif [ "$current_shell" = "bash" ]; then
    config_file="$HOME/.bashprofile"
  else
    config_file="$HOME/.profile"
  fi

  case "$architecture" in
    x86_64 | amd64) brew_home="/usr/local/bin";;
    aarch64 | arm64 | armv8*) brew_home="/opt/homebrew/bin";;
    *) echo "(!) Architecture $architecture unsupported"; exit 1 ;;
  esac
  
  if ! grep -q "brew shellenv" "$config_file"; then
    echo 'eval "$('"$brew_home"'/brew shellenv)"' | tee -a "$config_file" && eval "$($brew_home/brew shellenv)"
    echo "Successfully configure brew shellenv in $config_file"
  else
    echo "The brew shellenv is already configured in $config_file. Skipping..."
  fi

  # Restore softwares from brewfile
  if [ "$restore_homebrew" = "true" ]; then
    echo "Restoring softwares from Brewfile..."
    brew bundle install --file="$HOME/.codespaces/.config/homebrew/Brewfile"
  fi
fi

# Enable remote tunnel
if [ "$enable_tunnel" = "true" ]; then
  echo "Installing vscode cli..."
  sudo /bin/bash "$HOME/.codespaces/.devcontainer/local-features/remote-tunnel/install-vscode-cli.sh"
fi

# Restore private passwords
if [ "$restore_passwd" = "true" ]; then
  echo "Configurating passwords..."
  clone_repo "https://github.com/arctan95/password-store.git" "$HOME/.password-store"
  /bin/bash "$HOME/.password-store/setup.sh"
fi

# Create a monorepo for development
if [ ! -d "$HOME/repositories" ]; then
  ln -s "$HOME/.codespaces/repositories" "$HOME/repositories"
fi

echo "Installing asdf plugins and packages..."
# Install asdf plugins and packages from .tool-versions file
mv "$HOME/.codespaces/.tool-versions" "$HOME"
cut -d ' ' -f1 "$HOME/.tool-versions" | xargs -I {} sh -c 'echo "Installing {}..."; asdf plugin add {} && asdf install {}'
