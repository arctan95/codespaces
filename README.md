# Linux Universal Image

## Summary

*Use or extend the new Debian-based default, large, and multi-language universal image which contains many popular languages/frameworks/SDKS/runtimes*

| Metadata | Value |
|----------|-------|
| *Categories* | Services, GitHub |
| *Image type* | Dockerfile |
| *Published image* | ghcr.io/arctan95/codespaces |
| *Published image architecture(s)* | x86-64, aarch64 |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Python, Node.js, JavaScript, TypeScript, C++, Java, C#, F#, .NET Core, PHP, Go, Ruby, Rust |

## Description

This is a fork from [devcontainers/images](https://github.com/devcontainers/images). If you like what you see but want to make a few additions or changes, you can use a custom Dockerfile to extend it and add whatever you need.

The container includes the `zsh` (and Oh My Zsh!) shell that you can opt into using instead of the default `bash`. It also includes [Nix](https://nixos.org/) as package manager, [asdf](https://asdf-vm.com/) as multiple runtime version manager. You can also set things up to access the container via SSH.

## Using this image

While the image itself works unmodified, you can also directly reference pre-built versions of `Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own `Dockerfile` to:

`ghcr.io/arctan95/codespaces`

Alternatively, you can use the contents of the [`Dockerfile`](.devcontainer/Dockerfile) to fully customize your container's contents or to build it for a container host architecture not supported by the image.

Refer to [this guide](https://containers.dev/guide/dockerfile) for more details.

## Using with Nix

If you don't want to use docker image, you can alternatively run the command below.

`curl -sSL https://raw.githubusercontent.com/arctan95/codespaces/HEAD/.devcontainer/first-run-setup.sh | bash`

Refer to [Nix Manual](https://nixos.org/manual/nix/stable/) for more details.

## Homebrew

This repository also contains [Homebrew](https://brew.sh/) backup file in [`.config/homebrew`](.config/homebrew/Brewfile) for macOS system. You can simply run the following commands to backup & restore.

```sh
brew bundle dump --describe --force --file="/your/path/to/Brewfile" # backup
brew bundle install --file="/your/path/to/Brewfile" # restore
```

## Customization
You can edit the [config.toml](config.toml) file to customize your settings.

## License

Licensed under the MIT License. See [LICENSE](https://github.com/arctan95/codespaces/blob/master/LICENSE).

