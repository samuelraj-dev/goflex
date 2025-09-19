#!/bin/bash

if [ "$1" == "install" ]; then
    VERSION="$2"
    if [ -z "$VERSION" ]; then
        echo "Usage: $0 install <version>"
        exit 1
    fi

    # Download Go tarball
    URL="https://go.dev/dl/go${VERSION}.linux-amd64.tar.gz"
    wget $URL -O /tmp/go${VERSION}.tar.gz || { echo "Download failed"; exit 1; }

    # Extract to /usr/local
    sudo tar -C /usr/local -xzf /tmp/go${VERSION}.tar.gz
    sudo mv /usr/local/go /usr/local/go${VERSION}

    echo "Go $VERSION installed successfully!"

elif [ "$1" == "use" ]; then
    VERSION="$2"
    TARGET="/usr/local/go${VERSION}"
    if [ ! -d "$TARGET" ]; then
        echo "Error: Go version $VERSION not installed"
        exit 1
    fi

    sudo ln -sfn "$TARGET" /usr/local/go
    export GO_HOME="/usr/local/go"
    export PATH="$GO_HOME/bin:$PATH"
    echo "Switched to Go $VERSION"
    go version

elif [ "$1" == "list" ]; then
    ls -1 /usr/local | grep '^go[0-9]' || echo "No Go versions installed"

else
    echo "Usage: $0 install|use|list <version>"
fi