SciTE/Scintilla 3.2.1 modified source code
==========================================

Patch instructions
------------------

In order to get the modified source code, download & extract the file scite321.tgz or scite321.zip to a new folder, open a command prompt, navigate to it and issue the following command:

    patch -p1 < path/to/S4AHK_v3.0.00.patch

Build instructions
------------------

Use MSVC++ 2010/12 with the Windows 7.1 SDK to build everything. Open SciTE4AutoHotkey.sln, select the *Win32* or *x64* platform and the *Release* configuration then click on Build.
