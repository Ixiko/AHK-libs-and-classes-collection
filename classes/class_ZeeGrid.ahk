/**
 * Class for the (now free to use) ZeeGrid control
 * Credits to David Hillard for creating this awesome control.  See his license at the end of this documentation comment.
 *
 * Author: kczx3
 * AHK Version: 2.0-a100-52515e2
 * Created: 04/02/2019
 *
 * ZeeGrid License
    ZeeGrid is made available free-of-charge for any application development. You are free to redistribute the binary file ZeeGrid.DLL and/or ZeeGridx64.DLLwith your application, and use the message header file ZeeGrid.h or any derivative thereof, provided all copyright information remains unaltered.

    You may not publish, in any form, instructions, manuals, or tutorials on ZeeGrid usage. This only relates to ZeeGrid instructions, manuals, or tutorials in a development sense. ZeeGrid usage may be included in your own application instructions as it pertains to the user's view and interaction with ZeeGrid. Just to clarify; Discussion, code snippets, examples of ZeeGrid usage on user groups is fine. Writing and publishing an article or book such as "Using ZeeGrid in Win32 Applications" is not.

    I do request that if ZeeGrid is used in a commercial or publicly distributed application, a mention of ZeeGrid and my name (David Hillard) be put in your Help/About dialog.

    I would appreciate you letting me know what type of application ZeeGrid is being used in, and what language/platform was used in its development. It would also be interesting if you'd let me know what part of the world you're in. It would be cool to make a map graphic and put it on this site showing world-wide usage of ZeeGrid.

    ZeeGridTMCopyright © 2002-2016 by David Hillard
 */
class ZeeGrid extends ZeeGrid.ZeeGridBase {
    __New(gui, opts, title := "", dll := "\..\..\dll\ZeeGridx64.dll") {
        this.gui := gui
        this._handle := DllCall("LoadLibrary", "Str", dll)

        this.grid := gui.addCustom(opts " ClassZeeGrid", title)
    }

    __Delete() {
        DllCall("FreeLibrary", "Ptr", this._handle)
    }

    /**
     * Sends messages to the ZeeGrid control.
     * It is not recommended to call this method directly.  Instead, call the ZeeGrid message as a method on the ZeeGrid instance (minus the prefix of "ZGM_")
     * @param {msg}: The message number to send.  These are defined as static variables on ZeeGrid.ZeeGridBase
     * @param {wParam}: A number or address to a string buffer to be sent as the wParam
     * @param {lParam}: A number or address to a string buffer to be sent as the lParam
     * @return: The same value as documented by the called ZeeGrid message
    */
    __sendGrid(msg := 0, wParam := 0, lParam := 0) {
        return SendMessage(msg, wParam, lParam, this.grid.hwnd)
    }

    OnEvent(notification, cb) {
        if (!Type(cb) = "Func") {
            throw Exception(this.__class "::OnEvent expects a func object as its second parameter", -1)
        }

        this.grid.OnCommand(notification, () => cb.call(this))
    }

    class ZeeGridBase {

