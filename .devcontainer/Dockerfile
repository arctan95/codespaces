FROM debian:stable-slim

COPY first-run-notice.txt /tmp/scripts/

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive

ENV LANG="C.UTF-8"

# Install basic build and debug tools
RUN apt-get update \
    && apt-get -y install acl build-essential cmake cppcheck valgrind clang lldb llvm gdb python3-dev \
    # Install tools and shells not in common script
    && apt-get install -yq vim vim-doc xtail libsecret-1-dev \
    # Install additional tools
    && apt-get install -y --no-install-recommends libnss3 libnspr4 libatk-bridge2.0-0 libatk1.0-0 libx11-6 libpangocairo-1.0-0 \
                                                  libx11-xcb1 libcups2 libxcomposite1 libxdamage1 libxfixes3 libpango-1.0-0 libgbm1 libgtk-3-0 \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y \
    # Move first run notice to right spot
    && mkdir -p "/usr/local/etc/vscode-dev-containers" \
    && mv -f /tmp/scripts/first-run-notice.txt /usr/local/etc/vscode-dev-containers/

# Default to zsh shell
ENV SHELL=/usr/bin/zsh \
    DOCKER_BUILDKIT=1

# Remove scripts now that we're done with them
RUN apt-get clean -y && rm -rf /tmp/scripts

# Mount for Nix
VOLUME [ "/nix" ]

# Fire Docker/Moby script if needed
ENTRYPOINT [ "/usr/local/share/docker-init.sh", "/usr/local/share/ssh-init.sh"]
CMD [ "sleep", "infinity" ]

# [Optional] Install debugger for development of Codespaces - Not in resulting image by default
ARG DeveloperBuild
RUN if [ -z $DeveloperBuild ]; then \
        echo "not including debugger" ; \
    else \
        curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg ; \
    fi
