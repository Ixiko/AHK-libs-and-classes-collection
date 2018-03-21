; OneLineCommands (Execute AHK code dynamically!)
; by HotKeyIt
; http://www.autohotkey.com/forum/viewtopic.php?p=340131#340131
Exec(_#_1,_#_2="",_#_3="",_#_4="",_#_5="",_#_6="",_#_7="",_#_8="",_#_9="",_#_10="",_#_11="",_#_12="",_#_13="",_#_14="",_#_15="",_#_16="",_#_17="",_#_18="",_#_19="",_#_20=""){
   global
   local _#_T, _#_F, _#_L, _#_O,_#_C,_#_I,_#_P,_#_V
   If IsLabel(_#_1)
      GoTo % _#_1
   else if IsLabel(RegExReplace(_#_1,"[\s`,].*")){
      _#_I=0
      Loop,Parse,_#_1,`n
      {
         _#_P:=RegExReplace(A_LoopField,"^(\w+)\s","$1,")
         While (_#_I:=RegExMatch(_#_P,"(%[\w#@]+%)")){
            _#_V:=SubStr(_#_P,_#_I+1,InStr(_#_P,"%",1,_#_I+1)-_#_I-1)
            StringReplace,_#_P,_#_P,`%%_#_V%`%,% %_#_V%
            _#_I++
         }
         Loop,Parse,_#_P,`,,%A_Space%%A_Tab%
         {
            If A_LoopField=
               Continue
            If !(_#_T){
               _#_I++
               _#_%_#_I% := A_LoopField
            } else {
               StringTrimRight,_#_%_#_I%,_#_%_#_I%,1
               _#_%_#_I% .= "," A_LoopField,_#_T:=""
            }
            If (SubStr(A_LoopField,0)="``" && _#_T:=1)
               Continue
         }
         _#_T:="",_#_I:=0,_#_P:=""
         Gosub % _#_1
         Loop 20
            _#_%A_Index%=
      }
   } else
      Return "`tCheck Syntax:" . "`t" . _#_1 . "," . _#_2 . "," . _#_3 . "," . _#_4 . "," . _#_5 . "," . _#_6 . "," . _#_7
            . "," . _#_8 . "," . _#_9 . "," . _#_10 . "," . _#_11 . "," . _#_12 . "," . _#_13 . "," . _#_14 . "," . _#_15 . "," . _#_16
            . "," . _#_17 . "," . _#_18 . "," . _#_19 . "," . _#_20 "`n"
   Return
   Return: ;enter return value for debuging
   Return A_Tab . "ErrorLevel: " . Errorlevel . "`t" . _#_1 . "," . _#_2 . "," . _#_3 . "," . _#_4 . "," . _#_5 . "," . _#_6 . "," . _#_7 . "," . _#_8 . "," . _#_9 . "," . _#_10 . "," . _#_11 . "," . _#_12 . "," . _#_13 . "," . _#_14 . "," . _#_15 . "," . _#_16 . "," . _#_17 . "," . _#_18 . "," . _#_19 . "," . _#_20 "`n"
   AT:
   AutoTrim:
     AutoTrim, %_#_2%
   Return
   BI:
   BlockInput:
      BlockInput, %_#_2%
   Return
   C:
   Click:
      Click %_#_2%, %_#_3%, %_#_4%
   Return
   CW:
   ClipWait:
     ClipWait, %_#_2%, %_#_3%
   Goto, Return
   CTRL:
   Control:
     Control, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%
   Goto, Return
   CC:
   ControlClick:
     ControlClick, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%, %_#_9%
   Goto, Return
   CF:
   ControlFocus:
     ControlFocus, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Goto, Return
   CG:
   ControlGet:
     ControlGet, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%, %_#_9%

   Goto, Return
   CGF:
   ControlGetFocus:
     ControlGetFocus, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%

   Goto, Return
   CGP:
   ControlGetPos:
      ControlGetPos, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%, %_#_9%, %_#_10%
   Return
   CMO:
   ControlMove:
      ControlMove, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%, %_#_9%, %_#_10%

   Goto, Return
   CGT:
   ControlGetText:
     ControlGetText, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%

   Goto, Return
   CS:
   ControlSend:
     ControlSend, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%

   Goto, Return
   CSR:
   ControlSendRaw:
     ControlSendRaw, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%
   Goto, Return
   CST:
   ControlSetText:
     ControlSetText, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%

   Goto, Return
   CM:
   CoordMode:
     CoordMode, %_#_2%, %_#_3%
   Return
   CR:
   Critical:
      Critical, %_#_2%
   Return
   DHT:
   DetectHiddenText:
     DetectHiddenText, %_#_2%
   Return
   DHW:
   DetectHiddenWindows:
     DetectHiddenWindows, %_#_2%
   Return
   D:
   Drive:
     Drive, %_#_2%, %_#_3%, %_#_4%

   Goto, Return
   DG:
   DriveGet:
     DriveGet, %_#_2%, %_#_3%,%_#_4%

   Goto, Return
   DSF:
   DriveSpaceFree:
      DriveSpaceFree, %_#_2%, %_#_3%
   Return
   ES:
   EnvSet:
     EnvSet, %_#_2%, %_#_3%

   Goto, Return
   EG:
   EnvGet:
     EnvGet, %_#_2%, %_#_3%
   Return
   EU:
   EnvUpdate:
     EnvUpdate
   Goto, Return
   ESU:
   EnvSub:
     EnvSub, %_#_2%, %_#_3%
   Return
   EA:
   EnvAdd:
     EnvAdd, %_#_2%, %_#_3%
   Return
   ED:
   EnvDiv:
     EnvDiv, %_#_2%, %_#_3%
   Return
   EM:
   EnvMult:
     EnvMult, %_#_2%, %_#_3%
   Return
   E:
   Exit:
     Exit, %_#_2%
   Return
   EAP:
   ExitApp:
     ExitApp
   Return
   FA:
   FileAppend:
     FileAppend, %_#_2%, %_#_3%
   Goto, Return
   FC:
   FileCopy:
     FileCopy, %_#_2%, %_#_3%, %_#_4%
   Goto, Return
   FCD:
   FileCopyDir:
     FileCopyDir, %_#_2%, %_#_3%, %_#_4%
   Goto, Return
   FCDIR:
   FileCreateDir:
     FileCreateDir, %_#_2%
   Goto, Return
   FCS:
   FileCreateShortcut:
      FileCreateShortcut, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%, %_#_9%, %_#_10%

   Goto, Return
   FD:
   FileDelete:
     FileDelete, %_#_2%
   Goto, Return
   FGA:
   FileGetAttrib:
     FileGetAttrib, %_#_2%, %_#_3%
   Goto, Return
   FGS:
   FileGetSize:
     FileGetSize, %_#_2%, %_#_3%, %_#_4%
   Goto, Return
   FGSH:
   FileGetShortcut:
      _#_3:=!_#_3 ? "_#_T" : _#_3,_#_4:=!_#_4 ? "_#_T" : _#_4,_#_5:=!_#_5 ? "_#_T" : _#_5,_#_6:=!_#_6 ? "_#_T" : _#_6,_#_7:=!_#_7 ? "_#_T" : _#_7,_#_8:=!_#_8 ? "_#_T" : _#_8,_#_9:=!_#_9 ? "_#_T" : _#_9
      FileGetShortcut, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%, %_#_9%

   Goto, Return
   FGT:
   FileGetTime:
     FileGetTime, %_#_2%, %_#_3%, %_#_3%
   Goto, Return
   FGV:
   FileGetVersion:
      FileGetVersion, %_#_2%, %_#_3%

   Goto, Return
   FM:
   FileMove:
     FileMove, %_#_2%, %_#_3%, %_#_4%
   Goto, Return
   FMD:
   FileMoveDir:
     FileMoveDir, %_#_2%, %_#_3%, %_#_4%
   Goto, Return
   FR:
   FileRead:
     FileRead, %_#_2%, %_#_3%
   Goto, Return
   FRL:
   FileReadLine:
     FileReadLine, %_#_2%, %_#_3%, %_#_4%
   Goto, Return
   FRC:
   FileRecycle:
      FileRecycle, %_#_2%

   Goto, Return
   FRE:
   FileRecycleEmpty:
      FileRecycleEmpty, %_#_2%

   Goto, Return
   FRD:
   FileRemoveDir:
      FileRemoveDir, %_#_2%, %_#_3%

   Goto, Return
   FSF:
   FileSelectFile:
     FileSelectFile, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Goto, Return
   FSD:
   FileSelectFolder:
     FileSelectFolder, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Goto, Return
   FSA:
   FileSetAttrib:
     FileSetAttrib, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Goto, Return
   FST:
   FileSetTime:
     FileSetTime, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Goto, Return
   FT:
   FormatTime:
     FormatTime, %_#_2%, %_#_3%, %_#_4%
   Goto, Return
   GKS:
   GetKeyState:
      GetKeyState, %_#_2%, %_#_3%, %_#_4%
   Return
   GA:
   GroupActivate:
     GroupActivate, %_#_2%, %_#_3%
   Return
   GADD:
   GroupAdd:
     GroupAdd, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%
   Return
   GCL:
   GroupClose:
     GroupClose, %_#_2%, %_#_3%
   Return
   H:
   Hotkey:
      Hotkey, %_#_2%, %_#_3%, %_#_4%

   Goto, Return
   GS:
   GoSub:
      GoSub, %_#_2%
   Return
   GT:
   GoTo:
      Goto, %_#_2%
   Return
   IMB:
   IfMsgBox:
   IfMsgBox, %_#_2%
   {
      _#_C = 3
      Loop 18
      {
         _#_%A_Index% := _#_%_#_C%
         _#_C++
      }
      If IsLabel(_#_1)
         GoSub, %_#_1%
   }
   Return
   IEQ:
   INEQ:
   IG:
   IGOE:
   IL:
   ILOE:
   IIS:
   INIS:
   IWA:
   IWNA:
   IWE:
   IWNE:
   IE:
   INE:
   IfEqual:
   IfNotEqual:
   IfGreater:
   IfGreaterOrEqual:
   IfLess:
   IfLessOrEqual:
   IfInString:
   IfNotInString:
   IfWinActive:
   IfWinNotActive:
   IfWinExist:
   IfWinNotExist:
   IfExist:
   IfNotExist:
   {
   _#_L=
   If (_#_1 = "IfEqual" || _#_1 = "IEQ")
   {
      IfEqual, %_#_2%, %_#_3%
      {
         _#_F=4
         _#_L=17
         _#_O = %_#_4%
         _#_P -= 3
      }
      else
         Return
   }
   
   If (_#_1 = "IfNotEqual" || _#_1 = "INEQ")
   {
      IfNotEqual, %_#_2%, %_#_3%
      {
         _#_F=4
         _#_L=17
         _#_O = %_#_4%
         _#_P -= 3
      }
      else
         Return
   }
   
   If (_#_1 = "IfLess" || _#_1 = "IL")
   {
      IfLess, %_#_2%, %_#_3%
      {
         _#_F=4
         _#_L=17
         _#_O = %_#_4%
         _#_P -= 3
      }
      else
         Return
   }
   
   If (_#_1 = "IfLessOrEqual" || _#_1 = "ILOE")
   {
      IfLessOrEqual, %_#_2%, %_#_3%
      {
         _#_F=4
         _#_L=17
         _#_O = %_#_4%
         _#_P -= 3
      }
      else
         Return
   }
   
   If (_#_1 = "IfGreater" || _#_1 = "IG")
   {
      IfGreater, %_#_2%, %_#_3%
      {
         _#_F=4
         _#_L=17
         _#_O = %_#_4%
         _#_P -= 3
      }
      else
         Return
   }
   
   If (_#_1 = "IfGreaterOrEqual" || _#_1 = "IGOE")
   {
      IfGreaterOrEqual, %_#_2%, %_#_3%
      {
         _#_F=4
         _#_L=17
         _#_O = %_#_4%
         _#_P -= 3
      }
      else
         Return
   }
   
   If (_#_1 = "IfInString" || _#_1 = "IIS")
   {
      IfInString, %_#_2%, %_#_3%
      {
         _#_F=4
         _#_L=17
         _#_O = %_#_4%
         _#_P -= 3
      }
      else
         Return
   }
   
   If (_#_1 = "IfNotInString" || _#_1 = "INIS")
   {
      IfNotInString, %_#_2%, %_#_3%
      {
         _#_F=4
         _#_L=17
         _#_O = %_#_4%
         _#_P -= 3
      }
      else
         Return
   }
   
   If (_#_1 = "IfWinActive" || _#_1 = "IWA")
   {
      IfWinActive, %_#_2%, %_#_3%, %_#_4%, %_#_5%
      {
         _#_F=6
         _#_L=15
         _#_O = %_#_6%
         _#_P -= 5
      }
      else
         Return
   }
   
   If (_#_1 = "IfWinNotActive" || _#_1 = "IWNA")
   {
      IfWinNotActive, %_#_2%, %_#_3%, %_#_4%, %_#_5%
      {
         _#_F=6
         _#_L=15
         _#_O = %_#_6%
         _#_P -= 5
      }
      else
         Return
   }
   
   If (_#_1 = "IfWinExist" || _#_1 = "IWE")
   {
      IfWinExist, %_#_2%, %_#_3%, %_#_4%, %_#_5%
      {
         _#_F=6
         _#_L=15
         _#_O = %_#_6%
         _#_P -= 5
      }
      else
         Return
   }
   
   If (_#_1 = "IfWinNotExist" || _#_1 = "IWNE")
   {
      IfWinNotExist, %_#_2%, %_#_3%, %_#_4%, %_#_5%
      {
         _#_F=6
         _#_L=15
         _#_O = %_#_6%
         _#_P -= 5
      }
      else
         Return
   }
   
   If (_#_1 = "IfExist" || _#_1 = "IE")
   {
      IfExist, %_#_2%
      {
         _#_F=3
         _#_L=18
         _#_O = %_#_3%
         _#_P -= 2
      }
      else
         Return
   }
   If (_#_1 = "IfNotExist" || _#_1 = "INE")
   {
      IfNotExist, %_#_2%
      {
         _#_F=3
         _#_L=18
         _#_O = %_#_3%
         _#_P -= 2
      }
      else
         Return
   }
   Loop %_#_L%
   {
      _#_%A_Index% := _#_%_#_F%
      _#_F++
   }
   _#_O =
   If _#_L =
      Return
   IsLabel(_#_1)
         GoSub, %_#_1%
   _#_L=
   Return
   }

   KW:
   KeyWait:
     KeyWait, %_#_2%, %_#_3%
   Goto, Return
   M:
   Menu:
     Menu, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Return
   MC:
   MouseClick:
     MouseClick, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%
   Return
   MCD:
   MouseClickDrag:
     MouseClickDrag, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%
   Return
   MGP:
   MouseGetPos:
      _#_2:=!_#_2 ? "_#_T" : _#_2,_#_3:=!_#_3 ? "_#_T" : _#_3,_#_4:=!_#_4 ? "_#_T" : _#_4,_#_5:=!_#_5 ? "_#_T" : _#_5
      MouseGetPos, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Return
   MM:
   MouseMove:
     MouseMove, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Return
   MB:
   MsgBox:
      checkifmsgboxfull := _#_3 _#_4 _#_5
      IfNotEqual, checkifmsgboxfull, , SetEnv, checkifmsgboxfull, 1
      If _#_2 is digit
      {
         If checkifmsgboxfull = 1
         {
               ;MsgBox % _#_2
               If _#_2 < 1
                  MsgBox, 0, %_#_3%, %_#_4%, %_#_5%
               else if _#_2 = 1
               {
                  MsgBox, 1, %_#_3%, %_#_4%, %_#_5%
               }
               else if _#_2 = 2
               {
                  MsgBox, 2, %_#_3%, %_#_4%, %_#_5%
               }
               else if _#_2 = 3
               {
                  MsgBox, 3, %_#_3%, %_#_4%, %_#_5%
               }
               else if _#_2 = 4
               {
                  MsgBox, 4, %_#_3%, %_#_4%, %_#_5%
               }
               else if _#_2 = 5
               {
                  MsgBox, 5, %_#_3%, %_#_4%, %_#_5%
               }
               else if _#_2 = 6
               {
                  MsgBox, 6, %_#_3%, %_#_4%, %_#_5%
               }
               else if _#_2 = 262144
               {
                  MsgBox, 262144, %_#_3%, %_#_4%, %_#_5%
               }
               else if _#_2 = 262145
               {
                  MsgBox, 262145, %_#_3%, %_#_4%, %_#_5%
               }
               else if _#_2 = 262146
               {
                  MsgBox, 262146, %_#_3%, %_#_4%, %_#_5%
               }
               else if _#_2 = 262147
               {
                  MsgBox, 262147, %_#_3%, %_#_4%, %_#_5%
               }
               else if _#_2 = 262148
               {
                  MsgBox, 262148, %_#_3%, %_#_4%, %_#_5%
               }
               else if _#_2 = 262149
               {
                  MsgBox, 262149, %_#_3%, %_#_4%, %_#_5%
               }
               else if _#_2 = 262150
               {
                  MsgBox, 262150, %_#_3%, %_#_4%, %_#_5%
               }
         }
         else
         {
            MsgBox, %_#_2% %_#_3% %_#_4% %_#_5% %_#_6% %_#_7% %_#_8% %_#_9% %_#_10% %_#_11% %_#_12% %_#_13% %_#_14% %_#_15% %_#_16% %_#_17% %_#_18% %_#_19% %_#_20%
         }
      }
      else
     {
      MsgBox, %_#_2% %_#_3% %_#_4% %_#_5% %_#_6% %_#_7% %_#_8% %_#_9% %_#_10% %_#_11% %_#_12% %_#_13% %_#_14% %_#_15% %_#_16% %_#_17% %_#_18% %_#_19% %_#_20%
     }
   Return
   OE:
   OnExit:
     OnExit, %_#_2%
   Return
   PGC:
   PixelGetColor:
     PixelGetColor, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Goto, Return
   PS:
   PixelSearch:
     PixelSearch, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%, %_#_9%, %_#_10%
   Goto, Return
   PWC:
   PixelWaitColor:  ;(ByRef _#_2, ByRef _#_3, p_x1, p_y1, p_x2, p_y2, p_color, p_shades="", p_opts="", p_waitms=0, p_checkinterval="")
   {
      if (RegExMatch(_#_8, "i)^[0-9a-f]{6}$"))
         _#_8:="0x" _#_8
      _#_8_bkp:=_#_8
      _#_8:=RegExReplace(_#_8, "i)\bSlow\b")
      if (_#_8=_#_8_bkp)
         _#_8:=_#_8 " Fast"
      _#_8_bkp:=_#_8
      _#_8:=RegExReplace(_#_8, "i)\bBGR\b")
      if (_#_8=_#_8_bkp)
         _#_8:=_#_8 " RGB"
      if (_#_12="")
         _#_12=519
      ts:=A_TickCount
      Loop
      {
         PixelSearch, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%, %_#_9%, %_#_10%
         if (errorlevel=0 || _#_11 && A_TickCount-ts>=_#_11)
            break
         if (_#_11 && (A_TickCount-ts)+_#_12>=_#_11)
            _#_12:=(_#_11-(A_TickCount-ts))/2
         if (_#_12>19)
            Sleep, %_#_12%
      }
      Goto, Return
   }
   PR:
   Process:
     Process, %_#_2%, %_#_3%, %_#_4%
   Goto, Return
   R:
   Run:
     _#_5:=!_#_5 ? "_#_T" : _#_5
     Run, %_#_2%, %_#_3%, %_#_4%,%_#_5%
   Goto, Return
   RA:
   RunAs:
      If _#_2 =
         RunAs
      else
         RunAs, %_#_2%, %_#_3%, %_#_4%
   Return
   RW:
   RunWait:
      _#_5:=!_#_5 ? "_#_T" : _#_5
      RunWait, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Goto, Return
   SN:
   Send:
     Send, %_#_2%
   Return
   SP:
   SendPlay:
      SendPlay, %_#_2%
   Return
   SI:
   SendInput:
      SendInput, %_#_2%
   Return
   SRAW:
   SendRaw:
      SendRaw, %_#_2%
   Return
   SEV:
   SendEvent:
      SendEvent, %_#_2%
   Return
   RND:
   Random:
     Random, %_#_2%, %_#_3%, %_#_4%
   Return
   SE:
   SetEnv:
     SetEnv, %_#_2%, %_#_3%
   Return
   SF:
   SetFormat:
      SetFormat, %_#_2%, %_#_3%
   Return
   SMOD:
   SendMode:
     SendMode, %_#_2%
   Return
   SKD:
   SetKeyDelay:
     SetKeyDelay, %_#_2%, %_#_3%, %_#_4%
   Return
   SMD:
   SetMouseDelay:
     SetMouseDelay, %_#_2%, %_#_3%
   Return
   STMM:
   SetTitleMatchMode:
     SetTitleMatchMode, %_#_2%
   Return
   SWD:
   SetWinDelay:
     SetWinDelay, %_#_2%
   Return
   SD:
   Shutdown:
     Shutdown, %_#_2%
   Return
   S:
   Sleep:
     Sleep, %_#_2%
   Return
   SO:
   Sort:
     Sort, %_#_2%, %_#_3%
     If _#_3 = U

   Goto, Return
   SPP:
   SplitPath:
     _#_3:=!_#_3 ? "_#_T" : _#_3,_#_4:=!_#_4 ? "_#_T" : _#_4,_#_5:=!_#_5 ? "_#_T" : _#_5,_#_6:=!_#_6 ? "_#_T" : _#_6,_#_7:=!_#_7 ? "_#_T" : _#_7
     SplitPath, %_#_2%,%_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%
   Return
   SBGT:
   StatusBarGetText:
     StatusBarGetText, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%
   Goto, Return
   SBW:
   StatusBarWait:
     StatusBarWait, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%, %_#_9%
   Goto, Return
   SCS:
   StringCaseSense:
     StringCaseSense, %_#_2%
   Return
   SGP:
   StringGetPos:
     StringGetPos, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Goto, Return
   SL:
   StringLeft:
     StringLeft, %_#_2%, %_#_3%, %_#_4%
   Return
   SLEN:
   StringLen:
     StringLen, %_#_2%, %_#_3%
   Return
   SLOW:
   StringLower:
     StringLower, %_#_2%, %_#_3%, %_#_4%
   Return
   SM:
   StringMid:
     StringMid, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Return
   SRPL:
   StringReplace:
     StringReplace, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Goto, Return
   SR:
   StringRight:
     StringRight, %_#_2%, %_#_3%, %_#_4%
   Return
   SS:
   StringSplit:
     StringSplit, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Return
   STL:
   StringTrimLeft:
     StringTrimLeft, %_#_2%, %_#_3%, %_#_4%
   Return
   STR:
   StringTrimRight:
     StringTrimRight, %_#_2%, %_#_3%, %_#_4%
   Return
   SUP:
   StringUpper:
     StringUpper, %_#_2%, %_#_3%, %_#_4%
   Return
   SG:
   SysGet:
     SysGet, %_#_2%, %_#_3%, %_#_4%
   Return
   TT:
   ToolTip:
     ToolTip, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Return
   TRT:
   TrayTip:
     TrayTip, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Return
   TR:
   Transform:
     Transform, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Return
   UDTF:
   UrlDownloadToFile:
     UrlDownloadToFile, %_#_2%, %_#_3%
   Goto, Return
   VSC:
   VarSetCapacity:
      VarSetCapacity(%_#_2%, _#_3, _#_4)
   Return
   WA:
   WinActivate:
     WinActivate, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Return
   WAB:
   WinActivateBottom:
     WinActivateBottom, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Return
   WC:
   WinClose:
     WinClose, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Return
   WGAT:
   WinGetActiveTitle:
     WinGetActiveTitle, %_#_2%
   Return
   WGC:
   WinGetClass:
     WinGetClass, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Return
   WG:
   WinGet:
     WinGet, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Return
   WGP:
   WinGetPos:
     WinGetPos, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%, %_#_9%
   Return
   WGT:
   WinGetText:
     WinGetText, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Goto, Return
   WGTT:
   WinGetTitle:
     WinGetTitle, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Return
   WH:
   WinHide:
     WinHide, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Return
   WK:
   WinKill:
     WinKill, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Return
   WMSI:
   WinMenuSelectItem:
     WinMenuSelectItem, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%, %_#_9%, %_#_10%, %_#_11%, %_#_12%
   Goto, Return
   WM:
   WinMove:
     WinMove, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%, %_#_9%
   Return
   WSH:
   WinShow:
     WinShow, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Return
   WS:
   WinSet:
     WinSet, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%
     If (_#_2 = "Style" or _#_2 = "Exstyle" or _#_2 = Polygon)

   Goto, Return
   WST:
   WinSetTitle:
     WinSetTitle, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Return
   WW:
   WinWait:
     WinWait, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Goto, Return
   WWA:
   WinWaitActive:
     WinWaitActive, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Goto, Return
   WWC:
   WinWaitClose:
     WinWaitClose, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Goto, Return
   WWNA:
   WinWaitNotActive:
     WinWaitNotActive, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Goto, Return
   WMAX:
   WinMaximize:
     WinMaximize, %_#_2%, %_#_3%, %_#_4%
   Return
   WMIN:
   WinMinimize:
     WinMinimize, %_#_2%, %_#_3%, %_#_4%
   Return
   WR:
   WinRestore:
     WinRestore, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Return
   IS:
   ImageSearch:
     ImageSearch, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%
   Goto, Return
   ID:
   IniDelete:
     IniDelete, %_#_2%, %_#_3%, %_#_4%
   Goto, Return
   IR:
   IniRead:
     IniRead, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Return
   IW:
   IniWrite:
     IniWrite, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Goto, Return
   I:
   Input:
     If _#_2
      Input, %_#_2%, %_#_3%, %_#_4%, %_#_5%
     else
      Input
   Goto, Return
   IB:
   InputBox:
     InputBox, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%, %_#_9%, , %_#_11%, %_#_12%
   Goto, Return
   G:
   Gui:
      Gui, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Return
   GD:
   GroupDeactivate:
      GroupDeactivate, %_#_2%, %_#_3%
   Return
   GC:
   GuiControl:
      GuiControl, %_#_2%, %_#_3%, %_#_4%
   Goto, Return
   GuiControlGet:
      GuiControlGet, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Goto, Return
   If:
      If _#_3 = is
      {
         If (%_#_2% is %_#_4%)
         {
            GoTo, RunCommand
         }
      }
      else if _#_3 = is not
      {
         If (%_#_2% is not %_#_4%)
         {
            GoTo, RunCommand
         }
      }
      else If _#_3 = <
      {
         If (%_#_2% < %_#_4%)
         {
            GoTo, RunCommand
         }
      }
      else If _#_3 = =
      {
         If (%_#_2% = %_#_4%)
         {
            GoTo, RunCommand
         }
      }
      else If _#_3 = >
      {
         If %_#_2% > %_#_4%
         {
            GoTo, RunCommand
         }
      }
   Return
   RunCommand:
      _#_C = 5
      Loop 16
      {
         _#_%A_Index% := _#_%_#_C%
         _#_C++
      }
      If IsLabel(_#_1)
         GoTo, %_#_1%
   Return
   KH:
   KeyHistory:
      KeyHistory
   Return
   LH:
   ListHotkeys:
      ListHotkeys
   Return
   LV:
   ListVars:
      ListVars
   Return
   OD:
   OutputDebug:
      OutputDebug, %_#_2%
   Return
   P:
   Pause:
      Pause, %_#_2%, %_#_3%
   Return
   PM:
   PostMessage:
      PostMessage, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%, %_#_9%

   Goto, Return
   SMSG:
   SendMessage:
      SendMessage, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%, %_#_8%, %_#_9%

   Goto, Return
   PRG:
   Progress:
      Progress, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Return
   SIM:
   SplashImage:
      SplashImage, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%
   Return
   RD:
   RegDelete:
      Regdelete, %_#_2%, %_#_3%, %_#_4%

   Goto, Return
   REM:
   RegExMatch:
      RegExMatch(%_#_2%, %_#_3%, %_#_4%, %_#_5%)

   Goto, Return
   RER:
   RegExReplace:
      RegExReplace(%_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%, %_#_7%)

   Goto, Return
   RC:
   RegisterCallback:
      RegisterCallback(%_#_2%, %_#_3%, %_#_4%, %_#_5%)
   Return
   RR:
   RegRead:
      RegRead, %_#_2%, %_#_3%, %_#_4%, %_#_5%

   Goto, Return
   RWR:
   RegWrite:
      RegWrite, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%^

   Goto, Return
   RL:
   Reload:
      Reload
   Return
   SBL:
   SetBatchLines:
      SetBatchLines, %_#_2%
   Return
   SCD:
   SetControlDelay:
      SetControlDelay, %_#_2%
   Return
   SDMS:
   SetDefaultMouseSpeed:
      SetDefaultMouseSpeed, %_#_2%
   Return
   SNLS:
   SetNumLockState:
    SetNumLockState, %_#_2%
   Return
   SCLS:
   SetCapsLockState:
      SetCapsLockState, %_#_2%
   Return
   SSLS:
   SetScrollLockState:
      SetScrollLockState, %_#_2%
   Return
   SSCM:
   SetStoreCapslockMode:
      SetStoreCapslockMode, %_#_2%
   Return
   ST:
   SetTimer:
      SetTimer, %_#_2%, %_#_3%, %_#_4%
   Return
   SWDIR:
   SetWorkingDir:
      SetWorkingDir, %_#_2%

   Goto, Return
   SB:
   SoundBeep:
      SoundBeep, %_#_2%, %_#_3%
   Return
   SOG:
   SoundGet:
      SoundGet, %_#_2%, %_#_3%, %_#_4%, %_#_5%

   Goto, Return
   SGWV:
   SoundGetWaveVolume:
      SoundGetWaveVolume, %_#_2%, %_#_3%, %_#_4%

   Goto, Return
   SPL:
   SoundPlay:
      SoundPlay, %_#_2%, %_#_3%

   Goto, Return
   SOS:
   SoundSet:
      SoundSet, %_#_2%, %_#_3%, %_#_4%, %_#_5%

   Goto, Return
   SSWV:
   SoundSetWaveVolume:
      SoundSetWaveVolume, %_#_2%, %_#_3%

   Goto, Return
   STOF:
   SplashTextOff:
      SplashTextOff
   Return
   STON:
   SplashTextOn:
      SplashTextOn, %_#_2%, %_#_3%, %_#_4%, %_#_5%
   Return
   SU:
   Suspend:
      Suspend, %_#_2%
   Return
   T:
   Thread:
      Thread, %_#_2%, %_#_3%
   Return
   WGAS:
   WinGetActiveStats:
      WinGetActiveStats, %_#_2%, %_#_3%, %_#_4%, %_#_5%, %_#_6%
   Return
   WMA:
   WinMinimizeAll:
      WinMinimizeAll
   Return
   WMAU:
   WinMinimizeAllUndo:
      WinMinimizeAllUndo
   Return
}
