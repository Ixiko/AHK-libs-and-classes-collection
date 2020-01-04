; ----------------------------------------------------------------------------------------------------------------------
; Name .........: Bin library
; Description ..: This library is a collection of functions that deal with binary data and numbers.
; AHK Version ..: AHK_L 1.1.13.01 x32/64 ANSI/Unicode
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Jan. 21, 2015 - v0.1   - First version.
; ..............: Jan. 22, 2015 - v0.1.1 - Moved Bin_GetBitmap in a separated library (BinGet).
; ..............: Feb. 20, 2016 - v0.1.2 - Added Bin_BytesView function.
; ..............: Feb. 28, 2016 - v0.1.3 - Added Bin_ToBits and Bin_FromBits functions.
; ..............: Mar. 01, 2016 - v0.1.4 - Modified Bin_ToHex and Bin_CryptToString parameters to accept the buffer
; ..............:                          address instead of the buffer reference itself. Size is now compulsory.
; ----------------------------------------------------------------------------------------------------------------------

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: Bin_ToHex
; Description ..: Convert a binary buffer to a RAW hexadecimal string.
; Parameters ...: sHex    - ByRef variable that will receive the buffer as hexadecimal string.
; ..............: nAdrBuf - Address of the buffer.
; ..............: nSzBuf  - Size of the buffer.
; Return .......: String length.
; ----------------------------------------------------------------------------------------------------------------------
Bin_ToHex(ByRef sHex, nAdrBuf, nSzBuf)
{
    VarSetCapacity(sHex, nSzBuf*4+32, 0) ; Try to avoid dynamic reallocation, 1 byte  -> max 4 chars (0x12).
    f := A_FormatInteger
    SetFormat, Integer, Hex
    Loop %nSzBuf%
        sHex .= *nAdrBuf++
    SetFormat, Integer, %f%
    sHex := RegExReplace(sHex, "S)x(?=.0x|.$)|0x(?=..0x|..$)")
    Return StrLen(sHex)
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: Bin_FromHex
; Description ..: Convert a RAW hexadecimal string to binary data.
; Parameters ...: cBuf - Variable that will receive the binary data.
; ..............: sHex - Hexadecimal string to be converted.
; Return .......: Buffer size.
; ----------------------------------------------------------------------------------------------------------------------
Bin_FromHex(ByRef cBuf, ByRef sHex)
{
    VarSetCapacity(cBuf, nSzBuf:=StrLen(sHex)//2, 0)
    Loop %nSzBuf%
        NumPut("0x" SubStr(sHex, 2*A_Index-1, 2), cBuf, A_Index-1, "UChar")
    Return nSzBuf
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: Bin_CryptToString
; Description ..: Convert a binary buffer to a string, using the CryptBinaryToString system function. Default to hex.
; Parameters ...: sStr    - ByRef variable that will receive the buffer as a string.
; ..............: nAdrBuf - Address of the buffer.
; ..............: nSzBuf  - Size of the buffer.
; ..............: nFlags  - Flags for the CryptBinaryToString function: http://goo.gl/huxbgT.
; Return .......: String length.
; Remarks ......: The default flag value of 0x4 return a string with a ending CRLF. So final length is 2 bytes bigger.
; ----------------------------------------------------------------------------------------------------------------------
Bin_CryptToString(ByRef sStr, nAdrBuf, nSzBuf, nFlags:=0x4)
{
    DllCall( "Crypt32.dll\CryptBinaryToString", Ptr,nAdrBuf, UInt,nSzBuf, UInt,nFlags, Ptr,0, UIntP,nLen )
    VarSetCapacity(cHex, nLen*(A_IsUnicode ? 2 : 1), 0)
    DllCall( "Crypt32.dll\CryptBinaryToString", Ptr,nAdrBuf, UInt,nSzBuf, UInt,nFlags, Ptr,&cHex, UIntP,nLen )
    sStr := StrGet(&cHex, nLen, (A_IsUnicode ? "UTF-16" : "CP0")), cHex := ""
    Return nLen
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: Bin_CryptFromString
; Description ..: Convert a string to binary data. Default from hex.
; Parameters ...: cBuf   - Variable that will receive the binary data.
; ..............: sStr   - String to be converted.
; ..............: nFlags - Flags for the CryptStringToBinary function: http://goo.gl/FsgBwI.
; Return .......: Buffer size.
; ----------------------------------------------------------------------------------------------------------------------
Bin_CryptFromString(ByRef cBuf, ByRef sStr, nFlags:=0x4)
{
    DllCall( "Crypt32.dll\CryptStringToBinary", Ptr,&sStr, UInt,StrLen(sStr), UInt,nFlags
                                              , Ptr,0, UIntP,nSzBuf, Ptr,0, Ptr,0 )
    VarSetCapacity(cBuf, nSzBuf)
    DllCall( "Crypt32.dll\CryptStringToBinary", Ptr,&sStr, UInt,StrLen(sStr), UInt,nFlags
                                              , Ptr,&cBuf, UIntP,nSzBuf, Ptr,0, Ptr,0 )
    Return nSzBuf
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: Bin_ToBits
; Description ..: Convert a integer to its binary string representation in bits.
; Parameters ...: nInt  - Integer to be converted.
; ..............: nBits - Number of bits to use.
; Return .......: String containing the binary representation of the integer in bits.
; ----------------------------------------------------------------------------------------------------------------------
Bin_ToBits(nInt, nBits:=32)
{
    Loop %nBits%
        sBin := nInt & 1 sBin, nInt := nInt >> 1
    Return sBin
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: Bin_FromBits
; Description ..: Convert a binary string of bits to a integer.
; Parameters ...: sBin - String containing the binary representation of the integer in bits.
; Return .......: Converted integer.
; ----------------------------------------------------------------------------------------------------------------------
Bin_FromBits(sBin)
{
    Loop % (nLen := StrLen(sBin))
        nInt += ( (nBit := SubStr(sBin, nLen-(A_Index-1), 1)) == 1 ) ? 1 << A_Index-1 : 0
    Return nInt
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: Bin_BytesView
; Description ..: Show a bytes view of a buffer.
; Parameters ...: nAdrBuf - Address of the buffer.
; ..............: nSzBuf  - Size of the buffer.
; ..............: nCols   - How many column to show in the view. Must be multiple of 8 and >= 8.
; ..............: nRows   - How many rows to show in the view before the scrolling bar will appear.
; ..............: sFormat - Format of the offset: "u" for unsigned decimal int, "X" for unsigned hexadecimal int.
; ..............: nSpaces - How many spaces between bytes in the view. Must be > 0.
; ----------------------------------------------------------------------------------------------------------------------
Bin_BytesView(nAdrBuf, nSzBuf, nCols:=16, nRows:=20, sFormat:="u", nSpaces:=3)
{
    Static IMAGE_ICON       := 1
         , SB_VERT          := 1
         , SB_THUMBPOSITION := 4
         , CRYPT_STRING_HEX := 0x0004
         , WM_SETICON       := 0x0080
         , WM_KEYUP         := 0x0101
         , WM_COMMAND       := 0x0111
         , WM_VSCROLL       := 0x0115
         , WM_LBUTTONUP     := 0x0202
         , EM_GETSEL        := 0x00B0
         , EM_LINELENGTH    := 0x00C1
         , EM_SETLIMITTEXT  := 0x00C5
         , EN_VSCROLL       := 0x0602
         , hEdit1, hEdit2, sOfftFormat, nByteLen, nHdrCols, nRowLen
         , cbSubclassProc := RegisterCallback("Bin_BytesView",, 6)
         
    If ( sFormat == hEdit2 )
    {   ; Subclass call to catch scrollbar thumb scrolling and calculate offset.
        If ( nSzBuf == WM_VSCROLL )
            DllCall( "PostMessage", Ptr,hEdit1, UInt,WM_VSCROLL, Ptr,nCols, Ptr,nRows )
        If ( nSzBuf == WM_LBUTTONUP || nSzBuf == WM_KEYUP )
        {
            DllCall( "SendMessage", Ptr,hEdit2, UInt,EM_GETSEL, UIntP,nStart, UIntP,nEnd )
            nOfft := ((nStart // nRowLen) * nHdrCols) + (Mod(nStart, nRowLen) // nByteLen)
            GuiControl, _BV:, Static1, % "Offset: " Format("{1:02" sOfftFormat "}" , nOfft)
        }
        Return DllCall( "DefSubclassProc", Ptr,nAdrBuf, UInt,nSzBuf, Ptr,nCols, Ptr,nRows )
    }
    
    If ( nCols == WM_COMMAND )
    {   ; OnMessage call to catch scrolling. It doesn't notify of thumb scrolling.
        If ( nAdrBuf >> 16 == EN_VSCROLL )
            nPos := DllCall( "GetScrollPos", Ptr,hEdit2, Int,SB_VERT )
          , DllCall( "PostMessage", Ptr,hEdit1, UInt,WM_VSCROLL, Ptr,(nPos<<16)+SB_THUMBPOSITION, Ptr,0 )
        Return
    }
    
    Else
    {   ; Normal function call.
        If ( !nSzBuf || nSzBuf + 0 != nSzBuf || Mod(nCols, 8) != 0 || nSpaces < 1 )
        {   ; Ensures parameters integrity and a column size no less than 8.
            MsgBox, 0x10, BytesView, Wrong parameter(s)?
            Return
        } ( nSzBuf <= 8 ) ? nCols := 8
        
        ; Strings population (offset column, offset header and bytes dump view).
        sSpaces := Format("{1:" nSpaces "s}", A_Space)
        Loop % Ceil(nSzBuf / nCols)
            sOffsetCol .= Format("{1:0" StrLen(nSzBuf) sFormat "}", (A_Index-1)*nCols) "`n"
        Loop %nCols%
            sOffsetHdr .= Format("{1:02" sFormat "}" , A_Index-1) (( A_Index != nCols ) ? sSpaces : "")
        Loop %nSzBuf%
            sDump .= Format("{1:02X}", NumGet(nAdrBuf+0, A_Index-1, "UChar"))
                  .  (( Mod(A_Index, nCols) != 0 ) ? sSpaces : "`n")
        sDump := RTrim(sDump)
        
        Gui, _BV: +HwndhWnd
        Gui, _BV: Color, 909090
        Gui, _BV: Font, s8, Courier New  ; Fallback font.
        Gui, _BV: Font, s8, Consolas     ; Preferred font (available only on OS > Vista).
        Gui, _BV: Margin, 5, 5
        Gui, _BV: Add, Edit, ym+21 r%nRows% HwndhEdit1 -E0x200 ReadOnly -VScroll, %sOffsetCol%
        Gui, _BV: Add, Edit, x+5 ym+21 r%nRows% HwndhEdit2 -E0x200 +WantTab Section, %sOffsetHdr%
        GuiControlGet, nE1Pos, _BV: Pos, Edit1
        GuiControlGet, nE2Pos, _BV: Pos, Edit2
        Gui, _BV: Add, Text, % "w" nE2PosW - 95 " xs y+5 HwndhText1", Offset: 00
        Gui, _BV: Add, Button, w90 x+5 -Theme +0x8000, &Close
        Gui, _BV: Add, Edit, % "w" nE2PosW " xm+" nE1PosW + 5 " ym -E0x200 ReadOnly -VScroll", %sOffsetHdr%
  
        GuiControl, _BV:, Edit2, %sDump% ; Workaround edit control memory allocation limit.
        GuiControl, _BV: Focus, Edit2    ; Set focus on the bytes view.
        DllCall( "PostMessage", Ptr,hEdit2, UInt,EM_SETLIMITTEXT, Ptr,1, Ptr,0 ) ; Disable text editing.
        
        ; Set window and taskbar/alt-tab icon.
        hIcon := DllCall( "LoadImage", Ptr,DllCall("GetModuleHandle",Str,"Shell32.dll")
                                     , Ptr,13, UInt,IMAGE_ICON, Int,32, Int,32, UInt,0 )
        d := A_DetectHiddenWindows
        DetectHiddenWindows, On
        SendMessage, WM_SETICON, 0, hIcon,, ahk_id %hWnd%
        SendMessage, WM_SETICON, 1, hIcon,, ahk_id %hWnd%
        DetectHiddenWindows, %d%
        
        ; The EN_VSCROLL notification code is sent through the WM_COMMAND message, so we monitor it to get 
        ; notification about scrolling with mousewheel, keyboard and scrollbar arrows. This notification 
        ; is not sent when scrolling through the scrollbar thumb, so we need to subclass the edit control 
        ; to make it work. We use subclassing also for offset calculation so we set the required static
        ; variables to be used when receiving the subclass call.
        sOfftFormat := sFormat, nByteLen := nSpaces + 2, nHdrCols := nCols, nRowLen := (nByteLen * (nCols-1)) + 4
        DllCall( "SetWindowSubclass", Ptr,hEdit2, Ptr,cbSubclassProc, Ptr,hEdit2, Ptr,0 )
        OnMessage(WM_COMMAND, A_ThisFunc)
        
        Gui, _BV: Show,, BytesView
        WinWaitClose ; Prevent early return.
        Return
        
        _BVBUTTONCLOSE:
            DllCall( "RemoveWindowSubclass", Ptr,hEdit2, Ptr,cbSubclassProc, Ptr,hEdit2 )
            Gui, _BV: Destroy
            Return
        ;_BVBUTTONCLOSE
    }
}
