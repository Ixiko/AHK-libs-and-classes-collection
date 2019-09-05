; ADHDLib - Autohotkey Dynamic Hotkeys for Dummies

/*
ToDo:

BUGS:

Before next release:

Features:
* Hotkey box for use outside of bindings tab

Long-term:
* Re-add stick support
* Some way to remove self-refs to ADHD. in code?
* Way to move BindMode #If block inside object?
* Replace label names in ini with actual label names instead of 1, 2, 3 ?

*/

/*
 ####   #   #  ####   #       ###    ###          #####  #   #  #   #   ###   #####   ###    ###   #   #   ###
 #   #  #   #   #  #  #        #    #   #         #      #   #  #   #  #   #    #      #    #   #  #   #  #   #
 #   #  #   #   #  #  #        #    #             #      #   #  ##  #  #        #      #    #   #  ##  #  #
 ####   #   #   ###   #        #    #             ####   #   #  # # #  #        #      #    #   #  # # #   ###
 #      #   #   #  #  #        #    #             #      #   #  #  ##  #        #      #    #   #  #  ##      #
 #      #   #   #  #  #        #    #   #         #      #   #  #   #  #   #    #      #    #   #  #   #  #   #
 #       ###   ####   #####   ###    ###          #       ###   #   #   ###     #     ###    ###   #   #   ###

Functions in this section are intended for use by script authors.
*/

