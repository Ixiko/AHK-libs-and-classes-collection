/*
  Function:		ShowMenu
 				Show menu from the text string.
   
  Parameters: 
 				MenuDef	- Textual menu definition.
 				MenuName - Menu to show. Label with the same name as menu will be launched on item selection.
 						  "" means that first menu will be shown (default).
 				Fun		- Menu handler. If Empty, defaults to the menu name + "On" prefix.
 				Sep		- Separator char used for menu items in menu definition, by default new line.
 				
  Returns:      
 				Message describing error if it ocured or new line separated list of created menus.
 				If return value is blank, ShowMenu just displayed menu already created in one of previous calls.
 
  Remarks:
 				You must have in the code label with the same name as that given to the menu, otherwise
 				ShowMenu returns "No Label" error (unless you used "sub" parameter in which case the same 
 				applies to that subroutine). There must be no white space between menu name and start of the line.
 				Set each menu item on new line, use "-" to define separator.
 				To create submenu, use "item = [submenu]" notation where submenu must exist in the textual 
 				menu definition. While referencing any particular menu as submenu multiple times will work 
 				correctly, circular references will produce unexpected results. 
 				You can use = after item to store some custom data there. If text after = doesn't contain valid
 				submenu reference, it will just be removed before item is displayed.
 				To make menu definition more compact use something else then new line as item separator
 				for instance "|" :
 >
 >				MenuDef=
 >				(LTrim
 >					[MenuName1]
 >					item1|item2|item3|-|item4=[MenuName2]|item5
 >					[MenuName2]
 >					menu21 = menu21|menu22|menu23|menu24									  
 >				)
 				You can then use this command to show the menu :
 >					ShowMenu(MenuDef, "MenuName1", "", "|")						;use | as item separator.
 
  About:
 				v2.0 by majkinetor.
 				See:  http://www.autohotkey.com/forum/topic23138.html
 */
ShowMenu( MenuDef, MenuName="", Sub="", Sep="`n", r=0 ) {
	static p, menus
	if (!r)  {
		if (MenuName = "") and (SubStr(MenuDef, 1, 1) = "[")					;use first menu if MenuName = ""
			MenuName := SubStr(MenuDef, 2, InStr(MenuDef, "]")- 2)
		p := sub="" ? MenuName : sub, menus:=""									;set on function call (not on recursion step)
	}

	Menu, %MenuName%, UseErrorLevel, on
	Menu, %MenuName%, Color,													;check if menu already exists
	if !ErrorLevel
		if !r {																	;if this is first call, show the menu
			Menu, %MenuName%, Show
			return 
		} else return															; otherwise this is recursion step so just return
	
	if !(r || IsLabel(p))
		return A_ThisFunc "> No Label"

	if !(s := SubStr(MenuDef, 1, StrLen(MenuName)+2) = "[" MenuName "]" )		;start index
		s := InStr(MenuDef, "`n[" MenuName "]")
	IfEqual, s, 0, Return "Menu not found"
	
	if !(e := InStr(MenuDef, "`n[",false, s+1))									;end index
		e := StrLen(MenuDef)		

 	if *(&MenuDef+s-1) = 10														;skip `n if on start
		s++
	s += Strlen(MenuName)+3, this := SubStr(MenuDef, s, e-s+1)					;extract menu def

	menus .= MenuName "`n"
	Loop, parse, this, %Sep%, `n`r
	{
		s := A_LoopField
		IfEqual, s, ,continue
		IfEqual, s,-,SetEnv,s,													;separator
		if j := RegExMatch(s, "S)(?<=\[).+?(?=\])", out)						;check for submenu	
			 s := SubStr(s, 1, InStr(s,"=")-1),   ShowMenu( MenuDef, out, sub, Sep, 1)
		else if k := InStr(s,"=")												;if it has = after it remove it
			s := SubStr(s, 1, k-1)
		Menu, %MenuName%, Add, %s%, % j ? ":" out : p
	}

	IfEqual, r, 0 , Menu, %MenuName%, Show										;if not in recursion, show
	return menus
}