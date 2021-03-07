; Title:
; Link:   	https://github.com/acmeism/RosettaCodeData/blob/master/Task/Enforced-immutability/AutoHotkey/enforced-immutability.ahk
; Author:
; Date:
; for:     	AHK_L

/*

   MyData := new FinalBox("Immutable data")
   MsgBox % "MyData.Data = " MyData.Data
   MyData.Data := "This will fail to set"
   MsgBox % "MyData.Data = " MyData.Data

*/


Class FinalBox {
   __New(FinalValue) {
      ObjInsert(this, "proxy",{Data:FinalValue})
   }
; override the built-in methods:
   __Get(k) {
      return, this["proxy",k]
   }
   __Set(p*) {
      return
   }
   Insert(p*) {
      return
   }
   Remove(p*) {
      return
   }
}