;------------------------------------------------------------------------------------------------
; 								Library:		ShowMenu
; 								Show menu from text.
;------------------------------------------------------------------------------------------------

; https://autohotkey.com/board/topic/21347-function-showmenu-12/?&st=0
;
; J2DW mods:
;
; prefix:
; +] to check item
; -] to disable item
; *] to make item the bold/default
; ^]COLORCODE (any place after first menu item added, I use it at end)
; ex; ^]red
; _] to make dummy (useful when adding to sub,  add 1 dummy = [sub] to main to invoke adding to sub) eg ."">[x]|_]dummy =[sub1]|[sub1]|Option new = new""
;
; prefex mDef with ">" to APPEND  new menus
;
; showmenus(mdef,options)
;
;options: <LIST THEM IN ORDER>
;'
;		? or = = return '=' lookup value  ||  ! = use null label  || menuname = use this menu  || <labelID> = use this label  || (x,y) = put menu here x,y  || {delim} = use this delim (ex. {`n}) | is default



; prefix menu  to show with ?  to return selected value,  ?! to  use null label and return value
;  (also can use _sub of "-" to return null label)
;
; ShowMenu(mdef,"?") returns the = value for the selected menu item
; 	ShowMenu(mdef,"?!")  same w/ no need for label for menu
; 	ShowMenu(mdef,"!munx") same.. ie " ---> _sub is null label
;	ShowMenu(mdef,"?menx")  returns the selected value & shows menx
;
; ShowMenu_data now works with alt delim, eg. "ShowMenu_data(mdef,"{|}")"
; ShowMenu_data() now allowed,  returns result of last shown menu
;
; nice!
; Parameters:
;				mDef	- Textual menu definition.
;				_mnu		- Menu to show. Label with the same name as menu will be launched on item selection.
;						  "" means first menu will be shown (default)
;				_sub		- Optional _subroutine that will override default label (named by menu)
;				_sep		- Optional _separator char used for menu items in menu definition, by default new line
;
; J2dW adds:
;
;				x - X position to show menu
;				y - Y position to show menu
;551211; Returns:
;				Message describing error if it ocured or new line _separated list of created menus.
;				If return value is blank, ShowMenu just displayed menu already created in one of previous calls.
;
;
; Remarks:
;				You must have in the code label with the same name as that given to the menu, otherwise
;				ShowMenu returns "No Label" error (unless you used "_sub" parameter in which case the same
;				applies to that _subroutine). There must be no white space between menu name and start of the line.
;				Set each menu item on new line, use "-" to define _separator.
;
; Metachars:
;				To create *_submenu*, use "item = [_submenu]" notation where _submenu must exist in the textual
;				menu definition. Referencing any particular menu as _submenu multiple times will work
;				correctly, but circular references must be avoided.
;				To make item *checked*, use "+" as first character of its name, to make it *disabled* use "*".
;				To associated *user data* use "=data" after the item. If text after = doesn't contain valid
;				_submenu reference, it will be seen as user data. This also means that _submenu items can contain data.
;				To make menu definition more compact use something else then new line as item _separator
;				for instance "|" :
;>
;>					[_mnu1]
;>					item1|item2|item3|-|item4=[_mnu2]|item5
;>					[_mnu2]
;>					menu21 = menu21|menu22|menu23|menu24
;>
;				You can then use this command to show the menu
;>					ShowMenu(mDef, "", "", "|")				;use first menu found and | as item _separator
;
; About:
;				v1.2 by majkinetor
;				See:  http://www.autohotkey.com/forum/topic23138.html
;

;example menu handler  A_ThisMenuItem has menu item chosen, ShowMenu_Data(eMenu) to get menu included key info
;OnMenu:
;	data := ShowMenu_Data(eMenu)
;	Tooltip %A_ThisMenu%  -  %A_ThisMenuItem%`nUser data: "%data%", 0, 0
;return
;

ShowMenu(mDef, options = "", r=0)   {  ; , r =0)

	; options in order "? or =  = return = result | ! = use null label for sub | name = menu to show | <label> = sub to call to process | (x,y)  = x,y coordinates to show menu | {delim}  ex: {`n}  to set alt delim to | (default)

	; eg:  menu, "?!"
	; menu,"?menu2<processmenu1>{`n}"


	;if r
	;	regexmatch(options,"(?<mnu>[\w#_@$?\[\]]*)>(?<sub>[\w#_@$?\[\]]*)>(?<mx>\d*)>(?<my>\d*)>(?<sep>.+)",_)

	;else if
	if regexmatch(options,"S)^\s*"
					. "(?<Return_Result>[=?])?"
					. "(?<Null_sub>\!)?"
					. "\s*(?<mnu>[\w#_@$?\[\]]+)?"
					. "\s*(?:<\s*(?<sub>[\w#_@$?\[\]]+)\s*>)?"
					. "\s*(?:\(\s*(<mx>\d*)\s*,\s*(<my>\d*)\s*\))?"
					. "\s*(?:\{(?<sep>.+?)\})?",_) {


		if _Null_sub and !_sub
			_sub = ShowMenu_Null
		if _return_result
			_return_result = =
		_mnu = %_Return_Result%%_Null_sub%%_mnu%

	}

	if _sep =
		_sep = |


return ShowMenus(mDef, _mnu, _sub, _sep, _mx, _my , 0)

}

ShowMenus( mDef, _mnu="", _sub="", _sep="|", _mx = "", _my = "", r=0 ) {

	global ShowMenu_activemenu,ShowMenu_activedelim

	;Xebug( mDef "`n-->" _mnu)
	if (substr(_mnu,1,1) = "=") {
		if (substr(_mnu,2,1) = "!") {
			_mnu := substr(_mnu,3)
			_sub = -
		} else
			_mnu := substr(_mnu,2)
		_Return_Result = 1
	}

	if _sub = -
		_sub = ShowMenu_Null

	if (substr(mDef,1,1) = ">") {
		mDef := substr(mDef,2)
		Add_Menu = 1
	}

	/*
	options := _mnu

	if _sub !=
		options .= "<" _sub ">"

	if (_mx . _my != "")
		options .= "(" _mx "," _my ")"

	if _sep !=
		options .= "{" . _sep . "}"
*/


	;Xebug("options " options "`nReturn_result " _Return_Result "`nNull_sub" _Null_sub "`nmnu " _mnu "`nsub" _sub "`nx,y" _mx "," _my "`n sep=" _sep)


	/*
	;global ShowMenu_X, ShowMenu_Y
	if (substr(_mnu,1,1) = "?") {
		if (substr(_mnu,2,1) = "!") {
			_mnu := substr(_mnu,3)
			_sub = -
		} else
			_mnu := substr(_mnu,2)
		_Return_Result = 1
	}

	if _sub = -
		_sub = ShowMenu_Null

	*/

	static p, menus
	if (!r)  {
		if (_mnu = "") and (substr(mDef, 1, 1) = "[")				;use first menu if _mnu = ""
			_mnu := substr(mDef, 2, InStr(mDef, "]")- 2)
		p := _sub="" ? _mnu : _sub, menus:=""							;set on function call (not on recursion step)
	}

	Menu, %_mnu%, UseErrorLevel, on
	Menu, %_mnu%, nostandard				;check if menu already exists
	;Xebug("error level after default test is " errorlevel " and _mnu is " _mnu)
	if !ErrorLevel and  !Add_menu  ; ie uuhhoo EXISTS
		if !r {							;if this is first call, show the menu
			; restore color !
			;if regexmatch( _sep . mDef, "\Q" . _sep . "[" _mnu "]\E(?!\Q" _sep "[\E).*?\Q" _sep "^]\E([^\Q" _sep "\E]+)", color)
			;	Menu, %_mnu%, Color, %color%, single
			;Xebug("did not error on default,")
			if  _mx . _my =
				Menu, %_mnu%, Show
			else
				Menu, %_mnu%, Show, %_mx% , %_my%
				;if not in recursion, show
				;Menu, %_mnu%, Show, ShowMenu_X, ShowMenu_Y
			Showmenu_activemenu := mDef
			ShowMenu_activedelim := _sep
			return (_Return_Result ? ShowMenu_data()  : "")

		} else return			; otherwise this is recursion step so just return

/*
	if !r {														;if this is first call, show the menu

			if  _mx . _my =
				Menu, %_mnu%, Show
			else
				Menu, %_mnu%, Show, %_mx% , %_my%
				;if not in recursion, show
				;Menu, %_mnu%, Show, ShowMenu_X, ShowMenu_Y

			Showmenu_activemenu := mDef
			ShowMenu_activedelim := _sep
			return (_Return_Result ? ShowMenu_data()  : "")

	}
*/
; otherwise this is recursion step so just return
	;Menu, %_mnu%, Color,											    ;check if menu already exists
	;if !ErrorLevel

	;Xebug("got here to p = " p)
	if !(r || IsLabel(p))
		return "No Label"

	if !(s := substr(mDef, 1, StrLen(_mnu)+2) = "[" _mnu "]" )		;start index
		s := InStr(mDef, _sep "[" _mnu "]")
	IfEqual, s, 0, Return "Menu not found"

	if !(e := InStr(mDef, _sep "[",false, s+1))						;end index
		e := StrLen(mDef)

 	;if *(&mDef+s-1) = 10											;skip `n if on start
	;	s++
	s += Strlen(_mnu)+3, this := substr(mDef, s, e-s+1)				;extract menu def

	menus .= _mnu _sep  ; may need just `n ?? (insteapd of _sep)

	Loop, parse, this, %_sep%, % (_sep = "`n" ? : "`n`r"  : "")
	{
		s := A_LoopField
		;Xebug(s)
		IfEqual, s, ,continue
		IfEqual, s,-,SetEnv,s,										;_separator
		;Xebug(RegExMatch(s, "(?<S>\=)?\s*\[(?<T>[^\]]+)\]\s*(?<M>\w+)?",ou) "`n" ous "`n" out "`n" ouM "is ouM",1,1)
		if  RegExMatch(s, "(?<S>\=)?\s*\[(?<T>[^\]]+)\]\s*(?<M>\w)?", ou) 	; has _submenu somewhere
			if  (j := ouS)  and  !ouM  ;check for _submenu def
				;Xebug( "got here"  out "-" _sub "-"
				ShowMenus( (Add_menu ? ">" : "") . mDef, out , _sub, _sep, 0, 0 , 1 )
			; s := substr(s, 1, InStr(s,"=")-1),
		 if k := InStr(s,"=")									;if it has = after it remove it
				s := substr(s, 1, k-1)

		if ( (c := substr(s,1,2)) = "+]" ) or (c = "-]") or (c = "*]") or  (c = "^]")
			s := substr(s,3)

		if (c = "^]")
			;if substr(s,1,1) = "]"
			;	menu, %_mnu%, color, % substr(s,2)
			;else
				menu, %_mnu%, color, %s% ; , single
		else if c != _]
		{
			;Xebug(_mnu " is menu"  s "is item-->" (j ? ":" out : p))
			Menu, %_mnu%, Add, %s%, % j ? ":" out : p
			if c {
			IfEqual, c, +], Menu, %_mnu%, Check, %s%
			 IfEqual, c, -], Menu, %_mnu%, Disable, %s%
			 IfEqual, c, *], Menu, %_mnu%, Default, %s%
			 }
		}
		/*
		if (c:=(*&s = 43)) or ((*&s=42) and c:=2)
			StringTrimLeft, s, s, 1
		Menu, %_mnu%, Add, %s%, % j ? ":" out : p
		IfEqual, c, 1, Menu, %_mnu%, Check, %s%
		IfEqual, c, 2, Menu, %_mnu%, Disable, %s%
		*/

	}



