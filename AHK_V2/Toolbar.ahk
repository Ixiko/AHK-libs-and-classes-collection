#Include TheArkive_Toolbar.ahk
#Include TheArkive_Debug.ahk

ILA := IL_Create(4, 2, True) ; Create an ImageList.
IL_Add(ILA, "shell32.dll", 127)
IL_Add(ILA, "shell32.dll", 126)
IL_Add(ILA, "shell32.dll", 129)
IL_Add(ILA, "shell32.dll", 130)

; TBSTYLE_FLAT     := 0x0800 Required to show separators as bars.
; TBSTYLE_TOOLTIPS := 0x0100 Required to show Tooltips.
g := Gui.New("","Toolbar Test")
g.OnEvent("close","GuiClose")
ctl := g.Add("Custom","ClassToolbarWindow32 0x0800 0x0100")
; ctl.OnEvent("click","test")
hToolbar := ctl.hwnd
g.Add("Text","xm","Press F1 to customize.")
g.Show()

test(ctl,info) {
	msgbox "in"
}

GuiClose(g) {
	ExitApp
}



; Msgbox Format("0x{:X}",Toolbar.TB_BUTTONCOUNT)








class toolbar {
	__New() {
	
	}
	
	SetImageList(IL_Default, IL_Hot := "", IL_Pressed := "", IL_Disabled := "") {
        result := SendMessage(Toolbar.TB_SETIMAGELIST, 0, IL_Default,, "ahk_id " this.tbHwnd)
        If (IL_Hot)
            result := SendMessage(Toolbar.TB_SETHOTIMAGELIST, 0, IL_Hot,, "ahk_id " this.tbHwnd)
        If (IL_Pressed)
            result := SendMessage(Toolbar.TB_SETPRESSEDIMAGELIST, 0, IL_Pressed,, "ahk_id " this.tbHwnd)
        If (IL_Disabled)
            result := SendMessage(Toolbar.TB_SETDISABLEDIMAGELIST, 0, IL_Disabled,, "ahk_id " this.tbHwnd)
        return result
    }
	
