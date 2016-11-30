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

Building SciTE4AutoHotkey
-------------------------

First, SciTE4AutoHotkey must be cloned using the following command to ensure all submodules are also cloned:

	git clone --recursive https://github.com/fincs/SciTE4AutoHotkey

Afterwards build SciTE/Scintilla by following the instructions in the *scipatches* folder. When done building, copy SciTE.exe and SciLexer.dll to the /source folder.

You must also build the [documentation](https://github.com/fincs/SciTE4AHK-Docs) and place it in the source folder.

The latest AutoHotkey Unicode 32-bit binary also needs to be placed in the source folder, as `InternalAHK.exe`.
