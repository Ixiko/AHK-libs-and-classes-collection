; LINTALIST NOTE: Made minor changes for Lintalist, if you want to use this 
; function please use the original one which can be found at the link below.
; http://www.autohotkey.com/forum/viewtopic.php?p=69534#69534
; 
; 
; 
;#############   Edit ini file settings in a GUI   #############################
;  A function that can be used to edit settings in an ini file within it's own
;  GUI. Just plug this function into your script.
;
;  by Rajat, mod by toralf
;  www.autohotkey.com/forum/viewtopic.php?p=69534#69534
;
;   Tested OS: Windows XP Pro SP2
;   AHK_version= 1.0.44.09     ;(http://www.autohotkey.com/download/)
;   Language: English
;   Date: 2006-08-23
;
;   Version: 6
;
; changes since 5:
; - add key type "checkbox" with custom control name
; - added key field options (will only apply in Editor window)
; - whole sections can be set hidden
; - reorganized code in Editor and Creator
; - some fixes and adjustments
; changes since 1.4
; - Creator and Editor GUIs are resizeable (thanks Titan). The shortened Anchor function
;    is added with a long name, to avoid nameing conflicts and avoid dependencies.
; - switched from 1.x version numbers to full integer version numbers
; - requires AHK version 1.0.44.09
; - fixed blinking of description field
; changes since 1.3:
; - added field option "Hidden" (thanks jballi)
; - simplified array naming
; - shorted the code
; changes since 1.2:
; - fixed a bug in the description (thanks jaballi and robiandi)
; changes since 1.1:
; - added statusbar (thanks rajat)
; - fixed a bug in Folder browsing
; changes since 1.0:
; - added default value (thanks rajat)
; - fixed error with DisableGui=1 but OwnedBy=0 (thanks kerry)
; - fixed some typos
;  
; format:
; =======
;   IniSettingsEditor(ProgName, IniFile[, OwnedBy = 0, DisableGui = 0])
;
; with
;   ProgName - A string used in the GUI as text to describe the program 
;   IniFile - that ini file name (with path if not in script directory)
;   OwnedBy - GUI ID of the calling GUI, will make the settings GUI owned
;   DisableGui - 1=disables calling GUI during editing of settings
;
; example to call in script:
;   IniSettingsEditor("Hello World", "Settings.ini", 0, 0)
;
; Include function with:
;   #Include Func_IniSettingsEditor_v6.ahk
;
; No global variables needed.
;
; features:
; =========
; - the calling script will wait for the function to end, thus till the settings
;     GUI gets closed. 
; - Gui ID for the settings GUI is not hard coded, first free ID will be used 
; - multiple description lines (comments) for each key and section possible 
; - all characters are allowed in section and key names
; - when settings GUI is started first key in first section is pre-selected and
;     first section is expanded
; - tree branches expand when items get selected and collapse when items get
;     unselected
; - key types besides the default "Text" are supported 
;    + "File" and "Folder", will have a browse button and its functionality 
;    + "Float" and "Integer" with consistency check 
;    + "Hotkey" with its own hotkey control 
;    + "DateTime" with its own datetime control and custom format, default is
;        "dddd MMMM d, yyyy HH:mm:ss tt"
;    + "DropDown" with its own dropdown control, list of choices has to be given
;        list is pipe "|" separated 
;    + "Checkbox" where the name of the checkbox can be customized
; - default value can be specified for each key 
; - keys can be set invisible (hidden) in the tree
; - to each key control additional AHK specific options can be assigned  
;
; format of ini file:
; ===================
;     (optional) descriptions: to help the script's users to work with the settings 
;     add a description line to the ini file following the relevant 'key' or 'section'
;     line, put a semi-colon (starts comment), then the name of the key or section
;     just above it and a space, followed by any descriptive helpful comment you'd
;     like users to see while editing that field. 
;     
;     e.g.
;     [SomeSection]
;     ;somesection This can describe the section. 
;     Somekey=SomeValue 
;     ;somekey Now the descriptive comment can explain this item. 
;     ;somekey More then one line can be used. As many as you like.
;     ;somekey [Type: key type] [format/list] 
;     ;somekey [Default: default key value] 
;     ;somekey [Hidden:] 
;     ;somekey [Options: AHK options that apply to the control] 
;     ;somekey [CheckboxName: Name of the checkbox control] 
;     
;     (optional) key types: To limit the choice and get correct input a key type can
;     be set or each key. Identical to the description start an extra line put a
;     semi-colon (starts comment), then the name of the key with a space, then the
;     string "Type:" with a space followed by the key type. See the above feature
;     list for available key types. Some key types have custom formats or lists,
;     they are written after the key type with a space in-between.
;     
;     (optional) default key value: To allow a easy and quick way back to a 
;     default value, you can specify a value as default. If no default is given,
;     users can go back to the initial key value of that editing session.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "Default:" with a space followed by the default value.
;
;     (optional) hide key in tree: To hide a key from the user, a key can be set 
;     hidden.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "Hidden:".
;
;     (optional) add additional AHK options to key controls. To limit the input
;     or enforce a special input into the key controls in the GUI, additional 
;     AHK options can be specified for each control.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "Options" with a space followed by a list of AHK options for that
;     AHK control (all separated with a space).
;
;     (optional) custom checkbox name: To have a more relavant name then e.g.
;     "status" a custom name for the checkbox key type can be specified.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "CheckboxName:" with a space followed by the name of the checkbox.
;
;
; limitations:
; ============
; - ini file has to exist and created manually or with the IniFileCreator script
; - section lines have to start with [ and end with ]. No comments allowed on
;     same line
; - ini file must only contain settings. Scripts can't be used to store setting,
;     since the file is read and interpret as a whole. 
; - code: can't use g-labels for tree or edit fields, since the arrays are not
;     visible outside the function, hence inside the g-label subroutines. 
; - code: can't make GUI resizable, since this is only possible with hard
;     coded GUI ID, due to %GuiID%GuiSize label

IniSettingsEditor(ProgName,IniFile,OwnedBy = 0,DisableGui = 0) {
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
    Gui, Add, TreeView, x16 y75 w200 h370 0x400
    Gui, Add, Edit, x225 y114 w400 h20,                           ;ahk_class Edit1
    Gui, Add, Edit, x225 y174 w400 h200 ReadOnly,                 ;ahk_class Edit2
    Gui, Add, Button, x490 y420 w100 gExitSettings , E&xit     ;ahk_class Button1
    Gui, Add, Button, x565 y88  gBtnBrowseKeyValue Hidden, B&rowse ;ahk_class Button2
    Gui, Add, Button, x225 y420 gBtnDefaultValue, &Restore        ;ahk_class Button3
    Gui, Add, DateTime, x225 y114 w340 h20 Hidden,                ;ahk_class SysDateTimePick321
    Gui, Add, Hotkey, x225 y114 w340 h20 Hidden,                  ;ahk_class msctls_hotkey321
    Gui, Add, DropDownList, x225 y114 w340 h120 Hidden,           ;ahk_class ComboBox1 
    Gui, Add, CheckBox, x225 y114 w340 h20 Hidden,                ;ahk_class Button4 
    Gui, Add, GroupBox, x4 y63 w640 h390 ,                        ;ahk_class Button5
    Gui, Font, Bold 
    Gui, Add, Text, x225 y93, Value                               ;ahk_class Static1
    Gui, Add, Text, x225 y154, Description                        ;ahk_class Static2
    Gui, Add, Text, x15 y48 w650 h20 +Center, (All changes are Auto-Saved - A Reload may be needed for changes to have affect) 
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
    TV_Modify(CurrSecID, "Sort") ; modification lintalist
    Gui, Show, w650 h490, %ProgName% Settings 
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
            If Typ in File,Folder,Exe
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
    ;exit function 
    Return 1
    
    ;browse button got pressed
    BtnBrowseKeyValue: 
      ;get current value
      GuiControlGet, StartVal, , Edit1 
      Gui, +OwnDialogs 
      
      ;Select file or folder depending on key type
      If (Typ = "File"){ 
;          ;get StartFolder
;          IfExist %A_ScriptDir%\%StartVal% 
;              StartFolder = %A_ScriptDir% 
;          Else IfExist %StartVal% 
;              SplitPath, StartVal, , StartFolder 
;          Else 
;              StartFolder = 
;           ;select file LINTALIST "FIX"
					StartFolder:=A_ScriptDir
          FileSelectFile, Selected,M , %StartFolder%\bundles\, Select file for %SelSec% - %SelKey%, Any file (*.txt)  
      }

else      If (Typ = "Exe"){ 
		  StartFolder:=A_ScriptDir
          FileSelectFile, Selected, , %StartFolder%\bundles\, Select EXE for Snippet Editor, (*.exe) 
      }
          
      Else If (Typ = "Folder"){ 
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
          StringReplace, Selected, Selected, %A_ScriptDir%\bundles
          StringReplace, Selected, Selected, `n, `, , All
          StringReplace, Selected, Selected, `r,  , , All
          If (SubStr(Selected,1,1) = ",")
          	StringTrimLeft, Selected, Selected, 1
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
