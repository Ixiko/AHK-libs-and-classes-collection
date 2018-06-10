IniSettingsEditor(ProgName,IniFile,OwnedBy = 0,DisableGui = 0, HelpText = 0) {
    static pos

    ;Find a GUI ID that does not exist yet
    Loop, 99 {
      Gui %A_Index%:+LastFoundExist
      If not WinExist() {
          SettingsGuiID = %A_Index%
          break
      }Else If (A_Index = 99){
          MsgBox, 4112, Error in IniSettingsEditor function, Can't open settings dialog,`nsince no GUI ID was available.
          Return 0
        }
      }
    Gui, %SettingsGuiID%:Default

    ;apply options to settings GUI
    If OwnedBy {
        Gui, +ToolWindow +Owner%OwnedBy%
        If DisableGui
            Gui, %OwnedBy%:+Disabled
    }Else
        DisableGui := False

    Gui, +Resize +LabelGuiIniSettingsEditor
    ;create GUI (order of the two edit controls is crucial, since ClassNN is order dependent)
    Gui, Add, Statusbar
    Gui, Add, TreeView, x16 y75 w180 h242 0x400
    Gui, Add, Edit, x215 y114 w340 h20,                           ;ahk_class Edit1
    Gui, Add, Edit, x215 y174 w340 h100 ReadOnly,                 ;ahk_class Edit2
    Gui, Add, Button, x250 y335 w70 h30 gExitSettings , E&xit     ;ahk_class Button1
    Gui, Add, Button, x505 y88 gBtnBrowseKeyValue Hidden, B&rowse ;ahk_class Button2
    Gui, Add, Button, x215 y274 gBtnDefaultValue, &Restore        ;ahk_class Button3
    Gui, Add, DateTime, x215 y114 w340 h20 Hidden,                ;ahk_class SysDateTimePick321
    Gui, Add, Hotkey, x215 y114 w340 h20 Hidden,                  ;ahk_class msctls_hotkey321
    Gui, Add, DropDownList, x215 y114 w340 h120 Hidden,           ;ahk_class ComboBox1
    Gui, Add, CheckBox, x215 y114 w340 h20 Hidden,                ;ahk_class Button4
    Gui, Add, GroupBox, x4 y63 w560 h263 ,                        ;ahk_class Button5
    Gui, Font, Bold
    Gui, Add, Text, x215 y93, Value                               ;ahk_class Static1
    Gui, Add, Text, x215 y154, Description                        ;ahk_class Static2
    HelpTip = ( All changes are Auto-Saved )
    IfNotEqual, HelpText, 0
	{
    	HelpTip = ( All changes are Auto-Saved - Press F1 for Help )
    	Hotkey, IfWinActive, %ProgName% Settings
    	Hotkey, F1, ShowHelp
    }
    Gui, Add, Text, x45 y48 w480 h20 +Center, %HelpTip%
    Gui, Font, S16 CDefault Bold, Verdana
    Gui, Add, Text, x45 y13 w480 h35 +Center, Settings for %ProgName%

    ;read data from ini file, build tree and store values and description in arrays
    Loop, Read, %IniFile%
      {
        CurrLine = %A_LoopReadLine%
        CurrLineLength := StrLen(CurrLine)

        ;blank line
        If CurrLine is space
            Continue

        ;description (comment) line
        If ( InStr(CurrLine,";") = 1 ){
            StringLeft, chk2, CurrLine, % CurrLength + 2
            StringTrimLeft, Des, CurrLine, % CurrLength + 2
            ;description of key
            If ( %CurrID%Sec = False AND ";" CurrKey A_Space = chk2){
                ;handle key types
                If ( InStr(Des,"Type: ") = 1 ){
                    StringTrimLeft, Typ, Des, 6
                    Typ = %Typ%
                    Des = `n%Des%     ;add an extra line to the type definition in the description control

                    ;handle format or list
                    If (InStr(Typ,"DropDown ") = 1) {
                        StringTrimLeft, Format, Typ, 9
                        %CurrID%For = %Format%
                        Typ = DropDown
                        Des =
                    }Else If (InStr(Typ,"DateTime") = 1) {
                        StringTrimLeft, Format, Typ, 9
                        If Format is space
                            Format = dddd MMMM d, yyyy HH:mm:ss tt
                        %CurrID%For = %Format%
                        Typ = DateTime
                        Des =
                      }
                    ;set type
                    %CurrID%Typ := Typ
                ;remember default value
                }Else If ( InStr(Des,"Default: ") = 1 ){
                    StringTrimLeft, Def, Des, 9
                    %CurrID%Def = %Def%
                ;remember custom options
                }Else If ( InStr(Des,"Options: ") = 1 ){
                    StringTrimLeft, Opt, Des, 9
                    %CurrID%Opt = %Opt%
                    Des =
                ;remove hidden keys from tree
                }Else If ( InStr(Des,"Hidden:") = 1 ){
                    TV_Delete(CurrID)
                    Des =
                    CurrID =
                ;handle checkbox name
                }Else If ( InStr(Des,"CheckboxName: ") = 1 ){
                    StringTrimLeft, ChkN, Des, 14
                    %CurrID%ChkN = %ChkN%
                    Des =
                  }
                %CurrID%Des := %CurrID%Des "`n" Des
            ;description of section
            } Else If ( %CurrID%Sec = True AND ";" CurrSec A_Space = chk2 ){
                ;remove hidden section from tree
                If ( InStr(Des,"Hidden:") = 1 ){
                    TV_Delete(CurrID)
                    Des =
                    CurrSecID =
                  }
                ;set description
                %CurrID%Des := %CurrID%Des "`n" Des
              }

            ;remove leading and trailing whitespaces and new lines
            If ( InStr(%CurrID%Des, "`n") = 1 )
                StringTrimLeft, %CurrID%Des, %CurrID%Des, 1
            Continue
          }

        ;section line
        If ( InStr(CurrLine, "[") = 1 And InStr(CurrLine, "]", "", 0) = CurrLineLength) {
            ;extract section name
            StringTrimLeft, CurrSec, CurrLine, 1
            StringTrimRight, CurrSec, CurrSec, 1
            CurrSec = %CurrSec%
            CurrLength := StrLen(CurrSec)  ;to easily trim name off of following comment lines

            ;add to tree
            CurrSecID := TV_Add(CurrSec)
            CurrID = %CurrSecID%
            %CurrID%Sec := True
            CurrKey =
            Continue
          }

        ;key line
        Pos := InStr(CurrLine,"=")
        If ( Pos AND CurrSecID ){
            ;extract key name and its value
            StringLeft, CurrKey, CurrLine, % Pos - 1
            StringTrimLeft, CurrVal, CurrLine, %Pos%
            CurrKey = %CurrKey%             ;remove whitespaces
            CurrVal = %CurrVal%
            CurrLength := StrLen(CurrKey)

            ;add to tree and store value
            CurrID := TV_Add(CurrKey,CurrSecID)
            %CurrID%Val := CurrVal
            %CurrID%Sec := False

            ;store initial value as default for restore function
            ;will be overwritten if default is specified later on comment line
            %CurrID%Def := CurrVal
          }
      }

    ;select first key of first section and expand section
    TV_Modify(TV_GetChild(TV_GetNext()), "Select")

    ;show Gui and get UniqueID
    Gui, Show, w570 h400, %ProgName% Settings
    Gui, +LastFound
    GuiID := WinExist()

    ;check for changes in GUI
    Loop {
        ;get current tree selection
        CurrID := TV_GetSelection()

        If SetDefault {
            %CurrID%Val := %CurrID%Def
            LastID = 0
            SetDefault := False
            ValChanged := True
          }

        MouseGetPos,,, AWinID, ACtrl
        If ( AWinID = GuiID){
            If ( ACtrl = "Button3")
                SB_SetText("Restores Value to default (if specified), else restores it to initial value before change")
        } Else
            SB_SetText("")

        ;change GUI content if tree selection changed
        If (CurrID <> LastID) {
            ;remove custom options from last control
            Loop, Parse, InvertedOptions, %A_Space%
                GuiControl, %A_Loopfield%, %ControlUsed%

            ;hide/show browse button depending on key type
            Typ := %CurrID%Typ
            If Typ in File,Folder
                GuiControl, Show , Button2,
            Else
                GuiControl, Hide , Button2,

            ;set the needed value control depending on key type
            If (Typ = "DateTime")
                ControlUsed = SysDateTimePick321
            Else If ( Typ = "Hotkey" )
                ControlUsed = msctls_hotkey321
            Else If ( Typ = "DropDown")
                ControlUsed = ComboBox1
            Else If ( Typ = "CheckBox")
                ControlUsed = Button4
            Else                    ;e.g. Text,File,Folder,Float,Integer or No Tyo (e.g. Section)
                ControlUsed = Edit1

            ;hide/show the value controls
            Controls = SysDateTimePick321,msctls_hotkey321,ComboBox1,Button4,Edit1
            Loop, Parse, Controls, `,
                If ( ControlUsed = A_LoopField )
                    GuiControl, Show , %A_LoopField%,
                Else
                    GuiControl, Hide , %A_LoopField%,

            If ( ControlUsed = "Button4" )
                GuiControl,  , Button4, % %CurrID%ChkN

            ;get current options
            CurrOpt := %CurrID%Opt
            ;apply current custom options to current control and memorize them inverted
            InvertedOptions =
            Loop, Parse, CurrOpt, %A_Space%
              {
                ;get actual option name
                StringLeft, chk, A_LoopField, 1
                StringTrimLeft, chk2, A_LoopField, 1
                If chk In +,-
                  {
                    GuiControl, %A_LoopField%, %ControlUsed%
                    If (chk = "+")
                        InvertedOptions = %InvertedOptions% -%chk2%
                    Else
                        InvertedOptions = %InvertedOptions% +%chk2%
                }Else {
                    GuiControl, +%A_LoopField%, %ControlUsed%
                    InvertedOptions = %InvertedOptions% -%A_LoopField%
                  }
              }

            If %CurrID%Sec {                      ;section got selected
                CurrVal =
                GuiControl, , Edit1,
                GuiControl, Disable , Edit1,
                GuiControl, Disable , Button3,
            }Else {                               ;new key got selected
                CurrVal := %CurrID%Val   ;get current value
                GuiControl, , Edit1, %CurrVal%   ;put current value in all value controls
                GuiControl, Text, SysDateTimePick321, % %CurrID%For
                GuiControl, , SysDateTimePick321, %CurrVal%
                GuiControl, , msctls_hotkey321, %CurrVal%
                GuiControl, , ComboBox1, % "|" %CurrID%For
                GuiControl, ChooseString, ComboBox1, %CurrVal%
                GuiControl, , Button4 , %CurrVal%
                GuiControl, Enable , Edit1,
                GuiControl, Enable , Button3,
              }
            GuiControl, , Edit2, % %CurrID%Des
          }
        LastID = %CurrID%                   ;remember last selection

        ;sleep to reduce CPU load
        Sleep, 100

        ;exit endless loop, when settings GUI closes
        If not WinExist("ahk_id" GuiID)
            Break

        ;if key is selected, get value
        If (%CurrID%Sec = False){
            GuiControlGet, NewVal, , %ControlUsed%
            ;save key value when it has been changed
            If ( NewVal <> CurrVal OR ValChanged ) {
                ValChanged := False

                ;consistency check if type is integer or float
                If (Typ = "Integer")
                  If NewVal is not space
                    If NewVal is not Integer
                      {
                        GuiControl, , Edit1, %CurrVal%
                        Continue
                      }
                If (Typ = "Float")
                  If NewVal is not space
                    If NewVal is not Integer
                      If (NewVal <> ".")
                        If NewVal is not Float
                          {
                            GuiControl, , Edit1, %CurrVal%
                            Continue
                          }

                ;set new value and save it to INI
                %CurrID%Val := NewVal
                CurrVal = %NewVal%
                PrntID := TV_GetParent(CurrID)
                TV_GetText(SelSec, PrntID)
                TV_GetText(SelKey, CurrID)
                If (SelSec AND SelKey)
                    IniWrite, %NewVal%, %IniFile%, %SelSec%, %SelKey%
              }
          }
      }

    ;Exit button got pressed
    ExitSettings:
      ;re-enable calling GUI
      If DisableGui {
          Gui, %OwnedBy%:-Disabled
          Gui, %OwnedBy%:,Show
        }
      Gui, Destroy

	IfNotEqual, HelpText, 0
		Hotkey, F1, Off

    ;exit function
    Return 1

    ;browse button got pressed
    BtnBrowseKeyValue:
      ;get current value
      GuiControlGet, StartVal, , Edit1
      Gui, +OwnDialogs

      ;Select file or folder depending on key type
      If (Typ = "File"){
          ;get StartFolder
          IfExist %A_ScriptDir%\%StartVal%
              StartFolder = %A_ScriptDir%
          Else IfExist %StartVal%
              SplitPath, StartVal, , StartFolder
          Else
              StartFolder =

          ;select file
          FileSelectFile, Selected,, %StartFolder%, Select file for %SelSec% - %SelKey%, Any file (*.*)
      }Else If (Typ = "Folder"){
          ;get StartFolder
          IfExist %A_ScriptDir%\%StartVal%
              StartFolder = %A_ScriptDir%\%StartVal%
          Else IfExist %StartVal%
              StartFolder = %StartVal%
          Else
              StartFolder =

          ;select folder
          FileSelectFolder, Selected, *%StartFolder% , 3, Select folder for %SelSec% - %SelKey%

          ;remove last backslash "\" if any
          StringRight, LastChar, Selected, 1
          If LastChar = \
               StringTrimRight, Selected, Selected, 1
        }
      ;If file or folder got selected, remove A_ScriptDir (since it's redundant) and set it into GUI
      If Selected {
          StringReplace, Selected, Selected, %A_ScriptDir%\
          GuiControl, , Edit1, %Selected%
          %CurrID%Val := Selected
        }
    Return  ;end of browse button subroutine

    ;default button got pressed
    BtnDefaultValue:
      SetDefault := True
    Return  ;end of default button subroutine

    ;gui got resized, adjust control sizes
    GuiIniSettingsEditorSize:
      GuiIniSettingsEditorAnchor("SysTreeView321"      , "wh")
      GuiIniSettingsEditorAnchor("Edit1"               , "x")
      GuiIniSettingsEditorAnchor("Edit2"               , "xh")
      GuiIniSettingsEditorAnchor("Button1"             , "xy",true)
      GuiIniSettingsEditorAnchor("Button2"             , "x",true)
      GuiIniSettingsEditorAnchor("Button3"             , "xy",true)
      GuiIniSettingsEditorAnchor("Button4"             , "x",true)
      GuiIniSettingsEditorAnchor("Button5"             , "wh",true)
      GuiIniSettingsEditorAnchor("SysDateTimePick321"  , "x")
      GuiIniSettingsEditorAnchor("msctls_Hotkey321"    , "x")
      GuiIniSettingsEditorAnchor("ComboBox1"           , "x")
      GuiIniSettingsEditorAnchor("Static1"             , "x")
      GuiIniSettingsEditorAnchor("Static2"             , "x")
      GuiIniSettingsEditorAnchor("Static3"             , "x")
      GuiIniSettingsEditorAnchor("Static4"             , "x")
    Return

	ShowHelp:
		MsgBox, 64, %ProgName% Settings Help, %HelpText%
	Return

  }  ;end of function

GuiIniSettingsEditorAnchor(ctrl, a, draw = false) { ; v3.2 by Titan (shortened)
    static pos
    sig = `n%ctrl%=
    If !InStr(pos, sig) {
      GuiControlGet, p, Pos, %ctrl%
      pos := pos . sig . px - A_GuiWidth . "/" . pw  - A_GuiWidth . "/"
        . py - A_GuiHeight . "/" . ph - A_GuiHeight . "/"
    }
    StringTrimLeft, p, pos, InStr(pos, sig) - 1 + StrLen(sig)
    StringSplit, p, p, /
    c = xwyh
    Loop, Parse, c
      If InStr(a, A_LoopField) {
        If A_Index < 3
          e := p%A_Index% + A_GuiWidth
        Else e := p%A_Index% + A_GuiHeight
        m = %m%%A_LoopField%%e%
      }
    If draw
      d = Draw
    GuiControl, Move%d%, %ctrl%, %m%
  }