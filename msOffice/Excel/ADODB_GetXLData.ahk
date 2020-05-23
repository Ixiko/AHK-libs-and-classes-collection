;GXD_Base := A_ScriptDir . "\SampleData.xls" 
;GXD_Sheet := "Sheet1"
;clipboard := GetXLData(GXD_Base, GXD_Sheet,, "Units", "BETWEEN", 20, "AND",,, 50)
;clipboard := GetXLData(GXD_Base, GXD_Sheet, "Region,Rep,Unit Cost,", "Units", "BETWEEN", "20", "AND",,, 60)
;clipboard := GetXLData(GXD_Base, GXD_Sheet,, "Units", "BETWEEN", 30, "AND",,, 50)
;clipboard := GetXLData(GXD_Base, GXD_Sheet,, "Units", "IN", "(50, 60, 90)")
;clipboard := GetXLData(GXD_Base, GXD_Sheet,, "Units", ">", 90)
;clipboard := GetXLData(GXD_Base, GXD_Sheet, "Region, Rep,Unit Cost,", "Units", "BETWEEN", 30, "AND",,, 60)
;clipboard := GetXLData(GXD_Base, GXD_Sheet, "Region, Rep,Unit Cost,", "Region", "=", "Quebec", "AND", "Rep", "=", "Jones")
;clipboard := GetXLData(GXD_Base, GXD_Sheet, "Region, Rep,Unit Cost,", "Units", "LIKE", "3%")

GetXLData(GXD_Base, GXD_Sheet, GXD_ColsToGet = "*", GXD_ColToVerif1 = "", GXD_Filtre1 = "", GXD_ValToComp1 = "", GXD_Link = "", GXD_ColToVerif2 = "", GXD_Filtre2 = "", GXD_ValToComp2 = "") {
   
   adOpenStatic = 3
   adLockOptimistic = 3
   adCmdText = 1
   adApproxPosition := 0x4000

   GXD_Sheet := GXD_Sheet . "$"

   If (GXD_ColsToGet != "*")
   {
      GXD_LColsToGet := StrLen(GXD_ColsToGet)
      If SubStr(GXD_ColsToGet, StrLen(GXD_ColsToGet), 1) = ","
         GXD_ColsToGet := SubStr(GXD_ColsToGet, 1, StrLen(GXD_ColsToGet) - 1)
      If InStr(GXD_ColsToGet, ",")
      {
         If InStr(GXD_ColsToGet, ", ")
            StringReplace, GXD_ColsToGet, GXD_ColsToGet, `,%A_SPACE%, `,, All
         StringSplit, GXD_ColsContent, GXD_ColsToGet, `,]
         Loop, %GXD_ColsContent0%
         {
            If InStr(GXD_ColsContent%A_Index%, A_Space)
               GXD_ColsContent%A_Index% := "``" . GXD_ColsContent%A_Index% . "``"
            GXD_ColsContent := GXD_ColsContent . GXD_ColsContent%A_Index% . ", "
         }
      }
      GXD_ColsToGet := GXD_ColsContent
      If SubStr(GXD_ColsToGet, StrLen(GXD_ColsToGet)-1, 2) = ", "
         GXD_ColsToGet := SubStr(GXD_ColsToGet, 1, StrLen(GXD_ColsToGet) - 2)
   }

   Loop, 2
   {
      If GXD_ColToVerif%A_Index%
      {
         If InStr(GXD_ColToVerif%A_Index%, A_Space)
            GXD_ColToVerif%A_Index% := "``" . GXD_ColToVerif%A_Index% . "``"
      }
      If GXD_ValToComp%A_Index%
      {
         If (InStr(GXD_ValToComp%A_Index%, "%") or InStr(GXD_ValToComp%A_Index%, "_") or InStr(GXD_ValToComp%A_Index%, "-") or InStr(GXD_ValToComp%A_Index%, "!") or InStr(GXD_ValToComp%A_Index%, "[") or InStr(GXD_ValToComp%A_Index%, "]"))
            GXD_ValToComp%A_Index% := "'" . GXD_ValToComp%A_Index% . "'"
         If GXD_ValToComp%A_Index% is alpha
            GXD_ValToComp%A_Index% := "'" . GXD_ValToComp%A_Index% . "'"
      }
   }

   If (GXD_ColToVerif1 and GXD_ValToComp2 and GXD_ColToVerif2 and GXD_Filtre2)
      Request := "SELECT " . GXD_ColsToGet . " FROM [" . GXD_Sheet . "]" . " WHERE " . GXD_ColToVerif1 . " " . GXD_Filtre1 . " " . GXD_ValToComp1 . " " . GXD_Link . " " . GXD_ColToVerif2 . " " . GXD_Filtre2 . " " . GXD_ValToComp2

   If (GXD_ColToVerif1 and GXD_ValToComp2 and !GXD_ColToVerif2 and !GXD_Filtre2)
      Request := "SELECT " . GXD_ColsToGet . " FROM [" . GXD_Sheet . "]" . " WHERE " . GXD_ColToVerif1 . " " . GXD_Filtre1 . " " . GXD_ValToComp1 . " " . GXD_Link . " " . GXD_ValToComp2

   If (GXD_ColToVerif1 and !GXD_ValToComp2 and !GXD_ColToVerif2 and !GXD_Filtre2)
      Request := "SELECT " . GXD_ColsToGet . " FROM [" . GXD_Sheet . "]" . " WHERE " . GXD_ColToVerif1 . " " . GXD_Filtre1 . " " . GXD_ValToComp1

   If (!GXD_ColToVerif1 and !GXD_ValToComp2 and !GXD_ColToVerif2 and !GXD_Filtre2)
      Request := "SELECT " . GXD_ColsToGet . " FROM [" . GXD_Sheet . "]"

   objConnection := ComObjCreate("ADODB.Connection")
   objRecordSet := ComObjCreate("ADODB.Recordset")
   objConnection.Open("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" . GXD_Base . ";Extended Properties=""Excel 8.0;HDR=Yes;"";")
   objRecordSet.Open(Request, objConnection, adOpenStatic, adLockOptimistic, adCmdText)

   GXD_NumRec := objRecordSet.RecordCount
   GXD_pFields := objRecordSet.Fields
   GXD_NumFiels := GXD_pFields.Count

   Loop %GXD_NumRec%
   {
      Loop %GXD_NumFiels%
      {
         If A_Index < %GXD_NumFiels%
            GXD_Records := GXD_Records . GXD_pFields.Item(A_Index-1).Value . ";"
         Else
            GXD_Records := GXD_Records . GXD_pFields.Item(A_Index-1).Value
      }
      If A_Index < %GXD_NumRec%
         GXD_Records := GXD_Records . "|"
      objRecordSet.MoveNext
   } 

   objRecordSet.Close()
   objConnection.Close()
   objRecordSet := ""
   objConnection := ""   
   
   Return GXD_Records
}
