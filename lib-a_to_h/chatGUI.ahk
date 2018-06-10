/*

    Legend:

    mELog = Edit chat Log
    mLUsl = Listview User List
    mESmg = Edit Send Message
    mBSmg = Button Send Message
    mBCde = Button Code
    mGCon = GroupBox Connection settings
    mTNkN = Text NickName
    mENkN = Edit NickName
    mTSIP = Text Server IP
    mESIP = Edit Server IP
    mBCNk = Button Change NickName
    mBCon = Button Connect
    mCTst = CheckBox Test

*/
CreateGui(){
    global

    Gui, Main: +LastFound
    sci := {} ; Scintilla Editor Array
    hwnd := WinExist(), sci[1] := new scintilla(hwnd, 10,0,400,200, a_scriptdir "\lib")
    mELog := sci[1].hwnd

    Menu, mMenuBar, Add, Edit
    Menu, mMenuBar, Add, View
    Menu, mMenuBar, Add, Tools
    Gui, Main: Default
    Gui, Main: +Resize MinSize545x324 
    Gui, Main: Menu, mMenuBar
    Gui, Main: Add, StatusBar, 0x100
        SB_SetParts(80, 80, 300)
    Gui, Main: Add, ListView , x415 y6   w120 h198 HwndmLUsl -Hdr -Multi, Icon|Users
    Gui, Main: Add, Edit     , x10  y210 w400      HwndmESmg -WantReturn +WantTab vGuiMessage gMessageInput -0x100
    Gui, Main: Add, Button   , x415 y210 w55  h23  HwndmBSmg Default gHandleEnter, Send
    Gui, Main: Add, Button   , x480 y210 w55  h23  HwndmBCde gCodeWin, Code
    Gui, Main: Add, GroupBox , x5   y238 w530 h57  HwndmGCon, Connection Settings
    Gui, Main: Add, Text     , x17  y263 w51  h13  HwndmTNkN, Nickname:
    Gui, Main: Add, Edit     , x78  y260 w100 h21  HwndmENkN vEdNick -WantReturn, % (type = "client" ? "Guest" A_TickCount : "Server")
    Gui, Main: Add, Text     , x258 y263 w34  h13  HwndmTSIP , Server:
    Gui, Main: Add, Edit     , x308 y260 w100 h21  HwndmESIP vEdServIP Disabled, % (type = "client" ? "99.23.4.199" : "0.0.0.0")

    if (type = "client")
    {
        Gui, Main: Add, Button, x186 y260 w55       HwndmBCNk gChangeNick, Change
        Gui, Main: Add, Button, x420 y260 w55 h23   HwndmBCon gConnectToServer, Connect
        Gui, Main: Add, CheckBox, x485 y265 w43 h13 HwndmCTst gDisableIP vTest Checked1, Test
        Attach(mBCNk, "y r")
        Attach(mBCon, "y r")
        Attach(mCTst, "y r1")
    }

    ; Attach(mELog, "w h r")
    Attach(mLUsl, "x h r2")
    Attach(mESmg, "y w r")
    Attach(mBSmg, "x y r2")
    Attach(mBCde, "x y r2")
    Attach(mGCon, "y w r")
    Attach(mTNkN, "y r")
    Attach(mENkN, "y r")
    Attach(mTSIP, "y r")
    Attach(mESIP, "y r")

    if (type = "client")
    {
        Attach(mBCNk, "y r2")
        Attach(mBCon, "y r2")
        Attach(mCTst, "y r")
    }

    Gui, Code: Default
    Gui, Code: +LastFound
    hwnd := WinExist(), sci[2] := new scintilla(hwnd, 0,0,400,400, a_scriptdir "\lib")

    Gui, Code: Font, s10, Lucida Console
    Gui, Code: Add, ListView, x420 y8 w140 h400 -Hdr -Multi gListViewNotifications, Icon|Users
    ImageListID := IL_Create(2)
    LV_SetImageList(ImageListID)
    IL_Add(ImageListID, "shell32.dll", 71)
    IL_Add(ImageListID, "shell32.dll", 291)

    Gui, Code: Font, s8, Tahoma
    Gui, Code: Add, Button, x335 y410 w75 gSendCode, Send ;Sends to server

    Gui, Main: Submit, NoHide
    setup_Scintilla(sci, EdNick)
    Gui, Main: Show,, % "ahkMessenger " (type = "client" ? "Client" : "Server")
    GuiControl, Main: Focus, GuiMessage

    if (type = "client")
        Pause, On
    return

    HandleEnter:
        Gui, Main: Submit, NoHide
        GuiControlGet, edVar, FocusV 
        if (edVar == "EdNick")
            GoSub ChangeNick
        else if (edVar == "GuiMessage")
            GoSub SendMessage
    return

    MessageInput:
        Gui, Main: Submit, NoHide
        SendMessage, 0x00B0,,,, AHK_ID%mESmg%            ; Get Caret position
        caretPos := MakeShort(ErrorLevel)                ; Assign to variable
        StringMid, leftChars, GuiMessage, 0, %caretPos%  ; Grab all text BEFORE (to the left) of the caret
        if (RegexMatch(leftChars, "ix)\s?(\w+)\t$", m))  ; Test if a Tab was pressed
            findMatch(m1)
    return

    ConnectToServer:
        Gui, Main: Submit, NoHide     ;Necessary to submit Nickname (not a scintilla control)
        if (!clientConnected && nickCheck(EdNick))
        {
            setup_Scintilla(sci, EdNick)
            Pause, Off
            clientConnected++
        }
        else
            msgbox, Please close the window if you need to reconnect.
    return

    DisableIP:
        Gui, Main: Submit, NoHide
        GuiControl, % test ? "Disable" : "Enable", EdServIP
    return

    ChangeNick:
        Gui, Main: Submit, NoHide
        if (nickCheck(EdNick))
            WS_Send(client, "NKCH||" . EdNick)
    return

    CodeWin:
        Gui, Code: Show
    return

    SendMessage:
        Gui, Main: Submit, NoHide
        if (!GuiMessage)
            return
        sci[1].GotoPos(sci[1].GetLength())
        pos := RegexMatch(GuiMessage, "^/(#?)(\w+)", arg)
        nChan := arg2
        if (type = "client")
        {
            if (pos)  ; If the message is preppended with a /COMMAND
            {
                chanSwitch := arg1, nCmd := arg2
                outputdebug **chatGUI** **if arg1** chanSwitch = %chanSwitch%,
                if (chanSwitch == "#")  ; This condtion will not Ws_Send to server. Client side channel switch
                {
                    outputdebug **chatGUI** **if chanswitch** arg1=%arg1%
                    RegexMatch(GuiMessage, "^/(#.+)", arg)
                    nChan := toLower(arg1)
                    if (toLower(occupiedChannels[nChan]) != nChan)
                    {
                        msgbox create it first
                        return
                    }
                    sci[1].setReadOnly(false)

                    sci[1].GetText(sci[1].GetLength()+1, sci1Text)  ; Copy chatlog to display when switching back
                    channelChat[currentChan] := sci1Text
                    sci[1].ClearAll()

                    sci[1].AddText(strLen(str:=channelChat[nChan]), str), sci[1].GotoPos(sci[1].GetLength())
                    sci[1].setReadOnly(true)
                    currentChan := nChan
                    Gui, Main: Default
                    LV_Delete()
                    nickList := channelNicks[nChan]
                    Loop, Parse, nickList, %A_Space%, %A_Space%
                        LV_Add("" ,"", A_LoopField)  ; The username
                    for k, v in occupiedChannels
                    {
                        OutputDebug **chatGUI** **for k v in occupiedChannels** k = %k% v = %v%, currentChan = %currentChan%
                        if (toLower(v) == toLower(currentChan))
                        {
                            OutputDebug **chatGUI** ** if v (%v%) == currentChan (%currentChan%)
                            v := "[" . v . "]"
                        }
                        chanList .= v . " "
                    }

                    GuiControl, Main:, GuiMessage
                    SB_SetText(chanList, 3)
                    chanList := ""
                    return
                }
                else if (toLower(arg2) == "leave")
                {
                    if (currentChan == "#Main")
                    {
                        outputdebug hahah you cannot leave #Main!!!
                        return
                    }
                    WS_Send(client, "COMD||" . GuiMessage . "||" . currentChan)
                    sci[1].setReadOnly(false)
                    sci[1].ClearAll()
                    sci[1].AddText(strLen(str:=channelChat["#Main"]), str), sci[1].GotoPos(sci[1].GetLength())
                    sci[1].setReadOnly(true)
                    Gui, Main: Default
                    LV_Delete()
                    nickList := channelNicks["#Main"]
                    Loop, Parse, nickList, %A_Space%, %A_Space%
                        LV_Add("" ,"", A_LoopField)  ; The username

                    for k, v in occupiedChannels
                    {
                        OutputDebug **client** *for kv in occupiedChannels** k, v = %k% %v%
                        if (v == "#Main")
                            v := "[" . v . "]"
                        if (v == currentChan)
                            continue
                        chanList .= v . " "
                    }
                    Gui, Main: Default
                    SB_SetText(chanList, 3)
                    chanList := ""
                    occupiedChannels.Remove(currentChan)
                    currentChan := "#Main"
                }
                else
                {
                    OutputDebug **chatGUI** **else**  type = %type%
                    WS_Send(client, "COMD||" . GuiMessage)
                }
            }
            else
            {
                WS_Send(client, "MESG||"           ; MESG||Nick||#Room||Message
                              . EdNick . "||"
                              . currentChan . "||"
                              . GuiMessage)
            }
            GuiControl, Main:, GuiMessage
        }
        else if (type = "server")
        {
            if (arg1)  ; If the message is preppended with a /COMMAND
            {
                return
            }

            for key, value in socketFromNick
                WS_Send(socketFromNick[key], "MESG||" . EdNick . "||Global||" . GuiMessage)
            sci[1].SetReadOnly(false)
            sci[1].AddText(strLen(str:=EdNick ": " GuiMessage "`n"), str), sci[1].GotoPos(sci[1].GetLength())
            sci[1].SetReadOnly(true)
            GuiControl, Main:, GuiMessage
        }
    return

    SendCode:
        sci[2].GetText(sci[2].GetLength()+1, GuiCode)
        if (type = "client")
            WS_Send(client, "NWCD||" . GuiCode)
        else if (type "server")
        {
            userCodes[serverSocket] := GuiCode
            Gui, Code: Default

            LV_ModifyCol(1)
            if(!firstVisit)
            {
                LV_Add("Icon" . 3, "", EdNick)
                LV_ModifyCol(1), firstVisit++
            }

            for key, value in socketFromNick
                if (socketFromNick[key] != 000)
                    WS_Send(socketFromNick[key], "NWCD||" . EdNick)
        }
    return

    ListViewNotifications:
        if (A_GuiEvent == "DoubleClick")
        {
            Gui, Code: Default
            LV_GetText(nick, A_EventInfo, 2)

            if (type = "client")
                WS_Send(client, "RQST||" . nick)
            else if (type = "server")
            {
                skt := userNick[nick]
                sci[2].ClearAll(), sci[2].AddText(strLen(str:=userCodes[skt]), str), sci[2].GotoPos(sci[2].GetLength())
                LV_Modify(A_EventInfo, "Icon" . 0)
            }
        }
    return

    ; Menu Labels
    Edit:
        if (A_ThisMenu == "mMenuBar")
            ToolTip, Main GUI %A_ThisMenuItem%
        else if (A_ThisMenu == "cMenuBar")
            ToolTip, Code GUI %A_ThisMenuItem%
    return

    View:
        if (A_ThisMenu == "mMenuBar")
            ToolTip, Main GUI %A_ThisMenuItem%
        else if (A_ThisMenu == "cMenuBar")
            ToolTip, Code GUI %A_ThisMenuItem%
    return

    Tools:
        if (A_ThisMenu == "mMenuBar")
            ToolTip, Main GUI %A_ThisMenuItem%
        else if (A_ThisMenu == "cMenuBar")
            ToolTip, Code GUI %A_ThisMenuItem%
return
}

