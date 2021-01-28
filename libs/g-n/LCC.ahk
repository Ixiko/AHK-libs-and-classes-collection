; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=83719
; Author:
; Date:
; for:     	AHK_L

/*

  Note: This function requires lcc-win64 to be installed. Refer homepage of lcc-win.
  A NOTE of caution from @SOTE regarding LCC license : Read

  LCC(CCode, Switches, ByRef MCodeAsHex, ByRef MCodeAsBase64)
  Compiles C code and returns a function pointer that can be used with DllCall()
  The function will optionally encode machine code as text when (either/both) 3rd/4th parameters are used.

  Example for a quick test. MsgBox % DllCall(LCC("int add(int a, int b) {return a+b;}"), "Int",20, "Int",21, "Cdecl UInt")
  Note: For above example, a subfolder named add will be created in the script folder, and will contain the generated files.

  Example for testing/generating mcode:

    #NoEnv
    #Warn
    #SingleInstance Force

    ccode := "
    (

    int add(int a, int b)
    {
        return a+b;
    }

    )"

    pADD :=  LCC(ccode,, mcode)
    MsgBox % mcode
    MsgBox % DllCall(pADD, "Int",20, "Int",21, "Cdecl UInt") ; returns 20+21 = 41

*/

LCC( CCode, Switches := "-A -A -O", ByRef Hex:="", ByRef B64:="" ) {    ; v0.63 by SKAN on D3BI/D3BR
Local                                                                   ;              @ tiny.cc/Lcc
Static lccPath := "", OnLoad := LCC(""), fl := 0x40000001, n:=0, Cmd := A_ComSpec

  If (lccPath = "")
  {
      RegRead, lccPath, HKCU\SOFTWARE\lcc\compiler, includepath
      If ( ErrorLevel || (! FileExist(lccPath . "\..\bin\lcc.exe")) )
      {
        MsgBox, 16, LCC(), LCC is not properly installed!
        ExitApp
      }

      lccPath := SubStr(lccPath, 1, StrLen(lccPath)-8)
      EnvGet, ppath, PATH
      If (! InStr(ppath, lccPath . "\bin;"))
        EnvSet, PATH, % lccPath . "\bin;" . ppath
      Return 1
  }

  CCode  := Trim(CCode, "`r`n `t")
  dname  := StrSplit(StrSplit(CCode,"(")[1], A_Space, "*").Pop()
  fname  := ( dname . "_" . (A_PtrSize=8 ? 64 : 32) )
  If ( StrSplit( Trim(dname), StrSplit("\/:*?""<>|")).Count() != 1 )
  {
     MsgBox, 16, LCC(), Invalid folder name:`n`n%dname%
     ExitApp
  }

  folder := ( A_ScriptDir . "\" . dname )
  FileCreateDir, %folder%
  FileDelete, % folder . "\" . fname . ".*"
  FileOpen(folder . "\" . fname . ".c",   "w", "cp0").Write(CCode)

  xbit := (A_PtrSize=8 ? 64 : "")
  RunWait, %Cmd% /c lcc%xbit%.exe %Switches% %fname%.c 2> %fname%.txt, %folder%,  Hide UseErrorLevel
  If (ErrorLevel)
  {
    MsgBox, 16, LCC(), % FileOpen(folder . "\" . fname . ".txt", "r", "cp0").Read()
    ExitApp
  }

  RunWait, %Cmd% /c pedump.exe /x.text /ALL %fname%.obj 1> %fname%.txt, %folder%, Hide UseErrorLevel
  If (ErrorLevel)
  {
    MsgBox, 16, LCC(), % FileOpen(folder . "\" . fname . ".txt", "r", "cp0").Read()
    ExitApp
  }

  FileMove, %folder%\text.sec, %folder%\%fname%.bin, 1
  FileGetSize, Bytes, %folder%\%fname%.bin
  FileRead, All, % folder . "\" . fname . ".txt"
  If (! InStr( All, "(.data)  size: 00000",,0))
  {
    MsgBox, 16, LCC(), .data section not empty!`nMachine code not portable.
    ExitApp
  }

  G := DllCall("GlobalAlloc", "Int",0, "Ptr",Bytes, "UPtr")
  FileOpen(folder . "\" . fname . ".bin", "r", "cp0").RawRead(G+0, Bytes)
  DllCall("VirtualProtect", "Ptr",G, "Ptr",Bytes, "Int",0x40, "IntP",OldProtect := 0)

  If IsByRef(Hex)
     n := (Bytes*2) + 2 + (A_IsUnicode ? 1 : 0),  VarSetCapacity(Hex, Bytes*2*(A_IsUnicode ? 2 : 1))
  ,  DllCall("Crypt32.dll\CryptBinaryToString", "Ptr",G, "Int",Bytes, "Int",12, "Str",Hex, "IntP",n)

  If IsByRef(B64)
     DllCall("Crypt32.dll\CryptBinaryToString", "Ptr",G, "Int",Bytes, "Int",fl, "Ptr",0, "IntP",n)
  ,  VarSetCapacity(B64, n*2, 0)
  ,  DllCall("Crypt32.dll\CryptBinaryToString", "Ptr",G, "Int",Bytes, "Int",fl, "Str",B64, "IntP",n)

Return G
}