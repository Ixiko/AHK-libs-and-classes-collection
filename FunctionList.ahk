;{  A.ahk

;Functions:
0008 | A_Put(ByRef Array, ByRef Data, Index=-1, dSize=-1)
0095 | A_Get(ByRef Array, Index)
0117 | A_Implode(ByRef Array, glue=" ")
0148 | A_Explode(ByRef Array, dString, sString, Limit=0, trimChars="", trimCharsIsRegEx=False, dStringIsRegEx=False)
0190 | A_Del(ByRef Array, Item=-1)
0222 | A_Pop(ByRef Array)
0240 | A_Shift(ByRef Array)
0257 | A_Swap(ByRef Array, IdxA, IdxB)
0272 | A_Slice(ByRef Array, ByRef sArray, Start, End)
0295 | A_Merge(Byref Array, ByRef sArray)
0307 | A_Array(byRef Array)
0312 | A_Count(byRef Array)
0323 | A_Init(byRef Array)
0339 | A_Size(ByRef Array)
0350 | A_Length(ByRef Array)
0360 | A_Dump(ByRef Array)
0376 | A_ArrayMM(Target, Source, Length)
0381 | A___ArrayBin(ByRef Array,offset,length)
0400 | A___ArrayInsideView(Array)

;Labels:
0085 | GetArrayStats

;}
;{  ACC.ahk

;Functions:
0013 | Acc_Init()
0018 | Acc_ObjectFromEvent(ByRef _idChild_, hWnd, idObject, idChild)
0023 | Acc_ObjectFromPoint(ByRef _idChild_ = "", x = "", y = "")
0028 | Acc_ObjectFromWindow(hWnd, idObject = -4)
0033 | Acc_WindowFromObject(pacc)
0037 | Acc_GetRoleText(nRole)
0043 | Acc_GetStateText(nState)
0049 | Acc_SetWinEventHook(eventMin, eventMax, pCallback)
0052 | Acc_UnhookWinEvent(hHook)
0068 | Acc_Role(Acc, ChildId=0)
0071 | Acc_State(Acc, ChildId=0)
0074 | Acc_Location2(Acc, ChildId=0, byref Position="")
0081 | Acc_Children(Acc)
0094 | Acc_Location(Acc, ChildId=0)
0101 | Acc_Parent(Acc)
0105 | Acc_Child(Acc, ChildId=0)
0109 | Acc_Query(Acc)
0112 | Acc_Error(p="")
0116 | Acc_ChildrenByRole(Acc, Role)
0136 | Acc_Get(Cmd, ChildPath="", ChildID=0, WinTitle="", WinText="", ExcludeTitle="", ExcludeText="")

;}
;{  ACC_more.ahk

;Functions:
0007 | ACC_Init()
0013 | ACC_Term()
0019 | ACC_AccessibleChildren(pacc, ByRef varChildren)
0025 | ACC_AccessibleObjectFromEvent(hWnd, idObject, idChild, ByRef _idChild_)
0032 | ACC_AccessibleObjectFromPoint(x = "", y = "", ByRef _idChild_ = "")
0040 | ACC_AccessibleObjectFromWindow(hWnd = "", idObject = -4)
0047 | ACC_WindowFromAccessibleObject(pacc)
0052 | ACC_GetRoleText(nRole)
0059 | ACC_GetStateText(nState)
0067 | ACC_SetWinEventHook(eventMin, eventMax, pCallback)
0071 | ACC_UnhookWinEvent(hHook)
0075 | ACC_WinEventProc(hHook, event, hWnd, idObject, idChild, eventThread, eventTime)
0084 | acc_Query(pacc, bunk = "")
0090 | acc_Parent(pacc)
0095 | acc_ChildCount(pacc)
0100 | acc_Child(pacc, idChild)
0105 | acc_Name(pacc, idChild = 0)
0110 | acc_Value(pacc, idChild = 0)
0115 | acc_Description(pacc, idChild = 0)
0120 | acc_Role(pacc, idChild = 0)
0126 | acc_State(pacc, idChild = 0)
0166 | acc_Help(pacc, idChild = 0)
0171 | acc_HelpTopic(pacc, idChild = 0)
0176 | acc_KeyboardShortcut(pacc, idChild = 0)
0181 | acc_Focus(pacc)
0187 | acc_Selection(pacc)
0193 | acc_DefaultAction(pacc, idChild = 0)
0198 | acc_Select(pacc, idChild = 0, nFlags = 3)
0210 | acc_Location(pacc, idChild = 0, ByRef l = "", ByRef t = "", ByRef w = "", ByRef h = "")
0215 | acc_Navigate(pacc, idChild = 0, nDir = 7)
0231 | acc_HitTest(pacc, x = "", y = "")
0238 | acc_DoDefaultAction(pacc, idChild = 0)
0243 | acc_Name_(pacc, idChild = 0, sName = "")
0248 | acc_Value_(pacc, idChild = 0, sValue = "")
0252 | acc_Hex(num)

;}
;{  AddGraphicButton.ahk

;Functions:
0024 | AddGraphicButton(GUI_Number, Button_X, Button_Y, Button_H, Button_W, Button_Identifier, Button_Up, Button_Hover, Button_Down)
0038 | MouseMove(wParam, lParam, msg, hwnd)
0063 | MouseLDown(wParam, lParam, msg, hwnd)
0081 | MouseLUp(wParam, lParam, msg, hwnd)

;}
;{  Aero_Lib.ahk

;Functions:
0052 | Aero_StartUp()
0082 | Aero_Enable(enableBool=1)
0104 | Aero_IsEnabled()
0135 | Aero_BlurWindow(hwndWin ,enableBool=1 ,region=0)
0174 | Aero_GuiBlurWindow(GuiNum="default" ,enableBool=1 ,region=0)
0220 | Aero_ChangeFrameArea(hwndWin, leftPos=0, rightPos=0, topPos=0, bottomPos=0)
0261 | Aero_GuiChangeFrameArea(GuiNum="default", leftPos=0, rightPos=0, topPos=0, bottomPos=0)
0291 | Aero_ChangeFrameAreaAll(hwndWin)
0316 | Aero_GuiChangeFrameAreaAll(GuiNum="deafult")
0337 | Aero_GetDWMColor()
0362 | Aero_GetDWMTrans()
0389 | Aero_SetDWMColor(dwmColor=0x910047ab)
0416 | Aero_SetTrans(dwmTrans)
0454 | Aero_DrawPicture(hwnd,picturePath,xPos=0,yPos=0,autoUpdate=1)
0481 | Aero_CreateBuffer(hWnd)
0502 | Aero_CreateGuiBuffer(GuiNum="default")
0523 | Aero_DeleteBuffer(byref hBuffer)
0550 | Aero_UpdateWindow(hWnd, hBuffer)
0574 | Aero_UpdateGui(hBuffer, GuiNum="default")
0598 | Aero_AutoRepaint(hWnd, hBuffer)
0622 | Aero_AutoRepaintGui(hBuffer, GuiNum="default")
0643 | Aero_DisableAutoRepaint(hWnd)
0664 | Aero_DisableAutoRepaintGui(GuiNum="default")
0685 | Aero_ClearBuffer(hBuffer)
0714 | Aero_LoadImage(Filename)
0745 | Aero_DeleteImage(byref hImage)
0779 | Aero_DrawImage(hBuffer, hImage, x=0, y=0, alpha=0xFF)
0805 | Aero_End(MODUELIDPARAM_="")
0807 | If(MODUELIDPARAM_)
0814 | If(MODULEID)
0835 | Aero_CreateBufferFromBuffer(hBuffer)
0855 | Aero_AutoRepaintCallback(wParam, lParam, msg, hWnd)
0876 | Aero_AlphaBlend(hBufferDst, hBufferSrc, x=0, y=0, alpha=0xFF)
0891 | Aero_Blit(hBufferDst, hBufferSrc, x=0, y=0)
0905 | Aero_MultibyteToWide(Multibyte, byref Wide)
0913 | Aero_DrawText(hBuffer, Text, x=10, y=10, color="", glowsize=14)
0946 | Aero_UseFont(hWnd, hBuffer)
0954 | Aero_UseGuiFont(hBuffer, GuiNum="default")
0960 | IDE_DrawTransImage(hwnd,Path="")

;}
;{  Affinity.ahk

;Functions:
0001 | Affinity_Set( CPU=1, PID=0x0 )

;}
;{  AHKA.ahk

;Functions:
0089 | AHKA_Error(Err="")
0095 | AHKA_IsArray(Array)
0104 | AHKA_Open(Array)
0111 | AHKA_Close(Array)
0115 | AHKA_ParseFirst(Array)
0139 | AHKA_Parse(Array)
0150 | AHKA_Unparse(Array, OArray, skip="")
0171 | AHKA_GetFirstDimension(Array)
0196 | AHKA_GetDimension(Array, Index=0)
0215 | AHKA_Floor(number)
0241 | AHKA_Abs(number)
0250 | AHKA_SetDebug(newDebug)
0255 | AHKA_CheckDebug()
0263 | AHKA_Hex(String,Way,Enabled=true)
0309 | AHKA_CharToHex(String)
0367 | AHKA_CharFromHex(String)
0422 | AHKA_NewArray(String="")
0434 | AHKA_HexArray(Array)
0455 | AHKA_Size(Array)
0465 | AHKA_Add(Array,Value,Index1=0,Index2="",Index3="",Index4="",Index5="",Index6="",Index7="",Index8="",Index9="",Index10="")
0493 | AHKA_AddSimple(Array,Value,Index=0,HexIt=1)
0540 | AHKA_Get(Array,Index1=0,Index2="",Index3="",Index4="",Index5="",Index6="",Index7="",Index8="",Index9="",Index10="")
0552 | AHKA_GetSimple(Array,Index=0)
0605 | AHKA_Remove(Array,Index1=0,Index2="",Index3="",Index4="",Index5="",Index6="",Index7="",Index8="",Index9="",Index10="")
0630 | AHKA_RemoveSimple(Array,Index=0)
0642 | AHKA_Set(Array,Value,Index1=0,Index2="",Index3="",Index4="",Index5="",Index6="",Index7="",Index8="",Index9="",Index10="")
0682 | AHKA_SetSimple(Array,Value,Index=0)
0722 | AHKA_Split(String,Char="",CaseSensitive=false)
0745 | AHKA_Convert(Var)
0759 | AHKA_Sort(Array, First=1, Last=-1)
0811 | AHKA_Swap(Array,IndexA=1,IndexB=0)
0819 | AHKA_Move(Array,IndexA=1,IndexB=0)
0826 | AHKA_Find(Array,Value,Number=1)
0854 | AHKA_Minimum(Array)
0859 | AHKA_Maximum(Array)
0864 | AHKA_Reverse(Array)
0874 | AHKA_Trim(Array,First=0,Last=0)
0896 | AHKA_Merge(Array1, Array2, Array3="", Array4="", Array5="", Array6="", Array7="", Array8="", Array9="", Array10="")
0909 | AHKA_MergeSimple(Array1,Array2)
0917 | AHKA_String(Array, Delimeter="")

;}
;{   AhkDllThread.ahk

;Functions:
0002 | AhkDllThread_IsH()
0012 | AhkDllThread(dll="AutoHotkey.dll",obj=0)

;}
;{   ahkExec.ahk

;Functions:
0001 | ahkExec(Script)

;}
;{   AhkExported.ahk

;Functions:
0001 | AhkExported()

;}
;{   ahkhook.ahk

;Functions:
0005 | InstallHook(hook_function_name, byref function2hook, dll = "", function2hook_name = "" ,callback_options = "F")
0061 | InstallComHook(pInterface, byref pHooked, hook_name, offset, release = True)
0101 | ReleaseHooks()
0138 | redirectCall(_add, _func, options = "F")
0152 | redirectCallD(_add, _func, options = "F")
0170 | getModulePath(exe = "")
0178 | getModuleName(exe = True)
0184 | ahkHookGetScript(resource = "", module = "")

;}
;{   AhkSelf.ahk

;Functions:
0001 | AhkSelf()

;}
;{   AHKsock.ahk

;Functions:
0418 | AHKsock_Listen(sPort, sFunction = False)
0505 | AHKsock_Connect(sName, sPort, sFunction)
0676 | AHKsock_Send(iSocket, ptrData = 0, iLength = 0)
0708 | AHKsock_ForceSend(iSocket, ptrData, iLength)
0801 | AHKsock_Close(iSocket = -1, iTimeout = 5000)
0860 | AHKsock_GetAddrInfo(sHostName, ByRef sIPList, bOne = False)
0896 | AHKsock_GetNameInfo(sIP, ByRef sHostName, sPort = 0, ByRef sService = "")
0929 | AHKsock_SockOpt(iSocket, sOption, iValue = -1)
0972 | AHKsock_Startup(iMode = 0)
1006 | AHKsock_ShutdownSocket(iSocket)
1033 | AHKsock_RegisterAsyncSelect(iSocket, fFlags = 43, sFunction = "AHKsock_AsyncSelect", iMsg = 0)
1054 | AHKsock_AsyncSelect(wParam, lParam)
1213 | AHKsock_Sockets(sAction = "Count", iSocket = "", sName = "", sAddr = "", sPort = "", sFunction = "")
1342 | AHKsock_LastError()
1346 | AHKsock_ErrorHandler(sFunction = """")
1353 | AHKsock_RaiseError(iError, iSocket = -1)
1362 | AHKsock_Settings(sSetting, sValue = "")

;}
;{   ahkstructlib2.ahk

;Functions:
0022 | StructCreate(struct_name ,s_type1, s_var1 ,s_type2="", s_var2="" ,s_type3="", s_var3="",s_type4="" , s_var4="" ,s_type5="" , s_var5="" ,s_type6="" , s_var6="" ,s_type7="" , s_var7="",s_type8="" , s_var8="" ,s_type9="" , s_var9="" ,s_type10="", s_var10="" ,s_type11="", s_var11="",s_type12="", s_var12="" ,s_type13="", s_var13="" ,s_type14="", s_var14="" ,s_type15="", s_var15="",s_type16="", s_var16="" ,s_type17="", s_var17="" ,s_type18="", s_var18="" ,s_type19="", s_var19="",s_type20="", s_var20="" ,s_type21="", s_var21="" ,s_type22="", s_var22="" ,s_type23="", s_var23="",s_type24="", s_var24="" ,s_type25="", s_var25="" ,s_type26="", s_var26="" ,s_type27="", s_var27="",s_type28="", s_var28="" ,s_type29="", s_var29="" ,s_type30="", s_var30="" ,s_type31="", s_var31="",s_type32="", s_var32="")
0118 | struct?(s_query)
0161 | struct@(s_modify, s_value="")
0208 | ExtractIntegerSL(ByRef pSource, pOffset = 0, pIsSigned = false, pSize = 4)
0223 | InsertIntegerSL(pInteger, ByRef pDest, pOffset = 0, pSize = 4)

;}
;{   AhkThread.ahk

;Functions:
0012 | ahkthread_release(o)

;}
;{   AHKType.ahk

;Functions:
0006 | AHKType(exeName)

;}
;{   ALD.Connection.ahk

;Functions:
0007 | __New(URL)
0012 | getUserList(start = 0, count = "all")
0029 | getUser(name, request_user = "", request_password = "")
0045 | getItemById(id)
0053 | getItem(name, version)
0061 | _parseItemXML(doc)
0070 | getItemList(start = 0, count = "all", type = "", user = "", name = "")
0088 | _GETRequest(URL, NamespaceURI, user = "", password = "")
0101 | _POSTRequest(URL, headers, byRef data, NamespaceURI = "", user = "", password = "")
0106 | _Request(method, URL, headers, byRef data, NamespaceURI = "", user = "", password = "")
0140 | uploadItem(package, user, password)

;}
;{   ALD.DefinitionGenerator.ahk

;Functions:
0036 | SaveToFile(file)
0041 | Write()
0064 | _createAuthorList()
0073 | _createAuthorElement(obj)
0088 | _createDependencyList()
0097 | _createDependencyElement(obj)
0121 | _createRequirementsList()
0130 | _createRequirementElement(obj)
0152 | _createFileLists()
0158 | _createDocFileList()
0167 | _createSrcFileList()
0176 | _createFileElement(obj)
0183 | _createTagList()
0192 | _createTagElement(obj)
0199 | _createLinkList()
0208 | _createLinkElement(obj)
0217 | _createNamespaceAttribute(name, value)
0225 | _createNamespaceElement(name)

;}
;{   ALD.PackageGenerator.ahk

;Functions:
0005 | __New(defFile)
0011 | Package(outFile)
0019 | _getFileList()

;}
;{   Align.ahk

;Functions:
0049 | Align(HCtrl, Type="", Dim="", HGlueCtrl="")

;}
;{   Anchor.ahk

;Functions:
0026 | Anchor(i, a = "", r = false)

;}
;{   Animated_Controls.ahk

;Functions:
0030 | AVI_CreateControl(_guiHwnd, _x, _y, _w, _h, _aviRef, _aviDLL="", _style="")
0118 | AVI_Play(_aviHwnd)
0133 | AVI_Stop(_aviHwnd)
0140 | AVI_DestroyControl(_aviHwnd)
0183 | AniGif_CreateControl(_guiHwnd, _x, _y, _w, _h, _style="")
0236 | AniGif_DestroyControl(_agHwnd)
0252 | AniGif_LoadGifFromFile(_agHwnd, _gifFile)
0261 | AniGif_UnloadGif(_agHwnd)
0270 | AniGif_SetHyperlink(_agHwnd, _url)
0278 | AniGif_Zoom(_agHwnd, _bZoomIn)
0287 | AniGif_SetBkColor(_agHwnd, _backColor)

;Labels:
7109 | AVI_CreateControl_CleanUp
9228 | AniGif_CreateControl_CleanUp

;}
;{   API_Draw.ahk

;Functions:
0063 | API_GdiGetBatchLimit()
0067 | API_GdiSetBatchLimit( dwLimit )
0071 | API_GdiFlush()
0075 | API_InvalidateRect( hWnd, lpRect, bErase)
0079 | API_RedrawWindow(hWnd, lprcUpdate, hrgnUpdate, flags)
0083 | API_GetBkColor( hdc )
0087 | API_GetBkMode( hdc )
0091 | API_DeleteObject(hObject)
0095 | API_LineTo(hdc, nXEnd, nYEnd)
0099 | API_MoveToEx(hdc, X, Y, lpPoint)
0104 | API_LoadImage( hinst, lpszName, uType, cxDesired, cyDesired, fuLoad )
0109 | API_PatBlt(hdc, nXLeft, nYLeft, nWidth, nHeight, dwRop)
0113 | API_DeleteDC(hDC)
0118 | Draw_Init()
0254 | API_GetDC( hwnd )
0257 | API_CreatePen( fnPenStyle, nWidth, crColor )
0260 | API_Ellipse(hdc, nLeftRect, nTopRect, nRightRect, nBottomRect)
0263 | API_FrameRect(hDC, lprc, hbr)
0266 | API_Rectangle(hdc, nLeftRect, nTopRect, nRightRect, nBottomRect)
0269 | API_RoundRect(hdc, nLeftRect, nTopRect, nRightRect, nBottomRect)
0272 | API_Pie( hdc, nLeftRect, nTopRect, nRightRect, nBottomRect, nXRadial1, nYRadial1, nXRadial2, nYRadial2 )
0276 | API_InvertRect( hdc, lprec )
0279 | API_BitBlt( hdcDest, nXDest, nYDest, nWidth, nHeight , hdcSrc, nXSrc, nYSrc, dwRop )
0284 | API_CreateCompatibleBitmap( hdc , nWidth, nHeight )
0287 | API_CreateCompatibleDC(hDC)
0290 | API_CreateSolidBrush(crColor)
0293 | API_DrawEdge(hdc, qrc, edge, grfFlags)
0297 | API_DrawFocusRect(hdc, lprc)
0300 | API_DrawFrameControl(hDC, lprc, uType, ustate)
0303 | API_DrawIconEx( hDC, xLeft, yTop, hIcon, cxWidth, cyWidth, istepIfAniCur, hbrFlickerFreeDraw, diFlags)
0315 | API_DestroyIcon(hIcon)
0319 | API_DrawText( hDC, lpString, nCount, lpRect, uFormat )
0322 | API_FillRect(hDC, lpRec, hBr)
0325 | API_GetTextExtentPoint32(hDC, lpString, cbString, lpSize)
0328 | API_GetSysColor( nIndex )
0332 | API_GetSysColorBrush( nIndex )
0335 | API_SetBkColor( hDC, crColor )
0338 | API_SetBKMode(hDC, iBkMode)
0341 | API_SetTextColor(hDC, crColor)
0344 | API_SelectObject( hDC, hgdiobj )
0347 | API_TextOut(hDC, nXStart, nYStart, lpString, cbString)
0356 | USR_LoadIcon(pPath)
0366 | USR_DrawText(hDC, str, X, Y, W, H, options=0)
0379 | USR_FillRect( hdc, X, Y, W, H, hBrush)
0406 | RECT_Set(var)
0416 | RECT_Get(var)
0429 | SIZE_Get(var)
0435 | SIZE_Set(var)

;}
;{   API_GetWindowInfo.ahk

;Functions:
0018 | API_GetWindowInfo(HWND)

;}
;{   AppBar.ahk

;Functions:
0043 | Appbar_New(ByRef Hwnd, o1="", o2="", o3="", o4="", o5="", o6="", o7="", o8="", o9="")
0114 | Appbar_Remove(Hwnd)
0150 | Appbar_SetTaskBar(State="")
0179 | AppBar_animate(Hwnd, Type="", Time=100)
0194 | AppBar_onMessage(Wparam, Lparam, Msg, Hwnd)
0203 | Appbar_setAutoHideBar(Hwnd, Edge, AnimType, Label)
0224 | Appbar_timer(Hwnd="", Edge="", Anim1="", Anim2="", Label="")
0266 | Appbar_setPos(Hwnd, Edge="", Width="", Height="", Pos="")

;Labels:
6219 | Appbar_setAutoHideBar

;}
;{   AppFactory.ahk

;Functions:
0010 | AddInputButton(guid, options, callback)
0015 | AddControl(guid, ctrltype, options, default, callback)
0051 | _BindingChanged(ControlGuid, bo)
0056 | _GuiControlChanged(ControlGuid, value)
0061 | _SaveSettings()
0072 | Get()
0076 | __New(parent, guid, ctrltype, options, default, callback)
0103 | SetControlState(value)
0115 | _SetGlabel(state)
0125 | ControlChanged()
0133 | SetValue(value)
0153 | __New(parent, guid, options, callback)
0180 | SetBinding(bo)
0194 | IOControlChoiceMade(val)
0221 | SetMenuCheckState(which)
0226 | BindModeEnded(bo)
0232 | OpenMenu()
0238 | BuildHumanReadable()
0259 | BuildKeyName(code)
0272 | IsModifier(code)
0277 | RenderModifier(code)
0284 | InitBindMode()
0305 | StartBindMode(callback)
0321 | _BindModeEnded(callback, bo)
0327 | SetHotkeyState(state)
0343 | AssocToIndexed(arr)
0352 | ProcessBindModeInput(e, i, deviceid, IOClass)
0396 | InitInputThread()
0405 | _StartInputThread()
0422 | InputEvent(ControlGUID, e)

;}
;{   ArchLogger.ahk

;Functions:
0007 | SetLogger(newLogger)
0011 | Log(msg)
0023 | Log(msg)
0027 | __new(callBackFunction)
0036 | Log(msg)

;}
;{   argp.ahk

;Functions:
0438 | argp_parse(ByRef _args, _maxcount=32, ByRef _n1="", ByRef _v1="", ByRef _n2="", ByRef _v2="", ByRef _n3="", ByRef _v3="", ByRef _n4="", ByRef _v4="", ByRef _n5="", ByRef _v5="", ByRef _n6="", ByRef _v6="", ByRef _n7="", ByRef _v7="", ByRef _n8="", ByRef _v8="", ByRef _n9="", ByRef _v9="", ByRef _n10="", ByRef _v10="", ByRef _n11="", ByRef _v11="", ByRef _n12="", ByRef _v12="", ByRef _n13="", ByRef _v13="", ByRef _n14="", ByRef _v14="", ByRef _n15="", ByRef _v15="", ByRef _n16="", ByRef _v16="", ByRef _n17="", ByRef _v17="", ByRef _n18="", ByRef _v18="", ByRef _n19="", ByRef _v19="", ByRef _n20="", ByRef _v20="", ByRef _n21="", ByRef _v21="", ByRef _n22="", ByRef _v22="", ByRef _n23="", ByRef _v23="", ByRef _n24="", ByRef _v24="", ByRef _n25="", ByRef _v25="", ByRef _n26="", ByRef _v26="", ByRef _n27="", ByRef _v27="", ByRef _n28="", ByRef _v28="", ByRef _n29="", ByRef _v29="", ByRef _n30="", ByRef _v30="", ByRef _n31="", ByRef _v31="", ByRef _n32="", ByRef _v32="")
0549 | argp_getopt(ByRef _args, _keylist="", _case=true, ByRef _1="", ByRef _2="", ByRef _3="", ByRef _4="", ByRef _5="", ByRef _6="", ByRef _7="", ByRef _8="", ByRef _9="", ByRef _10="", ByRef _11="", ByRef _12="", ByRef _13="", ByRef _14="", ByRef _15="", ByRef _16="", ByRef _17="", ByRef _18="", ByRef _19="", ByRef _20="", ByRef _21="", ByRef _22="", ByRef _23="", ByRef _24="", ByRef _25="", ByRef _26="", ByRef _27="", ByRef _28="", ByRef _29="", ByRef _30="", ByRef _31="", ByRef _32="")

;}
;{   Array Extensions.ahk

;Functions:
0187 | Pop()
0218 | Reverse()
0241 | Shift()

;}
;{   Array.ahk

;Functions:
0016 | Array_indexOf(arr, val, opts="", startpos=1)
0038 | Array_Copy(arr)
0050 | Array_Reverse(arr)
0056 | Array_Sort(arr, func="Array_CompareFunc")
0069 | Array_Unique(arr, func="Array_CompareFunc")
0079 | Array_CompareFunc(a, b, c)
0098 | Array_Pop(arr)
0107 | Array_Length(arr)

;}
;{   AssociatedProgram.ahk

;Functions:
0009 | AssociatedProgram(p_FileExt)
0060 | AssocQueryApp(ext)
0070 | DefaultProgramUserChoice(ext)

;}
;{   AsyncHttp.ahk

;Functions:
0033 | __new(callbacks = "")
0037 | _NewEnum()
0041 | __get(key)
0045 | Request(verb, url, body = "", options = "")
0072 | MaxIndex()
0076 | Remove( idx )

;}
;{   AtachGui_to_other_window.ahk

;Functions:
0007 | Set_Parent_by_id(Window_ID, Gui_Number)
0013 | Set_Parent_by_title(Window_Title_Text, Gui_Number)
0022 | Set_Parent_by_class(Window_Class, Gui_Number)
0030 | Set_Parent_to_Toolbar(ToolbarName, Gui_Number)
0042 | FindToolbar(ToolbarName)

;}
;{   Atl.ahk

;Functions:
0008 | Atl_Init()
0015 | Atl_AxGetHost(hWnd)
0022 | Atl_AxGetControl(hWnd)
0029 | Atl_AxAttachControl(punk, hWnd)
0036 | Atl_AxCreateControl(hWnd, Name)
0043 | Atl_AxCreateContainer(hWnd, l, t, w, h, Name = "", ExStyle = 0, Style = 0x54000000)

;}
;{   Attach.ahk

;Functions:
0098 | Attach(hCtrl="", aDef="")
0102 | Attach_(hCtrl, aDef, Msg, hParent)
0207 | Attach_redrawDelayed(hCtrl)

;Labels:
7201 | Attach_GetPos
1212 | Attach_redrawDelayed

;}
;{   AttachToolWindow.ahk

;Functions:
0001 | AttachToolWindow(hParent, GUINumber, AutoClose)
0021 | DeAttachToolWindow(GUINumber)
0040 | ToolWindow_ShellMessage(wParam, lParam, msg, hwnd)

;}
;{   Auth.ahk

;Functions:
0019 | Auth_RunAsAdmin()
0039 | Auth_RunAsUser(sCmdLine)

;}
;{   Autocomplete.ahk

;Functions:
0040 | AutoComplete(self,celt,rgelt,pceltFetched)
0133 | _EnumString_QueryInterface(self,riid,pObj)
0140 | _EnumString_AddRef(self)
0144 | _EnumString_Release(self)
0148 | _EnumString_Skip(self,celt)
0155 | _EnumString_Reset(self)
0160 | _EnumString_Clone(self,ppenum)

;}
;{   Autoupdate.ahk

;Functions:
0001 | AutoUpdate()

;Labels:
0015 | UPDATEDSCRIPT

;}
;{   AveragingFunctions.ahk

;Functions:
0003 | SimpleMovingAverage(NumberToAppend,Method = "Mean",MaxListLen = 10)
0015 | MeanAverage(NumList)
0022 | MedianAverage(NumList)
0038 | ModeAverage(NumList)
0048 | RangeAverage(NumList)

;}
;{   AVICAP.ahk

;Functions:
0001 | AVICAP_Startup()
0006 | AVICAP_SetCam(CamWinhWnd)
0033 | AVICAP_GrabImage(ImageFile, capHWnd)

;}
;{   BalloonTip.ahk

;Functions:
0056 | BalloonTip(sTitle = "", sText = "", hlicon=0, TitleCodePage = "", TextCodePage = "", Clickable=1, Timeout = 10000, MinTimeDisp = 200, RefreshRate = 100)

;Labels:
6144 | _MinTimeDisp
4147 | _UpdateBalloonTip
7175 | _DestroyBalloonTip

;}
;{   BARCODER.ahk

;Functions:
0453 | GENERATE_ALPHANUMERIC_TABLE()
0463 | GENERATE_VERSION_CAPACITY_CUBE()
0488 | CONVERT_TO_NUMERIC_ENCODING(MESSAGE_TO_ENCODE)
0519 | CONVERT_TO_ALPHANUMERIC_ENCODING(MESSAGE_TO_ENCODE)
0555 | CONVERT_TO_BYTE_ENCODING(MESSAGE_TO_ENCODE)
0573 | GET_GENERATOR_POLYNOMIAL(CHOOSEN_VERSION, CHOOSEN_ERROR_CORRECTION_LEVEL)
0700 | LIST_NUMBER_OF_GROUPS_AND_BLOCKS()
0713 | GENERATE_ERROR_CORRECTION_CODEWORDS(FINAL_MESSAGE_RAW_DATA_BITS, CHOOSEN_ERROR_CORRECTION_LEVEL, GROUP, BLOCK, CHOOSEN_VERSION)
0789 | GENERATE_MATRIX(FINAL_MESSAGE, CHOOSEN_VERSION, CHOOSEN_ERROR_CORRECTION_LEVEL)
1114 | APPLY_FUNCTIONS_AND_TURN_RESERVED_AREAS_LIGHT(MATRIX_TO_APPLY, CHOOSEN_VERSION)
1185 | CALCULATE_PENALTY(MATRIX_TO_USE)
1356 | CREATE_LOG_AND_ANTILOG_TABLES()
1415 | BARCODER_GENERATE_CODE_39(MESSAGE_TO_ENCODE)
1457 | CREATE_CODE_39_CHARACTER_TABLE()
1559 | Add_Check_Sum(num)
1598 | BARCODER_GENERATE_CODE_128B(Str)
1748 | Bin(x)
1755 | Dec(x)

;Labels:
1370 | GUICLOSE

;}
;{   Base.ahk

;Functions:
0003 | __new(p=0)
0013 | __get(aName)
0018 | __delete()
0021 | vt(n)
0024 | query(iid=0)
0037 | Read(pv,cb)
0042 | Write(pv,cb)
0047 | Seek(dlibMove,dwOrigin)
0052 | SetSize(libNewSize)
0056 | CopyTo(pstm,cb)
0061 | Commit(grfCommitFlags)
0065 | Revert()
0069 | LockRegion(libOffset,cb,dwLockType)
0073 | UnlockRegion(libOffset,cb,dwLockType)
0077 | Stat(pstatstg,grfStatFlag)
0081 | Clone()
0094 | Next(celt,ByRef rgelt)
0100 | Skip(celt)
0105 | Reset()
0111 | Clone()
0119 | Next(celt,ByRef rgelt)
0123 | Skip(celt)
0126 | Reset()
0129 | Clone()
0140 | VariantType(type)
0157 | GetVariantValue(v)
0174 | GetSafeArrayValue(p,type)
0196 | _error(a,ByRef b)
0203 | GUID(ByRef GUID, sGUID)
0207 | DEFINE_GUID(ByRef GUID, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11)
0213 | PROPVARIANT(Byref var)
0219 | _struct(type,p)
0227 | StructArray(__,n)
0231 | IsInteger(p)

;}
;{   baseConvert.ahk

;Functions:
0007 | baseConvert(value, from, to)

;}
;{   Bin.ahk

;Functions:
0022 | Bin_ToHex(ByRef sHex, nAdrBuf, nSzBuf)
0041 | Bin_FromHex(ByRef cBuf, ByRef sHex)
0106 | Bin_FromBits(sBin)

;Labels:
6220 | _BVBUTTONCLOSE

;}
;{   Bin2Dec.ahk

;Functions:
0001 | Bin2Dec(bin)

;}
;{   BinaryEncodingDecoding.ahk

;Functions:
0020 | FormatHexNumber(_value, _digitNb)
0046 | Bin2Hex(ByRef @hexString, ByRef @bin, _byteNb=0)
0080 | Hex2Bin(ByRef @bin, ByRef @hex, _byteNb=0)

;}
;{   BindModeThread.ahk

;Functions:
0016 | __New(CallbackPtr)
0041 | SetDetectionState(state, IOClassMappingsPtr)
0056 | IndexedToAssoc(arr)
0067 | __New(callback)
0071 | SetDetectionState(state, ReturnIOClass)
0082 | __New(callback)
0087 | SetDetectionState(state, ReturnIOClass)
0099 | CreateHotkeys()
0143 | InputEvent(e, i)
0155 | __New(callback)
0160 | SetDetectionState(state, ReturnIOClass)
0171 | CreateHotkeys()
0187 | GetJoystickCaps()
0195 | InputEvent(e, i, deviceid)
0206 | __New(callback)
0218 | SetDetectionState(state, ReturnIOClass)
0226 | HatWatcher()

;}
;{   BinGet.ahk

;Functions:
0019 | BinGet_Bitmap(adrBuf, szBuf)

;}
;{   bink.ahk

;Functions:
0001 | PlayBink(file, pddraw, pPrimary, h_win, pdSound = "", scale = True, dllpath="binkw32.dll")

;}
;{   BinReadWrite.ahk

;Functions:
0039 | OpenFileForRead(_filename)
0065 | OpenFileForWrite(_filename)
0089 | CloseFile(_handle)
0107 | GetFileSize(_handle)
0134 | MoveInFile(_handle, _moveMethod=-1, _offset=0)
0171 | WriteInFile(_handle, ByRef @data, _byteNb=0, _moveMethod=-1, _offset=0)
0215 | ReadFromFile(_handle, ByRef @data, _byteNb=0, _moveMethod=-1, _offset=0)

;}
;{   BinToHex.ahk

;Functions:
0001 | BinToHex(addr,len)

;}
;{   BRA.ahk

;Functions:
0006 | BRA_LibraryVersion()
0013 | BRA_VersionNumber(ByRef BRAFromMemIn)
0026 | BRA_CreationDate(ByRef BRAFromMemIn)
0041 | BRA_ListFiles(ByRef BRAFromMemIn, FolderName="", Recurse=0, Alternate=0)
0089 | BRA_ListFolders(ByRef BRAFromMemIn, FolderName="", Recurse=0)
0141 | BRA_ListSizes(ByRef BRAFromMemIn, Files="", FolderName="", Recurse=0, Alternate=0)
0229 | BRA_AddFiles(ByRef BRAFromMemIn, Files="", Folder="")
0328 | BRA_DeleteFiles(ByRef BRAFromMemIn, Files="", FolderName="", Alternate=0)
0411 | BRA_DeleteFolders(ByRef BRAFromMemIn, Folders)
0489 | BRA_ExtractFiles(ByRef BRAFromMemin, Files="", FolderName="", OutputFolder="", Recurse=0, Alternate=0, Overwrite=0)
0592 | BRA_ExtractToMemory(ByRef BRAFromMemin, File, ByRef OutputVar, Alternate=0)
0598 | BRA_SaveToDisk(ByRef BRAFromMemIn, Output, Overwrite=0)

;}
;{   C.ahk

;Functions:
0285 | defineType(command)
0289 | typedef__(command)
0295 | typedef(command)
0302 | typedef___(command)
0309 | typedef____(command)
0316 | struct(command)
0326 | struct___(command)
0336 | struct____(command)
0346 | struct__(command)
0356 | union(command)
0366 | union___(command)
0376 | union____(command)
0386 | union__(command)
0397 | define(command)
0418 | define___(command)
0439 | define____(command)
0463 | define__(command)
0567 | sizeof(typeNameOrObject)
0597 | __New(typeName, operation = 0, byref value = 0)
0604 | init(type, operation, byref value)
0633 | IsOwner()
0638 | _retrive(type, address)
0651 | Get_DebugCode()
0660 | Get_ReleaseCode()
0804 | _assign(_type_, address, value)
0846 | Set_DebugCode(value)
0851 | Set_ReleaseCode(value)
1146 | _NewEnum()
1162 | next(ByRef key, ByRef val)
1274 | _tmp(type, address)
1284 | _del()
1290 | __tmp(type, address)
1311 | __New(typeName, arraySize, operation = 0, byref value = 0)
1324 | __Delete()
1332 | __New(typeName, indirectionCount, operation = 0, byref value = 0)
1345 | __Delete()
1353 | __New(typeName, indirectionCount, arraySize, operation = 0, byref value = 0)
1367 | __Delete()
1373 | use(type)
1390 | preprocess_macroReplace(tokens)
1412 | preprocess_macroReplace___(tokens)
1440 | preprocess_macroReplace____(tokens)
1468 | newName(type)
1482 | parseType(tokens, byref position)
1531 | parseType___(tokens, byref position)
1580 | parseType____(tokens, byref position)
1629 | parseType___DebugCode(lexer)
1737 | parseType___ReleaseCode(lexer)
1770 | parseDecoratedName(tokens, byref position, newType)
1812 | parseDecoratedName___(tokens, byref position, newType)
1861 | parseDecoratedName____(tokens, byref position, newType)
1910 | parseDecoratedName__(lexer, newType)
1955 | struct_parser(name, tokens, byref position)
2003 | struct_parser___(name, tokens, byref position)
2051 | struct_parser____(name, tokens, byref position)
2099 | struct_parser__(name, lexer)
2147 | union_parser(name, tokens, byref position)
2198 | union_parser___(name, tokens, byref position)
2249 | union_parser____(name, tokens, byref position)
2300 | union_parser__(lexer)
2350 | typedef_parser(tokens, byref position)
2384 | typedef_parser___(tokens, byref position)
2418 | typedef_parser____(tokens, byref position)
2452 | typedef_parser__(lexer)
2488 | __New(type, offset="")
2495 | description()
2505 | isASimplerTypeOf(simplerTypeToCheckFor)
2514 | hasSameRootTypeAs(otherType)
2519 | __Delete()
2526 | if(this[" isComplex"])
2542 | getType(name)
2550 | deleteType(typeObj)
2565 | name(name)
2581 | tokenizer_orig(command, operators, whitespace)
2602 | tokenizer(command, operators, whitespace)
2674 | t0f(calloutNumber, foundPos, haystack)
2680 | t1f(calloutNumber, foundPos)
2687 | t2f(calloutNumber, foundPos, haystack)
2693 | t3f(calloutNumber, foundPos, haystack)
2700 | t4f(calloutNumber, foundPos, haystack)
2706 | t5f(calloutNumber, foundPos, haystack)
2712 | t6f(calloutNumber, foundPos, haystack)
2718 | t7f(calloutNumber, foundPos, haystack)
2724 | t8f(calloutNumber, foundPos, haystack)
2730 | t9f(calloutNumber, foundPos, haystack)
2736 | tAf(calloutNumber, foundPos, haystack)
2741 | tnf(calloutNumber, foundPos, haystack)
2759 | tokenType(token)
2778 | tokenTypeInfo(token)
2820 | tokenizer_callback(lineReader, tokens, gettingLineContinuation)
2904 | tokenizer_piecemeal(lineReader, tokens, gettingLineContinuation)
3005 | someTokensAreNotIgnored(ByRef tokens)
3028 | preparser(byref tokens)
3146 | debug(x)
3151 | processBaseTypes(typesAndSizes)
3164 | isTypeDefined(name)
3169 | test1()
3232 | test2()
3252 | test2___()
3272 | test2____()
3292 | test2__()
3313 | test_lexerFromString()
3345 | test_lexerFromFile()
3356 | test_transientTypes()
3376 | test_typeComparisons()

;Labels:
3052 | CPP_DEFINE
3071 | CPP_UNDEF
3084 | CPP_INCLUDE
3088 | CPP_IF
3092 | CPP_ELSE
3096 | CPP_ENDIF

;}
;{   CalcChecksum.ahk

;Functions:
0001 | HashFile(filePath,hashType=2)

;Labels:
0178 | HashTypeFreeHandles

;}
;{   CApplication.ahk

;Functions:
0044 | __New()
0053 | __Delete()
0084 | Get(name, read = false)
0089 | if(val = this.ini.defaultValue)
0113 | Set(name, value, write = false)
0115 | if(write)
0134 | StoreSetting(name, value)
0147 | SaveSettings()
0171 | Initialize(ConfigData = "")
0256 | ReadSettings()
0270 | Run(StartupObject = "")
0289 | if(StartupObject)
0306 | Exit(ExitCode = 0)
0312 | GetString(strId)
0320 | GetLanguageList()
0325 | Localize(langId)
0342 | AddHotkeyCmd(hkCmd, mi = "")
0357 | if(mi)
0372 | AddHotkey(newHk, boundCtrl = "")
0378 | if(boundCtrl)
0386 | ReplaceHotkey(oldHkString, newHkString)
0415 | DisableHotkeys()
0429 | EnableHotkeys()
0443 | RemoveHotkey(strHk)
0451 | ShowForm(formName, disallowedForms = "")
0463 | if(disallowedForms)
0485 | HideForm(formName)
0492 | DisallowForms(forms)
0500 | IsDisallowed(formName)
0509 | AllowForms(forms)
0525 | AdjustDisallowedForms()
0530 | if(form.DisallowedForms)
0541 | RaiseEvent(e)
0555 | Subscribe(handler, e)
0571 | Unsubscribe(handler, e)

;}
;{   CB.ahk

;Functions:
0042 | CB_Get(Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
0047 | CB_Set(Pos=0, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
0052 | CB_Add(String="", Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
0059 | CB_Insert(String="", Pos=-1, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
0068 | CB_Modify(String="", Pos=-1, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
0078 | CB_Delete(Pos=-1, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
0087 | CB_Reset(Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
0092 | CB_Find(String, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
0098 | CB_FindExact(String, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
0104 | CB_Select(String, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
0109 | CB_Show(Flag=True, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
0114 | CB_GetCount(Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
0119 | CB_GetText(Pos=-1, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")

;}
;{   CColor.ahk

;Functions:
0026 | CColor(Hwnd, Background="", Foreground="")
0030 | CColor_(Wp, Lp, Msg, Hwnd)

;}
;{   cControls.ahk

;Functions:
0003 | __New(Name, Options, Text, GUINum)
0011 | Show()
0018 | Hide()
0025 | Focus()
0032 | __Get(Name)
0070 | if(hwnd=this.hwnd)
0099 | __Set(Name, Value)
0138 | __New(Name, Options, Text, GUINum)
0146 | __New(Name, Options, Text, GUINum)
0151 | HandleEvent()
0166 | __New(Name, Options, Text, GUINum)
0171 | HandleEvent()
0186 | __New(Name, Options, Text, GUINum, Type)
0191 | __Get(Name)
0206 | __Set(Name, Value)
0225 | HandleEvent()
0240 | __New(Name, Options, Text, GUINum, Type)
0245 | __Get(Name)
0272 | __Set(Name, Value)
0280 | if(Name = "SelectedItem")
0323 | HandleEvent()
0338 | __New(Name, ByRef Options, Text, GUINum)
0358 | __Delete()
0362 | ModifyCol(ColumnNumber="", Options="", ColumnTitle="")
0371 | InsertCol(ColumnNumber, Options="", ColumnTitle="")
0380 | DeleteCol(ColumnNumber)
0521 | __New(Control)
0525 | _NewEnum()
0530 | MaxIndex()
0548 | InsertRow(RowNumber, Options, Fields)
0557 | ModifyRow(RowNumber, Options, Fields)
0566 | DeleteRow(RowNumber)
0575 | __Get(Name)
0592 | __Set(Name, Value)
0623 | __New(Control, RowNumber)
0629 | _NewEnum()
0634 | MaxIndex()
0643 | __Get(Name)
0684 | __Set(Name, Value)
0720 | HandleEvent()
0759 | if(A_GuiEvent == "I")
0788 | __New(Name, Options, Text, GUINum)
0832 | SetImageFromHBitmap(hBitmap)
0837 | HandleEvent()
0853 | __New(Name, Options, Text, GUINum)

;}
;{   CDataBase.ahk

;Functions:
0009 | __New(fileName)
0015 | Create()
0048 | AddHotstring(hs, write = false)
0168 | RemoveHotstring(abbr)
0184 | findAll(s)
0190 | FindAbbreviation(s)
0266 | GetPhraseHotstring(phrase)
0283 | HasAbbreviation(abbr)
0303 | Reset()

;}
;{   CDialogs.ahk

;Functions:
0059 | __New(Mode="")
0073 | __Delete()
0083 | Show()
0086 | if(Multi)

;}
;{   CDirectory.ahk

;Functions:
0015 | Exists(DirName)
0035 | Create(DirName)

;}
;{   cdomessage.ahk

;Functions:
0019 | cdomessage(sFrom, sTo, sSubject, sBody, sAttach, sServer, sUsername, sPassword, bTLS = True, nPort = 25, nSend = 2, nAuth = 1)

;}
;{   CEnumerator.ahk

;Functions:
0013 | __New(Object)
0017 | Next(byref key, byref value)

;}
;{   CFile.ahk

;Functions:
0021 | Create(fileName, encoding="")

;}
;{   cFTP.ahk

;Functions:
0061 | FTPv2( AsyncMode=0 , Proxy = "" , ProxyBypass = "")
0086 | __New( AsyncMode=0 , Proxy = "" , ProxyBypass = "")
0134 | Open(Server, Username=0, Password=0)
0172 | GetCurrentDirectory()
0199 | SetCurrentDirectory(DirName)
0223 | CreateDirectory(DirName)
0247 | RemoveDirectory(DirName)
0257 | OpenFile(FileName,Write = 0)
0314 | InternetWriteFile(LocalFile, NewRemoteFile="", FnProgress = "")
0394 | InternetReadFile(RemoteFile, NewLocalFile = "", FnProgress = "")
0441 | ShowProgress()
0481 | PutFile(LocalFile, NewRemoteFile="", Flags=0)
0522 | GetFile(RemoteFile, NewFile="", Flags=0)
0563 | GetFileSize(FileName, Flags=0)
0607 | DeleteFile(FileName)
0632 | RenameFile(Existing, New)
0654 | CloseHandle()
0663 | __Delete()
0686 | FindFirstFile(SearchFile)
0718 | FindNextFile()
0747 | GetFileInfo(ByRef @FindData)
0783 | FileTimeToStr(FileTime)
0797 | GetModuleErrorText(errNr)
0820 | FTP_Status(wParam,lParam)
0832 | FTP_Callback(hInternet, dwContext, dwInternetStatus, lpvStatusInformation, dwStatusInformationLength)
0912 | FTP_TestFunction()

;}
;{   CGui.ahk

;Functions:
0039 | __New(app, n = "", options = "", title = "", isLocalizable = true)
0060 | Create()
0065 | CreateControls()
0075 | DetectOwner()
0083 | GetCmdPrefix()
0091 | AddControl(Type, options = "", text ="", tabControl = "", tabPage = 0, isLocalizable = true)
0107 | AddButton(options = "", text ="OK", tabControl = "", tabPage = 0, isLocalizable = true)
0114 | AddOkButton(options = "", text ="OK", tabControl = "", tabPage = 0, isLocalizable = true)
0125 | AddCancelButton(options = "", text ="", tabControl = "", tabPage = 0, isLocalizable = true)
0137 | Show(disableOwner = false, options = "", title = "")
0185 | Submit(NoHide = true)
0196 | Cancel()
0208 | Destroy()
0221 | Font(options = "", fontName = "")
0228 | Color(WindowColor = "", ControlColor = "")
0235 | Margin(x = "", y = "")
0242 | AddOption(option)
0253 | RemoveOption(option)
0273 | Enable()
0279 | Disable()
0285 | MenuBar(menu = "")
0299 | Hide()
0311 | Minimize()
0317 | Maximize()
0323 | Restore()
0329 | Flash(Off = false)
0343 | Default()
0349 | Localize()

;}
;{   CGuiCtrl.ahk

;Functions:
0054 | __New(gui, Type, Options = "", Text = "", tabControl = "", tabPage = 0, isLocalizable = true, setDefaultGlabel = true)
0092 | GetName()
0116 | SetName(newName)
0139 | GetEventGroup()
0154 | GetGLabel()
0166 | GetCmdPrefix()
0174 | SetDefaultGLabel()
0209 | Create()
0232 | Localize()
0265 | GetValue()
0286 | SetValue(v)
0297 | SetText(text)
0302 | LVSetHeaders(text)
0312 | _SetText(text, localize = true, applyOptions = false, apply = true)
0372 | Move(options)
0377 | Redraw()
0382 | MoveDraw(options)
0387 | Focus()
0392 | Enable()
0397 | Disable()
0402 | Hide()
0407 | Show()
0422 | Delete()
0440 | SelectItemIndex(n)
0445 | SelectItem(text)
0450 | Font(fontOptions = "", fontFace = "")
0456 | AddOption(option)
0465 | RemoveOption(option)

;}
;{   chatGUI.ahk

;Functions:
0020 | CreateGui()
0321 | setup_Scintilla(sci, localNick="")
0504 | nickCheck(n)
0513 | findMatch(searchFor)
0537 | MakeShort(Long)
0541 | toLower(v)

;Labels:
4197 | HandleEnter
7106 | MessageInput
6115 | ConnectToServer
5127 | DisableIP
7132 | ChangeNick
2138 | CodeWin
8142 | SendMessage
2259 | SendCode
9281 | ListViewNotifications
1299 | Edit
9306 | View
6313 | Tools

;}
;{   chooseColor.ahk

;Functions:
0096 | ColorWindowProc(hwnd, msg, wParam, lParam)
0127 | BGR2RGB(Color)

;}
;{   CHotKey.ahk

;Functions:
0011 | __New(hk, label, up=true)
0022 | _GetInternalName()
0030 | Create()
0040 | Enable()
0053 | Disable()
0077 | ToString()
0092 | _ToString()

;}
;{   CHotstringOptions.ahk

;Functions:
0021 | ToOptions(x)
0041 | ToHotstring(x)

;}
;{   CIniFile.ahk

;Functions:
0008 | CIniFile_New(fileName)
0040 | __New(FileName)
0064 | Exists()
0097 | CreateIfNotExists()
0135 | GetSectionCount()
0170 | GetSectionNamesArray()
0225 | HasSection(section)
0325 | ReadSection(Section)
0351 | _ReadSection(section)
0400 | WriteSection(Section, KeyValuePairs)
0445 | Read(Section, Key, Default="ERROR")
0506 | Write(Section, Key, Value)
0553 | ReadAll()
0595 | WriteAll(Settings)
0619 | VerifySettings(Settings)
0635 | VerifyKeyValuePairs(KeyValuePairs)
0683 | Delete(Section, Key="")

;}
;{   ClassCheck.ahk

;Functions:
0124 | __Get(key)
0132 | __Set(key, val)
0141 | __Get(key)
0152 | __Set(key, ByRef val)

;}
;{   classMemory.ahk

;Functions:
0278 | __delete()
0288 | version()
0345 | isHandleValid()
0367 | openProcess(PID, dwDesiredAccess)
0394 | closeHandle(hProcess)
0406 | numberOfBytesRead()
0410 | numberOfBytesWritten()
0834 | suspend()
0839 | resume()
0941 | GetModuleInformation(hModule, byRef aModuleInfo)
0985 | hexStringToPattern(hexString)
1212 | VirtualQueryEx(address, byRef aInfo)
1256 | patternScan(startAddress, sizeOfRegionBytes, byRef patternMask, byRef needleBuffer)
1307 | MCode(mcode)
1336 | __new()
1342 | __Delete()
1348 | __get(key)
1369 | __set(key, value)
1393 | Ptr()
1397 | sizeOf()

;}
;{   ClassPermissions.ahk

;Functions:
0097 | __Get(key)
0104 | __Set(key, val)
0113 | __Get(key)
0122 | __Set(key, ByRef val)
0136 | __Get(key)

;}
;{   Class_ColorPicker.ahk

;Functions:
0023 | __New(RGBv = "", Av = "", PickerTitle = "Color Picker", bgImage = "")
0214 | rgbaToARGBHex(r, g, b, a)
0232 | hexToRgb(s, d = "")
0240 | ValidateRGBColor(Color, Default)
0246 | ValidateOpacity(Opacity, Default)

;Labels:
6103 | ColorPickerEditSub
3122 | ColorPickerUpDownSub
2141 | ColorPickerSliderSub
1160 | ColorPickerSetValues
0179 | ColorPickerRemoveToolTip
9184 | ColorPickerButtonSave
4199 | ColorPickerButtonCancel
9204 | ColorPickerButtonToggleBg
4209 | GDIColorPickerPreviewGuiEscape

;}
;{   Class_FTP.ahk

;Functions:
0012 | InternetOpen(Agent)
0028 | InternetConnect(HINTERNET, ServerName, Username, Password)
0049 | FtpCreateDirectory(HCONNECT, Directory)
0060 | FtpDeleteFile(HCONNECT, FileName)
0071 | FtpGetCurrentDirectory(HCONNECT)
0084 | FtpGetFile(HCONNECT, RemoteFile, LocaleFile)
0100 | FtpGetFileSize(HFTPSESSION)
0111 | FtpOpenFile(HCONNECT, FileName)
0125 | FtpPutFile(HCONNECT, LocaleFile, RemoteFile)
0139 | FtpRemoveDirectory(HCONNECT, Directory)
0150 | FtpRenameFile(HCONNECT, ExistingFile, NewFile)
0162 | FtpSetCurrentDirectory(HCONNECT, Directory)
0173 | InternetCloseHandle(HINTERNET)

;}
;{   Class_GdipTooltip.ahk

;Functions:
0074 | ShowGdiTooltip(fontSize, String, XCoord, YCoord, relativeCoords = true, parentWindowHwnd = "", fixedCoords = false)
0147 | SetInnerBorder(state = true, luminosityFactor = 0, autoColor = true, argbColorHex = "")
0167 | SetRenderingFix(state)
0171 | SetBorderSize(w, h)
0175 | SetPadding(w, h)
0179 | HideGdiTooltip(debug = false)
0186 | GetVisibility()
0190 | CalculateToolTipDimensions(String, fontSize, ByRef ttWidth, ByRef ttLineHeight, ByRef ttHeight)
0214 | MeasureText(Str, FontOpts = "", FontName = "")
0235 | UpdateColors(wColor, wOpacity, bColor, bOpacity, tColor, tOpacity, opacityBase = 16, colorBase = 16)
0254 | ValidateRGBColor(Color, Default, hasOpacity = false)
0267 | ValidateOpacity(Opacity, Default, inBase = 16, outBase = 16)
0319 | ValidateInitColors(params)
0383 | FHex( int, pad=0 )
0396 | ConvertColorToARGBhex(param)
0453 | ChangeLuminosity(c, l = 0)
0468 | Min(x,x1="",x2="",x3="",x4="",x5="",x6="",x7="",x8="",x9="")
0476 | Max(x,x1="",x2="",x3="",x4="",x5="",x6="",x7="",x8="",x9="")
0484 | GetActiveMonitorInfo(ByRef X, ByRef Y, ByRef Width, ByRef Height)

;}
;{   Class_IPHelper.ahk

;Functions:
0025 | ResolveHostname(hostname)
0032 | ReverseLookup(ip_addr)
0043 | WSAStartup()
0055 | WSACleanup()
0065 | getaddrinfo(hostname)
0081 | freeaddrinfo(addrinfo)
0089 | getnameinfo(in_addr)
0108 | inet_addr(ip_addr)
0119 | inet_ntoa(in_addr)
0129 | IcmpCreateFile()
0139 | IcmpSendEcho(hIcmpFile, in_addr, timeout)
0158 | IcmpCloseHandle(hIcmpFile)

;}
;{   Class_LV_Colors.ahk

;Functions:
0082 | __Delete()
0094 | On_WM_NOTIFY(W, L, M, H)
0108 | On_NM_CUSTOMDRAW(H, L)
0147 | MapIndexToID(Row)

;}
;{   Class_LV_InCellEdit (2).ahk

;Functions:
0095 | GetOsVersion()
0101 | NextSubItem(H, K)
0170 | RegisterHotkeys(H, Register = True)
0189 | On_LVN_BEGINLABELEDIT(H, L)
0237 | On_LVN_ENDLABELEDIT(H, L)
0270 | On_NM_DBLCLICK(H, L)
0334 | SubClassProc(H, M, W, L, I, D)
0393 | OnMessage(DoIt = True)
0412 | Attach(HWND, HiddenCol1 = False)
0422 | Detach(HWND)
0431 | LV_InCellEdit_LVSUBCLASSPROC(H, M, W, L, I, D)
0438 | LV_InCellEdit_WM_NOTIFY(W, L)

;}
;{   Class_LV_InCellEdit.ahk

;Functions:
0098 | GetOsVersion()
0104 | NextSubItem(H, K)
0191 | RegisterHotkeys(H, Register = True)
0210 | On_LVN_BEGINLABELEDIT(H, L)
0264 | On_LVN_ENDLABELEDIT(H, L)
0299 | On_NM_DBLCLICK(H, L)
0369 | SubClassProc(H, M, W, L, I, D)
0462 | Detach(HWND)
0536 | LV_InCellEdit_LVSUBCLASSPROC(H, M, W, L, I, D)
0543 | LV_InCellEdit_WM_NOTIFY(W, L)

;}
;{   Class_Toolbar.ahk

;Functions:
0140 | AutoSize()
0150 | Customize()
0301 | GetButtonState(Button, StateQuerry)
0314 | GetCount()
0329 | GetHiddenButtons()
0377 | LabelToIndex(Label)
0420 | ModifyButtonInfo(Button, Property, Value)
0458 | MoveButton(Button, Target)
0580 | Reset()
0617 | SetButtonSize(W, H)
0655 | SetExStyle(Style)
0676 | SetHotItem(Button)
0709 | SetIndent(Value)
0721 | SetListGap(Value)
0746 | SetPadding(X, Y)
0781 | ToggleStyle(Style)
0817 | Delete(Slot)
0894 | Load(Slot)
0942 | Save(Slot, Buttons)
1102 | __New(hToolbar)
1109 | __Delete()
1195 | DefineBtnInfoStruct(ByRef BtnVar, Member, ByRef Value)
1242 | StringToNumber(String)
1252 | MakeLong(LoWord, HiWord)
1260 | MakeShort(Long, ByRef LoWord, ByRef HiWord)

;}
;{   Class_TransparentListBox.ahk

;Functions:
0085 | __Delete()
0107 | SubClassCallback(uMsg, wParam, lParam, IdSubclass, RefData)
0115 | SubClassProc(hWnd, uMsg, wParam, lParam)
0375 | SetRedraw(Mode)

;}
;{   ClearArray.ahk

;Functions:
0036 | ClearArray(p_ArrayName,p_Start=0,p_End=0)
0057 | varExist(ByRef v)

;}
;{   Clip2Object.ahk

;Functions:
0002 | __Set(key,ByRef raw)
0008 | Restore(key,ByRef raw)

;}
;{   Clipboard Manager.ahk

;Functions:
0003 | handleClip(action)

;}
;{   CLocalizer.ahk

;Functions:
0018 | __New(dir)
0033 | GetLanguageFileName(langId)
0050 | ReadLanguageList()
0080 | CreateLanguageFile(langId, langName, strings)
0112 | LoadStrings(langId, defaultStrings = "")
0164 | GetLangIdByName(langName)
0181 | GetLanguageList()

;}
;{   CLR.ahk

;Functions:
0014 | CLR_Start()
0024 | CLR_StartDomain(ByRef pAppDomain, BaseDirectory="")
0043 | CLR_StopDomain(pAppDomain)
0049 | CLR_Stop()
0061 | CLR_CreateObject(pAssembly, sType, Type1="", Arg1="", Type2="", Arg2="", Type3="", Arg3="", Type4="", Arg4="", Type5="", Arg5="", Type6="", Arg6="", Type7="", Arg7="", Type8="", Arg8="", Type9="", Arg9="")
0089 | CLR_LoadLibrary(sLibrary, pAppDomain=0)
0147 | CLR_CompileC#(Code, References, pAppDomain=0, FileName="", CompilerOptions="")
0153 | CLR_CompileVB(Code, References, pAppDomain=0, FileName="", CompilerOptions="")
0163 | CLR_GetDefaultDomain()
0169 | CLR_CompileAssembly(Code, References, ProviderAssembly, ProviderType, pAppDomain=0, FileName="", CompilerOptions="")

;}
;{   CMDret.ahk

;Functions:
0026 | CMDret_RunReturn(CMDin, WorkingDir=0)

;}
;{   CMDret_stream.ahk

;Functions:
0033 | CMDret_Stream(CMDin, CMDname="", WorkingDir=0)

;Labels:
3121 | cmdretSTR

;}
;{   CMenu.ahk

;Functions:
0026 | CMenu(HCtrl, MenuName="", Sub="")
0036 | CMenu_wndProc(Hwnd, UMsg, WParam, LParam)

;}
;{   CMenuBar.ahk

;Functions:
0045 | __New(name = "tray", parent = "", gui="", standard = false, default = "")
0074 | Create()
0116 | AddLastItem(name = "", label = "")
0129 | AddLastSubmenu(submenu)
0139 | AddFirstItem(name = "", label = "")
0151 | RemoveLastItem()
0161 | RemoveItems()
0171 | Localize()

;}
;{   CMenuItem.ahk

;Functions:
0046 | __New(menu, name="", label="")
0056 | GetName()
0070 | Create()
0086 | GetFullText()
0104 | Delete()
0125 | Rename(newText)
0146 | Check()
0160 | Uncheck()
0174 | ToggleCheck(update = false)
0188 | Enable()
0201 | Disable()
0214 | ToggleEnable()
0227 | Default()
0240 | Icon(FileName, IconNumber = 1, IconWidth = 16)
0252 | NoIcon()
0257 | Localize()
0265 | ReplaceHotkey(newHk)

;}
;{   CoHelper.ahk

;Functions:
0003 | VTable(ppv, idx)
0007 | QueryInterface(ppv, ByRef IID)
0014 | AddRef(ppv)
0018 | Release(ppv)
0022 | QueryService(ppv, ByRef SID, ByRef IID)
0034 | GetIDispatch(ppv, LCID = 0)
0048 | Invoke(pdisp, sName, arg1="vT_NoNe",arg2="vT_NoNe",arg3="vT_NoNe",arg4="vT_NoNe",arg5="vT_NoNe",arg6="vT_NoNe",arg7="vT_NoNe",arg8="vT_NoNe",arg9="vT_NoNe")
0075 | Invoke_(pdisp, sName, type1="",arg1="",type2="",arg2="",type3="",arg3="",type4="",arg4="",type5="",arg5="",type6="",arg6="",type7="",arg7="",type8="",arg8="",type9="",arg9="")
0099 | CreateObject(ByRef CLSID, ByRef IID, CLSCTX = 5)
0108 | ActiveXObject(ProgID, CLSCTX = 5)
0115 | GetObject(Moniker)
0122 | GetActiveObject(ProgID)
0131 | CLSID4ProgID(ByRef CLSID, sProgID, nOffset = 0)
0138 | ProgID4CLSID(ByRef CLSID, nOffset = 0)
0146 | GUID4String(ByRef CLSID, sString, nOffset = 0)
0153 | String4GUID(ByRef GUID, nOffset = 0)
0161 | CoCreateGuid()
0167 | CoTaskMemAlloc(cb)
0171 | CoTaskMemFree(pv)
0175 | CoInitialize()
0179 | CoUninitialize()
0183 | OleInitialize()
0187 | OleUninitialize()
0191 | SysAllocString(sString)
0195 | SysFreeString(pString)
0199 | Ansi4Unicode(pString, nSize = 0)
0207 | Unicode4Ansi(ByRef wString, sString, nSize = 0)
0215 | Ansi2Unicode(ByRef sString, ByRef wString, nSize = 0)
0223 | Unicode2Ansi(ByRef wString, ByRef sString, nSize = 0)
0232 | DecodeInteger(ref, nSize = 4)
0237 | EncodeInteger(ref, val = 0, nSize = 4)

;}
;{   Collection.ahk

;Functions:
0011 | Add(obj)
0018 | AddRange(objs)
0026 | Clear()
0030 | RemoveItem(item)
0039 | Count()
0046 | IsEmpty()
0050 | First()
0054 | Last()
0062 | Sort(comparer="")
0074 | ToString()
0099 | __New(enum = 0)

;}
;{   ColURL.ahk

;Functions:
0016 | ColURL_OpenURL(sURL)
0051 | ColURL_ComUrl2Mhtml(sURL, sDestPath="", nFlags=0)
0063 | ColURL_ComUnHthml(sHtml)

;}
;{   com (2).ahk

;Functions:
0007 | COM_Init()
0012 | COM_Term()
0017 | COM_VTable(ppv, idx)
0022 | COM_QueryInterface(ppv, IID = "")
0028 | COM_AddRef(ppv)
0033 | COM_Release(ppv)
0038 | COM_QueryService(ppv, SID, IID = "")
0046 | COM_FindConnectionPoint(pdp, DIID)
0054 | COM_GetConnectionInterface(pcp)
0061 | COM_Advise(pcp, psink)
0067 | COM_Unadvise(pcp, nCookie)
0072 | COM_Enumerate(penum, ByRef Result, ByRef vt = "")
0080 | COM_Invoke(pdsp,name="",prm0="vT_NoNe",prm1="vT_NoNe",prm2="vT_NoNe",prm3="vT_NoNe",prm4="vT_NoNe",prm5="vT_NoNe",prm6="vT_NoNe",prm7="vT_NoNe",prm8="vT_NoNe",prm9="vT_NoNe")
0135 | COM_Invoke_(pdsp,name,typ0="",prm0="",typ1="",prm1="",typ2="",prm2="",typ3="",prm3="",typ4="",prm4="",typ5="",prm5="",typ6="",prm6="",typ7="",prm7="",typ8="",prm8="",typ9="",prm9="")
0187 | COM_DispInterface(this, prm1="", prm2="", prm3="", prm4="", prm5="", prm6="", prm7="", prm8="")
0207 | COM_DispGetParam(pDispParams, Position = 0, vt = 8)
0214 | COM_DispSetParam(val, pDispParams, Position = 0, vt = 8)
0219 | COM_Error(hr = "", lr = "", pei = "", name = "")
0235 | COM_CreateIDispatch()
0247 | COM_GetDefaultInterface(pdisp)
0263 | COM_GetDefaultEvents(pdisp)
0300 | COM_GetGuidOfName(pdisp, Name)
0314 | COM_GetTypeInfoOfGuid(pdisp, GUID)
0325 | COM_ConnectObject(psource, prefix = "", DIID = "")
0342 | COM_DisconnectObject(psink)
0347 | COM_CreateObject(CLSID, IID = "", CLSCTX = 5)
0353 | COM_ActiveXObject(ProgID)
0359 | COM_GetObject(Moniker)
0365 | COM_GetActiveObject(ProgID)
0373 | COM_CLSID4ProgID(ByRef CLSID, ProgID)
0380 | COM_GUID4String(ByRef CLSID, String)
0387 | COM_ProgID4CLSID(pCLSID)
0393 | COM_String4GUID(pGUID)
0400 | COM_IsEqualGUID(pGUID1, pGUID2)
0405 | COM_CoCreateGuid()
0412 | COM_CoTaskMemAlloc(cb)
0417 | COM_CoTaskMemFree(pv)
0422 | COM_CoInitialize()
0427 | COM_CoUninitialize()
0432 | COM_SysAllocString(astr)
0437 | COM_SysFreeString(bstr)
0442 | COM_SysStringLen(bstr)
0447 | COM_SafeArrayDestroy(psar)
0452 | COM_VariantClear(pvar)
0457 | COM_VariantChangeType(pvarDst, pvarSrc, vt = 8)
0462 | COM_SysString(ByRef wString, sString)
0468 | COM_AccInit()
0475 | COM_AccTerm()
0482 | COM_AccessibleChildren(pacc, cChildren, ByRef varChildren)
0489 | COM_AccessibleObjectFromEvent(hWnd, idObject, idChild, ByRef _idChild_="")
0496 | COM_AccessibleObjectFromPoint(x, y, ByRef _idChild_="")
0503 | COM_AccessibleObjectFromWindow(hWnd, idObject=-4, IID = "")
0509 | COM_WindowFromAccessibleObject(pacc)
0515 | COM_GetRoleText(nRole)
0523 | COM_GetStateText(nState)
0531 | COM_AtlAxWinInit(Version = "")
0539 | COM_AtlAxWinTerm(Version = "")
0546 | COM_AtlAxAttachControl(pdsp, hWnd, Version = "")
0551 | COM_AtlAxCreateControl(hWnd, Name, Version = "")
0557 | COM_AtlAxGetControl(hWnd, Version = "")
0564 | COM_AtlAxGetHost(hWnd, Version = "")
0571 | COM_AtlAxCreateContainer(hWnd, l, t, w, h, Name = "", Version = "")
0576 | COM_AtlAxGetContainer(pdsp, bCtrl = "")
0584 | COM_Ansi4Unicode(pString, nSize = "")
0593 | COM_Unicode4Ansi(ByRef wString, sString, nSize = "")
0602 | COM_Ansi2Unicode(ByRef sString, ByRef wString, nSize = "")
0611 | COM_Unicode2Ansi(ByRef wString, ByRef sString, nSize = "")
0621 | COM_ScriptControl(sCode, sLang = "", bEval = False, sFunc = "", sName = "", pdisp = 0, bGlobal = False)

;}
;{   COM (3).ahk

;Functions:
0007 | COM_Init(bUn = "")
0013 | COM_Term()
0018 | COM_VTable(ppv, idx)
0023 | COM_QueryInterface(ppv, IID = "")
0029 | COM_AddRef(ppv)
0034 | COM_Release(ppv)
0045 | COM_QueryService(ppv, SID, IID = "")
0052 | COM_FindConnectionPoint(pdp, DIID)
0060 | COM_GetConnectionInterface(pcp)
0067 | COM_Advise(pcp, psink)
0073 | COM_Unadvise(pcp, nCookie)
0078 | COM_Enumerate(penum, ByRef Result, ByRef vt = "")
0086 | COM_Invoke(pdsp,name="",prm0="vT_NoNe",prm1="vT_NoNe",prm2="vT_NoNe",prm3="vT_NoNe",prm4="vT_NoNe",prm5="vT_NoNe",prm6="vT_NoNe",prm7="vT_NoNe",prm8="vT_NoNe",prm9="vT_NoNe")
0140 | COM_InvokeSet(pdsp,name,prm0,prm1="vT_NoNe",prm2="vT_NoNe",prm3="vT_NoNe",prm4="vT_NoNe",prm5="vT_NoNe",prm6="vT_NoNe",prm7="vT_NoNe",prm8="vT_NoNe",prm9="vT_NoNe")
0145 | COM_DispInterface(this, prm1="", prm2="", prm3="", prm4="", prm5="", prm6="", prm7="", prm8="")
0165 | COM_DispGetParam(pDispParams, Position = 0, vt = 8)
0172 | COM_DispSetParam(val, pDispParams, Position = 0, vt = 8)
0177 | COM_Error(hr = "", lr = "", pei = "", name = "")
0193 | COM_CreateIDispatch()
0205 | COM_GetDefaultInterface(pdisp)
0221 | COM_GetDefaultEvents(pdisp)
0258 | COM_GetGuidOfName(pdisp, Name)
0272 | COM_GetTypeInfoOfGuid(pdisp, GUID)
0282 | COM_ConnectObject(pdisp, prefix = "", DIID = "")
0300 | COM_DisconnectObject(psink)
0305 | COM_CreateObject(CLSID, IID = "", CLSCTX = 21)
0311 | COM_GetObject(Name)
0318 | COM_GetActiveObject(CLSID)
0326 | COM_CreateInstance(CLSID, IID = "", CLSCTX = 21)
0333 | COM_CLSID4ProgID(ByRef CLSID, ProgID)
0340 | COM_ProgID4CLSID(pCLSID)
0346 | COM_GUID4String(ByRef CLSID, String)
0353 | COM_String4GUID(pGUID)
0360 | COM_IsEqualGUID(pGUID1, pGUID2)
0365 | COM_CoCreateGuid()
0372 | COM_CoInitialize()
0377 | COM_CoUninitialize()
0382 | COM_CoTaskMemAlloc(cb)
0387 | COM_CoTaskMemFree(pv)
0392 | COM_SysAllocString(str)
0397 | COM_SysFreeString(pstr)
0402 | COM_SafeArrayDestroy(psar)
0407 | COM_VariantClear(pvar)
0412 | COM_VariantChangeType(pvarDst, pvarSrc, vt = 8)
0417 | COM_SysString(ByRef wString, sString)
0423 | COM_AccInit()
0430 | COM_AccTerm()
0435 | COM_AccessibleChildren(pacc, cChildren, ByRef varChildren)
0442 | COM_AccessibleObjectFromEvent(hWnd, idObject, idChild, ByRef _idChild_="")
0449 | COM_AccessibleObjectFromPoint(x, y, ByRef _idChild_="")
0456 | COM_AccessibleObjectFromWindow(hWnd, idObject=-4, IID = "")
0463 | COM_WindowFromAccessibleObject(pacc)
0469 | COM_GetRoleText(nRole)
0477 | COM_GetStateText(nState)
0485 | COM_AtlAxWinInit(Version = "")
0492 | COM_AtlAxWinTerm(Version = "")
0497 | COM_AtlAxGetHost(hWnd, Version = "")
0503 | COM_AtlAxGetControl(hWnd, Version = "")
0509 | COM_AtlAxAttachControl(pdsp, hWnd, Version = "")
0515 | COM_AtlAxCreateControl(hWnd, Name, Version = "")
0521 | COM_AtlAxCreateContainer(hWnd, l, t, w, h, Name = "", Version = "")
0526 | COM_AtlAxGetContainer(pdsp, bCtrl = "")
0534 | COM_ScriptControl(sCode, sEval = "", sName = "", Obj = "", bGlobal = "")
0540 | COM_Parameter(typ, prm = "", nam = "")
0545 | COM_Enwrap(obj, vt = 9)
0551 | COM_Unwrap(obj)

;}
;{   com.ahk

;Functions:
0007 | COM_Init()
0011 | COM_Term()
0015 | COM_VTable(ppv, idx)
0020 | COM_QueryInterface(ppv, IID = "")
0026 | COM_AddRef(ppv)
0031 | COM_Release(ppv)
0036 | COM_QueryService(ppv, SID, IID = "")
0044 | COM_FindConnectionPoint(pdp, DIID)
0052 | COM_GetConnectionInterface(pcp)
0059 | COM_Advise(pcp, psink)
0065 | COM_Unadvise(pcp, nCookie)
0070 | COM_Enumerate(penum, ByRef Result, ByRef vt = "")
0078 | COM_Invoke(pdsp,name="",prm0="vT_NoNe",prm1="vT_NoNe",prm2="vT_NoNe",prm3="vT_NoNe",prm4="vT_NoNe",prm5="vT_NoNe",prm6="vT_NoNe",prm7="vT_NoNe",prm8="vT_NoNe",prm9="vT_NoNe")
0133 | COM_Invoke_(pdsp,name,typ0="",prm0="",typ1="",prm1="",typ2="",prm2="",typ3="",prm3="",typ4="",prm4="",typ5="",prm5="",typ6="",prm6="",typ7="",prm7="",typ8="",prm8="",typ9="",prm9="")
0185 | COM_DispInterface(this, prm1="", prm2="", prm3="", prm4="", prm5="", prm6="", prm7="", prm8="")
0205 | COM_DispGetParam(pDispParams, Position = 0, vt = 8)
0212 | COM_DispSetParam(val, pDispParams, Position = 0, vt = 8)
0217 | COM_Error(hr = "", lr = "", pei = "", name = "")
0233 | COM_CreateIDispatch()
0245 | COM_GetDefaultInterface(pdisp)
0261 | COM_GetDefaultEvents(pdisp)
0298 | COM_GetGuidOfName(pdisp, Name)
0312 | COM_GetTypeInfoOfGuid(pdisp, GUID)
0323 | COM_ConnectObject(psource, prefix = "", DIID = "")
0340 | COM_DisconnectObject(psink)
0345 | COM_CreateObject(CLSID, IID = "", CLSCTX = 5)
0351 | COM_ActiveXObject(ProgID)
0357 | COM_GetObject(Moniker)
0363 | COM_GetActiveObject(ProgID)
0371 | COM_CLSID4ProgID(ByRef CLSID, ProgID)
0378 | COM_GUID4String(ByRef CLSID, String)
0385 | COM_ProgID4CLSID(pCLSID)
0391 | COM_String4GUID(pGUID)
0398 | COM_IsEqualGUID(pGUID1, pGUID2)
0403 | COM_CoCreateGuid()
0410 | COM_CoTaskMemAlloc(cb)
0415 | COM_CoTaskMemFree(pv)
0420 | COM_CoInitialize()
0425 | COM_CoUninitialize()
0430 | COM_SysAllocString(astr)
0435 | COM_SysFreeString(bstr)
0440 | COM_SysStringLen(bstr)
0445 | COM_SafeArrayDestroy(psar)
0450 | COM_VariantClear(pvar)
0455 | COM_VariantChangeType(pvarDst, pvarSrc, vt = 8)
0460 | COM_SysString(ByRef wString, sString)
0466 | COM_AccInit()
0473 | COM_AccTerm()
0480 | COM_AccessibleChildren(pacc, cChildren, ByRef varChildren)
0487 | COM_AccessibleObjectFromEvent(hWnd, idObject, idChild, ByRef _idChild_="")
0494 | COM_AccessibleObjectFromPoint(x, y, ByRef _idChild_="")
0501 | COM_AccessibleObjectFromWindow(hWnd, idObject=-4, IID = "")
0507 | COM_WindowFromAccessibleObject(pacc)
0513 | COM_GetRoleText(nRole)
0520 | COM_GetStateText(nState)
0527 | COM_AtlAxWinInit(Version = "")
0535 | COM_AtlAxWinTerm(Version = "")
0542 | COM_AtlAxAttachControl(pdsp, hWnd, Version = "")
0547 | COM_AtlAxCreateControl(hWnd, Name, Version = "")
0553 | COM_AtlAxGetControl(hWnd, Version = "")
0560 | COM_AtlAxGetHost(hWnd, Version = "")
0567 | COM_AtlAxCreateContainer(hWnd, l, t, w, h, Name = "", Version = "")
0572 | COM_AtlAxGetContainer(pdsp, bCtrl = "")
0580 | COM_Ansi4Unicode(pString, nSize = "")
0589 | COM_Unicode4Ansi(ByRef wString, sString, nSize = "")
0598 | COM_Ansi2Unicode(ByRef sString, ByRef wString, nSize = "")
0607 | COM_Unicode2Ansi(ByRef wString, ByRef sString, nSize = "")
0617 | COM_ScriptControl(sCode, sLang = "", bEval = False, sFunc = "", sName = "", pdisp = 0, bGlobal = False)

;}
;{   ComboX.ahk

;Functions:
0023 | ComboX_Hide( HCtrl )
0057 | ComboX_Set( HCtrl, Options="", Handler="")
0085 | ComboX_Show( HCtrl, X="", Y="", W="", H="" )
0108 | ComboX_Toggle(HCtrl)
0114 | ComboX_wndProc(Hwnd, UMsg, WParam, LParam)
0144 | ComboX_setPosition( HCtrl, Pos, Hwnd, W="", H="" )

;Labels:
4137 | ComboX_wndProc

;}
;{   COMo.ahk

;Functions:
0002 | COMo_GetVal(obj, name)
0010 | COMo_SetVal(obj, name, val)
0013 | COMo_Call(obj, func, prm1="vT_NoNe",prm2="vT_NoNe",prm3="vT_NoNe",prm4="vT_NoNe",prm5="vT_NoNe",prm6="vT_NoNe")
0024 | COMo(param, sfn="CreateObject")
0030 | COMo_Delete(obj)

;}
;{   compile to vpk.ahk

;Functions:
0015 | vpk_Compile(SourcePath)
0035 | vpk_Extract(SourcePath)
0059 | vpk_Run(command)

;}
;{   ComVar.ahk

;Functions:
0001 | ComVar(Type=0xC)
0017 | ComVarDel(cv)

;}
;{   ConnectedToInternet.ahk

;Functions:
0003 | ConnectedToInternet(flag=0x40)

;}
;{   ConsoleApp v1.2.ahk

;Functions:
0040 | ConsoleApp_RunWait(CmdLine, WorkingDir="", byref ExitCode="")
0106 | ConsoleApp_Run(CmdLine, WorkingDir="", Reserved="", byref PID="")
0310 | ConsoleApp_GetStdOut(ConsoleAppHandle, byref Stdout, byref BytesAppended = 0, byref ExitCode="")
0368 | ConsoleApp_CloseHandle(ConsoleAppHandle)
0406 | ConsoleApps_Initialize()
0428 | CONSOLEAPPS_PRIVATE_ReadFile(hFile, byref buf, byref BytesRead=0, BufferSize=4096)
0442 | CONSOLEAPPS_PRIVATE_abort()
0453 | CONSOLEAPPS_PRIVATE_calloc(byref Var, size, fillbyte=0)
0462 | CONSOLEAPPS_PRIVATE_free(byref Var)
0467 | CONSOLEAPPS_PRIVATE_WIN32_MAKELANGID(p, s)
0472 | CONSOLEAPPS_PRIVATE_malloc(byref var, size)
0487 | CONSOLEAPPS_PRIVATE_PtrToStr(lpStr)
0495 | CONSOLEAPPS_PRIVATE_throw(ErrorCode, ErrorMessage="", ParamName="", LastWin32Error="")

;}
;{   ConsoleApp.ahk V2.0

;Functions:
0040 | ConsoleApp_RunWait(CmdLine, WorkingDir="", byref ExitCode="")
0106 | ConsoleApp_Run(CmdLine, WorkingDir="", Reserved="", byref PID="")
0310 | ConsoleApp_GetStdOut(ConsoleAppHandle, byref Stdout, byref BytesAppended = 0, byref ExitCode="")
0368 | ConsoleApp_CloseHandle(ConsoleAppHandle)
0406 | ConsoleApps_Initialize()
0428 | CONSOLEAPPS_PRIVATE_ReadFile(hFile, byref buf, byref BytesRead=0, BufferSize=4096)
0442 | CONSOLEAPPS_PRIVATE_abort()
0453 | CONSOLEAPPS_PRIVATE_calloc(byref Var, size, fillbyte=0)
0462 | CONSOLEAPPS_PRIVATE_free(byref Var)
0467 | CONSOLEAPPS_PRIVATE_WIN32_MAKELANGID(p, s)
0472 | CONSOLEAPPS_PRIVATE_malloc(byref var, size)
0487 | CONSOLEAPPS_PRIVATE_PtrToStr(lpStr)
0495 | CONSOLEAPPS_PRIVATE_throw(ErrorCode, ErrorMessage="", ParamName="", LastWin32Error="")

;}
;{   Container.ahk

;Functions:
0018 | Container_DefaultPreferences(name)
0056 | Container_COM(c,comobj,field="")
0060 | Container_COMn(c,comobj,field="",n=1)
0068 | Container_list(c, list, delimiters="__deFault__", omit="__deFault__")
0072 | Container_listn(c,list,n,delimiters="__deFault__", omit="__deFault__")
0083 | Container_array(c, array)
0087 | Container_arrayn(c,array,n)
0094 | Container_file(c, fpath, delimiters="__deFault__", omit="__deFault__")
0098 | Container_filen(c,fpath,n,delimiters="__deFault__", omit="__deFault__")
0131 | Container_toList(c,delim="__deFault__")
0138 | Container_toArray(c)
0145 | Container_toFile(c,fpath="", options="")
0163 | Container_toClipboard(c,delim="__deFault__")
0170 | Container_x(c,indexOrValue)
0176 | Container_clear(c)
0180 | Container_makeTemplate(c)
0195 | Container_makeCopy(c)
0202 | Container_sort(c,type="__deFault__", method="__deFault__", c2="",reverse=0)
0235 | Container_rsort(c, type="__deFault__", method="__deFault__")
0239 | Container_sortLinked(c,c2, type="__deFault__", method="__deFault__")
0243 | Container_rsortLinked(c,c2, type="__deFault__", method="__deFault__")
0247 | Container_makeOrder(c)
0258 | Container_updateLinked(c,c2,order)
0269 | Container_refresh(c,param="__deFault__")
0332 | Container_editAsText(c,editor="__deFault__")
0372 | xor(a,b)
0379 | Container_xBlanks(c)
0387 | Container_xDuplicates(c)
0400 | Container_xShared(c,c2)
0407 | Container_xIn(c,c2)
0411 | Container_iIn(c,c2)
0415 | finder(item,c)
0420 | remove_unchanged(c1,c2)
0434 | Container_iAt(c,indices)
0438 | Container_xAt(c,indices)
0442 | Container_iRange(c,start=1,end="")
0446 | Container_xRange(c,start=1,end="")
0466 | Container_makeIndicesSlice(o,indices,ret="",overwrite=false)
0506 | Container_makeRangeSlice(o,start=1,end="",ret="",off0=-1,off1=-1,remove=true)
0544 | Container_makeSlice(o,a=1,b="",c=0, off0=-1,off1=-1,remove=true)
0558 | Container_isEmpty(c)
0563 | Container_IsEqual(c,c2,strict=true)
0575 | Container_IsEquivalent(c,c2)
0579 | Container_find(c,item,x_index=0)
0590 | Container_makeTemp(c,type="file", create=false, base="")
0615 | Container__runWait(f, line, working_dir="", options="")
0619 | Container__run(f, line, working_dir="", options="", wait=false)

;}
;{   Contains.ahk

;Functions:
0024 | Contains(haystack, needle)

;}
;{   ControlCol.ahk

;Functions:
0005 | ControlCol(Control, Window, bc="", tc="", redraw=1)
0031 | WindowProc(hwnd, uMsg, wParam, lParam)

;}
;{   ControlColor.ahk

;Functions:
0013 | WindowProc(hWnd, uMsg, wParam, lParam)

;}
;{   Control_AniGif.ahk

;Functions:
0037 | AniGif_CreateControl(_guiHwnd, _x, _y, _w, _h, _style="")
0094 | AniGif_DestroyControl(_agHwnd)
0111 | AniGif_LoadGifFromFile(_agHwnd, _gifFile)
0122 | AniGif_UnloadGif(_agHwnd)
0132 | AniGif_SetHyperlink(_agHwnd, _url)
0141 | AniGif_Zoom(_agHwnd, _bZoomIn)
0151 | AniGif_SetBkColor(_agHwnd, _backColor)


;}
;{   Control_AVI.ahk

;Functions:
0030 | AVI_CreateControl(_guiHwnd, _x, _y, _w, _h, _aviRef, _aviDLL="", _style="")
0120 | AVI_Play(_aviHwnd)
0136 | AVI_Stop(_aviHwnd)
0144 | AVI_DestroyControl(_aviHwnd)


;}
;{   ConvertImage.ahk

;Functions:
0016 | Gdip_Startup()
0028 | Gdip_Shutdown(pToken)
0053 | ConvertImage(sInput, sOutput, Width="", Height="", Method="Percent")

;}
;{   Count.ahk

;Functions:
0001 | Count(obj, key = "")

;}
;{   CpuMeter.ahk

;Functions:
0107 | LClick7()
0135 | Hover7()
0178 | FullDT()

;}
;{   CpyData.ahk

;Functions:
0045 | _CpyData_OnRcv(wParam, lParam)

;}
;{   cRichEdit.ahk

;Functions:
0023 | cRichEdit(_ctrlID, _action, opt1="", opt2="", opt3="", opt4="", opt5="", opt6="")
0595 | cRichEdit_RTFout(dwCookie, pbBuff, cb, pcb)

;}
;{   Crypt.ahk

;Functions:
0001 | Crypt_Hash(pData, nSize, SID = "CRC32", nInitial = 0)
0035 | Crypt_AES(pData, nSize, sPassword, SID = 256, bEncrypt = True)

;}
;{   CSV.ahk

;Functions:
0069 | CSV_Save(FileName, CSV_Identifier, OverWrite="1")
0108 | CSV_TotalRows(CSV_Identifier)
0115 | CSV_TotalCols(CSV_Identifier)
0122 | CSV_Delimiter(CSV_Identifier)
0129 | CSV_FileName(CSV_Identifier)
0136 | CSV_Path(CSV_Identifier)
0143 | CSV_FileNamePath(CSV_Identifier)
0150 | CSV_DeleteRow(CSV_Identifier, RowNumber)
0173 | CSV_AddRow(CSV_Identifier, RowData)
0182 | CSV_DeleteColumn(CSV_Identifier, ColNumber)
0205 | CSV_AddColumn(CSV_Identifier, ColData)
0220 | CSV_ModifyCell(CSV_Identifier, Value, Row, Col)
0226 | CSV_ModifyRow(CSV_Identifier, Value, RowNumber)
0232 | CSV_ModifyColumn(CSV_Identifier, Coldata, ColNumber)
0245 | CSV_Search(CSV_Identifier, SearchText, Instance=1)
0272 | CSV_SearchRow(CSV_Identifier, SearchText, RowNumber, Instance=1)
0292 | CSV_SearchColumn(CSV_Identifier, SearchText, ColNumber, Instance=1)
0312 | CSV_MatchCell(CSV_Identifier,SearchText, Instance=1)
0339 | CSV_MatchCellColumn(CSV_Identifier, SearchText, ColNumber, Instance=1)
0359 | CSV_MatchCellRow(CSV_Identifier, SearchText, RowNumber, Instance=1)
0379 | CSV_MatchRow(CSV_Identifier, SearchText, Instance=1)
0408 | CSV_MatchCol(CSV_Identifier, SearchText, Instance=1)
0437 | CSV_ReadCell(CSV_Identifier, Row, Col)
0444 | CSV_ReadRow(CSV_Identifier, RowNumber)
0458 | CSV_ReadCol(CSV_Identifier, ColNumber)
0472 | CSV_LVLoad(CSV_Identifier, Gui=1, x=10, y=10, w="", h="", header="", Sort=0, AutoAdjustCol=1)
0507 | CSV_LVSave(FileName, CSV_Identifier, Delimiter=",",OverWrite=1, Gui=1)
0539 | Format4CSV(F4C_String)
0582 | ReturnDSVArray(CurrentDSVLine, ReturnArray="DSVfield", Delimiter=",", Encapsulator="""")

;}
;{   CSV_Functions AHK_L.ahk

;Functions:
0096 | CSV_Save(FileName, CSV_Identifier, OverWrite="1")
0135 | CSV_TotalRows(CSV_Identifier)
0142 | CSV_TotalCols(CSV_Identifier)
0149 | CSV_Delimiter(CSV_Identifier)
0156 | CSV_FileName(CSV_Identifier)
0163 | CSV_Path(CSV_Identifier)
0170 | CSV_FileNamePath(CSV_Identifier)
0177 | CSV_DeleteRow(CSV_Identifier, RowNumber)
0200 | CSV_AddRow(CSV_Identifier, RowData)
0209 | CSV_DeleteColumn(CSV_Identifier, ColNumber)
0232 | CSV_AddColumn(CSV_Identifier, ColData)
0247 | CSV_ModifyCell(CSV_Identifier, Value, Row, Col)
0253 | CSV_ModifyRow(CSV_Identifier, Value, RowNumber)
0259 | CSV_ModifyColumn(CSV_Identifier, Coldata, ColNumber)
0272 | CSV_Search(CSV_Identifier, SearchText, Instance=1)
0299 | CSV_SearchRow(CSV_Identifier, SearchText, RowNumber, Instance=1)
0319 | CSV_SearchColumn(CSV_Identifier, SearchText, ColNumber, Instance=1)
0339 | CSV_MatchCell(CSV_Identifier,SearchText, Instance=1)
0366 | CSV_MatchCellColumn(CSV_Identifier, SearchText, ColNumber, Instance=1)
0408 | CSV_MatchRow(CSV_Identifier, SearchText, Instance=1)
0437 | CSV_MatchCol(CSV_Identifier, SearchText, Instance=1)
0466 | CSV_ReadCell(CSV_Identifier, Row, Col)
0473 | CSV_ReadRow(CSV_Identifier, RowNumber)
0487 | CSV_ReadCol(CSV_Identifier, ColNumber)
0501 | CSV_LVLoad(CSV_Identifier, Gui=1, x=10, y=10, w="", h="", header="", Sort=0, AutoAdjustCol=1)
0536 | CSV_LVSave(FileName, CSV_Identifier, Delimiter=",",OverWrite=1, Gui=1)
0571 | Format4CSV(F4C_String)
0614 | ReturnDSVArray(CurrentDSVLine, ReturnArray="DSVfield", Delimiter=",", Encapsulator="""")

;}
;{   Cursor.ahk

;Functions:
0048 | Ext_Cursor(HCtrl, Shape)
0055 | Ext_Cursor_wndProc(Hwnd, UMsg, WParam, LParam)

;}
;{   d2d1.ahk

;Functions:
0003 | __new(p="")
0017 | ReloadSystemMetrics()
0024 | GetDesktopDpi()
0030 | CreateRectangleGeometry(rectangle)
0039 | CreateRoundedRectangleGeometry(roundedRectangle)
0049 | CreateEllipseGeometry(ellipse)
0059 | CreateGeometryGroup(fillMode,geometries,geometriesCount)
0073 | CreateTransformedGeometry(sourceGeometry,transform)
0083 | CreatePathGeometry()
0090 | CreateStrokeStyle(strokeStyleProperties,dashes,dashesCount)
0101 | CreateDrawingStateBlock(drawingStateDescription,textRenderingParams)
0113 | CreateWicBitmapRenderTarget(target,renderTargetProperties)
0124 | CreateHwndRenderTarget(renderTargetProperties,hwndRenderTargetProperties)
0144 | CreateDxgiSurfaceRenderTarget(dxgiSurface,renderTargetProperties)
0158 | CreateDCRenderTarget(renderTargetProperties)
0172 | GetFactory()
0181 | CreateBitmap(x,y,srcData,pitch,bitmapProperties)
0194 | CreateBitmapFromWicBitmap(wicBitmapSource,bitmapProperties)
0220 | CreateSharedBitmap(riid,data,bitmapProperties)
0231 | CreateBitmapBrush(bitmap,bitmapBrushProperties=0,brushProperties=0)
0242 | CreateSolidColorBrush(color,brushProperties=0)
0252 | CreateGradientStopCollection(gradientStops,gradientStopsCount,colorInterpolationGamma,extendMode)
0264 | CreateLinearGradientBrush(linearGradientBrushProperties,brushProperties,gradientStopCollection)
0275 | CreateRadialGradientBrush(radialGradientBrushProperties,brushProperties,gradientStopCollection)
0294 | CreateCompatibleRenderTarget(desiredSize,desiredPixelSize,desiredFormat,options)
0308 | CreateLayer(size)
0318 | CreateMesh()
0329 | DrawLine(point0,point1,point2,point3,brush,strokeWidth,strokeStyle)
0339 | DrawRectangle(rect,brush,strokeWidth,strokeStyle)
0348 | FillRectangle(rect,brush)
0355 | DrawRoundedRectangle(roundedRect,brush,strokeWidth,strokeStyle)
0365 | FillRoundedRectangle(roundedRect,brush)
0372 | DrawEllipse(ellipse,brush,strokeWidth,strokeStyle)
0381 | FillEllipse(ellipse,brush)
0388 | DrawGeometry(geometry,brush,strokeWidth,strokeStyle)
0398 | FillGeometry(geometry,brush,opacityBrush=0)
0408 | FillMesh(mesh,brush)
0416 | FillOpacityMask(opacityMask,brush,content,destinationRectangle=0,sourceRectangle=0)
0426 | DrawBitmap(bitmap,destinationRectangle=0,opacity=1,interpolationMode=0,sourceRectangle=0)
0437 | DrawText(string,stringLength,textFormat,layoutRect,defaultForegroundBrush,options,measuringMode=0)
0450 | DrawTextLayout(origin0,origin1,textLayout,defaultForegroundBrush,options=0)
0459 | DrawGlyphRun(baselineOrigin0,baselineOrigin1,glyphRun,foregroundBrush,measuringMode=0)
0469 | SetTransform(transform)
0474 | GetTransform()
0481 | SetAntialiasMode(antialiasMode)
0486 | GetAntialiasMode()
0491 | SetTextAntialiasMode(textAntialiasMode)
0496 | GetTextAntialiasMode()
0503 | SetTextRenderingParams(textRenderingParams=0)
0510 | GetTextRenderingParams()
0517 | SetTags(tag1,tag2)
0523 | GetTags()
0532 | PushLayer(layerParameters,layer)
0541 | PopLayer()
0547 | Flush()
0553 | SaveDrawingState(drawingStateBlock)
0558 | RestoreDrawingState(drawingStateBlock)
0569 | PushAxisAlignedClip(clipRect,antialiasMode)
0577 | PopAxisAlignedClip()
0584 | Clear(D2D1_COLOR_F=0)
0597 | BeginDraw()
0602 | EndDraw()
0608 | GetPixelFormat()
0617 | SetDpi(dpiX,dpiY)
0622 | GetDpi()
0628 | GetSize()
0634 | GetPixelSize()
0642 | GetMaximumBitmapSize()
0648 | IsSupported(renderTargetProperties)
0657 | GetBitmap()
0666 | CheckWindowState()
0672 | Resize(pixelSize)
0677 | GetHwnd()
0686 | BindDC(hDC,pSubRect)
0694 | SetOpacity(opacity)
0699 | SetTransform(transform)
0704 | GetOpacity()
0709 | GetTransform()
0721 | SetExtendModeX(extendModeX)
0726 | SetExtendModeY(extendModeY)
0733 | SetInterpolationMode(interpolationMode)
0740 | SetBitmap(bitmap)
0747 | GetExtendModeX()
0752 | GetExtendModeY()
0757 | GetInterpolationMode()
0762 | GetBitmap()
0771 | SetColor(color)
0776 | GetColor()
0785 | SetStartPoint(startPoint)
0790 | SetEndPoint(endPoint)
0795 | GetStartPoint()
0800 | GetEndPoint()
0806 | GetGradientStopCollection()
0814 | SetCenter(center)
0819 | SetGradientOriginOffset(gradientOriginOffset)
0824 | SetRadiusX(radiusX)
0829 | SetRadiusY(radiusY)
0834 | GetCenter()
0839 | GetGradientOriginOffset()
0844 | GetRadiusX()
0849 | GetRadiusY()
0855 | GetGradientStopCollection()
0866 | GetBounds(worldTransform=0)
0876 | GetWidenedBounds(strokeWidth,strokeStyle,worldTransform,flatteningTolerance)
0889 | StrokeContainsPoint(point0,point1,strokeWidth,strokeStyle,worldTransform,flatteningTolerance)
0902 | FillContainsPoint(point0,point1,worldTransform,flatteningTolerance)
0914 | CompareWithGeometry(inputGeometry,inputGeometryTransform,flatteningTolerance)
0925 | Simplify(simplificationOption,worldTransform,flatteningTolerance)
0936 | Tessellate(worldTransform,flatteningTolerance)
0947 | CombineWithGeometry(inputGeometry,combineMode,inputGeometryTransform,flatteningTolerance)
0965 | Outline(worldTransform,flatteningTolerance)
0975 | ComputeArea(worldTransform,flatteningTolerance)
0985 | ComputeLength(worldTransform,flatteningTolerance)
0995 | ComputePointAtLength(length,worldTransform,flatteningTolerance)
1009 | Widen(strokeWidth,strokeStyle,worldTransform,flatteningTolerance,geometrySink)
1022 | GetRect()
1031 | GetRoundedRect()
1040 | GetEllipse()
1049 | GetFillMode()
1054 | GetSourceGeometryCount()
1059 | GetSourceGeometries(geometriesCount)
1067 | GetSourceGeometry()
1073 | GetTransform()
1085 | Open()
1091 | Stream(geometrySink)
1096 | GetSegmentCount()
1102 | GetFigureCount()
1114 | GetSize()
1119 | GetPixelSize()
1124 | GetPixelFormat()
1129 | GetDpi()
1138 | CopyFromBitmap(destPoint,bitmap,srcRect=0)
1148 | CopyFromRenderTarget(destPoint,renderTarget,srcRect=0)
1158 | CopyFromMemory(dstRect,srcData,pitch)
1170 | GetGradientStopCount()
1176 | GetGradientStops(gradientStopsCount)
1185 | GetColorInterpolationGamma()
1190 | GetExtendMode()
1197 | GetStartCap()
1202 | GetEndCap()
1207 | GetDashCap()
1212 | GetMiterLimit()
1217 | GetLineJoin()
1222 | GetDashOffset()
1228 | GetDashStyle()
1233 | GetDashesCount()
1239 | GetDashes(dashesCount)
1248 | Open()
1256 | GetSize()
1263 | GetDescription()
1270 | SetDescription(stateDescription)
1275 | SetTextRenderingParams(textRenderingParams=0)
1280 | GetTextRenderingParams()
1293 | SetFillMode(fillMode)
1298 | SetSegmentFlags(vertexFlags)
1304 | BeginFigure(startPoint0,startPoint1,figureBegin)
1311 | AddLines(points,pointsCount)
1318 | AddBeziers(beziers,beziersCount)
1325 | EndFigure(figureEnd)
1330 | Close()
1338 | AddLine(point0,point1)
1343 | AddBezier(bezier)
1348 | AddQuadraticBezier(bezier)
1353 | AddQuadraticBeziers(beziers,beziersCount)
1361 | AddArc(arc)
1372 | AddTriangles(triangles,trianglesCount)
1379 | Close()
1456 | D2D1_Struct(name,p=0)
1491 | D2D1_Constants(type)
1616 | D2D1_hr(a,ByRef b)

;}
;{   d3D.ahk

;Functions:
0019 | releaseDirect3D()
0032 | getDirect3D(h_win = "", device = "RGB Emulation", software = False)
0092 | getDirect3D2(h_win = "", device = "RGB Emulation", software = False)
0138 | getDirect3D3(h_win = "", device = "RGB Emulation", software = False)
0185 | getDirect3D7(h_win = "", device = "RGB Emulation")
0268 | enum3DDevices(device)
0275 | enum3DDevicesCallback(lpGuid, pDeviceDescription, lpDeviceName, lpD3DHWDeviceDesc, lpD3DHELDeviceDesc, lpUserArg)
0319 | enum3DDevices2(device)
0326 | enum3DDevicesCallback2(lpGuid, pDeviceDescription, lpDeviceName, lpD3DHWDeviceDesc, lpD3DHELDeviceDesc, lpUserArg)
0352 | enum3DDevices3(device)
0359 | enum3DDevicesCallback3(lpGuid, pDeviceDescription, lpDeviceName, lpD3DHWDeviceDesc, lpD3DHELDeviceDesc, lpUserArg)
0375 | createTexture2(pDdraw, pDevice, ww, hh, pixelformat = "ARGB")
0423 | releaseTexture2(tex)
0434 | matrix2String(pMatrix)
0446 | makeViewPortMatrix(x, y, w, h, MaxZ=1, MinZ=0)
0459 | changeViewPortMatrix(byref matrix, x, y, w, h, MaxZ=1, MinZ=0)

;}
;{   d3D11.ahk

;Functions:
0006 | getDirect3D11()
0057 | createBuffer11(byref pBuffer, size, pData = 0, stride = 4, STAGING = False)
0077 | compileShaderFromFile11(byref pShader, pDevice, file, entrypoint = "main", pTarget = "cs_4_1")
0120 | compileShader11(byref pShader, pDevice, ShaderCode, entrypoint = "main", pTarget = "cs_4_1")

;}
;{   d3D9.ahk

;Functions:
0006 | dumpPixelShader(pShader, file)
0018 | __new(dir, pDevice = "", file = "")
0066 | find(pShader)
0086 | __delete()
0096 | __new(pDevice, dim, tex)
0114 | update(dim, tex)
0132 | draw()
0144 | __delete()
0151 | __delete()
0158 | getRenderTargetTexture9(pDevice, pixelformat = "ARGB", width = 640, height = 480, usage = 0x00000001)
0186 | getDirect3D9(h_win = "", windowed = True, refresh = 60, ww = 640, hh = 480,pixelformat = "ARGB", dll = "d3dx9_24.dll")
0271 | releaseDirect3D9()

;}
;{   d3Dx9.ahk

;Functions:
0007 | __new(dll = "d3dx9_24.dll")
0030 | CreateTextureFromFile(pDevice, file, byref pTexture)
0035 | LoadSurfaceFromFile(pSurface, file, filter = 1)
0048 | CreateFontW(pDevice, font = "Verdana", italic = False)
0071 | DrawText(byref fnt, txt, clr = 0xFFFFFFFF, rct = "")
0093 | CompileShaderFromFile(pDevice, file, entrypoint, byref pShader)
0133 | CompileShader(pDevice, byref Shader, entrypoint, byref pShader)

;}
;{   DamerauLevenshteinDistance.ahk

;Functions:
0008 | DamerauLevenshteinDistance(s, t)

;}
;{   DataBaseAbstract.ahk

;Functions:
0020 | Count()
0024 | ToString()
0028 | __Get(param)
0060 | ContainsIndex(index)
0068 | __New(columns, fields)
0083 | __NewEnum()
0088 | __new(row)
0093 | next(ByRef key, ByRef val)
0110 | Count()
0114 | ToString()
0120 | __Get(param)
0141 | __New(rows, columns)
0155 | __NewEnum()
0166 | __delete()
0170 | IsValid()
0174 | Query(sql)
0178 | QueryValue(sQry)
0185 | QueryRow(sQry)
0192 | OpenRecordSet(sql, editable = false)
0196 | ToSqlLiteral(value)
0208 | EscapeString(string)
0212 | QuoteIdentifier(identifier)
0216 | BeginTransaction()
0220 | EndTransaction()
0224 | Rollback()
0228 | Insert(record, tableName)
0232 | InsertMany(records, tableName)
0236 | Update(fields, constraints, tableName, safe = True)
0240 | Close()
0249 | __delete()
0253 | TestRecordSet()
0257 | AddNew()
0261 | MoveNext()
0265 | Delete()
0269 | Update()
0273 | Close()
0277 | getEOF()
0281 | IsValid()
0285 | getColumnNames()
0289 | getCurrentRow()
0293 | __Get(param)

;}
;{   DataBaseADO.ahk

;Functions:
0011 | __New(connectionString)
0019 | Connect()
0030 | Close()
0041 | IsConnected()
0051 | IsValid()
0055 | GetLastError()
0059 | GetLastErrorMsg()
0070 | SetTimeout(timeout = 1000)
0077 | Changes()
0087 | OpenRecordSet(sql, editable = false)
0094 | Query(sql)
0112 | EscapeString(str)
0117 | BeginTransaction()
0122 | EndTransaction()
0127 | Rollback()
0132 | FetchADORecordSet(adoRS)
0164 | InsertMany(records, tableName)
0200 | Insert(record, tableName)

;}
;{   DataBaseFactory.ahk

;Functions:
0008 | OpenDataBase(dbType, connectionString)
0033 | __New()

;}
;{   DataBaseMySQL.ahk

;Functions:
0011 | __New(connectionData)
0022 | Connect()
0033 | Close()
0039 | IsValid()
0043 | GetLastError()
0047 | GetLastErrorMsg()
0051 | SetTimeout(timeout = 1000)
0058 | ErrMsg()
0062 | ErrCode()
0066 | Changes()
0076 | OpenRecordSet(sql, editable = false)
0103 | Query(sql)
0107 | EscapeString(str)
0111 | QuoteIdentifier(identifier)
0118 | BeginTransaction()
0122 | EndTransaction()
0126 | Rollback()
0130 | InsertMany(records, tableName)
0163 | Insert(record, tableName)
0169 | Update(fields, constraints, tableName, safe = True)
0189 | _GetTableObj(sql, maxResult = -1)

;}
;{   DataBaseSQLLite.ahk

;Functions:
0005 | GetVersion()
0009 | SQLiteExe(dbFile, commands, ByRef output)
0013 | __New()
0025 | __New(handleDB)
0035 | Close()
0040 | IsValid()
0044 | GetLastError()
0050 | GetLastErrorMsg()
0056 | SetTimeout(timeout = 1000)
0061 | ErrMsg()
0067 | ErrCode()
0071 | Changes()
0079 | OpenRecordSet(sql, editable = false)
0099 | Query(sql)
0122 | EscapeString(str)
0127 | QuoteIdentifier(identifier)
0135 | BeginTransaction()
0139 | EndTransaction()
0143 | Rollback()
0147 | InsertMany(records, tableName)
0209 | printKeys(arr)
0218 | Insert(record, tableName)
0227 | _GetTableObj(sql, maxResult = -1)
0311 | ReturnCode(RC)

;}
;{   DateParse.ahk

;Functions:
0018 | DateParse(str)

;}
;{   DBase.ahk

;Functions:
0036 | DBase_CreateDBF(pFileName, bVersion)
0055 | DBase_OpenDBF(pFileName)
0083 | DBase_AddField(hBase, fldName, fldType, fldLen, fldDecimal, fldWorkAreaId, fldFlag)
0109 | DBase_GetFieldName(hBase, fldNr)
0130 | DBase_GetFieldType(hBase, fldNr)
0151 | DBase_GetFieldLenght(hBase, fldNr)
0172 | DBase_GetFieldDecimal(hBase, fldNr)
0192 | DBase_GetRecordCount(hBase)
0212 | DBase_GetFieldCount(hBase)
0232 | DBase_AddRecord(hBase)
0253 | DBase_GetSubRecord(hBase, recNr, fldNr)
0276 | DBase_PutSubRecord(hBase, pValue, recNr, fldNr)
0296 | DBase_DeleteRecord(hBase, recNr)
0316 | DBase_UnDeleteRecord(hBase, recNr)
0347 | DBase_Search(hBase, pStr, fld, pBuf, len)
0372 | DBase_Pack(hBase)
0391 | DBase_Zap(hBase)
0412 | DBase_LoadMemo(hBase, recNr, fldNr)
0435 | DBase_WriteMemo(hBase, pMemo, recNr, fldNr)
0454 | DBase_CloseDBF(hBase)

;}
;{   DBGP.ahk

;Functions:
0005 | DBGp(session, command, args="", ByRef response="")
0021 | DBGp_StartListening(localAddress="127.0.0.1", localPort=9000)
0053 | DBGp_OnBegin(function_name)
0059 | DBGp_OnBreak(function_name)
0065 | DBGp_OnStream(function_name)
0071 | DBGp_OnEnd(function_name)
0077 | DBGp_StopListening(socket)
0083 | DBGp_Receive(session, ByRef packet)
0121 | DBGp_Send(session, command, args="")
0146 | DBGp_Base64UTF8Decode(ByRef base64)
0153 | DBGp_Base64UTF8Encode(ByRef textdata)
0160 | DBGp_Base64Decode(ByRef base64)
0168 | DBGp_Base64Encode(ByRef textdata)
0172 | DBGp_BinaryToString(ByRef bin, sz=0, fmt=12)
0179 | DBGp_StringToBinary(ByRef bin, hex, fmt=12)
0188 | DBGp_GetSessionSocket(session)
0193 | DBGp_GetSessionIDEKey(session)
0199 | DBGp_GetSessionCookie(session)
0205 | DBGp_GetSessionThread(session)
0210 | DBGp_GetSessionFile(session)
0230 | DBGp_WindowMessageHandler(hwnd, uMsg, wParam, lParam)
0339 | DBGp_AddSession(session)
0345 | DBGp_RemoveSession(session)
0351 | DBGp_FindSessionBySocket(socket)
0361 | DBGp_SetSessionAsync(session, async)
0385 | DBGp_EncodeFileURI(s)
0406 | DBGp_StrUpper(q)
0414 | DBGp_DecodeFileURI(s)
0434 | DBGp_DecodeXmlEntities(s)
0446 | DBGp_StrDup(str)
0455 | DBGp_hwnd()
0467 | DBGp_WSAE(n="")
0481 | DBGp_E(n)
0492 | DBGp_CloseSession(session)

;}
;{   dcomp.ahk

;Functions:
0005 | __new(p=0)
0037 | Commit()
0042 | WaitForCommitCompletion()
0048 | GetFrameStatistics()
0070 | CreateTargetForHwnd(hwnd,topmos=1)
0081 | CreateVisual()
0098 | CreateSurface(width,height,pixelFormat,alphaMode)
0111 | CreateVirtualSurface(initialWidth,initialHeight,pixelFormat,alphaMode)
0124 | CreateSurfaceFromHandle(handle)
0136 | CreateSurfaceFromHwnd(hwnd)
0147 | CreateTranslateTransform()
0155 | CreateScaleTransform()
0163 | CreateRotateTransform()
0171 | CreateSkewTransform()
0181 | CreateMatrixTransform()
0190 | CreateTransformGroup(transforms,elements=0)
0201 | CreateTranslateTransform3D()
0210 | CreateScaleTransform3D()
0219 | CreateRotateTransform3D()
0231 | CreateMatrixTransform3D()
0240 | CreateTransform3DGroup(transforms3D,elements=0)
0252 | CreateEffectGroup()
0261 | CreateRectangleClip()
0271 | CreateAnimation()
0280 | CheckDeviceState()
0295 | SetRoot(visual)
0317 | SetOffsetX(offset)
0322 | SetOffsetY(offset)
0335 | SetTransform(matrix)
0343 | SetTransformParent(visual)
0354 | SetEffect(effect)
0364 | SetBitmapInterpolationMode(interpolationMode)
0374 | SetBorderMode(borderMode)
0392 | SetClip(rect)
0408 | SetContent(content)
0423 | AddVisual(visual,insertAbove,referenceVisual)
0434 | RemoveVisual(visual)
0442 | RemoveAllVisuals()
0448 | SetCompositeMode(compositeMode)
0475 | SetOffsetX(offset)
0480 | SetOffsetY(offset)
0489 | SetScaleX(scale)
0493 | SetScaleY(scale)
0497 | SetCenterX(center)
0501 | SetCenterY(center)
0510 | SetAngle(angle)
0514 | SetCenterX(center)
0518 | SetCenterY(center)
0527 | SetAngleX(angle)
0531 | SetAngleY(angle)
0535 | SetCenterX(center)
0539 | SetCenterY(center)
0549 | SetMatrix(matrix)
0556 | SetMatrixElement(row,column,value)
0572 | SetOpacity(opacity)
0577 | SetTransform3D(transform3D)
0588 | SetOffsetX(offset)
0592 | SetOffsetY(offset)
0596 | SetOffsetZ(offset)
0605 | SetScaleX(scale)
0609 | SetScaleY(scale)
0613 | SetScaleZ(scale)
0617 | SetCenterX(center)
0621 | SetCenterY(center)
0625 | SetCenterZ(center)
0634 | SetAngle(angle)
0638 | SetAxisX(axis)
0642 | SetAxisY(axis)
0646 | SetAxisZ(axis)
0650 | SetCenterX(center)
0654 | SetCenterY(center)
0658 | SetCenterZ(center)
0667 | SetMatrix(matrix)
0673 | SetMatrixElement(row,column,value)
0693 | SetLeft(left)
0697 | SetTop(top)
0701 | SetRight(right)
0705 | SetBottom(bottom)
0709 | SetTopLeftRadiusX(radius)
0713 | SetTopLeftRadiusY(radius)
0717 | SetTopRightRadiusX(radius)
0721 | SetTopRightRadiusY(radius)
0725 | SetBottomLeftRadiusX(radius)
0729 | SetBottomLeftRadiusY(radius)
0733 | SetBottomRightRadiusX(radius)
0737 | SetBottomRightRadiusY(radius)
0760 | BeginDraw(updateRect,iid)
0774 | EndDraw()
0780 | SuspendDraw()
0785 | ResumeDraw()
0799 | Scroll(scrollRect,clipRect,offsetX,offsetY)
0815 | Resize(width,height)
0825 | Trim(rectangles,count)

;}
;{   DDE.ahk

;Functions:
0009 | DDE_Initialize(idInst = 0, pCallback = 0, nFlags = 0)
0015 | DDE_Uninitialize(idInst)
0020 | DDE_GetLastError(idInst)
0025 | DDE_NameService(idInst, sServ = "", nCmd = 1)
0030 | DDE_EnableCallback(idInst, hConv = 0, nCmd = 0)
0035 | DDE_PostAdvise(idInst, sTopic = "", sItem = "")
0042 | DDE_ClientTransaction(idInst, hConv, sType = "EXECUTE", sItem = "", pData = 0, cbData = 0, CF_Format = 1, bAsync = False)
0047 | DDE_AbandonTransaction(idInst, hConv = 0, idTransaction = 0)
0052 | DDE_Connect(idInst, sServ = "", sTopic = "", pCC = 0)
0059 | DDE_Reconnect(hConv)
0064 | DDE_Disconnect(hConv)
0069 | DDE_ConnectList(idInst, sServ = "", sTopic = "", hConvList = 0, pCC = 0)
0076 | DDE_DisconnectList(hConvList)
0081 | DDE_QueryNextServer(hConvList, hConvPrev = 0)
0086 | DDE_QueryConvInfo(hConv, idTransaction = -1, ByRef ci = "")
0091 | DDE_AccessData(hData, ByRef cbData = "")
0096 | DDE_UnaccessData(hData)
0101 | DDE_AddData(hData, pData, cbData, cbOff = 0)
0106 | DDE_GetData(hData, ByRef sData = "", cbOff = 0)
0114 | DDE_QueryString(idInst, hString, nCodePage = 1004)
0122 | DDE_CreateDataHandle(idInst, sItem = "", pData = 0, cbData = 0, cbOff = 0, CF_Format = 1, bOwned = True)
0127 | DDE_FreeDataHandle(hData)
0132 | DDE_CreateStringHandle(idInst, sString, nCodePage = 1004)
0137 | DDE_KeepStringHandle(idInst, hString)
0143 | DDE_FreeStringHandle(idInst, hString)
0148 | DDE_CmpStringHandles(hString1, hString2)
0153 | DDE_SetUserHandle(hConv, hUser)

;}
;{   DDEMessage.ahk

;Functions:
0033 | DDE_ACK(wParam, lParam, MsgID, hWnd)
0042 | DDE_DATA(wParam, lParam, MsgID)
0062 | DDE_POKE(sItem, sData)
0085 | DDE_EXECUTE(sCmd)

;}
;{   DDEML.ahk

;Functions:
0009 | DdeInitialize(pCallback = 0, nFlags = 0)
0015 | DdeUninitialize(idInst)
0020 | DdeConnect(idInst, hServer, hTopic, pCC = 0)
0025 | DdeDisconnect(hConv)
0030 | DdeAccessData(hData)
0035 | DdeUnaccessData(hData)
0040 | DdeFreeDataHandle(hData)
0045 | DdeCreateStringHandle(idInst, sString, nCodePage = 1004)
0050 | DdeFreeStringHandle(idInst, hString)
0055 | DdeClientTransaction(nType, hConv, hItem, sData = "", nFormat = 1, nTimeOut = 10000)

;}
;{   ddraw.ahk

;Functions:
0017 | fourCC(code)
0036 | setPixelFormat(format = "RGB")
0083 | getPixelFormat(byref desk)
0100 | LoadTexture(pInterface, pDevice, file_, byref ret, colorkey = "")
0168 | LoadTexture2(pInterface, pDevice, file_, byref ret, colorkey = "")
0253 | LoadSurface7(pInterface, file_)
0316 | dumpSurface(pSurface, dest)
0378 | dumpSurface2(pSurface, dest)
0429 | writeOnSurface(pSuf, txt, clr = 0x00000000, x = 0, y = 0)
0461 | DirectDrawCreate(software = False)
0478 | getDirectDraw(h_win = "", software=False)
0535 | getDirectDraw2(h_win = "", software = False)
0598 | getDirectDraw4(h_win = "", software=False)

;}
;{   DDSFile.ahk

;Functions:
0016 | setFilePixelFormat(format = "RGB")
0073 | getFilePixelFormat(byref fileHeader)
0099 | __delete()
0104 | makeDumpStructArray(byref lst)
0123 | loadDumpCollection(dir, byref lst)
0159 | loadCompiledDumpCollection(file, byref lst)
0221 | LoadTextureDumps(path = "")
0238 | compareSurfaceData(byref dump, byref desc, samples = 8, optimized = False)

;}
;{   Decompiler.ahk

;Functions:
0060 | Decompile(Path)
0188 | GetSectionOffset(ByRef Buffer,Name,ByRef DataOffset)
0217 | SearchBuffer(pBuffer,BufferSize,ByRef Search,SearchSize)

;Labels:
1716 | GuiClose
1619 | Update
1923 | GuiDropFiles
2331 | SelectFile
3137 | Decompile

;}
;{   Default.ahk

;Functions:
0012 | GetActiveWindowStats()
0040 | LLInit()
0046 | SendKey(Method = 1, Keys = "")
0112 | ClipSet(Task,ClipNum=1,SendMethod=1,Value="")
0235 | ClearClipboard()

;}
;{   DeluxeClipboard.ahk

;Functions:
0046 | WINDOW(Actn)
0157 | String2Hex(x)


;}
;{   Dictionary.ahk

;Functions:
0026 | Dictionary()
0033 | SetItem0(pdic, sKey, sItm)
0051 | SetItem(pdic, sKey, sItm)
0069 | GetItem(pdic, sKey)
0092 | Add(pdic, sKey, sItm)
0110 | Count(pdic)
0116 | Exists(pdic, sKey)
0130 | Items(pdic)
0138 | Rename(pdic, sKeyFr, sKeyTo)
0156 | Keys(pdic)
0164 | Remove(pdic, sKey)
0176 | RemoveAll(pdic)
0181 | SetCompareMode(pdic, nCompMode = 1)
0187 | GetCompareMode(pdic)
0193 | Enumerate(pdic)
0218 | NextKey(ByRef penm, pdic = 0)
0237 | HashVal(pdic, sKey)

;}
;{   dinput.ahk

;Functions:
0006 | DirectInputCreate(Unicode_ = False)
0031 | getDirectInput(Unicode_ = false)
0096 | DIEnumDevicesCallback(lpddi, pvRef)

;}
;{   DInputEmu.ahk

;Functions:
0006 | InitDInputEmu(byref config, _unicode = true)
0025 | IDirectInputDeviceW_GetDeviceState(p1, p2, p3)

;}
;{   Display.ahk

;Functions:
0017 | Display_CreateWindowCapture(ByRef device, ByRef context, ByRef pixels, ByRef id = "")
0028 | Display_DeleteWindowCapture(ByRef device, ByRef context, ByRef pixels)
0043 | Display_GetPixel(ByRef context, x, y)
0062 | Display_PixelSearch(x, y, w, h, color, variation, ByRef id = "")
0086 | Display_GetContext(ByRef device, ByRef context, ByRef pixels, ByRef id)
0097 | Display_CompareColors(ByRef bgr1, ByRef bgr2, ByRef variation)
0114 | Display_CompareRGBToBGR(ByRef rgb, ByRef bgr, ByRef variation)
0130 | Display_IsBlue(ByRef bgr, ByRef variation)
0137 | Display_IsGreen(ByRef bgr, ByRef variation)
0144 | Display_IsRed(ByRef bgr, ByRef variation)
0151 | Display_IsCyan(ByRef bgr, ByRef variation)
0165 | Display_IsViolet(ByRef bgr, ByRef variation)
0179 | Display_IsYellow(ByRef bgr, ByRef variation)
0193 | Display_IsLight(ByRef bgr, ByRef variation)
0204 | Display_IsDark(ByRef bgr, ByRef variation)
0218 | Display_FindPixelHorizontal(ByRef x, ByRef y, w, h, color, variation, ByRef context)
0237 | Display_FindPixelVertical(ByRef x, ByRef y, w, h, color, variation, ByRef context)
0267 | Display_FindText(ByRef x, ByRef y, ByRef w, ByRef h, color, variation, ByRef context)
0314 | Display_IsPixel(ByRef label, ByRef bgr, ByRef variation)
0387 | Display_ReadArea(x, y, w, h, color = 0x000000, variation = 32, ByRef id = "", maxwidth = 0, exclude = "")

;Labels:
7284 | Display_FTFindTop
4298 | Display_FTFindBottom
8317 | Display_BlueForeground
7320 | Display_BlueBackground
0323 | Display_GreenForeground
3326 | Display_GreenBackground
6329 | Display_RedForeground
9332 | Display_RedBackground
2335 | Display_CyanForeground
5338 | Display_CyanBackground
8341 | Display_YellowForeground
1344 | Display_YellowBackground
4347 | Display_VioletForeground
7350 | Display_VioletBackground
0353 | Display_DarkForeground
3356 | Display_DarkBackground
6359 | Display_LightForeground
9362 | Display_LightBackground
2430 | Display_SetPixels
0498 | Display_ReadDigit
8510 | Display_FoundTop
0521 | Display_FoundBottom
1539 | Display_SetColumnSequences
9573 | Display_SetRowSequences
3608 | Display_NextSetPixel
8617 | Display_NextClearPixel
7626 | Display_NextSetPixelH
6635 | Display_NextClearPixelH

;}
;{   Dlg.ahk

;Functions:
0016 | Dlg_Color(ByRef Color, hGui=0)
0080 | Dlg_Find( hGui, Handler, Flags="d", FindText="")
0113 | Dlg_Replace( hGui, Handler, Flags="", FindText="", ReplaceText="")
0160 | Dlg_Font(ByRef Name, ByRef Style, ByRef Color, Effects=true, hGui=0)
0264 | Dlg_Icon(ByRef Icon, ByRef Index, hGui=0)
0318 | Dlg_Open( hGui=0, Title="", Filter="", DefaultFilter="", Root="", DefaultExt="", Flags="FILEMUSTEXIST HIDEREADONLY" )
0380 | Dlg_Save( hGui=0, Title="", Filter="", DefaultFilter="", Root="", DefaultExt="", Flags="" )
0387 | Dlg_callback(wparam, lparam, msg, hwnd)

;}
;{   dll.ahk

;Functions:
0019 | Dll_PackFiles( Folder, DLL, Section="Files" )
0035 | Dll_CreateEmpty( F="empty.dll" )
0051 | Dll_Read( ByRef Var, Filename, Section, Key )

;}
;{   DllCallStruct.ahk

;Functions:
0037 | SetNextUInt(ByRef @struct, _value, _bReset=false)
0061 | GetNextUInt(ByRef @struct, _bReset=false)
0083 | SetNextByte(ByRef @struct, _value, _bReset=false)
0103 | GetNextByte(ByRef @struct, _bReset=false)
0129 | GetInteger(ByRef @source, _offset = 0, _size = 4, _bIsSigned = false)
0151 | SetInteger(ByRef @dest, _integer, _offset = 0, _size = 4)
0163 | GetUnicodeString(ByRef @unicodeString, _ansiString)
0181 | GetAnsiStringFromUnicodePointer(_unicodeStringPt)
0205 | DumpDWORDs(ByRef @bin, _byteNb, _bExtended=false)
0215 | DumpDWORDsByAddr(_binAddr, _byteNb, _bExtended=false)

;}
;{   DLLPack.ahk

;Functions:
0016 | DllPackFiles( Folder, DLL, Section="Files" )
0030 | DllCreateEmpty( F="empty.dll" )
0046 | DllRead( ByRef Var, Filename, Section, Key )

;}
;{   dmp.ahk

;Functions:
0145 | _dmpArrayEmpty(paArray)
0151 | _dmpGetQuotes(pVar)
0251 | _dmpGetVarContent(psText)
0260 | _dmpGetVarnames(psText)
0301 | _dmpListLines()

;}
;{   Dock.ahk

;Functions:
0070 | Dock(pClientID, pDockDef="", reset=0)
0138 | Dock_Shutdown()
0169 | Dock_Toggle( enable="" )
0197 | Dock_Update()
0252 | Dock_HookProc(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime )
0288 | API_SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags)
0293 | API_UnhookWinEvent( hWinEventHook )

;Labels:
3230 | Dock_SetZOrder
0237 | Dock_SetZOrder_OnClientFocus

;}
;{   DockA.ahk

;Functions:
0048 | DockA(HHost="", HClient="", DockDef="")
0052 | DockA_(HHost, HClient, DockDef, Hwnd)

;}
;{   DoDragDrop.ahk

;Functions:
0011 | DoDragDrop()

;}
;{   DownloadToFile.ahk

;Functions:
0001 | DownloadToFile(url, filename)

;}
;{   DownloadToString.ahk

;Functions:
0001 | DownloadToString(url, encoding = "utf-8")

;}
;{   DrawScreen.ahk

;Functions:
0029 | ShowSurface()
0035 | HideSurface()
0039 | WipeSurface(hwnd)
0055 | EndDraw(hdc)
0060 | SetPen(color, thickness, hdc)
0065 | if(pen)
0074 | DrawLine(hdc, rX1, rY1, rX2, rY2)
0079 | DrawRectangle(hdc, left, top, right, bottom)

;}
;{   dshow.ahk

;Functions:
0004 | getDirectShow()

;}
;{   dshow.hooks.ahk

;Functions:
0010 | IVideoWindow_SetWindowPosition(p1, p2, p3, p4, p5)

;}
;{   dsound.ahk

;Functions:
0006 | loadWAV(file_, formatcheck = True)
0082 | LoadRAWSoundData(byref PMEM, file_)
0101 | dumpSndBuffer(pSndBuff, locksize, file)
0142 | getDirectSound(hwin = "")

;}
;{   DumpHistory.ahk

;Functions:
0023 | DumpHistory()


;}
;{   dwrite (2).ahk

;Functions:
0005 | __new(ptr)
0018 | GetSystemFontCollection(checkForUpdates)
0027 | CreateCustomFontCollection(collectionLoader,collectionKey,collectionKeySize)
0039 | RegisterFontCollectionLoader(fontCollectionLoader)
0046 | UnregisterFontCollectionLoader(fontCollectionLoader)
0054 | CreateFontFileReference(filePath,lastWriteTime=0)
0076 | CreateFontFace(fontFaceType,numberOfFiles,fontFiles,faceIndex,fontFaceSimulationFlags)
0089 | CreateRenderingParams()
0097 | CreateMonitorRenderingParams(monitor)
0106 | CreateCustomRenderingParams(gamma,enhancedContrast,clearTypeLevel,pixelGeometry,renderingMode)
0120 | RegisterFontFileLoader(fontFileLoader)
0127 | UnregisterFontFileLoader(fontFileLoader)
0134 | CreateTextFormat(fontFamilyName,fontCollection,fontWeight,fontStyle,fontStretch,fontSize,localeName)
0149 | CreateTypography()
0157 | GetGdiInterop()
0165 | CreateTextLayout(string,stringLength,textFormat,maxWidth,maxHeight)
0179 | CreateGdiCompatibleTextLayout(string,stringLength,textFormat,layoutWidth,layoutHeight,pixelsPerDip,transform,useGdiNatural)
0196 | CreateEllipsisTrimmingSign(textFormat)
0206 | CreateTextAnalyzer()
0215 | CreateNumberSubstitution(substitutionMethod,localeName,ignoreUserOverride)
0228 | CreateGlyphRunAnalysis(glyphRun,pixelsPerDip,transform,renderingMode,measuringMode,baselineOriginX,baselineOriginY)
0248 | CreateEnumeratorFromKey(factory,collectionKey,collectionKeySize)
0264 | GetReferenceKey()
0273 | GetLoader()
0282 | Analyze()
0300 | ReadFileFragment(,fileOffset,fragmentSize)
0311 | ReleaseFileFragment(fragmentContext)
0319 | GetFileSize()
0328 | GetLastWriteTime()
0341 | MoveNext()
0349 | GetCurrentFontFile()
0362 | GetType()
0369 | GetFiles()
0378 | GetIndex()
0383 | GetSimulations()
0388 | IsSymbolFont()
0393 | GetMetrics()
0400 | GetGlyphCount()
0406 | GetDesignGlyphMetrics(glyphIndices,glyphCount,Byref glyphMetrics,isSideways)
0419 | GetGlyphIndices(codePoints,codePointCount)
0431 | TryGetFontTable(openTypeTableTag)
0443 | ReleaseFontTable(tableContext)
0450 | GetGlyphRunOutline(emSize,glyphIndices,glyphAdvances,glyphOffsets,glyphCount,isSideways,isRightToLeft,Byref geometrySink)
0465 | GetRecommendedRenderingMode(emSize,pixelsPerDip,measuringMode,renderingParams,Byref renderingMode)
0477 | GetGdiCompatibleMetrics(emSize,pixelsPerDip,transform,fontFaceMetrics=0)
0489 | GetGdiCompatibleGlyphMetrics(emSize,pixelsPerDip,transform,useGdiNatural,glyphIndices,glyphCount,glyphMetrics,isSideways)
0511 | GetGamma()
0517 | GetEnhancedContrast()
0523 | GetClearTypeLevel()
0528 | GetPixelGeometry()
0534 | GetRenderingMode()
0544 | GetFontFamilyCount()
0549 | GetFontFamily(index)
0558 | FindFamilyName(familyName)
0568 | GetFontFromFontFace(fontFace)
0583 | CreateStreamFromKey(fontFileReferenceKey,fontFileReferenceKeySize)
0597 | GetFilePathLengthFromKey(fontFileReferenceKey,fontFileReferenceKeySize)
0607 | GetFilePathFromKey(fontFileReferenceKey,fontFileReferenceKeySize)
0619 | GetLastWriteTimeFromKey(fontFileReferenceKey,fontFileReferenceKeySize)
0637 | SetTextAlignment(textAlignment)
0644 | SetParagraphAlignment(paragraphAlignment)
0651 | SetWordWrapping(wordWrapping)
0658 | SetReadingDirection(readingDirection)
0665 | SetFlowDirection(flowDirection)
0672 | SetIncrementalTabStop(incrementalTabStop)
0679 | SetTrimming(trimmingOptions,trimmingSign)
0688 | SetLineSpacing(lineSpacingMethod,lineSpacing,baseline)
0697 | GetTextAlignment()
0702 | GetParagraphAlignment()
0707 | GetWordWrapping()
0712 | GetReadingDirection()
0717 | GetFlowDirection()
0722 | GetIncrementalTabStop()
0727 | GetTrimming()
0736 | GetLineSpacing()
0746 | GetFontCollection()
0754 | GetFontFamilyNameLength()
0759 | GetFontFamilyName()
0768 | GetFontWeight()
0773 | GetFontStyle()
0778 | GetFontStretch()
0783 | GetFontSize()
0788 | GetLocaleNameLength()
0793 | GetLocaleName()
0807 | AddFontFeature(nameTag,parameter)
0816 | GetFontFeatureCount()
0821 | GetFontFeature(fontFeatureIndex)
0836 | CreateFontFromLOGFONT(logFont)
0845 | ConvertFontToLOGFONT(font)
0856 | ConvertFontFaceToLOGFONT(font)
0867 | CreateFontFaceFromHdc(hdc)
0876 | CreateBitmapRenderTarget(hdc,width,height)
0892 | SetMaxWidth(maxWidth)
0899 | SetMaxHeight(maxHeight)
0906 | SetFontCollection(fontCollection,startPosition,length)
0915 | SetFontFamilyName(fontFamilyName,startPosition,length)
0925 | SetFontWeight(fontWeight,startPosition,length)
0934 | SetFontStyle(fontStyle,startPosition,length)
0943 | SetFontStretch(fontStretch,startPosition,length)
0952 | SetFontSize(fontSize,startPosition,length)
0961 | SetUnderline(hasUnderline,startPosition,length)
0970 | SetStrikethrough(hasStrikethrough,startPosition,length)
0981 | SetDrawingEffect(drawingEffect,startPosition,length)
0990 | SetInlineObject(inlineObject,startPosition,length)
0999 | SetTypography(typography,startPosition,length)
1008 | SetLocaleName(localeName,startPosition,length)
1017 | GetMaxWidth()
1022 | GetMaxHeight()
1027 | GetFontCollection(currentPosition)
1038 | GetFontFamilyNameLength(currentPosition,nameLength)
1049 | GetFontFamilyName(currentPosition,nameSize)
1062 | GetFontWeight(currentPosition)
1073 | GetFontStyle(currentPosition)
1084 | GetFontStretch(currentPosition)
1095 | GetFontSize(currentPosition)
1106 | GetUnderline(currentPosition)
1117 | GetStrikethrough(currentPosition)
1128 | GetDrawingEffect(currentPosition)
1139 | GetInlineObject(currentPosition)
1150 | GetTypography(currentPosition)
1161 | GetLocaleNameLength(currentPosition)
1172 | GetLocaleName(currentPosition)
1187 | Draw(clientDrawingContext,renderer,originX,originY)
1198 | GetLineMetrics(lineMetrics,maxLineCount)
1208 | GetMetrics(textMetrics)
1218 | GetOverhangMetrics()
1228 | GetClusterMetrics(clusterMetrics,maxClusterCount)
1238 | DetermineMinWidth()
1246 | HitTestPoint(pointX,pointY)
1259 | HitTestTextPosition(textPosition,isTrailingHit)
1272 | HitTestTextRange(textPosition,textLength,originX,originY,maxHitTestMetricsCount)
1292 | AnalyzeScript(analysisSource,textPosition,textLength,analysisSink)
1302 | AnalyzeBidi(analysisSource,textPosition,textLength,analysisSink)
1313 | AnalyzeNumberSubstitution(analysisSource,textPosition,textLength,analysisSink)
1324 | AnalyzeLineBreakpoints(analysisSource,textPosition,textLength,analysisSink)
1334 | GetGlyphs(textString,textLength,fontFace,isSideways,isRightToLeft,scriptAnalysis,localeName,numberSubstitution,features,featureRangeLengths,featureRanges,maxGlyphCount)
1359 | GetGlyphPlacements(textString,clusterMap,textProps,textLength,glyphIndices,glyphProps,glyphCount,fontFace,fontEmSize,isSideways,isRightToLeft,scriptAnalysis,localeName,features,featureRangeLengths,featureRanges,glyphAdvances,glyphOffsets)
1385 | GetGdiCompatibleGlyphPlacements(textString,clusterMap,textProps,textLength,glyphIndices,glyphProps,glyphCount,fontFace,fontEmSize,pixelsPerDip,transform,useGdiNatural,isSideways,isRightToLeft,scriptAnalysis,localeName,features,featureRangeLengths,featureRanges,glyphAdvances,glyphOffsets)
1419 | GetAlphaTextureBounds(textureType)
1429 | CreateAlphaTexture(textureType,textureBounds,bufferSize)
1441 | GetAlphaBlendParams(renderingParams)
1457 | GetCount()
1462 | FindLocaleName(localeName)
1472 | GetLocaleNameLength(index)
1481 | GetLocaleName(index,size)
1493 | GetStringLength(index)
1503 | GetString(index,size)
1519 | GetFontCollection()
1527 | GetFontCount(GetFont)
1532 | GetFont(index)
1547 | GetFamilyNames()
1555 | GetFirstMatchingFont(weight,stretch,style,Byref matchingFont)
1566 | GetMatchingFonts(weight,stretch,style)
1582 | GetFontFamily()
1590 | GetWeight()
1595 | GetStretch()
1600 | GetStyle()
1605 | IsSymbolFont()
1610 | GetFaceNames()
1618 | GetInformationalStrings(informationalStringID)
1628 | GetSimulations()
1633 | GetMetrics()
1640 | HasCharacter(unicodeValue)
1649 | CreateFontFace()
1662 | Draw(clientDrawingContext,renderer,originX,originY,isSideways,isRightToLeft,clientDrawingEffect)
1675 | GetMetrics()
1685 | GetOverhangMetrics()
1694 | GetBreakConditions()
1708 | IsPixelSnappingDisabled(clientDrawingContext)
1717 | GetCurrentTransform(clientDrawingContext)
1728 | GetPixelsPerDip(clientDrawingContext)
1743 | DrawGlyphRun(clientDrawingContext,baselineOriginX,baselineOriginY,measuringMode,glyphRun,glyphRunDescription,clientDrawingEffect)
1757 | DrawUnderline(clientDrawingContext,baselineOriginX,baselineOriginY,underline,clientDrawingEffect)
1769 | DrawStrikethrough(clientDrawingContext,baselineOriginX,baselineOriginY,strikethrough,clientDrawingEffect)
1780 | DrawInlineObject(clientDrawingContext,originX,originY,inlineObject,isSideways,isRightToLeft,clientDrawingEffect)
1801 | DrawGlyphRun(baselineOriginX,baselineOriginY,measuringMode,glyphRun,renderingParams,textColor)
1818 | GetMemoryDC()
1824 | GetPixelsPerDip()
1829 | SetPixelsPerDip(pixelsPerDip)
1836 | GetCurrentTransform()
1845 | SetCurrentTransform(transform)
1852 | GetSize()
1861 | Resize(width,height)

;}
;{   dwrite.ahk

;Functions:
0005 | __new(ptr)
0017 | GetSystemFontCollection(checkForUpdates)
0023 | CreateCustomFontCollection(collectionLoader,collectionKey,collectionKeySize)
0030 | RegisterFontCollectionLoader(fontCollectionLoader)
0035 | UnregisterFontCollectionLoader(fontCollectionLoader)
0041 | CreateFontFileReference(filePath,lastWriteTime=0)
0054 | CreateFontFace(fontFaceType,numberOfFiles,fontFiles,faceIndex,fontFaceSimulationFlags)
0060 | CreateRenderingParams()
0066 | CreateMonitorRenderingParams(monitor)
0072 | CreateCustomRenderingParams(gamma,enhancedContrast,clearTypeLevel,pixelGeometry,renderingMode)
0079 | RegisterFontFileLoader(fontFileLoader)
0084 | UnregisterFontFileLoader(fontFileLoader)
0089 | CreateTextFormat(fontFamilyName,fontCollection,fontWeight,fontStyle,fontStretch,fontSize,localeName)
0095 | CreateTypography()
0101 | GetGdiInterop()
0107 | CreateTextLayout(string,stringLength,textFormat,maxWidth,maxHeight)
0114 | CreateGdiCompatibleTextLayout(string,stringLength,textFormat,layoutWidth,layoutHeight,pixelsPerDip,transform,useGdiNatural)
0121 | CreateEllipsisTrimmingSign(textFormat)
0128 | CreateTextAnalyzer()
0135 | CreateNumberSubstitution(substitutionMethod,localeName,ignoreUserOverride)
0143 | CreateGlyphRunAnalysis(glyphRun,pixelsPerDip,transform,renderingMode,measuringMode,baselineOriginX,baselineOriginY)
0154 | CreateEnumeratorFromKey(factory,collectionKey,collectionKeySize)
0165 | GetReferenceKey()
0171 | GetLoader()
0178 | Analyze()
0191 | ReadFileFragment(,fileOffset,fragmentSize)
0197 | ReleaseFileFragment(fragmentContext)
0203 | GetFileSize()
0210 | GetLastWriteTime()
0221 | MoveNext()
0227 | GetCurrentFontFile()
0238 | GetType()
0245 | GetFiles()
0251 | GetIndex()
0256 | GetSimulations()
0261 | IsSymbolFont()
0266 | GetMetrics()
0272 | GetGlyphCount()
0278 | GetDesignGlyphMetrics(glyphIndices,glyphCount,Byref glyphMetrics,isSideways)
0286 | GetGlyphIndices(codePoints,codePointCount,Byref glyphIndices)
0293 | TryGetFontTable(openTypeTableTag,tableData,Byref tableSize,Byref tableContext,Byref exists)
0299 | ReleaseFontTable(tableContext)
0304 | GetGlyphRunOutline(emSize,glyphIndices,glyphAdvances,glyphOffsets,glyphCount,isSideways,isRightToLeft,Byref geometrySink)
0310 | GetRecommendedRenderingMode(emSize,pixelsPerDip,measuringMode,renderingParams,Byref renderingMode)
0316 | GetGdiCompatibleMetrics(emSize,pixelsPerDip,transform,fontFaceMetrics=0)
0321 | GetGdiCompatibleGlyphMetrics(emSize,pixelsPerDip,transform,useGdiNatural,glyphIndices,glyphCount,glyphMetrics,isSideways)
0332 | GetGamma()
0338 | GetEnhancedContrast()
0344 | GetClearTypeLevel()
0349 | GetPixelGeometry()
0355 | GetRenderingMode()
0365 | GetFontFamilyCount()
0370 | GetFontFamily(index)
0376 | FindFamilyName(familyName)
0382 | GetFontFromFontFace(fontFace)
0394 | CreateStreamFromKey(fontFileReferenceKey,fontFileReferenceKeySize)
0404 | GetFilePathLengthFromKey(fontFileReferenceKey,fontFileReferenceKeySize)
0410 | GetFilePathFromKey(fontFileReferenceKey,fontFileReferenceKeySize)
0417 | GetLastWriteTimeFromKey(fontFileReferenceKey,fontFileReferenceKeySize,ByRef lastWriteTime)
0429 | SetTextAlignment(textAlignment)
0434 | SetParagraphAlignment(paragraphAlignment)
0439 | SetWordWrapping(wordWrapping)
0444 | SetReadingDirection(readingDirection)
0449 | SetFlowDirection(flowDirection)
0454 | SetIncrementalTabStop(incrementalTabStop)
0459 | SetTrimming(trimmingOptions,trimmingSign)
0465 | SetLineSpacing(lineSpacingMethod,lineSpacing,baseline)
0470 | GetTextAlignment()
0475 | GetParagraphAlignment()
0480 | GetWordWrapping()
0485 | GetReadingDirection()
0490 | GetFlowDirection()
0495 | GetIncrementalTabStop()
0500 | GetTrimming(ByRef trimmingOptions)
0506 | GetLineSpacing()
0512 | GetFontCollection()
0518 | GetFontFamilyNameLength()
0523 | GetFontFamilyName()
0530 | GetFontWeight()
0535 | GetFontStyle()
0540 | GetFontStretch()
0545 | GetFontSize()
0550 | GetLocaleNameLength()
0555 | GetLocaleName()
0567 | AddFontFeature(nameTag,parameter)
0573 | GetFontFeatureCount()
0578 | GetFontFeature(fontFeatureIndex)
0589 | CreateFontFromLOGFONT(logFont)
0595 | ConvertFontToLOGFONT(font)
0601 | ConvertFontFaceToLOGFONT(font)
0608 | CreateFontFaceFromHdc(hdc)
0614 | CreateBitmapRenderTarget(hdc,width,height)
0625 | SetMaxWidth(maxWidth)
0630 | SetMaxHeight(maxHeight)
0635 | SetFontCollection(fontCollection,startPosition,length)
0640 | SetFontFamilyName(fontFamilyName,startPosition,length)
0646 | SetFontWeight(fontWeight,startPosition,length)
0651 | SetFontStyle(fontStyle,startPosition,length)
0656 | SetFontStretch(fontStretch,startPosition,length)
0661 | SetFontSize(fontSize,startPosition,length)
0666 | SetUnderline(hasUnderline,startPosition,length)
0671 | SetStrikethrough(hasStrikethrough,startPosition,length)
0678 | SetDrawingEffect(drawingEffect,startPosition,length)
0683 | SetInlineObject(inlineObject,startPosition,length)
0688 | SetTypography(typography,startPosition,length)
0693 | SetLocaleName(localeName,startPosition,length)
0698 | GetMaxWidth()
0703 | GetMaxHeight()
0708 | GetFontCollection(currentPosition)
0714 | GetFontFamilyNameLength(currentPosition,nameLength)
0720 | GetFontFamilyName(currentPosition,nameSize)
0727 | GetFontWeight(currentPosition)
0733 | GetFontStyle(currentPosition)
0739 | GetFontStretch(currentPosition)
0745 | GetFontSize(currentPosition)
0751 | GetUnderline(currentPosition)
0757 | GetStrikethrough(currentPosition)
0763 | GetDrawingEffect(currentPosition)
0769 | GetInlineObject(currentPosition)
0775 | GetTypography(currentPosition)
0781 | GetLocaleNameLength(currentPosition)
0787 | GetLocaleName(currentPosition)
0796 | Draw(clientDrawingContext,renderer,originX,originY)
0802 | GetLineMetrics(lineMetrics,maxLineCount)
0808 | GetMetrics(textMetrics)
0814 | GetOverhangMetrics()
0821 | GetClusterMetrics(clusterMetrics,maxClusterCount)
0827 | DetermineMinWidth()
0833 | HitTestPoint(pointX,pointY)
0839 | HitTestTextPosition(textPosition,isTrailingHit)
0845 | HitTestTextRange(textPosition,textLength,originX,originY,maxHitTestMetricsCount)
0856 | AnalyzeScript(analysisSource,textPosition,textLength,analysisSink)
0861 | AnalyzeBidi(analysisSource,textPosition,textLength,analysisSink)
0867 | AnalyzeNumberSubstitution(analysisSource,textPosition,textLength,analysisSink)
0873 | AnalyzeLineBreakpoints(analysisSource,textPosition,textLength,analysisSink)
0878 | GetGlyphs(textString,textLength,fontFace,isSideways,isRightToLeft,scriptAnalysis,localeName,numberSubstitution,features,featureRangeLengths,featureRanges,maxGlyphCount,clusterMap,textProps,glyphIndices,Byref glyphProps,actualGlyphCount)
0884 | GetGlyphPlacements(textString,clusterMap,textProps,textLength,glyphIndices,glyphProps,glyphCount,fontFace,fontEmSize,isSideways,isRightToLeft,scriptAnalysis,localeName,features,featureRangeLengths,featureRanges,glyphAdvances,glyphOffsets)
0890 | GetGdiCompatibleGlyphPlacements(textString,clusterMap,textProps,textLength,glyphIndices,glyphProps,glyphCount,fontFace,fontEmSize,pixelsPerDip,transform,useGdiNatural,isSideways,isRightToLeft,scriptAnalysis,localeName,features,featureRangeLengths,featureRanges,glyphAdvances,glyphOffsets)
0901 | GetAlphaTextureBounds(textureType,Byref textureBounds)
0907 | CreateAlphaTexture(textureType,textureBounds,ByRef alphaValues,bufferSize)
0912 | GetAlphaBlendParams(renderingParams)
0923 | GetCount()
0928 | FindLocaleName(localeName)
0934 | GetLocaleNameLength(index)
0940 | GetLocaleName(index,size)
0948 | GetStringLength(index)
0955 | GetString(index,size)
0967 | GetFontCollection()
0973 | GetFontCount(GetFont)
0978 | GetFont(index)
0990 | GetFamilyNames()
0996 | GetFirstMatchingFont(weight,stretch,style,Byref matchingFont)
1002 | GetMatchingFonts(weight,stretch,style)
1013 | GetFontFamily()
1019 | GetWeight()
1024 | GetStretch()
1029 | GetStyle()
1034 | IsSymbolFont()
1039 | GetFaceNames()
1045 | GetInformationalStrings(informationalStringID)
1051 | GetSimulations()
1056 | GetMetrics()
1062 | HasCharacter(unicodeValue)
1068 | CreateFontFace()
1079 | Draw(clientDrawingContext,renderer,originX,originY,isSideways,isRightToLeft,clientDrawingEffect)
1084 | GetMetrics()
1091 | GetOverhangMetrics()
1097 | GetBreakConditions()
1108 | IsPixelSnappingDisabled(clientDrawingContext)
1114 | GetCurrentTransform(clientDrawingContext)
1121 | GetPixelsPerDip(clientDrawingContext)
1133 | DrawGlyphRun(clientDrawingContext,baselineOriginX,baselineOriginY,measuringMode,glyphRun,glyphRunDescription,clientDrawingEffect)
1139 | DrawUnderline(clientDrawingContext,baselineOriginX,baselineOriginY,underline,clientDrawingEffect)
1145 | DrawStrikethrough(clientDrawingContext,baselineOriginX,baselineOriginY,strikethrough,clientDrawingEffect)
1150 | DrawInlineObject(clientDrawingContext,originX,originY,inlineObject,isSideways,isRightToLeft,clientDrawingEffect)
1163 | DrawGlyphRun(baselineOriginX,baselineOriginY,measuringMode,glyphRun,renderingParams,textColor)
1171 | GetMemoryDC()
1177 | GetPixelsPerDip()
1182 | SetPixelsPerDip(pixelsPerDip)
1187 | GetCurrentTransform()
1193 | SetCurrentTransform(transform)
1198 | GetSize()
1204 | Resize(width,height)

;}
;{   EditControl.ahk

;Functions:
0059 | Edit_CanUndo(hEdit)
0108 | Edit_CharFromPos(hEdit,X,Y,ByRef r_CharPos="",ByRef r_LineIdx="")
0153 | Edit_Clear(hEdit)
0170 | Edit_Convert2DOS(p_Text)
0189 | Edit_Convert2Mac(p_Text)
0211 | Edit_Convert2Unix(p_Text)
0238 | Edit_ConvertCase(hEdit,p_Case)
0297 | Edit_Copy(hEdit)
0315 | Edit_Cut(hEdit)
0333 | Edit_EmptyUndoBuffer(hEdit)
0420 | Edit_FindText(hEdit,p_SearchText,p_Min=0,p_Max=-1,p_Flags="",ByRef r_RegExOut="")
0549 | Edit_FindTextReset()
0594 | Edit_FmtLines(hEdit,p_Flag)
0614 | Edit_GetFirstVisibleLine(hEdit)
0642 | Edit_GetLastVisibleLine(hEdit)
0665 | Edit_GetLimitText(hEdit)
0701 | Edit_GetLine(hEdit,p_LineIdx=-1,p_Length=-1)
0740 | Edit_GetLineCount(hEdit)
0771 | Edit_GetMargins(hEdit,ByRef r_LeftMargin="",ByRef r_RightMargin="")
0793 | Edit_GetModify(hEdit)
0821 | Edit_GetRect(hEdit,ByRef r_Left="",ByRef r_Top="",ByRef r_Right="",ByRef r_Bottom="")
0857 | Edit_GetSel(hEdit,ByRef r_StartSelPos="",ByRef r_EndSelPos="")
0886 | Edit_GetSelText(hEdit)
0926 | Edit_GetText(hEdit,p_Length=-1)
0949 | Edit_GetTextLength(hEdit)
0983 | Edit_GetTextRange(hEdit,p_Min=0,p_Max=-1)
0999 | Edit_IsMultiline(hEdit)
1016 | Edit_IsReadOnly(hEdit)
1061 | Edit_IsStyle(hEdit,p_Style)
1142 | Edit_LineFromChar(hEdit,p_CharPos=-1)
1161 | Edit_LineFromPos(hEdit,X,Y,ByRef r_CharPos="",ByRef r_LineIdx="")
1190 | Edit_LineIndex(hedit,p_LineIdx=-1)
1221 | Edit_LineLength(hEdit,p_LineIdx=-1)
1259 | Edit_LineScroll(hEdit,xScroll=0,yScroll=0)
1302 | Edit_LoadFile(hEdit,p_FileName,p_Convert2DOS=False,ByRef r_FileFormat="")
1364 | Edit_Paste(hEdit)
1398 | Edit_PosFromChar(hEdit,p_CharPos,ByRef X,ByRef Y)
1426 | Edit_ReplaceSel(hEdit,p_Text="",p_CanUndo=True)
1457 | Edit_SaveFile(hEdit,p_FileName,p_Convert="")
1517 | Edit_Scroll(hEdit,p_Pages=0,p_Lines=0)
1564 | Edit_ScrollCaret(hEdit)
1604 | Edit_SetLimitText(hEdit,p_Limit)
1638 | Edit_SetMargins(hEdit,p_LeftMargin="",p_RightMargin="")
1681 | Edit_SetModify(hEdit,p_Flag)
1766 | Edit_SetReadOnly(hEdit,p_Flag)
1799 | Edit_SetRect(hEdit,p_Left,p_Top,p_Right,p_Bottom)
1844 | Edit_SetTabStops(hEdit,p_NbrOfTabStops=0,p_DTU=32)
1885 | Edit_SetText(hEdit,p_Text)
1912 | Edit_SetSel(hEdit,p_StartSelPos=0,p_EndSelPos=-1)
1929 | Edit_TextIsSelected(hEdit)
1954 | Edit_Undo(hEdit)
1994 | Edit_GetActiveHandles(ByRef hEdit="",ByRef hWindow="",p_MsgBox=False)

;}
;{   EmptyMem.ahk

;Functions:
0050 | EmptyMem(PID="AHK Rocks")

;}
;{   Encoding.ahk

;Functions:
0002 | Encoding_IsValid(enc)

;}
;{   Eval.ahk

;Functions:
0076 | Eval(x)
0123 | Eval_1(x)
0155 | Eval_@(x)
0254 | Eval_ToBin(n)
0257 | Eval_ToBinW(n,W=8)
0262 | Eval_FromBin(bits)
0269 | Eval_GCD(a,b)
0272 | Eval_Choose(n,k)
0279 | Eval_Fib(n)
0285 | Eval_fac(n)

;}
;{   EWinHook.ahk

;Functions:
0042 | EWinHook_SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwflags)
0119 | EWinHook_UnhookWinEvent(hWinEventHook)

;}
;{   Excel.AHK

;Functions:
0091 | Excel_Get(_WinTitle="ahk_class XLMAIN")
0121 | Excel_ActiveCell(_ID)
0139 | Excel_GetActiveRow(_ID)
0157 | Excel_GetActiveCol(_ID)
0175 | Excel_GetActiveText(_ID)
0193 | Excel_GetSelection(_ID)
0219 | Excel_GetValue(_ID, _start="A1")
0241 | Excel_GetRowHeight(_ID, _start="1", _end="")
0265 | Excel_GetColWidth(_ID, _start="A", _end="")
0311 | Excel_AutoFill(_ID, _start="A1", _end="", _Sources="A1", _Type="Default")
0348 | Excel_SetRowHeight(_ID, _start="1", _end="", _value="Default")
0381 | Excel_SetColWidth(_ID, _start="A", _end="", _value="AutoFit")
0412 | Excel_SetValue(_ID, _start="A1", _end="", _value="")
0437 | Excel_SetStyle(_ID, _start="A1", _end="", _Style="Normal")
0461 | Excel_Select(_ID, _start="A1", _end="")
0483 | Excel_SetActive(_ID, _start="A1")
0507 | Excel_SetFormula(_ID, _start="A1", _end="", _value="SUM")
0535 | Excel_ScreenUpdate(_ID)
0549 | Excel_SplitPanes(_ID)
0566 | Excel_SetSplit(_ID,_Which="Row",_Where=1)
0593 | Excel_DelCells(_ID, _start="A1", _end="", _Direction="Up")
0619 | Excel_ClearText(_ID, _start="A1", _end="")
0643 | Excel_ClearAll(_ID, _start="A1", _end="")
0673 | Excel_ClearFormatting(_ID, _start="A1", _end="")
0697 | Excel_BgColor(_ID, _start="A1", _end="", _Color="19")
0773 | Excel_Font(_ID, _start="A1", _end="", _Options="B", _Font="")
0888 | Excel_Borders(_ID, _start="A1", _end="", _Options="s1 w2 c1 pt pb pl pr")
0946 | Excel_Acc_Init()
0952 | Excel_Acc_ObjectFromWindow(hWnd, idObject = -4)

;}
;{   ExcelToObj.ahk

;Functions:
0009 | ExcelToObj(ExcelFile, ByRef ResultObj, Format = "csv")

;}
;{   Exec.ahk

;Functions:
0004 | Exec(_#_1,_#_2="",_#_3="",_#_4="",_#_5="",_#_6="",_#_7="",_#_8="",_#_9="",_#_10="",_#_11="",_#_12="",_#_13="",_#_14="",_#_15="",_#_16="",_#_17="",_#_18="",_#_19="",_#_20="")

;Labels:
0443 | Return
4345 | AT
4546 | AutoTrim
4649 | BI
4950 | BlockInput
5053 | C
5354 | Click
5457 | CW
5758 | ClipWait
5861 | CTRL
6162 | Control
6265 | CC
6566 | ControlClick
6669 | CF
6970 | ControlFocus
7073 | CG
7374 | ControlGet
7478 | CGF
7879 | ControlGetFocus
7983 | CGP
8384 | ControlGetPos
8487 | CMO
8788 | ControlMove
8892 | CGT
9293 | ControlGetText
9397 | CS
9798 | ControlSend
8102 | CSR
2103 | ControlSendRaw
3106 | CST
6107 | ControlSetText
7111 | CM
1112 | CoordMode
2115 | CR
5116 | Critical
6119 | DHT
9120 | DetectHiddenText
0123 | DHW
3124 | DetectHiddenWindows
4127 | D
7128 | Drive
8132 | DG
2133 | DriveGet
3137 | DSF
7138 | DriveSpaceFree
8141 | ES
1142 | EnvSet
2146 | EG
6147 | EnvGet
7150 | EU
0151 | EnvUpdate
1154 | ESU
4155 | EnvSub
5158 | EA
8159 | EnvAdd
9162 | ED
2163 | EnvDiv
3166 | EM
6167 | EnvMult
7170 | E
0171 | Exit
1174 | EAP
4175 | ExitApp
5178 | FA
8179 | FileAppend
9182 | FC
2183 | FileCopy
3186 | FCD
6187 | FileCopyDir
7190 | FCDIR
0191 | FileCreateDir
1194 | FCS
4195 | FileCreateShortcut
5199 | FD
9200 | FileDelete
0203 | FGA
3204 | FileGetAttrib
4207 | FGS
7208 | FileGetSize
8211 | FGSH
1212 | FileGetShortcut
2217 | FGT
7218 | FileGetTime
8221 | FGV
1222 | FileGetVersion
2226 | FM
6227 | FileMove
7230 | FMD
0231 | FileMoveDir
1234 | FR
4235 | FileRead
5238 | FRL
8239 | FileReadLine
9242 | FRC
2243 | FileRecycle
3247 | FRE
7248 | FileRecycleEmpty
8252 | FRD
2253 | FileRemoveDir
3257 | FSF
7258 | FileSelectFile
8261 | FSD
1262 | FileSelectFolder
2265 | FSA
5266 | FileSetAttrib
6269 | FST
9270 | FileSetTime
0273 | FT
3274 | FormatTime
4277 | GKS
7278 | GetKeyState
8281 | GA
1282 | GroupActivate
2285 | GADD
5286 | GroupAdd
6289 | GCL
9290 | GroupClose
0293 | H
3294 | Hotkey
4298 | GS
8299 | GoSub
9302 | GT
2303 | GoTo
3306 | IMB
6307 | IfMsgBox
7320 | IEQ
0321 | INEQ
1322 | IG
2323 | IGOE
3324 | IL
4325 | ILOE
5326 | IIS
6327 | INIS
7328 | IWA
8329 | IWNA
9330 | IWE
0331 | IWNE
1332 | IE
2333 | INE
3334 | IfEqual
4335 | IfNotEqual
5336 | IfGreater
6337 | IfGreaterOrEqual
7338 | IfLess
8339 | IfLessOrEqual
9340 | IfInString
0341 | IfNotInString
1342 | IfWinActive
2343 | IfWinNotActive
3344 | IfWinExist
4345 | IfWinNotExist
5346 | IfExist
6347 | IfNotExist
7544 | KW
4545 | KeyWait
5548 | M
8549 | Menu
9552 | MC
2553 | MouseClick
3556 | MCD
6557 | MouseClickDrag
7560 | MGP
0561 | MouseGetPos
1565 | MM
5566 | MouseMove
6569 | MB
9570 | MsgBox
0643 | OE
3644 | OnExit
4647 | PGC
7648 | PixelGetColor
8651 | PS
1652 | PixelSearch
2655 | PWC
5656 | PixelWaitColor
6683 | PR
3684 | Process
4687 | R
7688 | Run
8692 | RA
2693 | RunAs
3699 | RW
9700 | RunWait
0704 | SN
4705 | Send
5708 | SP
8709 | SendPlay
9712 | SI
2713 | SendInput
3716 | SRAW
6717 | SendRaw
7720 | SEV
0721 | SendEvent
1724 | RND
4725 | Random
5728 | SE
8729 | SetEnv
9732 | SF
2733 | SetFormat
3736 | SMOD
6737 | SendMode
7740 | SKD
0741 | SetKeyDelay
1744 | SMD
4745 | SetMouseDelay
5748 | STMM
8749 | SetTitleMatchMode
9752 | SWD
2753 | SetWinDelay
3756 | SD
6757 | Shutdown
7760 | S
0761 | Sleep
1764 | SO
4765 | Sort
5770 | SPP
0771 | SplitPath
1775 | SBGT
5776 | StatusBarGetText
6779 | SBW
9780 | StatusBarWait
0783 | SCS
3784 | StringCaseSense
4787 | SGP
7788 | StringGetPos
8791 | SL
1792 | StringLeft
2795 | SLEN
5796 | StringLen
6799 | SLOW
9800 | StringLower
0803 | SM
3804 | StringMid
4807 | SRPL
7808 | StringReplace
8811 | SR
1812 | StringRight
2815 | SS
5816 | StringSplit
6819 | STL
9820 | StringTrimLeft
0823 | STR
3824 | StringTrimRight
4827 | SUP
7828 | StringUpper
8831 | SG
1832 | SysGet
2835 | TT
5836 | ToolTip
6839 | TRT
9840 | TrayTip
0843 | TR
3844 | Transform
4847 | UDTF
7848 | UrlDownloadToFile
8851 | VSC
1852 | VarSetCapacity
2855 | WA
5856 | WinActivate
6859 | WAB
9860 | WinActivateBottom
0863 | WC
3864 | WinClose
4867 | WGAT
7868 | WinGetActiveTitle
8871 | WGC
1872 | WinGetClass
2875 | WG
5876 | WinGet
6879 | WGP
9880 | WinGetPos
0883 | WGT
3884 | WinGetText
4887 | WGTT
7888 | WinGetTitle
8891 | WH
1892 | WinHide
2895 | WK
5896 | WinKill
6899 | WMSI
9900 | WinMenuSelectItem
0903 | WM
3904 | WinMove
4907 | WSH
7908 | WinShow
8911 | WS
1912 | WinSet
2917 | WST
7918 | WinSetTitle
8921 | WW
1922 | WinWait
2925 | WWA
5926 | WinWaitActive
6929 | WWC
9930 | WinWaitClose
0933 | WWNA
3934 | WinWaitNotActive
4937 | WMAX
7938 | WinMaximize
8941 | WMIN
1942 | WinMinimize
2945 | WR
5946 | WinRestore
6949 | IS
9950 | ImageSearch
0953 | ID
3954 | IniDelete
4957 | IR
7958 | IniRead
8961 | IW
1962 | IniWrite
2965 | I
5966 | Input
6972 | IB
2973 | InputBox
3976 | G
6977 | Gui
7980 | GD
0981 | GroupDeactivate
1984 | GC
4985 | GuiControl
5988 | GuiControlGet
8991 | If
1028 | RunCommand
1038 | KH
1039 | KeyHistory
1042 | LH
1043 | ListHotkeys
1046 | LV
1047 | ListVars
1050 | OD
1051 | OutputDebug
1054 | P
1055 | Pause
1058 | PM
1059 | PostMessage
1063 | SMSG
1064 | SendMessage
1068 | PRG
1069 | Progress
1072 | SIM
1073 | SplashImage
1076 | RD
1077 | RegDelete
1081 | REM
1082 | RegExMatch
1086 | RER
1087 | RegExReplace
1091 | RC
1092 | RegisterCallback
1095 | RR
1096 | RegRead
1100 | RWR
1101 | RegWrite
1105 | RL
1106 | Reload
1109 | SBL
1110 | SetBatchLines
1113 | SCD
1114 | SetControlDelay
1117 | SDMS
1118 | SetDefaultMouseSpeed
1121 | SNLS
1122 | SetNumLockState
1125 | SCLS
1126 | SetCapsLockState
1129 | SSLS
1130 | SetScrollLockState
1133 | SSCM
1134 | SetStoreCapslockMode
1137 | ST
1138 | SetTimer
1141 | SWDIR
1142 | SetWorkingDir
1146 | SB
1147 | SoundBeep
1150 | SOG
1151 | SoundGet
1155 | SGWV
1156 | SoundGetWaveVolume
1160 | SPL
1161 | SoundPlay
1165 | SOS
1166 | SoundSet
1170 | SSWV
1171 | SoundSetWaveVolume
1175 | STOF
1176 | SplashTextOff
1179 | STON
1180 | SplashTextOn
1183 | SU
1184 | Suspend
1187 | T
1188 | Thread
1191 | WGAS
1192 | WinGetActiveStats
1195 | WMA
1196 | WinMinimizeAll
1199 | WMAU
1200 | WinMinimizeAllUndo

;}
;{   exlib.ahk

;Functions:
0004 | print(msg = "")

;}
;{   Explorer.ahk

;Functions:
0005 | Explorer_GetPath(hwnd="")
0024 | Explorer_GetAll(hwnd="")
0028 | Explorer_GetSelected(hwnd="")
0033 | Explorer_GetWindow(hwnd="")
0050 | Explorer_Get(hwnd="",selection=false)

;}
;{   ExplorerGrouping.ahk

;Functions:
0035 | GetNewGroupName(dir)
0047 | FocusFolderView()
0053 | GetExplorerDirectory()
0060 | SetExplorerDirectory(dir)
0068 | MoveFileOrDir(source, dest)
0082 | GroupSelectedFiles()
0113 | UngroupSelectedFiles()

;}
;{   ExtListView.ahk

;Functions:
0032 | ExtListView_GetSingleItem(ByRef objLV, sState, nCol)
0125 | ExtListView_GetItemText(ByRef objLV, nRow, nCol)
0211 | ExtListView_DeInitialize(ByRef objLV)
0225 | ExtListView_CheckInitObject(ByRef objLV)
0234 | __ExtListView_AllocateMemory(ByRef objLV)
0250 | __ExtListView_DeAllocateMemory(ByRef objLV)

;}
;{   ExtractIconFromExecutable.ahk

;Functions:
0001 | ExtractIconFromExecutable(aFilespec, aIconNumber, aWidth, aHeight)

;}
;{   FAILED.ahk

;Functions:
0001 | FAILED(hr)

;}
;{   FC.ahk

;Functions:
0006 | GetDefaultPreferences()
0031 | FC_enableCatch(f)
0036 | FC_disableCatch(f)
0042 | FC_takeCatch(f,disable=false)
0064 | FC_array(f, array)
0072 | FC_file(f, fpath, fix_dirs=false, cpi=1200)
0081 | FC_pattern(f, pattern, folders=0, recurse=0, regexp="")
0093 | FC_regex(f,base,regexp, folders=1, recurse=1)
0101 | FC_exclude(f,indexOrValue)
0107 | FC_clear(f)
0112 | FC_getTemplate(f,takeCatch=false)
0130 | FC_getCopy(f,takeCatch=true)
0139 | FC_IsEqual(f,f2)
0146 | FC_IsEquivalent(f,f2)
0152 | FC_sort(f,method="depthsort",f2="")
0167 | FC_rsort(f)
0171 | FC_sortLinked(f,f2)
0175 | FC_rsortLinked(f,f2)
0179 | FC_getOrder(f)
0188 | FC_updateLinked(f,f2,order)
0198 | FC_refresh(f,param="__deFault__")
0227 | FC_absorb(f,p1="",p2="",p3="",p4="",p5="",p6="",p7="",p8="")
0240 | FC_extend(f, method,source="", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
0248 | FC_become(f, p1, p2="", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
0259 | FC_bud(f, p1, p2="", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
0266 | FC_getExpansion(f,includeFolders="__deFault__",recursive="__deFault__",pattern="__deFault__",f2="__deFault__")
0294 | FC_expand(f,includeFolders="__deFault__",recursive="__deFault__",pattern="__deFault__")
0300 | FC_getExpanded(f,includeFolders="__deFault__",recursive="__deFault__",pattern="__deFault__")
0327 | FC_getSplit(f,func, p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
0340 | FC_filter(f,func,keep_if_func_returns=false, p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
0344 | FC_filterTF(f,func,keep_if_return_is=false, p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
0354 | FC_manipulate(f,func, p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
0366 | FC_excludeAttributes(f,attr)
0370 | FC_includeAttributes(f,attr)
0374 | FC_getWithAttributes(f,attr)
0378 | FC_getWithoutAttributes(f,attr)
0382 | hasAttributes(item,list)
0388 | FC_excludeFiles(f)
0392 | FC_excludeFolders(f)
0396 | FC_getFiles(f)
0400 | FC_getFolders(f)
0404 | FC_excludeNotExist(f)
0408 | FC_getExist(f)
0412 | FC_excludeBlanks(f)
0421 | FC_get(f,func,p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
0426 | FC_excludeDuplicates(f)
0441 | FC_excludeWhereIn(f,f2)
0445 | FC_excludeWhereNotIn(f,f2)
0449 | FC_getWhereNotIn(f,f2)
0453 | FC_getWhereIn(f,f2)
0459 | FC_excludeMatched(f1,f2)
0463 | FC_excludeNotMatched(f1,f2)
0466 | remove_unchanged(f1,f2)
0491 | FC_excludeAt(f,indices)
0504 | FC_excludeNotAt(f,indices)
0511 | FC_getAt(f,indices)
0515 | FC_getNotAt(f,indices)
0519 | FC_excludeInRange(f,start=1,end="")
0526 | FC_excludeNotInRange(f,start=1,end="")
0530 | FC_getInRange(f,start=1,end="")
0534 | FC_getNotInRange(f,start=1,end="")
0544 | FC_simplify(f)
0597 | FC_getSimple(f)
0602 | FC_reduce(f)
0648 | FC_getReduced(f)
0653 | FC_getContaining(f,default="")
0678 | FC_toArray(f)
0700 | FC_structureToClipboard(f)
0708 | FC_explore(f, base_only=false, default="", warn=10)
0723 | FC_create(f)
0735 | FC_delete(f, recycle=true, prompt=false, extra_flags="")
0740 | FC_moveInto(f,p1,extra_flags="")
0744 | FC_moveOnto(f,p1,extra_flags="")
0748 | FC_move(f,p1, extra_flags="", dest_mode="onto")
0752 | FC_copyInto(f,p1, extra_flags="")
0756 | FC_copyOnto(f,p1, extra_flags="")
0760 | FC_copy(f,p1, extra_flags="", dest_mode="onto")
0765 | FC_rename(f,p1,extra_flags="")
0794 | FC_enfolder(f,dest="")
0802 | FC_spill(f,folders=1,recurse=0,delete=0)
0835 | FC_leak(f)
0839 | FC_dump(f,delete=0)
0843 | FC_flatten(f,delete=0)
0850 | FC_zip(f,destination="", prompt=true, hide=true, switches="-y")
0889 | FC_run7z(f, line, working_dir="", hide=true)
0894 | remove_dir_ext(item)
0900 | FC_shorten(f, recursive=false, delete=true)
0920 | shorten_helper(folder)
0924 | canShorten(item)
0941 | FC_removeEmptyFolders(f,recursive=true)
0952 | FC_up(f)
0956 | up_helper(item)
0963 | FC_doManip(f,func, p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
0969 | FC_setAttributes(f,attributes,recursive=false,catch=true)
0986 | FC_renameAsText(f,editor="__deFault__")
1002 | FC_find(f,path,exclude_index=-1)
1009 | FC_isEmpty(f)
1014 | FC_getStats(f, desired_units="")
1069 | StrSwap(item, target, replacement)
1074 | move_helper(item,dir)
1091 | sorter(a, b, c)
1098 | rs(a,b)
1102 | rsorter(a, b, c)
1107 | depthsort(item)
1112 | depthrsort(item)
1125 | simplifier(a,b,c)
1139 | reducer(a,b,c)
1145 | dir_fixer(item)
1161 | IsFolder(item)
1165 | IsFile(item)
1169 | IsBlank(item)
1173 | isEmpty(folder)
1179 | PathExist(item)
1183 | finder(item,fc)
1187 | getTemp(type="file", create=false, base="")
1209 | kill_bad_spaces(path)
1215 | promptForPath(list, path="", msg="", prompt=true, use_standard_dialog=false)
1255 | xor(a,b)
1269 | FC_SetPreference(f,name,value)
1273 | FC_GetPreference(f,name)
1277 | FC_runWait(f, line, working_dir="", options="")
1281 | FC_run(f, line, working_dir="", options="", wait=false)
1299 | MsgBox(p1,p2="",p3="",p4="")
1321 | FC_operation(f,operation,destination="",extra_flags="",dest_mode="onto")
1388 | ShFO(op, source_in, dest_in="", flags="", keep="__deFault__",merge="__deFault__", close_when_done=true)
1494 | MakeSuggestion(path)
1506 | tricky(item)
1512 | rts(item)
1519 | CallPrep(p1="__deFault__", p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__", p9="__deFault__")
1525 | Call0(func)
1528 | Call1(func,p1)
1531 | Call2(func,p1,p2)
1534 | Call3(func,p1,p2,p3)
1537 | Call4(func,p1,p2,p3,p4)
1540 | Call5(func,p1,p2,p3,p4,p5)
1543 | Call6(func,p1,p2,p3,p4,p5,p6)
1546 | Call7(func,p1,p2,p3,p4,p5,p6,p7)
1549 | Call8(func,p1,p2,p3,p4,p5,p6,p7,p8)
1552 | Call9(func,p1,p2,p3,p4,p5,p6,p7,p8,p9)
1561 | FC_caller(f,func,p1="__deFault__",p2="__deFault__",p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
1860 | Path(p1,p2="",p3="",p4="",p5="",p6="",p7="",p8="",p9="")
1880 | Path_caller(self,func,p1="__deFault__",p2="__deFault__",p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
1894 | Path_getter(self, key)
1905 | FC(method="",source="", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
2072 | FC_MethodDoesNotExist(f,method)
2078 | FC_Die(f)

;Labels:
1292 | FC_RUNDELAY

;}
;{   FcnLib-Misc.ahk

;Functions:
0007 | GitGetCurrentBranchName()
0015 | GitGetIssueNumber(currentBranchName)
0022 | GitGetIssueTitle(issueNumber)

;}
;{   FcnLib-Opera.ahk

;Functions:
0004 | RunOpera()
0029 | CloseAllTabs()
0043 | GoToPage(url)
0060 | WinWaitActiveTitleChange(oldTitle="")

;}
;{   FcnLib-Rewrites.ahk

;Functions:
0008 | FileAppend(text, file)
0015 | FileAppendLine(text, file)
0021 | FileCopy(source, dest, options="")
0032 | FileDelete(file)
0041 | FileMove(source, dest, options="")
0052 | FileCreate(text, file)
0068 | FileLineCount(file)
0079 | FileCopyDir(source, dest, options="")
0093 | FileDeleteDirForceful(dir)
0120 | FileDirExist(dirPath)
0124 | DirExist(dirPath)
0132 | EnsureDirExists(path)
0144 | ParentDir(fileOrFolder)
0157 | IniWrite(file, section, key, value)
0182 | IniDelete(file, section, key="")
0204 | IniRead(file, section, key, Default = "ERROR")
0224 | IniListAllSections(file)
0230 | IniListAllKeys(file, section="")
0238 | GetPID(exeName)
0244 | ProcessExist(exeName)
0250 | ProcessClose(exeName)
0255 | ProcessCloseAll(exeName)
0273 | ProcessCloseFifty(exeName)
0284 | StringReplace(ByRef InputVar, SearchText, ReplaceText = "", All = "A")
0291 | Reload()
0301 | ViewableIniFolder(iniFolder, viewableIniDestination)
0357 | IniFolderRead(iniFolder, section, key)
0385 | IniFolderWrite(iniFolder, section, key, value)
0400 | IniFolderListAllSections(iniFolder)
0420 | IniFolderListAllKeys(iniFolder, section="")
0450 | ArchiveOldInifParts(IniFolder)
0493 | ScriptCheckin(CurrentStatus)

;}
;{   FcnLib.ahk

;Functions:
0035 | SleepMinutes(minutes)
0041 | SleepSeconds(seconds)
0060 | CustomTitleMatchMode(options="")
0083 | ForceWinFocus(titleofwin, options="")
0113 | ForceWinFocusIfExist(titleofwin, options="")
0136 | CloseWin(titleofwin, options="")
0154 | SendViaClipboard(text)
0194 | MouseMoveIfImageSearch(filename)
0211 | ClickIfImageSearch(filename, clickOptions="left Mouse")
0235 | WaitForImageSearch(filename, variation=0, timeToWait=20, sleepTime=20)
0258 | IsRegExMatch(Haystack, Needle)
0263 | Remap(input, remap1, replace1, remap2=0, replace2=0, remap3=0, replace3=0, remap4=0, replace4=0, remap5=0, replace5=0, remap6=0, replace6=0)
0281 | MoveToRandomSpotInWindow()
0289 | WeightedRandom(OddsOfa1, OddsOfa2, OddsOfa3=0, OddsOfa4=0, OddsOfa5=0)
0312 | DebugBool(bool)
0331 | BoolToString(bool)
0341 | ColorIsDarkerThan(color1, color2)
0351 | WaitUntilColorStopsChanging(x, y)
0365 | ForcePixelColorChangeByClicking(x, y, lightestOrDarkest, checkboxStates=2)
0385 | Click(xCoord, yCoord, options="Left Mouse")
0422 | CloseWindowGracefully(title, text="", xClickToClose="", yClickToClose="")
0432 | CurrentTime(options="")
0476 | CurrentTimePlus(seconds)
0482 | TimePlus(one, two)
0493 | CurrentlyBefore(time)
0501 | CurrentlyAfter(time)
0522 | StartTimer()
0529 | ElapsedTime(StartTime)
0539 | PrettyTime(TimeToFormat)
0545 | IsMinimized(title="", text="")
0558 | IsMaximized(title="", text="")
0571 | CloseDifficultApps()
0635 | CloseDifficultAppsAllScreens()
0673 | EnsureDirExists(path)
0684 | ParentDir(fileOrFolder)
0693 | DirExist(dirPath)
0701 | ProgramFilesDir(relativePath)
0821 | SelfDestruct()
0836 | RunAhkAndBabysit(filename)
0860 | RunAhk(ahkFilename, params="", options="")
0871 | RunProgram(pathOrAppFilenameOrAppNickname)
0897 | GetProcesses()
0938 | GetCpuUsage( ProcNameOrPid )
0958 | GetRamUsage(ProcNameOrPid, Units="K")
0985 | IsFileEqual(filename1, filename2)
0994 | WaitFileExist(filename)
1003 | WaitFileNotExist(filename)
1014 | DualWinWait(successWin, failureWin)
1030 | TrayMsg(Title, Text="", TimeInSeconds=20, Icon=1, Options="")
1047 | CloseTrayTip(text)
1062 | GetOS()
1076 | DirGetSize(dirPath)
1085 | RepairPath(FullPath)
1094 | GetFolderName(FullPath)
1108 | Prompt(message, options="")
1119 | SexPanther(SexPanther="SexPanther")
1146 | UrlDownloadToVar(URL, Proxy="", ProxyBypass="")
1203 | ConcatWithSep(separator, text0, text1, text2="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text3="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text4="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text5="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text6="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text7="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text8="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text9="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text10="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text11="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text12="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text13="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text14="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ", text15="ZZZ-DEFAULT-BLANK-VAR-MSG-ZZZ")
1217 | IsVM(ComputerName="")
1226 | ForceReloadAll()
1233 | CloseAllAhks(excludeRegEx="", startAhkAfter="")
1245 | ZeroPad(number, length)
1262 | IsDirFileOrIndeterminate(path)
1274 | AddToTrace(var, t1="", t2="", t3="", t4="", t5="", t6="", t7="", t8="", t9="", t10="", t11="", t12="", t13="", t14="", t15="")
1282 | DeleteTraceFile()
1309 | EnsureEndsWith(string, char)
1318 | EnsureStartsWith(string, char)
1327 | SpiffyMute()
1342 | GetXmlElement(xml, pathToElement)
1359 | fatalIfNotThisPc(computerName)
1371 | ThreadedMsgbox(message)
1378 | LeadComputer()
1383 | MultiWinWait(successWin, successWinText, failureWin, failureWinText)
1397 | ClickButton(button)
1404 | AddDatetime(datetime, numberToAdd, unitsOfNumberToAdd)
1414 | Format(value, options)
1428 | InStrCount(String, Needle)
1435 | RegExMatchCount(Count_String, Count_Needle, Count_Type="", Count_SubPattern="")
1482 | RemoveLineEndings(page)
1487 | FormatDollar(amount)
1494 | MorningStatusAppend(header, item)
1501 | GetPath(file)
1515 | CommandPromptCopy()
1533 | NightlyStats(title, data)

;}
;{   FE.ahk

;Functions:
0001 | FE_load(autobuild=false)
0009 | FE_unload()
0014 | FE_addItem(id,parent,submenu,application,parameters,caption,hint,iconfile,iconindex,checked,filetype)
0045 | FE_deleteItem(id)
0067 | FE_int_copyItem(from,to)
0080 | FE_addCustomSetting(option,value)
0093 | FE_addDebugSetting(option,value)
0106 | FE_buildMenu()

;}
;{   FFAAS.ahk

;Functions:
0031 | _OnMessage()
0077 | Include(hwnd)
0081 | Exclude(hwnd)
0085 | _CheckComposition()
0094 | Enable(State=1)
0116 | _OffScreenPos()
0129 | SetAero(state=1)
0136 | SyncMode(Mode="ASync", Timer = 30)
0152 | Redraw(hWnd)
0164 | RedrawDB_Aero(hwnd)
0204 | DuplicateWindow(hwndSrc)
0263 | Copy(hwnd)
0279 | __msg(wParam, lParam, msg, hwnd)
0302 | FFAAS_WM_NCLBUTTONDOWN(wParam, lParam, msg, hwnd)
0331 | FFAAS_WM_ENTERSIZEMOVE(wParam, lParam, msg, hwnd)
0348 | FFAAS_WM_SIZING(wParam, lParam, msg, hwnd)
0369 | FFAAS_WM_EXITSIZEMOVE(wParam, lParam, msg, hwnd)
0407 | FFAAS_WM_NCCALCSIZE(wParam, lParam, msg, hwnd)
0447 | FFAAS_WM_WINDOWPOSCHANGING(wParam, lParam, msg, hwnd)
0476 | _FFAAS_CreateWindowEx(ExStyle, ClassName, WindowName, Style, x,y, w,h, hWndParent=0, hMenu=0, hInstance=0, lpParam=0)
0492 | _FFAAS_UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255, flag=4)
0515 | _FFAAS_GetWindowInfo(hwnd,ByRef wx,ByRef wy,ByRef ww,ByRef wh,ByRef cx,ByRef cy,ByRef cw,ByRef ch)
0531 | _FFAAS_RedrawWindow(hWnd, lprcUpdate=0, hrgnUpdate=0, flags=0x101)
0557 | _FFAAS_GetSystemMetrics(Index)
0561 | _FFAAS_IsComposition()
0569 | _FFAAS_WM_SETREDRAW(hWnd, state=1)
0575 | _FFAAS_ReleaseDC(hdc, hwnd=0)
0580 | _FFAAS_GetParent(hWnd)
0584 | _FFAAS_DeleteObject(hObject)
0589 | _FFAAS_BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster="")

;Labels:
9469 | _redraw
9593 | _FFAAS_EndScript

;}
;{   FGP.ahk

;Functions:
0009 | FGP_Init()
0038 | FGP_List(FilePath)
0064 | FGP_Name(PropNum)
0080 | FGP_Num(PropName)
0098 | FGP_Value(FilePath, Property)

;}
;{   File (3).ahk

;Functions:
0001 | File_Hash(sFile, SID = "CRC32")
0007 | File_AES(sFileFr, sFileTo, sPassword, SID = 256, bEncrypt = True)
0020 | File_ReadMemory(sFile, pBuffer, nSize = 512, bAppend = False)
0031 | File_WriteMemory(sFile, ByRef sBuffer, nSize = 0)
0043 | File_CreateFile(sFile, nCreate = 3, nAccess = 0x1F01FF, nShare = 3, bFolder = False)
0063 | File_DeleteFile(sFile)
0068 | File_ReadFile(hFile, pBuffer, nSize = 1024)
0074 | File_WriteFile(hFile, pBuffer, nSize = 1024)
0080 | File_GetFileSize(hFile)
0086 | File_SetEndOfFile(hFile)
0091 | File_SetFilePointer(hFile, nPos = 0, nMove = 0)
0101 | File_CloseHandle(Handle)
0107 | File_InternetOpen(sAgent = "AutoHotkey", nType = 4)
0114 | File_InternetOpenUrl(hInet, sUrl, nFlags = 0, pHeaders = 0)
0119 | File_InternetReadFile(hFile, pBuffer, nSize = 1024)
0125 | File_InternetWriteFile(hFile, pBuffer, nSize = 1024)
0131 | File_InternetSetFilePointer(hFile, nPos = 0, nMove = 0)
0136 | File_InternetCloseHandle(Handle)

;}
;{   File.ahk

;Functions:
0020 | File_Open(sType, sFile)
0039 | File_Read(hFile, ByRef bData, iLength = 0)
0062 | File_Write(hFile, ptrData, iLength)
0086 | File_Pointer(hFile, iOffset = 0, iMethod = -1)
0112 | File_Size(hFile)
0124 | File_Close(hFile)

;}
;{   FileExtract.ahk

;Functions:
0021 | FileExtract(Source, Dest, Flag=0)
0030 | FileExtract_(Source, Dest, Flag)
0065 | FileExtract_ToMem(Source, ByRef pData, ByRef DataSize)

;}
;{   FileHelperAndHash.ahk

;Functions:
0011 | File_Hash(sFile, SID = "CRC32")
0017 | File_AES(sFileFr, sFileTo, sPassword, SID = 256, bEncrypt = True)
0030 | File_ReadMemory(sFile, pBuffer, nSize = 512, bAppend = False)
0041 | File_WriteMemory(sFile, ByRef sBuffer, nSize = 0)
0053 | File_CreateFile(sFile, nCreate = 3, nAccess = 0x1F01FF, nShare = 3, bFolder = False)
0073 | File_DeleteFile(sFile)
0078 | File_ReadFile(hFile, pBuffer, nSize = 1024)
0084 | File_WriteFile(hFile, pBuffer, nSize = 1024)
0090 | File_GetFileSize(hFile)
0096 | File_SetEndOfFile(hFile)
0101 | File_SetFilePointer(hFile, nPos = 0, nMove = 0)
0111 | File_CloseHandle(Handle)
0117 | File_InternetOpen(sAgent = "AutoHotkey", nType = 4)
0124 | File_InternetOpenUrl(hInet, sUrl, nFlags = 0, pHeaders = 0)
0129 | File_InternetReadFile(hFile, pBuffer, nSize = 1024)
0135 | File_InternetWriteFile(hFile, pBuffer, nSize = 1024)
0141 | File_InternetSetFilePointer(hFile, nPos = 0, nMove = 0)
0146 | File_InternetCloseHandle(Handle)
0151 | Crypt_Hash(pData, nSize, SID = "CRC32", nInitial = 0)
0185 | Crypt_AES(pData, nSize, sPassword, SID = 256, bEncrypt = True)

;}
;{   FileHooks.ahk

;Functions:
0009 | initFileHooks(byref config)
0092 | CreateFileA(p1, p2, p3, p4, p5, p6, p7)
0102 | CreateFileW(p1, p2, p3, p4, p5, p6, p7)
0124 | OpenFile(p1, p2, p3)
0139 | buildfileslist()
0174 | SHGetFolderPathA(p1, p2, p3, p4, p5)
0189 | SHGetFolderPathW(p1, p2, p3, p4, p5)
0204 | SHGetSpecialFolderPathA(p1, p2, p3, p4)
0218 | SHGetSpecialFolderPathW(p1, p2, p3, p4)
0232 | SHGetKnownFolderPath(p1, p2, p3, p4)
0251 | FindFirstFileW(p1, p2)
0270 | FindFirstFileA(p1, p2)
0289 | PathFileExistsA(p1)
0296 | PathFileExistsW(p1)
0303 | GetModuleFileNameA(p1, p2, p3)
0313 | GetModuleFileNameW(p1, p2, p3)

;}
;{   FileInstallList.ahk

;Functions:
0018 | FileInstallList(FI_source, FI_dest, FI_overwrite="")

;}
;{   fileIsBinary.ahk

;Functions:
0004 | fileIsBinary(_filePath)

;}
;{   FindClick.ahk

;Functions:
0001 | FindClick(ImageFile="", Options="", ByRef FoundX="", ByRef FoundY="")

;Labels:
1584 | FindClickMenu
1585 | FindClickClose
1586 | FindClickEscape

;}
;{   FindFunc.ahk

;Functions:
0001 | FindFunc(Name)

;}
;{   FindLabel.ahk

;Functions:
0001 | FindLabel(Name)

;}
;{   FindMe.ahk

;Functions:
0498 | UnHTM( HTM )
0521 | ConvertEntities(HTML)
0539 | LV_SortArrow(h, c, d="")
0574 | TF_RegExReplaceInLines(Text, StartLine = 1, EndLine = 0, NeedleRegEx = "", Replacement = "")
0594 | TF_Count(String, Char)
0601 | TF_GetData(byref OW, byref Text, byref FileName)
0626 | TF_ReturnOutPut(OW, Text, FileName, TrimTrailing = 1, CreateNewFile = 0)
0678 | _MakeMatchList(Text, Start = 1, End = 0)
0864 | agrep(ByRef _haystack="", _pattern="", _ignoreCase=false, _invert=false, _lineMatch=false, _replace="")
0895 | Anchor(i, a = "", r = false)
0957 | Load_DDL_Values(_File, _Control="", _text="", _Max=5, _Section="Logs", _Keyname="LastSearch", _Default="Regex is Enabled. Case Insensitive")
0976 | DDL_Load(_file, _max=5, _section="Logs", _keyname="LastSearch", _default="Regex is Enabled. Case Insensitive")
0994 | DDL_Save(_file, _inputvar="", _max=5, _section="Logs", _keyname="LastSearch", _default="Regex is Enabled. Case Insensitive")
1010 | escIsPressed()

;Labels:
0113 | Guisize
3136 | ext
6148 | browse
8163 | listview
3176 | GuiContextMenu
6184 | editmenu
4207 | copymenu
7213 | selmenu
3222 | exportmenu
2227 | usereplace
7237 | replace
7273 | export
3323 | search
3435 | regexhelp
5650 | CreateNewFile
1021 | ExitLabel
1032 | Options
1041 | GuiClose

;}
;{   FixURI.ahk

;Functions:
0030 | FixURI(text,source,sourcedir="")

;}
;{   FloatToFraction.ahk

;Functions:
0036 | FloatToFraction(p_Input,p_MinRep=2,p_MinPatLen=1,p_MaxPatLen=15)

;}
;{   FlushDNS.ahk

;Functions:
0005 | FlushDNS()

;}
;{   Font.ahk

;Functions:
0017 | Font(HCtrl="", Font="", BRedraw=1)
0067 | Font_DrawText(Text, DC="", Font="", Flags="", Rect="")

;}
;{   Form Filler.ahk

;Functions:
0015 | FillForm(winTitle, formInfo, GetOrPost = "GET")

;Labels:
1589 | HideAllTooltips

;}
;{   Form.ahk

;Functions:
0087 | Form_Add(HParent, Ctrl, Txt="", Opt="", E1="",E2="",E3="",E4="",E5="",E6="",E7="")
0133 | Form_AutoSize( Hwnd, Delta="" )
0155 | Form_Destroy( HForm="")
0167 | Form_Default( HForm )
0176 | Form_Hide( HForm )
0197 | Form_GetNextPos( HForm, Options="", ByRef x="", ByRef y="")
0241 | Form_New(Options="", E1="", E2="", E3="", E4="", E5="")
0311 | Form_Parse(O, pQ, ByRef o1="",ByRef o2="",ByRef o3="",ByRef o4="",ByRef o5="",ByRef o6="",ByRef o7="",ByRef o8="", ByRef o9="", ByRef o10="", ByRef o11="", ByRef o12="", ByRef o13="", ByRef o14="", ByRef o15="")
0377 | Form_Show( HForm="", Options="", Title="" )
0393 | Form_Set(HForm, Options="", n="")
0471 | Form_addAhkControl(hParent, Ctrl, Txt, Opt )
0489 | Form_getFreeGuiNum()
0498 | Form_split(opt, s, ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="")
0506 | Form_setEsc(Hwnd, Type)

;Labels:
6513 | Form_setEsc

;}
;{   Format4Csv.ahk

;Functions:
0005 | Format4CSV(F4C_String)

;}
;{   FormatHRESULT.ahk

;Functions:
0001 | FormatHRESULT(hr)

;}
;{   formatTickCount.ahk

;Functions:
0001 | FormatTickCount(ms)

;}
;{   FreeImage.ahk

;Functions:
0053 | FreeImage_FoxInit(isInit=True)
0061 | FreeImage_FoxGetDllPath(DllName="FreeImage.dll")
0075 | FreeImage_FoxPalleteIndex70White(hImage)
0080 | FreeImage_FoxGetTransIndexNum(hImage)
0087 | FreeImage_FoxGetPallete(hImage)
0097 | FreeImage_FoxGetRGBi(StartAdress=2222, ColorIndexNum=1, GetColor="R")
0108 | FreeImage_FoxSetRGBi(StartAdress=2222, ColorIndexNum=1, SetColor="R", Value=255)
0122 | FreeImage_Initialise()
0126 | FreeImage_DeInitialise()
0130 | FreeImage_GetVersion()
0134 | FreeImage_GetCopyrightMessage()
0141 | FreeImage_Allocate(width=100, height=100, bpp=32, red_mask=0xFF000000, green_mask=0x00FF0000, blue_mask=0x0000FF00)
0145 | FreeImage_Load(ImPath)
0149 | FreeImage_Save(hImage, ImPath, OutExt=-1, ImgArg=0)
0156 | FreeImage_Clone(hImage)
0160 | FreeImage_UnLoad(hImage)
0167 | FreeImage_GetImageType(hImage)
0171 | FreeImage_GetColorsUsed(hImage)
0175 | FreeImage_GetBPP(hImage)
0179 | FreeImage_GetWidth(hImage)
0183 | FreeImage_GetHeight(hImage)
0187 | FreeImage_GetLine(hImage)
0191 | FreeImage_GetPitch(hImage)
0195 | FreeImage_GetDIBSize(hImage)
0199 | FreeImage_GetPalette(hImage)
0203 | FreeImage_GetDotsPerMeterX(hImage)
0207 | FreeImage_GetDotsPerMeterY(hImage)
0211 | FreeImage_SetDotsPerMeterX(hImage, DPMx)
0215 | FreeImage_SetDotsPerMeterY(hImage, DPMy)
0219 | FreeImage_GetInfoHeader(hImage)
0223 | FreeImage_GetInfo(hImage)
0227 | FreeImage_GetColorType(hImage)
0231 | FreeImage_GetRedMask(hImage)
0235 | FreeImage_GetGreenMask(hImage)
0239 | FreeImage_GetBlueMask(hImage)
0243 | FreeImage_GetTransparencyCount(hImage)
0247 | FreeImage_GetTransparencyTable(hImage)
0251 | FreeImage_SetTransparencyTable(hImage, hTransTable, count=256)
0255 | FreeImage_SetTransparent(hImage, isEnable=True)
0259 | FreeImage_IsTransparent(hImage)
0263 | FreeImage_HasBackgroundColor(hImage)
0267 | FreeImage_GetBackgroundColor(hImage)
0290 | FreeImage_GetFileType(ImPath)
0297 | FreeImage_GetBits(hImage)
0301 | FreeImage_GetScanLine(hImage, iScanline)
0305 | FreeImage_GetPixelIndex(hImage, xPos, yPos)
0313 | FreeImage_SetPixelIndex(hImage, xPos, yPos, nIndex)
0319 | FreeImage_GetPixelColor(hImage, xPos, yPos)
0337 | FreeImage_ConvertTo4Bits(hImage)
0341 | FreeImage_ConvertTo8Bits(hImage)
0345 | FreeImage_ConvertToGreyscale(hImage)
0349 | FreeImage_ConvertToStandardType(hImage, bScaleLinear=True)
0353 | FreeImage_ColorQuantize(hImage, quantize=0)
0357 | FreeImage_Threshold(hImage, TT=0)
0364 | FreeImage_OpenMemory(hMemory, size)
0368 | FreeImage_CloseMemory(hMemory)
0372 | FreeImage_TellMemory(hMemory)
0375 | FreeImage_AcquireMemory(hMemory, byref BufAdr, byref BufSize)
0382 | FreeImage_SaveToMemory(FIF,hImage, hMemory, Flags)
0388 | FreeImage_RotateClassic(hImage, angle)
0395 | FreeImage_Copy(hImage, nLeft, nTop, nRight, nBottom)
0399 | FreeImage_Paste(hImageDst, hImageSrc, nLeft, nTop, nAlpha)

;}
;{   FS.ahk

;Functions:
0002 | FS_Exists(path)
0008 | FS_FileExists(fileName)
0015 | FS_IsFile(fileName)
0021 | FS_DirExists(dirName)
0028 | FS_DirectoryExists(dirName)
0034 | FS_IsDirectory(dirName)
0040 | FS_FileCreate(fileName, encoding="")
0060 | FS_CreateFile(fileName, encoding="")
0066 | FS_MkDir(dirName)
0076 | FS_DirectoryCreate(dirName)
0082 | FS_CreateDirectory(dirName)
0088 | FS_CreateDir(dirName)
0094 | FS_DirCreate(dirName)
0099 | FS_FileCount(pattern)
0109 | FS_ShortcutCreate(TargetFileName, ShortcutDirectory, Description = "", recreate = false)
0127 | FS_ShortcutRemove(TargetFileName, ShortcutDirectory, Description = "")
0138 | FS_StartupShortcutCreate(TargetFileName, Description = "", recreate = false)
0144 | FS_StartupShortcutRemove(TargetFileName, Description = "")
0149 | FS_DesktopShortcutCreate(TargetFileName, Description = "", recreate = false)
0154 | FS_DesktopShortcutRemove(TargetFileName, Description = "")

;}
;{   ftp.ahk

;Functions:
0008 | FTP_CreateDirectory(hConnect,DirName)
0017 | FTP_RemoveDirectory(hConnect,DirName)
0026 | FTP_SetCurrentDirectory(hConnect,DirName)
0035 | FTP_PutFile(hConnect,LocalFile, NewRemoteFile="", Flags=0)
0055 | FTP_GetFile(hConnect,RemoteFile, NewFile="", Flags=0)
0077 | FTP_GetFileSize(hConnect,FileName, Flags=0)
0098 | FTP_DeleteFile(hConnect,FileName)
0107 | FTP_RenameFile(hConnect,Existing, New)
0116 | FTP_Open(Server, Port=21, Username=0, Password=0 ,Proxy="", ProxyBypass="")
0161 | FTP_CloseSocket(hConnect)
0165 | FTP_Close()
0173 | FTP_GetFileInfo(ByRef @FindData, InfoName)
0254 | FTP_FileTimeToStr(FileTime)
0267 | FTP_FindFirstFile(hConnect, SearchFile, ByRef @FindData)
0284 | FTP_FindNextFile(hEnum, ByRef @FindData)
0292 | FTP_GetCurrentDirectory(hConnect,ByRef DirName)

;}
;{   FTPv2.ahk

;Functions:
0019 | FTPv2( AsyncMode=0 , Proxy = "" , ProxyBypass = "")
0044 | __New( AsyncMode=0 , Proxy = "" , ProxyBypass = "")
0092 | Open(Server, Username=0, Password=0)
0130 | GetCurrentDirectory()
0157 | SetCurrentDirectory(DirName)
0181 | CreateDirectory(DirName)
0205 | RemoveDirectory(DirName)
0215 | OpenFile(FileName,Write = 0)
0272 | InternetWriteFile(LocalFile, NewRemoteFile="", FnProgress = "")
0352 | InternetReadFile(RemoteFile, NewLocalFile = "", FnProgress = "")
0399 | ShowProgress()
0439 | PutFile(LocalFile, NewRemoteFile="", Flags=0)
0480 | GetFile(RemoteFile, NewFile="", Flags=0)
0521 | GetFileSize(FileName, Flags=0)
0565 | DeleteFile(FileName)
0590 | RenameFile(Existing, New)
0612 | CloseHandle()
0621 | __Delete()
0644 | FindFirstFile(SearchFile)
0676 | FindNextFile()
0705 | GetFileInfo(ByRef @FindData)
0741 | FileTimeToStr(FileTime)
0755 | GetModuleErrorText(errNr)
0778 | FTP_Status(wParam,lParam)
0790 | FTP_Callback(hInternet, dwContext, dwInternetStatus, lpvStatusInformation, dwStatusInformationLength)
0870 | FTP_TestFunction()

;}
;{   Functions.ahk

;Functions:
0008 | Functions()
0012 | IfBetween(ByRef var, LowerBound, UpperBound)
0016 | IfNotBetween(ByRef var, LowerBound, UpperBound)
0020 | IfIn(ByRef var, MatchList)
0024 | IfNotIn(ByRef var, MatchList)
0028 | IfContains(ByRef var, MatchList)
0032 | IfNotContains(ByRef var, MatchList)
0036 | IfIs(ByRef var, type)
0040 | IfIsNot(ByRef var, type)
0045 | ControlGet(Cmd, Value = "", Control = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
0049 | ControlGetFocus(WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
0053 | ControlGetText(Control = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
0057 | DriveGet(Cmd, Value = "")
0061 | DriveSpaceFree(Path)
0065 | EnvGet(EnvVarName)
0069 | FileGetAttrib(Filename = "")
0073 | FileGetShortcut(LinkFile, ByRef OutTarget = "", ByRef OutDir = "", ByRef OutArgs = "", ByRef OutDescription = "", ByRef OutIcon = "", ByRef OutIconNum = "", ByRef OutRunState = "")
0076 | FileGetSize(Filename = "", Units = "")
0080 | FileGetTime(Filename = "", WhichTime = "")
0084 | FileGetVersion(Filename = "")
0088 | FileRead(Filename)
0092 | FileReadLine(Filename, LineNum)
0096 | FileSelectFile(Options = "", RootDir = "", Prompt = "", Filter = "")
0100 | FileSelectFolder(StartingFolder = "", Options = "", Prompt = "")
0104 | FormatTime(YYYYMMDDHH24MISS = "", Format = "")
0108 | GetKeyState(WhichKey , Mode = "")
0112 | GuiControlGet(Subcommand = "", ControlID = "", Param4 = "")
0116 | ImageSearch(ByRef OutputVarX, ByRef OutputVarY, X1, Y1, X2, Y2, ImageFile)
0119 | IniRead(Filename, Section, Key, Default = "")
0123 | Input(Options = "", EndKeys = "", MatchList = "")
0127 | InputBox(Title = "", Prompt = "", HIDE = "", Width = "", Height = "", X = "", Y = "", Font = "", Timeout = "", Default = "")
0131 | MouseGetPos(ByRef OutputVarX = "", ByRef OutputVarY = "", ByRef OutputVarWin = "", ByRef OutputVarControl = "", Mode = "")
0134 | PixelGetColor(X, Y, RGB = "")
0138 | PixelSearch(ByRef OutputVarX, ByRef OutputVarY, X1, Y1, X2, Y2, ColorID, Variation = "", Mode = "")
0141 | Random(Min = "", Max = "")
0145 | RegRead(RootKey, SubKey, ValueName = "")
0149 | Run(Target, WorkingDir = "", Mode = "")
0153 | SoundGet(ComponentType = "", ControlType = "", DeviceNumber = "")
0157 | SoundGetWaveVolume(DeviceNumber = "")
0161 | StatusBarGetText(Part = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
0165 | SplitPath(ByRef InputVar, ByRef OutFileName = "", ByRef OutDir = "", ByRef OutExtension = "", ByRef OutNameNoExt = "", ByRef OutDrive = "")
0168 | StringGetPos(ByRef InputVar, SearchText, Mode = "", Offset = "")
0172 | StringLeft(ByRef InputVar, Count)
0176 | StringLen(ByRef InputVar)
0180 | StringLower(ByRef InputVar, T = "")
0184 | StringMid(ByRef InputVar, StartChar, Count , L = "")
0188 | StringReplace(ByRef InputVar, SearchText, ReplaceText = "", All = "")
0192 | StringRight(ByRef InputVar, Count)
0196 | StringTrimLeft(ByRef InputVar, Count)
0200 | StringTrimRight(ByRef InputVar, Count)
0204 | StringUpper(ByRef InputVar, T = "")
0208 | SysGet(Subcommand, Param3 = "")
0212 | Transform(Cmd, Value1, Value2 = "")
0216 | WinGet(Cmd = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
0220 | WinGetActiveTitle()
0224 | WinGetClass(WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
0228 | WinGetText(WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
0232 | WinGetTitle(WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")

;}
;{   Func_IniSettingsEditor_v6.ahk

;Functions:
0156 | IniSettingsEditor(ProgName,IniFile,OwnedBy = 0,DisableGui = 0)
0556 | GuiIniSettingsEditorAnchor(ctrl, a, draw = false)

;Labels:
6467 | ExitSettings
7478 | BtnBrowseKeyValue
8532 | BtnDefaultValue
2537 | GuiIniSettingsEditorSize

;}
;{   GDI.hooks.ahk

;Functions:
0010 | ExtTextOutA(p1, p2, p3, p4, p5, p6, p7, p8)
0019 | TextOutA(p1, p2, p3, p4, p5)

;}
;{   Gdip.ahk

;Functions:
0069 | UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255)
0129 | BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster="")
0168 | StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster="")
0201 | SetStretchBltMode(hdc, iStretchMode=4)
0218 | SetImage(hwnd, hBitmap)
0276 | SetSysColorToControl(hwnd, SysColor=15)
0305 | Gdip_BitmapFromScreen(Screen=0, Raster="")
0357 | Gdip_BitmapFromHWND(hwnd)
0380 | CreateRectF(ByRef RectF, x, y, w, h)
0399 | CreateRect(ByRef Rect, x, y, w, h)
0415 | CreateSizeF(ByRef SizeF, w, h)
0431 | CreatePointF(ByRef PointF, x, y)
0451 | CreateDIBSection(w, h, hdc="", bpp=32, ByRef ppvBits=0)
0491 | PrintWindow(hwnd, hdc, Flags=0)
0507 | DestroyIcon(hIcon)
0514 | PaintDesktop(hdc)
0521 | CreateCompatibleBitmap(hdc, w, h)
0537 | CreateCompatibleDC(hdc=0)
0565 | SelectObject(hdc, hgdiobj)
0582 | DeleteObject(hObject)
0597 | GetDC(hwnd=0)
0618 | GetDCEx(hwnd, flags=0, hrgnClip=0)
0639 | ReleaseDC(hdc, hwnd=0)
0657 | DeleteDC(hdc)
0670 | Gdip_LibraryVersion()
0684 | Gdip_LibrarySubVersion()
0704 | Gdip_BitmapFromBRA(ByRef BRAFromMemIn, File, Alternate=0)
0762 | Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
0786 | Gdip_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r)
0820 | Gdip_DrawEllipse(pGraphics, pPen, x, y, w, h)
0847 | Gdip_DrawBezier(pGraphics, pPen, x1, y1, x2, y2, x3, y3, x4, y4)
0882 | Gdip_DrawArc(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
0915 | Gdip_DrawPie(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
0936 | Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2)
0960 | Gdip_DrawLines(pGraphics, pPen, Points)
0987 | Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
1015 | Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r)
1051 | Gdip_FillPolygon(pGraphics, pBrush, Points, FillMode=0)
1081 | Gdip_FillPie(pGraphics, pBrush, x, y, w, h, StartAngle, SweepAngle)
1110 | Gdip_FillEllipse(pGraphics, pBrush, x, y, w, h)
1130 | Gdip_FillRegion(pGraphics, pBrush, Region)
1148 | Gdip_FillPath(pGraphics, pBrush, Path)
1176 | Gdip_DrawImagePointsRect(pGraphics, pBitmap, Points, sx="", sy="", sw="", sh="", Matrix=1)
1255 | Gdip_DrawImage(pGraphics, pBitmap, dx="", dy="", dw="", dh="", sx="", sy="", sw="", sh="", Matrix=1)
1314 | Gdip_SetImageAttributesColorMatrix(Matrix)
1342 | Gdip_GraphicsFromImage(pBitmap)
1359 | Gdip_GraphicsFromHDC(hdc)
1374 | Gdip_GetDC(pGraphics)
1390 | Gdip_ReleaseDC(pGraphics, hdc)
1410 | Gdip_GraphicsClear(pGraphics, ARGB=0x00ffffff)
1428 | Gdip_BlurBitmap(pBitmap, Blur)
1471 | Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality=75)
1562 | Gdip_GetPixel(pBitmap, x, y)
1579 | Gdip_SetPixel(pBitmap, x, y, ARGB)
1593 | Gdip_GetImageWidth(pBitmap)
1608 | Gdip_GetImageHeight(pBitmap)
1626 | Gdip_GetImageDimensions(pBitmap, ByRef Width, ByRef Height)
1635 | Gdip_GetDimensions(pBitmap, ByRef Width, ByRef Height)
1642 | Gdip_GetImagePixelFormat(pBitmap)
1660 | Gdip_GetDpiX(pGraphics)
1668 | Gdip_GetDpiY(pGraphics)
1675 | Gdip_GetImageHorizontalResolution(pBitmap)
1681 | Gdip_GetImageVerticalResolution(pBitmap)
1687 | Gdip_BitmapSetResolution(pBitmap, dpix, dpiy)
1692 | Gdip_CreateBitmapFromFile(sFile, IconNumber=1, IconSize="")
1763 | Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette=0)
1771 | Gdip_CreateHBITMAPFromBitmap(pBitmap, Background=0xffffffff)
1777 | Gdip_CreateBitmapFromHICON(hIcon)
1783 | Gdip_CreateHICONFromBitmap(pBitmap)
1789 | Gdip_CreateBitmap(Width, Height, Format=0x26200A)
1795 | Gdip_CreateBitmapFromClipboard()
1813 | Gdip_SetBitmapToClipboard(pBitmap)
1831 | Gdip_CloneBitmapArea(pBitmap, x, y, w, h, Format=0x26200A)
1846 | Gdip_CreatePen(ARGB, w)
1852 | Gdip_CreatePenFromBrush(pBrush, w)
1858 | Gdip_BrushCreateSolid(ARGB=0xff000000)
1920 | Gdip_BrushCreateHatch(ARGBfront, ARGBback, HatchStyle=0)
1926 | Gdip_CreateTextureBrush(pBitmap, WrapMode=1, x=0, y=0, w="", h="")
1945 | Gdip_CreateLineBrush(x1, y1, x2, y2, ARGB1, ARGB2, WrapMode=1)
1960 | Gdip_CreateLineBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode=1, WrapMode=1)
1967 | Gdip_CloneBrush(pBrush)
1976 | Gdip_DeletePen(pPen)
1981 | Gdip_DeleteBrush(pBrush)
1986 | Gdip_DisposeImage(pBitmap)
1991 | Gdip_DeleteGraphics(pGraphics)
1996 | Gdip_DisposeImageAttributes(ImageAttr)
2001 | Gdip_DeleteFont(hFont)
2006 | Gdip_DeleteStringFormat(hFormat)
2011 | Gdip_DeleteFontFamily(hFamily)
2016 | Gdip_DeleteMatrix(Matrix)
2024 | Gdip_TextToGraphics(pGraphics, Text, Options, Font="Arial", Width="", Height="", Measure=0)
2108 | Gdip_DrawString(pGraphics, sString, hFont, hFormat, pBrush, ByRef RectF)
2131 | Gdip_MeasureString(pGraphics, sString, hFont, hFormat, ByRef RectF)
2160 | Gdip_SetStringFormatAlign(hFormat, Align)
2174 | Gdip_StringFormatCreate(Format=0, Lang=0)
2186 | Gdip_FontCreate(hFamily, Size, Style=0)
2192 | Gdip_FontFamilyCreate(Font)
2215 | Gdip_CreateAffineMatrix(m11, m12, m21, m22, x, y)
2221 | Gdip_CreateMatrix()
2233 | Gdip_CreatePath(BrushMode=0)
2239 | Gdip_AddPathEllipse(Path, x, y, w, h)
2244 | Gdip_AddPathPolygon(Path, Points)
2259 | Gdip_DeletePath(Path)
2273 | Gdip_SetTextRenderingHint(pGraphics, RenderingHint)
2286 | Gdip_SetInterpolationMode(pGraphics, InterpolationMode)
2296 | Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
2303 | Gdip_SetCompositingMode(pGraphics, CompositingMode=0)
2312 | Gdip_Startup()
2323 | Gdip_Shutdown(pToken)
2335 | Gdip_RotateWorldTransform(pGraphics, Angle, MatrixOrder=0)
2340 | Gdip_ScaleWorldTransform(pGraphics, x, y, MatrixOrder=0)
2345 | Gdip_TranslateWorldTransform(pGraphics, x, y, MatrixOrder=0)
2350 | Gdip_ResetWorldTransform(pGraphics)
2355 | Gdip_GetRotatedTranslation(Width, Height, Angle, ByRef xTranslation, ByRef yTranslation)
2370 | Gdip_GetRotatedDimensions(Width, Height, Angle, ByRef RWidth, ByRef RHeight)
2396 | Gdip_ImageRotateFlip(pBitmap, RotateFlipType=1)
2407 | Gdip_SetClipRect(pGraphics, x, y, w, h, CombineMode=0)
2412 | Gdip_SetClipPath(pGraphics, Path, CombineMode=0)
2418 | Gdip_ResetClip(pGraphics)
2423 | Gdip_GetClipRegion(pGraphics)
2430 | Gdip_SetClipRegion(pGraphics, Region, CombineMode=0)
2437 | Gdip_CreateRegion()
2443 | Gdip_DeleteRegion(Region)
2452 | Gdip_LockBits(pBitmap, x, y, w, h, ByRef Stride, ByRef Scan0, ByRef BitmapData, LockMode = 3, PixelFormat = 0x26200a)
2466 | Gdip_UnlockBits(pBitmap, ByRef BitmapData)
2475 | Gdip_SetLockBitPixel(ARGB, Scan0, x, y, Stride)
2482 | Gdip_GetLockBitPixel(Scan0, x, y, Stride)
2489 | Gdip_PixelateBitmap(pBitmap, ByRef pBitmapOut, BlockSize)
2577 | Gdip_ToARGB(A, R, G, B)
2584 | Gdip_FromARGB(ARGB, ByRef A, ByRef R, ByRef G, ByRef B)
2594 | Gdip_AFromARGB(ARGB)
2601 | Gdip_RFromARGB(ARGB)
2608 | Gdip_GFromARGB(ARGB)
2615 | Gdip_BFromARGB(ARGB)
2622 | StrGetB(Address, Length=-1, Encoding=0)

;}
;{   GDIPlusHelper.ahk

;Functions:
0020 | FormatHexNumber(_value, _digitNb)
0046 | Bin2Hex(ByRef @hexString, ByRef @bin, _byteNb=0)
0082 | Hex2Bin(ByRef @bin, _hex, _byteNb=0)
0166 | SetNextUInt(ByRef @struct, _value, _bReset=false)
0190 | GetNextUInt(ByRef @struct, _bReset=false)
0212 | SetNextByte(ByRef @struct, _value, _bReset=false)
0232 | GetNextByte(ByRef @struct, _bReset=false)
0258 | GetInteger(ByRef @source, _offset = 0, _bIsSigned = false, _size = 4)
0280 | SetInteger(ByRef @dest, _integer, _offset = 0, _size = 4)
0292 | GetUnicodeString(ByRef @unicodeString, _ansiString)
0310 | GetAnsiStringFromUnicodePointer(_unicodeStringPt)
0333 | DumpDWORDs(ByRef @bin, _byteNb, _bExtended=false)
0343 | DumpDWORDsByAddr(_binAddr, _byteNb, _bExtended=false)
0579 | GDIplus_Start()
0617 | GDIplus_Stop()
0627 | GDIplus_LoadBitmap(ByRef @bitmap, _fileName)
0644 | GDIplus_LoadImage(ByRef @image, _fileName)
0661 | GDIplus_LoadBitmapFromClipboard(ByRef @bitmap)
0697 | GDIplus_SaveImage(_image, _fileName, ByRef @clsidEncoder, ByRef @encoderParams)
0719 | GDIplus_GetEncoderCLSID(ByRef @encoderCLSID, _mimeType)
0829 | GDIplus_InitEncoderParameters(ByRef @encoderParameters, _paramCount)
0840 | GDIplus_AddEncoderParameter(ByRef @encoderParameters, _categoryGUID, ByRef @value)

;}
;{   GDIplusWrapper.ahk

;Functions:
0165 | GDIplus_Start()
0203 | GDIplus_Stop()
0213 | GDIplus_LoadBitmap(ByRef @bitmap, _fileName)
0230 | GDIplus_LoadImage(ByRef @image, _fileName)
0247 | GDIplus_LoadBitmapFromClipboard(ByRef @bitmap)
0300 | GDIplus_CaptureScreenRectangle(ByRef @bitmap, _x=0, _y=0, _w=0, _h=0, _hwndWindow=0, _bWholeWindow=false)
0390 | GDIplus_SaveImage(_image, _fileName, ByRef @clsidEncoder, ByRef @encoderParams)
0413 | GDIplus_DisposeImage(_image)
0420 | GDIplus_GetImageDimension(_image, ByRef @imageWidth, ByRef @imageHeight)
0440 | GDIplus_CloneBitmapArea(ByRef @croppedImage, _image, _x, _y, _w, _h)
0463 | GDIplus_GetEncoderCLSID(ByRef @encoderCLSID, _mimeType)
0573 | GDIplus_InitEncoderParameters(ByRef @encoderParameters, _paramCount)
0584 | GDIplus_AddEncoderParameter(ByRef @encoderParameters, _categoryGUID, ByRef @value)

;Labels:
4287 | LoadBitmapFromClipboard_CleanUp
7381 | CaptureScreenRectangle_CleanUp

;}
;{   gdiplus_outlinedtext.ahk

;Functions:
0165 | Gdip_AddString(Path, sString,fontName, options,stringFormat=0x4000)
0201 | Gdip_DrawPath(pGraphics, pPen, Path)
0206 | Gdip_SetLineJoin(pPen, linejoin=2)

;Labels:
0685 | Exit

;}
;{   Gdip_AddPathBeziers.ahk

;Functions:
0015 | Gdip_AddPathBeziers(pPath, Points)
0026 | Gdip_AddPathBezier(pPath, x1, y1, x2, y2, x3, y3, x4, y4)
0040 | Gdip_AddPathLines(pPath, Points)
0051 | Gdip_AddPathLine(pPath, x1, y1, x2, y2)
0056 | Gdip_AddPathArc(pPath, x, y, w, h, StartAngle, SweepAngle)
0060 | Gdip_AddPathPie(pPath, x, y, w, h, StartAngle, SweepAngle)
0064 | Gdip_StartPathFigure(pPath)
0068 | Gdip_ClosePathFigure(pPath)
0081 | Gdip_DrawPath(pGraphics, pPen, pPath)
0085 | Gdip_WidenPath(pPath, pPen, Matrix=0, Flatness=1)
0089 | Gdip_ClonePath(pPath)

;}
;{   Gdip_All (2).ahk

;Functions:
0069 | UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255)
0129 | BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster="")
0168 | StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster="")
0201 | SetStretchBltMode(hdc, iStretchMode=4)
0218 | SetImage(hwnd, hBitmap)
0276 | SetSysColorToControl(hwnd, SysColor=15)
0305 | Gdip_BitmapFromScreen(Screen=0, Raster="")
0357 | Gdip_BitmapFromHWND(hwnd)
0380 | CreateRectF(ByRef RectF, x, y, w, h)
0399 | CreateRect(ByRef Rect, x, y, w, h)
0415 | CreateSizeF(ByRef SizeF, w, h)
0431 | CreatePointF(ByRef PointF, x, y)
0451 | CreateDIBSection(w, h, hdc="", bpp=32, ByRef ppvBits=0)
0491 | PrintWindow(hwnd, hdc, Flags=0)
0507 | DestroyIcon(hIcon)
0514 | PaintDesktop(hdc)
0521 | CreateCompatibleBitmap(hdc, w, h)
0537 | CreateCompatibleDC(hdc=0)
0565 | SelectObject(hdc, hgdiobj)
0582 | DeleteObject(hObject)
0597 | GetDC(hwnd=0)
0618 | GetDCEx(hwnd, flags=0, hrgnClip=0)
0639 | ReleaseDC(hdc, hwnd=0)
0657 | DeleteDC(hdc)
0670 | Gdip_LibraryVersion()
0683 | Gdip_LibrarySubVersion()
0703 | Gdip_BitmapFromBRA(ByRef BRAFromMemIn, File, Alternate=0)
0761 | Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
0785 | Gdip_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r)
0819 | Gdip_DrawEllipse(pGraphics, pPen, x, y, w, h)
0846 | Gdip_DrawBezier(pGraphics, pPen, x1, y1, x2, y2, x3, y3, x4, y4)
0881 | Gdip_DrawArc(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
0914 | Gdip_DrawPie(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
0935 | Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2)
0959 | Gdip_DrawLines(pGraphics, pPen, Points)
0986 | Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
1014 | Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r)
1049 | Gdip_FillPolygon(pGraphics, pBrush, Points, FillMode=0)
1079 | Gdip_FillPie(pGraphics, pBrush, x, y, w, h, StartAngle, SweepAngle)
1108 | Gdip_FillEllipse(pGraphics, pBrush, x, y, w, h)
1128 | Gdip_FillRegion(pGraphics, pBrush, Region)
1146 | Gdip_FillPath(pGraphics, pBrush, Path)
1174 | Gdip_DrawImagePointsRect(pGraphics, pBitmap, Points, sx="", sy="", sw="", sh="", Matrix=1)
1253 | Gdip_DrawImage(pGraphics, pBitmap, dx="", dy="", dw="", dh="", sx="", sy="", sw="", sh="", Matrix=1)
1312 | Gdip_SetImageAttributesColorMatrix(Matrix)
1340 | Gdip_GraphicsFromImage(pBitmap)
1357 | Gdip_GraphicsFromHDC(hdc)
1372 | Gdip_GetDC(pGraphics)
1388 | Gdip_ReleaseDC(pGraphics, hdc)
1408 | Gdip_GraphicsClear(pGraphics, ARGB=0x00ffffff)
1426 | Gdip_BlurBitmap(pBitmap, Blur)
1469 | Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality=75)
1560 | Gdip_GetPixel(pBitmap, x, y)
1577 | Gdip_SetPixel(pBitmap, x, y, ARGB)
1591 | Gdip_GetImageWidth(pBitmap)
1606 | Gdip_GetImageHeight(pBitmap)
1624 | Gdip_GetImageDimensions(pBitmap, ByRef Width, ByRef Height)
1633 | Gdip_GetDimensions(pBitmap, ByRef Width, ByRef Height)
1640 | Gdip_GetImagePixelFormat(pBitmap)
1658 | Gdip_GetDpiX(pGraphics)
1666 | Gdip_GetDpiY(pGraphics)
1674 | Gdip_GetImageHorizontalResolution(pBitmap)
1682 | Gdip_GetImageVerticalResolution(pBitmap)
1690 | Gdip_BitmapSetResolution(pBitmap, dpix, dpiy)
1697 | Gdip_CreateBitmapFromFile(sFile, IconNumber=1, IconSize="")
1770 | Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette=0)
1780 | Gdip_CreateHBITMAPFromBitmap(pBitmap, Background=0xffffffff)
1788 | Gdip_CreateBitmapFromHICON(hIcon)
1796 | Gdip_CreateHICONFromBitmap(pBitmap)
1804 | Gdip_CreateBitmap(Width, Height, Format=0x26200A)
1812 | Gdip_CreateBitmapFromClipboard()
1832 | Gdip_SetBitmapToClipboard(pBitmap)
1852 | Gdip_CloneBitmapArea(pBitmap, x, y, w, h, Format=0x26200A)
1869 | Gdip_CreatePen(ARGB, w)
1877 | Gdip_CreatePenFromBrush(pBrush, w)
1885 | Gdip_BrushCreateSolid(ARGB=0xff000000)
1947 | Gdip_BrushCreateHatch(ARGBfront, ARGBback, HatchStyle=0)
1955 | Gdip_CreateTextureBrush(pBitmap, WrapMode=1, x=0, y=0, w="", h="")
1974 | Gdip_CreateLineBrush(x1, y1, x2, y2, ARGB1, ARGB2, WrapMode=1)
1989 | Gdip_CreateLineBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode=1, WrapMode=1)
1998 | Gdip_CloneBrush(pBrush)
2008 | Gdip_DeletePen(pPen)
2015 | Gdip_DeleteBrush(pBrush)
2022 | Gdip_DisposeImage(pBitmap)
2029 | Gdip_DeleteGraphics(pGraphics)
2036 | Gdip_DisposeImageAttributes(ImageAttr)
2043 | Gdip_DeleteFont(hFont)
2050 | Gdip_DeleteStringFormat(hFormat)
2057 | Gdip_DeleteFontFamily(hFamily)
2064 | Gdip_DeleteMatrix(Matrix)
2073 | Gdip_TextToGraphics(pGraphics, Text, Options, Font="Arial", Width="", Height="", Measure=0)
2157 | Gdip_DrawString(pGraphics, sString, hFont, hFormat, pBrush, ByRef RectF)
2180 | Gdip_MeasureString(pGraphics, sString, hFont, hFormat, ByRef RectF)
2209 | Gdip_SetStringFormatAlign(hFormat, Align)
2223 | Gdip_StringFormatCreate(Format=0, Lang=0)
2235 | Gdip_FontCreate(hFamily, Size, Style=0)
2241 | Gdip_FontFamilyCreate(Font)
2264 | Gdip_CreateAffineMatrix(m11, m12, m21, m22, x, y)
2270 | Gdip_CreateMatrix()
2282 | Gdip_CreatePath(BrushMode=0)
2288 | Gdip_AddPathEllipse(Path, x, y, w, h)
2293 | Gdip_AddPathPolygon(Path, Points)
2308 | Gdip_DeletePath(Path)
2322 | Gdip_SetTextRenderingHint(pGraphics, RenderingHint)
2335 | Gdip_SetInterpolationMode(pGraphics, InterpolationMode)
2345 | Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
2352 | Gdip_SetCompositingMode(pGraphics, CompositingMode=0)
2361 | Gdip_Startup()
2372 | Gdip_Shutdown(pToken)
2384 | Gdip_RotateWorldTransform(pGraphics, Angle, MatrixOrder=0)
2389 | Gdip_ScaleWorldTransform(pGraphics, x, y, MatrixOrder=0)
2394 | Gdip_TranslateWorldTransform(pGraphics, x, y, MatrixOrder=0)
2399 | Gdip_ResetWorldTransform(pGraphics)
2404 | Gdip_GetRotatedTranslation(Width, Height, Angle, ByRef xTranslation, ByRef yTranslation)
2419 | Gdip_GetRotatedDimensions(Width, Height, Angle, ByRef RWidth, ByRef RHeight)
2445 | Gdip_ImageRotateFlip(pBitmap, RotateFlipType=1)
2456 | Gdip_SetClipRect(pGraphics, x, y, w, h, CombineMode=0)
2461 | Gdip_SetClipPath(pGraphics, Path, CombineMode=0)
2467 | Gdip_ResetClip(pGraphics)
2472 | Gdip_GetClipRegion(pGraphics)
2479 | Gdip_SetClipRegion(pGraphics, Region, CombineMode=0)
2486 | Gdip_CreateRegion()
2492 | Gdip_DeleteRegion(Region)
2501 | Gdip_LockBits(pBitmap, x, y, w, h, ByRef Stride, ByRef Scan0, ByRef BitmapData, LockMode = 3, PixelFormat = 0x26200a)
2515 | Gdip_UnlockBits(pBitmap, ByRef BitmapData)
2524 | Gdip_SetLockBitPixel(ARGB, Scan0, x, y, Stride)
2531 | Gdip_GetLockBitPixel(Scan0, x, y, Stride)
2538 | Gdip_PixelateBitmap(pBitmap, ByRef pBitmapOut, BlockSize)
2626 | Gdip_ToARGB(A, R, G, B)
2633 | Gdip_FromARGB(ARGB, ByRef A, ByRef R, ByRef G, ByRef B)
2643 | Gdip_AFromARGB(ARGB)
2650 | Gdip_RFromARGB(ARGB)
2657 | Gdip_GFromARGB(ARGB)
2664 | Gdip_BFromARGB(ARGB)
2671 | StrGetB(Address, Length=-1, Encoding=0)

;}
;{   Gdip_All.ahk

;Functions:
0069 | UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255)
0129 | BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster="")
0168 | StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster="")
0201 | SetStretchBltMode(hdc, iStretchMode=4)
0218 | SetImage(hwnd, hBitmap)
0276 | SetSysColorToControl(hwnd, SysColor=15)
0305 | Gdip_BitmapFromScreen(Screen=0, Raster="")
0357 | Gdip_BitmapFromHWND(hwnd)
0380 | CreateRectF(ByRef RectF, x, y, w, h)
0399 | CreateRect(ByRef Rect, x, y, w, h)
0415 | CreateSizeF(ByRef SizeF, w, h)
0431 | CreatePointF(ByRef PointF, x, y)
0451 | CreateDIBSection(w, h, hdc="", bpp=32, ByRef ppvBits=0)
0491 | PrintWindow(hwnd, hdc, Flags=0)
0507 | DestroyIcon(hIcon)
0514 | PaintDesktop(hdc)
0521 | CreateCompatibleBitmap(hdc, w, h)
0537 | CreateCompatibleDC(hdc=0)
0565 | SelectObject(hdc, hgdiobj)
0582 | DeleteObject(hObject)
0597 | GetDC(hwnd=0)
0618 | GetDCEx(hwnd, flags=0, hrgnClip=0)
0639 | ReleaseDC(hdc, hwnd=0)
0657 | DeleteDC(hdc)
0670 | Gdip_LibraryVersion()
0683 | Gdip_LibrarySubVersion()
0703 | Gdip_BitmapFromBRA(ByRef BRAFromMemIn, File, Alternate=0)
0761 | Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
0785 | Gdip_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r)
0819 | Gdip_DrawEllipse(pGraphics, pPen, x, y, w, h)
0846 | Gdip_DrawBezier(pGraphics, pPen, x1, y1, x2, y2, x3, y3, x4, y4)
0881 | Gdip_DrawArc(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
0914 | Gdip_DrawPie(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
0935 | Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2)
0959 | Gdip_DrawLines(pGraphics, pPen, Points)
0988 | Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
1016 | Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r)
1051 | Gdip_FillPolygon(pGraphics, pBrush, Points, FillMode=0)
1081 | Gdip_FillPie(pGraphics, pBrush, x, y, w, h, StartAngle, SweepAngle)
1110 | Gdip_FillEllipse(pGraphics, pBrush, x, y, w, h)
1130 | Gdip_FillRegion(pGraphics, pBrush, Region)
1148 | Gdip_FillPath(pGraphics, pBrush, Path)
1176 | Gdip_DrawImagePointsRect(pGraphics, pBitmap, Points, sx="", sy="", sw="", sh="", Matrix=1)
1255 | Gdip_DrawImage(pGraphics, pBitmap, dx="", dy="", dw="", dh="", sx="", sy="", sw="", sh="", Matrix=1)
1314 | Gdip_SetImageAttributesColorMatrix(Matrix)
1342 | Gdip_GraphicsFromImage(pBitmap)
1359 | Gdip_GraphicsFromHDC(hdc)
1374 | Gdip_GetDC(pGraphics)
1390 | Gdip_ReleaseDC(pGraphics, hdc)
1410 | Gdip_GraphicsClear(pGraphics, ARGB=0x00ffffff)
1428 | Gdip_BlurBitmap(pBitmap, Blur)
1471 | Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality=75)
1562 | Gdip_GetPixel(pBitmap, x, y)
1579 | Gdip_SetPixel(pBitmap, x, y, ARGB)
1593 | Gdip_GetImageWidth(pBitmap)
1608 | Gdip_GetImageHeight(pBitmap)
1626 | Gdip_GetImageDimensions(pBitmap, ByRef Width, ByRef Height)
1635 | Gdip_GetDimensions(pBitmap, ByRef Width, ByRef Height)
1642 | Gdip_GetImagePixelFormat(pBitmap)
1660 | Gdip_GetDpiX(pGraphics)
1668 | Gdip_GetDpiY(pGraphics)
1676 | Gdip_GetImageHorizontalResolution(pBitmap)
1684 | Gdip_GetImageVerticalResolution(pBitmap)
1692 | Gdip_BitmapSetResolution(pBitmap, dpix, dpiy)
1699 | Gdip_CreateBitmapFromFile(sFile, IconNumber=1, IconSize="")
1772 | Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette=0)
1782 | Gdip_CreateHBITMAPFromBitmap(pBitmap, Background=0xffffffff)
1790 | Gdip_CreateBitmapFromHICON(hIcon)
1798 | Gdip_CreateHICONFromBitmap(pBitmap)
1806 | Gdip_CreateBitmap(Width, Height, Format=0x26200A)
1814 | Gdip_CreateBitmapFromClipboard()
1834 | Gdip_SetBitmapToClipboard(pBitmap)
1854 | Gdip_CloneBitmapArea(pBitmap, x, y, w, h, Format=0x26200A)
1871 | Gdip_CreatePen(ARGB, w)
1879 | Gdip_CreatePenFromBrush(pBrush, w)
1887 | Gdip_BrushCreateSolid(ARGB=0xff000000)
1949 | Gdip_BrushCreateHatch(ARGBfront, ARGBback, HatchStyle=0)
1957 | Gdip_CreateTextureBrush(pBitmap, WrapMode=1, x=0, y=0, w="", h="")
1976 | Gdip_CreateLineBrush(x1, y1, x2, y2, ARGB1, ARGB2, WrapMode=1)
1991 | Gdip_CreateLineBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode=1, WrapMode=1)
2000 | Gdip_CloneBrush(pBrush)
2010 | Gdip_DeletePen(pPen)
2017 | Gdip_DeleteBrush(pBrush)
2024 | Gdip_DisposeImage(pBitmap)
2031 | Gdip_DeleteGraphics(pGraphics)
2038 | Gdip_DisposeImageAttributes(ImageAttr)
2045 | Gdip_DeleteFont(hFont)
2052 | Gdip_DeleteStringFormat(hFormat)
2059 | Gdip_DeleteFontFamily(hFamily)
2066 | Gdip_DeleteMatrix(Matrix)
2075 | Gdip_TextToGraphics(pGraphics, Text, Options, Font="Arial", Width="", Height="", Measure=0)
2159 | Gdip_DrawString(pGraphics, sString, hFont, hFormat, pBrush, ByRef RectF)
2182 | Gdip_MeasureString(pGraphics, sString, hFont, hFormat, ByRef RectF)
2211 | Gdip_SetStringFormatAlign(hFormat, Align)
2225 | Gdip_StringFormatCreate(Format=0, Lang=0)
2237 | Gdip_FontCreate(hFamily, Size, Style=0)
2243 | Gdip_FontFamilyCreate(Font)
2266 | Gdip_CreateAffineMatrix(m11, m12, m21, m22, x, y)
2272 | Gdip_CreateMatrix()
2284 | Gdip_CreatePath(BrushMode=0)
2290 | Gdip_AddPathEllipse(Path, x, y, w, h)
2295 | Gdip_AddPathPolygon(Path, Points)
2310 | Gdip_DeletePath(Path)
2324 | Gdip_SetTextRenderingHint(pGraphics, RenderingHint)
2337 | Gdip_SetInterpolationMode(pGraphics, InterpolationMode)
2347 | Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
2354 | Gdip_SetCompositingMode(pGraphics, CompositingMode=0)
2363 | Gdip_Startup()
2374 | Gdip_Shutdown(pToken)
2386 | Gdip_RotateWorldTransform(pGraphics, Angle, MatrixOrder=0)
2391 | Gdip_ScaleWorldTransform(pGraphics, x, y, MatrixOrder=0)
2396 | Gdip_TranslateWorldTransform(pGraphics, x, y, MatrixOrder=0)
2401 | Gdip_ResetWorldTransform(pGraphics)
2406 | Gdip_GetRotatedTranslation(Width, Height, Angle, ByRef xTranslation, ByRef yTranslation)
2421 | Gdip_GetRotatedDimensions(Width, Height, Angle, ByRef RWidth, ByRef RHeight)
2447 | Gdip_ImageRotateFlip(pBitmap, RotateFlipType=1)
2458 | Gdip_SetClipRect(pGraphics, x, y, w, h, CombineMode=0)
2463 | Gdip_SetClipPath(pGraphics, Path, CombineMode=0)
2469 | Gdip_ResetClip(pGraphics)
2474 | Gdip_GetClipRegion(pGraphics)
2481 | Gdip_SetClipRegion(pGraphics, Region, CombineMode=0)
2488 | Gdip_CreateRegion()
2494 | Gdip_DeleteRegion(Region)
2503 | Gdip_LockBits(pBitmap, x, y, w, h, ByRef Stride, ByRef Scan0, ByRef BitmapData, LockMode = 3, PixelFormat = 0x26200a)
2517 | Gdip_UnlockBits(pBitmap, ByRef BitmapData)
2526 | Gdip_SetLockBitPixel(ARGB, Scan0, x, y, Stride)
2533 | Gdip_GetLockBitPixel(Scan0, x, y, Stride)
2540 | Gdip_PixelateBitmap(pBitmap, ByRef pBitmapOut, BlockSize)
2628 | Gdip_ToARGB(A, R, G, B)
2635 | Gdip_FromARGB(ARGB, ByRef A, ByRef R, ByRef G, ByRef B)
2645 | Gdip_AFromARGB(ARGB)
2652 | Gdip_RFromARGB(ARGB)
2659 | Gdip_GFromARGB(ARGB)
2666 | Gdip_BFromARGB(ARGB)
2673 | StrGetB(Address, Length=-1, Encoding=0)

;}
;{   Gdip_Ext.ahk

;Functions:
0001 | Gdip_TextToGraphics2(pGraphics, Text, Options, Font="Arial", Width="", Height="", Measure=0)
0075 | if(OutlineWidth1)
0118 | Gdip_AddPathString(Path, sString, FontFamily, Style, Size, ByRef RectF, Format)
0139 | Gdip_GetPathWorldBounds(Path)
0147 | Gdip_GetPathPoints(Path)
0165 | Gdip_GetPointCount(Path)
0171 | Gdip_DrawPath(pGraphics, pPen, pPath)
0189 | Gdip_AddPathBeziers(pPath, Points)
0200 | Gdip_AddPathBezier(pPath, x1, y1, x2, y2, x3, y3, x4, y4)
0215 | Gdip_AddPathLines(pPath, Points)
0226 | Gdip_AddPathLine(pPath, x1, y1, x2, y2)
0231 | Gdip_AddPathArc(pPath, x, y, w, h, StartAngle, SweepAngle)
0235 | Gdip_AddPathPie(pPath, x, y, w, h, StartAngle, SweepAngle)
0239 | Gdip_StartPathFigure(pPath)
0243 | Gdip_ClosePathFigure(pPath)
0247 | Gdip_WidenPath(pPath, pPen, Matrix=0, Flatness=1)
0251 | Gdip_ClonePath(pPath)

;}
;{   Gdip_ImageSearch.ahk

;Functions:
0192 | Gdip_SetBitmapTransColor(pBitmap,TransColor)
0404 | Gdip_LockedBitsSearch(hStride,hScan,hWidth,hHeight,nStride,nScan,nWidth,nHeight,ByRef x="",ByRef y="",sx1=0,sy1=0,sx2=0,sy2=0,Variation=0,sd=1)

;}
;{   GetAvailableFileName.ahk

;Functions:
0004 | GetAvailableFileName( GivenFileName, GivenPath = "", StartID = 1 )
0096 | GetAvailableFileName_fast( GivenFileName, GivenPath = "", StartID = 1 )

;}
;{   GetChildHWND.ahk

;Functions:
0001 | GetChildHWND(ParentHWND, ChildClassNN)

;}
;{   GetCommonPath.ahk

;Functions:
0003 | GetCommonPath( csidl )

;}
;{   GetControlsInfo.ahk

;Functions:
0037 | GetControlsInfo(p_WinTitle="",p_WinText="",p_ExcludeTitle="",p_ExcludeText="")

;}
;{   GetDnsAddress.ahk

;Functions:
0005 | GetDnsAddress()

;}
;{   GetEnv.ahk

;Functions:
0001 | GetEnv()

;}
;{   GetExeMachine.ahk

;Functions:
0005 | GetExeMachine(exepath)

;}
;{   GetFileEncoding.ahk

;Functions:
0007 | GetFileEncoding(File)

;}
;{   GetFileFolderSize.ahk

;Functions:
0018 | GetFileFolderSize(fPath)

;}
;{   GetFreeDriveSpace.ahk

;Functions:
0016 | GetFreeDriveSpace(fPath)

;}
;{   getInstalledPrograms.ahk

;Functions:
0001 | getInstalledPrograms()

;}
;{   GetListViewItems.ahk

;Functions:
0001 | GetListViewItemText(item_index, sub_index, ctrl_id, win_id)
0017 | GetListViewText(hListView, iItem, iSubItem, ByRef lpString, nMaxCount)
0112 | ExtractIntegerSL(ByRef pSource, pOffset = 0, pIsSigned = false, pSize = 4)
0127 | InsertIntegerSL(pInteger, ByRef pDest, pOffset = 0, pSize = 4)

;}
;{   GetModuleBaseAddr.ahk

;Functions:
0005 | GetModuleBaseAddr(ModuleName, ProcessID)

;}
;{   GetOSVersion.ahk

;Functions:
0039 | GetOSVersion(ByRef sOSName, ByRef bIs64 = 0, ByRef iServicePack = 0, ByRef bIsNT = 0, ByRef iBuildNumber = 0)

;}
;{   GetProcessModules.ahk

;Functions:
0005 | GetProcessModules(ProcessID)

;}
;{   GetProcessThreads.ahk

;Functions:
0005 | GetProcessThreads(ProcessID)

;}
;{   GetProcessWorkingDir.ahk

;Functions:
0005 | GetProcessWorkingDir(PID)

;}
;{   GetTcpTable.ahk

;Functions:
0005 | GetTcpTable()

;}
;{   GetThreadStartAddr.ahk

;Functions:
0005 | GetThreadStartAddr(ProcessID)

;}
;{   GetUdpTable.ahk

;Functions:
0005 | GetUdpTable()

;}
;{   GetWindowInfo.ahk

;Functions:
0018 | GetWindowInfo(HWND)

;}
;{   Get_Explorer_Paths.ahk

;Functions:
0025 | Explorer_GetPath(hwnd="")
0043 | Explorer_GetAll(hwnd="")
0047 | Explorer_GetSelected(hwnd="")
0052 | Explorer_GetWindow(hwnd="")
0069 | Explorer_Get(hwnd="",selection=false)

;}
;{   gl.ahk

;Functions:
0916 | glClearIndex(c)
0919 | glClearColor(red, green, blue, alpha)
0922 | glClear(mask)
0925 | glIndexMask(mask)
0928 | glColorMask(red, green, blue, alpha)
0931 | glAlphaFunc(func, ref)
0934 | glBlendFunc(sfactor, dfactor)
0937 | glLogicOp(opcode)
0940 | glCullFace(mode)
0943 | glFrontFace(mode)
0946 | glPointSize(size)
0949 | glLineWidth(width)
0952 | glLineStipple(factor, pattern)
0955 | glPolygonMode(face, mode)
0958 | glPolygonOffset(factor, units)
0961 | glPolygonStipple(byref mask)
0964 | glGetPolygonStipple(byref mask)
0967 | glEdgeFlag(flag)
0970 | glEdgeFlagv(byref flag)
0973 | glScissor(x, y, width, heigh)
0976 | glClipPlane(plane, equation)
0979 | glGetClipPlane(plane, equation)
0982 | glDrawBuffer(mode)
0985 | glReadBuffer(mode)
0988 | glEnable(cap)
0991 | glDisable(cap)
0994 | glIsEnabled(cap)
0997 | glEnableClientState(cap)
1000 | glDisableClientState(cap)
1003 | glGetBooleanv(pname, params)
1006 | glGetDoublev(pname, params)
1009 | glGetFloatv(pname, params)
1012 | glGetIntegerv(pname, params)
1015 | glPushAttrib(mask)
1018 | glPopAttrib()
1021 | glPushClientAttrib(mask)
1024 | glPopClientAttrib()
1027 | glRenderMode(mode)
1030 | glGetError()
1033 | glGetString(name)
1036 | glFinish()
1039 | glFlush()
1042 | glHint(target, mode)
1046 | glClearDepth(depth)
1049 | glDepthFunc(func)
1052 | glDepthMask(flag)
1055 | glDepthRange(near_val, far_val)
1059 | glClearAccum(red, green, blue, alpha)
1062 | glAccum(op, value)
1066 | glMatrixMode(mode)
1069 | glOrtho(left, right, bottom, top, near_val, far_val)
1072 | glFrustum(left, right, bottom, top, near_val, far_val)
1075 | glViewport(x, y, width, height)
1078 | glPushMatrix()
1081 | glPopMatrix()
1084 | glLoadIdentity()
1087 | glLoadMatrixd(byref m)
1090 | glLoadMatrixf(byref m)
1093 | glMultMatrixd(byref m)
1096 | glMultMatrixf(byref m)
1099 | glRotated(angle, x, y, z)
1102 | glRotatef(angle, x, y, z)
1105 | glScaled(x, y, z)
1108 | glScalef(x, y, z)
1111 | glTranslated(x, y, z)
1114 | glTranslatef(x, y, z)
1118 | glIsList(list)
1121 | glDeleteLists(list, range)
1124 | glGenLists(range)
1127 | glNewList(list, mode)
1130 | glEndList()
1133 | glCallList(list)
1136 | glCallLists(n, type, lists)
1139 | glListBase(base)
1143 | glBegin(mode)
1146 | glEnd()
1149 | glVertex2d(x, y)
1152 | glVertex2f(x, y)
1155 | glVertex2i(x, y)
1158 | glVertex2s(x, y)
1161 | glVertex3d(x, y, z)
1164 | glVertex3f(x, y, z)
1167 | glVertex3i(x, y, z)
1170 | glVertex3s(x, y, z)
1173 | glVertex4d(x, y, z, w)
1176 | glVertex4f(x, y, z, w)
1179 | glVertex4i(x, y, z, w)
1182 | glVertex4s(x, y, z, w)
1185 | glVertex2dv(byref v)
1188 | glVertex2fv(byref v)
1191 | glVertex2iv(byref v)
1194 | glVertex2sv(byref v)
1197 | glVertex3dv(byref v)
1200 | glVertex3fv(byref v)
1203 | glVertex3iv(byref v)
1206 | glVertex3sv(byref v)
1209 | glVertex4dv(byref v)
1212 | glVertex4fv(byref v)
1215 | glVertex4iv(byref v)
1218 | glVertex4sv(byref v)
1221 | glNormal3b(nx, ny, nz)
1224 | glNormal3d(nx, ny, nz)
1227 | glNormal3f(nx, ny, nz)
1230 | glNormal3i(nx, ny, nz)
1233 | glNormal3s(nx, ny, nz)
1236 | glNormal3bv(byref v)
1239 | glNormal3dv(byref v)
1242 | glNormal3fv(byref v)
1245 | glNormal3iv(byref v)
1248 | glNormal3sv(byref v)
1251 | glIndexd(c)
1254 | glIndexf(c)
1257 | glIndexi(c)
1260 | glIndexs(c)
1263 | glIndexub(c)
1266 | glIndexdv(byref c)
1269 | glIndexfv(byref c)
1272 | glIndexiv(byref c)
1275 | glIndexsv(byref c)
1278 | glIndexubv(byref c)
1281 | glColor3b(red, green, blue)
1284 | glColor3d(red, green, blue)
1287 | glColor3f(red, green, blue)
1290 | glColor3i(red, green, blue)
1293 | glColor3s(red, green, blue)
1296 | glColor3ub(red, green, blue)
1299 | glColor3ui(red, green, blue)
1302 | glColor3us(red, green, blue)
1305 | glColor4b(red, green, blue, alpha)
1308 | glColor4d(red, green, blue, alpha)
1311 | glColor4f(red, green, blue, alpha)
1314 | glColor4i(red, green, blue, alpha)
1317 | glColor4s(red, green, blue, alpha)
1320 | glColor4ub(red, green, blue, alpha)
1323 | glColor4ui(red, green, blue, alpha)
1326 | glColor4us(red, green, blue, alpha)
1329 | glColor3bv(byref v)
1332 | glColor3dv(byref v)
1335 | glColor3fv(byref v)
1338 | glColor3iv(byref v)
1341 | glColor3sv(byref v)
1344 | glColor3ubv(byref v)
1347 | glColor3uiv(byref v)
1350 | glColor3usv(byref v)
1353 | glColor4bv(byref v)
1356 | glColor4dv(byref v)
1359 | glColor4fv(byref v)
1362 | glColor4iv(byref v)
1365 | glColor4sv(byref v)
1368 | glColor4ubv(byref v)
1371 | glColor4uiv(byref v)
1374 | glColor4usv(byref v)
1377 | glTexCoord1d(s)
1380 | glTexCoord1f(s)
1383 | glTexCoord1i(s)
1386 | glTexCoord1s(s)
1389 | glTexCoord2d(s, t)
1392 | glTexCoord2f(s, t)
1395 | glTexCoord2i(s, t)
1398 | glTexCoord2s(s, t)
1401 | glTexCoord3d(s, t, r)
1404 | glTexCoord3f(s, t, r)
1407 | glTexCoord3i(s, t, r)
1410 | glTexCoord3s(s, t, r)
1413 | glTexCoord4d(s, t, r, q)
1416 | glTexCoord4f(s, t, r, q)
1419 | glTexCoord4i(s, t, r, q)
1422 | glTexCoord4s(s, t, r, q)
1425 | glTexCoord1dv(byref v)
1428 | glTexCoord1fv(byref v)
1431 | glTexCoord1iv(byref v)
1434 | glTexCoord1sv(byref v)
1437 | glTexCoord2dv(byref v)
1440 | glTexCoord2fv(byref v)
1443 | glTexCoord2iv(byref v)
1446 | glTexCoord2sv(byref v)
1449 | glTexCoord3dv(byref v)
1452 | glTexCoord3fv(byref v)
1455 | glTexCoord3iv(byref v)
1458 | glTexCoord3sv(byref v)
1461 | glTexCoord4dv(byref v)
1464 | glTexCoord4fv(byref v)
1467 | glTexCoord4iv(byref v)
1470 | glTexCoord4sv(byref v)
1473 | glRasterPos2d(x, y)
1476 | glRasterPos2f(x, y)
1479 | glRasterPos2i(x, y)
1482 | glRasterPos2s(x, y)
1485 | glRasterPos3d(x, y, z)
1488 | glRasterPos3f(x, y, z)
1491 | glRasterPos3i(x, y, z)
1494 | glRasterPos3s(x, y, z)
1497 | glRasterPos4d(x, y, z, w)
1500 | glRasterPos4f(x, y, z, w)
1503 | glRasterPos4i(x, y, z, w)
1506 | glRasterPos4s(x, y, z, w)
1509 | glRasterPos2dv(byref v)
1512 | glRasterPos2fv(byref v)
1515 | glRasterPos2iv(byref v)
1518 | glRasterPos2sv(byref v)
1521 | glRasterPos3dv(byref v)
1524 | glRasterPos3fv(byref v)
1527 | glRasterPos3iv(byref v)
1530 | glRasterPos3sv(byref v)
1533 | glRasterPos4dv(byref v)
1536 | glRasterPos4fv(byref v)
1539 | glRasterPos4iv(byref v)
1542 | glRasterPos4sv(byref v)
1545 | glRectd(x1, y1, x2, y2)
1548 | glRectf(x1, y1, x2, y2)
1551 | glRecti(x1, y1, x2, y2)
1554 | glRects(x1, y1, x2, y2)
1557 | glRectdv(byref v1, v2)
1560 | glRectfv(byref v1, v2)
1563 | glRectiv(byref v1, v2)
1566 | glRectsv(byref v1, v2)
1570 | glShadeModel(mode)
1573 | glLightf(light, pname, param)
1576 | glLighti(light, pname, param)
1579 | glLightfv(light, pname, params)
1582 | glLightiv(light, pname, params)
1585 | glGetLightfv(light, pname, params)
1588 | glGetLightiv(light, pname, params)
1591 | glLightModelf(pname, param)
1594 | glLightModeli(pname, param)
1597 | glLightModelfv(pname, params)
1600 | glLightModeliv(pname, params)
1603 | glMaterialf(face, pname, param)
1606 | glMateriali(face, pname, param)
1609 | glMaterialfv(face, pname, params)
1612 | glMaterialiv(face, pname, params)
1615 | glGetMaterialfv(face, pname, params)
1618 | glGetMaterialiv(face, pname, params)
1621 | glColorMaterial(face, mode)
1625 | glPixelZoom(xfactor, yfactor)
1628 | glPixelStoref(pname, param)
1631 | glPixelStorei(pname, param)
1634 | glPixelTransferf(pname, param)
1637 | glPixelTransferi(pname, param)
1640 | glPixelMapfv(map, mapsize, values)
1643 | glPixelMapuiv(map, mapsize, values)
1646 | glPixelMapusv(map, mapsize, values)
1649 | glGetPixelMapfv(map, values)
1652 | glGetPixelMapuiv(map, values)
1655 | glGetPixelMapusv(map, values)
1658 | glBitmap(width, height, xorig, yorig, xmove, ymove, bitmap)
1661 | glReadPixels(x, y, width, height, format, type, pixels)
1664 | glDrawPixels(width, height, format, type, pixels)
1667 | glCopyPixels(x, y, width, height, type)
1671 | glStencilFunc(func, ref, mask)
1674 | glStencilMask(mask)
1677 | glStencilOp(fail, zfail, zpass)
1680 | glClearStencil(s)
1684 | glTexGend(coord, pname, param)
1687 | glTexGenf(coord, pname, param)
1690 | glTexGeni(coord, pname, param)
1693 | glTexGendv(coord, pname, params)
1696 | glTexGenfv(coord, pname, params)
1699 | glTexGeniv(coord, pname, params)
1702 | glGetTexGendv(coord, pname, params)
1705 | glGetTexGenfv(coord, pname, params)
1708 | glGetTexGeniv(coord, pname, params)
1711 | glTexEnvf(target, pname, param)
1714 | glTexEnvi(target, pname, param)
1717 | glTexEnvfv(target, pname, params)
1720 | glTexEnviv(target, pname, params)
1723 | glGetTexEnvfv(target, pname, params)
1726 | glGetTexEnviv(target, pname, params)
1729 | glTexParameterf(target, pname, param)
1732 | glTexParameteri(target, pname, param)
1735 | glTexParameterfv(target, pname, params)
1738 | glTexParameteriv(target, pname, params)
1741 | glGetTexParameterfv(target, pname, param)
1744 | glGetTexParameteriv(target, pname, params)
1747 | glGetTexLevelParameterfv(target, level, pname, params)
1750 | glGetTexLevelParameteriv(target, level, pname, params)
1753 | glTexImage1D(target, level, internalFormat, width, border, format, type, pixels)
1756 | glTexImage2D(target, level, internalFormat, width, height, border, format, type, pixels)
1759 | glGetTexImage(target, level, format, type, pixels)
1763 | glMap1d(target, u1, u2, stride, order, points)
1766 | glMap1f(target, u1, u2, stride, order, points)
1769 | glMap2d(target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, points)
1772 | glMap2f(target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, points)
1775 | glGetMapdv(target, query, v)
1778 | glGetMapfv(target, query, v)
1781 | glGetMapiv(target, query, v)
1784 | glEvalCoord1d(u)
1787 | glEvalCoord1f(u)
1790 | glEvalCoord1dv(byref u)
1793 | glEvalCoord1fv(byref u)
1796 | glEvalCoord2d(u, v)
1799 | glEvalCoord2f(u, v)
1802 | glEvalCoord2dv(byref u)
1805 | glEvalCoord2fv(byref u)
1808 | glMapGrid1d(un, u1, u2)
1811 | glMapGrid1f(un, u1, u2)
1814 | glMapGrid2d(un, u1, u2, vn, v1, v2)
1817 | glMapGrid2f(un, u1, u2, vn, v1, v2)
1820 | glEvalPoint1(i)
1823 | glEvalPoint2(i, j)
1826 | glEvalMesh1(mode, i1, i2)
1829 | glEvalMesh2(mode, i1, i2, j1, j2)
1833 | glFogf(pname, param)
1836 | glFogi(pname, param)
1839 | glFogfv(pname, params)
1842 | glFogiv(pname, params)
1846 | glFeedbackBuffer(size, type, buffer)
1849 | glPassThrough(token)
1852 | glSelectBuffer(size, buffer)
1855 | glInitNames()
1858 | glLoadName(name)
1861 | glPushName(name)
1864 | glPopName()
1868 | glGenTextures(n, textures)
1871 | glDeleteTextures(n, texture)
1874 | glBindTexture(target, texture)
1877 | glPrioritizeTextures(n, textures, priorities)
1880 | glAreTexturesResident(n, textures, residences)
1883 | glIsTexture(texture)
1887 | glTexSubImage1D(target, level, xoffset, width, format, type, pixels)
1890 | glTexSubImage2D(target, level, xoffset, yoffset, width, height, format, type, pixels)
1893 | glCopyTexImage1D(target, level, internalformat, x, y, width, border)
1896 | glCopyTexImage2D(target, level, internalformat, x, y, width, height, border)
1899 | glCopyTexSubImage1D(target, level, xoffset, x, y, width)
1902 | glCopyTexSubImage2D(target, level, xoffset, yoffset, x, y, width, height)
1906 | glVertexPointer(size, type, stride, ptr)
1909 | glNormalPointer(type, stride, ptr)
1912 | glColorPointer(size, type, stride, ptr)
1915 | glIndexPointer(type, stride, ptr)
1918 | glTexCoordPointer(size, type, stride, ptr)
1921 | glEdgeFlagPointer(stride, ptr)
1924 | glGetPointerv(pname, params)
1927 | glArrayElement(i)
1930 | glDrawArrays(mode, first, count)
1933 | glDrawElements(mode, count, type, indices)
1936 | glInterleavedArrays(format, stride, pointer)
1940 | glDrawRangeElements(mode, start, end, count, type, indices)
1943 | glTexImage3D(target, level, internalFormat, width, height, depth, border, format, type, pixels)
1946 | glTexSubImage3D(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, pixel)
1949 | glCopyTexSubImage3D(target, level, xoffset, yoffset, zoffset, x, y, width, height)
1953 | glColorTable(target, internalformat, width, format, type, table)
1956 | glColorSubTable(target, start, count, format, type, data)
1959 | glColorTableParameteriv(target, pname, param)
1962 | glColorTableParameterfv(target, pname, param)
1965 | glCopyColorSubTable(target, start, x, y, width)
1968 | glCopyColorTable(target, internalformat, x, y, width)
1971 | glGetColorTable(target, format, type, table)
1974 | glGetColorTableParameterfv(target, pname, params)
1977 | glGetColorTableParameteriv(target, pname, params)
1980 | glBlendEquation(mode)
1983 | glBlendColor(red, green, blue, alpha)
1986 | glHistogram(target, width, internalformat, sink)
1989 | glResetHistogram(target)
1992 | glGetHistogram(target, reset, format, type, values)
1995 | glGetHistogramParameterfv(target, pname, params)
1998 | glGetHistogramParameteriv(target, pname, params)
2001 | glMinmax(target, internalformat, sink)
2004 | glResetMinmax(target)
2007 | glGetMinmax(target, reset, format, types, values)
2010 | glGetMinmaxParameterfv(target, pname, params)
2013 | glGetMinmaxParameteriv(target, pname, params)
2016 | glConvolutionFilter1D(target, internalformat, width, format, type, image)
2019 | glConvolutionFilter2D(target, internalformat, width, height, format, type, image)
2022 | glConvolutionParameterf(target, pname, params)
2025 | glConvolutionParameterfv(target, pname, params)
2028 | glConvolutionParameteri(target, pname, params)
2031 | glConvolutionParameteriv(target, pname, params)
2034 | glCopyConvolutionFilter1D(target, internalformat, x, y, width)
2037 | glCopyConvolutionFilter2D(target, internalformat, x, y, width, heigh)
2040 | glGetConvolutionFilter(target, format, type, image)
2043 | glGetConvolutionParameterfv(target, pname, params)
2046 | glGetConvolutionParameteriv(target, pname, params)
2049 | glSeparableFilter2D(target, internalformat, width, height, format, type, row, column)
2052 | glGetSeparableFilter(target, format, type, row, column, span)
2056 | glActiveTexture(texture)
2059 | glClientActiveTexture(texture)
2062 | glCompressedTexImage1D(target, level, internalformat, width, border, imageSize, data)
2065 | glCompressedTexImage2D(target, level, internalformat, width, height, border, imageSize, data)
2068 | glCompressedTexImage3D(target, level, internalformat, width, height, depth, border, imageSize, data)
2071 | glCompressedTexSubImage1D(target, level, xoffset, width, format, imageSize, data)
2074 | glCompressedTexSubImage2D(target, level, xoffset, yoffset, width, height, format, imageSize, data)
2077 | glCompressedTexSubImage3D(target, level, xoffset, yoffset, zoffset, width, height, depth, format, imageSize, data)
2080 | glGetCompressedTexImage(target, lod, img)
2083 | glMultiTexCoord1d(target, s)
2086 | glMultiTexCoord1dv(target, v)
2089 | glMultiTexCoord1f(target, s)
2092 | glMultiTexCoord1fv(target, v)
2095 | glMultiTexCoord1i(target, s)
2098 | glMultiTexCoord1iv(target, v)
2101 | glMultiTexCoord1s(target, s)
2104 | glMultiTexCoord1sv(target, v)
2107 | glMultiTexCoord2d(target, s, t)
2110 | glMultiTexCoord2dv(target, v)
2113 | glMultiTexCoord2f(target, s, t)
2116 | glMultiTexCoord2fv(target, v)
2119 | glMultiTexCoord2i(target, s, t)
2122 | glMultiTexCoord2iv(target, v)
2125 | glMultiTexCoord2s(target, s, t)
2128 | glMultiTexCoord2sv(target, v)
2131 | glMultiTexCoord3d(target, s, t, r)
2134 | glMultiTexCoord3dv(target, v)
2137 | glMultiTexCoord3f(target, s, t, r)
2140 | glMultiTexCoord3fv(target, v)
2143 | glMultiTexCoord3i(target, s, t, r)
2146 | glMultiTexCoord3iv(target, v)
2149 | glMultiTexCoord3s(target, s, t, r)
2152 | glMultiTexCoord3sv(target, v)
2155 | glMultiTexCoord4d(target, s, t, r, q)
2158 | glMultiTexCoord4dv(target, v)
2161 | glMultiTexCoord4f(target, s, t, r, q)
2164 | glMultiTexCoord4fv(target, v)
2167 | glMultiTexCoord4i(target, s, t, r, q)
2170 | glMultiTexCoord4iv(target, v)
2173 | glMultiTexCoord4s(target, s, t, r, q)
2176 | glMultiTexCoord4sv(target, v)
2179 | glLoadTransposeMatrixd(m[16])
2182 | glLoadTransposeMatrixf(m[16])
2185 | glMultTransposeMatrixd(m[16])
2188 | glMultTransposeMatrixf(m[16])
2191 | glSampleCoverage(value, invert)
2194 | glSamplePass(pass)

;}
;{   gl.hooks.ahk

;Functions:
0010 | InstallGlHook(function, GDI=False)

;}
;{   GlobalVarsScript.ahk

;Functions:
0001 | GlobalVarsScript(var="",size=102400,ByRef object=0)

;}
;{   glu.ahk

;Functions:
0039 | gluErrorStringWIN(errCode)
0047 | gluErrorString(errCode)
0053 | gluErrorUnicodeStringEXT(errCode)
0059 | gluGetString(name)
0065 | gluOrtho2D(left, right, bottom, top)
0071 | gluPerspective(fovy, aspect, zNear, zFar)
0077 | gluPickMatrix(x, y, width, height, viewport)
0083 | gluLookAt(eyex, eyey, eyez, centerx, centery, centerz, upx, upy, upz)
0089 | gluProject(objx, objy, objz, modelMatrix, projMatrix, viewport, byref winx, byref winy, byref winz)
0095 | gluUnProject(winx, winy, winz, modelMatrix, projMatrix, viewport, byref objx, byref objy, byref objz)
0101 | gluScaleImage(format, widthin, heightin, typein, datain, widthout, heightout, typeout, dataout)
0107 | gluBuild1DMipmaps(target, components, width, format, type, data)
0113 | gluBuild2DMipmaps(target, components, width, height, format, type, data)
0129 | gluNewQuadric()
0135 | gluDeleteQuadric(state)
0141 | gluQuadricNormals(quadObject, normals)
0147 | gluQuadricTexture(quadObject, textureCoords)
0153 | gluQuadricOrientation(quadObject, orientation)
0159 | gluQuadricDrawStyle(quadObject, drawStyle)
0165 | gluCylinder(qobj, baseRadius, topRadius, height, slices, stacks)
0171 | gluDisk(qobj, innerRadius, outerRadius, slices, loops)
0177 | gluPartialDisk(qobj, innerRadius, outerRadius, slices, loops, startAngle, sweepAngle)
0183 | gluSphere(qobj, radius, slices, stacks)
0189 | gluQuadricCallback(qobj, which, fn)
0195 | gluNewTess()
0201 | gluDeleteTess(tess)
0207 | gluTessBeginPolygon(tess, polygon_data)
0213 | gluTessBeginContour(tess)
0219 | gluTessVertex(tess, coords, data)
0225 | gluTessEndContour(tess)
0231 | gluTessEndPolygon(tess)
0237 | gluTessProperty(tess, which, value)
0243 | gluTessNormal(tess, x, y, z)
0249 | gluTessCallback(tess, which, fn)
0255 | gluGetTessProperty(tess, which, byref value)
0261 | gluNewNurbsRenderer()
0267 | gluDeleteNurbsRenderer(nobj)
0273 | gluBeginSurface(nobj)
0279 | gluBeginCurve(nobj)
0285 | gluEndCurve(nobj)
0291 | gluEndSurface(nobj)
0297 | gluBeginTrim(nobj)
0303 | gluEndTrim(nobj)
0309 | gluPwlCurve(nobj, count, array, stride, type)
0315 | gluNurbsCurve(nobj, nknots, knot, stride, ctlarray, order, type)
0321 | gluNurbsSurface(nobj, sknot_count, sknot, tknot_count, tknot, s_stride, t_stride, ctlarray, sorder, torder, type)
0327 | gluLoadSamplingMatrices(nobj, modelMatrix, projMatrix, viewport)
0333 | gluNurbsProperty(nobj, property, value)
0339 | gluGetNurbsProperty(nobj, property, byref value)
0345 | gluNurbsCallback(nobj, which, fn)

;}
;{   googl.ahk

;Functions:
0001 | googl(url)

;}
;{   GTranslate.ahk

;Functions:
0010 | __New()
0020 | Translate(str, lng)
0037 | getLangCode(Lang="")

;}
;{   guiAddonInfo.ahk

;Functions:
0023 | guiAddonInfo(SourceFile="")


;}
;{   guiCompile.ahk

;Functions:
0014 | guiCompile(SourceScriptFile="")

;}
;{   GuiCtl.ahk

;Functions:
0074 | SetFocus()

;}
;{   Guid (2).ahk

;Functions:
0006 | Guid_New()
0019 | Guid_FromStr(sGuid, ByRef VarOrAddress)
0036 | Guid_ToStr(ByRef VarOrAddress)

;}
;{   GUID.ahk

;Functions:
0001 | GUID_ToString(guid)
0008 | GUID_FromString(str, byRef mem)
0014 | GUID_IsGUIDString(str)
0019 | GUID_Create(byRef guid)

;}
;{   guiExplorer.ahk

;Functions:
0016 | guiExplorer(exploreDir)
0322 | loadTree(TreeRoot)
0335 | AddSubFoldersToTree(Folder, ParentItemID = 0)
0343 | getIcon(FilePath, ByRef ImageList)


;}
;{   guiOffscreenCheck.ahk

;Functions:
0001 | guiOffScreenCheck(hwnd)

;}
;{   GUIUniqueDefault().ahk

;Functions:
0003 | GUIUniqueDestroy(key = "")
0011 | GUIUniqueSingle(key = "")
0022 | GUIUniqueDefault(key = "", destroyMode = "")
0113 | MeasureText(text, ByRef Width, ByRef Height, fontName = "", fontOptions = "")

;}
;{   GuiWnd.ahk

;Functions:
0014 | __Delete()
0058 | Destroy()
0112 | Hide()
0118 | Minimize()
0124 | Maximize()
0130 | Restore()
0143 | SetAsDefault()
0158 | OnClose()
0212 | GWnd_Get(h)
0219 | GWnd_OnClose(h)
0224 | GWnd_OnEscape(h)

;Labels:
4171 | gwnd_exit

;}
;{   Help.ahk

;Functions:
0087 | setHTMLData(help_file)
0216 | help_onclick()
0236 | Ghelp_onclick()
0266 | Links_Pannel_onclick()
0274 | List_onclick(flag="")
0573 | RunAsAdmin()


;}
;{   HexToBin.ahk

;Functions:
0001 | HexToBin(ByRef bin,hex)

;}
;{   HIBYTE.ahk

;Functions:
0001 | HIBYTE(a)

;}
;{   HiEdit.ahk

;Functions:
0023 | HE_Add(HParent, X, Y, W, H, Style="", DllPath="")
0062 | HE_AutoIndent(hEdit, pState )
0093 | HE_CanPaste(hEdit,ClipboardFormat=0x1)
0103 | HE_CanRedo(hEdit)
0113 | HE_CanUndo(hEdit)
0126 | HE_CloseFile(hEdit, idx=-1)
0136 | HE_Clear(hEdit)
0152 | HE_CharFromPos(hEdit,X,Y)
0174 | HE_ConvertCase(hEdit, case="toggle")
0185 | HE_Copy(hEdit)
0194 | HE_Cut(hEdit)
0203 | HE_EmptyUndoBuffer(hEdit)
0221 | HE_FindText(hEdit, sText, cpMin=0, cpMax=-1, flags="")
0242 | HE_GetColors(hEdit)
0260 | HE_GetCurrentFile(hEdit)
0270 | HE_GetFileCount(hEdit)
0286 | HE_GetFileName(hEdit, idx=-1)
0297 | HE_GetFirstVisibleLine(hEdit)
0312 | HE_GetLastVisibleLine(hEdit)
0328 | HE_GetLine(hEdit,idx=-1)
0353 | HE_GetLineCount(hEdit)
0370 | HE_GetModify(hEdit, idx=-1)
0380 | HE_GetRedoData(hEdit, level)
0401 | HE_GetRect(hEdit,ByRef Left="",ByRef Top="",ByRef Right="",ByRef Bottom="")
0424 | HE_GetSel(hEdit, ByRef start_pos="@",ByRef end_pos="@")
0442 | HE_GetSelText(hEdit)
0454 | HE_GetTextLength(hEdit)
0468 | HE_GetTextRange(hEdit, min=0, max=-1)
0502 | HE_GetUndoData(hEdit, level)
0522 | HE_LineFromChar(hEdit, ich)
0538 | HE_LineIndex(hedit, idx=-1)
0554 | HE_LineLength(hEdit, idx=-1)
0569 | HE_LineNumbersBar( hEdit, state="show", linw=40, selw=10 )
0603 | HE_LineScroll(hEdit,xScroll=0,yScroll=0)
0612 | HE_NewFile(hEdit)
0629 | HE_OpenFile(hEdit, pFileName, flag=0)
0639 | HE_Paste(hEdit)
0661 | HE_PosFromChar(hEdit,CharIndex,ByRef X,ByRef Y)
0675 | HE_Redo(hEdit)
0687 | HE_ReloadFile(hEdit, idx=-1)
0700 | HE_ReplaceSel(hEdit, text="")
0718 | HE_SaveFile(hEdit, pFileName, idx=-1)
0751 | HE_Scroll(hEdit,Pages=0,Lines=0)
0807 | HE_ScrollCaret(hEdit)
0832 | HE_SetColors(hEdit, colors, fRedraw=true)
0870 | HE_SetCurrentFile(hEdit, idx)
0901 | HE_SetEvents(hEdit, Handler="", Events="selchange")
0938 | HE_SetFont(hEdit, pFont="")
0971 | HE_SetKeywordFile( pFile )
0983 | HE_SetModify(hEdit, Flag)
0996 | HE_SetSel(hEdit, nStart=0, nEnd=-1)
1010 | HE_SetTabWidth(hEdit, pWidth, pRedraw=true)
1023 | HE_SetTabsImageList(hEdit, pImg="")
1051 | HE_ShowFileList(hEdit, X=0, Y=0)
1063 | HE_Undo(hEdit)
1071 | HE_onNotify(wparam, lparam, msg, hwnd)
1112 | HE_writeFile(file,data)
1142 | HiEdit_add2Form(hParent, Txt, Opt)

;}
;{   HIWORD.ahk

;Functions:
0001 | HIWORD(a)

;}
;{   HL7.ahk

;Functions:
0017 | parse(p_HL7_Text)
0238 | Clean_HL7(p_HL7_Text, p_Array_Of_Delimiter_Needles, p_Escaped_Escape_Character)

;}
;{   HLink.ahk

;Functions:
0064 | HLink_onNotify(Wparam, Lparam, Msg, Hwnd)
0102 | HLink_add2Form(hParent, Txt, Opt)

;}
;{   HotkeyControl.ahk

;Functions:
0001 | HotkeyControl(QuotedVarName, GuiNameOrHwnd, ControlOptions="w180 h20", InitialText="", InitialTextColor="Gray")
0207 | HotkeyControl_GlobalVar(VarName)
0212 | HotkeyControl_UpdateVar(VarName, Value)


;}
;{   Hotstrings.ahk

;Functions:
0019 | hotstrings(k, a = "")

;}
;{   HPDF.ahk

;Functions:
0004 | HPDF_LinkAnnot_SetHighlightMode(ByRef annot,mode)
0015 | HPDF_LinkAnnot_SetBorderStyle(ByRef annot,width,dash_on,dash_off)
0019 | HPDF_TextAnnot_SetIcon(ByRef annot,icon)
0033 | HPDF_TextAnnot_SetOpened(ByRef annot,open)
0037 | HPDF_Annotation_SetBorderStyle(ByRef annot,subtype,width,dash_on,dash_off,dash_phase)
0055 | HPDF_Destination_SetXYZ(ByRef dst, left, top, zoom)
0059 | HPDF_Destination_SetFit(ByRef dst)
0063 | HPDF_Destination_SetFitH(ByRef dst, top)
0067 | HPDF_Destination_SetFitV(ByRef dst, left)
0071 | HPDF_Destination_SetFitR(ByRef dst, left, bottom, right, top)
0075 | HPDF_Destination_SetFitB(ByRef dst)
0079 | HPDF_Destination_SetFitBH(ByRef dst, top)
0083 | HPDF_Destination_SetFitBV(ByRef dst, top)
0093 | HPDF_LoadDLL(dll)
0097 | HPDF_UnloadDLL(hDll)
0102 | HPDF_New(user_error_fn,user_data)
0106 | HPDF_NewEx(user_error_fn,user_data)
0111 | HPDF_Free(ByRef hDoc)
0116 | HPDF_NewDoc(ByRef hDoc)
0121 | HPDF_FreeDoc(ByRef hDoc)
0125 | HPDF_FreeDocAll(ByRef hDoc)
0130 | HPDF_SaveToFile(ByRef hDoc, filename)
0135 | HPDF_HasDoc(ByRef hDoc)
0140 | HPDF_SetErrorHandler(ByRef hDoc, ByRef errorhandler)
0145 | HPDF_GetError(ByRef hDoc)
0150 | HPDF_ResetError(ByRef hDoc)
0157 | HPDF_SaveToStream(ByRef hDoc)
0162 | HPDF_GetStreamSize(ByRef hDoc)
0167 | HPDF_ReadFromStream(ByRef hDoc, ByRef buffer, ByRef buffer_size)
0172 | HPDF_ResetStream(ByRef hDoc)
0185 | HPDF_GetEncoder(ByRef hDoc, encoding_name)
0189 | HPDF_GetCurrentEncoder(ByRef hDoc)
0193 | HPDF_SetCurrentEncoder(ByRef hDoc, encoding_name)
0197 | HPDF_UseJPEncodings(ByRef hDoc)
0201 | HPDF_UseKREncodings(ByRef hDoc)
0205 | HPDF_UseCNSEncodings(ByRef hDoc)
0209 | HPDF_UseCNTEncodings(ByRef hDoc)
0216 | HPDF_AddPageLabel(ByRef hDoc, page_num, style, first_page, prefix)
0229 | HPDF_GetFont(ByRef hDoc, font_name, encoding_name)
0237 | HPDF_GetFont2(ByRef hDoc, ByRef font_name, encoding_name)
0246 | HPDF_LoadType1FontFromFile(ByRef hDoc, afmfilename, pfmfilename)
0250 | HPDF_LoadTTFontFromFile(ByRef hDoc, file_name, embedding)
0254 | HPDF_LoadTTFontFromFile2(ByRef hDoc, file_name, index, embedding)
0258 | HPDF_UseJPFonts(ByRef hDoc)
0262 | HPDF_UseKRFonts(ByRef hDoc)
0266 | HPDF_UseCNSFonts(ByRef hDoc)
0270 | HPDF_UseCNTFonts(ByRef hDoc)
0277 | HPDF_CreateOutline(ByRef hDoc, ByRef parent, title, ByRef encoder)
0294 | HPDF_LoadPngImageFromFile(ByRef hDoc, filename)
0302 | HPDF_LoadRawImageFromFile(ByRef hDoc, filename, width, height, color_space)
0312 | HPDF_LoadRawImageFromMem(ByRef hDoc, buf, width, height, color_space, bits_per_component)
0322 | HPDF_LoadJpegImageFromFile(ByRef hDoc, filename)
0326 | HPDF_SetInfoAttr(ByRef hDoc, type, value)
0340 | HPDF_GetInfoAttr(ByRef hDoc, type)
0358 | HPDF_SetPassword(ByRef hDoc, owner_passwd, user_passwd)
0362 | HPDF_SetPermission(ByRef hDoc, permission)
0372 | HPDF_SetEncryptionMode(ByRef hDoc, mode, key_len)
0381 | HPDF_SetCompressionMode(ByRef hDoc, mode)
0397 | HPDF_SetPagesConfiguration(ByRef hDoc, page_per_pages)
0401 | HPDF_SetPageLayout(ByRef hDoc, layout)
0405 | HPDF_GetPageLayout(ByRef hDoc)
0409 | HPDF_SetPageMode(ByRef hDoc, mode)
0420 | HPDF_GetPageMode(ByRef hDoc)
0424 | HPDF_SetOpenAction(ByRef hDoc, ByRef open_action)
0428 | HPDF_GetCurrentPage(ByRef hDoc)
0432 | HPDF_AddPage(ByRef hDoc)
0437 | HPDF_InsertPage(ByRef hDoc, ByRef target)
0445 | HPDF_Page_Arc(ByRef hPage, x, y, radius, ang1, ang2)
0449 | HPDF_Page_BeginText(ByRef hPage)
0453 | HPDF_Page_Circle(ByRef hPage, x, y, radius)
0457 | HPDF_Page_ClosePath(ByRef hPage)
0461 | HPDF_Page_ClosePathStroke(ByRef hPage)
0465 | HPDF_Page_ClosePathEofillStroke(ByRef hPage)
0469 | HPDF_Page_ClosePathFillStroke(ByRef hPage)
0473 | HPDF_Page_Concat(ByRef hPage, a, b, c, d, x, y)
0477 | HPDF_Page_CurveTo(ByRef hPage, x1, y1, x2, y2, x3, y3)
0481 | HPDF_Page_CurveTo2(ByRef hPage, x2, y2, x3, y3)
0485 | HPDF_Page_CurveTo3(ByRef hPage, x1, y1, x3, y3)
0489 | HPDF_Page_DrawImage(ByRef hPage, ByRef hImage, x, y, width, height)
0493 | HPDF_Page_Ellipse(ByRef hPage, x, y, x_radius, y_radius)
0497 | HPDF_Page_EndPath(ByRef hPage)
0501 | HPDF_Page_EndText(ByRef hPage)
0505 | HPDF_Page_Eofill(ByRef hPage)
0509 | HPDF_Page_EofillStroke(ByRef hPage)
0513 | HPDF_Page_ExecuteXObject(ByRef hPage, ByRef obj)
0517 | HPDF_Page_Fill(ByRef hPage)
0521 | HPDF_Page_FillStroke(ByRef hPage)
0525 | HPDF_Page_GRestore(ByRef hPage)
0529 | HPDF_Page_GSave(ByRef hPage)
0533 | HPDF_Page_LineTo(ByRef hPage, x, y)
0537 | HPDF_Page_MoveTextPos(ByRef hPage, x, y)
0541 | HPDF_Page_MoveTextPos2(ByRef hPage, x, y)
0545 | HPDF_Page_MoveTo(ByRef hPage, x, y)
0549 | HPDF_Page_MoveToNextLine(ByRef hPage)
0553 | HPDF_Page_Rectangle(ByRef hPage, x, y, width, height)
0557 | HPDF_Page_SetCharSpace(ByRef hPage, value)
0561 | HPDF_Page_SetCMYKFill(ByRef hPage, c, m, y, k)
0565 | HPDF_Page_SetCMYKStroke(ByRef hPage, c, m, y, k)
0569 | HPDF_Page_SetDash(ByRef hPage, ByRef dash_ptn, num_elem, phase)
0573 | HPDF_Page_SetExtGState(ByRef hPage, ByRef ext_gstate)
0577 | HPDF_Page_SetFontAndSize(ByRef hPage, ByRef font, size)
0581 | HPDF_Page_SetGrayFill(ByRef hPage, gray)
0585 | HPDF_Page_SetGrayStroke(ByRef hPage, gray)
0589 | HPDF_Page_SetHorizontalScalling(ByRef hPage, value)
0593 | HPDF_Page_SetLineCap(ByRef hPage, line_cap)
0604 | HPDF_Page_SetLineJoin(ByRef hPage, line_join)
0615 | HPDF_Page_SetLineWidth(ByRef hPage, line_width)
0619 | HPDF_Page_SetMiterLimit(ByRef hPage, miter_limit)
0623 | HPDF_Page_SetRGBFill(ByRef hPage, r, g, b)
0627 | HPDF_Page_SetRGBStroke(ByRef hPage, r, g, b)
0631 | HPDF_Page_SetTextLeading(ByRef hPage, value)
0635 | HPDF_Page_SetTextRenderingMode(ByRef hPage, mode)
0651 | HPDF_Page_SetTextRise(ByRef hPage, value)
0655 | HPDF_Page_SetWordSpace(ByRef hPage, value)
0659 | HPDF_Page_ShowText(ByRef hPage, text)
0663 | HPDF_Page_ShowTextNextLine(ByRef hPage, text)
0667 | HPDF_Page_ShowTextNextLineEx(ByRef hPage, word_space, char_space, text)
0671 | HPDF_Page_Stroke(ByRef hPage)
0675 | HPDF_Page_TextOut(ByRef hPage, xpos, ypos, text)
0679 | HPDF_Page_TextRect(ByRef hPage, left, top, right, bottom, text, align, ByRef len)
0691 | HPDF_Page_SetTextMatrix(ByRef hPage, a, b, c, d, x, y)
0699 | HPDF_Page_Clip(ByRef hPage)
0708 | print_grid(ByRef pdf, ByRef page,inc=5,stepsize=2,bigstep=2)
0833 | HPDF_Image_GetSize(ByRef image)
0837 | HPDF_Image_GetWidth(ByRef image)
0841 | HPDF_Image_GetHeight(ByRef image)
0845 | HPDF_Image_GetBitsPerComponent(ByRef image)
0849 | HPDF_Image_GetColorSpace(ByRef image)
0853 | HPDF_Image_SetColorMask(ByRef image, rmin, rmax, gmin, gmax, bmin, bmax)
0857 | HPDF_Image_SetMaskImage(ByRef image, ByRef mask_image)
0866 | HPDF_Outline_SetOpened(ByRef outline, opened)
0870 | HPDF_Outline_SetDestination(ByRef outline, ByRef dst)
0877 | HPDF_Page_SetWidth(ByRef hPage, value)
0881 | HPDF_Page_SetHeight(ByRef hPage, value)
0885 | HPDF_Page_SetSize(ByRef hPage, size, direction)
0910 | HPDF_Page_SetRotate(ByRef hPage, angle)
0914 | HPDF_Page_GetWidth(ByRef hPage)
0918 | HPDF_Page_GetHeight(ByRef hPage)
0922 | HPDF_Page_CreateDestination(ByRef hPage)
0926 | HPDF_Page_CreateTextAnnot(ByRef hPage, rect, text, encoder)
0930 | HPDF_Page_CreateLinkAnnot(ByRef hPage, ByRef rect, ByRef dst)
0934 | HPDF_Page_CreateURILinkAnnot(ByRef hPage, ByRef rect, uri)
0938 | HPDF_Page_TextWidth(ByRef hPage, text)
0942 | HPDF_Page_MeasureText(ByRef hPage, text, width, wordwrap, real_width)
0949 | HPDF_Page_GetGMode(ByRef hPage)
0953 | HPDF_Page_GetCurrentPos(ByRef hPage)
0957 | HPDF_Page_GetCurrentTextPos(ByRef hPage)
0961 | HPDF_Page_GetCurrentFont(ByRef hPage)
0965 | HPDF_Page_GetCurrentFontSize(ByRef hPage)
0969 | HPDF_Page_GetTransMatrix(ByRef hPage)
0973 | HPDF_Page_GetLineWidth(ByRef hPage)
0977 | HPDF_Page_GetLineCap(ByRef hPage)
0981 | HPDF_Page_GetLineJoin(ByRef hPage)
0985 | HPDF_Page_GetMiterLimit(ByRef hPage)
0989 | HPDF_Page_GetDash(ByRef hPage)
0993 | HPDF_Page_GetFlat(ByRef hPage)
0997 | HPDF_Page_GetCharSpace(ByRef hPage)
1001 | HPDF_Page_GetWordSpace(ByRef hPage)
1005 | HPDF_Page_GetHorizontalScalling(ByRef hPage)
1009 | HPDF_Page_GetTextLeading(ByRef hPage)
1013 | HPDF_Page_GetTextRenderingMode(ByRef hPage)
1017 | HPDF_Page_GetTextRise(ByRef hPage)
1021 | HPDF_Page_GetRGBFill(ByRef hPage)
1025 | HPDF_Page_GetRGBStroke(ByRef hPage)
1029 | HPDF_Page_GetCMYKFill(ByRef hPage)
1033 | HPDF_Page_GetCMYKStroke(ByRef hPage)
1037 | HPDF_Page_GetGrayFill(ByRef hPage)
1041 | HPDF_Page_GetGrayStroke(ByRef hPage)
1045 | HPDF_Page_GetStrokingColorSpace(ByRef hPage)
1049 | HPDF_Page_GetFillingColorSpace(ByRef hPage)
1053 | HPDF_Page_GetTextMatrix(ByRef hPage)
1057 | HPDF_Page_GetGStateDepth(ByRef hPage)
1061 | HPDF_Page_SetSlideShow(ByRef hPage, type, disp_time, trans_time)
1089 | HPDF_CreateRect(ByRef rect,left,bottom,right,top)
1097 | HPDF_ReadRect(ByRef rect,Byref left,Byref bottom,Byref right,Byref top)
1104 | HPDF_GetPoint(ByRef point, ByRef x, ByRef y)

;}
;{   hRes.ahk

;Functions:
0012 | ComputeResolutionCorrections(p2, p3)
0031 | _rect_setscale(scale="")
0050 | InitHighResHooks()
0064 | IDirectDraw_SetDisplayMode(p1, p2, p3, p4)
0077 | IDirect3DDevice_CreateMatrix(p1, p2)
0086 | IDirect3DDevice_Execute(p1, p2, p3, p4)
0110 | IDirect3DViewPort_SetViewPort(p1, p2)
0123 | IDirect3DViewPort_Clear(p1, p2, p3, p4)
0149 | IDirectDraw2_SetDisplayMode(p1, p2, p3, p4, p5, p6)
0166 | InitHighResHooks2(keep_aspect_ratio=True)
0184 | UpdateDevice2DrawPrimitieParamenters()
0194 | IDirect3DViewPort2_SetViewPort2(p1, p2)
0212 | IDirect3DViewPort2_Clear(p1, p2, p3, p4)
0239 | IDirectDraw4_SetDisplayMode(p1, p2, p3, p4, p5, p6)
0272 | InitHighResHooks3()
0293 | UpdateDevice3DrawPrimitieParamenters()
0304 | IDirect3DDevice3_DrawPrimitive(pIDirect3DDevice3, dptPrimitiveType, dwVertexTypeDesc, lpvVertices, dwVertexCount, dwFlags)
0342 | IDirect3DDevice3_DrawIndexedPrimitive(pIDirect3DDevice3, d3dptPrimitiveType, dwVertexTypeDesc, lpvVertices, dwVertexCount, lpwIndices, dwIndexCount, dwFlags)
0377 | IDirect3DDevice3_DrawIndexedPrimitiveStrided(p1, p2, p3, p4, p5, p6, p7, p8)
0383 | IDirect3DDevice3_DrawIndexedPrimitiveVB(p1, p2, p3, p4, p5, p6)
0392 | IDirect3DDevice3_DrawPrimitiveVB(p1, p2, p3, p4, p5, p6)
0400 | IDirect3DViewPort3_SetViewPort(p1, p2)
0407 | IDirect3DViewPort3_SetViewPort2(p1, p2)
0428 | IDirect3DViewport3_TransformVertices(p1, p2, p3, p4, p5)
0434 | IDirect3DViewPort3_Clear(p1, p2, p3, p4)
0452 | IDirect3DViewPort3_Clear2(p1, p2, p3, p4, p5, p6, p7)
0474 | initHighResHooks7()
0490 | IDirectDraw7_SetDisplayMode(p1, p2, p3, p4, p5, p6)
0511 | IDirect3DDevice7_SetViewPort(p1, p2)
0526 | IDirect3DDevice7_DrawPrimitive(pIDirect3DDevice7, dptPrimitiveType, dwVertexTypeDesc, lpvVertices, dwVertexCount, dwFlags)
0553 | IDirect3DDevice7_DrawPrimitiveVB(p1, p2, p3, p4, p5, p6)

;}
;{   httpQuery.ahk

;Functions:
0004 | httpQuery(byref Result, lpszUrl, POSTDATA="", HEADERS="")

;}
;{   HttpQueryInfo.ahk

;Functions:
0027 | HttpQueryInfo(URL, QueryInfoFlag=21, Proxy="", ProxyBypass="")

;}
;{   hwndHung.ahk

;Functions:
0001 | hwndHung(id)

;}
;{   Icon.ahk

;Functions:
0053 | Icon_Load(sBinFile, sResName, nWidth)
0090 | Icon_Destroy(hIcon)

;}
;{   IconEx.ahk

;Functions:
0050 | IconEx(StartFile="", Pos="", Settings="", GuiNum=69)
0117 | IconEx_onFilter(filter="")
0149 | IconEx_onPath()
0160 | IconEx_getFullName( Fn )
0170 | IconEx_onActivate(Wparam, Lparam, Msg, Hwnd)
0181 | IconEx_hasIcons( File )
0186 | IconEx_add2Combo( Item )
0194 | IconEx_scan( FileName = "" )
0268 | IconEx_scanFile( FileName="" )
0289 | IconEx_scanFolder( FolderName="" )
0338 | IconEx_addDrives()
0365 | IconEx_setStatus( s="" )
0371 | IconEx_onIconClick(e)
0407 | IconEx_anchor(c, a, r = false)
0423 | IconEx_setLV()
0435 | IconEx_exit()
0463 | IconEx_cfgGet( var, def="" )
0473 | IconEx_cfgSet( var, value )
0482 | IconEx_hkEnter()
0500 | IconEx_hkBackspace()
0516 | IconEx_ILAdd(hIL, FileName, IconNumber)
0526 | IconEx_ILCreate(InitialCount, GrowCount)
0534 | IconEx_defaultGui()

;Labels:
4145 | IconEx_onFilter
5155 | IconEx_onPath
5264 | IconEx_scanTimer
4401 | IconEx_onIconClick
1427 | IconEx_size
7457 | IconEx_close
7458 | IconEx_escape
8507 | IconEx_hkEnter
7511 | IconEx_hkBackspace

;}
;{   IDropTarget.ahk

;Functions:
0110 | RegisterDragDrop()
0120 | RevokeDragDrop()
0142 | __Delete()
0150 | QueryInterface(RIID, PPV)
0165 | AddRef()
0171 | Release()
0238 | DragLeave()

;}
;{   IE.ahk

;Functions:
0027 | IE_FangWei(ASK, ASW, AddPD="")
0049 | IE_InetOpen(Agent="IE8")
0056 | IE_InetClose()
0110 | IE_UrlEncode(String)
0129 | IE_uriEncode(str)
0146 | WININET_Init()
0151 | WININET_UnInit()
0156 | WININET_InternetOpenA(lpszAgent,dwAccessType=1,lpszProxyName=0,lpszProxyBypass=0,dwFlags=0)
0166 | WININET_InternetConnectA(hInternet,lpszServerName,nServerPort=80,lpszUsername="",lpszPassword="",dwService=3,dwFlags=0,dwContext=0)
0196 | WININET_HttpSendRequestA(hRequest,lpszHeaders="",lpOptional="")
0206 | WININET_InternetReadFile(hFile)
0228 | WININET_InternetCloseHandle(hInternet)
0234 | IE_New(url="", option="")
0254 | IE_quit()
0263 | IE_attach()
0285 | IE_term()
0292 | IE_Nav(URL="", timeout=30)
0307 | IE_tupian(show)
0316 | IE_daili(daili="")
0333 | IE_tanchu(daima, text="??", cishu=1)
0350 | IE_tanchu2(daima, text="??", cishu=1)

;}
;{   IE7_Dom.ahk

;Functions:
0002 | IE7_Get(title,url="http")
0028 | IE7_Navigate(parentWindow,url)
0043 | IE7_ExecuteJS(parentWindow, JS_to_Inject, VarNames_to_Return="")
0063 | IE7_readyState(parentWindow)
0085 | IE7_Quit(parentWindow)
0090 | IE7_New(url)
0100 | IE7_Click_Text(parentWindow,innerHTML)
0132 | IE7_Button_click(parentWindow,value)
0168 | IE7_Get_DOM(parentWindow,ID1)
0216 | IE7_Set_DOM(parentWindow,ID1,val="innerHTML")

;}
;{   IEL.ahk

;Functions:
0013 | IEL_new(url="", option="")
0030 | IEL_attach()
0053 | IEL_Nav(URL="", timeout=30)
0068 | IEL_tanchu(daima, text="??", cishu=1)
0085 | IEL_tanchu2(daima, text="??", cishu=1)
0111 | IEL_tupian(show)
0121 | IEL_daili(daili="")

;}
;{   IEReady.ahk

;Functions:
0038 | IEReady(hIESvr = 0)

;}
;{   Ignore.ahk

;Functions:
0003 | Ignore_GetPatterns(ignorefile)
0038 | Ignore_PatternTransform(patterns,baseDir)
0075 | Ignore_DirTree(dir,patterns)

;}
;{   IL.ahk

;Functions:
0001 | ImageList_Create(cx,cy,flags,cInitial,cGrow)
0005 | ImageList_Add(hIml, hbmImage, hbmMask="")
0009 | ImageList_AddIcon(hIml, hIcon)
0013 | ImageList_Remove(hIml, Pos=-1)
0018 | API_LoadImage(pPath, uType, cxDesired, cyDesired, fuLoad)
0022 | LoadIcon(Filename, IconNumber, IconSize)

;}
;{   ILButton.ahk

;Functions:
0037 | ILButton(HBtn, Images, Cx=16, Cy=16, Align="Left", Margin="1 1 1 1")

;}
;{   implode.ahk

;Functions:
0001 | implode(array, sep = "")

;}
;{   infogulchEncodings.ahk

;Functions:
0009 | Dec_XML(str)
0027 | Enc_XML(str, chars="")
0045 | Dec_Uri(str)
0054 | Enc_Uri(str)
0077 | Enc_Hex(x)
0088 | Dec_Hex(x)

;}
;{   ini.ahk

;Functions:
0315 | ini_getValue(ByRef _Content, _Section, _Key, _PreserveSpace = False)
0380 | ini_getKey(ByRef _Content, _Section, _Key)
0420 | ini_getSection(ByRef _Content, _Section)
0466 | ini_getAllValues(ByRef _Content, _Section = "", ByRef _count = "")
0514 | ini_getAllKeyNames(ByRef _Content, _Section = "", ByRef _count = "")
0560 | ini_getAllSectionNames(ByRef _Content, ByRef _count = "")
0620 | ini_replaceValue(ByRef _Content, _Section, _Key, _Replacement = "", _PreserveSpace = False)
0675 | ini_replaceKey(ByRef _Content, _Section, _Key, _Replacement = "")
0724 | ini_replaceSection(ByRef _Content, _Section, _Replacement = "")
0772 | ini_insertValue(ByRef _Content, _Section, _Key, _Value, _PreserveSpace = False)
0825 | ini_insertKey(ByRef _Content, _Section, _Key)
0872 | ini_insertSection(ByRef _Content, _Section, _Keys = "")
0951 | ini_load(ByRef _Content, _Path = "", _convertNewLine = false)
1031 | ini_save(ByRef _Content, _Path = "", _convertNewLine = true, _overwrite = true)
1075 | ini_buildPath(ByRef _path)
1305 | ini_mergeKeys(ByRef _Content, ByRef _source, _updateMode = 1)
1464 | ini_exportToGlobals(ByRef _Content, _CreateIndexVars = false, _Prefix = "ini", _Seperator = "_", _SectionSpaces = "", _PreserveSpace = False)
1586 | Ini_Read(ByRef _OutputVar, ByRef _Content, _Section, _Key, _Default = "ERROR")
1637 | Ini_Write(_Value, ByRef _Content, _Section, _Key)
1680 | Ini_Delete(ByRef _Content, _Section, _Key = "")

;}
;{   IniParser.ahk

;Functions:
0011 | IniParser(sFile)

;}
;{   IniSettingsEditor.ahk

;Functions:
0001 | IniSettingsEditor(ProgName,IniFile,OwnedBy = 0,DisableGui = 0, HelpText = 0)
0405 | GuiIniSettingsEditorAnchor(ctrl, a, draw = false)

;}
;{   iniWrapper.ahk

;Functions:
0024 | iniWrapper_loadAllSections(ByRef iniVar)
0066 | iniWrapper_loadSection(ByRef iniVar, section)
0099 | iniWrapper_unloadAllSections(ByRef iniVar)
0147 | iniWrapper_unloadSection(ByRef iniVar, section)
0184 | iniWrapper_saveAllSections(ByRef iniVar)
0231 | iniWrapper_saveSection(ByRef iniVar, section)

;}
;{   InjectAhkDll.ahk

;Functions:
0008 | InjectAhkDll(PID,dll="AutoHotkey.dll",script=0)

;}
;{   InputThread.ahk

;Functions:
0009 | __New(ProfileID, CallbackPtr)
0049 | UpdateBinding(ControlGUID, boPtr)
0062 | SetDetectionState(state)
0077 | __New(callback)
0082 | UpdateBinding(ControlGUID, bo)
0095 | SetDetectionState(state)
0106 | RemoveBinding(ControlGUID)
0118 | KeyEvent(ControlGUID, e)
0124 | InputEvent(ControlGUID, state)
0129 | BuildHotkeyString(bo)
0163 | BuildKeyName(code)
0176 | IsModifier(code)
0181 | RenderModifier(code)
0196 | __New(Callback)
0202 | UpdateBinding(ControlGUID, bo)
0218 | SetDetectionState(state)
0228 | RemoveBinding(ControlGUID)
0243 | KeyEvent(ControlGUID, e)
0258 | InputEvent(ControlGUID, state)
0262 | ButtonWatcher()
0279 | ProcessTimerState()
0292 | BuildHotkeyString(bo)
0316 | __New(Callback)
0323 | UpdateBinding(ControlGUID, bo)
0330 | SetDetectionState(state)
0335 | ProcessTimerState()
0377 | HatWatcher()
0399 | InputEvent(ControlGUID, state)
0406 | IsEmptyAssoc(assoc)

;Labels:
0643 | UCR_INPUTHREAD_DUMMY_LABEL

;}
;{   Install.ahk

;Functions:
0021 | Install_ExitCode(e)

;}
;{   Instance.ahk

;Functions:
0021 | Instance(Label="", Params="", WM="0x1357")
0064 | Instance_(wParam, lParam)

;}
;{   IPHelper.ahk

;Functions:
0030 | ResolveHostname(hostname)
0037 | ReverseLookup(ip_addr)
0048 | WSAStartup()
0060 | WSACleanup()
0070 | getaddrinfo(hostname)
0086 | freeaddrinfo(addrinfo)
0094 | getnameinfo(in_addr)
0113 | inet_addr(ip_addr)
0124 | inet_ntoa(in_addr)
0134 | IcmpCreateFile()
0144 | IcmpSendEcho(hIcmpFile, in_addr, timeout)
0163 | IcmpCloseHandle(hIcmpFile)

;}
;{   is2.ahk

;Functions:
0003 | OffscreenSnap(wid)
0024 | BlitSnap(wid)
0047 | DIBGetPixel(ByRef dibbuf, dibwidth, dibheight, dibbpp, x, y, ByRef r, ByRef g, ByRef b)
0055 | LastSnapGetPixel(x, y, ByRef r, ByRef g, ByRef b)
0060 | BoundsRelative(value, min, lim)
0064 | SearchLastSnap(ByRef foundx, ByRef foundy, x1, y1, x2, y2, templaddr)
0096 | SaveLastSnap(filename)
0141 | GetDC(wid)
0149 | CreateCompatibleDC(hdc1)
0157 | CreateCompatibleBitmap(hdc, width, height)
0165 | MakeBitmapInfoHeader(ByRef bi, width, height, bpp)
0175 | AllocateDIBBuf(ByRef buf, width, height, bpp)
0182 | CreateDIBSection(hDC, nW, nH, bpp, valuesptr="")
0191 | SelectObject(hdc, hbmp)
0199 | BitBlt(destDC, destx1, desty1, width, height, srcDC, srcx1, srcy1, operation=0x40CC0020)
0203 | PrintWindow(hwnd, hdc, flags=0)
0207 | GetDIBits(hdc, hbmp, startline, numlines, dataptr, ByRef bmi)
0216 | DeleteObject(hobj)
0220 | DeleteDC(hdc)
0224 | ReleaseDC(hwnd, hdc)
0228 | WriteFile(hfile, ByRef data, nbytes)
0236 | GetLastError()

;}
;{   IsEmpty.ahk

;Functions:
0028 | IsEmpty(var)

;}
;{   IsFullScreen.ahk

;Functions:
0015 | IsFullscreen(sWinTitle = "A", bRefreshRes = False)

;}
;{   IsProcessElevated.ahk

;Functions:
0005 | IsProcessElevated(ProcessID)

;}
;{   IsUpdated.ahk

;Functions:
0001 | IsUpdated()

;}
;{   iWeb.ahk

;Functions:
0040 | iWeb_Init()
0045 | iWeb_Term()
0053 | iWeb_newIe()
0058 | iWeb_Model(h=550,w=900)
0067 | iWeb_getwin(Name="")
0087 | iWeb_Release(pdsp)
0095 | iWeb_nav(pwb,url)
0110 | iWeb_complete(pwb)
0132 | iWeb_DomWin(pdsp,frm="")
0150 | iWeb_inpt(i)
0162 | iWeb_getDomObj(pwb,obj,frm="")
0199 | iWeb_setDomObj(pwb,obj,t,frm="")
0241 | iWeb_Checked(pwb,obj,checked=1,sIndex=0,frm="")
0254 | iWeb_SelectOption(pdsp,sName,selected,method="selectedIndex",frm="")
0266 | iWeb_TableParse(pdsp,table,row,cell,frm="")
0286 | iWeb_FireEvents(ele)
0297 | iWeb_TableLength(pdsp,TableRows="",TableRowsCells="",frm="")
0322 | iWeb_clickDomObj(pwb,obj,frm="")
0346 | iWeb_clickText(pwb,t,frm="")
0373 | iWeb_clickHref(pwb,t,frm="")
0400 | iWeb_clickValue(pwb,t,frm="")
0434 | iWeb_execScript(pwb,js,frm="")
0444 | iWeb_getVar(pwb,var,frm="")
0456 | iWeb_escape_text(txt)
0469 | iWeb_striphtml(HTML)
0480 | iWeb_Txt2Doc(t)
0487 | iWeb_Activate(sTitle)

;}
;{   iWeb_L.ahk

;Functions:
0043 | iWeb_newIe()
0048 | iWeb_Model(h=550,w=900)
0057 | iWeb_getWin(Name="")
0073 | iWeb_nav(pwb,url)
0087 | iWeb_complete(pwb)
0107 | iWeb_DomWin(pdsp,frm="")
0127 | iWeb_inpt(i)
0141 | iWeb_getDomObj(pdsp,obj,frm="")
0163 | iWeb_setDomObj(pdsp,obj,t,frm="")
0186 | iWeb_Checked(pdsp,obj,chkd=1,sIndex=-1,frm="")
0197 | iWeb_selectOption(pdsp,sName,selected,method="selectedIndex",frm="")
0207 | iWeb_getTagLen(pdsp,tag,frm="")
0216 | iWeb_getTagObj(pdsp,tag,itm,type="innerText",frm="")
0225 | iWeb_getTblLen(pdsp,t,r=-1,frm="")
0235 | iWeb_getTblObj(pdsp,t,r=-1,c=-1,type="innerText",frm="")
0247 | iWeb_FireEvents(ele)
0261 | iWeb_clickDomObj(pdsp,obj,frm="")
0270 | iWeb_clickText(pdsp,t,frm="")
0285 | iWeb_clickHref(pdsp,t,frm="")
0299 | iWeb_clickValue(pdsp,t,frm="")
0318 | iWeb_execScript(pwb,js,frm="")
0326 | iWeb_getVar(pwb,var,frm="")
0335 | iWeb_escape_text(txt)
0348 | iWeb_striphtml(HTML)
0359 | iWeb_Txt2Doc(t)
0368 | iWeb_Activate(sTitle, hwnd="", activate=1)
0389 | iWeb_TabWinID(tabName)

;}
;{   JEEGetAllText.ahk

;Functions:
0001 | JEE_StrRept(vText, vNum)

;}
;{   JEEGuiText.ahk

;Functions:
0008 | JEEGuiText_Load()
0417 | JEE_WinGetText(hWnd)
0427 | JEE_WinSetText(hWnd, vText)
0468 | JEE_EditSetText(hCtl, vText)
0484 | JEE_EditGetTextSpecialPlace(hCtl)
0511 | JEE_EditSetTextSpecialPlace(hCtl, vText)
0535 | JEE_StaticGetText(hCtl)
0542 | JEE_StaticSetText(hCtl, vText)
0546 | JEE_BtnGetText(hCtl)
0554 | JEE_BtnSetText(hCtl, vText)
0557 | JEE_PBGetPos(hCtl)
0560 | JEE_PBSetPos(hCtl, vPos)
0563 | JEE_TrBGetPos(hCtl)
0566 | JEE_TrBSetPos(hCtl, vPos)
0569 | JEE_REGetText(hCtl)
0631 | JEE_REGetStream(hCtl, vFormat)
0647 | JEE_REGetStreamCallback(dwCookie, pbBuff, cb, pcb)
0666 | JEE_REGetStreamToFile(hCtl, vFormat, vPath)
0685 | JEE_REGetStreamToFileCallback(dwCookie, pbBuff, cb, pcb)
0701 | JEE_RESetStream(hCtl, vFormat, vAddr, vSize)
0718 | JEE_RESetStreamCallback(dwCookie, pbBuff, cb, pcb)
0754 | JEE_RESetStreamFromFile(hCtl, vFormat, vPath)
0778 | JEE_RESetStreamFromFileCallback(dwCookie, pbBuff, cb, pcb)
0823 | JEE_DTPSetDate(hCtl, vDate)
0900 | JEE_MonthCalSetDate(hCtl, vDate)
0944 | JEE_HotkeyCtlGetText(hCtl)
0956 | JEE_HotkeyCtlSetText(hCtl, vKeys)
0987 | JEE_LinkCtlSetText(hCtl, vText)
1034 | JEE_SciSetText(hCtl, vText)

;}
;{   Json4Ahk.ahk

;Functions:
0017 | Json4Ahk_Encode(objAhk)

;}
;{   JSON_Beautify.ahk

;Functions:
0012 | JSON_Uglify(JSON)

;}
;{   JSON_FromObj.ahk

;Functions:
0006 | json_fromobj( obj )

;}
;{   JSON_ToObj.ahk

;Functions:
0004 | json_toobj( str )

;}
;{   KeyboardLayout.ahk

;Functions:
0013 | KeyboardLayout_Set(hkl, hWnd = 0)
0041 | KeyboardLayout_Get(hWnd = 0)

;}
;{   LBDDLib.ahk

;Functions:
0255 | LBDDLib_Init(Options=0)
0263 | LBDDLib_Add(hWnd, Switch=0, Options=0)
0270 | LBDDLib_Remove(hWnd)
0277 | LBDDLib_ReplaceHandle(OldhWnd, NewhWnd)
0284 | LBDDLib_Modify(hWnd, Options=0)
0294 | LBDDLib_ModifyGlobal(Options=0)
0301 | LBDDLib_UserVar(Switch)
0318 | LBDDLib_CallBack()
0329 | LBDDLib_LBGetItemText(hWnd, Item)
0337 | LBDDLib_LBDelItem(hWnd, Item)
0342 | LBDDLib_LBInsItem(hWnd, MyPos, MyText)
0351 | LBDDLib_info(switch="", p1="", p2="", p3="")
0440 | LBDDLib_resetOptions(ArrayNum)
0459 | LBDDLib_resetOptionsMain()
0466 | LBDDLib_parseOptionsMain(Options=0)
0482 | LBDDLib_parseOptions(ArrayNum, Options=0)
0539 | LBDDLib_cswap(col)
0551 | LBDDLib_getVerifyEvent(EventNum)
0568 | LBDDLib_drawInsert(hWnd, Switch, ArrayNum=0, ItemNum=0)
0716 | LBDDLib_ptInRect(RLeft, RTop, RRight, RBottom, PX, PY)
0720 | LBDDLib_itemFromPt(ArrayNum, Mx, My, bAutoScroll, dwInterval=300)
0813 | LBDDLib_msgFunc(wParam, lParam, uMsg, MsgParentWindow)
0982 | LBDDLib_callUser(fName, ArrayNum, hWnd, DraggedItem, CurrentItem=-10, VerifyEvent=-10)
1002 | LBDDLib_moveLB2EB(ItemToMove, hWnd_source, ArrayNum)
1019 | LBDDLib_moveLB2LB(ItemToMove, NewPosition, hWnd_source, ArrayNum)

;}
;{   LBEX.ahk

;Functions:
0021 | LBEX_Add(HLB, ByRef String)
0070 | LBEX_Delete(HLB, Index)
0079 | LBEX_DeleteAll(HLB)
0113 | LBEX_GetCount(HLB)
0125 | LBEX_GetCurrentSel(HLB)
0134 | LBEX_GetData(HLB, Index)
0146 | LBEX_GetFocus(HLB)
0155 | LBEX_GetItemHeight(HLB)
0165 | LBEX_GetSelCount(HLB)
0199 | LBEX_GetSelStart(HLB)
0209 | LBEX_GetSelState(HLB, Index)
0218 | LBEX_GetText(HLB, Index)
0232 | LBEX_GetTextLen(HLB, Index)
0241 | LBEX_GetTopIndex(HLB, Index)
0255 | LBEX_Insert(HLB, Index, ByRef String)
0267 | LBEX_ItemFromPoint(HLB, X, Y)
0374 | LBEX_SetCurSel(HLB, Index)
0385 | LBEX_SetFocus(HLB, Index)
0395 | LBEX_SetItemData(HLB, Index, Data)
0405 | LBEX_SetItemHeight(HLB, Index, Height)
0428 | LBEX_SetSelStart(HLB, Index)
0443 | LBEX_SetTabStops(HLB, TabArray)
0465 | LBEX_SetTopIndex(HLB, Index)

;}
;{   LetterVariations.ahk

;Functions:
0015 | LetterVariations(text,c=0)

;}
;{   lexer.ahk

;Functions:
0189 | generateEnums()
0209 | __New(lineReader)
0214 | incGet()
0221 | getInc()
0228 | decGet()
0235 | getDec()
0242 | __Get(offset)
0256 | get()
0263 | getPrev()
0270 | getNext()
0277 | hasMoreTokens()
0296 | holdTokens()
0303 | holdTokensRelease()
0312 | holdTokensRevert()
0320 | tokenizer_dropMultiLineToken(lineReader, tokens, ByRef startPos, ByRef endPos, byref match, TOKEN_END_RE)
0332 | tokenizer_readMultiLineToken(lineReader, tokens, ByRef startPos, ByRef endPos, byref match, TOKEN_END_RE)
0346 | cacheMoreTokens(failOnFailure = 1, holdTokens = 0)

;}
;{   Lib.ahk

;Functions:
0007 | __New(byref definition, ppInterface, version8 = False)
0051 | Hook(Method, hook = "", options = "F")
0091 | dllHook(Method, hook, dll = "peixoto.dll")
0130 | PatchVtable(method, table)
0142 | __delete()
0147 | __release()
0153 | UnHook(Method, hook = "")
0185 | keyevent(key)
0207 | StringFromIID(pIID)
0215 | zeromem(struct)
0219 | newmem(struct)
0224 | logErr(msg)
0239 | cicleColor(clr)
0253 | print(msg = "")
0268 | printl(msg = "")
0272 | parseConfig(item = "")

;}
;{   libcurl.ahk

;Functions:
0001 | CurlGlobalInit( Location = "", flags = 3 )
0032 | CurlFreeLibrary()
0039 | CurlEasyInit()
0046 | CurlEasyReset( EasyHandle )
0053 | CurlEasyCleanup( EasyHandle )
0060 | CurlShowErrors( Yes = true )
0066 | CurlEasySetOption( EasyHandle, Option, Parameter )
0077 | CurlSlistAppend( ByRef pSlist, String )
0088 | CurlSlistFreeAll( ByRef pSlist )
0096 | CurlFormAdd( ByRef pFirstItem, ByRef pLastItem, Option1, Value1, Option2, Value2 = 0, Option3 = 0, Value3 = 0, Option4 = 0, Value4 = 0, Option5 = 0, Value5 = 0, Option6 = 0, Value6 = 0, Option7 = 0, Value7 = 0, Option8 = 0, Value8 = 0 )
0123 | CurlFormFree( pFirstItem )
0130 | CurlEasyPerform( EasyHandle )
0137 | CurlEasyGetinfo( EasyHandle, Information )
0175 | CurlEasyStrError( ErrorCode )
0182 | CurlEasyEscape( EasyHandle, URL )
0190 | CurlEasyUnescape( EasyHandle, URL )
0197 | CurlVersion()
0208 | CurlFreeGet( pString )
0218 | MergeDouble( l, h )
0226 | CurlGetInfoType( Information )
0245 | CurlGetInfoDefine( All = true )
0290 | CurlEasyGetOptionType( Option )
0310 | CurlEasyDefineOptions( All = true )

;}
;{   lineReader.ahk

;Functions:
0084 | __New(buffer)
0093 | GetLine(byref startPos, byref endPos, gettingLineContinuation=0)
0133 | diagnositicInfo()
0146 | updateBuffer(gettingLineContinuation)
0152 | whatAndWhereAmI()
0159 | getContext()
0204 | source()
0212 | __New(filename)
0227 | updateBuffer(gettingLineContinuation)
0247 | source()
0252 | __Delete()

;}
;{   List.ahk

;Functions:
0001 | List_AddItem(list, item, select = false)
0023 | List_AddRange(list, range)
0029 | List_GetItem(list, index)
0035 | List_InsertItem(list, item, index)
0057 | List_FromPseudoArray(arr)
0067 | List_FromArray(arr, selectedItem="", selectIndex = false)
0091 | List_FromArrayKeys(arr, selectedItem="", selectIndex = false)
0115 | List_SelectFirstItem(list)
0128 | List_SelectItem(list, item)
0146 | List_MsgBox(list)

;}
;{   ListCompare.ahk

;Functions:
0008 | GreaterThanNumInList(ByRef NumList,Num)
0022 | LessThanNumInList(ByRef NumList,Num)
0043 | BetweenNumInList(ByRef NumList,LowerBound,UpperBound)

;}
;{   ListviewLib_1.01.ahk

;Functions:
0036 | LVM_GetCount(h)
0042 | LVM_GetColOrder(h)
0056 | LVM_SetColOrder(h, c)
0067 | LVM_GetColWidth(h, c)
0077 | LVM_SetColWidth(h, c, w=-1)
0085 | LVM_GetNext(h, r=0, o=0)
0093 | LVM_GetText(h, r, c=1)
0112 | LVM_Delete(h, i=0)

;}
;{   Listview_G.ahk

;Functions:
0195 | LVG_Search(Gui_nr=1,mode="Selected",mode2="Count",rows="all",cols="all",srch_str="")
0351 | LVG_Get(Gui_nr=1,mode="Selected",mode2="Count",rows="all")
0456 | LVG_Count_Un(Gui_nr=1,mode="Unchecked")
0499 | LVG_GetNext_Un(Gui_nr=1,mode="Unchecked",pr=0)
0547 | LVG_Check(Gui_nr=1,mode="Reverse")
0603 | LVG_Select(Gui_nr=1,mode="Reverse")
0663 | LVG_Delete(Gui_nr=1,mode="Selected")

;}
;{   LOBYTE.ahk

;Functions:
0001 | LOBYTE(a)

;}
;{   Lower.ahk

;Functions:
0011 | Lower(Text)

;}
;{   LowerReplaceSpace.ahk

;Functions:
0011 | LowerReplaceSpace(Text)

;}
;{   LOWORD.ahk

;Functions:
0001 | LOWORD(a)

;}
;{   LV.ahk

;Functions:
0009 | LV_SetDefault(sGUI, sLV)
0016 | LV_GetSel()
0021 | LV_GetSelText(iCol=1)
0029 | LV_GetAsText(iRow=1, iCol=1)
0035 | LV_SetSel(iRow=1, sOptsOverride="")
0048 | LV_SetSelText(sToSel, sOptsOverride="", iCol=1, bPartialMatch=false, bCaseSensitive=false)

;}
;{   LVA.ahk

;Functions:
0230 | LVA_OnNotify(wParam, lParam, msg, hwnd)
0237 | LVA_ListViewAdd(LVvar, Options="", UseFix=false, Opt="")
0257 | LVA_ListViewModify(LVvar, Options)
0281 | LVA_Refresh(LVvar)
0287 | LVA_SetProgressBar(LVvar, Row, Col, cInfo="")
0318 | LVA_Progress(Name, Row, Col, pProgress)
0324 | LVA_SetCell(Name, Row, Col, cBGCol="", cFGCol="")
0340 | LVA_EraseAllCells(Name)
0345 | LVA_GetCellNum(Switch=0, LVvar="")
0399 | LVA_SetSubItemImage(LVvar, Row, Col, iNum)
0416 | lva_VerifyColor(cColor, Switch=0)
0467 | lva_DrawProgressGetStatus(Switch, Row=0, Col=0, Name="")
0514 | lva_GetStatusColor(Switch, Row=0, Col=0, LVvar=0)
0582 | lva_hWndInfo(hwnd, switch=0, data=1)
0637 | lva_OnNotifyProg(wParam, lParam, msg, hwnd)
0683 | lva_OnLVScroll(hwnd, uMsg, wParam, lParam)
0697 | lva_DrawProgress(Row, Col, hHandle)
0762 | lva_Info(Switch, Name, Row=0, Col=0, Data=0)
0871 | lva_Subclass(hCtrl, Fun, Opt="", ByRef $WndProc="")

;}
;{   LVCustomColors.ahk

;Functions:
0001 | LV_Initialize(Gui_Number="", Control="", Column="")
0073 | LV_Change(Gui_Number="", Control="", Select="", Column="")
0138 | LV_SetColor(Index="", TextColor="", BackColor="", Redraw=1)
0204 | LV_GetColor(Index, T="Text")
0216 | LV_Destroy(Gui_Number="", Control="", DeactivateWMNotify="")
0286 | DecodeInteger( p_type, p_address, p_offset)
0301 | EncodeInteger( p_value, p_size, p_address, p_offset )
0309 | HWND2GuiNClass(hWnd, ByRef Gui = "", ByRef Control = "")
0339 | LV_WM_NOTIFY(p_l)
0376 | WM_NOTIFY( p_w, p_l, p_m )

;}
;{   LVEDIT.ahk

;Functions:
0027 | LVEDIT_INIT(LVHWND, BlankSubItem = False)
0055 | LVEDIT_SUBCLASSPROC(H, M, W, L, I, D)
0084 | LVEDIT_NOTIFY(W, L)

;}
;{   LVX.ahk

;Functions:
0025 | LVX_Setup(name)
0051 | LVX_CellEdit(set = true)
0131 | LVX_SetText(text, row = 1, col = 1)
0157 | LVX_SetEditHotkeys(enter = "Enter,NumpadEnter", esc = "Esc")
0200 | LVX_SetColour(index, back = 0xffffff, text = 0x000000)
0220 | LVX_RevBGR(i)
0228 | LVX_Notify(wParam, lParam, msg)
0242 | WM_NOTIFY(wParam, lParam, msg, hwnd)

;}
;{   LV_Colors.ahk

;Functions:
0043 | On_NM_CUSTOMDRAW(H, L)
0107 | GetItemParam(HWND, Row)
0119 | SetItemParam(HWND, Row, Param)
0188 | Detach(HWND)
0353 | LV_Colors_WM_NOTIFY(W, L)
0370 | LV_Colors_SubclassProc(H, M, W, L, S, R)

;}
;{   LV_EX.ahk

;Functions:
0087 | LV_EX_GetColumnOrder(HLV)
0107 | LV_EX_GetColumnWidth(HLV, Column)
0115 | LV_EX_GetExtendedStyle(HLV)
0123 | LV_EX_GetHeader(HLV)
0131 | LV_EX_GetItemParam(HLV, Row)
0164 | LV_EX_GetItemState(HLV, Row)
0188 | LV_EX_GetRowsPerPage(HLV)
0218 | LV_EX_GetTopIndex(HLV)
0226 | LV_EX_GetView(HLV)
0235 | LV_EX_IsRowChecked(HLV, Row)
0241 | LV_EX_IsRowFocused(HLV, Row)
0247 | LV_EX_IsRowSelected(HLV, Row)
0253 | LV_EX_IsRowVisible(HLV, Row)
0268 | LV_EX_MapIDToIndex(HLV, ID)
0276 | LV_EX_MapIndexToID(HLV, Index)
0346 | LV_EX_SetColumnOrder(HLV, ColArray)
0358 | LV_EX_SetExtendedStyle(HLV, StyleMask, Styles)
0366 | LV_EX_SetItemIndent(HLV, Row, NumIcons)
0381 | LV_EX_SetItemParam(HLV, Row, Value)
0396 | LV_EX_SetSubItemImage(HLV, Row, Column, ImageIndex)

;}
;{   LV_InCellEdit.ahk

;Functions:
0107 | __Delete()
0212 | On_WM_COMMAND(W, L, M, H)
0238 | On_WM_HOTKEY(W, L, M, H)
0257 | On_WM_NOTIFY(W, L)
0275 | LVN_BEGINLABELEDIT(L)
0325 | LVN_ENDLABELEDIT(L)
0358 | NM_DBLCLICK(L)
0415 | NextSubItem(K)
0483 | RegisterHotkeys(Register = True)

;}
;{   LV_SortArrow.ahk

;Functions:
0005 | LV_SortArrow(h, c, d="")

;}
;{   MAKELANGID.ahk

;Functions:
0001 | MAKELANGID(p, s)

;}
;{   MAKELCID.ahk

;Functions:
0001 | MAKELCID(lgid, srtid)

;}
;{   MAKELONG.ahk

;Functions:
0001 | MAKELONG(a, b)

;}
;{   MAKELPARAM.ahk

;Functions:
0001 | MAKELPARAM(a, b)

;}
;{   MAKELRESULT.ahk

;Functions:
0001 | MAKELRESULT(a, b)

;}
;{   MAKEWORD.ahk

;Functions:
0001 | MAKEWORD(a, b)

;}
;{   MAKEWPARAM.ahk

;Functions:
0001 | MAKEWPARAM(a, b)

;}
;{   Manifest.ahk

;Functions:
0002 | Manifest_FromPackage(fileName)
0020 | Manifest_FromFile(fileName)
0029 | Manifest_FromStr(tman)
0057 | _IsValidAHKIdentifier(x)
0062 | ObjHasNonEmptyKey(obj, field)
0067 | _ManValidateField(out, man, field)

;}
;{   Markdown2HTML.ahk

;Functions:
0023 | MD_IsMultiP(ByRef htmQ)
0032 | Markdown2HTML(ByRef text, simplify=0)
0045 | Markdown2HTML_(ByRef text)
0166 | SetStatus(ByRef out, t, ByRef inCode, ByRef inUList, ByRef inOList)
0176 | _MD(ByRef v)
0194 | _HTML(ByRef v)
0203 | _ElemID(ByRef v)
0218 | HighlightCode(ByRef code)
0237 | _MD_Callout(m, cId, foundPos, haystack)
0268 | _Tables(byref t)
0286 | _KeepHTML(byref t)
0298 | StrStartsWith(ByRef v, ByRef w)

;Labels:
9881 | _reprocess

;}
;{   MatchItemFromList.ahk

;Functions:
0003 | MatchItemFromList(iPtr, iCount, sItem)
0072 | InStrCount(ByRef Haystack, Trigram)

;}
;{   MCI.ahk

;Functions:
0199 | MCI_Open(p_MediaFile,p_Alias="",p_Flags="")
0344 | MCI_OpenCDAudio(p_Drive="",p_Alias="",p_CheckForMedia=true)
0480 | MCI_Close(p_lpszDeviceID)
0584 | MCI_Play(p_lpszDeviceID,p_Flags="",p_Callback="",p_hwndCallback=0)
0694 | MCI_Notify(wParam,lParam,msg,hWnd)
0753 | MCI_Stop(p_lpszDeviceID)
0790 | MCI_Pause(p_lpszDeviceID)
0836 | MCI_Resume(p_lpszDeviceID)
0903 | MCI_Record(p_lpszDeviceID,p_Flags="")
0946 | MCI_Save(p_lpszDeviceID,p_FileName)
0990 | MCI_Seek(p_lpszDeviceID,p_Position)
1063 | MCI_Length(p_lpszDeviceID,p_Track=0)
1102 | MCI_Status(p_lpszDeviceID)
1134 | MCI_Position(p_lpszDeviceID,p_Track=0)
1180 | MCI_DeviceType(p_lpszDeviceID)
1212 | MCI_MediaIsPresent(p_lpszDeviceID)
1257 | MCI_TrackIsAudio(p_lpszDeviceID,p_Track=1)
1298 | MCI_CurrentTrack(p_lpszDeviceID)
1333 | MCI_NumberOfTracks(p_lpszDeviceID)
1373 | MCI_SetVolume(p_lpszDeviceID,p_Factor)
1411 | MCI_SetBass(p_lpszDeviceID,p_Factor)
1448 | MCI_SetTreble(p_lpszDeviceID,p_Factor)
1478 | MCI_ToMilliseconds(Hour,Min,Sec)
1540 | MCI_ToHHMMSS(p_ms,p_MinimumSize=4)
1624 | MCI_SendString(p_lpszCommand,ByRef p_lpszReturnString,p_hwndCallback=0)

;}
;{   MCode.ahk

;Functions:
0008 | MCode(ByRef cBuf, ByRef sHex)
0020 | MCode_2(ByRef sMcode)

;}
;{   md5 (2).ahk

;Functions:
0003 | MD5_File( sFile="", cSz=4 )
0018 | MD5( ByRef V, L=0 )

;}
;{   md5.ahk

;Functions:
0035 | MD5(string, encoding = "UTF-8")
0039 | HexMD5(hexstring)
0043 | FileMD5(filename)
0047 | AddrMD5(addr, length)
0053 | CalcAddrHash(addr, length, algid, byref hash = 0, byref hashlength = 0)
0085 | CalcStringHash(string, algid, encoding = "UTF-8", byref hash = 0, byref hashlength = 0)
0095 | CalcHexHash(hexstring, algid)
0107 | CalcFileHash(filename, algid, continue = 0, byref hash = 0, byref hashlength = 0)

;}
;{   Mem.ahk

;Functions:
0001 | Mem_Allocate(bytes)
0006 | Mem_GetHeap()
0011 | Mem_Release(buffer)
0015 | Mem_Copy(src, dest, bytes)

;}
;{   MemBlk.ahk

;Functions:
0223 | RawRead(ByRef dest, bytes)
0247 | RawWrite(ByRef src, bytes)

;}
;{   memlib (2).ahk

;Functions:
0003 | __New(Name, ID_)
0010 | get_process_list()
0028 | open_process(ProcessID, access = "", InheritHandle = 0)
0036 | get_process_handle(process_, access = "")
0045 | close_process_handle(hProcess)
0049 | write_process_memory(hProcess, adress, type_, value)
0083 | read_process_memory(hProcess, adress, type_, arraysize = "")
0112 | read_pointer_sequence(hprocess, baseadress, offsets)
0127 | __New(hprocess, addy, newcode)
0141 | _enable()
0146 | _disable()
0151 | switch()
0172 | __Delete()
0177 | VirtualAllocEx(hProcess, mem_size)
0193 | dllcallEx(h_process, Lib, function, argument)
0230 | GetProcAddressEx(h_process, module, function)
0244 | ReverseInt32bytes(int32)
0278 | __New(hprocess, from, code, nops = 0)
0313 | _enable()
0322 | _disable()
0326 | switch()
0344 | __Delete()
0352 | GetSystemInfo()
0362 | VirtualQueryEx(hprocess, base_adress)
0382 | __New(Base_, Alocation, Size)
0390 | find_memory_pages(hprocess)
0413 | arrays_are_equal(a1, a2)
0441 | get_process_ID(_process)
0451 | __New(BaseAddr, BaseSize, Name)
0459 | get_modules_list(proccessID)
0486 | find_pages_in_range(hprocess, start, end_)
0502 | read_process_struct(hProcess, byref struct, size, adress)
0519 | find_module(name, id_process)
0528 | aobscan(hprocess, id_process, module_name, bytes, dllname = "peixoto.dll", range_ = 1)
0582 | CreateIdleProcess(Target, workingdir = "", args = "", noWindow = "")
0635 | ResumeProcess(hThread)
0639 | BlockNewProcess(parent_id, child_list)
0664 | memlib_Number2String(num, typ, reverse = False)
0685 | memlib_String2ByteArray(string)
0704 | GetModuleFileNameEx(hProcess, hModule)
0719 | EnumProcessModules(hprocess)
0756 | Get_Module_handle(hprocess, module)
0766 | Get_module_memory_space(hprocess, module)

;}
;{   MemLib.ahk

;Functions:
0006 | OpenMemoryfromProcess(process,right=0x1F0FFF)
0014 | OpenMemoryfromTitle(title,right=0x1F0FFF)
0021 | CloseMemory(hwnd)
0026 | WriteMemory(hwnd,address,writevalue,datatype="int",length=4,offset=0)
0033 | ReadMemory(hwnd,address,datatype="int",length=4,offset=0)
0053 | SetPrivileg(privileg = "SeDebugPrivilege")
0067 | Suspendprocess(hwnd)
0072 | Resumeprocess(hwnd)

;}
;{   MemoryBuffer.ahk

;Functions:
0023 | Create(srcPtr, size)
0035 | CreateFromFile(filePath)
0054 | CreateFromBase64(base64str)
0068 | GetPtr()
0077 | WriteToFile(filePath)
0090 | Free()
0106 | IsValid()
0113 | ToBase64()
0129 | __Delete()
0135 | ToString()
0140 | memcpy(dst, src, cnt)
0152 | AllocMemory(size)

;}
;{   Menu.ahk

;Functions:
0033 | Menu_BarRightJustify(HWND, ItemPos)
0070 | Menu_GetItemCount(HMENU)
0085 | Menu_GetItemInfo(HMENU, ItemPos)
0110 | Menu_GetItemPos(HMENU, ItemName)
0123 | Menu_GetItemState(HMENU, ItemPos)
0132 | Menu_GetItemName(HMENU, ItemPos)
0146 | Menu_GetMenu(HWND)
0156 | Menu_GetMenuByName(MenuName)
0179 | Menu_GetSubMenu(HMENU, ItemPos)
0187 | Menu_IsItemChecked(HMENU, ItemPos)
0194 | Menu_IsSeparator(HMENU, ItemPos)
0201 | Menu_IsSubmenu(HMENU, ItemPos)
0230 | Menu_ShowAligned(HMENU, HWND, X, Y, XAlign, YAlign)

;}
;{   mg.ahk

;Functions:
0053 | MG_GetMove(Angle)
0076 | MG_GetAngle(StartX, StartY, EndX, EndY)
0095 | MG_GetRadius(StartX, StartY, EndX, EndY)
0101 | MG_Recognize(MGHotkey="", ToolTip=0, MaxMoves=3, ExecuteMGFunction=1, SendIfNoDrag=1)

;}
;{   MI (2).ahk

;Functions:
0047 | MI_SetMenuItemIcon(MenuNameOrHandle, ItemPos, FilenameOrHICON, IconNumber=1, IconSize=0, ByRef unused1="", ByRef unused2="")
0145 | MI_RemoveIcons(MenuNameOrHandle)
0161 | MI_SetMenuItemBitmap(MenuNameOrHandle, ItemPos, hBitmap)
0194 | MI_GetMenuHandle(menu_name)
0229 | MI_SetMenuStyle(MenuNameOrHandle, style)
0246 | MI_ExtractIcon(Filename, IconNumber, IconSize)
0302 | MI_EnableOwnerDrawnMenus(hwnd="")
0319 | MI_ShowMenu(MenuNameOrHandle, x="", y="")
0405 | MI_OwnerDrawnMenuItemWndProc(hwnd, Msg, wParam, lParam)
0472 | MI_GetBitmapFromIcon32Bit(h_icon, width=0, height=0)

;}
;{   MI.ahk

;Functions:
0047 | MI_SetMenuItemIcon(MenuNameOrHandle, ItemPos, FilenameOrHICON, IconNumber=1, IconSize=0, ByRef unused1="", ByRef unused2="")
0146 | MI_RemoveIcons(MenuNameOrHandle)
0162 | MI_SetMenuItemBitmap(MenuNameOrHandle, ItemPos, hBitmap)
0195 | MI_GetMenuHandle(menu_name)
0230 | MI_SetMenuStyle(MenuNameOrHandle, style)
0247 | MI_ExtractIcon(Filename, IconNumber, IconSize)
0301 | MI_EnableOwnerDrawnMenus(hwnd="")
0318 | MI_ShowMenu(MenuNameOrHandle, x="", y="")
0405 | MI_OwnerDrawnMenuItemWndProc(hwnd, Msg, wParam, lParam)
0473 | MI_GetBitmapFromIcon32Bit(h_icon, width=0, height=0)
0551 | MI_DllProcAorW(dll, func)

;}
;{   misc.ahk

;Functions:
0058 | FAIL(msg)
0081 | WARN(msg)
0113 | removeCommentsAndWhitespaceFromRegEx(regex)
0152 | CallStack(skipStackLevels = 0, printLines = 1)
0173 | isNumber(ByRef x)
0186 | isInteger(ByRef x)
0201 | memcpy(pDst, pSrc, size)
0224 | memset(pDst, val, size)
0245 | repeat(x, y)

;}
;{   Misc_Functions_2.ahk

;Functions:
0001 | AddGraphicButton(VariableName, ImgPath, Options="", bHeight=32, bWidth=32)
0035 | ListView_HeaderFontSet(p_hwndlv="", p_fontstyle="", p_fontname="")
0140 | CreateFont( nHeight , nWidth , nEscapement, nOrientation , fnWeight , fdwItalic, fdwUnderline , fdwStrikeOut , fdwCharSet, fdwOutputPrecision , fdwClipPrecision , fdwQuality, fdwPitchAndFamily , lpszFace)
0153 | SendMessage(p_hwnd, p_msg, p_wParam="", p_lParam="")
0158 | A_SendMessage(p_msg, p_wParam="", p_lParam="", p_ctrl="", p_title="", p_text="", p_excludetitle="", p_excludetext="")
0164 | ControlFocused()
0185 | Edit_Standard_Params(ByRef Control, ByRef WinTitle)
0197 | Edit_TextIsSelected(Control="", WinTitle="")
0204 | Edit_GetSelection(ByRef start, ByRef end, Control="", WinTitle="")
0219 | Edit_Select(start=0, end=-1, Control="", WinTitle="")
0230 | Edit_SelectLine(line=0, include_newline=false, Control="", WinTitle="")
0260 | Edit_DeleteLine(line=0, Control="", WinTitle="")

;}
;{   Mount.ahk

;Functions:
0136 | Mount(SourcePath = "", Mountpoint = "", Options = "")
0255 | Mount_UnMount(Mountpoint = "", Options = "")
0266 | Mount_GetMountPathes(ByRef pPathes)
0297 | Mount_GetMount(pPath = "")

;}
;{   MouseDistance.ahk

;Functions:
0016 | Remove_Decimal(Temp_Number)
0022 | Reduce_Decimal(Temp_Number)

;}
;{   MouseKeyboardCounter.ahk

;Functions:
0459 | Format_To_7(Temp_Number)
1110 | AddOtherKeys()
1131 | AddNumpadKeys()

;}
;{   MouseMove_Ellipse.ahk

;Functions:
0036 | MouseMove_Ellipse(pos_X1, pos_Y1, param_Options="")

;}
;{   msg.ahk

;Functions:
0003 | Msg(Msg)

;}
;{   msTill.ahk

;Functions:
0004 | msTill(Time)

;}
;{   mySQL.ahk

;Functions:
0023 | MySQL_CreateConnectionData(connectionString)
0036 | MySQL_StartUp()
0061 | MySQL_DLLPath(forcedPath = "")
0065 | if(DLLPath == "")
0093 | MySQL_Connect(host, user, password, database, port = 3306)
0120 | MySQL_Close(db)
0126 | MySQL_GetVersion(db)
0130 | MySQL_Ping(db)
0134 | MySQL_GetLastErrorNo(db)
0138 | MySQL_GetLastErrorMsg(db)
0145 | MySQL_Store_Result(db)
0152 | MySQL_Use_Result(db)
0159 | MySQL_Query(db, query)
0163 | MySQL_free_result(requestResult)
0170 | MySQL_num_fields(requestResult)
0177 | MySQL_fetch_lengths(requestResult)
0185 | MySQL_fetch_row(requestResult)
0193 | Mysql_fetch_field_direct(requestResult, fieldnum)
0200 | Mysql_fetch_field(requestResult)
0207 | MySQL_fetch_fields(requestResult)
0225 | BuildMySQLErrorStr(db, message, query="")
0240 | GetUIntAtAddress(_addr, _offset)
0245 | GetPtrAtAddress(_addr, _offset)
0254 | __MySQL_Query_Dump(_db, _query)
0332 | Mysql_escape_string(unescaped_string)
0396 | __new(ptr)
0400 | Name()
0405 | OrgName()
0410 | Table()
0415 | OrgTable()

;}
;{   NetworkAPI.ahk

;Functions:
0050 | API_ValidateSource(domain)
0093 | u2v(u)
0100 | v_clean(s)
0113 | u2v_clean(u)
0140 | API_Info(file,item="")
0145 | API_Get(file)
0152 | API_GetDependencies(pack_ahkp)

;}
;{   newestFile.ahk

;Functions:
0018 | newestFile(folder)

;}
;{   NumSize.ahk

;Functions:
0001 | NumSize(v)

;}
;{   NumType.ahk

;Functions:
0001 | NumType(v)

;}
;{   Obj.ahk

;Functions:
0001 | Obj_Print(obj, indent = 0)
0042 | Obj_FindValue(obj, value, caseSensitive = false)
0052 | Obj_IsPureArray(obj, zeroBased = false)

;}
;{   ObjByRef.ahk

;Functions:
0013 | __GET(key)

;}
;{   ObjCSV.ahk

;Functions:
1108 | SaveBatch(strData, strFilePath, intProgressType, strFileEncoding)
1130 | MakeFixedWidth(strFixed, intWidth)
1139 | MakeHTMLHeaderFooter(strTemplate, strFilePath, strEncapsulator)
1152 | MakeHTMLRow(strTemplate, objRow, intRow, strEncapsulator)
1162 | MakeXMLRow(objRow)
1173 | ProgressBatchSize(intMax)
1183 | ProgressStart(intType, intMax, strText)
1197 | ProgressUpdate(intType, intActual, intMax, strText)
1210 | ProgressStop(intType)
1221 | CheckEolReplacement(strData, strEolReplacement, ByRef strEol)
1235 | GetEolCharacters(strData)

;}
;{   object.ahk

;Functions:
0052 | TO_DEPTH(x)
0245 | object_getBase(obj)
0251 | object_getBaseAddress(obj)
0258 | object_debug(str)
0288 | object_test()

;}
;{   ObjectBundles.ahk

;Functions:
0007 | WhichBundle()
0048 | LoadBundle(Reload="")
0104 | LoadAllBundles()
0185 | ReadBundle(File, Counter)
0217 | LoadPersonalBundle()
0241 | SaveUpdatedBundles(tosave="")
0303 | ParseBundle(Patterns, Counter)
0364 | CreateFirstBundle()
0388 | FixPreview(in)

;}
;{   ObjShare.ahk

;Functions:
0001 | ObjShare(obj)

;}
;{   ObjTree.ahk

;Functions:
0598 | ObjTree_Expand(TV_Item,OnlyOneItem=0,Collapse=0)
0607 | ObjTree_Add(obj,parent,ByRef p,G)
0621 | ObjTree_Clone(obj,e=0)
0645 | ObjTree_TVReload(ByRef obj,TV_Item,Key,ByRef parents,G)
0664 | ObjTree_LoadList(obj,text,G)

;}
;{   OCR.ahk

;Functions:
0029 | GetOCR(topLeftX="", topLeftY="", widthToScan="", heightToScan="", options="")
0163 | CMDret(CMD)

;}
;{   On.ahk

;Functions:
0133 | On_ActiveWindow(Label, Interval=200)
0155 | On_ControlList(WinTitle, Label, TitleMatchMode=3, Interval=200)
0178 | On_File(Filename, Label, Interval=1000)
0211 | On_Pixel(X, Y, Label, Method="", Interval=200)
0235 | On_StatusBar(WinTitle, Label, Part=1, TitleMatchMode=3, Interval=200)
0259 | On_WinTitle(WinTitle, Label, TitleMatchMode=3, Interval=200)
0282 | On_WinPos(WinTitle, Label, TitleMatchMode=3, Interval=200)
0307 | On_WinSize(WinTitle, Label, TitleMatchMode=3, Interval=200)
0332 | On_WinOpen(WinTitle, Label, TitleMatchMode=3, DetectHidden=0, Interval=200)
0355 | On_WinClose(WinTitle, Label, TitleMatchMode=3, DetectHidden=0, Interval=200)

;}
;{   OnMenuHilite.ahk

;Functions:
0029 | WM_ENTERMENULOOP()
0033 | WM_MENUSELECT( wParam, lParam, Msg, hWnd )

;}
;{   OnPBMsg.ahk

;Functions:
0043 | OnPBMsg(wParam, lParam, msg, hwnd)

;}
;{   OnWin.ahk

;Functions:
0119 | Watch()
0133 | Start()
0157 | SetTimer(arg3)
0185 | __Delete()
0248 | __New(self)
0262 | __Delete()
0273 | __New()
0281 | __Delete()
0286 | Revoke()
0321 | Assert()

;}
;{   Package.ahk

;Functions:
0002 | Package_Build(outFile, baseDir, jfile="")
0024 | Package_Validate(fIn)
0073 | _Package_Compress(fIn, fOut, manjson)
0095 | _Package_DumpTree(f, tree)
0123 | _Package_ExtractTree(ptr, dir)
0147 | _Package_ExtractTreeObj(ptr, tmpdir, Obj)

;}
;{   Panel.ahk

;Functions:
0033 | Panel_Add(HParent, X="", Y="", W="", H="", Style="", Text="")
0075 | Panel_SetStyle(Hwnd, Style, ByRef hStyle="", ByRef hExStyle="")
0116 | Panel_wndProc(Hwnd, UMsg, WParam, LParam)
0161 | Panel_registerClass()
0179 | Panel_add2Form(hParent, Txt, Opt)

;}
;{   Parse.ahk

;Functions:
0061 | Parse(O, pQ, ByRef o1="",ByRef o2="",ByRef o3="",ByRef o4="",ByRef o5="",ByRef o6="",ByRef o7="",ByRef o8="", ByRef o9="", ByRef o10="")

;}
;{   parser Directx1-10.ahk

;Functions:
0002 | _7thpass()
0028 | patch()
0048 | _7thpass()
0074 | _7thpass()
0113 | _6thpass()

;}
;{   parser Directx11, DirectShow.ahk

;Functions:
0002 | _5thpass()

;}
;{   Path.ahk

;Functions:
0011 | Path(p1,p2="",p3="",p4="",p5="",p6="",p7="",p8="",p9="")
0031 | Path_caller(self,func,p1="__deFault__",p2="__deFault__",p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
0042 | Path_getter(self, key)

;}
;{   Pebwa.ahk

;Functions:
0083 | EncodeQuantity(_quantity)
0117 | DecodeQuantity(_quantity)
0151 | Bin2Pebwa(ByRef @pebwa, ByRef @bin, _byteNb=0)
0260 | Pebwa2Bin(ByRef @bin, _pebwa)

;}
;{   PECreateEmpty.ahk

;Functions:
0011 | PECreateEmpty(sFile)

;}
;{   pgArray.ahk

;Functions:
0018 | pgArray_Insert( ArrayName, Idx, p1, p2="", p3="", p4="", p5="" )
0038 | pgArray_Shift( ArrayName, Idx=1, HowFar=1 )
0057 | pgArray_Rotate( ArrayName, FromIdx, ToIdx )
0072 | pgArray_Swap( ByRef Var1, ByRef Var2 )

;}
;{   PHY.ahk

;Functions:
0010 | PHY_INIT(w,h,n = 1000)
0036 | PHY_OBJECT_ADD(LISTTYPE,OBJECT_ID, x, y, w, h,xvec=0,yvec=0,colfact=1,r=0)
0072 | PHY_OBJECT_REMOVE(OBJECT_ID,_type = "")
0130 | PHY_OBJECT_UPDATE(OBJECT_ID, x="", y="", w="", h="",xvec="",yvec="",colfact="",r="")
0170 | PHY_QUAD_CREATE(byref OBJECTID, x=0, y=0, w=0, h=0,xvec=0,yvec=0,colfact=1,r=0)
0196 | PHY_EXECUTE_VECTORS()
0247 | PHY_COLLISION_LIST()
0365 | PHY_GRAVITY_SET(g=4)
0377 | PHY_GET_OBJECT_COLLISION(OBJECT_ID)
0386 | PHY_OBJECT_TYPE_CHECK(OBJECT_TYPE)
0402 | PHY_EVENT_LISTENER_ADD(object_id,callback_function,event)
0419 | PHY_EVENT_LISTENER_EXEC(object_one,event,object_two="")
0442 | PHY_EVENT_LISTENER_REMOVE(object_id)
0460 | PHY_EVENT_CORRECT_POSITION(SYS_PHY_OBJ1,EVENT,SYS_PHY_OBJ2)

;}
;{   PIG - Spy.ahk

;Functions:
0233 | info()
0278 | hideit()
0290 | rollit()
0331 | ILC_Create(i, g="1", s="16x16", f="M24")
0346 | ILC_List(cx, file, idx="100", cd="1")
0366 | ILC_FitBmp(hPic, hIL, idx="1")
0393 | ILC_Destroy(hwnd)
0400 | ILC_Add(hIL, icon, idx="1")

;}
;{   Ping (2).ahk

;Functions:
0003 | Ping(Address="8.8.8.8",Timeout = 1000,ByRef Data = "",Length = 0,ByRef Result = "",ByRef ResultLength = 0)

;}
;{   ping.ahk

;Functions:
0007 | ping_(adr, data, timeout)
0063 | ping_GetError(code, func="[ukn]")
0073 | ping_Host2IP(name)
0108 | ping_DW2IP(adr)
0113 | ping(addr, data="AHK ping test", timeout="500")

;Labels:
3129 | error

;}
;{   ping2.ahk

;Functions:
0007 | GetTextLines(FilePath)
0027 | Ping(SiteOrIP, ByRef AverageVar, ByRef MinimumVar, ByRef MaximumVar, ByRef StatusVar, ByRef LossVar, PingCount = 1, AltIP = 0, Timeout = 0)

;}
;{   PlaySound.ahk

;Functions:
0006 | PlaySound(PlaySound,Action)
0061 | PlayBeep(in)

;}
;{   PleasantNotify.ahk

;Functions:
0001 | PleasantNotify(title, message, pnW=700, pnH=300, position="b r", time=10)
0031 | Notify_Destroy()
0040 | pn_mod_title(title)
0045 | pn_mod_msg(message)
0050 | WinMove(hwnd,position)

;Labels:
5033 | ByeNotify

;}
;{   PluginHelper.ahk

;Functions:
0010 | GrabPlugin(data,tag="",level="1")
0040 | GrabPluginOptions(data)
0045 | CountString(String, Char)

;}
;{   Prefs.ahk

;Functions:
0012 | Prefs_init(b,default_func)
0054 | Prefs_setter(prefs,name,value)
0061 | Prefs_getter(prefs,name)
0067 | Prefs_caller(prefs, func, n1, ByRef r1="__deFault__",n2="",ByRef r2="__deFault__",n3="",ByRef r3="__deFault__",n4="",ByRef r4="__deFault__",n5="",ByRef r5="__deFault__",n6="",ByRef r6="__deFault__")
0119 | Prefs_remove(prefs,name)
0123 | Prefs_override(prefs,n1,v1="",n2="",v2="",n3="",v3="",n4="",v4="",n5="",v5="",n6="",v6="")

;}
;{   Printer.ahk

;Functions:
0001 | GetDefaultPrinter()
0007 | SetDefaultPrinter(sPrinter)
0011 | GetInstalledPrinters()

;}
;{   printerfunctions.ahk

;Functions:
0040 | GetDefaultPrinter()
0048 | SetDefaultPrinter(sPrinter)

;}
;{   Process.ahk

;Functions:
0016 | Process_GetImageFileName(nPid)
0058 | Process_GetParentPid(nPid)

;}
;{   ProcessInfo.ahk

;Functions:
0018 | ProcessInfo_GetCurrentProcessID()
0022 | ProcessInfo_GetCurrentParentProcessID()
0026 | ProcessInfo_GetProcessName(ProcessID)
0030 | ProcessInfo_GetParentProcessID(ProcessID)
0034 | ProcessInfo_GetProcessThreadCount(ProcessID)
0038 | ProcessInfo_GetProcessInformation(ProcessID, CallVariableType, VariableCapacity, DataOffset)

;}
;{   Property.ahk

;Functions:
0041 | Property_Add(HParent, X=0, Y=0, W=200, H=100, Style="", Handler="")
0053 | Property_Clear(HCtrl)
0057 | Property_Count(HCtrl)
0071 | Property_Define(HCtrl, ComboEvent=false)
0124 | Property_Remove(hCtrl, PropertyNames)
0147 | Property_Find(hCtrl, Name, StartAt=0)
0164 | Property_ForEach(hCtrl, SkipSeparators=TRUE)
0192 | Property_GetParam(hCtrl, Name)
0210 | Property_GetValue( hCtrl, Name )
0242 | Property_Insert(hCtrl, Properties, Position=0)
0347 | Property_InsertFile( hCtrl, FileName, ParseIni = false )
0393 | Property_Save(hCtrl, FileName, ComboEvent=false)
0409 | Property_Set( hCtrl, Name, Value, Param="")
0426 | Property_SetColSize(HCtrl, C=120)
0449 | Property_SetColors(hCtrl, Colors)
0468 | Property_SetFont(HCtrl, Element, Font)
0490 | Property_SetParam( HCtrl, Name, Param)
0505 | Property_SetRowHeight(hCtrl, Height)
0514 | Property_add2Form(hParent, Txt, Opt)
0520 | Property_handler(hCtrl, event, earg, col, row)
0573 | Property_initSheet(hCtrl)

;Labels:
3568 | Property_timer

;}
;{   Qhtm.ahk

;Functions:
0040 | QHTM_Add(Hwnd, X, Y, W, H, Text="", Style="", Handler="", DllPath="")
0093 | QHTM_AddHtml(hCtrl, HTML, bScroll=false)
0114 | QHTM_AdjustControl(hCtrl)
0132 | QHTM_FormReset(hCtrl, FormName )
0149 | QHTM_FormSubmit(hCtrl, FormName )
0170 | QHTM_FormSetSubmitCallback(hCtrl, Fun)
0188 | QHTM_GetDrawnSize(hCtrl, ByRef w, ByRef h)
0209 | QHTM_GetHTMLHeight(DC, HTML, Width)
0223 | QHTM_GetHTML(hCtrl)
0236 | QHTM_GotoLink( hCtrl, LinkName )
0255 | QHTM_Init( DllPath="qhtm.dll" )
0281 | QHTM_LoadFromFile(hCtrl, FileName)
0302 | QHTM_LoadFromResource(hCtrl, Name, Resource="")
0331 | QHTM_MsgBox(HTML, Caption="", Type="", HGui = 0 )
0359 | QHTM_PrintCreateContext()
0373 | QHTM_PrintDestroyContext(Context)
0389 | QHTM_PrintSetText(Context, HTML)
0404 | QHTM_PrintSetTextFile( Context, FileName )
0420 | QHTM_PrintLayout(Context, DC, PRECT)
0439 | QHTM_PrintPage(Context, DC, PageNum, PRECT)
0459 | QHTM_PrintGetHTMLHeight(DC, HTML, PrintWidth, ZoomLevel=2 )
0475 | QHTM_RenderHTML(DC, HTML, Width)
0490 | QHTM_RenderHTMLRect(DC, HTML, PRECT)
0507 | QHTM_SetHTMLButton( hButton, Adjust=false )
0535 | QHTM_SetHTMLListbox( hListbox, Adjust = true )
0553 | QHTM_ShowScrollbars(hCtrl, bShow)
0569 | QHTM_Zoom(hCtrl, Level=2)
0583 | QHTM_add2Form(hParent, Txt, Opt)
0589 | QHTM_onForm(hwndQHTM, pFormSubmit, lParam)
0604 | QHTM_onNotify(Wparam, Lparam, Msg, Hwnd)
0627 | QHTM_strAtAdr(adr)

;}
;{   QMsgBox.ahk

;Functions:
0001 | QMsgBoxF( title = "", msg = "", sBtns = "OK", icon = "", centered = True, modal = False )
0014 | __New( params )
0021 | _GetFreeGui()
0037 | SetParams( params )
0052 | Destroy()
0059 | __Delete()
0065 | __Get( name )
0070 | _ChangeModal( mode )
0084 | _GetPos()
0105 | _AddPic()
0163 | Show( pGuis = "" )


;}
;{   QMsgBox_foos.ahk

;Functions:
0001 | HBITMAPfromHICON( hIcon )
0011 | Gdip_Startup()
0021 | Gdip_Shutdown(pToken)
0029 | StrSplit(str,delim,omit = "")
0043 | IconExtract( pPath, pNum=0, size = 32 )
0062 | LoadDllFunction( file, function )
0070 | PathUnquoteSpaces( path )
0079 | IconGetPath(Ico)
0087 | IconGetIndex(Ico)
0099 | IsInteger( var )

;}
;{   Query.ahk

;Functions:
0015 | Query_Interface(pobj, IID = "", bRaw = "")
0021 | Query_Guid4String(ByRef GUID, sz = "")
0026 | Query_String4Guid(pGUID)

;}
;{   RaGrid.ahk

;Functions:
0046 | RG_Add(HParent,X,Y,W,H, Style="", Handler="", DllPath="")
0115 | RG_AddColumn(hGrd, o1="", o2="", o3="", o4="", o5="", o6="", o7="", o8="", o9="", o10="")
0164 | RG_AddRow(hGrd, Row="", c1="", c2="", c3="", c4="", c5="", c6="", c7="", c8="", c9="", c10="")
0191 | RG_CellConvert(hGrd, Col="", Row="")
0210 | RG_ComboAddString(hGrd, Col, Items)
0221 | RG_ComboClear(hGrd, Col)
0235 | RG_EnterEdit(hGrd, Col="", Row="")
0252 | RG_EndEdit(hGrd, Col="", Row="", bCancel=1)
0268 | RG_DeleteRow(hGrd, Row="")
0280 | RG_GetCell(hGrd, Col="", Row="")
0302 | RG_GetCellRect(hGrd, Col="", Row="", ByRef Top="", ByRef Left="", ByRef Right="", ByRef Bottom="")
0321 | RG_GetColFormat(hGrd, Col="")
0334 | RG_GetColCount(hGrd)
0347 | RG_GetColWidth(hGrd, Col="")
0365 | RG_GetColors(hGrd, pQ, ByRef o1="", ByRef o2="", ByRef o3="")
0390 | RG_GetColumn(hGrd, Col="", pQ="type", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="", ByRef o7="", ByRef o8="",ByRef o9="", ByRef o10="")
0421 | RG_GetCurrentCell(hGrd, ByRef Col, ByRef Row)
0431 | RG_GetCurrentCol(hGrd)
0440 | RG_GetCurrentRow(hGrd)
0450 | RG_GetHdrHeight(hGrd)
0460 | RG_GetHdrText(hGrd, Col="")
0477 | RG_GetRowColor(hGrd, Row="", ByRef B="", ByRef F="")
0490 | RG_GetRowHeight(hGrd)
0501 | RG_GetRowCount(hGrd)
0515 | RG_MoveRow(hGrd, From, To )
0525 | RG_ResetContent(hGrd)
0535 | RG_ResetColumns(hGrd)
0545 | RG_ScrollCell(hGrd)
0559 | RG_SetCell(hGrd, Col="", Row="", Value="")
0581 | RG_SetColors(hGrd, Colors)
0600 | RG_SetColWidth(hGrd, Col="", Width=0)
0611 | RG_SetColFormat(hGrd, Col="", Format="")
0622 | RG_SetCurrentRow(hGrd, Row)
0632 | RG_SetCurrentCol(hGrd, Col)
0645 | RG_SetCurrentSel(hGrd, Col, Row)
0658 | RG_SetFont(hGrd, pFont="")
0691 | RG_SetHdrHeight(hGrd, Height=0)
0701 | RG_SetHdrText(hGrd, Col="", Text="")
0716 | RG_SetRowColor(hGrd, Row="", B="", F="")
0730 | RG_SetRowHeight(hGrd, Height)
0744 | RG_Sort(hGrd, Col="", SortType=3)
0751 | RG_getType( Type )
0757 | RG_onNotify(Wparam, Lparam, Msg, Hwnd)
0832 | RG_strAtAdr(adr)
0837 | RaGrid_add2Form(hParent, Txt, Opt)

;}
;{   rand.ahk

;Functions:
0003 | Rand( a=0.0, b=1 )

;}
;{   Random jock StrX() Parsing.ahk

;Functions:
0062 | StrX( H, BS="",BO=0,BT=1, ES="",EO=0,ET=1, ByRef N="" )

;Labels:
6235 | 2Guiclose
3539 | mh1

;}
;{   RandomBezier.ahk

;Functions:
0034 | RandomBezier( X0, Y0, Xf, Yf, O="" )

;}
;{   randomdotorg.ahk

;Functions:
0058 | randomdotorg_integer(num,min,max,base="10",rnd="new")
0108 | randomdotorg_string(num,len,digits=true,upperalpha=true,loweralpha=true,unique=true,rnd="new")
0151 | randomdotorg_password(num,len,rnd="new")
0218 | randomdotorg_randomizelist(list,rnd="new")
0260 | randomdotorg_lottery(tickets,num_main,highest_main,num_bonus="0",highest_bonus="0")
0342 | randomdotorg_sequence(min,max,rnd="new")
0378 | randomdotorg_decimalfraction(num,dec=10,rnd="new")
0417 | randomdotorg_gaussian(num,mean="0.0",stdev="1.0",dec=10,rnd="new")
0491 | randomdotorg_bitmap(save_path="",format="gif",width=64,height=64,zoom=1)
0566 | randomdotorg_noise(save_path="",format="wav",volume=100,channels="stereo",rate=16000,size=8,date="today")
0602 | randomdotorg_quota(ip="")
0690 | httpQuery(byref Result, lpszUrl, POSTDATA="", HEADERS="")
0924 | write_bin(byref bin,filename,size)
0951 | Bin2Hex(ByRef @hex, ByRef @bin, _byteNb=0)

;}
;{   RandomUniqNum.ahk

;Functions:
0003 | RandomUniqNum(Min,Max,N)

;}
;{   RandomVar.ahk

;Functions:
0034 | RandomVar(p_MinLength,p_MaxLength,p_Type="",p_MinAsc=32,p_MaxAsc=126)

;}
;{   range.ahk

;Functions:
0015 | _RangeNewEnum(r)

;}
;{   RapidHotkey.ahk

;Functions:
0973 | RapidHotkey(keystroke, times="2", delay=0.2, IsLabel=0)
1035 | Morse(timeout = 400)

;}
;{   ReadIni.ahk

;Functions:
0006 | ReadIni()
0138 | Append2Ini(Setting,file)
0145 | ReadCountersIni()
0164 | ReadPlaySoundIni()
0182 | CreateDefaultIni()

;}
;{   ReadMultiCaretIni.ahk

;Functions:
0013 | ReadMultiCaretIni()
0040 | MultiCaretIni(ini)

;}
;{   readResource.ahk

;Functions:
0001 | readResource(ByRef Var, Name, Type="#10")

;}
;{   Rebar.ahk

;Functions:
0039 | Rebar_Add(hGui, Style="", hIL="", Pos="", Handler="")
0104 | Rebar_Count(hRebar)
0120 | Rebar_DeleteBand(hRebar, WhichBand)
0144 | Rebar_GetBand(hRebar, WhichBand, pQ="", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="", ByRef o7="")
0191 | Rebar_GetLayout(hRebar)
0209 | Rebar_GetRect(hRebar, WhichBand="", pQ="", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="")
0243 | Rebar_Height(hRebar)
0257 | Rebar_ID2Index(hRebar, Id)
0305 | Rebar_Insert(hRebar, hCtrl, o1="", o2="", o3="", o4="", o5="", o6="", o7="", o8="", o9="")
0328 | Rebar_Lock(hRebar, Lock="")
0352 | Rebar_MoveBand(hRebar, From, To=1)
0373 | Rebar_SetBand(hRebar, WhichBand, o1="", o2="", o3="", o4="", o5="", o6="", o7="", o8="", o9="")
0394 | Rebar_SetBandState(hRebar, WhichBand, State)
0415 | Rebar_SetBandWidth(hRebar, WhichBand, Width)
0443 | Rebar_SetBandStyle(hRebar, WhichBand, Style)
0470 | Rebar_SetLayout(hRebar, Layout)
0523 | Rebar_ShowBand(hRebar, WhichBand, bShow=true)
0535 | Rebar_compileBand(ByRef BAND, hCtrl, ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="", ByRef o7="", ByRef o8="", ByRef o9="")
0594 | Rebar_add2Form(hParent, Txt, Opt)
0620 | Rebar_getStyle( pStyle, pHex = false, ByRef hNegStyle="")
0655 | Rebar_getColor(pColor, pAHK = false)
0678 | Rebar_onNotify(Wparam, Lparam, Msg, Hwnd)
0707 | Rebar_malloc(pSize)
0712 | Rebar_mfree(pAdr)

;}
;{   Rechteck.ahk

;Functions:
0050 | GET_HBITMAP_FROM_Array(wt,ht,Array)

;}
;{   RecordSetADO.ahk

;Functions:
0011 | __New(sql, adoConnection, editable = false)
0023 | IsValid()
0030 | getColumnNames()
0040 | getEOF()
0044 | AddNew()
0051 | MoveNext()
0058 | Delete()
0065 | Update()
0072 | Reset()
0078 | Count()
0086 | Close()
0095 | __Get(propertyName)

;}
;{   RecordSetMySQL.ahk

;Functions:
0016 | __New(db, requestResult)
0030 | IsValid()
0037 | getColumnNames()
0050 | getEOF()
0055 | MoveNext()
0092 | Reset()
0097 | Close()

;}
;{   RecordSetSqlLite.ahk

;Functions:
0016 | __New(db, query)
0033 | Test()
0041 | IsValid()
0048 | getColumnNames()
0052 | getEOF()
0057 | MoveNext()
0125 | Reset()
0146 | Close()

;}
;{   ref.ahk

;Functions:
0005 | IDirectDrawSurface2_lock(p1, p2, p3, p4, p5)

;}
;{   ReFormatTime.ahk

;Functions:
0002 | ReFormatTime( Time, Format, Delimiters )

;}
;{   REG to VBS.ahk

;Functions:
0029 | Convert_REG(_SourceFile)
0129 | Compile_Key(_Key)
0136 | Compile_Container(_Container)
0150 | Compile_CreateKey(_HKEY, _Key)
0155 | Extract_Name(_String)
0170 | Parse_Name(_String)
0185 | Compile_Name(_Name)
0192 | Compile_Value(_Value, _Type)
0276 | Compile_Statement(_HKEY, _Key, _Name, _Type, _Value)

;}
;{   Regex.ahk

;Functions:
0012 | __New(N)
0021 | Match(H, N=-1)
0049 | MatchCall(H, F, N=-1)
0071 | MatchSimple(H, Subpat="", N=-1)
0081 | Test(H, N=-1)
0091 | GetGroups(N)

;}
;{   regionGetColor.ahk

;Functions:
0004 | regionGetColor(x, y, w, h, hwnd=0)
0036 | regionGetColor_AvgBitmap(hbmp, pc)
0046 | regionGetColor_SumIntBytes( ByRef arr, len, ByRef a, ByRef r, ByRef g, ByRef b )
0076 | regionGetColor_regionWaitColor(color, X, Y, W, H, hwnd=0, interval=100, timeout=5000, a="", b="", c="")
0089 | regionGetColor_regionCompareColor(color, x, y, w, h, hwnd=0, a="", b="", c="")
0093 | regionGetColor_withinVariation( x, y, a, b="", c="")
0105 | regionGetColor_Variation( x, y )
0111 | regionGetColor_invertColor(x, a = "")
0140 | regionGetColor_CreateCompatibleDC(hdc=0)
0144 | regionGetColor_CreateCompatibleBitmap(hdc, w, h)
0148 | regionGetColor_SelectObject(hdc, hgdiobj)
0152 | regionGetColor_GetDC(hwnd=0)
0156 | regionGetColor_BitBlt( hdc_dest, x1, y1, w1, h1 , hdc_source, x2, y2 , mode )
0163 | regionGetColor_DeleteObject(hObject)
0167 | regionGetColor_DeleteDC(hdc)
0171 | regionGetColor_ReleaseDC(hwnd, hdc)
0175 | regionGetColor_PrintWindow(hwnd, hdc, Flags=0)

;}
;{   ResDllCreate.ahk

;Functions:
0001 | ResDllCreate(path)

;}
;{   ResolveHostname.ahk

;Functions:
0005 | ResolveHostname(hostname)

;}
;{   ResourceID.ahk

;Functions:
0002 | ResourceIdOfIcon(Filename, IconIndex)
0028 | ResourceIdOfIcon_EnumIconResources(hModule, lpszType, lpszName, lParam)

;}
;{   ResourceIndexToId.ahk

;Functions:
0001 | ResourceIndexToId(aModule, aType, aIndex)
0012 | ResourceIndexToIdEnumProc(hModule, lpszType, lpszName, lParam)

;}
;{   ReverseLookup.ahk

;Functions:
0005 | ReverseLookup(ipaddr)

;}
;{   rgbToHex.ahk

;Functions:
0003 | rgbToHex(s, d = "")
0011 | hexToRgb(s, d = "")
0019 | CheckHexC(s, d = "")

;}
;{   RichEdit (2).ahk

;Functions:
0050 | RichEdit_Add(HParent, X="", Y="", W="", H="", Style="", Text="")
0134 | RichEdit_AutoUrlDetect(HCtrl, Flag="" )
0172 | RichEdit_CanPaste(hEdit, ClipboardFormat=0x1)
0189 | RichEdit_CharFromPos(hEdit,X,Y)
0211 | RichEdit_Clear(hEdit)
0227 | RichEdit_Convert(Input, Direction=0)
0246 | RichEdit_Copy(hEdit)
0258 | RichEdit_Cut(hEdit)
0316 | RichEdit_FindText(hEdit, Text, CpMin=0, CpMax=-1, Flags="UNICODE")
0361 | RichEdit_FindWordBreak(hCtrl, CharIndex, Flag="")
0392 | RichEdit_FixKeys(hCtrl)
0414 | RichEdit_GetLine(hEdit, LineNumber=-1)
0446 | RichEdit_GetLineCount(hEdit)
0459 | RichEdit_GetOptions(hCtrl)
0502 | RichEdit_GetCharFormat(hCtrl, ByRef Face="", ByRef Style="", ByRef TextColor="", ByRef BackColor="", Mode="SELECTION")
0567 | RichEdit_GetRedo(hCtrl, ByRef name="-")
0594 | RichEdit_GetModify(hEdit)
0605 | RichEdit_GetParaFormat(hCtrl)
0622 | RichEdit_GetRect(hEdit,ByRef Left="",ByRef Top="",ByRef Right="",ByRef Bottom="")
0650 | RichEdit_GetSel(hCtrl, ByRef cpMin="", ByRef cpMax="" )
0685 | RichEdit_GetText(HCtrl, CpMin="-", CpMax="-", CodePage="")
0769 | RichEdit_GetTextLength(hCtrl, Flags=0, CodePage="")
0815 | RichEdit_GetUndo(hCtrl, ByRef Name="-")
0845 | RichEdit_HideSelection(hCtrl, State=true)
0863 | RichEdit_LineFromChar(hCtrl, CharIndex=-1)
0882 | RichEdit_LineIndex(hEdit, LineNumber=-1)
0901 | RichEdit_LineLength(hEdit, LineNumber=-1)
0921 | RichEdit_LineScroll(hEdit,XScroll=0,YScroll=0)
0942 | RichEdit_LimitText(hCtrl,txtSize=0)
0954 | RichEdit_Paste(hEdit)
0969 | RichEdit_PasteSpecial(HCtrl, Format)
0994 | RichEdit_PosFromChar(hEdit, CharIndex, ByRef X, ByRef Y)
1008 | RichEdit_Redo(hEdit)
1021 | RichEdit_ReplaceSel(hEdit, Text="")
1048 | RichEdit_Save(hCtrl, FileName="")
1064 | RichEdit_ScrollCaret(hEdit)
1087 | RichEdit_ScrollPos(HCtrl, PosString="" )
1117 | RichEdit_SelectionType(hCtrl)
1154 | RichEdit_SetBgColor(hCtrl, Color)
1217 | RichEdit_SetCharFormat(HCtrl, Face="", Style="", TextColor="", BackColor="", Mode="SELECTION")
1323 | RichEdit_SetEvents(hCtrl, Handler="", Events="selchange")
1375 | RichEdit_SetFontSize(hCtrl, Add)
1389 | RichEdit_SetModify(hEdit, State=true)
1420 | RichEdit_SetOptions(hCtrl, Operation, Options)
1447 | RichEdit_PageRotate(hCtrl, R="")
1518 | RichEdit_SetParaFormat(hCtrl, o1="", o2="", o3="", o4="", o5="", o6="")
1601 | RichEdit_SetEditStyle(hCtrl, Style)
1636 | RichEdit_SetSel(hCtrl, CpMin=0, CpMax=0)
1683 | RichEdit_SetText(HCtrl, Txt="", Flag=0, Pos="" )
1746 | RichEdit_SetUndoLimit(hCtrl, nMax)
1776 | RichEdit_ShowScrollBar(hCtrl, Bar, State=true)
1842 | RichEdit_TextMode(HCtrl, TextMode="")
1879 | RichEdit_WordWrap(HCtrl, Flag)
1906 | Richedit_Zoom(hCtrl, zoom=0)
1940 | RichEdit_Undo(hCtrl, Reset=false)
1950 | RichEdit_add2Form(hParent, Txt, Opt)
1958 | RichEdit_onNotify(Wparam, Lparam, Msg, Hwnd)
2029 | RichEdit_wndProc(hwnd, uMsg, wParam, lParam)
2037 | RichEdit_editStreamCallBack(dwCookie, pbBuff, cb, pcb)

;}
;{   RichEdit.ahk

;Functions:
0050 | RichEdit_Add(HParent, X="", Y="", W="", H="", Style="", Text="")
0134 | RichEdit_AutoUrlDetect(HCtrl, Flag="" )
0172 | RichEdit_CanPaste(hEdit, ClipboardFormat=0x1)
0189 | RichEdit_CharFromPos(hEdit,X,Y)
0211 | RichEdit_Clear(hEdit)
0227 | RichEdit_Convert(Input, Direction=0)
0246 | RichEdit_Copy(hEdit)
0258 | RichEdit_Cut(hEdit)
0316 | RichEdit_FindText(hEdit, Text, CpMin=0, CpMax=-1, Flags="UNICODE")
0361 | RichEdit_FindWordBreak(hCtrl, CharIndex, Flag="")
0392 | RichEdit_FixKeys(hCtrl)
0414 | RichEdit_GetLine(hEdit, LineNumber=-1)
0446 | RichEdit_GetLineCount(hEdit)
0459 | RichEdit_GetOptions(hCtrl)
0502 | RichEdit_GetCharFormat(hCtrl, ByRef Face="", ByRef Style="", ByRef TextColor="", ByRef BackColor="", Mode="SELECTION")
0567 | RichEdit_GetRedo(hCtrl, ByRef name="-")
0594 | RichEdit_GetModify(hEdit)
0605 | RichEdit_GetParaFormat(hCtrl)
0622 | RichEdit_GetRect(hEdit,ByRef Left="",ByRef Top="",ByRef Right="",ByRef Bottom="")
0650 | RichEdit_GetSel(hCtrl, ByRef cpMin="", ByRef cpMax="" )
0685 | RichEdit_GetText(HCtrl, CpMin="-", CpMax="-", CodePage="")
0769 | RichEdit_GetTextLength(hCtrl, Flags=0, CodePage="")
0815 | RichEdit_GetUndo(hCtrl, ByRef Name="-")
0845 | RichEdit_HideSelection(hCtrl, State=true)
0863 | RichEdit_LineFromChar(hCtrl, CharIndex=-1)
0882 | RichEdit_LineIndex(hEdit, LineNumber=-1)
0901 | RichEdit_LineLength(hEdit, LineNumber=-1)
0921 | RichEdit_LineScroll(hEdit,XScroll=0,YScroll=0)
0942 | RichEdit_LimitText(hCtrl,txtSize=0)
0954 | RichEdit_Paste(hEdit)
0969 | RichEdit_PasteSpecial(HCtrl, Format)
0994 | RichEdit_PosFromChar(hEdit, CharIndex, ByRef X, ByRef Y)
1008 | RichEdit_Redo(hEdit)
1021 | RichEdit_ReplaceSel(hEdit, Text="")
1048 | RichEdit_Save(hCtrl, FileName="")
1064 | RichEdit_ScrollCaret(hEdit)
1087 | RichEdit_ScrollPos(HCtrl, PosString="" )
1117 | RichEdit_SelectionType(hCtrl)
1154 | RichEdit_SetBgColor(hCtrl, Color)
1217 | RichEdit_SetCharFormat(HCtrl, Face="", Style="", TextColor="", BackColor="", Mode="SELECTION")
1323 | RichEdit_SetEvents(hCtrl, Handler="", Events="selchange")
1375 | RichEdit_SetFontSize(hCtrl, Add)
1389 | RichEdit_SetModify(hEdit, State=true)
1420 | RichEdit_SetOptions(hCtrl, Operation, Options)
1447 | RichEdit_PageRotate(hCtrl, R="")
1518 | RichEdit_SetParaFormat(hCtrl, o1="", o2="", o3="", o4="", o5="", o6="")
1601 | RichEdit_SetEditStyle(hCtrl, Style)
1636 | RichEdit_SetSel(hCtrl, CpMin=0, CpMax=0)
1683 | RichEdit_SetText(HCtrl, Txt="", Flag=0, Pos="" )
1746 | RichEdit_SetUndoLimit(hCtrl, nMax)
1776 | RichEdit_ShowScrollBar(hCtrl, Bar, State=true)
1842 | RichEdit_TextMode(HCtrl, TextMode="")
1879 | RichEdit_WordWrap(HCtrl, Flag)
1906 | Richedit_Zoom(hCtrl, zoom=0)
1940 | RichEdit_Undo(hCtrl, Reset=false)
1950 | RichEdit_add2Form(hParent, Txt, Opt)
1958 | RichEdit_onNotify(Wparam, Lparam, Msg, Hwnd)
2029 | RichEdit_wndProc(hwnd, uMsg, wParam, lParam)
2037 | RichEdit_editStreamCallBack(dwCookie, pbBuff, cb, pcb)

;}
;{   RIni.ahk

;Functions:
0024 | RIni_Create(RVar, Correct_Errors=1)
0042 | RIni_Shutdown(RVar)
0086 | RIni_Read(RVar, File, Correct_Errors=1, Remove_Inline_Key_Comments=0, Remove_Lone_Line_Comments=0, Remove_Inline_Section_Comments=0, Treat_Duplicate_Sections=1, Treat_Duplicate_Keys=1, Read_Blank_Sections=1, Read_Blank_Keys=1, Trim_Spaces_From_Values=0, ByRef RIni_Read_Var = "")
0381 | RIni_AddSection(RVar, Sec)
0400 | RIni_AddKey(RVar, Sec, Key)
0423 | RIni_AppendValue(RVar, Sec, Key, Value, Trim_Spaces_From_Value=0, Removewlines=1)
0460 | RIni_ExpandSectionKeys(RVar, Sec, Amount=1)
0483 | RIni_ContractSectionKeys(RVar, Sec)
0498 | RIni_ExpandKeyValue(RVar, Sec, Key, Amount=1)
0534 | RIni_ContractKeyValue(RVar, Sec, Key)
0558 | RIni_SetKeyValue(RVar, Sec, Key, Value, Trim_Spaces_From_Value=0, Removewlines=1)
0594 | RIni_DeleteSection(RVar, Sec)
0630 | RIni_DeleteKey(RVar, Sec, Key)
0667 | RIni_GetSections(RVar, Delimiter=",")
0687 | RIni_GetSectionKeys(RVar, Sec, Delimiter=",")
0711 | RIni_GetKeyValue(RVar, Sec, Key, Default_Return="")
0735 | RIni_CopyKeys(From_RVar, To_RVar, From_Section, To_Section, Treat_Duplicate_Keys=2, Copy_Key_Values=1, Copy_Key_Comments=1, Copy_Blank_Keys=1)
0804 | RIni_Merge(From_RVar, To_RVar, Treat_Duplicate_Sections=1, Treat_Duplicate_Keys=2, Merge_Blank_Sections=1, Merge_Blank_Keys=1)
1030 | RIni_GetKeysValues(RVar, ByRef Values, Key, Delimiter=",", Default_Return="")
1052 | RIni_AppendTopComments(RVar, Comments)
1070 | RIni_SetTopComments(RVar, Comments)
1089 | RIni_AppendSectionComment(RVar, Sec, Comment)
1123 | RIni_SetSectionComment(RVar, Sec, Comment)
1154 | RIni_AppendSectionLLComments(RVar, Sec, Comments)
1188 | RIni_SetSectionLLComments(RVar, Sec, Comments)
1219 | RIni_AppendKeyComment(RVar, Sec, Key, Comment)
1262 | RIni_SetKeyComment(RVar, Sec, Key, Comment)
1323 | RIni_GetSectionComment(RVar, Sec, Default_Return="")
1367 | RIni_GetKeyComment(RVar, Sec, Key, Default_Return="")
1526 | RIni_VariableToRIni(RVar, ByRef Variable, Correct_Errors=1, Remove_Inline_Key_Comments=0, Remove_Lone_Line_Comments=0, Remove_Inline_Section_Comments=0, Treat_Duplicate_Sections=1, Treat_Duplicate_Keys=1, Read_Blank_Sections=1, Read_Blank_Keys=1, Trim_Spaces_From_Values=0)
1532 | RIni_CopySectionNames(From_RVar, To_RVar, Treat_Duplicate_Sections=1, CopySection_Comments=1, Copy_Blank_Sections=1)
1588 | RIni_CopySection(From_RVar, To_RVar, From_Section, To_Section, Copy_Lone_Line_Comments=1, CopySection_Comment=1, Copy_Key_Values=1, Copy_Key_Comments=1, Copy_Blank_Keys=1)
1643 | RIni_CloneKey(From_RVar, To_RVar, From_Section, To_Section, From_Key, To_Key)
1691 | RIni_RenameSection(RVar, From_Section, To_Section)
1730 | RIni_RenameKey(RVar, Sec, From_Key, To_Key)
1763 | RIni_SortSections(RVar, Sort_Type="")
1799 | RIni_SortKeys(RVar, Sec, Sort_Type="")
1813 | RIni_AddSectionsAsKeys(RVar, To_Section, Include_To_Section=0, Convert_Comments=1, Treat_Duplicate_Keys=1, Blank_Key_Values_On_Replace=1)
1866 | RIni_AddKeysAsSections(RVar, From_Section, Include_From_Section=0, Treat_Duplicate_Sections=1, Convert_Comments=1, Blank_Sections_On_Replace=1)
1950 | RIni_AlterSectionKeys(RVar, Sec, Alter_How=1)
2002 | RIni_CountSections(RVar)
2013 | RIni_CountKeys(RVar, Sec="")
2043 | RIni_AutoKeyList(RVar, Sec, List, List_Delimiter, Key_Prefix="Key", Returnw_Keys_List=1, New_Key_Delimiter=",", Trim_Spaces_From_Value=0)
2099 | RIni_SwapSections(RVar, Section_1, Section_2)
2136 | RIni_ExportKeysToGlobals(RVar, Sec, Replace_If_Exists=0, Replace_Spaces_with="_")
2162 | RIni_SectionExists(RVar, Sec)
2173 | RIni_KeyExists(RVar, Sec, Key)
2187 | RIni_FindKey(RVar, Key)
2208 | RIni_CalcMD5(_String)

;}
;{   RomanNumbers.ahk

;Functions:
0034 | Dec2Roman(p_Number,p_AllowNegative=false)
0052 | Roman2Dec(p_RomanStr,p_AllowNegative=false)

;}
;{   RXMS.ahk

;Functions:
0001 | RXMS(ByRef _String, _Needle, _Options="")
0191 | CSV(Text, Delimiter=",", Literal="""")

;}
;{   SB (2).ahk

;Functions:
0027 | SB_GetPos(hwnd, Which="V")
0032 | SB_SetPos(hwnd, Which="V", To="0")
0037 | SB_GetRange(hwnd, Which="V")
0043 | SB_Show(hwnd, Which="V")
0048 | SB_Hide(hwnd, Which="V")
0053 | SB_LineUP(hwnd, Which="V")
0059 | SB_LineDown(hwnd, Which="V")
0065 | SB_PageUp(hwnd, Which="V")
0071 | SB_PageDown(hwnd, Which="V")
0077 | SB_Top(hwnd, Which="V")
0083 | SB_Bottom(hwnd, Which="V")

;}
;{   SB.ahk

;Functions:
0005 | SB_SetProgress(Value=0,Seg=1,Ops="")

;}
;{   sc.ahk

;Functions:
0029 | sc_CaptureScreen(aRect = 0, bCursor = False, sFile = "", nQuality = "")
0089 | sc_CaptureCursor(hDC, nL, nT)
0114 | sc_Zoomer(hBM, nW, nH, znW, znH)
0131 | sc_Convert(sFileFr = "", sFileTo = "", nQuality = "")
0183 | sc_CreateDIBSection(hDC, nW, nH, bpp = 32, ByRef pBits = "")
0193 | sc_SaveHBITMAPToFile(hBitmap, sFile)
0204 | sc_SetClipboardData(hBitmap)
0219 | sc_Unicode4Ansi(ByRef wString, sString)
0227 | sc_Ansi4Unicode(pString)

;}
;{   Scheduler.ahk

;Functions:
0043 | Scheduler_Create( v, bForce=false )
0108 | Scheduler_ClearVar(v)
0123 | Scheduler_Delete( Name, bForce=false, User="", Password="", Computer="")
0148 | Scheduler_Query(Name="", var="")
0189 | Scheduler_Exists(Name)
0204 | Scheduler_Enable( Name, Value )
0217 | Scheduler_Open()
0233 | Scheduler_fixData( Field, Value )
0242 | Scheduler_run(Cmd, Dir = "", Skip=0, Input = "", Stream = "")

;}
;{   SciteOutPut.ahk

;Functions:
0001 | SciTE_Output(Text,Clear=1,LineBreak=1,Exit=0)

;}
;{   scriptCompile.ahk

;Functions:
0032 | scriptCompile(c_SourceFile, c_DestFile, c_SourceIcon="", c_IncludeDir="", c_IncludeDirTarget="")

;}
;{   ScrollBar.ahk

;Functions:
0037 | ScrollBar_Add(HParent, X, Y, W="", H="", Handler="", o1="", o2="", o3="", o4="", o5="")
0105 | ScrollBar_Get(HCtrl, pQ="", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="")
0135 | ScrollBar_Set(HCtrl, Pos="", Min="", Max="", Page="", Redraw="")
0166 | ScrollBar_SetPos(HCtrl, Pos=1)
0179 | ScrollBar_Enable(HCtrl, Enable=true)
0199 | ScrollBar_Show(HCtrl, Show=true)
0206 | ScrollBar_add2Form(hParent, Txt, Opt)
0218 | ScrollBar_onScroll(Wparam, Lparam, Msg)

;}
;{   Scroller.ahk

;Functions:
0012 | Scroller_Init()
0047 | Scroller_UpdateBars(Hwnd, Bars=3, MX=0, MY=0)
0095 | Scroller_getScrollArea(Hwnd, ByRef left, ByRef top, ByRef right, ByRef bottom)
0114 | Scroller_onScroll(WParam, LParam, Msg, Hwnd)

;}
;{   Service.ahk

;Functions:
0079 | Service_Start(ServiceName)
0105 | Service_Stop(ServiceName)
0131 | Service_State(ServiceName)
0166 | Service_Add(ServiceName, BinaryPath, StartType="")
0200 | Service_Delete(ServiceName)
0224 | _GetName_(DisplayName)

;}
;{   SetBtnTxtColor.ahk

;Functions:
0020 | SetBtnTxtColor(HWND, TxtColor)

;Labels:
0120 | CreateImageButton_FreeBitmaps
0124 | CreateImageButton_GDIPShutdown

;}
;{   SetEditPlaceholder.ahk

;Functions:
0011 | SetEditPlaceholder(control, string, showalways = 0)

;}
;{   SetExeSubsystem.ahk

;Functions:
0005 | SetExeSubsystem(exepath, subSys)

;}
;{   SetIcon.ahk

;Functions:
0020 | SetIcon(text,script)

;}
;{   Settings.ahk

;Functions:
0010 | Settings_Get()
0020 | Settings_Validate(j)
0029 | Settings_Default(key="")
0049 | Settings_Save(j)
0059 | Settings_InstallGet(f)
0071 | Settings_InstallSave(f,j)

;}
;{   SGDIPrint.ahk

;Functions:
0051 | SGDIPrint_GDIPStartup()
0065 | SGDIPrint_EnumPrinters()
0090 | SGDIPrint_GetDefaultPrinter()
0112 | SGDIPrint_GetHDCfromPrinterName(pPrinterName, dmOrientation = 0, dmColor = 0, dmCopies = 0)
0177 | SGDIPrint_GetHDCfromPrintDlg()
0240 | SGDIPrint_GetMatchingBitmap(width = "g", height = "g", color = 0xFFFFFF)
0264 | SGDIPrint_DeleteBitmap(pBitmap)
0274 | SGDIPrint_BeginDocument(hDC, Document_Name)
0287 | SGDIPrint_printerfriendlyGraphicsFromBitmap(pBitmap)
0298 | SGDIPrint_CopyBitmapToPrinterHDC(pBitmap, hDC)
0311 | SGDIPrint_printerfriendlyGraphicsFromHDC(hDC)
0444 | SGDIPrint_DeleteGraphics(G)
0453 | SGDIPrint_NextPage(hDC)
0463 | SGDIPrint_EndDocument(hDC)
0473 | SGDIPrint_AbortDocument(hDC)
0484 | SGDIPrint_GDIPShutdown(pToken)

;}
;{   shell.ahk

;Functions:
0001 | GetCommandLineAsList(index = 0)
0023 | GetCommandLineValueB(switch, value = "")
0032 | GetCommandLineValue(switch, value = "")
0041 | HijackShortCut(lnk, newTarget, abspath = False, cmdline = False)
0059 | GetScriptParamsAsList()
0068 | GetScriptParams()
0077 | getRunCommand(path = False)
0087 | RunAsAdmin(condition = False, foo = "temp", args = "")
0122 | GetCommonPath( csidl )

;}
;{   ShellContextMenu.ahk

;Functions:
0009 | Shell_ContextMenu(Path)
0044 | WindowProc(hWnd, nMsg, wParam, lParam)

;}
;{   ShellContextMenu2.ahk

;Functions:
0030 | ShellContextMenu(sPath,idn)
0090 | WindowProc(hWnd, nMsg, wParam, lParam)
0105 | VTable(ppv, idx)
0108 | QueryInterface(ppv, ByRef IID)
0114 | AddRef(ppv)
0117 | Release(ppv)
0120 | GUID4String(ByRef CLSID, String)
0125 | CoTaskMemAlloc(cb)
0128 | CoTaskMemFree(pv)
0131 | Unicode4Ansi(ByRef wString, sString, nSize = "")

;}
;{   ShellFileOperation.ahk

;Functions:
0014 | ShellFileOperation( fileO=0x0, fSource="", fTarget="", flags=0x0, ghwnd=0x0 )

;}
;{   ShowOCRUnderMouse.ahk

;Functions:
0100 | RunWaitEx(CMD, CMDdir, CMDin, ByRef CMDout, ByRef CMDerr)

;Labels:
0045 | GetTextUnderMouse
5108 | GDIplusError
8111 | GDIplusEnd
1117 | GuiEscape
7118 | ExitMe

;}
;{   Sift.ahk

;Functions:
0174 | Sift_Ngram_Compare(ByRef Hay, ByRef Needle)
0201 | Sift_SortResults(ByRef Data)

;}
;{   sizeof.ahk

;Functions:
0021 | sizeof(_TYPE_,parent_offset=0,ByRef _align_total_=0)
0190 | sizeof_maxsize(s)

;}
;{   socket.ahk

;Functions:
0023 | __Delete()
0029 | Connect(Address)
0054 | Bind(Address)
0079 | Listen(backlog=32)
0084 | Accept()
0095 | Disconnect()
0109 | MsgSize()
0166 | GetAddrInfo(Address)
0178 | OnMessage(wParam, lParam, Msg, hWnd)
0191 | EventProcRegister(lEvent)
0201 | EventProcUnregister()
0211 | AsyncSelect(lEvent)
0221 | GetLastError()
0238 | SetBroadcast(Enable)

;}
;{   sound.ahk

;Functions:
0024 | Sound_Open(File, Alias="")
0058 | Sound_Close(SoundHandle)
0074 | Sound_Play(SoundHandle, Wait=0)
0094 | Sound_Stop(SoundHandle)
0097 | If(r AND r2)
0114 | Sound_Pause(SoundHandle)
0128 | Sound_Resume(SoundHandle)
0142 | Sound_Length(SoundHandle)
0160 | Sound_Seek(SoundHandle, Hour, Min, Sec)
0182 | Sound_Status(SoundHandle)
0195 | Sound_Pos(SoundHandle)
0205 | Sound_SendString(string, UseSend=0, ReturnTemp=0)

;}
;{   Splitter.ahk

;Functions:
0045 | Splitter_Add(Opt="", Text="", Handler="")
0072 | Splitter_Add2Form(HParent, Txt, Opt)
0086 | Splitter_GetMax(HSep)
0091 | Splitter_GetMin(HSep)
0105 | Splitter_GetPos( HSep, Flag="" )
0117 | Splitter_GetSize(HSep)
0140 | Splitter_Set( HSep, Def, Pos="", Limit=0.0 )
0171 | Splitter_SetPos(HSep, Pos, bInternal=false)
0205 | Splitter_wndProc(Hwnd, UMsg, WParam, LParam)
0261 | Splitter_updateFocus( HSep="" )

;}
;{   SpreadSheet.ahk

;Functions:
0047 | SS_Add(HParent,X,Y,W,H, Style="", Handler="", DllPath="")
0093 | SS_BlankCell(hCtrl, Col="", Row="")
0112 | SS_CreateCombo(hCtrl, Content, Height=150)
0140 | SS_ConvertDate(hCtrl, Date, RefreshFormat=false)
0172 | SS_DeleteCell(hCtrl, Col="", Row="")
0187 | SS_DeleteCol(hCtrl, Col="")
0204 | SS_DeleteRow(hCtrl, Row="")
0220 | SS_ExpandCell(hCtrl, Left, Top, Right, Bottom )
0239 | SS_GetCell(hCtrl, Col, Row, pQ, ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="")
0305 | SS_GetCellArray(hCtrl, V, Col="", Row="")
0357 | SS_GetCellBLOB(EArg, GetText=false)
0372 | SS_GetCellData(hCtrl, Col="", Row="")
0392 | SS_GetCellRect(hCtrl, ByRef top, ByRef left, ByRef right, ByRef bottom)
0415 | SS_GetCellText(hCtrl, Col="", Row="")
0472 | SS_GetCellType(hCtrl, Col="", Row="", Flag=0)
0487 | SS_GetColCount(hCtrl)
0497 | SS_GetColWidth(hCtrl, col)
0510 | SS_GetCurrentCell(hCtrl, ByRef Col, ByRef Row)
0523 | SS_GetCurrentCol(hCtrl)
0538 | SS_GetCurrentRow(hCtrl)
0550 | SS_GetCurrentWin(hCtrl)
0560 | SS_GetDateFormat(hCtrl)
0577 | SS_GetGlobalFields(hCtrl, Fields, ByRef v1="", ByRef v2="", ByRef v3="", ByRef v4="", ByRef v5="", ByRef v6="", ByRef v7="")
0612 | SS_GetLockCol(hCtrl)
0622 | SS_GetLockRow(hCtrl)
0635 | SS_GetMultiSel(hCtrl, ByRef Top="", ByRef Left="", ByRef Right="", ByRef Bottom="")
0647 | SS_GetRowCount(hCtrl)
0657 | SS_GetRowHeight(hCtrl, Row)
0686 | SS_InsertCol(hCtrl, Col=-1)
0703 | SS_InsertRow(hCtrl, Row=-1)
0721 | SS_LoadFile(hCtrl, File)
0731 | SS_NewSheet(hCtrl)
0741 | SS_ReCalc(hCtrl)
0751 | SS_Redraw(hCtrl)
0760 | SS_SaveFile(hCtrl, File)
0770 | SS_ScrollCell(hCtrl)
0828 | SS_SetCell(hCtrl, Col="", Row="", o1="", o2="", o3="", o4="", o5="", o6="", o7="", o8="", o9="", o10="", o11="")
0936 | SS_SetCellData(hCtrl, Data, Col="", Row="")
0958 | SS_SetCellBLOB(hCtrl, ByRef BLOB, Col="", Row="")
0978 | SS_SetCellString(hCtrl, Txt="", Type="")
0990 | SS_SetColWidth(hCtrl, Col, Width)
1003 | SS_SetCurrentCell(hCtrl, Col, Row)
1016 | SS_SetCurrentWin(hCtrl, Win)
1030 | SS_SetDateFormat(hCtrl, Format)
1040 | SS_SetColCount(hCtrl, nCols)
1057 | SS_SetFont(HCtrl, Idx, Font)
1128 | SS_SetGlobal(hCtrl, g, cell, colhdr, rowhdr, winhdr)
1191 | SS_SetGlobalFields(hCtrl, Fields, v1="", v2="", v3="", v4="", v5="", v6="", v7="")
1230 | SS_SetLockCol(hCtrl, Cols=1)
1243 | SS_SetLockRow(hCtrl, Rows=1)
1253 | SS_SetMultiSel(hCtrl, Left, Top, Right, Bottom )
1264 | SS_SetRowCount(hCtrl, nRows)
1278 | SS_SetRowHeight(hCtrl, Row=0, Height=0)
1289 | SS_SplittHor(hCtrl)
1299 | SS_SplittVer(hCtrl)
1309 | SS_SplittClose(hCtrl)
1319 | SS_SplittSync(hCtrl, Flag=1 )
1327 | SpreadSheet_add2Form(hParent, Txt, Opt)
1337 | SS_onNotify(wparam, lparam, msg, hwnd)
1390 | SS_onDrawItem(wParam, lParam, msg, hwnd)
1411 | SS_getType( pType )
1433 | SS_getState( pState )
1461 | SS_getAlign( pAlign )
1491 | SS_getCellFloat(hCtrl, col, row)
1502 | SS_strAtAdr(adr)

;}
;{   SQLite.ahk

;Functions:
0132 | _SQLite_Startup()
0152 | _SQLite_Shutdown()
0174 | _SQLite_OpenDB($sDBFile)
0214 | _SQLite_CloseDB($hDB)
0268 | _SQLite_GetTable($hDB, $sSQL, ByRef $sResult, ByRef $iRows, ByRef $iCols, $iMaxResult = -1, $iCharSize = 64)
0389 | _SQLite_Exec($hDB, $sSQL)
0434 | _SQlite_Query($hDB, $sSQL)
0482 | _SQLite_FetchNames($hQuery, ByRef $sNames)
0542 | _SQLite_FetchData($hQuery, ByRef $sRow)
0639 | _SQLite_QueryFinalize($hQuery)
0683 | _SQLite_QueryReset($hQuery)
0725 | _SQLite_SQLiteExe($sDBFile, $sInput, ByRef $sOutput)
0799 | _SQLite_LibVersion()
0820 | _SQLite_LastInsertRowID($hDB, ByRef $iRow)
0857 | _SQLite_Changes($hDB, ByRef $iRows)
0895 | _SQLite_TotalChanges($hDB, ByRef $iRows)
0932 | _SQLite_ErrMsg($hDB, ByRef $sErr)
0969 | _SQLite_ErrCode($hDB, ByRef $sErr)
1005 | _SQLite_SetTimeout($hDB, $iTimeout = 1000)
1054 | _#SQLite_ExtractInt(ByRef $pResult, $pOffset = 0, $pIsSigned = false, $pSize = 4)
1080 | _#SQLite_CheckDB($hDB)
1105 | _#SQLite_CheckQuery($hQuery)

;}
;{   SQLite_L.ahk

;Functions:
0099 | SQLite_Startup()
0128 | SQLite_Shutdown()
0140 | SQLite_OpenDB(DBFile)
0176 | SQLite_IsFilePathValid(path)
0196 | SQLite_CloseDB(DB)
0236 | SQLite_GetTable(DB, SQL, ByRef Rows, ByRef Cols, ByRef Names, ByRef Result, MaxResult = -1)
0309 | SQLite_Bind(query, idx, val, type = "auto")
0353 | SQLite_Bind_blob(query, idx, addr, bytes)
0357 | SQLite_Bind_text(query, idx, text)
0362 | SQLite_bind_double(query, idx, double)
0366 | SQLite_bind_int(query, idx, int)
0370 | SQLite_bind_null(query, idx)
0374 | SQLite_Step(query)
0378 | SQLite_Reset(query)
0391 | SQLite_Exec(DB, SQL)
0442 | SQlite_Query(DB, SQL)
0478 | SQLite_FetchNames(Query, ByRef Names)
0518 | SQLite_QueryFinalize(Query)
0549 | SQLite_QueryReset(Query)
0583 | SQLite_SQLiteExe(DBFile, Commands, ByRef Output)
0642 | SQLite_LibVersion()
0660 | SQLite_LastInsertRowID(DB, ByRef rowId)
0686 | SQLite_Changes(DB, ByRef Rows)
0714 | SQLite_TotalChanges(DB, ByRef Rows)
0740 | SQLite_ErrMsg(DB, ByRef Msg)
0766 | SQLite_ErrCode(DB, ByRef Code)
0793 | SQLite_SetTimeout(DB, Timeout = 1000)
0823 | SQLite_LastError(Error = "")
0839 | SQLite_DLLPath(forcedPath = "")
0843 | if(DLLPath == "")
0870 | SQLite_EXEPath(forcedPath = "")
0895 | _SQLite_StrToUTF8(Str, ByRef UTF8)
0903 | _SQLite_UTF8ToStr(UTF8, ByRef Str)
0911 | _SQLite_ModuleHandle(Handle = "")
0921 | _SQLite_CurrentDB(DB = "")
0931 | _SQLite_CheckDB(DB, Action = "")
0953 | _SQLite_CurrentQuery(Query = "")
0963 | _SQLite_CheckQuery(Query, DB = "")
0985 | _SQLite_ReturnCode(RC)

;}
;{   SrtSynch.ahk

;Functions:
0006 | SrtSynch(delay_or_framerate, input_subtitle, output_subtitle, delay, is_delay_positive, input_fps, output_fps)

;}
;{   st.ahk

;Functions:
0009 | ST_Dim(ByRef Stack)
0024 | ST_Undim(ByRef Stack)
0035 | ST_Del(ByRef Stack)
0047 | ST_Push(ByRef Stack,Value)
0060 | ST_Pop(ByRef Stack)
0078 | ST_Peek(ByRef Stack)
0093 | ST_Len(ByRef Stack)
0113 | ST_Debug(OnOff="")
0125 | ST_Convert(Value,Mode=0)
0135 | ST_IsValid(ByRef Stack,Dim=0)

;}
;{   StayOnMonitor.ahk

;Functions:
0008 | StayOnMonXY(GW, GH, Mouse = 0, MouseAlternative = 1, Center = 0)
0092 | ReturnXY(X,Y)
0110 | If_Between(Var, Low, High, Reverse = 0)

;}
;{   StdOutToVar (2).ahk

;Functions:
0001 | StdOutToVar(cmd)

;}
;{   StdoutToVar.ahk

;Functions:
0032 | StdoutToVar_CreateProcess(sCmd, bStream = "", sDir = "", sInput = "")

;}
;{   String.ahk

;Functions:
0001 | String_Fill(char, count)
0011 | String_CopyFormat(pattern, string)
0032 | String_IsUpperCase(string)
0044 | String_IsSentenceCase(string)
0056 | String_ToSentenceCase(string)
0070 | String_StripTags(s)
0079 | String_StartsWith(haystack, needle)
0084 | String_IsEqual(haystack, needle, caseSensitive=true)

;}
;{   StrPutVar.ahk

;Functions:
0001 | StrPutVar(string,ByRef var,encoding)

;}
;{   strTail.ahk

;Functions:
0004 | strTail(_Str, _LineNum = 1)
0012 | strTail_last(ByRef _Str)

;}
;{   Struct.ahk

;Functions:
0030 | Struct(_def,_obj="",_name="",_offset=0,_TypeArray=0,_Encoding=0)
0286 | Struct_GetSize(_object,o=0)
0362 | Struct_getVar(var)

;}
;{   StrX.ahk

;Functions:
0002 | StrX( H, BS="",BO=0,BT=1, ES="",EO=0,ET=1, ByRef N="" )

;}
;{   Subprocess.ahk

;Functions:
0055 | __Delete()
0118 | __New(handle)
0123 | __Delete()
0128 | Close()
0164 | ReadLine()
0169 | ReadAll()
0179 | RawRead(ByRef var_or_address, bytes)
0194 | Write(string)
0199 | WriteLine(string)
0204 | RawWrite(ByRef var_or_address, bytes)

;}
;{   SubTitleClass.ahk

;Functions:
0028 | __Delete()
0032 | FreeMemory()
0039 | Destroy()
0044 | Hide()
0048 | Show()
0052 | ToggleVisible()
0056 | isVisible()
0060 | DetectScreenResolutionChange()
0499 | hIcon()
0558 | outline(o)
0586 | dropShadow(d)
0621 | colorMap()
0776 | x1()
0780 | y1()
0784 | x2()
0788 | y2()
0792 | width()
0796 | height()

;}
;{   SUCCEEDED.ahk

;Functions:
0001 | SUCCEEDED(hr)

;}
;{   SurfaceHooks.ahk

;Functions:
0001 | CheckSurface(p1)
0031 | IDirectDrawSurface_lock(p1, p2, p3, p4, p5)
0039 | IDirectDrawSurface_Unlock(p1, p2)

;}
;{   SuspendThread_ResumeThread.ahk

;Functions:
0006 | SuspendThread(ThreadID)
0016 | Wow64SuspendThread(ThreadID)
0026 | ResumeThread(ThreadID)

;}
;{   sXMLget.ahk

;Functions:
0003 | sXMLget( xml, node, attr = "" )

;}
;{   Table.ahk

;Functions:
0265 | Table_Append( TableA, TableB, Mode=0 )
0353 | Table_Between( Table, Column, GreaterThan, LessThan="" )
0459 | Table_Decode( String )
0469 | Table_Deintersect( TableA, TableB, MatchColA="", MatchColB="" )
0610 | Table_Encode( String )
0667 | Table_FromCSV( CSV_Table )
0691 | Table_FromHTML( HTML, StartChar=1 )
0808 | Table_FromListview( scf="" )
0856 | Table_FromLvHWND( hwnd, What_Rows="all" )
1028 | Table_FromXMLNode( XML, RowNode )
1264 | Table_GetColName( Table, Col=1 )
1321 | Table_Header( Table )
1330 | Table_Intersect( TableA, TableB, MatchColA="", MatchColB="" )
1464 | Table_Invert( Table )
1489 | Table_Join( TableA, TableB, JoinType="Left", MatchColA="", MatchColB="" )
1798 | Table_Len( Table )
1807 | Table_RemCols( Table, Columns )
1912 | Table_RenameCol( Table, Column_Names="" )
1928 | Table_Reverse( Table )
1941 | Table_RotateL( Table )
1960 | Table_SetCell( Table, RowID, Column, value )
2121 | Table_SpacePad( Table, MinPadCount=3, PadChar=" " )
2221 | Table_ToCSV( 9_10_Table )
2731 | Table_Transpose( Table )
2940 | Table_Width( Table )

;}
;{   talk.ahk

;Functions:
0044 | __New(Client)
0065 | getVar(Var)
0088 | suspend(timeinms)
0092 | terminate()
0097 | talk_reciever(wParam, lParam)
0156 | talk_send(ByRef StringToSend, ByRef TargetScriptTitle)

;}
;{   Taskbar.ahk

;Functions:
0017 | Taskbar_Count()
0129 | Taskbar_Flash( Hwnd=0, Options="" )
0153 | Taskbar_Focus()
0165 | Taskbar_Disable(bDisable=true)
0179 | Taskbar_GetHandle()
0198 | Taskbar_GetRect( Position, ByRef X="", ByRef Y="", ByRef W="", ByRef H="" )
0236 | Taskbar_Hide(Handle, bHide=True)
0257 | Taskbar_Move(Pos, NewPos)
0281 | Taskbar_Remove(Position)

;}
;{   taskbarInterface.ahk

;Functions:
0033 | showButton(n)
0039 | hideButton(n)
0045 | disableButton(n)
0052 | enableButton(n)
0060 | setButtonImage(n,nIL)
0098 | destroyImageList()
0113 | setButtonIcon(n,hIcon)
0121 | queryButtonIconSize()
0157 | removeButtonBackground(n)
0164 | reAddButtonBackground(n)
0172 | setButtonNonInteractive(n)
0179 | setButtonInteractive(n)
0411 | disableCustomThumbnailPreview()
0473 | disableCustomPeekPreview()
0494 | disallowPeek()
0497 | allowPeek()
0500 | excludeFromPeek()
0503 | unexcludeFromPeek()
0507 | refreshButtons()
0534 | restoreTaskbar()
0542 | stopThisButtonMonitor()
0547 | restartThisButtonMonitor()
0554 | exemptFromHook()
0557 | unexemptFromHook()
0560 | getLastError()
0566 | refreshAllButtons()
0583 | stopAllButtonMonitor()
0589 | restartAllButtonMonitor()
0607 | removeTemplate(n)
0641 | __Delete()
0651 | arrayIsEmpty(arr)
0656 | flashOn(type,flashTime,offTime)
0665 | flashOff(type,flashTime,offTime)
0679 | stopTimer()
0694 | clear()
0713 | freeMemory()
0720 | freeThumbnailPreviewBMP()
0725 | freePeekPreviewBMP()
0730 | PostMessage(hWnd,Msg,wParam,lParam)
0736 | verifyId(iId)
0749 | createButtons()
0811 | getThumbButtonMask(iId)
0816 | getThumbButtonFlags(iId)
0822 | setThumbButtonMask(iId,dwMask)
0827 | setThumbButtoniBitmap(iId,iBitmap)
0833 | setThumbButtonhIcon(iId,hIcon)
0844 | setThumbButtonFlags(iId,dwFlags)
0853 | addTab()
0856 | deleteTab()
0859 | activateTab()
0862 | setActiveAlt()
0865 | clearActiveAlt()
0868 | registerTab()
0871 | ThumbBarAddButtons()
0879 | ThumbBarSetImageList()
0882 | _setThumbnailToolTip()
0885 | setProgressState()
0888 | setProgressValue()
0891 | _setOverlayIcon()
0894 | _setThumbnailClip(rect)
0932 | initInterface()
0989 | clearInterface()
1019 | CoInitialize()
1036 | RegisterWindowMessage(msgName)
1050 | taskbarButtonCreatedMsgHandler(wParam,lParam,msg,hwnd)
1078 | SetWinEventHook()
1099 | ProcessExist()
1104 | UnhookWinEvent()
1192 | turnOffButtonMessages()
1198 | turnOnButtonMessages()
1206 | onButtonClick(wParam,lParam,msg,hWnd)
1224 | startTaskbarMsgMonitor()
1237 | stopTaskbarMsgMonitor()
1247 | WM_DWMSENDICONICTHUMBNAIL(wParam, lParam, msg, hWnd)
1278 | WM_DWMSENDICONICLIVEPREVIEWBITMAP(wParam, lParam, msg, hwnd)
1315 | InvalidateIconicBitmaps()
1320 | Dwm_SetWindowAttributeHasIconicBitmap(hwnd,onOff)
1337 | Dwm_SetWindowAttributeForceIconicRepresentaion(hwnd,onOff)
1456 | Dwm_InvalidateIconicBitmaps(hwnd)
1470 | GlobalAlloc(dwBytes)
1487 | GlobalFree(hMem)
1501 | freeBitmap(hbm)
1505 | GetClientRect(hwnd,ByRef X2, ByRef Y2)
1513 | min(x,y)

;}
;{   taskbarInterface_v2.ahk

;Functions:
0034 | showButton(n)
0040 | hideButton(n)
0046 | disableButton(n)
0053 | enableButton(n)
0061 | setButtonImage(n,nIL)
0099 | destroyImageList()
0114 | setButtonIcon(n,hIcon)
0122 | queryButtonIconSize()
0158 | removeButtonBackground(n)
0165 | reAddButtonBackground(n)
0173 | setButtonNonInteractive(n)
0180 | setButtonInteractive(n)
0414 | disableCustomThumbnailPreview()
0476 | disableCustomPeekPreview()
0497 | disallowPeek()
0500 | allowPeek()
0503 | excludeFromPeek()
0506 | unexcludeFromPeek()
0510 | refreshButtons()
0537 | restoreTaskbar()
0545 | stopThisButtonMonitor()
0550 | restartThisButtonMonitor()
0557 | exemptFromHook()
0560 | unexemptFromHook()
0563 | getLastError()
0569 | refreshAllButtons()
0586 | stopAllButtonMonitor()
0594 | restartAllButtonMonitor()
0617 | removeTemplate(n)
0651 | __Delete()
0663 | arrayIsEmpty(arr)
0668 | flashOn(type,flashTime,offTime)
0677 | flashOff(type,flashTime,offTime)
0691 | stopTimer()
0706 | clear()
0725 | freeMemory()
0732 | freeThumbnailPreviewBMP()
0737 | freePeekPreviewBMP()
0742 | PostMessage(hWnd,Msg,wParam,lParam)
0748 | verifyId(iId)
0761 | createButtons()
0823 | getThumbButtonMask(iId)
0828 | getThumbButtonFlags(iId)
0834 | setThumbButtonMask(iId,dwMask)
0839 | setThumbButtoniBitmap(iId,iBitmap)
0845 | setThumbButtonhIcon(iId,hIcon)
0856 | setThumbButtonFlags(iId,dwFlags)
0866 | addTab()
0869 | deleteTab()
0872 | activateTab()
0875 | setActiveAlt()
0878 | clearActiveAlt()
0881 | registerTab()
0884 | ThumbBarAddButtons()
0892 | ThumbBarSetImageList()
0895 | _setThumbnailToolTip()
0898 | setProgressState()
0901 | setProgressValue()
0904 | _setOverlayIcon()
0907 | _setThumbnailClip(rect)
0946 | initInterface()
1003 | clearInterface()
1033 | CoInitialize()
1050 | RegisterWindowMessage(msgName)
1064 | taskbarButtonCreatedMsgHandler(wParam,lParam,msg,hwnd)
1093 | SetWinEventHook()
1113 | UnhookWinEvent()
1202 | turnOffButtonMessages()
1208 | turnOnButtonMessages()
1216 | onButtonClick(wParam,lParam,msg,hWnd)
1234 | startTaskbarMsgMonitor()
1247 | stopTaskbarMsgMonitor()
1257 | WM_DWMSENDICONICTHUMBNAIL(wParam, lParam, msg, hWnd)
1288 | WM_DWMSENDICONICLIVEPREVIEWBITMAP(wParam, lParam, msg, hwnd)
1325 | InvalidateIconicBitmaps()
1330 | Dwm_SetWindowAttributeHasIconicBitmap(hwnd,onOff)
1347 | Dwm_SetWindowAttributeForceIconicRepresentaion(hwnd,onOff)
1466 | Dwm_InvalidateIconicBitmaps(hwnd)
1481 | GlobalAlloc(dwBytes)
1498 | GlobalFree(hMem)
1512 | freeBitmap(hbm)
1516 | GetClientRect(hwnd,ByRef X2, ByRef Y2)
1524 | min(x,y)

;}
;{   TaskButton (2).ahk

;Functions:
0019 | TaskButton(sExeName = "")
0055 | TaskButton_Hide(idn, bHide = True)
0062 | TaskButton_Delete(idx)
0069 | TaskButton_Move(idxOld, idxNew)
0076 | TaskButton_GetTaskSwBar()

;}
;{   TaskButton.ahk

;Functions:
0019 | TaskButton(sExeName = "")
0055 | TaskButton_Hide(idn, bHide = True)
0062 | TaskButton_Delete(idx)
0069 | TaskButton_Move(idxOld, idxNew)
0076 | TaskButton_GetTaskSwBar()

;}
;{   TaskDialog (2).ahk

;Functions:
0132 | TaskDialog(hParent = 0, sText = "", sButtons = "", iFlags = 0, sIcons = "", sRadios = "", sCallback = "", iWidth = 0, hNavigate = 0)
0399 | TaskDialog_ANSItoWide(ptrANSI, ByRef sWide)
0405 | TaskDialog_WidetoANSI(ptrWide, ByRef sANSI)
0413 | _TaskDialog_PrepSplitString(ByRef sString)
0436 | _TaskDialog_CureStringArray(ByRef sString)
0460 | _TaskDialog_ResolveIcon(sIcon)

;}
;{   TbMenu-proto.ahk

;Functions:
0030 | TbMenu_Create(Style=0x80800044, ExStyle=0, Owner=0)
0059 | TbMenu_Add(tbm, Text, ImageFileOrIndex="", IconNumber=1, State=0x4, Style=0)
0093 | TbMenu_SetMetrics(tbm, xPad="", yPad="", xButtonMargin="", yButtonMargin="", xMargin="", yMargin="")
0106 | TbMenu_SetImageList(tbm, hIL)
0112 | TbMenu_GetImageList(tbm)
0119 | TbMenu_Show(tbm)
0125 | TbMenu_RegisterClass()
0145 | TbMenu_WndProc(hwnd, Msg, wParam, lParam)

;}
;{   TC_EX.ahk

;Functions:
0041 | TC_EX_CreateTCITEM(ByRef TCITEM)
0049 | TC_EX_GetCount(HTC)
0058 | TC_EX_GetFocus(HTC)
0067 | TC_EX_GetIcon(HTC, TabIndex)
0084 | TC_EX_GetInterior(HTC, ByRef X, ByRef Y, ByRef W, ByRef H)
0100 | TC_EX_GetRect(HTC, TabIndex, ByRef X, ByRef Y, ByRef W, ByRef H)
0119 | TC_EX_GetSel(HTC)
0128 | TC_EX_GetText(HTC, TabIndex)
0165 | TC_EX_RemoveLast(HTC)
0183 | TC_EX_SetIcon(HTC, TabIndex, IconIndex)
0200 | TC_EX_SetImageList(HTC, HIL)
0209 | TC_EX_SetFocus(HTC, TabIndex)
0222 | TC_EX_SetMinWidth(HTC, Width)
0238 | TC_EX_SetPadding(HTC, Horizontal, Vertical, Redraw = False)
0256 | TC_EX_SetSel(HTC, TabIndex)
0285 | TC_EX_SetSize(HTC, Width, Height)
0299 | TC_EX_SetText(HTC, TabIndex, TabText)

;}
;{   TermWait.ahk

;Functions:
0045 | TermWait_StopWaiting(pGlobal)
0058 | __TermWait_TermNotifier(pGlobal)

;}
;{   TermWaitLibs.ahk

;Functions:
0095 | __TermWait_TermNotifier(pGlobal)

;}
;{   TexSwapLib.ahk

;Functions:
0004 | initTextSwapHooks(byref config)
0015 | initTextSwapHooks2(byref config)
0026 | initTextSwapHooks2Device3(byref config)
0033 | initTextSwapHooks7(byref config)
0044 | initTextSwapConfig(byref config)
0059 | browseTextures(pBackbuffer, clr = 0x00000000)
0109 | browseTextures2(pBackbuffer, clr = 0x00000000)
0158 | browseDevice3Textures2(pBackbuffer, pddraw, clr = 0x00FFFFFF)
0235 | browseTextures2DC(pBackbuffer, clr = 0x00FFFFFF)
0291 | browseTextures7(pBackbuffer, clr = 0x00000000)
0344 | TextSwapUpdate2Device3(pIDirectDraw)
0388 | TextSwapUpdate2(pIDirectDraw)
0433 | TextSwapUpdate(pIDirectDraw)

;}
;{   TexSwapLibGL.ahk

;Functions:
0003 | InitTextSwapHooksGl(byref config)
0024 | LoadTextureDumpsGl(path = "")

;}
;{   TextureHooks.ahk

;Functions:
0001 | IDirect3DTexture_GetHandle(p1, p2, p3)
0011 | IDirectDrawSurface2_QueryInterface(p1, p2, p3)
0034 | IDirect3DTexture_Release(p1)
0050 | IDirect3DTexture2_GetHandle(p1, p2, p3)
0060 | IDirectDrawSurface_QueryInterface(p1, p2, p3)
0081 | IDirect3DDevice3_SetTexture(p1, p2, p3)
0121 | IDirect3DTexture2_Release(p1)
0137 | UpdateSurface7(k)
0164 | IDirect3DDevice7_SetTexture(p1, p2, p3)
0177 | IDirectDrawSurface7_Release(p1)
0190 | IDirect3DDevice7_Load(p1, p2, p3, p4, p5, p6)

;}
;{   tf.ahk

;Functions:
0047 | TF_CountLines(Text)
0054 | TF_ReadLines(Text, StartLine = 1, EndLine = 0, Trailing = 0)
0070 | TF_ReplaceInLines(Text, StartLine = 1, EndLine = 0, SearchText = "", ReplaceText = "")
0089 | TF_Replace(Text, SearchText, ReplaceText="")
0103 | TF_RegExReplaceInLines(Text, StartLine = 1, EndLine = 0, NeedleRegEx = "", Replacement = "")
0122 | TF_RegExReplace(Text, NeedleRegEx = "", Replacement = "")
0131 | TF_RemoveLines(Text, StartLine = 1, EndLine = 0)
0151 | TF_RemoveBlankLines(Text, StartLine = 1, EndLine = 0)
0167 | TF_RemoveDuplicateLines(Text, StartLine = 1, Endline = 0, Consecutive = 0, CaseSensitive = false)
0202 | TF_InsertLine(Text, StartLine = 1, Endline = 0, InsertText = "")
0216 | TF_ReplaceLine(Text, StartLine = 1, Endline = 0, ReplaceText = "")
0230 | TF_InsertPrefix(Text, StartLine = 1, EndLine = 0, InsertText = "")
0244 | TF_InsertSuffix(Text, StartLine = 1, EndLine = 0 , InsertText = "")
0258 | TF_TrimLeft(Text, StartLine = 1, EndLine = 0, Count = 1)
0275 | TF_TrimRight(Text, StartLine = 1, EndLine = 0, Count = 1)
0292 | TF_AlignLeft(Text, StartLine = 1, EndLine = 0, Columns = 80, Padding = 0)
0321 | TF_AlignCenter(Text, StartLine = 1, EndLine = 0, Columns = 80, Padding = 0)
0353 | TF_AlignRight(Text, StartLine = 1, EndLine = 0, Columns = 80, Skip = 0)
0389 | TF_ConCat(FirstTextFile, SecondTextFile, OutputFile = "", Blanks = 0, FirstPadMargin = 0, SecondPadMargin = 0)
0427 | TF_LineNumber(Text, Leading = 0, Restart = 0, Char = 0)
0464 | TF_ColGet(Text, StartLine = 1, EndLine = 0, StartColumn = 1, EndColumn = 1, Skip = 0)
0487 | TF_ColPut(Text, Startline = 1, EndLine = 0, StartColumn = 1, InsertText = "", Skip = 0)
0509 | TF_ColCut(Text, StartLine = 1, EndLine = 0, StartColumn = 1, EndColumn = 1)
0530 | TF_ReverseLines(Text, StartLine = 1, EndLine = 0)
0564 | TF_SplitFileByLines(Text, SplitAt, Prefix = "file", Extension = "txt", InFile = 1)
0665 | TF_SplitFileByText(Text, SplitAt, Prefix = "file", Extension = "txt", InFile = 1)
0728 | TF_Find(Text, StartLine = 1, EndLine = 0, SearchText = "", ReturnFirst = 1, ReturnText = 0)
0759 | TF_FindLines(Text, StartLine = 1, EndLine = 0, SearchText = "", CaseSensitive = false)
0764 | TF_Prepend(File1, File2)
0775 | TF_Append(File1, File2)
0822 | TF_Wrap(Text, Columns = 80, AllowBreak = 0, StartLine = 1, EndLine = 0)
0848 | TF_WhiteSpace(Text, RemoveLeading = 1, RemoveTrailing = 1, StartLine = 1, EndLine = 0)
0893 | TF_Substract(File1, File2, PartialMatch = 0)
0935 | TF_RangeReplace(Text, SearchTextBegin, SearchTextEnd, ReplaceText = "", CaseSensitive = "False", KeepBegin = 0, KeepEnd = 0)
1001 | TF_MakeFile(Text, Lines = 1, Columns = 1, Fill = " ")
1014 | TF_Tab2Spaces(Text, TabStop = 4, StartLine = 1, EndLine =0)
1022 | TF_Spaces2Tab(Text, TabStop = 4, StartLine = 1, EndLine =0)
1030 | TF_Sort(Text, SortOptions = "", StartLine = 1, EndLine = 0)
1052 | TF_Tail(Text, Lines = 1, RemoveTrailing = 0, ReturnEmpty = 1)
1090 | TF_Count(String, Char)
1096 | TF_Save(Text, FileName, OverWrite = 1)
1100 | TF(TextFile, CreateGlobalVar = "T")
1108 | TF_SetGlobal(var, content = "")
1116 | TF_GetData(byref OW, byref Text, byref FileName)
1156 | TF_SetWidth(Text,Width,AlignText)
1181 | TF_Space(Width)
1188 | TF_ReturnOutPut(OW, Text, FileName, TrimTrailing = 1, CreateNewFile = 0)
1246 | _MakeMatchList(Text, Start = 1, End = 0)

;Labels:
1212 | CreateNewFile

;}
;{   ThousandsSep.ahk

;Functions:
0003 | ThousandsSep(x, s=",")

;}
;{   threadFunc.ahk

;Functions:
0062 | GlobalFree(hMem)

;}
;{   Threads.ahk

;Functions:
0008 | Threads_GetProcessThreadOrList( processID, byRef list="" )
0053 | Threads_GetThreadOfWindow( hWnd=0 )
0076 | Threads_GetThreadOfWindowCallBack( hWnd, lParam )

;}
;{   Title.ahk

;Functions:
0010 | Title(Text)

;}
;{   TO TextOverlay.ahk

;Functions:
0096 | TO_GenerateTree(charstring,fontinfo,forest)
0152 | TO_FindColHorizontal(pBitmap,x,y,findcol)
0169 | TO_FindNotColHorizontal(pBitmap,x,y,findcol)
0186 | TO_FindColVertical(pBitmap,x,y,findcol)
0203 | TO_FindNotColVertical(pBitmap,x,y,findcol,limit=0)
0232 | TO_FindLines(pBitmap,forest,skiplist,gaplist,backgroundcolour)
0374 | TO_WithinBox(x,y,box)
0388 | TO_FindGaps(pBitmap,backgroundcolour,skiplist)
0490 | TO_CreateCharBitmap(char,format)
0510 | TO_GetControlCoords(control,window)
0520 | TO_GetFontlines(format)
0537 | TO_GetLineHeight(pBitmap)
0593 | TO_DivideAndParse(pBitmap,forest,lines,spaceinpixels,skiplist)
0619 | TO_CropCharBitmap(pBitmap,fontlines)
0705 | TO_GetPixelpath(pBitmap)
0748 | TO_AddToPaths(pixelpath,pixeltree,char)
0879 | TO_CompactPixeltree(pixeltree)
0933 | TO_AddToResults(results,lineresults,y1,y2)
0944 | TO_EmptyColumnPath(lineheight)
0954 | TO_ParseBitmap(pBitmap,pixeltree,spaceinpixels,skiplist)
1106 | TO_BelowThresholdBrightness(argb)
1140 | TO_CoordAddition(controlcoords,wareacoords)
1149 | TO_DrawWords(matches,realcoords,selection)
1247 | TO_GenerateMatchnet(matches)
1319 | TO_FindClosestUp(sourcex,sourcey,results)
1343 | TO_FindClosestDown(sourcex,sourcey,results)
1370 | TO_FindClosestLeft(sourcex,sourcey,results)
1392 | TO_FindFarLeft(sourcex,sourcey,results)
1414 | TO_FindClosestRight(sourcex,sourcey,results)
1437 | TO_FindFarRight(sourcex,sourcey,results)
1460 | TO_SkipToNextTerm(matches,matchnet,selection,direction)
1492 | TO_ObjectHaskeys(object,number)
1510 | TO_RecursiveDebug(pixeltree)
1534 | TO_DebugBitmap(pBitmap)

;}
;{   todWulff.ahk

;Functions:
0014 | Paste2(Paste_Content, Paste_Description="", Paste_Language="text")
0068 | ShortURL(LURL)
0116 | jmp_Enc_Uri(uri)
0155 | Goo_gl(url)

;}
;{   tokelex.ahk

;Functions:
0388 | __New(lexerName, keepWhiteSpace=0)
0432 | invalidTokenCheck(byref string)
0452 | string_dropWhitespace(string, ByRef lastTokenDropped = 0)
0477 | string_collapseHWhitespaceAndKeepNewLine(string, ByRef lastTokenDropped = 0)
0500 | string_collapseHWhitespaceAndDropNewLine(string, ByRef lastTokenDropped = 0)
0532 | string_keepWhitespace(string, ByRef lastTokenDropped = 0)
0552 | string_keepHWhitespaceAndDropNewLine(string, ByRef lastTokenDropped = 0)
0579 | string_dropHWhitespaceAndKeepNewLine(string, ByRef lastTokenDropped = 0)
0610 | string_dropWhitespaceLexEnum(string, ByRef lastTokenDropped = 0)
0654 | string_collapseHWhitespaceAndKeepNewLineLexEnum(string, ByRef lastTokenDropped = 0)
0699 | string_collapseHWhitespaceAndDropNewLineLexEnum(string, ByRef lastTokenDropped = 0)
0749 | string_keepWhitespaceLexEnum(string, ByRef lastTokenDropped = 0)
0788 | string_keepHWhitespaceAndDropNewLineLexEnum(string, ByRef lastTokenDropped = 0)
0832 | string_dropHWhitespaceAndKeepNewLineLexEnum(string, ByRef lastTokenDropped = 0)
0881 | string(string)
0891 | openFile(filename, chunkSize=4096)
0902 | __Get_FromString(index, appendToTokenList=0, failOnNoMoreTokens=1)
0916 | __Get_FromFile(index, appendToTokenList=0, failOnNoMoreTokens=1)
1009 | tokenAvailable(pos)
1041 | holdTokens(pos)
1048 | holdTokensRelease()
1057 | holdTokensRevert()
1064 | test()

;}
;{   Toolbar.ahk

;Functions:
0078 | Toolbar_Add(hGui, Handler, Style="", ImageList="", Pos="")
0156 | Toolbar_AutoSize(hCtrl, Align="fit")
0187 | Toolbar_Clear(hCtrl)
0206 | Toolbar_Count(hCtrl, pQ="c")
0230 | Toolbar_CommandToIndex( hCtrl, ID )
0243 | Toolbar_Customize(hCtrl)
0263 | Toolbar_CheckButton(hCtrl, WhichButton, bCheck=1)
0285 | Toolbar_Define(hCtrl, pQ="")
0316 | Toolbar_DeleteButton(hCtrl, Pos=1)
0355 | Toolbar_GetButton(hCtrl, WhichButton, pQ="")
0421 | Toolbar_GetButtonSize(hCtrl, ByRef W, ByRef H)
0438 | Toolbar_GetMaxSize(hCtrl, ByRef Width, ByRef Height)
0458 | Toolbar_GetRect(hCtrl, Pos="", pQ="")
0525 | Toolbar_Insert(hCtrl, Btns, Pos="")
0552 | Toolbar_MoveButton(hCtrl, Pos, NewPos)
0573 | Toolbar_SetBitmapSize(hCtrl, Width=0, Height=0)
0591 | Toolbar_SetButton(hCtrl, WhichButton, State="", Width="")
0650 | Toolbar_SetButtonWidth(hCtrl, Min, Max="")
0675 | Toolbar_SetDrawTextFlags(hCtrl, Mask, Flags)
0691 | Toolbar_SetButtonSize(hCtrl, W, H="")
0708 | Toolbar_SetImageList(hCtrl, hIL="1S")
0734 | Toolbar_SetMaxTextRows(hCtrl, iMaxRows=0)
0749 | Toolbar_ToggleStyle(hCtrl, Style="LIST")
0781 | Toolbar_compileButtons(hCtrl, Btns, ByRef cBTN)
0875 | Toolbar_onNotify(Wparam,Lparam,Msg,Hwnd)
0979 | Toolbar_getButtonArray(hCtrl, ByRef cBtn)
0991 | Toolbar_getStateName( hState )
1008 | Toolbar_getStyleName( hStyle )
1024 | Toolbar_onEndAdjust(hCtrl, cBTN, cnt)
1062 | Toolbar_malloc(pSize)
1067 | Toolbar_mfree(pAdr)
1072 | Toolbar_memmove(dst, src, cnt)
1076 | Toolbar_memcpy(dst, src, cnt)
1081 | Toolbar_add2Form(hParent, Txt, Opt)

;}
;{   ToolTip.ahk

;Functions:
0199 | ToolTip(ID="", text="", title="",options="")
0629 | ToolTip_ExtractIcon(Filename, IconNumber, IconSize)
0653 | ToolTip_GetAssociatedIcon(File)

;Labels:
3389 | TTM_POP
9390 | TTM_POPUP
0391 | TTM_UPDATE
1394 | TTM_TRACKACTIVATE
4397 | TTM_UPDATETIPTEXT
7398 | TTM_GETBUBBLESIZE
8399 | TTM_ADDTOOL
9400 | TTM_DELTOOL
0401 | TTM_SETTOOLINFO
1402 | TTM_NEWTOOLRECT
2405 | TTM_SETTITLEA
5406 | TTM_SETTITLEW
6410 | TTM_SETWINDOWTHEME
0416 | TTM_SETMAXTIPWIDTH
6419 | TTM_TRACKPOSITION
9484 | TTM_SETTIPBKCOLOR
4492 | TTM_SETTIPTEXTCOLOR
2500 | TTM_SETMARGIN
0506 | TT_SETTOOLINFO
6544 | TTN_LINKCLICK
4617 | TT_DESTROY

;}
;{   Tray.ahk

;Functions:
0031 | Tray_Add( hGui, Handler, Icon, Tooltip="")
0068 | Tray_Click(Position, Button="L")
0087 | Tray_Count()
0175 | Tray_Disable(bDisable=true)
0193 | Tray_Focus(hGui="", hTray="")
0225 | Tray_GetRect( Position, ByRef x="", ByRef y="", ByRef w="", ByRef h="" )
0257 | Tray_GetTooltip(Position)
0332 | Tray_Move(Pos, NewPos="")
0354 | Tray_Remove( hGui, hTray="")
0379 | Tray_Refresh()
0391 | Tray_getTrayBar()
0398 | Tray_loadIcon(pPath, pSize=32)
0412 | Tray_onShellIcon(Wparam, Lparam)

;}
;{   TrayIcon (3).ahk

;Functions:
0036 | TrayIcon(sExeName = "")
0076 | TrayIcon_Remove(hWnd, uID, nMsg = 0, hIcon = 0, nRemove = 2)
0088 | TrayIcon_Hide(idn, bHide = True)
0096 | TrayIcon_Delete(idx)
0104 | TrayIcon_Move(idxOld, idxNew)
0111 | TrayIcon_GetTrayBar()

;}
;{   TrayIcon.ahk

;Functions:
0036 | TrayIcon(sExeName = "")
0076 | TrayIcon_Remove(hWnd, uID, nMsg = 0, hIcon = 0, nRemove = 2)
0088 | TrayIcon_Hide(idn, bHide = True)
0096 | TrayIcon_Delete(idx)
0104 | TrayIcon_Move(idxOld, idxNew)
0111 | TrayIcon_GetTrayBar()

;}
;{   TT.ahk

;Functions:
0148 | TT_Init()
0249 | TT_Delete(this)
0274 | TT_OnMessage(wParam,lParam,msg,hwnd)
0346 | TT_DEL(T,Control)
0363 | TT_Text(T,text)
0439 | TT_Close(T)
0608 | TTM_ADDTOOL(T,pTOOLINFO)
0612 | TTM_ADJUSTRECT(T,action,prect)
0616 | TTM_DELTOOL(T,pTOOLINFO)
0620 | TTM_ENUMTOOLS(T,idx,pTOOLINFO)
0624 | TTM_GETBUBBLESIZE(T,pTOOLINFO)
0628 | TTM_GETCURRENTTOOL(T,pTOOLINFO)
0632 | TTM_GETDELAYTIME(T,whichtime)
0637 | TTM_GETMARGIN(T,pRECT)
0645 | TTM_GETTEXT(T,buffer,pTOOLINFO)
0657 | TTM_GETTITLE(T,pTTGETTITLE)
0666 | TTM_GETTOOLINFO(T,pTOOLINFO)
0670 | TTM_HITTEST(T,pTTHITTESTINFO)
0754 | TTM_UPDATE(T)
0761 | TTM_WINDOWFROMPOINT(T,pPOINT)

;}
;{   TVX.ahk

;Functions:
0029 | TVX( pTree, pSub, pOptions="", pUserData="" )
0067 | TVX_Walk(root, label, ByRef event_type, ByRef event_param)
0162 | TVX_Move(item, direction)
0288 | TVX_CopyProc(iType, item)
0331 | TVX_CopyItem(destc, destp, source)
0344 | TVX_OnItemSelect(pItemId)
0372 | TVX_OnKeyPress(pKey)

;Labels:
2324 | _TVX_CopyProc
4430 | TVX_OnEvent

;}
;{   type.ahk

;Functions:
0004 | type(v)
0011 | com_type(ByRef v)

;}
;{   TypeFunctions.ahk

;Functions:
0039 | IsType( p_Input , p_Type )
0064 | VarTypes( p_Input )
0094 | SameTypes( p_Input1 , p_Input2 )
0116 | SameTypes02( p_Input1 , p_Input2 )
0156 | CommonTypes( p_InputList )

;}
;{   uia.ahk

;Functions:
0007 | __new()
0012 | CompareElements(el1,el2)
0022 | CompareRuntimeIds(runtimeId1,runtimeId2)
0032 | GetRootElement()
0040 | ElementFromHandle(hwnd)
0049 | ElementFromPoint(pt)
0058 | GetFocusedElement()
0066 | GetRootElementBuildCache(cacheRequest)
0075 | ElementFromHandleBuildCache(hwnd,cacheRequest)
0085 | ElementFromPointBuildCache(pt,cacheRequest)
0095 | GetFocusedElementBuildCache(cacheRequest)
0104 | CreateTreeWalker(pCondition)
0113 | ControlViewWalker()
0121 | ContentViewWalker()
0129 | RawViewWalker()
0137 | RawViewCondition()
0145 | ControlViewCondition()
0153 | ContentViewCondition()
0162 | CreateCacheRequest()
0170 | CreateTrueCondition()
0179 | CreateFalseCondition()
0187 | CreatePropertyCondition(propertyId,value)
0197 | CreatePropertyConditionEx(propertyId,value,flags)
0210 | CreateAndCondition(condition1,condition2)
0220 | CreateAndConditionFromArray(conditions)
0229 | CreateAndConditionFromNativeArray(conditions,conditionCount)
0239 | CreateOrCondition(condition1,condition2)
0249 | CreateOrConditionFromArray(conditions)
0258 | CreateOrConditionFromNativeArray(conditions,conditionCount)
0268 | CreateNotCondition(condition)
0281 | AddAutomationEventHandler(eventId,element,scope,cacheRequest,handler)
0292 | RemoveAutomationEventHandler(eventId,element,handler)
0303 | AddPropertyChangedEventHandlerNativeArray(element,scope,cacheRequest,handler,propertyArray,propertyCount)
0316 | AddPropertyChangedEventHandler(element,scope,cacheRequest,handler,propertyArray)
0327 | RemovePropertyChangedEventHandler(element,handler)
0335 | AddStructureChangedEventHandler(element,scope,cacheRequest,handler)
0345 | RemoveStructureChangedEventHandler(element,handler)
0354 | AddFocusChangedEventHandler(cacheRequest,handler)
0362 | RemoveFocusChangedEventHandler(handler)
0369 | RemoveAllEventHandlers()
0375 | IntNativeArrayToSafeArray(array,arrayCount)
0385 | IntSafeArrayToNativeArray(intArray)
0396 | RectToVariant(rc)
0405 | VariantToRect(var)
0414 | SafeArrayToRectNativeArray(rects)
0425 | CreateProxyFactoryEntry(factory)
0434 | ProxyFactoryMapping()
0445 | GetPropertyProgrammaticName(property)
0454 | GetPatternProgrammaticName(pattern)
0466 | PollForPotentialSupportedPatterns(pElement)
0476 | PollForPotentialSupportedProperties(pElement)
0487 | CheckNotSupported(value)
0497 | ReservedNotSupportedValue()
0506 | ReservedMixedAttributeValue()
0518 | ElementFromIAccessible(accessible,childId)
0528 | ElementFromIAccessibleBuildCache(accessible,childId,cacheRequest)
0546 | SetFocus()
0554 | GetRuntimeId()
0567 | FindFirst(scope,condition)
0577 | FindAll(scope,condition)
0587 | FindFirstBuildCache(scope,condition,cacheRequest)
0598 | FindAllBuildCache(scope,condition,cacheRequest)
0610 | BuildUpdatedCache(cacheRequest)
0621 | GetCurrentPropertyValue(propertyId)
0634 | GetCurrentPropertyValueEx(propertyId,ignoreDefaultValue)
0645 | GetCachedPropertyValue(propertyId)
0655 | GetCachedPropertyValueEx(propertyId,ignoreDefaultValue,retVal)
0666 | GetCurrentPatternAs(patternId,riid)
0676 | GetCachedPatternAs(patternId,riid)
0688 | GetCurrentPattern(patternId)
0697 | GetCachedPattern(patternId)
0706 | GetCachedParent()
0717 | GetCachedChildren()
0725 | CurrentProcessId()
0734 | CurrentControlType()
0742 | CurrentLocalizedControlType()
0750 | CurrentName()
0758 | CurrentAcceleratorKey()
0767 | CurrentAccessKey()
0775 | CurrentHasKeyboardFocus()
0783 | CurrentIsKeyboardFocusable()
0791 | CurrentIsEnabled()
0800 | CurrentAutomationId()
0809 | CurrentClassName()
0818 | CurrentHelpText()
0826 | CurrentCulture()
0834 | CurrentIsControlElement()
0843 | CurrentIsContentElement()
0852 | CurrentIsPassword()
0860 | CurrentNativeWindowHandle()
0869 | CurrentItemType()
0877 | CurrentIsOffscreen()
0886 | CurrentOrientation()
0894 | CurrentFrameworkId()
0902 | CurrentIsRequiredForForm()
0911 | CurrentItemStatus()
0919 | CurrentBoundingRectangle()
0930 | CurrentLabeledBy()
0938 | CurrentAriaRole()
0946 | CurrentAriaProperties()
0954 | CurrentIsDataValidForForm()
0962 | CurrentControllerFor()
0970 | CurrentDescribedBy()
0978 | CurrentFlowsTo()
0986 | CurrentProviderDescription()
0994 | CachedProcessId()
1002 | CachedControlType()
1010 | CachedLocalizedControlType()
1018 | CachedName()
1026 | CachedAcceleratorKey()
1034 | CachedAccessKey()
1042 | CachedHasKeyboardFocus()
1050 | CachedIsKeyboardFocusable()
1058 | CachedIsEnabled()
1066 | CachedAutomationId()
1074 | CachedClassName()
1082 | CachedHelpText()
1090 | CachedCulture()
1098 | CachedIsControlElement()
1106 | CachedIsContentElement()
1114 | CachedIsPassword()
1122 | CachedNativeWindowHandle()
1130 | CachedItemType()
1138 | CachedIsOffscreen()
1146 | CachedOrientation()
1154 | CachedFrameworkId()
1162 | CachedIsRequiredForForm()
1170 | CachedItemStatus()
1178 | CachedBoundingRectangle()
1186 | CachedLabeledBy()
1194 | CachedAriaRole()
1202 | CachedAriaProperties()
1210 | CachedIsDataValidForForm()
1218 | CachedControllerFor()
1226 | CachedDescribedBy()
1234 | CachedFlowsTo()
1242 | CachedProviderDescription()
1253 | GetClickablePoint()
1269 | Length()
1277 | Element(index)
1292 | __get(aName)
1307 | __set(aName,aValue)
1320 | AddProperty(propertyId)
1330 | AddPattern(patternId)
1342 | Clone()
1371 | value()
1383 | id()
1391 | value()
1400 | flags()
1410 | count()
1418 | ChildrenAsNativeArray()
1427 | Children()
1438 | count()
1446 | ChildrenAsNativeArray()
1455 | Children()
1466 | Child()
1484 | GetParentElement(element)
1493 | GetFirstChildElement(element)
1502 | GetLastChildElement(element)
1511 | GetNextSiblingElement(element)
1520 | GetPreviousSiblingElement(element)
1531 | NormalizeElement(element)
1540 | GetParentElementBuildCache(element,cacheRequest)
1550 | GetFirstChildElementBuildCache(element,cacheRequest)
1560 | GetLastChildElementBuildCache(element,cacheRequest)
1570 | GetNextSiblingElementBuildCache(element,cacheRequest)
1580 | GetPreviousSiblingElementBuildCache(element,cacheRequest)
1590 | NormalizeElementBuildCache(element,cacheRequest)
1601 | Condition()
1617 | Invoke()
1625 | SetDockPosition(dockPos)
1632 | CurrentDockPosition()
1640 | CachedDockPosition()
1653 | Expand()
1658 | Collapse()
1663 | CurrentExpandCollapseState()
1671 | CachedExpandCollapseState()
1681 | GetItem(row,column)
1693 | CurrentRowCount()
1701 | CurrentColumnCount()
1709 | CachedRowCount()
1717 | CachedColumnCount()
1727 | CurrentContainingGrid()
1735 | CurrentRow()
1743 | CurrentColumn()
1751 | CurrentRowSpan()
1759 | CurrentColumnSpan()
1767 | CachedContainingGrid()
1775 | CachedRow()
1783 | CachedColumn()
1791 | CachedRowSpan()
1799 | CachedColumnSpan()
1809 | GetViewName(view)
1818 | SetCurrentView(view)
1825 | CurrentCurrentView()
1833 | GetCurrentSupportedViews()
1841 | CachedCurrentView()
1849 | GetCachedSupportedViews()
1859 | SetValue(val)
1866 | CurrentValue()
1874 | CurrentIsReadOnly()
1882 | CurrentMaximum()
1890 | CurrentMinimum()
1900 | CurrentLargeChange()
1908 | CurrentSmallChange()
1916 | CachedValue()
1924 | CachedIsReadOnly()
1932 | CachedMaximum()
1940 | CachedMinimum()
1948 | CachedLargeChange()
1956 | CachedSmallChange()
1966 | Scroll(horizontalAmount,verticalAmount)
1974 | SetScrollPercent(horizontalPercent,verticalPercent)
1981 | CurrentHorizontalScrollPercent()
1989 | CurrentVerticalScrollPercent()
1997 | CurrentHorizontalViewSize()
2005 | CurrentVerticalViewSize()
2014 | CurrentHorizontallyScrollable()
2022 | CurrentVerticallyScrollable()
2030 | CachedHorizontalScrollPercent()
2038 | CachedVerticalScrollPercent()
2046 | CachedHorizontalViewSize()
2054 | CachedVerticalViewSize()
2062 | CachedHorizontallyScrollable()
2070 | CachedVerticallyScrollable()
2081 | ScrollIntoView()
2089 | GetCurrentSelection()
2097 | CurrentCanSelectMultiple()
2105 | CurrentIsSelectionRequired()
2113 | GetCachedSelection()
2121 | CachedCanSelectMultiple()
2129 | CachedIsSelectionRequired()
2139 | Select()
2145 | AddToSelection()
2152 | RemoveFromSelection()
2158 | CurrentIsSelected()
2166 | CurrentSelectionContainer()
2174 | CachedIsSelected()
2182 | CachedSelectionContainer()
2195 | StartListening(inputType)
2201 | Cancel()
2209 | GetCurrentRowHeaders()
2217 | GetCurrentColumnHeaders()
2225 | CurrentRowOrColumnMajor()
2233 | GetCachedRowHeaders()
2241 | GetCachedColumnHeaders()
2249 | CachedRowOrColumnMajor()
2259 | GetCurrentRowHeaderItems()
2267 | GetCurrentColumnHeaderItems()
2275 | GetCachedRowHeaderItems()
2283 | GetCachedColumnHeaderItems()
2294 | Toggle()
2300 | CurrentToggleState()
2308 | CachedToggleState()
2320 | Move(x,y)
2327 | Resize(width,height)
2334 | Rotate(degrees)
2340 | CurrentCanMove()
2348 | CurrentCanResize()
2356 | CurrentCanRotate()
2364 | CachedCanMove()
2372 | CachedCanResize()
2380 | CachedCanRotate()
2391 | SetValue(val)
2401 | CurrentValue()
2409 | CurrentIsReadOnly()
2417 | CachedValue()
2426 | CachedIsReadOnly()
2437 | Close()
2443 | WaitForInputIdle(milliseconds)
2450 | SetWindowVisualState(state)
2457 | CurrentCanMaximize()
2465 | CurrentCanMinimize()
2473 | CurrentIsModal()
2481 | CurrentIsTopmost()
2489 | CurrentWindowVisualState()
2497 | CurrentWindowInteractionState()
2505 | CachedCanMaximize()
2513 | CachedCanMinimize()
2521 | CachedIsModal()
2529 | CachedIsTopmost()
2537 | CachedWindowVisualState()
2545 | CachedWindowInteractionState()
2556 | Clone()
2565 | Compare(range)
2574 | CompareEndpoints(srcEndPoint,range,targetEndPoint)
2589 | ExpandToEnclosingUnit(textUnit)
2597 | FindAttribute(attr,val,backward)
2608 | FindText(text,backward,ignoreCase)
2623 | GetAttributeValue(attr,value)
2632 | GetBoundingRectangles()
2640 | GetEnclosingElement()
2648 | GetText(maxLength=-1)
2677 | Move(unit,count)
2687 | MoveEndpointByUnit(endpoint,unit,count)
2699 | MoveEndpointByRange(srcEndPoint,range,targetEndPoint)
2709 | Select()
2715 | AddToSelection()
2721 | RemoveFromSelection()
2728 | ScrollIntoView(alignToTop)
2733 | GetChildren()
2743 | Length()
2751 | GetElement(index)
2770 | RangeFromPoint(pt)
2781 | RangeFromChild(child)
2795 | GetSelection()
2806 | GetVisibleRanges()
2815 | DocumentRange()
2823 | SupportedTextSelection()
2836 | Select(flagsSelect)
2843 | DoDefaultAction()
2848 | SetValue(szValue)
2853 | CurrentChildId()
2861 | CurrentName()
2869 | CurrentValue()
2877 | CurrentDescription()
2885 | CurrentRole()
2893 | CurrentState()
2901 | CurrentHelp()
2909 | CurrentKeyboardShortcut()
2917 | GetCurrentSelection()
2925 | CurrentDefaultAction()
2933 | CachedChildId()
2941 | CachedName()
2949 | CachedValue()
2957 | CachedDescription()
2965 | CachedRole()
2973 | CachedState()
2981 | CachedHelp()
2989 | CachedKeyboardShortcut()
2997 | GetCachedSelection()
3005 | CachedDefaultAction()
3014 | GetIAccessible()
3030 | FindItemByProperty(pStartAfter,propertyId,value)
3045 | Realize()
3054 | UIA_OnEvent(ByRef ptr,name)
3067 | _UIA_QueryInterface(pSelf, pRIID, pObj)
3071 | _UIA_AddRef(pSelf)
3073 | _UIA_Release(pSelf)
3103 | variant(ByRef var,type=0,val=0)
3109 | VariantType(type)
3126 | GetVariantValue(v)
3143 | GetSafeArrayValue(p,type)
3166 | UIA_hr(a,b)
3179 | UIA_Property(n)
3188 | UIA_PropertyVariantType(id)
3194 | UIA_Pattern(n)
3203 | UIA_Attribute(n)
3212 | UIA_AttributeVariantType(id)
3218 | UIA_ControlType(n)
3227 | UIA_Event(n)
3236 | UIA_Enum(t)
3539 | vt(p,n)
3544 | GUID(ByRef GUID, sGUID)

;}
;{   UIA2.ahk

;Functions:
0007 | __new(p=0)
0012 | __delete()
0015 | vt(n)
0026 | __new()
0031 | CompareElements(el1,el2)
0037 | CompareRuntimeIds(runtimeId1,runtimeId2)
0043 | GetRootElement()
0049 | ElementFromHandle(hwnd)
0055 | ElementFromPoint(pt)
0061 | GetFocusedElement()
0067 | GetRootElementBuildCache(cacheRequest)
0073 | ElementFromHandleBuildCache(hwnd,cacheRequest)
0079 | ElementFromPointBuildCache(pt,cacheRequest)
0085 | GetFocusedElementBuildCache(cacheRequest)
0091 | CreateTreeWalker(pCondition)
0097 | ControlViewWalker()
0103 | ContentViewWalker()
0109 | RawViewWalker()
0115 | RawViewCondition()
0121 | ControlViewCondition()
0127 | ContentViewCondition()
0134 | CreateCacheRequest()
0140 | CreateTrueCondition()
0147 | CreateFalseCondition()
0153 | CreatePropertyCondition(propertyId,value)
0159 | CreatePropertyConditionEx(propertyId,value,flags)
0167 | CreateAndCondition(condition1,condition2)
0173 | CreateAndConditionFromArray(conditions)
0179 | CreateAndConditionFromNativeArray(conditions,conditionCount)
0185 | CreateOrCondition(condition1,condition2)
0191 | CreateOrConditionFromArray(conditions)
0197 | CreateOrConditionFromNativeArray(conditions,conditionCount)
0203 | CreateNotCondition(condition)
0213 | AddAutomationEventHandler(eventId,element,scope,cacheRequest,handler)
0218 | RemoveAutomationEventHandler(eventId,element,handler)
0225 | AddPropertyChangedEventHandlerNativeArray(element,scope,cacheRequest,handler,propertyArray,propertyCount)
0231 | AddPropertyChangedEventHandler(element,scope,cacheRequest,handler,propertyArray)
0236 | RemovePropertyChangedEventHandler(element,handler)
0241 | AddStructureChangedEventHandler(element,scope,cacheRequest,handler)
0246 | RemoveStructureChangedEventHandler(element,handler)
0252 | AddFocusChangedEventHandler(cacheRequest,handler)
0257 | RemoveFocusChangedEventHandler(handler)
0262 | RemoveAllEventHandlers()
0267 | IntNativeArrayToSafeArray(array,arrayCount)
0273 | IntSafeArrayToNativeArray(intArray)
0280 | RectToVariant(rc)
0286 | VariantToRect(var)
0292 | SafeArrayToRectNativeArray(rects)
0299 | CreateProxyFactoryEntry(factory)
0305 | ProxyFactoryMapping()
0314 | GetPropertyProgrammaticName(property)
0320 | GetPatternProgrammaticName(pattern)
0329 | PollForPotentialSupportedPatterns(pElement)
0335 | PollForPotentialSupportedProperties(pElement)
0342 | CheckNotSupported(value)
0349 | ReservedNotSupportedValue()
0356 | ReservedMixedAttributeValue()
0366 | ElementFromIAccessible(accessible,childId)
0372 | ElementFromIAccessibleBuildCache(accessible,childId,cacheRequest)
0386 | SetFocus()
0393 | GetRuntimeId()
0404 | FindFirst(scope,condition)
0410 | FindAll(scope,condition)
0416 | FindFirstBuildCache(scope,condition,cacheRequest)
0422 | FindAllBuildCache(scope,condition,cacheRequest)
0429 | BuildUpdatedCache(cacheRequest)
0437 | GetCurrentPropertyValue(propertyId)
0447 | GetCurrentPropertyValueEx(propertyId,ignoreDefaultValue)
0454 | GetCachedPropertyValue(propertyId)
0461 | GetCachedPropertyValueEx(propertyId,ignoreDefaultValue,retVal)
0468 | GetCurrentPatternAs(patternId,riid)
0474 | GetCachedPatternAs(patternId,riid)
0482 | GetCurrentPattern(patternId)
0489 | GetCachedPattern(patternId)
0495 | GetCachedParent()
0504 | GetCachedChildren()
0510 | CurrentProcessId()
0517 | CurrentControlType()
0523 | CurrentLocalizedControlType()
0529 | CurrentName()
0535 | CurrentAcceleratorKey()
0542 | CurrentAccessKey()
0548 | CurrentHasKeyboardFocus()
0554 | CurrentIsKeyboardFocusable()
0560 | CurrentIsEnabled()
0567 | CurrentAutomationId()
0574 | CurrentClassName()
0581 | CurrentHelpText()
0587 | CurrentCulture()
0593 | CurrentIsControlElement()
0600 | CurrentIsContentElement()
0607 | CurrentIsPassword()
0613 | CurrentNativeWindowHandle()
0620 | CurrentItemType()
0626 | CurrentIsOffscreen()
0633 | CurrentOrientation()
0639 | CurrentFrameworkId()
0645 | CurrentIsRequiredForForm()
0652 | CurrentItemStatus()
0658 | CurrentBoundingRectangle()
0667 | CurrentLabeledBy()
0673 | CurrentAriaRole()
0679 | CurrentAriaProperties()
0685 | CurrentIsDataValidForForm()
0691 | CurrentControllerFor()
0697 | CurrentDescribedBy()
0703 | CurrentFlowsTo()
0709 | CurrentProviderDescription()
0715 | CachedProcessId()
0721 | CachedControlType()
0727 | CachedLocalizedControlType()
0733 | CachedName()
0739 | CachedAcceleratorKey()
0745 | CachedAccessKey()
0751 | CachedHasKeyboardFocus()
0757 | CachedIsKeyboardFocusable()
0763 | CachedIsEnabled()
0769 | CachedAutomationId()
0775 | CachedClassName()
0781 | CachedHelpText()
0787 | CachedCulture()
0793 | CachedIsControlElement()
0799 | CachedIsContentElement()
0805 | CachedIsPassword()
0811 | CachedNativeWindowHandle()
0817 | CachedItemType()
0823 | CachedIsOffscreen()
0829 | CachedOrientation()
0835 | CachedFrameworkId()
0841 | CachedIsRequiredForForm()
0847 | CachedItemStatus()
0853 | CachedBoundingRectangle()
0859 | CachedLabeledBy()
0865 | CachedAriaRole()
0871 | CachedAriaProperties()
0877 | CachedIsDataValidForForm()
0883 | CachedControllerFor()
0889 | CachedDescribedBy()
0895 | CachedFlowsTo()
0901 | CachedProviderDescription()
0910 | GetClickablePoint()
0923 | Length()
0929 | Element(index)
0941 | __get(aName)
0953 | __set(aName,aValue)
0963 | AddProperty(propertyId)
0971 | AddPattern(patternId)
0979 | Clone()
1006 | value()
1016 | id()
1022 | value()
1029 | flags()
1038 | count()
1044 | ChildrenAsNativeArray()
1050 | Children()
1059 | count()
1065 | ChildrenAsNativeArray()
1071 | Children()
1080 | Child()
1096 | GetParentElement(element)
1102 | GetFirstChildElement(element)
1108 | GetLastChildElement(element)
1114 | GetNextSiblingElement(element)
1120 | GetPreviousSiblingElement(element)
1128 | NormalizeElement(element)
1134 | GetParentElementBuildCache(element,cacheRequest)
1140 | GetFirstChildElementBuildCache(element,cacheRequest)
1146 | GetLastChildElementBuildCache(element,cacheRequest)
1152 | GetNextSiblingElementBuildCache(element,cacheRequest)
1158 | GetPreviousSiblingElementBuildCache(element,cacheRequest)
1164 | NormalizeElementBuildCache(element,cacheRequest)
1171 | Condition()
1185 | Invoke()
1193 | SetDockPosition(dockPos)
1198 | CurrentDockPosition()
1204 | CachedDockPosition()
1215 | Expand()
1220 | Collapse()
1225 | CurrentExpandCollapseState()
1231 | CachedExpandCollapseState()
1239 | GetItem(row,column)
1247 | CurrentRowCount()
1253 | CurrentColumnCount()
1259 | CachedRowCount()
1265 | CachedColumnCount()
1273 | CurrentContainingGrid()
1279 | CurrentRow()
1285 | CurrentColumn()
1291 | CurrentRowSpan()
1297 | CurrentColumnSpan()
1303 | CachedContainingGrid()
1309 | CachedRow()
1315 | CachedColumn()
1321 | CachedRowSpan()
1327 | CachedColumnSpan()
1335 | GetViewName(view)
1341 | SetCurrentView(view)
1346 | CurrentCurrentView()
1352 | GetCurrentSupportedViews()
1358 | CachedCurrentView()
1364 | GetCachedSupportedViews()
1372 | SetValue(val)
1377 | CurrentValue()
1383 | CurrentIsReadOnly()
1389 | CurrentMaximum()
1395 | CurrentMinimum()
1403 | CurrentLargeChange()
1409 | CurrentSmallChange()
1415 | CachedValue()
1421 | CachedIsReadOnly()
1427 | CachedMaximum()
1433 | CachedMinimum()
1439 | CachedLargeChange()
1445 | CachedSmallChange()
1453 | Scroll(horizontalAmount,verticalAmount)
1459 | SetScrollPercent(horizontalPercent,verticalPercent)
1464 | CurrentHorizontalScrollPercent()
1470 | CurrentVerticalScrollPercent()
1476 | CurrentHorizontalViewSize()
1482 | CurrentVerticalViewSize()
1489 | CurrentHorizontallyScrollable()
1495 | CurrentVerticallyScrollable()
1501 | CachedHorizontalScrollPercent()
1507 | CachedVerticalScrollPercent()
1513 | CachedHorizontalViewSize()
1519 | CachedVerticalViewSize()
1525 | CachedHorizontallyScrollable()
1531 | CachedVerticallyScrollable()
1540 | ScrollIntoView()
1547 | GetCurrentSelection()
1553 | CurrentCanSelectMultiple()
1559 | CurrentIsSelectionRequired()
1565 | GetCachedSelection()
1571 | CachedCanSelectMultiple()
1577 | CachedIsSelectionRequired()
1585 | Select()
1590 | AddToSelection()
1596 | RemoveFromSelection()
1601 | CurrentIsSelected()
1607 | CurrentSelectionContainer()
1613 | CachedIsSelected()
1619 | CachedSelectionContainer()
1630 | StartListening(inputType)
1635 | Cancel()
1642 | GetCurrentRowHeaders()
1648 | GetCurrentColumnHeaders()
1654 | CurrentRowOrColumnMajor()
1660 | GetCachedRowHeaders()
1666 | GetCachedColumnHeaders()
1672 | CachedRowOrColumnMajor()
1680 | GetCurrentRowHeaderItems()
1686 | GetCurrentColumnHeaderItems()
1692 | GetCachedRowHeaderItems()
1698 | GetCachedColumnHeaderItems()
1707 | Toggle()
1712 | CurrentToggleState()
1718 | CachedToggleState()
1728 | Move(x,y)
1734 | Resize(width,height)
1739 | Rotate(degrees)
1744 | CurrentCanMove()
1750 | CurrentCanResize()
1756 | CurrentCanRotate()
1762 | CachedCanMove()
1768 | CachedCanResize()
1774 | CachedCanRotate()
1783 | SetValue(val)
1791 | CurrentValue()
1797 | CurrentIsReadOnly()
1803 | CachedValue()
1810 | CachedIsReadOnly()
1819 | Close()
1824 | WaitForInputIdle(milliseconds)
1830 | SetWindowVisualState(state)
1836 | CurrentCanMaximize()
1842 | CurrentCanMinimize()
1848 | CurrentIsModal()
1854 | CurrentIsTopmost()
1860 | CurrentWindowVisualState()
1866 | CurrentWindowInteractionState()
1872 | CachedCanMaximize()
1878 | CachedCanMinimize()
1884 | CachedIsModal()
1890 | CachedIsTopmost()
1896 | CachedWindowVisualState()
1902 | CachedWindowInteractionState()
1911 | Clone()
1918 | Compare(range)
1924 | CompareEndpoints(srcEndPoint,range,targetEndPoint)
1934 | ExpandToEnclosingUnit(textUnit)
1940 | FindAttribute(attr,val,backward)
1946 | FindText(text,backward,ignoreCase)
1956 | GetAttributeValue(attr,value)
1962 | GetBoundingRectangles()
1968 | GetEnclosingElement()
1974 | GetText(maxLength=-1)
2000 | Move(unit,count)
2006 | MoveEndpointByUnit(endpoint,unit,count)
2013 | MoveEndpointByRange(srcEndPoint,range,targetEndPoint)
2019 | Select()
2025 | AddToSelection()
2031 | RemoveFromSelection()
2038 | ScrollIntoView(alignToTop)
2043 | GetChildren()
2051 | Length()
2057 | GetElement(index)
2073 | RangeFromPoint(pt)
2081 | RangeFromChild(child)
2092 | GetSelection()
2101 | GetVisibleRanges()
2108 | DocumentRange()
2114 | SupportedTextSelection()
2125 | Select(flagsSelect)
2130 | DoDefaultAction()
2135 | SetValue(szValue)
2140 | CurrentChildId()
2146 | CurrentName()
2152 | CurrentValue()
2158 | CurrentDescription()
2164 | CurrentRole()
2170 | CurrentState()
2176 | CurrentHelp()
2182 | CurrentKeyboardShortcut()
2188 | GetCurrentSelection()
2194 | CurrentDefaultAction()
2200 | CachedChildId()
2206 | CachedName()
2212 | CachedValue()
2218 | CachedDescription()
2224 | CachedRole()
2230 | CachedState()
2236 | CachedHelp()
2242 | CachedKeyboardShortcut()
2248 | GetCachedSelection()
2254 | CachedDefaultAction()
2261 | GetIAccessible()
2275 | FindItemByProperty(pStartAfter,propertyId,value)
2285 | Realize()
2294 | UIA_OnEvent(ByRef ptr,name)
2307 | _UIA_QueryInterface(pSelf, pRIID, pObj)
2311 | _UIA_AddRef(pSelf)
2313 | _UIA_Release(pSelf)
2343 | variant(ByRef var,type=0,val=0)
2349 | VariantType(type)
2366 | GetVariantValue(v)
2383 | GetSafeArrayValue(p,type)
2406 | UIA_Error(a,b)
2419 | UIA_Property(n)
2428 | UIA_PropertyVariantType(id)
2434 | UIA_Pattern(n)
2443 | UIA_Attribute(n)
2452 | UIA_AttributeVariantType(id)
2458 | UIA_ControlType(n)
2467 | UIA_Event(n)
2476 | UIA_Enum(t)
2779 | vt(p,n)
2784 | GUID(ByRef GUID, sGUID)

;}
;{   UIA_Interface.ahk

;Functions:
0020 | __New(p="", flag=1)
0025 | __Get(member)
0040 | __Set(member)
0043 | __Call(member)
0047 | __Delete()
0050 | __Vt(n)
0060 | CompareElements(e1,e2)
0063 | CompareRuntimeIds(r1,r2)
0066 | GetRootElement()
0069 | ElementFromHandle(hwnd)
0072 | ElementFromPoint(x="", y="")
0075 | GetFocusedElement()
0082 | CreateTreeWalker(condition)
0087 | CreateTrueCondition()
0090 | CreateFalseCondition()
0093 | CreatePropertyCondition(propertyId, ByRef var, type="Variant")
0098 | CreatePropertyConditionEx(propertyId, ByRef var, type="Variant", flags=0x1)
0104 | CreateAndCondition(c1,c2)
0107 | CreateAndConditionFromArray(array)
0126 | CreateOrCondition(c1,c2)
0129 | CreateOrConditionFromArray(array)
0148 | CreateNotCondition(c)
0155 | AddPropertyChangedEventHandler(element,scope=0x1,cacheRequest=0,handler="",propertyArray="")
0164 | AddFocusChangedEventHandler(cacheRequest, handler)
0170 | IntNativeArrayToSafeArray(ByRef nArr, n="")
0178 | RectToVariant(ByRef rect, ByRef out="")
0191 | GetPropertyProgrammaticName(Id)
0194 | GetPatternProgrammaticName(Id)
0197 | PollForPotentialSupportedPatterns(e, Byref Ids="", Byref Names="")
0200 | PollForPotentialSupportedProperties(e, Byref Ids="", Byref Names="")
0203 | CheckNotSupported(value)
0210 | ElementFromIAccessible(IAcc, childId=0)
0225 | SetFocus()
0228 | GetRuntimeId(ByRef stringId="")
0231 | FindFirst(c="", scope=0x2)
0237 | FindAll(c="", scope=0x2)
0247 | GetCurrentPropertyValue(propertyId, ByRef out="")
0250 | GetCurrentPropertyValueEx(propertyId, ignoreDefaultValue=1, ByRef out="")
0255 | GetCachedPropertyValue(propertyId)
0261 | GetCurrentPatternAs(pattern="")
0270 | GetCachedChildren()
0281 | GetElement(i)
0291 | GetParentElement(e)
0294 | GetFirstChildElement(e)
0297 | GetLastChildElement(e)
0300 | GetNextSiblingElement(e)
0303 | GetPreviousSiblingElement(e)
0306 | NormalizeElement(e)
0347 | GetChildren()
0433 | SetDockPosition(Pos)
0450 | Expand()
0453 | Collapse()
0474 | GetItem(row,column)
0483 | Invoke()
0492 | FindItemByProperty(startAfter, propertyId, ByRef value, type=8)
0504 | Select(flags=3)
0507 | DoDefaultAction()
0510 | SetValue(value)
0513 | GetCurrentSelection()
0520 | GetIAccessible()
0534 | GetViewName(view)
0537 | SetCurrentView(view)
0540 | GetCurrentSupportedViews()
0543 | GetCachedSupportedViews()
0553 | SetValue(val)
0562 | ScrollIntoView()
0572 | Scroll(horizontal, vertical)
0575 | SetScrollPercent(horizontal, vertical)
0628 | UIA_Interface()
0636 | UIA_Hr(hr)
0645 | UIA_NotImplemented()
0649 | UIA_ElementArray(p, uia="")
0655 | UIA_RectToObject(ByRef r)
0659 | UIA_RectStructure(this, ByRef r)
0665 | UIA_SafeArraysToObject(keys,values)
0672 | UIA_Hex(p)
0679 | UIA_GUID(ByRef GUID, sGUID)
0683 | UIA_Variant(ByRef var,type=0,val=0)
0687 | UIA_IsVariant(ByRef vt, ByRef type="")
0691 | UIA_Type(ByRef item, ByRef info)
0693 | UIA_VariantData(ByRef p, flag=1)
0749 | UIA_VariantChangeType(pvarDst, pvarSrc, vt=8)
0752 | UIA_VariantClear(pvar)
0756 | MsgBox(msg)

;}
;{   UnHTM.ahk

;Functions:
0007 | UnHTM( HTM )

;}
;{   Update.ahk

;Functions:
0139 | VersionCompare(version1, version2)
0173 | CopyFilesAndFolders(SourcePattern, DestinationFolder, DoOverwrite = false)

;Labels:
3157 | ChangeButtonNames

;}
;{   UpdRes.ahk

;Functions:
0024 | UpdRes_LockResource(sBinFile, sResName, nResType, ByRef szData)
0071 | UpdRes_UpdateResource(sBinFile, bDelOld, sResName, nResType, nLangId, pData, szData)
0098 | UpdRes_UpdateArrayOfResources(sBinFile, bDelOld, ByRef objRes)
0133 | UpdRes_UpdateDirOfResources(sResDir, sBinFile, bDelOld, nResType, nLangId)
0188 | UpdRes_EnumerateResources(sBinFile, nResType)
0221 | __UpdRes_EnumeratorCallback(hModule, lpszType, lpszName, lParam)

;}
;{   Upper.ahk

;Functions:
0011 | Upper(Text)

;}
;{   uriencode.ahk

;Functions:
0001 | uriEncode(str)

;}
;{   uriEncoder-Decoder.ahk

;Functions:
0030 | uriDecode(str)
0039 | uriEncode(str)

;Labels:
3922 | code
2227 | guiclose

;}
;{   UrlDownloadToJson.ahk

;Functions:
0022 | UrlDownloadToJson(input)

;}
;{   UrlDownloadToVar.ahk

;Functions:
0006 | Download(ByRef Result,URL)

;}
;{   USBD.ahk

;Functions:
0004 | USBD_SafelyRemove( Drv )
0015 | USBD_GetDeviceSerial( Drv="" )
0037 | USBD_GetDeviceID( Serial )
0045 | USBD_DeviceEject( DeviceID )

;}
;{   USBUIRT.ahk

;Functions:
0035 | USBUIRT_LoadDLL()
0041 | USBUIRT_ReleaseDLL()
0052 | USBUIRT_ReceiveIR()
0061 | USBUIRT_AirCode(IrEventStr,Userdata)
0074 | USBUIRT_SendIRRaw(IRCode,RepeatCount=1)
0089 | USBUIRT_SendIRPronto(IRCode,RepeatCount=1)
0102 | USBUIRT_DriverInfo()
0111 | USBUIRT_HardwareInfo()
0124 | USBUIRT_ConfigInfo()
0135 | USBUIRT_SetConfig(config)
0143 | USBUIRT_LearnRaw()
0165 | USBUIRT_Abort(LearnPID)

;}
;{   Util.ahk

;Functions:
0002 | Util_VersionCompare(other,local)
0032 | Util_StrRepeat(s,r)
0057 | Util_ArrayInsert(ByRef Arr,InsArr)
0063 | Util_ObjCount(obj)
0068 | Util_ArraySort(Arr)
0077 | Util_ShortPath(p,l=50)
0087 | Util_FullPath(p)
0092 | Util_TempDir(outDir="")
0110 | Util_FileAlign(f)
0116 | Util_FileWriteStr(f, ByRef str)
0128 | Util_ReadLenStr(ptr, ByRef endPtr)
0135 | Util_DirTree(dir)
0155 | Util_isASCII(s)

;}
;{   uuid.ahk

;Functions:
0003 | uuid(c = false)

;}
;{   VA (2).ahk

;Functions:
0005 | VA_GetMasterVolume(channel="", device_desc="playback")
0016 | VA_SetMasterVolume(vol, channel="", device_desc="playback")
0027 | VA_GetMasterChannelCount(device_desc="playback")
0035 | VA_SetMasterMute(mute, device_desc="playback")
0042 | VA_GetMasterMute(device_desc="playback")
0054 | VA_GetVolume(subunit_desc="1", channel="", device_desc="playback")
0086 | VA_SetVolume(vol, subunit_desc="1", channel="", device_desc="playback")
0135 | VA_GetChannelCount(subunit_desc="1", device_desc="playback")
0145 | VA_SetMute(mute, subunit_desc="1", device_desc="playback")
0154 | VA_GetMute(subunit_desc="1", device_desc="playback")
0168 | VA_GetAudioMeter(device_desc="playback")
0177 | VA_GetDevicePeriod(device_desc, ByRef default_period, ByRef minimum_period="")
0201 | VA_GetAudioEndpointVolume(device_desc="playback")
0210 | VA_GetDeviceSubunit(device_desc, subunit_desc, subunit_iid)
0220 | VA_FindSubunit(device, target_desc, target_iid)
0239 | VA_FindSubunitCallback(part, interface, prm)
0249 | VA_EnumSubunits(device, callback, target_name="", target_iid="", callback_param="")
0266 | VA_EnumSubunitsEx(part, data_flow, callback, target_name="", target_iid="", callback_param="")
0315 | VA_GetDevice(device_desc="playback")
0379 | VA_GetDeviceName(device)
0394 | VA_StrGet(pString)
0413 | VA_dB2Scalar(dB, min_dB, max_dB)
0418 | VA_Scalar2dB(s, min_dB, max_dB)
0433 | VA_IMMDevice_Activate(this, iid, ClsCtx, ActivationParams, ByRef Interface)
0436 | VA_IMMDevice_OpenPropertyStore(this, Access, ByRef Properties)
0439 | VA_IMMDevice_GetId(this, ByRef Id)
0444 | VA_IMMDevice_GetState(this, ByRef State)
0451 | VA_IDeviceTopology_GetConnectorCount(this, ByRef Count)
0454 | VA_IDeviceTopology_GetConnector(this, Index, ByRef Connector)
0457 | VA_IDeviceTopology_GetSubunitCount(this, ByRef Count)
0460 | VA_IDeviceTopology_GetSubunit(this, Index, ByRef Subunit)
0463 | VA_IDeviceTopology_GetPartById(this, Id, ByRef Part)
0466 | VA_IDeviceTopology_GetDeviceId(this, ByRef DeviceId)
0471 | VA_IDeviceTopology_GetSignalPath(this, PartFrom, PartTo, RejectMixedPaths, ByRef Parts)
0478 | VA_IConnector_GetType(this, ByRef Type)
0481 | VA_IConnector_GetDataFlow(this, ByRef Flow)
0484 | VA_IConnector_ConnectTo(this, ConnectTo)
0487 | VA_IConnector_Disconnect(this)
0490 | VA_IConnector_IsConnected(this, ByRef Connected)
0493 | VA_IConnector_GetConnectedTo(this, ByRef ConTo)
0496 | VA_IConnector_GetConnectorIdConnectedTo(this, ByRef ConnectorId)
0501 | VA_IConnector_GetDeviceIdConnectedTo(this, ByRef DeviceId)
0510 | VA_IPart_GetName(this, ByRef Name)
0515 | VA_IPart_GetLocalId(this, ByRef Id)
0518 | VA_IPart_GetGlobalId(this, ByRef GlobalId)
0523 | VA_IPart_GetPartType(this, ByRef PartType)
0526 | VA_IPart_GetSubType(this, ByRef SubType)
0532 | VA_IPart_GetControlInterfaceCount(this, ByRef Count)
0535 | VA_IPart_GetControlInterface(this, Index, ByRef InterfaceDesc)
0538 | VA_IPart_EnumPartsIncoming(this, ByRef Parts)
0541 | VA_IPart_EnumPartsOutgoing(this, ByRef Parts)
0544 | VA_IPart_GetTopologyObject(this, ByRef Topology)
0547 | VA_IPart_Activate(this, ClsContext, iid, ByRef Object)
0550 | VA_IPart_RegisterControlChangeCallback(this, iid, Notify)
0553 | VA_IPart_UnregisterControlChangeCallback(this, Notify)
0560 | VA_IPartsList_GetCount(this, ByRef Count)
0563 | VA_IPartsList_GetPart(this, INdex, ByRef Part)
0570 | VA_IAudioEndpointVolume_RegisterControlChangeNotify(this, Notify)
0573 | VA_IAudioEndpointVolume_UnregisterControlChangeNotify(this, Notify)
0576 | VA_IAudioEndpointVolume_GetChannelCount(this, ByRef ChannelCount)
0579 | VA_IAudioEndpointVolume_SetMasterVolumeLevel(this, LevelDB, GuidEventContext="")
0582 | VA_IAudioEndpointVolume_SetMasterVolumeLevelScalar(this, Level, GuidEventContext="")
0585 | VA_IAudioEndpointVolume_GetMasterVolumeLevel(this, ByRef LevelDB)
0588 | VA_IAudioEndpointVolume_GetMasterVolumeLevelScalar(this, ByRef Level)
0591 | VA_IAudioEndpointVolume_SetChannelVolumeLevel(this, Channel, LevelDB, GuidEventContext="")
0594 | VA_IAudioEndpointVolume_SetChannelVolumeLevelScalar(this, Channel, Level, GuidEventContext="")
0597 | VA_IAudioEndpointVolume_GetChannelVolumeLevel(this, Channel, ByRef LevelDB)
0600 | VA_IAudioEndpointVolume_GetChannelVolumeLevelScalar(this, Channel, ByRef Level)
0603 | VA_IAudioEndpointVolume_SetMute(this, Mute, GuidEventContext="")
0606 | VA_IAudioEndpointVolume_GetMute(this, ByRef Mute)
0609 | VA_IAudioEndpointVolume_GetVolumeStepInfo(this, ByRef Step, ByRef StepCount)
0612 | VA_IAudioEndpointVolume_VolumeStepUp(this, GuidEventContext="")
0615 | VA_IAudioEndpointVolume_VolumeStepDown(this, GuidEventContext="")
0618 | VA_IAudioEndpointVolume_QueryHardwareSupport(this, ByRef HardwareSupportMask)
0621 | VA_IAudioEndpointVolume_GetVolumeRange(this, ByRef MinDB, ByRef MaxDB, ByRef IncrementDB)
0629 | VA_IPerChannelDbLevel_GetChannelCount(this, ByRef Channels)
0632 | VA_IPerChannelDbLevel_GetLevelRange(this, Channel, ByRef MinLevelDB, ByRef MaxLevelDB, ByRef Stepping)
0635 | VA_IPerChannelDbLevel_GetLevel(this, Channel, ByRef LevelDB)
0638 | VA_IPerChannelDbLevel_SetLevel(this, Channel, LevelDB, GuidEventContext="")
0641 | VA_IPerChannelDbLevel_SetLevelUniform(this, LevelDB, GuidEventContext="")
0644 | VA_IPerChannelDbLevel_SetLevelAllChannels(this, LevelsDB, ChannelCount, GuidEventContext="")
0651 | VA_IAudioMute_SetMute(this, Muted, GuidEventContext="")
0654 | VA_IAudioMute_GetMute(this, ByRef Muted)
0661 | VA_IAudioAutoGainControl_GetEnabled(this, ByRef Enabled)
0664 | VA_IAudioAutoGainControl_SetEnabled(this, Enable, GuidEventContext="")
0671 | VA_IAudioMeterInformation_GetPeakValue(this, ByRef Peak)
0674 | VA_IAudioMeterInformation_GetMeteringChannelCount(this, ByRef ChannelCount)
0677 | VA_IAudioMeterInformation_GetChannelsPeakValues(this, ChannelCount, PeakValues)
0680 | VA_IAudioMeterInformation_QueryHardwareSupport(this, ByRef HardwareSupportMask)

;Labels:
0371 | VA_GetDevice_Return

;}
;{   VA.ahk

;Functions:
0008 | VA_GetMasterVolume(channel="", device_desc="playback")
0020 | VA_SetMasterVolume(vol, channel="", device_desc="playback")
0032 | VA_GetMasterChannelCount(device_desc="playback")
0041 | VA_SetMasterMute(mute, device_desc="playback")
0049 | VA_GetMasterMute(device_desc="playback")
0062 | VA_GetVolume(subunit_desc="1", channel="", device_desc="playback")
0093 | VA_SetVolume(vol, subunit_desc="1", channel="", device_desc="playback")
0141 | VA_GetChannelCount(subunit_desc="1", device_desc="playback")
0150 | VA_SetMute(mute, subunit_desc="1", device_desc="playback")
0158 | VA_GetMute(subunit_desc="1", device_desc="playback")
0171 | VA_GetAudioMeter(device_desc="playback")
0180 | VA_GetDevicePeriod(device_desc, ByRef default_period, ByRef minimum_period="")
0196 | VA_GetAudioEndpointVolume(device_desc="playback")
0205 | VA_GetDeviceSubunit(device_desc, subunit_desc, subunit_iid)
0214 | VA_FindSubunit(device, target_desc, target_iid)
0228 | VA_FindSubunitCallback(part, interface, index)
0238 | VA_EnumSubunits(device, callback, target_name="", target_iid="", callback_param="")
0257 | VA_EnumSubunitsEx(part, data_flow, callback, target_name="", target_iid="", callback_param="")
0306 | VA_GetDevice(device_desc="playback")
0370 | VA_GetDeviceName(device)
0386 | VA_SetDefaultEndpoint(device_desc, role)
0423 | VA_GUIDOut(ByRef guid)
0430 | VA_WStrOut(ByRef str)
0435 | VA_dB2Scalar(dB, min_dB, max_dB)
0440 | VA_Scalar2dB(s, min_dB, max_dB)
0455 | VA_IMMDevice_Activate(this, iid, ClsCtx, ActivationParams, ByRef Interface)
0458 | VA_IMMDevice_OpenPropertyStore(this, Access, ByRef Properties)
0461 | VA_IMMDevice_GetId(this, ByRef Id)
0466 | VA_IMMDevice_GetState(this, ByRef State)
0473 | VA_IDeviceTopology_GetConnectorCount(this, ByRef Count)
0476 | VA_IDeviceTopology_GetConnector(this, Index, ByRef Connector)
0479 | VA_IDeviceTopology_GetSubunitCount(this, ByRef Count)
0482 | VA_IDeviceTopology_GetSubunit(this, Index, ByRef Subunit)
0485 | VA_IDeviceTopology_GetPartById(this, Id, ByRef Part)
0488 | VA_IDeviceTopology_GetDeviceId(this, ByRef DeviceId)
0493 | VA_IDeviceTopology_GetSignalPath(this, PartFrom, PartTo, RejectMixedPaths, ByRef Parts)
0500 | VA_IConnector_GetType(this, ByRef Type)
0503 | VA_IConnector_GetDataFlow(this, ByRef Flow)
0506 | VA_IConnector_ConnectTo(this, ConnectTo)
0509 | VA_IConnector_Disconnect(this)
0512 | VA_IConnector_IsConnected(this, ByRef Connected)
0515 | VA_IConnector_GetConnectedTo(this, ByRef ConTo)
0518 | VA_IConnector_GetConnectorIdConnectedTo(this, ByRef ConnectorId)
0523 | VA_IConnector_GetDeviceIdConnectedTo(this, ByRef DeviceId)
0532 | VA_IPart_GetName(this, ByRef Name)
0537 | VA_IPart_GetLocalId(this, ByRef Id)
0540 | VA_IPart_GetGlobalId(this, ByRef GlobalId)
0545 | VA_IPart_GetPartType(this, ByRef PartType)
0548 | VA_IPart_GetSubType(this, ByRef SubType)
0554 | VA_IPart_GetControlInterfaceCount(this, ByRef Count)
0557 | VA_IPart_GetControlInterface(this, Index, ByRef InterfaceDesc)
0560 | VA_IPart_EnumPartsIncoming(this, ByRef Parts)
0563 | VA_IPart_EnumPartsOutgoing(this, ByRef Parts)
0566 | VA_IPart_GetTopologyObject(this, ByRef Topology)
0569 | VA_IPart_Activate(this, ClsContext, iid, ByRef Object)
0572 | VA_IPart_RegisterControlChangeCallback(this, iid, Notify)
0575 | VA_IPart_UnregisterControlChangeCallback(this, Notify)
0582 | VA_IPartsList_GetCount(this, ByRef Count)
0585 | VA_IPartsList_GetPart(this, INdex, ByRef Part)
0592 | VA_IAudioEndpointVolume_RegisterControlChangeNotify(this, Notify)
0595 | VA_IAudioEndpointVolume_UnregisterControlChangeNotify(this, Notify)
0598 | VA_IAudioEndpointVolume_GetChannelCount(this, ByRef ChannelCount)
0601 | VA_IAudioEndpointVolume_SetMasterVolumeLevel(this, LevelDB, GuidEventContext="")
0604 | VA_IAudioEndpointVolume_SetMasterVolumeLevelScalar(this, Level, GuidEventContext="")
0607 | VA_IAudioEndpointVolume_GetMasterVolumeLevel(this, ByRef LevelDB)
0610 | VA_IAudioEndpointVolume_GetMasterVolumeLevelScalar(this, ByRef Level)
0613 | VA_IAudioEndpointVolume_SetChannelVolumeLevel(this, Channel, LevelDB, GuidEventContext="")
0616 | VA_IAudioEndpointVolume_SetChannelVolumeLevelScalar(this, Channel, Level, GuidEventContext="")
0619 | VA_IAudioEndpointVolume_GetChannelVolumeLevel(this, Channel, ByRef LevelDB)
0622 | VA_IAudioEndpointVolume_GetChannelVolumeLevelScalar(this, Channel, ByRef Level)
0625 | VA_IAudioEndpointVolume_SetMute(this, Mute, GuidEventContext="")
0628 | VA_IAudioEndpointVolume_GetMute(this, ByRef Mute)
0631 | VA_IAudioEndpointVolume_GetVolumeStepInfo(this, ByRef Step, ByRef StepCount)
0634 | VA_IAudioEndpointVolume_VolumeStepUp(this, GuidEventContext="")
0637 | VA_IAudioEndpointVolume_VolumeStepDown(this, GuidEventContext="")
0640 | VA_IAudioEndpointVolume_QueryHardwareSupport(this, ByRef HardwareSupportMask)
0643 | VA_IAudioEndpointVolume_GetVolumeRange(this, ByRef MinDB, ByRef MaxDB, ByRef IncrementDB)
0654 | VA_IPerChannelDbLevel_GetChannelCount(this, ByRef Channels)
0657 | VA_IPerChannelDbLevel_GetLevelRange(this, Channel, ByRef MinLevelDB, ByRef MaxLevelDB, ByRef Stepping)
0660 | VA_IPerChannelDbLevel_GetLevel(this, Channel, ByRef LevelDB)
0663 | VA_IPerChannelDbLevel_SetLevel(this, Channel, LevelDB, GuidEventContext="")
0666 | VA_IPerChannelDbLevel_SetLevelUniform(this, LevelDB, GuidEventContext="")
0669 | VA_IPerChannelDbLevel_SetLevelAllChannels(this, LevelsDB, ChannelCount, GuidEventContext="")
0676 | VA_IAudioMute_SetMute(this, Muted, GuidEventContext="")
0679 | VA_IAudioMute_GetMute(this, ByRef Muted)
0686 | VA_IAudioAutoGainControl_GetEnabled(this, ByRef Enabled)
0689 | VA_IAudioAutoGainControl_SetEnabled(this, Enable, GuidEventContext="")
0696 | VA_IAudioMeterInformation_GetPeakValue(this, ByRef Peak)
0699 | VA_IAudioMeterInformation_GetMeteringChannelCount(this, ByRef ChannelCount)
0702 | VA_IAudioMeterInformation_GetChannelsPeakValues(this, ChannelCount, PeakValues)
0705 | VA_IAudioMeterInformation_QueryHardwareSupport(this, ByRef HardwareSupportMask)
0712 | VA_IAudioClient_Initialize(this, ShareMode, StreamFlags, BufferDuration, Periodicity, Format, AudioSessionGuid)
0715 | VA_IAudioClient_GetBufferSize(this, ByRef NumBufferFrames)
0718 | VA_IAudioClient_GetStreamLatency(this, ByRef Latency)
0721 | VA_IAudioClient_GetCurrentPadding(this, ByRef NumPaddingFrames)
0724 | VA_IAudioClient_IsFormatSupported(this, ShareMode, Format, ByRef ClosestMatch)
0727 | VA_IAudioClient_GetMixFormat(this, ByRef Format)
0730 | VA_IAudioClient_GetDevicePeriod(this, ByRef DefaultDevicePeriod, ByRef MinimumDevicePeriod)
0733 | VA_IAudioClient_Start(this)
0736 | VA_IAudioClient_Stop(this)
0739 | VA_IAudioClient_Reset(this)
0742 | VA_IAudioClient_SetEventHandle(this, eventHandle)
0745 | VA_IAudioClient_GetService(this, iid, ByRef Service)
0757 | VA_IAudioSessionControl_GetState(this, ByRef State)
0760 | VA_IAudioSessionControl_GetDisplayName(this, ByRef DisplayName)
0765 | VA_IAudioSessionControl_SetDisplayName(this, DisplayName, EventContext)
0768 | VA_IAudioSessionControl_GetIconPath(this, ByRef IconPath)
0773 | VA_IAudioSessionControl_SetIconPath(this, IconPath)
0776 | VA_IAudioSessionControl_GetGroupingParam(this, ByRef Param)
0782 | VA_IAudioSessionControl_SetGroupingParam(this, Param, EventContext)
0785 | VA_IAudioSessionControl_RegisterAudioSessionNotification(this, NewNotifications)
0788 | VA_IAudioSessionControl_UnregisterAudioSessionNotification(this, NewNotifications)
0795 | VA_IAudioSessionManager_GetAudioSessionControl(this, AudioSessionGuid)
0798 | VA_IAudioSessionManager_GetSimpleAudioVolume(this, AudioSessionGuid, StreamFlags, ByRef AudioVolume)
0805 | VA_IMMDeviceEnumerator_EnumAudioEndpoints(this, DataFlow, StateMask, ByRef Devices)
0808 | VA_IMMDeviceEnumerator_GetDefaultAudioEndpoint(this, DataFlow, Role, ByRef Endpoint)
0811 | VA_IMMDeviceEnumerator_GetDevice(this, id, ByRef Device)
0814 | VA_IMMDeviceEnumerator_RegisterEndpointNotificationCallback(this, Client)
0817 | VA_IMMDeviceEnumerator_UnregisterEndpointNotificationCallback(this, Client)
0824 | VA_IMMDeviceCollection_GetCount(this, ByRef Count)
0827 | VA_IMMDeviceCollection_Item(this, Index, ByRef Device)
0834 | VA_IControlInterface_GetName(this, ByRef Name)
0839 | VA_IControlInterface_GetIID(this, ByRef IID)
0855 | VA_IAudioSessionControl2_GetSessionIdentifier(this, ByRef id)
0860 | VA_IAudioSessionControl2_GetSessionInstanceIdentifier(this, ByRef id)
0865 | VA_IAudioSessionControl2_GetProcessId(this, ByRef pid)
0868 | VA_IAudioSessionControl2_IsSystemSoundsSession(this)
0871 | VA_IAudioSessionControl2_SetDuckingPreference(this, OptOut)
0879 | VA_IAudioSessionManager2_GetSessionEnumerator(this, ByRef SessionEnum)
0882 | VA_IAudioSessionManager2_RegisterSessionNotification(this, SessionNotification)
0885 | VA_IAudioSessionManager2_UnregisterSessionNotification(this, SessionNotification)
0888 | VA_IAudioSessionManager2_RegisterDuckNotification(this, SessionNotification)
0891 | VA_IAudioSessionManager2_UnregisterDuckNotification(this, SessionNotification)
0898 | VA_IAudioSessionEnumerator_GetCount(this, ByRef SessionCount)
0901 | VA_IAudioSessionEnumerator_GetSession(this, SessionCount, ByRef Session)
0913 | VA_xIPolicyConfigVista_SetDefaultEndpoint(this, DeviceId, Role)
0920 | VA_ISimpleAudioVolume_SetMasterVolume(this, ByRef fLevel, GuidEventContext="")
0923 | VA_ISimpleAudioVolume_GetMasterVolume(this, ByRef fLevel)
0926 | VA_ISimpleAudioVolume_SetMute(this, ByRef Muted, GuidEventContext="")
0929 | VA_ISimpleAudioVolume_GetMute(this, ByRef Muted)
0934 | GetVolumeObject(Param = 0)

;Labels:
4362 | VA_GetDevice_Return

;}
;{   VARIANT.ahk

;Functions:
0001 | VARIANT_Create(value, byRef buffer)
0015 | VARIANT_GetValue(variant)

;}
;{   VarZ_Compress.ahk

;Functions:
0064 | VarZ_Uncompress( ByRef D )
0079 | VarZ_Decompress( ByRef Data )
0121 | VarZ_Load( ByRef Data, SrcFile )
0127 | VarZ_Save( ByRef Data, DataSize, TrgFile )

;}
;{   VersionRes.ahk

;Functions:
0034 | _NewEnum()
0039 | AddChild(node)
0044 | GetChild(name)
0051 | GetText()
0057 | SetText(txt)
0067 | GetDataAddr()
0072 | Save(addr)

;}
;{   VLCHTTP3.ahk

;Functions:
0026 | VLCHTTP3_Start(VLC_path, plist = "")
0039 | VLCHTTP3_Close()
0046 | VLCHTTP3_Exist()
0055 | VLCHTTP3_Pause()
0061 | VLCHTTP3_Play()
0067 | VLCHTTP3_Stop()
0073 | VLCHTTP3_FullScreen()
0079 | VLCHTTP3_PlayFaster(Val)
0084 | VLCHTTP3_NormalSpeed()
0089 | VLCHTTP3_PlaySlower(Val)
0094 | VLCHTTP3_Rate()
0105 | VLCHTTP3_SetPos(Val)
0110 | VLCHTTP3_JumpForward(Val)
0115 | VLCHTTP3_JumpBackward(Val)
0120 | VLCHTTP3_VolumeUp(Val)
0126 | VLCHTTP3_VolumeDown(Val)
0132 | VLCHTTP3_VolumeChange(Val)
0138 | VLCHTTP3_ToggleMute(resetvol)
0160 | VLCHTTP3_CurrentVol()
0171 | VLCHTTP3_NowPlayingFilePath()
0175 | VLCHTTP3_NowPlaying()
0188 | VLCHTTP3_GetFullscreen()
0199 | VLCHTTP3_Status()
0206 | VLCHTTP3_PlayList()
0212 | VLCHTTP3_PlayListNext()
0217 | VLCHTTP3_PlayListPrevious()
0222 | VLCHTTP3_PlayListClear()
0227 | VLCHTTP3_PlayListRandom()
0232 | VLCHTTP3_PlayListIsRandom()
0243 | VLCHTTP3_PlayListLoop()
0248 | VLCHTTP3_PlayListIsLoop()
0259 | VLCHTTP3_PlayListRepeat()
0264 | VLCHTTP3_PlayListIsRepeat()
0275 | VLCHTTP3_PlaylistPlayID(id)
0280 | VLCHTTP3_PlaylistDeleteID(id)
0285 | VLCHTTP3_PlaylistTracks()
0313 | VLCHTTP3_PlaylistArtist()
0337 | VLCHTTP3_PlayListAlbum()
0362 | VLCHTTP3_PlayListFilePathID(id)
0388 | VLCHTTP3_CurrentPlayListIDTESTPURPOSE()
0418 | VLCHTTP3_CurrentPlayListID()
0444 | VLCHTTP3_PlayListID()
0470 | VLCHTTP3_PlaylistAdd(path)
0477 | VLCHTTP3_PlaylistAddPlay(path)
0487 | VLCHTTP3_PlaylistSortID(order=0)
0492 | VLCHTTP3_PlaylistSortName(order=0)
0497 | VLCHTTP3_PlaylistSortAuthor(order=0)
0502 | VLCHTTP3_PlaylistSortRandom(order=0)
0507 | VLCHTTP3_PlaylistSortTrackNum(order=0)
0514 | VLCHTTP3_Sap()
0519 | VLCHTTP3_Shoutcast()
0524 | VLCHTTP3_Podcast()
0529 | VLCHTTP3_Hal()
0534 | VLCHTTP3_ServMod(Mod)
0541 | VLCHTTP3_TimeUF()
0552 | VLCHTTP3_Time()
0557 | VLCHTTP3_LengthUF()
0568 | VLCHTTP3_Length()
0573 | VLCHTTP3_RemainingUT()
0578 | VLCHTTP3_Remaining()
0583 | VLCHTTP3_Position()
0596 | VLCHTTP3_State()
0610 | VLCHTTP3_VidSize()
0624 | FormatSeconds(NumberOfSeconds)
0634 | SendRequest(cmd)
0652 | UrlDownloadToVar(URL, Proxy="", ProxyBypass="")
0711 | UnHTM( HTM )
0734 | uriDecode(str)

;}
;{   WaitForEvent.ahk

;Functions:
0039 | WaitForEvent(Parameter, Timeout = 0, Incremental = 0, FinishWaiting = false)
0046 | if(FinishWaiting)
0073 | if(WaitQueue[Parameter].EventCount = 0)
0098 | RaiseEvent(Parameter)

;}
;{   WaitForIEPageLoad.ahk

;Functions:
0025 | IE_DocumentComplete(prms, sink)
0037 | IEReady(hIESvr = 0)

;Labels:
3721 | OnComplete

;}
;{   WaitPixelColor.ahk

;Functions:
0033 | WaitPixelColor(p_DesiredColor,p_PosX,p_PosY,p_TimeOut=0,p_GetMode="",p_ReturnColor=0)

;}
;{   WakeOnLan.ahk

;Functions:
0006 | WakeOnLAN(mac)
0014 | GenerateMagicPacketHex(mac)
0020 | CreateBinary(hexString, ByRef var)

;}
;{   wam.ahk

;Functions:
0006 | __new()
0013 | CreateAnimationVariable(initialValue)
0024 | ScheduleTransition(variable,transition,timeNow)
0034 | CreateStoryboard()
0043 | FinishAllStoryboards(completionDeadline)
0051 | AbandonAllStoryboards()
0058 | Update(timeNow)
0070 | GetVariableFromTag(object,id)
0080 | GetStoryboardFromTag(object,id)
0090 | GetStatus()
0099 | SetAnimationMode(mode)
0106 | Pause()
0112 | Resume()
0118 | SetManagerEventHandler(handler)
0129 | SetCancelPriorityComparison(comparison)
0136 | SetTrimPriorityComparison(comparison)
0143 | SetCompressPriorityComparison(comparison)
0150 | SetConcludePriorityComparison(comparison)
0157 | SetDefaultLongestAcceptableDelay(delay)
0165 | Shutdown()
0177 | GetValue()
0187 | GetFinalValue()
0195 | GetPreviousValue()
0205 | GetIntegerValue()
0213 | GetFinalIntegerValue()
0221 | GetPreviousIntegerValue()
0229 | GetCurrentStoryboard()
0238 | SetLowerBound(bound)
0245 | SetUpperBound(bound)
0252 | SetRoundingMode(mode)
0260 | SetTag(object,id)
0268 | GetTag()
0279 | SetVariableChangeHandler(handler)
0287 | SetVariableIntegerChangeHandler(handler)
0301 | AddTransition(variable,transition)
0311 | AddKeyframeAtOffset(existingKeyframe,offset)
0321 | AddKeyframeAfterTransition(transition)
0333 | AddTransitionAtKeyframe(variable,transition,startKeyframe)
0343 | AddTransitionBetweenKeyframes(variable,transition,startKeyframe,endKeyframe)
0353 | RepeatBetweenKeyframes(startKeyframe,endKeyframe,repetitionCount=-1)
0363 | HoldVariable(variable)
0371 | SetLongestAcceptableDelay(delay)
0378 | Schedule(timeNow)
0390 | Conclude()
0396 | Finish(completionDeadline)
0404 | Abandon()
0411 | SetTag(object,id)
0420 | GetTag()
0430 | GetStatus()
0438 | GetElapsedTime()
0447 | SetStoryboardEventHandler(handler)
0461 | SetInitialValue(value)
0467 | SetInitialVelocity(velocity)
0473 | IsDurationKnown()
0480 | GetDuration()
0490 | __new()
0498 | SetTimerUpdateHandler(updateHandler,idleBehavior)
0507 | SetTimerEventHandler(handler)
0514 | Enable()
0519 | Disable()
0524 | IsEnabled()
0530 | GetTime()
0539 | SetFrameRateThreshold(framesPerSecond)
0550 | __new()
0556 | CreateInstantaneousTransition(finalValue)
0566 | CreateConstantTransition(duration)
0576 | CreateDiscreteTransition(delay,finalValue,hold)
0588 | CreateLinearTransition(duration,finalValue)
0599 | CreateLinearTransitionFromSpeed(speed,finalValue)
0610 | CreateSinusoidalTransitionFromVelocity(duration,period)
0621 | CreateSinusoidalTransitionFromRange(duration,minimumValue,maximumValue,period,slope)
0636 | CreateAccelerateDecelerateTransition(duration,finalValue,accelerationRatio,decelerationRatio)
0649 | CreateReversalTransition(duration)
0659 | CreateCubicTransition(duration,finalValue,finalVelocity)
0671 | CreateSmoothStopTransition(maximumDuration,finalValue)
0682 | CreateParabolicTransitionFromAcceleration(finalValue,finalVelocity,acceleration)
0702 | SetInitialValueAndVelocity(initialValue,initialVelocity)
0712 | SetDuration(duration)
0719 | GetDuration()
0727 | GetFinalValue()
0735 | InterpolateValue(offset)
0744 | InterpolateVelocity(offset)
0761 | GetDependencies()
0775 | __new()
0780 | CreateTransition(interpolator)
0797 | HasPriority(scheduledStoryboard,newStoryboard,priorityEffect)
0809 | CreateTransition(interpolator)
0884 | WAM_Constant(type)
0930 | WAM_hr(a,ByRef b)

;}
;{   WatchDirectory (2).ahk

;Functions:
0038 | WatchDirectory(WatchFolder="", WatchSubDirs=true)

;Labels:
8120 | StopWatchingDirectories
0134 | ReadDirectoryChanges

;}
;{   wic.ahk

;Functions:
0008 | __new()
0012 | CreateDecoderFromFilename(wzFilename,pguidVendor,dwDesiredAccess,metadataOptions)
0024 | CreateDecoderFromStream(pIStream,pguidVendor,metadataOptions)
0036 | CreateDecoderFromFileHandle(hFile,pguidVendor,metadataOptions)
0047 | CreateComponentInfo(clsidComponent)
0056 | CreateDecoder(guidContainerFormat,pguidVendor)
0067 | CreateEncoder(guidContainerFormat,pguidVendor)
0077 | CreatePalette()
0085 | CreateFormatConverter()
0093 | CreateBitmapScaler()
0101 | CreateBitmapClipper()
0109 | CreateBitmapFlipRotator()
0117 | CreateStream()
0125 | CreateColorContext()
0133 | CreateColorTransformer()
0141 | CreateBitmap(uiWidth,uiHeight,pixelFormat,option)
0152 | CreateBitmapFromSource(pIBitmapSource,option)
0164 | CreateBitmapFromSourceRect(pIBitmapSource,x,y,width,height)
0178 | CreateBitmapFromMemory(uiWidth,uiHeight,pixelFormat,cbStride,cbBufferSize,pbBuffer)
0192 | CreateBitmapFromHBITMAP(hBitmap,hPalette,options)
0202 | CreateBitmapFromHICON(hIcon)
0212 | CreateComponentEnumerator(componentTypes,options)
0223 | CreateFastMetadataEncoderFromDecoder(pIDecoder)
0233 | CreateFastMetadataEncoderFromFrameDecode(pIFrameDecoder)
0242 | CreateQueryWriter(guidMetadataFormat,pguidVendor)
0252 | CreateQueryWriterFromReader(pIQueryReader,pguidVendor)
0269 | GetSize()
0278 | GetPixelFormat(ByRef pPixelFormat)
0288 | GetResolution()
0297 | CopyPalette(pIPalette)
0315 | CopyPixels(prc,cbStride,cbBufferSize)
0331 | Lock(prcLock,flags)
0341 | SetPalette(pIPalette)
0349 | SetResolution(dpiX,dpiY)
0360 | Initialize(pISource,uiWidth,uiHeight,mode)
0373 | Initialize(pISource,prc)
0385 | Initialize(pISource,options)
0397 | Initialize(pIBitmapSource,pIContextSource,pIContextDest,pixelFmtDest)
0411 | GetMetadataQueryReader()
0421 | GetColorContexts(cCount)
0434 | GetThumbnail()
0449 | Initialize(pISource,dstFormat,dither,pIPalette,alphaThresholdPercent,paletteTranslate)
0478 | CanConvert(srcPixelFormat,dstPixelFormat)
0496 | QueryCapability(pIStream)
0505 | Initialize(pIStream,cacheOptions)
0513 | GetContainerFormat()
0521 | GetDecoderInfo()
0530 | CopyPalette(pIPalette)
0538 | GetMetadataQueryReader()
0547 | GetPreview()
0555 | GetColorContexts(cCount)
0567 | GetThumbnail()
0575 | GetFrameCount()
0583 | GetFrame(index)
0599 | Initialize(pIStream,cacheOption)
0607 | GetContainerFormat()
0615 | GetEncoderInfo()
0623 | SetColorContexts(cCount,ppIColorContext)
0632 | SetPalette(pIPalette)
0639 | SetThumbnail(pIThumbnail)
0646 | SetPreview(pIPreview)
0658 | CreateNewFrame(ppIEncoderOptions=0)
0671 | Commit()
0676 | GetMetadataQueryWriter()
0691 | InitializeFromIStream(pIStream)
0700 | InitializeFromFilename(wzFileName,dwDesiredAccess)
0710 | InitializeFromMemory(pbBuffer,cbBufferSize)
0719 | InitializeFromIStreamRegion(pIStream,ulOffset,ulMaxSize)
0736 | GetContainerFormat()
0747 | GetLocation(cchMaxLength,wzNamespace)
0761 | GetMetadataByName(wzName)
0771 | GetEnumerator()
0783 | SetMetadataByName(wzName,pvarValue)
0793 | RemoveMetadataByName(wzName)
0803 | WIC_Struct(name,p=0)
0815 | WIC_Constant()
1060 | WIC_GUID(ByRef GUID,name)
1231 | WIC_hr(a,b)

;}
;{   Win.ahk

;Functions:
0039 | Win_Animate(Hwnd, Type="", Time=100)
0059 | Win_FromPoint(X="mouse", Y="")
0106 | Win_Get(Hwnd, pQ="", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="", ByRef o7="", ByRef o8="", ByRef o9="")
0238 | Win_GetRect(hwnd, pQ="", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="")
0275 | Win_GetChildren(Hwnd)
0301 | Win_GetClassNN(HCtrl, HRoot="")
0336 | Win_Is(Hwnd, pQ="win")
0366 | Win_Move(Hwnd, X="", Y="", W="", H="", Flags="")
0402 | Win_MoveDelta( Hwnd, Xd="", Yd="", Wd="", Hd="", Flags="" )
0472 | Win_Recall(Options, Hwnd="", IniFileName="")
0565 | Win_Redraw( Hwnd=0, Option="" )
0604 | Win_SetMenu(Hwnd, hMenu=0)
0622 | Win_SetIcon(Hwnd, Icon="", Flag=1)
0652 | Win_SetParent(Hwnd, HParent=0, bFixStyle=false)
0688 | Win_SetOwner(Hwnd, hOwner)
0719 | Win_Show(Hwnd, bShow=true)
0734 | Win_ShowSysMenu(Hwnd, X="mouse", Y="")
0784 | Win_Subclass(Hwnd, Fun, Opt="", ByRef $WndProc="")

;Labels:
4135 | Win_Get_C
5139 | Win_Get_I
9143 | Win_Get_N
3150 | Win_Get_B
0154 | Win_Get_R
4158 | Win_Get_L
8161 | Win_Get_Rect
1173 | Win_Get_S
3176 | Win_Get_E
6179 | Win_Get_P
9182 | Win_Get_A
2185 | Win_Get_O
5188 | Win_Get_T
8193 | Win_Get_M
3201 | Win_Get_D
1515 | Win_Recall

;}
;{   WinApi.ahk

;Functions:
0017 | WinApi(mapping="advapi32.dll comctl32.dll comdlg32.dll gdi32.dll kernel32.dll ole32.dll oleaut32.dll psapi.dll shell32.dll user32.dll version.dll winmm.dll wsock32.dll",object="advapi32.dll comctl32.dll comdlg32.dll gdi32.dll kernel32.dll ole32.dll oleaut32.dll psapi.dll shell32.dll user32.dll version.dll winmm.dll wsock32.dll")

;}
;{   WinApiDef.ahk

;Functions:
0001 | WinApiDef(def)

;}
;{   WinCaption.ahk

;Functions:
0001 | WinCaption(Hwnd)

;}
;{   WinClip.ahk

;Functions:
0012 | __New()
0018 | _toclipboard( ByRef data, size )
0058 | _fromclipboard( ByRef clipData )
0112 | _IsInstance( funcName )
0122 | _loadFile( filePath, ByRef Data )
0133 | _saveFile( filepath, byRef data, size )
0141 | _setClipData( ByRef data, size )
0153 | _getClipData( ByRef data )
0164 | __Delete()
0170 | _parseClipboardData( ByRef data, size )
0194 | _compileClipData( ByRef out_data, objClip )
0216 | GetFormats()
0223 | iGetFormats()
0231 | Snap( ByRef data )
0236 | iSnap()
0244 | Restore( ByRef clipData )
0250 | iRestore()
0258 | Save( filePath )
0265 | iSave( filePath )
0273 | Load( filePath )
0280 | iLoad( filePath )
0288 | Clear()
0297 | iClear()
0303 | Copy( timeout = 1, method = 1 )
0317 | iCopy( timeout = 1, method = 1 )
0337 | Paste( plainText = "", method = 1 )
0360 | iPaste( method = 1 )
0375 | IsEmpty()
0380 | iIsEmpty()
0385 | _isClipEmpty()
0390 | _waitClipReady( timeout = 10000 )
0398 | iSetText( textData )
0409 | SetText( textData )
0419 | GetRTF()
0428 | iGetRTF()
0438 | SetRTF( textData )
0448 | iSetRTF( textData )
0459 | _setRTF( ByRef clipData, clipSize, textData )
0471 | iAppendText( textData )
0482 | AppendText( textData )
0492 | SetHTML( html, source = "" )
0502 | iSetHTML( html, source = "" )
0513 | _calcHTMLLen( num )
0520 | _setHTML( ByRef clipData, clipSize, htmlData, source )
0555 | _appendText( ByRef clipData, clipSize, textData, IsSet = 0 )
0572 | _getFiles( pDROPFILES )
0586 | _setFiles( ByRef clipData, clipSize, files, append = 0, isCut = 0 )
0619 | SetFiles( files, isCut = 0 )
0629 | iSetFiles( files, isCut = 0 )
0640 | AppendFiles( files, isCut = 0 )
0650 | iAppendFiles( files, isCut = 0 )
0661 | GetFiles()
0670 | iGetFiles()
0680 | _getFormatData( ByRef out_data, ByRef data, size, needleFormat )
0705 | _DIBtoHBITMAP( ByRef dibData )
0717 | GetBitmap()
0726 | iGetBitmap()
0736 | _BITMAPtoDIB( bitmap, ByRef DIB )
0821 | _setBitmap( ByRef DIB, DIBSize, ByRef clipData, clipSize )
0831 | SetBitmap( bitmap )
0842 | iSetBitmap( bitmap )
0854 | GetText()
0863 | iGetText()
0873 | GetHtml()
0882 | iGetHtml()
0892 | _getFormatName( iformat )
0900 | iGetData( ByRef Data )
0906 | iSetData( ByRef data )
0912 | iGetSize()
0918 | HasFormat( fmt )
0926 | iHasFormat( fmt )
0934 | _hasFormat( ByRef data, size, needleFormat )
0955 | iSaveBitmap( filePath, format )
0974 | SaveBitmap( filePath, format )

;Labels:
4810 | _BITMAPtoDIB_cleanup

;}
;{   WinClipAPI.ahk

;Functions:
0018 | Err( msg )
0022 | ErrorFormat( error_id )
0038 | __Get( name )
0048 | memcopy( dest, src, size )
0051 | GlobalSize( hObj )
0054 | GlobalLock( hMem )
0057 | GlobalUnlock( hMem )
0060 | GlobalAlloc( flags, size )
0063 | OpenClipboard()
0066 | CloseClipboard()
0069 | SetClipboardData( format, hMem )
0072 | GetClipboardData( format )
0075 | EmptyClipboard()
0078 | EnumClipboardFormats( format )
0081 | CountClipboardFormats()
0084 | GetClipboardFormatName( iFormat )
0089 | GetEnhMetaFileBits( hemf, ByRef buf )
0097 | SetEnhMetaFileBits( pBuf, bufSize )
0100 | DeleteEnhMetaFile( hemf )
0103 | ErrorFormat(error_id)
0115 | IsInteger( var )
0121 | LoadDllFunction( file, function )
0128 | SendMessage( hWnd, Msg, wParam, lParam )
0137 | GetWindowThreadProcessId( hwnd )
0140 | WinGetFocus( hwnd )
0149 | GetPixelInfo( ByRef DIB )
0181 | Gdip_Startup()
0189 | Gdip_Shutdown(pToken)
0195 | StrSplit(str,delim,omit = "")
0207 | RemoveDubls( objArray )
0227 | RegisterClipboardFormat( fmtName )
0230 | GetOpenClipboardWindow()
0233 | IsClipboardFormatAvailable( iFmt )
0236 | GetImageEncodersSize( ByRef numEncoders, ByRef size )
0239 | GetImageEncoders( numEncoders, size, pImageCodecInfo )
0242 | GetEncoderClsid( format, ByRef CLSID )

;}
;{   WindowPad.ahk

;Functions:
0039 | WindowPad_LoadSettings(ininame)
0082 | WindowPad_INI_ReadSection(Filename, Section)
0111 | WindowPadMove(P)
0141 | MaximizeToggle(P)
0153 | MoveWindowInDirection(sideX, sideY, widthFactor, heightFactor)
0230 | GetMonitorAt(x, y, default=1)
0244 | IsResizable()
0250 | WindowPad_WinExist(WinTitle)
0263 | WinPreviouslyActive()
0291 | WindowScreenMove(P)
0353 | GatherWindows(md=1)
0455 | Hotkeys(P)
0559 | Hotkey_Params(line, Options="")
0612 | Hotkey_Params_Execute(Hotkey, ByRef List)
0628 | WM_COMMAND(wParam, lParam)
0643 | WindowPad_SetTrayIcon(is_enabled)
0655 | GetLastMinimizedWindow()

;Labels:
5207 | CalcNewPosition
7221 | CalcMonitorStats
1530 | HC_SendThisHotkey
0531 | HC_SendThisHotkeyAndReturn
1606 | ExecuteHotkeyWithParams
6678 | SwitchScreensUnderMouse
8681 | SwitchScreens
1685 | GatherWindows
5688 | WindowPadMove
8691 | WindowScreenMove
1694 | MaximizeToggle
4697 | Hotkeys
7700 | Send
0703 | Minimize
3707 | Unminimize
7711 | Restore

;}
;{   WinEvents.ahk

;Functions:
0018 | WinEvents_RegisterForEvents(sLogName)
0028 | WinEvents_DeregisterForEvents(hSource)

;}
;{   WinGetAll.ahk

;Functions:
0001 | WinGetAll(TextFile = True, DetHidden = False)

;}
;{   WinGetPosEx.ahk

;Functions:
0087 | WinGetPosEx(hWindow,ByRef X="",ByRef Y="",ByRef Width="",ByRef Height="",ByRef Offset_Left="",ByRef Offset_Top="",ByRef Offset_Right="",ByRef Offset_Bottom="")

;}
;{   WinHttpRequest.ahk

;Functions:
0023 | WinHttpRequest( URL, ByRef In_POST__Out_Data="", ByRef In_Out_HEADERS="", Options="" )

;}
;{   WinIniNet.ahk

;Functions:
0013 | WININET_Init()
0018 | WININET_UnInit()
0023 | WININET_InternetOpenA(lpszAgent,dwAccessType=1,lpszProxyName=0,lpszProxyBypass=0,dwFlags=0)
0033 | WININET_InternetConnectA(hInternet,lpszServerName,nServerPort=80,lpszUsername="",lpszPassword="",dwService=3,dwFlags=0,dwContext=0)
0063 | WININET_HttpSendRequestA(hRequest,lpszHeaders="",lpOptional="")
0073 | WININET_InternetReadFile(hFile)
0095 | WININET_FtpCreateDirectoryA(hConnect,lpszDirectory)
0105 | WININET_FtpRemoveDirectoryA(hConnect,lpszDirectory)
0114 | WININET_FtpSetCurrentDirectoryA(hConnect,lpszDirectory)
0123 | WININET_FtpPutFileA(hConnect,lpszLocalFile, lpszNewRemoteFile="", dwFlags=0,dwContext=0)
0139 | WININET_FtpGetFileA(hConnect,lpszRemoteFile, lpszNewFile="", fFailIfExists=1,dwFlagsAndAttributes=0,dwFlags=0,dwContext=0)
0158 | WININET_FtpOpenFileA(hConnect,lpszFileName,dwAccess=0x80000000,dwFlags=0,dwContext=0)
0171 | WININET_InternetCloseHandle(hInternet)
0176 | WININET_FtpGetFileSize(hFile,lpdwFileSizeHigh=0)
0183 | WININET_FtpDeleteFileA(hConnect,lpszFileName)
0194 | WININET_FtpRenameFileA(hConnect,lpszExisting, lpszNew)
0206 | WININET_FindFirstFile(hConnect, lpszSearchFile, ByRef lpFindFileData,dwFlags=0,dwContext=0)
0222 | WININET_FindNextFile(hFind, ByRef lpvFindData)
0229 | UrlGetContents(sUrl,sUserName="",sPassword="",sPostData="",sUserAgent="Autohotkey")

;Labels:
9228 | UrlGetContents()
8321 | CleanUp

;}
;{   WinMovePos.ahk

;Functions:
0019 | WinMovePos(winHwnd, pos)

;}
;{   WinSet_Click_Through.ahk

;Functions:
0021 | WinSet_Click_Through(I="", T="150")
0095 | WinGet_Click_Through(I="")
0120 | WinSet_Click_Through_Class(I="", T="150")
0202 | WinGet_Click_Through_Class(I="")
0231 | WinSet_Click_Through_PID(P="", T="150")
0311 | WinGet_Click_Through_PID(P="")
0338 | WinGet_Transparent(I="")
0357 | WinSet_Click_Through_Click()

;Labels:
5771 | Set_Click_Through
7176 | Remove_Click_Through
6170 | Set_Click_Through_Class
0179 | Remove_Click_Through_Class
9279 | Set_Click_Through_PID
9288 | Remove_Click_Through_PID

;}
;{   WinSet_NoActivate.ahk

;Functions:
0020 | WinSet_NoActivate(I="", T="On")
0071 | WinGet_NoActivate(I="")

;Labels:
7151 | WinSet_NoActivate
5154 | Remove_NoActivate

;}
;{   WinSock2.ahk

;Functions:
0036 | WS2_Connect(lpszUrl)
0103 | WS2_AsyncSelect(Ws2_Socket,UDF,WindowMessage="")
0117 | WS2_SendData(WS2_Socket, StringToSend)
0124 | WS2_SendDataEx(WS2_Socket, DataToSend, DataLength)
0131 | WS2_SendNumber(WS2_Socket, Num, Type="UInt")
0142 | WS2_CleanUp()
0146 | WS2_Disconnect(WS2_Socket)
0154 | __WSA_ScriptInit()
0183 | __WSA_Startup()
0212 | __WSA_Socket()
0234 | __WSA_Connect()
0269 | __WSA_GetHostByName(url)
0297 | __WSA_GetLastError(txt=1)
0318 | __WSA_AsyncSelect(__WSA_Socket, UDF, __WSA_NotificationMsg=0x5000,__WSA_DataReceiver="__WSA_recv")
0346 | __WSA_recv(wParam, lParam)
0397 | __WSA_send(__WSA_Socket, __WSA_Data, __WSA_DataLen)
0413 | __WSA_CloseSocket(__WSA_Socket)
0427 | __WSA_GetThisScriptHandle()
0443 | __WinINet_InternetCrackURL(lpszUrl,arrayName="URL")

;}
;{   WinSysMenuAPI.ahk

;Functions:
0028 | GetSystemMenu(ByRef hWnd, Revert = False)
0034 | DrawMenuBar(hWnd)
0039 | RevertSystemMenu(hWnd = "")
0044 | RemoveMenu(hWnd, Position, Flags = 0)
0050 | EnableMenuItem(hWnd, SystemCommand, EnableFlag)
0055 | DeleteWindowResizing(hWnd = "")
0059 | DeleteWindowMoving(hWnd = "")
0063 | DeleteWindowMinimizing(hWnd = "")
0067 | DeleteWindowMaximizing(hWnd = "")
0071 | DeleteWindowArranging(hWnd = "")
0075 | DeleteWindowRestoring(hWnd = "")
0079 | DeleteWindowClosing(hWnd = "")
0083 | DeleteWindowMenuSeparator(hWnd = "")
0087 | DisableWindowResizing(hWnd = "")
0091 | DisableWindowMoving(hWnd = "")
0095 | DisableWindowMinimizing(hWnd = "")
0099 | DisableWindowMaximizing(hWnd = "")
0103 | DisableWindowArranging(hWnd = "")
0107 | DisableWindowRestoring(hWnd = "")
0111 | DisableWindowClosing(hWnd = "")
0115 | EnableWindowResizing(hWnd = "")
0119 | EnableWindowMoving(hWnd = "")
0123 | EnableWindowMinimizing(hWnd = "")
0127 | EnableWindowMaximizing(hWnd = "")
0131 | EnableWindowArranging(hWnd = "")
0135 | EnableWindowRestoring(hWnd = "")
0139 | EnableWindowClosing(hWnd = "")

;}
;{   WinVisible.ahk

;Functions:
0001 | WinVisible(Title)

;}
;{   WLAN.ahk

;Functions:
0170 | WLAN_WlanAllocateMemory(dwMemorySize)
0175 | WLAN_WlanCloseHandle(hClientHandle)
0180 | WLAN_WlanConnect(hClientHandle,pInterfaceGuid,pConnectionParameters)
0185 | WLAN_WlanDeleteProfile(hClientHandle,pInterfaceGuid,strProfileName)
0190 | WLAN_WlanDisconnect(hClientHandle,pInterfaceGuid)
0195 | WLAN_WlanEnumInterfaces(hClientHandle)
0201 | WLAN_WlanExtractPsdIEDataList(hClientHandle,dwIeDataSize, pRawIeData,strFormat)
0207 | WLAN_WlanFreeMemory(pMemory)
0212 | WLAN_WlanGetAvailableNetworkList(hClientHandle,pInterfaceGuid,dwFlags)
0218 | WLAN_WlanGetFilterList(hClientHandle,wlanFilterListType)
0224 | WLAN_WlanGetInterfaceCapability(hClientHandle,pInterfaceGuid)
0230 | WLAN_WlanGetNetworkBssList(hClientHandle,pInterfaceGuid,pDot11Ssid,dot11BssType,bSecurityEnabled)
0236 | WLAN_WlanGetProfile(hClientHandle,pInterfaceGuid,strProfileName,ByRef dwFlags,ByRef dwGrantedAccess)
0242 | WLAN_WlanGetProfileCustomUserData(hClientHandle,pInterfaceGuid,strProfileName,ByRef dwDataSize)
0248 | WLAN_WlanGetProfileList(hClientHandle,pInterfaceGuid)
0254 | WLAN_WlanGetSecuritySettings(hClientHandle,SecurableObject, ByRef ValueType,ByRef dwGrantedAccess)
0260 | WLAN_WlanIhvControl(hClientHandle,pInterfaceGuid,Type,dwInBufferSize,pInBuffer,dwOutBufferSize,pOutBuffer)
0266 | WLAN_WlanOpenHandle(dwClientVersion = 1, ByRef dwNegotiatedVersion = "")
0272 | WLAN_WlanQueryAutoConfigParameter(hClientHandle,OpCode,ByRef dwDataSize,ByRef WlanOpcodeValueType)
0278 | WLAN_WlanQueryInterface(hClientHandle,pInterfaceGuid,OpCode,ByRef dwDataSize,ByRef WlanOpcodeValueType)
0284 | WLAN_WlanReasonCodeToString(dwReasonCode)
0290 | WLAN_WlanRegisterNotification(hClientHandle,dwNotifSource,bIgnoreDuplicate,funcCallback,pCallbackContext)
0296 | WLAN_WlanRenameProfile(hClientHandle, pInterfaceGuid, strOldProfileName, strNewProfileName)
0301 | WLAN_WlanSaveTemporaryProfile(hClientHandle,pInterfaceGuid,strProfileName, strAllUserProfileSecurity,dwFlags,bOverWrite)
0306 | WLAN_WlanScan(hClientHandle, pInterfaceGuid, pDot11Ssid, pIeData)
0311 | WLAN_WlanSetAutoConfigParameter(hClientHandle,OpCode,dwDataSize,pData)
0316 | WLAN_WlanSetFilterList(hClientHandle,wlanFilterListType,pNetworkList)
0321 | WLAN_WlanSetInterface(hClientHandle,pInterfaceGuid,OpCode,dwDataSize,pData)
0326 | WLAN_WlanSetProfile(hClientHandle, pInterfaceGuid, dwFlags, strProfileXml, strAllUserProfileSecurity, bOverwrite,ByRef dwReasonCode)
0331 | WLAN_WlanSetProfileCustomUserData(hClientHandle,pInterfaceGuid,strProfileName,dwDataSize,pData)
0336 | WLAN_WlanSetProfileEapUserData(hClientHandle,pInterfaceGuid,strProfileName,eapType,dwFlags,dwEapUserDataSize,pbEapUserData)
0341 | WLAN_WlanSetProfileEapXmlUserData(hClientHandle,pInterfaceGuid,strProfileName,dwFlags,strEapXmlUserData)
0346 | WLAN_WlanSetProfileList(hClientHandle,pInterfaceGuid,dwItems,pwstrProfileNames)
0351 | WLAN_WlanSetProfilePosition(hClientHandle,pInterfaceGuid,strProfileName,dwPosition)
0356 | WLAN_WlanSetPsdIEDataList(hClientHandle,strFormat,pPsdIEDataList)
0361 | WLAN_WlanSetSecuritySettings(hClientHandle,SecurableObject,strModifiedSDDL)
0366 | WLAN_WlanUIEditProfile(dwClientVersion,strProfileName,pInterfaceGuid,hWnd,wlStartPage,ByRef dwReasonCode)
0371 | WLAN_Init()
0375 | WLAN_UnInit(hWlan)
0379 | Wlan_GUID4String(ByRef GUID, String)
0386 | Wlan_String4GUID(pGUID)
0393 | Wlan_Ansi4Unicode(pString)
0400 | Wlan_Unicode4Ansi(ByRef wString, sString)

;}
;{   Wmic_Win32_FunctionLog.ahk

;Functions:
0005 | wmic_Win32_Group()
0035 | wmic_Win32_GroupUser()

;Labels:
3529 | StopPullingLogs_11
2959 | StopPullingLogs_12

;}
;{   WPD.ahk

;Functions:
0009 | GetDevices()
0032 | RefreshDeviceList()
0038 | GetDeviceFriendlyName(pszPnPDeviceID)
0054 | GetDeviceDescription(pszPnPDeviceID)
0070 | GetDeviceManufacturer(pszPnPDeviceID)
0088 | GetDeviceProperty(pszPnPDeviceID,pszDevicePropertyName)
0112 | GetPrivateDevices()
0143 | Open(pszPnPDeviceID,pClientInfo)
0152 | SendCommand(pParameters)
0162 | Content()
0170 | Capabilities()
0181 | Cancel()
0187 | Close()
0192 | Advise(dwFlags,pCallback)
0203 | Unadvise(pszCookie)
0212 | GetPnPDeviceID(ppszPnPDeviceID)
0226 | GetCount()
0234 | GetAt(index,pKey,pValue)
0247 | SetValue(key,pValue)
0258 | GetValue(key)
0268 | SetStringValue(key,Value)
0276 | GetStringValue(key)
0286 | SetUnsignedIntegerValue(key,Value)
0294 | GetUnsignedIntegerValue(key)
0303 | SetSignedIntegerValue(key,Value)
0311 | GetSignedIntegerValue(key)
0320 | SetUnsignedLargeIntegerValue(key,Value)
0328 | GetUnsignedLargeIntegerValue(key)
0337 | SetSignedLargeIntegerValue(key,Value)
0345 | GetSignedLargeIntegerValue(key)
0354 | SetFloatValue(key,Value)
0362 | GetFloatValue(key)
0371 | SetErrorValue(key,Value)
0379 | GetErrorValue(key)
0388 | SetKeyValue(key,Value)
0396 | GetKeyValue(key)
0405 | SetBoolValue(key,Value)
0413 | GetBoolValue(key)
0422 | SetIUnknownValue(key,pValue)
0430 | GetIUnknownValue(key)
0439 | SetGuidValue(key,Value)
0447 | GetGuidValue(key,ByRef pValue)
0457 | SetBufferValue(key,pValue,cbValue)
0466 | GetBufferValue(key,ByRef value)
0479 | SetIPortableDeviceValuesValue(key,pValue)
0487 | GetIPortableDeviceValuesValue(key)
0496 | SetIPortableDevicePropVariantCollectionValue(key,pValue)
0504 | GetIPortableDevicePropVariantCollectionValue(key)
0513 | SetIPortableDeviceKeyCollectionValue(key,pValue)
0521 | GetIPortableDeviceKeyCollectionValue(key)
0530 | SetIPortableDeviceValuesCollectionValue(key,pValue)
0538 | GetIPortableDeviceValuesCollectionValue(key)
0547 | RemoveValue(key)
0554 | CopyValuesFromPropertyStore(pStore)
0561 | CopyValuesToPropertyStore(pStore)
0568 | Clear()
0578 | EnumObjects(dwFlags,pszParentObjectID,pFilter)
0589 | Properties()
0597 | Transfer()
0605 | CreateObjectWithPropertiesOnly(pValues)
0614 | CreateObjectWithPropertiesAndData(pValues,ppData,pdwOptimalWriteBufferSize,ppszCookie)
0625 | Delete(dwOptions,pObjectIDs)
0635 | GetObjectIDsFromPersistentUniqueIDs(pPersistentUniqueIDs)
0644 | Cancel()
0649 | Move(pObjectIDs,pszDestinationFolderObjectID)
0659 | Copy(pObjectIDs,pszDestinationFolderObjectID)
0674 | UpdateObjectWithPropertiesAndData(pszObjectID,pProperties)
0691 | GetSupportedProperties(pszObjectID)
0701 | GetPropertyAttributes(pszObjectID,Key)
0711 | GetValues(pszObjectID,pKeys)
0722 | SetValues(pszObjectID,pValues)
0734 | Delete(pszObjectID,pKeys)
0743 | Cancel()
0754 | Next(cObjects)
0764 | Skip(cObjects)
0772 | Reset()
0777 | Clone()
0786 | Cancel()
0797 | GetCount()
0805 | GetAt(dwIndex,ByRef pKey)
0813 | Add(Key)
0820 | Clear()
0825 | RemoveAt(dwIndex)
0838 | GetSupportedResources(pszObjectID)
0847 | GetResourceAttributes(pszObjectID,Key)
0860 | GetStream(pszObjectID,Key,dwMode)
0874 | Delete(pszObjectID,pKeys)
0883 | Cancel()
0891 | CreateResource(pResourceAttributes)
0907 | GetSupportedCommands(ppCommands)
0918 | GetCommandOptions(Command)
0928 | GetFunctionalCategories()
0937 | GetFunctionalObjects(Category)
0946 | GetSupportedContentTypes(Category)
0955 | GetSupportedFormats(ContentType)
0966 | GetSupportedFormatProperties(Format)
0977 | GetFixedPropertyAttributes(Format,Key)
0988 | Cancel()
0993 | GetSupportedEvents()
1001 | GetEventOptions(Event)
1017 | QueueGetValuesByObjectList(pObjectIDs,pKeys,pCallback,ByRef pContext)
1042 | QueueGetValuesByObjectFormat(pguidObjectFormat,pszParentObjectID,dwDepth,pKeys,pCallback,ByRef pContext)
1056 | QueueSetValuesByObjectList(pObjectValues,pCallback,ByRef pContext)
1066 | Start(pContext)
1073 | Cancel(pContext)
1086 | GetCount()
1094 | GetAt(dwIndex)
1105 | Add(pValue)
1112 | GetType()
1120 | ChangeType(vt)
1128 | Clear()
1134 | RemoveAt(dwIndex)
1147 | GetCount()
1155 | GetAt(dwIndex)
1164 | Add(pValues)
1171 | Clear()
1177 | RemoveAt(dwIndex)
1190 | GetObjectID()
1199 | Cancel()
1212 | GetDeviceServices(pszPnPDeviceID,guidServiceCategory)
1238 | GetDeviceForService(pszPnPServiceID)
1253 | Open(pszPnPServiceID,pClientInfo)
1261 | Capabilities()
1269 | Content()
1277 | Methods()
1287 | Cancel()
1294 | Close()
1299 | GetServiceObjectID()
1307 | GetPnPServiceID(ppszPnPServiceID)
1315 | Advise(dwFlags,pCallback,pParameters,ppszCookie)
1326 | Unadvise(pszCookie)
1342 | SendCommand(dwFlags,pParameters)
1357 | GetSupportedMethods()
1365 | GetSupportedMethodsByFormat(Format)
1374 | GetMethodAttributes(Method)
1384 | GetMethodParameterAttributes(Method,Parameter)
1394 | GetSupportedFormats()
1403 | GetFormatAttributes(Format)
1414 | GetSupportedFormatProperties(Format)
1425 | GetFormatPropertyAttributes(Format,Property)
1435 | GetSupportedEvents()
1444 | GetEventAttributes(Event)
1454 | GetEventParameterAttributes(Event,Parameter)
1467 | GetInheritedServices(dwInheritanceType)
1477 | GetFormatRenderingProfiles(Format)
1486 | GetSupportedCommands()
1494 | GetCommandOptions(Command)
1504 | Cancel()
1515 | Invoke(Method,pParameters)
1526 | InvokeAsync(Method,pParameters,pCallback)
1537 | Cancel(pCallback)
1552 | Connect(pCallback)
1562 | Disconnect(pCallback)
1569 | Cancel(pCallback)
1579 | GetProperty(pPropertyKey)
1592 | SetProperty(pPropertyKey,PropertyType,pData,cbData)
1604 | GetPnPID()
1617 | Next(cRequested=1)
1635 | Skip(cConnectors)
1642 | Reset()
1647 | Clone()
1662 | GetDeviceDispatch(pszPnPDeviceID)
1671 | WPD_hr(a,b)

;}
;{   WRandom.ahk

;Functions:
0037 | WRandom(p_FieldStr,ByRef out_Chance=0,ByRef out_P2D=0,ByRef out_D2P=0)

;}
;{   ws.ahk

;Functions:
0074 | WS_HandleEvents(socket, events="READ ACCEPT CONNECT CLOSE")
0103 | WS_Proc(wParam, lParam, msg, hwnd)
0145 | WS_DefProc(socket, event)
0182 | WS_MessageSize(socket)
0193 | WS_EnableBroadcast(socket)
0224 | WS_GetAddrInfo(socket, hostname_or_ip, port, byref sockaddr, byref sockaddrlen)
0259 | WS_Send(socket, message, len=0, flags=0)
0288 | WS_SendBinary(socket, pbuffer, len, flags=0)
0315 | WS_SendFile(socket, file, flags=0)
0364 | WS_SendTo(socket, ip, port, message, len=0, flags=0)
0399 | WS_Recv(socket, byref message, len=0, flags=0)
0434 | WS_RecvBinary(socket, byref pbuffer, len, flags=0)
0464 | WS_RecvFile(socket, file, flags=0)
0510 | WS_RecvFrom(socket, byref out_ip, byref out_port, byref message, len=0, flags=0)
0571 | WS_Connect(socket, ip, port)
0594 | WS_Accept(socket, byref out_ip, byref out_port)
0639 | WS_Bind(socket, ip, port)
0663 | WS_Listen(socket, backlog=32)
0676 | WS_GetSocketInfo(socket, byref af, byref maxsockaddr, byref minsockaddr, byref type, byref protocol)
0699 | WS_Socket(protocol="TCP", ipversion="IPv4")
0726 | WS_CloseSocket(byref socket)
0742 | WS_Startup(version = "2.0")
0782 | WS_Shutdown()
0808 | WS_Log(str, type=0)
0866 | WS_GetConsoleInput()
0887 | WS_GetLog()

;}
;{   ws4ahk.ahk

;Functions:
0113 | WS_Initialize(sLanguage = "VBScript", sMSScriptOCX="")
0186 | WS_Uninitialize()
0246 | WS_Exec(sCode)
0343 | WS_Eval(ByRef xReturn, sCode)
0409 | __WS_HandleScriptError()
0459 | VBStr(s)
0508 | JStr(s)
0722 | WS_ReleaseObject(iObjPtr)
0778 | WS_AddObject(pObject, sName, blnGlobalMembers = False)
0826 | WS_InitComControls()
0862 | WS_UninitComControls()
0901 | WS_GetHWNDofComControl(pComObject)
0945 | WS_GetComControlInHWND(hWnd)
1011 | WS_AttachComControlToHWND(pdsp, hWnd)
1086 | WS_CreateComControlContainer(hWnd, x, y, w, h, sName = "")
1238 | __WS_CreateInstanceFromDll(sDll, ByRef sbinClassId, ByRef sbinIId)
1302 | __WS_GetIDispatch(ppObj, LCID = 0)
1362 | __WS_CLSIDFromProgID(sProgId, ByRef sbinClassId)
1402 | __WS_CLSIDFromString(sClassId, ByRef sbinClassId)
1446 | __WS_IIDFromString(sIId, ByRef sbinIId)
1486 | __WS_IsComError(sFunction, iErr)
1529 | __WS_ComError(iErr, sErrDesc)
1559 | __WS_ANSI2Unicode(sAnsi, ByRef sUtf16)
1628 | __WS_Unicode2ANSI(psUtf16, ByRef sAnsi)
1694 | __WS_VTable(ppv, idx)
1721 | __WS_StringToBSTR(sAnsi)
1761 | __WS_FreeBSTR(iBstrPtr)
1795 | __WS_UnpackVARIANT(ByRef VARIANT, ByRef xReturn)
1945 | __WS_VariantClear(ByRef VAR)
2188 | __WS_IScriptControl_Error(ppvScriptControl)
2224 | __WS_IScriptControl_AddObject(ppvScriptControl, sName, pObjectDispatch, blnAddMembers)
2275 | __WS_IScriptControl_Eval(ppvScriptControl, sExpression, ByRef VarRet)
2327 | __WS_IScriptControl_ExecuteStatement(ppvScriptControl, sStatement)
2394 | __WS_IScriptError_Number(ppvScriptError)
2427 | __WS_IScriptError_Description(ppvScriptError)
2469 | __WS_IScriptError_Clear(ppvScriptError)
2513 | __WS_IClassFactory_CreateInstance(ppvIClassFactory, pUnkOuter, ByRef riid)
2579 | __WS_ITypeInfo_GetTypeAttr(ppTypeInfo)
2612 | __WS_ITypeInfo_ReleaseTypeAttr(ppTypeInfo, pTypeAttr)
2659 | __WS_IDispatch_GetTypeInfoCount(ppDispatch)
2693 | __WS_IDispatch_GetTypeInfo(ppDispatch, LCID = 0)
2739 | __WS_IUnknown_QueryInterface(ppv, iid)
2787 | __WS_IUnknown_AddRef(ppv)
2820 | __WS_IUnknown_Release(ppv)

;}
;{   WS_DEControl.ahk

;Functions:
0128 | DE_Add(hWnd, x, y, w, h)
0133 | DE_Move(pwb, x, y, w, h)
0138 | DE_BrowseMode(sDHtmlEdit)
0154 | DE_LoadUrl(sDhtmlEdit, url)
0160 | DE_NewDocument(sDhtmlEdit)
0167 | DE_LoadDocument(sDhtmlEdit, FileDir)
0173 | DE_SaveDocument(sDhtmlEdit, Filedir)
0180 | DE_GetDocumentHtml(sDhtmlEdit)
0187 | DE_SetDocumentHtml(sDhtmlEdit, sHtml)
0193 | DE_Refresh(sDhtmlEdit)
0205 | DE_SetBOLD(sDhtmlEdit)
0212 | DE_SetUnderline(sDhtmlEdit)
0219 | DE_SetItalic(sDhtmlEdit)
0226 | DE_SetForeColor(sDhtmlEdit, sColor)
0236 | DE_SetHyperLink(sDhtmlEdit)
0246 | DE_SetImage(sDhtmlEdit)
0261 | DE_DOM(sDHtmlEdit)

;}
;{   WS_DEControl2.ahk

;Functions:
0129 | DE_Add(hWnd, x, y, w, h)
0139 | DE_Move(pwb, x, y, w, h)
0144 | DE_BrowseMode()
0160 | DE_LoadUrl(url)
0166 | DE_NewDocument()
0173 | DE_LoadDocument(FileDir)
0179 | DE_SaveDocument(Filedir)
0186 | DE_GetDocumentHtml()
0193 | DE_SetDocumentHtml(sHtml)
0199 | DE_Refresh()
0211 | DE_SetBOLD()
0218 | DE_SetUnderline()
0225 | DE_SetItalic()
0232 | DE_SetForeColor(sColor)
0243 | DE_SetBackColor(sColor)
0253 | DE_Font()
0260 | DE_SetFontName(sFont)
0270 | DE_SetFontSize(iFontSize)
0280 | DE_JustifyLeft()
0287 | DE_JustifyCenter()
0294 | DE_JustifyRight()
0301 | DE_SetHyperLink()
0311 | DE_SetImage()
0321 | DE_UnLink()
0331 | DE_SelectAll()
0340 | DE_Paste(pDHtmlEdit)
0350 | DE_Properties()
0357 | DE_UnDo()
0364 | DE_ReDo()
0371 | DE_FindText()
0378 | DE_Delete()
0385 | DE_Cut()
0392 | DE_COPY()
0401 | DE_OrderList()
0408 | DE_UnorderList()
0416 | DE_InsertTable(numrows, numcols)
0436 | GetSelection()

;}
;{   WS_RemoveErrChk.ahk

;Functions:
0047 | LineBeginsErrorChecking(sLine)
0056 | LineEndsErrorChecking(sLine)

;}
;{   XGraph.ahk

;Functions:
0268 | XGraph_Detach( pGraph )

;Labels:
8159 | XGraph_Info_Data

;}
;{   Xinput (2).ahk

;Functions:
0001 | XinputSetState(index = 1, left_ = 0, right_ = 0)
0070 | XinputGetState(index = 1)
0123 | XinputGetLeftStickAngle()
0137 | XinputGetEvent(index)

;}
;{   Xinput.ahk

;Functions:
0001 | XinputSetState(index = 1, left_ = 0, right_ = 0)
0070 | XinputGetState(index = 1)
0123 | XinputGetLeftStickAngle()
0137 | XinputGetEvent(index)

;}
;{   XML.ahk

;Functions:
0167 | __Delete()
0172 | __Set(property, value)
0186 | __Get(property)
0232 | rename(node, newName)
0285 | getAtt(element, name)
0429 | saveXML()
0434 | transformXML()
0438 | toEntity(ByRef str)
0446 | toChar(ByRef str)
0481 | style()

;Labels:
1619 | viewXMLSize
9620 | viewXMLClose

;}
;{   xpath.ahk

;Functions:
0032 | xpath(ByRef doc, step, set = "")
0356 | xpath_save(ByRef doc, src = "")
0406 | xpath_load(ByRef doc, src = "")

;}
;{   Yaml.ahk

;Functions:
0001 | Yaml(YamlText,IsFile=1,YamlObj=0)
0237 | Yaml_Save(obj,file,level="")
0255 | Yaml_Merge(obj,merge)
0267 | Yaml_Add(O,Yaml="",IsFile=0)
0275 | Yaml_Dump(O,J="",R=0,Q=0)
0344 | Yaml_UniChar( string )
0384 | Yaml_CharUni( string )
0412 | Yaml_EscIfNeed(s)
0419 | Yaml_IsQuoted(ByRef s)
0422 | Yaml_UnQuoteIfNeed(s)
0428 | Yaml_S2I(str)
0437 | Yaml_I2S(idx)
0442 | Yaml_Continue(Obj,key,value,scalar="",isval=0)
0452 | Yaml_Quote(ByRef L,F,Q,B,ByRef E)
0455 | Yaml_SeqMap(o,k,v,isVal=0)
0460 | Yaml_Seq(obj,key,value,isVal=0)
0541 | Yaml_Map(obj,key,value,isVal=0)
0638 | Yaml_Incomplete(value)
0642 | Yaml_IsSeqMap(value)

;}
;{   Zip.ahk

;Functions:
0017 | Zip_Add(sZip, sFiles)
0051 | Zip_Extract(sZip, sDir)

;}
;{   ZipFile.ahk

;Functions:
0024 | __New(file)
0214 | _NewEnum()
0225 | ZipFile(file)

;Labels:
5205 | __zf_get

;}
;{   _.ahk

;Functions:
0049 | _(opt="")
0355 | d(fun, delay="", a1="", a2="" )
0372 | d_(hwnd, msg, id="", time="")
0388 | Fatal(Message, E=1, ExitCode="")

;Labels:
8108 | __HotkeyEsc
8298 | v

;}
;{   _DragDrop.ahk

;Functions:
0045 | __New(hCallback, hDropWnd)
0081 | __Delete()
0108 | ShouldUseDD()
0123 | GetExplorerDDContents(hExplorerWnd)
0142 | Explorer_GetWindow(hwnd="")
0166 | DragDropProc(hExplorerWnd, pDragDrop)
0190 | DD_MouseProc(nCode, wParam, lParam)
0263 | DD_CallNextHookEx(nCode, wParam, lParam)

;}
;{   _filesystem.ahk

;Functions:
0001 | MountVirtualDisk(path = "")
0015 | MountVirtualDiskD(path = "")
0046 | MountVirtualDiskNative(path = "")
0107 | PathRemoveFileSpec(file)
0112 | rmDirTree(root)
0119 | deleteLater(file = "")
0136 | ShellUnzip(arch, dest)
0149 | GetParentDir()
0163 | CreateSimbolicLink(lnk, target, dir=1)
0172 | CreateShortCutsFolder(folder, icon, index=0)

;}
;{   _Input.ahk

;Functions:
0089 | __New(EndKeys,WatchInput="",Options="MIA",MatchList="")
0139 | Input(ByRef Input="",Timer=25,Options="",MatchList="",AlwaysNotify=0)

;Labels:
9156 | _Input

;}
;{   _MemoryLibrary.ahk

;Functions:
0275 | __New(DataPTR)
0346 | GetProcAddress(name)
0369 | Free()
0388 | CopySections(data, oh)
0408 | FinalizeSections()
0442 | PerformBaseRelocation(delta)
0462 | BuildImportTable()

;}
;{   _queue.ahk

;Functions:
0006 | __new(callback, limit = "", type = "fifo")
0015 | __get(key)
0019 | remove(key = "")
0025 | add(id, value)
0029 | Emit()

;}
;{   _RemoteBuf.ahk

;Functions:
0003 | __New(hwnd=0,size=0)
0009 | __Delete()
0018 | Open(size="",hwnd="")
0041 | Read(size=0,offset=0)
0049 | Write(value,offset=0,CP="")
0064 | NumPut(value,offset=0,Type="UInt")

;}
;{   _Scintilla.ahk

;Functions:
0006 | __New(hWnd,x,y,w,h)
0017 | __Delete()
0020 | ADDREFDOCUMENT(pDoc=0)
0023 | ADDSELECTION(caret=0,anchor=0)
0026 | ADDSTYLEDTEXT(s="")
0030 | ADDTEXT(s="")
0034 | ADDUNDOACTION(token=0,flags=0)
0037 | ALLOCATE(bytes=0)
0040 | ANNOTATIONCLEARALL()
0043 | ANNOTATIONGETLINES(line=0)
0046 | ANNOTATIONGETSTYLE(line=0)
0049 | ANNOTATIONGETSTYLEOFFSET()
0052 | ANNOTATIONGETSTYLES(line=0,styles="")
0056 | ANNOTATIONGETTEXT(line=0,text="")
0060 | ANNOTATIONGETVISIBLE()
0063 | ANNOTATIONSETSTYLE(line=0,style=0)
0066 | ANNOTATIONSETSTYLEOFFSET(style=0)
0069 | ANNOTATIONSETSTYLES(line=0,styles="")
0073 | ANNOTATIONSETTEXT(line=0,text="")
0077 | ANNOTATIONSETVISIBLE(visible=0)
0080 | APPENDTEXT(length=0,s="")
0084 | ASSIGNCMDKEY(keyDefinition=0,sciCommand=0)
0087 | AUTOCACTIVE()
0090 | AUTOCCANCEL()
0093 | AUTOCCOMPLETE()
0096 | AUTOCGETAUTOHIDE()
0099 | AUTOCGETCANCELATSTART()
0102 | AUTOCGETCHOOSESINGLE()
0105 | AUTOCGETCURRENT()
0108 | AUTOCGETCURRENTTEXT()
0112 | AUTOCGETDROPRESTOFWORD()
0115 | AUTOCGETIGNORECASE()
0118 | AUTOCGETMAXHEIGHT()
0121 | AUTOCGETMAXWIDTH()
0124 | AUTOCGETSEPARATOR()
0127 | AUTOCGETTYPESEPARATOR()
0130 | AUTOCPOSSTART()
0133 | AUTOCSELECT(select="")
0137 | AUTOCSETAUTOHIDE(autoHide=0)
0140 | AUTOCSETCANCELATSTART(cancel=0)
0143 | AUTOCSETCHOOSESINGLE(chooseSingle=0)
0146 | AUTOCSETDROPRESTOFWORD(dropRestOfWord=0)
0149 | AUTOCSETFILLUPS(chars="")
0153 | AUTOCSETIGNORECASE(ignoreCase=0)
0156 | AUTOCSETMAXHEIGHT(rowCount=0)
0159 | AUTOCSETMAXWIDTH(characterCount=0)
0162 | AUTOCSETSEPARATOR(eparator="")
0166 | AUTOCSETTYPESEPARATOR(eparatorCharacter="")
0170 | AUTOCSHOW(lenEntered=0,list="")
0174 | AUTOCSTOPS(chars="")
0178 | BEGINUNDOACTION()
0181 | BRACEBADLIGHT(pos1=0)
0184 | BRACEHIGHLIGHT(pos1=0,pos2=0)
0187 | BRACEMATCH(pos=0,maxReStyle=0)
0190 | CALLTIPACTIVE()
0193 | CALLTIPCANCEL()
0196 | CALLTIPPOSSTART()
0199 | CALLTIPSETBACK(colour=0)
0202 | CALLTIPSETFORE(colour=0)
0205 | CALLTIPSETFOREHLT(colour=0)
0208 | CALLTIPSETHLT(hlStart=0,hlEnd=0)
0211 | CALLTIPSHOW(posStart=0,definition="")
0215 | CALLTIPUSESTYLE(tabsize=0)
0218 | CANPASTE()
0221 | CANREDO()
0224 | CANUNDO()
0227 | CHANGELEXERSTATE(startPos=0,endPos=0)
0230 | CHARPOSITIONFROMPOINT(x=0,y=0)
0233 | CHARPOSITIONFROMPOINTCLOSE(x=0,y=0)
0236 | CHOOSECARETX()
0239 | CLEAR()
0242 | CLEARALL()
0245 | CLEARALLCMDKEYS()
0248 | CLEARCMDKEY(keyDefinition=0)
0251 | CLEARDOCUMENTSTYLE()
0254 | CLEARREGISTEREDIMAGES()
0257 | CLEARSELECTIONS()
0260 | COLOURISE(startPos=0,endPos=0)
0263 | CONTRACTEDFOLDNEXT(lineStart=0)
0266 | CONVERTEOLS(eolMode=0)
0269 | COPY()
0272 | COPYALLOWLINE()
0275 | COPYRANGE(start=0,end=0)
0278 | COPYTEXT(length=0,text="")
0282 | CREATEDOCUMENT()
0285 | CUT()
0288 | DESCRIBEKEYWORDSETS()
0292 | DESCRIBEPROPERTY(name="")
0297 | DOCLINEFROMVISIBLE(displayLine=0)
0300 | EMPTYUNDOBUFFER()
0303 | ENCODEDFROMUTF8(utf8="")
0309 | ENDUNDOACTION()
0312 | ENSUREVISIBLE(line=0)
0315 | ENSUREVISIBLEENFORCEPOLICY(line=0)
0318 | FINDCOLUMN(line=0,column=0)
0321 | FINDTEXT(searchFlags=0,ttf=0)
0324 | FORMATRANGE(bDraw=0,pfr=0)
0327 | GETADDITIONALCARETFORE()
0330 | GETADDITIONALCARETSBLINK()
0333 | GETADDITIONALCARETSVISIBLE()
0336 | GETADDITIONALSELALPHA()
0339 | GETADDITIONALSELECTIONTYPING()
0342 | GETANCHOR()
0345 | GETBACKSPACEUNINDENTS()
0348 | GETBUFFEREDDRAW()
0351 | GETCARETFORE()
0354 | GETCARETLINEBACK()
0357 | GETCARETLINEBACKALPHA()
0360 | GETCARETLINEVISIBLE()
0363 | GETCARETPERIOD()
0366 | GETCARETSTICKY()
0369 | GETCARETSTYLE()
0372 | GETCARETWIDTH()
0375 | GETCHARACTERPOINTER()
0378 | GETCHARAT(pos=0)
0381 | GETCODEPAGE()
0384 | GETCOLUMN(pos=0)
0387 | GETCONTROLCHARSYMBOL()
0390 | GETCURLINE()
0394 | GETCURRENTPOS()
0397 | GETCURSOR()
0400 | GETDIRECTFUNCTION()
0403 | GETDIRECTPOINTER()
0406 | GETDOCPOINTER()
0409 | GETEDGECOLOUR()
0412 | GETEDGECOLUMN()
0415 | GETEDGEMODE()
0418 | GETENDATLASTLINE()
0421 | GETENDSTYLED()
0424 | GETEOLMODE()
0427 | GETEXTRAASCENT()
0430 | GETEXTRADESCENT()
0433 | GETFIRSTVISIBLELINE()
0436 | GETFOCUS()
0439 | GETFOLDEXPANDED(line=0)
0442 | GETFOLDLEVEL(line=0)
0445 | GETFOLDPARENT(startLine=0)
0448 | GETFONTQUALITY()
0451 | GETHIGHLIGHTGUIDE()
0454 | GETHOTSPOTACTIVEBACK()
0457 | GETHOTSPOTACTIVEFORE()
0460 | GETHOTSPOTACTIVEUNDERLINE()
0463 | GETHOTSPOTSINGLELINE()
0466 | GETHSCROLLBAR()
0469 | GETINDENT()
0472 | GETINDENTATIONGUIDES()
0475 | GETINDICATORCURRENT()
0478 | GETINDICATORVALUE()
0481 | GETKEYSUNICODE()
0484 | GETLASTCHILD(startLine=0,level=0)
0487 | GETLAYOUTCACHE()
0490 | GETLENGTH()
0493 | GETLEXER()
0496 | GETLEXERLANGUAGE()
0501 | GETLINE(line=0)
0506 | GETLINECOUNT()
0509 | GETLINEENDPOSITION(line=0)
0512 | GETLINEINDENTATION(line=0)
0515 | GETLINEINDENTPOSITION(line=0)
0518 | GETLINESELENDPOSITION(line=0)
0521 | GETLINESELSTARTPOSITION(line=0)
0524 | GETLINESTATE(line=0)
0527 | GETLINEVISIBLE(line=0)
0530 | GETMAINSELECTION()
0533 | GETMARGINCURSORN(margin=0)
0536 | GETMARGINLEFT()
0539 | GETMARGINMASKN(margin=0)
0542 | GETMARGINRIGHT()
0545 | GETMARGINSENSITIVEN(margin=0)
0548 | GETMARGINTYPEN(margin=0)
0551 | GETMARGINWIDTHN(margin=0)
0554 | GETMAXLINESTATE()
0557 | GETMODEVENTMASK()
0560 | GETMODIFY()
0563 | GETMOUSEDOWNCAPTURES()
0566 | GETMOUSEDWELLTIME()
0569 | GETMULTIPASTE()
0572 | GETMULTIPLESELECTION()
0575 | GETOVERTYPE()
0578 | GETPASTECONVERTENDINGS()
0581 | GETPOSITIONCACHE()
0584 | GETPRINTCOLOURMODE()
0587 | GETPRINTMAGNIFICATION()
0590 | GETPRINTWRAPMODE()
0593 | GETPROPERTY(key="")
0601 | GETPROPERTYEXPANDED(key="")
0607 | GETPROPERTYINT(key="",default=0)
0611 | GETREADONLY()
0614 | GETRECTANGULARSELECTIONANCHOR()
0617 | GETRECTANGULARSELECTIONANCHORVIRTUALSPACE()
0620 | GETRECTANGULARSELECTIONCARET()
0623 | GETRECTANGULARSELECTIONCARETVIRTUALSPACE()
0626 | GETRECTANGULARSELECTIONMODIFIER()
0629 | GETSCROLLWIDTH()
0632 | GETSCROLLWIDTHTRACKING()
0635 | GETSEARCHFLAGS()
0638 | GETSELALPHA()
0641 | GETSELECTIONEND()
0644 | GETSELECTIONMODE()
0647 | GETSELECTIONNANCHOR(selection=0)
0650 | GETSELECTIONNANCHORVIRTUALSPACE(selection=0)
0653 | GETSELECTIONNCARET(selection=0)
0656 | GETSELECTIONNCARETVIRTUALSPACE(selection=0)
0659 | GETSELECTIONNEND(selection=0)
0662 | GETSELECTIONNSTART(selection=0)
0665 | GETSELECTIONS()
0668 | GETSELECTIONSTART()
0671 | GETSELEOLFILLED()
0674 | GETSELTEXT()
0678 | GETSTATUS()
0681 | GETSTYLEAT(pos=0)
0684 | GETSTYLEBITS()
0687 | GETSTYLEBITSNEEDED()
0690 | GETSTYLEDTEXT(tr=0)
0693 | GETTABINDENTS()
0696 | GETTABWIDTH()
0699 | GETTAG(tagNumber=0)
0703 | GETTARGETEND()
0706 | GETTARGETSTART()
0709 | GETTEXT(Encoding="")
0713 | GETTEXTLENGTH()
0716 | GETTEXTRANGE(cmin=0,cmax=0,Encoding="")
0723 | GETTWOPHASEDRAW()
0726 | GETUNDOCOLLECTION()
0729 | GETUSEPALETTE()
0732 | GETUSETABS()
0735 | GETVIEWEOL()
0738 | GETVIEWWS()
0741 | GETVIRTUALSPACEOPTIONS()
0744 | GETVSCROLLBAR()
0747 | GETWHITESPACESIZE()
0750 | GETWRAPINDENTMODE()
0753 | GETWRAPMODE()
0756 | GETWRAPSTARTINDENT()
0759 | GETWRAPVISUALFLAGS()
0762 | GETWRAPVISUALFLAGSLOCATION()
0765 | GETXOFFSET()
0768 | GETZOOM()
0771 | GOTOLINE(line=0)
0774 | GOTOPOS(pos=0)
0777 | GRABFOCUS()
0780 | HIDELINES(lineStart=0,lineEnd=0)
0783 | HIDESELECTION(hide=0)
0786 | INDICATORALLONFOR(position=0)
0789 | INDICATORCLEARRANGE(position=0,clearLength=0)
0792 | INDICATOREND(indicator=0,position=0)
0795 | INDICATORFILLRANGE(position=0,fillLength=0)
0798 | INDICATORSTART(indicator=0,position=0)
0801 | INDICATORVALUEAT(indicator=0,position=0)
0804 | INDICGETALPHA(indicatorNumber=0)
0807 | INDICGETFORE(indicatorNumber=0)
0810 | INDICGETSTYLE(indicatorNumber=0)
0813 | INDICGETUNDER(indicatorNumber=0)
0816 | INDICSETALPHA(indicatorNumber=0,alpha=0)
0819 | INDICSETFORE(indicatorNumber=0,colour=0)
0822 | INDICSETSTYLE(indicatorNumber=0,indicatorStyle=0)
0825 | INDICSETUNDER(indicatorNumber=0,under=0)
0828 | INSERTTEXT(pos=0,text="")
0832 | LINEFROMPOSITION(pos=0)
0835 | LINELENGTH(line=0)
0838 | LINESCROLL(column=0,line=0)
0841 | LINESJOIN()
0844 | LINESONSCREEN()
0847 | LINESSPLIT(pixelWidth=0)
0850 | LOADLEXERLIBRARY(path="")
0854 | MARGINGETSTYLE(line=0)
0857 | MARGINGETSTYLEOFFSET()
0860 | MARGINGETSTYLES(line=0)
0864 | MARGINGETTEXT(line=0)
0868 | MARGINSETSTYLE(line=0,style=0)
0871 | MARGINSETSTYLEOFFSET(style=0)
0874 | MARGINSETSTYLES(line=0,styles="")
0878 | MARGINSETTEXT(line=0,text="")
0882 | MARGINTEXTCLEARALL()
0885 | MARKERADD(line=0,markerNumber=0)
0888 | MARKERADDSET(line=0,markerMask=0)
0891 | MARKERDEFINE(markerNumber=0,markerSymbols=0)
0894 | MARKERDEFINEPIXMAP(markerNumber=0,xpm="")
0909 | MARKERDELETE(line=0,markerNumber=0)
0912 | MARKERDELETEALL(markerNumber=0)
0915 | MARKERDELETEHANDLE(markerHandle=0)
0918 | MARKERGET(line=0)
0921 | MARKERLINEFROMHANDLE(markerHandle=0)
0924 | MARKERNEXT(lineStart=0,markerMask=0)
0927 | MARKERPREVIOUS(lineStart=0,markerMask=0)
0930 | MARKERSETALPHA(markerNumber=0,alpha=0)
0933 | MARKERSETBACK(markerNumber=0,colour=0)
0936 | MARKERSETFORE(markerNumber=0,colour=0)
0939 | MARKERSYMBOLDEFINED(markerNumber=0)
0942 | MOVECARETINSIDEVIEW()
0945 | NULL()
0948 | PASTE()
0951 | POINTXFROMPOSITION(pos=0)
0954 | POINTYFROMPOSITION(pos=0)
0957 | POSITIONAFTER(position=0)
0960 | POSITIONBEFORE(position=0)
0963 | POSITIONFROMLINE(line=0)
0966 | POSITIONFROMPOINT(x=0,y=0)
0969 | POSITIONFROMPOINTCLOSE(x=0,y=0)
0972 | PROPERTYNAMES()
0976 | PROPERTYTYPE(name="")
0980 | REDO()
0983 | REGISTERIMAGE(type=0,xpmData="")
0987 | RELEASEDOCUMENT(pDoc=0)
0990 | REPLACESEL(text="")
0994 | REPLACETARGET(length=0,text="")
0998 | REPLACETARGETRE(length=0,text="")
1002 | ROTATESELECTION()
1005 | SCROLLCARET()
1008 | SEARCHANCHOR()
1011 | SEARCHINTARGET(length=0,text="")
1015 | SEARCHNEXT(searchFlags=0,text="")
1019 | SEARCHPREV(searchFlags=0,text="")
1023 | SELECTALL()
1026 | SELECTIONISRECTANGLE()
1029 | SETADDITIONALCARETFORE(colour=0)
1032 | SETADDITIONALCARETSBLINK(additionalCaretsBlink=0)
1035 | SETADDITIONALCARETSVISIBLE(additionalCaretsVisible=0)
1038 | SETADDITIONALSELALPHA(alpha=0)
1041 | SETADDITIONALSELBACK(colour=0)
1044 | SETADDITIONALSELECTIONTYPING(additionalSelectionTyping=0)
1047 | SETADDITIONALSELFORE(colour=0)
1050 | SETANCHOR(pos=0)
1053 | SETBACKSPACEUNINDENTS(bsUnIndents=0)
1056 | SETBUFFEREDDRAW(isBuffered=0)
1059 | SETCARETFORE(colour=0)
1062 | SETCARETLINEBACK(colour=0)
1065 | SETCARETLINEBACKALPHA(alpha=0)
1068 | SETCARETLINEVISIBLE(show=0)
1071 | SETCARETPERIOD(milliseconds=0)
1074 | SETCARETSTICKY(useCaretStickyBehaviour=0)
1077 | SETCARETSTYLE(style=0)
1080 | SETCARETWIDTH(pixels=0)
1083 | SETCHARSDEFAULT()
1086 | SETCODEPAGE(codePage=0)
1089 | SETCONTROLCHARSYMBOL(symbol=0)
1092 | SETCURRENTPOS(pos=0)
1095 | SETCURSOR(curType=0)
1098 | SETDOCPOINTER(pDoc=0)
1101 | SETEDGECOLOUR(colour=0)
1104 | SETEDGECOLUMN(column=0)
1107 | SETEDGEMODE(edgeMode=0)
1110 | SETENDATLASTLINE(endAtLastLine=0)
1113 | SETEOLMODE(eolMode=0)
1116 | SETEXTRAASCENT(extraAscent=0)
1119 | SETEXTRADESCENT(extraDescent=0)
1122 | SETFIRSTVISIBLELINE(lineDisplay=0)
1125 | SETFOCUS(focus=0)
1128 | SETFOLDEXPANDED(line=0,expanded=0)
1131 | SETFOLDFLAGS(flags=0)
1134 | SETFOLDLEVEL(line=0,level=0)
1137 | SETFOLDMARGINCOLOUR(useSetting=0,colour=0)
1140 | SETFOLDMARGINHICOLOUR(useSetting=0,colour=0)
1143 | SETFONTQUALITY(fontQuality=0)
1146 | SETHIGHLIGHTGUIDE(column=0)
1149 | SETHOTSPOTACTIVEBACK(useHotSpotBackColour=0,colour=0)
1152 | SETHOTSPOTACTIVEFORE(useHotSpotForeColour=0,colour=0)
1155 | SETHOTSPOTACTIVEUNDERLINE(underline=0)
1158 | SETHOTSPOTSINGLELINE(singleLine=0)
1161 | SETHSCROLLBAR(visible=0)
1164 | SETINDENT(widthInChars=0)
1167 | SETINDENTATIONGUIDES(indentView=0)
1170 | SETINDICATORCURRENT(indicator=0)
1173 | SETINDICATORVALUE(value=0)
1176 | SETKEYSUNICODE(keysUnicode=0)
1179 | SETKEYWORDS(keyWordSet=0,keyWordList="")
1183 | SETLAYOUTCACHE(cacheMode=0)
1186 | SETLENGTHFORENCODE(bytes=0)
1189 | SETLEXER(lexer=0)
1192 | SETLEXERLANGUAGE(name="")
1196 | SETLINEINDENTATION(line=0,indentation=0)
1199 | SETLINESTATE(line=0,value=0)
1202 | SETMAINSELECTION(selection=0)
1205 | SETMARGINCURSORN(margin=0,cursor=0)
1208 | SETMARGINLEFT(pixels=0)
1211 | SETMARGINMASKN(margin=0,mask=0)
1214 | SETMARGINRIGHT(pixels=0)
1217 | SETMARGINSENSITIVEN(margin=0,sensitive=0)
1220 | SETMARGINTYPEN(margin=0,iType=0)
1223 | SETMARGINWIDTHN(margin=0,pixelWidth=0)
1226 | SETMODEVENTMASK(eventMask=0)
1229 | SETMOUSEDOWNCAPTURES(captures=0)
1232 | SETMOUSEDWELLTIME(mSec)
1235 | SETMULTIPASTE(multiPaste=0)
1238 | SETMULTIPLESELECTION(multipleSelection=0)
1241 | SETOVERTYPE(overType=0)
1244 | SETPASTECONVERTENDINGS(convert=0)
1247 | SETPOSITIONCACHE(size=0)
1250 | SETPRINTCOLOURMODE(mode=0)
1253 | SETPRINTMAGNIFICATION(magnification=0)
1256 | SETPRINTWRAPMODE(wrapMode=0)
1259 | SETPROPERTY(key="",value="")
1263 | SETREADONLY(readOnly=0)
1266 | SETRECTANGULARSELECTIONANCHOR(posAnchor=0)
1269 | SETRECTANGULARSELECTIONANCHORVIRTUALSPACE(space=0)
1272 | SETRECTANGULARSELECTIONCARET(pos=0)
1275 | SETRECTANGULARSELECTIONCARETVIRTUALSPACE(space=0)
1278 | SETRECTANGULARSELECTIONMODIFIER(modifier=0)
1281 | SETSAVEPOINT()
1284 | SETSCROLLWIDTH(pixelWidth=0)
1287 | SETSCROLLWIDTHTRACKING(tracking=0)
1290 | SETSEARCHFLAGS(searchFlags=0)
1293 | SETSEL(anchorPos=0,currentPos=0)
1296 | SETSELALPHA(alpha=0)
1299 | SETSELBACK(useSelectionBackColour=0,colour=0)
1302 | SETSELECTION(caret=0,anchor=0)
1305 | SETSELECTIONEND(pos=0)
1308 | SETSELECTIONMODE(mode=0)
1311 | SETSELECTIONNANCHOR(selection=0,posAnchor=0)
1314 | SETSELECTIONNANCHORVIRTUALSPACE(selection=0,space=0)
1317 | SETSELECTIONNCARET(selection=0,pos=0)
1320 | SETSELECTIONNCARETVIRTUALSPACE(selection=0,space=0)
1323 | SETSELECTIONNEND(selection=0,pos=0)
1326 | SETSELECTIONNSTART(selection=0,pos=0)
1329 | SETSELECTIONSTART(pos=0)
1332 | SETSELEOLFILLED(filled=0)
1335 | SETSELFORE(useSelectionForeColour=0,colour=0)
1338 | SETSTATUS(status=0)
1341 | SETSTYLEBITS(bits=0)
1344 | SETSTYLING(length=0,style=0)
1347 | SETSTYLINGEX(length=0,styles="")
1351 | SETTABINDENTS(tabIndents=0)
1354 | SETTABWIDTH(widthInChars=0)
1357 | SETTARGETEND(pos=0)
1360 | SETTARGETSTART(pos=0)
1363 | SETTEXT(text="",Encoding="")
1367 | SETTWOPHASEDRAW(twoPhase=0)
1370 | SETUNDOCOLLECTION(collectUndo=0)
1373 | SETUSEPALETTE(allowPaletteUse=0)
1376 | SETUSETABS(useTabs=0)
1379 | SETVIEWEOL(visible=0)
1382 | SETVIEWWS(wsMode=0)
1385 | SETVIRTUALSPACEOPTIONS(virtualSpace=0)
1388 | SETVISIBLEPOLICY(caretPolicy=0,caretSlop=0)
1391 | SETVSCROLLBAR(visible=0)
1394 | SETWHITESPACEBACK(useWhitespaceBackColour=0,colour=0)
1397 | SETWHITESPACECHARS(chars="")
1401 | SETWHITESPACEFORE(useWhitespaceForeColour=0,colour=0)
1404 | SETWHITESPACESIZE(size=0)
1407 | SETWORDCHARS(chars="")
1411 | SETWRAPINDENTMODE(indentMode=0)
1414 | SETWRAPMODE(wrapMode=0)
1417 | SETWRAPSTARTINDENT(indent=0)
1420 | SETWRAPVISUALFLAGS(wrapVisualFlags=0)
1423 | SETWRAPVISUALFLAGSLOCATION(wrapVisualFlagsLocation=0)
1426 | SETXCARETPOLICY(caretPolicy=0,caretSlop=0)
1429 | SETXOFFSET(xOffset=0)
1432 | SETYCARETPOLICY(caretPolicy=0,caretSlop=0)
1435 | SETZOOM(zoomInPoints=0)
1438 | SHOWLINES(lineStart=0,lineEnd=0)
1441 | STARTRECORD()
1444 | STARTSTYLING(pos=0,mask=0)
1447 | STOPRECORD()
1450 | STYLECLEARALL()
1453 | STYLEGETBACK(styleNumber=0)
1456 | STYLEGETBOLD(styleNumber=0)
1459 | STYLEGETCASE(styleNumber=0)
1462 | STYLEGETCHANGEABLE(styleNumber=0)
1465 | STYLEGETCHARACTERSET(styleNumber=0)
1468 | STYLEGETEOLFILLED(styleNumber=0)
1471 | STYLEGETFONT(styleNumber=0)
1475 | STYLEGETFORE(styleNumber=0)
1478 | STYLEGETHOTSPOT(styleNumber=0)
1481 | STYLEGETITALIC(styleNumber=0)
1484 | STYLEGETSIZE(styleNumber=0)
1487 | STYLEGETUNDERLINE(styleNumber=0)
1490 | STYLEGETVISIBLE(styleNumber=0)
1493 | STYLERESETDEFAULT()
1496 | STYLESETBACK(styleNumber=0,colour=0)
1499 | STYLESETBOLD(styleNumber=0,bold=0)
1502 | STYLESETCASE(styleNumber=0,caseMode=0)
1505 | STYLESETCHANGEABLE(styleNumber=0,changeable=0)
1508 | STYLESETCHARACTERSET(styleNumber=0,charSet=0)
1511 | STYLESETEOLFILLED(styleNumber=0,eolFilled=0)
1514 | STYLESETFONT(styleNumber=0,fontName="")
1518 | STYLESETFORE(styleNumber=0,colour=0)
1521 | STYLESETHOTSPOT(styleNumber=0,hotspot=0)
1524 | STYLESETITALIC(styleNumber=0,italic=0)
1527 | STYLESETSIZE(styleNumber=0,sizeInPoints=0)
1530 | STYLESETUNDERLINE(styleNumber=0,underline=0)
1533 | STYLESETVISIBLE(styleNumber=0,visible=0)
1536 | SWAPMAINANCHORCARET()
1539 | TARGETASUTF8()
1543 | TARGETFROMSELECTION()
1546 | TEXTHEIGHT(line=0)
1549 | TEXTWIDTH(styleNumber=0,text="")
1553 | TOGGLECARETSTICKY()
1556 | TOGGLEFOLD(line=0)
1559 | UNDO()
1562 | USEPOPUP(bEnablePopup=0)
1565 | USERLISTSHOW(listType=0,list="")
1569 | VISIBLEFROMDOCLINE(docLine=0)
1572 | WORDENDPOSITION(position=0,onlyWordCharacters=0)
1575 | WORDSTARTPOSITION(position=0,onlyWordCharacters=0)
1578 | WRAPCOUNT(docLine=0)
1581 | ZOOMIN()
1584 | ZOOMOUT()
1588 | HOMERECTEXTEND()
1591 | BACKTAB()
1594 | CANCEL()
1597 | CHARLEFT()
1600 | CHARLEFTEXTEND()
1603 | CHARLEFTRECTEXTEND()
1606 | CHARRIGHT()
1609 | CHARRIGHTEXTEND()
1612 | CHARRIGHTRECTEXTEND()
1615 | DELETEBACK()
1618 | DELETEBACKNOTLINE()
1621 | DELLINELEFT()
1624 | DELLINERIGHT()
1627 | DELWORDLEFT()
1630 | DELWORDRIGHT()
1633 | DELWORDRIGHTEND()
1636 | DOCUMENTEND()
1639 | DOCUMENTENDEXTEND()
1642 | DOCUMENTSTART()
1645 | DOCUMENTSTARTEXTEND()
1648 | EDITTOGGLEOVERTYPE()
1651 | FORMFEED()
1654 | HOME()
1657 | HOMEDISPLAY()
1660 | HOMEDISPLAYEXTEND()
1663 | HOMEEXTEND()
1666 | HOMEWRAP()
1669 | HOMEWRAPEXTEND()
1672 | LINECOPY()
1675 | LINECUT()
1678 | LINEDELETE()
1681 | LINEDOWN()
1684 | LINEDOWNEXTEND()
1687 | LINEDOWNRECTEXTEND()
1690 | LINEDUPLICATE()
1693 | LINEEND()
1696 | LINEENDDISPLAY()
1699 | LINEENDDISPLAYEXTEND()
1702 | LINEENDEXTEND()
1705 | LINEENDRECTEXTEND()
1708 | LINEENDWRAP()
1711 | LINEENDWRAPEXTEND()
1714 | LINESCROLLDOWN()
1717 | LINESCROLLUP()
1720 | LINETRANSPOSE()
1723 | LINEUP()
1726 | LINEUPEXTEND()
1729 | LINEUPRECTEXTEND()
1732 | LOWERCASE()
1735 | NEWLINE()
1738 | PAGEDOWN()
1741 | PAGEDOWNEXTEND()
1744 | PAGEDOWNRECTEXTEND()
1747 | PAGEUP()
1750 | PAGEUPEXTEND()
1753 | PAGEUPRECTEXTEND()
1756 | PARADOWN()
1759 | PARADOWNEXTEND()
1762 | PARAUP()
1765 | PARAUPEXTEND()
1768 | SELECTIONDUPLICATE()
1771 | STUTTEREDPAGEDOWN()
1774 | STUTTEREDPAGEDOWNEXTEND()
1777 | STUTTEREDPAGEUP()
1780 | STUTTEREDPAGEUPEXTEND()
1783 | TAB()
1786 | UPPERCASE()
1789 | VCHOME()
1792 | VCHOMEEXTEND()
1795 | VCHOMERECTEXTEND()
1798 | VCHOMEWRAP()
1801 | VCHOMEWRAPEXTEND()
1804 | VERTICALCENTRECARET()
1807 | WORDLEFT()
1810 | WORDLEFTEND()
1813 | WORDLEFTENDEXTEND()
1816 | WORDLEFTEXTEND()
1819 | WORDPARTLEFT()
1822 | WORDPARTLEFTEXTEND()
1825 | WORDPARTRIGHT()
1828 | WORDPARTRIGHTEXTEND()
1831 | WORDRIGHT()
1834 | WORDRIGHTEND()
1837 | WORDRIGHTENDEXTEND()
1840 | WORDRIGHTEXTEND()
1844 | StyleSet(style,set)

;}
;{   _Struct.ahk

;Functions:
0090 | ___InitField(_this,N,offset=" ",encoding=0,AHKType=0,isptr=" ",type=0,arrsize=0,memory=0)
0128 | __NEW(_TYPE_,_pointer_=0,_init_=0)
0325 | SizeT(_key_="")
0328 | Size()
0331 | IsPointer(_key_="")
0334 | Type(_key_="")
0337 | AHKType(_key_="")
0340 | Offset(_key_="")
0343 | Encoding(_key_="")
0346 | Capacity(_key_="")
0349 | Alloc(_key_="",size="",ptrsize=0)
0401 | ___Clone(offset)

;}
;{   Examples\Appfactory_Example.ahk

;Functions:
0014 | InputEvent(ctrl, state)
0019 | GuiEvent(ctrl, state)

;Labels:
1924 | GuiClose

;}
;{   Examples\Appfactory_Simplest Example.ahk

;Functions:
0012 | InputEvent(state)
0017 | GuiEvent(state)

;Labels:
1722 | GuiClose

;}
;{   Examples\GDI_GraphicsPathExample.ahk

;Functions:
0076 | WM_LBUTTONDOWN()
0094 | Gdip_AddPathBeziers(pPath, Points)
0105 | Gdip_AddPathBezier(pPath, x1, y1, x2, y2, x3, y3, x4, y4)
0119 | Gdip_AddPathLines(pPath, Points)
0130 | Gdip_AddPathLine(pPath, x1, y1, x2, y2)
0135 | Gdip_AddPathArc(pPath, x, y, w, h, StartAngle, SweepAngle)
0139 | Gdip_AddPathPie(pPath, x, y, w, h, StartAngle, SweepAngle)
0143 | Gdip_StartPathFigure(pPath)
0147 | Gdip_ClosePathFigure(pPath)
0160 | Gdip_DrawPath(pGraphics, pPen, pPath)
0164 | Gdip_WidenPath(pPath, pPen, Matrix=0, Flatness=1)
0168 | Gdip_ClonePath(pPath)

;}
;{   Examples\testing-ash.ahk_l

;Functions:
0047 | Finished( id )

;}
;{   Examples\AHKSock\example_1_client.ahk

;Functions:
0080 | Recv(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, iLength = 0)
0104 | AHKsockErrors(iError, iSocket)
0110 | Bin2Hex(addr,len)

;Labels:
1049 | CloseAHKsock

;}
;{   Examples\AHKSock\example_1_server.ahk

;Functions:
0077 | Send(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bRecvData = 0, bRecvDataLength = 0)
0165 | AHKsockErrors(iError, iSocket)

;Labels:
6546 | CloseAHKsock

;}
;{   Examples\AHKSock\example_2_client.ahk

;Functions:
0137 | Recv(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bNewData = 0, bNewDataLength = 0)
0321 | AHKsockErrors(iError, iSocket)
0325 | CopyBinData(ptrSource, ptrDestination, iLength)
0335 | File_Open(sType, sFile)
0350 | File_Read(hFile, ByRef bData, iLength = 0)
0367 | File_Write(hFile, ptrData, iLength)
0377 | File_Pointer(hFile, iOffset = 0, iMethod = -1)
0399 | File_Size(hFile)
0407 | File_Close(hFile)

;Labels:
0794 | btnBrowse
4101 | btnServer
1109 | btnConnect
9122 | GuiClose
2123 | GuiEscape
3124 | CloseAHKsock

;}
;{   Examples\AHKSock\example_2_server_multiple_clients.ahk

;Functions:
0126 | Send(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, iLength = 0)
0321 | AHKsockErrors(iError, iSocket)
0344 | SocketPointer(iSocket = -1, sAction = "Count", iValue = -1)
0415 | File_Open(sType, sFile)
0430 | File_Read(hFile, ByRef bData, iLength = 0)
0447 | File_Write(hFile, ptrData, iLength)
0457 | File_Pointer(hFile, iOffset = 0, iMethod = -1)
0479 | File_Size(hFile)
0487 | File_Close(hFile)

;Labels:
8774 | btnBrowse
7481 | btnListen
1111 | GuiClose
1112 | GuiEscape
2113 | CloseAHKsock

;}
;{   Examples\AHKSock\example_2_server_single_client.ahk

;Functions:
0122 | Send(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, iLength = 0)
0366 | AHKsockErrors(iError, iSocket)
0370 | CopyBinData(ptrSource, ptrDestination, iLength)
0380 | File_Open(sType, sFile)
0395 | File_Read(hFile, ByRef bData, iLength = 0)
0412 | File_Write(hFile, ptrData, iLength)
0422 | File_Pointer(hFile, iOffset = 0, iMethod = -1)
0444 | File_Size(hFile)
0452 | File_Close(hFile)

;Labels:
5270 | btnBrowse
7077 | btnListen
7107 | GuiClose
7108 | GuiEscape
8109 | CloseAHKsock

;}
;{   Examples\AHKSock\example_2_server_transmitfile.ahk

;Functions:
0125 | Send(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, iLength = 0)
0186 | AHKsockErrors(iError, iSocket)
0195 | File_Open(sType, sFile)
0210 | File_Read(hFile, ByRef bData, iLength = 0)
0227 | File_Write(hFile, ptrData, iLength)
0237 | File_Pointer(hFile, iOffset = 0, iMethod = -1)
0259 | File_Size(hFile)
0267 | File_Close(hFile)

;Labels:
6769 | btnBrowse
6976 | btnListen
6106 | GuiClose
6107 | GuiEscape
7108 | CloseAHKsock

;}
;{   Examples\AHKSock\example_3.ahk

;Functions:
0210 | AddDialog(ptrText, bYou = True)
0228 | Peer(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, bDataLength = 0)
0418 | StreamProcessor(ByRef bNewData = 0, bNewDataLength = -1)
0539 | AHKsockErrors(iError, iSocket)
0543 | CopyBinData(ptrSource, ptrDestination, iLength)
0552 | InsertText(hEdit, ptrText, iPos = -1)
0565 | Anchor(i, a = "", r = false)

;Labels:
5105 | GuiSize
5112 | GuiEscape
2113 | GuiClose
3128 | txtInput
8166 | btnSend

;}
;{   Mini_Framwork\0.3\System\MfArithmeticException.ahk

;Functions:
0057 | __New(message = "", innerException = "")

;}
;{   Mini_Framwork\0.3\System\MfAttribute.ahk

;Functions:
0044 | __New()
0074 | CompareTo(obj)

;}
;{   Mini_Framwork\0.3\System\MfBidiCategory.ahk

;Functions:
0078 | AddEnums()
0106 | DestroyInstance()
0120 | GetInstance()

;}
;{   Mini_Framwork\0.3\System\MfBool.ahk

;Functions:
0353 | CompareTo(obj)
0394 | Equals(value)
0444 | GetHashCode()
0459 | GetTypeCode()
0630 | _GetValue(obj)
0772 | Is(ObjType)
0851 | ToString()
0988 | _TrimWhiteSpaceAndNull(value)
0993 | _TrimWhiteSpaceAndNullRight(value)
1019 | _TrimWhiteSpaceAndNullLeft(value)

;}
;{   Mini_Framwork\0.3\System\MfByte.ahk

;Functions:
0303 | Add(value)
0357 | CompareTo(obj)
0401 | Divide(value)
0467 | Equals(value)
0517 | GetHashCode()
0529 | GetTypeCode()
0643 | _GetValue(obj)
0712 | _GetValueFromVar(varInt)
0793 | GreaterThen(value)
0837 | GreaterThenOrEqual(value)
0881 | LessThen(value)
0925 | LessThenOrEqual(value)
0973 | Multiply(value)
1129 | Subtract(value)
1174 | ToString()

;}
;{   Mini_Framwork\0.3\System\MfChar.ahk

;Functions:
0445 | CompareTo(obj)
0492 | GetHashCode()
0558 | GetTypeCode()
1683 | ToString()
1710 | TryParse(ByRef result, s)
1755 | Equals(obj)
1769 | CheckLetter(uc)
1781 | CheckLetterOrDigit(uc)
1794 | CheckNumber(uc)
1804 | CheckPunctuation(uc)
1818 | CheckSeparator(uc)
1828 | CheckSymbol(uc)
1933 | _GetCharValue(c)
2033 | _GetByteArray()
2110 | GetLatin1UnicodeCategory(c)
2138 | IsAscii(c)
2159 | _isCharInstance(ByRef c)
2167 | _IsDigit(c)
2205 | IsLatin1(c)
2229 | _IsSeparatorLatin1(c)
2240 | _IsSurrogateSI(s, index, methodName = "")
2261 | _IsSurrogateC(c)
2267 | _IsSurrogatePairCC(highSurrogate, lowSurrogate)
2276 | _IsSurrogatePairSI(s, index, methodName = "")
2314 | IsCharObj(obj)
2319 | _ResetLength()
2325 | _StrPutVar(String, ByRef Var, encoding)
2331 | _Text2Hex(String)
2348 | _Hex2Text(Hex)
2470 | __Delete()

;}
;{   Mini_Framwork\0.3\System\MfCharUnicodeInfo.ahk

;Functions:
0056 | __New()
0506 | _InternalConvertToUtf32Cl(s, index, ByRef charLength)
0525 | _InternalConvertToUtf32(s, index)
0542 | GetUnicodeCategory(c)
0623 | _GetCharFromString(s, index)

;}
;{   Mini_Framwork\0.3\System\MfCollection.ahk

;Functions:
0029 | __New()

;}
;{   Mini_Framwork\0.3\System\MfCollectionBase.ahk

;Functions:
0036 | __New()
0063 | Add(obj)
0095 | Clear()
0123 | Contains(obj)
0133 | _NewEnum()
0144 | __new(ParentClass)
0149 | Next(ByRef key, ByRef value)
0189 | IndexOf(obj)
0217 | Insert(index, obj)
0256 | OnClear()
0273 | OnClearComplete()
0300 | OnInsert(index, ByRef value)
0326 | OnInsertComplete(index, ByRef value)
0356 | OnSet(index, ByRef oldValue, ByRef newValue)
0386 | OnSetComplete(index, ByRef oldValue, ByRef newValue)
0414 | OnRemove(index, ByRef value)
0443 | OnRemoveComplete(index, ByRef value)
0470 | OnValidate(ByRef obj)
0504 | Remove(obj)
0550 | RemoveAt(index)
0588 | ToString()

;}
;{   Mini_Framwork\0.3\System\MfDateTime.ahk

;Functions:
0066 | __New(MfDateTime, returnAsObj = false)
0076 | DateToTicks(year, month, day)
0110 | ToFileTimeUtc()
0123 | ToString()
0132 | GetType()

;}
;{   Mini_Framwork\0.3\System\MfDictionary.ahk

;Functions:
0031 | __New()

;}
;{   Mini_Framwork\0.3\System\MfDictionarybase.ahk

;Functions:
0040 | __New(capacity = 0)
0078 | Add(key, value)
0124 | Clear()
0147 | Contains(key)
0157 | _NewEnum()
0168 | __new(ParentClass)
0177 | Next(ByRef key, ByRef value)
0208 | OnClear()
0223 | OnClearComplete()
0247 | OnInsert(key, ByRef value)
0271 | OnInsertComplete(key, ByRef value)
0295 | OnRemove(key, ByRef value)
0319 | OnRemoveComplete(key, ByRef value)
0345 | OnSet(key, ByRef oldValue, ByRef newValue)
0371 | OnSetComplete(key, ByRef oldValue, ByRef newValue)
0396 | OnValidate(key, ByRef value)
0419 | Remove(key)

;}
;{   Mini_Framwork\0.3\System\MfDictionaryEntry.ahk

;Functions:
0041 | __New(key, value)

;}
;{   Mini_Framwork\0.3\System\MfDigitShapes.ahk

;Functions:
0084 | AddEnums()
0107 | GetInstance()

;}
;{   Mini_Framwork\0.3\System\MfDivideByZeroException.ahk

;Functions:
0061 | __New(message = "", innerException = "")

;}
;{   Mini_Framwork\0.3\System\MfEnum.ahk

;Functions:
0198 | AddAttributes()
0212 | AddEnums()
0240 | AddEnumValue(name, value)
0287 | AddFlag(flag)
0348 | DestroyInstance()
0383 | Equals(objA, objB="")
0447 | CompareTo(obj)
0490 | GetHashCode()
0513 | GetInstance()
0530 | GetNames()
0549 | GetTypeCode()
0554 | GetValue(eInstance, EnumType = "")
0607 | GetValues()
0638 | HasFlag(flag)
0687 | _HasFlag(flag)
0733 | Parse(enumType, value, ignoreCase = true)
0770 | ParseItem(enumType, value, ignoreCase = true)
0796 | RemoveFlag(flag)
0879 | TryParse(value, ByRef outEnum, ignoreCase = true)
0930 | TryParseItem(enumType, value, ByRef outEnumItem, ignoreCase = true)
0944 | _GetEnumItemByValue(EnumType, iValue)
0971 | _GetEnumItemCI(EnumType, strKey)
0998 | _GetEnumItemCS(EnumType, strKey)
1056 | TryParseEnum(enumType, value, ignoreCase, ByRef parseResult)
1157 | if(_ignoreCase)
1207 | _TryParseEnumItem(EnumType, value, ignoreCase, ByRef parseResult)
1271 | if(_ignoreCase)
1308 | _GetEnumInstance(enumType)
1334 | if(outArray0)
1370 | GetEnumValuesAndNames(enumType, ByRef Values, ByRef Names, getValues = true, getNames = true)
1468 | ToObject(enumType, value)
1550 | ToString()
1577 | if(v.Value = this.Value)
1645 | __New(name, value, byref type, byref pEnum)
1709 | CompareTo(obj)
1773 | Equals(objA, objB = "")
1840 | GetHashCode()
1858 | GetTypeCode()
1882 | Is(ObjType)
1902 | ToString()
2017 | __New(value = 0)
2041 | AddEnums()
2057 | DestroyInstance()
2072 | GetInstance()
2112 | __New(canMethodThrow)
2124 | GetEnumParseException()
2139 | SetFailure(argA, argB = "_empty", argC = "_empty")
2156 | SetFailureA(unhandledException)
2160 | SetFailureB(failure, failureParameter)
2168 | SetFailureC(failure, failureMessageID, failureMessageFormatArgument)
2288 | if(this._hasFlagsAttributeValue = -1)

;}
;{   Mini_Framwork\0.3\System\MfEnumerableBase.ahk

;Functions:
0039 | __New()
0060 | GetEnumerator()
0075 | _NewEnum()

;}
;{   Mini_Framwork\0.3\System\MfEnvironment.ahk

;Functions:
0036 | __New()
0061 | DestroyInstance()
0076 | Reset()
0164 | GetInstance()

;}
;{   Mini_Framwork\0.3\System\MfEqualityComparerBase.ahk

;Functions:
0035 | __New()
0072 | Equals(x, y)
0103 | GetHashCode(obj)

;}
;{   Mini_Framwork\0.3\System\MfEqualsOptions.ahk

;Functions:
0089 | AddAttributes()
0106 | AddEnums()
0129 | GetInstance()
0153 | DestroyInstance()

;}
;{   Mini_Framwork\0.3\System\MfException.ahk

;Functions:
0077 | __New(message = "", innerException = "")
0135 | CompareTo(obj)
0168 | ConvertFromException(e)
0207 | GetBaseException()
0226 | GetClassName()
0263 | GetHashCode()
0283 | ToString()
0510 | IsValidException(e)
0522 | SetErrorCode(hr)

;}
;{   Mini_Framwork\0.3\System\MfFlagsAttribute.ahk

;Functions:
0038 | __New()
0054 | DestroyInstance()
0069 | GetInstance()

;}
;{   Mini_Framwork\0.3\System\MfFloat.ahk

;Functions:
0360 | Add(value)
0414 | CompareTo(obj)
0457 | Equals(value)
0510 | Divide(value)
0597 | GetHashCode()
0631 | GetTypeCode()
0801 | _GetValue(obj)
0864 | GreaterThen(value)
0912 | GreaterThenOrEqual(value)
0958 | GetTrimmed()
1066 | LessThen(value)
1114 | LessThenOrEqual(value)
1167 | Multiply(value)
1343 | Subtract(value)
1394 | ToInteger(flt)
1448 | ToString()
1600 | _cDoubleToInt64(input)
1625 | _cInt64ToInt(input)
1637 | _ForceFormat()
1645 | _GetFmtObjValue(fObj)
1665 | _GetFmtValue(f, fmt)
1680 | _SetFormat(Value)
1705 | _GetFormatFromArg(arg)

;}
;{   Mini_Framwork\0.3\System\MfFormatException.ahk

;Functions:
0060 | __New(message = "", innerException = "")

;}
;{   Mini_Framwork\0.3\System\MfFormatProvider.ahk

;Functions:
0034 | __New()
0063 | GetFormat(formatType)

;}
;{   Mini_Framwork\0.3\System\MfFrameWorkOptions.ahk

;Functions:
0064 | AddAttributes()
0075 | AddEnums()
0095 | GetInstance()
0110 | DestroyInstance()

;}
;{   Mini_Framwork\0.3\System\MfGenericList.ahk

;Functions:
0047 | __New(genericType)
0093 | Add(obj)
0128 | Clear()
0164 | Contains(obj)
0198 | _NewEnum()
0210 | __new(ParentClass)
0215 | Next(ByRef key, ByRef value)
0253 | IndexOf(obj)
0308 | Insert(index, obj)
0367 | Remove(obj)
0418 | RemoveAt(index)

;}
;{   Mini_Framwork\0.3\System\MfHashTable.ahk

;Functions:
0032 | __New(capacity = 0)
0061 | Add(key, value)
0095 | Clear()
0122 | Contains(key)
0144 | ContainsKey(key)
0169 | ContainsValue(value)
0217 | GetHash(key)
0252 | Remove(key)
0278 | _UpdateVersion()
0293 | _NewEnum()
0304 | __new(ParentClass)
0313 | Next(ByRef key, ByRef value)

;}
;{   Mini_Framwork\0.3\System\MfIndexOutOfRangeException.ahk

;Functions:
0065 | __New(message = "", innerException = "")

;}
;{   Mini_Framwork\0.3\System\MfInfo.ahk

;Functions:
0062 | __New()
0079 | GetHelpFileLocation()
0110 | GetProgInstallLocation()

;}
;{   Mini_Framwork\0.3\System\MfInt16.ahk

;Functions:
0291 | Add(value)
0347 | CompareTo(obj)
0391 | Divide(value)
0457 | Equals(value)
0491 | GetHashCode()
0504 | GetTypeCode()
0672 | _GetValue(obj)
0733 | _GetValueFromVar(varInt)
0814 | GreaterThen(value)
0858 | GreaterThenOrEqual(value)
0902 | LessThen(value)
0946 | LessThenOrEqual(value)
0995 | Multiply(value)
1143 | Subtract(value)
1188 | ToString()
1324 | _cInt64ToInt(input)
1343 | _cInt16ToUInt16(input)
1362 | _uIntToInt(uInt)
1371 | _ReturnInt16(obj)

;}
;{   Mini_Framwork\0.3\System\MfInt64.ahk

;Functions:
0291 | Add(value)
0347 | CompareTo(obj)
0391 | Divide(value)
0457 | Equals(value)
0491 | GetHashCode()
0506 | GetTypeCode()
0674 | _GetValue(obj)
0735 | _GetValueFromVar(varInt)
0816 | GreaterThen(value)
0860 | GreaterThenOrEqual(value)
0904 | LessThen(value)
0948 | LessThenOrEqual(value)
0997 | Multiply(value)
1145 | Subtract(value)
1190 | ToString()
1326 | _cInt64ToInt(input)
1345 | _uIntToInt(uInt)

;}
;{   Mini_Framwork\0.3\System\MfInteger.ahk

;Functions:
0321 | Add(value)
0376 | Divide(value)
0443 | CompareTo(obj)
0484 | Equals(value)
0518 | GetHashCode()
0530 | GetTypeCode()
0698 | _GetValue(obj)
0766 | _GetValueFromVar(varInt)
0847 | GreaterThen(value)
0883 | GreaterThenOrEqual(value)
0928 | Is(ObjType)
0962 | LessThen(value)
1009 | LessThenOrEqual(value)
1057 | Multiply(value)
1209 | Subtract(value)
1254 | ToString()

;}
;{   Mini_Framwork\0.3\System\MfInvalidOperationException.ahk

;Functions:
0060 | __New(message = "", innerException = "")

;}
;{   Mini_Framwork\0.3\System\MfList.ahk

;Functions:
0032 | __New()
0056 | Add(obj)
0084 | Clear()
0119 | Contains(obj)
0155 | _NewEnum()
0166 | __new(ParentClass)
0171 | Next(ByRef key, ByRef value)
0207 | IndexOf(obj)
0266 | Insert(index, obj)
0310 | Remove(obj)
0354 | RemoveAt(index)

;}
;{   Mini_Framwork\0.3\System\MfListBase.ahk

;Functions:
0035 | __New()
0063 | Add(obj)
0081 | Clear()
0105 | Contains(obj)
0129 | IndexOf(obj)
0154 | Insert(index, obj)
0183 | Remove(obj)
0205 | RemoveAt(index)
0219 | ToString()

;}
;{   Mini_Framwork\0.3\System\MfMemberAccessException.ahk

;Functions:
0065 | __New(message = "", innerException = "")

;}
;{   Mini_Framwork\0.3\System\MfNameObjectCollectionBase.ahk

;Functions:
0047 | __New()
0121 | __New(coll)
0127 | Get(index)
0166 | __New(name, obj)
0179 | __New(coll)
0186 | MoveNext()
0204 | Reset()

;}
;{   Mini_Framwork\0.3\System\MfNotImplementedException.ahk

;Functions:
0059 | __New(message = "", innerException = "")

;}
;{   Mini_Framwork\0.3\System\MfNotSupportedException.ahk

;Functions:
0059 | __New(message = "", innerException = "")

;}
;{   Mini_Framwork\0.3\System\MfNull.ahk

;Functions:
0038 | __New()
0062 | GetInstance()
0123 | __New()
0152 | Equals(obj)
0173 | GetInstance()
0196 | GetObjOrNull(obj)
0218 | GetValue(obj)
0242 | Is(ObjType)
0272 | IsNull(obj = "")
0351 | ToString()

;}
;{   Mini_Framwork\0.3\System\MfNullReferenceException.ahk

;Functions:
0059 | __New(message = "", innerException = "")

;}
;{   Mini_Framwork\0.3\System\MfNumberFormatInfo.ahk

;Functions:
0086 | __New()
0097 | CheckGroupSize(propName, groupSize)
0135 | ReadOnly(nfi)
0159 | VerifyDigitSubstitution(digitSub, propertyName)
0171 | VerifyNativeDigits(nativeDig, propertyName)

;}
;{   Mini_Framwork\0.3\System\MfNumberFormatInfoBase.ahk

;Functions:
0038 | __New()

;}
;{   Mini_Framwork\0.3\System\MfNumberStyles.ahk

;Functions:
0084 | AddAttributes()
0098 | AddEnums()
0135 | GetInstance()
0156 | DestroyInstance()

;}
;{   Mini_Framwork\0.3\System\MfObject.ahk

;Functions:
0055 | __New()
0081 | AddAttribute(attrib)
0123 | CompareTo(obj)
0237 | GetAttribute(index)
0269 | GetAttributes()
0310 | GetHashCode()
0345 | GetIndexOfAttribute(attrib)
0386 | GetType()
0410 | HasAttribute(attrib)
0460 | Is(ObjType)
0498 | IsInstance()
0522 | IsMfObject(obj)
0561 | IsObjInstance(obj, objType = "")
0597 | MemberwiseClone()
0623 | ReferenceEquals(objA, objB)
0645 | ToString()
0995 | _IsNull(obj)
1031 | _ParamAddStringCompVar(var1, var2, byref p)
1033 | if(A_StringCaseSense = "On")
1062 | _ParamAddNumbCompVar(var1, var2, byref p)
1064 | if(A_StringCaseSense = "On")

;}
;{   Mini_Framwork\0.3\System\MfOrdinalComparer.ahk

;Functions:
0031 | __New(ignoreCase)
0036 | Compare(x, y)
0071 | Equals(x, y)
0096 | GetHashCode(obj)

;}
;{   Mini_Framwork\0.3\System\MfOverflowException.ahk

;Functions:
0062 | __New(message = "", innerException = "")

;}
;{   Mini_Framwork\0.3\System\MfParams.ahk

;Functions:
0147 | AddBool(value)
0191 | AddByte(value)
0244 | AddChar(value)
0288 | AddFloat(value)
0332 | AddInt64(value)
0385 | AddInteger(value)
0438 | AddString(value)
0484 | Add(value)
0537 | B(value)
0571 | C(value)
0589 | D(value)
0615 | F(value)
0675 | GetValue(index)
0712 | I(value)
0742 | OnValidate(ByRef value)
0790 | S(value)
0822 | ToString()
0867 | ToStringList()
0929 | _LoadKeyValueParam(value)

;}
;{   Mini_Framwork\0.3\System\MfPrimitive.ahk

;Functions:
0053 | __New(value, returnAsObject = false, SetReadOnly = false)
0104 | ToString()
0113 | _ReturnBool(obj)
0125 | _ReturnByte(obj)
0137 | _ReturnChar(obj)
0149 | _ReturnDate(obj)
0161 | _ReturnFloat(obj)
0173 | _ReturnInteger(obj)
0185 | _ReturnInt64(obj)
0197 | _ReturnString(obj)
0209 | _ReturnTimeSpan(obj)
0359 | _ErrorCheckParameter(index, pArgs, AllowUndefined = true)

;}
;{   Mini_Framwork\0.3\System\MfQueue.ahk

;Functions:
0032 | __New()
0045 | Clear()
0064 | Contains(obj)
0115 | Dequeue()
0139 | Enqueue(obj)
0159 | _NewEnum()
0170 | __new(ParentClass)
0175 | Next(ByRef key, ByRef value)
0208 | Peek()

;}
;{   Mini_Framwork\0.3\System\MfResourceManager.ahk

;Functions:
0048 | __New(lang = "en-US")
0098 | SetResDir(lang)
0251 | IsValidLanguageResource(lang)
0381 | GetResourceString(key, Section="CORE")

;}
;{   Mini_Framwork\0.3\System\MfResourceSingletonBase.ahk

;Functions:
0040 | __New()
0063 | DestroyInstance()
0145 | GetInstance()

;}
;{   Mini_Framwork\0.3\System\MfSetFormatNumberType.ahk

;Functions:
0069 | __New(value = 2)
0093 | AddEnums()
0112 | DestroyInstance()
0133 | GetInstance()

;}
;{   Mini_Framwork\0.3\System\MfSingletonBase.ahk

;Functions:
0040 | __New()
0061 | DestroyInstance()
0083 | GetInstance()

;}
;{   Mini_Framwork\0.3\System\MfStack.ahk

;Functions:
0032 | __New()
0045 | Clear()
0064 | Contains(obj)
0115 | Pop()
0144 | _NewEnum()
0155 | __new(ParentClass)
0160 | Next(ByRef key, ByRef value)
0191 | Push(obj)
0216 | Peek()

;}
;{   Mini_Framwork\0.3\System\MfString.ahk

;Functions:
0223 | Append(value)
0262 | AppendLine(value="")
0480 | CompareTo(obj)
0895 | if(mfSc.Value = MfStringComparison.Instance.Ordinal.Value)
1197 | EscapeSend()
1304 | GetHashCode()
1326 | __MD5( ByRef V, L=0 )
1352 | GetValue(obj)
1396 | IsStringObj(obj)
1414 | IsNullOrEmpty(str = "")
1461 | _Index(i)
2796 | Remove(startIndex)
2838 | Reverse(str = "")
2841 | if(_ist)
2845 | if(this.ReturnAsObject)
2888 | if(this.ReturnAsObject)
2898 | if(str.ReturnAsObject)
3004 | if(bTrimLineEndChars)
3208 | if(mfSc.Value = MfStringComparison.Instance.Ordinal.Value)
3548 | ToCharArray(startIndex = 0, length = "")
3646 | ToLower()
3666 | ToString()
3683 | ToTitle()
3701 | ToUpper()
3730 | Trim(trimChars = "")
3788 | TrimEnd(trimChars = "")
3845 | TrimStart(trimChars = "")
3940 | _CompareSISII(strA, indexA, strB, indexB, length)
3948 | _CompareSISIIB(strA, indexA, strB, indexB, length, ignoreCase)
3975 | _CompareSSB(strA, strB, ignoreCase)
3981 | _CompareSSC(strA, strB, comparisonType)
4008 | _CompareSS(strA, strB)
4056 | _CreateTrimmedString(start, end)
4074 | _IndexOfC(searchChar)
4077 | _IndexOfCI(searchChar, startIndex)
4085 | _IndexOfCII(searchChar, startIndex, count)
4093 | _IndexOfS(searchString)
4096 | _IndexofSI(searchString, startIndex)
4104 | _IndexofSII(searchString, startIndex, count)
4112 | _IndexOfSC(str, searchChar)
4147 | _IndexOfSS(str, searchString)
4153 | _LastIndexOfSC(str, searchChar)
4183 | _LastIndexOfC(searchChar)
4186 | _LastIndexOfCI(searchChar, startIndex)
4192 | _LastIndexOfCII(searchChar, startIndex, count)
4207 | _LastIndexOfS(searchString)
4210 | _LastIndexOfSS(str,searchString)
4224 | _LastIndexOfSI(searchString, startIndex)
4230 | _LastIndexOfSII(searchString, startIndex, count)
4247 | __PadHelper(Str, PadChar,PadLen,Left=1)
4274 | _ResetLength()
4328 | String2Hex(x)
4339 | _GetCRC32(x)
4371 | _TrimHelperA(trimType)
4410 | _TrimHelperB(trimChars, trimType)
4467 | _TrimHelperC(trimChars, trimType)

;}
;{   Mini_Framwork\0.3\System\MfStringComparison.ahk

;Functions:
0079 | __New(value = 5)
0131 | AddEnums()
0148 | DestroyInstance()
0168 | GetInstance()

;}
;{   Mini_Framwork\0.3\System\MfStringSplitOptions.ahk

;Functions:
0067 | __New(value)
0086 | AddAttributes()
0101 | AddEnums()
0125 | DestroyInstance()
0147 | GetInstance()

;}
;{   Mini_Framwork\0.3\System\MfSystemException.ahk

;Functions:
0059 | __New(message = "", innerException = "")

;}
;{   Mini_Framwork\0.3\System\MfTimeSpan.ahk

;Functions:
0271 | Add(ts)
0316 | Compare(t1, t2)
0363 | CompareTo(obj)
0390 | Duration()
0513 | FromDays(value)
0572 | FromHours(value)
0630 | FromMilliseconds(value)
0688 | FromMinutes(value)
0746 | FromSeconds(value)
0804 | FromTicks(value)
0849 | GetHashCode()
0863 | Interval(value, scale)
0895 | Negate()
1044 | _ParseBuild(iDays=0,iHours=0, iMin=0, iSec=0, iFrac=0, iLz = 0)
1087 | _LeadingZeros(value)
1123 | Subtract(ts)
1145 | TimeToTicks(hour, minute, second)
1174 | ToString()

;}
;{   Mini_Framwork\0.3\System\MfType.ahk

;Functions:
0081 | __New(obj, TypeName = "")
0099 | _Init(T)
0113 | if(T.__Class)
0223 | CompareTo(obj)
0285 | Equals(objA, objB = "")
0327 | GetHashCode()
0401 | IsObject()
0425 | SetMfObject(obj)
0513 | ToString()
0539 | TypeOf(obj)
0567 | TypeOfName(obj)

;}
;{   Mini_Framwork\0.3\System\MfTypeCode.ahk

;Functions:
0077 | AddEnums()
0102 | DestroyInstance()
0116 | GetInstance()

;}
;{   Mini_Framwork\0.3\System\Mfunc.ahk

;Functions:
0039 | __New()
0080 | ControlGet(Cmd, Value = "", Control = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
0121 | ControlGetFocus(WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
0156 | ControlGetText(Control = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
0189 | DriveGet(Cmd, Value = "")
0219 | DriveSpaceFree(Path)
0245 | EnvGet(EnvVarName)
0291 | FileAppend(Text="", Filename="", Encoding="")
0353 | FileCopy(SourcePattern, DestPattern, Flag = "")
0404 | FileCopyDir(Source, Dest, Flag = "")
0436 | FileCreateDir(DirName)
0471 | FileDelete(FilePattern)
0524 | FileGetAttrib(Filename = "")
0582 | FileGetShortcut(LinkFile, ByRef OutTarget = "", ByRef OutDir = "", ByRef OutArgs = "", ByRef OutDescription = "", ByRef OutIcon = "", ByRef OutIconNum = "", ByRef OutRunState = "")
0634 | FileGetSize(Filename = "", Units = "")
0678 | FileGetTime(Filename = "", WhichTime = "")
0718 | FileGetVersion(Filename = "")
0768 | FileMove(Source, Dest, Flag="")
0828 | FileMoveDir(Source, Dest, Flag="")
0916 | FileRead(Filename)
0972 | FileReadLine(Filename, LineNum)
1013 | FileRemoveDir(Path, Recurse = 0)
1141 | FileSelectFile(Options = "", RootDir = "", Prompt = "", Filter = "")
1234 | FileSelectFolder(StartingFolder = "", Options = "", Prompt = "")
1299 | FileSetAttrib(Attributes, FilePattern="", OperateOnFolders=0, Recurse=0)
1344 | FormatTime(YYYYMMDDHH24MISS = "", Format = "")
1361 | Functions()
1488 | GuiControlGet(Subcommand = "", ControlID = "", Param4 = "")
1541 | IfBetween(ByRef var, LowerBound, UpperBound)
1571 | IfNotBetween(ByRef var, LowerBound, UpperBound)
1600 | IfIn(ByRef var, MatchList)
1629 | IfNotIn(ByRef var, MatchList)
1657 | IfContains(ByRef var, MatchList)
1685 | IfNotContains(ByRef var, MatchList)
1709 | IfIs(ByRef var, type)
1733 | IfIsNot(ByRef var, type)
1865 | ImageSearch(ByRef OutputVarX, ByRef OutputVarY, X1, Y1, X2, Y2, ImageFile)
1906 | IniDelete(Filename, Section, Key= "")
1980 | IniRead(Filename, Section = "", Key = "", Default = "")
2031 | IniWrite(Value, FileName, Section, Key = "")
2185 | Input(Options = "", EndKeys = "", MatchList = "")
2258 | InputBox(Title = "", Prompt = "", HIDE = "", Width = "", Height = "", X = "", Y = "", Font = "", Timeout = "", Default = "")
2333 | MouseGetPos(ByRef OutputVarX = "", ByRef OutputVarY = "", ByRef OutputVarWin = "", ByRef OutputVarControl = "", Mode = "")
2399 | PixelGetColor(X, Y, RGB = "")
2483 | PixelSearch(ByRef OutputVarX, ByRef OutputVarY, X1, Y1, X2, Y2, ColorID, Variation = "", Mode = "")
2569 | Process(Cmd, Pid_Or_Name, Parm3="")
2666 | Random(Min = "", Max = "")
2720 | RegRead(RootKey, SubKey, ValueName = "")
2946 | Run(Target, WorkingDir = "", Mode = "")
3089 | RunWait(Target, WorkingDir = "", Mode = "")
3167 | SoundGet(ComponentType = "", ControlType = "", DeviceNumber = "")
3287 | SetFormat(NumberType, Format)
3397 | SoundGetWaveVolume(DeviceNumber = 1)
3465 | StatusBarGetText(Part = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
3539 | SplitPath(ByRef Input, ByRef OutFileName = "", ByRef OutDir = "", ByRef OutExtension = "", ByRef OutNameNoExt = "", ByRef OutDrive = "")
3604 | StringGetPos(ByRef Input, SearchText, Mode = "", Offset = "")
3636 | StringLeft(ByRef Input, Count)
3667 | StringLen(ByRef Input)
3707 | StringLower(ByRef Input, T = "")
3763 | StringMid(ByRef Input, StartChar, Count , L = "")
3821 | StringReplace(ByRef Input, SearchText, ReplaceText = "", All = "")
3859 | StringRight(ByRef Input, Count)
3944 | StringTrimLeft(ByRef Input, Count)
3976 | StringTrimRight(ByRef Input, Count)
4013 | StringUpper(ByRef Input, T = "")
4202 | SysGet(Subcommand, Param3 = "")
4395 | Transform(Cmd, Value1, Value2 = "")
4441 | WinActivate(WinTitle = "", WinText = "", ExcludeTitle ="",ExcludeText = "")
4590 | WinGet(Cmd = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
4610 | WinGetActiveTitle()
4647 | WinGetClass(WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
4710 | WinGetText(WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
4760 | WinGetTitle(WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
4769 | _SetObjValue(byref obj, value)
4784 | _GetStringFromVarOrObj(InputVar)
4828 | IsNumeric(num)
4853 | IsInteger(num)
4878 | IsFloat(num)

;}
;{   Mini_Framwork\0.3\System\MfUnicodeCategory.ahk

;Functions:
0244 | AddEnums()
0287 | DestroyInstance()
0308 | GetInstance()

;}
;{   Mini_Framwork\0.3\System\MfValueType.ahk

;Functions:
0039 | __New()

;}
;{   Mini_Framwork\0.3\System\MfVersion.ahk

;Functions:
0097 | __New(arg1="",arg2="",arg3="",arg4="")
0265 | CompareTo(value)
0329 | GetHashCode()
0354 | GreaterThen(value)
0392 | GreaterThenOrEqual(value)
0430 | LessThen(value)
0468 | LessThenOrEqual(value)
0509 | Parse(input)
0553 | ToString(fieldCount = -1)
0569 | _ToString(fieldCount)
0616 | _TryParseVersion(version, ByRef result)
0665 | _TryParseComponent(component, componentName, ByRef result, ByRef parsedComponent)
0720 | AddEnums()
0737 | GetInstance()
0761 | Is(ObjType)
0778 | DestroyInstance()
0794 | __New()
0797 | Init(argumentName, canThrow)
0802 | SetFailure(failure, argument = "")
0811 | GetVersionParseException()
0830 | Is(ObjType)

;}
;{   Mini_Framwork\0.3\System\IO\MfFileNotFoundException.ahk

;Functions:
0136 | ToString()

;}
;{   Mini_Framwork\0.3\System\MfUnicode\MfDataBaseFactory.ahk

;Functions:
0010 | OpenDataBase(dbType, connectionString)
0011 | if(dbType = "SQLite")
0018 | if(handle == 0)
0039 | __New()

;}
;{   Mini_Framwork\0.3\System\MfUnicode\MfDbUcdAbstract.ahk

;Functions:
0043 | _intiColumnsFields(columns, fields)
0076 | _initDic(dicColFields)
0125 | HasColumn(columnName)
0131 | ToString()
0147 | ContainsIndex(index)
0166 | __NewEnum()
0184 | Is(ObjType)
0196 | _NewEnum()
0207 | __new(ParentClass)
0216 | Next(ByRef key, ByRef value)
0249 | __New(rows, columns)
0318 | Is(ObjType)
0329 | Count()
0333 | ToString()
0339 | __NewEnum()
0350 | __New()
0354 | __delete()
0358 | IsValid()
0367 | Query(sql)
0375 | QueryValue(sQry)
0382 | QueryRow(sQry)
0389 | OpenRecordSet(sql, editable = false)
0397 | ToSqlLiteral(value)
0409 | EscapeString(string)
0417 | QuoteIdentifier(identifier)
0425 | BeginTransaction()
0433 | EndTransaction()
0441 | Rollback()
0449 | Insert(record, tableName)
0457 | InsertMany(records, tableName)
0465 | Update(fields, constraints, tableName, safe = True)
0472 | Close()
0495 | Is(ObjType)
0510 | __New()
0530 | __delete()
0534 | TestRecordSet()
0538 | AddNew()
0546 | MoveNext()
0554 | Delete()
0562 | Update()
0570 | Close()
0578 | getEOF()
0586 | IsValid()
0594 | getColumnNames()
0602 | getCurrentRow()
0621 | Is(ObjType)

;}
;{   Mini_Framwork\0.3\System\MfUnicode\MfRecordSetSqlLite.ahk

;Functions:
0040 | __New(db, query)
0067 | Test()
0075 | IsValid()
0082 | getColumnNames()
0086 | getEOF()
0091 | MoveNext()
0162 | Reset()
0183 | Close()

;}
;{   Mini_Framwork\0.3\System\MfUnicode\MfSQLite_L.ahk

;Functions:
0096 | __New()
0106 | SQLite_Startup()
0150 | SQLite_Shutdown()
0162 | SQLite_OpenDB(DBFile)
0212 | SQLite_IsFilePathValid(path)
0232 | SQLite_CloseDB(DB)
0272 | SQLite_GetTable(DB, SQL, ByRef Rows, ByRef Cols, ByRef Names, ByRef Result, MaxResult = -1)
0345 | SQLite_Bind(query, idx, val, type = "auto")
0394 | SQLite_Bind_blob(query, idx, addr, bytes)
0398 | SQLite_Bind_text(query, idx, text)
0403 | SQLite_bind_double(query, idx, double)
0407 | SQLite_bind_int(query, idx, int)
0411 | SQLite_bind_null(query, idx)
0415 | SQLite_Step(query)
0419 | SQLite_Reset(query)
0432 | SQLite_Exec(DB, SQL)
0498 | SQlite_Query(DB, SQL)
0534 | SQLite_FetchNames(Query, ByRef Names)
0574 | SQLite_QueryFinalize(Query)
0605 | SQLite_QueryReset(Query)
0639 | SQLite_SQLiteExe(DBFile, Commands, ByRef Output)
0698 | SQLite_LibVersion()
0716 | SQLite_LastInsertRowID(DB, ByRef rowId)
0742 | SQLite_Changes(DB, ByRef Rows)
0770 | SQLite_TotalChanges(DB, ByRef Rows)
0796 | SQLite_ErrMsg(DB, ByRef Msg)
0822 | SQLite_ErrCode(DB, ByRef Code)
0849 | SQLite_SetTimeout(DB, Timeout = 1000)
0879 | SQLite_LastError(Error = "")
0895 | SQLite_DLLPath(forcedPath = "")
0899 | if(DLLPath == "")
0926 | SQLite_EXEPath(forcedPath = "")
0951 | _SQLite_StrToUTF8(Str, ByRef UTF8)
0959 | _SQLite_UTF8ToStr(UTF8, ByRef Str)
0967 | _SQLite_ModuleHandle(Handle = "")
0977 | _SQLite_CurrentDB(DB = "")
0987 | _SQLite_CheckDB(DB, Action = "")
1009 | _SQLite_CurrentQuery(Query = "")
1019 | _SQLite_CheckQuery(Query, DB = "")
1042 | _SQLite_ReturnCode(RC)
1098 | Create(srcPtr, size)
1110 | CreateFromFile(filePath)
1133 | CreateFromBase64(base64str)
1147 | GetPtr()
1156 | WriteToFile(filePath)
1169 | Free()
1185 | IsValid()
1192 | ToBase64()
1208 | __Delete()
1217 | memcpy(dst, src, cnt)
1229 | AllocMemory(size)
1268 | Is(ObjType)
1290 | ToString()

;}
;{   Mini_Framwork\0.3\System\MfUnicode\MfUcdDb.ahk

;Functions:
0005 | GetVersion()
0009 | SQLiteExe(dbFile, commands, ByRef output)
0013 | __New()
0029 | __New(handleDB)
0042 | Close()
0046 | IsValid()
0050 | GetLastError()
0056 | GetLastErrorMsg()
0062 | SetTimeout(timeout = 1000)
0067 | ErrMsg()
0073 | ErrCode()
0077 | Changes()
0085 | OpenRecordSet(sql, editable = false)
0102 | Query(sql)
0131 | EscapeString(str)
0136 | QuoteIdentifier(identifier)
0144 | BeginTransaction()
0148 | EndTransaction()
0152 | Rollback()
0167 | InsertMany(records, tableName)
0250 | printKeys(arr)
0269 | Insert(row, tableName)
0297 | _GetTableObj(sql, maxResult = -1)
0394 | Is(ObjType)
0406 | ReturnCode(RC)

;}
;{   Mini_Framwork\0.3\System\MfUnicode\UCDSqlite.ahk

;Functions:
0008 | __New()
0050 | GetUnicodeGeneralCategory(iChar)
0089 | GetDigitValue(iChar)
0126 | GetDecimalDigitValue(iChar)
0156 | GetNumericValue(iChar)
0196 | _GetNV(iChar)
0242 | FractionToDec(strF)
0270 | GetInstance()
0300 | DestroyInstance()
0321 | Is(ObjType)
0333 | QuoteIdentifier(identifier)
0340 | RunSQL(SQL)

;}
;{   Mini_Libs\AhkDllObject.ahk

;Functions:
0001 | AhkDllObject(dll="AutoHotkey.dll",obj=0)

;}
;{   Mini_Libs\ahkExec.ahk

;Functions:
0001 | ahkExec(Script)

;}
;{   Mini_Libs\AhkExported.ahk

;Functions:
0001 | AhkExported()

;}
;{   Mini_Libs\AhkThread.ahk

;Functions:
0012 | ahkthread_release(o)

;}
;{   Mini_Libs\AHKType.ahk

;Functions:
0006 | AHKType(exeName)

;}
;{   Mini_Libs\audioRouter.ahk

;Functions:
0023 | __new(path)
0039 | __delete()
0057 | getDeviceList()
0065 | _method1(procName)
0084 | _selectDeviceRouteWindow(deviceName)
0107 | killIt()
0113 | LVM_GETITEMPOSITION(itemIdx,hwnd)

;}
;{   Mini_Libs\BinToHex.ahk

;Functions:
0001 | BinToHex(addr,len)

;}
;{   Mini_Libs\borderlessMode.ahk

;Functions:
0001 | borderlessMode(winId="")

;}
;{   Mini_Libs\borderlessMove.ahk

;Functions:
0001 | borderlessMove(winId="",key="LButton")

;}
;{   Mini_Libs\checkSession.ahk

;Functions:
0045 | checkSession(_msgHandler,_params=0)
0051 | checkSession_msgHandler(wParam,lParam,msg,hwnd)

;}
;{   Mini_Libs\commaFormat.ahk

;Functions:
0001 | commaFormat(num)

;}
;{   Mini_Libs\compileScript.ahk

;Functions:
0001 | compileScript(file,out="",bin="",icon="",mpress=0)
0007 | if(bin)
0011 | if(icon)

;}
;{   Mini_Libs\ComVar.ahk

;Functions:
0001 | ComVar(Type=0xC)
0017 | ComVarDel(cv)

;}
;{   Mini_Libs\ConnectedToInternet.ahk

;Functions:
0003 | ConnectedToInternet(flag=0x40)

;}
;{   Mini_Libs\CopyDirStructure.ahk

;Functions:
0017 | CopyDirStructure(_inpath,_outpath,_i=true)

;}
;{   Mini_Libs\DamerauLevenshteinDistance.ahk

;Functions:
0008 | DamerauLevenshteinDistance(s, t)

;}
;{   Mini_Libs\dpiOffset.ahk

;Functions:
0001 | dpiOffset(val)

;}
;{   Mini_Libs\EmptyMem.ahk

;Functions:
0008 | EmptyMem(PID=0)

;}
;{   Mini_Libs\externalIP_old.ahk

;Functions:
0001 | externalIP_old()

;}
;{   Mini_Libs\ExtractIconFromExecutable.ahk

;Functions:
0001 | ExtractIconFromExecutable(aFilespec, aIconNumber, aWidth, aHeight)

;}
;{   Mini_Libs\FileCountLines.ahk

;Functions:
0005 | FileCountLines(FileName)

;}
;{   Mini_Libs\FileFindWord.ahk

;Functions:
0005 | FileFindWord(FileName, Search)

;}
;{   Mini_Libs\FileGetVersionInfo.ahk

;Functions:
0004 | FileGetVersionInfo( peFile="", StringFileInfo="" )

;}
;{   Mini_Libs\fileIsBinary.ahk

;Functions:
0004 | fileIsBinary(_filePath)

;}
;{   Mini_Libs\fileUnblock.ahk

;Functions:
0001 | fileUnblock(path)

;}
;{   Mini_Libs\FindFunc.ahk

;Functions:
0001 | FindFunc(Name)

;}
;{   Mini_Libs\FindLabel.ahk

;Functions:
0001 | FindLabel(Name)

;}
;{   Mini_Libs\GetChildHWND.ahk

;Functions:
0001 | GetChildHWND(ParentHWND, ChildClassNN)

;}
;{   Mini_Libs\getCurrentTime.ahk

;Functions:
0008 | if(countryIsTimezone)

;}
;{   Mini_Libs\GetEnv.ahk

;Functions:
0001 | GetEnv()

;}
;{   Mini_Libs\GetExeMachine.ahk

;Functions:
0005 | GetExeMachine(exepath)

;}
;{   Mini_Libs\getImageSize.ahk

;Functions:
0001 | getImageSize(imagePath)

;}
;{   Mini_Libs\getPosFromAngle.ahk

;Functions:
0001 | getPosFromAngle(ByRef x2,ByRef y2,x1,y1,len,ang)

;}
;{   Mini_Libs\getSelected.ahk

;Functions:
0001 | getSelected()
0006 | if(errorlevel)

;}
;{   Mini_Libs\getUTCOffset.ahk

;Functions:
0002 | getUTCOffset(timezone)

;}
;{   Mini_Libs\getWinClientSize.ahk

;Functions:
0001 | getWinClientSize(hwnd)

;}
;{   Mini_Libs\HexToBin.ahk

;Functions:
0001 | HexToBin(ByRef bin,hex)

;}
;{   Mini_Libs\HIBYTE.ahk

;Functions:
0001 | HIBYTE(a)

;}
;{   Mini_Libs\HIWORD.ahk

;Functions:
0001 | HIWORD(a)

;}
;{   Mini_Libs\Hotstrings.ahk

;Functions:
0019 | hotstrings(k, a = "")

;Labels:
1992 | __hs

;}
;{   Mini_Libs\hour.ahk

;Functions:
0001 | hour(hr)

;}
;{   Mini_Libs\httpQuery (2).ahk

;Functions:
0004 | httpQuery(byref Result, lpszUrl, POSTDATA="", HEADERS="")

;}
;{   Mini_Libs\httpQuery.ahk

;Functions:
0002 | httpQuery(byref Result, lpszUrl, POSTDATA="", HEADERS="")

;}
;{   Mini_Libs\HttpQueryInfo.ahk

;Functions:
0027 | HttpQueryInfo(URL, QueryInfoFlag=21, Proxy="", ProxyBypass="")

;}
;{   Mini_Libs\hwndHung.ahk

;Functions:
0001 | hwndHung(id)

;}
;{   Mini_Libs\IEObj.ahk

;Functions:
0004 | __new()
0009 | __delete()
0029 | init2()
0067 | quit()
0085 | IEGetbyURL(URL)
0092 | err(desc)

;}
;{   Mini_Libs\ifContains.ahk

;Functions:
0001 | ifContains(haystack,needle)

;}
;{   Mini_Libs\ifIn.ahk

;Functions:
0001 | ifIn(needle,haystack)

;}
;{   Mini_Libs\ILButton.ahk

;Functions:
0037 | ILButton(HBtn, Images, Cx=16, Cy=16, Align="Left", Margin="1 1 1 1")

;}
;{   Mini_Libs\imageSearchc.ahk

;Functions:
0003 | imageSearchc(byRef out1,byRef out2,x1,y1,x2,y2,image,vari=0,trans="",direction=5,debug=0)
0013 | if(errorlev)

;}
;{   Mini_Libs\invertCaseChr.ahk

;Functions:
0001 | invertCaseChr(char)

;}
;{   Mini_Libs\invertCaseStr.ahk

;Functions:
0001 | invertCaseStr(str)

;}
;{   Mini_Libs\is64bitExe.ahk

;Functions:
0001 | is64bitExe(path)

;}
;{   Mini_Libs\isAlpha.ahk

;Functions:
0001 | isAlpha(in)

;}
;{   Mini_Libs\isAlphaNum.ahk

;Functions:
0001 | isAlphaNum(in)

;}
;{   Mini_Libs\isBetween.ahk

;Functions:
0001 | isBetween(lower,check,upper)

;}
;{   Mini_Libs\isDigit.ahk

;Functions:
0001 | isDigit(in)

;}
;{   Mini_Libs\isFloat.ahk

;Functions:
0001 | isFloat(in)

;}
;{   Mini_Libs\IsFullScreen.ahk

;Functions:
0015 | IsFullscreen(sWinTitle = "A", bRefreshRes = False)

;}
;{   Mini_Libs\isHex.ahk

;Functions:
0001 | isHex(in)

;}
;{   Mini_Libs\isInt.ahk

;Functions:
0001 | isInt(in)

;}
;{   Mini_Libs\isLower.ahk

;Functions:
0001 | isLower(in)

;}
;{   Mini_Libs\isNum.ahk

;Functions:
0001 | isNum(in)

;}
;{   Mini_Libs\isSpace.ahk

;Functions:
0001 | isSpace(in)

;}
;{   Mini_Libs\isUpper.ahk

;Functions:
0001 | isUpper(in)

;}
;{   Mini_Libs\json.ahk

;Functions:
0016 | json(ByRef js, s, v = "")

;}
;{   Mini_Libs\lanConnected.ahk

;Functions:
0001 | lanConnected()

;}
;{   Mini_Libs\LOBYTE.ahk

;Functions:
0001 | LOBYTE(a)

;}
;{   Mini_Libs\LOWORD.ahk

;Functions:
0001 | LOWORD(a)

;}
;{   Mini_Libs\MAKELANGID.ahk

;Functions:
0001 | MAKELANGID(p, s)

;}
;{   Mini_Libs\MAKELCID.ahk

;Functions:
0001 | MAKELCID(lgid, srtid)

;}
;{   Mini_Libs\MAKELONG.ahk

;Functions:
0001 | MAKELONG(a, b)

;}
;{   Mini_Libs\MAKELPARAM.ahk

;Functions:
0001 | MAKELPARAM(a, b)

;}
;{   Mini_Libs\MAKELRESULT.ahk

;Functions:
0001 | MAKELRESULT(a, b)

;}
;{   Mini_Libs\MAKEWORD.ahk

;Functions:
0001 | MAKEWORD(a, b)

;}
;{   Mini_Libs\MAKEWPARAM.ahk

;Functions:
0001 | MAKEWPARAM(a, b)

;}
;{   Mini_Libs\min.ahk

;Functions:
0001 | min(min)

;}
;{   Mini_Libs\mouseOverWin.ahk

;Functions:
0001 | mouseOverWin(winName,winText="")

;}
;{   Mini_Libs\msTill.ahk

;Functions:
0004 | msTill(Time)

;}
;{   Mini_Libs\mtoh.ahk

;Functions:
0001 | mtoh(hr)

;}
;{   Mini_Libs\mtom.ahk

;Functions:
0001 | mtom(mil)

;}
;{   Mini_Libs\mtos.ahk

;Functions:
0001 | mtos(sec)

;}
;{   Mini_Libs\muteWindow.ahk

;Functions:
0003 | muteWindow(winName="A",mode="t")
0007 | if(mode=t)

;}
;{   Mini_Libs\nicRestart.ahk

;Functions:
0001 | nicRestart(adapter)

;}
;{   Mini_Libs\nicSetState.ahk

;Functions:
0004 | nicSetState(adapter,state)

;}
;{   Mini_Libs\ObjByRef.ahk

;Functions:
0013 | __GET(key)

;}
;{   Mini_Libs\ObjShare.ahk

;Functions:
0001 | ObjShare(obj)

;}
;{   Mini_Libs\processExist.ahk

;Functions:
0001 | processExist(im)

;}
;{   Mini_Libs\processPriority.ahk

;Functions:
0001 | processPriority(PID)

;}
;{   Mini_Libs\rand (2).ahk

;Functions:
0003 | Rand( a=0.0, b=1 )

;}
;{   Mini_Libs\rand.ahk

;Functions:
0001 | rand(lowerBound,upperBound)

;}
;{   Mini_Libs\RandomUniqNum.ahk

;Functions:
0003 | RandomUniqNum(Min,Max,N)

;}
;{   Mini_Libs\randStr.ahk

;Functions:
0016 | randStr(lowerBound,upperBound,mode=1)

;}
;{   Mini_Libs\regExMatchI.ahk

;Functions:
0001 | regExMatchI(haystack,needleRegEx,byref unquotedOutputVar="",startingPosition=1)

;}
;{   Mini_Libs\regExReplaceI.ahk

;Functions:
0001 | regExReplaceI(haystack,needleRegEx,replacement="",byref outputVarCount="",limit=-1,startingPosition=1)

;}
;{   Mini_Libs\ResDllCreate.ahk

;Functions:
0001 | ResDllCreate(path)

;}
;{   Mini_Libs\ResourceIndexToId.ahk

;Functions:
0001 | ResourceIndexToId(aModule, aType, aIndex)
0012 | ResourceIndexToIdEnumProc(hModule, lpszType, lpszName, lParam)

;}
;{   Mini_Libs\SB.ahk

;Functions:
0005 | SB_SetProgress(Value=0,Seg=1,Ops="")

;}
;{   Mini_Libs\sec.ahk

;Functions:
0001 | sec(sec)

;}
;{   Mini_Libs\SetExeSubsystem.ahk

;Functions:
0005 | SetExeSubsystem(exepath, subSys)

;}
;{   Mini_Libs\StdOutStream.ahk

;Functions:
0001 | StdOutStream( sCmd, Callback = "" )
0008 | if(a_ptrSize=8)

;}
;{   Mini_Libs\StdoutToVar (2).ahk

;Functions:
0032 | StdoutToVar_CreateProcess(sCmd, bStream = "", sDir = "", sInput = "")

;}
;{   Mini_Libs\StdOutToVar.ahk

;Functions:
0002 | StdOutToVar( sCmd )
0008 | if(a_ptrSize=8)

;}
;{   Mini_Libs\strI.ahk

;Functions:
0001 | strI(str)

;}
;{   Mini_Libs\StrPutVar.ahk

;Functions:
0001 | StrPutVar(string,ByRef var,encoding)

;}
;{   Mini_Libs\strReplaceI.ahk

;Functions:
0001 | strReplaceI(haystack,searchText,replaceText="",byref outputVarCount="",limit=-1)

;}
;{   Mini_Libs\strTail.ahk

;Functions:
0004 | strTail(_Str, _LineNum = 1)
0012 | strTail_last(ByRef _Str)

;}
;{   Mini_Libs\strToLower.ahk

;Functions:
0001 | strToLower(str)

;}
;{   Mini_Libs\strToUpper.ahk

;Functions:
0001 | strToUpper(str)

;}
;{   Mini_Libs\StrX.ahk

;Functions:
0002 | StrX( H, BS="",BO=0,BT=1, ES="",EO=0,ET=1, ByRef N="" )

;}
;{   Mini_Libs\sXMLget.ahk

;Functions:
0003 | sXMLget( xml, node, attr = "" )

;}
;{   Mini_Libs\ThousandsSep.ahk

;Functions:
0003 | ThousandsSep(x, s=",")

;}
;{   Mini_Libs\threadMan.ahk

;Functions:
0011 | __New(ahkDllPath,isResource=0)
0020 | __Delete()
0028 | newFromText(codeStr,options="",params="")
0034 | newFromFile(filePath,options="",params="")
0040 | waitQuit(timeout="",sleepAccuracy=100)
0052 | quit(timeout=0)
0056 | status()
0060 | reload()
0064 | exec(codeStr)
0068 | execLine(linePointer="",mode="",wait="")
0072 | execLabel(label,wait=0)
0084 | varSet(varName,varVal)
0088 | varGet(varName,pointer=0)

;}
;{   Mini_Libs\tool.ahk

;Functions:
0001 | tool(content,wait=2500,x="",y="")

;Labels:
0015 | tOff

;}
;{   Mini_Libs\UnHTM.ahk

;Functions:
0007 | UnHTM( HTM )

;}
;{   Mini_Libs\urlDownloadToFile.ahk

;Functions:
0001 | urlDownloadToFile(url,fileDest="",method=0)

;}
;{   Mini_Libs\urlFileGetSize.ahk

;Functions:
0010 | urlFileGetSize(url,units=0)

;}
;{   Mini_Libs\uuid.ahk

;Functions:
0003 | uuid(c = false)

;}
;{   Mini_Libs\VersionRes.ahk

;Functions:
0034 | _NewEnum()
0039 | AddChild(node)
0044 | GetChild(name)
0051 | GetText()
0057 | SetText(txt)
0067 | GetDataAddr()
0072 | Save(addr)

;}
;{   Mini_Libs\winInfo.ahk

;Functions:
0001 | winInfo(winName="A")

;}
