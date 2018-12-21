;#SingleInstance force
;#NoTrayIcon

/** Class Window

	KNOWING ISSUES: window position is offseted of 8px, window position is -8,-8 instead of 0,0, corrected with variable POSITION_CORRECTION

*/
#Include  %A_LineFile%\..\Monitor.ahk

Class Window extends Monitor {

	POSITION_CORRECTION := 8
	win_ids	:= {}
	win_pos	:= {}
	class	:= ""
	title	:= ""
	pid	:= ""

	__New(){
		this._initMonitorClass()
	}

	;/** windowTest
	;*/
	windowTest(){
		MsgBox,262144,, windowTest, 2
	}
	/** run
	*/
	run($path){
		Run, %$path%,,,$pid
		this.setPid($pid)
		return this
	}
	runWait($path){
		RunWait, %$path%,,,$pid
		this.setPid($pid)
		return this
	}
	/**
	  */
	setPid($pid){
		this.pid := $pid
		this.setClass()
		this.setTitle()
		this._setWinPos()
		this.setMonitor()
		return this
	}
	/** setActiveWindow
	*/
	setActive(){
		WinGet, $PID, PID, A
		;dump($PID, "$PID", 0)
		this.setPid($PID)
		return this
	}

	/** setExe
	*/
	setProcess($process){
		winGet, $pid, PID, ahk_exe %$process%
		this.setPid($pid)
		return this
	}


	/** setClass
	*/
	setClass($class:=""){
		if($class=="")
			WinGetClass, $class, % this.getPid()
		this.class := $class
		return this
	}
	/** setTitle
	*/
	setTitle($title:=""){
		setTitleMatchMode, 2
		if($title=="")
			WinGetTitle, $title, % this.getPid()
		;dump($title, "$title", 0)
		this.title := $title
		return this
	}
	/** getPid
	*/
	getPid(){
		return % "ahk_pid " this.pid
	}
	/** exist
	*/
	exist(){
		IfWinExist, % this.getPid()
			return true
		else
			return false
	}
	/** activate
	*/
	activate(){
		WinWaitActive, % this.getPid()
		return this
	}
	/** close
	*/
	close(){
		WinClose, % this.getPid()
		return this
	}
	/** toFront
	*/
	toFront(){
		this.alwaysOnTop(true)
		this.alwaysOnTop(false)
		return this
	}
	/** alwaysOnTOp
	*/
	alwaysOnTop($switch:=true){
		$switch := $switch ? "On" : "Off"
		Winset, AlwaysOnTop, %$switch%,  % this.getPid()
		return this
	}
	/** setMonitor
	*/
	setMonitor($num:="ACTIVE"){
		;dump(this.win_pos.x, "setMonitor()", 1)
		;MsgBox,262144,, % "setMonitor " $num, 2
		if($num=="ACTIVE")
			this.findMonitorActive(this.win_pos.x)
		else
			this.setMonitorActive($num)

		return this
	}

	/** _setMonitorIfNotSet
	*/
	_setMonitorIfNotSet(){
		;dump(this.monitor.active, "this.monitor.active", 0)

		if(this.monitor.active==0)
			this.setMonitor()
		;dump(this.monitor.active=="" , "this.monitor ", 1)

		return this
	}

	/** winWait
	*/
	winWait($wait:=3,$sleep:=0){
		;WinWait, % this.getPid(),,%$wait%
		;If (ErrorLevel == 0){
			sleep, %$sleep%
		;	return this
		;}
		;MsgBox,262144,, % "WinWait timed out"
		return this
	}

	/** setPosition
	*/
	setPosition( $position_X:=0, $position_Y:=0 ){
		this._setMonitorIfNotSet()
		;MsgBox,262144,, EXIST, 2
		$position_X := this._precentToPixel($position_X, this.getDimensions("width")) + this.getDimensions("offset")
		$position_Y := this._precentToPixel($position_Y, this.getDimensions("height"))
		;;dump($position_X, "$position_X", 0)
		;dump($position_Y, "$position_Y", 0)
		WinMove, % this.getPid(),, % $position_X-this.POSITION_CORRECTION, %$position_Y%
		this._setWinPos()



		return this

	}
	/** setSize
	*/
	setSize($width, $height){
		this._setMonitorIfNotSet()
		;WinMove, % "ahk_id " this.id,, % this.win_pos.x, % this.win_pos.y, % this._precentToPixel($width, this.getDimensions("width")), % this._precentToPixel($height, this.getDimensions("height"))
		WinMove, % this.getPid(),, % this.win_pos.x, % this.win_pos.y, % this._precentToPixel($width, this.getDimensions("width"))+this.POSITION_CORRECTION*2, % this._precentToPixel($height, this.getDimensions("height"))
		this._setWinPos()
		return this

	}
	/** _precentToPixel
	*/
	_precentToPixel($percents, $pixels){
		;return 0
		return % $percents ? ($percents/100)*$pixels : 0
	}

	/*
	-----------------------------------------------
		PRIVATE METHODS
	-----------------------------------------------
	*/
	/** _setWinIds
	*/
	_setWinIds(){
        WinGet, $windows, List, % this.class
        Loop, %$windows% { ; will run loop for number of windows in array
            $ahk_id = % $windows%A_Index%
            WinGetTitle, $winTitle, % "ahk_id " $ahk_id
			this.win_ids[$ahk_id] := $winTitle
		}
	}
	/** _setWinPos
	*/
	_setWinPos(){

		;MsgBox,262144,, _setWinPos(), 2
		WinGetPos, $win_x, $win_y, $win_width, $win_height, % this.getPid()
		this.win_pos := {"x":$win_x+this.POSITION_CORRECTION, "y":$win_y+this.POSITION_CORRECTION, "width":$win_width, "height":$win_height}
		;dump(this.win_pos, "this.win_pos", 0)
	}
	/** _setWinId
	*/
	_setWinId(){
		for $win_id, $win_title in % this.win_ids
			if (RegExMatch( $win_title, this.title )){
				this.id := $win_id
				break
			}
	}


	;/** _findInArray
	;*/
	;_findInArray($array, $needle){
	;	;if !(IsObject($array)) || ($array.Length() = 0)
	;		;return 0
	;	for $index, $value in $array
	;		if ($value = $needle)
	;			return $index
	;	return 0
	;}
}

