; GetActiveObjects v1.0 by Lexikos
; http://ahkscript.org/boards/viewtopic.php?f=6&t=6494
GetActiveObjects(Prefix:="", CaseSensitive:=false) {
objects := {}
DllCall("ole32\CoGetMalloc", "uint", 1, "ptr*", malloc) ; malloc: IMalloc
DllCall("ole32\CreateBindCtx", "uint", 0, "ptr*", bindCtx) ; bindCtx: IBindCtx
DllCall(NumGet(NumGet(bindCtx+0)+8*A_PtrSize), "ptr", bindCtx, "ptr*", rot) ; rot: IRunningObjectTable
DllCall(NumGet(NumGet(rot+0)+9*A_PtrSize), "ptr", rot, "ptr*", enum) ; enum: IEnumMoniker
while DllCall(NumGet(NumGet(enum+0)+3*A_PtrSize), "ptr", enum, "uint", 1, "ptr*", mon, "ptr", 0) = 0 ; mon: IMoniker
{
DllCall(NumGet(NumGet(mon+0)+20*A_PtrSize), "ptr", mon, "ptr", bindCtx, "ptr", 0, "ptr*", pname) ; GetDisplayName
name := StrGet(pname, "UTF-16")
DllCall(NumGet(NumGet(malloc+0)+5*A_PtrSize), "ptr", malloc, "ptr", pname) ; Free
if InStr(name, Prefix, CaseSensitive) = 1 {
DllCall(NumGet(NumGet(rot+0)+6*A_PtrSize), "ptr", rot, "ptr", mon, "ptr*", punk) ; GetObject
; Wrap the pointer as IDispatch if available, otherwise as IUnknown.
if (pdsp := ComObjQuery(punk, "{00020400-0000-0000-C000-000000000046}"))
obj := ComObject(9, pdsp, 1), ObjRelease(punk)
else
obj := ComObject(13, punk, 1)
; Store it in the return array by suffix.
objects[SubStr(name, StrLen(Prefix) + 1)] := obj
}
ObjRelease(mon)
}
ObjRelease(enum)
ObjRelease(rot)
ObjRelease(bindCtx)
ObjRelease(malloc)
return objects
}