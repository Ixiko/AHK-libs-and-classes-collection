;#f::MsgBox, % ShellFolder()
;#m::ShellNavigate(A_MyDocuments, True)
;#p::ShellNavigate(A_ProgramFiles)
;#s::ShellNavigate(A_ScriptDir)
;#w::ShellNavigate(A_WinDir)


ShellNavigate(sPath, bExplore=False, hWnd=0)  {
   shell  :=   ComObjCreate("Shell.Application")
   If   hWnd||(hWnd:=WinExist("ahk_class CabinetWClass"))||(hWnd:=WinExist("ahk_class ExploreWClass"))
   {
      Loop, % shell.Windows.Count
        If ( (win := shell.Windows.Item(A_Index-1)).hWnd = hWnd )
          Break
      win.Navigate2(sPath)
   }
   Else bExplore ? shell.Explore(sPath) : shell.Open(sPath)
}

ShellFolder(hWnd=0) {
  If   hWnd||(hWnd:=WinExist("ahk_class CabinetWClass"))||(hWnd:=WinExist("ahk_class ExploreWClass"))
  {
  shell  :=   ComObjCreate("Shell.Application")
  Loop, % shell.Windows.Count
     If ( (win := shell.Windows.Item(A_Index-1)).hWnd = hWnd )
        Break
  sFolder := win.Document.Folder.Self.Path, sFocus  := win.Document.FocusedItem.Name
  For item in win.Document.selecteditems
     sSelect .= item.name . "`n"
  Return   "Folder:`t" . sFolder . "`nFocus:`t" . sFocus . "`nSelected Items:`n" . sSelect
  }
}