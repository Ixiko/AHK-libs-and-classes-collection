; #Include type.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Example by MasterFocus, copied from source and adjusted to match renamed functions.
text := "* EXAMPLES *"
text .= "`n"
text .= "`nvar1 = " ( var1 := "AB4D" ) ": " type_var( var1 )
text .= "`nvar2 = " ( var2 := "8df3K" ) ": " type_var( var2 )
text .= "`nvar3 = " ( var3 := "2345" ) ": " type_var( var3 )
text .= "`n"
text .= "`n" "SameTypes(var1,var2): " type_same(var1,var2)
text .= "`n" "SameTypes02(var1,var3): " type_same(var1,var3)
text .= "`n"
text .= "`n" "CommonTypes(""var1,var2,var3""): " type_common("var1,var2,var3")
text .= "`n" "CommonTypes(""var3,var1,var2""): " type_common("var3,var1,var2")

MsgBox %text%