setup_Scintilla(sci, localNick=""){

    static controlflow, commands, functions, directives, keysbuttons, variables, specialparams
    controlflow =
    (
        break continue else exit exitapp gosub goto loop onexit pause repeat return settimer sleep suspend
        static global local byref while until for
    )
    commands =
    (
        autotrim blockinput clipwait control controlclick controlfocus controlget controlgetfocus
        controlgetpos controlgettext controlmove controlsend controlsendraw controlsettext coordmode
        critical detecthiddentext detecthiddenwindows drive driveget drivespacefree edit endrepeat envadd
        envdiv envget envmult envset envsub envupdate fileappend filecopy filecopydir filecreatedir
        filecreateshortcut filedelete filegetattrib filegetshortcut filegetsize filegettime filegetversion
        fileinstall filemove filemovedir fileread filereadline filerecycle filerecycleempty fileremovedir
        fileselectfile fileselectfolder filesetattrib filesettime formattime getkeystate groupactivate
        groupadd groupclose groupdeactivate gui guicontrol guicontrolget hideautoitwin hotkey if ifequal
        ifexist ifgreater ifgreaterorequal ifinstring ifless iflessorequal ifmsgbox ifnotequal ifnotexist
        ifnotinstring ifwinactive ifwinexist ifwinnotactive ifwinnotexist imagesearch inidelete iniread
        iniwrite input inputbox keyhistory keywait listhotkeys listlines listvars menu mouseclick
        mouseclickdrag mousegetpos mousemove msgbox outputdebug pixelgetcolor pixelsearch postmessage
        process progress random regdelete regread regwrite reload run runas runwait send sendevent
        sendinput sendmessage sendmode sendplay sendraw setbatchlines setcapslockstate setcontroldelay
        setdefaultmousespeed setenv setformat setkeydelay setmousedelay setnumlockstate setscrolllockstate
        setstorecapslockmode settitlematchmode setwindelay setworkingdir shutdown sort soundbeep soundget
        soundgetwavevolume soundplay soundset soundsetwavevolume splashimage splashtextoff splashtexton
        splitpath statusbargettext statusbarwait stringcasesense stringgetpos stringleft stringlen
        stringlower stringmid stringreplace stringright stringsplit stringtrimleft stringtrimright
        stringupper sysget thread tooltip transform traytip urldownloadtofile winactivate
        winactivatebottom winclose winget wingetactivestats wingetactivetitle wingetclass wingetpos
        wingettext wingettitle winhide winkill winmaximize winmenuselectitem winminimize winminimizeall
        winminimizeallundo winmove winrestore winset winsettitle winshow winwait winwaitactive
        winwaitclose winwaitnotactive fileencoding
    )
    functions =
    (
        abs acos asc asin atan ceil chr cos dllcall exp fileexist floor getkeystate numget numput
        registercallback il_add il_create il_destroy instr islabel isfunc ln log lv_add lv_delete
        lv_deletecol lv_getcount lv_getnext lv_gettext lv_insert lv_insertcol lv_modify lv_modifycol
        lv_setimagelist mod onmessage round regexmatch regexreplace sb_seticon sb_setparts sb_settext sin
        sqrt strlen substr tan tv_add tv_delete tv_getchild tv_getcount tv_getnext tv_get tv_getparent
        tv_getprev tv_getselection tv_gettext tv_modify varsetcapacity winactive winexist trim ltrim rtrim
        fileopen strget strput object isobject objinsert objremove objminindex objmaxindex objsetcapacity
        objgetcapacity objgetaddress objnewenum objaddref objrelease objclone _insert _remove _minindex
        _maxindex _setcapacity _getcapacity _getaddress _newenum _addref _release _clone comobjcreate
        comobjget comobjconnect comobjerror comobjactive comobjenwrap comobjunwrap comobjparameter
        comobjmissing comobjtype comobjvalue comobjarray
    )
    directives =
    (
        allowsamelinecomments clipboardtimeout commentflag errorstdout escapechar hotkeyinterval
        hotkeymodifiertimeout hotstring if iftimeout ifwinactive ifwinexist include includeagain
        installkeybdhook installmousehook keyhistory ltrim maxhotkeysperinterval maxmem maxthreads
        maxthreadsbuffer maxthreadsperhotkey menumaskkey noenv notrayicon persistent singleinstance
        usehook warn winactivateforce
    )
    keysbuttons =
    (
        shift lshift rshift alt lalt ralt control lcontrol rcontrol ctrl lctrl rctrl lwin rwin appskey
        altdown altup shiftdown shiftup ctrldown ctrlup lwindown lwinup rwindown rwinup lbutton rbutton
        mbutton wheelup wheeldown xbutton1 xbutton2 joy1 joy2 joy3 joy4 joy5 joy6 joy7 joy8 joy9 joy10
        joy11 joy12 joy13 joy14 joy15 joy16 joy17 joy18 joy19 joy20 joy21 joy22 joy23 joy24 joy25 joy26
        joy27 joy28 joy29 joy30 joy31 joy32 joyx joyy joyz joyr joyu joyv joypov joyname joybuttons
        joyaxes joyinfo space tab enter escape esc backspace bs delete del insert ins pgup pgdn home end
        up down left right printscreen ctrlbreak pause scrolllock capslock numlock numpad0 numpad1 numpad2
        numpad3 numpad4 numpad5 numpad6 numpad7 numpad8 numpad9 numpadmult numpadadd numpadsub numpaddiv
        numpaddot numpaddel numpadins numpadclear numpadup numpaddown numpadleft numpadright numpadhome
        numpadend numpadpgup numpadpgdn numpadenter f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15 f16
        f17 f18 f19 f20 f21 f22 f23 f24 browser_back browser_forward browser_refresh browser_stop
        browser_search browser_favorites browser_home volume_mute volume_down volume_up media_next
        media_prev media_stop media_play_pause launch_mail launch_media launch_app1 launch_app2 blind
        click raw wheelleft wheelright
    )
    variables =
    (
        a_ahkpath a_ahkversion a_appdata a_appdatacommon a_autotrim a_batchlines a_caretx a_carety
        a_computername a_controldelay a_cursor a_dd a_ddd a_dddd a_defaultmousespeed a_desktop
        a_desktopcommon a_detecthiddentext a_detecthiddenwindows a_endchar a_eventinfo a_exitreason
        a_formatfloat a_formatinteger a_gui a_guievent a_guicontrol a_guicontrolevent a_guiheight
        a_guiwidth a_guix a_guiy a_hour a_iconfile a_iconhidden a_iconnumber a_icontip a_index
        a_ipaddress1 a_ipaddress2 a_ipaddress3 a_ipaddress4 a_isadmin a_iscompiled a_issuspended
        a_keydelay a_language a_lasterror a_linefile a_linenumber a_loopfield a_loopfileattrib
        a_loopfiledir a_loopfileext a_loopfilefullpath a_loopfilelongpath a_loopfilename
        a_loopfileshortname a_loopfileshortpath a_loopfilesize a_loopfilesizekb a_loopfilesizemb
        a_loopfiletimeaccessed a_loopfiletimecreated a_loopfiletimemodified a_loopreadline a_loopregkey
        a_loopregname a_loopregsubkey a_loopregtimemodified a_loopregtype a_mday a_min a_mm a_mmm a_mmmm
        a_mon a_mousedelay a_msec a_mydocuments a_now a_nowutc a_numbatchlines a_ostype a_osversion
        a_priorhotkey a_programfiles a_programs a_programscommon a_screenheight a_screenwidth a_scriptdir
        a_scriptfullpath a_scriptname a_sec a_space a_startmenu a_startmenucommon a_startup
        a_startupcommon a_stringcasesense a_tab a_temp a_thishotkey a_thismenu a_thismenuitem
        a_thismenuitempos a_tickcount a_timeidle a_timeidlephysical a_timesincepriorhotkey
        a_timesincethishotkey a_titlematchmode a_titlematchmodespeed a_username a_wday a_windelay a_windir
        a_workingdir a_yday a_year a_yweek a_yyyy clipboard clipboardall comspec errorlevel programfiles
        true false a_thisfunc a_thislabel a_ispaused a_iscritical a_isunicode a_ptrsize
    )
    specialparams =
    (
        ltrim rtrim join ahk_id ahk_pid ahk_class ahk_group processname minmax controllist statuscd
        filesystem setlabel alwaysontop mainwindow nomainwindow useerrorlevel altsubmit hscroll vscroll
        imagelist wantctrla wantf2 vis visfirst wantreturn backgroundtrans minimizebox maximizebox sysmenu
        toolwindow exstyle check3 checkedgray readonly notab lastfound lastfoundexist alttab shiftalttab
        alttabmenu alttabandmenu alttabmenudismiss controllisthwnd hwnd deref pow bitnot bitand bitor
        bitxor bitshiftleft bitshiftright sendandmouse mousemove mousemoveoff hkey_local_machine
        hkey_users hkey_current_user hkey_classes_root hkey_current_config hklm hku hkcu hkcr hkcc reg_sz
        reg_expand_sz reg_multi_sz reg_dword reg_qword reg_binary reg_link reg_resource_list
        reg_full_resource_descriptor caret reg_resource_requirements_list reg_dword_big_endian regex pixel
        mouse screen relative rgb low belownormal normal abovenormal high realtime between contains in is
        integer float number digit xdigit alpha upper lower alnum time date not or and topmost top bottom
        transparent transcolor redraw region id idlast count list capacity eject lock unlock label serial
        type status seconds minutes hours days read parse logoff close error single shutdown menu exit
        reload tray add rename check uncheck togglecheck enable disable toggleenable default nodefault
        standard nostandard color delete deleteall icon noicon tip click show edit progress hotkey text
        picture pic groupbox button checkbox radio dropdownlist ddl combobox statusbar treeview listbox
        listview datetime monthcal updown slider tab tab2 iconsmall tile report sortdesc nosort nosorthdr
        grid hdr autosize range xm ym ys xs xp yp font resize owner submit nohide minimize maximize
        restore noactivate na cancel destroy center margin owndialogs guiescape guiclose guisize
        guicontextmenu guidropfiles tabstop section wrap border top bottom buttons expand first lines
        number uppercase lowercase limit password multi group background bold italic strike underline norm
        theme caption delimiter flash style checked password hidden left right center section move focus
        hide choose choosestring text pos enabled disabled visible notimers interrupt priority waitclose
        unicode tocodepage fromcodepage yes no ok cancel abort retry ignore force on off all send wanttab
        monitorcount monitorprimary monitorname monitorworkarea pid base useunsetlocal useunsetglobal
        localsameasglobal
    )
    infoMessages = Notice

    ;{ sci[1] Configuration
    sci[1].SetWrapMode("SC_WRAP_WORD"), sci[1].SetMarginWidthN(1, 0), sci[1].SetReadOnly(true), sci[1].SetLexer(6)
    sci[1].SetCaretWidth(0), sci[1].StyleSetBold("STYLE_DEFAULT", true), sci[1].StyleClearAll()

    sci[1].SetKeywords(0,localNick), sci[1].SetKeywords(2,infoMessages)

    sci[1].StyleSetFore(0,0x000000), sci[1].StyleSetBold(0, false)      ; SCE_MSG_DEFAULT
    sci[1].StyleSetFore(1,0xFF0000)                                     ; SCE_MSG_LOCALNICK
    sci[1].StyleSetFore(2,0x0000FF)                                     ; SCE_MSG_OTHERNICK
    sci[1].StyleSetFore(3,0x00FF00), sci[1].StyleSetBold(3, false)      ; SCE_MSG_INFOMESSAGE
    ;}

    ;{ sci[2] Configuration
    sci[2].SetWrapMode("SC_WRAP_WORD"), sci[2].SetMarginWidthN(0, 40), sci[2].SetMarginWidthN(1, 16), sci[2].SetLexer(6)
    sci[2].StyleSetBold("STYLE_DEFAULT", true), sci[2].StyleClearAll()

    ; Change this in to a loop
    sci[2].SetKeywords(0,controlflow)
    sci[2].SetKeywords(1,commands)
    sci[2].SetKeywords(2,functions)
    sci[2].SetKeywords(3,directives)
    sci[2].SetKeywords(4,keysbuttons)
    sci[2].SetKeywords(5,variables)
    sci[2].SetKeywords(6,specialparams)
    sci[2].SetKeywords(7,userdefined)

    sci[2].StyleSetBold("STYLE_LINENUMBER", false)

    ; Change this in to a loop
    sci[2].StyleSetFore(0,0x000000), sci[2].StyleSetBold(0, false)      ; SCE_AHK_DEFAULT
    sci[2].StyleSetFore(1,0x009900), sci[2].StyleSetBold(1, false)      ; SCE_AHK_COMMENTLINE
    sci[2].StyleSetFore(2,0x009900), sci[2].StyleSetBold(2, false)      ; SCE_AHK_COMMENTBLOCK
    sci[2].StyleSetFore(3,0xFF0000)                                     ; SCE_AHK_ESCAPE
    sci[2].StyleSetFore(4,0x000080), sci[2].StyleSetBold(4, false)      ; SCE_AHK_SYNOPERATOR
    sci[2].StyleSetFore(5,0x000080), sci[2].StyleSetBold(5, false)      ; SCE_AHK_EXPOPERATOR
    sci[2].StyleSetFore(6,0xA2A2A2), sci[2].StyleSetBold(6, false)      ; SCE_AHK_STRING
    sci[2].StyleSetFore(7,0xFF9000), sci[2].StyleSetBold(7, false)      ; SCE_AHK_NUMBER
    sci[2].StyleSetFore(8,0xFF9000), sci[2].StyleSetBold(8, false)      ; SCE_AHK_IDENTIFIER
    sci[2].StyleSetFore(9,0XFF9000), sci[2].StyleSetBold(9, false)      ; SCE_AHK_VARREF
    sci[2].StyleSetFore(10,0x0000FF)                                    ; SCE_AHK_LABEL
    sci[2].StyleSetFore(11,0x0000FF)                                    ; SCE_AHK_WORD_CF
    sci[2].StyleSetFore(12,0x0000FF)                                    ; SCE_AHK_WORD_CMD
    sci[2].StyleSetFore(13,0xFF0090)                                    ; SCE_AHK_WORD_FN
    sci[2].StyleSetFore(14,0xA50000)                                    ; SCE_AHK_WORD_DIR
    sci[2].StyleSetFore(15,0xA2A2A2),sci[2].StyleSetItalic(15, true)    ; SCE_AHK_WORD_KB
    sci[2].StyleSetFore(16,0xFF9000)                                    ; SCE_AHK_WORD_VAR
    sci[2].StyleSetFore(17,0x0000FF), sci[2].StyleSetBold(17, false)    ; SCE_AHK_WORD_SP
    sci[2].StyleSetFore(18,0x00F000)                                    ; SCE_AHK_WORD_UD
    sci[2].StyleSetFore(19,0xFF9000)                                    ; SCE_AHK_VARREFKW
    sci[2].StyleSetFore(20,0xFF0000)                                    ; SCE_AHK_ERROR

    ;}

    return  controlflow := commands := functions := directives := keysbuttons := variables := specialparams := ""
}

