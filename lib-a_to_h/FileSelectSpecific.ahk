; **********************************************************
; FileSelectSpecific Functions by DigiDon
; **********************************************************
; Use/modify as you wish
; Based on Main example from https://autohotkey.com/docs/commands/ListView.htm
; **********************************************************
; AHK GUI alternative to the FileSelectFile / FileSelectFolder dialogs
; Allows more parameters/customization
; Allows to restrict navigation within a specific folder
; Allows to select File(s) or/and Folder(s)
; Allows to filter file types in or out
; **********************************************************
; FileSelectSpecific(P_OwnerNum,P_Path,P_SelectFileOrFolder="File",P_Prompt="",P_ComplementText="",P_Multi="",P_DefaultView="Icon",P_FilterOK="",P_FilterNO="",P_Restrict=1,P_LVHeight="220",P_LVWidth="350")
;*****************************
;	PARAMETERS
;*****************************
;----- P_OwnerNum: Num/Name of the Gui Owner: it will be disabled the time a selection is made
;----- P_Path: Starting Folder 
;EMPTY: Start with all disks
;----- P_SelectFileOrFolder : Type of Selection to make
;"File" : User should select File(s)
;"Folder" : User should select Folder(s)
;"All" : User should select File(s) and/or Folder(s)
;----- P_Prompt : Text to display at the top of GUI
;----- P_ComplementText : Text to display at the bottom the GUI
;----- P_Multi : MultiSelection
;VALUE: Allowed / EMPTY: Forbidden
;----- P_DefaultView : Default View for the Tree List
;"Icon" / "Report"
;----- P_FilterOK : Comma-list of allowed extensions to be displayed and chosen
;ex "EXE,INI"
;----- P_FilterNO : Comma-list of forbidden extensions to be displayed and chosen
;ex "EXE,INI"
;----- P_Restrict : The user should not be able to navigate above the starting folder
;----- P_LVHeight : Height of ListView in Px
;----- P_LVWidth  : Width  of ListView in Px
;*****************************
;	RETURN VALUE
;*****************************
;----- FSHwnd: Hwnd of the GUI windows
;*****************************
; GLOBAL VALUE TO CHECK AFTER CALL
;*****************************
;----- glb_FSReturn: Contains the path of the selected file(s)
;NO SELECTION : EMPTY
;NO Multi Selection: Path of the selected File
;Multi Selection: Path of the folder "`n" Paths of the selected files (`n separated)
;*****************************
;			USAGE
;*****************************
;ANY SINGLE FILE ANYWHERE
FSHwnd:=FileSelectSpecific("","","File","Please Choose a file")
WinWait % "ahk_id " FSHwnd
WinWaitClose % "ahk_id " FSHwnd
if !glb_FSReturn
	msgbox No selection
else
	msgbox selection was %glb_FSReturn%
; ONE OR MORE NON-RTF FILES WITHIN C:
FSHwnd:=FileSelectSpecific("","C:","File","Please Choose file(s) in C: (no rtf)","",1,,,"rtf",1)
WinWait % "ahk_id " FSHwnd
WinWaitClose % "ahk_id " FSHwnd
if !glb_FSReturn
	msgbox No selection
else
	msgbox selection was %glb_FSReturn%
;*****************************