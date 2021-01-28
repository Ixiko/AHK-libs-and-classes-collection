
; FileOpen / FileSave dialogue functions
; This File is relased under the zlib/libpng License
; ( c ) 2007 Raphael Friedel
;
; http://www.opensource.org/licenses/zlib-license.php
;
; For a List of possible Flags have a look at EOF

;----------------------------------------------------------------------------------------------
; Function:  FileOpen
;            Display standard OpenSaveDialogue
;
; Parameters:
;            HWND            - Parent's Handle
;            Filter          - Specify Filter as with FileSelectFile
;                              for use of multiple Filter seperate them with |
;            defaultFilter   - Selects default Filter from above List
;            IniDir          - Specify Initialisation Directory
;                              chosen Directory will be set as WorkingDir in
;                              A_WorkingDir
;            DialogTitle     - Dialogue Title
;            defaulltExt     - Extension to append when none given
;            flags           - Flags for Dialogue
;                              when no supplied 
;                               OFN_FILEMUSTEXIST - OFN_HIDEREADONLY  - OFN_ENABLEXPLORER
;                              are used as default
;
;  Returns:
;            Selected FileName or Emtpy when cancelled
;
;  Remarks:
;            When OFN_ALLOWMULTISELECT flag is set, be sure to set OFN_ENABLEXPLORER flag,
;            too. Without it the Old-Style FileOpen Dialogue appears and handling multiple
;            fileNames might be different and wont work as expected
;            See http://msdn2.microsoft.com/en-us/library/ms646839.aspx for details
;
DLG_FileOpen( ByRef HWND=0
            , ByRef Filter="Text Files (*.txt)|All Files (*.*)"
            , ByRef defaultFilter=1
            , ByRef IniDir=""
            , ByRef DialogTitle="Select file to open"
            , ByRef defaulExt="txt"
            , ByRef flags="" )
{

   VarSetCapacity( FileTitle,0xffff,0 )    ; OutName - w/o Dir
   VarSetCapacity( fT,0xffff,0 )           ; OutName - w/ Dir
   VarSetCapacity( lpstrFilter,0xffff,0 )  ; fILTERtEXT
   VarSetCapacity( cF,0xff,0 )             ; cUSTOMfILTER
   VarSetCapacity( OFName,90,0 )           ; OPENFILENAME

   ; Contruct FilterText seperate by \0
   fI          := 0                        ; Used by Loop as Offset
   
   loop, Parse, Filter, |               
   {
      OB       := InStr( A_LoopField,"(" ) + 1         ; Find Open Bracket
      Ext       := SubStr( A_LoopField, OB,-1 )
      Loop, Parse, A_LoopField
      {
         NumPut( asc( A_LoopField ),lpstrFilter,fI,"UChar" )
         fI++
      }
      NumPut( 0,lpstrFilter,fI,"UChar" )
      fI++
      Loop, Parse, Ext
      {
         NumPut( asc( A_LoopField ),lpstrFilter,fI,"UChar" )
         fI++
      }
      NumPut( 0,lpstrFilter,fI,"UChar" )
      fI++
   }
   NumPut( 0,lpstrFilter,fI,"UChar" )                   ; Double Zero Termination

   ; SetDefaultFlags

   If ( flags="" ) {
      hFlags := __helperFileOpenSaveFlags( "0x1000|0x4|0x80000" )
   } else {
      hFlags := __helperFileOpenSaveFlags( flags )
   }


   ; Contruct OPENFILENAME Structure
   
   NumPut( 76,            OFName, 0,  "UInt" )    ; Length of Structure
   NumPut( HWND,          OFName, 4,  "UInt" )    ; HWND
   NumPut( &lpstrFilter,  OFName, 12, "UInt" )    ; Pointer to FilterStruc
   NumPut( &cF,           OFName, 16, "UInt" )    ; Pointer to CustomFilter
   NumPut( 255,           OFName, 20, "UInt" )    ; MaxChars for CustomFilter
   NumPut( defaultFilter, OFName, 24, "UInt" )    ; DefaultFilter Pair
   NumPut( &fT,           OFName, 28, "UInt" )    ; lpstrFile / InitialisationFileName
   NumPut( 0xffff,        OFName, 32, "UInt" )    ; MaxFile / lpstrFile length
   NumPut( &FileTitle,    OFName, 36, "UInt" )    ; lpstrFileTitle
   NumPut( 0xffff,        OFName, 40, "UInt" )    ; maxFileTitle
   NumPut( &IniDir,       OFName, 44, "UInt" )    ; IniDir
   NumPut( &DialogTitle,  OFName, 48, "UInt" )    ; DlgTitle
   NumPut( hFlags,        OFName, 52, "UInt" )    ; Flags
   NumPut( &defaultExt,   OFName, 60, "UInt" )    ; DefaultExt

   DllCall("comdlg32\GetOpenFileNameA", "Uint", &OFName  )
   
   fDirAndName  := ""
   fZeroHit     := 0
   fNameCount   := 0
   
   Loop, 0xffff
   {
      char := NumGet( fT, A_Index-1, "UChar" )
      if ( char=0 ) {
         fDirAndName .= "|"                    ; Set Delimiter as there might be more than
         fNameCount++                          ; one File selected
         fZeroHit++                            ; increment ZeroCount
      } else {
         fDirAndName .= chr( char )            ; Append to FileName
         fZeroHit := 0                         ; reset FileTerminationCount
      }
      if fZeroHit = 2
         break
   }
   
   if ( fNameCount-fZeroHit>0 )                  ; This is the multiple File Selection
   {
      fDirName    := SubStr( fDirAndName, 1, InStr( fDirAndName, "|" )-1 )
      fNames      := SubStr( fDirAndName, StrLen( fDirName )+2, -2 )
      fDirAndName := ""
      Loop, Parse, fNames, |
      {
         fDirAndName .= fDirName . "\" . A_LoopField . "|"
      }
      StringTrimRight, fDirAndName, fDirAndName, 1         ; remove last delimiter
   } else {
      StringTrimRight, fDirAndName, fDirAndName, %fZeroHit%   ; remove last two delimiters
   }
   
   return %fDirAndName%
}

