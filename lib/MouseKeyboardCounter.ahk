;To do
;Read instructions at the begining of "DetailedStatistics:" and do that (later maybe)
Letter_string = qqq,www,eee,rrr,ttt,yyy,uuu,iii,ooo,ppp,aaa,sss,ddd,fff,ggg,hhh,jjj,kkk,lll,zzz,xxx,ccc,vvv,bbb,nnn,mmm
GoSub,ResetCounters
Menu,Tray,NoStandard
Menu,Tray,Add,Reset Counters,ResetCounters_menu
Menu,Tray,Add
Menu,Tray,Add,Show overall detailed statistics,DetailedStatistics_overall
Menu,Tray,Add,Show current run detailed statistics,DetailedStatistics_currentrun
Menu,Tray,Add

Menu,SubMenuCopy,Add,Copy simple overall counters to clipboard,ClipBoard_1
Menu,SubMenuCopy,Add,Copy simple current run counters to clipboard,ClipBoard_2
Menu,SubMenuCopy,Add
Menu,SubMenuCopy,Add,Copy simple overall statistics to clipboard,Statistics_T1_2
Menu,SubMenuCopy,Add,Copy simple current run statistics to clipboard,Statistics_T2_2
Menu,SubMenuCopy,Add
Menu,SubMenuCopy,Add,Copy detailed overall counts to clipboard,Clipboard_overall_counts
Menu,SubMenuCopy,Add,Copy detailed current run counts to clipboard,Clipboard_current_run_counts
Menu,Tray,Add,Copy to clipboard, :SubMenuCopy

Menu,SubMenuOptions,Add,Count Other keys pressed,Letters
Menu,SubMenuOptions,Add,Count Numpad keys pressed,Numbers
Menu,SubMenuOptions,Add,Maintain count between sessions,Maintain
Menu,SubMenuOptions,Add
Menu,SubMenuOptions,Add,Don't Show Pop-up message at startup,Pop-up
Menu,SubMenuOptions,Add,Hide tray icon,Hide_Icon
Menu,SubMenuOptions,Add
Menu,SubMenuOptions,Add,Autostart at logon,ShortCut
Menu,Tray,Add,Options, :SubMenuOptions

Menu,Tray,Add
Menu,Tray,Add,About,About
Menu,Tray,Add,Exit,Exit

GoSub,InitializeVariables
GoSub,UpdateTrayTip
#MaxHotkeysPerInterval 2000
SetBatchLines -1
If (Popup_Message != 0){
	TrayTip, M&K Counter,Program started successfully`n`nHover over for counts`nCounts are logged to "M&K Counter.log" at exit.`nRight click for more options,,1
}
OnExit,LogAndExit
Exit

*~LButton::LM++
*~MButton::MM++
*~RButton::RM++
*~WheelUp::MWU++
*~WheelDown::MWD++

if (NUMB = 1){
	*~Numpad0 Up::Np0++
	*~Numpad1 Up::Np1++
	*~Numpad2 Up::Np2++
	*~Numpad3 Up::Np3++
	*~Numpad4 Up::Np4++
	*~Numpad5 Up::Np5++
	*~Numpad6 Up::Np6++
	*~Numpad7 Up::Np7++
	*~Numpad8 Up::Np8++
	*~Numpad9 Up::Np9++
	
	*~NumpadDot Up::Np10++
	*~NumpadDiv Up::Np11++
	*~NumpadMult Up::Np12++
	*~NumpadAdd Up::Np13++
	*~NumpadSub Up::Np14++
	*~NumpadEnter Up::Np15++

	*~NumpadIns Up::Np16++
	*~NumpadEnd Up::Np17++
	*~NumpadDown Up::Np18++
	*~NumpadPgDn Up::Np19++
	*~NumpadLeft Up::Np20++
	*~NumpadClear Up::Np21++
	*~NumpadRight Up::Np22++
	*~NumpadHome Up::Np23++
	*~NumpadUp Up::Np24++
	*~NumpadPgUp Up::Np25++
	*~NumpadDel Up::Np26++
	
	*~NumLock Up::Np27++
}