Class ADHDLib {
	__New(){
		this.private := New ADHD_Private
		this.private.parent := this
	}

	/*
	  ###                   ##     #                           #
	 #   #                 #  #
	 #       ###   # ##    #      ##     ## #  #   #  # ##    ##    # ##    ## #
	 #      #   #  ##  #  ####     #    #  #   #   #  ##  #    #    ##  #  #  #
	 #      #   #  #   #   #       #     ##    #   #  #        #    #   #   ##
	 #   #  #   #  #   #   #       #    #      #  ##  #        #    #   #  #
	  ###    ###   #   #   #      ###    ###    ## #  #       ###   #   #   ###
	                                    #   #                              #   #
	                                     ###                                ###
	Set various options for the script before starting
	*/

	; Make sure the macro runs with administrator priveleges.
	; Some games etc will not see sent keys without this.
	; Run as admin code from http://www.autohotkey.com/board/topic/46526-
	run_as_admin(){
		Global 0
		IfEqual, A_IsAdmin, 1, Return 0
		Loop, %0% {
			params .= A_Space . %A_Index%
		}
		DllCall("shell32\ShellExecute" (A_IsUnicode ? "":"A"),uint,0,str,"RunAs",str,(A_IsCompiled ? A_ScriptFullPath
			: A_AhkPath),str,(A_IsCompiled ? "": """" . A_ScriptFullPath . """" . A_Space) params,str,A_WorkingDir,int,1)
		ExitApp
	}
	
	; --------------------------------------------------------------------------------------------------------------------------------------

	; Configure the About tab
	; Pass an associative array
	; name:		The name of your script
	; author:	Your name
	; link:		A Link to a web page about your script
	; eg: ADHD.config_about({name: "My script", version: 1.0.0, author: "myname", link: "<a href=""http://google.com"">Google</a>"})
	config_about(data){
		this.private.author_macro_name := data.name					; Change this to your macro name
		this.private.author_version := data.version									; The version number of your script
		this.private.author_name := data.author							; Your Name
		this.private.author_link := data.link
		if (data.help == "" || data.help == null){
			this.private.author_help := this.private.author_link
		} else {
			this.private.author_help := data.help
		}
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Sets the default option for the "Limit App" setting.
	; If you are writing a macro for a game, you should find the game's ahk_class using the AHK Window Spy and set it here
	config_limit_app(app){
		this.private.limit_app := app
	}
	
	; --------------------------------------------------------------------------------------------------------------------------------------

	; Sets the size of the GUI
	config_size(w,h){
		this.private.gui_w := w
		this.private.gui_h := h
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Configures the update notifications system for your script
	; If you wish to notify users when you update your script, you can have ADHD check a web URL to determine what the latest version of your script is.
	; ADHD will be expecting to find a text file at that URL containing only text like so: Version = 1.2.3
	; eg: ADHD.config_updates("http://evilc.com/files/ahk/mwo/firectrl/firectrl.au.txt")
	config_updates(url){
		this.private.author_url_prefix := url
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Adds a hotkey to the script
	; Pass an associative array
	; uiname:		The name of the hotkey
	; subroutine: 	The label to call when this hotkey is pressed
	;				Also be aware here that if you declare a hotkey that points to the subroutine "fire"...
	;				"fire_up" will also be called when the hotkey is released
	; tooltip:		A tooltip to display when the user hovers over the hotkey
	; eg: ADHD.config_hotkey_add({uiname: "Fire", subroutine: "Fire", tooltip: "When you press this button, the fire Action will be run"})
	config_hotkey_add(data){
		this.private.hotkey_list.Insert(data)
	}

	; --------------------------------------------------------------------------------------------------------------------------------------
	
	; Adds a "hook" into ADHD - when a specific event happens, the specified label will be called
	; Available events:
	; option_changed		An option changed
	; tab_changed			The current tab changed
	; on_exit				The app is about to exit
	; app_active			The "Limited" app came into focus
	; app_inactive			The "Limited" app went out of focus
	; resolution_changed	The resolution of the "Limited" app changed
	config_event(name, hook){
		this.private.events[name] := hook
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Configures tabs used by ADHD.
	; If you wish to add aditional tabs, or change the name of the "Main" tab, pass an array of names to this function
	; The FIRST item will ALWAYS be the "Main" tab.
	; ADHD will add the other default tabs (Bindings, Profiles, About) at the end of these tabs. 
	; eg: ADHD.config_tabs(Array("Axes 1", "Axes 2", "Buttons 1", "Buttons 2", "Hats"))
	config_tabs(tabs){
		this.private.tab_list := tabs
		return
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Sets the version of the INI file.
	; Use this if you make major changes to the names of the GUI controls etc, such that an INI file would not be compatible.
	; Set to a new version to force a message warning users that the ini file will not be compatible.
	config_ini_version(ver){
		return this.private.config_ini_version(ver)
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Determines if config version is written to INI file on exit
	config_write_version(setting){
		this.private.write_version := setting
		return
	}

	; When compiling scripts, you should use the 32-bit version of AHK, else it will not run on 32-bit machines.
	; On startup, ADHD checks if the script is compiled as 64-bit, and if it is, warns you.
	; You can override that behavior with this function
	config_ignore_x64_warning(){
		this.private.x64_warning := 0
	}
	
	; On startup, ADHD will check to see if you have any actions defined, and will exit if not.
	; You can override that behaviour with this function
	config_ignore_noaction_warning(){
		this.private.noaction_warning := 0
	}
	
	; --------------------------------------------------------------------------------------------------------------------------------------

	/*
	  ###    #                    #       #                         #   #
	 #   #   #                    #                                 #   #
	 #      ####    ###   # ##   ####    ##    # ##    ## #         #   #  # ##
	  ###    #         #  ##  #   #       #    ##  #  #  #          #   #  ##  #
	     #   #      ####  #       #       #    #   #   ##           #   #  ##  #
	 #   #   #  #  #   #  #       #  #    #    #   #  #             #   #  # ##
	  ###     ##    ####  #        ##    ###   #   #   ###           ###   #
	                                                  #   #                #
	                                                   ###                 #
	*/

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Initializes ADHD
	; Load settings, staring profile etc.
	init(){
		; Perform some sanity checks
		
		; Check if compiled and x64
		if (A_IsCompiled){
			if (A_Ptrsize == 8 && this.private.x64_warning){
				Msgbox, You have compiled this script under 64-bit AutoHotkey.`n`nAs a result, it will not work for people on 32-bit windows.`n`nDo one of the following:`n`nReinstall Autohotkey and choose a 32-bit option.`n`nCreate an x64 exe without this warning by calling config_ignore_x64_warning()
				ExitApp
			}
		}

		; Check the user instantiated the class
		if (this.private.instantiated != 1){
			msgbox You must use an instance of this class, not the class itself.`nPut something like ADHD := New ADHDLib at the start of your script
			ExitApp
		}
		
		; Check the user defined a hotkey
		if (this.private.hotkey_list.MaxIndex() < 1){
			if (this.private.noaction_warning){
				msgbox, No Actions defined, Exiting...
				ExitApp
			}
		}

		; Check that labels specified as targets for hotkeys actually exist
		Loop, % this.private.hotkey_list.MaxIndex()
		{
			If (IsLabel(this.private.hotkey_list[A_Index,"subroutine"]) == false){
				msgbox, % "The label`n`n" this.private.hotkey_list[A_Index,"subroutine"] ":`n`n does not appear in the script.`nExiting..."
				ExitApp
			}

		}
		this.private.debug_ready := 0
		
		; Indicates that we are starting up - ignore errant events, always log until we have loaded settings etc use this value
		this.private.starting_up := 1

		this.private.debug("Starting up...")
		this.private.app_act_curr := -1						; Whether the current app is the "Limit To" app or not. Start on -1 so we can init first state of app active or inactive

		; Start ADHD init vars and settings

		; Variables to be stored in the INI file - will be populated by code later
		; [Variable Name, Control Type, Default Value]
		; eg ["MyControl","Edit","None"]
		this.private.ini_vars := []
		; Holds a REFERENCE copy of the hotkeys so authors can access the info (eg to quickly send a keyup after the trigger key is pressed)
		this.private.hotkey_mappings := {}

		#InstallKeybdHook
		#InstallMouseHook
		#MaxHotKeysPerInterval, 200

		#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
		SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

		; Make sure closing the GUI using X exits the script
		OnExit, GuiClose

		ini := this.private.ini_name
		IniRead, x, %ini%, Settings, adhd_gui_x, unset
		IniRead, y, %ini%, Settings, adhd_gui_y, unset
		this.private.first_run := 0
		if (x == "unset"){
			msgbox, Welcome to this ADHD based macro.`n`nThis window is appearing because no settings file was detected, one will now be created in the same folder as the script`nIf you wish to have an icon on your desktop, it is recommended you place this file somewhere other than your desktop and create a shortcut, to avoid clutter or accidental deletion.`n`nIf you need further help, look in the About tab for links to Author(s) sites.`nYou may find help there, you may also find a Donate button...
			x := 0	; initialize
			this.private.first_run := 1
		}
		if (y == "unset"){
			y := 0
			this.private.first_run := 1
		}

		if (x == ""){
			x := 0	; in case of crash empty values can get written
		}
		if (y == ""){
			y := 0
		}
		this.private.gui_x := x
		this.private.gui_y := y
		
		; Get list of profiles
		IniRead, pl, %ini%, Settings, adhd_profile_list, %A_Space%
		this.private.profile_list := pl
		; Get current profile
		IniRead, cp, %ini%, Settings, adhd_current_profile, Default
		this.private.current_profile := cp

		; Get version of INI file
		IniRead, iv, %ini%, Settings, adhd_ini_version, 1
		this.private.loaded_ini_version := iv

	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Creates the GUI
	create_gui(){
		; IMPORTANT !!
		; Declare global for gui creation routine.
		; Limitation of AHK - no dynamic creation of vars, and guicontrols need a global or static var
		; Also, gui commands do not accept objects
		; So declare temp vars as local in here
		global
		; Set up the GUI ====================================================
		local w := this.private.gui_w
		local h := this.private.gui_h - 30
		
		local tabs := ""
		Loop, % this.private.tab_list.MaxIndex()
		{
			tabs := tabs this.private.tab_list[A_Index] "|"
		}
		Gui, Add, Tab2, x0 w%w% h%h% vadhd_current_tab gadhd_tab_changed, %tabs%Bindings|Profiles|About

		local tabtop := 40
		local current_row := tabtop + 20
		
		local nexttab := this.private.tab_list.MaxIndex() + 1
		Gui, Tab, %nexttab%
		; BINDINGS TAB
		Gui, Add, Text, x5 y40 W100 Center, Action

		hotkey_w := this.private.gui_w - 220
		hotkey_after := hotkey_w + 10

		xpos := 105 + (hotkey_w / 2) - 50

		Gui, Add, Text, x%xpos% yp W100 Center, Current Binding

		; Add hotkeys
	
		; Add functionality toggle as last item in list
		this.config_hotkey_add({uiname: "Functionality Toggle", subroutine: "adhd_functionality_toggle"})

		xpos := 105 + hotkey_w + 45
		Gui, Add, Text, x%xpos% y30 w30 center, Wild`nMode

		Gui, Add, Text, xp+30 y30 w30 center, Pass`nThru

		Loop % this.private.hotkey_list.MaxIndex() {
			local name := this.private.hotkey_list[A_Index,"uiname"]
			Gui, Add, Text,x5 W100 y%current_row%, %name%
			Gui, Add, Edit, Disabled vadhd_hk_hotkey_%A_Index% w%hotkey_w% x105 yp-3,
			;Gui, Add, Edit, Disabled vadhd_hk_hotkey_display_%A_Index% w160 x105 yp-3, None
			;Gui, Add, Edit, Disabled vadhd_hk_hotkey_%A_Index% w95 xp+165 yp,
			Gui, Add, Button, gadhd_set_binding vadhd_hk_bind_%A_Index% yp-1 xp+%hotkey_after%, Bind
			adhd_hk_bind_%A_Index%_TT := this.private.hotkey_list[A_Index,"tooltip"]

			;Gui, Add, Button, gadhd_set_binding vadhd_hk_bind_%A_Index% yp-1 xp+105, Bind
			Gui, Add, Checkbox, vadhd_hk_wild_%A_Index% gadhd_option_changed xp+45 yp+5 w25 center
			adhd_hk_wild_%A_Index%_TT := "Wild Mode allows hotkeys to trigger when other modifiers are also held.`nFor example, if you bound Ctrl+C to an action...`nWild Mode ON: Ctrl+Alt+C, Ctrl+Shift+C etc would still trigger the action`nWild Mode OFF: Ctrl+Alt+C etc would not trigger the action."

			Gui, Add, Checkbox, vadhd_hk_passthru_%A_Index% gadhd_option_changed xp+30 yp w25 center Checked
			adhd_hk_passthru_%A_Index%_TT := "Pass Thru mode off tries to stop the game from seeing the pressed key.`nNote, PassThru is FORCED ON if you bind just the Left Mouse or Right Mouse buttons."

			current_row := current_row + 30
		}
		
		local nexttab := this.private.tab_list.MaxIndex() + 2
		Gui, Tab, %nexttab%
		; PROFILES TAB
		current_row := tabtop + 20
		Gui, Add, Text,x5 W40 y%current_row%,Profile
		local pl := this.private.profile_list
		local cp := this.private.current_profile
		Gui, Add, DropDownList, xp+35 yp-5 W300 vadhd_current_profile gadhd_profile_changed, Default||%pl%
		Gui, Add, Button, x40 yp+25 gadhd_add_profile, Add
		Gui, Add, Button, xp+35 yp gadhd_delete_profile, Delete
		Gui, Add, Button, xp+47 yp gadhd_duplicate_profile, Copy
		Gui, Add, Button, xp+40 yp gadhd_rename_profile, Rename
		GuiControl,ChooseString, adhd_current_profile, %cp%
		
		; Limit application toggle
		Gui, Add, CheckBox, x5 yp+25 W160 vadhd_limit_application_on gadhd_option_changed, Limit to Application: ahk_class

		; Limit application Text box
		Gui, Add, Edit, xp+170 yp+2 W120 vadhd_limit_application gadhd_option_changed,
		
		; Launch window spy
		Gui, Add, Button, xp+125 yp-1 W70 gadhd_show_window_spy, Window Spy
		adhd_show_window_spy_TT := "Enter a value here to make hotkeys only trigger when a specific application is open.`nUse the window spy (? Button to the right) to find the ahk_class of your application.`nCaSe SenSitIve !!!"

		; Auto profile switching
		Gui, Add, CheckBox, x5 yp+25 W260 vadhd_auto_profile_switching gadhd_option_changed, Enable automatic profile switching

		local nexttab := this.private.tab_list.MaxIndex() + 3
		Gui, Tab, %nexttab%
		; ABOUT TAB
		current_row := tabtop + 5
		Gui, Add, Link,x5 y%current_row%, This macro was created using AHK Dynamic Hotkeys for Dummies (ADHD)
		Gui, Add, Link,x5 yp+25,By Clive "evilC" Galway <a href="http://evilc.com/proj/adhd">HomePage</a>    <a href="https://github.com/evilC/ADHD-AHK-Dynamic-Hotkeys-for-Dummies">GitHub Page</a>
		local aname := this.private.author_name
		local mname := this.private.author_macro_name
		Gui, Add, Link,x5 yp+35, This macro ("%mname%") was created by %aname%
		local link := this.private.author_link
		Gui, Add, Link,x5 yp+25, %link%

		Gui, Tab

		; Add a Status Bar for at-a-glance current profile readout and update status
		local ypos := this.private.gui_h - 17
		local tmp := this.private.gui_w - 200
		Gui, Add, Text, x5 y%ypos%,Current Profile:
		Gui, Add, Text, x80 y%ypos% w%tmp% vCurrentProfile,

		local tmp := this.private.gui_w - 120
		Gui, Add, Text, x%tmp% y%ypos%, Updates:
		;local tmp := this.private.gui_w - 200
		Gui, Add, Text, xp+50 y%ypos% w60 vUpdateStatus
		;Gui, Add, Button, xp+48 yp-6 w20 gadhd_update_status_info, ?
		Gui, Add, Button, xp+48 yp-6 w20 vUpdateStatusInfo, ?
		UpdateStatusInfo_TT := ""

		; Build version info
		local bad := 0
		
		; Check versions:
		local tt := "Versions found on the internet:`n`nADHD library:`n"

		; ADHD version
		ver := this.private.get_ver("http://evilc.com/files/ahk/adhd/adhd.au.txt")
		if (ver){
			cv := this.private.pad_version(this.private.core_version)
			rv := this.private.pad_version(ver)
			diffc := this.private.semver_compare(cv,rv)

			tt .= this.private.version_tooltip_create(diffc,rv,cv)
		} else {
			tt .= "Unknown"
			bad++
		}
		tt .= "`n`n" this.private.author_macro_name ":`n"

		; Author Script version
		ver := this.private.get_ver(this.private.author_url_prefix)
		if (ver){
			av := this.private.pad_version(this.private.author_version)
			rv := this.private.pad_version(ver)
			diffa := this.private.semver_compare(av,rv)

			tt .= this.private.version_tooltip_create(diffa,rv,av)
		} else {
			tt .= "Unknown"
			bad++
		}

		; Show status
		if (bad){
			GuiControl,+Cblack,UpdateStatus
			GuiControl,,UpdateStatus, Unknown
		} else if (diffc > 0 || diffa > 0){
			GuiControl,+Cblue,UpdateStatus
			GuiControl,,UpdateStatus, Newer
		} else if (diffc < 0 || diffa < 0){
			GuiControl,+Cred,UpdateStatus
			GuiControl,,UpdateStatus, Available
		} else {
			GuiControl,+Cgreen,UpdateStatus
			GuiControl,,UpdateStatus, Latest
		}

		; Apply tooltip
		UpdateStatusInfo_TT := tt

		; Add Debug window controls
		Gui, Tab
		local tmp
		tmp := w - 90
		Gui, Add, CheckBox, x%tmp% y10 vadhd_debug_window gadhd_debug_window_change, Show Window
			
		tmp := w - 180
		Gui, Add, CheckBox, x%tmp% y10 vadhd_debug_mode gadhd_debug_change, Debug Mode

		; Fire GuiSubmit while starting_up is on to set all the variables
		Gui, Submit, NoHide

		; Create the debug GUI, but do not show yet
		tmp := w - 30
		Gui, 2:Add,Edit,w%tmp% h350 vadhd_log_contents hwndadhd_log ReadOnly,
		Gui, 2:Add, Button, gadhd_clear_log, clear

		; Create the Bind GUI
		prompt := "Please press the desired key combination.`n`n"
		prompt .= "Supports most keyboard keys and all mouse buttons. Also Ctrl, Alt, Shift, Win as modifiers or individual keys.`n"
		;prompt .= "Joystick buttons are also supported, but currently not with modifiers.`n"
		prompt .= "`nHit Escape to cancel."
		prompt .= "`nHold Escape to clear a binding."
		Gui, 3:Add, text, center, %prompt%
		Gui, 3:-Border +AlwaysOnTop
		;Gui, 3:Show


	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Adds a GUI item and registers it for storage in the INI file
	; type(edit etc), name(variable name), options(eg xp+50), param3(eg dropdown list, label), default(used for ini file)
	gui_add(ctype, cname, copts, cparam3, cdef){
		; Note this function assumes global so it can create gui items
		Global
		Gui, Add, %ctype%, %copts% v%cname% gadhd_option_changed, %cparam3%
		this.private.ini_vars.Insert([cname,ctype,cdef])
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Call once you are ready to actually start the macro.
	finish_startup(){
		global	; Remove! phase out mass use of globals
		
		; Show the GUI =====================================
		local ver := this.private.core_version
		local aver := this.private.author_version
		local name := this.private.author_macro_name
		local x := this.private.gui_x
		local y := this.private.gui_y
		local w := this.private.gui_w
		local h := this.private.gui_h

		local l := 0,r := 0,t := 0,b := 0
		local mon, monleft, monright, montop, monbottom

		; Check GUI is not at non-visible location (ie off screen)
		SysGet, Count, 80
		Loop % Count {
			SysGet, Mon, Monitor, % A_Index
			if (monleft < l){
				l := monleft
			}
			if (monright > r){
				r := monright
			}
			if (montop < t){
				t := montop
			}
			if (monbottom > b){
				b := monbottom
			}
		}
		if (x < l){
			x := l
		}
		if (x + w > r){
			x := r - w
		}
		if (y < t){
			y := t
		}
		if (y + h > b){
			y := b - h
		}

		Gui, Show, x%x% y%y% w%w% h%h%, %name% v%aver% (ADHD v%ver%)

		

		this.private.debug_ready := 1

		; Set up the links on the footer of the main page
		h := this.private.get_gui_h() - 40
		name := this.private.get_macro_name()
		alink := this.private.author_help
		Gui, Add, Link, x5 y%h%, <a href="http://evilc.com/proj/adhd">ADHD Instructions</a>    %name% %alink%


		;Hook for Tooltips
		;OnMessage(0x200, "this.private.mouse_move")
		OnMessage(0x200, "adhd_mouse_move")


		; Finish setup =====================================
		this.private.profile_changed()
		this.private.option_changed()
		this.private.debug_window_change()
		
		; Auto profile switching
		Gui +LastFound 
		hWnd := WinExist()
		DllCall( "RegisterShellHookWindow", UInt,Hwnd )
		MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
		fn := this.active_window_changed.bind(this)
		OnMessage( MsgNum, fn )

		this.private.debug("Finished startup")

		; Finished startup, allow change of controls to fire events
		this.private.starting_up := 0

	}

	active_window_changed( wParam,lParam ){
		if (this.private.auto_profile_switching){
			If (lParam) { ; id of 0 is desktop
				WinGetClass, class, ahk_id %lParam%
				if (lParam <= 2 || class = ""){
					return
				}
				profile := this.private.app_list[class]
				if (profile){
					GuiControl,ChooseString, adhd_current_profile, %profile%
					this.private.profile_changed()
					return
				}
			}
			; Change to default profile
			GuiControl,ChooseString, adhd_current_profile, Default
			this.private.profile_changed()
		}
	}
	; --------------------------------------------------------------------------------------------------------------------------------------

	/*
	  ###           #      #                                                   #          ###           #      #
	 #   #          #      #                                                   #         #   #          #      #
	 #       ###   ####   ####    ###   # ##    ###           ###   # ##    ## #         #       ###   ####   ####    ###   # ##    ###
	 #      #   #   #      #     #   #  ##  #  #                 #  ##  #  #  ##          ###   #   #   #      #     #   #  ##  #  #
	 #  ##  #####   #      #     #####  #       ###           ####  #   #  #   #             #  #####   #      #     #####  #       ###
	 #   #  #       #  #   #  #  #      #          #         #   #  #   #  #  ##         #   #  #       #  #   #  #  #      #          #
	  ###    ###     ##     ##    ###   #      ####           ####  #   #   ## #          ###    ###     ##     ##    ###   #      ####
	
	; Functions to get and set values
	*/

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Gets the name of the application specified in the "Limit to Application" box
	get_limit_app(){
		return this.private.get_limit_app()
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Gets the state of the "Limit to Application" checkbox
	get_limit_app_on(){
		return this.private.get_limit_app_on()
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Gets the current size of the application specified in the "Limit to Application" box
	; returns  an object with .w and .h properties
	limit_app_get_size(){
		return this.private.limit_app_get_size()
	}

	; --------------------------------------------------------------------------------------------------------------------------------------
	
	; Gets the LAST size of the application specified in the "Limit to Application" box
	; This is useful for example to detect an game going from windowed mode (lobby) to fullscreen (game)
	; returns  an object with .w and .h properties
	limit_app_get_last_size(){
		return this.private.limit_app_get_last_size()
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Is ADHD still starting up?
	is_starting_up(){
		return this.private.starting_up
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Is ADHD in Debug Mode?
	get_debug_mode(){
		global adhd_debug_mode
		return adhd_debug_mode
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Gets the name of the current tab in ADHD
	get_current_tab(){
		global adhd_current_tab
		return adhd_current_tab
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Changes to the specified tab
	set_current_tab(tab){
		;global adhd_current_tab
		GuiControl, Choose,adhd_current_tab, %tab%
		return
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Is this the first time this macro has been run ?
	; Can be used to provide custom welcome screens, set up stuff etc.
	is_first_run(){
		return this.private.first_run
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Gets the version of the INI file - see config_ini_version()
	get_ini_version(){
		return this.private.loaded_ini_version
	}

	; returns true if the application specified in the "Limit to Application" box is active, false if not
	limit_app_is_active(){
		return this.private.limit_app_is_active()
	}

	; Returns the number of GUIs used by ADHD.
	; You can use this to determine the next safe number GUI to use.
	get_guis_used(){
		return this.private.guis_used
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	/*
	 #   #    #                         #####                        #       #
	 #   #                              #                            #
	 ## ##   ##     ###    ###          #      #   #  # ##    ###   ####    ##     ###   # ##    ###
	 # # #    #    #      #   #         ####   #   #  ##  #  #   #   #       #    #   #  ##  #  #
	 #   #    #     ###   #             #      #   #  #   #  #       #       #    #   #  #   #   ###
	 #   #    #        #  #   #         #      #  ##  #   #  #   #   #  #    #    #   #  #   #      #
	 #   #   ###   ####    ###          #       ## #  #   #   ###     ##    ###    ###   #   #  ####
	
	; Useful stuff that does not fit into any other category
	*/

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Writes something to the debug window
	debug(msg){
		return this.private.debug(msg)
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; Quits the script
	exit_app(){
		return this.private.exit_app()
	}

	; Compares two version numbers.
	; May be wise to pass the version numbers to pad_version first.
	semver_compare(version1, version2){
		return this.private.semver_compare(version1, version2)
	}

	; Pads from one-point (ie 1) to two-point (ie 1.0) to three-point (ie 1.0.0) intelligently
	pad_version(version){
		return this.private.pad_version(version)
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

	; When doing a macro that is activated by holding a button, some games behave weirdly if an up event is not seen for the hotkey.
	; eg you have a macro where holding Right Mouse performs a rapid fire...
	; ...Some games will not work right if they do not see an up event for the Right Mouse button
	; Use this function to send an up event for whatever key a user has bound to an action
	; sub = the subroutine that is called for the hotkey (eg "fire")
	; mod = "mofified" or "unmodified"
	; If a user bound Ctrl+Right Mouse to an action...
	; "modified" would send an up event for Ctrl+Right Mouse
	; "unmodified" would send an up event for just Right Mouse
	send_keyup_on_press(sub,mod){
		return this.private.send_keyup_on_press(sub,mod)
	}

	; x64 compatible registry read/write from http://www.autohotkey.com/board/topic/36290-regread64-and-regwrite64-no-redirect-to-wow6432node/
	RegRead64(sRootKey, sKeyName, sValueName = "", DataMaxSize=1024) {
		HKEY_CLASSES_ROOT	:= 0x80000000	; http://msdn.microsoft.com/en-us/library/aa393286.aspx
		HKEY_CURRENT_USER	:= 0x80000001
		HKEY_LOCAL_MACHINE	:= 0x80000002
		HKEY_USERS			:= 0x80000003
		HKEY_CURRENT_CONFIG	:= 0x80000005
		HKEY_DYN_DATA		:= 0x80000006
		HKCR := HKEY_CLASSES_ROOT
		HKCU := HKEY_CURRENT_USER
		HKLM := HKEY_LOCAL_MACHINE
		HKU	 := HKEY_USERS
		HKCC := HKEY_CURRENT_CONFIG
		
		REG_NONE 				:= 0	; http://msdn.microsoft.com/en-us/library/ms724884.aspx
		REG_SZ 					:= 1
		REG_EXPAND_SZ			:= 2
		REG_BINARY				:= 3
		REG_DWORD				:= 4
		REG_DWORD_BIG_ENDIAN	:= 5
		REG_LINK				:= 6
		REG_MULTI_SZ			:= 7
		REG_RESOURCE_LIST		:= 8

		KEY_QUERY_VALUE := 0x0001	; http://msdn.microsoft.com/en-us/library/ms724878.aspx
		KEY_WOW64_64KEY := 0x0100	; http://msdn.microsoft.com/en-gb/library/aa384129.aspx (do not redirect to Wow6432Node on 64-bit machines)
		KEY_SET_VALUE	:= 0x0002
		KEY_WRITE		:= 0x20006

		myhKey := %sRootKey%		; pick out value (0x8000000x) from list of HKEY_xx vars
		IfEqual,myhKey,, {		; Error - Invalid root key
			ErrorLevel := 3
			return ""
		}
		
		RegAccessRight := KEY_QUERY_VALUE + KEY_WOW64_64KEY
		
		DllCall("Advapi32.dll\RegOpenKeyExA", "uint", myhKey, "str", sKeyName, "uint", 0, "uint", RegAccessRight, "uint*", hKey)	; open key
		DllCall("Advapi32.dll\RegQueryValueExA", "uint", hKey, "str", sValueName, "uint", 0, "uint*", sValueType, "uint", 0, "uint", 0)		; get value type
		If (sValueType == REG_SZ or sValueType == REG_EXPAND_SZ) {
			VarSetCapacity(sValue, vValueSize:=DataMaxSize)
			DllCall("Advapi32.dll\RegQueryValueExA", "uint", hKey, "str", sValueName, "uint", 0, "uint", 0, "str", sValue, "uint*", vValueSize)	; get string or string-exp
		} Else If (sValueType == REG_DWORD) {
			VarSetCapacity(sValue, vValueSize:=4)
			DllCall("Advapi32.dll\RegQueryValueExA", "uint", hKey, "str", sValueName, "uint", 0, "uint", 0, "uint*", sValue, "uint*", vValueSize)	; get dword
		} Else If (sValueType == REG_MULTI_SZ) {
			VarSetCapacity(sTmp, vValueSize:=DataMaxSize)
			DllCall("Advapi32.dll\RegQueryValueExA", "uint", hKey, "str", sValueName, "uint", 0, "uint", 0, "str", sTmp, "uint*", vValueSize)	; get string-mult
			sValue := this.ExtractData(&sTmp) "`n"
			Loop {
				If (errorLevel+2 >= &sTmp + vValueSize)
					Break
				sValue := sValue this.ExtractData( errorLevel+1 ) "`n" 
			}
		} Else If (sValueType == REG_BINARY) {
			VarSetCapacity(sTmp, vValueSize:=DataMaxSize)
			DllCall("Advapi32.dll\RegQueryValueExA", "uint", hKey, "str", sValueName, "uint", 0, "uint", 0, "str", sTmp, "uint*", vValueSize)	; get binary
			sValue := ""
			SetFormat, integer, h
			Loop %vValueSize% {
				hex := SubStr(Asc(SubStr(sTmp,A_Index,1)),3)
				StringUpper, hex, hex
				sValue := sValue hex
			}
			SetFormat, integer, d
		} Else {				; value does not exist or unsupported value type
			DllCall("Advapi32.dll\RegCloseKey", "uint", hKey)
			ErrorLevel := 1
			return ""
		}
		DllCall("Advapi32.dll\RegCloseKey", "uint", hKey)
		return sValue
	}

	RegWrite64(sValueType, sRootKey, sKeyName, sValueName = "", sValue = "") {
		HKEY_CLASSES_ROOT	:= 0x80000000	; http://msdn.microsoft.com/en-us/library/aa393286.aspx
		HKEY_CURRENT_USER	:= 0x80000001
		HKEY_LOCAL_MACHINE	:= 0x80000002
		HKEY_USERS			:= 0x80000003
		HKEY_CURRENT_CONFIG	:= 0x80000005
		HKEY_DYN_DATA		:= 0x80000006
		HKCR := HKEY_CLASSES_ROOT
		HKCU := HKEY_CURRENT_USER
		HKLM := HKEY_LOCAL_MACHINE
		HKU	 := HKEY_USERS
		HKCC := HKEY_CURRENT_CONFIG
		
		REG_NONE 				:= 0	; http://msdn.microsoft.com/en-us/library/ms724884.aspx
		REG_SZ 					:= 1
		REG_EXPAND_SZ			:= 2
		REG_BINARY				:= 3
		REG_DWORD				:= 4
		REG_DWORD_BIG_ENDIAN	:= 5
		REG_LINK				:= 6
		REG_MULTI_SZ			:= 7
		REG_RESOURCE_LIST		:= 8

		KEY_QUERY_VALUE := 0x0001	; http://msdn.microsoft.com/en-us/library/ms724878.aspx
		KEY_WOW64_64KEY := 0x0100	; http://msdn.microsoft.com/en-gb/library/aa384129.aspx (do not redirect to Wow6432Node on 64-bit machines)
		KEY_SET_VALUE	:= 0x0002
		KEY_WRITE		:= 0x20006
		
		myhKey := %sRootKey%			; pick out value (0x8000000x) from list of HKEY_xx vars
		myValueType := %sValueType%		; pick out value (0-8) from list of REG_SZ,REG_DWORD etc. types
		IfEqual,myhKey,, {		; Error - Invalid root key
			ErrorLevel := 3
			return ErrorLevel
		}
		IfEqual,myValueType,, {	; Error - Invalid value type
			ErrorLevel := 2
			return ErrorLevel
		}
		
		RegAccessRight := KEY_QUERY_VALUE + KEY_WOW64_64KEY + KEY_WRITE
		
		DllCall("Advapi32.dll\RegCreateKeyExA", "uint", myhKey, "str", sKeyName, "uint", 0, "uint", 0, "uint", 0, "uint", RegAccessRight, "uint", 0, "uint*", hKey)	; open/create key
		If (myValueType == REG_SZ or myValueType == REG_EXPAND_SZ) {
			vValueSize := StrLen(sValue) + 1
			DllCall("Advapi32.dll\RegSetValueExA", "uint", hKey, "str", sValueName, "uint", 0, "uint", myValueType, "str", sValue, "uint", vValueSize)	; write string
		} Else If (myValueType == REG_DWORD) {
			vValueSize := 4
			DllCall("Advapi32.dll\RegSetValueExA", "uint", hKey, "str", sValueName, "uint", 0, "uint", myValueType, "uint*", sValue, "uint", vValueSize)	; write dword
		} Else {		; REG_MULTI_SZ, REG_BINARY, or other unsupported value type
			ErrorLevel := 2
		}
		DllCall("Advapi32.dll\RegCloseKey", "uint", hKey)
		return ErrorLevel
	}

	ExtractData(pointer) {  ; http://www.autohotkey.com/forum/viewtopic.php?p=91578#91578 SKAN
		Loop {
				errorLevel := ( pointer+(A_Index-1) )
				Asc := *( errorLevel )
				IfEqual, Asc, 0, Break ; Break if NULL Character
				String := String . Chr(Asc)
			}
		Return String
	}

	; --------------------------------------------------------------------------------------------------------------------------------------

}

/*
 ####   ####    ###   #   #    #    #####  #####         #####  #   #  #   #   ###   #####   ###    ###   #   #   ###
 #   #  #   #    #    #   #   # #     #    #             #      #   #  #   #  #   #    #      #    #   #  #   #  #   #
 #   #  #   #    #    #   #  #   #    #    #             #      #   #  ##  #  #        #      #    #   #  ##  #  #
 ####   ####     #     # #   #   #    #    ####          ####   #   #  # # #  #        #      #    #   #  # # #   ###
 #      # #      #     # #   #####    #    #             #      #   #  #  ##  #        #      #    #   #  #  ##      #
 #      #  #     #     # #   #   #    #    #             #      #   #  #   #  #   #    #      #    #   #  #   #  #   #
 #      #   #   ###     #    #   #    #    #####         #       ###   #   #   ###     #     ###    ###   #   #   ###

There be dragons ahead!
There are no guarantees that these functions will remain named the same, so it is not advised to reference any stuff in here in your script.
If you need access to stuff in here, request an update to the library!
*/

Class ADHD_Private {
	; PRIVATE Class - Script Authors should NOT be directly accessing stuff in here

	; Constructor - init default values
	__New(){
		this.core_version := "3.3.4"

		this.instantiated := 1
		this.hotkeys_enabled := 0
		this.hotkey_list := []									; list of all possible hotkeys
		this.defined_hotkeys := {limit_app_on: 0, limit_app: "", hotkey_cache: []}								; currently defined hotkeys
		this.author_macro_name := "An ADHD Macro"				; Change this to your macro name
		this.author_version := 1.0								; The version number of your script
		this.author_name := "Unknown"							; Your Name
		this.author_link := ""
		
		this.limit_app := ""
		this.gui_w := 450
		this.gui_h := 200
		this.guis_used := 3					; The number of GUIs used by ADHD. 1 = Main GUI, 2 = Debug Window, 3 = Bind popup
		
		this.ini_version := 1
		this.write_version := 1				; set to 0 to stop writing of version to INI file on exit
		
		; Hooks
		this.events := {}
		;this.events.profile_load := ""
		this.events.option_changed := ""
		this.events.tab_changed := ""
		this.events.on_exit := ""
		this.events.app_active := ""		; When the "Limited" app comes into focus
		this.events.app_inactive := ""		; When the "Limited" app goes out of focus
		this.events.bind_mode_on := ""		; Bind mode started
		this.events.bind_mode_off := ""		; Bind Mode stopped
		this.events.functionality_toggled := ""		; Bind Mode stopped
		
		this.limit_app_w := -1				; Used for resolution change detection
		this.limit_app_h := -1
		this.limit_app_last_w := -1
		this.limit_app_last_h := -1
		this.tab_list := Array("Main")
		
		this.x64_warning := 1
		this.noaction_warning := 1
		; strip extension from end of script name for basis of INI name
		;this.ini_name := this.build_ini_name()
		this.build_ini_name()
		
		this.functionality_enabled := 1

		; Build list of "End Keys" for Input command
		this.EXTRA_KEY_LIST := "{Escape}"	; DO NOT REMOVE! - Used to quit binding
		; Standard non-printables
		this.EXTRA_KEY_LIST .= "{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}"
		this.EXTRA_KEY_LIST .= "{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BackSpace}{Pause}{Space}"
		; Numpad - Numlock ON
		this.EXTRA_KEY_LIST .= "{Numpad0}{Numpad1}{Numpad2}{Numpad3}{Numpad4}{Numpad5}{Numpad6}{Numpad7}{Numpad8}{Numpad9}{NumpadDot}{NumpadMult}{NumpadAdd}{NumpadSub}"
		; Numpad - Numlock OFF
		this.EXTRA_KEY_LIST .= "{NumpadIns}{NumpadEnd}{NumpadDown}{NumpadPgDn}{NumpadLeft}{NumpadClear}{NumpadRight}{NumpadHome}{NumpadUp}{NumpadPgUp}{NumpadDel}"
		; Numpad - Common
		this.EXTRA_KEY_LIST .= "{NumpadMult}{NumpadAdd}{NumpadSub}{NumpadDiv}{NumpadEnter}"
		; Stuff we may or may not want to trap
		;EXTRA_KEY_LIST .= "{Numlock}"
		this.EXTRA_KEY_LIST .= "{Capslock}"
		;EXTRA_KEY_LIST .= "{PrintScreen}"
		; Browser keys
		this.EXTRA_KEY_LIST .= "{Browser_Back}{Browser_Forward}{Browser_Refresh}{Browser_Stop}{Browser_Search}{Browser_Favorites}{Browser_Home}"
		; Media keys
		this.EXTRA_KEY_LIST .= "{Volume_Mute}{Volume_Down}{Volume_Up}{Media_Next}{Media_Prev}{Media_Stop}{Media_Play_Pause}"
		; App Keys
		this.EXTRA_KEY_LIST .= "{Launch_Mail}{Launch_Media}{Launch_App1}{Launch_App2}"

		this.BindMode := 0
		this.HKModifierState := {}	; The state of the modifiers at the end of the last detection sequence
		this.HKControlType := 0		; The kind of control that the last hotkey was. 0 = regular key, 1 = solitary modifier, 2 = mouse, 3 = joystick
		this.HKSecondaryInput := ""	; Set to button pressed if the last detected bind was a Mouse button, Joystick button or Solitary Modifier
		this.HKLastHotkey := 0			; Time that Escape was pressed to exit key binding. Used to determine if Escape is held (Clear binding)
	}

	/*
	  ###   #   #   ###          #   #                    #   ##      #
	   #    #   #    #           #   #                    #    #
	   #    ##  #    #           #   #   ###   # ##    ## #    #     ##    # ##    ## #
	   #    # # #    #           #####      #  ##  #  #  ##    #      #    ##  #  #  #
	   #    #  ##    #           #   #   ####  #   #  #   #    #      #    #   #   ##
	   #    #   #    #           #   #  #   #  #   #  #  ##    #      #    #   #  #
	  ###   #   #   ###          #   #   ####  #   #   ## #   ###    ###   #   #   ###
	                                                                              #   #
	                                                                               ###
	Functions to handle persistent data storage
	*/

	/*
	; Updates the settings file. If value is default, it deletes the setting to keep the file as tidy as possible
	update_ini(key, section, value, default){
		update_fn := this.asynch_update_ini.bind(this, key, section, value, default)
		SetTimer % update_fn, -0
	}
	*/

	/*
	; Asynchronously update ini file
	; If INI is stored on HDD which is powered down, this will stop script freezing when you change settings
	asynch_update_ini(key, section, value, default){
	*/
	; Updates the settings file. If value is default, it deletes the setting to keep the file as tidy as possible
	update_ini(key, section, value, default){
		if (value != default){
			; Only write the value if it differs from what is already written
			if (this.read_ini(key,section,-1) != value){
				IniWrite,  %value%, % this.ini_name, %section%, %key%
			}
		} else {
			; Only delete the value if there is already a value to delete
			if (this.read_ini(key,section,-1) != -1){
				IniDelete, % this.ini_name, %section%, %key%
			}
		}
	}
	
	read_ini(key,section,default){
		sleep 0
		ini := this.ini_name
		IniRead, out, %ini%, %section%, %key%, %default%
		return out
	}

	build_ini_name(){
		tmp := A_Scriptname
		Stringsplit, tmp, tmp,.
		ini_name := ""
		last := ""
		Loop, % tmp0
		{
			if (last != ""){
				if (ini_name != ""){
					ini_name := ini_name "."
				}
				ini_name := ini_name last
			}
			last := tmp%A_Index%
		}
		this.ini_name := ini_name ".ini"
		return
	}

	/*
	 ####            #                   #                    ###           #      #                                     #          ###           #      #
	 #   #                               #                   #   #          #      #                                     #         #   #          #      #
	 #   #  # ##    ##    #   #   ###   ####    ###          #       ###   ####   ####    ###   # ##    ###             #          #       ###   ####   ####    ###   # ##    ###
	 ####   ##  #    #    #   #      #   #     #   #         #      #   #   #      #     #   #  ##  #  #               #            ###   #   #   #      #     #   #  ##  #  #
	 #      #        #     # #    ####   #     #####         #  ##  #####   #      #     #####  #       ###           #                #  #####   #      #     #####  #       ###
	 #      #        #     # #   #   #   #  #  #             #   #  #       #  #   #  #  #      #          #         #             #   #  #       #  #   #  #  #      #          #
	 #      #       ###     #     ####    ##    ###           ###    ###     ##     ##    ###   #      ####          #              ###    ###     ##     ##    ###   #      ####
	Private versions of getters and setters.
	A bit lazy, but no biggie
	*/

	; Sets the INI version to be written out.
	config_ini_version(ver){
		this.ini_version := ver
	}

	get_macro_name(){
		return this.author_macro_name
	}
	
	limit_app_get_size(){
		return {w: this.limit_app_w, h:this.limit_app_h}
	}
	
	limit_app_get_last_size(){
		return {w: this.limit_app_last_w, h:this.limit_app_last_h}	
	}
	
	limit_app_is_active(){
		if (this.app_act_curr){
			return true
		} else {
			return false
		}
	}

	get_gui_h(){
		return this.gui_h
	}
	
	get_gui_w(){
		return this.gui_w
	}
	
	get_limit_app_on(){
		global adhd_limit_application_on
		;Gets the state of the Limit App checkbox
		return adhd_limit_application_on
	}
	
	get_limit_app(){
		global adhd_limit_application
		;Gets the state of the Limit App checkbox
		return adhd_limit_application
	}
	
	/*
	 #   #             #          #                                  #       #      ##     #                   #       #
	 #   #             #          #                                  #             #  #                        #
	 #   #  # ##    ## #   ###   ####    ###          # ##    ###   ####    ##     #      ##     ###    ###   ####    ##     ###   # ##
	 #   #  ##  #  #  ##      #   #     #   #         ##  #  #   #   #       #    ####     #    #   #      #   #       #    #   #  ##  #
	 #   #  ##  #  #   #   ####   #     #####         #   #  #   #   #       #     #       #    #       ####   #       #    #   #  #   #
	 #   #  # ##   #  ##  #   #   #  #  #             #   #  #   #   #  #    #     #       #    #   #  #   #   #  #    #    #   #  #   #
	  ###   #       ## #   ####    ##    ###          #   #   ###     ##    ###    #      ###    ###    ####    ##    ###    ###   #   #
	        #
	        #
	*/

	; Attempts to read a version from a text file at a specified URL
	get_ver(url){
		if (url == ""){
			return 0
		}
		/*
		pwhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		pwhr.Open("GET",url) 
		pwhr.Send()
		ret := pwhr.ResponseText
		
		; Cater for 404s etc
		if (InStr(ret, "<html>")){
			return 0
		}		
		*/
		ret := this.download_to_string(url)
		out := {}
		
		Loop, Parse, ret, `n`r, %A_Space%%A_Tab%
		{
			c := SubStr(A_LoopField, 1, 1)
			if (c="[")
				;key := SubStr(A_LoopField, 2, -1)
				continue
			else if (c=";")
				continue
			else {
				p := InStr(A_LoopField, "=")
				if p {
					k := SubStr(A_LoopField, 1, p-1)
					try {
						out[%k%] := SubStr(A_LoopField, p+1)
					} catch {
						return 0
					}
				}
			}
		}
		if (out[version] == ""){
			return 0
		}
		return out[version]
	}

	download_to_string(url, encoding = "utf-8")	{
		; Code by Bentschi, from http://ahkscript.org/boards/viewtopic.php?f=6&t=3291#p16243
	    static a := "AutoHotkey/" A_AhkVersion
	    if (!DllCall("LoadLibrary", "str", "wininet") || !(h := DllCall("wininet\InternetOpen", "str", a, "uint", 1, "ptr", 0, "ptr", 0, "uint", 0, "ptr")))
	        return 0
	    c := s := 0, o := ""
	    if (f := DllCall("wininet\InternetOpenUrl", "ptr", h, "str", url, "ptr", 0, "uint", 0, "uint", 0x80003000, "ptr", 0, "ptr"))
	    {
	        while (DllCall("wininet\InternetQueryDataAvailable", "ptr", f, "uint*", s, "uint", 0, "ptr", 0) && s > 0)
	        {
	            VarSetCapacity(b, s, 0)
	            DllCall("wininet\InternetReadFile", "ptr", f, "ptr", &b, "uint", s, "uint*", r)
	            o .= StrGet(&b, r >> (encoding = "utf-16" || encoding = "cp1200"), encoding)
	        }
	        DllCall("wininet\InternetCloseHandle", "ptr", f)
	    }
	    DllCall("wininet\InternetCloseHandle", "ptr", h)
	    return o
	}

	; Semantic version comparison from http://www.autohotkey.com/board/topic/81789-semverahk-compare-version-numbers/
	semver_validate(version){
		return !!RegExMatch(version, "^(\d+)\.(\d+)\.(\d+)(\-([0-9A-Za-z\-]+\.)*[0-9A-Za-z\-]+)?(\+([0-9A-Za-z\-]+\.)*[0-9A-Za-z\-]+)?$")
	}

	semver_parts(version, byRef out_major, byRef out_minor, byRef out_patch, byRef out_prerelease, byRef out_build){
		return !!RegExMatch(version, "^(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)(\-(?P<prerelease>([0-9A-Za-z\-]+\.)*([0-9A-Za-z\-]+)))?(\+?(?P<build>([0-9A-Za-z\-]+\.)*([0-9A-Za-z\-]+)))?$", out_)
	}

	semver_compare(version1, version2){
		if (!this.semver_parts(version1, maj1, min1, pat1, pre1, bld1))
			throw Exception("Invalid version: " version1)
		if (!this.semver_parts(version2, maj2, min2, pat2, pre2, bld2))
			throw Exception("Invalid version: " version2)
	 
		for each, part in ["maj", "min", "pat"]
		{
			%part%1 += 0, %part%2 += 0
			if (%part%1 < %part%2)
				return -1
			else if (%part%1 > %part%2)
				return +1
		}
	 
		for each, part in ["pre", "bld"] ; { "pre" : 1, "bld" : -1 }
		{
			if (%part%1 && %part%2)
			{
				StringSplit part1_, %part%1, .
				StringSplit part2_, %part%2, .
				Loop % part1_0 < part2_0 ? part1_0 : part2_0 ; use the smaller amount of parts
				{
					if part1_%A_Index% is digit
					{
						if part2_%A_Index% is digit ; both are numeric: compare numerically
						{
							part1_%A_Index% += 0, part2_%A_Index% += 0
							if (part1_%A_Index% < part2_%A_Index%)
								return -1
							else if (part1_%A_Index% > part2_%A_Index%)
								return +1
							continue
						}
					}
					; at least one is non-numeric: compare by characters
					if (part1_%A_Index% < part2_%A_Index%)
						return -1
					else if (part1_%A_Index% > part2_%A_Index%)
						return +1
				}
				; all compared parts were equal - the longer one wins
				if (part1_0 < part2_0)
					return -1
				else if (part1_0 > part2_0)
					return +1
			}
			else if (!%part%1 && %part%2) ; only version2 has prerelease -> version1 is higher
				return (part == "pre") ? +1 : -1
			else if (!%part%2 && %part%1) ; only version1 has prerelease -> it is smaller
				return (part == "pre") ? -1 : +1
		}
		return 0
	}

	; pad version numbers to have 3 numbers (x.y.z) at a minimum.
	pad_version(ver){
		stringsplit, ver, ver,.

		if (ver0 < 3){
			ctr := 3-ver0
			Loop, %ctr% {
				ver .= ".0"
			}
		}
		return ver
	}

	; Create tooltips for core script and author script versions
	version_tooltip_create(diff,rem,loc){
		tt := ""

		if (diff == 0){
			tt .= "Same (" loc ")"
		} else if (diff > 0){
			tt .= "Newer (" rem ", you have " loc ")"
		} else {
			tt .= "Older (" rem ", you have " loc ")"
		}

		return tt
	}

	/*
	 #####                        #            #   #                    #   ##      #
	 #                            #            #   #                    #    #
	 #      #   #   ###   # ##   ####          #   #   ###   # ##    ## #    #     ##    # ##    ## #
	 ####   #   #  #   #  ##  #   #            #####      #  ##  #  #  ##    #      #    ##  #  #  #
	 #       # #   #####  #   #   #            #   #   ####  #   #  #   #    #      #    #   #   ##
	 #       # #   #      #   #   #  #         #   #  #   #  #   #  #  ##    #      #    #   #  #
	 #####    #     ###   #   #    ##          #   #   ####  #   #   ## #   ###    ###   #   #   ###
	                                                                                            #   #
	                                                                                             ###
	*/

	tab_changed(){
		Gui, Submit, NoHide
		this.fire_event(this.events.tab_changed)
		return
	}

	; Called on app exit
	exit_app(){	
		Gui, +Hwndgui_id
		WinGetPos, gui_x, gui_y,,, ahk_id %gui_id%
		ini := this.ini_name
		if (this.read_ini("adhd_gui_x","Settings", -1) != gui_x && gui_x >= 0){
			IniWrite, %gui_x%, %ini%, Settings, adhd_gui_x
		}
		if (this.read_ini("gui_y","Settings", -1) != gui_y && gui_x >= 0){
			IniWrite, %gui_y%, %ini%, Settings, adhd_gui_y
		}

		if (this.write_version){
			tmp := this.ini_version
			IniWrite, %tmp%, %ini%, Settings, adhd_ini_version
		}
		
		this.fire_event(this.events.on_exit)
		ExitApp
		return
	}

	; Fires an event.
	; Basically executes a string as a function
	; Checks string is not empty first
	fire_event(event){
		if (event && event != ""){
			%event%()
		}
	}
	
	/*
	  ###   #   #   ###                                                                          #
	 #   #  #   #    #                                                                           #
	 #      #   #    #           ## #    ###   # ##    ###    ## #   ###   ## #    ###   # ##   ####
	 #      #   #    #           # # #      #  ##  #      #  #  #   #   #  # # #  #   #  ##  #   #
	 #  ##  #   #    #           # # #   ####  #   #   ####   ##    #####  # # #  #####  #   #   #
	 #   #  #   #    #           # # #  #   #  #   #  #   #  #      #      # # #  #      #   #   #  #
	  ###    ###    ###          #   #   ####  #   #   ####   ###    ###   #   #   ###   #   #    ##
	                                                         #   #
	                                                          ###
	*/

	; Converts a Control name (eg DropDownList) into the parameter passed to GuiControl to set that value (eg ChooseString)
	control_name_to_set_method(name){
		if (name == "DropDownList"){
			return "ChooseString"
		} else {
			return ""
		}
	}

	; Add and remove glabel is useful because:
	; When you use GuiControl to set the contents of an edit...
	; .. it's glabel is fired.
	; So remove glabel, set editbox value, re-add glabel to solve
	add_glabel(ctrl){
		GuiControl, +gadhd_option_changed, %ctrl%
	}

	remove_glabel(ctrl){
		GuiControl, -g, %ctrl%
	}

	set_profile_statusbar(){
		cp := this.current_profile
		GuiControl,,CurrentProfile,%cp%
	}

	/*
	 #   #          #     #                           #   #                    #   ##      #
	 #   #          #     #                           #   #                    #    #
	 #   #   ###   ####   #   #   ###   #   #         #   #   ###   # ##    ## #    #     ##    # ##    ## #
	 #####  #   #   #     #  #   #   #  #   #         #####      #  ##  #  #  ##    #      #    ##  #  #  #
	 #   #  #   #   #     ###    #####  #  ##         #   #   ####  #   #  #   #    #      #    #   #   ##
	 #   #  #   #   #  #  #  #   #       ## #         #   #  #   #  #   #  #  ##    #      #    #   #  #
	 #   #   ###     ##   #   #   ###       #         #   #   ####  #   #   ## #   ###    ###   #   #   ###
	                                    #   #                                                          #   #
	                                     ###                                                            ###
	*/

	enable_hotkeys(){
		global adhd_limit_application
		global adhd_limit_application_on

		if (!this.hotkeys_enabled){
			this.hotkeys_enabled := 1
			; ToDo: Should not submit gui here, triggering save...
			;this.debug("enable_hotkeys")
			
			Gui, Submit, NoHide
			this.defined_hotkeys.hotkey_cache := []
			cache_idx := 1

			this.joystick_lookup := {}

			Loop % this.hotkey_list.MaxIndex(){
				name := this.hotkey_index_to_name(A_Index)
				if (this.hotkey_mappings[name].modified != ""){
					;msgbox % this.hotkey_mappings[name].modified " -> " this.hotkey_list[A_Index,"subroutine"]
					hotkey_string := this.hotkey_mappings[name].modified
					hotkey_subroutine := this.hotkey_list[A_Index,"subroutine"]

					; Apply "Limit app" option
					if (adhd_limit_application_on == 1 && adhd_limit_application !=""){
						limit_app_on := 1
						; Enable Limit Application for all subsequently declared hotkeys
						Hotkey, IfWinActive, ahk_class %adhd_limit_application%
					} else {
						limit_app_on := 0
						; Disable Limit Application for all subsequently declared hotkeys
						Hotkey, IfWinActive
					}

					; Bind down action of hotkey
					prefix := ""
					if (this.hotkey_mappings[name].passthru){
						prefix .= "~"
					}
					if (this.hotkey_mappings[name].wild){
						prefix .= "*"
					}

					; If Joystick type, redirect to joystick_handler
					if (this.hotkey_mappings[name].type == 3){
						hotkey_subroutine := "adhd_joystick_handler"
						this.joystick_lookup[hotkey_string] := name
					}
					Hotkey, %prefix%%hotkey_string% , %hotkey_subroutine%, On
					
					this.debug("Adding hotkey: " prefix hotkey_string ", sub: " hotkey_subroutine ", wild: " this.hotkey_mappings[name].wild ", passthru: " this.hotkey_mappings[name].passthru)

					this.defined_hotkeys.hotkey_cache[cache_idx] := {string: prefix hotkey_string, noprefix: hotkey_string, subroutine: hotkey_subroutine}
					cache_idx++
					this.defined_hotkeys.limit_app_on := limit_app_on
					this.defined_hotkeys.limit_app := adhd_limit_application

					if (IsLabel(hotkey_subroutine "Up") && this.hotkey_mappings[name].type != 3){
						; Bind up action of hotkey
						;Hotkey, %prefix%%hotkey_string% up , %hotkey_subroutine%Up
						Hotkey, %prefix%%hotkey_string% up , %hotkey_subroutine%Up, On
					}

					; Disable Limit Application for all subsequently declared hotkeys
					Hotkey, IfWinActive
					; ToDo: Up event does not fire for wheel "buttons" - send dupe event or something?

				}
			}
			this.enable_heartbeat()
		}
	}

	disable_hotkeys(mode){
		global adhd_limit_application
		global adhd_limit_application_on

		if (this.hotkeys_enabled){
			this.hotkeys_enabled := 0
			;this.debug("disable_hotkeys")
			this.disable_heartbeat()

			; If "Functionality Toggle" is defined and 1 passed as mode, do not disable the last hotkey (Functionality Toggle)
			max := this.defined_hotkeys.hotkey_cache.MaxIndex()
			
			limit_app_on := this.defined_hotkeys.limit_app_on
			limit_app := this.defined_hotkeys.limit_app

			; If there are entries to be processed...
			if (max){
				; Set Limit App mode
				if (limit_app_on){
					Hotkey, IfWinActive, ahk_class %limit_app%
				} else {
					Hotkey, IfWinActive
				}
			}

			Loop % max {
				str := this.defined_hotkeys.hotkey_cache[A_Index].string
				sub := this.defined_hotkeys.hotkey_cache[A_Index].subroutine
				
				this.debug("Removing hotkey: " str ", sub: " sub)

				if (mode && (this.defined_hotkeys.hotkey_cache[A_Index].subroutine = "adhd_functionality_toggle" || this.joystick_lookup[this.defined_hotkeys.hotkey_cache[A_Index].noprefix] == "adhd_functionality_toggle")){
					continue
				}
				;if (this.hotkey_mappings[sub].type == 3){
				;	this.joystick_lookup.remove(hotkey_string)
				;}

				;Hotkey, %str%, %sub%, Off
				Hotkey, %str%, Off
				if (IsLabel(sub "Up") && this.hotkey_mappings[sub].type != 3){
					; Remove up action of hotkey
					;Hotkey, %str% up , %sub%Up, Off
					Hotkey, %str% up , Off
				}
			}

			Hotkey, IfWinActive

		}
		return
	}

	; AHK does not support Up events for joystick hotkeys - eg the hotkey "1Joy1 Up" fires on button down.
	; Intercept joystick button mappings, and simulate up event.
	joystick_handler(){
		hotkey_string := this.strip_prefix(A_ThisHotkey)
		hotkey_subroutine := this.joystick_lookup[hotkey_string]
		Gosub % hotkey_subroutine

		while(GetKeyState(hotkey_string)){
			; do nothing
		}

		if (IsLabel(hotkey_subroutine "Up")){
			Gosub % hotkey_subroutine "Up"
		}
	}

	; Joystick button was pressed at bind time.
	; Set appropriate flags and quit the escape routine
	bind_joystick_button(){
		this.HKControlType := 3

		; Dirty bodge fix due to AHK limitation	
		this.HKSecondaryInput := this.strip_prefix(A_ThisHotkey)

		; Send escape to quit bind routine - bind routine will inspect flags.
		Send {Escape}
	}

	; Removes (clears) a hotkey - called at end of a timer, not a general purpose functions
	delete_hotkey(){
		soundbeep
		this.disable_hotkeys()
		name := this.hotkey_index_to_name(this.HKLastHotkey)
		this.hotkey_mappings[name].modified := ""
		this.hotkey_mappings[name].type := 0
		
		this.option_changed()
		return
	}

	; For some games, they will not let you autofire if the triggering key is still held down...
	; even if the triggering key is not the key sent and does nothing in the game!
	; Often a workaround is to send a keyup of the triggering key
	; Calling send_keyup_on_press() in an action will cause this to happen
	send_keyup_on_press(sub,mod){
		tmp := this.hotkey_mappings[sub][mod] " up"
		Send {%tmp%}
	}

	; Detects key combinations
	set_binding(ctrlnum){
		global adhd_limit_application_on

		this.fire_event(this.events.bind_mode_on)

		; init vars
		this.HKControlType := 0
		this.HKModifierState := {ctrl: 0, alt: 0, shift: 0, win: 0}

		; Disable existing hotkeys
		this.disable_hotkeys(0)

		; Enable Joystick detection hotkeys
		this.joystick_detection(1)

		; Start Bind Mode - this starts detection for mouse buttons and modifier keys
		this.BindMode := 1

		; Turn off caps lock if on
		caps_state := GetKeyState("Capslock", "T") 
		if (caps_state){
			SetCapsLockState, Off
		}


		; Show instructions
		Gui, 3:Show

		outhk := ""

		EXTRA_KEY_LIST := this.EXTRA_KEY_LIST

		Input, detectedkey, L1 M, %EXTRA_KEY_LIST%

		; Hide Instructions
		Gui, 3:Submit

		if (substr(ErrorLevel,1,7) == "EndKey:"){
			; A "Special" (Non-printable) key was pressed
			tmp := substr(ErrorLevel,8)
			detectedkey := tmp
			if (tmp == "Escape"){
				; Detection ended by Escape
				if (this.HKControlType > 0){
					; The Escape key was sent because a special button was used
					detectedkey := this.HKSecondaryInput
				} else {
					detectedkey := ""
					; Start listening to key up event for Escape, to see if it was held
					this.HKLastHotkey := ctrlnum

					hotkey, Escape up, adhd_escape_released, ON
					SetTimer, adhd_delete_hotkey, 1000
				}
			}
		}

		; Stop listening to mouse, keyboard etc
		this.BindMode := 0

		; turn caps Lock back on if it was on
		if (caps_state){
			SetCapsLockState, On
		}

		this.joystick_detection(0)

		;msgbox % detectedkey "`n" this.HKModifierState.ctrl
		;msgbox % detectedkey "`n" this.HKControlType "`n" this.HKSecondaryInput

		; Process results

		modct := this.current_modifier_count()

		if (detectedkey && modct && this.HKControlType == 3){
			msgbox ,,Error, Modifiers (Ctrl, Alt, Shift, Win) are currently not supported with Joystick buttons.
			detectedkey := ""
		}

		if (detectedkey){
			if ( (adhd_limit_application_on == 0) && (detectedkey = "lbutton" || detectedkey = "rbutton") ) {
				GuiControl,, adhd_hk_passthru_%ctrlnum%, 1
				GuiControl, Disable, adhd_hk_passthru_%ctrlnum%
			} else {
				GuiControl, Enable, adhd_hk_passthru_%ctrlnum%
			}
			clash := 0
			hk := this.build_hotkey_string(detectedkey,this.HKControlType)
			clash := 0
			Loop % this.hotkey_list.MaxIndex(){
				if (A_Index == ctrlnum){
					continue
				}

				name := this.hotkey_index_to_name(A_Index)
				if (this.hotkey_mappings[name].modified != "" && this.strip_prefix(this.hotkey_mappings[name].modified) == this.strip_prefix(hk)){
					clash := 1
				}
			}
			if (clash){
				msgbox You cannot bind the same hotkey to two different actions. Aborting...
			} else {
				this.hotkey_mappings[this.hotkey_index_to_name(ctrlnum)].modified := hk
				this.hotkey_mappings[this.hotkey_index_to_name(ctrlnum)].type := this.HKControlType
	
			}
			; Rebuild rest of hotkey object, save settings etc
			this.option_changed()
		} else {
			; Escape was pressed - resotre original hotkey, if any
			this.enable_hotkeys()
		}
		this.fire_event(this.events.bind_mode_off)
		return

	}

	; Adds / removes joystick hoykeys to enable detection of joystick buttons
	joystick_detection(mode){
		/*
		if (mode){
			mode := "ON"
		} else {
			mode := "OFF"
		}
		*/
		;Hotkey, IfWinActive
		Loop , 16 {
			stickid := A_Index
			Loop, 32 {
				buttonid := A_Index
				if (mode){
					hotkey, %stickid%Joy%buttonid%, adhd_bind_joystick_button, On
				} else {
					hotkey, %stickid%Joy%buttonid%, Off
				}
			}
		}
	}

	; Builds a Human-Readable form of a Hotkey string (eg "^C" -> "CTRL + C")
	build_hotkey_name(hk,ctrltype){
		outstr := ""
		modctr := 0
		stringupper, hk, hk

		Loop % strlen(hk) {
			chr := substr(hk,1,1)
			mod := 0

			if (chr == "^"){
				; Ctrl
				mod := "CTRL"
				modctr++
			} else if (chr == "!"){
				; Alt
				mod := "ALT"
				modctr++
			} else if (chr == "+"){
				; Shift
				mod := "SHIFT"
				modctr++
			} else if (chr == "#"){
				; Win
				mod := "WIN"
				modctr++
			} else {
				break
			}
			if (mod){
				if (modctr > 1){
					outstr .= " + "
				}
				outstr .= mod
				; shift character out
				hk := substr(hk,2)
			}
		}
		if (modctr){
			outstr .= " + "
		}

		if (ctrltype == 1){
			; Solitary Modifiers
			pfx := substr(hk,1,1)
			if (pfx == "L"){
				outstr .= "LEFT "
			} else {
				outstr .= "RIGHT "
			}
			outstr .= substr(hk,2)
		} else if (ctrltype == 2){
			; Mouse Buttons
			if (hk == "LBUTTON") {
				outstr .= "LEFT MOUSE"
			} else if (hk == "RBUTTON") {
				outstr .= "RIGHT MOUSE"
			} else if (hk == "MBUTTON") {
				outstr .= "MIDDLE MOUSE"
			} else if (hk == "XBUTTON1") {
				outstr .= "MOUSE THUMB 1"
			} else if (hk == "XBUTTON2") {
				outstr .= "MOUSE THUMB 2"
			} else if (hk == "WHEELUP") {
				outstr .= "MOUSE WHEEL U"
			} else if (hk == "WHEELDOWN") {
				outstr .= "MOUSE WHEEL D"
			} else if (hk == "WHEELLEFT") {
				outstr .= "MOUSE WHEEL L"
			} else if (hk == "WHEELRIGHT") {
				outstr .= "MOUSE WHEEL R"
			}
		} else if (ctrltype == 3){
			; Joystick Buttons
			pos := instr(hk,"JOY")
			id := substr(hk,1,pos-1)
			button := substr(hk,5)
			outstr .= "JOYSTICK " id " BTN " button
		} else {
			; Keyboard Keys
			tmp := instr(hk,"NUMPAD")
			if (tmp){
				outstr .= "NUMPAD " substr(hk,7)
			} else {
				; Replace underscores with spaces (In case of key name like MEDIA_PLAY_PAUSE)
				StringReplace, hk, hk, _ , %A_SPACE%, All
				outstr .= hk
			}
		}
		return outstr
	}

	; Builds an AHK String (eg "^c" for CTRL + C) from the last detected hotkey
	build_hotkey_string(str, type := 0){

		outhk := ""
		modct := this.current_modifier_count()

		if (type == 1){
			; Solitary modifier key used (eg Left / Right Alt)
			outhk := str
		} else {
			if (modct){
				; Modifiers used in combination with something else - List modifiers in a specific order
				modifiers := ["CTRL","ALT","SHIFT","WIN"]

				Loop, 4 {
					key := modifiers[A_Index]
					value := this.HKModifierState[modifiers[A_Index]]
					if (value){
						if (key == "CTRL"){
							outhk .= "^"
						} else if (key == "ALT"){
							outhk .= "!"
						} else if (key == "SHIFT"){
							outhk .= "+"
						} else if (key == "WIN"){
							outhk .= "#"
						}
					}
				}
			}
			; Modifiers etc processed, complete the string
			outhk .= str
		}

		return outhk
	}

	; Sets the state of the HKModifierState object to reflect the state of the modifier keys
	set_modifier(hk,state){
		if (hk == "lctrl" || hk == "rctrl"){
			this.HKModifierState.ctrl := state
		} else if (hk == "lalt" || hk == "ralt"){
			this.HKModifierState.alt := state
		} else if (hk == "lshift" || hk == "rshift"){
			this.HKModifierState.shift := state
		} else if (hk == "lwin" || hk == "rwin"){
			this.HKModifierState.win := state
		}
		return
	}

	; Counts how many modifier keys are currently held
	current_modifier_count(){
		return this.HKModifierState.ctrl + this.HKModifierState.alt + this.HKModifierState.shift  + this.HKModifierState.win
	}

	hotkey_index_to_name(idx){
		return this.hotkey_list[idx,"subroutine"]
	}

	; Removes ~ * etc prefixes (But NOT modifiers!) from a hotkey object for comparison
	strip_prefix(hk){
		Loop {
			chr := substr(hk,1,1)
			if (chr == "~" || chr == "*" || chr == "$"){
				hk := substr(hk,2)
			} else {
				break
			}
		}
		return hk
	}

	; Removes ^ ! + # modifiers from a hotkey object for comparison
	strip_modifiers(hk){
		hk := this.strip_prefix(hk)

		Loop {
			chr := substr(hk,1,1)
			if (chr == "^" || chr == "!" || chr == "+" || chr == "#"){
				hk := substr(hk,2)
			} else {
				break
			}
		}
		return hk
	}

	; Turns on or off all hotkeys
	functionality_toggle(){
		if (this.functionality_enabled){
			this.functionality_enabled := 0
			this.disable_hotkeys(1)
			this.fire_event(this.events.functionality_toggled)
			soundbeep, 400, 200
			; pass 1 as a parameter to disable_hotkeys to tell it to not disable functionality toggle
		} else {
			this.functionality_enabled := 1
			this.enable_hotkeys()
			this.fire_event(this.events.functionality_toggled)
			soundbeep, 800, 200
		}
	}
	
	/*
	 ####                   ##     #     ##                  #                        #   ##      #
	 #   #                 #  #           #                  #                        #    #
	 #   #  # ##    ###    #      ##      #     ###          # ##    ###   # ##    ## #    #     ##    # ##    ## #
	 ####   ##  #  #   #  ####     #      #    #   #         ##  #      #  ##  #  #  ##    #      #    ##  #  #  #
	 #      #      #   #   #       #      #    #####         #   #   ####  #   #  #   #    #      #    #   #   ##
	 #      #      #   #   #       #      #    #             #   #  #   #  #   #  #  ##    #      #    #   #  #
	 #      #       ###    #      ###    ###    ###          #   #   ####  #   #   ## #   ###    ###   #   #   ###
	                                                                                                          #   #
	                                                                                                           ###
	*/

	add_profile(name){
		global adhd_current_profile
		
		Loop, {
			if (name == ""){
				InputBox, name, Profile Name, Please enter a profile name
				if (ErrorLevel){
					return
				}
			}
			if (this.profile_unique(name)){
				break
			} else {
				msgbox Duplicate names are not allowed, please re-enter name.
				name := ""
			}
		}
		if (this.profile_list == ""){
			this.profile_list := name
		} else {
			this.profile_list := this.profile_list "|" name
		}
		pl := this.profile_list
		Sort, pl, D|
		this.profile_list := pl
		
		GuiControl,, adhd_current_profile, |Default||%pl%
		GuiControl,ChooseString, adhd_current_profile, %name%
		adhd_current_profile := name
		this.update_ini("adhd_profile_list", "Settings", this.profile_list, "")
		; Call profile load on a nonexistant profile to force settings to defaults and reset UI
		this.profile_changed()
		; No need to save - profile is default options

		return name
	}

	; Deletes a profile
	delete_profile(name, gotoprofile = "Default"){
		Global adhd_current_profile
		
		if (name != "Default"){
			pl := this.profile_list
			StringSplit, tmp, pl, |
			out := ""
			Loop, %tmp0%{
				if (tmp%a_index% != name){
					if (out != ""){
						out := out "|"
					}
					out := out tmp%a_index%
				}
			}
			pl := out
			this.profile_list := pl
			
			ini := this.ini_name
			IniDelete, %ini%, %name%
			this.update_ini("adhd_profile_list", "Settings", this.profile_list, "")		
			
			; Set new contents of list
			GuiControl,, adhd_current_profile, |Default|%pl%
			
			; Select the desired new current profile
			GuiControl, ChooseString, adhd_current_profile, %gotoprofile%
			
			; Trigger save
			Gui, Submit, NoHide
			
			this.profile_changed()
		}
		return
	}

	; Copies a profile
	duplicate_profile(name){
		global adhd_current_profile
		
		Loop, {
			; Blank name specified - prompt for name
			if (name == ""){
				InputBox, name, Profile Name, Please enter a profile name,,,,,,,,%adhd_current_profile%
				if (ErrorLevel){
					return
				}
			}
			if (this.profile_unique(name)){
				break
			} else {
				msgbox Duplicate names are not allowed, please re-enter name.
				name := ""
			}
		}
		; Create the new item in the profile list
		if (this.profile_list == ""){
			this.profile_list := name
		} else {
			this.profile_list := this.profile_list "|" name
		}
		pl := this.profile_list
		Sort, pl, D|
		this.profile_list := pl
		
		this.current_profile := name
		adhd_current_profile := name
		; Push the new list to the profile select box
		GuiControl,, adhd_current_profile, |Default||%pl%
		; Set the new profile to the currently selected item
		GuiControl,ChooseString, adhd_current_profile, %name%
		; Update the profile list in the INI
		this.update_ini("adhd_profile_list", "Settings", this.profile_list, "")
		
		; Firing option_changed saves the current state to the new profile name in the INI
		this.debug("duplicate_profile calling option_changed")
		this.option_changed()
		
		; Fire profile changed to update current profile in ini
		this.profile_changed()

		return name
	}

	; Renames a profile
	rename_profile(){
		old_prof := this.current_profile
		if (this.current_profile != "Default"){
			Loop {
				InputBox, new_prof, Profile Name, Please enter a new name,,,,,,,,%old_prof%
				if (ErrorLevel){
					return
				}
				if (this.current_profile == name){
					msgbox Please enter a different name.
					return
				}
				if (this.profile_unique(name)){
					break
				} else {
					msgbox Duplicate names are not allowed, please re-enter name.
				}
			}
			if (this.duplicate_profile(new_prof) != ""){
				this.delete_profile(old_prof,new_prof)
			}
		}
		return
	}

	; Checks if a profile name is unique
	profile_unique(name){
		tmp := this.profile_list
		Loop, parse, tmp, |
		{
			if (A_LoopField == name){
				return 0
			}
		}
		return 1
	}

	; aka load profile
	profile_changed(){
		global adhd_debug_mode

		global adhd_limit_application
		global adhd_limit_application_on
		global adhd_debug_window
		
		; Remove old bindings before changing profile
		;this.disable_hotkeys(1)
		this.disable_hotkeys(0)
		
		GuiControlGet,cp,,adhd_current_profile
		this.current_profile := cp
		this.debug("profile_changed - " this.current_profile)
		Gui, Submit, NoHide

		this.update_ini("adhd_current_profile", "Settings", this.current_profile,"")
		
		;SB_SetText("Current profile: " this.current_profile,2) 
		this.set_profile_statusbar() 
		
		this.hotkey_mappings := {}
		
		; Load hotkey bindings
		Loop, % this.hotkey_list.MaxIndex()
		{
			name := this.hotkey_index_to_name(A_Index)

			this.hotkey_mappings[this.hotkey_index_to_name(A_Index)] := {}
			this.hotkey_mappings[this.hotkey_index_to_name(A_Index)]["index"] := A_Index

			tmp := this.read_ini("adhd_hk_hotkey_" A_Index,this.current_profile,A_Space)
			this.hotkey_mappings[name].modified := tmp

			this.hotkey_mappings[name].unmodified := this.strip_prefix(this.hotkey_mappings[name].modified)

			tmp := this.read_ini("adhd_hk_wild_" A_Index,this.current_profile,0)
			this.hotkey_mappings[name].wild := tmp
			GuiControl,, adhd_hk_wild_%A_Index%, %tmp%

			tmp := this.read_ini("adhd_hk_passthru_" A_Index,this.current_profile,1)
			this.hotkey_mappings[name].passthru := tmp
			GuiControl,, adhd_hk_passthru_%A_Index%, %tmp%

			tmp := this.read_ini("adhd_hk_type_" A_Index,this.current_profile,0)
			this.hotkey_mappings[name].type := tmp

			tmp := this.build_hotkey_name(this.hotkey_mappings[name].modified, this.hotkey_mappings[name].type)
			GuiControl,, adhd_hk_hotkey_%A_Index%, %tmp%
		}
		
		; limit application name
		this.remove_glabel("adhd_limit_application")
		if (this.limit_app == "" || this.limit_app == null){
			this.limit_app := A_Space
		}
		tmp := this.read_ini("adhd_limit_app",this.current_profile,this.limit_app)
		GuiControl,, adhd_limit_application, %tmp%
		this.add_glabel("adhd_limit_application")
		
		; limit application status
		tmp := this.read_ini("adhd_limit_app_on",this.current_profile,0)
		GuiControl,, adhd_limit_application_on, %tmp%
		
		; Auto profile switching
		tmp := this.read_ini("adhd_auto_profile_switching","Settings",0)
		GuiControl,, adhd_auto_profile_switching, % tmp
		this.auto_profile_switching := tmp
		
		; Get author vars from ini
		Loop, % this.ini_vars.MaxIndex()
		{
			def := this.ini_vars[A_Index,3]
			if (def == ""){
				def := A_Space
			}
			key := this.ini_vars[A_Index,1]
			sm := this.control_name_to_set_method(this.ini_vars[A_Index,2])
			
			this.remove_glabel(key)
			tmp := this.read_ini(key,this.current_profile,def)
			GuiControl,%sm%, %key%, %tmp%
			this.add_glabel(key)
		}

		; Debug settings
		adhd_debug_mode := this.read_ini("adhd_debug_mode","Settings",0)
		GuiControl,, adhd_debug_mode, %adhd_debug_mode%
		
		adhd_debug_window := this.read_ini("adhd_debug_window","Settings",0)
		GuiControl,, adhd_debug_window, %adhd_debug_window%

		this.enable_hotkeys()
		
		; Fire the Author hook
		this.fire_event(this.events.option_changed)

		return
	}

	; aka save profile
	option_changed(){
		global adhd_debug_mode

		global adhd_limit_application
		global adhd_limit_application_on
		global adhd_debug_window
		global adhd_auto_profile_switching

		; Pull state of UI vars through
		Gui, Submit, NoHide

		; Disable Pass Thru boxes if not in Limit App mode and binding is lbutton or rbutton
		Loop % this.hotkey_list.MaxIndex(){
			name := this.hotkey_index_to_name(A_Index)
			if ( (adhd_limit_application_on == 0 ) && (this.hotkey_mappings[name].modified = "lbutton" || this.hotkey_mappings[name].modified = "rbutton") ){
				GuiControl,, adhd_hk_passthru_%A_Index%, 1
				GuiControl, Disable , adhd_hk_passthru_%A_Index%
			} else {
				GuiControl, Enable , adhd_hk_passthru_%A_Index%
			}
		}

		; If not starting up, update hotkeys
		if (this.starting_up != 1){
			;this.debug("option_changed - control: " A_guicontrol)

			; Disable existing hotkeys
			this.disable_hotkeys(0)
			
			; Hotkey bindings
			Loop % this.hotkey_list.MaxIndex(){
				name := this.hotkey_index_to_name(A_Index)

				; Hotkey
				this.update_ini("adhd_hk_hotkey_" A_Index, this.current_profile, this.hotkey_mappings[name].modified, "")
				tmp := this.build_hotkey_name(this.hotkey_mappings[name].modified, this.hotkey_mappings[name].type)
				GuiControl,, adhd_hk_hotkey_%A_Index%, %tmp%

				; Strip ~ * etc and store it in umnodified opbect.
				this.hotkey_mappings[name].unmodified := this.strip_prefix(this.hotkey_mappings[name].modified)

				; Type
				this.update_ini("adhd_hk_type_" A_Index, this.current_profile, this.hotkey_mappings[name].type,0)

				; Wild
				this.hotkey_mappings[name].wild := adhd_hk_wild_%A_Index%
				this.update_ini("adhd_hk_wild_" A_Index, this.current_profile, this.hotkey_mappings[name].wild, 0)

				; PassThru
				this.hotkey_mappings[name].passthru := adhd_hk_passthru_%A_Index%
				this.update_ini("adhd_hk_passthru_" A_Index, this.current_profile, this.hotkey_mappings[name].passthru, 1)
			}
			
			this.update_ini("adhd_profile_list", "Settings", this.profile_list,"")
			
			; Limit app
			if (this.limit_app == "" || this.limit_app == null){
				this.limit_app := A_Space
			}
			this.update_ini("adhd_limit_app", this.current_profile, adhd_limit_application, this.limit_app)
			;SB_SetText("Current profile: " this.current_profile, 2)
			this.set_profile_statusbar()
			
			; Limit app toggle
			this.update_ini("adhd_limit_app_on", this.current_profile, adhd_limit_application_on, 0)
			
			; App switch toggle (NOT per-profile!)
			this.update_ini("adhd_auto_profile_switching", "settings", adhd_auto_profile_switching, 0)
			
			; Add author vars to ini
			Loop, % this.ini_vars.MaxIndex()
			{
				tmp := this.ini_vars[A_Index,1]
				this.update_ini(tmp, this.current_profile, %tmp%, this.ini_vars[A_Index,3])
			}

			; Re-enable the hotkeys			
			this.enable_hotkeys()

			; Fire the Author hook
			this.fire_event(this.events.option_changed)
			
			; Debug settings
			this.update_ini("adhd_debug_mode", "settings", adhd_debug_mode, 0)
			this.update_ini("adhd_debug_window", "settings", adhd_debug_window, 0)
			
		} else {
			this.debug("ignoring option_changed - " A_Guicontrol)
		}
		; Build app-switching list
		this.app_list := {}
		pl := "default|" this.profile_list
		StringSplit, tmp, pl, |
		Loop, %tmp0%{
			limit_app := this.read_ini("adhd_limit_app_on",tmp%a_index%,0)
			if (limit_app){
				app := this.read_ini("adhd_limit_app",tmp%a_index%,-1)
				this.app_list[app] := tmp%a_index%
			}
		}

		return
	}

	/*
	 ####          #                           #####                        #       #
	  #  #         #                           #                            #
	  #  #   ###   # ##   #   #   ## #         #      #   #  # ##    ###   ####    ##     ###   # ##    ###
	  #  #  #   #  ##  #  #   #  #  #          ####   #   #  ##  #  #   #   #       #    #   #  ##  #  #
	  #  #  #####  #   #  #   #   ##           #      #   #  #   #  #       #       #    #   #  #   #   ###
	  #  #  #      ##  #  #  ##  #             #      #  ##  #   #  #   #   #  #    #    #   #  #   #      #
	 ####    ###   # ##    ## #   ###          #       ## #  #   #   ###     ##    ###    ###   #   #  ####
	                             #   #
	                              ###
	*/

	debug_window_change(){
		global adhd_debug_window
		
		gui, submit, nohide
		if (adhd_debug_window == 1){
			Gui, +Hwndgui_id
			WinGetPos, x, y,,, ahk_id %gui_id%
			y := y - 440
			w := this.gui_w
			Gui, 2:Show, x%x% y%y% w%w% h400, ADHD Debug Window
		} else {
			gui, 2:hide
		}
		; On startup do not call option_changed, we are just setting the window open or closed
		if (!this.starting_up){
			this.option_changed()
		}
		return
	}

	debug_change(){
		gui, 2:submit, nohide
		this.option_changed()
		return
	}

	debug(msg){
		global adhd_log_contents
		global adhd_debug_mode
		global adhd_log

		; If in debug mode, or starting up...
		if (adhd_debug_mode || this.starting_up){
			;adhd_log_contents := adhd_log_contents "* " msg "`n"
			adhd_log_contents := "* " msg "`n " adhd_log_contents
			if (this.debug_ready){
				guicontrol,2:,adhd_log_contents, % adhd_log_contents
				; Send CTRL-END to log control to make it scroll down.
				;controlsend,,^{End},ahk_id %adhd_log%
				gui, 2:submit, nohide
			}
		}
	}
	
	clear_log(){
		global adhd_log_contents
		adhd_log_contents := ""
		GuiControl,,adhd_log_contents,%adhd_log_contents%
	}

	/*
	   #                         ####           #                    #       #
	  # #                         #  #          #                    #
	 #   #  # ##   # ##           #  #   ###   ####    ###    ###   ####    ##     ###   # ##
	 #   #  ##  #  ##  #          #  #  #   #   #     #   #  #   #   #       #    #   #  ##  #
	 #####  ##  #  ##  #          #  #  #####   #     #####  #       #       #    #   #  #   #
	 #   #  # ##   # ##           #  #  #       #  #  #      #   #   #  #    #    #   #  #   #
	 #   #  #      #             ####    ###     ##    ###    ###     ##    ###    ###   #   #
	        #      #
	        #      #
	Functions to detect which app is the current app
	*/

	; App detection stuff
	enable_heartbeat(){
		this.debug("Enabling Heartbeat")
		global adhd_limit_application
		global adhd_limit_application_on
		
		if (adhd_limit_application_on == 1 && adhd_limit_application != ""){
			SetTimer, adhd_heartbeat, 500
		}
		return
	}

	disable_heartbeat(){
		this.debug("Disabling Heartbeat")
		SetTimer, adhd_heartbeat, Off
		return
	}

	heartbeat(){
		global adhd_limit_application
		; Check current app here.
		; Not used to enable or disable hotkeys, used to start or stop author macros etc
		IfWinActive, % "ahk_class " adhd_limit_application
		{
			WinGetPos,,,limit_w,limit_h, % "ahk_class " adhd_limit_application
			; ToDo: Bodged
			;WinGet, tmp, MinMax, % "ahk_class " adhd_limit_application
			;if (tmp == -1 || limit_h <= 30)
			if (limit_h <= 30){
				this.debug("Minimized app - not firing change")
				return
			}
			; If the size has changed since the last heartbeat
			if ( (this.limit_app_w != limit_w) || (this.limit_app_h != limit_h)){
				if ((this.limit_app_w == -1) && (this.limit_app_h == -1)){
					fire_change := 0
				} else {
					fire_change := 1
				}
				this.limit_app_last_w := this.limit_app_w
				this.limit_app_last_h := this.limit_app_h
				this.limit_app_w := limit_w
				this.limit_app_h := limit_h
				if (fire_change){
					this.debug("Resolution change detected (" this.limit_app_last_w "x" this.limit_app_last_h " --> " this.limit_app_w "x" this.limit_app_h ")- firing change")
					this.fire_event(this.events.resolution_changed)
					  
				} else {
					this.debug("First detection of resolution - not firing change")
				}
			}
			this.app_active(1)
		}
		else
		{
			this.app_active(0)
		}
		return
	}

	app_active(act){
		if (act){
			if (this.app_act_curr == 0){
				; Changing from inactive to active
				this.app_act_curr := 1
				this.debug("Firing app_active")
				this.fire_event(this.events.app_active)
			}
		} else {
			if (this.app_act_curr == 1 || this.app_act_curr == -1){
				; Changing from active to inactive or on startup
				; Stop Author Timers
				this.app_act_curr := 0
				
				; Fire event hooks
				this.debug("Firing app_inactive")
				this.fire_event(this.events.app_inactive)
				;Gosub, adhd_disable_author_timers	; Fire the Author hook
			}
		}
	}

	/*
	 #   #    #
	 #   #
	 ## ##   ##     ###    ###
	 # # #    #    #      #   #
	 #   #    #     ###   #
	 #   #    #        #  #   #
	 #   #   ###   ####    ###
	Miscellaneous or unsorted stuff
	*/

	show_window_spy(){
		SplitPath, A_AhkPath,,tmp
		tmp := tmp "\AU3_Spy.exe"
		IfExist, %tmp%
			Run, %tmp%
	}

	/*
	get_hotkey_string(hk){
		;Get hotkey string - could be keyboard or mouse
		tmp := adhd_hk_k_%hk%
		if (tmp == ""){
			tmp := adhd_hk_m_%hk%
			if (tmp == "None"){
				tmp := ""
			}
		}
		return tmp
	}
	*/

}

/*
  ###   #       ###   ####     #    #              ###   #####  #   #  #####  #####
 #   #  #      #   #   #  #   # #   #             #   #    #    #   #  #      #
 #      #      #   #   #  #  #   #  #             #        #    #   #  #      #
 #      #      #   #   ###   #   #  #              ###     #    #   #  ####   ####
 #  ##  #      #   #   #  #  #####  #                 #    #    #   #  #      #
 #   #  #      #   #   #  #  #   #  #             #   #    #    #   #  #      #
  ###   #####   ###   ####   #   #  #####          ###     #     ###   #      #

This stuff is only here because of limitations in AHK.

You should NOT reference anything prefixed "adhd_" directly.
All access to these functions and data should be via "Public" functions.
If there is no public function to do what you require, request a library update!
*/

; Tooltip function from http://www.autohotkey.com/board/topic/81915-solved-gui-control-tooltip-on-hover/#entry598735
; ToDo: Has to be here as when handling an OnMessage callback, it has no concept of "this"
adhd_mouse_move(){
	static CurrControl, PrevControl, _TT

	; Only check if current window is the AHK GUI
	IfWinActive, % "ahk_class AutoHotkeyGUI"
	{
		CurrControl := A_GuiControl
		If (CurrControl <> PrevControl){
				SetTimer, adhd_display_tooltip, -750 	; shorter wait, shows the tooltip faster
				PrevControl := CurrControl
		}
		return
		
		adhd_display_tooltip:
		try
				ToolTip % %CurrControl%_TT
		catch
				ToolTip
		SetTimer, adhd_remove_tooltip, -10000
		return
		
		adhd_remove_tooltip:
		ToolTip
		return
	}
	return
}

; A Joystick button was pressed while in Binding mode
adhd_bind_joystick_button:
	ADHD.private.bind_joystick_button()
	return

; A Joystick button was pressed in normal usage
adhd_joystick_handler:
	ADHD.private.joystick_handler()
	return

; Label triggers

adhd_profile_changed:
	ADHD.private.profile_changed()
	return

adhd_option_changed:
	ADHD.private.option_changed()
	return

adhd_set_binding:
	ADHD.private.set_binding(substr(A_GuiControl,14))
	return

adhd_add_profile:
	ADHD.private.add_profile("")	; just clicking the button calls with empty param
	return

; Delete Profile pressed
adhd_delete_profile:
	ADHD.private.delete_profile(adhd_current_profile)	; Just clicking the button deletes the current profile
	return

adhd_duplicate_profile:
	ADHD.private.duplicate_profile("")
	return
	
adhd_rename_profile:
	ADHD.private.rename_profile()
	return

adhd_tab_changed:
	ADHD.private.tab_changed()
	return

adhd_show_window_spy:
	ADHD.private.show_window_spy()
	return

adhd_debug_window_change:
	ADHD.private.debug_window_change()
	return

adhd_debug_change:
	ADHD.private.debug_change()
	return
	
adhd_clear_log:
	ADHD.private.clear_log()
	return

adhd_heartbeat:
	ADHD.private.heartbeat()
	return

adhd_functionality_toggle:
	ADHD.private.functionality_toggle()
	return

adhd_delete_hotkey:
	SetTimer, adhd_delete_hotkey, Off
	ADHD.private.delete_hotkey()
	return

adhd_escape_released:
	hotkey, Escape up, adhd_escape_released, OFF
	SetTimer, adhd_delete_hotkey, Off
	return
	
; === SHOULD NOT NEED TO EDIT BELOW HERE! ===========================================================================


; Kill the macro if the GUI is closed
adhd_exit_app:
GuiClose:
	ADHD.private.exit_app()
	return

; Detects Modifiers and Mouse Buttons in BindMode
#If ADHD.private.BindMode
	; Detect key down of modifier keys
	*lctrl::
	*rctrl::
	*lalt::
	*ralt::
	*lshift::
	*rshift::
	*lwin::
	*rwin::
		adhd_tmp_modifier := substr(A_ThisHotkey,2)
		ADHD.private.set_modifier(adhd_tmp_modifier,1)
		return

	; Detect key up of modifier keys
	*lctrl up::
	*rctrl up::
	*lalt up::
	*ralt up::
	*lshift up::
	*rshift up::
	*lwin up::
	*rwin up::
		; Strip * from beginning, " up" from end etc
		adhd_tmp_modifier := substr(substr(A_ThisHotkey,2),1,strlen(A_ThisHotkey) -4)
		if (ADHD.private.current_modifier_count() == 1){
			; If current_modifier_count is 1 when an up is received, then that is a Solitary Modifier
			; It cannot be a modifier + normal key, as this code would have quit on keydown of normal key

			ADHD.private.HKControlType := 1
			ADHD.private.HKSecondaryInput := adhd_tmp_modifier

			; Send Escape - This will cause the Input command to quit with an EndKey of Escape
			; But we stored the modifier key, so we will know it was not really escape
			Send {Escape}
		}
		ADHD.private.set_modifier(adhd_tmp_modifier,0)
		return

	; Detect Mouse buttons
	lbutton::
	rbutton::
	mbutton::
	xbutton1::
	xbutton2::
	wheelup::
	wheeldown::
	wheelleft::
	wheelright::
		ADHD.private.HKControlType := 2
		ADHD.private.HKSecondaryInput := A_ThisHotkey
		Send {Escape}
		return
#If