;----------------------------------------------------------------------------------------------
; Function:  FileSave
;            Display standard OpenSaveDialogue
;
; Parameters:
;            HWND            - Parent's Handle
;            Filter          - Specify Filter as with FileSelectFile
;                              for use of multiple Filter seperate them with |
;            defaultFilter   - Selects default Filter from above List
;            IniDir          - Specify Initialisation Directory
;                              chosen Directory will be set as WorkingDir in
;                              A_WorkingDir
;            DialogTitle     - Dialogue Title
;            defaulltExt     - Extension to append when none given
;            flags           - Flags for Dialogue
;                              when no supplied 
;                               OFN_EXTENSIONDIFFERENT - OFN_OVERWRITEPROMPT
;                              are used as default
;
;  Returns:
;            Selected FileName or Emtpy when cancelled
;
DLG_FileSave( ByRef HWND=0
            , ByRef Filter="Text Files (*.txt)|All Files (*.*)"
            , ByRef defaultFilter=1
            , ByRef IniDir=""
            , ByRef DialogTitle="Select file to Save"
            , ByRef defaulExt="txt"
            , ByRef flags="" )
{

   VarSetCapacity( FileTitle,0xffff,0 )    ; OutName - w/o Dir
   VarSetCapacity( fT,0xffff,0 )           ; OutName - w/ Dir
   VarSetCapacity( lpstrFilter,0xffff,0 )  ; fILTERtEXT
   VarSetCapacity( cF,0xff,0 )             ; cUSTOMfILTER
   VarSetCapacity( OFName,90,0 )           ; OPENFILENAME

   ; Contruct FilterText seperate by \0
   fI          := 0                        ; Used by Loop as Offset
   
   loop, Parse, Filter, |               
   {
      OB       := InStr( A_LoopField,"(" ) + 1         ; Find Open Bracket
      Ext       := SubStr( A_LoopField, OB,-1 )
      Loop, Parse, A_LoopField
      {
         NumPut( asc( A_LoopField ),lpstrFilter,fI,"UChar" )
         fI++
      }
      NumPut( 0,lpstrFilter,fI,"UChar" )
      fI++
      Loop, Parse, Ext
      {
         NumPut( asc( A_LoopField ),lpstrFilter,fI,"UChar" )
         fI++
      }
      NumPut( 0,lpstrFilter,fI,"UChar" )
      fI++
   }
   NumPut( 0,lpstrFilter,fI,"UChar" )                   ; Double Zero Termination
   
   ; SetDefaultFlags

   If ( flags="" ) {
      hFlags := __helperFileOpenSaveFlags( "EXTENSIONDIFFERENT OVERWRITEPROMPT" )
   } else {
      hFlags := __helperFileOpenSaveFlags( flags )
   }

   ; Contruct OPENFILENAME Structure
   
   NumPut( 76,            OFName, 0,  "UInt" )    ; Length of Structure
   NumPut( HWND,          OFName, 4,  "UInt" )    ; HWND
   NumPut( &lpstrFilter,  OFName, 12, "UInt" )    ; Pointer to FilterStruc
   NumPut( &cF,           OFName, 16, "UInt" )    ; Pointer to CustomFilter
   NumPut( 255,           OFName, 20, "UInt" )    ; MaxChars for CustomFilter
   NumPut( defaultFilter, OFName, 24, "UInt" )    ; DefaultFilter Pair
   NumPut( &fT,           OFName, 28, "UInt" )    ; lpstrFile / InitialisationFileName
   NumPut( 0xffff,        OFName, 32, "UInt" )    ; MaxFile / lpstrFile length
   NumPut( &FileTitle,    OFName, 36, "UInt" )    ; lpstrFileTitle
   NumPut( 0xffff,        OFName, 40, "UInt" )    ; maxFileTitle
   NumPut( &IniDir,       OFName, 44, "UInt" )    ; IniDir
   NumPut( &DialogTitle,  OFName, 48, "UInt" )    ; DlgTitle
   NumPut( hFlags,        OFName, 52, "UInt" )    ; Flags
   NumPut( &defaultExt,   OFName, 60, "UInt" )    ; DefaultExt

   DllCall("comdlg32\GetSaveFileNameA", "Uint", &OFName  )
   
   fDirAndName  := ""
   
   Loop, 0xffff
   {
      char := NumGet( fT, A_Index-1, "UChar" )
      if char=0
         break
      fDirAndName .= chr( char )
      
   }
   
   return %fDirAndName%
}


