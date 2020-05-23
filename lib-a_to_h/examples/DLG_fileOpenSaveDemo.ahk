
;
; DemoAHK Scriplet for DLG_FileOpen & DLG_FileSave
;

Gui, Add, Button, w300 gOpenFileDlg_Single,Show Open Single File Dialog
Gui, Add, Button, w300 gOpenFileDlg_Multi,Show Open Multiple Files Dialog
Gui, Add, Button, w300 gSaveFileDlg,Show Save File Dialog
Gui, Show,, File Open and Save Demo
return

OpenFileDlg_Multi:
   HWND          := WinExist(A)

   Filter        := "Text Files (*.txt;*.doc)"
    Filter        .= "|Autohotkey Files (*.ahk)"
    Filter        .= "|AutoIT v3 Files (*.au3)"
    Filter        .= "|VisualBasic Script Files (*.vbs)"
    Filter        .= "|All Files (*.*)"

   defaultFilter := 2
   IniDir        := A_WorkingDir
   DialogTitle   := "AHK-Demonstration: Choose multiple files to OPEN or press Cancel"
   defaultExt    := "txt"
   flags         := "FILEMUSTEXIST EXPLORER HIDEREADONLY ALLOWMULTISELECT"

                  ; These are default flags - these are set, when no flags are specified
                  ;     0x1000  -> OFN_FILEMUSTEXIST
                  ;     0x80000 -> OFN_EXPLORER
                  ;     0x4     -> OFN_HIDEREADONLY
                  ;
                  ; This Flag allows multiple Files to be selected
                  ;     0x200   -> OFN_ALLOWMULTISELECT


    FileName := DLG_FileOpen( HWND
                            , Filter
                            , defaultFilter
                            , InitilisationDir
                            , DialogTitle
                            , defaultExt
                            , flags )
   If !( FileName )
      MsgBox The dialog was cancelled or no Filename chosen
   else {
      ; Filenames are Pipedelimited when more than one is selected
      ; path\tp\file1.ext|path\to\file2.ext ...
      ; This just replaces Pipe with CR

      StringReplace, FileName, FileName, |, `n, All, UseErrorLevel
      FilesTotal := ErrorLevel + 1
      s := ""
      if FilesTotal>1
         s := "s"
      MsgBox You selected a total of %FilesTotal% file%s%. The selection was:`n`n%FileName%
   }
return

OpenFileDlg_Single:
   HWND          := WinExist(A)

   Filter        := "Text Files (*.txt;*.doc)"
    Filter        .= "|Autohotkey Files (*.ahk)"
    Filter        .= "|AutoIT v3 Files (*.au3)"
    Filter        .= "|VisualBasic Script Files (*.vbs)"
    Filter        .= "|All Files (*.*)"

   defaultFilter := 2
   IniDir        := A_WorkingDir
   DialogTitle   := "AHK-Demonstration: Choose your file to OPEN or press Cancel"
   defaultExt    := "txt"

    FileName := DLG_FileOpen( HWND
                            , Filter
                            , defaultFilter
                            , InitilisationDir
                            , DialogTitle
                            , defaultExt )
   If !( FileName )
      MsgBox The dialog was cancelled or no Filename chosen
   else
      MsgBox The FileName you selected is:`n%FileName%
return

SaveFileDlg:

   HWND          := WinExist(A)

   Filter        := "Text Files (*.txt;*.doc)"
    Filter        .= "|Autohotkey Files (*.ahk)"
    Filter        .= "|AutoIT v3 Files (*.au3)"
    Filter        .= "|VisualBasic Script Files (*.vbs)"
    Filter        .= "|All Files (*.*)"

   defaultFilter := 2
   IniDir        := A_WorkingDir
   DialogTitle   := "AHK-Demonstration: Choose your file to OPEN or press Cancel"
   defaultExt    := "txt"

    FileName := DLG_FileSave( HWND
                            , Filter
                            , defaultFilter
                            , InitilisationDir
                            , DialogTitle
                            , defaultExt )
   If !( FileName )
      MsgBox The dialog was cancelled or no Filename chosen
   else
      MsgBox The FileName you selected is:`n%FileName%
return


#Include %A_ScriptDir%\..\DLG_FileOpenSave.ahk