nickCheck(n){
    RegexMatch(n, "^(\d)", m)
    if (!m1 && n) && (!RegexMatch(n, "\s")) && (StrLen(n) < 15)
        return 1
    else
        msgbox, A nickname cannot be empty, longer than 14 characters, contain spaces and must begin with a letter.`nPlease try again.
        return 0
}

findMatch(searchFor){
    global mESmg, caretPos

    ;Gui, Main: Default
    loop % LV_GetCount()
    {
        LV_GetText(rowText, A_Index, 2)
        if (searchFor == rowText)
            continue
        firstLtrMatch := SubStr(searchFor, 1, 1)     ; Set the first letter of match1
        firstLtrRow   := SubStr(rowText  , 1, 1)     ; from Edit control and Row text
        StringLower, firstLtrMatch, firstLtrMatch    ; to lower case.
        StringLower, firstLtrRow  , firstLtrRow      ;
        if (firstLtrMatch == firstLtrRow)            ;  Then compare them.
        {
            startOfWord := caretPos - (StrLen(searchFor) + 1)
            SendMessage, 0x00B1, startOfWord, caretPos,, AHK_ID%mESmg%  ; EM_SETSEL
            SendMessage, 0x00C2,            , &rowText,, AHK_ID%mESmg%  ; EM_REPLACESEL
            break                                                       ; > Replaces highlighted
        }                                                               ;   text with LV Item
    }

}

MakeShort(Long) {
 return Long & 0xffff
}

toLower(v){
    StringLower,v, v
    return v
}