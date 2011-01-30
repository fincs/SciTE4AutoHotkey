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

The code is complete, except for the help file. The recommended "setup" procedure is fetching the repository somewhere, then making a symbolic link between %AhkDir%\SciTE and <repo-dir>\source. \*.exe, \*.dll, \*.chm, \*.bak and \*.db are already discarded by .gitignore.

Building SciTE4AutoHotkey
-------------------------

In order to do so, follow the instructions in the *scipatches* folder. When done building, copy the following files to the following locations:

* SciTE.exe and SciLexer.dll -> source/
* dbguihlp.dll -> source/debugger/

Afterwards, download the current [portable build](http://www.autohotkey.net/~fincs/SciTE4AutoHotkey_3/SciTE4AutoHotkey_v3_beta4_Portable.zip) in order to get some files from it:

* SciTE_beta4/SciTE.chm -> source/
* SciTE_beta4/tools/GenDocs/hha.dll and hha.exe -> source/tools/GenDocs/
* SciTE_beta4/tools/Rebranded/\*.\* -> source/tools/Rebranded/
