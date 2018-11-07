; ************************************************************************************************
; Function:         Class definitions for ListView Group
; AHK version:      AHK_L(U) 1.1.05.06 (U 32)
; Language:         English
; Tested on:        Win XPSP3 (Not suit for win2000/98/me)
; Version:          0.1.0.0/2012-02-20
; Author:           hughman@gmail.com
; thread:           http://www.autohotkey.com/forum/viewtopic.php?p=514935#514935
; Method:
;     Enable:         enable or disable group view
;     Toggle:         toggle group view
;     IsEnabled:      check if group view is enabled
;     Insert:         Insert a new group
;     InsertSorted:   Inserts a group into an ordered list of groups
;     Add:            add a new group at the end
;     Select:         move an item to its group through group title
;     Select2:         move an item to its group through group id
;     Sort:           Sort groups by any costumized methods
;     Delete:         remove a group
;     Clear:          remove all groups
;     Display:        change the border size and title color
;     Align:          change the alignment of group title
;     Title:          change the group tilte
;     Exist:          chekc if a goup exists or not
;     Get:            get group info
;     GetGID:         get group id via title
; *************************************************************************************************



; Callback function to compare used by LVGroup sort funtion
; You need to write it yourself. This is just an example.
; if id1 is less than id2 then return negative, greater then positive, equal then 0.
LVGroupCompare(id1, id2, this)
{
  this := Object(this)
  
  if (this.SortBy="customize")
  {
    Order := ["rmc", "ahk", "ahkl", "chm", "zip", "html", "lnk", "jpg", "dll", "exe"] ; here you need change it yourself
    for k, v in order
    {
      if (this.G[id1].header = v)
        ret1 := k
      if (this.G[id2].header = v)
        ret2 := k
    }
  }
  else
  {
    ret1 := this.G[id1].header
    ret2 := this.G[id2].header
  }
  
  ret := (ret1>ret2) ? 1 : (ret1<ret2) ? -1 : 0
  Return, this.SortAsc ? ret : -ret
}


class cLVGROUP
{
  ; XP+
  static LVM_ENABLEGROUPVIEW := 0x109d, LVM_ISGROUPVIEWENABLED := 0x10af
  , LVM_INSERTGROUP := 0x1091, LVM_INSERTGROUPSORTED := 0x109f
  , LVM_SETGROUPINFO := 0x1093, LVM_SETGROUPMETRICS := 0x109b
  , LVM_GETGROUPINFO := 0x1095, LVM_GETGROUPMETRICS := 0x109c
  , LVM_REMOVEGROUP := 0x1096, LVM_REMOVEALLGROUPS := 0x10a0
  , LVM_SORTGROUPS := 0x109e, LVM_HASGROUP := 0x10a1
  ; group info flag , LVGF_FOOTER(0x2) and VGF_STATE(0x4) are ignored by XP 
  static LVGF_NONE := 0x0, LVGF_HEADER := 0x1, LVGF_ALIGN := 0x8, LVGF_GROUPID := 0x10
  ; group meter flag,  LVGMF_BORDERCOLOR(0x2) is ignored by XP
  static LVGMF_NONE := 0x0, LVGMF_BORDERSIZE := 0x1, LVGMF_TEXTCOLOR := 0x4

  ; Vista+
  ; LVM_GETFOCUSEDGROUP, LVM_GETGROUPCOUNT, LVM_GETGROUPINFOBYINDEX, LVM_GETGROUPRECT, LVM_GETGROUPSTATE
  
  __New(hLV)
  {
    this.ID := hLV            ; listview handle
    this.GroupCount := 0      ; group count
    this.G := {}              ; each group info: header, align, count, firstItem
    this.GID := []            ; an index of gid
    this.SortAsc := true      ; sort asc or desc, used by callback function
    this.SortBy := "default"  ; sort method: default, customize; used by callback function
  }
  
  
  ; enable or disable group view
  Enable(bFlag=1)
  {
    Return, this._SendMsg(this.LVM_ENABLEGROUPVIEW, bFlag)
  }
  
  
  ; toggle group view
  Toggle()
  {
    this.Enable(!this.IsEnabled())
  }
  
  
  ; check if group view is enabled.
  IsEnabled()
  {
    Return this._SendMsg(this.LVM_ISGROUPVIEWENABLED)
  }
  

  ; insert a group, return index, 0 if fail
  Insert(nIdx, sHeader)
  {
    gid := (this.GroupCount ? this.G.MaxIndex() : 0) + 1
    VarSetCapacity(LVG, 96, 0)                                    ; struct LVGROUP
    , NumPut(96, &LVG, 0,"Int")                                   ; cbSize
    , NumPut(this.LVGF_HEADER | this.LVGF_GROUPID, &LVG, 4,"Int") ; Mask
    , NumPut(&sHeader, &LVG, 8, "Int")                            ; pszHeader
    , NumPut(gid, &LVG, 24,"Int")                                ; iGroupId
    if (ret := this._SendMsg(this.LVM_INSERTGROUP, nIdx-1, &LVG) + 1) {
      this.GID.Insert(ret, gid)
      this.G[gid] := {header: sHeader, align: 1, count: 0, firstItem: 0}
      this.GroupCount += 1
    }
    Return, ret
  }
  
