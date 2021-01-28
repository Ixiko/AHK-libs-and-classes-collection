; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=31273&sid=f891fce1bd8f3e596149c2d0565fa3bd

; Return values:
;    pid                 | Process ID of the launched process if successful.
;    stdout              | Standard output if "stdout" is a parameter.
;    stderr              | Standard error if "stderr" is a parameter.
;    [pid,stdout,stderr] | An array at indexes 0, 1, and 2 if both "stdout" and "stderr" are input parameters.
;    ""                  | Error.

/* DESCRIPTION

   Console() lets you customize your command prompt the way you like it. By default, the console will open in the current folder you are browsing.

   Material Theme | Console(, "background color #282D3F", "text color #959DCB")
   Image

   Examples:
   Launches cmd.exe | Console()
   Powershell with white text on bluish-green background. | Console("powershell", "background color #259184", "text color #FFFFFF", "window width 200", "window height 10")
   Administrator Powershell | Console("powershell", "admin")
   Flush DNS | Console("ipconfig /FlushDNS", "pause", "exit")

   Advanced Examples:
   Finds your external IP address | Console("nslookup myip.opendns.com. resolver1.opendns.com", "pause", "exit")
   Finds your external IP address and pings it | Console("ping -t " RegExReplace(Console("nslookup myip.opendns.com. resolver1.opendns.com", "stdout", "hide", "exit"),"s)^.*?(?<value>\b((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])(\.|\b)){4}\b)(?!\s*Name).*$","${value}"))
   Save stdout to a variable | MsgBox % stdout := Console("dir /?", "stdout", "hide", "exit")

   Cosmetic Parameters:
   window width 200 - Changes the window width to 200 characters. (Note: that there is a minimum window width that can not be exceeded.)
   window height 10 - Changes the window height to 10 lines.
   background color 259184 - Changes the background color to bluish-green. Prefixing the color value with # or 0x does not matter.
   text color FFFFFF - Changes the text color to white.

   Functional Parameters:
   activate - Activates the console.
   admin - Elevates to administrator. Shows UAC prompt.
   bind - Forcefully quits all child processes when current script crashes or ends.
   debug - Shows the command to be run.
   exit - Runs command and then exits the console.
   hide - Hides the console.
   max - Maximizes the console.
   min - Minimizes the console.
   pause - Pauses the console after execution. Useful with exit.
   root - Launches from the script's current directory.
   run - Bypasses using a console and runs the executable directly.
   stderr - Returns the standard error.
   stdout - Returns the standard output.
   wait -Waits for the command to execute completely before returning. Use exit.

   Return values:
   pid - Returns the process ID if stdout and stderr are not parameters.
   stdout - The standard out is returned when it is a parameter.
   stderr - The standard error is returned when it is a parameter.
   [pid,stdout,stderr] - An array at indexes 0, 1, and 2 if both stdout and stderr are input parameters.
   "" - Returns an empty string if unsuccessful. For example if the user presses "No" at the UAC elevation prompt.

*/

