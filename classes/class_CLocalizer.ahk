#include <class_CIniFile>

class CLocalizer
{
  ; The directory where all language files are stored 
  dir := ""
  ; Current language id
  langId := ""
  ; Current language name
  langName := "" 
  ; Current localization strings
  strings := []
  ; The file extension
  FileExtenstion := "ini"
  ; Language id-name list
  LanguageList := {}
  
  __New(dir)
  {
    this.dir := dir
  }

;
; Function: GetLanguageFileName
; Description:
;		Cteates the language file name for the supplied language id.
; Syntax: CLocalizer.GetLanguageFileName(langId)
; Parameters:
;		langId - The language id like "en-US".
; Return Value:
; 		Returns the language file name for the supplied language id.
;
  GetLanguageFileName(langId)
  {
    fname := this.dir "\" langId "." this.FileExtenstion
    return fname
  }

;
; Function: ReadLanguageList
; Description:
;		Reads language ids and names into LanguageList property of CLocalizer.
; Syntax: CLocalizer.ReadLanguageList()
; Return Value:
; 		Returns the language list.
;

; USES: CIniFile.Read.
; SIDE-EFFECT: Updates LanguageList.
  ReadLanguageList()
  {
    result := {}
    pattern := this.dir "\*." this.FileExtenstion
    Loop, %pattern%
    {
;       OutputDebug CLocalizer.ReadLanguageNames: Looping thru %A_LoopFileFullPath%
      SplitPath, A_LoopFileFullPath,,,,langId
      ini := new CIniFile(A_LoopFileFullPath)
      langName := ini.Read(langId, "_langName")
;       OutputDebug CLocalizer.ReadLanguageNames: got langName = %langName% 
      if(langName <> ini.defaultValue)
        result[langId] := langName
    }
    this.LanguageList := result
    return result
  }

;
; Function: CreateLanguageFile
; Description:
;		Creates a language file for the specified language ID and name and writes supplied strings into it.
; Syntax: CLocalizer.CreateLanguageFile(langId, langName, strings)
; Parameters:
;		langId - The language id like "en-US".
;		langName - The language display name (spelled in the language itself).
;		strings - An associative array of string IDs with the respective strings.
; Remarks:
;		Sets ErrorLevel to 1 if an attempt to create the file failed.
;
  CreateLanguageFile(langId, langName, strings)
  {
;     OutputDebug In CLocalizer.CreateLanguageFile(%langId%, %langName%, %strings%)
    fname := this.GetLanguageFileName(langId)
;     OutputDebug `tChecking file for existence = %fname%
    ini := new CIniFile(fname)
    if(!ini.Exists(fname))
    {
      if(!ini.CreateIfNotExists())
      {
        ErrorLevel := 1
        return
      }
    }
    strings["_langName"] := langName
    strings["_langId"] := langId
    ini.WriteSection(langId, strings)
  }

;
; Function: LoadStrings
; Description:
;		Loads strings for the specified language ID.
; Syntax: CLocalizer.LoadStrings(langId, defaultStrings)
; Parameters:
;		langId - The language id like "en-US".
;		defaultStrings - (Optional) An associative array of string IDs with the respective strings
;       that will be used if some strings were not localised.
; Remarks:
;		If any string ID is not localized, the respective default string remains as is.
;     ErrorLevel is set to 1 on failure to write default strings into a new language file upon the first start.
;
  LoadStrings(langId, defaultStrings = "")
  {
;     OutputDebug Loading strings for langId = %langId%
    success := true
    if(!IsObject(defaultStrings))
      defaultStrings := {}
      
    this.strings := defaultStrings
    this.langId := langId
    this.fileName := this.GetLanguageFileName(this.langId)
    ini := new CIniFile(this.fileName)
    if(!ini.GetSectionCount()) ; Also checks for existence
    {
      this.CreateLanguageFile(defaultStrings._langId, defaultStrings._langName, defaultStrings)
      if ErrorLevel
        success := false
    }
;     OutputDebug LoadStrings before read ErrorLevel = %ErrorLevel% 
    strings := ini.ReadSection(this.langId)
;     OutputDebug LoadStrings after read ErrorLevel = %ErrorLevel% 
    for k, s in strings
    {
;       OutputDebug Trying string %k% = %s%
      ; Disallow any custom strings
      if(defaultStrings.haskey(k))
      {
        this.strings[k] := s
;         OutputDebug Loaded string %k% = %s%
      }
    }
    
    if(!success)
      ErrorLevel := 1
    else if(ErrorLevel)
      ErrorLevel := 2
      
;     OutputDebug LoadStrings result ErrorLevel = %ErrorLevel% 
  }
  
;
; Function: GetLangIdByName
; Description:
;		Gets the language ID for the specified language name.
; Syntax: CLocalizer.GetLangIdByName(langName)
; Parameters:
;		langName - The language display name (spelled in the language itself).
; Return Value:
; 		Returns the language ID like "en-US".
;

; USES: ReadLanguageList to update the language list.
; SIDE-EFFECT: Updates LanguageList.
  GetLangIdByName(langName)
  {
    this.ReadLanguageList()
    result := ""
    for langId, exlangName in this.LanguageList
    {
;       OutputDebug comparing %langName%, %exlangName%
      if(String_IsEqual(langName, exlangName))
      {
        result := langId
        break
      }
    }
;     OutputDebug return %langId%
    return langId
  }
  
  GetLanguageList()
  {
    this.ReadLanguageList()
    return this.LanguageList
  }
}
