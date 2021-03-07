; Title:   	Console() - Customize your command prompt
; Link:   	autohotkey.com/boards/viewtopic.php?p=380328#p380328
; Author:	iseahound
; Date:   	06.02.2021
; for:     	AHK_L

/*


*/

PowerShell(subroutine, parameters*) {
   return Console("powershell -NoProfile -command " Chr(34) "& {" subroutine "}" Chr(34), parameters*)
}

; Return values:
;    positive integer    | Process ID of the launched process if successful.
;    ""                  | Error.
;    stdout              | Standard output if "stdout" is a parameter.
;    stderr              | Standard error if "stderr" is a parameter.
;    [pid,stdout,stderr] | An array at indexes 0, 1, and 2 if both "stdout" and "stderr" are input parameters.

Console(subroutine := "", parameters*) {
   Critical On ; Ensure that sub processes are closed properly.

   ; Get path of active window.
   _hwnd := WinExist("A")
   WinGetClass _class, ahk_id %_hwnd%
   if (_class == "ExploreWClass" || _class == "CabinetWClass")
      for window in ComObjCreate("Shell.Application").Windows
         if (window.hwnd == _hwnd)
            _path := try window.Document.Folder.Self.Path

   ; Parse parameters.
   for i, p in parameters {
      activate   := (p = "activate")   ? 1 : activate   ; Activates the console.
      admin      := (p = "admin")      ? 1 : admin      ; Elevates to administrator. Shows UAC prompt.
      bind       := (p = "bind")       ? 1 : bind       ; Forcefully quits all child processes when current script crashes or ends.
      cd         := (p = "cd")         ? 1 : cd         ; Launches from the script's current directory.
      debug      := (p = "debug")      ? 1 : debug      ; Shows the command to be run.
      exit       := (p = "exit")       ? 1 : exit       ; Runs command and then exits the console.
      hide       := (p = "hide")       ? 1 : hide       ; Hides the console.
      max        := (p ~= "i)^max")    ? 1 : max        ; Maximizes the console.
      min        := (p ~= "i)^min")    ? 1 : min        ; Minimizes the console.
      pause      := (p = "pause")      ? 1 : pause      ; Pauses the console after execution. Useful with 'exit'.
      run        := (p = "run")        ? 1 : run        ; Bypasses using a console and runs the executable directly.
      stderr     := (p = "stderr")     ? 1 : stderr     ; Returns the standard error. (If stderr & stdout are both selected an array will be returned.)
      stdout     := (p = "stdout")     ? 1 : stdout     ; Returns the standard output. (array[1] is stdout and array[2] is stderr.)
      wait       := (p = "wait")       ? 1 : wait       ; Waits for the command to execute completely before returning. Use 'exit'.
      working    := (p = "working")    ? 1 : working    ; Launches from the script's working directory.

      window_width     := (p ~= "i)window" && p ~= "i)width")     ? RegExReplace(p, "^.*(?<!\d)(\d+).*$", "$1")                                     : window_width
      window_height    := (p ~= "i)window" && p ~= "i)height")    ? RegExReplace(p, "^.*(?<!\d)(\d+).*$", "$1")                                     : window_height
      background_color := (p ~= "i)background" && p ~= "i)color") ? RegExReplace(p, "(?i)^.*([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})\b.*$", "0x$3$2$1") : background_color
      text_color       := (p ~= "i)text" && p ~= "i)color")       ? RegExReplace(p, "(?i)^.*([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})\b.*$", "0x$3$2$1") : text_color
      face_name        := (p ~= "i)face" && p ~= "i)name")        ? RegExReplace(p, "^.*(?<!\d)(\d+).*$", "$1")                                     : face_name
   }

   ; Process parameters.
   _color := background_color || text_color
   _cosmetic := window_width || window_height || background_color || text_color
   _output := stderr || stdout
   _path := (cd) ? A_ScriptDir : (working) ? A_WorkingDir : (_path) ? _path : A_Desktop
   _win := (hide) ? "hide" : (max) ? "max" : (min) ? "min" : ""

   ; Escape double quote character.
   static q := Chr(0x22)

   ; Construct the command to execute.
   ; Workaround: The flags "stdout" or "stderr" will suppress the "admin" flag when run from a user level script or else "AttachConsole" would fail.
   if (run)
      _cmd := (!A_IsAdmin && admin)        ? "*RunAs " subroutine       : subroutine
   else if (_output)
      _cmd := (_color)                     ? A_ComSpec " /U /K"         : A_ComSpec " /U /T:07 /K"
   else {
      _cmd .= (!A_IsAdmin && admin)        ? "*RunAs " A_ComSpec " /U " : A_ComSpec " /U "  ; Output unicode characters.
      _cmd .= (_color)                     ? "/T:07 "                   : ""                ; Sets the default colors to be modified later.
      _cmd .= (exit)                       ? "/C "                      : "/K "             ; Terminate or return to the prompt.
      _cmd .= (admin)                      ? "cd /d " q _path q " "     : ""                ; Manually change path if admin.
      _cmd .= (admin && subroutine != "")  ? "&& "                      : ""
      _cmd .= (subroutine != "")           ? subroutine                 : ""
      _cmd .= (pause)                      ? " && pause"                : ""
   }

   ; Show command for debugging.
   if (debug)
      MsgBox % _cmd

   ; Check for original registry keys in case this script crashed during a previous execution.
   RegRead _restore, HKCU\Console, % "(Backup)"

   ; Alter console registry keys for cosmetic purposes. https://devblogs.microsoft.com/commandline/understanding-windows-console-host-settings/
   if (_cosmetic && !run) {
      RegRead _window_size,      HKCU\Console, WindowSize
      RegRead _background_color, HKCU\Console, ColorTable00
      RegRead _text_color,       HKCU\Console, ColorTable07

      _backup .= "REG_DWORD,WindowSize,"    _window_size       "|"
      _backup .= "REG_DWORD,ColorTable00,"  _background_color  "|"
      _backup .= "REG_DWORD,ColorTable07,"  _text_color        "|"

      ; Store original registry keys and do not overwrite existing ones.
      if !(_restore)
         RegWrite % "REG_SZ", HKCU\Console, % "(Backup)", % _backup

      window_size := 0
      window_size |= (window_width) ? (window_width) : _window_size & 0xFFFF
      window_size |= (window_height) ? (window_height << 16) : _window_size & 0xFFFF0000

      RegWrite REG_DWORD, HKCU\Console, WindowSize,   % (window_size)      ? window_size      : _window_size
      RegWrite REG_DWORD, HKCU\Console, ColorTable00, % (background_color) ? background_color : _background_color
      RegWrite REG_DWORD, HKCU\Console, ColorTable07, % (text_color)       ? text_color       : _text_color
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
   if (_cosmetic && !run) OR (activate) OR (bind || (_output && exit)) OR (_output && !run) {
      WinWait ahk_pid %_pid%,, 12 ; Process Wait flashes a console occasionally.
      if (ErrorLevel)
         throw Exception("The application or console has already exited cannot be found."
         . "Remove the activate, bind, and exit parameters if this error persists.")
   }

   ; Restore original registry keys. Don't restore before window appears.
   if (_restore || _backup) {
      Loop Parse, % (_restore) ? _restore : _backup , % "|"
      {
         ___ := StrSplit(A_LoopField, ",")
         RegWrite % ___.1, HKCU\Console, % ___.2 , % ___.3
      }
      RegDelete HKCU\Console, % "(Backup)"
   }

   ; Activate the console.
   ; Known Issue: An elevated console cannot be activated by a user level script. Install AutoHotkey with UI access.
   if (activate)
      WinActivate ahk_pid %_pid%

   ; Ensures that the process executed has a fail-safe method of termination.
   ; Spawns an independent process that does two things:
   ; (1) Terminates the child process when this owner process is no longer running. (e.g. crashes or exits)
   ; (2) Exits when the child process exits.
   if (bind || (_output && exit)) {
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
   if (_output && !run) {
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