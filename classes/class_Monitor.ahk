;#NoTrayIcon
;#SingleInstance force


/**
  Class Monitor

	KNOWING ISSUES: MULTIPLE MONITORS SETUP MUST BE 1|2|3
		E.G: CORRECT:	http://www.msoffice-tutorial-training.com/wp-content/uploads/2017/09/Change-screen-resolution-in-settings.jpg
		E.G: NON CORRECT:	http://dxg49ziwjgkgt.cloudfront.net/wp-content/uploads/2012/10/11-520x296.png

*/

Class Monitor {

	;monitors_count	:= 1
	;monitor_primary	:= 1
	;monitor_number	:= 1
	monitor	:= {"count":0, "primary":0, "active":0}

	__New(){
		this._initMonitorClass()
		;MsgBox,262144,, monitor, 2
		;dump(this, "monitor", 1)
	}
	/** _initMonitorClass
	*/
	_initMonitorClass(){
		this._setMonitorsCount()
		this._setMonitorPrimary()
		this._setDimensions()
		this._setOffset()
	}

	/** getDimensions
	*/
	getDimensions($key:="", $monitor:=0){
		if($key=="")
			return % this.dimensions

		$monitor := $monitor==0 ? this.monitor.active : $monitor
		$value := this.dimensions[$monitor][$key]
		return % $value ? $value : 0
	}
	/** getMonitorActive
	*/
	setMonitorActive($num){
		;MsgBox,262144,, setMonitorActive, 2
		if($num<1 || $num>this.monitor.count)
			$num := $num>this.monitor.count
		this.monitor.active := $num
		return this
	}

	/** @return integer monitor number of give position
	*/
	findMonitorActive($search_pos_x:=""){
		if(!$search_pos_x)
			WinGetPos,$search_pos_x,,,, A
		while, ($search_pos_x>=this.dimensions[A_Index]["offset"] && A_Index<=this.monitor.count)
			this.monitor.active := A_Index
		return this
	}
	/** _setMonitorPrimary
	*/
	_setMonitorPrimary(){
		SysGet, $monitor_primary, MonitorPrimary
		this.monitor.primary := $monitor_primary
	}

	/** _setMonitorsCount
	*/
	_setMonitorsCount(){
		SysGet, $monitors_count, MonitorCount
		this.monitor.count := $monitors_count
	}
	/** _setDimensions
	*/
	_setDimensions(){
		;dump( "_setDimensions()", 0)
		Loop, % this.monitor.count
			this._setDimensionsPerMonitor(A_Index)
	}
	/** _setDimensionsPerMonitor
	*/
	_setDimensionsPerMonitor($monitor_number){
		SysGet, $MonitorArea, MonitorWorkArea, % $monitor_number
		this.dimensions[$monitor_number] := {	"width":	$MonitorAreaRight  - $MonitorAreaLeft
			,"height":	$MonitorAreaBottom - $MonitorAreaTop}
	}
	/** set 0 to primary monitor
	*/
	_setOffset(){
		$area_offset := 0
		while (A_Index < this.monitor.primary)
			$area_offset := $area_offset - this.dimensions[A_Index]["width"]
			;dump(A_Index, "A_Index", 0)
		;dump($area_offset, "$area_offset", 0)
		For $monitor_num, $dimensions in this.dimensions {
			this.dimensions[$monitor_num]["offset"] := $area_offset
			$area_offset := $area_offset + this.dimensions[$monitor_num]["width"]
		}
	}





}

/**
	CALL CLASS FUNCTION
*/
Monitor(){
	return % new Monitor()
}


/*
-----------------------------------------------
	TEST FUNCTIONS
-----------------------------------------------
*/
/** setDimensions
*/
Monitor_setDimensions(){
	$monitor := Monitor()
	;dump($monitor, "$monitor", 1)
}

/*
-----------------------------------------------
	RUN TEST
-----------------------------------------------
*/
;Monitor_setDimensions()









/*
-----------------------------------------
	OLD FUNCTIONS
-----------------------------------------
*/
;
;Monitor_getResolution($monitor_number:=""){
;	MsgBox,262144,, "Function Monitor_getResolution() IS DEPRECATED, USE Monitor().getDimensions()"
;
;    SysGet, $MonitorCount, MonitorCount
;    if ($monitor_number > $MonitorCount )
;        MsgBox,262144,, Function Call Monitor_getResolution() `nargument: $monitor_number = %$monitor_number% `nmonitor_number is more then count of monitors, 1000
;
;
;    if $monitor_number=
;        $monitor_number := Mouse_getMonitorNumber()
;
;
;    SysGet, $MonitorArea, MonitorWorkArea, %$monitor_number%
;    $width  := $MonitorAreaRight  - $MonitorAreaLeft
;    $height := $MonitorAreaBottom - $MonitorAreaTop
;
;    SysGet, $Mon, Monitor, %$monitor_number%
;    $width  := $MonRight  - $MonLeft
;    $height := $MonBottom - $MonTop
;
;
;    MsgBox, width: %$width% -- height: %$height%
;    $resolution := [$width,$height]
;    $resolution := {"width":$width
;            ,"height":$height}
;    For key, value in $resolution
;        MsgBox %key% = %value%
;    return %$resolution%
;
;}
;

;
;$resolution := Monitor_getResolution(1)
;    MsgBox,262144,, % $resolution["width"] " x " $resolution["height"], 5

;$resolution := Monitor_getResolution(2)
;    MsgBox,262144,, % $resolution["width"] " x " $resolution["height"], 5





;;sleep, 1000
;WinGet, $winChromeId, ID, A
;
;;WinGetActiveTitle, $ActiveWinTitle
;;MsgBox,262144,, ActiveWinTitle: %$ActiveWinTitle%, 5
;
;$current_monitor := Window_getMonitorNumber($winChromeId)
;
;MsgBox,262144,, current_monitor: %$current_monitor%, 5
;
;$resolutionX := Monitor_getResolution(2)
;    MsgBox,262144,, % $resolutionX["width"] " x " $resolutionX["height"], 5


;$position :=  Window_getMonitorNumber(1)
;MsgBox,262144,, position: %$position%, 5
;$mouse_monitor := Mouse_getMonitorNumber()
;MsgBox,262144,, mouse_monitor: %$mouse_monitor%, 5

;    setTitleMatchMode, 2
;    WinActivate, Google Chrome
;    WinGetActiveTitle, $WinTitle
;	WinGet, $winChromeId, ID, %$WinTitle%
;	;MsgBox,262144,, winChromeId: %$winChromeId%, 5
;	WinGetPos, $win_X, $win_Y, $win_width, $win_Height, %$winChromeId%
;
;	;MsgBox,262144,, winChromeId: %$winChromeId%, 5
;	$current_monitor := Window_getMonitorNumber($winChromeId)
;	MsgBox,262144,, current_monitor: %$current_monitor%, 5
;	$resolution := Monitor_getResolution($current_monitor)
;
;	if ( $win_Height >=$resolution["height"]  )
;		MsgBox,262144,, FullScreen, 2