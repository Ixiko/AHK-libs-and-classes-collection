#include %A_LineFile%\..
#include JSON.ahk
#include %A_LineFile%\..
#include MultiMony.ahk
#include %A_LineFile%\..\..
#include Wy.ahk

class Mony {
	/* 
	Class: Mony
	Handling a single Monitor, identified via its monitor ID
	
	Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original
	*/
	_debug := 0
	_version := "0.1.0"
	_id := 0
	_hmon := 0
	_overlay := Object()
	
	; ===== Properties ===============================================================
	boundary[] {
	/* -------------------------------------------------------------------------------
	Property: boundary [get]
	Get the boundaries of a monitor in Pixel (related to Virtual Screen) as a <Wy.Recty>.
	
	Remarks:
	* There is no setter available, since this is a constant system property
	
	See Also: 
	<virtualScreenSize [get]>
	*/
		get {
			mon := this.id
			MonitorGet(mon, sizeLeft, sizeTop, sizeRight, sizeBottom)
			rect := new Wy.Recty(sizeLeft, sizeTop, sizeRight, sizeBottom)
			dbgOut("=[" A_ThisFunc "([" this.id "])] -> " rect.toJson() , this.debug)
			return rect
		}
	}
	center[] {
	/* -------------------------------------------------------------------------------
	Property: center [get]
	Get the center coordinates of a monitor in Pixel (related to Virtual Screen)  as a <Wy.Pointy>.
		
	Remarks:
	* There is no setter available, since this is a constant system property
	*/	
		get {
			boundary := this.boundary
			xcenter := floor(boundary.x+(boundary.width-boundary.x)/2)
			ycenter := floor(boundary.y+(boundary.height-boundary.y)/2)
			pt := new Wy.Pointy(xcenter, ycenter)
			dbgOut("=[" A_ThisFunc "([" this.id "])] -> " pt.toJSON() , this.debug)
			return pt
		}
	}
	debug[] {
	/* -------------------------------------------------------------------------------
	Property: debug [get/set]
	Debug flag for debugging the object
	
	Value:
	flag - *true* or *false*
	*/
		get {
			return this._debug
		}
		set {
			mode := value<1?0:1
			this._debug := mode
			return this._debug
		}
	}	
	hmon[] {
	/* -------------------------------------------------------------------------------
	Property: hmon [get]
	Get the handle of the monitor

	Remarks:
	* There is no setter available, since this is a constant system property
	*/	
		get {
			rect := this.boundary
			X := rect.x + 1
			Y := rect.y + 1
			hmon := DllCall("User32.dll\MonitorFromPoint", "Int64", (X & 0xFFFFFFFF) | (Y << 32), "UInt", 0, "UPtr")
			this._hmon := hmon
			dbgOut("=[" A_ThisFunc "([" this.id "])] -> (" this._hmon ")" , this.debug)
			return this._hmon
		}
	}
	id[] {
	/* -------------------------------------------------------------------------------
	Property: id [get/set]
	ID of the monitor
	*/
		get {
			return this._id
		}
		set {
			ret := 0
			; Existiert der Monitor mit der uebergebenen ID?
			CoordMode("Mouse", "Screen")
			mCnt := MonitorGetCount()
			if (value > 0) {
				if (value <= mCnt) {
					this._id := value
					ret := value
				}
			}
			dbgOut("=[" A_ThisFunc "([" this.id "],value:=" value ")] -> (" ret ")" , this.debug)
			return ret
		}
	}
	idNext[ cycle := true ] {
	/* -------------------------------------------------------------------------------
	Property:	idNext [get]
	Gets the id of the next monitor.
			
	Parameters:
	cycle - == 1 cycle through monitors; == 0 stop at last monitor (*Optional*, Default: 1)
			
	Remarks:
	* There is no setter available, since this is a constant system property

	See Also: 
	<idPrev [get]>
	*/
		get {
			md := new MultiMony(this.debug)
			nextMon := md.idNext(this.id, cycle)
			dbgOut("=[" A_ThisFunc "([" this.id "],cycle=" cycle ")] -> " nextMon , this.debug)
			
			return nextMon
		}
	}
	idPrev[ cycle := true ] {
	/* -------------------------------------------------------------------------------
	Property:	idPrev [get]
	Gets the id of the previous monitor
			
	Parameters:
	cycle - == true cycle through monitors; == false stop at last monitor (*Optional*, Default: true)
			
	Remarks:
	* There is no setter available, since this is a constant system property

	See Also: 
	<idNext [get]>
	*/
		get {
			md := new MultiMony(this.debug)
			prevMon := md.idPrev(this.id, cycle)
			dbgOut("=[" A_ThisFunc "([" this.id "],cycle=" cycle ")] -> " prevMon , this.debug)
			
			return prevMon
		}
	}
;	info[] {
;	/* -------------------------------------------------------------------------------
;	Property:	info [get]
;	Gets info about monitor by calling Win32-API GetMonitorInfo() . 
;
;	More infos on GetMonitorInfo see <http://msdn.microsoft.com/de-de/library/windows/desktop/dd144901%28v=vs.85%29.aspx>
;
;	The return value is an object containing 
;	
;	 * Monitor handle
;	 * Monitor name
;	 * Monitor Id 
;	 * Rectangle containing the Monitor Boundaries (relative to Virtual Screen)
;	 * Rectangle containing the Monitor WorkingArea (relative to Virtual Screen)
;	 * Flag to indicate whether monitor is primary monitor or not ...
;	 
;	Remarks:
;	* There is no setter available, since this is a constant system property
;
;	Authors:
;	* Original: <just me at http://ahkscript.org/boards/viewtopic.php?f=6&t=4606>
;	*/
;		get {
;			hmon := this.hmon
;			ret := false
;			NumPut(VarSetCapacity(MIEX, 40 + (32 << !!A_IsUnicode)), MIEX, 0, "UInt")
;	 		If DllCall("User32.dll\GetMonitorInfo", "Ptr", hmon, "Ptr", &MIEX) {
;				MonName := StrGet(&MIEX + 40, 32)    ; CCHDEVICENAME = 32
;				MonNum := RegExReplace(MonName, ".*(\d+)$", "$1")
;
;				x := NumGet(MIEX, 4, "Int")
;				y := NumGet(MIEX, 8, "Int")
;				w := NumGet(MIEX, 12, "Int")
;				h := NumGet(MIEX, 16, "Int")
;				rectBound := new GdipC.Rect(x,y,w,h,this.debug)
;				x := NumGet(MIEX, 20, "Int")
;				y := NumGet(MIEX, 24, "Int")
;				w := NumGet(MIEX, 28, "Int")
;				h := NumGet(MIEX, 32, "Int")
;				rectWA := new GdipC.Rect(x,y,w,h,this.debug)
;
;				ret := { hmon:         hmon
;								, Name:          MonName
;								, Id:            MonNum
;								, Boundary:      rectBound    ; display rectangle
;								, WorkingAreaVS: rectWA  ; work area
;								, Primary:       NumGet(MIEX, 36, "UInt")} ; contains a non-zero value for the primary monitor.
;				dbgOut("=[" A_ThisFunc "([" this.id "])] -> (hmon=" ret.hmon ", Name=" ret.Name ", id=" ret.Id ", Boundary=" ret.Boundary.dump() ", WorkingArea" ret.WorkingArea.dump() ", Primary=" ret.Primary ")" , this.debug)
;			}
;			else {
;				dbgOut("=[" A_ThisFunc "([" this.id "])] -> " ret , this.debug)
;	   	}
;	 		Return ret
;		}
;	}
	monitorsCount[] {
	/* ---------------------------------------------------------------------------------------
	Property: monitorsCount [get]
	Number of available monitors. 

	Remarks:
	* There is no setter available, since this is a constant system property
	*/
		get {
			md := new MultiMony(this.debug)
			mcnt := md.monitorsCount
			dbgOut("=[" A_ThisFunc "([" this.id "]) -> (" mCnt ")]" , this.debug)		
			return mCnt
		}
	}
	name[] {
	/* ---------------------------------------------------------------------------------------
	Property: name [get]
	Name of the monitors. 

	Remarks:
	* There is no setter available, since this is a constant system property
	*/
		get {
			mon := this.id
			name := MonitorGetName(mon)
			dbgOut("=[" A_ThisFunc "([" this.id "])] -> (" name ")" , this.debug)
			return name
		}
	}
	primary[] {
	/* ---------------------------------------------------------------------------------------
	Property: primary [get]
	Is the monitor the primary monitor? 

	Remarks:
	* There is no setter available, since this is a constant system property
	*/
		get {
			hmon := this.hmon
			ret := false
			NumPut(VarSetCapacity(MIEX, 40 + (32 << !!A_IsUnicode)), MIEX, 0, "UInt")
	 		If DllCall("User32.dll\GetMonitorInfo", "Ptr", hmon, "Ptr", &MIEX) {
				ret := NumGet(MIEX, 36, "UInt") ; contains a non-zero value for the primary monitor.
			}
			dbgOut("[" A_ThisFunc "([" this.id "]) -> (" ret ")]" , this.debug)		
			return ret
		}
	}
	scale[ monDest := 1 ] {
	/* -------------------------------------------------------------------------------
	Property:  scale [get]
	Determines the scaling factors in x/y-direction for coordinates when moving to monDest as a <Wy.Pointy>.
			
	Parameters:
	monDest - Destination Monitor number (*Required*, Default := 1)
			
	Returns:
	Scaling factor for x/y -coordinates as a <Wy.Pointy>.

	Remarks:
	* There is no setter available, since this is a constant system property

	See Also: 
	<scaleX [get]>, <scaleY [get]>
	*/
		get {
			scaleX := this.scaleX[monDest]
			scaleY := this.scaleY[monDest]
			pt := new Wy.Pointy(scaleX,scaleY)
			dbgOut("=[" A_ThisFunc "([" this.id "],monDest:= " monDest "] -> (" JSON.Dump(pt) ")" , this.debug)
			return pt
		}
	}
	scaleX[ monDest := 1 ] {
	/* -------------------------------------------------------------------------------
	Property:  scaleX [get]
	Determines the scaling factor in x and -direction for coordinates when moving to monDest
			
	Parameters:
	monDest - Destination Monitor number (*Required*, Default := 1)
			
	Returns:
	Scaling factor for x-coordinates as a <Wy.Pointy>.

	Remarks:
	* There is no setter available, since this is a constant system property

	See Also: 
	<scale [get]>, <scaleY [get]>
	*/
		get {
			size1 := this.size
			md := new Mony(monDest, this.debug)
			size2 := md.size
			scaleX := size2.width / size1.width
			dbgOut("=[" A_ThisFunc "([" this.id "],monDest:=" monDest ") -> (" scaleX ")]" , this.debug)		
			return scaleX
		}
	}
	scaleY[ monDest := 1 ] {
	/* -------------------------------------------------------------------------------
	Property:  scaleY [get]
	Determines the scaling factor in y-direction for coordinates when moving to monDest
			
	Parameters:
	monDest - Destination Monitor number (*Required*, Default := 1)
			
	Returns:
	Scaling factor for y-coordinates

	Remarks:
	* There is no setter available, since this is a constant system property

	See Also: 
	<scale [get]>, <scaleX [get]>
	*/
		get {
			size1 := this.size
			md := new Mony(monDest, this.debug)
			size2 := md.size
			scaleY := size2.height / size1.height
			dbgOut("=[" A_ThisFunc "([" this.id "],monDest:=" monDest ") -> (" scaleY ")]" , this.debug)		
			return scaleY
		}
	}
	size[] {
	/* ---------------------------------------------------------------------------------------
	Property:  size [get]
	Get the size of a monitor in Pixel as a <Wy.Recty>.
			
	Remarks:
	* There is no setter available, since this is a constant system property

	See Also: 
	<virtualScreenSize [get]>, <workingArea [get]>
	*/
		get {
			mon := this.id
			m := MonitorGet(mon, sizeLeft, sizeTop, sizeRight, sizeBottom)
			rect := new Wy.Recty(0,0, sizeRight-sizeLeft, sizeBottom-sizeTop)
			dbgOut("=[" A_ThisFunc "([" this.id "])] -> (" rect.toJson() ")" , this.debug)
			return rect
		}
	}
	version[] {
	/* -------------------------------------------------------------------------------
	Property: version [get]
	Version of the class
	
	Remarks:
	* There is no setter available, since this is a constant system property
	*/
		get {
			return this._version
		}
	}
	virtualScreenSize[] {
	/* ---------------------------------------------------------------------------------------
	Property: virtualScreenSize [get]
	Get the size of virtual screen in Pixel as a <Wy.Recty>.
	
	The virtual screen is the bounding rectangle of all display monitors
	
	Remarks:
	* There is no setter available, since this is a constant system property

	See Also: 
	<size [get]>, <boundary [get]>
	*/
		get {
			md := new MultiMony(this.debug)
			rect := md.virtualScreenSize
			dbgOut("=[" A_ThisFunc "([" this.id "])] -> (" rect.toJson() ")" , this.debug)
			return rect
		}
	}
	workingArea[] {
	/* -------------------------------------------------------------------------------
	Property:  workingArea [get]
	Get the working area of a monitor in Pixel as a <Wy.Recty>.
	
	Same as <size [get]>, except the area is reduced to exclude the area occupied by the taskbar and other registered desktop toolbars.
	The working area is given as a <Wy.Recty>.
		
	Remarks:
	* There is no setter available, since this is a constant system property

	See Also: 
	<size [get]>
	*/
		get {
			mon := this.id
			m := MonitorGetWorkArea(mon, Left, Top, Right, Bottom)
			rect := new Wy.Recty(0,0, Right-Left, Bottom-Top)
			dbgOut("=[" A_ThisFunc "([" this.id "])] -> (" rect.toJson() ")" , this.debug)
			return rect
		}
	}

