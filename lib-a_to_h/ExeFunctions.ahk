#DllImport, exeFunction,%A_AhkPath%\ahkFunction,Str,,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,Cdecl Str
#DllImport, exePostFunction,%A_AhkPath%\ahkPostFunction,Str,,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,PTR,0,Cdecl Str
#DllImport, exeExec,%A_AhkPath%\ahkExec,Str,,Cdecl
#DllImport, exeaddScript,%A_AhkPath%\addScript,Str,,UInt,0,Cdecl PTR
#DllImport, exeaddFile,%A_AhkPath%\addFile,Str,,UInt,0,Cdecl PTR
#DllImport, exeExecuteLine,%A_AhkPath%\ahkExecuteLine,PTR,0,UInt,0,UInt,0,Cdecl PTR
#DllImport, exeFindLabel,%A_AhkPath%\ahkFindLabel,Str,,Cdecl PTR
#DllImport, exeFindFunc,%A_AhkPath%\ahkFindFunc,Str,,Cdecl PTR
#DllImport, exeassign,%A_AhkPath%\ahkAssign,Str,,Str,,Cdecl
#DllImport, exegetvar,%A_AhkPath%\ahkgetvar,Str,,UInt,0,Cdecl STR
#DllImport, exeLabel,%A_AhkPath%\ahkLabel,Str,,UInt,0,Cdecl PTR
#DllImport, exePause,%A_AhkPath%\ahkPause,Str,,Cdecl