	; Messages
	Static TB_ADDBUTTONS            := 0x0414
	Static TB_ADDSTRING             := 0x044D ; 0x041C ANSI
	Static TB_AUTOSIZE              := 0x0421
	Static TB_BUTTONCOUNT           := 0x0418
	Static TB_CHECKBUTTON           := 0x0402
	Static TB_COMMANDTOINDEX        := 0x0419
	Static TB_CUSTOMIZE             := 0x041B
	Static TB_DELETEBUTTON          := 0x0416
	Static TB_ENABLEBUTTON          := 0x0401
	Static TB_GETBUTTON             := 0x0417
	Static TB_GETBUTTONSIZE         := 0x043A
	Static TB_GETBUTTONTEXT         := 0x044B ; 0x042D ANSI
	Static TB_GETEXTENDEDSTYLE      := 0x0455
	Static TB_GETHOTITEM            := 0x0447
	Static TB_GETIMAGELIST          := 0x0431
	Static TB_GETIMAGELISTCOUNT     := 0x0462
	Static TB_GETITEMDROPDOWNRECT   := 0x0467
	Static TB_GETITEMRECT           := 0x041D
	Static TB_GETMAXSIZE            := 0x0453
	Static TB_GETPADDING            := 0x0456
	Static TB_GETRECT               := 0x0433
	Static TB_GETROWS               := 0x0428
	Static TB_GETSTATE              := 0x0412
	Static TB_GETSTYLE              := 0x0439
	Static TB_GETSTRING             := 0x045B ; 0x045C ANSI
	Static TB_GETTEXTROWS           := 0x043D
	Static TB_HIDEBUTTON            := 0x0404
	Static TB_INDETERMINATE         := 0x0405
	Static TB_INSERTBUTTON          := 0x0443 ; 0x0415 ANSI
	Static TB_ISBUTTONCHECKED       := 0x040A
	Static TB_ISBUTTONENABLED       := 0x0409
	Static TB_ISBUTTONHIDDEN        := 0x040C
	Static TB_ISBUTTONHIGHLIGHTED   := 0x040E
	Static TB_ISBUTTONINDETERMINATE := 0x040D
	Static TB_ISBUTTONPRESSED       := 0x040B
	Static TB_MARKBUTTON            := 0x0406
	Static TB_MOVEBUTTON            := 0x0452
	Static TB_PRESSBUTTON           := 0x0403
	Static TB_SETBUTTONINFO         := 0x0440 ; 0x0442 ANSI
	Static TB_SETBUTTONSIZE         := 0x041F
	Static TB_SETBUTTONWIDTH        := 0x043B
	Static TB_SETDISABLEDIMAGELIST  := 0x0436
	Static TB_SETEXTENDEDSTYLE      := 0x0454
	Static TB_SETHOTIMAGELIST       := 0x0434
	Static TB_SETHOTITEM            := 0x0448
	Static TB_SETHOTITEM2           := 0x045E
	Static TB_SETIMAGELIST          := 0x0430
	Static TB_SETINDENT             := 0x042F
	Static TB_SETLISTGAP            := 0x0460
	Static TB_SETMAXTEXTROWS        := 0x043C
	Static TB_SETPADDING            := 0x0457
	Static TB_SETPRESSEDIMAGELIST   := 0x0468
	Static TB_SETROWS               := 0x0427
	Static TB_SETSTATE              := 0x0411
	Static TB_SETSTYLE              := 0x0438
	; Styles
	Static TBSTYLE_ALTDRAG      := 0x0400
	Static TBSTYLE_CUSTOMERASE  := 0x2000
	Static TBSTYLE_FLAT         := 0x0800
	Static TBSTYLE_LIST         := 0x1000
	Static TBSTYLE_REGISTERDROP := 0x4000
	Static TBSTYLE_TOOLTIPS     := 0x0100
	Static TBSTYLE_TRANSPARENT  := 0x8000
	Static TBSTYLE_WRAPABLE     := 0x0200
	Static TBSTYLE_ADJUSTABLE   := 0x20
	Static TBSTYLE_BORDER       := 0x800000
	Static TBSTYLE_THICKFRAME   := 0x40000
	Static TBSTYLE_TABSTOP      := 0x10000
	; ExStyles
	Static TBSTYLE_EX_DOUBLEBUFFER       := 0x80 ; // Double Buffer the toolbar
	Static TBSTYLE_EX_DRAWDDARROWS       := 0x01
	Static TBSTYLE_EX_HIDECLIPPEDBUTTONS := 0x10 ; // don't show partially obscured buttons
	Static TBSTYLE_EX_MIXEDBUTTONS       := 0x08
	Static TBSTYLE_EX_MULTICOLUMN        := 0x02 ; // Intended for internal use; not recommended for use in applications.
	Static TBSTYLE_EX_VERTICAL           := 0x04 ; // Intended for internal use; not recommended for use in applications.
	; Button states
	Static TBSTATE_CHECKED       := 0x01
	Static TBSTATE_ELLIPSES      := 0x40
	Static TBSTATE_ENABLED       := 0x04
	Static TBSTATE_HIDDEN        := 0x08
	Static TBSTATE_INDETERMINATE := 0x10
	Static TBSTATE_MARKED        := 0x80
	Static TBSTATE_PRESSED       := 0x02
	Static TBSTATE_WRAP          := 0x20
	; Button styles
	Static BTNS_BUTTON        := 0x00 ; TBSTYLE_BUTTON
	Static BTNS_SEP           := 0x01 ; TBSTYLE_SEP
	Static BTNS_CHECK         := 0x02 ; TBSTYLE_CHECK
	Static BTNS_GROUP         := 0x04 ; TBSTYLE_GROUP
	Static BTNS_CHECKGROUP    := 0x06 ; TBSTYLE_CHECKGROUP  // (TBSTYLE_GROUP | TBSTYLE_CHECK)
	Static BTNS_DROPDOWN      := 0x08 ; TBSTYLE_DROPDOWN
	Static BTNS_AUTOSIZE      := 0x10 ; TBSTYLE_AUTOSIZE    // automatically calculate the cx of the button
	Static BTNS_NOPREFIX      := 0x20 ; TBSTYLE_NOPREFIX    // this button should not have accel prefix
	Static BTNS_SHOWTEXT      := 0x40 ; // ignored unless TBSTYLE_EX_MIXEDBUTTONS is set
	Static BTNS_WHOLEDROPDOWN := 0x80 ; // draw drop-down arrow, but without split arrow section
	; TB_GETBITMAPFLAGS
	Static TBBF_LARGE   := 0x00000001
	Static TBIF_BYINDEX := 0x80000000 ; // this specifies that the wparam in Get/SetButtonInfo is an index, not id
	Static TBIF_COMMAND := 0x00000020
	Static TBIF_IMAGE   := 0x00000001
	Static TBIF_LPARAM  := 0x00000010
	Static TBIF_SIZE    := 0x00000040
	Static TBIF_STATE   := 0x00000004
	Static TBIF_STYLE   := 0x00000008
	Static TBIF_TEXT    := 0x00000002
	; Notifications
	Static TBN_BEGINADJUST     := -703
	Static TBN_BEGINDRAG       := -701
	Static TBN_CUSTHELP        := -709
	Static TBN_DELETINGBUTTON  := -715
	Static TBN_DRAGOUT         := -714
	Static TBN_DRAGOVER        := -727
	Static TBN_DROPDOWN        := -710
	Static TBN_DUPACCELERATOR  := -725
	Static TBN_ENDADJUST       := -704
	Static TBN_ENDDRAG         := -702
	Static TBN_GETBUTTONINFO   := -720 ; A_IsUnicode ? -720 : -700
	Static TBN_GETDISPINFO     := -717 ; -716 ANSI
	Static TBN_GETINFOTIP      := -719 ; -718 ANSI
	Static TBN_GETOBJECT       := -712
	Static TBN_HOTITEMCHANGE   := -713
	Static TBN_INITCUSTOMIZE   := -723
	Static TBN_MAPACCELERATOR  := -728
	Static TBN_QUERYDELETE     := -707
	Static TBN_QUERYINSERT     := -706
	Static TBN_RESET           := -705
	Static TBN_RESTORE         := -721
	Static TBN_SAVE            := -722
	Static TBN_TOOLBARCHANGE   := -708
	Static TBN_WRAPACCELERATOR := -726
	Static TBN_WRAPHOTITEM     := -724
}