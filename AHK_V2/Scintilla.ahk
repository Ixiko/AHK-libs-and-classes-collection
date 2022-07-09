/**
 * Class to add Scintilla Edit controls to AHK Guis
 * For AHK v2. Tested with version 2.0-a100-52515e2 and x64 SciLexer.dll
 * @auther: kczx3 (adapted from RaptorX and Alguimist's version)
 * @modified: 3/24/19
 * @requires: SciLexer.dll
 * @see: https://www.scintilla.org/ScintillaDoc.html for information about the Scintilla Control
 */
Class Scintilla extends Scintilla.ScintillaBase {
    /**
     * Static variables - shared by all instances of the Scintilla class
     */
    static controlCount := 0
    static DllPath := "SciLexer.dll"
    
    /**
     * Instance variables
     */
    hWnd            := 0        ; Component Handle
    docs            := []
    currentDoc      := 0
    
    ; Following are all set within the __sciNotify callback method
    idFrom          := 0        ; The handle from which the notification was sent
    scnCode         := 0        ; The SCN_* notification code
    position        := 0        ; SCN_STYLENEEDED, SCN_DOUBLECLICK, SCN_MODIFIED, SCN_MARGINCLICK
                                ; SCN_NEEDSHOWN, SCN_DWELLSTART, SCN_DWELLEND, SCN_CALLTIPCLICK
                                ; SCN_HOTSPOTCLICK, SCN_HOTSPOTDOUBLECLICK, SCN_HOTSPOTRELEASECLICK
                                ; SCN_INDICATORCLICK, SCN_INDICATORRELEASE
                                ; SCN_USERLISTSELECTION, SCN_AUTOCSELECTION

    ch              := 0        ; SCN_CHARADDED, SCN_KEY
    modifiers       := 0        ; SCN_KEY, SCN_DOUBLECLICK, SCN_HOTSPOTCLICK, SCN_HOTSPOTDOUBLECLICK
                                ; SCN_HOTSPOTRELEASECLICK, SCN_INDICATORCLICK, SCN_INDICATORRELEASE

    modType         := 0        ; SCN_MODIFIED
    text            := 0        ; SCN_MODIFIED, SCN_USERLISTSELECTION, SCN_AUTOCSELECTION, SCN_URIDROPPED
    length          := 0        ; SCN_MODIFIED
    linesAdded      := 0        ; SCN_MODIFIED
    macMessage      := 0        ; SCN_MACRORECORD
    macwParam       := 0        ; SCN_MACRORECORD
    maclParam       := 0        ; SCN_MACRORECORD
    line            := 0        ; SCN_MODIFIED
    foldLevelNow    := 0        ; SCN_MODIFIED
    foldLevelPrev   := 0        ; SCN_MODIFIED
    margin          := 0        ; SCN_MARGINCLICK
    listType        := 0        ; SCN_USERLISTSELECTION
    x               := 0        ; SCN_DWELLSTART, SCN_DWELLEND
    y               := 0        ; SCN_DWELLSTART, SCN_DWELLEND
    token           := 0        ; SCN_MODIFIED with SC_MOD_CONTAINER
    annotLinesAdded := 0        ; SCN_MODIFIED with SC_MOD_CHANGEANNOTATION
    updated         := false    ; SCN_UPDATEUI

    __New(gui, opts := "", DllPath := "", Style := 0x50010000, ExStyle := 0x200) {
        ; store reference to the parent gui object
        this.gui := gui
        
        if (DllPath) {
            this.DllPath := DllPath
        }
        
        ; Load the SciLexer dll if this is the first instance of Scintilla
        If (!this.controlCount) {
            If !(this._handle := DllCall("LoadLibrary", "Str", this.DllPath)) {
                scriptName := StrSplit(A_ScriptName, ".")[1]
                MsgBox(scriptName . " - Error " . A_LastError, "Failed to load library DllPath.", 0x10)
                Return
            }
        }
        
        ; Store reference to the GuiControl object
        this.ctrl := this.gui.addCustom("ClassScintilla " opts " " Style . (ExStyle ? " +E" ExStyle : ""))
        
        this.hwnd := this.ctrl.hwnd
        
        ; Used for sending messages directly to the control
        this.df := SendMessage(this.SCI_GETDIRECTFUNCTION, 0, 0, this.hWnd)
        this.dp := SendMessage(this.SCI_GETDIRECTPOINTER, 0, 0, this.hWnd)
        
        this.currentDoc := this.docs.push(this.GetDocPointer())
        
        ; increment control count, which is seen by all instances of Scintilla
        this.controlCount++
    }
    
    __Delete() {
        ; decrement control counter
        this.controlCount--
        
        ; If no more Scintilla controls present, then free the library
        If (this.controlCount = 0) {
            DllCall("FreeLibrary", "Ptr", this._handle)
        }
    }
    
    addDocument(cb := false) {
        ; add a ref to the current doc before switching to a new one
        this.AddRefDocument(0, this.docs[this.currentDoc])
        
        this.SetDocPointer(0, 0)
        
        ; Save the pointer to the newly created doc
        this.currentDoc := this.docs.push(this.GetDocPointer())
        
        if (cb && Type(cb) ~= "Func|Closure") {
            cb.Call(this)
        }
    }
    
    switchDocument(index, cb := false) {
        ; This shouldn't ever happen since we disable the buttons but just make sure that the index is valid
        if (this.docs.HasKey(index)) {
            ; add a ref to the current doc before switching
            this.AddRefDocument(0, this.docs[this.currentDoc])
            
            ; change the pointer
            this.SetDocPointer(0, this.docs[index])
            
            this.currentDoc := index
            
            ; release the ref that we were holding to the now current doc so that Scintilla is the sole owner
            this.ReleaseDocument(0, this.docs[index])
            
            if (cb && Type(cb) ~= "Func|Closure") {
                cb.Call(this)
            }
        }
    }
    
    deleteDocument(index, cb := false) {
        isCurrentDoc := this.currentDoc = index
        
        ; save our pointer of the current doc locally to make things easier
        prevDoc := this.docs[index]
        
        ; determine which doc we are going to show after deleting the current one
        ; If we are deleting the last doc, then show the previous one
        ; if we are deleting any other doc, then show the document whose pointer will now occupy the currentDoc position of sciDocs
        showNext := isCurrentDoc || this.currentDoc = this.docs.length() ? this.currentDoc - 1 : this.currentDoc

        ; if (isCurrentDoc) {
            ; Store our own ref to the current document
            this.AddRefDocument(0, this.docs[index])
        ; }
        
        ; Remove our current doc from tracking
        this.docs.RemoveAt(index)
        
        if (isCurrentDoc) {
            ; Change the current document to the next one
            this.SetDocPointer(0, this.docs.HasKey(showNext) ? this.docs[showNext] : 0)
        }
        
        ; release our ref from the previous document which drops the ref count to 0 and clears the memory
        ; You should never drop the count to 0 if the Scintilla control is the last to own the document
        this.ReleaseDocument(0, prevDoc)
        
        this.currentDoc := showNext
        
        if (cb && Type(cb) ~= "Func|Closure") {
            cb.Call(this)
        }
    }
    
    /**
     * Sends messages to the Scintilla control. Calls them via direct pointer and direct function that were retrieved in __New
     * It is not recommended to call this method directly.  Instead, call the Scintilla message as a method on the Scintilla instance (minus the prefix of "SCI_")
     * @param {msg}: The message number to send.  These are defined as static variables on Scintilla.ScintillaBase
     * @param {wParam}: A number or address to a string buffer to be sent as the wParam
     * @param {lParam}: A number or address to a string buffer to be sent as the lParam
     * @return: The same value as documented by the called Scintilla message
    */
    __sendEditor(msg := 0, wParam := 0, lParam := 0) {
        ; The fast way to control Scintilla
        return DllCall(this.df            ; DIRECT FUNCTION
                      ,"UInt" , this.dp    ; DIRECT POINTER
                      ,"UInt" , msg
                      ,"Int"  , wParam
                      ,"Int"  , lParam)
    }
    
    /**
     * This is automatically called first for any messages that the consumer wants to monitor via this.OnNotify
     * It extracts several items from the lParam onto the instance as variables to later be used in the user-defined callback
      * @param {ctrl}: The GuiControl instance (the Custom control added to the gui in __New)
      * @param {lParam}: The lParam from WM_NOTIFY
      * @param {cb}: The user-defined function object which came from the consumer calling <instance>.OnNotify(notification, cb)
    */
    __sciNotify(ctrl, lParam, cb) {
        Static x64 := A_PtrSize == 8
        Static OffPosition := A_Ptrsize * 3
        Static OffCh := x64 ? 28 : 16
        Static OffModifiers := x64 ? 32 : 20
        Static OffModType := x64 ? 36 : 24
        Static OffText := x64 ? 40 : 28
        Static OffLength := x64 ? 48 : 32
        Static OffLinesAdded := x64 ? 52 : 36
        Static OffLine := x64 ? 80 : 52
        Static OffMargin := x64 ? 92 : 64
        Static OffListType := x64 ? 96 : 68
        Static OffX := x64 ? 100 : 72
        Static OffY := x64 ? 104 : 76
        Static OffUpdated := x64 ? 116 : 88
        static offListCompletionMethod := x64 ? 120 : 92
        
        this.IdFrom          := NumGet(lParam + A_Ptrsize * 1)
        this.SCNCode         := NumGet(lParam + A_Ptrsize * 2)

        this.Position        := NumGet(lParam + OffPosition)
        this.Ch              := NumGet(lParam + OffCh)
        this.Modifiers       := NumGet(lParam + OffModifiers)
        this.ModType         := NumGet(lParam + OffModType)
        this.Text            := NumGet(lParam + OffText)
        this.Length          := NumGet(lParam + OffLength)
        this.LinesAdded      := NumGet(lParam + OffLinesAdded)

        ;this.macMessage      := NumGet(lParam + (x64 ? 56 : 40)) ; SCN_MACRORECORD
        ;this.macwParam       := NumGet(lParam + (x64 ? 64 : 44))
        ;this.maclParam       := NumGet(lParam + (x64 ? 72 : 48))

        this.Line            := NumGet(lParam + OffLine)
        ;this.foldLevelNow    := NumGet(lParam + (x64 ? 84 : 56))
        ;this.foldLevelPrev   := NumGet(lParam + (x64 ? 88 : 60))
        this.Margin          := NumGet(lParam + OffMargin)
        this.ListType        := NumGet(lParam + OffListType)
        this.X               := NumGet(lParam + OffX)
        this.Y               := NumGet(lParam + OffY)

        ;this.token           := NumGet(lParam + (x64 ? 108 : 80))
        ;this.annotLinesAdded := NumGet(lParam + (x64 ? 112 : 84))
        this.Updated         := NumGet(lParam + OffUpdated)
        this.listCompletionMethod := NumGet(lParam + offListCompletionMethod)

        ; Call user defined Notify function and passes object to it as last parameter
        cb.call(ctrl, lParam)
    }
    
    /**
     * Allows for passing any function object that implements a Call method to handle the passed notification code
     * Every notification that is monitored via this method will first go through this.__sciNotify which sets several instance variables to later be used
     * The user passed function oject is then called.
     * @param {notification}: The notification for cb to be called in response to.  Use <instance of Scintilla>.<notification>.  E.g. sci.SCN_CHARADDED
     * @param {cb}: A function object to be called.  It is passed the GuiControl instance and the lParam from the WM_NOTIFY message.
     */
    OnNotify(notification, cb) {
        this.ctrl.OnNotify(notification, (ctrl, l) => this.__sciNotify(ctrl, l, cb))
    }
    
    /**
     * Base nested class for Scintilla
     * @description:
     *      Handles all method calls on instances of Scintilla where the method is not defined on the Scintilla class
     *      If the method name is found as a static variable defined on Scintilla.ScintillaBase, then we invoke <instance of Scintilla>.__sendEditor
     *      passing the value of the static variable whose name was the method called on the Scintilla instance as the first parameter.
     *
     *      This class will throw an error on any method call it receives where
     *      the method name called on the instance of Scintilla is not a static variable of Scintilla.ScintillaBase
     */
    class ScintillaBase {
        ; Main Scintilla functions
        static SCI_ADDTEXT:=2001,SCI_ADDSTYLEDTEXT:=2002,SCI_INSERTTEXT:=2003,SCI_CLEARALL:=2004,SCI_CLEARDOCUMENTSTYLE:=2005,SCI_GETLENGTH:=2006,SCI_GETCHARAT:=2007,SCI_GETCURRENTPOS:=2008,SCI_GETANCHOR:=2009,SCI_GETSTYLEAT:=2010,SCI_REDO:=2011,SCI_SETUNDOCOLLECTION:=2012,SCI_SELECTALL:=2013,SCI_SETSAVEPOINT:=2014,SCI_GETSTYLEDTEXT:=2015,SCI_CANREDO:=2016,SCI_MARKERLINEFROMHANDLE:=2017,SCI_MARKERDELETEHANDLE:=2018,SCI_GETUNDOCOLLECTION:=2019,SCI_GETVIEWWS:=2020,SCI_SETVIEWWS:=2021,SCI_POSITIONFROMPOINT:=2022,SCI_POSITIONFROMPOINTCLOSE:=2023,SCI_GOTOLINE:=2024,SCI_GOTOPOS:=2025,SCI_SETANCHOR:=2026,SCI_GETCURLINE:=2027,SCI_GETENDSTYLED:=2028,SCI_CONVERTEOLS:=2029,SCI_GETEOLMODE:=2030,SCI_SETEOLMODE:=2031
        static SCI_STARTSTYLING:=2032,SCI_SETSTYLING:=2033,SCI_GETBUFFEREDDRAW:=2034,SCI_SETBUFFEREDDRAW:=2035,SCI_SETTABWIDTH:=2036,SCI_GETTABWIDTH:=2121,SCI_SETCODEPAGE:=2037,SCI_SETUSEPALETTE:=2039,SCI_MARKERDEFINE:=2040,SCI_MARKERSETFORE:=2041,SCI_MARKERSETBACK:=2042,SCI_MARKERADD:=2043,SCI_MARKERDELETE:=2044,SCI_MARKERDELETEALL:=2045,SCI_MARKERGET:=2046,SCI_MARKERNEXT:=2047,SCI_MARKERPREVIOUS:=2048,SCI_MARKERDEFINEPIXMAP:=2049,SCI_MARKERADDSET:=2466,SCI_MARKERSETALPHA:=2476,SCI_SETMARGINTYPEN:=2240,SCI_GETMARGINTYPEN:=2241,SCI_SETMARGINWIDTHN:=2242,SCI_GETMARGINWIDTHN:=2243,SCI_SETMARGINMASKN:=2244,SCI_GETMARGINMASKN:=2245,SCI_SETMARGINSENSITIVEN:=2246,SCI_GETMARGINSENSITIVEN:=2247,SCI_STYLECLEARALL:=2050
        static SCI_STYLESETFORE:=2051,SCI_STYLESETBACK:=2052,SCI_STYLESETBOLD:=2053,SCI_STYLESETITALIC:=2054,SCI_STYLESETSIZE:=2055,SCI_STYLESETFONT:=2056,SCI_STYLESETEOLFILLED:=2057,SCI_STYLEGETFORE:=2481,SCI_STYLEGETBACK:=2482,SCI_STYLEGETBOLD:=2483,SCI_STYLEGETITALIC:=2484,SCI_STYLEGETSIZE:=2485,SCI_STYLEGETFONT:=2486,SCI_STYLEGETEOLFILLED:=2487,SCI_STYLEGETUNDERLINE:=2488,SCI_STYLEGETCASE:=2489,SCI_STYLEGETCHARACTERSET:=2490,SCI_STYLEGETVISIBLE:=2491,SCI_STYLEGETCHANGEABLE:=2492,SCI_STYLEGETHOTSPOT:=2493,SCI_STYLERESETDEFAULT:=2058,SCI_STYLESETUNDERLINE:=2059,SCI_STYLESETCASE:=2060,SCI_STYLESETCHARACTERSET:=2066,SCI_STYLESETHOTSPOT:=2409,SCI_SETSELFORE:=2067,SCI_SETSELBACK:=2068,SCI_GETSELALPHA:=2477,SCI_SETSELALPHA:=2478
        static SCI_SETCARETFORE:=2069,SCI_ASSIGNCMDKEY:=2070,SCI_CLEARCMDKEY:=2071,SCI_CLEARALLCMDKEYS:=2072,SCI_SETSTYLINGEX:=2073,SCI_STYLESETVISIBLE:=2074,SCI_GETCARETPERIOD:=2075,SCI_SETCARETPERIOD:=2076,SCI_SETWORDCHARS:=2077,SCI_BEGINUNDOACTION:=2078,SCI_ENDUNDOACTION:=2079,SCI_INDICSETSTYLE:=2080,SCI_INDICGETSTYLE:=2081,SCI_INDICSETFORE:=2082,SCI_INDICGETFORE:=2083,SCI_SETWHITESPACEFORE:=2084,SCI_SETWHITESPACEBACK:=2085,SCI_SETSTYLEBITS:=2090,SCI_GETSTYLEBITS:=2091,SCI_SETLINESTATE:=2092,SCI_GETLINESTATE:=2093,SCI_GETMAXLINESTATE:=2094,SCI_GETCARETLINEVISIBLE:=2095,SCI_SETCARETLINEVISIBLE:=2096,SCI_GETCARETLINEBACK:=2097,SCI_SETCARETLINEBACK:=2098,SCI_STYLESETCHANGEABLE:=2099
        static SCI_AUTOCSHOW:=2100,SCI_AUTOCCANCEL:=2101,SCI_AUTOCACTIVE:=2102,SCI_AUTOCPOSSTART:=2103,SCI_AUTOCCOMPLETE:=2104,SCI_AUTOCSTOPS:=2105,SCI_AUTOCSETSEPARATOR:=2106,SCI_AUTOCGETSEPARATOR:=2107,SCI_AUTOCSELECT:=2108,SCI_AUTOCSETCANCELATSTART:=2110,SCI_AUTOCGETCANCELATSTART:=2111,SCI_AUTOCSETFILLUPS:=2112,SCI_AUTOCSETCHOOSESINGLE:=2113,SCI_AUTOCGETCHOOSESINGLE:=2114,SCI_AUTOCSETIGNORECASE:=2115,SCI_AUTOCGETIGNORECASE:=2116,SCI_USERLISTSHOW:=2117,SCI_AUTOCSETAUTOHIDE:=2118,SCI_AUTOCGETAUTOHIDE:=2119,SCI_AUTOCSETDROPRESTOFWORD:=2270,SCI_AUTOCGETDROPRESTOFWORD:=2271,SCI_REGISTERIMAGE:=2405,SCI_CLEARREGISTEREDIMAGES:=2408,SCI_AUTOCGETTYPESEPARATOR:=2285,SCI_AUTOCSETTYPESEPARATOR:=2286
        static SCI_AUTOCSETMAXWIDTH:=2208,SCI_AUTOCGETMAXWIDTH:=2209,SCI_AUTOCSETMAXHEIGHT:=2210,SCI_AUTOCGETMAXHEIGHT:=2211,SCI_SETINDENT:=2122,SCI_GETINDENT:=2123,SCI_SETUSETABS:=2124,SCI_GETUSETABS:=2125,SCI_SETLINEINDENTATION:=2126,SCI_GETLINEINDENTATION:=2127,SCI_GETLINEINDENTPOSITION:=2128,SCI_GETCOLUMN:=2129,SCI_SETHSCROLLBAR:=2130,SCI_GETHSCROLLBAR:=2131,SCI_SETINDENTATIONGUIDES:=2132,SCI_GETINDENTATIONGUIDES:=2133,SCI_SETHIGHLIGHTGUIDE:=2134,SCI_GETHIGHLIGHTGUIDE:=2135,SCI_GETLINEENDPOSITION:=2136,SCI_GETCODEPAGE:=2137,SCI_GETCARETFORE:=2138,SCI_GETUSEPALETTE:=2139,SCI_GETREADONLY:=2140,SCI_SETCURRENTPOS:=2141,SCI_SETSELECTIONSTART:=2142,SCI_GETSELECTIONSTART:=2143,SCI_SETSELECTIONEND:=2144,SCI_GETSELECTIONEND:=2145
        static SCI_SETPRINTMAGNIFICATION:=2146,SCI_GETPRINTMAGNIFICATION:=2147,SCI_SETPRINTCOLORMODE:=2148,SCI_GETPRINTCOLORMODE:=2149,SCI_FINDTEXT:=2150,SCI_FORMATRANGE:=2151,SCI_GETFIRSTVISIBLELINE:=2152,SCI_GETLINE:=2153,SCI_GETLINECOUNT:=2154,SCI_SETMARGINLEFT:=2155,SCI_GETMARGINLEFT:=2156,SCI_SETMARGINRIGHT:=2157,SCI_GETMARGINRIGHT:=2158,SCI_GETMODIFY:=2159,SCI_SETSEL:=2160,SCI_GETSELTEXT:=2161,SCI_GETTEXTRANGE:=2162,SCI_HIDESELECTION:=2163,SCI_POINTXFROMPOSITION:=2164,SCI_POINTYFROMPOSITION:=2165,SCI_LINEFROMPOSITION:=2166,SCI_POSITIONFROMLINE:=2167,SCI_LINESCROLL:=2168,SCI_SCROLLCARET:=2169,SCI_REPLACESEL:=2170,SCI_SETREADONLY:=2171,SCI_NULL:=2172,SCI_CANPASTE:=2173,SCI_CANUNDO:=2174,SCI_EMPTYUNDOBUFFER:=2175
        static SCI_UNDO:=2176,SCI_CUT:=2177,SCI_COPY:=2178,SCI_PASTE:=2179,SCI_CLEAR:=2180,SCI_SETTEXT:=2181,SCI_GETTEXT:=2182,SCI_GETTEXTLENGTH:=2183,SCI_GETDIRECTFUNCTION:=2184,SCI_GETDIRECTPOINTER:=2185,SCI_SETOVERTYPE:=2186,SCI_GETOVERTYPE:=2187,SCI_SETCARETWIDTH:=2188,SCI_GETCARETWIDTH:=2189,SCI_SETTARGETSTART:=2190,SCI_GETTARGETSTART:=2191,SCI_SETTARGETEND:=2192,SCI_GETTARGETEND:=2193,SCI_REPLACETARGET:=2194,SCI_REPLACETARGETRE:=2195,SCI_SEARCHINTARGET:=2197,SCI_SETSEARCHFLAGS:=2198,SCI_GETSEARCHFLAGS:=2199,SCI_CALLTIPSHOW:=2200,SCI_CALLTIPCANCEL:=2201,SCI_CALLTIPACTIVE:=2202,SCI_CALLTIPPOSSTART:=2203,SCI_CALLTIPSETHLT:=2204,SCI_CALLTIPSETBACK:=2205,SCI_CALLTIPSETFORE:=2206,SCI_CALLTIPSETFOREHLT:=2207,SCI_CALLTIPUSESTYLE:=2212
        static SCI_VISIBLEFROMDOCLINE:=2220,SCI_DOCLINEFROMVISIBLE:=2221,SCI_WRAPCOUNT:=2235,SCI_SETFOLDLEVEL:=2222,SCI_GETFOLDLEVEL:=2223,SCI_GETLASTCHILD:=2224,SCI_GETFOLDPARENT:=2225,SCI_SHOWLINES:=2226,SCI_HIDELINES:=2227,SCI_GETLINEVISIBLE:=2228,SCI_SETFOLDEXPANDED:=2229,SCI_GETFOLDEXPANDED:=2230,SCI_TOGGLEFOLD:=2231,SCI_ENSUREVISIBLE:=2232,SCI_SETFOLDFLAGS:=2233,SCI_ENSUREVISIBLEENFORCEPOLICY:=2234,SCI_SETTABINDENTS:=2260,SCI_GETTABINDENTS:=2261,SCI_SETBACKSPACEUNINDENTS:=2262,SCI_GETBACKSPACEUNINDENTS:=2263,SCI_SETMOUSEDWELLTIME:=2264,SCI_GETMOUSEDWELLTIME:=2265,SCI_WORDSTARTPOSITION:=2266,SCI_WORDENDPOSITION:=2267,SCI_SETWRAPMODE:=2268,SCI_GETWRAPMODE:=2269,SCI_SETWRAPVISUALFLAGS:=2460,SCI_GETWRAPVISUALFLAGS:=2461
        static SCI_SETWRAPVISUALFLAGSLOCATION:=2462,SCI_GETWRAPVISUALFLAGSLOCATION:=2463,SCI_SETWRAPSTARTINDENT:=2464,SCI_GETWRAPSTARTINDENT:=2465,SCI_SETLAYOUTCACHE:=2272,SCI_GETLAYOUTCACHE:=2273,SCI_SETSCROLLWIDTH:=2274,SCI_GETSCROLLWIDTH:=2275,SCI_TEXTWIDTH:=2276,SCI_SETENDATLASTLINE:=2277,SCI_GETENDATLASTLINE:=2278,SCI_TEXTHEIGHT:=2279,SCI_SETVSCROLLBAR:=2280,SCI_GETVSCROLLBAR:=2281,SCI_APPENDTEXT:=2282,SCI_GETTWOPHASEDRAW:=2283,SCI_SETTWOPHASEDRAW:=2284,SCI_TARGETFROMSELECTION:=2287,SCI_LINESJOIN:=2288,SCI_LINESSPLIT:=2289,SCI_SETFOLDMARGINCOLOR:=2290,SCI_SETFOLDMARGINHICOLOR:=2291,SCI_ZOOMIN:=2333,SCI_ZOOMOUT:=2334,SCI_MOVECARETINSIDEVIEW:=2401,SCI_LINELENGTH:=2350,SCI_BRACEHIGHLIGHT:=2351,SCI_BRACEBADLIGHT:=2352,SCI_BRACEMATCH:=2353
        static SCI_GETVIEWEOL:=2355,SCI_SETVIEWEOL:=2356,SCI_GETDOCPOINTER:=2357,SCI_SETDOCPOINTER:=2358,SCI_SETMODEVENTMASK:=2359,SCI_GETEDGECOLUMN:=2360,SCI_SETEDGECOLUMN:=2361,SCI_GETEDGEMODE:=2362,SCI_SETEDGEMODE:=2363,SCI_GETEDGECOLOR:=2364,SCI_SETEDGECOLOR:=2365,SCI_SEARCHANCHOR:=2366,SCI_SEARCHNEXT:=2367,SCI_SEARCHPREV:=2368,SCI_LINESONSCREEN:=2370,SCI_USEPOPUP:=2371,SCI_SELECTIONISRECTANGLE:=2372,SCI_SETZOOM:=2373,SCI_GETZOOM:=2374,SCI_CREATEDOCUMENT:=2375,SCI_ADDREFDOCUMENT:=2376,SCI_RELEASEDOCUMENT:=2377,SCI_GETMODEVENTMASK:=2378,SCI_SETFOCUS:=2380,SCI_GETFOCUS:=2381,SCI_SETSTATUS:=2382,SCI_GETSTATUS:=2383,SCI_SETMOUSEDOWNCAPTURES:=2384,SCI_GETMOUSEDOWNCAPTURES:=2385,SCI_SETCURSOR:=2386,SCI_GETCURSOR:=2387,SCI_CHANGEINSERTION:=2672
        static SCI_SETCONTROLCHARSYMBOL:=2388,SCI_GETCONTROLCHARSYMBOL:=2389,SCI_SETVISIBLEPOLICY:=2394,SCI_SETXOFFSET:=2397,SCI_GETXOFFSET:=2398,SCI_CHOOSECARETX:=2399,SCI_GRABFOCUS:=2400,SCI_SETXCARETPOLICY:=2402,SCI_SETYCARETPOLICY:=2403,SCI_SETPRINTWRAPMODE:=2406,SCI_GETPRINTWRAPMODE:=2407,SCI_SETHOTSPOTACTIVEFORE:=2410,SCI_SETHOTSPOTACTIVEBACK:=2411,SCI_SETHOTSPOTACTIVEUNDERLINE:=2412,SCI_SETHOTSPOTSINGLELINE:=2421,SCI_POSITIONBEFORE:=2417,SCI_POSITIONAFTER:=2418,SCI_COPYRANGE:=2419,SCI_COPYTEXT:=2420,SCI_SETSELECTIONMODE:=2422,SCI_GETSELECTIONMODE:=2423,SCI_GETLINESELSTARTPOSITION:=2424,SCI_GETLINESELENDPOSITION:=2425,SCI_SETWHITESPACECHARS:=2443,SCI_SETCHARSDEFAULT:=2444,SCI_AUTOCGETCURRENT:=2445,SCI_ALLOCATE:=2446,SCI_REGISTERRGBAIMAGE:=2627,SCI_RGBAIMAGESETWIDTH:=2624,SCI_RGBAIMAGESETHEIGHT:=2625
        static SCI_TARGETASUTF8:=2447,SCI_SETLENGTHFORENCODE:=2448,SCI_ENCODEDFROMUTF8:=2449,SCI_FINDCOLUMN:=2456,SCI_GETCARETSTICKY:=2457,SCI_SETCARETSTICKY:=2458,SCI_TOGGLECARETSTICKY:=2459,SCI_SETPASTECONVERTENDINGS:=2467,SCI_GETPASTECONVERTENDINGS:=2468,SCI_SETCARETLINEBACKALPHA:=2470,SCI_GETCARETLINEBACKALPHA:=2471,SCI_STARTRECORD:=3001,SCI_STOPRECORD:=3002,SCI_SETLEXER:=4001,SCI_GETLEXER:=4002,SCI_COLORISE:=4003,SCI_SETPROPERTY:=4004,SCI_SETKEYWORDS:=4005,SCI_SETLEXERLANGUAGE:=4006,SCI_LOADLEXERLIBRARY:=4007,SCI_GETPROPERTY:=4008,SCI_GETPROPERTYEXPANDED:=4009,SCI_GETPROPERTYINT:=4010,SCI_GETSTYLEBITSNEEDED:=4011, SCI_SETEXTRAASCENT := 2525, SCI_SETINDICATORCURRENT := 2500, SCI_INDICATORCLEARRANGE := 2505, SCI_INDICSETOUTLINEALPHA := 2558, SCI_INDICSETALPHA := 2523, SCI_INDICATORFILLRANGE := 2504, SCI_INDICATORSTART := 2508, SCI_INDICATOREND := 2509, SCI_INDICATORALLONFOR := 2506, SCI_SETTECHNOLOGY := 2630,SCI_DELETERANGE := 2645, SCI_AUTOCSETORDER := 2660, SCI_SETCARETLINEVISIBLEALWAYS := 2655, SCI_FOLDALL := 2662, SCI_TARGETWHOLEDOCUMENT := 2690
        
        ; Styles, Markers and Indicators
        static MARKER_MAX:=31,STYLE_DEFAULT:=32,STYLE_LINENUMBER:=33,STYLE_BRACELIGHT:=34,STYLE_BRACEBAD:=35,STYLE_CONTROLCHAR:=36,STYLE_INDENTGUIDE:=37,STYLE_CALLTIP:=38,STYLE_LASTPREDEFINED:=39,STYLE_MAX:=127,INDIC_MAX:=7,INDIC_PLAIN:=0,INDIC_SQUIGGLE:=1,INDIC_TT:=2,INDIC_DIAGONAL:=3,INDIC_STRIKE:=4,INDIC_HIDDEN:=5,INDIC_BOX:=6,INDIC_ROUNDBOX:=7,INDIC0_MASK:=0x20,INDIC1_MASK:=0x40,INDIC2_MASK:=0x80,INDICS_MASK:=0xE0,SCI_START:=2000,SCI_OPTIONAL_START:=3000,SCI_LEXER_START:=4000,SCWS_INVISIBLE:=0,SCWS_VISIBLEALWAYS:=1,SCWS_VISIBLEAFTERINDENT:=2,SC_EOL_CRLF:=0,SC_EOL_CR:=1,SC_EOL_LF:=2,SC_CP_UTF8:=65001,SC_CP_DBCS:=1,SC_MARK_CIRCLE:=0,SC_MARK_ROUNDRECT:=1,SC_MARK_ARROW:=2,SC_MARK_SMALLRECT:=3,SC_MARK_SHORTARROW:=4
        static SC_MARK_EMPTY:=5,SC_MARK_ARROWDOWN:=6,SC_MARK_MINUS:=7,SC_MARK_PLUS:=8,SC_MARK_VLINE:=9,SC_MARK_LCORNER:=10,SC_MARK_TCORNER:=11,SC_MARK_BOXPLUS:=12,SC_MARK_BOXPLUSCONNECTED:=13,SC_MARK_BOXMINUS:=14,SC_MARK_BOXMINUSCONNECTED:=15,SC_MARK_LCORNERCURVE:=16,SC_MARK_TCORNERCURVE:=17,SC_MARK_CIRCLEPLUS:=18,SC_MARK_CIRCLEPLUSCONNECTED:=19,SC_MARK_CIRCLEMINUS:=20,SC_MARK_CIRCLEMINUSCONNECTED:=21,SC_MARK_BACKGROUND:=22,SC_MARK_DOTDOTDOT:=23,SC_MARK_ARROWS:=24,SC_MARK_PIXMAP:=25,SC_MARK_FULLRECT:=26,SC_MARK_CHARACTER:=10000,SC_MARKNUM_FOLDEREND:=25,SC_MARKNUM_FOLDEROPENMID:=26,SC_MARKNUM_FOLDERMIDTAIL:=27,SC_MARKNUM_FOLDERTAIL:=28,SC_MARKNUM_FOLDERSUB:=29,SC_MARKNUM_FOLDER:=30,SC_MARKNUM_FOLDEROPEN:=31,SC_MASK_FOLDERS:=0xFE000000,SC_MARGIN_SYMBOL:=0,SC_MARGIN_NUMBER:=1,SC_MARGIN_BACK:=2,SC_MARGIN_FORE:=3,SC_MARGIN_TEXT_:=4,SC_MARGIN_RTEXT:=5,SC_MARGIN_COLOUR:=6
        static SC_IV_NONE:=0,SC_IV_REAL:=1,SC_IV_LOOKFORWARD:=2,SC_IV_LOOKBOTH:=3
        
        ; Search flags
        static SCFIND_WHOLEWORD:=2,SCFIND_MATCHCASE:=4,SCFIND_WORDSTART:=0x00100000,SCFIND_REGEXP:=0x00200000,SCFIND_POSIX:=0x00400000
        
        static SC_UPDATE_CONTENT:=0x01,SC_UPDATE_SELECTION:=0x02,SC_UPDATE_V_SCROLL:=0x04,SC_UPDATE_H_SCROLL:=0x08
        
        static SC_AC_FILLUP := 1, SC_AC_DOUBLECLICK := 2, SC_AC_TAB := 3, SC_AC_NEWLINE := 4, SC_AC_COMMAND := 5
        
        ; Keys
        static SCMOD_NORM:=0, SCMOD_SHIFT:=1,SCMOD_CTRL:=2,SCMOD_ALT:=4, SCK_DOWN:=300,SCK_UP:=301,SCK_LEFT:=302,SCK_RIGHT:=303,SCK_HOME:=304,SCK_END:=305,SCK_PRIOR:=306,SCK_NEXT:=307,SCK_DELETE:=308,SCK_INSERT:=309,SCK_ESCAPE:=7,SCK_BACK:=8,SCK_TAB:=9,SCK_RETURN:=13,SCK_ADD:=310,SCK_SUBTRACT:=311,SCK_DIVIDE:=312

        ; Lexing
        static SCE_AHKL_NEUTRAL:=0,SCE_AHKL_IDENTIFIER:=1,SCE_AHKL_COMMENTDOC:=2,SCE_AHKL_COMMENTLINE:=3,SCE_AHKL_COMMENTBLOCK:=4,SCE_AHKL_COMMENTKEYWORD:=5,SCE_AHKL_STRING:=6,SCE_AHKL_STRINGOPTS:=7,SCE_AHKL_STRINGBLOCK:=8,SCE_AHKL_STRINGCOMMENT:=9,SCE_AHKL_LABEL:=10,SCE_AHKL_HOTKEY:=11,SCE_AHKL_HOTSTRING:=12,SCE_AHKL_HOTSTRINGOPT:=13,SCE_AHKL_HEXNUMBER:=14,SCE_AHKL_DECNUMBER:=15,SCE_AHKL_VAR:=16,SCE_AHKL_VARREF:=17,SCE_AHKL_OBJECT:=18,SCE_AHKL_USERFUNCTION:=19
        static SCE_AHKL_DIRECTIVE:=20,SCE_AHKL_COMMAND:=21,SCE_AHKL_PARAM:=22,SCE_AHKL_CONTROLFLOW:=23,SCE_AHKL_BUILTINFUNCTION:=24,SCE_AHKL_BUILTINVAR:=25,SCE_AHKL_KEY:=26,SCE_AHKL_USERDEFINED1:=27,SCE_AHKL_USERDEFINED2:=28,SCE_AHKL_ESCAPESEQ:=30,SCE_AHKL_ERROR:=31,AHKL_LIST_DIRECTIVES:=0,AHKL_LIST_COMMANDS:=1,AHKL_LIST_PARAMETERS:=2,AHKL_LIST_CONTROLFLOW:=3,AHKL_LIST_FUNCTIONS:=4,AHKL_LIST_VARIABLES:=5,AHKL_LIST_KEYS:=6,AHKL_LIST_USERDEFINED1:=7,AHKL_LIST_USERDEFINED2:=8,SCLEX_AUTOMATIC:=1000

        ; Lexing SQL
        static SCE_SQL_DEFAULT := 0, SCE_SQL_COMMENT := 1, SCE_SQL_COMMENTLINE := 2, SCE_SQL_COMMENTDOC := 3, SCE_SQL_NUMBER := 4, SCE_SQL_WORD := 5, SCE_SQL_STRING := 6, SCE_SQL_CHARACTER := 7, SCE_SQL_SQLPLUS := 8, SCE_SQL_SQLPLUS_PROMPT := 9, SCE_SQL_OPERATOR := 10, SCE_SQL_IDENTIFIER := 11, SCE_SQL_SQLPLUS_COMMENT := 13, SCE_SQL_COMMENTLINEDOC := 15, SCE_SQL_WORD2 := 16, SCE_SQL_COMMENTDOCKEYWORD := 17, SCE_SQL_COMMENTDOCKEYWORDERROR := 18, SCE_SQL_USER1 := 19, SCE_SQL_USER2 := 20, SCE_SQL_USER3 := 21, SCE_SQL_USER4 := 22, SCE_SQL_QUOTEDIDENTIFIER := 23, SCE_SQL_QOPERATOR := 24

        ; Notifications
        static SCEN_CHANGE:=768,SCEN_SETFOCUS:=512,SCEN_KILLFOCUS:=256, SCN_STYLENEEDED:=2000,SCN_CHARADDED:=2001,SCN_SAVEPOINTREACHED:=2002,SCN_SAVEPOINTLEFT:=2003,SCN_MODIFYATTEMPTRO:=2004,SCN_DOUBLECLICK:=2006,SCN_UPDATEUI:=2007,SCN_MODIFIED:=2008,SCN_MACRORECORD:=2009,SCN_MARGINCLICK:=2010,SCN_NEEDSHOWN:=2011,SCN_PAINTED:=2013,SCN_USERLISTSELECTION:=2014,SCN_URIDROPPED:=2015,SCN_DWELLSTART:=2016,SCN_DWELLEND:=2017,SCN_ZOOM:=2018,SCN_HOTSPOTCLICK:=2019,SCN_HOTSPOTDOUBLECLICK:=2020,SCN_CALLTIPCLICK:=2021,SCN_AUTOCSELECTION:=2022, SCN_AUTOCCOMPLETED:=2030,SCN_AUTOCCANCELLED:=2025,SCN_FOCUSIN:=2028,SCN_FOCUSOUT:=2029

        ; Other
        static SCI_LINEDOWN:=2300,SCI_LINEDOWNEXTEND:=2301,SCI_LINEDOWNRECTEXTEND:=2426,SCI_LINESCROLLDOWN:=2342,SCI_LINEUP:=2302,SCI_LINEUPEXTEND:=2303,SCI_LINEUPRECTEXTEND:=2427,SCI_LINESCROLLUP:=2343,SCI_PARADOWN:=2413,SCI_PARADOWNEXTEND:=2414,SCI_PARAUP:=2415,SCI_PARAUPEXTEND:=2416,SCI_CHARLEFT:=2304,SCI_CHARLEFTEXTEND:=2305,SCI_CHARLEFTRECTEXTEND:=2428,SCI_CHARRIGHT:=2306,SCI_CHARRIGHTEXTEND:=2307,SCI_CHARRIGHTRECTEXTEND:=2429,SCI_WORDLEFT:=2308,SCI_WORDLEFTEXTEND:=2309,SCI_WORDRIGHT:=2310,SCI_WORDRIGHTEXTEND:=2311,SCI_WORDLEFTEND:=2439,SCI_WORDLEFTENDEXTEND:=2440,SCI_WORDRIGHTEND:=2441,SCI_WORDRIGHTENDEXTEND:=2442,SCI_WORDPARTLEFT:=2390,SCI_WORDPARTLEFTEXTEND:=2391,SCI_WORDPARTRIGHT:=2392,SCI_WORDPARTRIGHTEXTEND:=2393
        static SCI_HOME:=2312,SCI_HOMEEXTEND:=2313,SCI_HOMERECTEXTEND:=2430,SCI_HOMEDISPLAY:=2345,SCI_HOMEDISPLAYEXTEND:=2346,SCI_HOMEWRAP:=2349,SCI_HOMEWRAPEXTEND:=2450,SCI_VCHOME:=2331,SCI_VCHOMEEXTEND:=2332,SCI_VCHOMERECTEXTEND:=2431,SCI_VCHOMEWRAP:=2453,SCI_VCHOMEWRAPEXTEND:=2454,SCI_LINEEND:=2314,SCI_LINEENDEXTEND:=2315,SCI_LINEENDRECTEXTEND:=2432,SCI_LINEENDDISPLAY:=2347,SCI_LINEENDDISPLAYEXTEND:=2348,SCI_LINEENDWRAP:=2451,SCI_LINEENDWRAPEXTEND:=2452,SCI_DOCUMENTSTART:=2316,SCI_DOCUMENTSTARTEXTEND:=2317,SCI_DOCUMENTEND:=2318,SCI_DOCUMENTENDEXTEND:=2319,SCI_PAGEUP:=2320,SCI_PAGEUPEXTEND:=2321,SCI_PAGEUPRECTEXTEND:=2433,SCI_PAGEDOWN:=2322,SCI_PAGEDOWNEXTEND:=2323,SCI_PAGEDOWNRECTEXTEND:=2434,SCI_STUTTEREDPAGEUP:=2435
        static SCI_STUTTEREDPAGEUPEXTEND:=2436,SCI_STUTTEREDPAGEDOWN:=2437,SCI_STUTTEREDPAGEDOWNEXTEND:=2438,SCI_DELETEBACK:=2326,SCI_DELETEBACKNOTLINE:=2344,SCI_DELWORDLEFT:=2335,SCI_DELWORDRIGHT:=2336,SCI_DELLINELEFT:=2395,SCI_DELLINERIGHT:=2396,SCI_LINEDELETE:=2338,SCI_LINECUT:=2337,SCI_LINECOPY:=2455,SCI_LINETRANSPOSE:=2339,SCI_LINEDUPLICATE:=2404,SCI_LOWERCASE:=2340,SCI_UPPERCASE:=2341,SCI_CANCEL:=2325,SCI_EDITTOGGLEOVERTYPE:=2324,SCI_NEWLINE:=2329,SCI_FORMFEED:=2330,SCI_TAB:=2327,SCI_BACKTAB:=2328,SCI_SELECTIONDUPLICATE:=2469,SCI_SCROLLTOSTART:=2628,SCI_SCROLLTOEND:=2629,SCI_DELWORDRIGHTEND:=2518,SCI_VERTICALCENTRECARET:=2619,SCI_MOVESELECTEDLINESUP:=2620,SCI_MOVESELECTEDLINESDOWN:=2621,SC_TIME_FOREVER:=10000000
        static SC_WRAP_NONE:=0,SC_WRAP_WORD:=1,SC_WRAP_CHAR:=2,SC_WRAPVISUALFLAG_NONE:=0x0000,SC_WRAPVISUALFLAG_END:=0x0001,SC_WRAPVISUALFLAG_START:=0x0002,SC_WRAPVISUALFLAG_MARGIN:=0x0004, SC_WRAPVISUALFLAGLOC_DEFAULT:=0x0000,SC_WRAPVISUALFLAGLOC_END_BY_TEXT:=0x0001,SC_WRAPVISUALFLAGLOC_START_BY_TEXT:=0x0002,SC_CACHE_NONE:=0,SC_CACHE_CARET:=1,SC_CACHE_PAGE:=2,SC_CACHE_DOCUMENT:=3,EDGE_NONE:=0,EDGE_LINE:=1,EDGE_BACKGROUND:=2,SC_CURSORNORMAL:=-1,SC_CURSORWAIT:=4,VISIBLE_SLOP:=0x01,VISIBLE_STRICT:=0x04,CARET_SLOP:=0x01,CARET_STRICT:=0x04,CARET_JUMPS:=0x10,CARET_EVEN:=0x08,SC_SEL_STREAM:=0,SC_SEL_RECTANGLE:=1,SC_SEL_LINES:=2,SC_ALPHA_TRANSPARENT:=0,SC_ALPHA_OPAQUE:=255,SC_ALPHA_NOALPHA:=256,KEYWORDSET_MAX:=8
        static SC_MOD_INSERTTEXT:=0x1,SC_MOD_DELETETEXT:=0x2,SC_MOD_CHANGESTYLE:=0x4,SC_MOD_CHANGEFOLD:=0x8,SC_PERFORMED_USER:=0x10,SC_PERFORMED_UNDO:=0x20,SC_PERFORMED_REDO:=0x40,SC_MULTISTEPUNDOREDO:=0x80,SC_LASTSTEPINUNDOREDO:=0x100,SC_MOD_CHANGEMARKER:=0x200,SC_MOD_BEFOREINSERT:=0x400,SC_MOD_BEFOREDELETE:=0x800,SC_MOD_INSERTCHECK:=0x100000,SC_MULTILINEUNDOREDO:=0x1000,SC_MODEVENTMASKALL:=0x1FFF,SC_WEIGHT_NORMAL:=400, SC_WEIGHT_SEMIBOLD:=600, SC_WEIGHT_BOLD:=700
        
        __Call(msg, ByRef wParam := 0, ByRef lParam := 0, Params*) {
            ; we could let integer method calls through, but then we would have to verify them somehow as well
            ; I prefer to define them once and use the message names.  Makes the consumers code easier to reason about.
            if (Type(msg) = "Integer") {
                throw Exception(this.__class "::" msg "`n`nPlease use the defined static variables on the " this.__class " instance for sending messages to the Scintilla control.`n`n`tFor example, <instance>.SetTabWidth(4)", -1)
            }
            ; msg is a string but Scintilla.ScintillaBase does not have a key defined for "SCI_" msg
            else if (Type(msg) = "String" && !this.ScintillaBase.HasKey(newMsg := "SCI_" msg)) {
                throw Exception(this.__class "::" msg "`n`nCall to non-existent method", -1)
            }
            
            If (wParam && Type(wParam) = "String" && !isObject(wParam)) {
                VarSetCapacity(wParamA, StrPut(wParam, "UTF-8"))
                StrPut(wParam, &wParamA, "UTF-8")
                wParam := &wParamA
            }

            ; If the second parameter to any method call on Scintilla is a string and you need to pass an address,
            ; then pass true/1 as the third parameter
            ; same as how the first parameter gets handled if its a string
            If (Params[1]) {
                VarSetCapacity(lParamA, StrPut(lParam, "UTF-8"))
                StrPut(lParam, &lParamA, "UTF-8")
                lParam := &lParamA
            }

            ; pass the value of this.ScintillaBase[newMsg] since we already 
            return this.__sendEditor(this.ScintillaBase[newMsg], wParam, lParam)
        }
        
        /**
         * Called if a property is read from a Scintilla instance but it is not defined on that instance
         * Checks if <instance>.ScintillaBase has a property of the same name.
         * If it does, return its value, otherwise throw an exception.
         * @param {key}: The requested property from the instance of Scintilla
         * @return: Value of that property from Scintilla.ScintillaBase
         */
        __Get(key) {
            if (!this.ScintillaBase.HasKey(key)) {
                throw Exception(this.__class "::" key "`n`nUnknown property!", -1)
            }
            
            return this.ScintillaBase[key]
        }
    }
}
