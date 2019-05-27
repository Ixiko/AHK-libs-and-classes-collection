/* Example
#NoEnv
Gui, Show, w700 h500, Test
Sleep 2000
SC_CutWindow.Square("Test", 200, 200, 880, 659, 0 )
Sleep 3000
SC_CutWindow.Square("Test", 200, 200, 881, 660, 0 )
Sleep 3000
SC_CutWindow.Restore("Test")
Return
*/

Class SC_CutWindow
{  
    Square( Window_Name, X1, Y1, X2, Y2, Invert)
    {   If ( X1 > X2 || Y1 > Y2 )
            Return 1
        WinGetPos, , , Width, Height, %Window_Name%
        If Invert = 1
            WinSet, Region, % X1 "-" Y1 " " X2 "-" Y1 " " X2 "-" Y2 " " X1 "-" Y2 " " X1 "-" Y1, %Window_Name%
        else
            WinSet, Region, % "0-0 " Width "-0 " Width "-" Height " 0-" Height " 0-0 " X1 "-" Y1 " " X2 "-" Y1 " " X2 "-" Y2 " " X1 "-" Y2 " " X1 "-" Y1, %Window_Name%
        Return 0
    }
    Triangle( Window_Name, X1, Y1, X2, Y2, X3, Y3, Invert )
    {   WinGetPos, , , Width, Height, %Window_Name%
        If Invert = 1
            WinSet, Region,  %X1%-%Y1% %X2%-%Y2% %X3%-%Y3%, %Window_Name%
        else
            WinSet, region, 0-0 %Width%-0 %Width%-%Height% 0-%Height% 0-0  %X1%-%Y1% %X2%-%Y2% %X3%-%Y3%, %Window_Name%
        Return 0
    }
    Polygon( Window_Name, Positions, Invert )
    {   WinGetPos, , , Width, Height, %Window_Name%
        Loop, Parse, Positions, |
            Whole .= A_LoopField " "
        StringSplit, Pos, Positions, |
        If Invert = 0
            Whole := "0-0 " Width "-0 " Width "-" Height " 0-" Height " 0-0  " Whole  Pos1 "-" Pos2
        WinSet, Region, %Whole%, %Window_name%
        Return 0
    }
    Restore( Window_Name )
    {   WinSet, Region, , %Window_Name%
        Return 0
    }   
}