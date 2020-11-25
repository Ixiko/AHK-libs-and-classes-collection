#Include, Console.ahk

MyConsole := new Console()
MyConsole.WriteLine("Hey, what's your name?!")
Name := MyConsole.ReadLine()
MyConsole.WriteLine("Nice to meet you " Name)
MyConsole.WriteLine("`n`n`n`n`n`n`nPress any key to exit")
MyConsole.getch()
ExitApp
