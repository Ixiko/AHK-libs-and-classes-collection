; LintaList Include
; Purpose: Load and Parse LintaList Bundles at startup into memory
;          and later determine which one to load
; Version: 1.3
; Date:    20170204

WhichBundle() ; determine which bundle to use based on active window (titlematch)
	{
	 global 
	 ;ToolTip, % load, 0,0 ; debug
	 If (LoadAll = 1)
		{
		 Load:=Group
		 Return
		}	 
	 If (Lock = 1) ; Load was already set by FileMenu or was locked by user
		 Return
	 Load= ; clear
	 Loop, parse, group, CSV ; detect which list to use
		{
		 MatchList:=TitleMatchList_%A_LoopField%
		 MatchList=%MatchList% ; autotrim
		 ;MsgBox % MatchList ; debug
		 If RegExMatch(MatchList,"^!") ; v1.9 adding NOT active match issue #30
			{
			 MatchList:=SubStr(MatchList,2)
			 If ActiveWindowTitle not contains %MatchList%
				{
				 Load .= A_LoopField ","
				}
			}
		 Else
			If ActiveWindowTitle contains %MatchList%
				{
				 Load .= A_LoopField ","
				}
		}
	 If (Load = "") ; Load default bundle if no match found, default is set in ini DefaultBundleIndex is defined in LoadAllBundles() 
		Load .= DefaultBundleIndex ","
	 Load .= AlwaysLoadBundles ","	
	 StringTrimRight, Load, Load, 1
	 If (SubStr(Load, 0) = ",") ; if trailing , remove
		StringTrimRight, Load, Load, 1
	 Sort, Load, U D, ; remove duplicates if any (might be added via AlwaysLoadBundles)
	 Return Load	
	}
	
LoadBundle(Reload="")
	{
	 Global
	 ;MsgBox % "x" Snippet[1,1,1] ; debug
	 Gui, 1:Default
	 LV_Delete()
	 If (ReLoad = "")
		WhichBundle()
	 Else
		Load:=Reload
	 Col2=0
	 Col3=0
	 Col4=0
	 Loop, parse, MenuName_HitList, |
		{
		 StringSplit, MenuText, A_LoopField, % Chr(5)
		 Menu, file, UnCheck, &%MenuText1%
		}

	 ; setup imagelist and define icons
	 #IncludeAgain %A_ScriptDir%\include\ImageList.ahk

	 Loop, Parse, Load, CSV
	 {
	  Bundle:=A_LoopField
	  MenuItem:=MenuName_%Bundle%
	  If (MenuItem <> "") ; just to be sure
			Menu, file, Check, &%MenuItem%

	  Max:=Snippet[Bundle].MaxIndex()
	  Max:=MaxRes
	  Loop, % max
		{
		 If (Snippet[Bundle,A_Index,"1v"] = "" AND Snippet[Bundle,A_Index,"2v"] = "" AND Snippet[Bundle,A_Index,3] = "" AND Snippet[Bundle,A_Index,4] = "" AND Snippet[Bundle,A_Index,5] = "")
			Continue

		 IconVal:=""
		 IfEqual, ShowIcons, 1
			{
			 IconVal:=SetIcon(Snippet[Bundle,A_Index],Snippet[Bundle,A_Index,5])
			}
		 LV_Add(IconVal,Snippet[Bundle,A_Index,"1v"],Snippet[Bundle,A_Index,"2v"],Snippet[Bundle,A_Index,3],Snippet[Bundle,A_Index,4],Bundle . "_" . A_Index, MenuName_%Bundle%) ; populate listview
	
		 If (Snippet[Bundle,A_Index,"2v"] <> "") ; part2 e.g. shift+enter
			Col2 = 1
		 If (Snippet[Bundle,A_Index,3] <> "")  ; key
			Col3 = 1
		 If (Snippet[Bundle,A_Index,4] <> "")  ; shorthand
			Col4 = 1
		}
	 }	
	 If (DisplayBundle > 1)
	 	Gosub, ColorList
	 Return	
	}

