; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

/*  By RazorHalo
	RemoteObj_AHKsock Server Example - Using Remote Objects with AHKsock
    Version 1.0 - August 8, 2020
	
	*** Required Libraries ***
	AHKsock.ahk by TheGood
		https://autohotkey.com/board/topic/53827-ahksock-a-simple-ahk-implementation-of-winsock-tcpip/page-1
	Jxon.ahk by Coco
		https://www.autohotkey.com/boards/viewtopic.php?t=627
*/
#NoEnv
SetBatchLines, -1

#Include AHKsock.ahk
#Include Jxon.ahk
#Include RemoteObj_AHKsock.ahk

;Register OnExit subroutine so that AHKsock_Close is called before exit
OnExit, CloseAHKsock

;Add menu item for exiting gracefully (see comment block in CloseAHKsock)
Menu, Tray, Add
Menu, Tray, Add, Exit Gracefully, CloseAHKsock

;Set up an error handler (this is optional)
AHKsock_ErrorHandler("AHKsockErrors")

;Create instance of the Server
;RemoteObjServer(Port)
ObjServer := new RemoteObjServer(27015)

;Add the object to the server
;Pass the object and quoted identifier - these can be different. The identifier will
;be used on the client side to know ;which object will be called
MyClass := new ExampleClass()
ObjServer.Add(MyClass, "MyClass")

MyTest := new Test()
ObjServer.Add(MyTest, "MyTest")

return



class ExampleClass
{
	__New()
	{
		Gui, New, +hWndhWnd +AlwaysOnTop
		this.hWnd := hWnd
		Gui, Add, Text, w100 Center, Remote!
		Gui, Show
	}
	
	AddButton(ButtonText, Action, Params*)
	{
		hWnd := this.hWnd
		Gui, %hWnd%: Default
		Gui, Add, Button, xm y+m w100 hWndhButton, %ButtonText%
		
		BoundFunc := this[Action].Bind(this, Params*)
		GuiControl, +g, %hButton%, %BoundFunc%
		
		Gui, Show, AutoSize
	}
	
	Run(Target)
	{
		Run, %Target%
	}
	
	MsgBox(Text)
	{
		MsgBox, 4096,, %Text%
	}
}


class Test {
	InputBox(Prompt) {
		InputBox, Out, % this.Title, %Prompt%
		return Out
	}
}

GuiClose:
CloseAHKsock:
    /*! If the user selects the "Exit" menu item from the tray menu, this sub will execute once, i.e. as the OnExit sub. In
    this situation, if we're still connected to the server, we will have no way of gracefully shutting down the connection.
    
    But if the user selects the "Exit Gracefully" menu item that we added at startup, this sub will execute twice: once as
    the label of the menu item, and once more right after as the OnExit sub (since ExitApp is called at the end of the sub).
    Therefore, during the first execution of those two, since the thread will be interruptible, calling AHKsock_Close will
    gracefully shutdown the connection. Note that the second call to AHKsock_Close during the OnExit sub then becomes
    useless by redundancy, but harmless (so there's no need to ensure that it is only called during the first of the two
    executions).
    
    If this application had a GUI, we could instead execute a graceful shutdown on the GuiClose event, as done in other
    AHKsock examples. Here, we have to rely on the tray menu because it is the only way for the user to exit while still
    being able to gracefully shutdown.
    
    Note however that in this example, the server shuts down the client as soon as it is done sending data to it (see the
    server's SEND event of the Send() function). Therefore, the conversation between server and client is very short. This
    means that when the user decides to exit the application, chances are, we are no longer connected to the server, and on
    our way to exiting anyway.
    
    However, if we want to guarantee a graceful shutdown, we must still be safe and consider the slim possibility that the
    user wants to exit before we are done receiving all the data from the server. This is why we are doing this here. This
    possibility can be much larger in applications that have longer conversations (or applications that stay connected until
    the user exits, like in AHKsock Example 3).
    
    See the section "NOTES ON CLOSING SOCKETS AND AHKsock_Close" in the documentation for more information on performing
    graceful shutdown.
    */
    AHKsock_Close()
ExitApp


;We're not actually handling errors here. This is here just to make us aware of errors if any do come up.
AHKsockErrors(iError, iSocket) {
    OutputDebug, % "Client - Error " iError " with error code = " ErrorLevel ((iSocket <> -1) ? " on socket " iSocket : "")
}