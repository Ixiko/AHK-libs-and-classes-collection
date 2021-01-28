/*  Options: one or more of the following semicolon-delimited values: 
dialogHeight:sHeight 
    Sets the height of the dialog window. 
    Valid unit-of-measure prefixes: cm, mm, in, pt, pc, em, ex, px 
dialogLeft:sXPos 
    Sets the left position of the dialog window relative to the upper-left 
    corner of the desktop. 
dialogTop:sYPos 
    Sets the top position of the dialog window relative to the upper-left 
    corner of the desktop. 
dialogWidth:sWidth 
    Sets the width of the dialog window. 
    Valid unit-of-measure prefixes: cm, mm, in, pt, pc, em, ex, px 
center:{ yes | no | 1 | 0 | on | off } 
    Specifies whether to center the dialog window within the desktop. Default: yes 
dialogHide:{ yes | no | 1 | 0 | on | off } 
    Specifies whether the dialog window is hidden when printing or using print 
    preview. Default: no 
edge:{ sunken | raised } 
    Specifies the edge style of the dialog window. Default: raised 
resizable:{ yes | no | 1 | 0 | on | off } 
    Specifies whether the dialog window has fixed dimensions. Default: no 
scroll:{ yes | no | 1 | 0 | on | off } 
    Specifies whether the dialog window displays scrollbars. Default: yes 
status:{ yes | no | 1 | 0 | on | off } 
    Specifies whether the dialog window displays a status bar. Default: no 
unadorned:{ yes | no | 1 | 0 | on | off } 
    Specifies whether the dialog window displays the window border. 
*/ 
ShowHTMLDialog(URL, argIn="", Options="", hwndParent=0) 
{ 
    ; "Typically, the COM library is initialized on a thread only once. Subsequent 
    ;  calls to CoInitialize or CoInitializeEx on the same thread will succeed,..." 
    COM_CoInitialize() 
    
    hinstMSHTML := DllCall("LoadLibrary","str","MSHTML.DLL") 
    hinstUrlMon := DllCall("LoadLibrary","str","urlmon.dll") ; necessary to keep the URL moniker in memory. 
    
    if !hinstMSHTML or !hinstUrlMon 
        goto ShowHTMLDialog_Exit 
    
    pUrl := COM_SysAllocString(URL) 
    
    hr := DllCall("urlmon\CreateURLMonikerEx","uint",0,"uint",pUrl,"uint*",pUrlMoniker,"uint",1) 
    if (ErrorLevel) { 
        Error = DllCall(CreateURLMoniker)--%ErrorLevel% 
        goto ShowHTMLDialog_Exit 
    } 
    if (hr or !pUrlMoniker) { 
        Error = CreateURLMoniker--%hr% 
        goto ShowHTMLDialog_Exit 
    } 

    pOptions := Options!="" ? COM_SysAllocString(Options) : 0 
    
    pArgIn := COM_SysAllocString(argIn) 
    VarSetCapacity(varArgIn, 16, 0), NumPut(8,varArgIn,0), NumPut(pArgIn,varArgIn,8) 
    VarSetCapacity(varResult, 16, 0) 

    hr := DllCall("mshtml\ShowHTMLDialog","uint",hwndParent,"uint",pUrlMoniker,"uint",&varArgIn,"uint",pOptions,"uint",&varResult) 
    if (ErrorLevel) { 
        Error = DllCall(ShowHTMLDialog)--%ErrorLevel% 
        goto ShowHTMLDialog_Exit 
    } 
    if (hr) { 
        Error = ShowHTMLDialog--%hr% 
        goto ShowHTMLDialog_Exit 
    } 
    ; based on a line from COM_Invoke(). returnValue = varResult as string; 
    InStr(" 0 4 5 6 7 14 "," " . NumGet(varResult,0,"Ushort") . " ") ? DllCall("oleaut32\VariantChangeTypeEx","Uint",&varResult,"Uint",&varResult,"Uint",0,"Ushort",0,"Ushort",8) : "", NumGet(varResult,0,"Ushort")=8 ? (returnValue:=COM_Ansi4Unicode(NumGet(varResult,8))) . COM_SysFreeString(NumGet(varResult,8)) : returnValue:=NumGet(varResult,8) 
    
ShowHTMLDialog_Exit: 
    if pArgIn 
        COM_SysFreeString(pArgIn) 
    if pOptions 
        COM_SysFreeString(pOptions) 
    if pUrlMoniker 
        COM_Release(pUrlMoniker) 
    if pUrl 
        COM_SysFreeString(pUrl) 
    
    ; "Each process maintains a reference count for each loaded library module. 
    ;  This reference count is incremented each time LoadLibrary is called and 
    ;  is decremented each time FreeLibrary is called." 
    ; -- So FreeLibrary() will not unload these DLLs if they were loaded before 
    ;    the function was called. :) 
    if hinstMSHTML 
        DllCall("FreeLibrary","uint",hinstMSHTML) 
    if hinstUrlMon 
        DllCall("FreeLibrary","uint",hinstUrlMon) 
    
    ; "To close the COM library gracefully, each successful call to CoInitialize 
    ;  or CoInitializeEx, including those that return S_FALSE, must be balanced 
    ;  by a corresponding call to CoUninitialize." 
    COM_CoUninitialize() 
    
    ErrorLevel := Error 
    return returnValue 
}