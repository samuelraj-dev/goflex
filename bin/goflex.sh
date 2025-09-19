#!/bin/bash

# Goflex - Linux/macOS starter CLI

GoflexDir="$HOME/.goflex"
# GoflexDir="/home/sam/code/projects/goflex/bin/.goflextest"
VersionsDir="$GoflexDir/versions"
CurrentDir="$GoflexDir/current"
CacheDir="$GoflexDir/cache"

mkdir -p "$VersionsDir" "$CurrentDir" "$CacheDir"

function usage() {
    echo "Usage: goflex <command> [version]"
    echo "Commands:"
    echo "  install <version>  Install Go version"
    echo "  default <version>  Set default Go version"
    echo "  list               List installed versions"
    echo "  version            Show goflex version"
    echo "  help               Show this help message"
    exit 1
}

function help() {
    echo "Usage: goflex <command> [version]"
    echo "Commands:"
    echo "  install <version>  Install Go version"
    echo "  default <version>  Set default Go version"
    echo "  list               List installed versions"
    echo "  version            Show goflex version"
    echo "  help               Show this help message"
    exit 0
}

if [ $# -lt 1 ]; then
    usage
fi

COMMAND=$1
VERSION=$2

GO_BASE_URL="https://golang.org/dl"

OS_TYPE="$(uname | tr '[:upper:]' '[:lower:]')"
ARCH_TYPE="$(uname -m)"

if [ "$ARCH_TYPE" = "x86_64" ]; then
    ARCH_TYPE="amd64"
elif [[ "$ARCH_TYPE" == "arm64" || "$ARCH_TYPE" == "aarch64" ]]; then
    ARCH_TYPE="arm64"
else
    echo "Unsupported architecture: $ARCH_TYPE"
    exit 1
fi

get_checksum_from_json() {
    # echo $1 $2 $3
    local version="$1" os="$2" arch="$3"
    local json_url="https://go.dev/dl/?mode=json"

    if command -v jq >/dev/null 2>&1; then
        curl -s "$json_url" | \
        jq -r --arg ver "go${version}" \
                --arg file "go${version}.${os}-${arch}.tar.gz" \
            '.[] | select(.version == $ver) | .files[] | select(.filename == $file) | .sha256' \
        | head -n1
    else
        curl -s "$json_url" | tr -d '\n' | \
        grep -oP "\"filename\":\"go${version}\.${os}-${arch}\.tar\.gz\".*?\"sha256\":\"\K[0-9a-f]{64}" \
        | head -n1
    fi
}

get_checksum_from_html() {
  local version="$1" os="$2" arch="$3"
  local dl_page="https://go.dev/dl/"
  local file="go${version}.${os}-${arch}.tar.gz"

  curl -s "$dl_page" | awk -v f="$file" '
    BEGIN { RS="</tr>"; FS="\n" }
    $0 ~ f {
      if (match($0, /<tt>[0-9a-f]+<\/tt>/)) {
        checksum = substr($0, RSTART+4, RLENGTH-9)
        print checksum
        exit
      }
    }'
}

case $COMMAND in
    list)
        echo "Installed versions:"
        for v in "$VersionsDir"/go*; do
            [ -d "$v" ] && echo "  $(basename "$v")"
        done
        ;;
    # list-online)
    #     echo "Available Go versions online:"
    #     curl -s https://go.dev/dl/?mode=json | jq -r '.[].version'
    #     ;;
    # list-online)
    #     echo "Available Go versions online:"
    #     curl -s https://go.dev/dl/?mode=json | grep -oP '"version":\s*"\Kgo[0-9\.rc]+' 
    #     ;;
    help)
        help
        ;;
    version)
        echo "goflex version 0.0.1alpha"
        ;;
    # use)
    #     if [ -z "$VERSION" ]; then
    #         echo "Specify version: goflex use <version>"
    #         exit 1
    #     fi

    #     if [ ! -d "$VersionsDir/go$VERSION" ]; then
    #         echo "Go version $VERSION not installed. Run goflex install $VERSION first."
    #         exit 1
    #     fi

    #     export GO_HOME="$VersionsDir/go$VERSION"
    #     export PATH="$GO_HOME/bin:$PATH"
    #     echo "Using Go $VERSION for this shell session"
    #     go version
    #     ;;
    default)
        if [ -z "$VERSION" ]; then
            echo "Specify version: goflex default <version>"
            exit 1
        fi

        if [ ! -d "$VersionsDir/go$VERSION" ]; then
            echo "Go version $VERSION not installed. Run goflex install $VERSION first."
            exit 1
        fi

        ln -sfn "$VersionsDir/go$VERSION" "$CurrentDir/go"
        echo "Default Go version set to $VERSION"

        if ! grep -q 'Goflex' "$HOME/.bashrc"; then
            echo "# Goflex" >> "$HOME/.bashrc"
            echo 'export GO_HOME="$HOME/.goflex/current/go"' >> "$HOME/.bashrc"
            echo 'export PATH="$GO_HOME/bin:$PATH"' >> "$HOME/.bashrc"
        fi
        ;;
    install)
        SKIP_CHECKSUM_FLAG=0
        while [[ "$3" == --* ]]; do
            case "$3" in
                --skip-checksum) SKIP_CHECKSUM_FLAG=1; shift;;
                *) echo "Unknown flag $3"; exit 1;;
            esac
        done
        if [ -z "$VERSION" ]; then
            echo "Specify version: goflex install <version>"
            exit 1
        fi

        if [ -d "$VersionsDir/go$VERSION" ]; then
            echo "Go $VERSION is already installed."
            exit 0
        fi

        TAR_FILE="go${VERSION}.${OS_TYPE}-${ARCH_TYPE}.tar.gz"
        CACHE_FILE="$CacheDir/$TAR_FILE"

        if [ ! -f "$CACHE_FILE" ]; then
            echo "Downloading Go $VERSION..."
            curl -L -o "$CACHE_FILE" "$GO_BASE_URL/$TAR_FILE"
            if [ $? -ne 0 ]; then
                echo "Download failed!"
                exit 1
            fi
        else
            echo "Using cached Go $VERSION..."
        fi
        
        EXPECTED_HASH=""
        EXPECTED_HASH=$(get_checksum_from_json "$VERSION" "$OS_TYPE" "$ARCH_TYPE")
        echo $VERSION
        echo $OS_TYPE
        echo $ARCH_TYPE
        echo $EXPECTED_HASH
        if [ -z "$EXPECTED_HASH" ]; then
            echo "No JSON checksum entry found; trying HTML fallback..."
            EXPECTED_HASH=$(get_checksum_from_html "$VERSION" "$OS_TYPE" "$ARCH_TYPE")
        fi

        if [ -z "$EXPECTED_HASH" ]; then
            echo $SKIP_CHECKSUM_FLAG
            if [ "${GOFLEX_SKIP_CHECKSUM:-0}" = "1" ] || [ "$SKIP_CHECKSUM_FLAG" = "1" ]; then
                echo "Warning: no checksum available; skipping verification (user requested skip)."
            else
                echo "Error: no checksum available for $TAR_FILE. Use --skip-checksum or set GOFLEX_SKIP_CHECKSUM=1 to bypass."
                exit 1
            fi
        else
            ACTUAL_HASH=""
            if command -v sha256sum >/dev/null 2>&1; then
                ACTUAL_HASH=$(sha256sum "$CACHE_FILE" | awk '{print $1}')
            else
                ACTUAL_HASH=$(shasum -a 256 "$CACHE_FILE" | awk '{print $1}')
            fi

            if [ "$EXPECTED_HASH" != "$ACTUAL_HASH" ]; then
                echo "SHA256 mismatch! Expected: $EXPECTED_HASH"
                echo "Actual:   $ACTUAL_HASH"
                echo "Aborting install."
                exit 1
            fi
            echo "SHA256 verification passed."
        fi

        echo "Installing Go $VERSION..."
        tar -C "$VersionsDir" -xzf "$CACHE_FILE" || { echo "Error: Extract failed"; exit 1; }
        if [ -d "$VersionsDir/go" ]; then
            mv "$VersionsDir/go" "$VersionsDir/go$VERSION"
        fi

        echo "Go $VERSION installed successfully!"
        ;;

    use)
        echo "Command not implemented yet"
        usage
        ;;
    current)
        echo "Command not implemented yet"
        usage
        ;;
    *)
        echo "Unknown command: $COMMAND"
        usage
        ;;
esac