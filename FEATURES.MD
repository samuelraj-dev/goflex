Install Go from source
Install Go from binary
Automatic architecture detection (amd64/arm64)
Cross-platform support - Windows, MacOS, Linux (Ubuntu, Fedora, Arch, etc.)
Cross-shell support - Bash, Zsh, Fish, Windows (PowerShell, CMD).
List installed versions - with better UI (colors, table)
Switch version for current shell - with optional shell auto-switch on directory/project
Persistent default version - Project-level default
Auto-suggest installed versions - (tab-completion + suggestions on invalid version)
Auto-update Go
Install Go packages with version

# Basic commands
goflex install 1.25.1      # Install Go version
goflex use 1.25.1          # Switch current shell to this version
goflex default 1.25.1      # Set global default version
goflex list                # List installed versions
goflex remove 1.24.7       # Uninstall old version

# Advanced commands
goflex cache clean         # Clean cached binaries
goflex project             # Auto-switch Go version using .goflexrc
goflex upgrade             # Upgrade default Go version to latest stable
goflex help


Extra advanced ideas

Dependency caching.
Cache downloaded Go binaries to speed up install.
Checksum verification
Download official SHA256 and verify integrity.