# Goflex

**Goflexw** is a cross-platform Go version manager for Linux, macOS, and Windows.  
It allows developers to install, switch, and manage multiple Go versions effortlessly, with project-level versioning, caching, checksum verification, and an interactive CLI.

---

## Features

- Install Go from official binary or compile from source
- Switch between Go versions globally or per project
- Project-level `.goflexrc` support for automatic version switching
- Binary caching for faster reinstallation
- Checksum verification for secure installs
- Cross-platform support: Linux, macOS, Windows (PowerShell/WSL)
- Color-coded interactive CLI with current/default version indicators
- Remove old Go versions easily
- Auto-suggestions and error handling for invalid versions

---

## Installation

### Note
This is currently in alpha phase. Use at your own risk
Conditions to use:
 - linux user (non-root)
 - install packages jq (optional but recommended), curl, wget
 - only bash is supported

### Install
```
curl -fsSL https://raw.githubusercontent.com/samuelraj-dev/goflex/refs/heads/main/install.sh | bash
``` 
### Verify Installation
```
goflex version
```