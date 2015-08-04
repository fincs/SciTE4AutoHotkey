SciTE/Scintilla 3.6.0 modified source code
==========================================

Patch instructions
------------------

In order to get the modified source code, download & extract the file scite360.tgz to a new folder, open a command prompt, navigate to it and issue the following command:

    patch -p1 < path/to/S4AHK.patch

Build instructions
------------------

Use MSVC++ 2015 to build everything. Open SciTE4AutoHotkey.sln, select the *Win32* platform and the *Release* configuration then click on Build.
