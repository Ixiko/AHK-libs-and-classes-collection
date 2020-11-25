/*________________________________________________________________________________________
       __  __ _____ _   _ _____ ___________ _____       _____  _      _
      |  \/  |_   _| \ | |_   _|___  /_   _|  __ \     |  __ \| |    | |
      | \  / | | | |  \| | | |    / /  | | | |__) |    | |  | | |    | |
      | |\/| | | | | . ` | | |   / /   | | |  ___/     | |  | | |    | |
      | |  | |_| |_| |\  |_| |_ / /__ _| |_| |     _   | |__| | |____| |____
      |_|  |_|_____|_| \_|_____/_____|_____|_|    (_)  |_____/|______|______|
      http://edel.realsource.de/downloads/doc_download/27-minizip-dll

 Script       :  MiniZIP.ahk - AutoHotkey Wrapper for minizip.dll
 Created On   :  27-Jun-2012  /  Last Modified:  27-Jun-2012  /  v1.0
 Author       :  SKAN ( A.N.Suresh Kumar, arian.suresh@gmail.com )
 Forum Topic  :  www.autohotkey.com/community/viewtopic.php?t=88218
 My License   :  Unrestricted! www.autohotkey.com/community/viewtopic.php?p=505843#p505843
 _________________________________________________________________________________________


 The DLL exported functions names are confusing, atleast for me!.
 Here follows the list of wrapper functions, categorically named
 and arranged in order of importance:
 _______________________________________________________________
 
 Initialization Functions:
 
       01)  MiniZIP_Init()                 <--             Kernel32\LoadLibrary()
       02)  MZ_SetPassword()               <--             ZIP_SetPassword()

 Creating/Updating ZIP files:
 
       03)  MZ_ZipCreate()                 <--             ZIP_FileCreate()
       04)  MZ_ZipOpen()                   <--             ZIP_FileOpen()
       05)  MZ_ZipAddFolder()              <--             ZIP_DirAdd()
       06)  MZ_ZipAddFile()                <--             ZIP_FileAdd()
       07)  MZ_ZipAddMem()                 <--             ZIP_MemAdd()
       08)  MZ_ZipClose()                  <--             ZIP_FileClose()

 Unzipping ZIP files:
 
       09)  MZ_ZipIsValid()                <--             ZIP_IsZipArchive()
       10)  MZ_ZipGetFileCount()           <--             ZIP_GetFilesCount()
       11)  MZ_ZipGetFileNumber()          <--             ZIP_GetFileNumber()
       12)  MZ_ZipIsPasswordRequired()     <--             ZIP_IsPasswordRequired()
       13)  MZ_ZipGetFilename()            <--             ZIP_GetFileInfo()
       14)  MZ_ZipGetComment()             <--             ZIP_GetFileComment()

       15)  MZ_UnzipAll()                  <--             ZIP_ExtractArchiv()
       16)  MZ_UnzipFileToDisk()           <--             ZIP_ExtractFile()
       17)  MZ_UnzipFileToMem()            <--             ZIP_CatchFile()

 Zip/Unzip for MEMORY VARIABLE
 
       18)  MZ_MemPack()                   <--             ZIP_PackMemory()
       19)  MZ_MemUnpack()                 <--             ZIP_UnpackMemory()



 Compression Parameter
 _____________________
 MiniZIP handles 4 levels of Compression.  When function expects Compression as parameter,
 pass one of the following Constant value:
 
 NO_COMPRESSION = 0 /  BEST_SPEED = 1 /  BEST_COMPRESSION = 9 /  DEFAULT_COMPRESSION = -1



 Callback Parameter
 _____________________

 Zip/Unzip functions offer callback facility to AHK functions for which you may pass the
 address returned by

 RegisterCallback( "ZIP_ArchivCallback" )
 OR
 RegisterCallback( "ZIP_PackerCallback" )
 

 Callback procedure for MZ_UnzipAll()
                        MZ_ZipAddFolder()
 
 
          ZIP_ArchivCallback( Progress, Files ) {
            Return 0 ;  ZIP_OK = 0  or  ZIP_CANCEL = 1
          }



 Callback procedure for MZ_ZipAddFile()
                        MZ_ZipAddMem()
                        MZ_UnzipFileToMem()
                        MZ_UnzipFileToDisk()
                        

          ZIP_PackerCallback( Progress ) {
            Return 0 ;  ZIP_OK = 0  or  ZIP_CANCEL = 1
          }


__________________________________________________________________________________________
*/

