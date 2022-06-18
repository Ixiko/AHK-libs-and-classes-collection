; Title:   	Search optimisation
; Link:       https://www.autohotkey.com/boards/viewtopic.php?f=76&t=90171&sid=20e96800f4b110683a5724a50a46cbf3
; Author:   teadrinker
; Date:     May-04-2021
; for:     	AHK_L

/*

   SetBatchLines, -1

   filePath := A_ScriptDir "\fb_tools.7z"
   bytes := "ee ff"

   size := RawReadFile(filePath, buff)
   len := CryptStringToBinary(bytes, needle, "CRYPT_STRING_HEX")
   start := A_TickCount
   offsets := SearchInBuff(&buff, size, &needle, len)
   MsgBox,, % A_TickCount - start . "ms", % "filesize: " size "`n`noffsets:`n" offsets

*/


SearchInBuff(pHaystack, hstkSize, pNeedle, needleSize) {
   arr := GetMax(pNeedle, needleSize)
   maxByte := arr.max, offset := arr.maxIdx
   prevByte := arr.prevMax, prevByteShift := arr.prevMaxIdx - offset
   bool := needleSize > 1
   found := "", addr := pHaystack + offset - 1, maxAddr := addr + hstkSize - needleSize + 1
   while addr := DllCall("msvcrt\memchr", "Ptr", addr + 1, "Int", maxByte, "Ptr", maxAddr - addr, "Cdecl Ptr") {
      ( (bool ? NumGet(addr + prevByteShift, "UChar") = prevByte : true)
        && DllCall("msvcrt\memcmp", "Ptr", addr - offset, "Ptr", pNeedle, "Ptr", needleSize, "Cdecl") = 0
        && found .= Format("{:#x}", addr - offset - pHaystack) . "`n" )
   }
   Return RTrim(found, "`n")
}

RawReadFile(filePath, ByRef buff) {
   File := FileOpen(filePath, "r")
   File.Pos := 0
   File.RawRead(buff, size := File.Length)
   File.Close()
   Return size
}

CryptStringToBinary(string, ByRef outData, formatName := "CRYPT_STRING_BASE64") {
   static formats := { CRYPT_STRING_BASE64: 0x1
                     , CRYPT_STRING_HEX:    0x4
                     , CRYPT_STRING_HEXRAW: 0xC }
   fmt := formats[formatName]
   chars := StrLen(string)
   if !DllCall("Crypt32\CryptStringToBinary", "Str", string, "UInt", chars, "UInt", fmt
                                            , "Ptr", 0, "UIntP", bytes, "UIntP", 0, "UIntP", 0)
      throw "CryptStringToBinary failed. LastError: " . A_LastError
   VarSetCapacity(outData, bytes)
   DllCall("Crypt32\CryptStringToBinary", "Str", string, "UInt", chars, "UInt", fmt
                                        , "Str", outData, "UIntP", bytes, "UIntP", 0, "UIntP", 0)
   Return bytes
}

GetMax(pData, len) {
   VarSetCapacity(sortedData, len, 0)
   DllCall("RtlMoveMemory", "Ptr", &sortedData, "Ptr", pData, "Ptr", len)
   pCmp := RegisterCallback("cmp", "C F", 2)
   DllCall("msvcrt\qsort", "Ptr", &sortedData, "Ptr", len, "Ptr", 1, "Ptr", pCmp, "Cdecl")
   max := NumGet(sortedData, "UChar"), (len > 1 && prevMax := NumGet(sortedData, 1, "UChar"))
   Loop % len {
      i := A_Index - 1
      res := NumGet(pData + i, "UChar")
     (res = max && maxIdx := i)
     (res = prevMax && prevMaxIdx := i)
   }
   Return {max: max, maxIdx: maxIdx, prevMax: prevMax, prevMaxIdx: prevMaxIdx}
}

cmp(a, b) {
   a := NumGet(a + 0, "UChar"), b := NumGet(b + 0, "UChar")
   Return a < b ? 1 : a > b ? -1 : 0
}