;	if ShowMenu_Colors and regexmatch(showmenu_colors,"\b\Q" _mnu "\E\b\s*(?<r>\w+)",Colo)
;;	if regexmatch(_mnu,"_(?<r>\w+)$",Colo)
;;		menu, %_mnu%, color , %Color%,single
		;Xebug("THIS: " ShowMenu_Colors "- " Color  "--" _mnu,1,1)
	if ( r = 0 ) {
		if  _mx . _my =
			Menu, %_mnu%, Show
		else
			Menu, %_mnu%, Show, %_mx% , %_my%
		ShowMenu_activemenu := mDef
		ShowMenu_activedelim := _sep
		if _Return_Result
			menus :=  showMenu_Data()
	}
	return menus

	ShowMenu_Null:

	return
}

ShowMenu_Data(mDef = "", item="", _sep = "|") {

	;------------------------------------------------------------------------------------------------
	; Function:		ShowMenu_Data
	;				Get data associated with menu item
	;
	; Parameters:
	;				mDef	- Textual menu definition.
	;				item	- Menu item which associated data will be returned, if omited defaults to A_ThisMenuItem
	;
	; Returns:
	;				Associated data or empty string if no data is associated with item.

	global Showmenu_activeMenu,Showmenu_activeDelim
	if item =
		item := A_ThisMenuItem
	if (mDef = "") {
		mDef := ShowMenu_activemenu
		_sep := ShowMenu_activedelim
	}
	;Xebug(mDef "-->" item "---->" _sep)
	mDef .= _sep
	j := InStr(mDef, item "=")
	IfEqual, j, 0, return
	j += StrLen(item)+1
	return substr(mDef, j, InStr(mDef, _sep, false, j)-j)

}

