/*
Func: guiAddonInfo
    Form to edit or create addoninfo.txt files used by source engine addons to display addon information ingame

Parameters:
    SourceFile		- (optional) path to existing addoninfo.txt file

Returns:
    ErrorLevel if
		SourceFile is specified and is not a text file
		Form was closed without saving
		
Examples:
    > guiAddonInfo()
    = returns addoninfo file var when form is saved
	
	> guiAddonInfo("e:\downloads\addoninfo.txt")
	= loads file into form and deletes&rewrites file when form is saved
	
Required libs:
	StringBetween.ahk
*/
guiAddonInfo(SourceFile="") {
	global
	
	OutPut := ""
	
	gui addonInfo: Default
	gui addonInfo: Margin, 5, 5
	gui addonInfo: +AlwaysOnTop +Hwnd_guiAddonInfo +LabelguiAddonInfo_

	gui addonInfo: Add, Text, section, SteamAppID
	gui addonInfo: Add, Edit, vaddonSteamAppID w120 r1, %addonSteamAppID%
	gui addonInfo: Add, Text, , Title
	gui addonInfo: Add, Edit, vaddonTitle w120 r1, %addonTitle%
	gui addonInfo: Add, Text, , Version
	gui addonInfo: Add, Edit, vaddonVersion w120 r1, %addonVersion%
	gui addonInfo: Add, Text, , Tagline
	gui addonInfo: Add, Edit, vaddonTagline w120 r1, %addonTagline%
	gui addonInfo: Add, Text, , Author
	gui addonInfo: Add, Edit, vaddonAuthor w120 r1, %addonAuthor%
	gui addonInfo: Add, Text, , AuthorSteamID
	gui addonInfo: Add, Edit, vaddonAuthorSteamID w120 r1, %addonAuthorSteamID%
	gui addonInfo: Add, Text, , SteamGroupName
	gui addonInfo: Add, Edit, vaddonSteamGroupName w120 r1, %addonSteamGroupName%
	gui addonInfo: Add, Text, , URL
	gui addonInfo: Add, Edit, vaddonURL0 w120 r1, %addonURL0%
	gui addonInfo: Add, Text, , Description
	gui addonInfo: Add, Edit, vaddonDescription w240 r3, %addonDescription%

	gui addonInfo: Add, Button, w240 r1 gguiAddonInfo_btnSave, Save
	
	gui addonInfo: Add, Text, xs+130 ys, Game Modes
	gui addonInfo: Add, Checkbox, checked%addonContent_Campaign% Checked0 vaddonContent_Campaign, Campaign
	gui addonInfo: Add, Checkbox, checked%addonContent_Survival% Checked0 vaddonContent_Survival, Survival
	gui addonInfo: Add, Checkbox, checked%addonContent_Scavenge% Checked0 vaddonContent_Scavenge, Scavenge
	gui addonInfo: Add, Checkbox, checked%addonContent_Versus% Checked0 vaddonContent_Versus, Versus
	gui addonInfo: Add, Checkbox, checked%addonContent_Map% Checked0 vaddonContent_Map, Map

	gui addonInfo: Add, Text, , Skin
	gui addonInfo: Add, Checkbox, checked%addonContent_Survivor% Checked0 vaddonContent_Survivor, Survivor
	gui addonInfo: Add, Checkbox, checked%addonContent_Skin% Checked0 vaddonContent_Skin, Skin

	gui addonInfo: Add, Text, , Misc
	gui addonInfo: Add, Checkbox, checked%addonContent_BossInfected% Checked0 vaddonContent_BossInfected, BossInfected
	gui addonInfo: Add, Checkbox, checked%addonContent_CommonInfected% Checked0 vaddonContent_CommonInfected, CommonInfected
	gui addonInfo: Add, Checkbox, checked%addonContent_Music% Checked0 vaddonContent_Music, Music
	gui addonInfo: Add, Checkbox, checked%addonContent_Sound% Checked0 vaddonContent_Sound, Sound
	gui addonInfo: Add, Checkbox, checked%addonContent_Prop% Checked0 vaddonContent_Prop, Prop
	gui addonInfo: Add, Checkbox, checked%addonContent_Prefab% Checked0 vaddonContent_Prefab, Prefab
	gui addonInfo: Add, Checkbox, checked%addonContent_Spray% Checked0 vaddonContent_Spray, Spray
	gui addonInfo: Add, Checkbox, checked%addonContent_Script% Checked0 vaddonContent_Script, Script
	gui addonInfo: Add, Checkbox, checked%addonContent_BackgroundMovie% Checked0 vaddonContent_BackgroundMovie, BackgroundMovie
	
	gui addonInfo: Add, Link, y+10, <a href="https://developer.valvesoftware.com/wiki/Deadline_AddonInfo_File">Help</a>
	
	Gosub guiAddonInfo_readSourceFile
	
	gui addonInfo: Show, x0 y0
	WinWaitClose, % "ahk_id " _guiAddonInfo
	gui addonInfo: Destroy
	If (OutPut = "")
		return ErrorLevel := 1
	else
		return OutPut
	
	guiAddonInfo_close:
		gui addonInfo: destroy
	return
	
	guiAddonInfo_readSourceFile:
		If !(SourceFile = "") ; read addonfile if specified
		{
			SplitPath, SourceFile, , , SourceFileExt
			If !(SourceFileExt = "txt")
				return ErrorLevel := 1
			FileRead, addonInfo, % SourceFile
			
			loop, parse, addonInfo, `n
			{
				StringReplace, LoopField, A_LoopField, ", ", UseErrorLevel
				LoopFieldQuoteCount := ErrorLevel

				If (LoopFieldQuoteCount = 2) ; assumed layout: addonSteamAppID		"550"
				{
					key := SubStr(A_LoopField, 1, InStr(A_LoopField, """") - 1)
					key := Trim(key)
					value := StringBetween(A_LoopField, """", """")
				}
				If (LoopFieldQuoteCount = 4) ; assumed layout: "addonSteamAppID"		"550"
				{
					key := StringBetween(A_LoopField, """", """") ; key is first value between quotes
					
					StringReplace, value, A_LoopField, % """" key """" ; remove key from line to build value var
					StringReplace, value, value, ", , All ; " ; remove quotes
					StringReplace, value, value, `r, , All ; remove enters
					value := Trim(value) ; remove empty space
				}

				GuiControl addonInfo: , % key, % value
			}
		}
	return
	
	guiAddonInfo_btnSave:
		gui addonInfo: Submit, NoHide
		
		StringReplace, addonDescription, addonDescription, `n, , All ; remove enters from description
		
		OutPut =
		(
"AddonInfo"
{
	"addonSteamAppID"				"%addonSteamAppID%"
	"addonTitle"					"%addonTitle%"
	"addonVersion"					"%addonVersion%"
	"addonTagline"					"%addonTagline%"
	"addonAuthor"					"%addonAuthor%"
	"addonAuthorSteamID"			"%addonAuthorSteamID%"
	"addonSteamGroupName"			"%addonSteamGroupName%"
	"addonURL0"						"%addonURL0%"
 
	"addonContent_Campaign"			"%addonContent_Campaign%"
	"addonContent_Survival"			"%addonContent_Survival%"
	"addonContent_Scavenge"			"%addonContent_Scavenge%"
	"addonContent_Versus"			"%addonContent_Versus%"
	"addonContent_Map"				"%addonContent_Map%"
 
	"addonContent_Survivor"			"%addonContent_Survivor%"
	"addonContent_Skin"				"%addonContent_Skin%"
 
	"addonContent_BossInfected"		"%addonContent_BossInfected%"
	"addonContent_CommonInfected"	"%addonContent_CommonInfected%"
	"addonContent_Music"			"%addonContent_Music%"
	"addonContent_Sound"			"%addonContent_Sound%"
	"addonContent_Prop"				"%addonContent_Prop%"
	"addonContent_Prefab"			"%addonContent_Prefab%"
	"addonContent_Spray"			"%addonContent_Spray%"
	"addonContent_Script"			"%addonContent_Script%"
	"addonContent_BackgroundMovie"	"%addonContent_BackgroundMovie%"

	"addonDescription"				"%addonDescription%"
 }
		)
		
		If !(SourceFile = "")
		{
			FileDelete, % SourceFile
			FileAppend, % OutPut, % SourceFile
		}
		
		gui addonInfo: Destroy
	return
}