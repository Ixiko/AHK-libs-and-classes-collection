/*
text:="
(
--- !<tag:clarkevans.com,2002:invoice>
invoice: 34843
date   : 2001-01-23
bill-to: &id001
    given  : Chris
    family : Dumars
    address:
        lines: |
            458 Walkman Dr.
            Suite #292
        city    : Royal Oak
        state   : MI
        postal  : 48046
ship-to: *id001
product:
    - sku         : BL394D
      quantity    : 4
      description : Basketball
      price       : 450.00
    - sku         : BL4438H
      quantity    : 1
      description : Super Hoop
      price       : 2392.00
tax  : 251.42
total: 4443.52
comments:
    Late afternoon is best.
    Backup contact is Nancy
    Billsmer @ 338-4338.
---
Time: 2001-11-23 15:01:42 -5
User: ed
Warning:
  This is an error message
  for the log file
---
Time: 2001-11-23 15:02:31 -5
User: ed
Warning:
  A slightly different error
  message.
---
Date: 2001-11-23 15:03:17 -5
User: ed
Fatal:
  Unknown variable "bar"
Stack:
  - file: TopClass.py
    line: 23
    code: |
      x = MoreObject("345\n")
  - file: MoreClass.py
    line: 58
    code: |-
      foo = bar
)"
text:="
(
{
"users": [
{
"_id": "45166552176594981065",
"index": 692815193,
"guid": "oLzFhQttjjCGmijYulZg",
"isActive": true,
"balance": "XtMtTkSfmQtyRHS1086c",
"picture": "Q8YoyJ0cL1MGFwC9bpAzQXSFBEcAUQ8lGQekvJZDeJ5C5p",
"age": 23,
"eyeColor": "XqoN9IzOBVixZhrofJpd",
"name": "xBavaMCv6j0eYkT6HMcB",
"gender": "VnuP3BaA3flaA6dLGvqO",
"company": "L9yT2IsGTjOgQc0prb4r",
"email": "rfmlFaVxGBSZFybTIKz0",
"phone": "vZsxzv8DlzimJauTSBre",
"address": "fZgFDv9tX1oonnVjcNVv",
"about": "WysqSAN1psGsJBCFSR7P",
"registered": "Lsw4RK5gtyNWGYp9dDhy",
"latitude": 2.6395313895198393,
"longitude": 110.5363758848371,
"tags": [
"Hx6qJTHe8y",
"23vYh8ILj6",
"geU64sSQgH",
"ezNI8Gx5vq"
],
"friends": [
{
"id": "3987",
"name": "dWwKYheGgTZejIMYdglXvvrWAzUqsk"
},
{
"id": "4673",
"name": "EqVIiZyuhSCkWXvqSxgyQihZaiwSra"
}
],
"greeting": "xfS8vUXYq4wzufBLP6CY",
"favoriteFruit": "KT0tVAxXRawtbeQIWAot"
},
{
"_id": "23504426278646846580",
"index": 675066974,
"guid": "MfiCc1n1WfG6d6iXcdNf",
"isActive": true,
"balance": "OQEwTOBvwK0b8dJYFpBU",
"picture": "avtMGQxSrO1h86V7KVaKaWUFZ0ooZd9GmIynRomjCjP8tEN",
"age": 33,
"eyeColor": "Fjsm1nmwyphAw7DRnfZ7",
"name": "NnjrrCj1TTObhT9gHMH2",
"gender": "ISVVoyQ4cbEjQVoFy5z0",
"company": "AfcGdkzUQMzg69yjvmL5",
"email": "mXLtlNEJjw5heFiYykwV",
"phone": "zXbn9iJ5ljRHForNOa79",
"address": "XXQUcaDIX2qpyZKtw8zl",
"about": "GBVYHdxZYgGCey6yogEi",
"registered": "bTJynDeyvZRbsYQIW9ys",
"latitude": 16.675958191062414,
"longitude": 114.20858157883556,
"tags": [],
"friends": [],
"greeting": "EQqKZyiGnlyHeZf9ojnl",
"favoriteFruit": "9aUx0u6G840i0EeKFM4Z"
}
]
}
)"
Y:=Yaml(text)
MsgBox Yaml(Y[1],-5)
Yaml("{`"test`": 1}",Y)
MsgBox Yaml(Y,-5)
MsgBox Yaml(Map("test",1,"try","hand"),-5)
*/

