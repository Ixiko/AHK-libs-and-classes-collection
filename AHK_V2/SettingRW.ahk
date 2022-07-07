SettingLoad(SettingFilePath) {
	FileOutput := FileRead(SettingFilePath)
	return FileOutput
}

SettingAddSection(SettingData,SectionName,SectionData,IncludeBrackets:=True) {
    CurSec := SettingGetSection(SettingData,SectionName,IncludeBrackets)
    If (IncludeBrackets) {
        SectionName := "[" SectionName "]"
    }
    
    ; MsgBox % SettingData
    
    TempBlank := Trim(StrReplace(SettingData,SectionName "`r`n" CurSec,""),OmitChars:=" `t`r`n")
    NewSetData := Trim(TempBlank,OmitChars:=" `t`r`n") "`r`n`r`n" SectionName "`r`n" SectionData
    
    return NewSetData
}

SettingRemoveSection(SettingData,SectionName,IncludeBrackets:=True) {
    CurSec := SettingGetSection(SettingData,SectionName,IncludeBrackets)
    
    If (IncludeBrackets) {
        SectionName := "[" SectionName "]"
    }
    
    TempBlank := Trim(StrReplace(SettingData,SectionName "`r`n" CurSec,""),OmitChars:=" `t`r`n")
    
    return TempBlank
}

SettingGetSectionList(SettingData,sFilter:="",IncludeBrackets:=True) {
    ReadSection := false
    SectionList := ""
    
    Loop Parse SettingData, "`r", "`n"
    {
        If (A_Index = 1) {
            CurSection := A_LoopField
            CurSection := StrReplace(StrReplace(CurSection,"[",""),"]","")
        } Else {
            CurSection := ""
            
            If (IncludeBrackets) {
                If (InStr(A_LoopField,"[") = 1 And InStr(A_LoopField,"]") = StrLen(A_LoopField)) {
                    CurSection := A_LoopField
                    CurSection := StrReplace(StrReplace(CurSection,"[",""),"]","")
                }
            } Else {
                If (ReadSection) {
                    CurSection := A_LoopField
                    ReadSection := false
                }
                
                If (A_LoopField = "") {
                    ReadSection := true
                }
            }
        }
        
        If (SectionList = "" And CurSection != "") {
            SectionList := CurSection
        } Else If (CurSection != "") {
            SectionList := SectionList "|" CurSection
        }
    }
    
    If (sFilter = "") {
        FinalList := SectionList
    } Else {
        Loop Parse SectionList, "|"
        {
            If (InStr(A_LoopField,sFilter) > 0) {
                FinalList .= A_LoopField "|"
            }
        }
    }
    
    FinalList := Sort(FinalList,"U D|")
    
    return FinalList
}

SettingGetSection(SettingData,SectionName,IncludeBrackets:=True) {
    ReadData := False
    
    If (IncludeBrackets) {
        SectionConv := "[" SectionName "]"
    } Else {
        SectionConv := SectionName
    }
    
    Loop Parse SettingData, "`r", "`n"
    {
        If (ReadData) {
            If (IncludeBrackets) {
                If (SubStr(A_LoopField,1,1) = "[") {
                    Break
                }
            } Else {
                If (A_LoopField = "") {
                    Break
                }
            }
            SectionFilter .= A_LoopField "`r`n"
        }
        
        If (SectionConv = A_LoopField) {
            ReadData := True
        }
    }
    
    ; SectionFilter := SectionConv "`r`n" SectionFilter
    
    return Trim(SectionFilter,OmitChars:=" `r`n`t")
}

SettingReadSectionItem(SettingData,SectionName,ItemName,IncludeBrackets:=True) {
    CurSec := SettingGetSection(SettingData,SectionName,IncludeBrackets)
    ; MsgBox % CurSec
    
    ItemData := SettingRead(CurSec,ItemName,"=")
    
    return ItemData
}

