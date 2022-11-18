class ProcessInfo
{
    FromPID(pid) {
        ; (PROCESS_QUERY_LIMITED_INFORMATION := 0x1000) | (SYNCHRONIZE := 0x100000)
        if !hproc := DllCall("OpenProcess", "uint", 0x101000, "int", false, "uint", pid, "ptr")
            return
        return {handle: hproc, base: this}
    }
    
    __Delete() {
        DllCall("CloseHandle", "ptr", this.handle)
    }
    
    Exists {
        get {
            ; (WAIT_TIMEOUT := 258)
            return DllCall("WaitForSingleObject", "ptr", this.handle, "uint", 0) = 258
        }
    }
    
    ExitCode {
        get {
            return this.Exists ? "" : DllCall("GetExitCodeProcess", "ptr", this.handle, "int*", exitCode) ? exitCode : 0
        }
    }
}