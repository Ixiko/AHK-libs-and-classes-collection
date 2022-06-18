; Title:   	BtnIL() : PNG BUTTON_IMAGELIST
; Link:   	autohotkey.com/boards/viewtopic.php?f=6&t=92531&sid=0fbe541c108a3e4759d7d87a09a80b46
; Author:	SKAN
; Date:   	11-07-2021
; for:     	AHK_L

/* DESCRIPTION

BtnIL( ByRef BUTTON_IMAGELIST, Hwnd, uAlign, Left, Top, Right, Bottom )
     Creates/Applies an ImageList to a Button. Returns False on failure, otherwise true.
     BtnIL() is a redo of my decade old code: https://autohotkey.com/board/topic/67252-/?p=430050

BtnIL() operates in two modes.
     1) When Hwnd parameter is omitted or blank, It creates/prepares BUTTON_IMAGELIST structure from PNG data contained in BUTTON_IMAGELIST parameter.
     2) When Hwnd points to a Button control the function sends BCM_SETIMAGELIST message to apply the BUTTON_IMAGELIST structure to Button.

Creating BUTTON_IMAGELIST
     The image needs to be in PNG format and needs to have exactly 6 images (needn't be square) for showing following states
          PUSHBUTTONSTATES {
          PBS_NORMAL = 1,
          PBS_HOT = 2,
          PBS_PRESSED = 3,
          PBS_DISABLED = 4,
          PBS_DEFAULTED = 5,
          PBS_STYLUSHOT = 6,
          };

     For example, here is the smiley.png used in Example #1
     Image

     To load/convert the image to BUTTON_IMAGELIST structure
     FileRead, BUTTON_IMAGELIST, *c smiley.png
     BtnIL(BUTTON_IMAGELIST) ; convert PNG data to struct

     Or
     BUTTON_IMAGELIST := "smiley.png"
     BtnIL(BUTTON_IMAGELIST) ; Load/convert PNG data to struct

     Note: You may pass PNG as Base64 text, but you need to store it in a var and pass the var instead. Remember that first parameter is a in/out and requires ByRef Var.

Applying BUTTON_IMAGELIST
     Use the Hwnd parameter to attach ImageList to a button.

     Gui, Add, Button, HWndhButton ....
     BtnIL(BUTTON_IMAGELIST, hButton)

Removing BUTTON_IMAGELIST from a button.
     Pass -1 (BCCL_NOGLYPH) as first parameter to detach ImageList from a button.

     BtnIL(-1, hButton)

Destroying BUTTON_IMAGELIST
     Pass false as Hwnd parameter to destroy ImageList.

GuiClose:
     BtnIL(BUTTON_IMAGELIST, False)
     ExitApp

The rest of parameters are optional and can be set in both modes.
     uAlign parameter:  By default, the Image will appear of left side of the text. Pass "Left", "Right", "Top", "Bottom" to move/rotate it around any times.
                                   To suppress text from a button, use +0x80 (BS_BITMAP) when creating a button.
                 Margins*:  Use these parameters to set spacing around the Image. They need to be in this order: Left, Top, Right, Bottom.

*/

