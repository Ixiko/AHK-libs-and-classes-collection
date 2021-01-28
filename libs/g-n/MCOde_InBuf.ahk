; Link:   	https://autohotkey.com/board/topic/23627-machine-code-binary-buffer-searching-regardless-of-null/
; Author:
; Date:
; for:     	AHK_L

/*

   Offset := InBuf( &Buffer, &sought, 10000, 100)
   Offset := InBufRev( &Buffer, &sought, 10000, 100, 5000)

   Offset := InBuf[b]Str[/b]Rev( &Buffer, "ImmediateString", 10000, -1)
   Offset := InBuf[b]Str[/b]( &Buffer, StringVar, 10000, StartOffset)
   Offset := InBuf[b]Str[/b]( &Buffer, StringVar, 10000000)
   ifNotEqual, Offset, -1
      Text := substrBuf( &buffer+Offset)
   ifNotEqual, Offset, -1
      Text := substrBuf( &buffer+Offset1, Offset2-Offset1)

*/

substrBufZ(bufAddr, Length="") {
   ;substrBuf - extract a string of specified length from a binary buffer
   ;         usage: stringVar:=substrBuf( &buf+Offset, 100 )
   ;         the Length is optional, if none specified then NULL-terminated string is extracted
   ;         be accurate in order to not exceed the buf bounds, if no NULL is there
   IfEqual,Length,
      Length:=dllCall("lstrlen","uint",bufAddr)
   VarSetCapacity(result,Length)
   DllCall("RtlMoveMemory", "str",result, "uint", bufAddr, "uint",Length)
   return result
}

substrBuf(bufAddr, Length) {
   ;substrBuf - extract a string of specified length from a binary buffer
   ;         usage: stringVar:=substrBuf( &buf+Offset, 100 )
   VarSetCapacity(result,Length)
   DllCall("RtlMoveMemory", "str",result, "uint", bufAddr, "uint",Length)
   return result
}

InBufStr(haystackAddr, needleStr, haystackSize, StartOffset=0){
   ;InBufStr - look for string Needle in binary Buffer
   ;         0-based (-1 = not found), case-sensitive.
return InBuf(haystackAddr, &needleStr, haystackSize, strlen(needleStr))
}

InBufStrRev(haystackAddr, needleStr, haystackSize, StartOffsetOfLastNeedleByte=-1){
   ;InBufStrRev - reverse look for string Needle in binary Buffer
   ;         0-based (-1 = not found), case-sensitive.
   ;         StartOffsetOfLastNeedleByte - maximum hayStack offset to contain Needle's bytes (-1=whole haystackSize)
return InBufRev(haystackAddr, &needleStr, haystackSize, strlen(needleStr), StartOffsetOfLastNeedleByte)
}

InBuf(haystackAddr, needleAddr, haystackSize, needleSize, StartOffset=0) {
   Static fun
   IfEqual,fun,
   {
      h=
      ( LTrim join
         5589E583EC0C53515256579C8B5D1483FB000F8EC20000008B4D108B451829C129D9410F8E
         B10000008B7D0801C78B750C31C0FCAC4B742A4B742D4B74364B74144B753F93AD93F2AE0F
         858B000000391F75F4EB754EADF2AE757F3947FF75F7EB68F2AE7574EB628A26F2AE756C38
         2775F8EB569366AD93F2AE755E66391F75F7EB474E43AD8975FC89DAC1EB02895DF483E203
         8955F887DF87D187FB87CAF2AE75373947FF75F789FB89CA83C7038B75FC8B4DF485C97404
         F3A775DE8B4DF885C97404F3A675D389DF4F89F82B45089D5F5E5A595BC9C2140031C0F7D0EBF0
      )
      VarSetCapacity(fun,StrLen(h)//2)
      Loop % StrLen(h)//2
         NumPut("0x" . SubStr(h,2*A_Index-1,2), fun, A_Index-1, "Char")
   }
   Return DllCall(&fun
      , "uint",haystackAddr, "uint",needleAddr
      , "uint",haystackSize, "uint",needleSize
      , "uint",StartOffset)
}

InBufRev(haystackAddr, needleAddr, haystackSize, needleSize, StartOffsetOfLastNeedleByte=-1) {
   Static fun
   IfEqual,fun,
   {
      h=
      ( LTrim join
         5589E583EC0C53515256579C8B5D1483FB000F8EDE0000008B4510488B4D1883F9FF0F44
         C839C80F4CC829D989CF410F8EC1000000037D088B750C83E000FCAC4B74224B742A4B74
         354B74434B754E93AD93FDF2AE0F859B000000395F0275F3E981000000FDF2AE0F858800
         0000EB76FD8A26F2AE757F38670275F7EB689366AD93FDF2AE756F66395F0275F6EB574E
         ADFDF2AE756039470175F7EB494E43AD8975FC89DAC1EB02895DF483E2038955F887DF87
         D1FD87FB87CAF2AE753839470175F7FC89FB89CA83C7058B75FC8B4DF485C97404F3A775
         DC8B4DF885C97404F3A675D189DF4789F82B45089D5F5E5A595BC9C2140031C0F7D0EBF0
      )
      VarSetCapacity(fun,StrLen(h)//2)
      Loop % StrLen(h)//2
      NumPut("0x" . SubStr(h,2*A_Index-1,2), fun, A_Index-1, "Char")
   }
   return DllCall(&fun
      , "uint",haystackAddr, "uint",needleAddr
      , "uint",haystackSize, "uint",needleSize
      , "uint",StartOffsetOfLastNeedleByte)
}