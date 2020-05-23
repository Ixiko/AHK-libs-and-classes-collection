;========================================================================
; 
; Function:     VarHistory
; Description:  Allows working with variable history
; Online Ref.:  http://www.autohotkey.net/~MasterFocus/VarHistory.ahk
; TEMPORARY LINK!! CHECK MY HOME TOPIC MEANWHILE !!
; http://www.autohotkey.com/community/viewtopic.php?f=2&t=88198
;
; Last Update:  17/July/2012 03:30
;
; Created by:   MasterFocus
;               http://u.ahk.me/MasterFocus
;
; Based on a request (IRC) by MorePowah
;
;========================================================================
;
; p_Dest [, p_Orig, p_Show, p_Func]
;
; + Required parameters:
; - p_Dest   The variable whose history should be changed/listed/erased
;
; + Optional parameters:
; - p_Orig   New value for the variable
; - p_Show   Number of latest history entries to work with
; - p_Func   Secondary function to execute on each specified entry
;
; The function allows setting new values for a certain variable while storing
; changes. Everytime a new value is set, the variable's history gains one more
; entry. These entries can be passed to a secondary function (all of them or
; just some of the latest ones). Since the variable's history is stored in a
; group of static variables, there's also an option to reset it, possibly
; avoiding memory issues. Please see the examples for detailed usage.
;
; If the variable receives new content, the function returns the number of
; history entries currently stored. The reset feature returns 0. The other
; calls (which use the secondary function) will return the same thing that
; the secondary function returns for only the last processed history entry.
;
;========================================================================

VarHistory(p_Dest,p_Orig="",p_Show=0,p_Func="") {
    Static
    %p_Dest%0 := (%p_Dest%0=="") ? 0 : %p_Dest%0
    Local l_Ret := "" , l_Index := 0 , l_Temp
    If IsFunc(p_Func) {
        Loop, % ( l_Temp := ( p_Show > %p_Dest%0 ) ? p_Show : %p_Dest%0 )
            l_Index := l_Temp-A_Index+1 , l_Ret := %p_Func%(%p_Dest%%l_Index%)
        Return l_Ret
    }
    If ( p_Orig == "" ) {
        Loop, % %p_Dest%0
            %p_Dest%%A_Index% := ""
        Return ( %p_Dest%0 := 0 )
    }
    l_Temp := %p_Dest%0 := %p_Dest%0 + 1
    %p_Dest% := %p_Dest%%l_Temp% := p_Orig
    Return l_Temp
}

;************************************************************************
;************************************************************************
;************************************************************************

;======================================================
; !! EXAMPLE !!
;
; VarHistory("var")
;    Resets all stored history for var
;
; VarHistory("var",new)
;    Main functionality - same as " var := new ", but adds it to the var history
;
; VarHistory("var",0,N,"Func")
;    Executes Func() for the latest N history entries and returns the returned value of the last function call
;
; VarHistory("var",0,0,"Func")
;    Executes Func() for all history entries and returns the returned value of the last function call
;
;======================================================

Loop, {
  Random, NewValue, -10, 10
  VarHistory("wtf",NewValue)
  ToolTip, % "Index: "A_Index "`nSum of last 50 values: " VarHistory("wtf",0,50,"SumAll")
  SumAll()
  Sleep, 50
}
;-------------------------
SumAll(x="") {
  Static SUM
  If ( x == "" ) {
    SUM := x
	Return SUM
  }
  SUM += x
  Return SUM
}