__helperFileOpenSaveFlags( flags )
{

    flagNames = OFN_SHAREWARN, OFN_SHARENOWARN, OFN_SHAREFALLTHROUGH, OFN_READONLY
              , OFN_OVERWRITEPROMPT, OFN_HIDEREADONLY, OFN_NOCHANGEDIR, OFN_SHOWHELP
              , OFN_ENABLEHOOK, OFN_ENABLETEMPLATE, OFN_ENABLETEMPLATEHANDLE
              , OFN_NOVALIDATE, OFN_ALLOWMULTISELECT, OFN_EXTENSIONDIFFERENT
              , OFN_PATHMUSTEXIST, OFN_FILEMUSTEXIST, OFN_CREATEPROMPT, OFN_SHAREAWARE
              , OFN_NOREADONLYRETURN, OFN_NOTESTFILECREATE, OFN_NONETWORKBUTTON
              , OFN_NOLONGNAMES, OFN_EXPLORER, OFN_NODEREFERENCELINKS, OFN_LONGNAMES
              , OFN_ENABLEINCLUDENOTIFY, OFN_ENABLESIZING, OFN_DONTADDTORECENT
              , OFN_FORCESHOWHIDDEN

    flagValue = 0, 1, 2, 0x1, 0x2, 0x4,0x8,0x10,0x20,0x40,0x80
              , 0x100, 0x200, 0x400, 0x800, 0x1000, 0x2000, 0x4000, 0x8000
              , 0x10000, 0x20000, 0x40000, 0x80000, 0x100000, 0x200000
              , 0x400000, 0x800000, 0x2000000, 0x10000000

   rFlag     := 0
   empty     := ""

   StringSplit, flagV, flagValue, `,

   StringUpper, flags, flags
   
   if ( InStr( flags, "OFN_" )!=0 ) {
      StringReplace, flags, flags, OFN_, %empty%, All
   }

   flags     := RegExReplace( flags, "\|+", "," )  ; Replace all Pipe Chars with Comma
   flags     := RegExReplace( flags, "\s+", "," )  ; Replace all WhiteSpace with Comma
   flags     := RegExReplace( flags, ",+", "," )   ; Replace all multifolowing Comma with one
   flags     := RegExReplace( flags, "(^,|,$)" )   ; Remove any leading or trailing Comma

   flagNames := RegExReplace( flagNames, "\s+" )   ; Remove all WhiteSpace
   flagValue := RegExReplace( flagValue, "\s+" )   ; Remove all WhiteSpace

   Loop, Parse, flags, `,
   {
      flag := A_LoopField
      if A_LoopField is Integer                   ; Check: Is Integer
      {
         if A_LoopField in %flagValue%           ; Pass only if allowed ( from List given )
         {
            rFlag |= A_LoopField            ; add to flags
         }
      }
      else {
         Loop, Parse, flagNames, `,              ; Must be Name
         {
            if ( SubStr( A_LoopField, 5 ) = flag ) {      ; Known Name?
               rFlag |= flagV%A_Index%         ; Grab its Value and add to return flags
            }
         }
      }
   }
   
   return, rFlag
   
}



; Possible FLAGS for FileOpen/FileSave Dlg
; Refer to http://msdn2.microsoft.com/en-us/library/ms646839.aspx

;    OFN_ALLOWMULTISELECT     := 0x200
;    OFN_CREATEPROMPT         := 0x2000
;    OFN_DONTADDTORECENT      := 0x2000000
;    OFN_ENABLEHOOK           := 0x20
;    OFN_ENABLEINCLUDENOTIFY  := 0x400000
;    OFN_ENABLESIZING         := 0x800000
;    OFN_ENABLETEMPLATE       := 0x40
;    OFN_ENABLETEMPLATEHANDLE := 0x80
;    OFN_EXPLORER             := 0x80000
;    OFN_EXTENSIONDIFFERENT   := 0x400
;    OFN_FILEMUSTEXIST        := 0x1000
;    OFN_FORCESHOWHIDDEN      := 0x10000000
;    OFN_HIDEREADONLY         := 0x4
;    OFN_NOCHANGEDIR          := 0x8
;    OFN_NODEREFERENCELINKS   := 0x100000
;    OFN_NOVALIDATE           := 0x100
;    OFN_OVERWRITEPROMPT      := 0x2
;    OFN_PATHMUSTEXIST        := 0x800
;    OFN_READONLY             := 0x1
;    OFN_SHAREAWARE           := 0x4000
;    OFN_SHAREFALLTHROUGH     := 2
;    OFN_SHARENOWARN          := 1
;    OFN_SHAREWARN            := 0
;    OFN_SHOWHELP             := 0x10
;    OFN_NONETWORKBUTTON      := 0x20000
;    OFN_NOREADONLYRETURN     := 0x8000
;    OFN_NOTESTFILECREATE     := 0x10000
;    OFN_LONGNAMES            := 0x200000
;    OFN_NOLONGNAMES          := 0x40000
   
;    ; Not used here: FlagEx - not supported by OpenFileName Structure
;    OFN_EX_NOPLACESBAR       := 0x1
