;#NoTrayIcon
;#SingleInstance force
/**
	Class Mouse
*/
Class Mouse {
	
	pos_saved := {"x":"","y":"","coord_mode":""}
	
	__New(){
		
	}
	/** get number of monitor where is cursor
	*/
	monitorNumber(){
		;CoordMode, Mouse, Screen
		;MouseGetPos, $mouse_x, $mouse_y
		$mouse_pos := this.getPosition()
		return % Monitor().getMonitorByPos($mouse_pos.x)
	}
	/** getPos
	*/
	getPos($CoordMode:="Screen"){
		CoordMode, Mouse, %$CoordMode%
		MouseGetPos, $mouse_x, $mouse_y
		return % {"x":$mouse_x, "y":$mouse_y}
	}
	
	/** posSave
	*/
	posSave(){
		;this.pos_saved.coord_mode := A_CoordModeMouse
		$coord_mode_tmp := A_CoordModeMouse
		CoordMode, mouse, screen	

		MouseGetPos, $mouse_x, $mouse_y
		this.pos_saved.x := $mouse_x
		this.pos_saved.y := $mouse_y
		;CoordMode, Mouse, % this.pos_saved.coord_mode
		
		CoordMode, Mouse, %$coord_mode_tmp%

		return this
	}
	/** posRestore
	*/
	posRestore(){
		$coord_mode_tmp := A_CoordModeMouse
		CoordMode, Mouse, Screen
		MouseMove, % this.pos_saved.x, % this.pos_saved.y, 0
		
		CoordMode, Mouse, %$coord_mode_tmp%
		return this	
	}
	
	
}

/**
	CALL CLASS FUNCTION
*/
Mouse(){
	return % new Mouse()
}

/*
-----------------------------------------------
	TEST FUNCTIONS
-----------------------------------------------
*/
/** monitorNumber
*/
monitorNumber(){
	$mouse_monitor := Mouse().monitorNumber()
	dump($mouse_monitor, "mouse_monitor", 1)
}

/* 
-----------------------------------------------
	RUN TEST
-----------------------------------------------
*/
;monitorNumber()



/*
-----------------------------------------
	OLD FUNCTIONS  
-----------------------------------------  
*/


;;; ------------------------------------------------------------------
Mouse_getMonitorNumber(){
	MsgBox,262144,, "Function Mouse_getMonitorNumber() IS DEPRECATED, USE Mouse().monitorNumber()"
}
