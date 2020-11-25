; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

/*  WebView2 for AutoHotkey v2.0-a122
 *
 *  Provides an interfaces to The Microsoft Edge WebView2 control and enables you to host web content in your applications
 *  This is a 64-bit Dll program, use AHK U64.
 *
 *  Use, modify and redistribute without limitation.
 */

winSize(controller,minMax,*){
    ; IWebView2WebViewController::get_IsVisible
    ComCall 3,controller,"int*",isVisible := 0
    If(minMax == -1){
        if(isvisible)
            ; IWebView2WebViewController::put_IsVisible
            ComCall 4,controller,"int",False
    }Else{
        If(!isVisible)
            ; IWebView2WebViewController::put_IsVisible
            ComCall 4,controller,"int",True
        Else{
            DllCall "GetClientRect","ptr",hWnd,"ptr",RECT := BufferAlloc(16)
            ; IWebView2WebViewController::put_Bounds
            ComCall 6,controller,"ptr",RECT
        }
    }
}

QueryInterface(this,riid,ppvObject){
    ; This isn't called at all...
}

AddRef(this){
    NumPut "uint",ObjAddRef(this),this,A_PtrSize
}

Release(this){
    NumPut "uint",ObjRelease(this),this,A_PtrSize
}

Invoke_1(this,HRESULT,ICoreWebView2Environment){
    ; ICoreWebView2Environment::CreateCoreWebView2Controller Method.
    ComCall 3,ICoreWebView2Environment,"ptr",hWnd,"ptr",WebView2Controller
}

Invoke_2(this,HRESULT,IWebView2WebViewController){
    ObjAddRef IWebView2WebViewController

    winParent.OnEvent "Size",Func("winSize").bind(IWebView2WebViewController)

    ; Resize WebView to fit the bounds of the parent window.
    ; IWebView2WebViewController::put_Bounds Method.
    DllCall "GetClientRect","ptr",hWnd,"ptr",RECT := BufferAlloc(16)
    ComCall 6,IWebView2WebViewController,"ptr",RECT

    ; IWebView2WebViewController::get_CoreWebView2
    ComCall 25,IWebView2WebViewController,"ptr*",webview := 0

    ; IWebView2WebViewController::put_ZoomFactor
    ComCall 8,IWebView2WebViewController,"double",ZoomFactor

    ; ICoreWebView2::add_navigationstarting
    ComCall 7,webView,"ptr",WebView2NavigationStartingEventArgs,"uint64",token := 0
    If HtmlSite
        ; ICoreWebView2::Navigate
        ComCall 5,webView,"str",HtmlSite
    If HtmlStr
        ; ICoreWebView2::NavigateToString
        ComCall 6,webView,"str",HtmlStr
    If WebView2DocumentTitleChangedEventHandler
        ; ICoreWebView2::add_DocumentTitleChanged
        ComCall 46,webView,"ptr",WebView2DocumentTitleChangedEventHandler,"uint64",token := 0
}

Invoke_3(this,IWebView2WebView,IWebView2NavigationStartingEventArgs){
    ; ICoreWebView2NavigationStartingEventArgs::get_IsUserInitiated
    ComCall 4,IWebView2NavigationStartingEventArgs,"int*",isUserInitiated := False

    if(isUserInitiated)
        ; ICoreWebView2NavigationStartingEventArgs::get_Uri
        ComCall 3,IWebView2NavigationStartingEventArgs,"str*",uri := ""
}

Invoke_4(this,IWebView2WebView,IUnknown){
    ; ICoreWebView2::get_DocumentTitle
    ComCall 48,IWebView2WebView,"str*",DocTitle := ""

    If(!isfunc("On_Click")){
        MsgBox "Function On_Click Not Created....","Func Error!","iconi"
        ExitApp
    }
    Func("On_Click").Call(DocTitle)
}


WebView2(Invoke){
    vtbl.Push BufferAlloc(4*A_PtrSize)
    For Each,Method In ["QueryInterface","AddRef","Release","Invoke_" Invoke]
        NumPut "uptr",CallbackCreate(Method),vtbl[Invoke],(A_Index-1)*A_PtrSize
    ptr := DllCall("GlobalAlloc","uint",64,"ptr",A_PtrSize+4,"uptr")
    NumPut "uptr",vtbl[Invoke].ptr,ptr
    NumPut "uint",1,ptr,A_PtrSize
    Return ptr
}

ClickEvents_WebView2(){
    WebView2DocumentTitleChangedEventHandler := WebView2(4)  ; ICoreWebView2DocumentTitleChangedEventHandler.
}

Init_WebView2(parent){
    hWnd                                  := parent.hWnd
    winParent                             := parent
    WebView2Environment                   := WebView2(1)     ; IWebView2CreateWebView2EnvironmentCompletedHandler.
    WebView2Controller                    := WebView2(2)     ; ICoreWebView2CreateCoreWebView2ControllerCompletedHandler.
    WebView2NavigationStartingEventArgs   := WebView2(3)     ; IWebView2NavigationCompletedEventHandler.

    EdgePath := "c:\Program Files (x86)\Microsoft\Edge\Application\85.0.564.51\"
    dllPath  := "WebView2Loader"

    DllCall dllPath "\CreateCoreWebView2EnvironmentWithOptions","str",EdgePath,"str","","ptr",0,"uptr",WebView2Environment

    If(a_lasterror){
        buf := BufferAlloc(8,0)
        DllCall "FormatMessage","uint",256|4096,"ptr",0,"uint",a_lasterror,"uint",0,"ptr",buf.ptr,"uint",0,"ptr",0
        msgbox "Error " a_lasterror " = " StrGet(NumGet(buf,"ptr"))
        exitapp
    }
}

global WebView2Environment                      := 0
global WebView2Controller                       := 0
global WebView2NavigationStartingEventArgs      := 0
global WebView2DocumentTitleChangedEventHandler := 0

global hWnd := 0,winParent := {},vtbl := [],HtmlSite := "",HtmlStr := "",ZoomFactor := 1.25 ; =125%