/* CALL CLASS FUNCTION
*/
Window(){
	return % new Window()
}
/*
-----------------------------------------------
	TEST FUNCTIONS
-----------------------------------------------
*/
/** setTitle
*/
Window_setTitle(){
	;Window().setClass("Chrome_WidgetWin_1").setTitle("Google Chrome")
	;$Window	:= Window().setTitle("ActiveState Komodo IDE")
	$Window	:= Window().setProcess("komodo.exe")
	$Window_active	:= Window().setActive()

	dump($Window, "$Window", 1)
	dump($Window_active, "$Window_active", 1)

}
/** monitor
*/
Window_monitorNumberTest(){
	$window_monitor := Window().setActive().getMonitor()
	;dump($window_monitor, "window_monitor", 1)
}
/** setPosition
*/
Window_setPositionTest(){
	$window := Window().setActive()
					.setMonitor(2)
					.setPosition(25,0)
					.setDimensions(75,100)
	exitApp
	;dump($window, "$window", 1)
}
/*
-----------------------------------------------
	RUN TEST
-----------------------------------------------
*/
;Window_setTitle()
;Window_monitorNumberTest()
;Window_setPositionTest()




































/*
-----------------------------------------
	OLD FUNCTIONS
-----------------------------------------
*/

Window_GetId( $class, $find, $exclude:=false ){
    ;MsgBox, getWindowId
    ;MsgBox, -%$find%-

    ;;;check exclude string if is valid
    if $exclude
       if ($exclude=="" || $exclude=="|")
            MsgBox,262144,, getWindowId - $exclude string is empty


    if $find =
    {
        ;MsgBox, passed variable find is empty
    } else{
        ;MsgBox,262144,, test, 2
        SetTitleMatchMode, RegEx
        WinGet, $windows, List,  ahk_class %$class%

        Loop, %$windows% { ; will run loop for number of windows in array
            $ahk_id = % "ahk_id " $windows%A_Index%
            WinGetTitle, $winTitle, %$ahk_id%

            ;;IF STRING MATCH
            $match_title := RegExMatch( $winTitle , $find )
            if $match_title > 0
            ;IfInString, $winTitle, %$find%
            {
                ;;IF EXCLUDE
                if $exclude
                {
                    ;;;check exclude string if is valid
                   if ($exclude=="" || $exclude=="|")
                        MsgBox,262144,, getWindowId - $exclude string is empty

                    ;;;IF NOT MATCH ON EXCLUDE
                    $match_exclude := RegExMatch( $winTitle , $exclude )

                    ;MsgBox,262144,, %$match_exclude%, 5
                    if $match_exclude = 0
                    {
                        ;MsgBox, %$winTitle%
                        return %$ahk_id%
                    }
                }
                ;;IF NOT EXCLUDE
                else
                {
                    ;MsgBox, %$winTitle%
                    return %$ahk_id%
                }
            }
        }

    }
    Return


}

