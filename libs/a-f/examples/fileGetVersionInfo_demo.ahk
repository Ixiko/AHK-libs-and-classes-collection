#SingleInstance, Force
SetBatchLines -1

Loop, %A_WinDir%\System32\*.??l
  Files .= "`n" A_LoopFileLongPath
Files := A_AhkPath . Files

StringFileInfo=
( LTrim
  FileDescription
  FileVersion
  InternalName
  LegalCopyright
  OriginalFilename
  ProductName
  ProductVersion
  CompanyName
  PrivateBuild
  SpecialBuild
  LegalTrademarks
)

Loop, Parse, Files, "`n"
  If VI := FileGetVersionInfo( A_LoopField, StringFileInfo, "`n"  )
    MsgBox, 64, %A_LoopField%, %VI%