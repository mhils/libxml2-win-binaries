# libxml Windows binaries

This repository contains everything that's needed to compile libiconv, libxml2, and libxslt on Windows with Visual Studio 2015 / UCRT so that it can be used to build lxml wheels for Python 3.5.

## Instructions

1. Open a Powershell prompt and install the Powershell Community Tools:
```powershell
Set-ExecutionPolicy remotesigned
Find-Package pscx | ? ProviderName -eq PSModule | Install-Package -Force
```
2. Run build.ps1

## Acknowledgements

This work was made possible by https://github.com/winlibs!