ToggleMenu(dothis, delim="|") {

	/*			EXAMPLE

			showmenu("[test]|test \= 1= 1|+]test 2= 2|test4","?!")
			togglemenu("*|test 2|")
			showmenu("[test]")
			togglemenu("test|+test4 = cool|-test 2|test \= 1 = this_var")
			showmenu("[test]")
			togglemenu()
			showmenu("[test]")
			msgbox

	*/

	global
	local _,_main,_var,t, dothis2, A, Active, ALoop
	;debug(regexmatch(ShowMenu_activemenu,"^\s*\[(?<ctive>[^\]]+)\]",A) and  (A_ThisMenuItem != ""))
	if  !dothis and  regexmatch(ShowMenu_activemenu,"^\s*\[(?<ctive>[^\]]+)\]",A) and  (A_ThisMenuItem != "")
		dothis := Active  . delim . A_ThisMenuItem
	else if (substr(dothis,1,strlen(delim) + 1) = "*" . delim)  {
		loop parse, dothis, %delim%, %a_space%
			if ( ( aloop := regexreplace(a_loopfield,"\s*(?<!\\)=.*$")) = a_thisMenuItem)  and regexmatch(ShowMenu_activemenu,"^\s*\[(?<ctive>[^\]]+)\]",A) {

				dothis2 :=  Active . delim . a_loopfield
				break
			}
		if !(dothis := dothis2)  ;and !debug("returning")
			return
	}
	;debug( dothis "what i'm testnig")
	loop parse, dothis, %delim%, %a_space%
	{
		if (a_index = 1) {
			if (themenu := a_loopfield) {
				Menu, %themenu%, UseErrorLevel, on
			} else if !(themenu :=  ShowMenu_activemenu)
				return
		} else {

			if !(k := regexmatch(a_loopfield,"^(?<main>.+?)\s*(?:[^\\]=)\s*(?<var>[\w$#[\]@?]+)\s*$",_)  ) ;InStr(s,"=")									;if it has = after it remove it
				;s := substr(a_loopfield, 1, k) ; k-1)
			; else
				_main := a_loopfield

			if ((t := substr(_main,1,1))  = "+") or  (t = "-")
				_main := substr(_Main,2)

			stringreplace, _main, _main, \=,=,ALL
			if t = +
				menu, %themenu%, check, %_main%
			else if t = -
				menu, %themenu%, uncheck, %_main%
			else
				menu, %themenu%, togglecheck , %_main%

			if _var
				%_var% := ! %_var%

		}

	}

}