        ; Messages
        static ZGM_LOADICON:=0x401, ZGM_SETCELLICON:=0x402, ZGM_SETROWHEIGHT:=0x403, ZGM_SETCELLFONT:=0x404, ZGM_SETCELLFCOLOR:=0x405, ZGM_SETCELLBCOLOR:=0x406, ZGM_SETTITLEHEIGHT:=0x407, ZGM_SETCELLJUSTIFY:=0x408, ZGM_GETCRC:=0x409, ZGM_ENABLETBEDIT:=0x40a, ZGM_ENABLETBSEARCH:=0x40b, ZGM_SHOWTOOLBAR:=0x40c, ZGM_SHOWEDIT:=0x40d, ZGM_SHOWSEARCH:=0x40e, ZGM_GRAYBGONLOSTFOCUS:=0x40f, ZGM_ALLOCATEROWS:=0x410, ZGM_SETAUTOINCREASESIZE:=0x411, ZGM_APPENDROW:=0x412, ZGM_DELETEROW:=0x413, ZGM_SHRINKTOFIT:=0x414, ZGM_SETRANGE:=0x415, ZGM_GETRANGESUM:=0x416
        static ZGM_SHOWTITLE:=0x417, ZGM_ENABLESORT:=0x418, ZGM_ENABLECOLMOVE:=0x419, ZGM_SELECTCOLUMN:=0x41a, ZGM_DIMGRID:=0x41b, ZGM_SETROWNUMBERSWIDTH:=0x41c, ZGM_SETDEFAULTBCOLOR:=0x41d, ZGM_SETGRIDLINECOLOR:=0x41e, ZGM_SETCELLTEXT:=0x41f, ZGM_SETCOLWIDTH:=0x420, ZGM_INSERTROW:=0x421, ZGM_SHOWROWNUMBERS:=0x422, ZGM_GETROWS:=0x423, ZGM_REFRESHGRID:=0x424, ZGM_SETDEFAULTFCOLOR:=0x425, ZGM_SETDEFAULTFONT:=0x426, ZGM_MERGEROWS:=0x427, ZGM_SETDEFAULTJUSTIFY:=0x428, ZGM_SETCELLTYPE:=0x429, ZGM_SETCELLFORMAT:=0x42a, ZGM_SETCOLFORMAT:=0x42b, ZGM_SETCOLTYPE:=0x42c, ZGM_SETCOLJUSTIFY:=0x42d, ZGM_SETCOLFONT:=0x42e, ZGM_GETCELLINDEX:=0x42f, ZGM_ENABLETBMERGEROWS:=0x430, ZGM_SHOWCURSORONLOSTFOCUS:=0x431, ZGM_EMPTYGRID:=0x432, ZGM_ENABLETBROWNUMBERS:=0x433, ZGM_GETFIXEDCOLUMNS:=0x434, ZGM_SETCOLFCOLOR:=0x435, ZGM_SETLEFTINDENT:=0x436, ZGM_SETRIGHTINDENT:=0x437, ZGM_ENABLEICONINDENT:=0x438, ZGM_GETROWHEIGHT:=0x439, ZGM_ENABLECOLRESIZING:=0x43a, ZGM_GETCOLWIDTH:=0x43b, ZGM_SETCOLBCOLOR:=0x43c, ZGM_SELECTROW:=0x43d
        static ZGM_SHOWCURSOR:=0x43e, ZGM_SETCELLEDIT:=0x43f, ZGM_GETCELLEDIT:=0x440, ZGM_GETCURSORINDEX:=0x441, ZGM_AUTOSIZE_ALL_COLUMNS:=0x442, ZGM_SETCOLUMNHEADERHEIGHT:=0x443, ZGM_GETEDITEDCELL:=0x444, ZGM_GOTOCELL:=0x445, ZGM_SETCELLMARK:=0x446, ZGM_MARKTEXT:=0x447, ZGM_SETMARKTEXT:=0x448, ZGM_ENABLETOOLBARTOGGLE:=0x449, ZGM_HIGHLIGHTCURSORROW:=0x44a, ZGM_HIGHLIGHTCURSORROWINFIXEDCOLUMNS:=0x44b, ZGM_GETROWOFINDEX:=0x44c, ZGM_GETCOLOFINDEX:=0x44d, ZGM_GETCELLTEXT:=0x44e, ZGM_SETDEFAULTEDIT:=0x44f, ZGM_SETCOLEDIT:=0x450, ZGM_SHOWGRIDLINES:=0x451, ZGM_ENABLEROWSIZING:=0x452, ZGM_GETGRIDWIDTH:=0x453, ZGM_SETCOLUMNORDER:=0x454, ZGM_ENABLETBEXPORT:=0x455, ZGM_ENABLETBPRINT:=0x456, ZGM_SHOWHSCROLL:=0x457, ZGM_SHOWVSCROLL:=0x458, ZGM_AUTOVSCROLL:=0x459, ZGM_AUTOHSCROLL:=0x45a, ZGM_EXPORT:=0x45b, ZGM_COMPARETEXT:=0x45c, ZGM_GETEDITTEXT:=0x45d, ZGM_SETEDITTEXT:=0x45e, ZGM_COMPARETEXT2STRING:=0x45f, ZGM_GETMOUSEROW:=0x460, ZGM_GETMOUSECOL:=0x461, ZGM_SETCURSORCELL:=0x462, ZGM_CURSORFOLLOWMOUSE:=0x463
        static ZGM_GETROWSPERPAGE:=0x464, ZGM_GETTOPROW:=0x465, ZGM_SETTOPROW:=0x466, ZGM_AUTOSIZECOLONEDIT:=0x467, ZGM_SETSORTLIMIT:=0x469, ZGM_SORTONCOLDCLICK:=0x46a, ZGM_STOPWATCH_START:=0x46b, ZGM_STOPWATCH_STOP:=0x46c, ZGM_SORTCOLUMNASC:=0x46d, ZGM_SORTCOLUMNDESC:=0x46e, ZGM_GETCOLS:=0x46f, ZGM_SETSORTESTIMATE:=0x470, ZGM_GETCELLTYPE:=0x471, ZGM_GETCELLJUSTIFY:=0x472, ZGM_GETCELLFCOLOR:=0x473, ZGM_GETCELLBCOLOR:=0x474, ZGM_GETCELLFONT:=0x475, ZGM_GETCELLMARK:=0x476, ZGM_GETCELLICON:=0x477, ZGM_SETROWTYPE:=0x478, ZGM_SETROWJUSTIFY:=0x479, ZGM_SETROWFCOLOR:=0x47a, ZGM_SETROWBCOLOR:=0x47b, ZGM_SETROWFONT:=0x47c, ZGM_SETROWMARK:=0x47d, ZGM_SETROWICON:=0x47e, ZGM_SETROWEDIT:=0x47f, ZGM_SEARCHEACHKEYSTROKE:=0x480, ZGM_COMBOCLEAR:=0x481, ZGM_COMBOADDSTRING:=0x482, ZGM_CLEARMARKONSELECT:=0x483, ZGM_SETCOLICON:=0x484, ZGM_SETCOLMARK:=0x485, ZGM_SETDEFAULTTYPE:=0x486, ZGM_SETDEFAULTMARK:=0x487, ZGM_SETDEFAULTICON:=0x488, ZGM_SORTSECONDARY:=0x489, ZGM_GETSORTCOLUMN:=0x48a, ZGM_GETCURSORROW:=0x48b
        static ZGM_GETCURSORCOL:=0x48c, ZGM_GETSIZEOFCELL:=0x48d, ZGM_GETCELLDOUBLE:=0x48e, ZGM_SETCELLDOUBLE:=0x48f, ZGM_SETDEFAULTNUMWIDTH:=0x490, ZGM_SETDEFAULTNUMPRECISION:=0x491, ZGM_SETCELLNUMWIDTH:=0x492, ZGM_SETCOLNUMWIDTH:=0x493, ZGM_SETROWNUMWIDTH:=0x494, ZGM_SETCELLNUMPRECISION:=0x495, ZGM_SETCOLNUMPRECISION:=0x496, ZGM_SETROWNUMPRECISION:=0x497, ZGM_SETCELLINT:=0x498, ZGM_GETCELLINT:=0x499, ZGM_INTERPRETBOOL:=0x49a, ZGM_INTERPRETNUMERIC:=0x49b, ZGM_SETCOLOR:=0x49d, ZGM_GETCOLOR:=0x49e, ZGM_SETFONT:=0x49f, ZGM_GETFONT:=0x4a0, ZGM_SETPRINTPOINTSIZE:=0x4a1, ZGM_GETROWSALLOCATED:=0x4a2, ZGM_GETCELLSALLOCATED:=0x4a3, ZGM_GETSIZEOFGRID:=0x4a5, ZGM_PRINT:=0x4a6, ZGM_SETITEMDATA:=0x4a7, ZGM_GETITEMDATA:=0x4a8, ZGM_ALTERNATEROWCOLORS:=0x4a9, ZGM_UNLOCK:=0x4aa, ZGM_QUERYBUILD:=0x4ab, ZGM_SAVEGRID:=0x4ac, ZGM_LOADGRID:=0x4ad, ZGM_GETCELLTEXTLENGTH:=0x4ae, ZGM_AUTOSIZECOLUMN:=0x4af, ZGM_ISGRIDDIRTY:=0x4b0, ZGM_INTERPRETDATES:=0x4b1, ZGM_SETCELLCDATE:=0x4b2, ZGM_SETCELLJDATE:=0x4b3
        static ZGM_GETJDATE:=0x4b4, ZGM_GETCDATE:=0x4b5, ZGM_GETTODAY:=0x4b6, ZGM_SETREGCDATE:=0x4b7, ZGM_SETREGJDATE:=0x4b8, ZGM_GETREGDATEFORMATTED:=0x4b9, ZGM_ISDATEVALID:=0x4ba, ZGM_GETREGDATEYEAR:=0x4bb, ZGM_GETREGDATEMONTH:=0x4bc, ZGM_GETREGDATEDAY:=0x4bd, ZGM_GETREGDATEDOW:=0x4be, ZGM_GETDOW:=0x4bf, ZGM_GETDOWLONG:=0x4c0, ZGM_GETDOWSHORT:=0x4c1, ZGM_GETREGDATEDOY:=0x4c2, ZGM_GETREGDATEWOY:=0x4c3, ZGM_GETDOY:=0x4c4, ZGM_GETWOY:=0x4c5, ZGM_GETLASTBUTTONPRESSED:=0x4c6, ZGM_ENABLECOLUMNSELECT:=0x4c7, ZGM_KEEP3DONLOSTFOCUS:=0x4c8, ZGM_SETLOSTFOCUSHIGHLIGHTCOLOR:=0x4c9, ZGM_GOTOFIRSTONSEARCH:=0x4ca, ZGM_GETSELECTEDROW:=0x4cb, ZGM_GETSELECTEDCOL:=0x4cc, ZGM_COPYCELL:=0x4cd, ZGM_GETCOLUMNORDER:=0x4ce, ZGM_GETDISPLAYPOSITIONOFCOLUMN:=0x4cf, ZGM_GETCOLUMNINDISPLAYPOSITION:=0x4d0, ZGM_SCROLLDOWN:=0x4d1, ZGM_SCROLLUP:=0x4d2, ZGM_SCROLLRIGHT:=0x4d3, ZGM_SCROLLLEFT:=0x4d4, ZGM_SETBACKGROUNDBITMAP:=0x4d5, ZGM_ENABLECOPY:=0x4d6, ZGM_ENABLECUT:=0x4d7, ZGM_ENABLEPASTE:=0x4d8, ZGM_EXPANDROWSONPASTE:=0x4d9
        static ZGM_SETCELLRESTRICTION:=0x4da, ZGM_SETROWRESTRICTION:=0x4db, ZGM_SETCOLRESTRICTION:=0x4dc, ZGM_SETDEFAULTRESTRICTION:=0x4dd, ZGM_GETCELLRESTRICTION:=0x4de, ZGM_SETROWNUMBERFONT:=0x4df, ZGM_SETGRIDBGCOLOR:=0x4e0, ZGM_GETCELLFORMAT:=0x4e1, ZGM_SHOWCOPYMENU:=0x4e2, ZGM_ADJUSTHEADERS:=0x4e3, ZGM_ENABLETRANSPARENTHIGHLIGHTING:=0x4e4, ZGM_GETCELLADVANCE:=0x4e5, ZGM_SETCELLADVANCE:=0x4e6, ZGM_SETCOLADVANCE:=0x4e7, ZGM_SETROWADVANCE:=0x4e8, ZGM_SETDEFAULTADVANCE:=0x4e9, ZGM_GETCELLINTSAFE:=0x4ea, ZGM_GETROWNUMBERSWIDTH:=0x4eb, ZGM_SPANCOLUMN:=0x4ec, ZGM_GETAUTOINCREASESIZE:=0x4ed

