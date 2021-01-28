#Include RegExSort.ahk

TestList =
(
George`t12 : 45`tYellow
Amy`t11 : 33`tBlue
Johnny`t11 : 33`tAqua
Danny`t08 : 33`tAqua
Jimmy`t13 : 13`tPurple
Benji`t03 : 87`tTan
Grant`t14 : 06`tCyan
Billy`t02 : 95`tWhite
)

PreText := ">> Format:`n[N]ame, [H]our, [M]inute, [C]olor`n`n"

Text := ">> RegExNeedle:`n* Invalid RegEx Needle *`n`n>> Result:`n"
MsgBox % PreText Text RegExSort(   TestList   ,   "invalid"   )

Text := ">> RegExNeedle:`n* Nothing *`n`n>> Result:`n"
MsgBox % PreText Text RegExSort(   TestList   ,   ""   )

Text := ">> Order:`nBlank (default)`n`n>> Result:`n" 
MsgBox % PreText Text RegExSort(   TestList   ,   ".+`t(\d+) : (\d+)"   )

Text := ">> Order:`n[M]`n`n>> Result:`n"
MsgBox % PreText Text RegExSort(   TestList   ,   ".+`t(\d+) : (\d+)"   ,   "2"   )

Text := ">> Order:`n[H]`n`n>> Result:`n"
MsgBox % PreText Text RegExSort(   TestList   ,   ".+`t(\d+) : (\d+)"   ,   "1"   )

Text := ">> Order:`n[M] [H] [C]`n`n>> Result:`n"
MsgBox % PreText Text RegExSort(   TestList   ,   ".+`t(\d+) : (\d+)`t(.+)"   ,   "2,1,3")

Text := ">> Order:`n[M] [H] [N]`n`n>> Result:`n"
MsgBox % PreText Text RegExSort(   TestList   ,   "(.+)`t(\d+) : (\d+)`t.+"   ,   "3,2,1" )

Text := ">> Order:`nInverse ([C] [M] [H] [N])`n`n>> Result:`n"
MsgBox % PreText Text RegExSort(   TestList   ,   "(.+)`t(\d+) : (\d+)`t(.+)"   ,   "i" )

Return