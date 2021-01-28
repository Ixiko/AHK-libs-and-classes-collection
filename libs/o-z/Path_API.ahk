PathIsFileSpec( pPath )
{
  return DllCall("Shlwapi\PathIsFileSpecW","Ptr",&pPath)
}

PathSplit( path, ByRef out_args,ByRef out_dir )
{
  out_args := PathGetArgs( path )
  if out_args
    path := PathRemoveArgs( path )
  out_dir := PathGetDir( path )
  path := PathResolve( path )
  return path
}

PathQuoteSpaces( path )
{
  path := Trim( path )
  if( instr( path, A_Space ) && !instr( path, """" ) )
    path = "%path%"
  return path
}

PathUnquoteSpaces( path )
{
  path := Trim( path )
  regex = O)^\s*"+(.*?)"+\s*$
  if RegExMatch( path, regex, match )
    path := match[1]
  return path
}

;removes unallowed characters from file name
PathCleanup( path )
{
  ;VarSetCapacity( qPath, glb[ "MAX_PATH" ], 0 )
  VarSetCapacity( qPath, 522, 0 )
  StrPut( path, &qPath )
  if DllCall("shell32\PathCleanupSpec","Ptr",0,"Ptr",&qPath )
    path := StrGet( &qPath )
  free( qPath )
  return path
}

PathIsNetworkPath( path )
{
  return DllCall( "Shlwapi\PathIsNetworkPathW", "Ptr", &path )
}

PathIsURL( path )
{
  return DllCall( "Shlwapi\PathIsURLW", "Ptr", &path )
}

PathIsDir( path )
{
  return DllCall( "Shlwapi\PathIsDirectoryW", "WStr", path )
}

PathGetDir( path )
{
  path := PathUnquoteSpaces( path )
  if PathIsDir( path )
  {
    DllCall( "Shlwapi\PathRemoveBackslashW", "WStr", path )
    return path
  }
  else
  {
    DllCall( "Shlwapi\PathRemoveFileSpecW", "WStr", path )
    return path
  }
}


PathResolve( path )
{
  path := PathUnquoteSpaces( path )
  if PathIsRelative( path )
    if IsProperPath( path )
      path := PathAppend( A_WorkingDir, path )
  return PathQuoteSpaces( path )
}

IsProperPath( path )
{
  if RegExMatch( path, "^\s*(\.|\.\.)\s*$" )	;paths like "." or ".." considered proper
    return 1
  return !( PathIsFileSpec( path ) || PathIsURL( path ) || InStr( path, "%" ) )
}

PathIsRelative( path )
{
  return DllCall("Shlwapi\PathIsRelativeW","Ptr",&path )
}

PathAppend( path1, path2 )
{
  ;VarSetCapacity( qPath, glb[ "MAX_PATH" ], 0 )
  VarSetCapacity( qPath, 522, 0 )
  StrPut( path1, &qPath )
  if DllCall("Shlwapi\PathAppendW","Ptr",&qPath,"Ptr",&path2 )
    path1 := StrGet( &qPath )
  free( qPath )
  return path1
}

ParseEnvVars(path)
{
  fPos := 1
  loop
    if fPos := RegExMatch( path,"%\K.+?(?=%)", env_var_name, fPos )
    {
      EnvGet, env_var_value, %env_var_name%
      if env_var_value {
        StringReplace,path,path,% "%" env_var_name "%",% env_var_value
        fPos += StrLen( env_var_value ) - 1		;-1 because we removing two %
      }
      else
        fPos += StrLen( env_var_name ) + 1		;+1 because we have one % beyond var name
    }
    else
      break
  return path
}

PathGetArgs(path)
{
  args := DllCall("Shlwapi\PathGetArgsW","str",path,"str")	;return string though function returns pointer
  return args
}

PathRelativeTo(pTo,pFrom = "")
{
  pTo := PathUnquoteSpaces( pTo )
  if (pFrom = "")
    pFrom := A_WorkingDir
  VarSetCapacity(path_out,260*2)
  if IsProperPath( pTo )
    if DllCall("Shlwapi\PathRelativePathToW","Ptr", &path_out,"Ptr",&pFrom,"Int",0x10,"Ptr",&pTo,"int",0)	;FILE_ATTRIBUTE_DIRECTORY = 0x10
      pTo := StrGet( &path_out )
  free( path_out )
  pTo := PathQuoteSpaces( pTo )
  return pTo
}

PathRemoveArgs( path )
{
  DllCall("Shlwapi\PathRemoveArgsW","str",path)
  Return Path
}

URLEscape( url )
{
  StringReplace,url,url,&euro;,€,1
  StringReplace,url,url,&nbsp;,%A_Space%,1
  StringReplace,url,url,&quot;,",1
  StringReplace,url,url,&amp;,&,1
  StringReplace,url,url,&lt;,<,1
  StringReplace,url,url,&gt;,>,1
  return url
}

MailEscape(ByRef email)
{
  StringReplace, email, email, %A_Space%,`%20,1 
  StringReplace, email, email, %A_Tab%,`%09,1 
  StringReplace, email, email, `n,`%0A,1
  StringReplace, email, email, `r,`%0D,1
  StringReplace, email, email, &,`%26,1
  StringReplace, email, email, ",`%22,1
  StringReplace, email, email, ?,`%3F,1
  StringReplace, email, email, {,`%7B,1
  StringReplace, email, email, },`%7D,1
  return email
}

MailDescape(byref email)
{
  StringReplace, email, email,`%20, %A_Space%,1 
  StringReplace, email, email,`%09,%A_Tab%,1 
  StringReplace, email, email,`%0A,`n,1
  StringReplace, email, email,`%0D,`r,1
  StringReplace, email, email,`%26,&,1
  StringReplace, email, email,`%22, ",1
  StringReplace, email, email,`%3F, ?,1
  StringReplace, email, email,`%7B, {,1
  StringReplace, email, email,`%7D, },1
  return	email 
}

MsiGetShortcutTarget( sPath )
{
  VarSetCapacity( szProductCode,39*2,0),VarSetCapacity( szFeatureId,39*2,0),VarSetCapacity( szComponentCode,39*2,0)
  if DllCall( "msi\MsiGetShortcutTargetW", "Ptr", &sPath, "wstr", szProductCode, "wstr", szFeatureId, "wstr", szComponentCode )
    return 0
  pathSize := 255*2
  VarSetCapacity( sTarget, pathSize, 0 )
  DllCall( "msi\MsiGetComponentPathExW", "wstr", szProductCode, "wstr", szComponentCode, "ptr", 0,  "uint", 4, "wstr", sTarget, "UInt*", pathSize )
  return sTarget
}

PathFileExist( sPath )
{
  return DllCall( "Shlwapi\PathFileExistsW", "ptr", &sPath )
}

PathRemoveExt( sFileName )
{
  sNew := RegExReplace( sFileName, "\.[^\.]*\s*$" )
  if( sNew = "" )
    return sFileName
  return sNew
}

PathFindExtension( sPath )
{
  return DllCall( "Shlwapi\PathFindExtensionW", "ptr", &sPath )
}

PathGetExt( sPath )
{
  sPath := PathUnquoteSpaces( sPath )
  if IsEmpty( sPath )
    return ""
  ext := StrGet( PathFindExtension( sPath ), "UTF-16" )
  return SubStr( ext, 2 ) ;getting extension without dot
}

PathShortcutGet( sPath, ByRef sTarget, ByRef sIcon, includeArgs = True )
{
  sTarget := sIcon := ""
  sPath := PathUnquoteSpaces( sPath )
  if ( sTarget := MsiGetShortcutTarget( sPath ) )
    sTarget := PathQuoteSpaces( sTarget )
  else
  {
    FileGetShortcut,% sPath, sTarget,,sArgs,,icoPath,icoNum
    sTarget := PathQuoteSpaces( sTarget )
    if( includeArgs && !isEmpty( sArgs ) )
      sTarget := sTarget " " sArgs
    sIcon := ( icoPath != "" && icoNum != "" ) ? icoPath ":" icoNum-1 : ""
  }
  return
}

PathParseName( sPath )
{
  DllCall("shell32\SHParseDisplayName", "Wstr", PathUnquoteSpaces( sPath ), "Ptr", 0, "Ptr*", pidl, "Uint", 0, "Uint*", 0)
  ;VarSetCapacity( out_str, glb[ "MAX_PATH" ], 0 )
  VarSetCapacity( out_str, 522, 0 )
  DllCall("shell32\SHGetPathFromIDListW", "ptr", pidl, "wstr", out_str )
  return out_str
}

FileReadLine( file, line )
{
  FileReadLine, data,% file,% line
  return data
}

FileRead(Filename) 
{
  v:= ""
  FileRead, _v, %Filename%
  return _v
}


Free(byRef var)
{
  VarSetCapacity(var,0)
  return
}


isEmpty( var )
{
  return ( var = "" ? True : False )
}
