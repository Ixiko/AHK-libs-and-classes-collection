/*; ==================================================================================================================================
; Function:       Notifies about changes within folders.
;                       This is a rewrite of HotKeyIt's WatchDirectory() released at
;                       http://www.autohotkey.com/board/topic/60125-ahk-lv2-watchdirectory-report-directory-changes/
; Tested with:    AHK 1.1.23.01 (A32/U32/U64)
; Tested on:      Win 10 Pro x64
; Usage:            WatchFolder(Folder, UserFunc[, SubTree := False[, Watch := 3]])
; Parameters:
;     Folder        The full qualified path of the folder to be watched.
;                       Pass the string "**PAUSE" and set UserFunc to either True or False to pause respectively resume watching.
;                       Pass the string "**END" and an arbitrary value in UserFunc to completely stop watching anytime.
;                       If not, it will be done internally on exit.
;     UserFunc    -  The name of a user-defined function to call on changes. The function must accept at least two parameters:
;                       1: The path of the affected folder. The final backslash is not included even if it is a drive's root
;                       directory (e.g. C:).
;                       2: An array of change notifications containing the following keys:
;                       Action:  One of the integer values specified as FILE_ACTION_... (see below).
;                                In case of renaming Action is set to FILE_ACTION_RENAMED (4).
;                       Name:    The full path of the changed file or folder.
;                       OldName: The previous path in case of renaming, otherwise not used.
;                       IsDir:   True if Name is a directory; otherwise False. In case of Action 2 (removed) IsDir is always False.
;                       Pass the string "**DEL" to remove the directory from the list of watched folders.
;     SubTree     -  Set to true if you want the whole subtree to be watched (i.e. the contents of all sub-folders).
;                       D efault: False - sub-folders aren't watched.
;     Watch        -  The kind of changes to watch for. This can be one or any combination of the FILE_NOTIFY_CHANGES_...
;                           values specified below.
;                       Default: 0x03 - FILE_NOTIFY_CHANGE_FILE_NAME + FILE_NOTIFY_CHANGE_DIR_NAME
; Return values:
;     Returns True on success; otherwise False.
; Change history:
;     1.0.02.00/2016-11-30/just me        -  bug-fix for closing handles with the '**END' option.
;     1.0.01.00/2016-03-14/just me        -  bug-fix for multiple folders
;     1.0.00.00/2015-06-21/just me        -  initial release
; License:
;     The Unlicense -> http://unlicense.org/
; Remarks:
;     Due to the limits of the API function WaitForMultipleObjects() you cannot watch more than MAXIMUM_WAIT_OBJECTS (64)
;     folders simultaneously.
; MSDN:
;     ReadDirectoryChangesW          msdn.microsoft.com/en-us/library/aa365465(v=vs.85).aspx
;     FILE_NOTIFY_CHANGE_FILE_NAME   	= 1		(0x00000001) : Notify about renaming, creating, or deleting a file.
;     FILE_NOTIFY_CHANGE_DIR_NAME    	= 2   	(0x00000002) : Notify about creating or deleting a directory.
;     FILE_NOTIFY_CHANGE_ATTRIBUTES  	= 4   	(0x00000004) : Notify about attribute changes.
;     FILE_NOTIFY_CHANGE_SIZE               	= 8   	(0x00000008) : Notify about any file-size change.
;     FILE_NOTIFY_CHANGE_LAST_WRITE 	= 16  	(0x00000010) : Notify about any change to the last write-time of files.
;     FILE_NOTIFY_CHANGE_LAST_ACCESS	= 32  	(0x00000020) : Notify about any change to the last access time of files.
;     FILE_NOTIFY_CHANGE_CREATION    	= 64  	(0x00000040) : Notify about any change to the creation time of files.
;     FILE_NOTIFY_CHANGE_SECURITY      	= 256	(0x00000100) : Notify about any security-descriptor change.
;     FILE_NOTIFY_INFORMATION        												msdn.microsoft.com/en-us/library/aa364391(v=vs.85).aspx
;     FILE_ACTION_ADDED                         	= 1   	(0x00000001) : The file was added to the directory.
;     FILE_ACTION_REMOVED                     	= 2   	(0x00000002) : The file was removed from the directory.
;     FILE_ACTION_MODIFIED                    	= 3   	(0x00000003) : The file was modified.
;     FILE_ACTION_RENAMED                     	= 4   	(0x00000004) : The file was renamed (not defined by Microsoft).
;     FILE_ACTION_RENAMED_OLD_NAME	= 4   	(0x00000004) : The file was renamed and this is the old name.
;     FILE_ACTION_RENAMED_NEW_NAME	= 5   	(0x00000005) : The file was renamed and this is the new name.
;     GetOverlappedResult            													msdn.microsoft.com/en-us/library/ms683209(v=vs.85).aspx
;     CreateFile                     																msdn.microsoft.com/en-us/library/aa363858(v=vs.85).aspx
;     FILE_FLAG_BACKUP_SEMANTICS     		= 			(0x02000000)
;     FILE_FLAG_OVERLAPPED           			= 			(0x40000000)
; ==================================================================================================================================
*/

