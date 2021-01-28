/* About GuiControl()

 GuiControl() to update multiple controlls at once.
 You can use any of the first 3 parameters to you're liking, in the same way
 as in the command GuiControl. Input type is preferable a string but can be a var
 , mind the double quotes.
 
 Command:
  GuiControl(, "aID", "SomeParameter") or GuiControl("Move", "aID", "x10")
 
 Or Just Ignore the first 3 parmaters and insert a Object or Array on parameter 4.
 
 Command:
  GuiControl(,,, MyArray)
  GuiControl(,,, {1: Gui1, 2: Gui2, 3: Gui3}, {1: Parm1, 2: Parm2, 3: Parm3}, {1: Parm1}, {1: Parm1, 2: Parm2})
 
  Returns ErrorLevel.

*/

GuiControl(cmd:="", CtrlId:="", Parm:="", A*) {
    SetControlDelay -1
    Critical
    
    if IsObject(A[1]) {
        for i, CtrlId in A[1] {
            for indx, Parm in A[i+1] {
            
                if (A[i+1].Length() = 1) {
                    GuiControl, , %CtrlId%, %Parm%
                    E := ErrorLevel
                }
                else if (A[i+1].Length() = 2) {
                    if (indx = 1) {
                        cmd :=  Parm
                   }     
                    else if (indx = 2) {
                        GuiControl, %cmd%, %CtrlId%, %Parm%
                        E := ErrorLevel
    }    }   }    }   }
    
    else if (!cmd && Parm) {
        GuiControl, , %CtrlId%, %Parm%
        E := ErrorLevel
        
    } Else if (cmd && !parm) {
        GuiControl, %cmd%, %CtrlId%
     E := ErrorLevel
     
    } Else if (cmd && parm) {
        GuiControl, %cmd%, %CtrlId%, %P%
        E := ErrorLevel
    }
    return E
}
