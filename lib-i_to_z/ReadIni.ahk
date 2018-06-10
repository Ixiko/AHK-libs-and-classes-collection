; LintaList Include
; Purpose: Read INI
; Version: 1.5
; Date:    20150328

ReadIni()
	{
	 Global
	 local ini
	 ini=%A_ScriptDir%\%IniFile%
	 IfNotExist, %ini%
	 	{
		 CreateDefaultIni()
		 Gosub, SetShortcuts ; (#Include from main script)
		} 

/*
			, Keyname {default:"",find:"",replace:"",empty:"",min:"",max:""}
default:      default value if keyname is not found
find/replace: clean up setting
empty:        explicit option if keyname is found to be empty
min/max:      minimum / maximum settings for numerical values
*/

;			, Keyname {default:"",find:"",replace:"",empty:"",min:"",max:""}
INISetup:={ AlwaysLoadBundles:     {default:"",find:"bundles\"}
			, LastBundle:          {default:"default.txt"}
			, DefaultBundle:       {default:"default.txt",find:"bundles\"}
			, MinLen:              {default:"1"}
			, SortByUsage:         {default:"1"}
			, MaxRes:              {default:"100"}
			, SearchMethod:        {default:"1"}
			, StartSearchHotkey:   {default:"Capslock",empty:"Capslock"}
			, StartOmniSearchHotkey: {default:"^Capslock"}
			, QuickSearchHotkey:   {default:"#z"}
			, ExitProgramHotKey:   {default:"^#q"}
			, CompactWidth:        {default:"450",min:"300"}
			, CompactHeight:       {default:"450",min:"300"}
			, WideWidth:           {default:"760",min:"300"}
			, WideHeight:          {default:"400",min:"300"}
			, Width:               {default:"450"}
			, Height:              {default:"400"}
			, PreviewHeight:       {default:"102"}
			, ShowIcons:           {default:"1"}
			, Icon1:               {default:"TextIcon.ico"}
			, Icon2:               {default:"ScriptIcon.ico"}
			, SendMethod:          {default:"3"}
			, PasteDelay:          {default:"10"}
			, TriggerKeys:         {default:"Tab,Space"}
			, DoubleClickSends:    {default:"1"}
			, Load:                {default:"0"}
			, LoadAll:             {default:"0"}
			, Lock:                {default:"0"}
			, Case:                {default:"0"}
			, ShorthandPaused:     {default:"0"}
			, ShortcutPaused:      {default:"0"}
			, ScriptPaused:        {default:"0"}
			, Center:              {default:"0"}
			, MouseAlternative:    {default:"1"}
			, Mouse:               {default:"0"}
			, PreviewSection:      {default:"1"}
			, ShowGrid:            {default:"0"}
			, Counters:            {default:"0"}
			, SetStartup:          {default:"0"}
			, SetDesktop:          {default:"0"}
			, ShowQuickStartGuide: {default:"1"}
			, ActivateWindow:      {default:"0"}
			, OnPaste:             {default:"0"}
			, PasteMethod:         {default:"0"}
			, AlwaysUpdateBundles: {default:"0"}
			, AutoExecuteOne:      {default:"0"}
			, SingleClickSends:    {default:"0"}
			, OmniChar:            {default:"@"}
			, DisplayBundle:       {default:"0"}
			, ColumnWidth:         {default:"50-50"}
			, ColumnSort:          {default:"NoSort"}
			, SearchLetterVariations: {default:"0"}
			, Font:                {default:"Arial"}
            , FontSize:            {default:"10"}
            , PlaySound:           {default:""}
            , SnippetEditor:       {default:""} }

	 for k, v in INISetup
		{
		 IniRead, %k%  ,%ini%, settings, %k%
		 If (%k% = "ERROR")
			{
			 Append2Ini(k,ini)
			 IniRead, %k%  ,%ini%, settings, %k%, % v.default
			}
		 if v.find
			StringReplace, %k%, %k%, % v.find, % v.replace, All
		 if (%k% = "")
			%k%:=v.empty
		 if v.min
		 	if (%k% < v.min)	
				%k%:=v.min
		 if v.max
			if (%k% > v.max)	
				%k%:=v.max
		}

		; finalise certain settings
		SplitPath, Icon1, , , , Icon1 ; trim ext
		SplitPath, Icon2, , , , Icon2 ; trim ext

		StringSplit, ColumnWidthPart, ColumnWidth, -

		if (ColumnSort <> "NoSort")
			{
			 StringSplit, ColumnSortOption, ColumnSort, -
			 if (ColumnSortOption1 = "Part1")
				ColumnSortOption1:=1
			 else	
				ColumnSortOption1:=2
			}
			

		Loop, parse, TriggerKeys, CSV
			{
			 TmpKey = %A_LoopField%
			 TmpTriggerKeys .= "EndKey:" TmpKey ","
			 TmpKey =
			 }
		StringTrimRight, TmpTriggerKeys,TmpTriggerKeys,1
		TriggerKeys:=TmpTriggerKeys
		TmpTriggerKeys=

		If (ShowGrid = 0)
			ShowGrid =
		Else
			ShowGrid = Grid

	 ReadCountersIni()
	 ReadPlaySoundIni()
	}                         

Append2Ini(Setting,file)
	{
	 FileRead, New2IniFile, %A_ScriptDir%\include\settings\%Setting%.ini
	 FileAppend, `n%New2IniFile%, %file%
	 Sleep 100
	}

ReadCountersIni()
	{
	 Global
	 If (Counters <> 0) or (Counters <> "")
	 	{
	 	 LocalCounter_0=
	 	 Loop, parse, counters, |
	 	 	{
	 	 	 If (A_LoopField = "")
	 	 	 	Continue
	 	 	 StringSplit, _ctemp, A_LoopField, `,
	 	 	 LocalCounter_%_ctemp1% := _ctemp2
	 	 	 LocalCounter_0 .= _ctemp1 ","
	 	 	 _ctemp1=
	 	 	 _ctemp2=
	 	 	}
	 	}  
	}

ReadPlaySoundIni()
	{
	 Global
	 local ini
	 ini=%A_ScriptDir%\Sound.ini
	 IfNotExist, %ini%
	 	FileCopy, %A_ScriptDir%\Extras\sounds\Sound.ini.txt, %ini%
	 IniRead, playsound_1_open , %ini%, 1, open,  %A_Space%
	 IniRead, playsound_1_paste, %ini%, 1, paste, %A_Space%
	 IniRead, playsound_1_close, %ini%, 1, close, %A_Space%
	 IniRead, playsound_2_open , %ini%, 2, open,  %A_Space%
	 IniRead, playsound_2_paste, %ini%, 2, paste, %A_Space%
	 IniRead, playsound_2_close, %ini%, 2, close, %A_Space%
	 IniRead, playsound_3_open , %ini%, 3, open,  %A_Space%
	 IniRead, playsound_3_paste, %ini%, 3, paste, %A_Space%
	 IniRead, playsound_3_close, %ini%, 3, close, %A_Space%
	}
	
CreateDefaultIni()
	{
	 Global IniFile
	 NewIni=
	 (
`; Lintalist uses a modified version of Func_IniSettingsEditor, http://www.autohotkey.com/forum/viewtopic.php?p=69534#69534
`;     ;functions remarks
`;     ;[SomeSection]
`;     ;somesection This can describe the section. 
`;     Somekey=SomeValue 
`;     ;somekey Now the descriptive comment can explain this item. 
`;     ;somekey More then one line can be used. As many as you like.
`;     ;somekey [Type: key type] [format/list] 
`;     ;somekey [Default: default key value] 
`;     ;somekey [Hidden:] 
`;     ;somekey [Options: AHK options that apply to the control] 
`;     ;somekey [CheckboxName: Name of the checkbox control] 
[Settings]

)
FileAppend, %NewIni%, %A_ScriptDir%\%IniFile%
}

