;Function WatchDirectory()
;
;Parameters
;      WatchFolder         - Specify a valid path to watch for changes in.
;                     - can be directory or drive (e.g. c:\ or c:\Temp)
;                     - can be network path e.g. \\192.168.2.101\Shared)
;                     - can include last backslash. e.g. C:\Temp\ (will be reported same form)
;
;      WatchSubDirs      - Specify whether to search in subfolders
;
;StopWatching   -   THIS SHOULD BE DONE BEFORE EXITING SCRIPT AT LEAST (OnExit)
;      Call WatchDirectory() without parameters to stop watching all directories
;
;ReportChanges
;      Call WatchDirectory("ReportingFunctionName") to process registered changes.
;      Syntax of ReportingFunctionName(Action,Folder,File)
;
;      Example
/*
      #Persistent
      OnExit,Exit
      WatchDirectory("C:\Windows",1)
      SetTimer,WatchFolder,100
      Return
      WatchFolder:
         WatchDirectory("RegisterChanges")
      Return
      RegisterChanges(action,folder,file){
         static
         #1:="New File", #2:="Deleted", #3:="Modified", #4:="Renamed From", #5:="Renamed To"
         ToolTip % #%Action% "`n" folder . (SubStr(folder,0)="\" ? "" : "\") . file
      }   
      Exit:
         WatchDirectory()
      ExitApp
*/

WatchDirectory(WatchFolder="", WatchSubDirs=true)
{
   static
   local hDir, hEvent, r, Action, FileNameLen, pFileName, Restart, CurrentFolder, PointerFNI, _SizeOf_FNI_=65536
   nReadLen := 0
   If !(WatchFolder){
      Gosub, StopWatchingDirectories
   } else if IsFunc(WatchFolder) {
      r := DllCall("MsgWaitForMultipleObjectsEx", UInt, DirIdx, UInt, &DirEvents, UInt, -1, UInt, 0x4FF, UInt, 0x6) ;Timeout=-1
      if !(r >= 0 && r < DirIdx)
         Return
      r += 1
      CurrentFolder := Dir%r%Path
      PointerFNI := &Dir%r%FNI
      DllCall( "GetOverlappedResult", UInt, hDir, UInt, &Dir%r%Overlapped, UIntP, nReadLen, Int, true )
      Loop {
         pNext      := NumGet( PointerFNI + 0  )
         Action      := NumGet( PointerFNI + 4  )
         FileNameLen := NumGet( PointerFNI + 8  )
         pFileName :=       ( PointerFNI + 12 )
         If (Action < 0x6){
            VarSetCapacity( FileNameANSI, FileNameLen )
            DllCall( "WideCharToMultiByte",UInt,0,UInt,0,UInt,pFileName,UInt,FileNameLen,Str,FileNameANSI,UInt,FileNameLen,UInt,0,UInt,0)
            %WatchFolder%(Action,CurrentFolder,SubStr( FileNameANSI, 1, FileNameLen/2 ))
         }
         If (!pNext or pNext = 4129024)
            Break
         Else
            PointerFNI := (PointerFNI + pNext)
      }
      DllCall( "ResetEvent", UInt,NumGet( Dir%r%Overlapped, 16 ) )
      Gosub, ReadDirectoryChanges
      return r
   } else {
      Loop % (DirIdx) {
         If InStr(WatchFolder, Dir%A_Index%Path){
            If (Dir%A_Index%Subdirs)
               Return
         } else if InStr(Dir%A_Index%Path, WatchFolder) {
            If (WatchSubDirs){
               DllCall( "CloseHandle", UInt,Dir%A_Index% )
               DllCall( "CloseHandle", UInt,NumGet(Dir%A_Index%Overlapped, 16) )
               Restart := DirIdx, DirIdx := A_Index
            }
         }
      }
      If !Restart
         DirIdx += 1
      r:=DirIdx
      hDir := DllCall( "CreateFile"
                , Str  , WatchFolder
                , UInt , ( FILE_LIST_DIRECTORY := 0x1 )
                , UInt , ( FILE_SHARE_READ     := 0x1 )
                     | ( FILE_SHARE_WRITE    := 0x2 )
                     | ( FILE_SHARE_DELETE   := 0x4 )
                , UInt , 0
                , UInt , ( OPEN_EXISTING := 0x3 )
                , UInt , ( FILE_FLAG_BACKUP_SEMANTICS := 0x2000000  )
                     | ( FILE_FLAG_OVERLAPPED       := 0x40000000 )
                , UInt , 0 )
      Dir%r%         := hDir
      Dir%r%Path     := WatchFolder
      Dir%r%Subdirs  := WatchSubDirs
      VarSetCapacity( Dir%r%FNI, _SizeOf_FNI_ )
      VarSetCapacity( Dir%r%Overlapped, 20, 0 )
      DllCall( "CloseHandle", UInt,hEvent )
      hEvent := DllCall( "CreateEvent", UInt,0, Int,true, Int,false, UInt,0 )
      NumPut( hEvent, Dir%r%Overlapped, 16 )
      if ( VarSetCapacity(DirEvents) < DirIdx*4 and VarSetCapacity(DirEvents, DirIdx*4 + 60))
         Loop %DirIdx%
         {
            If (SubStr(Dir%A_Index%Path,1,1)!="-"){
               action++
               NumPut( NumGet( Dir%action%Overlapped, 16 ), DirEvents, action*4-4 )
            }
         }
      NumPut( hEvent, DirEvents, DirIdx*4-4)
      Gosub, ReadDirectoryChanges
      If Restart
         DirIdx = %Restart%
   }
   Return
   StopWatchingDirectories:
      Loop % (DirIdx) {
         DllCall( "CloseHandle", UInt,Dir%A_Index% )
         DllCall( "CloseHandle", UInt,NumGet(Dir%A_Index%Overlapped, 16) )
         Dir%A_Index%=
         Dir%A_Index%Path=
         Dir%A_Index%Subdirs=
         Dir%A_Index%FNI=
         DllCall( "CloseHandle", UInt, NumGet(Dir%A_Index%Overlapped,16) )
         VarSetCapacity(Dir%A_Index%Overlapped,0)
      }
      DirIdx=
      VarSetCapacity(DirEvents,0)
   Return
   ReadDirectoryChanges:
      DllCall( "ReadDirectoryChangesW"
         , UInt , Dir%r%
         , UInt , &Dir%r%FNI
         , UInt , _SizeOf_FNI_
         , UInt , Dir%r%SubDirs
         , UInt , ( FILE_NOTIFY_CHANGE_FILE_NAME   := 0x1   )
               | ( FILE_NOTIFY_CHANGE_DIR_NAME    := 0x2   )
               | ( FILE_NOTIFY_CHANGE_ATTRIBUTES  := 0x4   )
               | ( FILE_NOTIFY_CHANGE_SIZE        := 0x8   )
               | ( FILE_NOTIFY_CHANGE_LAST_WRITE  := 0x10  )
               | ( FILE_NOTIFY_CHANGE_CREATION    := 0x40  )
               | ( FILE_NOTIFY_CHANGE_SECURITY    := 0x100 )
         , UInt , 0
         , UInt , &Dir%r%Overlapped
         , UInt , 0  )
   Return
}
