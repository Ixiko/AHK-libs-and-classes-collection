;-------------------------------------------------------------------------------
;
;  ContextMenuLib 0.10
;  Add commands to the right-click menu of any file
;  by Danny Ben Shitrit (aka Icarus) 2008
;
;  Usage:
;    CM_AddMenuItem( extension, label, command )
;    CM_DelMenuItem( extension, label )
;
;  Examples:
;    CM_AddMenuItem( "mp3", "&Test 1 2 3", "Testing.exe %1" )
;    CM_DelMenuItem( "mp3", "&Test 1 2 3" )
;
;  NOTE:
;    Since Windows stores the menu commands in various places, the DelMenuItem
;    function may not always work on items that were not added by the
;    AddMenuItem function.
;    For example, media files (mp3, avi) have menu items such as "Queue-it-up"
;    or "Play with Media Player" which cannot be deleted using this library.
;
;-------------------------------------------------------------------------------

; TESTER
;CM_AddMenuItem( "ahk", "&Test 1 2 3 ", "Notepad ""%1""" )
;msgbox Item added.`nRight click your file to see the new command.`nPress OK to delete.
;CM_DelMenuItem( "ahk", "Test 1 2 3 " )
;msgbox Item deleted
; END OF TESTER

;Return

CM_AddMenuItem( ext, label, command ) {
  If( ext = "" or label = "" or command = "" )
    Return false

  CleanLabel := RegExReplace( label, "\W", "" )
  RegRead FileType, HKCR, .%ext%
  If( Not FileType )
    Return false

  RegWrite REG_SZ, HKCR, %FileType%\shell\%CleanLabel%,, %label%
  RegWrite REG_SZ, HKCR, %FileType%\shell\%CleanLabel%\command,, %command%

  Return true
}

CM_DelMenuItem( ext, label ) {
  If( ext = "" or label = "" )
    Return false

  CleanLabel := RegExReplace( label, "\W", "" )
  RegRead FileType, HKCR, .%ext%
  If( Not FileType )
    Return false

  RegDelete HKCR, %FileType%\shell\%CleanLabel%

  Return true
}
