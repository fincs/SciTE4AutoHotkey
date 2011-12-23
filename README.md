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
* AutoHotkey_L debugging support
* Tools for AutoHotkey scripting
* A toolbar that enables easy access to the tools
* Some AutoHotkey scripting facilities

Git importing status
--------------------

Complete. The recommended "setup" procedure is fetching the repository somewhere, then making a symbolic link between %AhkDir%\SciTE and <repo-dir>\source. \*.exe, \*.dll, \*.chm, \*.bak and \*.db are already discarded by .gitignore.

Building SciTE4AutoHotkey
-------------------------

In order to do so, follow the instructions in the *scipatches* folder. When done building, copy SciTE.exe and SciLexer.dll to the /source folder.

Afterwards, download the current [portable build](http://www.autohotkey.net/~fincs/SciTE4AutoHotkey_3/SciTE4AutoHotkey_v3_beta5a_Portable.zip) in order to get some files from it:

* SciTE_beta5/tools/GenDocs/hha.dll and hha.exe -> source/tools/GenDocs/
* SciTE_beta5/tools/Rebranded/\*.\* -> source/tools/Rebranded/

You must also build the [documentation](https://github.com/fincs/SciTE4AHK-Docs) and place it in the source folder.

The latest AutoHotkey_L Unicode binary (v1.1.05.05 at the time of writing) also needs to be placed in the source folder.
