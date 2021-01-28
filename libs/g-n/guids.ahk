; Type 0uid, 1uid or ruid (random guid) to expand
:*:0uid::00000000-0000-0000-0000-000000000000
:*:1uid::11111111-1111-1111-1111-111111111111
:*:ruid::
Send % GUID()
return



; Create a random GUID in
; Sql Server: NEWID()
; Oracle: sys_guid()
; MySql: UUID()
; Postgres: uuid_generate_v4()
; MongoDb: UUID()



; ijprest/guidgen.ahk
; https://gist.github.com/ijprest/3845947
GUID()
{
   format = %A_FormatInteger%       ; save original integer format
   SetFormat Integer, Hex           ; for converting bytes to hex
   VarSetCapacity(A,16)
   DllCall("rpcrt4\UuidCreate","Str",A)
   Address := &A
   Loop 16
   {
      x := 256 + *Address           ; get byte in hex, set 17th bit
      StringTrimLeft x, x, 3        ; remove 0x1
      h = %x%%h%                    ; in memory: LS byte first
      Address++
   }
   SetFormat Integer, %format%      ; restore original format
   h := SubStr(h,1,8) . "-" . SubStr(h,9,4) . "-" . SubStr(h,13,4) . "-" . SubStr(h,17,4) . "-" . SubStr(h,21,12)
   return h
}
