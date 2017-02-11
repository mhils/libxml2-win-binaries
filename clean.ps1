<#
This script resets all submodules to a clean state so that no previous build artifacts are reused.
#>

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

ForEach ($repo in "libiconv","libxslt","libxml2","zlib") {
    echo "Cleaning up $repo..."
    Set-Location $repo
    Get-ChildItem -Exclude .git . | Remove-Item -Recurse
    git reset --hard
    Set-Location ..
}

if (Test-Path .\dist) { Remove-Item .\dist -Recurse }
echo "done!"
