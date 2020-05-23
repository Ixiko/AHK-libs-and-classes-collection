/*
Window Tiling system
Takes the default windows (Win+Arrow) hotkeys and makes them a bit better
Adds the ability to Tile windows into quarters / halves on both axes
Win+Alt+Arrow can be used to force a monitor change
Also adds a Win+Wheel hotkey to cycle between windows in the same Tile
*/
OutputDebug DBGVIEWCLEAR
#SingleInstance force
te := new TileEngine()
 
; Set monitor positions.
; The opposite (ie dest to source) is automatically added also
; My monitor order (L to R) : 1, 4, 2, 5, 3
;~ te.SetMonitorPosition(1, "West", 2)	; Monitor 1 is to the West of monitor 4
;~ te.SetMonitorPosition(2, "West", 4)	; Monitor 4 is to the West of monitor 2
;~ te.SetMonitorPosition(5, "East", 4)	; Monitor 5 is to the East of monitor 3
;~ te.SetMonitorPosition(3, "East", 5)	; Monitor 3 is to the East of monitor 2
;~ te.SetMonitorPosition(1, "East", 3)	; Monitor 1 is to the East of monitor 3 (Enable wrap)
 
;~ ; [1, 3, 2] order....
;te.SetMonitorPosition(1, "West", 3)	; Monitor 1 is to the West of monitor 2
;te.SetMonitorPosition(3, "West", 2)	; Monitor 3 is to the East of monitor 2
;te.SetMonitorPosition(1, "East", 2)	; Monitor 3 is to the East of monitor 2
;te.SetMonitorPosition(3, "East", 1)	; Monitor 1 is to the East of monitor 3 (Enable wrap)
;~ te.SetMonitorPosition(1, "West", 3)	; Monitor 1 is to the West of monitor 2

te.SetMonitorPosition(1, "West", 2)	; Monitor 1 is to the West of monitor 2
te.SetMonitorPosition(2, "East", 1)	; Monitor 3 is to the East of monitor 2
;
; A note about terms
; Vectors (eg {x:-1, y:0} meaning spanned along the left side of the monitor, aka "west")
; These are used to represent tile positions in a mathematical way that can be compared, altered etc
; For x, -1 is left, 1 is right. For y, -1 is up, 1 is down.
 
; Vector (eg {axis: "x", dir: -1} meaning "west" or "left")
; This is used for input or move calculations (in combination with Vectors arrays)
 
; "Compass" (ie n,e,s,w,ne,se,sw,nw)
; These are used where one "key" is needed to represent a tile's location
 