        ; Cell Types
        static BOOL_FALSE:=0, BOOL_TRUE:=1, TEXT:=2, NUMERIC:=3, DATE:=4, BUTTON:=5

        ; Notifications
        static ZGN_MOUSEMOVE := 1, ZGN_SORT := 2, ZGN_CURSORCELLCHANGED := 3, ZGN_EDITEND := 4, ZGN_RIGHTCLICK := 5, ZGN_LOADCOMBO := 6, ZGN_INSERT := 7, ZGN_DELETE := 8, ZGN_F1 := 9, ZGN_F2 := 10, ZGN_F3 := 11, ZGN_F4 := 12, ZGN_F5 := 13, ZGN_F6 := 14, ZGN_F7 := 15, ZGN_F8 := 16, ZGN_EDITCOMPLETE := 17, ZGN_DOUBLECLICKREADONLY := 18, ZGN_DOUBLECLICKFIXEDCOLUMN := 19, ZGN_SORTCOMPLETE := 20, ZGN_BUTTONPRESSED := 21, ZGN_CELLCLICKED := 22, ZGN_COLUMNMOVED := 23, ZGN_PASTECOMPLETE := 24, ZGN_GOTFOCUS := 25, ZGN_LOSTFOCUS := 26, ZGN_ROWSELECTED := 27

