### Remarks  
Wrapper for [AutoHotkey Docs - WinActivate](http://ahkscript.org/docs/commands/WinActivate.htm){_blank}.  
Static method.
		
If the window is minimized, it is automatically restored prior to being activated.

Six attempts will be made to activate the target window over the course of 60ms. Thus, it is usually unnecessary to follow WinActivate with [WinWaitActive](http://ahkscript.org/docs/commands/WinWaitActive.htm){_blank} or
[IfWinNotActive](http://ahkscript.org/docs/commands/WinActive.htm){_blank}.

If a matching window is already active, that window will be kept active rather than activating any other matching window beneath it.
In general, if more than one window matches, the topmost (most recently used) will be activated. You can activate the bottommost
(least recently used) via [WinActivateBottom](http://ahkscript.org/docs/commands/WinActivateBottom.htm){_blank}.

When a window is activated immediately after the activation of some other window, task bar buttons might start flashing on some
systems (depending on OS and settings). To prevent this, use
[#WinActivateForce](http://ahkscript.org/docs/commands/_WinActivateForce.htm){_blank}.

Window titles and text are case sensitive. Hidden windows are not detected unless
[DetectHiddenWindows](http://ahkscript.org/docs/commands/DetectHiddenWindows.htm){_blank} has been turned on.

See Also:[AutoHotkey Docs - WinActivate](http://ahkscript.org/docs/commands/WinActivate.htm){_blank}.