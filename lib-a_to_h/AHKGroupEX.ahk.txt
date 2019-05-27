
/* About AHKGroupEX()

 ahk_group is great for checking multiple windows.
 What I miss is a feature to also remove apps from the ahk_group.
 This function allows you to create a window group that can both add and
 remove. In it's essence, it creates and returns a array made from the
 GuiNames in parameter AddApp*
 
 Command to add:
  AHKGroupEX(, "MyGui1", "MyGui2" .. . )

 Command to remove:
  AHKGroupEX(1, "MyGui1", "MyGui2" .. . )
 
*/

AHKGroupEX(Remove:="", AddApp*) {
    Static Apps := []
    
    if (Remove) {
        Apps.RemoveAt(Remove, Apps.Length(Apps[Remove]))
    }
    else if (Apps.Length() < 1) {
        i := 1
    
        ParseFile:
        Loop, parse, % FileOpen(A_ScriptDir "\NetAccess.acc", 0).read(), `n, `r`n
        {
            If (A_LoopField) {
                Apps[(i++)] := Trim(A_LoopField, " `t`r`n"), Size := A_Index
            } else {
                Continue, ParseFile
    }   }   }
    else if (AddApp.Length() > 0) {
        for i, App in AddApp {
            Apps.InsertAt(Apps.Length()+i, "ahk_exe " App)
            FileAppend, % "ahk_exe " App "`n", %A_ScriptDir%\NetAccess.acc
    } }
    Return Apps
}