; Main class
Class TileEngine extends TileEngineBase {
	windows := {}
	monitors := []
	MonitorMap := {}
	MonitorCount := 0
	MonitorPrimary := 0
 
	__New(){
		static DirectionKeys := {x: {-1: "#Left", 1: "#Right"}, y: {-1: "#Up", 1: "#Down"}}
		static CycleKeys := {-1: "#WheelUp", 1: "#WheelDown"}
		static MonitorModifier := "+"
		static SwitchModifier := "^"
 
		this.log("Starting up")
 
		CoordMode, Caret, Screen
		CoordMode, Mouse, Screen
 
		Gui +Hwndhwnd
		this.hwnd := hwnd
		;~ DllCall( "RegisterShellHookWindow", UInt,hWnd )
		;~ MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
		;~ fn := this.ShellMessage.Bind(this)
		;~ OnMessage( MsgNum, fn )
 
		this.IniFile := RegexReplace(A_ScriptName, "(.ahk|.exe)$", ".ini")
 
		; Query monitor info
		SysGet, MonitorCount, MonitorCount
		this.MonitorCount := MonitorCount
		SysGet, MonitorPrimary, MonitorPrimary
		this.MonitorPrimary := MonitorPrimary
		this.log(MonitorCount " monitors detected")
 
		; Create Monitor objects
		Loop % this.MonitorCount {
			this.monitors.push(new CMonitor(A_Index))
		}
 
		; Bind Direction Keys to WindowSizeMove
		for axis, hks in DirectionKeys {
			for dir, hk in hks {
				fn := this.WindowSizeMove.Bind(this, 0, {axis: axis, dir: dir})
				hotkey, % hk, % fn
				if (MonitorModifier){
					fn := this.WindowSizeMove.Bind(this, 1, {axis: axis, dir: dir})
					hotkey, % MonitorModifier hk, % fn
				}
				if (SwitchModifier){
					fn := this.TileSwitch.Bind(this, {axis: axis, dir: dir})
					hotkey, % SwitchModifier hk, % fn
				}
			}
		}
 
		; Bind Cycle Keys to cycle between windows in the same tile
		for dir, hk in CycleKeys {
			fn := this.TileCycle.Bind(this, dir)
			hotkey, % hk, % fn
		}
 
		; Add windows which are already located in a tile, but not added to the tiling system
		; (ie windows tiled in last run of script)
		Loop % this.MonitorCount {
			this.AddWindowsAlreadyOnMonitor(A_Index)
		}
		
	}
	
	AddWindowsAlreadyOnMonitor(monitor_id){
		static searchorder := ["full", "n", "e", "s", "w", "ne", "se", "sw", "nw"]
		monitor := this.monitors[monitor_id]
		WinGet, l, List
		windows := []
		Loop, % l {
			windows.push(l%A_Index%)
		}
		max := windows.length()
		
		Loop 9 {
			compass := searchorder[A_Index]
			tile := monitor.TileCoords[compass]
			Loop % max {
				hwnd := windows[A_Index]
				;this.log("Checking " hwnd)
				WinGetPos, x, y, w, h, % "ahk_id " hwnd
				WinGetTitle, title, % "ahk_id " hwnd
				if (x == tile.x && y == tile.y && w == tile.w && h == tile.h){
					this.log("Existing window " title " is in compass " compass " on monitor " this.id)
					if (!title)
						continue
					window := this.AddWindow(hwnd)
					monitor.AddWindow(window, compass)
				}
			}
		}
	}
 
	; Called by user to configure monitors
	SetMonitorPosition(dest, direction, source){
		static directions := {North: {axis:"y", dir:-1}, South: {axis:"y", dir: 1}, West:{axis:"x", dir: -1}, East: {axis:"x", dir: 1}}
		axis := directions[direction].axis, dir := directions[direction].dir
		if (!ObjHasKey(this.MonitorMap, source))
			this.MonitorMap[source] := {x: {}, y: {}}
		this.MonitorMap[source, axis, dir] := dest
 
		if (!ObjHasKey(this.MonitorMap, dest))
			this.MonitorMap[dest] := {x: {}, y: {}}
		this.MonitorMap[dest, axis, dir * -1] := source
	}
 
	; === Methods called as a result of user interaction ===
 
	; Window Move or Size requested
	; Mode 0 = resize / move
	; Mode 1 = move monitor
	WindowSizeMove(mode, vector, hwnd := 0){
		static ModeName := {0: "Size", 1: "Move"}
		if (hwnd == 0)
			hwnd := this.GetActiveHwnd()
		axis := vector.axis
		dir := vector.dir
		if (ObjHasKey(this.windows, hwnd)){
			; Existing window
			window := this.windows[hwnd]
			monitor := window.monitor
			vectors := window.vectors.clone()
			this.log(ModeName[mode] " requested - Monitor: " monitor ", Dir: " this.VectorToCompass(vector) ", Window: " hwnd)
			if (mode){
				; Move mode
				if (!nm := this.NavigateMonitor(monitor, vector))
					return
				this.log("Moving " hwnd " to monitor " nm)
				this.monitors[monitor].RemoveWindow(window)
				monitor := nm
			} else if (window.vectors[vector.axis] == vector.dir){
				; Size issued when window is half size against that edge - move window to next monitor
				if (!(monitor := this.NavigateMonitor(monitor, vector))){
					; No monitor in that direction - abort
					return
				}
				vectors[vector.axis] *= -1
				this.log("Moving " hwnd " to monitor " monitor ", flipping " vector.axis)
			} else {
				vectors[vector.axis]:= this.AddDirections(vectors[vector.axis],vector.dir)
			}
			compass := this.VectorsToCompass(vectors)
			this.monitors[monitor].TileWindow(window, compass)
		} else {
			; New window
			window := this.AddWindow(hwnd)
			monitor := this.GetWindowMonitor(window)
 
			vectors := this.VectorToVectors(vector)
			this.log("New window " hwnd " is on monitor " monitor)
			this.monitors[monitor].TileWindow(window, this.VectorsToCompass(vectors))
		}
	}
 
	; User requested switch of focus to tile in specified direction
	TileSwitch(vector){
		hwnd := this.GetActiveHwnd()
		if (!window := this.windows[hwnd])
			return
		monitor_id := window.monitor
		vectors := window.vectors.clone()
 
		other_axis := this.OtherAxis(vector.axis)
		spans := (vectors[other_axis] = 0)
		bias := this.GetCaretEdge(window, other_axis)
		this.log("Active window is " window.hwnd "(" window.title ")")
		this.log("Tile Switch requested from monitor " monitor_id ", moving " this.VectorToCompass(vector) ", bias " this.VectorToCompass({axis:other_axis, dir: bias}))
		searchorder := []
		if (vectors[vector.axis] == 0 || vectors[vector.axis] == vector.dir){
			; Movement is towards monitor edge
			monitor_id := this.NavigateMonitor(monitor_id, vector)	; find next monitor in direction <dir>
			this.log("Movement is towards the " this.VectorToCompass(vector) " of monitor_id " window.monitor)
			if (!monitor_id){
				this.log("There is no monitor to move to, aborting")
				return
			}
			this.log("Changing monitor to " monitor_id)
		}
		monitor := this.monitors[monitor_id]
		searchorder := this.GetSearchOrder(vectors, vector, bias)
		Loop % searchorder.length(){
			str .= searchorder[A_Index] ", "
		}
		this.log("SearchOrder: " str)
		Loop % searchorder.length(){
			if (nw := monitor.ActivateTile(searchorder[A_Index])){
				this.log("MATCH " nw.hwnd " (" nw.title ")")
				break
			}
		}
	}
	
	GetSearchOrder(original_vectors, vector, bias){
		vectors := original_vectors.clone()
		other_axis := this.OtherAxis(vector.axis)
		spans := (vectors[other_axis] = 0)
		move_monitor := 0
		order := []
		if (vectors[vector.axis] == 0 || vectors[vector.axis] == vector.dir){
			order := this.AddOrder(order, "full")
			move_monitor := 1
		}
		vectors[vector.axis] := this.Invert(vectors[vector.axis]) ; flip alignment in direction of movement
		order := this.AddOrder(order, this.VectorsToCompass(vectors))
		
		if (spans && move_monitor){
			vectors[vector.axis] := this.Invert(vector.dir)
			compass := this.VectorsToCompass(vectors)
			order := this.AddOrder(order, this.VectorsToCompass(vectors))
		}
		
		vectors[vector.axis] := this.Invert(original_vectors[vector.axis])
		vectors[other_axis] := this.Alt(vectors[other_axis], bias)
		compass := this.VectorsToCompass(vectors)
		order := this.AddOrder(order, this.VectorsToCompass(vectors))
		
		if (spans){
			vectors := original_vectors.clone()
			vectors[vector.axis] := this.Invert(vector.dir)
			vectors[other_axis] := this.Alt(vectors[other_axis], bias)
			compass := this.VectorsToCompass(vectors)
			order := this.AddOrder(order, this.VectorsToCompass(vectors))

			vectors[other_axis] := this.Alt(original_vectors[other_axis], this.Invert(bias))
			compass := this.VectorsToCompass(vectors)
			order := this.AddOrder(order, this.VectorsToCompass(vectors))
		} else {
			vectors := original_vectors.clone()
			vectors[vector.axis] := this.Alt(vectors[vector.axis])
			vectors[other_axis] := this.Alt(vectors[other_axis])
			compass := this.VectorsToCompass(vectors)
			order := this.AddOrder(order, this.VectorsToCompass(vectors))
		}
		
		return order
	}
	
	AddOrder(order, compass){
		Loop % order.length(){
			if (order[A_Index] == compass)
				return order
		}
		order.push(compass)
		return order
	}
 
	; User requested Cycle between windows in a tile
	TileCycle(dir){
		hwnd := this.GetActiveHwnd()
		if (!window := this.windows[hwnd])
			return
		monitor := window.monitor
		this.monitors[monitor].TileCycle(window, dir)
	}
 
	; ====================== Private Methods ===================
	; Creates window object and adds it to list of windows
	AddWindow(hwnd){
		window := new CWindow(hwnd)
		this.windows[hwnd] := window
		this.log(ModeName[mode] "New window added - " hwnd " ( " window.title ")")
		return window
	}
 
	GetActiveHwnd(){
		WinGet, hwnd, ID, A
		return hwnd+0
	}
 
	; Returns the monitor number that the center of the window is on
	GetWindowMonitor(window){
		c := window.GetCenter()
		Loop % this.monitors.length() {
			m := this.monitors[A_Index].coords
			; Is the top-left corner of the window
			if (c.x >= m.l && c.x <= m.r && c.y >= m.t && c.y <= m.b){
				return A_Index
			}
		}
		return 0
	}
 
	; Specify a monitor and a direction and it will tell you which monitor (if any) is there
	NavigateMonitor(monitor, vector){
		dest := this.MonitorMap[monitor, vector.axis, vector.dir]
		if (dest)
			return dest
		else
			return 0
	}
 
	GetCaretEdge(window, axis){
		wc := window.GetCenter()
		cp := {x: A_CaretX, y: A_CaretY}
		if (cp[axis] < wc[axis])
			return -1
		else if (cp[axis] > wc[axis])
			return 1
		else
			return 0
	}
}
 
