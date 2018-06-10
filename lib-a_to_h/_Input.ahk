/*!
	Library: _Input Class
		_Input class is a combination of Hotkey and Hotstrings with advanced features. It serves an advanced, easy to use and invisible interface for user / application communication. Using _Input it is very simple to keep your code very tidy and clear and very easy to maintain.
	Author: HotKeyIt
	License: http://www.autohotkey.com/forum/viewtopic.php?t=65671
*/


/*!
	Class: _Input
		_Input class is a combination of Hotkey and Hotstrings with advanced features
		It serves an advanced, easy to use and invisible interface for user / application communication
		Using _Input it is very simple to keep your code very tidy and clear and very easy to maintain
	Inherits: No
	Example: @file:_Input_Example.ahk
*/




Class _Input {
  Options := ""
  EndKeys := ""
  MatchList := ""
  Parameters := []
  Function := []
  WatchInput := ""
  /*!
    Constructor: (EndKeys[,WatchInput,Options,MatchList])
        Creates an _Input class.
    Parameters:
      EndKeys - This Must be an Object containing {Keys:["Function",ParameterKey1,ParameterKey2,[ManyParams1Key1,ManyParams2Key1,...],...]} or {Keys:"Function"}.
        * Keys is a RegEx needle that will be searched in all available EndKeys
        * Function is the name of the function to call when key was hit
        * ParameterKey1...  = parameter to pass to function (will be last parameter in function)
        * - ParameterKey can be an array that will expand to parameters !!!
        !!! NOTE !!!
        > ; WHEN USING | SEPARATOR IN ENDKEYS, KEYS MUST BE GIVEN IN ALPHABETICAL ORDER !!!
        > MyInput := new _Input({"Enter|Tab":["Enter_Function","Enter","Tab"]})
        > ; FOLLOWING WOULD PRODUCE WRONG PARAMETERS BECAUSE KEYS ARE PROCESSED ALPHABETICALLY SO FIRST ENTER THAN TAB 
        > MyInput := new _Input({"Tab|Enter":["Input_Enter","Tab","Enter"]})
        * Simple keys can have the value in second param
        > ; For example 
        > MyInput := new _Input({Enter:["Input_Enter","User Pressed Enter"]})
        * NOTE AGAIN WHEN SPECIFYING SEVERAL ENDKEYS LIKE TAB|UP|DOWN THEY HAVE TO BE IN ALPHABETICAL ORDER TO MATCH PARAMETERS SO DOWN|TAB|UP
        > ; For example "F.*" would match F1 - F24 and "Numpad" would match all NumPad keys
        > ; So pressing F6 causes following call: Pressed_F(InputVar,CtrlDown,AltDown,ShiftDown,6)
        > MyInput := new _Input({"F.":["Pressed_F",1,2,3,4,5,6,7,8,9]})
        > 
        > ; Here pressing F6 causes following call: Pressed_F(InputVar,CtrlDown,AltDown,ShiftDown,1,2,3)
        > MyInput := new _Input({"F.":["Pressed_F",1,2,3,4,5,[1,2,3],7,8,9]})
        * Function:
        * User function needs to have at least 4 parameters when no parameters were specified
        > Input_Enter(ByRef Input,c,a,s){ ; C=CTRL, A=ALT, S=SHIFT
        > }
        * Otherwise 4 + as many as parameters for given key
        > Input_Enter(ByRef Input,c,a,s,e){ ; C=CTRL, A=ALT, S=SHIFT, E = Errorlevel parameter
        > }
      WatchInput - Name of a function that will be called using a timer and allows to see users input instantly.
        > ; For example
        > WatchingInput(ByRef Input){
        >   ToolTip % Input
        > }
      Options - see Input command (default set to MIA (accept modifiers/Ignore ahk input/append variable content (A -> only available in AHK_H)
      MatchList - see Input command
    Example:
      > #include <_Input>                                                                            ; Requred due to _Input Class
      > Input := new _Input({"Enter|Tab":["Input_Execute","User pressed Enter","User pressed Tab"]   ; Input_Execute will be called when pressed Enter or Tab
      >                     ,Delete:"Input_Delete",Escape:"Input_Exit"}                              ; Input_Delete will be called when pressed Delete
      >                     ,"Input_Watcher")                                                        ; Input_Watcher will be called constantly while Input in progress
      > MsgBox % Input.Input()                                                                       ; Watch Input and show input when finished
      > ExitApp
      > 
      > Input_Watcher(ByRef Input){                                                                  ; Function will be launched constantly
      >   ToolTip % Input
      > }
      > Input_Execute(ByRef Input,c,a,s,e){
      >   MsgBox % e "`nUser Input: " Input                                                          ; E contains the parameter we supplied above
      > }
      > Input_Delete(ByRef Input,c,a,s){
      >   Input:=""                                                                                  ; Input is ByRef so we can modify it
      > }
      > Input_Exit(ByRef Input,c,a,s){
      >   Return 1                                                                                  ; Notifies Input Method to finish Input
      > }
    Returns:
      Input object that can be used to grab user or artficial input
  */
  __New(EndKeys,WatchInput="",Options="MIA",MatchList=""){
    static _EndKeys:=" AppsKey Backspace Break Browser_Back Browser_Favorites Browser_Forward Browser_Home Browser_Refresh Browser_Search Browser_Stop CapsLock CtrlBreak Delete Down End Enter Escape F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 F13 F14 F15 F16 F17 F18 F19 F20 F21 F22 F23 F24 Help Home Insert LAlt Launch_App1 Launch_App2 Launch_Mail Launch_Media LControl Left LShift LWin Media_Next Media_Play_Pause Media_Prev Media_Stop NumLock Numpad0 Numpad1 Numpad2 Numpad3 Numpad4 Numpad5 Numpad6 Numpad7 Numpad8 Numpad9 NumpadAdd NumpadAdd NumpadClear NumpadDel NumpadDiv NumpadDiv NumpadDot NumpadDown NumpadEnd NumpadEnter NumpadEnter NumpadHome NumpadIns NumpadLeft NumpadMult NumpadMult NumpadPgDn NumpadPgUp NumpadRight NumpadSub NumpadSub NumpadUp Pause PgDn PgUp PrintScreen RAlt RControl Right RShift RWin ScrollLock Sleep Space Tab Up Volume_Down Volume_Mute Volume_Up ^ ° ! "" § $ `% & / ( ) = ? `` ´ * + ~ ' # < > | , . `; : - _ { } [ ] 0 1 2 3 4 5 6 7 8 9 "
    this.WatchInput := WatchInput
    this.Options := Options
    this.MatchList := MatchList
    for EndKey,Function in EndKeys
    {
      If RegExMatch(" Max TimeOut Match ","i)\s(" EndKey ")\s") ; ErrorLevel is not an EndKey: , go different route
      {
        idx:=1                      ; init function parameter index to 0
        Loop,Parse,EndKey,|         ; in case we have several Errorlevel entries, e.g. Max|Timeout|Match (will launch same function)
        {
          this.Parameters[A_LoopField]:=[]   ; create an array object for parameters
          idx++                     ; increase index by one, will be set to 1 on first run
          If IsObject(Function){    ; parameter is an array object containing function and parameters for function
            thisFunction[A_LoopField]:=Function.1                  ; function name
            this.Parameters[A_LoopField].Insert(Function[idx])        ; function parameters
          } else this.Function[A_LoopField]:=Function              ; no object was given, so it is a function name only
        }
      } else {   ; ErrorLevel is EndKey:
        ; Replace Ctrl to Control and Control+Alt+Shift+Win to LAlt|RAlt....
        EndKey:=RegExReplace(RegExReplace(EndKey,"i)([LR])?Ctrl","$1Control"),"i)(Alt|Control|Shift|Win)","L$1$2|R$1$2")
        idx:=1                      ; init function parameter index to 0
        Loop,Parse,_EndKeys,%A_Space% ; check all available Keys for match in our pattern
        {
          If (RegExMatch(A_LoopField,"i)^(" EndKey ")$")){
            this.EndKeys .= "{" A_LoopField "}" ; add EndKey to list of EndKeys
            this.Parameters["EndKey:"  A_LoopField]:=[] ; create an array object for parameters
            idx++                     ; increase index by one, will be set to 1 on first run
            If IsObject(Function){    ; parameter is an array object containing function and parameters for function
              this.Function["EndKey:" A_LoopField]:=Function.1                   ; function name
              this.Parameters["EndKey:" A_LoopField].Insert(Function[idx])       ; function parameters
            } else this.Function["EndKey:" A_LoopField]:=Function                ; no object was given, so it is a function name only
          }
        }
      }
    }
  }
  
  /*!
    Method: Input([ByRef InputVar,Timer,Options,MatchList])
      Starts Watching Input
    Parameters:
      InputVar - ByRef parameter that will be passed to the watching function and key functions
      Timer - Determines how often in ms the function WatchInput will be called, default is 50 ms
      Options - Use different Options
      MatchList - Use different MatchList
			AlwaysNotify - Watching Function will be called even if input variable did not change
    Returns: Entered (final) input
  */
  Input(ByRef Input="",Timer=25,Options="",MatchList="",AlwaysNotify=0){
    If IsFunc(Function:=this.WatchInput) ; check if we have a valid function for watching input
      SetTimer,_Input,% Timer       ; set timer to run watching function
		else Function:=""
    FuncObj:=this.Function
    Loop {                          ; repeat command until ErrorLevel=NewInput or a function returns true (1)
      Input,Input,% Options!=""?Options:this.Options,% this.EndKeys,% MatchList!=""?MatchList:this.MatchList ; pass parameters created previously
			If Function
				SetTimer,_Input,Off         ; disable watching function while processing input and in case we break
			If (ErrorLevel="NewInput"     ; NewInput or a function that returns true will break the Loop
        || FuncObj[ErrorLevel](Input,GetKeyState("Ctrl","P"),GetKeyState("Alt","P"),GetKeyState("Shift","P"),this.Parameters[ErrorLevel]*))
        break
			If Function
				SetTimer,_Input,% Timer     ; enable watching function again
    }
    Return Input                    ; return entered input
    
    _Input:                         ; Private label only accessible to Input method
			If (!AlwaysNotify && Previous=Input)
				return
			Function.(Input)              ; launch watching function
			If !AlwaysNotify
				Previous:=Input
    Return
  }
	/*!
		End of class
	*/
}