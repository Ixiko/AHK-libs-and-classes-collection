; Link:   	https://autohotkey.com/board/topic/27374-com-invokedeep-climb-a-com-tree-more-easily/
; Author:
; Date:
; for:     	AHK_L

/*


*/

; Usage:
;   res := COM_InvokeDeep(res, dotted-path, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
; Example:
;   pBody2 := COM_InvokeDeep(pweb, "document.frames[1].document.body")
;   (returns pointer to the body portion of the HTML document located in the second frame on the
;   loaded web page, where pweb is a pointer to the parent IID_IHTMLWindow2.
COM_InvokeDeep(obj, path, arg1="vT_NoNe", arg2="vT_NoNe", arg3="vT_NoNe", arg4="vT_NoNe", arg5="vT_NoNe", arg6="vT_NoNe", arg7="vT_NoNe", arg8="vT_NoNe"){
   res := obj
   COM_AddRef(res) ; compensate for loop's Release()
   PathCt := 0
   Loop, Parse, Path, .
   {
	  PathCt++
   }
   Loop, Parse, Path, ., ]
   {
      prop := A_LoopField
      value =
      StringGetPos, i, A_LoopField, [
      IfEqual, ErrorLevel, 0 ; contains index
      {
         StringLeft, prop, A_LoopField, %i%
         StringMid, value, A_LoopField, % i+2
      }
      If (value != "") ; contains index or parameter passed to a method, enclosed in "[]"
      {
         If (prop = "item") or (RegExMatch(value, "^[0-9]+$") = false) ; "item" already specified, or method call
         {
            If (A_Index < PathCt)
               propobj := COM_Invoke(res, prop, value)
            Else
               propobj := COM_Invoke(res, prop, value, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
            COM_Release(res),	VarSetCapacity(res,		0)
            res := propobj
         }
         Else
         {
            propobj := COM_Invoke(res, prop)
            If (A_Index < PathCt)
               itemobj := COM_Invoke(propobj, "Item", value)
            Else
               itemobj := COM_Invoke(propobj, "Item", value, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
            COM_Release(res),	VarSetCapacity(res,		0)
            COM_Release(propobj),	VarSetCapacity(propobj,		0)
            res := itemobj
         }
      }
      Else
      {
         If (A_Index < PathCt)
            propobj := COM_Invoke(res, prop)
         Else
         {
			sParams	:= 12345678
			int:=False
			Loop,	Parse,	sParams
				If	arg%A_LoopField% is Integer
				{
					int:=true
					Break
				}
			If int
			{
				Loop,	Parse,	sParams
				{
						If	(arg%A_LoopField% == "vT_NoNe")
						{
							arg%A_LoopField% := ""
							VT_BSTR%A_LoopField%:=""
						}
						Else
							VT_BSTR%A_LoopField%:=8
				}
				propobj := COM_Invoke_(res, prop, VT_BSTR1,arg1,VT_BSTR2,arg2, VT_BSTR3,arg3, VT_BSTR4,arg4, VT_BSTR5,arg5, VT_BSTR6,arg6, VT_BSTR7,arg7, VT_BSTR8,arg8)
			}
			Else
				propobj := COM_Invoke(res, prop, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
		 }
         COM_Release(res),	VarSetCapacity(res,		0)
         res := propobj
      }
      if !res ; no sense in continuing - object not found (returns 0 or null)
         break
   }
   Return res
}