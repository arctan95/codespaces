#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo or switch to root before running this script.'
    exit 1
fi

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

platform="$(uname)"
architecture="$(uname -m)"
release=$(get_latest_release "asdf-vm/asdf")

if [ "$platform" = "Linux" ]; then
    platform="linux"
elif [ "$platform" = "Darwin" ]; then
    platform="darwin"
fi

case "$architecture" in
    x86_64 | amd64) architecture="amd64";;
    aarch64 | arm64 | armv8*) architecture="arm64";;
    *) echo "(!) Architecture $architecture unsupported."; exit 1 ;;
esac

asdf_package="asdf-${release}-${platform}-${architecture}.tar.gz"
URL="https://github.com/asdf-vm/asdf/releases/download/${release}/${asdf_package}"
echo "Downloading asdf-go from $URL"
wget -qP /tmp $URL
tar -xzf /tmp/${asdf_package} -C /usr/local/bin
rm -rf /tmp/${asdf_package}

echo "ASDF-Go has been installed! Run asdf --help for more information."
