; ==================================================================================================================================================;
; **************************************************************************************************************************************************;
;
;	UX_THEME / VISUAL STYLE / AEROWIZARD
;
;	Author:		MIAMIGUY | CHESHIRECAT
;	Developed:	04/27/2008 - 11/13/2019
;	Function:		Constants for UxTheme Button Window and other controls needed for VisualStyle Class 
;	Tested with:	AHK 1.1.20.00+ (A32/U32)
;	Tested On:	Win Vista | Win 7 | Win 10
;	Org. Forum:	https://autohotkey.com/board/topic/28522-help-with-extending-client-area-in-vista-gui/
;
;	Changes:
;		0.1.00.00/2019-11-13 - initial release 
; **************************************************************************************************************************************************;
;
;	THIS CODE AND/OR INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND EITHER EXPRESSED OR IMPLIED
;	INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
;	IN NO EVENT WILL THE AUTHOR BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE USE OR MISUSE OF THIS SOFTWARE.
;
; ==================================================================================================================================================;

	Global DWM_WINEXTENT := 33  ;needed
	Global S_OK := 0  ;needed
	Global SS_NOTIFY := 0x100

   ;  ---- Button Control Messages ---- ;
	Global BM_SETIMAGE:=0xF7  ;needed
	Global BCM_SETSHIELD := 0x0000160C  ;needed
	Global BS_COMMANDLINK := 0x000E  ;needed
	Global BS_DEFCOMMANDLINK := 0x000F  ;needed

   ;  ---- Load Image Function Image Types ---- ;
	Global IMAGE_BITMAP := 0
	Global IMAGE_ICON := 1  ;needed
	Global IMAGE_CURSOR := 2
	Global IMAGE_ENHMETAFILE := 3

   ;  ---- Set Cuebanner Message ---- ;
	Global EM_SETCUEBANNER:=0x1501  ;needed

   ;  ---- Showwindow Function Values ---- ; 
	Global SW_SHOW := 5  ;needed
	Global SW_HIDE := 0  ;needed
	Global SW_SHOWNORMAL := 1
	Global SW_NORMAL := 1
	Global SW_SHOWMINIMIZED := 2
	Global SW_SHOWMAXIMIZED := 3
	Global SW_MAXIMIZE := 3
	Global SW_SHOWNOACTIVATE := 4
	Global SW_SHOW := 5
	Global SW_MINIMIZE := 6
	Global SW_SHOWMINNOACTIVE := 7
	Global SW_SHOWNA := 8
	Global SW_RESTORE := 9
	Global SW_SHOWDEFAULT := 10
	Global SW_FORCEMINIMIZE := 11
	Global SW_MAX := 11

   ;  ---- Setwindowlong Function Values ---- ;
	Global GWL_ROOT := 2
	Global GWL_WNDPROC := (-4)
	Global GWL_HINSTANCE := (-6)
	Global GWL_HWNDPARENT := (-8)
	Global GWL_STYLE := (-16)
	Global GWL_EXSTYLE := (-20)
	Global GWL_USERDATA := (-21)
	Global GWL_ID := (-12)
	Global DWL_MSGRESULT := 0
	Global DWL_DLGPROC := 4
	Global DWL_USER := 8

   ;  ---- Window Messages ---- ;
	Global WM_PAINT := 0x0F  ;needed
	Global WM_MOUSEFIRST := 0x200  ;needed
	Global WM_MOUSEHOVER := 0x02A1  ;needed
	Global WM_MOUSELEAVE := 0x02A3  ;needed
	Global WM_LBUTTONUP := 0x202  ;needed
	Global WM_LBUTTONDOWN := 0x201  ;needed
	Global WM_CTLCOLORDLG:=0x136  ;needed
	Global WM_CTLCOLORBTN := 0x135  ;needed
	Global WM_SETTEXT := 0x0C  ;needed
	Global WM_NCACTIVATE := 0x86  ;needed
	Global WM_NCLBUTTONDOWN := 0xA1  ;needed
	Global WM_GETICON := 0x7F  ;needed
	Global WM_SETICON := 0x80  ;needed
	Global WM_SETREDRAW := 0x0B  ;needed
	Global WM_SETCURSOR := 0x20  ;needed
	Global WM_DWMCOMPOSITIONCHANGED := 0x031E  ;needed
	Global WM_ACTIVATE := 0x06  ;needed

   ;  ---- Tv Control Messages ---- ;
	Global TV_FIRST := 0x1100  ;needed
	Global TVM_SETEXTENDEDSTYLE := (TV_FIRST + 44)  ;needed
	Global TVM_SETTEXTCOLOR := (TV_FIRST + 30)  ;needed
	Global TVM_SETBKCOLOR := (TV_FIRST + 29)  ;needed
	Global TVM_SETINDENT := (TV_FIRST + 7)  ;needed
   
   ;  ---- Track Mouse Even Function/structure ---- ; 
	Global TME_HOVER := 0x00000001  ;needed
	Global TME_LEAVE := 0x00000002  ;needed
	Global TME_NONCLIENT := 0x00000010
	Global TME_QUERY := 0x40000000
	Global TME_CANCEL:= 0x80000000

   ;  ---- Progressbar Values ---- ;   
	Global PBST_NORMAL := 0x0001  ;needed
	Global PBST_ERROR := 0x0002  ;needed
	Global PBST_PAUSE := 0x0003  ;needed
	Global PBM_SETMARQUEE := 0x40a  ;needed
	Global PBS_MARQUEE := 0x8  ;needed
	Global PBS_SMOOTH := 0x1  ;needed
	Global PBM_SETSTATE := (WM_USER + 16)  ;needed

   ;  ---- Setcursor Values ---- ;
	Global IDC_HAND  := 32649  ;needed
	Global IDC_ARROW := 32512  ;needed

   ;  ---- Buffered Paint Function dwFlags ---- ;
	Global BPBF_COMPATIBLEBITMAP := 0  ;needed
	Global BPBF_DIB := 1
	Global BPBF_TOPDOWNDIB := 2  ;needed
	Global BPBF_TOPDOWNMONODIB := 3
	Global BPBF_COMPOSITED := BPBF_TOPDOWNDIB
	Global BPPF_ERASE := 0x0001  ;needed
	Global BPPF_NOCLIP := 0x0002  ;needed
	Global BPPF_NONCLIENT := 0x0004

   ; Global BS_MULTILINE := 0x2000

   ;  ---- Setwindowthemeattribute Values ---- ;
	Global WTA_NONCLIENT := 1  ;needed
	Global WTNCA_NODRAWCAPTION := 0x00000001  ;needed
	Global WTNCA_NODRAWICON := 0x00000002  ;needed
	Global WTNCA_NOSYSMENU := 0x00000004  ;needed
	Global WTNCA_NOMIRRORHELP := 0x00000008  ;needed

   ;  ---- Redraw Function Values ---- ;
	Global RDW_ALLCHILDREN := 0x80  ;needed
	Global RDW_ERASE := 0x4
	Global RDW_ERASENOW := 0x200
	Global RDW_INTERNALPAINT := 0x2  ;needed
	Global RDW_INVALIDATE := 0x1  ;needed
	Global RDW_NOCHILDREN := 0x40
	Global RDW_NOERASE := 0x20
	Global RDW_NOFRAME := 0x800
	Global RDW_NOINTERNALPAINT := 0x10
	Global RDW_UPDATENOW := 0x100  ;needed
	Global RDW_VALIDATE := 0x8
	Global RDW_FRAME := 0x400

   ;  ---- Windows Color Values ---- ;
	Global COLOR_3DDKSHADOW := 21
	Global COLOR_3DFACE := 15
	Global COLOR_3DHIGHLIGHT := 20
	Global COLOR_3DHILIGHT := 20
	Global COLOR_3DLIGHT := 22
	Global COLOR_3DSHADOW := 16
	Global COLOR_ACTIVEBORDER := 10
	Global COLOR_ACTIVECAPTION := 2
	Global COLOR_APPWORKSPACE := 12
	Global COLOR_BACKGROUND := 1  ;needed
	Global COLOR_BTNFACE := 15  ;needed
	Global COLOR_BTNHIGHLIGHT := 20
	Global COLOR_BTNHILIGHT := 20
	Global COLOR_BTNSHADOW := 16
	Global COLOR_BTNTEXT := 18
	Global COLOR_CAPTIONTEXT := 9
	Global COLOR_DESKTOP := 1
	Global COLOR_GRADIENTACTIVECAPTION := 27  ;needed
	Global COLOR_GRADIENTINACTIVECAPTION := 28  ;needed
	Global COLOR_GRAYTEXT := 17
	Global COLOR_HIGHLIGHT := 13
	Global COLOR_HIGHLIGHTTEXT := 14
	Global COLOR_HOTLIGHT := 26
	Global COLOR_INACTIVEBORDER := 11
	Global COLOR_INACTIVECAPTION := 3
	Global COLOR_INACTIVECAPTIONTEXT := 19
	Global COLOR_INFOBK := 24
	Global COLOR_INFOTEXT := 23
	Global COLOR_MENU := 4
	Global COLOR_MENUHILIGHT := 29
	Global COLOR_MENUBAR := 30
	Global COLOR_MENUTEXT := 7
	Global COLOR_SCROLLBAR := 0
	Global COLOR_WINDOW := 5  ;needed
	Global COLOR_WINDOWFRAME := 6
	Global COLOR_WINDOWTEXT := 8

   ;  ---- Draw Text Values ---- ;
	Global DT_TOP := 0x00000000
	Global DT_LEFT := 0x00000000  ;needed
	Global DT_CENTER := 0x00000001  ;needed
	Global DT_RIGHT := 0x00000002
	Global DT_VCENTER := 0x00000004  ;needed
	Global DT_BOTTOM := 0x00000008
	Global DT_WORDBREAK := 0x00000010  ;needed
	Global DT_SINGLELINE := 0x00000020
	Global DT_EXPANDTABS := 0x00000040
	Global DT_TABSTOP := 0x00000080
	Global DT_NOCLIP := 0x00000100
	Global DT_EXTERNALLEADING := 0x00000200
	Global DT_CALCRECT := 0x00000400  ;needed
	Global DT_NOPREFIX := 0x00000800
	Global DT_INTERNAL := 0x00001000
	Global DT_EDITCONTROL  := 0x00002000
	Global DT_PATH_ELLIPSIS := 0x00004000  ;needed
	Global DT_END_ELLIPSIS  := 0x00008000  ;needed
	Global DT_MODIFYSTRING := 0x00010000
	Global DT_RTLREADING := 0x00020000
	Global DT_WORD_ELLIPSIS := 0x00040000
	Global DT_NOFULLWIDTHCHARBREAK := 0x00080000
	Global DT_HIDEPREFIX := 0x00100000
	Global DT_PREFIXONLY := 0x00200000

   ;  ---- Property Identifiers ---- ;
	Global TMT_RESERVEDLOW := 0
	Global TMT_RESERVEDHIGH := 7999
	Global TMT_DIBDATA := 2
	Global TMT_GLYPHDIBDATA := 8
	Global TMT_ENUM := 200
	Global TMT_STRING := 201
	Global TMT_INT := 202
	Global TMT_BOOL := 203
	Global TMT_COLOR := 204
	Global TMT_MARGINS := 205
	Global TMT_FILENAME := 206
	Global TMT_SIZE := 207
	Global TMT_POSITION := 208
	Global TMT_RECT := 209
	Global TMT_FONT := 210  ;needed
	Global TMT_INTLIST := 211
	Global TMT_HBITMAP := 212
	Global TMT_DISKSTREAM := 213
	Global TMT_STREAM := 214
	Global TMT_BITMAPREF := 215
	Global TMT_COLORSCHEMES := 401
	Global TMT_SIZES := 402
	Global TMT_CHARSET := 403
	Global TMT_NAME := 600
	Global TMT_DISPLAYNAME := 601
	Global TMT_TOOLTIP := 602
	Global TMT_COMPANY := 603
	Global TMT_AUTHOR := 604
	Global TMT_COPYRIGHT := 605
	Global TMT_URL := 606
	Global TMT_VERSION := 607
	Global TMT_DESCRIPTION := 608
	Global TMT_FIRST_RCSTRING_NAME := TMT_DISPLAYNAME
	Global TMT_LAST_RCSTRING_NAME := TMT_DESCRIPTION
	Global TMT_CAPTIONFONT := 801
	Global TMT_SMALLCAPTIONFONT := 802
	Global TMT_MENUFONT := 803
	Global TMT_STATUSFONT := 804
	Global TMT_MSGBOXFONT := 805
	Global TMT_ICONTITLEFONT := 806
	Global TMT_HEADING1FONT := 807
	Global TMT_HEADING2FONT := 808
	Global TMT_BODYFONT := 809
	Global TMT_FIRSTFONT := TMT_CAPTIONFONT
	Global TMT_LASTFONT := TMT_BODYFONT
	Global TMT_FLATMENUS := 1001
	Global TMT_FIRSTBOOL := TMT_FLATMENUS
	Global TMT_LASTBOOL := TMT_FLATMENUS
	Global TMT_SIZINGBORDERWIDTH := 1201
	Global TMT_SCROLLBARWIDTH := 1202
	Global TMT_SCROLLBARHEIGHT := 1203
	Global TMT_CAPTIONBARWIDTH := 1204
	Global TMT_CAPTIONBARHEIGHT := 1205
	Global TMT_SMCAPTIONBARWIDTH := 1206
	Global TMT_SMCAPTIONBARHEIGHT := 1207
	Global TMT_MENUBARWIDTH := 1208
	Global TMT_MENUBARHEIGHT := 1209
	Global TMT_PADDEDBORDERWIDTH := 1210
	Global TMT_FIRSTSIZE := TMT_SIZINGBORDERWIDTH
	Global TMT_LASTSIZE := TMT_PADDEDBORDERWIDTH
	Global TMT_MINCOLORDEPTH := 1301
	Global TMT_FIRSTINT := TMT_MINCOLORDEPTH
	Global TMT_LASTINT := TMT_MINCOLORDEPTH
	Global TMT_CSSNAME := 1401
	Global TMT_XMLNAME := 1402
	Global TMT_LASTUPDATED := 1403
	Global TMT_ALIAS := 1404
	Global TMT_FIRSTSTRING := TMT_CSSNAME
	Global TMT_LASTSTRING := TMT_ALIAS
	Global TMT_SCROLLBAR := 1601
	Global TMT_BACKGROUND := 1602
	Global TMT_ACTIVECAPTION := 1603
	Global TMT_INACTIVECAPTION := 1604
	Global TMT_MENU := 1605
	Global TMT_WINDOW := 1606
	Global TMT_WINDOWFRAME := 1607
	Global TMT_MENUTEXT := 1608
	Global TMT_WINDOWTEXT := 1609
	Global TMT_CAPTIONTEXT := 1610
	Global TMT_ACTIVEBORDER := 1611
	Global TMT_INACTIVEBORDER := 1612
	Global TMT_APPWORKSPACE := 1613
	Global TMT_HIGHLIGHT := 1614
	Global TMT_HIGHLIGHTTEXT := 1615
	Global TMT_BTNFACE := 1616
	Global TMT_BTNSHADOW := 1617
	Global TMT_GRAYTEXT := 1618
	Global TMT_BTNTEXT := 1619
	Global TMT_INACTIVECAPTIONTEXT := 1620
	Global TMT_BTNHIGHLIGHT := 1621
	Global TMT_DKSHADOW3D := 1622
	Global TMT_LIGHT3D := 1623
	Global TMT_INFOTEXT := 1624
	Global TMT_INFOBK := 1625
	Global TMT_BUTTONALTERNATEFACE := 1626
	Global TMT_HOTTRACKING := 1627
	Global TMT_GRADIENTACTIVECAPTION := 1628
	Global TMT_GRADIENTINACTIVECAPTION := 1629
	Global TMT_MENUHILIGHT := 1630
	Global TMT_MENUBAR := 1631
	Global TMT_FIRSTCOLOR := TMT_SCROLLBAR
	Global TMT_LASTCOLOR := TMT_MENUBAR
	Global TMT_FROMHUE1 := 1801
	Global TMT_FROMHUE2 := 1802
	Global TMT_FROMHUE3 := 1803
	Global TMT_FROMHUE4 := 1804
	Global TMT_FROMHUE5 := 1805
	Global TMT_TOHUE1 := 1806
	Global TMT_TOHUE2 := 1807
	Global TMT_TOHUE3 := 1808
	Global TMT_TOHUE4 := 1809
	Global TMT_TOHUE5 := 1810
	Global TMT_FROMCOLOR1 := 2001
	Global TMT_FROMCOLOR2 := 2002
	Global TMT_FROMCOLOR3 := 2003
	Global TMT_FROMCOLOR4 := 2004
	Global TMT_FROMCOLOR5 := 2005
	Global TMT_TOCOLOR1 := 2006
	Global TMT_TOCOLOR2 := 2007
	Global TMT_TOCOLOR3 := 2008
	Global TMT_TOCOLOR4 := 2009
	Global TMT_TOCOLOR5 := 2010
	Global TMT_TRANSPARENT := 2201
	Global TMT_AUTOSIZE := 2202
	Global TMT_BORDERONLY := 2203
	Global TMT_COMPOSITED := 2204
	Global TMT_BGFILL := 2205
	Global TMT_GLYPHTRANSPARENT := 2206
	Global TMT_GLYPHONLY := 2207
	Global TMT_ALWAYSSHOWSIZINGBAR := 2208
	Global TMT_MIRRORIMAGE := 2209
	Global TMT_UNIFORMSIZING := 2210
	Global TMT_INTEGRALSIZING := 2211
	Global TMT_SOURCEGROW := 2212
	Global TMT_SOURCESHRINK := 2213
	Global TMT_DRAWBORDERS := 2214
	Global TMT_NOETCHEDEFFECT := 2215
	Global TMT_TEXTAPPLYOVERLAY := 2216
	Global TMT_TEXTGLOW := 2217
	Global TMT_TEXTITALIC := 2218
	Global TMT_COMPOSITEDOPAQUE := 2219
	Global TMT_LOCALIZEDMIRRORIMAGE := 2220
	Global TMT_IMAGECOUNT := 2401
	Global TMT_ALPHALEVEL := 2402
	Global TMT_BORDERSIZE := 2403
	Global TMT_ROUNDCORNERWIDTH := 2404
	Global TMT_ROUNDCORNERHEIGHT := 2405
	Global TMT_GRADIENTRATIO1 := 2406
	Global TMT_GRADIENTRATIO2 := 2407
	Global TMT_GRADIENTRATIO3 := 2408
	Global TMT_GRADIENTRATIO4 := 2409
	Global TMT_GRADIENTRATIO5 := 2410
	Global TMT_PROGRESSCHUNKSIZE := 2411
	Global TMT_PROGRESSSPACESIZE := 2412
	Global TMT_SATURATION := 2413
	Global TMT_TEXTBORDERSIZE := 2414
	Global TMT_ALPHATHRESHOLD := 2415
	Global TMT_WIDTH := 2416
	Global TMT_HEIGHT := 2417
	Global TMT_GLYPHINDEX := 2418
	Global TMT_TRUESIZESTRETCHMARK := 2419
	Global TMT_MINDPI1 := 2420
	Global TMT_MINDPI2 := 2421
	Global TMT_MINDPI3 := 2422
	Global TMT_MINDPI4 := 2423
	Global TMT_MINDPI5 := 2424
	Global TMT_TEXTGLOWSIZE := 2425
	Global TMT_FRAMESPERSECOND := 2426
	Global TMT_PIXELSPERFRAME := 2427
	Global TMT_ANIMATIONDELAY := 2428
	Global TMT_GLOWINTENSITY := 2429
	Global TMT_OPACITY := 2430
	Global TMT_COLORIZATIONCOLOR := 2431
	Global TMT_COLORIZATIONOPACITY := 2432
	Global TMT_GLYPHFONT := 2601
	Global TMT_IMAGEFILE := 3001
	Global TMT_IMAGEFILE1 := 3002
	Global TMT_IMAGEFILE2 := 3003
	Global TMT_IMAGEFILE3 := 3004
	Global TMT_IMAGEFILE4 := 3005
	Global TMT_IMAGEFILE5 := 3006
	Global TMT_GLYPHIMAGEFILE := 3008
	Global TMT_TEXT := 3201
	Global TMT_CLASSICVALUE := 3202
	Global TMT_OFFSET := 3401
	Global TMT_TEXTSHADOWOFFSET := 3402
	Global TMT_MINSIZE := 3403
	Global TMT_MINSIZE1 := 3404
	Global TMT_MINSIZE2 := 3405
	Global TMT_MINSIZE3 := 3406
	Global TMT_MINSIZE4 := 3407
	Global TMT_MINSIZE5 := 3408
	Global TMT_NORMALSIZE := 3409
	Global TMT_SIZINGMARGINS := 3601
	Global TMT_CONTENTMARGINS := 3602
	Global TMT_CAPTIONMARGINS := 3603
	Global TMT_BORDERCOLOR := 3801
	Global TMT_FILLCOLOR := 3802
	Global TMT_TEXTCOLOR := 3803  ;needed
	Global TMT_EDGELIGHTCOLOR := 3804
	Global TMT_EDGEHIGHLIGHTCOLOR := 3805
	Global TMT_EDGESHADOWCOLOR := 3806
	Global TMT_EDGEDKSHADOWCOLOR := 3807
	Global TMT_EDGEFILLCOLOR := 3808
	Global TMT_TRANSPARENTCOLOR := 3809
	Global TMT_GRADIENTCOLOR1 := 3810
	Global TMT_GRADIENTCOLOR2 := 3811
	Global TMT_GRADIENTCOLOR3 := 3812
	Global TMT_GRADIENTCOLOR4 := 3813
	Global TMT_GRADIENTCOLOR5 := 3814
	Global TMT_SHADOWCOLOR := 3815
	Global TMT_GLOWCOLOR := 3816
	Global TMT_TEXTBORDERCOLOR := 3817
	Global TMT_TEXTSHADOWCOLOR := 3818
	Global TMT_GLYPHTEXTCOLOR := 3819
	Global TMT_GLYPHTRANSPARENTCOLOR := 3820
	Global TMT_FILLCOLORHINT := 3821
	Global TMT_BORDERCOLORHINT := 3822
	Global TMT_ACCENTCOLORHINT := 3823
	Global TMT_TEXTCOLORHINT := 3824
	Global TMT_HEADING1TEXTCOLOR := 3825
	Global TMT_HEADING2TEXTCOLOR := 3826
	Global TMT_BODYTEXTCOLOR := 3827
	Global TMT_BGTYPE := 4001
	Global TMT_BORDERTYPE := 4002
	Global TMT_FILLTYPE := 4003
	Global TMT_SIZINGTYPE := 4004
	Global TMT_HALIGN := 4005
	Global TMT_CONTENTALIGNMENT := 4006
	Global TMT_VALIGN := 4007
	Global TMT_OFFSETTYPE := 4008
	Global TMT_ICONEFFECT := 4009
	Global TMT_TEXTSHADOWTYPE := 4010
	Global TMT_IMAGELAYOUT := 4011
	Global TMT_GLYPHTYPE := 4012
	Global TMT_IMAGESELECTTYPE := 4013
	Global TMT_GLYPHFONTSIZINGTYPE := 4014
	Global TMT_TRUESIZESCALINGTYPE := 4015
	Global TMT_USERPICTURE := 5001
	Global TMT_DEFAULTPANESIZE := 5002
	Global TMT_BLENDCOLOR := 5003
	Global TMT_CUSTOMSPLITRECT := 5004
	Global TMT_ANIMATIONBUTTONRECT := 5005
	Global TMT_ANIMATIONDURATION := 5006
	Global TMT_TRANSITIONDURATIONS := 6000
	Global TMT_SCALEDBACKGROUND := 7001
	Global TMT_ATLASIMAGE := 8000
	Global TMT_ATLASINPUTIMAGE := 8001
	Global TMT_ATLASRECT := 8002
	Global BCM_FIRST := 0x3
	Global BCM_GETNOTELENGTH := 0x160B  ;needed
	Global BCM_GETNOTE := 0x160A  ;needed
	Global BCM_SETNOTE := 0x1609  ;needed
	Global SRCCOPY := 0x00CC0020  ;needed

   ;  ---- Window Class Styles ---- ;
	Global CS_VREDRAW  := 0x0001
	Global CS_HREDRAW  := 0x0002
	Global CS_DBLCLKS  := 0x0008
	Global CS_OWNDC    := 0x0020
	Global CS_CLASSDC  := 0x0040
	Global CS_PARENTDC := 0x0080
	Global CS_NOCLOSE  := 0x0200
	Global CS_SAVEBITS := 0x0800
	Global CS_BYTEALIGNCLIENT := 0x1000
	Global CS_BYTEALIGNWINDOW := 0x2000
	Global CS_GLOBALCLASS := 0x4000
	Global CS_IME := 0x00010000
	Global CS_DROPSHADOW  := 0x00020000

   ;  ---- Values for Blend Function Structure ---- ;
	Global AC_SRC_OVER := 0x0
	Global AC_SRC_ALPHA := 0x01
	Global AC_SRC_NO_ALPHA := 0x02

   ;  ---- Values for BP_BUFFERFORMAT ---- ;
	Global BPAS_NONE := 0
	Global BPAS_LINEAR := 1
	Global BPAS_CUBIC := 2
	Global BPAS_SINE := 3

   ;  ---- dwFlags for OpenThemeDataEx ---- ;
	Global OTD_FORCE_RECT_SIZING := 0x00000001
	Global OTD_NONCLIENT := 0x00000002

   ;  ---- dwFlags for DrawThemeBackgroundEx ---- ;
	Global DTBG_CLIPRECT := 0x00000001
	Global DTBG_DRAWSOLID := 0x00000002 
	Global DTBG_OMITBORDER := 0x00000004
	Global DTBG_OMITCONTENT := 0x00000008
	Global DTBG_COMPUTINGREGION := 0x00000010
	Global DTBG_MIRRORDC  := 0x00000020
	Global DTBG_NOMIRROR := 0x00000040

   ;  ----- dwFlags for DrawThemeText ---- ;
	Global DTT_GRAYED := 0x00000001
	Global DTT_TEXTCOLOR := (1 << 0)
	Global DTT_BORDERCOLOR := (1 << 1)
	Global DTT_SHADOWCOLOR := (1 << 2)
	Global DTT_SHADOWTYPE := (1 << 3)
	Global DTT_SHADOWOFFSET := (1 << 4)
	Global DTT_BORDERSIZE := (1 << 5)
	Global DTT_FONTPROP := (1 << 6)
	Global DTT_COLORPROP := (1 << 7)
	Global DTT_STATEID := (1 << 8)
	Global DTT_CALCRECT := (1 << 9)
	Global DTT_APPLYOVERLAY := (1 << 10)
	Global DTT_GLOWSIZE := (1 << 11)
	Global DTT_CALLBACK := (1 << 12)
	Global DTT_COMPOSITED := (1 << 13)

   ;  ----- eSize for GetThemePartSize ---- ;
	Global TS_MIN := 0
	Global TS_TRUE := 1
	Global TS_DRAW := 2

   ;  ----- dwOptions for HitTestThemeBackground ---- ;
	Global HTTB_BACKGROUNDSEG := 0x00000000
	Global HTTB_FIXEDBORDER := 0x00000002
	Global HTTB_CAPTION := 0x00000004
	Global HTTB_RESIZINGBORDER_LEFT := 0x00000010
	Global HTTB_RESIZINGBORDER_TOP := 0x00000020
	Global HTTB_RESIZINGBORDER_RIGHT := 0x00000040
	Global HTTB_RESIZINGBORDER_BOTTOM :=0x00000080
	Global HTTB_RESIZINGBORDER := (HTTB_RESIZINGBORDER_LEFT|HTTB_RESIZINGBORDER_TOP|HTTB_RESIZINGBORDER_RIGHT|HTTB_RESIZINGBORDER_BOTTOM)
	Global HTTB_SIZINGTEMPLATE := 0x00000100
	Global HTTB_SYSTEMSIZINGMARGINS := 0x00000200

   ;  ---- dwFlags for GetThemeIntList ---- ;
	Global MAX_INTLIST_COUNT := 402
	Global MAX_INTLIST_COUNT := 10

   ;  ---- dwFlags for SetWindowThemeAttribute ---- ;
	Global WTA_NONCLIENT := 1
	Global WTNCA_NODRAWCAPTION := 0x00000001
	Global WTNCA_NODRAWICON := 0x00000002
	Global WTNCA_NOSYSMENU := 0x00000004
	Global WTNCA_NOMIRRORHELP := 0x00000008

   ;  ---- dwFlags for EnableThemeDialogTexture ---- ;
	Global ETDT_DISABLE := 0x00000001
	Global ETDT_ENABLE := 0x00000002
	Global ETDT_USETABTEXTURE := 0x00000004
	Global ETDT_USEAEROWIZARDTABTEXTURE := 0x00000008
	Global ETDT_ENABLETAB := (ETDT_ENABLE|ETDT_USETABTEXTURE)
	Global ETDT_ENABLEAEROWIZARDTAB := (ETDT_ENABLE|ETDT_USEAEROWIZARDTABTEXTURE)

   ;  ---- dwFlags for SetThemeAppProperties ---- ;
	Global STAP_ALLOW_NONCLIENT := (1 << 0)
	Global STAP_ALLOW_CONTROLS := (1 << 1)
	Global STAP_ALLOW_WEBCONTENT := (1 << 2)

   ;  ---- dwFlags for DrawThemeParentBackgroundEx ---- ;
	Global DTPB_WINDOWDC := 0x00000001
	Global DTPB_USECTLCOLORSTATIC := 0x00000002
	Global DTPB_USEERASEBKGND := 0x00000004

   ;  ---- dwFlags for GetThemeBitmap ---- ;
	Global GBF_DIRECT := 0x00000001
	Global GBF_COPY := 0x00000002

   ;  ==== UxTheme Parts and States ==== ;

   ;  ---- AEROWIZARDPARTS ---- ;
	Global AW_TITLEBAR           := 1
	Global AW_HEADERAREA         := 2
	Global AW_CONTENTAREA        := 3
	Global AW_COMMANDAREA        := 4
	Global AW_BUTTON             := 5

   ;  ---- AEROWIZARD TITLEBARSTATES ---- ;
	Global AW_S_TITLEBAR_ACTIVE  := 1
	Global AW_S_TITLEBAR_INACTIVE:= 2

   ;  ---- AEROWIZARD HEADERAREASTATES ---- ;
	Global AW_S_HEADERAREA_NOMARGIN := 1

   ;  ---- AEROWIZARD CONTENTAREASTATES ---- ;
	Global AW_S_CONTENTAREA_NOMARGIN := 1

   ;  ---- BUTTONPARTS ---- ;
	Global BP_PUSHBUTTON         := 1
	Global BP_RADIOBUTTON        := 2
	Global BP_CHECKBOX           := 3
	Global BP_GROUPBOX           := 4
	Global BP_USERBUTTON         := 5
	Global BP_COMMANDLINK        := 6
	Global BP_COMMANDLINKGLYPH   := 7

   ;  ---- PUSHBUTTONSTATES ---- ;
	Global PBS_NORMAL            := 1
	Global PBS_HOT               := 2
	Global PBS_PRESSED           := 3
	Global PBS_DISABLED          := 4
	Global PBS_DEFAULTED         := 5
	Global PBS_DEFAULTED_ANIMATING := 6

   ;  ---- RADIOBUTTONSTATES ---- ;
	Global RBS_UNCHECKEDNORMAL   := 1
	Global RBS_UNCHECKEDHOT      := 2
	Global RBS_UNCHECKEDPRESSED  := 3
	Global RBS_UNCHECKEDDISABLED := 4
	Global RBS_CHECKEDNORMAL     := 5
	Global RBS_CHECKEDHOT        := 6
	Global RBS_CHECKEDPRESSED    := 7
	Global RBS_CHECKEDDISABLED   := 8

   ;  ---- CHECKBOXSTATES ---- ;
	Global CBS_UNCHECKEDNORMAL   := 1
	Global CBS_UNCHECKEDHOT      := 2
	Global CBS_UNCHECKEDPRESSED  := 3
	Global CBS_UNCHECKEDDISABLED := 4
	Global CBS_CHECKEDNORMAL     := 5
	Global CBS_CHECKEDHOT        := 6
	Global CBS_CHECKEDPRESSED    := 7
	Global CBS_CHECKEDDISABLED   := 8
	Global CBS_MIXEDNORMAL       := 9
	Global CBS_MIXEDHOT          := 10
	Global CBS_MIXEDPRESSED      := 11
	Global CBS_MIXEDDISABLED     := 12
	Global CBS_IMPLICITNORMAL    := 13
	Global CBS_IMPLICITHOT       := 14
	Global CBS_IMPLICITPRESSED   := 15
	Global CBS_IMPLICITDISABLED  := 16
	Global CBS_EXCLUDEDNORMAL    := 17
	Global CBS_EXCLUDEDHOT       := 18
	Global CBS_EXCLUDEDPRESSED   := 19
	Global CBS_EXCLUDEDDISABLED  := 20

   ;  ---- GROUPBOXSTATES ---- ;
	Global GBS_NORMAL            := 1
	Global GBS_DISABLED          := 2

   ;  ---- COMMANDLINKSTATES ---- ;
	Global CMDLS_NORMAL          := 1
	Global CMDLS_HOT             := 2
	Global CMDLS_PRESSED         := 3
	Global CMDLS_DISABLED        := 4
	Global CMDLS_DEFAULTED       := 5
	Global CMDLS_DEFAULTED_ANIMATING := 6

   ;  ---- COMMANDLINKGLYPHSTATES ---- ;
	Global CMDLGS_NORMAL         := 1
	Global CMDLGS_HOT            := 2
	Global CMDLGS_PRESSED        := 3
	Global CMDLGS_DISABLED       := 4
	Global CMDLGS_DEFAULTED      := 5

   ;  ---- COMBOBOXPARTS ---- ;
	Global CP_DROPDOWNBUTTON     := 1
	Global CP_BACKGROUND         := 2
	Global CP_TRANSPARENTBACKGROUND := 3
	Global CP_BORDER             := 4
	Global CP_READONLY           := 5 
	Global CP_DROPDOWNBUTTONRIGHT:= 6
	Global CP_DROPDOWNBUTTONLEFT := 7
	Global CP_CUEBANNER          := 8

   ;  ---- COMBOBOXSTYLESTATES ---- ;
	Global CBXS_NORMAL           := 1
	Global CBXS_HOT              := 2
	Global CBXS_PRESSED          := 3
	Global CBXS_DISABLED         := 4

   ;  ---- DROPDOWNBUTTONRIGHTSTATES ---- ;
	Global CBXSR_NORMAL          := 1
	Global CBXSR_HOT             := 2
	Global CBXSR_PRESSED         := 3
	Global CBXSR_DISABLED        := 4

   ;  ---- DROPDOWNBUTTONLEFTSTATES ---- ;
	Global CBXSL_NORMAL          := 1
	Global CBXSL_HOT             := 2
	Global CBXSL_PRESSED         := 3
	Global CBXSL_DISABLED        := 4

   ;  ---- TRANSPARENTBACKGROUNDSTATES ---- ;
	Global CBTBS_NORMAL          := 1
	Global CBTBS_HOT             := 2
	Global CBTBS_PRESSED         := 3
	Global CBTBS_DISABLED        := 4

   ;  ---- BORDERSTATES ---- ;
	Global CBB_NORMAL            := 1
	Global CBB_HOT               := 2
	Global CBB_PRESSED           := 3
	Global CBB_DISABLED          := 4

   ;  ---- READONLYSTATES ---- ;
	Global CBRO_NORMAL           := 1
	Global CBRO_HOT              := 2
	Global CBRO_PRESSED          := 3
	Global CBRO_DISABLED         := 4

   ;  ---- CUEBANNERSTATES ---- ;
	Global CBCB_NORMAL          := 1
	Global CBCB_HOT             := 2
	Global CBCB_PRESSED         := 3
	Global CBCB_DISABLED        := 4

   ;  ---- COMMUNICATIONSPARTS ---- ;
	Global CSST_TAB             := 1

   ;  ---- TABSTATES ---- ;
	Global CSTB_NORMAL          := 1
	Global CSTB_HOT             := 2
	Global CSTB_SELECTED        := 3

   ;  ---- CONTROLPANELPARTS ---- ;
	Global CPANEL_NAVIGATIONPANE:= 1
	Global CPANEL_CONTENTPANE   := 2
	Global CPANEL_NAVIGATIONPANELABEL := 3
	Global CPANEL_CONTENTPANELABEL:= 4
	Global CPANEL_TITLE         := 5
	Global CPANEL_BODYTEXT      := 6
	Global CPANEL_HELPLINK      := 7
	Global CPANEL_TASKLINK      := 8
	Global CPANEL_GROUPTEXT     := 9
	Global CPANEL_CONTENTLINK   := 10
	Global CPANEL_SECTIONTITLELINK:= 11
	Global CPANEL_LARGECOMMANDAREA:= 12
	Global CPANEL_SMALLCOMMANDAREA:= 13
	Global CPANEL_BUTTON        := 14
	Global CPANEL_MESSAGETEXT   := 15
	Global CPANEL_NAVIGATIONPANELINE:= 16
	Global CPANEL_CONTENTPANELINE:= 17
	Global CPANEL_BANNERAREA    := 18
	Global CPANEL_BODYTITLE     := 19

   ;  ---- HELPLINKSTATES ---- ;
	Global CPHL_NORMAL          := 1
	Global CPHL_HOT             := 2
	Global CPHL_PRESSED         := 3
	Global CPHL_DISABLED        := 4

   ;  ---- TASKLINKSTATES ---- ;
	Global CPTL_NORMAL          := 1
	Global CPTL_HOT             := 2
	Global CPTL_PRESSED         := 3
	Global CPTL_DISABLED        := 4
	Global CPTL_PAGE            := 5

   ;  ---- CONTENTLINKSTATES ---- ;
	Global CPCL_NORMAL          := 1
	Global CPCL_HOT             := 2
	Global CPCL_PRESSED         := 3
	Global CPCL_DISABLED        := 4

   ;  ---- SECTIONTITLELINKSTATES ---- ;
	Global CPSTL_NORMAL         := 1
	Global CPSTL_HOT            := 2

   ;  ---- DATEPICKERPARTS ---- ;
	Global DP_DATETEXT          := 1
	Global DP_DATEBORDER        := 2
	Global DP_SHOWCALENDARBUTTONRIGHT:= 3

   ;  ---- DATETEXTSTATES ---- ;
	Global DPDT_NORMAL          := 1
	Global DPDT_DISABLED        := 2
	Global DPDT_SELECTED        := 3

   ;  ---- DATEBORDERSTATES ---- ;
	Global DPDB_NORMAL          := 1
	Global DPDB_HOT             := 2
	Global DPDB_FOCUSED         := 3
	Global DPDB_SELECTED        := 4

   ;  ---- SHOWCALENDARBUTTONRIGHTSTATES ---- ;
	Global DPSCBR_NORMAL        := 1
	Global DPSCBR_HOT           := 2
	Global DPSCBR_PRESSED       := 3
	Global DPSCBR_DISABLED      := 4

   ;  ---- DRAGDROPPARTS ---- ;
	Global DD_COPY              := 1
	Global DD_MOVE              := 2
	Global DD_UPDATEMETADATA    := 3
	Global DD_CREATELINK        := 4
	Global DD_WARNING           := 5
	Global DD_NONE              := 6
	Global DD_IMAGEBG           := 7
	Global DD_TEXTBG            := 8

   ;  ---- COPYSTATES ---- ;
	Global DDCOPY_HIGHLIGHT     := 1
	Global DDCOPY_NOHIGHLIGHT   := 2

   ;  ---- MOVESTATES ---- ;
	Global DDMOVE_HIGHLIGHT     := 1
	Global DDMOVE_NOHIGHLIGHT   := 2

   ;  ---- UPDATEMETADATASTATES ---- ;
	Global DDUPDATEMETADATA_HIGHLIGHT  := 1
	Global DDUPDATEMETADATA_NOHIGHLIGHT:= 2

   ;  ---- CREATELINKSTATES ---- ;
	Global DDCREATELINK_HIGHLIGHT  := 1
	Global DDCREATELINK_NOHIGHLIGHT:= 2

   ;  ---- WARNINGSTATES ---- ;
	Global DDWARNING_HIGHLIGHT  := 1
	Global DDWARNING_NOHIGHLIGHT:= 2

   ;  ---- NONESTATES ---- ;
	Global DDNONE_HIGHLIGHT     := 1
	Global DDNONE_NOHIGHLIGHT   := 2

   ;  ---- EDITPARTS ---- ;
	Global EP_EDITTEXT := 1
	Global EP_CARET := 2
	Global EP_BACKGROUND := 3
	Global EP_PASSWORD := 4
	Global EP_BACKGROUNDWITHBORDER := 5
	Global EP_EDITBORDER_NOSCROLL := 6
	Global EP_EDITBORDER_HSCROLL := 7
	Global EP_EDITBORDER_VSCROLL := 8
	Global EP_EDITBORDER_HVSCROLL := 9

   ;  ---- EDITTEXTSTATES ---- ;
	Global ETS_NORMAL := 1
	Global ETS_HOT := 2
	Global ETS_SELECTED := 3  ;needed
	Global ETS_DISABLED := 4
	Global ETS_FOCUSED := 5
	Global ETS_READONLY := 6
	Global ETS_ASSIST := 7
	Global ETS_CUEBANNER := 8

   ;  ---- BACKGROUNDSTATES ---- ;
	Global EBS_NORMAL := 1  ;needed
	Global EBS_HOT := 2
	Global EBS_DISABLED := 3
	Global EBS_FOCUSED := 4
	Global EBS_READONLY := 5
	Global EBS_ASSIST := 6

   ;  ---- BACKGROUNDWITHBORDERSTATES ---- ;
	Global EBWBS_NORMAL := 1
	Global EBWBS_HOT := 2
	Global EBWBS_DISABLED := 3
	Global EBWBS_FOCUSED := 4

   ;  ---- EDITBORDER_NOSCROLLSTATES ---- ;
	Global EPSN_NORMAL := 1
	Global EPSN_HOT := 2
	Global EPSN_FOCUSED := 3
	Global EPSN_DISABLED := 4

   ;  ---- EDITBORDER_HSCROLLSTATES  ---- ;
	Global EPSH_NORMAL := 1
	Global EPSH_HOT := 2
	Global EPSH_FOCUSED := 3
	Global EPSH_DISABLED := 4

   ;  ---- EDITBORDER_VSCROLLSTATES ---- ;
	Global EPSV_NORMAL := 1
	Global EPSV_HOT := 2
	Global EPSV_FOCUSED := 3
	Global EPSV_DISABLED := 4

   ;  ---- EDITBORDER_HVSCROLLSTATES ---- ;
	Global EPSHV_NORMAL := 1
	Global EPSHV_HOT := 2
	Global EPSHV_FOCUSED := 3
	Global EPSHV_DISABLED := 4

   ;  ---- EXPLORERBARPARTS ---- ;
	Global EBP_HEADERBACKGROUND := 1
	Global EBP_HEADERCLOSE := 2
	Global EBP_HEADERPIN := 3
	Global EBP_IEBARMENU := 4
	Global EBP_NORMALGROUPBACKGROUND := 5
	Global EBP_NORMALGROUPCOLLAPSE := 6
	Global EBP_NORMALGROUPEXPAND := 7
	Global EBP_NORMALGROUPHEAD := 8
	Global EBP_SPECIALGROUPBACKGROUND := 9
	Global EBP_SPECIALGROUPCOLLAPSE := 10
	Global EBP_SPECIALGROUPEXPAND := 11
	Global EBP_SPECIALGROUPHEAD := 12

   ;  ---- HEADERCLOSESTATES ---- ;
	Global EBHC_NORMAL := 1
	Global EBHC_HOT := 2
	Global EBHC_PRESSED := 3

   ;  ---- HEADERPINSTATES ---- ;
	Global EBHP_NORMAL := 1
	Global EBHP_HOT := 2
	Global EBHP_PRESSED := 3
	Global EBHP_SELECTEDNORMAL := 4
	Global EBHP_SELECTEDHOT := 5
	Global EBHP_SELECTEDPRESSED := 6

   ;  ---- IEBARMENUSTATES  ---- ;
	Global EBM_NORMAL := 1
	Global EBM_HOT := 2
	Global EBM_PRESSED := 3

   ;  ---- NORMALGROUPCOLLAPSESTATES  ---- ;
	Global EBNGC_NORMAL := 1
	Global EBNGC_HOT := 2
	Global EBNGC_PRESSED := 3

   ;  ---- NORMALGROUPEXPANDSTATES ---- ;
	Global EBNGE_NORMAL := 1
	Global EBNGE_HOT := 2
	Global EBNGE_PRESSED := 3

   ;  ---- SPECIALGROUPCOLLAPSESTATES  ---- ;
	Global EBSGC_NORMAL := 1
	Global EBSGC_HOT := 2
	Global EBSGC_PRESSED := 3

   ;  ---- SPECIALGROUPEXPANDSTATES  ---- ;
	Global EBSGE_NORMAL := 1
	Global EBSGE_HOT := 2
	Global EBSGE_PRESSED := 3

   ;  ---- FLYOUTPARTS  ---- ;
	Global FLYOUT_HEADER        := 1
	Global FLYOUT_BODY          := 2
	Global FLYOUT_LABEL         := 3
	Global FLYOUT_LINK          := 4
	Global FLYOUT_DIVIDER       := 5
	Global FLYOUT_WINDOW        := 6
	Global FLYOUT_LINKAREA      := 7
	Global FLYOUT_LINKHEADER    := 8

   ;  ---- LABELSTATES ---- ;   
	Global FLS_NORMAL           := 1
	Global FLS_SELECTED         := 2
	Global FLS_EMPHASIZED       := 3
	Global FLS_DISABLED         := 4

   ;  ---- LINKSTATES  ---- ;    
	Global FLYOUTLINK_NORMAL    := 1
	Global FLYOUTLINK_HOVER     := 2

   ;  ---- BODYSTATES  ---- ;    
	Global FBS_NORMAL           := 1
	Global FBS_EMPHASIZED       := 2

   ;  ---- LINKHEADERSTATES  ---- ;    
	Global FLH_NORMAL           := 1
	Global FLH_HOVER            := 2

   ;  ---- HEADERPARTS ---- ;
	Global HP_HEADERITEM := 1
	Global HP_HEADERITEMLEFT := 2
	Global HP_HEADERITEMRIGHT := 3
	Global HP_HEADERSORTARROW := 4
	Global HP_HEADERDROPDOWN := 5
	Global HP_HEADERDROPDOWNFILTER := 6
	Global HP_HEADEROVERFLOW := 7

   ;  ---- HEADERSTYLESTATES ---- ;
	Global HBG_DETAILS := 1
	Global HBG_ICON := 2
   ;  ---- HEADERITEMSTATES ---- ;
	Global HIS_NORMAL := 1
	Global HIS_HOT := 2
	Global HIS_PRESSED := 3
	Global HIS_SORTEDNORMAL := 4
	Global HIS_SORTEDHOT := 5
	Global HIS_SORTEDPRESSED := 6
	Global HIS_ICONNORMAL := 7
	Global HIS_ICONHOT := 8
	Global HIS_ICONPRESSED := 9
	Global HIS_ICONSORTEDNORMAL := 10
	Global HIS_ICONSORTEDHOT := 11
	Global HIS_ICONSORTEDPRESSED := 12

   ;  ---- HEADERITEMLEFTSTATES ---- ;
	Global HILS_NORMAL := 1
	Global HILS_HOT := 2
	Global HILS_PRESSED := 3

   ;  ---- HEADERITEMRIGHTSTATES ---- ;
	Global HIRS_NORMAL := 1
	Global HIRS_HOT := 2
	Global HIRS_PRESSED := 3
   ;  ---- HEADERSORTARROWSTATES ---- ;
	Global HSAS_SORTEDUP := 1
	Global HSAS_SORTEDDOWN := 2

   ;  ---- HEADERDROPDOWNSTATES ---- ;
	Global HDDS_NORMAL := 1
	Global HDDS_SOFTHOT := 2
	Global HDDS_HOT := 3
   ;  ---- HEADERDROPDOWNFILTERSTATES ---- ;
	Global HDDFS_NORMAL := 1
	Global HDDFS_SOFTHOT := 2
	Global HDDFS_HOT := 3

   ;  ---- HEADEROVERFLOWSTATES ---- ;
	Global HOFS_NORMAL := 1
	Global HOFS_HOT := 2

   ;  ---- LISTBOXPARTS ---- ;
	Global LBCP_BORDER_HSCROLL := 1
	Global LBCP_BORDER_HVSCROLL := 2
	Global LBCP_BORDER_NOSCROLL := 3
	Global LBCP_BORDER_VSCROLL := 4
	Global LBCP_ITEM := 5

   ;  ---- BORDER_HSCROLLSTATES ---- ;
	Global LBPSH_NORMAL := 1
	Global LBPSH_FOCUSED := 2
	Global LBPSH_HOT := 3
	Global LBPSH_DISABLED := 4

   ;  ---- BORDER_HVSCROLLSTATES ---- ;
	Global LBPSHV_NORMAL := 1
	Global LBPSHV_FOCUSED := 2
	Global LBPSHV_HOT := 3
	Global LBPSHV_DISABLED := 4

   ;  ---- BORDER_NOSCROLLSTATES ---- ;
	Global LBPSN_NORMAL := 1
	Global LBPSN_FOCUSED := 2
	Global LBPSN_HOT := 3
	Global LBPSN_DISABLED := 4

   ;  ---- BORDER_VSCROLLSTATES ---- ;
	Global LBPSV_NORMAL := 1
	Global LBPSV_FOCUSED := 2
	Global LBPSV_HOT := 3
	Global LBPSV_DISABLED := 4

   ;  ---- ITEMSTATES ---- ;
	Global LBPSI_HOT := 1
	Global LBPSI_HOTSELECTED := 2
	Global LBPSI_SELECTED := 3
	Global LBPSI_SELECTEDNOTFOCUS := 4

   ;  ---- LISTVIEWPARTS ---- ;
	Global LVP_LISTITEM := 1
	Global LVP_LISTGROUP := 2
	Global LVP_LISTDETAIL := 3
	Global LVP_LISTSORTEDDETAIL := 4
	Global LVP_EMPTYTEXT := 5
	Global LVP_GROUPHEADER := 6
	Global LVP_GROUPHEADERLINE := 7
	Global LVP_EXPANDBUTTON := 8
	Global LVP_COLLAPSEBUTTON := 9
	Global LVP_COLUMNDETAIL := 10

   ;  ---- LISTITEMSTATES ---- ;
	Global LISS_NORMAL := 1
	Global LISS_HOT := 2
	Global LISS_SELECTED := 3
	Global LISS_DISABLED := 4
	Global LISS_SELECTEDNOTFOCUS := 5
	Global LISS_HOTSELECTED := 6

   ;  ---- GROUPHEADERSTATES ---- ;
	Global LVGH_OPEN := 1
	Global LVGH_OPENHOT := 2
	Global LVGH_OPENSELECTED := 3
	Global LVGH_OPENSELECTEDHOT := 4
	Global LVGH_OPENSELECTEDNOTFOCUSED := 5
	Global LVGH_OPENSELECTEDNOTFOCUSEDHOT := 6
	Global LVGH_OPENMIXEDSELECTION := 7
	Global LVGH_OPENMIXEDSELECTIONHOT := 8
	Global LVGH_CLOSE := 9
	Global LVGH_CLOSEHOT := 10
	Global LVGH_CLOSESELECTED := 11
	Global LVGH_CLOSESELECTEDHOT := 12
	Global LVGH_CLOSESELECTEDNOTFOCUSED := 13
	Global LVGH_CLOSESELECTEDNOTFOCUSEDHOT := 14
	Global LVGH_CLOSEMIXEDSELECTION := 15
	Global LVGH_CLOSEMIXEDSELECTIONHOT := 16

   ;  ---- GROUPHEADERLINESTATES ---- ;
	Global LVGHL_OPEN := 1
	Global LVGHL_OPENHOT := 2
	Global LVGHL_OPENSELECTED := 3
	Global LVGHL_OPENSELECTEDHOT := 4
	Global LVGHL_OPENSELECTEDNOTFOCUSED := 5
	Global LVGHL_OPENSELECTEDNOTFOCUSEDHOT := 6
	Global LVGHL_OPENMIXEDSELECTION := 7
	Global LVGHL_OPENMIXEDSELECTIONHOT := 8
	Global LVGHL_CLOSE := 9
	Global LVGHL_CLOSEHOT := 10
	Global LVGHL_CLOSESELECTED := 11
	Global LVGHL_CLOSESELECTEDHOT := 12
	Global LVGHL_CLOSESELECTEDNOTFOCUSED := 13
	Global LVGHL_CLOSESELECTEDNOTFOCUSEDHOT := 14
	Global LVGHL_CLOSEMIXEDSELECTION := 15
	Global 	Global LVGHL_CLOSEMIXEDSELECTIONHOT := 16

   ;  ---- EXPANDBUTTONSTATES ---- ;
	Global LVEB_NORMAL := 1
	Global LVEB_HOVER := 2
	Global LVEB_PUSHED := 3

   ;  ---- COLLAPSEBUTTONSTATES ---- ;
	Global LVCB_NORMAL := 1
	Global LVCB_HOVER := 2
	Global LVCB_PUSHED := 3

   ;  ---- MENUPARTS ---- ;
	Global MENU_MENUITEM_TMSCHEMA := 1
	Global MENU_MENUDROPDOWN_TMSCHEMA := 2
	Global MENU_MENUBARITEM_TMSCHEMA := 3
	Global MENU_MENUBARDROPDOWN_TMSCHEMA := 4
	Global MENU_CHEVRON_TMSCHEMA := 5
	Global MENU_SEPARATOR_TMSCHEMA := 6
	Global MENU_BARBACKGROUND := 7
	Global MENU_BARITEM := 8
	Global MENU_POPUPBACKGROUND := 9
	Global MENU_POPUPBORDERS := 10
	Global MENU_POPUPCHECK := 11
	Global MENU_POPUPCHECKBACKGROUND := 12
	Global MENU_POPUPGUTTER := 13
	Global MENU_POPUPITEM := 14
	Global MENU_POPUPSEPARATOR := 15
	Global MENU_POPUPSUBMENU := 16
	Global MENU_SYSTEMCLOSE := 17
	Global MENU_SYSTEMMAXIMIZE := 18
	Global MENU_SYSTEMMINIMIZE := 19
	Global MENU_SYSTEMRESTORE := 20

   ;  ---- BARBACKGROUNDSTATES ---- ;
	Global MB_ACTIVE := 1
	Global MB_INACTIVE := 2

   ;  ---- BARITEMSTATES ---- ;
	Global MBI_NORMAL := 1
	Global MBI_HOT := 2
	Global MBI_PUSHED := 3
	Global MBI_DISABLED := 4
	Global MBI_DISABLEDHOT := 5
	Global MBI_DISABLEDPUSHED := 6

   ;  ---- POPUPCHECKSTATES ---- ;
	Global MC_CHECKMARKNORMAL := 1
	Global MC_CHECKMARKDISABLED := 2
	Global MC_BULLETNORMAL := 3
	Global MC_BULLETDISABLED := 4

   ;  ---- POPUPCHECKBACKGROUNDSTATES ---- ;
	Global MCB_DISABLED := 1
	Global MCB_NORMAL := 2
	Global MCB_BITMAP := 3

   ;  ---- POPUPITEMSTATES ---- ;
	Global MPI_NORMAL := 1
	Global MPI_HOT := 2
	Global MPI_DISABLED := 3
	Global MPI_DISABLEDHOT := 4

   ;  ---- POPUPSUBMENUSTATES ---- ;
	Global MSM_NORMAL := 1
	Global MSM_DISABLED := 2

   ;  ---- SYSTEMCLOSESTATES ---- ;
	Global MSYSC_NORMAL := 1
	Global MSYSC_DISABLED := 2

   ;  ---- SYSTEMMAXIMIZESTATES ---- ;
	Global MSYSMX_NORMAL := 1
	Global MSYSMX_DISABLED := 2

   ;  ---- SYSTEMMINIMIZESTATES ---- ;
	Global MSYSMN_NORMAL := 1
	Global MSYSMN_DISABLED := 2

   ;  ---- SYSTEMRESTORESTATES ---- ;
	Global MSYSR_NORMAL := 1
	Global MSYSR_DISABLED := 2

   ;  ---- NAVIGATIONPARTS ---- ;
	Global NAV_BACKBUTTON := 1
	Global NAV_FORWARDBUTTON := 2
	Global NAV_MENUBUTTON := 3

   ;  ---- NAV_BACKBUTTONSTATES ---- ;
	Global NAV_BB_NORMAL := 1
	Global NAV_BB_HOT := 2
	Global NAV_BB_PRESSED := 3
	Global NAV_BB_DISABLED := 4

   ;  ---- NAV_FORWARDBUTTONSTATES ---- ;
	Global NAV_FB_NORMAL := 1
	Global NAV_FB_HOT := 2
	Global NAV_FB_PRESSED := 3
	Global NAV_FB_DISABLED := 4

   ;  ---- NAV_MENUBUTTONSTATES ---- ;
	Global NAV_MB_NORMAL := 1
	Global NAV_MB_HOT := 2
	Global NAV_MB_PRESSED := 3
	Global NAV_MB_DISABLED := 4

   ;  ---- PROGRESSPARTS ---- ;
	Global PP_BAR := 1
	Global PP_BARVERT := 2
	Global PP_CHUNK := 3
	Global PP_CHUNKVERT := 4
	Global PP_FILL := 5
	Global PP_FILLVERT := 6
	Global PP_PULSEOVERLAY := 7
	Global PP_MOVEOVERLAY := 8
	Global PP_PULSEOVERLAYVERT := 9
	Global PP_MOVEOVERLAYVERT := 10
	Global PP_TRANSPARENTBAR := 11
	Global PP_TRANSPARENTBARVERT := 12

   ;  ---- TRANSPARENTBARSTATES ---- ;
	Global PBBS_NORMAL := 1
	Global PBBS_PARTIAL := 2

   ;  ---- TRANSPARENTBARVERTSTATES ---- ;
	Global PBBVS_NORMAL := 1
	Global PBBVS_PARTIAL := 2

   ;  ---- FILLSTATES ---- ;
	Global PBFS_NORMAL := 1
	Global PBFS_ERROR := 2
	Global PBFS_PAUSED := 3
	Global PBFS_PARTIAL := 4

   ;  ---- FILLVERTSTATES ---- ;
	Global PBFVS_NORMAL := 1
	Global PBFVS_ERROR := 2
	Global PBFVS_PAUSED := 3
	Global PBFVS_PARTIAL := 4

   ;  ---- REBARPARTS ---- ;
	Global RP_GRIPPER := 1
	Global RP_GRIPPERVERT := 2
	Global RP_BAND := 3
	Global RP_CHEVRON := 4
	Global RP_CHEVRONVERT := 5
	Global RP_BACKGROUND := 6
	Global RP_SPLITTER := 7
	Global RP_SPLITTERVERT := 8

   ;  ---- CHEVRONSTATES ---- ;
	Global CHEVS_NORMAL := 1
	Global CHEVS_HOT := 2
	Global CHEVS_PRESSED := 3

   ;  ---- CHEVRONVERTSTATES ---- ;
	Global CHEVSV_NORMAL := 1
	Global CHEVSV_HOT := 2
	Global CHEVSV_PRESSED := 3

   ;  ---- SPLITTERSTATES ---- ;
	Global SPLITS_NORMAL := 1
	Global SPLITS_HOT := 2
	Global SPLITS_PRESSED := 3

   ;  ---- SPLITTERVERTSTATES ---- ;
	Global SPLITSV_NORMAL := 1
	Global SPLITSV_HOT := 2
	Global SPLITSV_PRESSED := 3

   ;  ---- SCROLLBARPARTS ---- ;
	Global SBP_ARROWBTN := 1
	Global SBP_THUMBBTNHORZ := 2
	Global SBP_THUMBBTNVERT := 3
	Global SBP_LOWERTRACKHORZ := 4
	Global SBP_UPPERTRACKHORZ := 5
	Global SBP_LOWERTRACKVERT := 6
	Global SBP_UPPERTRACKVERT := 7
	Global SBP_GRIPPERHORZ := 8
	Global SBP_GRIPPERVERT := 9
	Global SBP_SIZEBOX := 10

   ;  ---- ARROWBTNSTATES ---- ;
	Global ABS_UPNORMAL := 1
	Global ABS_UPHOT := 2
	Global ABS_UPPRESSED := 3
	Global ABS_UPDISABLED := 4
	Global ABS_DOWNNORMAL := 5
	Global ABS_DOWNHOT := 6
	Global ABS_DOWNPRESSED := 7
	Global ABS_DOWNDISABLED := 8
	Global ABS_LEFTNORMAL := 9
	Global ABS_LEFTHOT := 10
	Global ABS_LEFTPRESSED := 11
	Global ABS_LEFTDISABLED := 12
	Global ABS_RIGHTNORMAL := 13
	Global ABS_RIGHTHOT := 14
	Global ABS_RIGHTPRESSED := 15
	Global ABS_RIGHTDISABLED := 16
	Global ABS_UPHOVER := 17
	Global ABS_DOWNHOVER := 18
	Global ABS_LEFTHOVER := 19
	Global ABS_RIGHTHOVER := 20

   ;  ---- SCROLLBARSTYLESTATES ---- ;
	Global SCRBS_NORMAL := 1
	Global SCRBS_HOT := 2
	Global SCRBS_PRESSED := 3
	Global SCRBS_DISABLED := 4
	Global SCRBS_HOVER := 5

   ;  ---- SIZEBOXSTATES ---- ;
	Global SZB_RIGHTALIGN := 1
	Global SZB_LEFTALIGN := 2
	Global SZB_TOPRIGHTALIGN := 3
	Global SZB_TOPLEFTALIGN := 4
	Global SZB_HALFBOTTOMRIGHTALIGN := 5
	Global SZB_HALFBOTTOMLEFTALIGN := 6
	Global SZB_HALFTOPRIGHTALIGN := 7
	Global SZB_HALFTOPLEFTALIGN := 8

   ;  ---- SPINPARTS ---- ;
	Global SPNP_UP := 1
	Global SPNP_DOWN := 2
	Global SPNP_UPHORZ := 3
	Global SPNP_DOWNHORZ := 4

   ;  ---- UPSTATES ---- ;
	Global UPS_NORMAL := 1
	Global UPS_HOT := 2
	Global UPS_PRESSED := 3
	Global UPS_DISABLED := 4

   ;  ---- DOWNSTATES ---- ;
	Global DNS_NORMAL := 1
	Global DNS_HOT := 2
	Global DNS_PRESSED := 3
	Global DNS_DISABLED := 4

   ;  ---- UPHORZSTATES ---- ;
	Global UPHZS_NORMAL := 1
	Global UPHZS_HOT := 2
	Global UPHZS_PRESSED := 3
	Global UPHZS_DISABLED := 4

   ;  ---- DOWNHORZSTATES ---- ;
	Global DNHZS_NORMAL := 1
	Global DNHZS_HOT := 2
	Global DNHZS_PRESSED := 3
	Global DNHZS_DISABLED := 4

   ;  ---- STATUSPARTS ---- ;
	Global SP_PANE := 1
	Global SP_GRIPPERPANE := 2
	Global SP_GRIPPER := 3

   ;  ---- TABPARTS ---- ;
	Global TABP_TABITEM := 1
	Global TABP_TABITEMLEFTEDGE := 2
	Global TABP_TABITEMRIGHTEDGE := 3
	Global TABP_TABITEMBOTHEDGE := 4
	Global TABP_TOPTABITEM := 5
	Global TABP_TOPTABITEMLEFTEDGE := 6
	Global TABP_TOPTABITEMRIGHTEDGE := 7
	Global TABP_TOPTABITEMBOTHEDGE := 8
	Global TABP_PANE := 9
	Global TABP_BODY := 10
	Global TABP_AEROWIZARDBODY := 11

   ;  ---- TABITEMSTATES ---- ;
	Global TIS_NORMAL := 1
	Global TIS_HOT := 2
	Global TIS_SELECTED := 3
	Global TIS_DISABLED := 4
	Global TIS_FOCUSED := 5

   ;  ---- TABITEMLEFTEDGESTATES ---- ;
	Global TILES_NORMAL := 1
	Global TILES_HOT := 2
	Global TILES_SELECTED := 3
	Global TILES_DISABLED := 4
	Global TILES_FOCUSED := 5

   ;  ---- TABITEMRIGHTEDGESTATES ---- ;
	Global TIRES_NORMAL := 1
	Global TIRES_HOT := 2
	Global TIRES_SELECTED := 3
	Global TIRES_DISABLED := 4
	Global TIRES_FOCUSED := 5

   ;  ---- TABITEMBOTHEDGESTATES ---- ;
	Global TIBES_NORMAL := 1
	Global TIBES_HOT := 2
	Global TIBES_SELECTED := 3
	Global TIBES_DISABLED := 4
	Global TIBES_FOCUSED := 5

   ;  ---- TOPTABITEMSTATES ---- ;
	Global TTIS_NORMAL := 1
	Global TTIS_HOT := 2
	Global TTIS_SELECTED := 3
	Global TTIS_DISABLED := 4
	Global TTIS_FOCUSED := 5

   ;  ---- TOPTABITEMLEFTEDGESTATES ---- ;
	Global TTILES_NORMAL := 1
	Global TTILES_HOT := 2
	Global TTILES_SELECTED := 3
	Global TTILES_DISABLED := 4
	Global TTILES_FOCUSED := 5

   ;  ---- TOPTABITEMRIGHTEDGESTATES ---- ;
	Global TTIRES_NORMAL := 1
	Global TTIRES_HOT := 2
	Global TTIRES_SELECTED := 3
	Global TTIRES_DISABLED := 4
	Global TTIRES_FOCUSED := 5

   ;  ---- TOPTABITEMBOTHEDGESTATES ---- ;
	Global TTIBES_NORMAL := 1
	Global TTIBES_HOT := 2
	Global TTIBES_SELECTED := 3
	Global TTIBES_DISABLED := 4
	Global TTIBES_FOCUSED := 5

   ;  ---- TASKDIALOGPARTS ---- ;
	Global TDLG_PRIMARYPANEL := 1
	Global TDLG_MAININSTRUCTIONPANE := 2
	Global TDLG_MAINICON := 3
	Global TDLG_CONTENTPANE := 4
	Global TDLG_CONTENTICON := 5
	Global TDLG_EXPANDEDCONTENT := 6
	Global TDLG_COMMANDLINKPANE := 7
	Global TDLG_SECONDARYPANEL := 8
	Global TDLG_CONTROLPANE := 9
	Global TDLG_BUTTONSECTION := 10
	Global TDLG_BUTTONWRAPPER := 11
	Global TDLG_EXPANDOTEXT := 12
	Global TDLG_EXPANDOBUTTON := 13
	Global TDLG_VERIFICATIONTEXT := 14
	Global TDLG_FOOTNOTEPANE := 15
	Global TDLG_FOOTNOTEAREA := 16
	Global TDLG_FOOTNOTESEPARATOR := 17
	Global TDLG_EXPANDEDFOOTERAREA := 18
	Global TDLG_PROGRESSBAR := 19
	Global TDLG_IMAGEALIGNMENT := 20
	Global TDLG_RADIOBUTTONPANE := 21

   ;  ---- CONTENTPANESTATES ---- ;
	Global TDLGCPS_STANDALONE := 1

   ;  ---- EXPANDOBUTTONSTATES ---- ;
	Global TDLGEBS_NORMAL := 1
	Global TDLGEBS_HOVER := 2
	Global TDLGEBS_PRESSED := 3
	Global TDLGEBS_EXPANDEDNORMAL := 4
	Global TDLGEBS_EXPANDEDHOVER := 5
	Global TDLGEBS_EXPANDEDPRESSED := 6

   ;  ---- TEXTSTYLEPARTS ---- ;
	Global TEXT_MAININSTRUCTION := 1
	Global TEXT_INSTRUCTION     := 2
	Global TEXT_BODYTITLE       := 3
	Global TEXT_BODYTEXT        := 4
	Global TEXT_SECONDARYTEXT   := 5
	Global TEXT_HYPERLINKTEXT   := 6
	Global TEXT_EXPANDED        := 7
	Global TEXT_LABEL           := 8
	Global TEXT_CONTROLLABEL    := 9

   ;  ---- HYPERLINKTEXTSTATES ---- ;
	Global TS_HYPERLINK_NORMAL  := 1
	Global TS_HYPERLINK_HOT     := 2
	Global TS_HYPERLINK_PRESSED := 3
	Global TS_HYPERLINK_DISABLED:= 4

   ;  ---- CONTROLLABELSTATES ---- ;
	Global TS_CONTROLLABEL_NORMAL  := 1
	Global TS_CONTROLLABEL_DISABLED:= 2

   ;  ---- TOOLBARPARTS ---- ;
	Global TP_BUTTON := 1
	Global TP_DROPDOWNBUTTON := 2
	Global TP_SPLITBUTTON := 3
	Global TP_SPLITBUTTONDROPDOWN := 4
	Global TP_SEPARATOR := 5
	Global TP_SEPARATORVERT := 6

   ;  ---- TOOLBARSTYLESTATES ---- ;
	Global TS_NORMAL := 1
	Global TS_HOT := 2
	Global TS_PRESSED := 3
	Global TS_DISABLED := 4
	Global TS_CHECKED := 5
	Global TS_HOTCHECKED := 6
	Global TS_NEARHOT := 7
	Global TS_OTHERSIDEHOT := 8

   ;  ---- TOOLTIPPARTS ---- ;
	Global TTP_STANDARD := 1
	Global TTP_STANDARDTITLE := 2
	Global TTP_BALLOON := 3
	Global TTP_BALLOONTITLE := 4
	Global TTP_CLOSE := 5
	Global TTP_BALLOONSTEM := 6

   ;  ---- CLOSESTATES ---- ;
	Global TTCS_NORMAL := 1
	Global TTCS_HOT := 2
	Global TTCS_PRESSED := 3

   ;  ---- STANDARDSTATES ---- ;
	Global TTSS_NORMAL := 1
	Global TTSS_LINK := 2

   ;  ---- BALLOONSTATES ---- ;
	Global TTBS_NORMAL := 1
	Global TTBS_LINK := 2

   ;  ---- BALLOONSTEMSTATES ---- ;
	Global TTBSS_POINTINGUPLEFTWALL := 1
	Global TTBSS_POINTINGUPCENTERED := 2
	Global TTBSS_POINTINGUPRIGHTWALL := 3
	Global TTBSS_POINTINGDOWNRIGHTWALL := 4
	Global TTBSS_POINTINGDOWNCENTERED := 5
	Global TTBSS_POINTINGDOWNLEFTWALL := 6

   ;  ---- TRACKBARPARTS ---- ;
	Global TKP_TRACK := 1
	Global TKP_TRACKVERT := 2
	Global TKP_THUMB := 3
	Global TKP_THUMBBOTTOM := 4
	Global TKP_THUMBTOP := 5
	Global TKP_THUMBVERT := 6
	Global TKP_THUMBLEFT := 7
	Global TKP_THUMBRIGHT := 8
	Global TKP_TICS := 9
	Global TKP_TICSVERT := 10

   ;  ---- TRACKBARSTYLESTATES ---- ;
	Global TKS_NORMAL := 1

   ;  ---- TRACKSTATES ---- ;
	Global TRS_NORMAL := 1

   ;  ---- TRACKVERTSTATES ---- ;
	Global TRVS_NORMAL := 1

   ;  ---- THUMBSTATES ---- ;
	Global TUS_NORMAL := 1
	Global TUS_HOT := 2
	Global TUS_PRESSED := 3
	Global TUS_FOCUSED := 4
	Global TUS_DISABLED := 5

   ;  ---- THUMBBOTTOMSTATES ---- ;
	Global TUBS_NORMAL := 1
	Global TUBS_HOT := 2
	Global TUBS_PRESSED := 3
	Global TUBS_FOCUSED := 4
	Global TUBS_DISABLED := 5

   ;  ---- THUMBTOPSTATES ---- ;
	Global TUTS_NORMAL := 1
	Global TUTS_HOT := 2
	Global TUTS_PRESSED := 3
	Global TUTS_FOCUSED := 4
	Global TUTS_DISABLED := 5

   ;  ---- THUMBVERTSTATES ---- ;
	Global TUVS_NORMAL := 1
	Global TUVS_HOT := 2
	Global TUVS_PRESSED := 3
	Global TUVS_FOCUSED := 4
	Global TUVS_DISABLED := 5

   ;  ---- THUMBLEFTSTATES ---- ;
	Global TUVLS_NORMAL := 1
	Global TUVLS_HOT := 2
	Global TUVLS_PRESSED := 3
	Global TUVLS_FOCUSED := 4
	Global TUVLS_DISABLED := 5

   ;  ---- THUMBRIGHTSTATES ---- ;
	Global TUVRS_NORMAL := 1
	Global TUVRS_HOT := 2
	Global TUVRS_PRESSED := 3
	Global TUVRS_FOCUSED := 4
	Global TUVRS_DISABLED := 5

   ;  ---- TICSSTATES ---- ;
	Global TSS_NORMAL := 1

   ;  ---- TICSVERTSTATES ---- ;
	Global TSVS_NORMAL := 1

   ;  ---- TREEVIEWPARTS ---- ;
	Global TVP_TREEITEM := 1
	Global TVP_GLYPH := 2
	Global TVP_BRANCH := 3
	Global TVP_HOTGLYPH := 4

   ;  ---- TREEITEMSTATES ---- ;
	Global TREIS_NORMAL := 1
	Global TREIS_HOT := 2
	Global TREIS_SELECTED := 3
	Global TREIS_DISABLED := 4
	Global TREIS_SELECTEDNOTFOCUS := 5
	Global TREIS_HOTSELECTED := 6

   ;  ---- GLYPHSTATES ---- ;
	Global GLPS_CLOSED := 1
	Global GLPS_OPENED := 2

   ;  ---- HOTGLYPHSTATES ---- ;
	Global HGLPS_CLOSED := 1
	Global HGLPS_OPENED := 2

   ;  ---- WINDOWPARTS ---- ;
	Global WP_CAPTION := 1  ;needed
	Global WP_SMALLCAPTION := 2
	Global WP_MINCAPTION := 3
	Global WP_SMALLMINCAPTION := 4
	Global WP_MAXCAPTION := 5
	Global WP_SMALLMAXCAPTION := 6
	Global WP_FRAMELEFT := 7
	Global WP_FRAMERIGHT := 8
	Global WP_FRAMEBOTTOM := 9
	Global WP_SMALLFRAMELEFT := 10
	Global WP_SMALLFRAMERIGHT := 11
	Global WP_SMALLFRAMEBOTTOM := 12
	Global WP_SYSBUTTON := 13
	Global WP_MDISYSBUTTON := 14
	Global WP_MINBUTTON := 15
	Global WP_MDIMINBUTTON := 16
	Global WP_MAXBUTTON := 17
	Global WP_CLOSEBUTTON := 18
	Global WP_SMALLCLOSEBUTTON := 19
	Global WP_MDICLOSEBUTTON := 20
	Global WP_RESTOREBUTTON := 21
	Global WP_MDIRESTOREBUTTON := 22
	Global WP_HELPBUTTON := 23
	Global WP_MDIHELPBUTTON := 24
	Global WP_HORZSCROLL := 25
	Global WP_HORZTHUMB := 26
	Global WP_VERTSCROLL := 27
	Global WP_VERTTHUMB := 28
	Global WP_DIALOG := 29
	Global WP_CAPTIONSIZINGTEMPLATE := 30
	Global WP_SMALLCAPTIONSIZINGTEMPLATE := 31
	Global WP_FRAMELEFTSIZINGTEMPLATE := 32
	Global WP_SMALLFRAMELEFTSIZINGTEMPLATE := 33
	Global WP_FRAMERIGHTSIZINGTEMPLATE := 34
	Global WP_SMALLFRAMERIGHTSIZINGTEMPLATE := 35
	Global WP_FRAMEBOTTOMSIZINGTEMPLATE := 36
	Global WP_SMALLFRAMEBOTTOMSIZINGTEMPLATE := 37
	Global WP_FRAME := 38

   ;  ---- FRAMESTATES ---- ;
	Global FS_ACTIVE := 1
	Global FS_INACTIVE := 2

   ;  ---- CAPTIONSTATES ---- ;
	Global CS_ACTIVE := 1  ;needed
	Global CS_INACTIVE := 2
	Global CS_DISABLED := 3

   ;  ---- MAXCAPTIONSTATES ---- ;
	Global MXCS_ACTIVE := 1
	Global MXCS_INACTIVE := 2
	Global MXCS_DISABLED := 3

   ;  ---- MINCAPTIONSTATES ---- ;
	Global MNCS_ACTIVE := 1
	Global MNCS_INACTIVE := 2
	Global MNCS_DISABLED := 3

   ;  ---- HORZSCROLLSTATES ---- ;
	Global HSS_NORMAL := 1
	Global HSS_HOT := 2
	Global HSS_PUSHED := 3
	Global HSS_DISABLED := 4

   ;  ---- HORZTHUMBSTATES ---- ;
	Global HTS_NORMAL := 1
	Global HTS_HOT := 2
	Global HTS_PUSHED := 3
	Global HTS_DISABLED := 4

   ;  ---- VERTSCROLLSTATES ---- ;
	Global VSS_NORMAL := 1
	Global VSS_HOT := 2
	Global VSS_PUSHED := 3
	Global VSS_DISABLED := 4

   ;  ---- VERTTHUMBSTATES ---- ;
	Global VTS_NORMAL := 1
	Global VTS_HOT := 2
	Global VTS_PUSHED := 3
	Global VTS_DISABLED := 4

   ;  ---- SYSBUTTONSTATES ---- ;
	Global SBS_NORMAL := 1
	Global SBS_HOT := 2
	Global SBS_PUSHED := 3
	Global SBS_DISABLED := 4

   ;  ---- MINBUTTONSTATES ---- ;
	Global MINBS_NORMAL := 1
	Global MINBS_HOT := 2
	Global MINBS_PUSHED := 3
	Global MINBS_DISABLED := 4

   ;  ---- MAXBUTTONSTATES ---- ;
	Global MAXBS_NORMAL := 1
	Global MAXBS_HOT := 2
	Global MAXBS_PUSHED := 3
	Global MAXBS_DISABLED := 4

   ;  ---- RESTOREBUTTONSTATES ---- ;
	Global RBS_NORMAL := 1
	Global RBS_HOT := 2
	Global RBS_PUSHED := 3
	Global RBS_DISABLED := 4

   ;  ---- HELPBUTTONSTATES ---- ;
	Global HBS_NORMAL := 1
	Global HBS_HOT := 2
	Global HBS_PUSHED := 3
	Global HBS_DISABLED := 4

   ;  ---- CLOSEBUTTONSTATES ---- ;
	Global CBS_NORMAL := 1
	Global CBS_HOT := 2
	Global CBS_PUSHED := 3
	Global CBS_DISABLED := 4