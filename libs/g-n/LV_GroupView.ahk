; Based on functions from LV_EX written by just_me
LV_InsertGroup(hLV, GroupID, Header, Index := -1) {
    Static GroupIdOff := (A_PtrSize == 8) ? 36 : 24
    NumPut(VarSetCapacity(LVGROUP, 56, 0), LVGROUP, 0)
    NumPut(0x15, LVGROUP, 4, "UInt") ; mask: LVGF_HEADER|LVGF_STATE|LVGF_GROUPID
    NumPut((A_IsUnicode) ? &Header : UTF16(Header, @), LVGROUP, 8, "Ptr") ; pszHeader
    NumPut(GroupID, LVGROUP, GroupIdOff, "Int") ; iGroupId
    NumPut(0x8, LVGROUP, GroupIdOff + 8, "Int") ; state: LVGS_COLLAPSIBLE
    SendMessage 0x1091, %Index%, % &LVGROUP,, ahk_id %hLV% ; LVM_INSERTGROUP
    Return ErrorLevel
}

LV_SetGroup(hLV, Row, GroupID) {
    Static GroupIdOff := (A_PtrSize == 8) ? 52 : 40
    VarSetCapacity(LVITEM, 58, 0)
    NumPut(0x100, LVITEM, 0, "UInt")  ; mask: LVIF_GROUPID
    NumPut(Row - 1, LVITEM, 4, "Int") ; iItem
    NumPut(GroupID, LVITEM, GroupIdOff, "Int")
    SendMessage 0x1006, 0, &LVITEM,, ahk_id %HLV% ; LVM_SETITEMA
    Return ErrorLevel
}

LV_EnableGroupView(hLV, bEnable := True) {
    SendMessage 0x109D, %bEnable%, 0,, ahk_id %hLV% ; LVM_ENABLEGROUPVIEW
}

UTF16(String, ByRef Var) {
    VarSetCapacity(Var, StrPut(String, "UTF-16") * 2, 0)
    StrPut(String, &Var, "UTF-16")
    Return &Var
}
