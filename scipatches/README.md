SciTE/Scintilla 3.2.3 modified source code
==========================================

Patch instructions
------------------

In order to get the modified source code, download & extract the file scite321.tgz or scite321.zip to a new folder, open a command prompt, navigate to it and issue the following command:

    patch -p1 < path/to/S4AHK_v3.0.01.patch

Build instructions
------------------

Use MSVC++ 2010/12 to build everything. Open SciTE4AutoHotkey.sln, select the *Win32* platform and the *Release* configuration then click on Build.