SettingAddSectionItem(SettingData,SectionName,ItemName,ItemValue,IncludeBrackets:=True) {
    CurSec := SettingGetSection(SettingData,SectionName,IncludeBrackets)
    
    ; MsgBox % "CurSec: " "`r`n`r`n" CurSec
    
    NewCurSec := SettingUpdate(CurSec,ItemName,ItemValue,"=")
    
    ; MsgBox % "NewCurSec: " "`r`n`r`n" NewCurSec
    
    If (IncludeBrackets) {
        SectionName := "[" SectionName "]"
    }
    
    CurSec := SectionName "`r`n" Trim(CurSec,OmitChars:=" `t`r`n")
    
    ; MsgBox % "CurSec2:" "`r`n`r`n" CurSec
    
    TempBlank := Trim(StrReplace(SettingData,CurSec,""),OmitChars:=" `t`r`n")
    
    ; MsgBox % "TempBlank: " "`r`n`r`n" TempBlank
    
    NewSetData := Trim(TempBlank,OmitChars:=" `t`r`n") "`r`n`r`n" SectionName "`r`n" NewCurSec
    
    ; MsgBox % "NewSetData: " "`r`n`r`n" NewSetData
    
    return NewSetData
}

SettingTotalLines(SettingData) {
    i := 0
    Loop Parse SettingData, "`r", "`n"
        i++
    
    return i
}

SettingStripComments(SettingData) {
    Loop Parse SettingData, "`r", "`n"
    {
        If (SubStr(A_LoopField,1,1) != "#") {
            NewSettingData .= A_LoopField . "`r`n"
        }
    }
    
    return NewSettingData
}

SettingRead(SettingData,SettingName,Sep,TrimOutput:=False) {
	SettingValue := ""
	Loop Parse SettingData, "`r", "`n"
	{
        If (SubStr(A_LoopField,1,1) != "#") { ; ignore comments starting with #
            If (Trim(GetTok(A_LoopField,Sep,1)) = SettingName) {
                TotTok := NumTok(A_LoopField,Sep)
				
				sRange := "2-" TotTok
                If (TrimOutput = True) {
                    SettingValue := Trim(GetTok(A_LoopField,Sep,sRange))
                } Else {
                    SettingValue := GetTok(A_LoopField,Sep,sRange)
                }
                Break
            }
        }
	}
	
	return SettingValue
}

SettingUpdate(SettingData,SettingName,SettingValue,Sep) {
	NewSettingData := ""
	i := 0
    DataAdded := 0
    
    SettingData := StrReplace(StrReplace(SettingData,"`r`n`r`n","`r`n"),"`r`n`r`n","`r`n")
    SettingData := Trim(SettingData,OmitChars := " `t`r`n")

    ; don't forget to do this:
    ;   SettingVar := SettingUpdate(...)
    
	Loop Parse SettingData, "`r", "`n"
	{
        If (SubStr(A_LoopField,1,1) != "#") {
            TotTok := NumTok(A_LoopField,Sep)
            CurName := GetTok(A_Loopfield,Sep,"1")
            CurValue := GetTok(A_LoopField,Sep,"2-" . TotTok)
            
            If (CurName = SettingName) {
                DataAdded := 1
                SettingLine := CurName Sep SettingValue
            } Else {
                SettingLine := CurName Sep CurValue
            }
            
            If (NewSettingData = "") {
                NewSettingData := SettingLine
            } Else {
                NewSettingData := NewSettingData "`r`n" SettingLine
            }
        }
			
		i++
	}
    
    If (DataAdded = 0) {
        If (NewSettingData = "") {
            NewSettingData := SettingName Sep SettingValue
        } Else {
            NewSettingData .= "`r`n" SettingName Sep SettingValue
        }
    }
    
    ; no more remove blank lines
    ; NewSettingData := Trim(StrReplace(NewSettingData,"`r`n`r`n","`r`n"),OmitChars := " `t`r`n")
    NewSettingData := Trim(NewSettingData,OmitChars := " `t`r`n")
    
    ; don't forget to do this:
    ;   SettingVar := SettingUpdate(...)
	
	return NewSettingData
}

