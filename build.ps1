$ErrorActionPreference = "Stop"
Import-Module Pscx

cd $PSScriptRoot

# Change theset two lines to change VS version
Import-VisualStudioVars -VisualStudioVersion 140 -Architecture x86
cd .\libiconv\MSVC14


msbuild libiconv.sln /p:Configuration=Release 
# /p:Platform=Win32
# msbuild libiconv.sln /p:Configuration=Release /p:Platform=x64
$iconvLib = Join-Path (pwd) Release
$iconvInc = Join-Path (pwd) ..\source\include
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
$xsltLib = Join-Path (pwd) bin.msvc
$xsltInc = Join-Path (pwd) ..\libxslt
cd ..\..


# Bundle releases
Function BundleRelease($name, $lib, $inc)
{
    New-Item -ItemType Directory .\dist\$name

    New-Item -ItemType Directory .\dist\$name\lib
    Copy-Item -Recurse $lib .\dist\$name\lib

    New-Item -ItemType Directory .\dist\$name\include
    Copy-Item -Recurse $inc .\dist\$name\include
    Compress-Archive  .\dist\$name .\dist\$name.zip
    Remove-Item -Recurse -Path .\dist\$name
}

if (Test-Path .\dist) { Remove-Item .\dist -Recurse }
New-Item -ItemType Directory .\dist
BundleRelease "iconv-1.14.win32" (dir $iconvLib\*) (dir $iconvInc\*.h)
BundleRelease "libxml2-2.9.4.win32" (dir $xmlLib\*.lib,$xmlLib\*.exp) (dir $xmlInc\libxml\*.h)
BundleRelease "libxslt-1.1.27.win32" (dir $xsltLib\*.lib,$xsltLib\*.exp) (dir $xsltInc\*.h)
