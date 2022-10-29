COM1 := new Serial("COM1")

;the following listens on COM1 and calls MyFunc when ever a newline char is detected. Then passing the message received
;by default it polls the COM port every 100ms to see if anything has been sent
COM1.Event_Parse_Start("MyFunc", "`n") 

MyFunc(Recv) ;called any time a full message is received
{
	msgbox, % "sweet! just recieved the following: `n" Recv
	return
}

Esc::
COM1.Send_Message("Thanks! I'm out now") ;send notification that you are closing your connection
COM1.Event_Parse_Stop()
return
