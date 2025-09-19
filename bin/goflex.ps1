# Goflex - Windows starter CLI

# $GoflexDir = "$HOME\.goflex"
# $VersionsDir = "$GoflexDir\versions"
# $CurrentDir = "$GoflexDir\current"

# New-Item -ItemType Directory -Force -Path $VersionsDir
# New-Item -ItemType Directory -Force -Path $CurrentDir

# param(
#     [string]$Command,
#     [string]$Version
# )

# switch ($Command) {
#     "list" {
#         Get-ChildItem $VersionsDir | ForEach-Object { $_.Name }
#     }
#     "use" {
#         if (-not $Version) { Write-Host "Specify version: goflex use <version>"; exit 1 }
#         $Target = Join-Path $VersionsDir "go$Version"
#         if (-not (Test-Path $Target)) { Write-Host "Version $Version not installed."; exit 1 }
#         Remove-Item $CurrentDir -Recurse -Force
#         New-Item -ItemType SymbolicLink -Path $CurrentDir -Target $Target
#         $env:GOROOT = $CurrentDir
#         $env:PATH = "$CurrentDir\bin;" + $env:PATH
#         Write-Host "Switched to Go $Version"
#         go version
#     }
#     default {
#         Write-Host "Command not implemented yet"
#     }
# }