        ; File Export flags
        static EF_FILENAMESUPPLIED := 0x01, EF_DELIMITERSUPPLIED := 0x02, EF_SILENT := 0x04, EF_NOHEADER := 0x08

        ; Text Justification Constants
        static LEFT_SINGLE := 1, CENTER_SINGLE := 4, RIGHT_SINGLE := 7, LEFT_MULTI := 9, CENTER_MULTI := 10, RIGHT_MULTI := 11

        __Call(msg, ByRef wParam := 0, ByRef lParam := 0, Params*) {
            ; we could let integer method calls through, but then we would have to verify them somehow as well
            ; I prefer to define them once and use the message names.  Makes the consumers code easier to reason about.
            if (Type(msg) = "Integer") {
                throw Exception(this.__class "::" msg "`n`nPlease use the defined static variables on the " this.__class " instance for sending messages to the ZeeGrid control.`n`n`tFor example, <instance>.MarkText(4)", -1)
            }
            ; msg is a string but ZeeGrid.ZeeGridBase does not have a key defined for "SCI_" msg
            else if (Type(msg) = "String" && !this.ZeeGridBase.HasKey(newMsg := "ZGM_" msg)) {
                throw Exception(this.__class "::" msg "`n`nCall to non-existent method", -1)
            }

            If (wParam && Type(wParam) = "String" && !isObject(wParam)) {
                VarSetCapacity(wParamA, StrPut(wParam, "UTF-8"))
                StrPut(wParam, &wParamA, "UTF-8")
                wParam := &wParamA
            }

            ; If the second parameter to any method call on ZeeGrid is a string and you need to pass an address,
            ; then pass true/1 as the third parameter
            ; same as how the first parameter gets handled if its a string
            If (Params[1]) {
                VarSetCapacity(lParamA, StrPut(lParam, "UTF-8"))
                StrPut(lParam, &lParamA, "UTF-8")
                lParam := &lParamA
            }

            ; pass the value of this.ZeeGridBase[newMsg] since we already
            return this.__sendGrid(this.ZeeGridBase[newMsg], wParam, lParam)
        }

        /**
         * Called if a property is read from a ZeeGrid instance but it is not defined on that instance
         * Checks if <instance>.ZeeGridBase has a property of the same name.
         * If it does, return its value, otherwise throw an exception.
         * @param {key}: The requested property from the instance of ZeeGrid
         * @return: Value of that property from ZeeGrid.ZeeGridBase
         */
        __Get(key) {
            if (!this.ZeeGridBase.HasKey(key)) {
                throw Exception(this.__class "::" key "`n`nUnknown property!", -1)
            }

            return this.ZeeGridBase[key]
        }
    }
}