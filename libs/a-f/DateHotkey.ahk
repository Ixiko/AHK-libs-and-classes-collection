#SingleInstance Prompt
#Persistent

; DateHotkey
; Created by tiuub
;
; GitHub: https://github.com/tiuub/DateHotkey
; License: MIT (https://github.com/tiuub/DateHotkey)
; Last update: 2021-09-16
global VERSION = "1.4.1"
global LANG = "UNIVERSAL"
global GITHUB = "https://github.com/tiuub/DateHotkey"

global germanTwoLetter = "DE"
global englishTwoLetter = "EN"

global startingTimeDate := A_Now
global iniFilePath := % Format("{1}/{2}.ini", A_Temp, A_ScriptName)
global updateFilePath := % Format("{1}/{2}.remote.version.txt", A_Temp, A_ScriptName)
global updateUrl := "https://raw.githubusercontent.com/tiuub/DateHotkey/master/VERSION"
global updateDefaultEnabled := True
global updateDefaultDayOffset := 2
global recognitionKeyDefaultItemName := "Enter"
global recognitionKeyDefaultMenuName := "RecognitionKey"
global recognitionKeyDefaultValue := "\R"
global recognitionKeyLastItemName := ""
global recognitionKeyLastMenuName := ""
global recognitionKey := ""
global endingKeyDelay := 50
global endingKeyDefaultItemName := "None"
global endingKeyDefaultMenuName := "EndingKey"
global endingKeyDefaultValue := ""
global endingKeyLastItemName := ""
global endingKeyLastMenuName := ""
global endingKey := ""
global dateFormatDefaultItemName := Format("Automatic ({1})", GetDateFormatEx(startingTimeDate))
global dateFormatDefaultMenuName := "DateFormat"
global dateFormatDefaultValue := ""
global dateFormatLastItemName := ""
global dateFormatLastMenuName := ""
global dateFormat := ""
global scopeLanguageDefaultItemName := "English"
global scopeLanguageDefaultMenuName := "Language"
global scopeLanguageDefaultValue := %englishTwoLetter%
global scopeLanguageLastItemName := ""
global scopeLanguageLastMenuName := ""
global scopeLang := ""
IniRead, scopeLang, %iniFilePath%, Language, Value, %englishTwoLetter%
if (scopeLang = englishTwoLetter){
    IniWrite, %englishTwoLetter%, %iniFilePath%, Language, Value
}

SetTitleMatchMode, RegEx
DetectHiddenWindows, On
while (processId:=WinExist(".*(((EN|DE|UN)_DateHotkey|DateHotkey).(exe|ahk)).* ahk_class AutoHotkey", "", A_Scriptname))
{
    if (scopeLang = germanTwoLetter){
        MsgBox, 52, Achtung, Ein anderer Prozess von DateHotkey läuft bereits. Dies kann mehrere Probleme verursachen.`n`nMöchten Sie den laufenden Prozess durch den aktuellen Prozess ersetzen?`n("Nein" beendet den aktuellen Prozess!)
    }else{
        MsgBox, 52, Attention, Another Process of DateHotkey is already running. This can lead to serious bugs.`n`nWould you like to replace it with the current?`n(No will cancel the current process!)
    }
    IfMsgBox Yes
        WinClose, ahk_id %processId%
    else
        Exit
}

checkForUpdate()
createTrayMenu()
updateAboutSection()
loadSavedSettings()
registerHotstrings()
return

checkForUpdate(forcePoll:=False, showIfNotAvailable:=False) {
    IniRead, updateEnabled, %iniFilePath%, Update, Enabled, %updateDefaultEnabled%
    if (updateEnabled = updateDefaultEnabled) {
        IniWrite, %updateDefaultEnabled%, %iniFilePath%, Update, Enabled
    }
    if (updateEnabled or forcePoll) {
        IniRead, updateDayOffset, %iniFilePath%, Update, DayOffset, %updateDefaultDayOffset%
        if (updateDayOffset = updateDefaultDayOffset) {
            IniWrite, %updateDefaultDayOffset%, %iniFilePath%, Update, DayOffset
        }
        IniRead, lastPoll, %iniFilePath%, Update, LastPoll, 20000101000000
        EnvSub, lastPoll, %startingTimeDate%, days 
        if (Abs(lastPoll) > updateDayOffset or forcePoll) {
            URLDownloadToFile, %updateUrl%, %updateFilePath%
            langFound := False
            Loop
            {
                FileReadLine, line, %updateFilePath%, %A_Index%
                if ErrorLevel
                    break
                RegExMatch(line, "O)::([A-Za-z]+):([0-9.]+)::", reg)
                if (reg.Value(1) = LANG) {
                    langFound = True
                    if (compareVersionStrings(VERSION, reg.Value(2))) {
                        if (scopeLang = germanTwoLetter) {
                            MsgBox, 68, Update - DateHotkey, % Format("Es steht ein Update für DateHotkey bereit!`n`nNeue Version: {1}`nAktuelle Version: {2}`n`nDas Update kann jetzt über GitHub heruntergeladen werden.`nGitHub: https://github.com/tiuub/DateHotkey`n`nSoll GitHub im Browser geöffnet werden?", reg.Value(2), VERSION)
                        }else{
                            MsgBox, 68, Update - DateHotkey, % Format("DateHotkey has an update!`n`nNew Version: {1}`nCurrent Version: {2}`n`nJust download the new version from GitHub.`nGitHub: https://github.com/tiuub/DateHotkey`n`nDo you want to open GitHub in your browser?", reg.Value(2), VERSION)
                        }
                        IfMsgBox Yes
                            openGitHubRepository()
                    }else if (showIfNotAvailable){
                        if (scopeLang = germanTwoLetter) {
                            MsgBox, 64, Update - DateHotkey, % Format("Sie haben die neuste Version bereits installiert!`n`nIhre Version: {1}`nNeuste Version (online): {2}`nGitHub: https://github.com/tiuub/DateHotkey", VERSION, reg.Value(2))
                        }else{
                            MsgBox, 64, Update - DateHotkey, % Format("You already have installed the newest version!`n`nCurrent Version: {1}`nNewest Version (online): {2}`nGitHub: https://github.com/tiuub/DateHotkey", VERSION, reg.Value(2))
                        } 
                    }
                }
            }
            if (!langFound and showIfNotAvailable){
                if (scopeLang = germanTwoLetter) {
                    MsgBox, 68, Update - DateHotkey, % Format("Deine aktuell installierte Sprache wird scheinbar nicht offiziell unterstütz!`n`nDeine aktuell installierte Sprache: {1}`n`nLade dir bestenfalls den neusten Release von DateHotkey über GitHub herunter.`nGitHub: https://github.com/tiuub/DateHotkey`n`nSoll GitHub im Browser geöffnet werden?", LANG)
                }else{
                    MsgBox, 68, Update - DateHotkey, % Format("Your currently installed language seems not to be supported at all.`n`nCurrently installed language: {1}`n`nConsider reinstalling DateHotkey from GitHub.`nGitHub: https://github.com/tiuub/DateHotkey`n`nDo you want to open GitHub in your browser?", LANG)
                }
            }
            FileDelete, %updateFilePath%
            IniWrite, %startingTimeDate%, %iniFilePath%, Update, LastPoll
        }
    }
}

compareVersionStrings(pLocalVersion, pRemoteVersion){
    StringSplit, localVersion, pLocalVersion, .
    StringSplit, remoteVersion, pRemoteVersion, .
    Loop, 4 {
        if (remoteVersion%A_Index% > localVersion%A_Index%){
            return True
        }else if (remoteVersion%A_Index% < localVersion%A_Index%){
            return False
        }
    }
    return False
}

openGitHubRepository(pSection:="") {
    Run, %GITHUB%%pSection%
}

openConfigFile() {
    if (!FileExist(iniFilePath)){
        updateAboutSection()
    }
    Run, %iniFilePath%
}

createTrayMenu() {
    Menu, Tray, Add
    
    BoundRecognitionKeyReturn := Func("RecognitionKey").Bind("\R")
    BoundRecognitionKeyWhitespace := Func("RecognitionKey").Bind("[ ]")
    BoundRecognitionKeyTabulator := Func("RecognitionKey").Bind("\t")
    BoundRecognitionKeyDot := Func("RecognitionKey").Bind("[.]")
    Menu, %recognitionKeyDefaultMenuName%, Add, %recognitionKeyDefaultItemName%, % BoundRecognitionKeyReturn, +Radio
    Menu, %recognitionKeyDefaultMenuName%, Add, Whitespace, % BoundRecognitionKeyWhitespace, +Radio
    Menu, %recognitionKeyDefaultMenuName%, Add, Tabulator, % BoundRecognitionKeyTabulator, +Radio
    Menu, %recognitionKeyDefaultMenuName%, Add, Dot, % BoundRecognitionKeyDot, +Radio
    Menu, %recognitionKeyDefaultMenuName%, Add
    Menu, %recognitionKeyDefaultMenuName%, Add, Help, HelpRecognitionKey
    Menu, Tray, Add, Recognition Key, :%recognitionKeyDefaultMenuName%
    
    BoundEndingKeyNone := Func("EndingKey").Bind("")
    BoundEndingKeyReturn := Func("EndingKey").Bind("{Enter}")
    BoundEndingKeyTabulator := Func("EndingKey").Bind("{Tab}")
    Menu, %endingKeyDefaultMenuName%, Add, %endingKeyDefaultItemName%, % BoundEndingKeyNone, +Radio
    Menu, %endingKeyDefaultMenuName%, Add, Return, % BoundEndingKeyReturn, +Radio
    Menu, %endingKeyDefaultMenuName%, Add, Tabulator, % BoundEndingKeyTabulator, +Radio
    Menu, %endingKeyDefaultMenuName%, Add
    Menu, %endingKeyDefaultMenuName%, Add, Help, HelpEndingKey
    Menu, Tray, Add, Ending Character, :%endingKeyDefaultMenuName%
    
    
    BoundDateFormatAutomatic := Func("DateFormat").Bind("")
    Menu, %dateFormatDefaultMenuName%, Add, %dateFormatDefaultItemName%, % BoundDateFormatAutomatic, +Radio
    
    
    ; ISO8601 formats: yyyy-MM-dd;yyyyMMdd
    BoundDateFormatISO8601YYY_MM_DD := Func("DateFormat").Bind("yyyy-MM-dd")
    BoundDateFormatISO8601YYYMMDD := Func("DateFormat").Bind("yyyyMMdd")
    Menu, ISO8601, Add, % Format("yyyy-MM-dd ({1})", GetDateFormatEx(startingTimeDate, "yyyy-MM-dd")), % BoundDateFormatISO8601YYY_MM_DD, +Radio
    Menu, ISO8601, Add, % Format("yyyyMMdd ({1})", GetDateFormatEx(startingTimeDate, "yyyyMMdd")), % BoundDateFormatISO8601YYYMMDD, +Radio
    Menu, %dateFormatDefaultMenuName%, Add, ISO8601, :ISO8601
    
    
    ; European formats: dd.MM.yyyy;dd.MM.yy;yyyy.MM.dd;dd. MMM. yyyy;dddd, d. MMMM yyyy;d. MMMM yyyy;d. MMM yyyy
    BoundDateFormatEuropeDD_MM_YYYY := Func("DateFormat").Bind("dd.MM.yyyy")
    BoundDateFormatEuropeDD_MM_YY := Func("DateFormat").Bind("dd.MM.yy")
    BoundDateFormatEuropeYYYY_MM_DD := Func("DateFormat").Bind("yyyy.MM.dd")
    BoundDateFormatEuropeDD__MMM__YYYY := Func("DateFormat").Bind("dd. MMM. yyyy")
    BoundDateFormatEuropeDDDD__D__MMMM_YYYY := Func("DateFormat").Bind("dddd, d. MMMM yyyy")
    BoundDateFormatEuropeD__MMMM_YYYY := Func("DateFormat").Bind("d. MMMM yyyy")
    BoundDateFormatEuropeD__MMM_YYYY := Func("DateFormat").Bind("d. MMM yyyy")
    Menu, Europe, Add, % Format("dd.MM.yyyy ({1})", GetDateFormatEx(startingTimeDate, "dd.MM.yyyy")), % BoundDateFormatEuropeDD_MM_YYYY, +Radio
    Menu, Europe, Add, % Format("dd.MM.yy ({1})", GetDateFormatEx(startingTimeDate, "dd.MM.yy")), % BoundDateFormatEuropeDD_MM_YY, +Radio
    Menu, Europe, Add, % Format("yyyy.MM.dd ({1})", GetDateFormatEx(startingTimeDate, "yyyy.MM.dd")), % BoundDateFormatEuropeYYYY_MM_DD, +Radio
    Menu, Europe, Add, % Format("dd. MMM. yyyy ({1})", GetDateFormatEx(startingTimeDate, "dd. MMM. yyyy")), % BoundDateFormatEuropeDD__MMM__YYYY, +Radio
    Menu, Europe, Add, % Format("dddd, d. MMMM yyyy ({1})", GetDateFormatEx(startingTimeDate, "dddd, d. MMMM yyyy")), % BoundDateFormatEuropeDDDD__D__MMMM_YYYY, +Radio
    Menu, Europe, Add, % Format("d. MMMM yyyy ({1})", GetDateFormatEx(startingTimeDate, "d. MMMM yyyy")), % BoundDateFormatEuropeD__MMMM_YYYY, +Radio
    Menu, Europe, Add, % Format("d. MMM yyyy ({1})", GetDateFormatEx(startingTimeDate, "d. MMM yyyy")), % BoundDateFormatEuropeD__MMM_YYYY, +Radio
    Menu, %dateFormatDefaultMenuName%, Add, Europe, :Europe
    
    
    ; United States formats: M/d/yyyy;M/d/yy;MM/dd/yy;MM/dd/yyyy;yy/MM/dd;yyyy-MM-dd;dd-MMM-yy;dddd, MMMM d, yyyy;MMMM d, yyyy;dddd, d MMMM, yyyy;d MMMM, yyyy
    BoundDateFormatUnitedStatesM_D_YYYY := Func("DateFormat").Bind("M/d/yyyy")
    BoundDateFormatUnitedStatesM_D_YY := Func("DateFormat").Bind("M/d/yy")
    BoundDateFormatUnitedStatesMM_DD_YY := Func("DateFormat").Bind("MM/dd/yy")
    BoundDateFormatUnitedStatesMM_DD_YYYY := Func("DateFormat").Bind("MM/dd/yyyy")
    BoundDateFormatUnitedStatesYY_MM_DD := Func("DateFormat").Bind("yy/MM/dd")
    BoundDateFormatUnitedStatesYYYY_MM_DD := Func("DateFormat").Bind("yyyy-MM-dd")
    BoundDateFormatUnitedStatesDD_MMM_YY := Func("DateFormat").Bind("dd-MMM-yy")
    BoundDateFormatUnitedStatesDDDD__MMMM_D__YYYY := Func("DateFormat").Bind("dddd, MMMM d, yyyy")
    BoundDateFormatUnitedStatesMMMM_D__YYYY := Func("DateFormat").Bind("MMMM d, yyyy")
    BoundDateFormatUnitedStatesDDDD__D_MMMM__YYYY := Func("DateFormat").Bind("dddd, d MMMM, yyyy")
    BoundDateFormatUnitedStatesD_MMMM__YYYY := Func("DateFormat").Bind("d MMMM, yyyy")
    Menu, UnitedStates, Add, % Format("M/d/yyyy ({1})", GetDateFormatEx(startingTimeDate, "M/d/yyyy")), % BoundDateFormatUnitedStatesM_D_YYYY, +Radio
    Menu, UnitedStates, Add, % Format("M/d/yy ({1})", GetDateFormatEx(startingTimeDate, "M/d/yy")), % BoundDateFormatUnitedStatesM_D_YY, +Radio
    Menu, UnitedStates, Add, % Format("MM/dd/yy ({1})", GetDateFormatEx(startingTimeDate, "MM/dd/yy")), % BoundDateFormatUnitedStatesMM_DD_YY, +Radio
    Menu, UnitedStates, Add, % Format("MM/dd/yyyy ({1})", GetDateFormatEx(startingTimeDate, "MM/dd/yyyy")), % BoundDateFormatUnitedStatesMM_DD_YYYY, +Radio
    Menu, UnitedStates, Add, % Format("yy/MM/dd ({1})", GetDateFormatEx(startingTimeDate, "yy/MM/dd")), % BoundDateFormatUnitedStatesYY_MM_DD, +Radio
    Menu, UnitedStates, Add, % Format("yyyy-MM-dd ({1})", GetDateFormatEx(startingTimeDate, "yyyy-MM-dd")), % BoundDateFormatUnitedStatesYYYY_MM_DD, +Radio
    Menu, UnitedStates, Add, % Format("dd-MMM-yy ({1})", GetDateFormatEx(startingTimeDate, "dd-MMM-yy")), % BoundDateFormatUnitedStatesDD_MMM_YY, +Radio
    Menu, UnitedStates, Add, % Format("dddd, MMMM d, yyyy ({1})", GetDateFormatEx(startingTimeDate, "dddd, MMMM d, yyyy")), % BoundDateFormatUnitedStatesDDDD__MMMM_D__YYYY, +Radio
    Menu, UnitedStates, Add, % Format("MMMM d, yyyy ({1})", GetDateFormatEx(startingTimeDate, "MMMM d, yyyy")), % BoundDateFormatUnitedStatesMMMM_D__YYYY, +Radio
    Menu, UnitedStates, Add, % Format("dddd, d MMMM, yyyy ({1})", GetDateFormatEx(startingTimeDate, "dddd, d MMMM, yyyy")), % BoundDateFormatUnitedStatesDDDD__D_MMMM__YYYY, +Radio
    Menu, UnitedStates, Add, % Format("d MMMM, yyyy ({1})", GetDateFormatEx(startingTimeDate, "d MMMM, yyyy")), % BoundDateFormatUnitedStatesD_MMMM__YYYY, +Radio
    Menu, %dateFormatDefaultMenuName%, Add, United States, :UnitedStates
    
    
    ; Other formats: d/M/yyyy;dd/MM/yyyy;d/M/yy;dd/MM/yy
    BoundDateFormatOthersD_M_YYYY := Func("DateFormat").Bind("d/M/yyyy")
    BoundDateFormatOthersDD_MM_YYYY := Func("DateFormat").Bind("dd/MM/yyyy")
    BoundDateFormatOthersD_M_YY := Func("DateFormat").Bind("d/M/yy")
    BoundDateFormatOthersDD_MM_YY := Func("DateFormat").Bind("dd/MM/yy")
    Menu, Others, Add, % Format("d/M/yyyy ({1})", GetDateFormatEx(A_Now, "d/M/yyyy")), % BoundDateFormatOthersD_M_YYYY, +Radio
    Menu, Others, Add, % Format("dd/MM/yyyy ({1})", GetDateFormatEx(A_Now, "dd/MM/yyyy")), % BoundDateFormatOthersDD_MM_YYYY, +Radio
    Menu, Others, Add, % Format("d/M/yy ({1})", GetDateFormatEx(A_Now, "d/M/yy")), % BoundDateFormatOthersD_M_YY, +Radio
    Menu, Others, Add, % Format("dd/MM/yy ({1})", GetDateFormatEx(A_Now, "dd/MM/yy")), % BoundDateFormatOthersDD_MM_YY, +Radio
    Menu, %dateFormatDefaultMenuName%, Add, Others, :Others
    
    
    Menu, Tray, Add, DateFormat, :%dateFormatDefaultMenuName%
    
    
    BoundScopeLanguageEnglish := Func("ScopeLanguage").Bind(englishTwoLetter)
    BoundScopeLanguageGerman := Func("ScopeLanguage").Bind(germanTwoLetter)
    Menu, Language, Add, English, % BoundScopeLanguageEnglish, +Radio
    Menu, Language, Add, German, % BoundScopeLanguageGerman, +Radio
    Menu, Tray, Add, Language, :Language
    
    
    BoundCheckForUpdate := Func("checkForUpdate").Bind(True, True)
    BoundOpenGitHubRepositor := Func("openGitHubRepository").Bind("")
    BoundDonate := Func("openGitHubRepository").Bind("#contributing")
    Menu, Help, Add, About, AboutPage
    Menu, Help, Add, Check for update, % BoundCheckForUpdate
    Menu, Help, Add, Open GitHub Repository, % BoundOpenGitHubRepositor
    Menu, Help, Add, Open config file, openConfigFile
    Menu, Help, Add, Donate, % BoundDonate
    Menu, Tray, Add, Help, :Help
}

HelpRecognitionKey()
{
    if (scopeLang = germanTwoLetter) {
        MsgBox, 68, RecognitionKey - DateHotkey, % "Der RecognitionKey wird dazu verwendet, um das Ende eines Hotstring zu identifizieren.`n`nBeispiel 'Enter':`nHier muss der der Hotstring '#today4d' mit einem Enter bestätigt werden.`n`nBeispiel 'Tabulator':`nHier muss nach der Eingabe des Hotstrings 'today4d' die Eingabe mit der Tabulatortaste bestätigt werden.`n`nSoll GitHub für weitere Informationen geöffnet werden?"
    }else{
        MsgBox, 68, RecognitionKey - DateHotkey, % "The RecognitionKey is used to identify the end of a hotstring.`n`nExample 'Enter':`nAfter typing in the hotstring '#today4d', you have to confirm with pressing enter.`n`nExample 'Tabulator':`nAfter typing in the hotstring '#today4d', you have to confirm with pressing the tabulator key.`n`nDo you want to open GitHub for further information?"
    }
    IfMsgBox Yes
        openGitHubRepository()
}

RecognitionKey(pRecognitionKey, pItemName, pItemPos, pMenuName)
{
    if recognitionKeyLastItemName{
        Menu, %pMenuName%, Uncheck, %recognitionKeyLastItemName%
    }
    Menu, %pMenuName%, Check, %pItemName%
    recognitionKeyLastItemName = %pItemName%
    recognitionKeyLastMenuName = %pMenuName%
    recognitionKey = %pRecognitionKey%
    IniWrite, %pRecognitionKey%, %iniFilePath%, RecognitionKey, Value
    IniWrite, %pItemName%, %iniFilePath%, RecognitionKey, ItemName
    IniWrite, %pMenuName%, %iniFilePath%, RecognitionKey, MenuName
    Reload
    Return
}

HelpEndingKey()
{
    if (scopeLang = germanTwoLetter) {
        MsgBox, 68, EndingKey - DateHotkey, % "Der EndingKey wird nach erfolgreichem Ersetzten des Hotstrings ausgegeben.`n`nBeispiel 'None':`nBei der Eingabe des Hotstrings '#today4d', wird einfach das Datum ohne Zusatz zurück gegeben.`n`nBeispiel 'Enter':`nBei der Eingabe des Hotstrings '#today4d', wird das Datum und die Eingabetaste zurückgegeben.`n`nSoll GitHub für weitere Informationen geöffnet werden?"
    }else{
        MsgBox, 68, EndingKey - DateHotkey, % "The EndingKey will be printed after giving the output for your hotstring.`n`nExample 'None':`nWhen entering '#today4d', you will receive the date string and nothing else.`n`nExample 'Enter':`nWhen entering '#today4d', you will receive the date string and a return afterwards.`n`nDo you want to open GitHub for further information?"
    }
    IfMsgBox Yes
        openGitHubRepository()
}

EndingKey(pEndingKey, pItemName, pItemPos, pMenuName)
{
    if endingKeyLastItemName{
        Menu, %pMenuName%, Uncheck, %endingKeyLastItemName%
    }
    Menu, %pMenuName%, Check, %pItemName%
    endingKeyLastItemName = %pItemName%
    endingKeyLastMenuName = %pMenuName%
    endingKey = %pEndingKey%
    IniWrite, %pEndingKey%, %iniFilePath%, EndingKey, Value
    IniWrite, %pItemName%, %iniFilePath%, EndingKey, ItemName
    IniWrite, %pMenuName%, %iniFilePath%, EndingKey, MenuName
}

DateFormat(pDateFormat, pItemName, pItemPos, pMenuName)
{
    if dateFormatLastItemName{
        Menu, %dateFormatLastMenuName%, Uncheck, %dateFormatLastItemName%
    }
    Menu, %pMenuName%, Check, %pItemName%
    dateFormatLastItemName = %pItemName%
    dateFormatLastMenuName = %pMenuName%
    dateFormat = %pDateFormat%
    IniWrite, %pDateFormat%, %iniFilePath%, DateFormat, Value
    itemNameTemp := RegExReplace(pItemName, "\([\w\d._ ,-]+\)", "")
    itemNameTemp := RegExReplace(itemNameTemp, "[\s]+$", "")
    IniWrite, %itemNameTemp%, %iniFilePath%, DateFormat, ItemName
    IniWrite, %pMenuName%, %iniFilePath%, DateFormat, MenuName
}

ScopeLanguage(pLanguageTwoLetter, pItemName, pItemPos, pMenuName)
{
    if scopeLanguageLastItemName{
        Menu, %pMenuName%, Uncheck, %scopeLanguageLastItemName%
    }
    Menu, %pMenuName%, Check, %pItemName%
    scopeLanguageLastItemName = %pItemName%
    scopeLanguageLastMenuName = %pMenuName%
    scopeLanguage = %pLanguageTwoLetter%
    IniWrite, %pLanguageTwoLetter%, %iniFilePath%, Language, Value
    IniWrite, %pItemName%, %iniFilePath%, Language, ItemName
    IniWrite, %pMenuName%, %iniFilePath%, Language, MenuName
    Reload
    Return
}

AboutPage(){
    MsgBox, 64, About - DateHotkey, % Format("DateHotkey by tiuub`nVersion: {1}`nLicense: MIT`nGitHub: https://github.com/tiuub/DateHotkey`n`nConfig: {2}`n`nDependencies:`nHotstring by menixator (2017-08-14)`nGetDateFormat by jNizM (2015-11-03)", VERSION, iniFilePath)
}

updateAboutSection(){
    IniWrite, DateHotkey, %iniFilePath%, About, Name
    IniWrite, tiuub, %iniFilePath%, About, Author
    IniWrite, https://github.com/tiuub/DateHotkey, %iniFilePath%, About, GitHub
    IniWrite, MIT, %iniFilePath%, About, License
    IniWrite, % A_ScriptFullPath, %iniFilePath%, About, PathOfScript
    IniWrite, % GetDateFormatEx(startingTimeDate), %iniFilePath%, About, LastAccess
}

loadSavedSettings() {
    IniRead, recognitionKey, %iniFilePath%, RecognitionKey, Value
    if (recognitionKey = "ERROR"){
        recognitionKey = %recognitionKeyDefaultValue%
    }
    IniRead, recognitionKeyItemName, %iniFilePath%, RecognitionKey, ItemName, %recognitionKeyDefaultItemName%
    IniRead, recognitionKeyMenuName, %iniFilePath%, RecognitionKey, MenuName, %recognitionKeyDefaultMenuName%
    Menu, %recognitionKeyMenuName%, Check, %recognitionKeyItemName%
    recognitionKeyLastItemName = %recognitionKeyItemName%
    recognitionKeyLastMenuName = %recognitionKeyMenuName%

    IniRead, endingKey, %iniFilePath%, EndingKey, Value
    if (endingKey = "ERROR"){
        endingKey = %endingKeyDefaultValue%
    }
    IniRead, endingKeyItemName, %iniFilePath%, EndingKey, ItemName, %endingKeyDefaultItemName%
    IniRead, endingKeyMenuName, %iniFilePath%, EndingKey, MenuName, %endingKeyDefaultMenuName%
    Menu, %endingKeyMenuName%, Check, %endingKeyItemName%
    endingKeyLastItemName = %endingKeyItemName%
    endingKeyLastMenuName = %endingKeyMenuName%

    IniRead, dateFormat, %iniFilePath%, DateFormat, Value
    if (dateFormat = "ERROR"){
        dateFormat = %dateFormatDefaultValue%
    }
    IniRead, dateFormatItemName, %iniFilePath%, DateFormat, ItemName
    if (dateFormatItemName = "ERROR"){
        dateFormatItemName = %dateFormatDefaultItemName%
    }else{
        dateFormatItemName = % Format("{1} ({2})", dateFormatItemName, GetDateFormatEx(startingTimeDate, dateFormat))
    }
    IniRead, dateFormatMenuName, %iniFilePath%, DateFormat, MenuName, %dateFormatDefaultMenuName%
    Menu, %dateFormatMenuName%, Check, %dateFormatItemName%
    dateFormatLastItemName = %dateFormatItemName%
    dateFormatLastMenuName = %dateFormatMenuName%
    
    IniRead, scopeLanguage, %iniFilePath%, Language, Value
    if (scopeLanguage = "ERROR"){
        scopeLanguage = %scopeLanguageDefaultValue%
    }
    IniRead, scopeLanguageItemName, %iniFilePath%, Language, ItemName, %scopeLanguageDefaultItemName%
    IniRead, scopeLanguageMenuName, %iniFilePath%, Language, MenuName, %scopeLanguageDefaultMenuName%
    Menu, %scopeLanguageMenuName%, Check, %scopeLanguageItemName%
    scopeLanguageLastItemName = %scopeLanguageItemName%
    scopeLanguageLastMenuName = %scopeLanguageMenuName%
}

registerHotstrings() {
    if (scopeLang = germanTwoLetter) {
        Hotstring(Format("#heute(([\+\-0-9]+(t(age?)?|w(ochen?)?|m(onate?)?|j(ahre?)?)?)+)?{1}", recognitionKey), "today", 3)
        Hotstring(Format("#gestern(([\+\-0-9]+(t(age?)?|w(ochen?)?|m(onate?)?|j(ahre?)?)?)+)?{1}", recognitionKey), "yesterday", 3)
        Hotstring(Format("#morgen(([\+\-0-9]+(t(age?)?|w(ochen?)?|m(onate?)?|j(ahre?)?)?)+)?{1}", recognitionKey), "tomorrow", 3)
        Hotstring(Format("#mo(?:ntag)?(([\+\-0-9]+(t(age?)?|(w(ochen?)?)|m(onate?)?|j(ahre?)?)?)+)?{1}", recognitionKey), "monday", 3)
        Hotstring(Format("#di(?:enstag)?(([\+\-0-9]+(t(age?)?|(w(ochen?)?)|m(onate?)?|j(ahre?)?)?)+)?{1}", recognitionKey), "tuesday", 3)
        Hotstring(Format("#mi(?:ttwoch)?(([\+\-0-9]+(t(age?)?|(w(ochen?)?)|m(onate?)?|j(ahre?)?)?)+)?{1}", recognitionKey), "wednesday", 3)
        Hotstring(Format("#do(?:nnerstag)?(([\+\-0-9]+(t(age?)?|(w(ochen?)?)|m(onate?)?|j(ahre?)?)?)+)?{1}", recognitionKey), "thursday", 3)
        Hotstring(Format("#fr(?:eitag)?(([\+\-0-9]+(t(age?)?|(w(ochen?)?)|m(onate?)?|j(ahre?)?)?)+)?{1}", recognitionKey), "friday", 3)
        Hotstring(Format("#sa(?:mstag)?(([\+\-0-9]+(t(age?)?|(w(ochen?)?)|m(onate?)?|j(ahre?)?)?)+)?{1}", recognitionKey), "saturday", 3)
        Hotstring(Format("#so(?:nntag)?(([\+\-0-9]+(t(age?)?|(w(ochen?)?)|m(onate?)?|j(ahre?)?)?)+)?{1}", recognitionKey), "sunday", 3)
        Hotstring(Format("#k(?:alender)?w(?:oche)?(([\+\-0-9]+(t(age?)?|(w(ochen?)?)|m(onate?)?|j(ahre?)?)?)+)?{1}", recognitionKey), "calendarweek", 3)
    }else{
        Hotstring(Format("#today(([\+\-0-9]+(d(ays?)?|w(eeks?)?|m(onths?)?|y(ears?)?)?)+)?{1}", recognitionKey), "today", 3)
        Hotstring(Format("#yesterday(([\+\-0-9]+(d(ays?)?|w(eeks?)?|m(onths?)?|y(ears?)?)?)+)?{1}", recognitionKey), "yesterday", 3)
        Hotstring(Format("#tomorrow(([\+\-0-9]+(d(ays?)?|w(eeks?)?|m(onths?)?|y(ears?)?)?)+)?{1}", recognitionKey), "tomorrow", 3)
        Hotstring(Format("#mo(?:nday)?(([\+\-0-9]+(d(ays?)?|w(eeks?)?|m(onths?)?|y(ears?)?)?)+)?{1}", recognitionKey), "monday", 3)
        Hotstring(Format("#tu(?:esday)?(([\+\-0-9]+(d(ays?)?|w(eeks?)?|m(onths?)?|y(ears?)?)?)+)?{1}", recognitionKey), "tuesday", 3)
        Hotstring(Format("#we(?:dnesday)?(([\+\-0-9]+(d(ays?)?|w(eeks?)?|m(onths?)?|y(ears?)?)?)+)?{1}", recognitionKey), "wednesday", 3)
        Hotstring(Format("#th(?:ursday)?(([\+\-0-9]+(d(ays?)?|w(eeks?)?|m(onths?)?|y(ears?)?)?)+)?{1}", recognitionKey), "thursday", 3)
        Hotstring(Format("#fr(?:iday)?(([\+\-0-9]+(d(ays?)?|w(eeks?)?|m(onths?)?|y(ears?)?)?)+)?{1}", recognitionKey), "friday", 3)
        Hotstring(Format("#sa(?:turday)?(([\+\-0-9]+(d(ays?)?|w(eeks?)?|m(onths?)?|y(ears?)?)?)+)?{1}", recognitionKey), "saturday", 3)
        Hotstring(Format("#su(?:nday)?(([\+\-0-9]+(d(ays?)?|w(eeks?)?|m(onths?)?|y(ears?)?)?)+)?{1}", recognitionKey), "sunday", 3)
        Hotstring(Format("#c(?:alendar)?w(?:eek)?(([\+\-0-9]+(d(ays?)?|(w(eeks?)?)|m(onths?)?|y(ears?)?)?)+)?{1}", recognitionKey), "calendarweek", 3)
    }
}

today($) {
	SendInput % fRelativeDate($)
    Sleep endingKeyDelay
    Send % endingKey
}
yesterday($) {
    SendInput % fRelativeDate($, -1) ; subtracts one day from the calculated date
    Sleep endingKeyDelay
    Send % endingKey
}
tomorrow($) {
    SendInput % fRelativeDate($, 1) ; adds one day to the calculated date
    Sleep endingKeyDelay
    Send % endingKey
}

monday($) {
    SendInput % fWeekday($, 2) ; 2 stands for monday
    Sleep endingKeyDelay
    Send % endingKey
}
tuesday($) {
    SendInput % fWeekday($, 3) ; 3 stands for tuesday
    Sleep endingKeyDelay
    Send % endingKey
}
wednesday($) {
    SendInput % fWeekday($, 4) ; 4 stands for wednesday
    Sleep endingKeyDelay
    Send % endingKey
}
thursday($) {
    SendInput % fWeekday($, 5) ; 5 stands for thursday
    Sleep endingKeyDelay
    Send % endingKey
}
friday($) {
    SendInput % fWeekday($, 6) ; 6 stands for friday
    Sleep endingKeyDelay
    Send % endingKey
}
saturday($) {
    SendInput % fWeekday($, 7) ; 7 stands for saturday
    Sleep endingKeyDelay
    Send % endingKey
}
sunday($) {
    SendInput % fWeekday($, 1) ; 1 stands for sunday
    Sleep endingKeyDelay
    Send % endingKey
}

calendarweek($) {
	SendInput % fCalendarweek($)
    Sleep endingKeyDelay
    Send % endingKey
}

fDate(pDays:=0, pWeeks:=0, pMonths:=0, pYears:=0) {  ; Date Function (Sven Seebeck)
    pWeeks *= 7
	currentDate :=  A_Now
	year := SubStr(currentDate, 1, 4)
	month := Floor(SubStr(currentDate, 5, 2))
    day := Floor(SubStr(currentDate, 7, 2))
	If (pMonths) {
		year += Round((month + pMonths - 1) / 12 - 0.5)
		month := Mod(month + pMonths, 12)
		if (month=0) { 
			month := 12 
		}
        if(day > fDaysInMonth(year . SubStr("00" . month, -1))) {
            day := fDaysInMonth(year . SubStr("00" . month, -1))
        }
	}
	If (pYears) {
		year += pYears
	}
	currentDate := year . SubStr("00" . month, -1) . SubStr("00" . day, -1) . SubStr(currentDate, 9)
    currentDate += %pWeeks%, days
    currentDate += %pDays%, days
    return %currentDate% 
}

fDaysInMonth(date) {
    FormatTime, year,  % date, % "yyyy"
    FormatTime, month, % date, % "MM"
    month += 1                 ; next month
    if (month > 12)
        year += 1, month := 1  ; if next month new year, next year and reset month
    new_date := year . SubStr("00" . month, -1) ; 1 to 01
    new_date += -1, days       ; minus 1 day
    return SubStr(new_date, 7, 2)
}

fMiddleware($, pDays:=0, pWeeks:=0, pMonths:=0, pYears:=0){
    expression := ""
    shorts := []
    if (scopeLang = germanTwoLetter) {
        expression := "O)(([\+\-0-9]+)((t(age?)?|w(ochen?)?|m(onate?)?|j(ahre?)?|$)))"
        shorts := ["t", "w", "m", "j"]
    }else{
        expression := "O)(([\+\-0-9]+)((d(ays?)?|w(eeks?)?|m(onths?)?|y(ears?)?|$)))"
        shorts := ["d", "w", "m", "y"]
    }

	While (Pos := Ma.Pos() = "" ? 1 : Ma.Pos()) := RegExMatch($.Value(1), expression, Ma, Pos + StrLen(Ma.Value(1))) {
        If InStr(Ma.Value(3), shorts[1]) = 1
			pDays += Ma.Value(2)
		If InStr(Ma.Value(3), shorts[2]) = 1 || Ma.Value(3) = ""
			pWeeks += Ma.Value(2)
		If InStr(Ma.Value(3), shorts[3]) = 1
			pMonths += Ma.Value(2)
		If InStr(Ma.Value(3), shorts[4]) = 1
			pYears += Ma.Value(2)
	}

	return % fDate(pDays, pWeeks, pMonths, pYears)
}

fRelativeDate($, pDelta:=0){
    return GetDateFormatEx(fMiddleware($, pDelta), dateFormat)
}

fWeekday($, pWeekday){
    m_date := fMiddleware($,0,0,0,0)
    FormatTime, weekday, % m_date, % "WDay"
    EnvAdd, m_date, % pWeekday - weekday, days
    return GetDateFormatEx(m_date, dateFormat)
}

fCalendarweek($) {
    m_date := fMiddleware($,0,0,0,0)
    FormatTime, output, % m_date, % "YWeek" 
    return SubStr(output, -1)
}

; GetDateFormatEx Function created by jNizM (2015-11-03)
; Forum: https://www.autohotkey.com/boards/viewtopic.php?p=56009#p56009
GetDateFormatEx(Date, Format := "", LocaleName := "!x-sys-default-locale")
{
	VarSetCapacity(SYSTEMTIME, 16, 0)
	NumPut(SubStr(Date,  1, 4), SYSTEMTIME,  0, "ushort") ; Year
	NumPut(SubStr(Date,  5, 2), SYSTEMTIME,  2, "ushort") ; Month
	NumPut(SubStr(Date,  7, 2), SYSTEMTIME,  6, "ushort") ; Day
	NumPut(SubStr(Date,  9, 2), SYSTEMTIME,  8, "ushort") ; Hour
	NumPut(SubStr(Date, 11, 2), SYSTEMTIME, 10, "ushort") ; Minutes
	NumPut(SubStr(Date, 13, 2), SYSTEMTIME, 12, "ushort") ; Seconds

	if (Size := DllCall("GetDateFormatEx", "str", LocaleName, "uint", 0, "ptr", &SYSTEMTIME, "ptr", (Format ? &Format : 0), "ptr", 0, "int", 0, "ptr", 0)) {
		VarSetCapacity(DateStr, Size << !!A_IsUnicode, 0)
		if (DllCall("GetDateFormatEx", "str", LocaleName, "uint", 0, "ptr", &SYSTEMTIME, "ptr", (Format ? &Format : 0), "str", DateStr, "int", Size, "ptr", 0))
			return DateStr
	}
	return false
}

; Hotstring created by menixator (2017-08-14)
; GitHub: https://github.com/menixator/hotstring
/*
Hotstring(
	trigger:
		A string or a regular expression to trigger the hotstring. (If you use a regex here, the mode should be 3 for the regex to work)
	
	label:  	
		A string to replace the trigger / A label to go to / A function to call when the hotstring is triggered.
		If you used a regular expression as the trigger and mode was set to three, backreferences like $0, $1 would work.
		If a function name was passed, the function will be called with the phrase that triggered the hotstring(If the trigger was a string)
			or the Match object(If the trigger was a regex & mode equals 3).
		If this parameter was a label, the global variable '$' will contain the string/match object.
		If you wish to remove a hotstring, Pass the trigger with this parameter empty.
	
	Mode:	
		A number between 1 and 3 that determines the properties of the hotstring.
		If Mode == 1 then the hotstring is case insensitive.
		If Mode == 2 then the hostrings is case sensitive.
		If Mode == 3 then you can use regex in the trigger.
		
		1 is the defualt.
	
	clearTrigger:
			Determines if the trigger is erased after the hotstring is triggered.
	
	cond:
			A name of a function that allows the conditional trigerring of the hotstring.
	
)
*/
Hotstring(trigger, label, mode := 1, clearTrigger := 1, cond := ""){
	global $
	static keysBound := false,hotkeyPrefix := "~$", hotstrings := {}, typed := "", keys := {"symbols": "!""#$%&'()*+,-./:;<=>?@[\]^_``{|}~", "num": "0123456789", "alpha":"abcdefghijklmnopqrstuvwxyz", "other": "BS,Return,Tab,Space", "breakKeys":"Left,Right,Up,Down,Home,End,RButton,LButton,LControl,RControl,LAlt,RAlt,AppsKey,Lwin,Rwin,WheelDown,WheelUp,f1,f2,f3,f4,f5,f6,f7,f8,f9,f6,f7,f9,f10,f11,f12", "numpad":"Numpad0,Numpad1,Numpad2,Numpad3,Numpad4,Numpad5,Numpad6,Numpad7,Numpad8,Numpad9,NumpadDot,NumpadDiv,NumpadMult,NumpadAdd,NumpadSub,NumpadEnter"}, effect := {"Return" : "`n", "Tab":A_Tab, "Space": A_Space, "Enter":"`n", "Dot": ".", "Div":"/", "Mult":"*", "Add":"+", "Sub":"-"}
	
	if (!keysBound){
		;Binds the keys to watch for triggers.
		for k,v in ["symbols", "num", "alpha"]
		{
			;alphanumeric/symbols
			v := keys[v]
			Loop,Parse, v
				Hotkey,%hotkeyPrefix%%A_LoopField%,__hotstring
		}
		
		v := keys.alpha
		Loop,Parse, v
			Hotkey, %hotkeyPrefix%+%A_Loopfield%,__hotstring
		for k,v in ["other", "breakKeys", "numpad"]
		{
			;comma separated values
			v := keys[v]
			Loop,Parse, v,`,
				Hotkey,%hotkeyPrefix%%A_LoopField%,__hotstring
		}
		keysBound := true ;keysBound is a static varible. Now, the keys won't be bound twice.
	}
	if (mode == "CALLBACK"){
		; Callback for the hotkey.s
		Hotkey := SubStr(A_ThisHotkey,3)
		if (StrLen(Hotkey) == 2 && Substr(Hotkey,1,1) == "+" && Instr(keys.alpha, Substr(Hotkey, 2,1))){
			Hotkey := Substr(Hotkey,2)
			if (!GetKeyState("Capslock", "T")){
				StringUpper, Hotkey,Hotkey
			}
		}
		
		shiftState := GetKeyState("Shift", "P")
		uppercase :=  GetKeyState("Capslock", "T") ? !shiftState : shiftState 
		;If capslock is down, shift's function is reversed.(ie pressing shift and a key while capslock is on will provide the lowercase key)
		if (uppercase && Instr(keys.alpha, Hotkey)){
			StringUpper, Hotkey,Hotkey
		}
		if (Instr("," . keys.breakKeys . ",", "," . Hotkey . ",")){
			typed := ""
			return
		} else if Hotkey in Return,Tab,Space
		{
			typed .= effect[Hotkey]
		} else if (Hotkey == "BS"){
			; trim typed var if Backspace was pressed.
			StringTrimRight,typed,typed,1
			return
		} else if (RegExMatch(Hotkey, "Numpad(.+?)", numKey)) {
			if (numkey1 ~= "\d"){
				typed .= numkey1
			} else {
				typed .= effect[numKey1]
			}
		} else {
			typed .= Hotkey
		}
		matched := false
		for k,v in hotstrings
		{
			matchRegex := (v.mode == 1 ? "Oi)" : "")  . (v.mode == 3 ? RegExReplace(v.trigger, "\$$", "") : "\Q" . v.trigger . "\E") . "$"
			
			if (v.mode == 3){
				if (matchRegex ~= "^[^\s\)\(\\]+?\)"){
					matchRegex := "O" . matchRegex
				} else {
					matchRegex := "O)" . matchRegex
				}
			}
			if (RegExMatch(typed, matchRegex, local$)){
				matched := true
				if (v.cond != "" && IsFunc(v.cond)){
					; If hotstring has a condition function.
					A_LoopCond := Func(v.cond)
					if (A_LoopCond.MinParams >= 1){
						; If the function has atleast 1 parameters.
						A_LoopRetVal := A_LoopCond.(v.mode == 3 ? local$ : local$.Value(0))
					} else {
						A_LoopRetVal := A_LoopCond.()
					}
					if (!A_LoopRetVal){
						; If the function returns a non-true value.
						matched := false
						continue
					}
				}
				if (v.clearTrigger){
					;Delete the trigger
					SendInput % "{BS " . StrLen(local$.Value(0))  . "}"
				}
				if (IsLabel(v.label)){
					$ := v.mode == 3 ? local$ : local$.Value(0)
					gosub, % v.label
				} else if (IsFunc(v.label)){
					callbackFunc := Func(v.label)
					if (callbackFunc.MinParams >= 1){
						callbackFunc.(v.mode == 3 ? local$ : local$.Value(0))
					} else {
						callbackFunc.()
					}
				} else {
					toSend := v.label
				
					;Working out the backreferences
					Loop, % local$.Count()
						StringReplace, toSend,toSend,% "$" . A_Index,% local$.Value(A_index),All
					toSend := RegExReplace(toSend,"([!#\+\^\{\}])","{$1}") ;Escape modifiers
					SendInput,%toSend%
				}
				
			}
		}
		if (matched){
			typed := ""
		} else if (StrLen(typed) > 350){
			StringTrimLeft,typed,typed,200
		}
	} else {
		if (hotstrings.HasKey(trigger) && label == ""){
			; Removing a hotstring.
			hotstrings.remove(trigger)
		} else {
			; Add to hotstrings object.
			hotstrings[trigger] := {"trigger" : trigger, "label":label, "mode":mode, "clearTrigger" : clearTrigger, "cond": cond}
		}
		
	}
	return

	__hotstring:
	; This label is triggered every time a key is pressed.
	Hotstring("", "", "CALLBACK")
	return
}