/* Example 1
#NoEnv
#Warn
#SingleInstance, Force

BIL := "
( LTrim Join
  iVBORw0KGgoAAAANSUhEUgAAAYAAAABACAMAAAAkhlCNAAACZ1BMVEUAAADwvTP/zCr83yD2wCv/xhj/9Af/ySLruCL/yif/yyn/yij
  /zCX+yiP4wh/ruC/gsCT/yij/ySjsuSH/yijotyHuvSL/yyj/0yLrtin2wyH/yij/yCfitST/zSfzux3/yij8yCf4xyfwySz9xSzswC
  rotyHuvSDuuh7/wy3/yinrsyf/yCr/xiv+zC3tuiTouCX/yizqtCf/0yH/yifotyP/yynitSXltCr/ySj/yij/ySf/3Rz/0Sb/2hz2u
  yn/0Sv3xyr5tRzqvhv/3C/zySzltCLkxD36xSfmsCjpuibosybquST/xSz/ziXhqyj/wy3ksCX/yCvttCntwCjutSf8xSztvibrtSX/
  1yvqvCTzwyXrsyv/ySr/vCb/wyfyviDtsB3sviD/uyb/1SL1yhj/yij/riD/zSb/oRz2wC7/ySj/yij/yyjntiL/zCjmtSLltSL/0ij
  /1Cj/zSj/0ChgQyP9yCfktCH/zyjmtiFRNiP/1ij2wiZdQCNMMiJPNCLptyL5xCbxvyVXOyPruSNaPiP+ySdUOSP7xyfotyZTOCP/yC
  rtuyPtuiLquSHpuCP/2ilJLyKnfyX/xSzYqSd+XCP/2CjtuidxUCP2wyegeSXPoSf/xymkfSWNaSR1VCNsTSPisSeUbyW3jSZiRSLLn
  ibEmCb/2SjWpyfTpifImya+kyb9zSirgiVoSSPeryfmtCKcdiT/3Cnltie0iiaCYCPwviVnSCNVOSJ6WSNBKSL/xyv0wSjarSeyiSXl
  tiDjsx68kSbyxijbrCfnuiXClib/wDD/0y7/0C2GYySIZSSuhiUwT/K4AAAAbHRSTlMAAisJDh0GBd24nY9QRS8kFvjz8O7t08Kxq6i
  ajImIbVY8OCcZ+PPq5OHf2c/NyLy4pKGdmIx+fXl4bmVlZGNhXE5NSz00KiD++fj49+3m2NbV0sTExMK9urSxr62onJmTkY+Nhm9qV1
  ZTS0c7BWOMAAAITUlEQVR42u3bddeaUAAGcNbd3d3d3d3d3XWv4A0VYcKmc1NXrly4cG7Tpevurg81lgi4cuLh7PD89R7lB8/xeuHyc
  mR+lnKtRg8f0Lh3xUaV+g6qUrI085PY3hRfunmlerWPbwffU6Nzr6FlbF8kX6JlxY5AF3j8wNT6lUvZvgh+UwWQOw9hl8GlbG+yb1EB
  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
)"


BtnIL(BIL,, "Center") ; Convert Base64 encoded PNG to BUTTON_IMAGELIST structure.

Gui, New, -DpiScale -MinimizeBox, BtnIL() demo
Gui, Margin, 24, 24

Gui, Add, Button, xm ym   w96 h96 hwndhButton1
BtnIL(BIL, hButton1)

Gui, Add, Button, x+m ym  w96 h96 hwndhButton2
BtnIL(BIL, hButton2)

Gui, Add, Button, xm  y+m w96 h96 hwndhButton3
BtnIL(BIL, hButton3)

Gui, Add, Button, x+m yp  w96 h96 hwndhButton4 Disabled
BtnIL(BIL, hButton4)

Gui, Show
Return


GuiEscape:
GuiClose:
  BtnIL(BIL, False) ; Delete ImageList/Stucture
  ExitApp



*/

