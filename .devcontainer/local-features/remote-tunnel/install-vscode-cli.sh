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

mkdir -p ${CODE_CLI_HOME}
curl -sSL "https://code.visualstudio.com/sha/download?build=stable&os=cli-${platform}-${architecture}" -o /tmp/code-cli

if [ ! -f "/tmp/code-cli" ]; then
    echo "(!) Failed to download code-cli."
    exit 1
fi

FILE_TYPE=$(file -b --mime-type "/tmp/code-cli")
case "$FILE_TYPE" in
    application/zip)
        unzip "/tmp/code-cli" -d "${CODE_CLI_HOME}"
        ;;
    application/gzip)
        tar -xf "/tmp/code-cli" -C "${CODE_CLI_HOME}"
        ;;
    *)
        echo "Unsupported file type: $FILE_TYPE"
        exit 1
        ;;
esac
mv "${CODE_CLI_HOME}/code" "${CODE_CLI_HOME}/code-cli"
rm /tmp/code-cli

echo "VSCode CLI has been installed! Run code-cli --help for more information."