; Represents one of your monitors, and the windows that have been tiled to it
Class CMonitor extends TileEngineBase {
	id := 0		; Monitor number
	HwndToCompass := {}	; Which Tile each window is in. Also used by other classes to tell if a window is on this monitor
	CompassToVectors := {n: {x:0,y:-1}, e: {x:1,y:0}, s: {x:0,y:1}, w: {x:-1,y:0}
		, ne: {x:1,y:-1}, se: {x:1,y:1}, sw: {x:-1,y:1}, nw: {x:-1,y:-1}, full: {x:0,y:0}}	; Conversion table for vectors to compass
	Tiles := {n: {}, e: {}, s: {}, w: {}, ne: {}, se: {}, sw: {}, nw: {}, full: {}}	; Compass-indexed array of windows in each tile
	TileOrders := {n: [], e: [], s: [], w: [], ne: [], se: [], sw: [], nw: [], full: []}
	TileCoords := {n: {}, e: {}, s: {}, w: {}, ne: {}, se: {}, sw: {}, nw: {}, full: {}}	; Coordinates for each tile
 
	; ============== Public Methods ===================
	__New(id){
		this.log("Creating Monitor " id)
		this.id := id
		this.coords := this.GetWorkArea()
		this.log("Work Area is " this.coords.w "x" this.coords.h)
		this.BuildTileCoords()
	}

	BuildTileCoords(){
		static divisors := {-1: 2, 0: 1, 1: 2}
		monitor := this.coords
		for compass, nothing in this.TileOrders {
			vectors := this.CompassToVectors[compass]
			w := round(monitor.w / divisors[vectors.x])
			h := round(monitor.h / divisors[vectors.y])
			; if vectors.x is 1 then set position to center x, else left x
			x := vectors.x == 1 ? monitor.cx : monitor.l
			y := vectors.y == 1 ? monitor.cy : monitor.t
			this.TileCoords[compass] := {x: x, y: y, w: w, h: h}
		}
	}
	
	; Request a window be placed in a certain tile
	TileWindow(window, compass){
		if (ObjHasKey(this.HwndToCompass, window.hwnd)){
			; Window already on this monitor, update
			this.RemoveWindow(window)
		}
		this.AddWindow(window, compass)
		c := this.TileCoords[compass]
		this.log("Moving hwnd " window.hwnd " to x:" c.x ", y:" c.y ", w: " c.w ", h: " c.h)
		WinMove, % "ahk_id " window.hwnd,, c.x, c.y, c.w, c.h
	}
 
	; A request has been made to cycle windows in a tile
	TileCycle(window, dir){
		compass := this.HwndToCompass[window.hwnd]
		this.log("Cycling windows in tile " compass " on monitor " this.id)
		i := window.order + dir
		max := this.TileOrders[compass].length()
		if (i < 1)
			i := max
		else if (i > max)
			i := 1
		nw := this.TileOrders[compass, i]
		this.log("Activating window " nw.hwnd " (" nw.title ")")
		WinActivate, % "ahk_id " nw.hwnd
	}
 
	; Tries to activate the top-most window in the given tile
	; returns window object that was activated or 0 for none found
	ActivateTile(compass){
		window := this.GetTopMostTableInStack(compass)
		if (window)
			WinActivate, % "ahk_id " window.hwnd
		return window
	}
 
	; ===================== Private =======================
	AddWindow(window, compass){
		hwnd := window.hwnd
		this.Tiles[compass, hwnd] := window
		this.HwndToCompass[hwnd] := compass
		this.BuildTileList(compass)
		window.monitor := this.id
		window.vectors := this.CompassToVectors[compass]
	}
 
	BuildTileList(compass){
		this.TileOrders[compass] := []
		for hwnd, window in this.Tiles[compass] {
			this.TileOrders[compass].push(window)
			window.Order := A_Index
		}
	}
 
	RemoveWindow(window){
		hwnd := window.hwnd
		compass := this.HwndToCompass[window.hwnd]
		this.Tiles[compass].Delete(hwnd)
		this.HwndToCompass.Delete(hwnd)
		this.BuildTileList(compass)
		window.monitor := 0
		window.vectors := 0
	}
 
	; Gets the "Work Area" of a monito (The coordinates of the desktop on that monitor minus the taskbar)
	; also pre-calculates a few values derived from the coordinates
	GetWorkArea(){
		SysGet, coords_, MonitorWorkArea, % this.id
		out := {}
		out.l := coords_left
		out.r := coords_right
		out.t := coords_top
		out.b := coords_bottom
		out.w := coords_right - coords_left
		out.h := coords_bottom - coords_top
		out.cx := coords_left + round(out.w / 2)	; center x
		out.cy := coords_top + round(out.h / 2)		; center y
		out.hw := round(out.w / 2)	; half width
		out.hh := round(out.w / 2)	 ; half height
		return out
	}
 
	; GetZorderPosition / GetTopMostTableInStack by Guest3456 https://autohotkey.com/boards/viewtopic.php?p=92069#p92069
	;// gets the number/position of the window in the z-order 
	GetZorderPosition(hwnd)	{
	   PtrType := A_PtrSize ? "Ptr" : "UInt" ; AHK_L : AHK_Basic
	   z := 0
	   h := hwnd
	   while (h != 0)
	   {
		  h := DllCall("user32.dll\GetWindow", PtrType, h, "UInt", GW_HWNDPREV := 3)
		  ; WinGetTitle, title, ahk_id %h%
		  ; msgbox, h=%h%`ntitle=%title%
		  z++
	   }
	   return z
	}
 
	GetTopMostTableInStack(compass)	{
	   prev_z := 999999
	   hwnd_lowest_z := 0
	   for hwnd, window in this.Tiles[compass] {
		  z := this.GetZorderPosition(hwnd)
		  ;WinGetTitle, title, ahk_id %A_LoopField%      
		  ;msgbox, checking`n`n%title%`n`nzorder = %z%
		  if (z < prev_z)
			 lowest_z := window
		  prev_z := z
	   }
	   return lowest_z
	}
}
 
; Represents a window that has been added by the tiling system
Class CWindow extends TileEngineBase {
	monitor := 0	; which monitor ID the window is on
	vectors := {}		; what alignment the window has
	Order := 0		; Window's Order in tile stack
 
	__New(hwnd){
		this.hwnd := hwnd
		WinGetTitle, title, % "ahk_id " hwnd
		this.title := title
	}
 
	; Gets the coordinates of the center of the window
	GetCenter(){
		WinGetPos, wx, wy, ww, wh, % "ahk_id " this.hwnd
		cx := wx + round(ww / 2)
		cy := wy + round(wh / 2)
		return {x: cx, y: cy}
	}
}
 
; Helper functions that any class may use
Class TileEngineBase {
	; Debug logger to prefix string for filtering in DebugView
	Log(str){
		OutputDebug % "TileEngine| " str
	}
 
	; Converts vector objects ({axis: "x", dir: 1}) to compass types ("e")
	VectorToCompass(vector){
		static directions := {x: {-1: "w", 1: "e"}, y: {-1: "n", 1: "s"}}
		return directions[vector.axis, vector.dir]
	}
 
	; Converts a vector (eg: {axis: "x", dir: -1}) to a vectors (eg {x: -1, y: 0})
	VectorToVectors(vector){
		vectors := {x: 0, y: 0}
		vectors[vector.axis] := vector.dir
		return vectors
	}
 
	; Converts vectors objects ({x:1, y:0}) to compass types ("e")
	VectorsToCompass(vectors){
		static directions := {x: {-1: "w", 1: "e"}, y: {-1: "n", 1: "s"}}
		str := this.VectorToCompass({axis: "y", dir: vectors.y}) this.VectorToCompass({axis: "x", dir: vectors.x})
		return (str ? str : "full")
	}
 
	; Adds two -1/0/+1 directions together, but clamps to -1/0/+1
	AddDirections(dir, dir2){
		dir += dir2
		if dir > 1
			return 1
		if dir < -1
			return -1
		return dir
	}
 
	; Returns the other axis to the one passed
	OtherAxis(axis){
		static opposites := {x: "y", y: "x"}
		return opposites[axis]
	}
 
	; Inverts a vector
	Invert(vector){
		return vector * -1
	}
 
	; Returns the "Alternative" of a vector.
	; If vector is +1 or -1, return 0
	; else, return the bias (which should be either +1 or -1)
	Alt(vector, bias := 1){
		if (vector == 0)
			return bias
		return 0
	}
}