MiniZIP_Init( DllFile ) {                                     ;             MiniZIP_Init()
 Return DllCall( "LoadLibrary", Str,DllFile, UInt )
}


MZ_SetPassword( Password="" ) {                               ;           MZ_SetPassword()
 Return DllCall( "MiniZIP\ZIP_SetPassword"
             , ( A_IsUnicode ? "AStr" : "Str" ), Password
                                               , UInt )
}


MZ_ZipCreate( zipFilename ) {                                 ;             MZ_ZipCreate()
 Return DllCall( "MiniZIP\ZIP_FileCreate"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFileName, UInt )
}


MZ_ZipOpen( zipFilename ) {                                   ;               MZ_ZipOpen()
 IfNotExist, %zipfileName%, Return
 Return DllCall( "MiniZIP\ZIP_FileOpen"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
                                               , UInt )
}


MZ_ZipAddFolder( zipHandle, SourceDir, Compression=-1         ;          MZ_ZipAddFolder()
                                     , Callback=0 ) {
 Return DllCall( "MiniZIP\ZIP_DirAdd"
                                               , UInt, zipHandle
             , ( A_IsUnicode ? "AStr" : "Str" ), SourceDir
                                         , Int , Compression
                                         , UInt, Callback
                                               , UInt )
}


MZ_ZipAddFile( zipHandle, SourceFilename, ArchiveFilename     ;            MZ_ZipAddFile()
                        , Compression=-1, Callback=0 ) {
 Return DllCall( "MiniZIP\ZIP_FileAdd"
                                         , UInt, zipHandle
             , ( A_IsUnicode ? "AStr" : "Str" ), SourceFilename
             , ( A_IsUnicode ? "AStr" : "Str" ), ArchiveFilename
                                         , Int , Compression
                                         , UInt, Callback
                                               , UInt )
}


MZ_ZipAddMem( zipHandle, memPointer, memSize, ArchiveFilename ;             MZ_ZipAddMem()
                                   , Compression=-1, Callback=0 ) {
 Return DllCall( "MiniZIP\ZIP_MemAdd"
                                    , UInt, zipHandle
                                    , UInt, memPointer
                                    , UInt, memSize
  , ( A_IsUnicode ? "AStr" : "Str" ), ArchiveFilename
                              , Int , Compression
                              , UInt, Callback
                                    , UInt  )
}


MZ_ZipClose( zipHandle, Comment="Created with MiniZIP.dll" ) { ;             MZ_ZipClose()
 Return DllCall( "MiniZIP\ZIP_FileClose"
                                         , UInt, ZipHandle
             , ( A_IsUnicode ? "AStr" : "Str" ), Comment
                                               , UInt )
}


