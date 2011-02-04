SciTE/Scintilla 2.23 modified source code
=========================================

Patch instructions
------------------

In order to get the modified source code, download & extract the file scite224.tgz or scite224.zip to a new folder, open a command prompt, navigate to it and issue the following command:

    patch -p1 < path/to/S4AHK_v3b5.patch

The source for dbguihlp.dll is also included in this patch.

Build instructions
------------------

### 32-bit version

Use MinGW to build everything. In order to do that, use the provided batch files. dbguihlp has not got a batch file, so use the instructions in the comments. Newer versions also require the use of `-static-libgcc` in order to remove the libgcc.dll dependency.

### 64-bit version

Use MSVC++ 2010 with the Windows 7.1 SDK to build everything. Open SciTE4AutoHotkey.sln, select the *x64* platform and the *Release* configuration then click on Build.