;;; ------------------------------------------------------------------
;;; CENTER MOUSE to window
;;; ------------------------------------------------------------------
Window_CenterMouse($WinTitle){
    WinGetPos, $win_X, $win_Y, $win_width, $win_Height, %$WinTitle%

    $mouse_X := $win_width /2
    $mouse_Y := $win_height /2

    MouseMove, $mouse_X, $mouse_Y, 0
    MouseMove, +1, 0, 10, R
    MouseMove, -1, 0, 10, R

}

Window_getMonitorNumber($WinId:=""){
	MsgBox,262144,, "Function Window_getMonitorNumber() IS DEPRECATED, USE Window().getMonitor()"
}


;;; ------------------------------------------------------------------------------------------------------------------------
;;; Window_closeClassByTitle() CLOSE all windows with ahk_class of given $WinTitle
;;; string $WinTitle is title of window which class will be closed, USE current ACTIVE window IF $WinTitle IS NOT DEFINED
;;;
;;; E.G.: Window_closeClassByTitle()                    // CLOSE class of windows of ACTIVE window
;;;       Window_closeClassByTitle("Google Chrome" )    // CLOSE all windows of ahk_class MozillaWindowClass
;;; ------------------------------------------------------------------------------------------------------------------------
Window_closeClassByTitle($WinTitle:=""){
    setTitleMatchMode, 2
    if $WinTitle=
        WinGetActiveTitle, $WinTitle

    WinGetClass, $ahk_class , %$WinTitle%
    GroupAdd $classGroup, ahk_class %$ahk_class%
    WinClose ahk_group $classGroup
}


;;; ------------------------------------------------------------------------------------------------------------------------
;;; set window position and dimensions in percents
;;; Window_setPosition( ahk_class Chrome_WidgetWin_1, 0, 50, 75, 30, 2 ) // set chrome window to position X=0%, Y=50% and dimensions width=75%, height=30% on second monitor
;;; E.G.:
;;;     Window_setPosition()                // set current active window position
;;;     Window_setPosition( $WinTitle:="" ) // set current active window position

;;; ------------------------------------------------------------------------------------------------------------------------

Window_setPosition( $WinTitle:="", $position_X:=0, $position_Y:=0, $win_width:=0, $win_height:=0, $monitor_number:=1  ){
	if $WinTitle=
        WinGetActiveTitle, $WinTitle
	IfWinNotExist, %$WinTitle%
		msgBox, %$WinTitle%
		;notify("error", "WINDOW " $WinTitle " IS NOT EXIST", "WRONG $WinTitle ARGUMENT PASSED`nin function: Window_setPosition" )

	SysGet, $MonitorCount, MonitorCount
	If $monitor_number<=%$MonitorCount%
	{
		SysGet, $MonitorWorkArea, MonitorWorkArea, %$monitor_number%
		;;GET  WORKING DESKTOP POSITIONS
		$start_X=%$MonitorWorkAreaLeft%
		$start_Y=%$MonitorWorkAreaTop%
		$end_X  =%$MonitorWorkAreaRight%
		$end_Y  =%$MonitorWorkAreaBottom%


		;;;GET DIMENSIONS
		$monitor_width :=$end_X-$start_X
		$monitor_height:=$end_Y-$start_Y
		;;; GET WINDOW POSITION IN PERCENTS
		$win_pos_px_X :=Floor(( $monitor_width/100) *$position_X)
		$win_pos_px_Y :=Floor(( $monitor_height/100)*$position_Y)
		if $monitor_number>1
		{
			$win_pos_px_X:=$win_pos_px_X+$start_X
			$win_pos_px_Y:=$win_pos_px_Y+$start_Y
		}
		;;;CORRECT WINDOW SIZE ON WINDOWS 10
		$win_pos_px_X:=$win_pos_px_X-6

		;;; GET WINDOW DIMENSIONS IN PERCENTS
		$win_width_px :=Floor(( $monitor_width/100) *$win_width )+15
		$win_height_px:=Floor(( $monitor_height/100)*$win_height ) +8

		WinMove, %$WinTitle%, , %$win_pos_px_X%, %$win_pos_px_Y%, %$win_width_px%, %$win_height_px%
	}
}
