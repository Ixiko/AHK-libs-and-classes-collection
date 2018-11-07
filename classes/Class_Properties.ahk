;=======================================================================================
;
;                    Class Properties
;
; Author:            Pulover [Rodolfo U. Batista]
;                    rodolfoub@gmail.com
; AHK version:       1.1.11.00
; Release date:      24 July 2013
; Depends on:        Class_Rebar <https://gist.github.com/Pulover/6003125>
;
;                    Custom Properties Sheet control for AutoHotkey.
;=======================================================================================
Class Properties
{
    __New(gLabel, W=400, H=23, X=0, Y=0, Gui=1)
    {
        If !(IsLabel(gLabel))
            return False
        this.Label := gLabel, this.Gui := Gui
        this.Width := W, this.Height := H
        this.PosX := X, this.PosY := Y
    ,   this.Count := 0, this.Handles := []
    }
    
    Add(CtrlType, BandText="", CtrlValue="")
    {
        this.Count += 1, ID := this.Count
    ,   Gui := this.Gui, Label := this.Label
    ,   W := this.Width, H := this.Height, HalfW := W//2
    ,   X := this.PosX, Y := this.PosY, HalfW := W//2
    
        Gui, %Gui%:Add, Custom, ClassReBarWindow32 hwndhRebar%ID% g%Label% 0x044C x%X% y%Y% w%W% h%H%
        Gui, %Gui%:Add, %CtrlType%, hwndhCtr%ID%, %CtrlValue%
        GuiControlGet, cValue,, % hCtr%ID%
        
        RB%ID% := New Rebar(hRebar%ID%)
    ,   RB%ID%.InsertBand("", 0, "NoGripper Hidden", 0, BandText, HalfW)
    ,   RB%ID%.InsertBand(hCtr%ID%, 0, "NoGripper Hidden", 0, "", HalfW, 0, "", H)
    ,   RB%ID%.InsertBand("", 0, "NoGripper", 0, BandText, HalfW)
    ,   RB%ID%.InsertBand("", 0, "NoGripper", 0, cValue, HalfW, 0, "", H)
    ,   this.Handles.Insert({Ptr: RB%ID%, hRebar: hRebar%ID%, hCtr: hCtr%ID%})
    ,   this.PosY += this.Height
        return
    }
    
    EditProperty()
    {
        nCode := NumGet(A_EventInfo + (A_PtrSize * 2), 0, "Int")
        If (nCode = -16)
        {
            rbHwnd := NumGet(A_EventInfo + 0, 0, "UPtr")
            Loop, % this.Handles.MaxIndex()
            {
                If (this.Handles[A_Index].hRebar = rbHwnd)
                {
                    ID := A_Index
                    break
                }
            }
            GuiControlGet, ctrlValue,, % this.Handles[ID].hCtr
            this.Handles[ID].Ptr.GetBand(1, "", "", "", "", "", Style)
        ,   SetProp := (Style & 0x0008) ? 1 : 0
        ,   this.Handles[ID].Ptr.ModifyBand(4, "Text", (ctrlValue = "") ? A_Space : ctrlValue)
        ,   this.Handles[ID].Ptr.ShowBand(1, SetProp)
        ,   this.Handles[ID].Ptr.ShowBand(2, SetProp)
        ,   this.Handles[ID].Ptr.ShowBand(3, !SetProp)
        ,   this.Handles[ID].Ptr.ShowBand(4, !SetProp)
        }
        return
    }
}