if (LET = 1){
	*~q Up::qqq++
	*~w Up::www++
	*~e Up::eee++
	*~r Up::rrr++
	*~t Up::ttt++
	*~y Up::yyy++
	*~u Up::uuu++
	*~i Up::iii++
	*~o Up::ooo++
	*~p Up::ppp++
	*~a Up::aaa++
	*~s Up::sss++
	*~d Up::ddd++
	*~f Up::fff++
	*~g Up::ggg++
	*~h Up::hhh++
	*~j Up::jjj++
	*~k Up::kkk++
	*~l Up::lll++
	*~z Up::zzz++
	*~x Up::xxx++
	*~c Up::ccc++
	*~v Up::vvv++
	*~b Up::bbb++
	*~n Up::nnn++
	*~m Up::mmm++
	
	*~1::
	If (sscs23 = 0){
		If GetKeyState("Shift"){
			ssc23++ ;!
			sscs23 = 1
		} else {
			n1++ ;1
			sscs23 = 1
		}
	}
	Return
	*~1 Up::sscs23 = 0
	
	*~2::
	If (sscs24 = 0){
		If GetKeyState("Shift"){
			ssc24++ ;@
			sscs24 = 1
		} else {
			n2++ ;2
			sscs24 = 1
		}
	}
	Return
	*~2 Up::sscs24 = 0
	
	*~3::
	If (sscs25 = 0){
		If GetKeyState("Shift"){
			ssc25++ ;#
			sscs25 = 1
		} else {
			n3++ ;3
			sscs25 = 1
		}
	}
	Return
	*~3 Up::sscs25 = 0
	
	*~4::
	If (sscs26 = 0){
		If GetKeyState("Shift"){
			ssc26++ ;$
			sscs26 = 1
		} else {
			n4++ ;4
			sscs26 = 1
		}
	}
	Return
	*~4 Up::sscs26 = 0
	
	*~5::
	If (sscs27 = 0){
		If GetKeyState("Shift"){
			ssc27++ ;%
			sscs27 = 1
		} else {
			n5++ ;5
			sscs27 = 1
		}
	}
	Return
	*~5 Up::sscs27 = 0
	
	*~6::
	If (sscs28 = 0){
		If GetKeyState("Shift"){
			ssc28++ ;^
			sscs28 = 1
		} else {
			n6++ ;6
			sscs28 = 1
		}
	}
	Return
	*~6 Up::sscs28 = 0
	
	*~7::
	If (sscs29 = 0){
		If GetKeyState("Shift"){
			ssc29++ ;&
			sscs29 = 1
		} else {
			n7++ ;7
			sscs29 = 1
		}
	}
	Return
	*~7 Up::sscs29 = 0
	
	*~8::
	If (sscs30 = 0){
		If GetKeyState("Shift"){
			ssc30++ ;*
			sscs30 = 1
		} else {
			n8++ ;8
			sscs30 = 1
		}
	}
	Return
	*~8 Up::sscs30 = 0
	
	*~9::
	If (sscs31 = 0){
		If GetKeyState("Shift"){
			ssc31++ ;(
			sscs31 = 1
		} else {
			n9++ ;9
			sscs31 = 1
		}
	}
	Return
	*~9 Up::sscs31 = 0
	
	*~0::
	If (sscs32 = 0){
		If GetKeyState("Shift"){
			ssc32++ ;)
			sscs32 = 1
		} else {
			n0++ ;0
			sscs32 = 1
		}
	}
	Return
	*~0 Up::sscs32 = 0
	
	*~VKC0::
	If (sscs12 = 0){
		If GetKeyState("Shift"){
			ssc12++ ;~
			sscs12 = 1
		} else {
			ssc1++ ;`
			sscs12 = 1
		}
	}
	Return
	*~VKC0 Up::sscs12 = 0
	
	*~VKBA::
	If (sscs13 = 0){
		If GetKeyState("Shift"){
			ssc2++ ;:
			sscs13 = 1
		} else {
			ssc13++ ;;
			sscs13 = 1
		}
	}
	Return
	*~VKBA Up::sscs13 = 0
	
	*~VKBB::
	If (sscs14 = 0){
		If GetKeyState("Shift"){
			ssc3++ ;+
			sscs14 = 1
		} else {
			ssc14++ ;=
			sscs14 = 1
		}
	}
	Return
	*~VKBB Up::sscs14 = 0
	
	*~VKBC::
	If (sscs15 = 0){
		If GetKeyState("Shift"){
			ssc15++ ;<
			sscs15 = 1
		} else {
			ssc4++ ;,
			sscs15 = 1
		}
	}
	Return
	*~VKBC Up::sscs15 = 0
	
	*~VKBD::
	If (sscs16 = 0){
		If GetKeyState("Shift"){
			ssc16++ ;_
			sscs16 = 1
		} else {
			ssc5++ ;-
			sscs16 = 1
		}
	}
	Return
	*~VKBD Up::sscs16 = 0
	
	*~VKBE::
	If (sscs17 = 0){
		If GetKeyState("Shift"){
			ssc17++ ;>
			sscs17 = 1
		} else {
			ssc6++ ;.
			sscs17 = 1
		}
	}
	Return
	*~VKBE Up::sscs17 = 0
	
	*~VKBF::
	If (sscs18 = 0){
		If GetKeyState("Shift"){
			ssc18++ ;?
			sscs18 = 1
		} else {
			ssc7++ ;/
			sscs18 = 1
		}
	}
	Return
	*~VKBF Up::sscs18 = 0
	
	*~VKDB::
	If (sscs19 = 0){
		If GetKeyState("Shift"){
			ssc19++ ;{
			sscs19 = 1
		} else {
			ssc8++ ;[
			sscs19 = 1
		}
	}
	Return
	*~VKDB Up::sscs19 = 0
	
	*~VKDC::
	If (sscs20 = 0){
		If GetKeyState("Shift"){
			ssc20++ ;|
			sscs20 = 1
		} else {
			ssc9++ ;\
			sscs20 = 1
		}
	}
	Return
	*~VKDC Up::sscs20 = 0
	
	*~VKDD::
	If (sscs21 = 0){
		If GetKeyState("Shift"){
			ssc21++ ;}
			sscs21 = 1
		} else {
			ssc10++ ;]
			sscs21 = 1
		}
	}
	Return
	*~VKDD Up::sscs21 = 0
	
	*~VKDE::
	If (sscs22 = 0){
		If GetKeyState("Shift"){
			ssc22++ ;"
			sscs22 = 1
		} else {
			ssc11++ ;'
			sscs22 = 1
		}
	}
	Return
	*~VKDE Up::sscs22 = 0
	
	*~Space Up::ok1++
	*~LAlt Up::ok2++
	*~RAlt Up::ok3++
	*~LWin::ok4++
	*~RWin::ok5++
	*~AppsKey Up::ok6++
	*~LControl Up::ok7++
	*~RControl Up::ok8++
	*~LShift Up::ok9++
	*~RShift Up::ok10++
	*~Enter Up::ok11++
	*~Backspace Up::ok12++
	*~CapsLock Up::ok13++
	*~Tab Up::ok14++
	*~Up Up::ok15++
	*~Down Up::ok16++
	*~Left Up::ok17++
	*~Right Up::ok18++
	*~Delete Up::ok19++
	*~Insert Up::ok20++
	*~Home Up::ok21++
	*~End Up::ok22++
	*~PgUp Up::ok23++
	*~PgDn Up::ok24++
	*~PrintScreen Up::ok25++
	*~ScrollLock Up::ok26++
	*~ScrollLock::
	If GetKeyState("Insert"){
		If (A_IconHidden = 0){
			Menu,Tray,NoIcon
			FileAppend,Hide Tray icon file.,%TP4%
		} else {
			Menu,Tray,Icon
			FileDelete,%TP4%
			Menu,SubMenuOptions,UnCheck,Hide tray icon
		}
	}
	Return
	*~Insert::
	If GetKeyState("ScrollLock"){
		If (A_IconHidden = 0){
			Menu,Tray,NoIcon
			FileAppend,Hide Tray icon file.,%TP4%
		} else {
			Menu,Tray,Icon
			FileDelete,%TP4%
			Menu,SubMenuOptions,UnCheck,Hide tray icon
		}
	}
	Return
	*~Pause Up::ok27++
	*~F1 Up::ok28++
	*~F2 Up::ok29++
	*~F3 Up::ok30++
	*~F4 Up::ok31++
	*~F5 Up::ok32++
	*~F6 Up::ok33++
	*~F7 Up::ok34++
	*~F8 Up::ok35++
	*~F9 Up::ok36++
	*~F10 Up::ok37++
	*~F11 Up::ok38++
	*~F12 Up::ok39++
	*~Escape Up::
	ok40++
	if (repeat_message = 1){
		repeat_message = 0
		GoSub,Statistics_run
	}
	Return
}

Format_To_7(Temp_Number)
{
	If (Temp_Number != 0.000000){
		SetFormat,Float,7.6
		Temp_Number += 0.0
		loop 7 {
			Break_Go = 0
			StringLeft,ZerosLeft,Temp_Number,1
			StringRight,ZerosRight,Temp_Number,1
			If (ZerosLeft = 0){
				StringRight,Temp_Number,Temp_Number,(StrLen(Temp_Number) - 1)
			} else {
				Break_Go++
			}
			If (ZerosRight = 0){
				StringLeft,Temp_Number,Temp_Number,(StrLen(Temp_Number) - 1)
			} else {
				Break_Go++
			}
			If (Break_Go = 2){
				Break
			}
		}
		loop 7 {
			If (StrLen(Temp_Number) < 8){
				Temp_Number = 0%Temp_Number%
			} else {
				Break
			}
		}
		Loop 15 {
			If (StrLen(Temp_Number) > 8){
				StringLeft,Temp_Number,Temp_Number,(StrLen(Temp_Number) - 1)
			} else {
				Break
			}
		}
	} else {
		Temp_Number = 0000000
	}
	Return Temp_Number
}

Current_Run_Counts:
LM := LM - ReadLM
MM := MM - ReadMM
RM := RM - ReadRM
MWU := MWU - ReadMWU
MWD := MWD - ReadMWD
II = 0
Loop 28{
	np%II% := np%II% - Readnp%II%
	II++
}
II = 0
Loop 10{
	n%II% := n%II% - Readn%II%
	II++
}
II = 1
Loop 32{
	ssc%II% := ssc%II% - Readssc%II%
	II++
}
II = 1
Loop 40{
	ok%II% := ok%II% - Readok%II%
	II++
}
Loop,parse,Letter_string,`,
{
	%A_LoopField% := %A_LoopField% - Read%A_LoopField%
}
Return

Normal_Counts:
LM := LM + ReadLM
MM := MM + ReadMM
RM := RM + ReadRM
MWU := MWU + ReadMWU
MWD := MWD + ReadMWD
II = 0
Loop 28{
	np%II% := np%II% + Readnp%II%
	II++
}
II = 0
Loop 10{
	n%II% := n%II% + Readn%II%
	II++
}
II = 1
Loop 32{
	ssc%II% := ssc%II% + Readssc%II%
	II++
}
II = 1
Loop 40{
	ok%II% := ok%II% + Readok%II%
	II++
}
Loop,parse,Letter_string,`,
{
	%A_LoopField% := %A_LoopField% + Read%A_LoopField%
}
Return

Clipboard_overall_counts:
TAT := OriginalStartTime +((A_TickCount / 1000) - TST)
ToCopy = Overall Counts:`r`n`r`nTotal overall runtime in seconds: %TAT%`r`n`r`n
ToCopy = %ToCopy%Left Mouse: %LM%`r`n
ToCopy = %ToCopy%Middle Mouse: %MM%`r`n
ToCopy = %ToCopy%Right Mouse: %RM%`r`n
ToCopy = %ToCopy%Mouse Wheel Up: %MWU%`r`n
ToCopy = %ToCopy%Mouse Wheel Down: %MWD%`r`n
If (LET = 1){
	;Letters
	ToCopy = %ToCopy%A: %aaa%`r`nB: %bbb%`r`nC: %ccc%`r`nD: %ddd%`r`nE: %eee%`r`nF: %fff%`r`nG: %ggg%`r`nH: %hhh%`r`nI: %iii%`r`nJ: %jjj%`r`nK: %kkk%`r`nL: %lll%`r`nM: %mmm%`r`nN: %nnn%`r`nO: %ooo%`r`nP: %ppp%`r`nQ: %qqq%`r`nR: %rrr%`r`nS: %sss%`r`nT: %ttt%`r`nU: %uuu%`r`nV: %vvv%`r`nW: %www%`r`nX: %xxx%`r`nY: %yyy%`r`nZ: %zzz%`r`n
	;Numbers
	ToCopy = %ToCopy%1: %n1%`r`n2: %n2%`r`n3: %n3%`r`n4: %n4%`r`n5: %n5%`r`n6: %n6%`r`n7: %n7%`r`n8: %n8%`r`n9: %n9%`r`n0: %n0%`r`n
	;Control
	ToCopy = %ToCopy%Space: %ok1%`r`nLeft Alt: %ok2%`r`nRight Alt: %ok3%`r`nLeft Windows: %ok4%`r`nRight Windows: %ok5%`r`nApps Key: %ok6%`r`nLeft Control: %ok7%`r`nRight Control: %ok8%`r`nLeft Shift: %ok9%`r`nRight Shift: %ok10%`r`nEnter: %ok11%`r`nBackspace: %ok12%`r`nCapslock: %ok13%`r`nTab: %ok14%`r`nUp: %ok15%`r`nDown: %ok16%`r`nLeft: %ok17%`r`nRight: %ok18%`r`nDelete: %ok19%`r`nInsert: %ok20%`r`nHome: %ok21%`r`nEnd: %ok22%`r`nPage Up: %ok23%`r`nPage Down: %ok24%`r`nPrintScreen: %ok25%`r`nScroll-Lock: %ok26%`r`nPause-Break: %ok27%`r`nEscape: %ok40%`r`n
	;Function
	ToCopy = %ToCopy%F1: %ok28%`r`nF2: %ok29%`r`nF3: %ok30%`r`nF4: %ok31%`r`nF5: %ok32%`r`nF6: %ok33%`r`nF7: %ok34%`r`nF8: %ok35%`r`nF9: %ok36%`r`nF10: %ok37%`r`nF11: %ok38%`r`nF12: %ok39%`r`n
	;Special
	ToCopy = %ToCopy%``: %ssc1%`r`n:: %ssc2%`r`n+: %ssc3%`r`n,: %ssc4%`r`n-: %ssc5%`r`n.: %ssc6%`r`n/: %ssc7%`r`n[: %ssc8%`r`n\: %ssc9%`r`n]: %ssc10%`r`n': %ssc11%`r`n~: %ssc12%`r`n`;: %ssc13%`r`n=: %ssc14%`r`n<: %ssc15%`r`n_: %ssc16%`r`n>: %ssc17%`r`n?: %ssc18%`r`n{: %ssc19%`r`n|: %ssc20%`r`n}: %ssc21%`r`n": %ssc22%`r`n!: %ssc23%`r`n@: %ssc24%`r`n#: %ssc25%`r`n$: %ssc26%`r`n`%: %ssc27%`r`n^: %ssc28%`r`n&: %ssc29%`r`n*: %ssc30%`r`n(: %ssc31%`r`n): %ssc32%`r`n
}
If (NUMB = 1){
	ToCopy = %ToCopy%Numpad 0 %np0%`r`nNumpad 1 %np1%`r`nNumpad 2 %np2%`r`nNumpad 3 %np3%`r`nNumpad 4 %np4%`r`nNumpad 5 %np5%`r`nNumpad 6 %np6%`r`nNumpad 7 %np7%`r`nNumpad 8 %np8%`r`nNumpad 9 %np9%`r`nNumpad . %np10%`r`nNumpad / %np11%`r`nNumpad * %np12%`r`nNumpad + %np13%`r`nNumpad - %np14%`r`nNumpad Enter %np15%`r`nNumpad Insert %np16%`r`nNumpad End %np17%`r`nNumpad Down %np18%`r`nNumpad Page Down %np19%`r`nNumpad Left %np20%`r`nNumpad Clear %np21%`r`nNumpad Right %np22%`r`nNumpad Home %np23%`r`nNumpad Up %np24%`r`nNumpad Page Up %np25%`r`nNumpad Delete %np26%`r`nNumpad Lock %np27%`r`n
}
ClipBoard := ToCopy
Return

Clipboard_current_run_counts:
TAT := (A_TickCount / 1000) - TST
ToCopy = Current Run Counts:`r`n`r`nTotal current runtime in seconds: %TAT%`r`n`r`n
GoSub,Current_Run_Counts
ToCopy = %ToCopy%Left Mouse: %LM%`r`n
ToCopy = %ToCopy%Middle Mouse: %MM%`r`n
ToCopy = %ToCopy%Right Mouse: %RM%`r`n
ToCopy = %ToCopy%Mouse Wheel Up: %MWU%`r`n
ToCopy = %ToCopy%Mouse Wheel Down: %MWD%`r`n
If (LET = 1){
	;Letters
	ToCopy = %ToCopy%A: %aaa%`r`nB: %bbb%`r`nC: %ccc%`r`nD: %ddd%`r`nE: %eee%`r`nF: %fff%`r`nG: %ggg%`r`nH: %hhh%`r`nI: %iii%`r`nJ: %jjj%`r`nK: %kkk%`r`nL: %lll%`r`nM: %mmm%`r`nN: %nnn%`r`nO: %ooo%`r`nP: %ppp%`r`nQ: %qqq%`r`nR: %rrr%`r`nS: %sss%`r`nT: %ttt%`r`nU: %uuu%`r`nV: %vvv%`r`nW: %www%`r`nX: %xxx%`r`nY: %yyy%`r`nZ: %zzz%`r`n
	;Numbers
	ToCopy = %ToCopy%1: %n1%`r`n2: %n2%`r`n3: %n3%`r`n4: %n4%`r`n5: %n5%`r`n6: %n6%`r`n7: %n7%`r`n8: %n8%`r`n9: %n9%`r`n0: %n0%`r`n
	;Control
	ToCopy = %ToCopy%Space: %ok1%`r`nLeft Alt: %ok2%`r`nRight Alt: %ok3%`r`nLeft Windows: %ok4%`r`nRight Windows: %ok5%`r`nApps Key: %ok6%`r`nLeft Control: %ok7%`r`nRight Control: %ok8%`r`nLeft Shift: %ok9%`r`nRight Shift: %ok10%`r`nEnter: %ok11%`r`nBackspace: %ok12%`r`nCapslock: %ok13%`r`nTab: %ok14%`r`nUp: %ok15%`r`nDown: %ok16%`r`nLeft: %ok17%`r`nRight: %ok18%`r`nDelete: %ok19%`r`nInsert: %ok20%`r`nHome: %ok21%`r`nEnd: %ok22%`r`nPage Up: %ok23%`r`nPage Down: %ok24%`r`nPrintScreen: %ok25%`r`nScroll-Lock: %ok26%`r`nPause-Break: %ok27%`r`nEscape: %ok40%`r`n
	;Function
	ToCopy = %ToCopy%F1: %ok28%`r`nF2: %ok29%`r`nF3: %ok30%`r`nF4: %ok31%`r`nF5: %ok32%`r`nF6: %ok33%`r`nF7: %ok34%`r`nF8: %ok35%`r`nF9: %ok36%`r`nF10: %ok37%`r`nF11: %ok38%`r`nF12: %ok39%`r`n
	;Special
	ToCopy = %ToCopy%``: %ssc1%`r`n:: %ssc2%`r`n+: %ssc3%`r`n,: %ssc4%`r`n-: %ssc5%`r`n.: %ssc6%`r`n/: %ssc7%`r`n[: %ssc8%`r`n\: %ssc9%`r`n]: %ssc10%`r`n': %ssc11%`r`n~: %ssc12%`r`n`;: %ssc13%`r`n=: %ssc14%`r`n<: %ssc15%`r`n_: %ssc16%`r`n>: %ssc17%`r`n?: %ssc18%`r`n{: %ssc19%`r`n|: %ssc20%`r`n}: %ssc21%`r`n": %ssc22%`r`n!: %ssc23%`r`n@: %ssc24%`r`n#: %ssc25%`r`n$: %ssc26%`r`n`%: %ssc27%`r`n^: %ssc28%`r`n&: %ssc29%`r`n*: %ssc30%`r`n(: %ssc31%`r`n): %ssc32%`r`n
}
If (NUMB = 1){
	ToCopy = %ToCopy%Numpad 0 %np0%`r`nNumpad 1 %np1%`r`nNumpad 2 %np2%`r`nNumpad 3 %np3%`r`nNumpad 4 %np4%`r`nNumpad 5 %np5%`r`nNumpad 6 %np6%`r`nNumpad 7 %np7%`r`nNumpad 8 %np8%`r`nNumpad 9 %np9%`r`nNumpad . %np10%`r`nNumpad / %np11%`r`nNumpad * %np12%`r`nNumpad + %np13%`r`nNumpad - %np14%`r`nNumpad Enter %np15%`r`nNumpad Insert %np16%`r`nNumpad End %np17%`r`nNumpad Down %np18%`r`nNumpad Page Down %np19%`r`nNumpad Left %np20%`r`nNumpad Clear %np21%`r`nNumpad Right %np22%`r`nNumpad Home %np23%`r`nNumpad Up %np24%`r`nNumpad Page Up %np25%`r`nNumpad Delete %np26%`r`nNumpad Lock %np27%`r`n
}
ClipBoard := ToCopy
GoSub,Normal_Counts
Return

DetailedStatistics_overall:
TAT := OriginalStartTime +((A_TickCount / 1000) - TST)
DetailedStatistics_type = 1
GoSub,DetailedStatistics
Return


DetailedStatistics_currentrun:
TAT := (A_TickCount / 1000) - TST
DetailedStatistics_type = 2
GoSub,Current_Run_Counts
GoSub,DetailedStatistics
Return




DetailedStatistics:

;Add in the ability to copy either overall statistics or current run statistics to the clipboard.
;This would take a lot of extra code and I don't think it's worth it.

Old_Float := A_FormatFloat

;Gui Tab controller. This adds only the tabs that will be used to the tab controller.
Mouse_Tabs = Mouse|Mouse/S
MTT = 2
LTT = 0
NTT = 0
STT = 0
CTT = 0
FTT = 0
NPTT = 0
If (LET = 1){
	Letter_Tabs = Letters|Letters/S
	Number_Tabs = Numbers|Numbers/S
	Special_Tabs = Specials|Specials/S
	Control_Tabs = Controls|Controls/S
	Function_Tabs = Functions|Functions/S
	LTT += 2
	NTT += 2
	STT += 2
	CTT += 2
	FTT += 2
}
If (NUMB = 1){
	Numpad_Tabs = Numpads|Numpads/S
	NPTT += 2
}
If ((TAT / 60) >= 1){
	Mouse_Tabs = %Mouse_Tabs%|Mouse/M
	MTT += 1
	If (LET = 1){
		Letter_Tabs = %Letter_Tabs%|Letters/M
		Number_Tabs = %Number_Tabs%|Numbers/M
		Special_Tabs = %Special_Tabs%|Specials/M
		Control_Tabs = %Control_Tabs%|Controls/M
		Function_Tabs = %Function_Tabs%|Functions/M
		LTT += 1
		NTT += 1
		STT += 1
		CTT += 1
		FTT += 1
	}
	If (NUMB = 1){
		Numpad_Tabs = %Numpad_Tabs%|Numpads/M
		NPTT += 1
	}
}
If (((TAT / 60) /60) >= 1){
	Mouse_Tabs = %Mouse_Tabs%|Mouse/H
	MTT += 1
	If (LET = 1){
		Letter_Tabs = %Letter_Tabs%|Letters/H
		Number_Tabs = %Number_Tabs%|Numbers/H
		Special_Tabs = %Special_Tabs%|Specials/H
		Control_Tabs = %Control_Tabs%|Controls/H
		Function_Tabs = %Function_Tabs%|Functions/H
		LTT += 1
		NTT += 1
		STT += 1
		CTT += 1
		FTT += 1
	}
	If (NUMB = 1){
		Numpad_Tabs = %Numpad_Tabs%|Numpads/H
		NPTT += 1
	}
}
If ((((TAT /60) /60) / 24) >= 1){
	Mouse_Tabs = %Mouse_Tabs%|Mouse/D
	MTT += 1
	If (LET = 1){
		Letter_Tabs = %Letter_Tabs%|Letters/D
		Number_Tabs = %Number_Tabs%|Numbers/D
		Special_Tabs = %Special_Tabs%|Specials/D
		Control_Tabs = %Control_Tabs%|Controls/D
		Function_Tabs = %Function_Tabs%|Functions/D
		LTT += 1
		NTT += 1
		STT += 1
		CTT += 1
		FTT += 1
	}
	If (NUMB = 1){
		Numpad_Tabs = %Numpad_Tabs%|Numpads/D
		NPTT += 1
	}
}

Create_Tabs = %Mouse_Tabs%
If (LET = 1){
	Create_Tabs = %Create_Tabs%|%Letter_Tabs%|%Number_Tabs%|%Special_Tabs%|%Control_Tabs%|%Function_Tabs%
}
If (NUMB = 1){
	Create_Tabs = %Create_Tabs%|%Numpad_Tabs%
}

Gui, Add, Tab2, r15 w373,%Create_Tabs%

II = 1
loop 5{
	Run_Time%II% = Seconds
	If (II = 2){
		TAT%II% := TAT
		Run_Time%II% = Seconds
	}
	If (II = 3){
		if ((TAT / 60) >= 1){
			TAT%II% := TAT / 60
			Run_Time%II% = Minutes
		} else {
			II += 1
			Break
		}
	}
	If (II = 4){
		If (((TAT / 60) /60) >= 1){
			TAT%II% := ((TAT / 60) /60)
			Run_Time%II% = Hours
		} else {
			II += 1
			Break
		}
	}
	If (II = 5){
		if ((((TAT /60) /60) / 24) >= 1){
			TAT%II% := (((TAT /60) /60) / 24)
			Run_Time%II% = Days
		} else {
			II += 1
			Break
		}
	}
	TAT1 := TAT
	SetFormat,float,0.0
	TAT1 += 0.0
	TAT2 := TAT1
	SetFormat,float,07
	TT = 1
	loop 5{
		LMLM%TT% := LM
		LMLM%TT% += 0.0
		MMMM%TT% := MM
		MMMM%TT% += 0.0
		RMRM%TT% := RM
		RMRM%TT% += 0.0
		MWUMWU%TT% := MWU
		MWUMWU%TT% += 0.0
		MWDMWD%TT% := MWD
		MWDMWD%TT% += 0.0
		TT := TT + 1
	}
	tmp_time%II% := TAT%II%
	Setformat,float,%Old_Float%
	If (II > 1){
		LMLM%II% := LMLM%II% / TAT%II%
		MMMM%II% := MMMM%II% / TAT%II%
		RMRM%II% := RMRM%II% / TAT%II%
		MWUMWU%II% := MWUMWU%II% / TAT%II%
		MWDMWD%II% := MWDMWD%II% / TAT%II%
		
		LMLM%II% := Format_To_7(LMLM%II%)
		MMMM%II% := Format_To_7(MMMM%II%)
		RMRM%II% := Format_To_7(RMRM%II%)
		MWUMWU%II% := Format_To_7(MWUMWU%II%)
		MWDMWD%II% := Format_To_7(MWDMWD%II%)
		Setformat,float,%Old_Float%
		
	}
	If (II > 2){
		tmp_time%II% := Format_To_7(tmp_time%II%)
	}
	Gui,Tab,%II%
	Gui, Add, ListView, Disabled r16 -Hdr w350, # |Name |# |Name 
	LV_Add("","Runtime:",tmp_time%II%,"",Run_Time%II%)
	LV_Add("","","","","")
	LV_Add("","Left mouse:",LMLM%II%,"          Middle mouse:",MMMM%II%)
	LV_Add("","Right mouse:",RMRM%II%,"          Mouse scroll up:",MWUMWU%II%)
	LV_Add("","Mouse scroll down:",MWDMWD%II%)
	LV_ModifyCol()

	Setformat,float,%Old_Float%

	If (LET = 1){
		TT = 1
		Setformat,float,07
		Loop 5{
			Loop,parse,Letter_string,`,
			{
				%A_LoopField%%A_LoopField%%TT% := %A_LoopField%
				%A_LoopField%%A_LoopField%%TT% += 0.0
			}
			TT := TT + 1
		}
		If (II > 1){
			Loop,parse,Letter_string,`,
			{
				Setformat,float,%Old_Float%
				tmp_tmp = %A_LoopField%%A_LoopField%%II%
				%tmp_tmp% := %tmp_tmp% / TAT%II%
				%tmp_tmp% := Format_To_7(%tmp_tmp%)
			}
			Setformat,float,%Old_Float%
		}

		LII := MTT + II
		Gui,Tab,%LII%
		Gui, Add, ListView, Disabled r16 -Hdr w350, # |Name |# |Name
		LV_Add("","Runtime:",tmp_time%II%,"",Run_Time%II%)
		LV_Add("","","","","")
		LV_Add("","A:",aaaaaa%II%,"          B:",bbbbbb%II%)
		LV_Add("","C:",cccccc%II%,"          D:",dddddd%II%)
		LV_Add("","E:",eeeeee%II%,"          F:",ffffff%II%)
		LV_Add("","G:",gggggg%II%,"          H:",hhhhhh%II%)
		LV_Add("","I:",iiiiii%II%,"          J:",jjjjjj%II%)
		LV_Add("","K:",kkkkkk%II%,"          L:",llllll%II%)
		LV_Add("","M:",mmmmmm%II%,"          N:",nnnnnn%II%)
		LV_Add("","O:",oooooo%II%,"          P:",pppppp%II%)
		LV_Add("","Q:",qqqqqq%II%,"          R:",rrrrrr%II%)
		LV_Add("","S:",ssssss%II%,"          T:",tttttt%II%)
		LV_Add("","U:",uuuuuu%II%,"          V:",vvvvvv%II%)
		LV_Add("","W:",wwwwww%II%,"          X:",xxxxxx%II%)
		LV_Add("","Y:",yyyyyy%II%,"          Z:",zzzzzz%II%)
		LV_ModifyCol()
		Setformat,float,%Old_Float%

		NII := MTT + LTT + II
		Gui,Tab,%NII%
		Gui, Add, ListView, Disabled r16 -Hdr w350, # |Name |# |Name

		TT1 = 1
		Setformat,float,07
		Loop 5{
			TT2 = 1
			loop 32 {
				ssc%TT2%ssc%TT2%%TT1% := ssc%TT2%
				ssc%TT2%ssc%TT2%%TT1% += 0.0
				TT2 := TT2 + 1
			}
			TT3 = 0
			loop 10 {
				n%TT3%n%TT3%%TT1% := n%TT3%
				n%TT3%n%TT3%%TT1% += 0.0
				TT3 := TT3 + 1
			}
			TT1 := TT1 + 1
		}
		Setformat,float,%Old_Float%
		If (II > 1){
			TT2 = 1
			loop 32 {
				ssc%TT2%ssc%TT2%%II% := ssc%TT2%ssc%TT2%%II% / TAT%II%
				ssc%TT2%ssc%TT2%%II% := Format_To_7(ssc%TT2%ssc%TT2%%II%)
				TT2 := TT2 + 1
			}
			TT3 = 0
			loop 10 {
				n%TT3%n%TT3%%II% := n%TT3%n%TT3%%II% / TAT%II%
				n%TT3%n%TT3%%II% := Format_To_7(n%TT3%n%TT3%%II%)
				TT3 := TT3 + 1
			}
			Setformat,float,%Old_Float%
		}
		LV_Add("","Runtime:",tmp_time%II%,"",Run_Time%II%)
		LV_Add("","","","","")
		LV_Add("","0:",n0n0%II%,"          1:",n1n1%II%)
		LV_Add("","2:",n2n2%II%,"          3:",n3n3%II%)
		LV_Add("","4:",n4n4%II%,"          5:",n5n5%II%)
		LV_Add("","6:",n6n6%II%,"          7:",n7n7%II%)
		LV_Add("","8:",n8n8%II%,"          9:",n9n9%II%)
		LV_ModifyCol()
		Setformat,float,%Old_Float%
		
		SII := MTT + LTT + NTT + II
		Gui,Tab,%SII%
		Gui, Add, ListView, Disabled r16 -Hdr w350, # |Name |# |Name|#|#
		LV_Add("","Runtime:",tmp_time%II%,"",Run_Time%II%)
		LV_Add("","","","","")
		LV_Add("","``:",ssc1ssc1%II%,"          `;:",ssc13ssc13%II%,"          =:",ssc14ssc14%II%)
		LV_Add("",",:",ssc4ssc4%II%,"          -:",ssc5ssc5%II%,"          .:",ssc6ssc6%II%)
		LV_Add("","/:",ssc7ssc7%II%,"          [:",ssc8ssc8%II%,"          \:",ssc9ssc9%II%)
		LV_Add("","]:",ssc10ssc10%II%,"          ':",ssc11ssc11%II%)
		LV_Add("","","","","","","")
		LV_Add("","~:",ssc12ssc12%II%,"          ::",ssc2ssc2%II%,"          +:",ssc3ssc3%II%)
		LV_Add("","<:",ssc15ssc15%II%,"          _:",ssc16ssc16%II%,"          >:",ssc17ssc17%II%)
		LV_Add("","?:",ssc18ssc18%II%,"          {:",ssc19ssc19%II%,"          |:",ssc20ssc20%II%)
		LV_Add("","}:",ssc21ssc21%II%,"          "":",ssc22ssc22%II%,"          !:",ssc23ssc23%II%)
		LV_Add("","@:",ssc24ssc24%II%,"          #:",ssc25ssc25%II%,"          $:",ssc26ssc26%II%)
		LV_Add("","%:",ssc27ssc27%II%,"          ^:",ssc28ssc28%II%,"          &:",ssc29ssc29%II%)
		LV_Add("","*:",ssc30ssc30%II%,"          (:",ssc31ssc31%II%,"          ):",ssc32ssc32%II%)
		LV_ModifyCol()
		Setformat,float,%Old_Float%

		CII := MTT + LTT + NTT + STT + II
		Gui,Tab,%CII%
		Gui, Add, ListView, Disabled r16 -Hdr w350, # |Name |# |Name
		TT1 = 1
		Setformat,float,07
		Loop 5{
			TT2 = 1
			Loop 40 {
				ok%TT2%ok%TT2%%TT1% := ok%TT2%
				ok%TT2%ok%TT2%%TT1% += 0.0
				TT2 := TT2 + 1
			}
			TT1 := TT1 + 1
		}
		Setformat,float,%Old_Float%
		If (II > 1){
			TT2 = 1
			Loop 40 {
				ok%TT2%ok%TT2%%II% := ok%TT2%ok%TT2%%II% / TAT%II%
				ok%TT2%ok%TT2%%II% := Format_To_7(ok%TT2%ok%TT2%%II%)
				TT2 := TT2 + 1
			}
			Setformat,float,%Old_Float%
		}
		;1-27 + 40
		LV_Add("","Runtime:",tmp_time%II%,"",Run_Time%II%)
		LV_Add("","","","","")
		LV_Add("","Space:",ok1ok1%II%,"          Left Alt:",ok2ok2%II%)
		LV_Add("","Right Alt:",ok3ok3%II%,"          Left Windows:",ok4ok4%II%)
		LV_Add("","Right Windows:",ok5ok5%II%,"          AppsKey:",ok6ok6%II%)
		LV_Add("","Left Control:",ok7ok7%II%,"          Right Control:",ok8ok8%II%)
		LV_Add("","Left Shift:",ok9ok9%II%,"          Right Shift:",ok10ok10%II%)
		LV_Add("","Enter:",ok11ok11%II%,"          Backspace:",ok12ok12%II%)
		LV_Add("","Caps Lock:",ok13ok13%II%,"          Tab:",ok14ok14%II%)
		LV_Add("","Up:",ok15ok15%II%,"          Down:",ok16ok16%II%)
		LV_Add("","Left:",ok17ok17%II%,"          Right:",ok18ok18%II%)
		LV_Add("","Delete:",ok19ok19%II%,"          Insert:",ok20ok20%II%)
		LV_Add("","Home:",ok21ok21%II%,"          End:",ok22ok22%II%)
		LV_Add("","Page Up:",ok23ok23%II%,"          Page Down:",ok24ok24%II%)
		LV_Add("","PrintScreen:",ok25ok25%II%,"          Scroll Lock:",ok26ok26%II%)
		LV_Add("","Pause Break:",ok27ok27%II%,"          Escape:",ok40ok40%II%)
		LV_ModifyCol()
		Setformat,float,%Old_Float%
		
		FII := MTT + LTT + NTT + STT + CTT + II
		Gui,Tab,%FII%
		Gui, Add, ListView, Disabled r16 -Hdr w350, # |Name |# |Name
		;28-39
		LV_Add("","Runtime:",tmp_time%II%,"",Run_Time%II%)
		LV_Add("","","","","")
		LV_Add("","F1:",ok28ok28%II%,"          F2:",ok29ok29%II%)
		LV_Add("","F3:",ok30ok30%II%,"          F4:",ok31ok31%II%)
		LV_Add("","F5:",ok32ok32%II%,"          F6:",ok33ok33%II%)
		LV_Add("","F7:",ok34ok34%II%,"          F8:",ok35ok35%II%)
		LV_Add("","F9:",ok36ok36%II%,"          F10:",ok37ok37%II%)
		LV_Add("","F11:",ok38ok38%II%,"          F12:",ok39ok39%II%)
		LV_ModifyCol()
		Setformat,float,%Old_Float%
	}

	if (NUMB = 1){
		TII := MTT + LTT + NTT + STT + CTT + FTT + II
		Gui,Tab,%TII%
		Gui, Add, ListView, Disabled r16 -Hdr w350, # |Name |# |Name
		TT1 = 1
		Setformat,float,07
		Loop 5{
			TT2 = 0
			Loop 28 {
				np%TT2%np%TT2%%TT1% := np%TT2%
				np%TT2%np%TT2%%TT1% += 0.0
				TT2 := TT2 + 1
			}
			TT1 := TT1 + 1
		}
		Setformat,float,%Old_Float%
		If (II > 1){
			TT2 = 0
			Loop 28 {
				np%TT2%np%TT2%%II% := np%TT2%np%TT2%%II% / TAT%II%
				np%TT2%np%TT2%%II% := Format_To_7(np%TT2%np%TT2%%II%)
				TT2 := TT2 + 1
			}
			Setformat,float,%Old_Float%
		}
		LV_Add("","Runtime:",tmp_time%II%,"",Run_Time%II%)
		LV_Add("","","","","")
		LV_Add("","Numpad 0:",np0np0%II%,"          Numpad 1:",np1np1%II%)
		LV_Add("","Numpad 2:",np2np2%II%,"          Numpad 3:",np3np3%II%)
		LV_Add("","Numpad 4:",np4np4%II%,"          Numpad 5:",np5np5%II%)
		LV_Add("","Numpad 6:",np6np6%II%,"          Numpad 7:",np7np7%II%)
		LV_Add("","Numpad 8:",np8np8%II%,"          Numpad 9:",np9np9%II%)
		LV_Add("","Numpad .:",np10np10%II%,"          Numpad /:",np11np11%II%)
		LV_Add("","Numpad *:",np12np12%II%,"          Numpad +:",np13np13%II%)
		LV_Add("","Numpad -:",np14np14%II%,"          Numpad Enter:",np15np15%II%)
		LV_Add("","Numpad Insert:",np16np16%II%,"          Numpad End:",np17np17%II%)
		LV_Add("","Numpad Down:",np18np18%II%,"          Numpad Page Down:",np19np19%II%)
		LV_Add("","Numpad Left:",np20np20%II%,"          Numpad Clear:",np21np21%II%)
		LV_Add("","Numpad Right:",np22np22%II%,"          Numpad Home:",np23np23%II%)
		LV_Add("","Numpad Up:",np24np24%II%,"          Numpad Page Up:",np25np25%II%)
		LV_Add("","Numpad Delete:",np26np26%II%,"          Numpad On/Off:",np27np27%II%)
		LV_ModifyCol()
		Setformat,float,%Old_Float%
	}
	II += 1
}
Gui,Show
If (DetailedStatistics_type = 2){
	GoSub,Normal_Counts
}
Return

GuiClose:
Gui,destroy
Return

AddLetters:
AddedLetters = 0
Loop,parse,Letter_string,`,
{
	AddedLetters := AddedLetters + %A_LoopField%
}
Return

About:
Progress,A M2 zh0 C00 WM400,,M&K Counter`n`nCreated by: Robert Eding`nVersion number: 2.3`n`nThis counter counts the number of times the mouse is clicked or scrolled and the number of times a keyboard key is pressed. It does NOT count the order in which they are performed.,About M&K Counter
Return

Statistics_T1_1:
If (OST = 0){
	MsgBox,4,,Inorder to use the simple overall statistics option you must have just checked the "mainintain" option or just reset the counters.`n`nDo you want to reset the counters and enable overall history?
	IfMsgBox YES
	MsgBox,4,,Are you sure you want to reset the counters?
	IfMsgBox YES
	GoSub,ResetCounters
} else{
	Statistics_type = 1
	repeat_message = 1
	start_repeat = 1
	if (fake_statistics_type = 0){
		fake_statistics_type = 1
	}
	GoSub,Statistics_run
}
Return

Statistics_T1_2:
If (OST = 0){
	MsgBox,4,,Inorder to use the simple overall statistics option you must have just checked the "mainintain" option or just reset the counters.`n`nDo you want to reset the counters and enable overall history?
	IfMsgBox YES
	MsgBox,4,,Are you sure you want to reset the counters?
	IfMsgBox YES
	GoSub,ResetCounters
} else{
	Statistics_type = 1
	Clipboard_statistics = 1
	GoSub,Statistics_run
}
Return

Statistics_T2_1:
Statistics_type = 2
repeat_message = 1
start_repeat = 1
if (fake_statistics_type = 0){
	fake_statistics_type = 2
}
GoSub,Statistics_run
Return

Statistics_T2_2:
Statistics_type = 2
Clipboard_statistics = 1
GoSub,Statistics_run
Return

AddOtherKeys()
{
II = 0
II_T = 0
Loop 10{
	II_T := II_T + n%II%
	II++
}
II = 1
Loop 32{
	II_T := II_T + ssc%II%
	II++
}
II = 1
Loop 40{
	II_T := II_T + ok%II%
	II++
}
Return II_T
}

AddNumpadKeys()
{
II = 0
II_T = 0
Loop 28{
	II_T := II_T + np%II%
	II++
}
Return II_T
}

;This entire section does the clipboard copy, window popup and statics autorefresh windows.
Statistics_run:
SetFormat, float, 0.3
TAT := (A_TickCount / 1000) - TST

if (LET = 0){
	GoSub,LetterReset
}
if (NUMB = 0){
	GoSub,NumPadReset
}

NumPadKeys := AddNumpadKeys()
GoSub,AddLetters
OtherKeys := AddOtherKeys() + AddedLetters

If (Statistics_type = 1){
	ToPrint = Overall statistics`r`n`r`n
	
	II = 
	Loop 4{
		TLM%II% := LM
		TMM%II% := MM
		TRM%II% := RM
		TMWD%II% := MWD
		TMWU%II% := MWU
		TNumPadKeys%II% := NumPadKeys
		TOtherKeys%II% := OtherKeys
		If (II > 0){
			II++
		} else {
			II = 2
		}
	}
	
	TTTT := A_TickCount / 1000
	TMPWRITETIME := OriginalStartTime + (TTTT - TST)
	TTTT := TAT
	TAT = %TMPWRITETIME%
}
If (Statistics_type = 2){
	ToPrint = Current run statistics`r`n`r`n
	
	II = 
	Loop 4{
		TLM%II% := LM - ReadLM
		TMM%II% := MM - ReadMM
		TRM%II% := RM - ReadRM
		TMWD%II% := MWD - ReadMWD
		TMWU%II% := MWU - READMWU
		TNumPadKeys%II% := NumPadKeys - ReadNPK
		TOtherKeys%II% := OtherKeys - ReadABC
		If (II > 0){
			II++
		} else {
			II = 2
		}
	}
	
	TTTT := TAT
}

Time_Index = second
Time_Index2 = minute
Time_Index3 = hour
Time_Index4 = day

ToPrint = %ToPrint%%TLM% Left Clicks`r`n%TMM% Middle Clicks`r`n%TRM% Right Clicks`r`n%TMWD% Mouse Scroll Downs`r`n%TMWU% Mouse Scroll Ups`r`n%TNumPadKeys% Numpad Keys`r`n%TOtherKeys% Other Keys`r`n`r`n

II = 
loop 4{
If (II < 0){
	TMPII = 
}
If (II = 2){
	if ((TAT / 60) >= 1){
		TAT1 := TAT / 60
		TMPII := II - 1
	} else {
		GoTo,Skip
	}
}
If (II = 3){
	If (((TAT / 60) /60) >= 1){
		TAT2 := ((TAT / 60) /60)
		TMPII := II - 1
	} else {
		GoTo,Skip
	}
}
If (II = 4){
	if ((((TAT /60) /60) / 24) >= 1){
		TAT3 := (((TAT /60) /60) / 24)
		TMPII := II - 1
	} else {
		GoTo,Skip
	}
}

TNumPadKeys%II% := TNumPadKeys%II% / TAT%TMPII%

If (TNumPadKeys%II% <= 0.0009){
	TNumPadKeys%II% = 0
}
TNPK := TNumPadKeys%II%
TTINDEX := Time_Index%II%
TTINDEX2 := Time_Index%TMPII%
TTAT := TAT%TMPII%

ToPrint = %ToPrint%`r`n%TNPK% NumPad keys per %TTINDEX% over %TTAT% %TTINDEX%s`r`n
TOtherKeys%II% := TOtherKeys%II% / TAT%TMPII%
If (TOtherKeys%II% <= 0.0009){
	TOtherKeys%II% = 0
}
TOK := TOtherKeys%II%
ToPrint = %ToPrint%%TOK% OtherKeys keys per %TTINDEX% over %TTAT% %TTINDEX%s`r`n
TLM%II% := TLM%II% / TAT%TMPII%
If (TLM%II% <= 0.0009){
	TLM%II% = 0
}
TTLM := TLM%II%
ToPrint = %ToPrint%%TTLM% Left mouse clicks per %TTINDEX% over %TTAT% %TTINDEX%s`r`n
TMM%II% := TMM%II% / TAT%TMPII%
If (TMM%II% <= 0.0009){
	TMM%II% = 0
}
TTMM := TMM%II%
ToPrint = %ToPrint%%TTMM% Middle mouse clicks per %TTINDEX% over %TTAT% %TTINDEX%s`r`n
TRM%II% := TRM%II% / TAT%TMPII%
If (TRM%II% <= 0.0009){
	TRM%II% = 0
}
TTRM := TRM%II%
ToPrint = %ToPrint%%TTRM% Right mouse clicks per %TTINDEX% over %TTAT% %TTINDEX%s`r`n
TMWD%II% := TMWD%II% / TAT%TMPII%
If (TMWD%II% <= 0.0009){
	TMWD%II% = 0
}
TTMWD := TMWD%II%
ToPrint = %ToPrint%%TTMWD% Mouse scroll downs per %TTINDEX% over %TTAT% %TTINDEX%s`r`n
TMWU%II% := TMWU%II% / TAT%TMPII%
If (TMWU%II% <= 0.0009){
	TMWU%II% = 0
}
TTMWU := TMWU%II%
ToPrint = %ToPrint%%TTMWU% Mouse scroll ups per %TTINDEX% over %TTAT% %TTINDEX%s`r`n


Skip:
If (II < 0){
	II = 2
} else {
	II++
}
}

TAT := TTTT

;This section does the cliboard copy, statistics count windows and autorefresh
if (Clipboard_statistics = 1){
	Clipboard = %ToPrint%
	Clipboard_statistics = 0
	Statistics_type := fake_statistics_type
} else {
	if (repeat_message = 1){
		if (start_repeat = 0){
			Progress,,,%ToPrint%
			SetTimer,Statistics_run,10000
		} else {
			Progress,A M zh0 C00 W480 WM400,,%ToPrint%,Press Escape to close window - auto refreshed every 10~ seconds
			start_repeat = 0
			SetTimer,Statistics_run,10000
		}
	} else {
		Progress,Off
		fake_statistics_type = 0
	}
}
Return

ClipBoard_1:
Clipboard_type = 1
GoSub,ClipBoard
Return

ClipBoard_2:
Clipboard_type = 2
GoSub,ClipBoard
Return

ClipBoard:
if (LET = 0){
	GoSub,LetterReset
}
if (NUMB = 0){
	GoSub,NumPadReset
}
TOTALNUMPAD := AddNumpadKeys()
GoSub,AddLetters
TOTALKEYS := AddOtherKeys() + AddedLetters

If (Clipboard_type = 1){
	TMPLM := LM
	TMPMM := MM
	TMPRM := RM
	TMPMWD := MWD
	TMPMWU := MWU
	ToCopy = Overall counts:
}
If (Clipboard_type = 2){
	TMPLM := LM - ReadLM
	TMPMM := MM - ReadMM
	TMPRM := RM - ReadRM
	TMPMWD := MWD - ReadMWD
	TMPMWU := MWU - ReadMWU
	TOTALNUMPAD := TOTALNUMPAD - ReadNPK
	TOTALKEYS := TOTALKEYS - ReadABC
	ToCopy = Current run counts:
}

ToCopy = %ToCopy% %TMPLM% Left clicks`,
ToCopy = %ToCopy% %TMPMM% Middle clicks`,
ToCopy = %ToCopy% %TMPRM% Right clicks`,
ToCopy = %ToCopy% %TMPMWD% Scroll downs`,

if (TOTALNUMPAD = 0){
	if (TOTALKEYS = 0){
		ToCopy = %ToCopy% and %TMPMWU% Scroll ups
	} else {
		ToCopy = %ToCopy% %TMPMWU% Scroll ups`,
	}
} else {
	ToCopy = %ToCopy% %TMPMWU% Scroll ups`,
}

if (NUMB = 1){
	if (TOTALNUMPAD > 0){
		if (LET = 1){
			if (TOTALKEYS > 0){
				ToCopy = %ToCopy% %TOTALNUMPAD% Numpad presses
			} else {
				ToCopy = %ToCopy% and %TOTALNUMPAD% Numpad presses
			}
		} else {
			ToCopy = %ToCopy% and %TOTALNUMPAD% Numpad presses
		}
	}
}
if (LET = 1){
	if (TOTALKEYS > 0){
		ToCopy = %ToCopy% and %TOTALKEYS% Other key presses
	}
}
clipboard = %ToCopy%
Return

ResetCounters_menu:
MsgBox,4,,Are you sure you want to reset the counters?
IfMsgBox YES
GoSub,ResetCounters
Return

ResetCounters:
OriginalStartTime = 0
OST = 1
ReadLM = 0
ReadMM = 0
ReadRM = 0
ReadMWD = 0
ReadMWU = 0
ReadNPK = 0
ReadABC = 0

TST := A_TickCount / 1000

GoSub,MouseReset
GoSub,LetterReset
GoSub,NumPadReset
sleep 100
GoSub,RecordMaintain
Return

MouseReset:
LM=0
MM=0
RM=0
MWU=0
MWD=0
Return

NumPadReset:
II = 0
Loop 28{
	np%II% = 0
	II++
}
Return

LetterReset:
II = 0
Loop 10{
	n%II% = 0
	II++
}
II = 1
Loop 32{
	ssc%II% = 0
	sscs%II% = 0
	II++
}
II = 1
Loop 40{
	ok%II% = 0
	II++
}
Loop,parse,Letter_string,`,
{
	%A_LoopField% = 0
}
Return

Pop-up:
If FileExist(TP3){
	Menu,SubMenuOptions,UnCheck,Don't Show Pop-up message at startup
	FileDelete,%TP3%
} Else {
	Menu,SubMenuOptions,Check,Don't Show Pop-up message at startup
	FileAppend,Do not show the pop-up message at startup - file.,%TP3%
}
Return

Hide_Icon:
MsgBox,4,,You can restore the icon by pressing ScrollLock + Insert. Or by deleting the file "M&K3.ini" located in %appdata%\M&K Counter\ and restarting the program.`n`nAre you sure you want to hide the tray icon?
IfMsgBox YES
{
	FileAppend,Hide Tray icon file.,%TP4%
	Menu,Tray,NoIcon
}
Return

ShortCut:
IfExist,C:\users\
{
	IfExist,C:\users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\M&K Counter.lnk
	{
	FileDelete,C:\users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\M&K Counter.lnk
	GoTo,Autostart_Done
	} else {
		FileCreateShortcut,%A_ScriptFullPath%,C:\users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\M&K Counter.lnk,%A_WorkingDir%,,M&K Counter,%A_ScriptFullPath%,m
		GoTo,Autostart_Done
	}
}
IfExist,C:\Documents and settings\
{
	IfExist,C:\Documents and Settings\%username%\Start Menu\Programs\Startup\M&K Counter.lnk
	{
	FileDelete,C:\Documents and Settings\%username%\Start Menu\Programs\Startup\M&K Counter.lnk
	} else {
		FileCreateShortcut,%A_ScriptFullPath%,C:\Documents and Settings\%username%\Start Menu\Programs\Startup\M&K Counter.lnk,%A_WorkingDir%,,M&K Counter,%A_ScriptFullPath%,m
	}
}
Autostart_Done:
Menu,SubMenuOptions,ToggleCheck,Autostart at logon
Return

InitializeVariables:
IfExist,C:\users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\M&K Counter.lnk
{
	Menu,SubMenuOptions,ToggleCheck,Autostart at logon
	Goto,Autostart_Done_2
}
IfExist,C:\Documents and Settings\%username%\Start Menu\Programs\Startup\M&K Counter.lnk
{
	Menu,SubMenuOptions,ToggleCheck,Autostart at logon
}
Autostart_Done_2:
Clipboard_statistics = 0
MT = 0
RN = 1
NUMB = 0
LET = 0

TST := A_TickCount / 1000
FormatTime,StartTime,,d/M/yyyy - H:m:s

Shutting_down = 0

IfNotExist,%appdata%\M&K Counter\
{
	FileCreateDir,%appdata%\M&K Counter\
}
TP2 = %appdata%\M&K Counter\M&K2.ini
TP3 = %appdata%\M&K Counter\M&K1.ini
TP4 = %appdata%\M&K Counter\M&K3.ini

ReadLM = 0
ReadMM = 0
ReadRM = 0
ReadMWD = 0
ReadMWU = 0
ReadNPK = 0
ReadABC = 0
OST = 0
NPK = 0
ABC = 0
II = 0
Loop 28{
	Readnp%II% = 0
	II++
}
II = 0
Loop 10{
	Readn%II% = 0
	II++
}
II = 1
Loop 32{
	Readssc%II% = 0
	II++
}
II = 1
Loop 40{
	Readok%II% = 0
	II++
}
Loop,parse,Letter_string,`,
{
	Read%A_LoopField% = 0
}
Popup_Message = 1

If FileExist(TP3){
	Menu,SubMenuOptions,Check,Don't Show Pop-up message at startup
	Popup_Message = 0
}

Hide_Tray_Icon = 0

If FileExist(TP4){
	Menu,SubMenuOptions,Check,Hide tray icon
	Menu,Tray,NoIcon
}

If FileExist(TP2){
	FileReadLine, RN, %TP2%, 1
	RN := RN + 1
	FileReadLine, OriginalStartTime, %TP2%, 2
	if (OriginalStartTime <= 0){
		OST = 0
		OriginalStartTime = 0
	} else {
		OST = 1
	}
	MT = 1
	
	;mouse
	FileReadLine, LM, %TP2%, 3
	ReadLM := LM
	FileReadLine, MM, %TP2%, 4
	ReadMM := MM
	FileReadLine, RM, %TP2%, 5
	ReadRM := RM
	FileReadLine, MWD, %TP2%, 6
	ReadMWD := MWD
	FileReadLine, MWU, %TP2%, 7
	ReadMWU := MWU
	
	;numpad
	II = 0
	II_2 = 8
	Loop 28{
		FileReadLine, np%II%, %TP2%, %II_2%
		Readnp%II% := np%II%
		II++
		II_2++
	}
	;above loop reads line 35 as the last variable
	
	;numbers
	II = 0
	II_2 = 36
	Loop 10{
		FileReadLine, n%II%, %TP2%, %II_2%
		Readn%II% := n%II%
		II++
		II_2++
	}
	
	;other keys
	II = 1
	II_2 = 46
	Loop 32{
		FileReadLine, ssc%II%, %TP2%, %II_2%
		Readssc%II% := ssc%II%
		II++
		II_2++
	}
	II = 1
	II_2 = 78
	Loop 40{
		FileReadLine, ok%II%, %TP2%, %II_2%
		Readok%II% := ok%II%
		II++
		II_2++
	}
	
	;letters
	II_2 = 118
	Loop,parse,Letter_string,`,
	{
	FileReadLine, %A_LoopField%, %TP2%, %II_2%
	Read%A_LoopField% := %A_LoopField%
	II_2++
	}
	
	GoSub,AddLetters
	ReadABC := AddOtherKeys() + AddedLetters
	ABC := ReadABC
	if (ABC > 0){
		Menu,SubMenuOptions,ToggleCheck,Count Other keys pressed
		LET = 1
	} else {
		ABC = 0
	}
	
	ReadNPK := AddNumpadKeys()
	NPK := ReadNPK
	if (NPK > 0){
		Menu,SubMenuOptions,ToggleCheck,Count Numpad keys pressed
		NUMB = 1
	} else {
		NPK = 0
	}
	GoSub,RecordMaintain
	Menu,SubMenuOptions,Check,Maintain count between sessions
}
Return

Numbers:
if (NUMB = 0){
	NUMB = 1
	ReadNPK = 0
	GoSub,NumPadReset
}else{
	NUMB = 0
}
Menu,SubMenuOptions,ToggleCheck,Count Numpad keys pressed
Return

Letters:
if (LET = 0){
	LET = 1
	GoSub,LetterReset
	ReadABC = 0
}else{
	LET = 0
}
Menu,SubMenuOptions,ToggleCheck,Count Other keys pressed
Return

Maintain:
if (MT = 0){
	OriginalStartTime = 0
	OST = 1
	MT = 1
}else{
	MT = 0
}
Menu,SubMenuOptions,ToggleCheck,Maintain count between sessions
GoSub,RecordMaintain
Return

UpdateTrayTip:
if (LET = 1) and if (NUMB = 1){
	Print = Clicks`n%LM% left`n%MM% middle`n%RM% right`n`nScrolls`n%MWD% Down`n%MWU% Up
}else{
	Print = Click Count`n%LM% left clicks`n%MM% middle clicks`n%RM% right clicks`n`nScroll Count`n%MWD% Down`n%MWU% Up
}
if (NUMB = 1){
	Total := AddNumpadKeys()
	if (LET = 1){
		Print = %Print%`n`nNumpads`n%Total%
	}else{
		Print = %Print%`n`nNumpad Count`n%Total% Keys
	}
}
if (LET = 1){
	GoSub,AddLetters
	Total := AddOtherKeys() + AddedLetters
	if (NUMB = 1){
		Print = %Print%`n`nLetters`n%Total%
	}else{
		Print = %Print%`n`nLetter Count`n%Total% Keys
	}
}
Menu,Tray,Tip,%Print%
SetTimer,UpdateTrayTip,1000
Return

LogAndExit:
TET := (A_TickCount / 1000) - TST
FormatTime,EndTime,,d/M/yyyy - H:m:s

SetFormat, float, 0.2
if ((((TET / 60) / 60) / 24) >= 1){
	TET := (((TET / 60) / 60) / 24)
	TET += 0
	TET = %TET% Days
}else if (((TET / 60) / 60) >= 1){
		TET := ((TET / 60) / 60)
		TET += 0
		TET = %TET% Hours
}else if ((TET / 60) >= 1){
			TET := (TET / 60)
			TET += 0
			TET = %TET% Minutes
}else{
				TET = %TET% Seconds
}

if (RN > 1){
	RNP = Run %RN%, %StartTime% Through %EndTime%, Estimated Runtime: %TET%,
}else{
	RNP = %StartTime% Through %EndTime%, Estimated Runtime: %TET%,
}
LM := LM - ReadLM
MM := MM - ReadMM
RM := RM - ReadRM
TTC := LM + MM + RM
MWD := MWD - ReadMWD
MWU := MWU - ReadMWU
TTS := MWD + MWU
FileAppend,%RNP% %LM% Left clicks`, %MM% Middle clicks`, %RM% Right clicks`, %TTC% Total clicks`, %MWD% Scroll downs`, %MWU% Scroll ups`, %TTS% Total scrolls,M&K counter.log
Total1 := AddNumpadKeys() - ReadNPK
GoSub,AddLetters
Total2 := AddOtherKeys() + AddedLetters - ReadABC
if (Total1 > 0){
	FileAppend,`, %Total1% Numpads pressed,M&K counter.log
}
if (Total2 > 0){
	FileAppend,`, %Total2% Letters pressed,M&K counter.log
}
FileAppend,`n,M&K counter.log
LM := LM + ReadLM
MM := MM + ReadMM
RM := RM + ReadRM
MWD := MWD + ReadMWD
MWU := MWU + ReadMWU
Shutting_down = 1
GoSub,RecordMaintain
ExitApp

RecordMaintain:
FileDelete, %TP2%
if (Shutting_down = 1 and MT = 1){
	TrayTip,,Saving counters and exiting...,10,1
}

if (MT = 1){
	;run number
	FileAppend,%RN%`r`n,%TP2%
	;run time
	if (OST = 1){
		TTTT := A_TickCount / 1000
		TMPWRITETIME := OriginalStartTime + (TTTT - TST)
		FileAppend,%TMPWRITETIME%`r`n,%TP2%
	} else {
		FileAppend,0`r`n,%TP2%
	}
	;mouse
	FileAppend,%LM%`r`n%MM%`r`n%RM%`r`n%MWD%`r`n%MWU%`r`n,%TP2%
	;numpad
	if (NUMB = 0){
		GoSub,NumPadReset
	}
	II = 0
	Loop 28{
		II2I := np%II%
		FileAppend,%II2I%`r`n,%TP2%
		II++
	}
	;letters/other keys
	if (LET = 0){
		GoSub,LetterReset
	}
	II = 0
	Loop 10{
		II2I := n%II%
		FileAppend,%II2I%`r`n,%TP2%
		II++
	}
	II = 1
	Loop 32{
		II2I := ssc%II%
		FileAppend,%II2I%`r`n,%TP2%
		II++
	}
	II = 1
	Loop 40{
		II2I := ok%II%
		FileAppend,%II2I%`r`n,%TP2%
		II++
	}
	Loop,parse,Letter_string,`,
	{
	TMP := %A_LoopField%
	FileAppend,%TMP%`r`n,%TP2%
	}
}

SetTimer,RecordMaintain,600000
Return

Exit:
ExitApp