/* Example 2
#NoEnv
#Warn
#SingleInstance, Force

ParanoidMode := True
ResourceFile := ParanoidMode ? "ImageList.ini" : "ImageList.dll"

If ! FileExist(ResourceFile)
     If ( ResourceFile = "ImageList.dll" )
          UrlDownloadToFile
        , https://drive.google.com/u/0/uc?id=1mN_0jgr62lGUYqba04boSQwC6j_xL0CX&export=download
        , %ResourceFile% ; 23,552 bytes
     Else UrlDownloadToFile
        , https://drive.google.com/u/0/uc?id=11Trq9jDa24x9fNoRSPek-n9krL3Fsr_u&export=download
        , %ResourceFile% ; 29,091 bytes

Png := Format("DPI-{:03d}.PNG", A_ScreenDPI<=96  ?  96 : A_ScreenDPI<=120 ? 120
                              : A_ScreenDPI<=144 ? 144 : A_ScreenDPI<=168 ? 168 : 192)

If ( ResourceFile = "ImageList.dll" )
     DllRead( BIL,  ResourceFile ,  "IMAGELIST",  Png )
Else IniRead, BIL, %ResourceFile%,   IMAGELIST,  %Png%

Margin := 4 * (A_ScreenDPI/96)
Left   := ["Left",  Margin, 0, 0, 0]
Right  := ["Right", 0, 0, Margin, 0]

BtnIL(BIL) ; PNG data to BUTTON_IMAGELIST structure.

Gui, New, +DpiScale -MinimizeBox, BtnIL() Demo
Gui, Margin, 12, 12
Gui, Add, Button, xm ym  w120 h40 HwndhButton1 Section,  Button 1
Gui, Add, Button,    y+m wp   hp  HwndhButton2,          Button 2
Gui, Add, Button,    y+m wp   hp  HwndhButton3,          Button 3
Gui, Add, Button,    y+m wp   hp  HwndhButton4,          Button 4

Gui, Add, Button, x+m ys wp   hp  HwndhButton5,          Button 5
Gui, Add, Button,    y+m wp   hp  HwndhButton6,          Button 6
Gui, Add, Button,    y+m wp   hp  HwndhButton7,          Button 7
Gui, Add, Button,    y+m wp   hp  HwndhButton8 Disabled, Button 8

BtnIL(BIL, hButton1, Left*)
BtnIL(BIL, hButton2)
BtnIL(BIL, hButton3)
BtnIL(BIL, hButton4)

BtnIL(BIL, hButton5, Right*)
BtnIL(BIL, hButton6)
BtnIL(BIL, hButton7)
BtnIL(BIL, hButton8)

Gui, Show, AutoSize
Return

GuiClose:
GuiEscape:
  BtnIL(BIL, False) ; Delete ImageList/Stucture
  ExitApp
Return

DllRead( ByRef Var, Filename, Section, Key ) {    ; By SKAN | goo.gl/DjDxzW
Local ResType, ResName, hMod, hRes, hData, pData, nBytes := 0
  ResName := ( Key+0 ? Key : &Key ), ResType := ( Section+0 ? Section : &Section )

  VarSetCapacity( Var,128 ), VarSetCapacity( Var,0 )
  If hMod  := DllCall( "LoadLibraryEx", "Str",Filename, "Ptr",0, "UInt",0x2, "Ptr" )
  If hRes  := DllCall( "FindResource", "Ptr",hMod, "Ptr",ResName, "Ptr",ResType, "Ptr" )
  If hData := DllCall( "LoadResource", "Ptr",hMod, "Ptr",hRes, "Ptr" )
  If pData := DllCall( "LockResource", "Ptr",hData, "Ptr" )
  If nBytes := DllCall( "SizeofResource", "Ptr",hMod, "Ptr",hRes )
     VarSetCapacity( Var,nBytes,1 )
   , DllCall( "RtlMoveMemory", "Ptr",&Var, "Ptr",pData, "Ptr",nBytes )
  DllCall( "FreeLibrary", "Ptr",hMod )
Return nBytes
}
*/