MZ_ZipIsValid( zipFilename ) {                                ;           MZ_ZipIsValid(()
 IfNotExist, %zipfileName%, Return 3
 Return DllCall( "MiniZIP\ZIP_IsZipArchive"
             , ( A_IsUnicode ? "AStr" : "Str" ), ZipFilename, UInt )
} ;  Return Values:   0 = OK,  1 = NOT_ARCHIVE,  2 = ERROR_IN_ARCHIVE,  3 = FILE_NOT_FOUND


MZ_ZipGetFileCount( zipFilename ) {                           ;       MZ_ZipGetFileCount()
 IfNotExist, %zipfileName%, Return
 Return DllCall( "MiniZIP\ZIP_GetFilesCount"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
                                               , UInt )
}


MZ_ZipGetFileNumber( zipFileName, ArchiveFilename ) {         ;      MZ_ZipGetFileNumber()
 IfNotExist, %zipfileName%, Return
 Return DllCall( "MiniZIP\ZIP_GetFileNumber"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
             , ( A_IsUnicode ? "AStr" : "Str" ), ArchiveFilename
                                               , UInt )
}


MZ_ZipIsPasswordRequired( zipFilename, zipFileNumber ) {      ; MZ_ZipIsPasswordRequired()
 IfNotExist, %zipfileName%, Return
 Return DllCall( "MiniZIP\ZIP_IsPasswordRequired"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
                                         , UInt, zipFileNumber, UInt )
}


MZ_ZipGetFilename( zipFilename, zipFileNumber=1               ;        MZ_ZipGetFilename()
                              , ByRef FILEINFO="" ) {
 IfNotExist, %zipfileName%, Return
 VarSetCapacity( FILEINFO, 310, 0 )
 Return DllCall( "MiniZIP\ZIP_GetFileInfo"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
                                         , UInt, zipFileNumber
                                         , UInt, &FILEINFO
                                               , ( A_IsUnicode ? "AStr" : "Str" ) )
}


MZ_ZipGetComment( zipFilename ) {                             ;         MZ_ZipGetComment()
 IfNotExist, %zipfileName%, Return
 Return DllCall( "MiniZIP\ZIP_GetFileComment"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
                                               , ( A_IsUnicode ? "AStr" : "Str" ) )
}


MZ_UnzipAll( zipFilename, TargetPath, CreateTargetPath=1      ;              MZ_UnzipAll()
                                    , Callback=0 ) {
 IfNotExist, %zipfileName%, Return
 Return DllCall("MiniZIP\ZIP_ExtractArchiv"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
             , ( A_IsUnicode ? "AStr" : "Str" ), TargetPath
                                         , UInt, CreateTargetPath
                                         , UInt, Callback
                                               , UInt )
}


MZ_UnzipFileToDisk( zipFilename, zipFileNumber, TargetPath    ;       MZ_UnzipFileToDisk()
                               , CreateTargetPath=1, Callback=0 ) {
 IfNotExist, %zipfileName%, Return
 Return DllCall("MiniZIP\ZIP_ExtractFile"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
                                         , UInt, zipFileNumber
             , ( A_IsUnicode ? "AStr" : "Str" ), TargetPath
                                         , UInt, CreateTargetPath
                                         , UInt, Callback
                                               , UInt )
}


MZ_UnzipFileToMem( zipFilename, zipFileNumber=1               ;        MZ_UnzipFileToMem()
                              , Callback=0 ) {
 IfNotExist, %zipfileName%, Return ErrorLevel := 0
 Return hGlobal := DllCall( "MiniZIP\ZIP_CatchFile"
                        , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
                                                          , UInt, zipFileNumber
                                                          , UInt )
      , ErrorLevel := DllCall( "GlobalSize", UInt,hGlobal, UInt )
}


MZ_MemPack( memPointer, memSize, Compression=9 ) {            ;               MZ_MemPack()
 Return hGlobal := DllCall( "MiniZIP\ZIP_PackMemory"
                                                , UInt, memPointer
                                                , UInt, memSize
                                                , Int , Compression
                                                      , UInt )
   , ErrorLevel := DllCall( "GlobalSize", UInt,hGlobal, UInt )
}


MZ_MemUnpack( memPointerSource, memPointerTarget ) {          ;             MZ_MemUnpack()
 Return DllCall( "MiniZIP\ZIP_UnpackMemory"
                                          , UInt, memPointerSource
                                          , UInt, memPointerTarget
                                          , UInt )
}


;____________________________________________________________   //   End of MiniZIP.ahk //