	; ===== Methods ==================================================================
	/* -------------------------------------------------------------------------------
	Method:	coordDisplayToVirtualScreen
	Transforms coordinates relative to given monitor into absolute (virtual) coordinates. 
	Returns object of type <Wy.Pointy>.
	
	Parameters:
	x,y - relative coordinates on given monitor
	
	Returns:
	<Wy.Pointy>.
	*/
	coordDisplayToVirtualScreen( x := 0, y := 0) {
		dbgOut(">[" A_ThisFunc "(id= " this.id ",x=" x ",y=" y ")" , this.debug)
		md := new MultiMony(this.debug)
		pt := md.coordDisplayToVirtualScreen(this.id, x, y)
		dbgOut("<[" A_ThisFunc "(id= " this.id ", x=" x ", y=" y ")] -> (" pt.toJson() ")" , this.debug)
		return pt
	}
	
	/* -------------------------------------------------------------------------------
	method: identify
	Identify monitor by displaying the monitor id
	
	Parameters:
	disptime - time to display the monitor id (*Optional*, Default: 1500[ms])
	txtcolor - color of the displayed monitor id (*Optional*, Default: "000000")
	txtsize - size of the displayed monitor id (*Optional*, Default: 300[px])
	*/
	identify( disptime := 1500, txtcolor := "000000", txtsize := 300 ) {
		dbgOut(">[" A_ThisFunc "([" this.id "], disptime := " disptime ", txtcolor := " txtcolor ", txtsize := " txtsize ")]" , this.debug)
		this.__idShow(txtcolor, txtsize)
		Sleep(disptime)
		this.__idHide()
		dbgOut("<[" A_ThisFunc "([" this.id "], disptime := " disptime ", txtcolor := " txtcolor ", txtsize := " txtsize ")]" , this.debug)
		return
	}
	
