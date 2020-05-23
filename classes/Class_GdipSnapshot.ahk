/*
CGDipSnapShot.ahk
By evilc@evilc.com

Use Gdip_All.ahk from this page: http://www.autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/
Place it in C:\Program Files\Autohotkey\Lib (Create Lib folder if it does not exist)

Documentation can largely be gleaned from the comments.
Consider anything prefixed with _ as "internal" and not to be messed with unless you know what you are doing.

ToDo:

*/
#Include %A_LineFile%\..\gdip.ahk

Class CGDipSnapShot {
	; "private" Properties - Do not attempt to Set or Get! ===============
	; Coords of snapshot area relative to screen
	; Access via this.Coords instead!
	_Coords := {x: 0, y: 0, w: 0, h: 0}

	; Cache of RGB value for pixels in the Snapshot.
	; Access via this.PixelSnap[] or this.PixelScreen[] instead!
	_PixelCache := [[],[]]
	
	; Internal - you should not need these at all
	_SnapshotTaken := 0
	_NegativeValue := {rgb: -1, r: -1, g: -1, b: -1}

	; GDI stuff for the snapshot. You are unlikely to need these
	pToken := 0
	pBitmap := 0 								; bitmap image
	hBitmap := 0 								; HWND for bitmap?

	; === User Methods ==================================================================================================================================
	; Intended for use by people using the class.

	; Take a new Snapshot
	TakeSnapshot(){
		this._ResetSnapshot()
		this.pBitmap := GDIP_BitmapFromScreen(this._Coords.x "|" this._Coords.y "|" this._Coords.w "|" this._Coords.h)
		this._SnapshotTaken := 1
		return
	}

	; Show the Snapshot in the specified HWND.
	; Declare a regular AHK GUI Textbox like so:
	; Gui, Add, Text, 0xE x5 y5 w200 h200 hwndSnapshotPreview
	; Then ShowSnapshot(SnapshotPreview) to show the snapshot in that GUI item
	ShowSnapshot(hwnd){
		if (!this._SnapshotTaken){
			this.TakeSnapshot()
		}
		if (this.hBitmap){
			; Delete old hwnd
			DeleteObject(this.hBitmap)
		}
		this.hBitmap := Gdip_CreateHBITMAPFromBitmap(this.pBitmap)
		SendMessage, 0x172, 0, % this.hBitmap, , % "ahk_id " hwnd
		return
	}

	; Save snapshot to file
	; Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
	SaveSnapshot(filename, quality := 100){
		if (!this._SnapshotTaken){
			this.TakeSnapshot()
		}
		return Gdip_SaveBitmapToFile(this.pBitmap, filename, quality)
	}

	; Move / Resize the Snapshot after creation
	; Pass an object containing which properties you wish to set.
	; eg to set only x and h to 0, but leave y and w the same, pass {x: 0, h:0}
	SetCoords(obj){
		was_set := 0
		for key, value in Obj {
			if (key = "x" || key = "y" || key = "w" || key = "h"){
				was_set++
				this._Coords[key] := value
			}
		}
		; If moved or resized, reset the Pixel Cache
		if (was_set){
			this._ResetSnapshot()
		}
	}
	
	; Compares one snapshot with another, with optional tolerance
	Compare(snap, tol := 20){
		if (!this._SnapshotTaken){
			this.TakeSnapshot()
		}
		if (this._Coords.w != snap._Coords.w || this._Coords.h != snap._Coords.h){
			return 0
		}
		Loop % this._Coords.w {
			x := A_Index
			Loop % this._Coords.h {
				y := A_Index
				if (!this.PixelSnap[x,y].Compare(snap.PixelSnap[x,y],tol)){
					return 0
				}
			}
		}
		return 1
	}
	
	; Return the Coords object, for completeness
	GetCoords(){
		return this._Coords
	}
	
	; Converts Screen coords to Snapshot coords
	ScreenToSnap(x,y){
		return {x: x - this._Coords.x, y: y - this._Coords.y}
	}

	; Returns true if the snapshot coordinates are valid (eg x not bigger than width)
	; NOT for telling if a screen coord is inside the snapshot
	IsSnapCoord(xpos,ypos){
		if (xpos < 0 || xpos > this._Coords.w || ypos < 0 || ypos > this._Coords.h){
			return 0
		}
		return 1
	}
	
	; Is a screen coord inside the snapshot area?
	IsInsideSnap(xpos,ypos){
		if (xpos < this._Coords.x || ypos < this._Coords.y || xpos > (this._Coords.x + this._Coords.w) || ypos > (this._Coords.y + this._Coords.h) ){
			return 0
		}
		return 1
	}
	
	; ===== Available for End-user use, but not advised (Use better alternatives) ===================================================
	
	; Gets color of a pixel relative to the screen (As long as it is inside the snapshot)
	; Returns -1 if asked for a pixel outside the snapshot
	; Advise use of PixelScreen[] Array instead of this function, as results are cached
	PixelGetColor(xpos,ypos){
		; Return RGB value of -1 if outside snapshot area
		if (!this.IsInsideSnap(xpos,ypos)){
			return this._NegativeValue
		}
		; Work out which pixel in the Snapshot was requested
		xpos := xpos - this._Coords.x
		ypos := ypos - this._Coords.y
		
		return this.SnapshotGetColor(xpos,ypos)
	}

	; Gets color of a pixel relative to the SnapShot
	; Advise use of PixelSnap[] Array instead of this function, as results are cached.
	SnapshotGetColor(xpos, ypos){
		if (!this._SnapshotTaken){
			this.TakeSnapshot()
		}
		if (!this.IsSnapCoord(xpos, ypos)){
			return this._NegativeValue
		}
		ret := GDIP_GetPixel(this.pBitmap, xpos, ypos)
		ret := this.ARGBtoRGB(ret)
		return new this._CColor(ret)
	}
	
	; ===== Mainly for internal use. ==========================================================================================

	_ResetSnapshot(){
		if (this.pBitmap){
			; delete old bitmap
			Gdip_DisposeImage(this.pBitmap)
		}
		this._SnapshotTaken := 0
		this._PixelCache := [[],[]]
	}
	
	; Converts RGB with Alpha Channel to RGB
	ARGBtoRGB( ARGB ){
		SetFormat, IntegerFast, hex
		ARGB := ARGB & 0x00ffffff
		ARGB .= ""  ; Necessary due to the "fast" mode.
		SetFormat, IntegerFast, d
		return ARGB
	}

	; Constructor
	__New(x,y,w,h){
		this.Coords := new this._CCoords()
		this._Coords := {x: x, y: y, w: w, h: h}
		this.pToken := Gdip_Startup()
	}

	; Destructor
	__Delete(){
		Gdip_DisposeImage(this.pBitmap)
		DeleteObject(this.hBitmap)
		Gdip_ShutDown(this.pToken)
	}
	
	; Implements Pixel Cache via Dynamic Properties
	__Get(aName, x := "", y := ""){
		if (aName = "Coords"){
			return this._Coords
		} else if (aName = "PixelSnap"){
			if (this._PixelCache[x,y] == ""){
				this._PixelCache[x,y] := this.SnapshotGetColor(x,y)
			}
			return this._PixelCache[x,y]
		}
		if (aName = "PixelScreen"){
			col := this.PixelGetColor(x,y)
			; Convert to snapshot coords for array index
			coords := this.ScreenToSnap(x,y)
			x := coords.x
			y := coords.y
			; Check coords are within snapshot
			if (col.rgb != -1){
				this._PixelCache[x,y] := col
			}
			return col
		}
	}
	
	; Implements snapshot coords Get / Set via Dynamic Properties.
	; Automatically resets snapshot if viewport moved
	Class _CCoords {
		__Get(aName){
			if (aName = "x" || aName = "y" || aName = "w" || aName = "h"){
				return this._Coords[aName]
			}
		}
		
		__Set(aName, aValue){
			if (aName = "x" || aName = "y" || aName = "w" || aName = "h"){
				this._Coords[aName] = aValue
				this._ResetSnapshot()
			}
		}
	}
	
	; color class - provides r/g/b values via Dynamic Properties
	Class _CColor {
		__New(RGB){
			this._RGB := RGB
		}
		
		; Implement RGB and R, G, B as Dynamic Properties
		__Get(aName := ""){
			if (aName = "RGB"){
				; Return RGB in Hexadecimal (eg 0xFF00AA) format
				SetFormat, IntegerFast, hex
				ret := this._RGB
				ret += 0
				ret .= ""
				SetFormat, IntegerFast, d
				return ret
			} else if (aName = "R"){
				; Return red in Decimal format
				return (this._RGB >> 16) & 255
			} else if (aName = "G"){
				return (this._RGB >> 8) & 255
			} else if (aName = "B"){
				return this._RGB & 255
			}
		}
		
		; Compares this pixel to a provided color, with a tolerance
		Compare(c2, tol := 20){
			return PixelCompare(this, c2, tol)
		}
	}

}

; Compares two r/g/b integer objects, with a tolerance
; returns true or false
; Note! NOTHING to do with any pixels in the snapshot - purely compares two hex values.
PixelCompare(c1, c2, tol := 20) {
	return (PixelDiff(c1,c2) <= tol)
}

; Returns the Difference between two colors
PixelDiff(c1,c2){
	diff := Abs( c1.r - c2.r ) "," Abs( c1.g - c2.g ) "," Abs( c1.b - c2.b )
	sort diff,N D,

	StringSplit, diff, diff, `,
	return diff%diff0%
}

; Converts hex ("0xFFFFFF" as a string) to an object of r/g/b integers
HexToRGB(color) {
	return { "r": (color >> 16) & 0xFF, "g": (color >> 8) & 0xFF, "b": color & 0xFF }
}