BtnIL(ByRef BIL, Hwnd:="",  V*) {                        ; BtnIL() v0.60 by SKAN on D479/D47B @ tiny.cc/btnil
Local
  BCCL_NOGLYPH     := -1
  BCM_SETIMAGELIST := 0x1602
  BCM_GETIMAGELIST := 0x1602

  nBytes  := ( IsByRef(BIL) ?  VarSetCapacity(BIL) : 0 )
  himl    := ( nBytes = A_PtrSize+20 ? NumGet(BIL) : 0 )

  If ( Hwnd = False )
  {
       VarSetCapacity(BIL, 0)
       Return himl ? IL_Destroy(himl) : 0
  }

  If ( Hwnd != "" )
  {
      Hwnd := Format("0x{:x}", Hwnd)
      WinGetClass, Class, ahk_id %Hwnd%

      If ( Class != "Button" )
           Return 0

      If ( nBytes = 0 )
      {
           VarSetCapacity(BIL, A_PtrSize+20, 0)
           DllCall("User32.dll\SendMessage", "Ptr",Hwnd, "Int",BCM_GETIMAGELIST, "Ptr",0, "Ptr",&BIL)

           If ( NumGet(BIL, A_PtrSize=8 ? "Ptr" : "Int") = BCCL_NOGLYPH )
                Return 0

           NumPut(BCCL_NOGLYPH, BIL, "Ptr")
           Return DllCall("User32.dll\SendMessage", "Ptr",Hwnd, "Int",BCM_SETIMAGELIST, "Ptr",0, "Ptr",&BIL)
      }

      If ( himl = 0 )
           Return 0

      Align := SubStr(V.1, 1, 1)
      If ( Align != "" )
           NumPut(InStr("RTBC", Align),  BIL, A_PtrSize+16, "Int")

      DllCall("User32.dll\SetRect", "Ptr",&BIL+A_PtrSize
            , "Int", V.2 != "" ? Format("{:d}",V.2) : NumGet(BIL, A_PtrSize+0,  "Int")
            , "Int", V.3 != "" ? Format("{:d}",V.3) : NumGet(BIL, A_PtrSize+4,  "Int")
            , "Int", V.4 != "" ? Format("{:d}",V.4) : NumGet(BIL, A_PtrSize+8,  "Int")
            , "Int", V.5 != "" ? Format("{:d}",V.5) : NumGet(BIL, A_PtrSize+12, "Int") )

      Return DllCall("User32.dll\SendMessage", "Ptr",Hwnd, "Int",BCM_SETIMAGELIST, "Ptr",0, "Ptr",&BIL)
  }


  If ( IsByRef(BIL) = False )
       Return 0

  If ( himl && DllCall("Comctl32.dll\ImageList_GetImageCount", "Ptr",himl))
       Return himl

  If FileExist(BIL)
  {
     FileRead, BIL, *c %BIL%
     nBytes := VarSetCapacity(BIL)
  }

  If ! ( Base64 := (nBytes > 3  &&   SubStr(BIL,1,4) == "iVBO") )
    If ( nBytes < 4  ||  NumGet(BIL,"UInt") != 0x474e5089 )
         Return 0

  If ( Base64 && (Base64 := BIL) )
  {
       VarSetCapacity(BIL, nBytes := Floor((B64Len := StrLen(Base64 := RTrim(Base64,"=")))*3/4))
       DllCall("Crypt32.dll\CryptStringToBinary", "Str",Base64, "Int",B64Len, "Int",1, "Ptr",&BIL
              ,"UIntP",nBytes, "Int",0, "Int",0)
       VarSetCapacity(Base64, 0)
  }

  hicon := DllCall("User32.dll\CreateIconFromResourceEx", "Ptr",&BIL, "Int",nBytes, "Int",True, "Int",0x30000
                 , "Int",0, "Int",0, "Int",0, "Ptr")
  If ( hicon = 0 )
       Return  0

  VarSetCapacity(BIL, 128, 0)
  DllCall("User32.dll\GetIconInfo", "Ptr",hicon, "Ptr",&BIL)                                 ; Bin = ICONINFO
  hbmMask  := NumGet(BIL, A_PtrSize=8 ? 16 : 12, "Ptr")
  hbmColor := NumGet(BIL, A_PtrSize=8 ? 24 : 16, "Ptr")
  hbmColor := DllCall("User32.dll\CopyImage", "Ptr",hbmColor, "Int",0, "Int",0, "Int",0, "Int",0x2008, "Ptr")
  hbmMask  := DllCall("User32.dll\CopyImage", "Ptr",hbmMask,  "Int",0, "Int",0, "Int",0, "Int",0x2008, "Ptr")

  DllCall("Gdi32.dll\GetObject", "Ptr",hbmColor, "Int",A_PtrSize=8 ? 104 : 84, "Ptr",&BIL) ; Bin = DIBSECTION
  W := NumGet(BIL, 4,"UInt")
  H := NumGet(BIL, 8,"UInt")
  himl := DllCall("Comctl32.dll\ImageList_Create", "Int",W/6, "Int",H, "Int",32, "Int",6, "Int",0, "Ptr")
  DllCall("Comctl32.dll\ImageList_Add", "Ptr",himl, "Ptr",hbmColor, "Ptr",hbmMask)

  DllCall("Gdi32.dll\DeleteObject", "Ptr",hbmColor)
  DllCall("Gdi32.dll\DeleteObject", "Ptr",hbmMask)
  DllCall("User32.dll\DestroyIcon", "Ptr",hicon)

  VarSetCapacity(BIL, VarSetCapacity(BIL, 0) + A_PtrSize + 20, 0)
  NumPut(himl, BIL, "Ptr")
  NumPut(InStr("RTBC", SubStr(V.1 . A_Space, 1,1)), BIL, A_PtrSize+16, "Int")
  DllCall("User32.dll\SetRect", "Ptr",&BIL+A_PtrSize
            , "Int",Format("{:d}",V.2)
            , "Int",Format("{:d}",V.3)
            , "Int",Format("{:d}",V.4)
            , "Int",Format("{:d}",V.5) )
Return himl
}