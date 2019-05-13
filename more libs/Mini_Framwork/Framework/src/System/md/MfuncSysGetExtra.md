### Sub-commands  
Can be [MfString](MfString.html) instance or var containing string.

**MonitorCount**: Retrieves the total number of monitors. Unlike SM_CMONITORS mentioned in the table below,
MonitorCount includes all monitors, even those not being used as part of the desktop.

**MonitorPrimary**: Retrieves the number of the primary monitor, which will be 1 in a single-monitor system.

**Monitor [, N]**: Retrieves the bounding coordinates of monitor number **N** (if **N** is omitted, the primary monitor is used).
The information is stored in four variables whose names all start with OutputVar. If **N** is too high or there is a problem
retrieving the info, the variables are all made blank. For example:
> Mon2 := Mfunc.SysGet(*Monitor*, 2)
> MsgBox, Left: %Mon2Left% -- Top: %Mon2Top% -- Right: %Mon2Right% -- Bottom %Mon2Bottom%.
Within a [function](http://ahkscript.org/docs/Functions.htm){_blank}, to create a set of variables that is global
instead of local, [declare](http://ahkscript.org/docs/Functions.htm#Global){_blank} Mon2 as a global variable prior to using this
command (the converse is true for [assume-global](http://ahkscript.org/docs/Functions.htm#Global){_blank} functions).

**MonitorWorkArea [, N]**: Same as the above except the area is reduced to exclude the area occupied by the taskbar and other
registered desktop toolbars.

**MonitorName [, N]**: The operating system's name for monitor number **N** (if **N** is omitted, the primary monitor is used).

**(Numeric)**: Specify for Sub-command one of the numbers from the table below to retrieve the corresponding value.
The following example would store the number of mouse buttons in a variable named "MouseButtonCount" `MouseButtonCount := Mfunc.SysGet(43)`.

### Commonly Used  
* **80** - SM_CMONITORS: Number of display monitors on the desktop (not including "non-display pseudo-monitors").
* **43** - SM_CMOUSEBUTTONS: Number of buttons on mouse (0 if no mouse is installed).
* **16, 17** - SM_CXFULLSCREEN, SM_CYFULLSCREEN: Width and height of the client area for a full-screen window on the primary display monitor, in pixels.
* **61, 62** - SM_CXMAXIMIZED, SM_CYMAXIMIZED: Default dimensions, in pixels, of a maximized top-level window on the primary display monitor.
* **59, 60** - SM_CXMAXTRACK, SM_CYMAXTRACK: Default maximum dimensions of a window that has a caption and sizing borders, in pixels. This metric refers to the entire desktop. The user cannot drag the window frame to a size larger than these dimensions.
* **28, 29** - SM_CXMIN, SM_CYMIN: Minimum width and height of a window, in pixels.
* **57, 58** - SM_CXMINIMIZED, SM_CYMINIMIZED: Dimensions of a minimized window, in pixels.
* **34, 35** - SM_CXMINTRACK, SM_CYMINTRACK: Minimum tracking width and height of a window, in pixels. The user cannot drag the window frame to a size smaller than these dimensions. A window can override these values by processing the WM_GETMINMAXINFO message.
* **0, 1** - SM_CXSCREEN, SM_CYSCREEN: Width and height of the screen of the primary display monitor, in pixels. These are the same as the built-in variables [A_ScreenWidth](http://ahkscript.org/docs/Variables.htm#Screen){_blank} and [A_ScreenHeight](http://ahkscript.org/docs/Variables.htm#Screen){_blank}.
* **78, 79** - SM_CXVIRTUALSCREEN, SM_CYVIRTUALSCREEN: Width and height of the virtual screen, in pixels. The virtual screen is the bounding rectangle of all display monitors. The SM_XVIRTUALSCREEN, SM_YVIRTUALSCREEN metrics are the coordinates of the top-left corner of the virtual screen.
* **19** - SM_MOUSEPRESENT: Nonzero if a mouse is installed; zero otherwise.
* **75** - SM_MOUSEWHEELPRESENT: Nonzero if a mouse with a wheel is installed; zero otherwise.
* **63** - SM_NETWORK: Least significant bit is set if a network is present; otherwise, it is cleared. The other bits are reserved for future use.
* **8193** - SM_REMOTECONTROL: This system metric is used in a Terminal Services environment. Its value is nonzero if the current session is remotely controlled; zero otherwise.
* **4096** - SM_REMOTESESSION: This system metric is used in a Terminal Services environment. If the calling process is associated with a Terminal Services client session, the return value is nonzero. If the calling process is associated with the Terminal Server console session, the return value is zero. The console session is not necessarily the physical console.
* **70** - SM_SHOWSOUNDS: Nonzero if the user requires an application to present information visually in situations where it would otherwise present the information only in audible form; zero otherwise.
* **8192** - SM_SHUTTINGDOWN: Nonzero if the current session is shutting down; zero otherwise. Windows 2000: The retrieved value is always 0.
* **23** - SM_SWAPBUTTON: Nonzero if the meanings of the left and right mouse buttons are swapped; zero otherwise.
* **76, 77** - SM_XVIRTUALSCREEN, SM_YVIRTUALSCREEN: Coordinates for the left side and the top of the virtual screen. The virtual screen is the bounding rectangle of all display monitors. By contrast, the SM_CXVIRTUALSCREEN, SM_CYVIRTUALSCREEN metrics (further above) are the width and height of the virtual screen.

### Not Commonly Used  
* **56** - SM_ARRANGE: Flags specifying how the system arranged minimized windows. See MSDN for more information.
* **67** - SM_CLEANBOOT: Specifies how the system was started:  
[class_tab]0. Normal boot[/]  
[class_tab]1. Fail-safe boot[/]  
[class_tab]2. Fail-safe with network boot[/]
* **5, 6** - SM_CXBORDER, SM_CYBORDER: Width and height of a window border, in pixels. This is equivalent to the SM_CXEDGE value for windows with the 3-D look.
* **13, 14** - SM_CXCURSOR, SM_CYCURSOR: Width and height of a cursor, in pixels. The system cannot create cursors of other sizes.
* **36, 37** - SM_CXDOUBLECLK, SM_CYDOUBLECLK: Width and height of the rectangle around the location of a first click in a double-click sequence, in pixels. The second click must occur within this rectangle for the system to consider the two clicks a double-click. (The two clicks must also occur within a specified time.)
* **68, 69** - SM_CXDRAG, SM_CYDRAG: Width and height of a rectangle centered on a drag point to allow for limited movement of the mouse pointer before a drag operation begins. These values are in pixels. It allows the user to click and release the mouse button easily without unintentionally starting a drag operation.
* **45, 46** - SM_CXEDGE, SM_CYEDGE: Dimensions of a 3-D border, in pixels. These are the 3-D counterparts of SM_CXBORDER and SM_CYBORDER.
* **7, 8** - SM_CXFIXEDFRAME, SM_CYFIXEDFRAME (synonymous with SM_CXDLGFRAME, SM_CYDLGFRAME): Thickness of the frame around the perimeter of a window that has a caption but is not sizable, in pixels. SM_CXFIXEDFRAME is the height of the horizontal border and SM_CYFIXEDFRAME is the width of the vertical border.
* **83, 84** - SM_CXFOCUSBORDER, SM_CYFOCUSBORDER: Width (in pixels) of the left and right edges and the height of the top and bottom edges of a control's focus rectangle. Windows 2000: The retrieved value is always 0.
* **21, 3** - SM_CXHSCROLL, SM_CYHSCROLL: Width of the arrow bitmap on a horizontal scroll bar, in pixels; and height of a horizontal scroll bar, in pixels.
* **10** - SM_CXHTHUMB: Width of the thumb box in a horizontal scroll bar, in pixels.
* **11, 12** - SM_CXICON, SM_CYICON: Default width and height of an icon, in pixels.
* **38, 39** - SM_CXICONSPACING, SM_CYICONSPACING: Dimensions of a grid cell for items in large icon view, in pixels. Each item fits into a rectangle of this size when arranged. These values are always greater than or equal to SM_CXICON and SM_CYICON.
* **71, 72** - SM_CXMENUCHECK, SM_CYMENUCHECK: Dimensions of the default menu check-mark bitmap, in pixels.
* **54, 55** - SM_CXMENUSIZE, SM_CYMENUSIZE: Dimensions of menu bar buttons, such as the child window close button used in the multiple document interface, in pixels.
* **47, 48** - SM_CXMINSPACING SM_CYMINSPACING: Dimensions of a grid cell for a minimized window, in pixels. Each minimized window fits into a rectangle this size when arranged. These values are always greater than or equal to SM_CXMINIMIZED and SM_CYMINIMIZED.
* **30, 31** - SM_CXSIZE, SM_CYSIZE: Width and height of a button in a window's caption or title bar, in pixels.
* **32, 33** - SM_CXSIZEFRAME, SM_CYSIZEFRAME: Thickness of the sizing border around the perimeter of a window that can be resized, in pixels. SM_CXSIZEFRAME is the width of the horizontal border, and SM_CYSIZEFRAME is the height of the vertical border. Synonymous with SM_CXFRAME and SM_CYFRAME.
* **49, 50** - SM_CXSMICON, SM_CYSMICON: Recommended dimensions of a small icon, in pixels. Small icons typically appear in window captions and in small icon view.
* **52, 53** - SM_CXSMSIZE SM_CYSMSIZE: Dimensions of small caption buttons, in pixels.
* **2, 20** - SM_CXVSCROLL, SM_CYVSCROLL: Width of a vertical scroll bar, in pixels; and height of the arrow bitmap on a vertical scroll bar, in pixels.
* **4** - SM_CYCAPTION: Height of a caption area, in pixels.
* **18** - SM_CYKANJIWINDOW: For double byte character set versions of the system, this is the height of the Kanji window at the bottom of the screen, in pixels.
* **15** - SM_CYMENU: Height of a single-line menu bar, in pixels.
* **51** - SM_CYSMCAPTION: Height of a small caption, in pixels.
* **9** - SM_CYVTHUMB: Height of the thumb box in a vertical scroll bar, in pixels.
* **42** - SM_DBCSENABLED: Nonzero if User32.dll supports DBCS; zero otherwise.
* **22** - SM_DEBUG: Nonzero if the debug version of User.exe is installed; zero otherwise.
* **82** - SM_IMMENABLED: Nonzero if Input Method Manager/Input Method Editor features are enabled; zero otherwise.
[class_tab_block]SM_IMMENABLED indicates whether the system is ready to use a Unicode-based IME on a Unicode application. To ensure that a language-dependent IME works, check SM_DBCSENABLED and the system ANSI code page. Otherwise the ANSI-to-Unicode conversion may not be performed correctly, or some components like fonts or registry setting may not be present.[/]
* **87** - SM_MEDIACENTER: Nonzero if the current operating system is the Windows XP, Media Center Edition, zero if not.
* **40** - SM_MENUDROPALIGNMENT: Nonzero if drop-down menus are right-aligned with the corresponding menu-bar item; zero if the menus are left-aligned.
* **74** - SM_MIDEASTENABLED: Nonzero if the system is enabled for Hebrew and Arabic languages, zero if not.
* **41** - SM_PENWINDOWS: Nonzero if the Microsoft Windows for Pen computing extensions are installed; zero otherwise.
* **44** - SM_SECURE: Nonzero if security is present; zero otherwise.
* **81** - SM_SAMEDISPLAYFORMAT: Nonzero if all the display monitors have the same color format, zero otherwise. Note that two displays can have the same bit depth, but different color formats. For example, the red, green, and blue pixels can be encoded with different numbers of bits, or those bits can be located in different places in a pixel's color value.
* **86** - SM_TABLETPC: Nonzero if the current operating system is the Windows XP Tablet PC edition, zero if not.

### Remarks  
Wrapper for [AutoHotkey Docs - SysGet](http://ahkscript.org/docs/commands/SysGet.htm){_blank}.  
Static method.
		
The built-in variables [A_ScreenWidth](http://ahkscript.org/docs/Variables.htm#Screen){_blank} and
[A_ScreenHeight](http://ahkscript.org/docs/Variables.htm#Screen){_blank} contain the dimensions of the primary monitor, in pixels.

Any and/or all parameter for this function can be instance of [MfString](MfString.html) or var containing string.

See Also:[AutoHotkey Docs - SysGet](http://ahkscript.org/docs/commands/SysGet.htm){_blank}.