LoadAllBundles()
	{
	 Global
	 local AvailableBundles, Changed
	 Snippet:={}
	 AvailableBundles=
	 Load=
	 Loop, %A_ScriptDir%\Bundles\*.txt
		AvailableBundles .= A_LoopFileName ","
	 StringTrimRight, AvailableBundles, AvailableBundles, 1 ; trim trailing
	 If (AvailableBundles = "")
		{
		 AvailableBundles:=CreateFirstBundle()
		} 
	 Changed:=AlwaysLoadBundles	
	 Loop, parse, AlwaysLoadBundles, CSV
		{
		 If A_LoopField in %AvailableBundles%
			Continue
		 Stringreplace, AlwaysLoadBundles, AlwaysLoadBundles, %A_LoopField%, , all
		}
	 If (Changed <> AlwaysLoadBundles)
		{
		 Sort, AlwaysLoadBundles, U D`,
		 If (SubStr(AlwaysLoadBundles, 0) = ",") ; if it has changed write to ini so it will be faster at next startup. The Bundle isn't there so no need to try and load it again next time around.
			StringTrimRight, AlwaysLoadBundles, AlwaysLoadBundles, 1
		 If (SubStr(AlwaysLoadBundles, 1, 1) = ",") ; if it has changed write to ini so it will be faster at next startup. The Bundle isn't there so no need to try and load it again next time around.
			StringTrimLeft, AlwaysLoadBundles, AlwaysLoadBundles, 1
		 IniWrite, %AlwaysLoadBundles%, %IniFile%, Settings, AlwaysLoadBundles
		}
	 Changed:=LastBundle
	 Loop, parse, LastBundle, CSV
		{
		 If A_LoopField in %AvailableBundles%
			Continue
		 Stringreplace, LastBundle, LastBundle, %A_LoopField%, , all
		}
	 If (Changed <> LastBundle)
		{
		 Sort, LastBundle, U D`,
		 If (SubStr(LastBundle, 0) = ",") ; if it has changed write to ini so it will be faster at next startup. The Bundle isn't there so no need to try and load it again next time around.
			StringTrimRight, LastBundle, LastBundle, 1
		 If (SubStr(LastBundle, 1, 1) = ",") ; if it has changed write to ini so it will be faster at next startup. The Bundle isn't there so no need to try and load it again next time around.
			StringTrimLeft, LastBundle, LastBundle, 1
		 IniWrite, %LastBundle%, %IniFile%, Settings, LastBundle
	}		 	 
	 If (LastBundle	= "") and (Lock = 1)
		Lock=0 ; unlock as it won't be able to load the bundle that was last locked anyway
	 Changed:=DefaultBundle
	 Loop, parse, DefaultBundle, CSV
		{
		 If A_LoopField in %AvailableBundles%
			Continue
		 Stringreplace, DefaultBundle, DefaultBundle, %A_LoopField%, , all
		}
	 If (Changed <> DefaultBundle)
		{
		 Sort, DefaultBundle, U D`,
		 If (SubStr(DefaultBundle, 0) = ",") ; if it has changed write to ini so it will be faster at next startup. The Bundle isn't there so no need to try and load it again next time around.
			StringTrimRight, DefaultBundle, DefaultBundle, 1
		 If (SubStr(DefaultBundle, 1, 1) = ",") ; if it has changed write to ini so it will be faster at next startup. The Bundle isn't there so no need to try and load it again next time around.
			StringTrimLeft, DefaultBundle, DefaultBundle, 1
		 IniWrite, %DefaultBundle%, %IniFile%, Settings, DefaultBundle
	}		
	 Loop, parse, AvailableBundles, CSV
		{
		 If (A_LoopField = DefaultBundle)
			 DefaultBundleIndex:=A_Index ; default bundle defined in INI setting
		 If A_LoopField in %LastBundle%
			 Load .= A_Index ","
		 If A_LoopField in %AlwaysLoadBundles%
			 StringReplace, AlwaysLoadBundles, AlwaysLoadBundles, %A_LoopField%, %A_Index%, All
		 ReadBundle(A_LoopField, A_Index)
		}	
	 StringTrimRight, Load, Load, 1   ; remove trailing ,
	 StringTrimRight, Group, Group, 1 ; remove trailing ,
	 StringTrimRight, MenuName_HitList, MenuName_HitList, 1 ; remove trailing |
	 Sort, MenuName_HitList, D|
	 Return		
	}

ReadBundle(File, Counter)
	{
	 Global
	 IfInString,file,\
		FileRead, CBundle, %File%
	 Else
		FileRead, CBundle, %A_ScriptDir%\Bundles\%File%
	 ParseBundle(SubStr(CBundle, InStr(CBundle, "- LLPart1:")), Counter)                       ; Create arrays out of ...
	 Group .= Counter ","
	 FileName_%Counter%:=File
	 Loop, Parse, CBundle, `n, `r ; get the various properties of the bundle
		{
		 IfInString, A_LoopField, Name:
			{
			 MenuName_%Counter%:=RegExReplace(A_LoopField, "i)^Name:\s*(.*)\s*$", "$1")
			 If (MenuName_%Counter% = "")
				MenuName_%Counter%:=File ; safety check, fall back to filename if no name was found
			 MenuName_HitList .= MenuName_%Counter% Chr(5) Counter "|"
			 MenuName_0++
			} 
		 IfInString, A_LoopField, Description:
			 Description_%Counter%:=RegExReplace(A_LoopField, "i)^Description:\s*(.*)\s*$", "$1")
		 IfInString, A_LoopField, Author:
			 Author_%Counter%:=RegExReplace(A_LoopField, "i)^Author:\s*(.*)\s*$", "$1")
		 IfInString, A_LoopField, TitleMatch:
			 TitleMatchList_%Counter%:=RegExReplace(A_LoopField, "i)^TitleMatch:\s*(.*)\s*$", "$1")
		 IfInString, A_LoopField, Patterns:
			 Break
		}
	 CBundle=
	}

LoadPersonalBundle()
	{
	 Global
	 IfNotExist, %A_ScriptDir%\local\local.txt
		FileCopy, %A_ScriptDir%\local\example\local.txt, %A_ScriptDir%\local\local.txt, 1
	 FileRead, CBundle, %A_ScriptDir%\local\local.txt
	 Patterns:=RegExReplace(SubStr(CBundle, InStr(CBundle, "Patterns:") + 10),"im)\s*- LLVarName:\s*", Chr(5)) ; prepare split per pattern lintalist bundles
	 Patterns:=Ltrim(patterns,"`r`n")
	 Patterns:=RegExReplace(Patterns,"im)\s*LLContent:\s*", Chr(7)) ; prepare split per pattern local bundles
	 StringSplit, __loc, Patterns, % Chr(5) 
	 Loop, % __loc0 ; %
		{
		 StringSplit, __pers, __loc%A_Index%, % Chr(7) ; %
		 LocalVar_%__pers1% := __pers2
		 LocalVarMenu .= __pers1 ","
		 __pers1= ; free mem
		 __pers2=
		 __loc%A_Index%=
		}
	 Patterns= ; free mem
	 LocalVarMenu:=Rtrim(LocalVarMenu,",")
	 Return	
	}
	
SaveUpdatedBundles(tosave="") ; Save any updated Bundles on Exit of Application OR specific bundle (AlwaysUpdateBundles setting)
	{
	 Global
	 if (tosave <> "")
		{
		 OldGroup:=Group
		 Group:=tosave
		}

	 Loop, parse, Group, CSV
		{
		 Bundle:=A_LoopField
		 If (Snippet[Bundle,"Save"] = 1)
			{
			 Snippet[Bundle,"Save"] := 0 ; now we can't update it twice by accident
			 Append=
			 File=
			 BakFile=
			 Loop, % Snippet[Bundle].MaxIndex() ; %
				{
				 If (Snippet[Bundle,A_Index,1] = "" AND Snippet[Bundle,A_Index,2] = "" AND Snippet[Bundle,A_Index,3] = "" AND Snippet[Bundle,A_Index,4] = "" AND Snippet[Bundle,A_Index,5] = "") ; skip empty snippets
					Continue
				 Append .= "- LLPart1: " Snippet[Bundle,A_Index,1] "`n  LLPart2: " Snippet[Bundle,A_Index,2] "`n  LLKey: " Snippet[Bundle,A_Index,3] "`n  LLShorthand: " Snippet[Bundle,A_Index,4] "`n  LLScript: " Snippet[Bundle,A_Index,5] "`n" 
				} 
				 File    := A_ScriptDir "\bundles\" FileName_%Bundle%
				 BakFile := A_ScriptDir "\bundles\backup\" FileName_%Bundle%
			 FileMove, %file%, %BakFile%, 1                ; create backup
			 If (ErrorLevel > 0)                           ; move not successful, backup dir may be missing
				{
				 IfNotExist, %A_ScriptDir%\bundles\backup\ ; check
				 	FileCreateDir %A_ScriptDir%\bundles\backup\ 
				 FileMove, %file%, %BakFile%, 1            ; create backup (try again)
				 If (ErrorLevel > 0)                       ; still no success, so no backup just delete
					FileDelete, %file%
				 If (ErrorLevel > 0)
					{
					 MsgBox, 48, Not saved, Could not save Bundle`n%file%`n`nWill try to save as %file%.BAK
					 File := A_ScriptDir "\bundles\" FileName_%Bundle% ".BAK"
					 FileDelete, %File%
					}	
				}
			 BundleName:=MenuName_%Bundle%
			 BundleDescription:=Description_%Bundle%
			 BundleAuthor:=Author_%Bundle%
			 BundleTitleMatch:=TitleMatchList_%Bundle%
			 FileAppend, 
(
BundleFormat: 1
Name: %BundleName%
Description: %BundleDescription%
Author: %BundleAuthor%
TitleMatch: %BundleTitleMatch%
Patterns:
%Append%
), %file%
			}
		}

	 if (tosave <> "")
		 Group:=OldGroup
	}
	
ParseBundle(Patterns, Counter)
	{
	 global
	 local list,fix1,fix2
	 ; checking for new empty bundle - we still need to create an object to ensure it will work correctly
	 If !InStr(Patterns,"- LLPart1")
		{
		 ShortHandHitList_%Counter% := Chr(5)
		 HotKeyHitList_%Counter% := Chr(5) 
		 Snippet[Counter,1,1]:=""
		 Snippet[Counter,1,2]:=""
		 Snippet[Counter,1,3]:=""
		 Snippet[Counter,1,4]:=""
		 Snippet[Counter,1,5]:=""
		 Snippet[Counter,1,"1v"]:=""
		 Snippet[Counter,1,"2v"]:=""
		 Return
		}
	 ; /checking for new empty bundle
	 Patterns:=RegExReplace(Patterns,"im)\s*- LLPart1:\s*LLPart2:\s*LLKey:\s*LLShorthand:\s*LLScript:\s*", "") ; remove empty snippets from bundle
	 Patterns:=RegExReplace(Patterns,"im)\s*- LLPart1:\s*", Chr(5)) ; prepare split per pattern/snippet
	 StringTrimLeft, Patterns, Patterns, 1                          ; trim first Chr(5) to prevent empty array element
	 Patterns:=RegExReplace(Patterns,"im)\s*LLPart2:\s*|\s*LLKey:\s*|\s*LLShorthand:\s*|\s*LLScript:\s*", Chr(7)) ; prepare split for each pattern in to an array elements
	 StringSplit, list, Patterns, % Chr(5) ; split pattern 
	 ;MsgBox % Snippet[Counter,1]
	 ShortHandHitList_%Counter% := Chr(5)
	 HotKeyHitList_%Counter% := Chr(5) 

	 Loop, % list0                    ; split pattern elements
		{                             ; result: list_listnumber_indexitemnumber_1..5
		 ;MsgBox % list%A_Index% ; debug
		 Snippet[Counter,A_Index]:=StrSplit(list%A_Index%,Chr(7))
		 List%A_Index%:=""
		 ;MsgBox % Snippet[counter,A_Index,1] ; debug

		 Snippet[Counter,A_Index,"1v"]:=FixPreview(Snippet[Counter,A_Index,1])
		 Snippet[Counter,A_Index,"2v"]:=FixPreview(Snippet[Counter,A_Index,2])
		 
		 If (Snippet[Counter,A_Index,3] <> "") ; if no hotkey defined: skip
			{
			 Hotkey, IfWinNotActive, ahk_group BundleHotkeys	
			 Hotkey, % "$" . Snippet[Counter,A_Index,3], ShortCut ; setup hotkeys
			 If (ShortcutPaused = 1)
				{
				 Hotkey, % "$" . Snippet[Counter,A_Index,3], Off ; turn hotkeys off ...
				}
			 HotKeyHitList_%Counter% .= Snippet[Counter,A_Index,3] Chr(5)
			 Hotkey, IfWinNotActive
			}
			
		 If (Snippet[Counter,A_Index,4] <> "")                 ; if no shorthand defined: skip
			{
			 ShortHandHitList_%Counter% .= Snippet[Counter,A_Index,4] Chr(5)
			} 
			 
		 %ArrayName%%A_Index%= ; free mem	
		}
	 ;MsgBox % Snippet[Counter,1,1] ; debug
	 Return	
	}

CreateFirstBundle()
	{
Global IniFile		
FileAppend, 
(
BundleFormat: 1
Name: Default
Description: Default bundle for Lintalist
Author: Lintalist
TitleMatch: 
Patterns:
- LLPart1: This is Snippet Part 1, refer to documentation for further info.
  LLPart2: This is Snippet Part 2
  LLKey: 
  LLShorthand:
  LLScript:
), %A_ScriptDir%\bundles\default.txt
DefaultBundle:="default.txt"
IniWrite, default.txt, %A_ScriptDir%\%IniFile%, Settings, AlwaysLoadBundles
IniWrite, default.txt, %A_ScriptDir%\%IniFile%, Settings, DefaultBundle
IniWrite, default.txt, %A_ScriptDir%\%IniFile%, Settings, LastBundle
Return "default.txt"
	}

FixPreview(in)
	{
	 StringReplace, in, in, `r, ,all
	 StringReplace, in, in, `n, \n,all
	 StringReplace, in, in, %A_Tab%, \t,all
	 return in
	}
	