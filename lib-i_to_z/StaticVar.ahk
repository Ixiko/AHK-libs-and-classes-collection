StaticVar(name,func){
    if (fun:=FindFunc(func))&&mVar:=(f:=Struct("ScriptStruct(Func)",fun)).mStaticVar
        Loop f.mStaticVarCount
            If (var:=mVar[A_Index]).mName = name
                return var
    return []
}