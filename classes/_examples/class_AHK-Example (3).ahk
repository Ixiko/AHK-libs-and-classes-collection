#Include, Console.ahk

MyConsole := new Console()
MyConsole.WriteLine("Will continue till 'x' is encountered")
while(Char!= 120)
{
	Char := MyConsole.getch()
	MyConsole.Write(Chr(Char))
}
MyConsole.ClearScreen()
MyConsole.WriteLine("Will not continue till a double click is made")
Loop
{
	E := MyConsole.ReadConsoleInput()
	if(E.EventType = 2 && E.EventInfo[5] = 2)
		break
}

MyConsole.ClearScreen()
MyConsole.WriteLine("Press left Ctrl + left Alt")
Loop
{
	E := MyConsole.ReadConsoleInput()
	if(E.EventType = 1 && (E.EventInfo[6] = 0x0002|0x0008))
		break
}

MyConsole.ClearScreen()
MyConsole.WriteLine("Exiting...")
Sleep, 3000
ExitApp

esc::ExitApp
