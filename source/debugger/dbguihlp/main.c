// SciTE4AutoHotkey v3 Lua message pumper 1.0
// Build with: gcc -shared -o module.dll -I..\lualib\src main.c scite.la
// You've got to have a Lua distribution at ..\lualib (creates the src folder)
// for this to work.
// Also copy the scite.* files from http://luaforge.net/frs/download.php/3293/scite-debug.zip (scite.la, scite.def and scite.lib)

// Includes
#include <windows.h> // Windows include
#include <tchar.h>
#include "lauxlib.h" // Lua include

// Some defines
#define DllExport __declspec(dllexport)
#define RET_OK 1
#define RET_FAIL 0
#define MAX_TITLE 255
#define ADDFUNC(a) lua_register(L, #a, lib_##a)

// Those defines may not be present
#ifndef PROCESS_VM_OPERATION
#define PROCESS_VM_OPERATION 0x0008
#endif
#ifndef PROCESS_VM_READ
#define PROCESS_VM_READ 0x0010
#endif
#ifndef PROCESS_VM_WRITE
#define PROCESS_VM_WRITE 0x0020
#endif
#ifndef MEM_COMMIT
#define MEM_COMMIT 0x1000
#endif
#ifndef PAGE_READWRITE
#define PAGE_READWRITE 4
#endif
#ifndef MEM_RELEASE
#define MEM_RELEASE 0x8000
#endif

// Global variables
HWND cWindow = 0, tWindow = 0;
const char* cWinTitle; // variable pointer to constant char

// For IsHungAppWindowProc()
typedef BOOL (*IWAPtype)(HWND);
IWAPtype IsHungAppWindowProc;

// Dummy function that always returns false
BOOL _lib_ishungapp(HWND hWnd){ return 0; }

// Initializes the IsHungAppWindow() function.
void _lib_initprocs(){
	HMODULE user32 = LoadLibrary(_T("user32"));
	IsHungAppWindowProc = (IWAPtype) GetProcAddress(user32, "IsHungAppWindow");
	if(!IsHungAppWindowProc)
		IsHungAppWindowProc = (IWAPtype) _lib_ishungapp;
}

// Private callback function to enumerate the windows.
BOOL CALLBACK _lib_winsearchproc(HWND hWnd, LPARAM lParam){
	char wTitle[MAX_TITLE+1];
	// Get window title
	GetWindowTextA(hWnd, wTitle, MAX_TITLE);
	if(!strncmp(wTitle, cWinTitle, lParam)){
		// Window found.
		cWindow = hWnd;
		return 0; // Cancel the enumeration
	}
	return 1; // Continue enumerating the windows
}

// localizewin(wintitle) -- Localizes the window with the specified window title to
//  further send messages to it. True = sucess, false = failure.
int lib_localizewin(lua_State* L){
	// set the global variables
	cWinTitle = luaL_checkstring(L, 1);
	tWindow = cWindow, cWindow = 0;

	// look for the window
	EnumWindows((WNDENUMPROC)_lib_winsearchproc, strlen(cWinTitle));
	if(!cWindow){ // no window found?
		// just restore the old window and return false.
		cWindow = tWindow;
		lua_pushboolean(L, RET_FAIL);
		return 1;
	}
	// return true.
	lua_pushboolean(L, RET_OK);
	return 1;
}

// pumpmsg(msg, wparam, lparam) -- Sends a message to the current window.
//  Timeout of 8 seconds. It returns the value that the window returns.
int lib_pumpmsg(lua_State* L){
	int result;

	// get the parameters
	int iMsg = luaL_checkint(L, 1);
	int wParam = luaL_checkint(L, 2);
	int lParam = luaL_checkint(L, 3);

	if(!IsWindow(cWindow)) // invalid window?
		return luaL_error(L, "Invalid window handle.");
	if(IsHungAppWindowProc(cWindow))
		return luaL_error(L, "The window appears to be hung. Aborting...");

	// just dispatch the message to the window
	result = (int) SendMessageA(cWindow, (UINT)iMsg, (WPARAM)wParam, (LPARAM)lParam);
	
	// return the number that the window gave to us
	lua_pushinteger(L, result);
	return 1;
}

// pumpmsg(msg, wparam, lparam) -- Sends a message with lparam as string to the current window.
//  Timeout of 8 seconds. It returns the value that the window returns.
int lib_pumpmsgstr(lua_State* L){
	DWORD pID;
	HANDLE hProcess;
	void* rlParam;
	int result;

	// get the parameters
	int iMsg = luaL_checkint(L, 1);
	int wParam = luaL_checkint(L, 2);
	const char* lParam = luaL_checkstring(L, 3);
	// get the string length
	size_t lParamSize = strlen(lParam) + 1;

	if(!IsWindow(cWindow)) // invalid window?
		return luaL_error(L, "Invalid window handle.");
	if(IsHungAppWindowProc(cWindow))
		return luaL_error(L, "The window appears to be hung. Aborting...");

	// inject the string at the process.
	GetWindowThreadProcessId(cWindow, &pID);
	hProcess = OpenProcess(PROCESS_VM_OPERATION | PROCESS_VM_READ | PROCESS_VM_WRITE, 0, pID);
	if(!hProcess)
		return luaL_error(L, "Couldn't open the memory of the window!");
	rlParam = VirtualAllocEx(hProcess, 0, lParamSize, MEM_COMMIT, PAGE_READWRITE);
	if(!rlParam)
		return luaL_error(L, "Couldn't allocate the memory at the window!");
	if(!WriteProcessMemory(hProcess, rlParam, lParam, lParamSize, NULL))
		return luaL_error(L, "Couldn't inject the string parameter at the window!");

	// just dispatch the message to the window
	result = (int) SendMessageA(cWindow, (UINT)iMsg, (WPARAM)wParam, (LPARAM)rlParam);

	// free the memory used by the string
	if(!VirtualFreeEx(hProcess, rlParam, 0, MEM_RELEASE))
		return luaL_error(L, "Failed to free the memory at the window!");
	if(!CloseHandle(hProcess))
		return luaL_error(L, "Couldn't close the process handle!");

	// return the number that the window gave to us
	lua_pushinteger(L, result);
	return 1;
}

DllExport int libinit(lua_State* L){
	// initialize the IsHungAppWindowProc() function
	_lib_initprocs();
	// add the following functions to the Lua engine
	ADDFUNC(localizewin);
	ADDFUNC(pumpmsg);
	ADDFUNC(pumpmsgstr);
	return 0;
}
