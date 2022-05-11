# SciTE4AutoHotkey Installer

This folder contains the source code of the program that installs SciTE4AutoHotkey.
A helper script (BuildInstaller.ahk) is provided, and it generates both the installer and the portable zip file.
7-zip files (7z.exe, 7zSD.sfx) are required for the script to work, and must be copied into this folder manually.

The target folder used as a template (by default `..\..\S4AHK_Test`) should be a pristine clone of the
SciTE4AutoHotkey repo with a few extra binary files (such as SciTE.exe or InternalAHK.exe, a renamed copy of AutoHotkeyU32.exe)
dropped in place.
