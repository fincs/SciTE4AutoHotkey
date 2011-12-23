SciTE/Scintilla 3.0.2 modified source code
=========================================

Patch instructions
------------------

In order to get the modified source code, download & extract the file scite302.tgz or scite302.zip to a new folder, open a command prompt, navigate to it and issue the following command:

    patch -p1 < path/to/S4AHK_v3rc1.patch

Build instructions
------------------

Use MSVC++ 2010 with the Windows 7.1 SDK to build everything. Open SciTE4AutoHotkey.sln, select the *Win32* or *x64* platform and the *Release* configuration then click on Build.