SettingWrite(SettingFilePath,SettingData,RemoveBlankLines:=False) {
	BackupFolder := A_WorkingDir . "\Backup"
	SettingFileName := FileFromPath(SettingFilePath)
    SettingFolder := PathToFile(SettingFilePath)
    SettingFileTitle := FileTitle(SettingFileName)
    SettingFileTemp := SettingFileTitle "Temp"
	; ErrResult := MakeFolderCheck(BackupFolder)
    SettingBackup := SettingData
	
    ; remove blank lines
    If (RemoveBlankLines) {
        SettingData := StrReplace(StrReplace(SettingData,"`r`n`r`n","`r`n"),"`r`n`r`n","`r`n")
    }
    
    SettingData := Trim(SettingData,OmitChars := " `r`n`t")
    
    FileMove SettingFilePath, SettingFolder SettingFileTemp ".txt"
    
    If (ErrorLevel > 0) {
        MsgBox("Backing up setting file failed!`r`n`r`n" SettingFolder SettingFileTemp ".txt")
        return
    }
    
    FileAppend SettingData, SettingFilePath
    
    If (ErrorLevel > 0) {
        MsgBox("Writing setting file failed!`r`n`r`n" SettingFilePath)
        return
    }
    
    FileDelete SettingFolder SettingFileTemp ".txt"
    
    If (ErrorLevel > 0) {
        MsgBox("Removing backup file failed!`r`n`r`n" SettingFolder SettingFileTemp ".txt")
        return
    }
}

SettingDelete(SettingData,SettingName,Sep) {
	NewData := ""
	
	Loop Parse SettingData, "`r", "`n"
	{
        If (A_LoopField != "") {
            CurName := GetTok(A_LoopField,Sep,1)
            CurValue := GetTok(A_LoopField,Sep,"2-")
            
            ;MsgBox % CurName . " / " . SettingName
            
            If (CurName != SettingName) {
                NewData .= CurName Sep CurValue "`r`n"
            }
        }
	}
	
	return NewData
}

SettingLine(SettingData,LineNum) {
    LineValue := ""
    Loop Parse SettingData, "`r", "`n"
    {
        LineValue := A_LoopField
        If (LineNum = A_Index)
            Break
    }
    return LineValue
}

LineDelete(SettingData,IndexVal,NoBlanks:=False) {
	NewData := ""
	
    If (NoBlanks = True) {
        Loop Parse SettingData, "`r", "`n"
        {
            If (A_Index != "" And A_LoopField != IndexVal) {
                NewData .= A_LoopField "`r`n"
            }
        }
    } Else {
        Loop Parse SettingData, "`r", "`n"
        {
            If (A_Index != IndexVal)
                NewData .= A_LoopField "`r`n"
        }
    }
	
	return NewData
}

MakeFolderCheck(FolderName) {
	If (FileExist(FolderName)="") {
		DirCreate FolderName
	}
	If (ErrorLevel > 0) {
		MsgBox("There was an error: " A_LastError " / " ErrorLevel "`r`n`r`n" "Can't make folder:" "`r`n`r`n" FolderName)
	}
	
	return ErrorLevel
}

; FileEncoding, CP65001 ; UTF-8
; FileEncoding, CP1200 ; UTF-16

WriteMultiByte(sFilePath,sFileData) {
    FileEncoding "CP65001" ; UTF-8
    fo := FileOpen(sFilePath,"w")
    If !IsObject(fo) {
        MsgBox("Can't open " sFilePath " for writing.")
        return
    }
    fo.Write(sFileData)
    fo.Close()
    
    return ErrorLevel
}

ReadMultiByte(sFilePath,lNumChars:=0) {
    FileEncoding "CP65001" ; UTF-8
    fo := FileOpen(sFilePath,"rw")
    If !IsObject(fo) {
        MsgBox("Can't open " sFilePath " for writing.")
        return
    }
    
    If (lNumChars=0) {
        sString := fo.Read()
    } Else {
        sString := fo.Read(lNumChars)
    }
    
    return ErrorLevel
}