<#
This script builds libiconv,libxml2 and libxslt
#>
Param(
	[string]$arch,
	[int]$vsver
)

$ErrorActionPreference = "Stop"
Import-Module Pscx

$x64Dir = If($arch -eq "x64") { "\x64" } Else { "" }
$distname = If($arch -eq "x64") { "win64" } Else { "win32" }
If($vsver -eq 90) { $distname = "vs2008.$distname" }
$vcvarsarch = If($arch -eq "x64") { "amd64" } Else { "x86" }

Set-Location $PSScriptRoot

$VisualStudioVersion = [string]$vsver
Import-VisualStudioVars -VisualStudioVersion $VisualStudioVersion -Architecture $vcvarsarch

Set-Location (".\libiconv\MSVC" + [string]($vsver / 10))
if($vsver -eq 9) {
    $vcarch = If($arch -eq "x64") { "x64" } Else {"Win32"}
    vcbuild libiconv_static\libiconv_static.vcproj "Release|$vcarch"
} else {
    msbuild libiconv.sln /p:Configuration=Release /t:libiconv_static
}
$iconvLib = Join-Path (pwd) libiconv_static$x64Dir\Release
$iconvInc = Join-Path (pwd) ..\source\include
Set-Location ..\..

Set-Location .\zlib
Start-Process -NoNewWindow -Wait nmake "-f win32/Makefile.msc zlib.lib"
$zlibLib = (pwd)
$zlibInc = (pwd)
Set-Location ..

Set-Location .\libxml2\win32
cscript configure.js lib="$zlibLib;$iconvLib" include="$zlibInc;$iconvInc" vcmanifest=yes zlib=yes
Start-Process -NoNewWindow -Wait nmake libxmla
$xmlLib = Join-Path (pwd) bin.msvc
$xmlInc = Join-Path (pwd) ..\include
Set-Location ..\..

Set-Location .\libxslt\win32
cscript configure.js lib="$zlibLib;$iconvLib;$xmlLib" include="$zlibInc;$iconvInc;$xmlInc" vcmanifest=yes zlib=yes
Start-Process -NoNewWindow -Wait nmake "libxslta libexslta"
Set-Location ..\..

# Pushed by Import-VisualStudioVars
Pop-EnvironmentBlock

# Bundle releases
Function BundleRelease($name, $lib, $inc)
{
    New-Item -ItemType Directory .\dist\$name

    New-Item -ItemType Directory .\dist\$name\lib
    Copy-Item -Recurse $lib .\dist\$name\lib
    Get-ChildItem -File -Recurse .\dist\$name\lib | Where{$_.Name -NotMatch ".(lib|pdb)$" } | Remove-Item

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

BundleRelease "iconv-1.14.$distname" (dir $iconvLib\iconv_a*) (dir $iconvInc\*)
BundleRelease "libxml2-2.9.4.$distname" (dir $xmlLib\*) (Get-Item $xmlInc\libxml)
BundleRelease "libxslt-1.1.29.$distname" (dir .\libxslt\win32\bin.msvc\*) (Get-Item .\libxslt\libxslt,.\libxslt\libexslt)
BundleRelease "zlib-1.2.8.$distname" (Get-Item .\zlib\*.*) (Get-Item .\zlib\zconf.h,.\zlib\zlib.h)
