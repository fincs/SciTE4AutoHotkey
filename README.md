SciTE4AutoHotkey
================

Introduction
------------

SciTE4AutoHotkey is a SciTE-based AutoHotkey script editor. It offers:

* Syntax highlighting
* Code folding
* Calltips (also known as IntelliSense)
* AutoComplete
* AutoIndent
* AutoHotkey help integration
* Abbreviations
* Debugging support
* Tools for AutoHotkey scripting
* A toolbar that enables easy access to the tools
* Some AutoHotkey scripting facilities

Git importing status
--------------------

Complete. The recommended "setup" procedure is fetching the repository somewhere. \*.exe, \*.dll, \*.chm, \*.bak and \*.db are already discarded by .gitignore.

Building SciTE4AutoHotkey
-------------------------

In order to do so, follow the instructions in the *scipatches* folder. When done building, copy SciTE.exe and SciLexer.dll to the /source folder.

GenDocs v3.0 must be placed in a SciTE/tools/GenDocs/ folder.

You must also build the [documentation](https://github.com/fincs/SciTE4AHK-Docs) and place it in the source folder.

The latest AutoHotkey Unicode 32-bit binary also needs to be placed in the source folder, as `InternalAHK.exe`.
