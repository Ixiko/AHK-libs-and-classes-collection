
global $MsgBoxActiveWindowID
global $setAlwaysOnTop

/** MsgBox
	
	@method message( $params* )	show MsgBox
	@method confirm( $params* )	show confirm box
	@method input( $params* )	show input box
	@method exit( $params* )	show MsgBox then exitScript
	
	@method alwaysOnTop( Toggle:=true )	set msg box always on top, return this

*/
Class MsgBox
{

	_params	:= []
	_title	:= ""
	_title_default	:= ""		
	_message	:= ""
	_timeout	:= ""
	_button	:= ""
	_options	:= {}	
	_defaults	:= { "x":"", "y":"", "w":"", "h":128, "default":"" }		

	__New()
	{
		$setAlwaysOnTop := true	
	}
	/** Show message box centered to window
		@params
			$title
			$message
			$timeout 
	 */
	message( $params* )
	{
		this._setParams($params)
		this._centerToWindow()

		MsgBox,262144, % this._title , % this._message, % this._timeout
		
		return this
	}
	/** Show confirm box centered to window
			@param string	$title	
			@param string	$message	
			@param string	$button	'yes|no'
			@param integer	$timeout 	
	 */
	confirm( $params* )
	{
		this._setParams($params)
		this._centerToWindow()

		if(RegExMatch( this._button, "i)yes" ))
			MsgBox, 4, % this._title , % this._message, % this._timeout
		
		else
			MsgBox,260, % this._title , % this._message, % this._timeout
	
		IfMsgBox, Yes
			return true		 
	}
	/** Show input box
			@param string	$title
			@param string	$message
			@param object	$options ; { "x":int, "y":int, "w":int, "h"int:, "default":string, "font":string }
			@param integer	$timeout
		
		@return string value || false if canceled
	 */
	input( $params* )
	{
		this._setParams($params)
		this._centerToWindow()
		
		InputBox, $value, % this._title, % this._message,, % this._options.w, % this._options.h, % this._options.x, % this._options.y,, % this._timeout, % this._options.default
		
		
		if ErrorLevel
			return false
		else
			return %$value%				
	}
	/** message before script exit
	 */
	exit( $params* )
	{
		this._findParamsTitleAndMessage()

		if( ! this._title )
			this._title_default := "ERROR - " A_ScriptName ; set default error title
		
		this.message($params*)
		ExitApp
	}
	/**
	 */
	alwaysOnTop($toggle:=true)
	{
		$setAlwaysOnTop := $toggle
		return this
	}
	
	
	
	
	/** 
	 */
	_setParams( $params )
	{
		this._params	:= $params
		
		this._setParamsDefaults()
		
		this._findParamsTitleAndMessage()
		this._findParamTimeout()		
		this._setButtonParam()
		this._findOptionsObject()				
	}
	/**
	 */
	_setParamsDefaults()
	{
		this._title	:= RegExReplace( A_ScriptName, "i)\.(ahk|exe)$", "" ) 
		this._timeout	:= 0
		this._button	:= "yes"
		this._options	:= this._defaults
	}
	/** Set title and message
		
		If 1 parameters	then it is title
		If 2 parameters	then 1st is title, 2nd is message
	 */
	_findParamsTitleAndMessage()
	{
		$length	:= this._params.Length()
		
		if($length==1)
			this._message := this._params[1]
		
		if($length>1){
			this._title 	:= this._isString(this._params[1]) ? this._params[1] : ""
			this._message	:= this._isString(this._params[2]) ? this._params[2] : ""
		}
		
		/* If title is not defined
		*/
		if( this._title && ! this._message ){
			this._message	:= this._title
			this._title	:= this._title_default
		}
			
		
		
	} 
	/** Find options object
		It is object in parameters 
	 */
	_findParamTimeout()
	{
		For $i, $param in this._params
			if $param is integer
				this._timeout	:= $param
	} 
	/** Find options object
		It is integer in parameters
	 */
	_findOptionsObject()
	{
		For $i, $param in this._params
			if( IsObject($param) )
				this._options	:= $param
		
		this._setOptionsDefaults()	 	
		
	}
	/**
	 */
	_setOptionsDefaults()
	{
		For $option, $value in this._defaults
			if( ! this._options[$option] )
				this._options[$option] := this._defaults[$option]
			 
	} 
	
	/** set which button is selected
		parameter is "yes|no"
	 */
	_setButtonParam()
	{
		For $i, $param in this._params
			if( RegExMatch( $param, "i)^(yes|no)$", $button ) )
				this._button := $button
	} 
	/**
	 */
	_centerToWindow()
	{
		WinGet, $MsgBoxActiveWindowID, ID, A
		OnMessage(0x44, "centerMsgToWinow")
	}
	/**
	 */
	_isString( $param )
	{
		if $param is number
			return false 			
		
		if ( IsObject($param) )
			return false
		
		return true 
	} 
	
	
}

/* OnMessage Callback
*/
centerMsgToWinow($wParam)
{
	;MsgBox,262144,wParam, %$wParam%,3 
	WinGetPos, $X, $Y, $W, $H, ahk_id %$MsgBoxActiveWindowID%
    if ($wParam == 1027 || $wParam == 1031) { ; AHK_DIALOG
        Process, Exist
        DetectHiddenWindows, On
        if WinExist("ahk_class #32770 ahk_pid " . ErrorLevel) {
			
			WinGetPos,,, $mW, $mH, A
			WinMove, ($W-$mW)/2 + $X, ($H-$mH)/2 + $Y -128
			
			if( $setAlwaysOnTop )
				WinSet, AlwaysOnTop, On, A
        }
    }
}