  ; Inserts a group into an ordered list of groups
  ; not sure how to use it. You can use Insert + Sort instead.
  InsertSorted(sHeader, sMethod="default", bAsc=true)
  {
    callback := RegisterCallback("LVGroupCompare", "F", 3)
    , gid := (this.GroupCount ? this.G.MaxIndex() : 0) + 1
    , VarSetCapacity(LVG, 96, 0)                                    ; struct LVGROUP
    , NumPut(96, &LVG, 0,"Int")                                   ; cbSize
    , NumPut(this.LVGF_HEADER | this.LVGF_GROUPID, &LVG, 4,"Int") ; Mask
    , NumPut(&sHeader, &LVG, 8, "Int")                            ; pszHeader
    , NumPut(gid, &LVG, 24,"Int")                                 ; iGroupId
    , VarSetCapacity(LVIGS, 12)
    , NumPut(callback, &LVIGS, 0)
    , NumPut(&this, &LVIGS, 4)
    , NumPut(&LVG, &LVGIS, 8)
  
    this._SendMsg(this.LVM_INSERTGROUPSORTED, &LVIGS)
    this.G[gid] := {header: sHeader, align: 1, count: 0, firstItem: 0}
    this.GroupCount += 1
  }
  
  
  ; add a group at the end
  Add(sHeader, sFooter="")
  {
    Return this.Insert(0, sHeader, sFooter)
  }
  
  
  ; move an item to its group through group title, create group if nonexist.
  Select(nRow, sHeader, nIdx = 0)
  {
    if (!gid := this.GetGID(sHeader))
    {
      if !gid := this.GID[this.Insert(nIdx, sHeader)]
        MsgBox error
      if !this.IsEnabled()
        this.Enable(1)
    }
    
    this.Select2(nRow, gid, nIdx)
  }
  
  
  ; move an item to its group through group id
  ; not like select, you need add group first and then get group id
  Select2(nRow, nGID, nIdx = 0)
  {
    VarSetCapacity(LVI, 64, 0)        ; struct LVITEM
    , NumPut(0x100, &LVI, 0,  "Int")    ; LVIF_GROUPID (flag 0x100)
    , NumPut(nRow-1, &LVI, 4,  "Int")   ; iItem
    , NumPut(nGID, &LVI, 40, "Int")      ; iGroupId
    this._SendMsg(0x1006, 0, &LVI)     ; LVM_SETITEM = 0x1006 ; 0x104C unicode?
    if !(this.G[nGID].count)
      this.G[nGID].firstItem := nRow
    this.G[nGID].count += 1
  }
  
  ; you need write a callback function named LVGroupCompare with 3 parameters by yourself
  ; below is a tmeplate, this function should be written outside the class
  ; LVGroupCompare(gid1, gid2, this)
  ; {
  ;   this := Object(this)
  ;   ............
  ;   [YOUR CODE TO RETRIVE ret1 VIA gid1, ret2 VIA gid2]
  ;   ret := (ret1>ret2) ? 1 : (ret1<ret2) ? -1 : 0
  ;   Return, this.SortAsc ? ret : -ret
  ; }
  Sort(sMethod="default", bAsc=true)
  {
    this.SortAsc := bAsc, this.SortBy := sMethod
    callback := RegisterCallback("LVGroupCompare","F", 3)
    this._SendMsg(this.LVM_SORTGROUPS, callback, &this)
    
    ; rebuild index, bubble sort
    G := this.GID, n := G.MaxIndex()
    Loop, % n - 1
    {
      i := min := A_Index
      Loop, % n - i
        if ( 0 < ret := DllCall(callback, int, G[min], int, G[j], int, &this) )
          min := j
      if (min != i)
        j := G[min], G[min] := G[i], G[i] := j
    }
    this.GID := G, G := ""
  }
  
  
  ; remove a group, return index, 0 if fail
  ; you can retrive the group via this.GID[index]
  Delete(nGID)
  {
    if (!ret := this._SendMsg(this.LVM_REMOVEGROUP, nGID) + 1)
      Return, ret
    this.G.Remove(nGID)
    this.GID.Remove(ret)
    this.GroupCount -= 1
    if (!this.GroupCount)
      this.Enable(0)
    Return, ret
  }
  
