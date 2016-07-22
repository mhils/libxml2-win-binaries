<#
This script builds libiconv,libxml2 and libxslt
#>

$ErrorActionPreference = "Stop"
Import-Module Pscx

cd $PSScriptRoot

# Change theset two lines to change VS version
Import-VisualStudioVars -VisualStudioVersion 140 -Architecture x86

cd .\libiconv\MSVC14
msbuild libiconv.sln /p:Configuration=Release 
# /p:Platform=Win32
# msbuild libiconv.sln /p:Configuration=Release /p:Platform=x64
$iconvLib = Join-Path (pwd) libiconv_static\Release
$iconvInc = Join-Path (pwd) ..\source\include
# Make sure that libiconv.(lib|exp) is included
Copy-Item -Force (Join-Path (pwd) Release\*) -Destination $iconvLib
cd ..\..

cd .\libxml2\win32
cscript configure.js lib="$iconvLib" include="$iconvInc" vcmanifest=yes
nmake
$xmlLib = Join-Path (pwd) bin.msvc
$xmlInc = Join-Path (pwd) ..\include
cd ..\..

cd .\libxslt\win32
cscript configure.js lib="$iconvLib;$xmlLib" include="$iconvInc;$xmlInc" vcmanifest=yes
nmake
cd ..\..


# Bundle releases
Function BundleRelease($name, $lib, $inc)
{
    New-Item -ItemType Directory .\dist\$name

    New-Item -ItemType Directory .\dist\$name\lib
    Copy-Item -Recurse $lib .\dist\$name\lib
    Get-ChildItem -File -Recurse .\dist\$name\lib | Where{$_.Name -NotMatch ".(lib|exp)$" } | Remove-Item

    New-Item -ItemType Directory .\dist\$name\include
    Copy-Item -Recurse $inc .\dist\$name\include
    Get-ChildItem -File -Recurse .\dist\$name\include | Where{$_.Name -NotMatch ".h$" } | Remove-Item

    Write-Zip  .\dist\$name .\dist\$name.zip
    Remove-Item -Recurse -Path .\dist\$name
}

if (Test-Path .\dist) { Remove-Item .\dist -Recurse }
New-Item -ItemType Directory .\dist

# lxml expects iconv to be called iconv, not libiconv
Dir $iconvLib\libiconv* | Copy-Item -Force -Destination {Join-Path $iconvLib ($_.Name -replace "libiconv","iconv") }
Remove-Item (Join-Path $iconvLib iconv_static.tlog)

BundleRelease "iconv-1.14.win32" (dir $iconvLib\iconv* | Where-Object {$_.Name -notmatch "^libiconv"}) (dir $iconvInc\*)
BundleRelease "libxml2-2.9.4.win32" (dir $xmlLib\*) (Get-Item $xmlInc\libxml)
BundleRelease "libxslt-1.1.29.win32" (dir .\libxslt\win32\bin.msvc\*) (Get-Item .\libxslt\libxslt,.\libxslt\libexslt)
