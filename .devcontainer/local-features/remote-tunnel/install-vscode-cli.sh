#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo or switch to root before running this script.'
    exit 1
fi

CODE_CLI_HOME="/usr/local/bin"

platform="$(uname)"
architecture="$(uname -m)"

if [ "$platform" = "Linux" ]; then
    platform="alpine"
elif [ "$platform" = "Darwin" ]; then
    platform="darwin"
fi

case "$architecture" in
    x86_64 | amd64) architecture="x64";;
    aarch64 | arm64 | armv8*) architecture="arm64";;
    *) echo "(!) Architecture $architecture unsupported."; exit 1 ;;
esac

URL="https://code.visualstudio.com/sha/download?build=stable&os=cli-${platform}-${architecture}"
echo "Downloading VSCode CLI from $URL"
mkdir -p "${CODE_CLI_HOME}/tmp"
cd "${CODE_CLI_HOME}/tmp"
curl -sSL -OJ "$URL"

file_name=$(ls)
case "$file_name" in
    *.zip)
        unzip -q "$file_name" -d "${CODE_CLI_HOME}/tmp"
        ;;
    *.tar.gz | *.tgz)
        tar -xzf "$file_name" -C "${CODE_CLI_HOME}/tmp"
        ;;
    *.tar)
        tar -xf "$file_name" -C "${CODE_CLI_HOME}/tmp"
        ;;
    *)
        echo "Unsupported file format: $file_name"
        exit 1
        ;;
esac

if [ -f "${CODE_CLI_HOME}/tmp/code" ]; then
    mv -f "${CODE_CLI_HOME}/tmp/code" "${CODE_CLI_HOME}/code-cli"
fi
rm -rf "${CODE_CLI_HOME}/tmp"

echo "VSCode CLI has been installed! Run code-cli --help for more information."