	/* ---------------------------------------------------------------------------------------
	Method: rectToPercent
	calculates monitor percents from given rectangle.

	The given rectangle-coordinates are transformed into percent of the screen. For example on a 1920x1200 screen 
    the coordinates x=394,y=240,w=960,h=400 are transformed into (20, 20, 50, 33.33) because 
    394/1920 = 20%, 240/1200=20%, 960/1920=50%, 400/1200=33.33%
	 	 
	Parameters:
	x,y,w,h - position and width/height to be transformed into screen percents

	Returns:
	<Wy.Recty> containing screen percents.
	*/	
    rectToPercent(rect) {
		monBound := this.boundary
		wfactor := (rect.width/monBound.width)*100
		hfactor := (rect.height/monBound.height)*100
		xfactor := (rect.x/monBound.width)*100
		yfactor := (rect.y/monBound.height)*100
		ret := new Wy.Recty(xfactor, yfactor, wfactor, hfactor, this.debug)
		dbgOut("=[" A_ThisFunc "([" this.hwnd "], rect=(" rect.toJson() ")]  -> percent=(" ret.toJson() ")" , this.debug)
		return ret
    }
	
	; ===== Internal Methods =========================================================
	/*! -------------------------------------------------------------------------------
	method: __idHide
	Helper function for <identify>: Hides the Id, shown with <__idShow> (*INTERNAL*)
	
	See Also: 
	<identify>, <__idShow>
	*/
	__idHide() {
		this._overlay.Destroy()
		dbgOut("=[" A_ThisFunc "([" this.id "])]" , this.debug)
		return
	}
	/*! -------------------------------------------------------------------------------
	method: __idShow
	Helper function for <identify>: Identify monitor by displaying the monitor id, hidden via <__idHide> (*INTERNAL*)
	
	Parameters:
	txtcolor - color of the displayed monitor id (*Optional*, Default: "000000")
	txtsize - size of the displayed monitor id (*Optional*, Default: 300[px])
		
	Authors:
	* Original: <Bkid at http://ahkscript.org/boards/viewtopic.php?f=6&t=3761&p=19836&hilit=Monitor#p19836>
		
	See Also: 
	<identify>, <__idHide>
	*/
	__idShow( txtcolor := "000000", txtsize := 300 ) {
		mon := this.id
		TPColor := "AABBCC"
		MonitorGet(mon, sizeLeft, sizeTop, sizeRight, sizeBottom)
		x := sizeLeft
		this._overlay := GuiCreate(,"Monitor " . this.id . " Overlay")
		this._overlay.Opt("+LastFound +AlwaysOnTop -Caption +ToolWindow")
		this._overlay.BackColor  := TPColor
		WinSetTransColor(TPColor)
		this._overlay.SetFont("s" . txtsize . " w700")
		this._overlay.Add("Text", "x0 y0 c" . txtcolor, mon)
		this._overlay.Show("x" . x . " y0 NoActivate")
		dbgOut("=[" A_ThisFunc "([" this.id "], txtcolor := " txtcolor ", txtsize := " txtsize ")]" , this.debug)
		return
	}
	/* -------------------------------------------------------------------------------
	Constructor: __New
	Constructor (*INTERNAL*)
		
	Parameters:
	_id - Monitor ID
	_debug - Flag to enable debugging (Optional - Default: 0)
	*/  
	__New(_id := 1, _debug := false) {
		this._debug := _debug
		ret := true
		CoordMode("Mouse", "Screen")
		mCnt := MonitorGetCount()
		if (_id > 0) {
			if (_id <= mCnt) {
				this.id := _id
			}
			else {
				dbgOut("=[" A_ThisFunc "(_id:=" _id ", _debug:=" _debug ")] (version: " this.version ") -> " false , this.debug)
				return false
			}
		}
		else {
			dbgOut("=[" A_ThisFunc "(_id:=" _id ", _debug:=" _debug ")] (version: " this.version ") -> " false , this.debug)
			return false
		}
		dbgOut("=[" A_ThisFunc "(_id:=" _id ", _debug:=" _debug ")] (version: " this.version ") -> " this.id , this.debug)
		return this
	}
}