WatchFolder(Folder, UserFunc, SubTree := False, Watch := 0x03) {
   Static DummyObject := {Base: {__Delete: Func("WatchFolder").Bind("**END", "")}}
   Static TimerID := "**" . A_TickCount
   Static TimerFunc := Func("WatchFolder").Bind(TimerID, "")
   Static MAXIMUM_WAIT_OBJECTS := 64
   Static MAX_DIR_PATH := 260 - 12 + 1
   Static SizeOfLongPath := MAX_DIR_PATH << !!A_IsUnicode
   Static SizeOfFNI := 0xFFFF ; size of the FILE_NOTIFY_INFORMATION structure buffer (64 KB)
   Static SizeOfOVL := 32     ; size of the OVERLAPPED structure (64-bit)
   Static WatchedFolders := {}
   Static EventArray := []
   Static HandleArray := []
   Static WaitObjects := 0
   Static BytesRead := 0
   Static Paused := False
   ; ===============================================================================================================================
   If (Folder = "")
      Return False
   SetTimer, % TimerFunc, Off
   RebuildWaitObjects := False
   ; ===============================================================================================================================
   If (Folder = TimerID) 
   { ; called by timer
		  If (ObjCount := EventArray.Length()) && !Paused 
		  {
			 ObjIndex := DllCall("WaitForMultipleObjects", "UInt", ObjCount, "Ptr", &WaitObjects, "Int", 0, "UInt", 0, "UInt")
			 While (ObjIndex >= 0) && (ObjIndex < ObjCount) 
			{
					FolderName := WatchedFolders[ObjIndex + 1]
					D := WatchedFolders[FolderName]
					
					If DllCall("GetOverlappedResult", "Ptr", D.Handle, "Ptr", D.OVLAddr, "UIntP", BytesRead, "Int", True) 
					{
						   Changes := []
						   FNIAddr := D.FNIAddr
						   FNIMax := FNIAddr + BytesRead
						   OffSet := 0
						   PrevIndex := 0
						   PrevAction := 0
						   PrevName := ""
						   Loop 
						   {
									  FNIAddr += Offset
									  OffSet := NumGet(FNIAddr + 0, "UInt")
									  Action := NumGet(FNIAddr + 4, "UInt")
									  Length := NumGet(FNIAddr + 8, "UInt") // 2
									  Name   := FolderName . "\" . StrGet(FNIAddr + 12, Length, "UTF-16")
									  IsDir  := InStr(FileExist(Name), "D") ? 1 : 0
									  
									  If (Name = PrevName) 
									  {
												 If (Action = PrevAction)
															Continue
												 If (Action = 1) && (PrevAction = 2) 
												 {
															PrevAction := Action
															Changes.RemoveAt(PrevIndex--)
															Continue
												 }
									  }
									  
									If (Action = 4)
												PrevIndex := Changes.Push({Action: Action, OldName: Name, IsDir: 0})
									Else If (Action = 5) && (PrevAction = 4) 
									{
													Changes[PrevIndex, "Name"] := Name
													Changes[PrevIndex, "IsDir"] := IsDir
									}
									Else
											PrevIndex := Changes.Push({Action: Action, Name: Name, IsDir: IsDir})
								  PrevAction := Action
								  PrevName := Name
						   } Until (Offset = 0) || ((FNIAddr + Offset) > FNIMax)
						   If (Changes.Length() > 0)
							  D.Func.Call(FolderName, Changes)
						   DllCall("ResetEvent", "Ptr", EventArray[D.Index])
						   DllCall("ReadDirectoryChangesW", "Ptr", D.Handle, "Ptr", D.FNIAddr, "UInt", SizeOfFNI, "Int", D.SubTree
														  , "UInt", D.Watch, "UInt", 0, "Ptr", D.OVLAddr, "Ptr", 0)
						}
						ObjIndex := DllCall("WaitForMultipleObjects", "UInt", ObjCount, "Ptr", &WaitObjects, "Int", 0, "UInt", 0, "UInt")
						Sleep, 0
					 }
		  }
   }
   Else If (Folder = "**PAUSE") { ; called to pause/resume watching
      Paused := !!UserFunc
      RebuildObjects := Paused
   }
   Else If (Folder = "**END") { ; called to stop watching
      For K, D In WatchedFolders
         If K Is Not Integer
            DllCall("CloseHandle", "Ptr", D.Handle)
      For Each, Event In EventArray
         DllCall("CloseHandle", "Ptr", Event)
      WatchedFolders := {}
      EventArray := []
      Paused := False
      Return True
   }
   Else { ; called to add, update, or remove folders
      Folder := RTrim(Folder, "\")
      VarSetCapacity(LongPath, SizeOfLongPath, 0)
      If !DllCall("GetLongPathName", "Str", Folder, "Ptr", &LongPath, "UInt", SizeOfLongPath)
         Return False
      VarSetCapacity(LongPath, -1)
      Folder := LongPath
      If (WatchedFolders[Folder]) { ; update or remove
         Handle := WatchedFolders[Folder, "Handle"]
         Index  := WatchedFolders[Folder, "Index"]
         DllCall("CloseHandle", "Ptr", Handle)
         DllCall("CloseHandle", "Ptr", EventArray[Index])
         EventArray.RemoveAt(Index)
         WatchedFolders.RemoveAt(Index)
         WatchedFolders.Delete(Folder)
         RebuildWaitObjects := True
      }
	  
      If InStr(FileExist(Folder), "D") && (UserFunc <> "**DEL") && (EventArray.Length() < MAXIMUM_WAIT_OBJECTS) {
         If (IsFunc(UserFunc) && (UserFunc := Func(UserFunc)) && (UserFunc.MinParams >= 2)) && (Watch &= 0x017F) {
            Handle := DllCall("CreateFile", "Str", Folder . "\", "UInt", 0x01, "UInt", 0x07, "Ptr",0, "UInt", 0x03
                                          , "UInt", 0x42000000, "Ptr", 0, "UPtr")
            If (Handle > 0) {
               Event := DllCall("CreateEvent", "Ptr", 0, "Int", 1, "Int", 0, "Ptr", 0)
               Index := EventArray.Push(Event)
               WatchedFolders[Index] := Folder
               WatchedFolders[Folder] := {Func: UserFunc, Handle: Handle, Index: Index, SubTree: !!SubTree, Watch: Watch}
               WatchedFolders[Folder].SetCapacity("FNIBuff", SizeOfFNI)
               FNIAddr := WatchedFolders[Folder].GetAddress("FNIBuff")
               DllCall("RtlZeroMemory", "Ptr", FNIAddr, "Ptr", SizeOfFNI)
               WatchedFolders[Folder, "FNIAddr"] := FNIAddr
               WatchedFolders[Folder].SetCapacity("OVLBuff", SizeOfOVL)
               OVLAddr := WatchedFolders[Folder].GetAddress("OVLBuff")
               DllCall("RtlZeroMemory", "Ptr", OVLAddr, "Ptr", SizeOfOVL)
               NumPut(Event, OVLAddr + 8, A_PtrSize * 2, "Ptr")
               WatchedFolders[Folder, "OVLAddr"] := OVLAddr
               DllCall("ReadDirectoryChangesW", "Ptr", Handle, "Ptr", FNIAddr, "UInt", SizeOfFNI, "Int", SubTree
                                              , "UInt", Watch, "UInt", 0, "Ptr", OVLAddr, "Ptr", 0)
               RebuildWaitObjects := True
            }
         }
      }
	  
      If (RebuildWaitObjects) {
         VarSetCapacity(WaitObjects, MAXIMUM_WAIT_OBJECTS * A_PtrSize, 0)
         OffSet := &WaitObjects
         For Index, Event In EventArray
            Offset := NumPut(Event, Offset + 0, 0, "Ptr")
      }
   }
   
   If (EventArray.Length() > 0)
      SetTimer, % TimerFunc, -100
   Return (RebuildWaitObjects) ; returns True on success, otherwise False
}