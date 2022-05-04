# SciTE4AutoHotkey patches for Scintilla, Lexilla and SciTE

## Prerequisites

- Mercurial
- Git
- [msys2](https://www.msys2.org/) with clang64 environment and toolchain (`pacman -S --needed mingw-w64-clang-x86_64-toolchain`)

All commands below assume you are using the clang64 shell provided by msys2.

## Getting the source and patching it

```bash
hg clone http://hg.code.sf.net/p/scintilla/code scintilla
git clone https://github.com/ScintillaOrg/lexilla -b rel-5-1-6 lexilla
hg clone http://hg.code.sf.net/p/scintilla/scite scite
cd scintilla && hg update rel-5-2-2 && cd ..
cd lexilla && git apply ../lexilla.diff && cd ..
cd scite && hg update rel-5-2-2 && hg import --no-commit ../scite.diff && cd ..
cp SciTE4AutoHotkey.ico scite/win32/
```

## Building the components

```bash
cd scintilla/win32 && make CLANG=1 && cd ../..
cd lexilla/src && make CLANG=1 && cd ../..
cd scite/win32 && make CLANG=1 && cd ../bin && strip *.exe *.dll && cd ../..
```

The resulting files (SciTE.exe, Scintilla.dll, lexilla.dll) should be present in `scite/bin`, and can be copied to the main SciTE4AutoHotkey program folder.
