MCodeH(h,def,p*){
static f,DynaCalls
If !f
f:={},DynaCalls:={}
If DynaCalls.HasKey(h)
return DynaCalls[h]
f.Insert(h),f.SetCapacity(f.MaxIndex(),len:=StrLen(h)//2)
DllCall("VirtualProtect","PTR",addr:=f.GetAddress(f.MaxIndex()),"Uint",len,"UInt",64,"Uint*",0)
Loop % len
NumPut("0x" SubStr(h,2*A_Index-1,2),addr+0,A_Index-1,"Char")
if p.MaxIndex()
Return DynaCalls[h]:=DynaCall(addr,def,p*)
else Return DynaCalls[h]:=DynaCall(addr,def)
}