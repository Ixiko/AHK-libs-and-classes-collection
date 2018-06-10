HBITMAPfromHICON( hIcon )
{
  VarSetCapacity( ICONINFO, 8 + 3*A_PtrSize, 0 )
  ret := DllCall( "User32\GetIconInfo","Ptr", hIcon, "Ptr", &ICONINFO )
  hbmMask := NumGet( &ICONINFO, 8 + A_PtrSize, "UPtr" )
  DllCall("DeleteObject", "Ptr", hbmMask )
  hbmColor := NumGet( &ICONINFO, 8 + 2*A_PtrSize, "UPtr" )
  return hbmColor
}

Gdip_Startup()
{
  if !DllCall( "GetModuleHandleW", "Wstr", "gdiplus", "UPtr" )
        DllCall( "LoadLibraryW", "Wstr", "gdiplus", "UPtr" )
  
  VarSetCapacity(GdiplusStartupInput , 3*A_PtrSize, 0), NumPut(1,GdiplusStartupInput ,0,"UInt") ; GdiplusVersion = 1
  DllCall("gdiplus\GdiplusStartup", "Ptr*", pToken, "Ptr", &GdiplusStartupInput, "Ptr", 0)
  return pToken
}

Gdip_Shutdown(pToken)
{
  DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
  if hModule := DllCall( "GetModuleHandleW", "Wstr", "gdiplus", "UPtr" )
    DllCall("FreeLibrary", "Ptr", hModule)
  return 0
}

StrSplit(str,delim,omit = "")
{
  if (strlen(delim) > 1)
  {
    StringReplace,str,str,% delim,ƒ,1 		;¦¶+
    delim = ƒ
  }
  ra := Array()
  loop, parse,str,% delim,% omit
    if (A_LoopField != "")
      ra.Insert(A_LoopField)
  return ra
}

IconExtract( pPath, pNum=0, size = 32 ) 
{
  static PrivateExtractIconsW
  if !PrivateExtractIconsW
    PrivateExtractIconsW := LoadDllFunction( "user32.dll", "PrivateExtractIconsW" )
  VarSetCapacity(hicon,A_PtrSize,0)
  ;http://msdn.microsoft.com/en-us/library/ms648075%28v=VS.85%29.aspx
  DllCall(PrivateExtractIconsW, "Str", pPath, "UInt", pNum, "UInt", size, "UInt", size, "Ptr", &hicon, "Ptr", 0,"UInt",1, "UInt", 0)
  handle := NumGet( hicon,0,"UPtr")
  if !handle
  {
    SplitPath, pPath,,,Ext
    if (Ext = "exe")
      DllCall(PrivateExtractIconsW, "Str", "shell32.dll", "UInt", 2, "UInt", size, "UInt", size, "Ptr", &hicon, "Ptr", 0,"UInt",1, "UInt", 0)
      ,handle  := NumGet( hicon,0,"UPtr")
  }
  return handle
}

LoadDllFunction( file, function ) {
    if !hModule := DllCall( "GetModuleHandleW", "Wstr", file, "UPtr" )
        hModule := DllCall( "LoadLibraryW", "Wstr", file, "UPtr" )
  
    ret := DllCall("GetProcAddress", "Ptr", hModule, "AStr", function, "UPtr")
  return ret
}

PathUnquoteSpaces( path )
{
  path := Trim( path )
  regex = ^"\K.*(?="$)
  while RegExMatch( path, regex, cmd_new )
    path := cmd_new
  return path
}

IconGetPath(Ico)	{
  spec := Ico
  pos := InStr(Ico, ":", 0, 0)
  if (pos > 4)
    spec := substr(Ico,1,pos-1)
  return PathUnquoteSpaces( spec )
}

IconGetIndex(Ico)	
{	
  pos := InStr(Ico, ":", 0, 0)
  if (pos > 4)
  {
    ind := substr(Ico,pos+1)
    if !ind
      ind := 0
    return ind
  }
}

IsInteger( var )
{
  if var is integer
    return True
  else 
    return False
}