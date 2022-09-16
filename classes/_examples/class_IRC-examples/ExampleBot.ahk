#Include <Socket> ; Include the Socket library
#Include ..\MyRC.ahk ; Include the IRC library

MyBot := new IRCBot() ; Create a new instance of your bot
MyBot.Connect("chat.freenode.net", 6667, "MyBotsName") ; Connect to an IRC server
MyBot.SendJOIN("#uptone") ; Join a channel
return

; Create a bot that extends the IRC library
class IRCBot extends IRC
{
	; This function gets called on every PRIVMSG (IRC protocol name for incoming chat message)
	onPRIVMSG(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		; In a PRIVMSG, the channel the message came from is stored as the first parameter.
		; This line sets the variable "Channel" to the channel the message came from.
		Channel := Params[1]
		
		; This displays a ToolTip in the form of "<Nick> Message person sent"
		ToolTip, % "<" Nick "> " Msg
		
		; This is a regular expression command parser, for commands in the form "!Command [Parameter]"
		if RegExMatch(Msg, "^\s*!(\S+)(?:\s+(.+?))?\s*$", Match)
		{
			Command := Match1 ; Command is the first capturing subpattern in the RegEx
			Param := Match2 ; The parameter is the second capturing subpattern in the RegEx
			
			if (Command = "Hi")
			{
				; Send a chat message saying "Hello Nick!" in the channel that the command was triggered in
				this.SendPRIVMSG(Channel, "Hello " Nick "!")
			}
			else if (Command = "Slap")
			{
				; Send a "/me slaps Parameter" to the channel the command was triggered in
				this.SendACTION(Channel, "slaps " Param)
			}
			else if (Command = "Help")
			{
				; Send a helpful message to the person who triggered this command
				this.SendPRIVMSG(Nick, "This is a helpful message!")
			}
		}
	}
	
	; This function gets called for every raw line from the server
	Log(Data)
	{
		; Print the raw data received from the server
		Print(Data)
	}
}

Print(Params*)
{
	static _ := DllCall("AllocConsole") ; Create a console on script start
	StdOut := FileOpen("*", "w") ; Open the standard output
	for each, Param in Params ; Iterate over function parameters
		StdOut.Write(Param "`n") ; Append the parameter to the standard output
}