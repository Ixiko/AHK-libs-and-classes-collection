pcre_callout = RegExDebug
RegExDebug(fnMatch,fnCalloutNumber,fnFoundPos,fnHaystack,fnNeedleRegEx)
{
	; RegEx debugging window
	; https://www.autohotkey.com/docs/misc/RegExCallout.htm#auto
	; add C to the regex options e.g. "imSC)..." to trigger debugging callout
	; MsgBox fnMatch: %fnMatch% `nfnCalloutNumber: %fnCalloutNumber% `nfnFoundPos: %fnFoundPos% `nfnHaystack: %fnHaystack% `nfnNeedleRegEx: %fnNeedleRegEx%


	; declare local, global, static variables
    Static HSTTextL, HSTTextC, HSTTextR, LastMatchFoundString := ""


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters


		; initialise variables
		; http://www.pcre.org/pcre.txt#SearchFor THE CALLOUT INTERFACE
		pad               := A_PtrSize = 8 ? 4 : 0  ; Compensate for 64-bit data alignment.
		start_match       := NumGet(A_EventInfo,12    +A_PtrSize*2,"Int")
		current_position  := NumGet(A_EventInfo,16    +A_PtrSize*2,"Int")
		pattern_position  := NumGet(A_EventInfo,28+pad+A_PtrSize*3,"Int")
		next_item_length  := NumGet(A_EventInfo,32+pad+A_PtrSize*3,"Int")
		version           := NumGet(A_EventInfo, 0                ,"Int")
		callout_number    := NumGet(A_EventInfo, 4                ,"Int")
		offset_vector     := NumGet(A_EventInfo, 8                      )
		subject           := NumGet(A_EventInfo, 8    +A_PtrSize        )
		subject_length    := NumGet(A_EventInfo, 8    +A_PtrSize*2,"Int")
		capture_top       := NumGet(A_EventInfo,20    +A_PtrSize*2,"Int")
		capture_last      := NumGet(A_EventInfo,24    +A_PtrSize*2,"Int")
		callout_data      := NumGet(A_EventInfo,28+pad+A_PtrSize*2      )

		If (version >= 2)
			mark := StrGet(NumGet(A_EventInfo,36+pad+A_PtrSize*3,"Int"),"UTF-8")
		
		SpaceDisplayChar := "·" ; Middle Dot


		; format text for display
		; _HAYSTACK := SubStr(fnHaystack   , 1, start_match     ) . "»" SubStr(fnHaystack   , start_match      + 1, current_position - start_match) . "«" SubStr(fnHaystack   , current_position + 1                   )
		; _NEEDLE   := SubStr(fnNeedleRegEx, 1, pattern_position) . "»" SubStr(fnNeedleRegEx, pattern_position + 1, next_item_length              ) . "«" SubStr(fnNeedleRegEx, pattern_position + 1 + next_item_length)

		HayL := SubStr(fnHaystack,1                 ,start_match                 )
		HayC := SubStr(fnHaystack,start_match     +1,current_position-start_match)
		HayR := SubStr(fnHaystack,current_position+1                             )
		HayL := StrReplace(StrReplace(StrReplace(HayL,"`n","``n"),"`r","``r"),A_Space,SpaceDisplayChar)
		HayC := StrReplace(StrReplace(StrReplace(HayC,"`n","``n"),"`r","``r"),A_Space,SpaceDisplayChar)
		HayR := StrReplace(StrReplace(StrReplace(HayR,"`n","``n"),"`r","``r"),A_Space,SpaceDisplayChar)
		HayLLen := StrLen(HayL)
		HayCLen := StrLen(HayC)
		HayRLen := StrLen(HayR)
		HaystackString     :=                  HayL         HayC                      HayR
		MatchedSoFarString := StrReplicate(" ",HayLLen) "»" HayC "«" StrReplicate(" ",HayRLen)
		
		NeedleL := SubStr(fnNeedleRegEx,1                                  , pattern_position)
		NeedleC := SubStr(fnNeedleRegEx,pattern_position+1                 , next_item_length)
		NeedleR := SubStr(fnNeedleRegEx,pattern_position+1+next_item_length                  )
		NeedleLLen := StrLen(NeedleL)
		NeedleCLen := StrLen(NeedleC)
		NeedleRLen := StrLen(NeedleR)
		LookingToMatchString := StrReplicate(" ",NeedleLLen) "»" StrReplace(NeedleC,A_Space,SpaceDisplayChar) "«" StrReplicate(" ",NeedleRLen)
		
		LastMatchFoundString := ""
		If (pattern_position = StrLen(fnNeedleRegEx)) ; matched all elements
		{
			LastMatchFoundString := StrReplace(fnMatch,A_Space,SpaceDisplayChar)
			LastMatchFoundString := StrReplace(LastMatchFoundString,"`r","``r")
			LastMatchFoundString := StrReplace(LastMatchFoundString,"`n","``n")
		}
			
		NeedleRegExString  := StrReplace(fnNeedleRegEx,A_Space,SpaceDisplayChar)
		NeedleRegExString  := StrReplace(NeedleRegExString,"`a","``a")
		NeedleRegExString  := StrReplace(NeedleRegExString,"`n","``n")
		NeedleRegExString  := StrReplace(NeedleRegExString,"`r","``r")
		
		InfoTipText := ""
		InfoTipText .= "Haystack       : " A_Space HaystackString       "`r`n"
		InfoTipText .= "MatchedSoFar   : "         MatchedSoFarString   "`r`n"
		InfoTipText .= "NeedleRegEx    : " A_Space NeedleRegExString    "`r`n"
		InfoTipText .= "LookingToMatch : "         LookingToMatchString "`r`n"
		InfoTipText .= "MatchFound     : "         LastMatchFoundString


		; display text
		InfoTipX := A_ScreenWidth
		InfoTipY := Floor(A_ScreenHeight/2)
		InfoTipMatch := LastMatchFoundString ? 1 : 0
		Infotip(InfoTipText,InfoTipX,InfoTipY,,"RegExDebug",InfoTipMatch,-1)
		Pause
		Infotip(,,,,"RegExDebug")

	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing

; Var := "http://www.google.com"
; Var := "https://www.google.com"
Var := "P:\www\google\com"
a := RegExReplace(Var,"imSC)(https?|[A-Z])?[:\\/][\\/].*","$0")

#!p:: ; pause app
Pause, Toggle, 1 ; toggle pause on underlying thread (to pause anything currently in action)
Return

*/