  ; remove all groups and disable the group view
  Clear()
  {
    this._SendMsg(this.LVM_REMOVEALLGROUPS)
    this.Disable()
    this.GroupCount := 0
    this.G := {}
    this.GID := []
  }
  
  
  ; change the border size and title color
  ; param: combination of the first alphabeta of left, top, right, bottom, color, followed by a value
  ; eg. Display("l20", "c0x00ff00") specifies the width of left border and the color of header
  ; left, right: in icon, small icon, or tile view
  ; top, bottom: in all group views (but bottom can't be changed in report view?)
  Display(params*)
  {
    static arr := {l:8, t:12, r:16, b:20, c:40}
    VarSetCapacity(LVGM, 48, 0)
    , NumPut(48, &LVGM, 0)
    , NumPut(this.LVGMF_BORDERSIZE | this.LVGMF_TEXTCOLOR, &LVGM, 4)
    
    this._SendMsg(this.LVM_GETGROUPMETRICS, 0, &LVGM)
    for each, param in params
    {
      offset := arr[SubStr(param, 1, 1)]
      value := SubStr(param, 2)
      NumPut(value, &LVGM, offset)
    }
    this._SendMsg(this.LVM_SETGROUPMETRICS, 0, &LVGM)
  }
  
  
  ; change the alignment of title, left: 1, center: 2, right: 4
  ; return group id, -1 if fail
  ; bug: if the method align is called before select, the first group can't be displayed, why?
  Align(nIdx, nAlign)
  {
    ; static LVGA_HEADER_LEFT := 0x1, LVGA_HEADER_CENTER := 0x2, LVGA_HEADER_RIGHT := 0x4
    gid := this.GID[nIdx]
    VarSetCapacity(LVG, 96, 0)  ; struct LVGROUP
    , NumPut(96, &LVG, 0,"Int") ; cbSize
    , NumPut(this.LVGF_ALIGN, &LVG, 4,"Int") ; Mask
    , NumPut(nAlign, &LVG, 36, "UInt")  ; uAligh
    ret := this._SendMsg(this.LVM_SETGROUPINFO, gid, &LVG)
    if (ret > -1)
      this.G[gid].align := nAlign
    Return, ret
  }
  
  
  ; Change a group's title by index, return group id, -1 if fail
  ; The title can't be changed unless the group id is changed first
  ; Is it a bug? So this is a workaround.
  ; need to update manually by toggling group view
  Title(nIdx, sHeader, bUpdate=false)
  {
    gid := this.GID[nIdx], tmpID := 65535
    VarSetCapacity(LVG, 96, 0)                                    ; struct LVGROUP
    , NumPut(96, &LVG, 0,"Int")                                   ; cbSize
    , NumPut(this.LVGF_HEADER | this.LVGF_GROUPID, &LVG, 4,"Int") ; Mask
    , NumPut(&sHeader, &LVG, 8, "Int")                            ; pszHeader
    , NumPut(tmpID, &LVG, 24, "Int")
    ret := this._SendMsg(this.LVM_SETGROUPINFO, gid, &LVG) ; return the former id before changed.
    if (ret1 = -1)
      Return -1
    NumPut(this.LVGF_GROUPID, &LVG, 4,"Int")
    NumPut(gid, &LVG, 24, "Int")
    ret := this._SendMsg(this.LVM_SETGROUPINFO, tmpID, &LVG) ; this moment, ret = tmpID
    if (ret > -1) {
      this.G[gid].header := sHeader
      ret := gid  ;
      if (bUpdate) && this.IsEnabled()
        this.Enable(0), this.Enable(1)
    }
    Return ret
  }
  
  
  ; get group info.
  Get(nIdx, ByRef LVG)
  {
    gid := this.GID[nIdx]
    VarSetCapacity(LVG, 96, 0)
    , NumPut(96, &LVG, 0, "Int")
    , NumPut(this.LVGF_HEADER | this.LVGF_ALIGN | this.LVGF_GROUPID, &LVG, 4,"Int")
    ret := this._SendMsg(this.LVM_GETGROUPINFO, gid, &LVG)
    if (ret = -1)
      MsgBox, 0,  cLVGROUP Error, Get group info failed!
    Return ret
  }
  
  
  ; if a group exist or not.
  ; you can retrive the group via this.GID[index]
  Exist(nGID)
  {
    Return this._SendMsg(this.LVM_HASGROUP, nGID)
  }
  
  
  ; get group id via header
  GetGID(sHeader)
  {
    gid := 0
    
    for k, v in this.G
    {
      if (v.header = sHeader)
      {
        gid := k
        break
      }
    }
    
    Return gid
  }
  
  
  ; help function
  _SendMsg(uMsg, wParam=0, lParam=0)
  {
    Return, DllCall("SendMessage", "UInt", this.ID, "UInt", uMsg, "Int", wParam, "Int", lParam)
  }
}