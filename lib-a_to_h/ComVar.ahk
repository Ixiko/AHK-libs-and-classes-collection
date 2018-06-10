ComVar(Type=0xC){
static base
if !base
  base:={__Get:"ComVarGet",__Set:"ComVarSet",__Delete:"ComVarDel"}
arr:=ComObjArray(Type,1)
DllCall("oleaut32\SafeArrayAccessData","ptr",ComObjValue(arr),"ptr*",arr_data)
return {ref:ComObject(0x4000|Type,arr_data),_:arr,base:base}
}
ComVarGet(cv,p*){
if !p.MaxIndex()
return cv._[0]
}
ComVarSet(cv,v,p*){
if !p.MaxIndex()
return cv._[0]:=v
}
ComVarDel(cv){
DllCall("oleaut32\SafeArrayUnaccessData","ptr",ComObjValue(cv._))
}