;~ #include <windows.h>
;~ WCHAR* getline(WCHAR *i, BOOL set){
	;~ if (i==NULL || *i == L'\0')
		;~ return 0;
	;~ for (; *i; i++)
	;~ {
		;~ if (*i == L'\n')
		;~ {
			;~ if (set)
				;~ *i = L'\0';
			;~ return i + 1;
		;~ }
		;~ else if (*i == L'\r' && *(i + 1) == L'\n')
		;~ {
			;~ if (set)
			;~ {
				;~ *i = L'\0';
;~ //				*(i+1) = L'\0';
			;~ }
			;~ return i + 2;
		;~ }
	;~ }
	;~ return i;
;~ }

;Yaml v1.0.10 requires AutoHotkey v2.106+
Yaml(ByRef TextFileObject,Yaml:=0){
  If IsObject(TextFileObject)
    return D(TextFileObject,Yaml) ; dump object to yaml string
  else If FileExist(TextFileObject)
    return L(FileRead(TextFileObject),Yaml) ; load yaml from file
  else return L(TextFileObject,Yaml) ; load object from yaml string
  ;~ G(p,ByRef LF:=""){ ; get line and advance pointer to next line
    ;~ return !p||!NumGet(p,"UShort")?0:(str:=StrSplit(StrGet(P),"`n","`r",2)).Length?(p+=StrLen(LF:=str[1])*2,p+=!NumGet(p,"UShort") ? 0 : NumGet(p,"USHORT")=13?4:2):0
  ;~ }
  L(ByRef txt,Y:=0){ ; convert yaml to object
    static _fun_:=A_PtrSize=8?"SIXJdExED7cBZkWFwHUM60BIg8ECZkWFwHQkZkGD+Ap0IWZBg/gNRA+3QQJ142ZBg/gKdB9Ig8ECZkWFwHXjSInIw4XSdAUx0maJEUiNQQLDMcDDhdJ0BTHAZokBSI1BBMOQkJCQ":"i0QkBIXAdEsPtxBmhdJ1CutBg8ACZoXSdDdmg/oKdCBmg/oND7dQAnXoZoP6CnQmg8ACZoXSdejzw422AAAAAItMJAiFyXQFMdJmiRCDwALD88MxwMOLTCQIhcl0BTHSZokQg8AEw5A=",_sz_,NXTLN,_op_,__:=(DllCall("crypt32\CryptStringToBinary","str",_fun_,"uint",0,"uint",1,"ptr",0,"uint*",_sz_:=0,"ptr",0,"ptr",0),NXTLN:=DllCall("GlobalAlloc","uint",0,"ptr",_sz_,"ptr"),DllCall("VirtualProtect","ptr",NXTLN,"ptr",_sz_,"uint",0x40,"uint*",_op_:=0),DllCall("crypt32\CryptStringToBinary","str",_fun_,"uint",0,"uint",1,"ptr",NXTLN,"uint*",_sz_,"ptr",0,"ptr",0))
    If InStr("[{", SubStr(D:=LTrim(txt," `t`n`r"),1,1))
      return J(D,Yaml) ; create pure json object (different syntax to YAML and better performance)
    VarSetCapacity(text,StrLen(txt)*2+4,0),StrPut(txt,&text), VarsetCapacity(text,-1)
    P:=&text,A:=Map(),D:=[],I:=[]
    Loop 1000
      D.Push(0),I.Push(0)
    ;~ While P:=G(LP:=P,LF){
    While P && (LP:=P,P:=DllCall(NXTLN,"PTR",P,"Int",true,"PTR"),LF:=StrGet(LP),P){ ;P:=(LP:=P,!p||!NumGet(p,"UShort")?0:(str:=StrSplit(StrGet(P),"`n","`r",2)).Length?(p+=StrLen(LF:=str[1])*2,p+=!NumGet(p,"UShort") ? 0 : NumGet(p,"USHORT")=13?4:2):0){
      if (InStr(LF,"---")=1&&!Y)||(InStr(LF,"---")=1&&(Y.Push(""),D[1]:=0,_L:=_LL:=O:=_Q:=_K:=_S:=_T:=_V:="",1))||(InStr(LF,"...")=1&&NEWDOC:=1)||(LF="")||RegExMatch(LF,"^\s+$")
        continue
      else if NEWDOC&&MsgBox("Error, document ended but new document not specified: " LF)
        Exit
      if RegExMatch(LF,"^\s*#")||InStr(LF,"``%")=1 ; Comments, tag, document start/end or empty line, ignore
        continue
      else If _C || (_S&&SubStr(LF,1,LL*2)=I(LL+1)) || (V&&!(K&&_.SEQ)&&SubStr(LF,1,LL*2)=I(LL+1)){ ; Continuing line incl. scalars
        if _Q&&!_K{ ; Sequence
          If D[L].Length && IsObject(VC:=D[L].Pop()) && MsgBox("Error: Malformed inline YAML string") ; Error if previous value is an object
            Exit
          else D[L].Push(VC (VC?(_S=">"?" ":"`n"):"") _CE:=LTrim(LF,"`t ")) ; append value to previous item
        } else if IsObject(VC:=D[L][K]) && MsgBox("Error: Malformed inline YAML string") ; Error if previous value is an object
          Exit
        else D[L][K]:=VC (VC?(_S=">"?" ":"`n"):"") _CE:=LTrim(LF,"`t ") ; append value to previous item
          continue
      } else if _C&&(SubStr(_CE,-1)!=_C)&&MsgBox("Error: unexpected character near`n" (_Q?D[L][D[L].Length]:D[L][K])) ; else check if quoted value was ended with a quote
        Exit
      else _C:="" ; reset continuation
      If (CM:=InStr(LF," #"))&&!RegExMatch(LF,".*[`"'].*\s\#.*[`"'].*") ; check for comments and remove
        LF:=SubStr(LF,1,CM-1)
      ; Split line into yaml elements
      If SubStr(LTrim(LF," `t"),1,1)=":"
        return MsgBox("Error: Unexpected character: ':'")
      RegExMatch(LF,"S)^(?<LVL>\s+)?(?<SEQ>-\s)?(?<KEY>`".*`"\s*:\s?|'.*'\s*:\s?|[^:`"'\{\[]+\s*:\s?)?\s*(?<SCA>[\|\>][+-]?)?\s*(?<TYP>!!\w+)?\s*(?<AGET>\*[^\s\t]+)?\s*(?<ASET>&[^\s\t]+)?\s*(?<VAL>`".+`"|'.+'|.+)?\s*$",_),L:=LL:=S(_.LVL),Q:=_.SEQ,K:=_.KEY,S:=_.SCA,T:=SubStr(_.TYP,3),V:=Q(_.VAL),V:= V is "Integer"&&"" V+0=V?V+0:V,VQ:=InStr(".''.`"`".", "." SubStr(LTrim(_.VAL," `t"),1,1) SubStr(RTrim(_.VAL," `t"),-1) ".")
      if L>1{
        if LL=_LL
          L:=_L
        else if LL>_LL
          I[LL]:=L:=_L+1
        else if LL<_LL
          if !I[LL]&&MsgBox("Error, indentation problem: " LF)
            Exit
          else L:=I[LL]
       }
      if Trim(_.Value()," `t")="-" ; empty sequence not cached by previous line
        V:="",Q:="-"
      else if K=""&&V&&!Q ; only a value is catched, convert to key
        K:=V,V:=""
      If !Q&&SubStr(RTrim(K," `t"),-1)!=":" ; not a sequence and key is missing :
        if L>_L&&(D[_L][_K]:=K,LL:=_LL,L:=_L,K:=_K,Q:=_Q,_S:=">")
          continue
        else (MsgBox("Error, invalid key:`n" LF),Exit())
      else if K!="" ; trim key if not empty
        K:=Q(RTrim(K,": "))
      Loop _L ? _L-L : 0 ; remove objects in deeper levels created before
        D[L+A_Index]:=0,I[L+A_Index]:=0
      if !VQ&&!InStr("'`"",_C:=SubStr(LTrim(_.VAL," `t"),1,1)) ; check if value started with a quote and was not closed so next line continues
        _C:=""
      if _L!=L && !D[L] ; object in this level not created yet
        if L=1{ ; first level, use or create main object
          if Y&&Type(Y[Y.Length])!="String"&&((Q&&Type(Y[Y.Length])!="Array")||(!Q&&Type(Y[Y.Length])="Array"))&&MsgBox("Mapping Item and Sequence cannot be defined on the same level:`n" LF) ; trying to create sequence on the same level as key or vice versa
            Exit
          else D[L]:=Y ? (Type(Y[Y.Length])="String"?(Y[Y.Length]:=Q?[]:Map()):Y[Y.Length]) : (Y:=Q?[[]]:[Map()])[1]
        } else if !_Q&&Type(D[L-1][_K])=(Q?"Array":"Object") ; use previous object
          D[L]:=D[L-1][_K]
        else D[L]:=O:=Q?[]:Map(),_A?A[_A]:=O:"",_Q ? D[L-1].Push(O) : D[L-1][_K]:=O,O:="" ; create new object
      _A:="" ; reset alias
      if Q&&K ; Sequence containing a key, create object
        D[L].Push(O:=Map()),D[++L]:=O,Q:=O:="",LL+=1
      If (Q&&Type(D[L])!="Array"||!Q&&Type(D[L])="Array")&&MsgBox("Mapping Item and Sequence cannot be defined on the same level:`n" LF) ; trying to create sequence on the same level as key or vice versa
        Exit
      if T="binary"{ ; !!binary
        O:=BufferAlloc(StrLen(V)//2),PBIN:=O.Ptr
        Loop Parse V
          If (""!=h.=A_LoopField) && !Mod(A_Index,2)
            NumPut("0x" h,PBIN,A_Index/2-1,"UChar"),h:=""
      } else if T="set"&&MsgBox("Error, Tag set is not supported") ; tag !!set is not supported
        Exit 
      else V:=T="int"||T="float"?V+0:T="str"?V "":T="null"?"":T="bool"?(V="true"?true:V="false"?false:V):V ; tags !!int !!float !!str !!null !!bool - else seq map omap ignored
      if _.ASET
        A[_A:=SubStr(_.ASET,2)]:=V
      if _.AGET
        V:=A[SubStr(_.AGET,2)]
      else If !VQ && SubStr(LTrim(V," `t"),1,1)="{" ; create json map object
        O:=Map(),_A?A[_A]:=O:"",P:=(O(O,LP+InStr(LF,V)*2,L))
      else if !VQ && SubStr(LTrim(V," `t"),1,1)="[" ; create json sequence object
        O:=[],_A?A[_A]:=O:"",P:=(A(O,LP+InStr(LF,V)*2,L))
      if Q ; push sequence value into an object
        (V ? D[L].Push(O?O:S?"":V) : 0)
      else D[L][K]:=O?O:D[L].HasOwnProp(K)?D[L][K]:S?"":V ; add key: value into object
      if !Q&&V ; backup yaml elements
        _L:=L,_LL:=LL,O:=_Q:=_K:=_S:=_T:=_V:="" ;_L:=
      else _L:=L,_LL:=LL,_Q:=Q,_K:=K,_S:=S,_T:=T,_V:=V,O:=""
    }
    if Y&&Type(Y[Y.Length])="String"
      Y.Pop()
    return Y
  }
  U(ByRef S,e:=1){ ; UniChar: convert unicode and special characters
    static m:=Map(Ord('"'),'"',Ord("a"),"`a",Ord("b"),"`b",Ord("t"),"`t",Ord("n"),"`n",Ord("v"),"`v",Ord("f"),"`f",Ord("r"),"`r",Ord("e"),Chr(0x1B),Ord("N"),Chr(0x85),Ord("P"),Chr(0x2029),0,"",Ord("L"),Chr(0x2028),Ord("_"),Chr(0xA0))
    Loop Parse S,"\"
      If !((e:=!e)&&A_LoopField=""?v.="\":!e?v.=A_LoopField:0)
        v .= (t:=InStr("ux",SubStr(A_LoopField,1,1)) ? SubStr(A_LoopField,1,RegExMatch(A_LoopField,"^[ux]?([\dA-F]{4})?([\dA-F]{2})?\K")-1) : "")&&RegexMatch(t,"i)^[ux][\da-f]+$") ? Chr(Abs("0x" SubStr(t,2))) SubStr(A_LoopField,RegExMatch(A_LoopField,"^[ux]?([\dA-F]{4})?([\dA-F]{2})?\K")) : m.has(Ord(A_LoopField)) ? m[Ord(A_LoopField)] SubStr(A_LoopField,2) : "\" A_LoopField,e:=A_LoopField=""?e:!e
    return v
  }
  C(ByRef S){ ; CharUni: convert text to unicode notation
    static ascii:=Map("\","\","`a","a","`b","b","`t","t","`n","n","`v","v","`f","f","`r","r",Chr(0x1B),"e","`"","`"",Chr(0x85),"N",Chr(0x2029),"P",Chr(0x2028),"L","","0",Chr(0xA0),"_")
    If !RegexMatch(s,"[\x{007F}-\x{FFFF}]"){ ;!(v:="") && 
      Loop Parse, S
        v .= ascii.Has(A_LoopField) ? "\" ascii[A_LoopField] : A_LoopField
      return v
    }
    Loop Parse, S
      v .= ascii.Has(A_LoopField) ? "\" ascii[A_LoopField] : Ord(A_LoopField)<128 ? A_LoopField : "\u" format("{1:.4X}",Ord(A_LoopField))
    return v
  }
  E(ByRef S, J:=1){ ; EscIfNeed: check if escaping needed and convert to unicode notation
    If S=""
      return '""'
    else if (J<1&&!InStr("IntegerFloat",Type(S)))||RegExMatch(S,"m)[\{\[`"'\r\n]|:\s|,\s|\s#")||RegExMatch(S,"^[\s#\\\-:>]")||RegExMatch(S,"m)\s$")||RegExMatch(S,"m)[\x{7F}-\x{7FFF}]")
      return ("`"" C(S) "`"")
    else return S
  }
  D(O:="",J:=0){ ; dump object to string
    if Type(O)!="Array"||!O.Length||!IsObject(O[1])
      D.= H(O,J)
    else if j<1 {
      for K,V in O
        D.=H(V,J) (j<0?"`n,":",")
      return J<0?"[`n  " StrReplace(RTrim(D,",`n"),"`n","`n  ") "`n]":"[" RTrim(D,",`n") "]"
    } else
      for K,V in O
        D.="---`n" H(V,J) "`n"
    return RTrim(D,",`n")
  }
  H(O:="",J:=0,R:=0,Q:=0){ ; helper: convert object to yaml string
    static M1:="{",M2:="}",S1:="[",S2:="]",N:="`n",C:=",",S:="- ",E:="",K:=":"
    If (t:=type(O))="Array"{
      D:=J<1&&!R?S1:""
      for key, value in O{
        if Type(value)="Buffer"{
          Loop (VAL:="",PTR:=value.Ptr,value.size)
            VAL.=format("{1:.2X}",NumGet(PTR+A_Index-1,"UCHAR"))
          value:="!!binary " VAL,F:=E
        } else
          F:=IsObject(value)?(Type(value)="Array"?"S":"M"):E
		Z:=Type(value)="Array"&&value.Length=0?"[]":((Type(value)="Map"&&value.count=0)||(Type(value)="Object"&&ObjOwnPropCount(value)=0))?"{}":""
        If J<=R
          D.=(J<R*-1?"`n" I(R+2):"") (F?(%F%1 (Z?"":H(value,J,R+1,F)) %F%2):E(value, J)) ((Type(O)="Array"&&O.Length=A_Index) ? E : C)
        else if ((D:=D N I(R+1) S)||1)&&F
            D.= Z?Z:(J<=(R+1)?%F%1:E) H(value,J,R+1,F) (J<=(R+1)?%F%2:E)
        else D .= E(value,J)
      }
    } else {
      D:=J<1&&!R?M1:""
      for key, value in Type(O)="Map"?(Y:=1,O):O.OwnProps(){
        if Type(value)="Buffer"{
          Loop (VAL:="",PTR:=value.Ptr,value.size)
            VAL.=format("{1:.2X}",NumGet(PTR+A_Index-1,"UCHAR"))
          value:="!!binary " VAL,F:=E
        } else
          F:=IsObject(value)?(Type(value)="Array"?"S":"M"):E
		Z:=Type(value)="Array"&&value.Length=0?"[]":((Type(value)="Map"&&value.count=0)||(Type(value)="Object"&&ObjOwnPropCount(value)=0))?"{}":""
        If J<=R
          D.=(J<R*-1?"`n" I(R+2):"") (Q="S"&&A_Index=1?M1:E) (J<1?'"' E(key) '"':E(key)) K (F?(%F%1 (Z?"":H(value,J,R+1,F)) %F%2): E(value,J)) (Q="S"&&A_Index=(Y?O.count:ObjOwnPropCount(O))?M2:E) (J!=0||R?(A_Index=(Y?O.count:ObjOwnPropCount(O))?E:C):E)
        else If ((D:=D N I(R+1) E(key) K)||1)&&F
          D.= Z?Z:(J<=(R+1)?%F%1:E) H(value,J,R+1,F) (J<=(R+1)?%F%2:E)
        else D .= E(value, J)
        If J=0&&!R
          D.= (A_Index<(Y?O.count:ObjOwnPropCount(O))?C:E)
      }
    }
	if J<0&&J<R*-1
	  D.= "`n" I(R+1)
    If R=0
      D:=RegExReplace(D,"^\R+") (J<1?(Type(O)="Array"?S2:M2):"")
    Return D
  }
  S(ByRef s){ ; Convert Spaces to level, 1 = first level
    Loop Parse, (i:=0,s)
      i += (A_LoopField=A_Tab||!Mod(A_index,2)) ? 1 : 0
    Return i + 1
  }
  I(i){ ; Convert level to spaces
    Loop i-1
      s .= "  "
    Return s
  }
  Q(S){ ; UnQuote: remove quotes
    return (t:=SubStr(S:=Trim(S," `t"),1,1) SubStr(S,-1)) = '""' ? (InStr(S,"\")?U(SubStr(S,2,-1)):SubStr(S,2,-1)) : t = "''" ? SubStr(S,2,-1) : S
  }
  O(O,P,L){ ; YamlObject: convert json map 
    static _fun_:=A_PtrSize=8?"SIXJdExED7cBZkWFwHUM60BIg8ECZkWFwHQkZkGD+Ap0IWZBg/gNRA+3QQJ142ZBg/gKdB9Ig8ECZkWFwHXjSInIw4XSdAUx0maJEUiNQQLDMcDDhdJ0BTHAZokBSI1BBMOQkJCQ":"i0QkBIXAdEsPtxBmhdJ1CutBg8ACZoXSdDdmg/oKdCBmg/oND7dQAnXoZoP6CnQmg8ACZoXSdejzw422AAAAAItMJAiFyXQFMdJmiRCDwALD88MxwMOLTCQIhcl0BTHSZokQg8AEw5A=",_sz_,NXTLN,_op_,__:=(DllCall("crypt32\CryptStringToBinary","str",_fun_,"uint",0,"uint",1,"ptr",0,"uint*",_sz_:=0,"ptr",0,"ptr",0),NXTLN:=DllCall("GlobalAlloc","uint",0,"ptr",_sz_,"ptr"),DllCall("VirtualProtect","ptr",NXTLN,"ptr",_sz_,"uint",0x40,"uint*",_op_:=0),DllCall("crypt32\CryptStringToBinary","str",_fun_,"uint",0,"uint",1,"ptr",NXTLN,"uint*",_sz_,"ptr",0,"ptr",0))
    v:=q:=k:=0,key:=val:=lf:=""
    If ""!=c:=Chr(NumGet(p,"UShort"))
    Loop {
      if c="`n"||(c="`r"&&10=NumGet(p+2,"UShort")){
        if (q||k||(!v&&!k)||SubStr(Ltrim(StrGet(p+(c="`n"?2:4))," `t`r`n"),1,1)="}") && P+=c="`n"?2:4
          continue
        else if MsgBox("Error: Malformed inline YAML string: " StrGet(p-6))
          Exit
      } else if !q&&(c=" "||c=A_Tab) && P+=2
        continue
      else if !v&&(c='"'||c="'") && (q:=c,v:=1,P+=2)
        continue
      else if !v&&k&&(c="["||c="{") && (P:=c="[" ? A(O[key]:=[],P+2,L) : O(O[key]:=Map(),P+2,L),key:="",k:=0,1)
        continue
      else if v&&!k&&((!q&&c=":")||(q&&q=c)) && (v:=0,key:=!q && key is "number"&&"" key+0=key?key+0:q?(InStr(key,"\")?U(key):key):Trim(key," `t"),k:=1,q:=0,P+=2)
        continue
      else if v&&k&&((!q&&c=",")||(q&&q=c)) && (v:=0,O[key]:=!q && val is "number"&&"" val+0=val ? val+0 : q ? (InStr(val,"\")?U(val):val) : Trim(val," `t"),val:="",key:="",q:=0,k:=0,P+=2)
        continue
      else if !q&&c="}"&&(k&&v?(O[key]:=val,1):1){
        ;~ if ((tp:=G(P+2,lf))&&(NumGet(P+2,"UShort")=10||NumGet(P+4,"UShort")=10||(nl:=RegExMatch(lf,"^\s+?$"))||RegExMatch(lf,"^\s*[,\}\]]")))
        if ((tp:=DllCall(NXTLN,"PTR",P+2,"Int",false,"PTR"),lf:=StrGet(P+2),tp)&&(NumGet(P+2,"UShort")=0||(nl:=RegExMatch(lf,"^\s+?$"))||RegExMatch(lf,"^\s*[,\}\]]")))
          return nl?DllCall(NXTLN,"PTR",P+2,"Int",true,"PTR"):P+4
        else if !tp
          return DllCall(NXTLN,"PTR",P+4,"Int",false,"PTR")
        else if MsgBox("Error: Malformed inline YAML string: " StrGet(p))
          Exit
      } else if !v&&(c=","||c=":"||c=" "||c="`t")&&P+=2
        continue
      else if !v&& (!k ? (key:=c) : val:=c,v:=1,P+=2)
        continue
      else if v&& (!k ? (key.=c) : val.=c,P+=2)
        continue
      else if MsgBox("Error undefined")
        Exit 
    } Until(""=c:=Chr(NumGet(p,"UShort")))
    return P
    ;~ MsgBox("Error: unexpected end of YAML string: " StrGet(p))
    ;~ Exit
  }
  A(O,P,L){ ; YamlArray: convert json sequence
    static _fun_:=A_PtrSize=8?"SIXJdExED7cBZkWFwHUM60BIg8ECZkWFwHQkZkGD+Ap0IWZBg/gNRA+3QQJ142ZBg/gKdB9Ig8ECZkWFwHXjSInIw4XSdAUx0maJEUiNQQLDMcDDhdJ0BTHAZokBSI1BBMOQkJCQ":"i0QkBIXAdEsPtxBmhdJ1CutBg8ACZoXSdDdmg/oKdCBmg/oND7dQAnXoZoP6CnQmg8ACZoXSdejzw422AAAAAItMJAiFyXQFMdJmiRCDwALD88MxwMOLTCQIhcl0BTHSZokQg8AEw5A=",_sz_,NXTLN,_op_,__:=(DllCall("crypt32\CryptStringToBinary","str",_fun_,"uint",0,"uint",1,"ptr",0,"uint*",_sz_:=0,"ptr",0,"ptr",0),NXTLN:=DllCall("GlobalAlloc","uint",0,"ptr",_sz_,"ptr"),DllCall("VirtualProtect","ptr",NXTLN,"ptr",_sz_,"uint",0x40,"uint*",_op_:=0),DllCall("crypt32\CryptStringToBinary","str",_fun_,"uint",0,"uint",1,"ptr",NXTLN,"uint*",_sz_,"ptr",0,"ptr",0))
    v:=q:=c:=0,lf:=""
    If ""!=c:=Chr(NumGet(p,"UShort"))
    Loop {
      if c="`n"||(c="`r"&&10=NumGet(p+2,"UShort")){
        if (q||!v||SubStr(Ltrim(StrGet(p+(c="`n"?2:4))," `t`r`n"),1,1)="]") && P+=c="`n"?2:4
          continue
        else if MsgBox("Error: Malformed inline YAML string: " s "`n" StrGet(p-6))
          Exit
      } else if !q&&(c=" "||c=A_Tab) && P+=2
        continue
      else if !v&&(c='"'||c="'") && (q:=c,v:=1,P+=2)
        continue
      else if !v&&(c="["||c="{") && (P:=c="[" ? A((O.Push(lf:=[]),lf),P+2,L) : O((O.Push(lf:=Map()),lf),P+2,L),lf:="",1)
        continue
      else if v&&((!q&&c=",")||(q&&c=q)) && (v:=0,O.Push(!q && lf is "number"&&"" lf+0=lf ? lf+0 : q ? (InStr(lf,"\")?U(lf):lf) : Trim(lf," `t")),q:=0,lf:="",P+=2)
        continue
      else if !q&&c="]"&&(v?(O.Push(Trim(lf," `t")),1):1){
        ;~ if ((tp:=G(P+2,lf))&&(NumGet(P+2,"UShort")=10||NumGet(P+4,"UShort")=10||(nl:=RegExMatch(lf,"^\s+?$"))||RegExMatch(lf,"^\s*[,\}\]]")))
        if ((tp:=DllCall(NXTLN,"PTR",P+2,"Int",false,"PTR"),lf:=StrGet(P+2),tp)&&(NumGet(P+2,"UShort")=0||(nl:=RegExMatch(lf,"^\s+?$"))||RegExMatch(lf,"^\s*[,\}\]]")))
          return nl?DllCall(NXTLN,"PTR",P+2,"Int",true,"PTR"):P+4
        else if !tp
          return DllCall(NXTLN,"PTR",P+4,"Int",false,"PTR")
        else if MsgBox("Error: Malformed inline YAML string: " StrGet(p))
          Exit
      } else if !v&&(c=","||c=" "||c="`t")&&P+=2 ;InStr(", `t",c)
        continue
      else if !v&& (lf.=c,v:=1,P+=2)
        continue
      else if v&& (lf.=c,P+=2)
        continue
      else if MsgBox("Error undefined")
        Exit
    } Until(""=c:=Chr(NumGet(p,"UShort")))
    return P
    ;~ MsgBox("Error: unexpected end of YAML string: " StrGet(p))
    ;~ Exit
  }
  J(ByRef S,Y){ ; PureJSON: convert pure JSON Object
    D:=[C:=(A:=InStr(S,"[")=1)?[]:Map()],S:=LTrim(SubStr(S,2)," `t`r`n"),L:=1,N:=0,V:=K:="",Y?(Y.Push(C),J:=Y):J:=[C],!(Q:=InStr(S,'"')!=1)?S:=LTrim(S,'"'):""
    Loop Parse, S, '"' {
      Q:=NQ?1:!Q
      NQ:=Q&&(SubStr(A_LoopField,-3)="\\\"||(SubStr(A_LoopField,-1)="\"&&SubStr(A_LoopField,-2)!="\\"))
      if !Q {
        If (t:=Trim(A_LoopField," `t`r`n"))=","||(t=":"&&V:=1)
          continue
        else If t&&(InStr("{[]},:",SubStr(t,1,1)) || RegExMatch(t,"^\d*\s*[,\]\}]")){
          Loop Parse, t {
            if N&&N--
              continue
            If InStr("`n`r `t",A_LoopField)
              continue
            else If InStr("{[",A_LoopField){
              if !A&&!V
                return MsgBox("Error: Malformed JSON - missing key: " t)
              C:=A_LoopField="["?[]:Map(),A?D[L].Push(C):D[L][K]:=C,D.Has(++L)?D[L]:=C:D.Push(C),V:="",A:=Type(C)="Array"
              continue
            } else if InStr("]}",A_LoopField){
              If !A&&V
                return MsgBox("Error: Malformed JSON - missing value: " t)
              else if L=0
                return MsgBox("Error: Malformed JSON - to many closing bracket: " t)
              else C:=--L=0?"":D[L],A:=Type(C)="Array"
            } else if !(InStr(" `t`r,",A_LoopField)||(A_LoopField=":"&&V:=1)){
              If RegExMatch(SubStr(t,A_Index),"m)^(null|false|true|-?\d+\.?\d*)\s*[,}\]\r\n]",R)&&(N:=R.Len(0)-2,R:=R.1,1){
                if A
                  C.Push(R="null"?"":R="true"?true:R="false"?false:"" R+0=R?R+0:R)
                else if V
                  C[K]:=R="null"?"":R="true"?true:R="false"?false:"" R+0=R?R+0:R,K:=V:=""
                else
                  return MsgBox("Error: Malformed JSON - missing key in: " t)
              } else
                return MsgBox("Error: Malformed JSON - unrecognized character: " A_LoopField " in " t)
            }
          }
        }
      } else if NQ&&(P.=A_LoopField '"',1)
        continue
      else if A
        LF:=P A_LoopField,C.Push(LF~="^(?!0)-?\d+\.?\d*$"&&"" LF+0=LF?LF+0:InStr(LF,"\")?U(LF):LF),P:=""
      else if V
        LF:=P A_LoopField,C[K]:=LF~="^(?!0)-?\d+\.?\d*$"&&"" LF+0=LF?LF+0:InStr(LF,"\")?U(LF):LF,K:=V:=P:=""
      else
        LF:=P A_LoopField,K:=LF~="^(?!0)-?\d+\.?\d*$"&&"" LF+0=LF?LF+0:InStr(LF,"\")?U(LF):LF,P:=""
    }
    return J[1]
  }
}