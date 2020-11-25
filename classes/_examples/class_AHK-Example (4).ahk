#Include, Console.ahk

MyConsole := new Console()
MyConsole.WriteLine("A simple progress bar Example")
MyConsole.SetColor(MyConsole.Color.Black, MyConsole.Color.Green)
Progress1 := MyConsole.CreateProgress(0, 1, 50, 2, 1)
MyConsole.SetColor(MyConsole.Color.Black, MyConsole.Color.Turquoise)
Progress2 := MyConsole.CreateProgress(0, 4, 50, 1)
MyConsole.FillConsoleOutputAttribute(0x03, Object("X", 0, "Y", 4) , 51)


while(A_Index <= 200)
{
	MyConsole.SetProgress(Progress1, A_Index//2)
	MyConsole.SetProgress(Progress2, ((A_Index>100)?A_Index-100:A_Index))
	MyConsole.SetCursorPosition(0, 5)
	MyConsole.WriteLine(A_Index//2 "% Completed")
	MyConsole.SetConsoleTitle(A_Index//2 "% Completed")
	Sleep, 10
}



MyConsole.WriteLine("`n`n`n`n`n`n`n`n`n`n`n`nPress any Key to Exit..")
MyConsole.getch()
ExitApp
esc::ExitApp