Console(subroutine := "", parameters*) {
      Critical On ; Ensure that sub processes are closed properly.

   ; Get path of active window.
   _hwnd := WinExist("A")
   WinGetClass _class, ahk_id %_hwnd%
   if (_class == "ExploreWClass" || _class == "CabinetWClass")
      for window in ComObjCreate("Shell.Application").Windows
         if (window.hwnd == _hwnd)
            _path := try window.Document.Folder.Self.Path

   ; Check for original registry keys in case this script crashed during a previous execution.
   RegRead _restore, % "HKEY_CURRENT_USER\Console", % "(Backup)"

   ; Parse parameters.
   for i, p in parameters {
      activate := (p = "activate") ? 1 : activate   ; Activates the console.
      admin    := (p = "admin")    ? 1 : admin      ; Elevates to administrator. Shows UAC prompt.
      bind     := (p = "bind")     ? 1 : bind       ; Forcefully quits all child processes when current script crashes or ends.
      debug    := (p = "debug")    ? 1 : debug      ; Shows the command to be run.
      exit     := (p = "exit")     ? 1 : exit       ; Runs command and then exits the console.
      hide     := (p = "hide")     ? 1 : hide       ; Hides the console.
      max      := (p ~= "i)^max")  ? 1 : max        ; Maximizes the console.
      min      := (p ~= "i)^min")  ? 1 : min        ; Minimizes the console.
      pause    := (p = "pause")    ? 1 : pause      ; Pauses the console after execution. Useful with 'exit'.
      root     := (p = "root")     ? 1 : root       ; Launches from the script's current directory.
      run      := (p = "run")      ? 1 : run        ; Bypasses using a console and runs the executable directly.
      stderr   := (p = "stderr")   ? 1 : stderr     ; Returns the standard error. (If stderr & stdout are both selected an array will be returned.)
      stdout   := (p = "stdout")   ? 1 : stdout     ; Returns the standard output. (array[1] is stdout and array[2] is stderr.)
      wait     := (p = "wait")     ? 1 : wait       ; Waits for the command to execute completely before returning. Use 'exit'.

      window_width     := (p ~= "i)window" && p ~= "i)width")     ? RegExReplace(p, "^.*(?<!\d)(\d+).*$", "$1")                                     : window_width
      window_height    := (p ~= "i)window" && p ~= "i)height")    ? RegExReplace(p, "^.*(?<!\d)(\d+).*$", "$1")                                     : window_height
      background_color := (p ~= "i)background" && p ~= "i)color") ? RegExReplace(p, "(?i)^.*([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})\b.*$", "0x$3$2$1") : background_color
      text_color       := (p ~= "i)text" && p ~= "i)color")       ? RegExReplace(p, "(?i)^.*([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})\b.*$", "0x$3$2$1") : text_color
   }

   ; Process parameters.
   _color := background_color || text_color
   _cosmetic := window_width || window_height || background_color || text_color
   _return := stderr || stdout
   _path := (root) ? A_ScriptDir : (_path) ? _path : A_Desktop
   _win := (hide) ? "hide" : (max) ? "max" : (min) ? "min" : ""

   ; Escape double quote character.
   static q := Chr(0x22)

   ; Construct the command to execute.
   ; Workaround: A "stdout" or "stderr" console is not allowed to be elevated as admin consoles cannot be attached to user scripts.
   if (run) {
      _cmd := (admin)                                  ? "*RunAs " subroutine     : subroutine
   } else {
      _cmd .= (admin && (A_IsAdmin || !_return))       ? "*RunAs " ComSpec " /U"  : ComSpec " /U"   ; Output unicode characters.
      _cmd .= (_color)                                 ? " /T:0a "                : ""              ; Sets the default colors to be modified later.
      _cmd .= (exit && !_return)                       ? " /C "                   : " /K "          ; Terminate or return to the prompt.
      _cmd .= (admin)                                  ? "cd /d " q _path q " "   : ""              ; Manually change path if admin.
      _cmd .= (admin && subroutine != "" && !_return)  ? " && "                   : ""
      _cmd .= (subroutine != "" && !_return)           ? subroutine               : ""
      _cmd .= (pause && !_return)                      ? " && pause"              : ""
   }

   ; Show command for debugging.
   if (debug)
      MsgBox % _cmd

   ; Alter console registry keys for cosmetic purposes.
   if (_cosmetic && !run) {
      RegRead _window_size,      % "HKEY_CURRENT_USER\Console", % "WindowSize"
      RegRead _background_color, % "HKEY_CURRENT_USER\Console", % "ColorTable00"
      RegRead _text_color,       % "HKEY_CURRENT_USER\Console", % "ColorTable10"

      _backup .= "REG_DWORD,WindowSize,"   _window_size      "|"
      _backup .= "REG_DWORD,ColorTable00," _background_color "|"
      _backup .= "REG_DWORD,ColorTable10," _text_color

      ; Store original registry keys and do not overwrite existing ones.
      if !(_restore)
         RegWrite % "REG_SZ", % "HKEY_CURRENT_USER\Console", % "(Backup)", % _backup

      window_size := 0
      window_size |= (window_width) ? (window_width) : _window_size & 0xFFFF
      window_size |= (window_height) ? (window_height << 16) : _window_size & 0xFFFF0000

      RegWrite % "REG_DWORD", % "HKEY_CURRENT_USER\Console", % "WindowSize",   % (window_size)      ? window_size      : _window_size
      RegWrite % "REG_DWORD", % "HKEY_CURRENT_USER\Console", % "ColorTable00", % (background_color) ? background_color : _background_color
      RegWrite % "REG_DWORD", % "HKEY_CURRENT_USER\Console", % "ColorTable10", % (text_color)       ? text_color       : _text_color
   }

   ; Ensures that 32-bit AutoHotkey opens a 32-bit console.
   ; Workaround: Redirection is disabled for elevated consoles because RunAs fails to escalate in 32-bit console on 64-bit OS.
   if (!admin && A_Is64bitOS && A_PtrSize == 4)
      DllCall("Wow64DisableWow64FsRedirection", "ptr*", _oldRedirectionValue)

   ; Execute. Errors will fail silently due to "try".
   if (wait)
      try RunWait % _cmd, % _path, % _win, _pid
      catch
         return
   else
      try Run % _cmd, % _path, % _win, _pid
      catch
         return

   ; Restore SysWow64 redirection when running as 32-bit AutoHotkey on 64-bit OS.
   if (_oldRedirectionValue)
      if !DllCall("Wow64RevertWow64FsRedirection", "ptr", _oldRedirectionValue)
         throw Exception("SysWow64 redirection failed.")

   ; Allow detection of hidden consoles.
   _dhw := A_DetectHiddenWindows
   DetectHiddenWindows On

   ; Prevent a race condition.
   if (_cosmetic && !run) OR (activate) OR (bind || (_return && exit)) OR (_return && !run) {
      WinWait ahk_pid %_pid%,, 12 ; Process Wait flashes a console occasionally.
      if (ErrorLevel)
         throw Exception("The application or console has already exited cannot be found."
         . "Remove the activate, bind, and exit parameters if this error persists.")
   }

   ; Restore original registry keys.
   if (_restore || _backup) {
      Loop Parse, % (_restore) ? _restore : _backup , % "|"
      {
         ___ := StrSplit(A_LoopField, ",")
         RegWrite % ___.1, % "HKEY_CURRENT_USER\Console", % ___.2 , % ___.3
      }
      RegDelete % "HKEY_CURRENT_USER\Console", % "(Backup)"
   }

   ; Activate the console.
   ; Known Issue: An elevated console cannot be activated by a user level script. Install AutoHotkey with UI access.
   if (activate)
      WinActivate ahk_pid %_pid%

   ; Ensures that the process executed has a fail-safe method of termination.
   ; Spawns an independent process that does two things:
   ; (1) Terminates the child process when this owner process is no longer running. (e.g. crashes or exits)
   ; (2) Exits when the child process exits.
   if (bind || (_return && exit)) {
      VarSetCapacity(_process, 2048)
      DllCall("GetModuleFileName", "int", 0, "str", _process) ; Get name of current process.
      SplitPath _process,,,, _process
      ; Memory usage: Slowly climbs and stabilizes to 8196 KB from my testing.
      ;_bind := Comspec " /q /c for /L %n in (1,0,10) do (timeout /t 1 1>NUL && (tasklist /FI " q "PID eq "
      ;      . DllCall("GetCurrentProcessId") q " 2>NUL | find /I /N " q _process q " 1>NUL || TASKKILL /PID "
      ;      . _pid " /F 2>NUL) & (tasklist /FI " q "PID eq " _pid q " 2>NUL | find /I /N " q _pid q " 1>NUL || exit))"
      _bind := "powershell -NoProfile -command " q "& {Do {if (Get-Process -id " DllCall("GetCurrentProcessId")
               . " | where {$_.Processname -eq '" _process "'}) {sleep 1} else {Get-Process -id " _pid
               . " | foreach {$_.CloseMainWindow(); Stop-Process -id $_.id}}} while (Get-Process -id " _pid ")}" q
      Run % _bind,, hide
      VarSetCapacity(_process, 0)
   }

   ; If "stdout" or "stderr" is passed, attach to the console, and run the subroutine using that console host.
   if (_return && !run) {
      DllCall("AttachConsole", "uint", _pid)                  ; Attaching a hidden console prevents flashes.
      objShell := ComObjCreate("WScript.Shell")               ; Will allocate a new console if needed causing flashes.
      objExec := objShell.Exec(ComSpec " /C " q subroutine q) ; Windows 7: Don't call subroutine directly.
      while (!objExec.Status)
         Sleep 10
      _stdout := objExec.StdOut.ReadAll()
      _stderr := objExec.StdErr.ReadAll()
      DllCall("FreeConsole")
      Process Close, % _pid                                   ; Better than PostMessage and WinClose.
   }

   ; Restore global script settings.
   DetectHiddenWindows %_dhw%
   Critical Off

   ; Returns an array only if both stdout and stderr are wanted. Otherwise returns stdout, stderr, or the process ID.
   return (stdout && stderr) ? {0:_pid, 1:_stdout, 2:stderr} : (stdout) ? _stdout : (stderr) ? _stderr : _pid
}