<#
This script resets all submodules to a clean state so that no previous build artifacts are reused.
#>

$ErrorActionPreference = "Stop"
cd $PSScriptRoot

ForEach ($repo in "libiconv","libxslt","libxml2") {
    echo "Cleaning up $repo..."
    cd $repo
    Get-ChildItem -Exclude .git . | Remove-Item -Recurse
    git reset --hard
    cd ..
}

if (Test-Path .\dist) { Remove-Item .\dist -Recurse }
echo "done!"