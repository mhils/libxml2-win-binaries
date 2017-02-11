# libxml2 Windows binaries for lxml

![appveyor ci status](https://ci.appveyor.com/api/projects/status/cc6q3nrosjul2sgl?svg=true)

This repository contains everything required to compile libiconv, libxml2, and libxslt on Windows with Visual Studio 2015 / UCRT so that it can be used to build lxml wheels for Python 3.5.

## Instructions

- Install the [Visual C++ Build Tools](http://landinghub.visualstudio.com/visual-cpp-build-tools) (or Visual Studio).
- Open a Powershell prompt and install the Powershell Community Tools: 
```powershell
Set-ExecutionPolicy remotesigned
Find-Package pscx | ? ProviderName -eq PSModule | Install-Package -Force
```
- Run `build.ps1`
- Take binaries from `dist/`

## Acknowledgements

This work was made possible by https://github.com/winlibs!
