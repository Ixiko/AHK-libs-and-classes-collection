#include <class_CFile>

; Throw exceptions where a programmer fails
; TODO: add example section for all functions (starting from WriteSection)
; TODO: create new documentation
; XTODO: add object serialization features

CIniFile_New(fileName)
{
	return new CIniFile(fileName)
}

;
; Function: CIniFile
; Description:
;                An object that represents an .ini file.
; Syntax: ini := new CIniFile(FileName)
; Parameters:
;                FileName - The name of the file, which is assumed to be in %A_WorkingDir% if an absolute path isn't specified.
; Return Value:
;                Returns an instance of CIniFile object.
; Remarks:
; 				Reading/deleting methods do not try to create the .ini file, but writing methods do. If a writing method fails to create the .ini file, it means that ErrorLevel is set to a value other than 0 by FileCreateDir command or FileOpen function used to create the .ini file. In this case A_LastError is set to the result of the operating system's GetLastError() function.
; Example:
;				fname := A_ScriptDir "\test.ini"
;				; Delete the temporary file for testing purposes
;				FileDelete % fname
; 				ini := new CIniFile(fname)
; 				ini.WriteAll({sec1:{key11:"val11", key12:"val12"}, sec2:{key21:"val21", key22:"val22"}})
; 				MsgBox, % "key21 = " ini.Read("sec2", "key21") ; Outputs "key21=val21" in a MessageBox 
;

class CIniFile
{
	; INI file name
	fileName := ""
	; The Default value to return if the Read method finds no value.
	defaultValue := "ERROR"
	
	__New(FileName)
	{
		this.fileName := FileName
		;~ OutputDebug, % "CIniFile created with file name " this.FileName
	}
	
;
; Function: Exists
; Description:
;                Determines if the file exists.
; Syntax: exists := CIniFile.Exists()
; Return Value:
;                Returns true if the file exists and false otherwise.
; Related: CreateIfNotExists
; Example:
;				fname := A_ScriptDir "\test.ini"
;				; Delete the temporary file for testing purposes
;				FileDelete % fname
; 				ini := new CIniFile(fname)
; 				MsgBox, % ini.Exists() ; Outputs "0" in a MessageBox (CIniFile object creation does not involve the .ini file creation)
; 				ini.WriteAll({sec1:{key11:"val11", key12:"val12"}, sec2:{key21:"val21", key22:"val22"}})
;				; At this point the .ini file should be created during WriteAll call
; 				MsgBox, % ini.Exists() ; Outputs "1" in a MessageBox
;
	Exists()
	{
		result := FileExist(this.FileName) <> ""
;     OutputDebug % "CIniFile: Exists (" this.FileName ") = " result
		return result
	}
	
;
; Function: CreateIfNotExists
; Description:
;                Creates the file if it does not exist.
; Syntax: CIniFile.CreateIfNotExists()
; Return value:
;				Returns true if the file was successfully created or already exists and false otherwise.
; Remarks:
;				Call this method to determine if the .ini file can be created,
;					This method is called internally by all write methods of the CIniFile object, so there's no need to call it before writing into the .ini file.
;                	ErrorLevel is set to 1 on failure to create the file (e.g. invalid file name).
; Related: Exists, Write, WriteSection, WriteAll
; Example:
;				fname := A_ScriptDir "\test.ini"
;				; Delete the temporary file for testing purposes
;				FileDelete % fname
; 				ini := new CIniFile(fname)
; 				MsgBox, % ini.Exists() ; Outputs "0" in a MessageBox (CIniFile object creation does not involve the .ini file creation)
; 				if(ini.CreateIfNotExists())
;				{
;					; At this point the .ini file should be created during WriteAll call
; 					MsgBox, % ini.Exists() ; Outputs "1" in a MessageBox
;				}
;				else
;					MsgBox % "Could not create the .ini file: " ini.FileName
;
	CreateIfNotExists()
	{
    global CFile
		if (!this.Exists())
		{
			file := CFile.Create(this.FileName)
			if(IsObject(file))
			{
				file.Close()
        return true
			}
			else
			{
				ErrorLevel = 1
        return false
			}
		}
    else
      return true
	}
	
;
; Function: GetSectionCount
; Description:
;                Gets section count in the .ini file.
; Syntax: cnt := CIniFile.GetSectionCount()
; Return Value:
;                Returns section count in the .ini file. See Remarks.
; Remarks:
;                If the .ini file does not exist, ErrorLevel is set to 1, and the return value is 0. If the .ini file exists but contains no sections, both ErrorLevel and return value are set to 0.
; Example:
;				fname := A_ScriptDir "\test.ini"
;				; Delete the temporary file for testing purposes
;				FileDelete % fname
;				ini := new CIniFile(fname)
;				ini.WriteAll({sec1:{key11:"val11", key12:"val12"}, sec2:{key21:"val21", key22:"val22"}})
;				MsgBox % "There are " ini.GetSectionCount() " sections in " ini.FileName
;
	GetSectionCount()
	{
		if(!this.Exists())
    {
      ErrorLevel = 1
      return 0
    }
		
		IniRead, sections,  % this.FileName
		StringSplit, sectionsArray, sections, `n
		return sectionsArray0
	}

;
; Function: GetSectionNamesArray
; Description:
;                Returns section names in the form of an array object.
; Syntax: cnt := CIniFile.GetSectionNamesArray()
; Return Value:
;                Returns section names as an array object. If the file is empty, returns an empty string.
; Remarks:
;				If the file does not exist, ErrorLevel is set to 1 and an empty string is returned.
; Example:
;				fname := A_ScriptDir "\test.ini"
;				; Delete the temporary file for testing purposes
;				FileDelete % fname
;				ini := new CIniFile(fname)
;				ini.WriteAll({sec1:{key11:"val11", key12:"val12"}, sec2:{key21:"val21", key22:"val22"}})
;				sections := ini.GetSectionNamesArray()
;				for index, section in sections
;				{
;					MsgBox, 4, Sections, Section %section%.`nContinue?
;					IfMsgBox, No, break
;				}
;
	GetSectionNamesArray()
	{	
		sections := this.GetSectionNamesString()
    if (ErrorLevel || sections = "")
    {
;       OutputDebug GetSectionNamesArray: returning ""
      return ""
		}
    
		if(InStr(sections, "`n") = 0)
    {
;       OutputDebug GetSectionNamesArray: returning [%sections%]
			return [sections]
    }
		
;     OutputDebug GetSectionNamesArray: sections = %sections%
    
		StringSplit, sectionsArray, sections, `n

		result := []
		Loop,  %sectionsArray0%
			result.insert(sectionsArray%A_Index%)
		
    ; An empty string is returned to incapsulate Count checks into this method.
    if(Count(result) = 0)
			return ""
		else
			return result
	}

;
; Function: HasSection
; Description:
;		Checks if the specified section exists in the INI file.
; Syntax: CIniFile.HasSection(Section)
; Parameters:
;		Section - Section name
; Return Value:
; 		Returns true if the section exists and false otherwise.
; Remarks:
;		ErrorLeves is set to 1 if the file does not exist or has no sections
; Related: GetSectionNamesArray, GetSectionNamesString.
; Example:
;				fname := A_ScriptDir "\test.ini"
;				; Delete the temporary file for testing purposes
;				FileDelete % fname
;				ini := new CIniFile(fname)
;				ini.WriteAll({sec1:{key11:"val11", key12:"val12"}, sec2:{key21:"val21", key22:"val22"}})
;				result := ini.HasSection("sec1")
;				if(result)
;             MsgBox, Section sec1 exists
;       else
;             MsgBox, Section sec1 does not exist
;

  HasSection(section)
  {
    sections := this.GetSectionNamesString()
		if (ErrorLevel || sections = "")
      return false
		
		if(InStr(sections, "`n") = 0)
			return sections = section
		
		StringSplit, sectionsArray, sections, `n

		result := []
		Loop,  %sectionsArray0%
    {
      if(sectionsArray%A_Index% = section)
        return true
		}
    return false
  }

;
; Function: GetSectionNamesString
; Description:
;                Gets section names in a string with specified delimiters.
; Syntax: cnt := CIniFile.GetSectionNamesString([Delimiter])
; Parameters:
;                Delimiter - (Optional) Specifies a delimiter for section names. Default value: `n.
; Return Value:
;                Returns section names in a string with specified delimiters. If the file is empty, returns an empty string.
; Remarks:
;				If the file does not exist, an exception is thrown.
; Example:
;				fname := A_ScriptDir "\test.ini"
;				; Delete the temporary file for testing purposes
;				FileDelete % fname
;				ini := new CIniFile(fname)
;				ini.WriteAll({sec1:{key11:"val11", key12:"val12"}, sec2:{key21:"val21", key22:"val22"}})
;				; Get section names separated by a pipe (|)
;				sections := ini.GetSectionNamesString("|")
;				MsgBox, Sections: %sections%
;
	GetSectionNamesString(Delimiter = "`n")
	{
;     OutputDebug GetSectionNamesString: Start: ErrorLevel = %ErrorLevel%
		if(!this.Exists())
		{
;       OutputDebug GetSectionNamesString: ini does not exist
			ErrorLevel = 1
      return ""
    }
    
;     OutputDebug GetSectionNamesString: Before reading: ErrorLevel = %ErrorLevel%
		
		IniRead, sections,  % this.FileName

		if(Delimiter = "`n" || InStr(sections, "`n") = 0)
    {
;       OutputDebug GetSectionNamesString: Std delim or a single section: returning %sections%, ErrorLevel = %ErrorLevel%
			return sections
    }
		else
		{
			StringReplace, result, sections, `n, %Delimiter%, all
			; For an empty file, StringReplace sets ErrorLevel to 1 because `n is not found
			if(ErrorLevel = 1)
			{
				ErrorLevel = 0
;         OutputDebug GetSectionNamesString: Alternate delimiter, returning ""
				return ""
			}
			else
      {
;         OutputDebug GetSectionNamesString: Alternate delimiter, returning %result%, ErrorLevel = %ErrorLevel%
				return result
      }
		}
	}
  
;
; Function: ReadSection
; Description:
;                Gets section data as an associative array.
; Syntax: cnt := CIniFile.ReadSection(Section)
; Parameters:
;                Section - The section name in the .ini file.
; Return Value:
;                Returns settings names and values in an associative array. If the file is empty, an empty string is returned.
; Remarks:
;				If the .ini file does not exist, an exception is thrown.
; 					TODO: what is retval if a file does not contain the section
; Example:
;				fname := A_ScriptDir "\test.ini"
;				; Delete the temporary file for testing purposes
;				FileDelete % fname
;				ini := new CIniFile(fname)
;				ini.WriteAll({sec1:{key11:"val11", key12:"val12"}, sec2:{key21:"val21", key22:"val22"}})
;				; Get section values
;				sec := ini.ReadSection("sec1")
;				MsgBox, % "Section values: key11 = " sec.key11 "; key12 = " sec.key12
;
	ReadSection(Section)
	{
;     OutputDebug In CIniFile.ReadSection(%Section%)
    
    ; HasSection method checks for existence
		if(!this.HasSection(Section))
    {
;       OutputDebug % "No section '" section "' in the file " this.fileName 
			return ""
    } 
    settings := this._ReadSection(section)
;     OutputDebug Read section content: %settings%
		; IniRead deprecated because it does not read long sections
; 		IniRead, settings, % this.FileName, %Section%
;     OutputDebug % "IniRead, " settings ", " this.FileName ", " Section
		
		result := {}
		Loop, Parse, settings, `n
		{
			StringSplit, keyValuePair, A_LoopField, =
			result[keyValuePair1] := keyValuePair2
		}
; 		OutputDebug ReadSection result ErrorLevel = %ErrorLevel% 
		return result
	}
  
  _ReadSection(section)
  {
    result := ""
    FileRead, content, % this.fileName
    reading := false
    sectionString = [%section%]
    Loop, Parse, content, `n, `r
    {
      if(A_LoopField = sectionString)
      {
        reading := true
      }
      else if(reading)
      {
        if(SubStr(A_LoopField, 1, 1) = "[")
          break
        else
          result .= A_LoopField "`n"
      }
    }
    
    return result
  }
	
;
; Function: WriteSection
; Description:
;                Writes the supplied associative array to the specified section.
; Syntax: CIniFile.WriteSection(Section, KeyValuePairs)
; Parameters:
;               Section - The section name in the ini file.
;				         KeyValuePairs - The associative array of keys and values for the section.
; Remarks:
;				if Section is an empty string, an exception is thrown.
;                	Sets ErrorLevel to on failure to the following values:
;						1 - Could not create the file.
;						2  - Error writing to the .ini file.
; Related: VerifyKeyValuePairs, WriteAll, Write, ReadAll
; Example:
;				fname := A_ScriptDir "\test.ini"
;				; Delete the temporary file for testing purposes
;				FileDelete % fname
;				ini := new CIniFile(fname)
;				ini.WriteSection("sec1", {key11:"val11", key12:"val12"})
;				; Get section values
;				sec := ini.ReadSection("sec1")
;				MsgBox, % "Section values: key11 = " sec.key11 "; key12 = " sec.key12
;

	WriteSection(Section, KeyValuePairs)
	{
;     OutputDebug % "Writing section '" section "' to the file " this.fileName 
		exists := this.CreateIfNotExists()
		if(!exists)
		{
			ErrorLevel := 1
			return
		}
		
		if(Section = "")
			throw "CIniFile.WriteSection: Section is an empty string."
		
		this.VerifyKeyValuePairs(KeyValuePairs)
		
		for k, v in KeyValuePairs
		{
			this.Write(Section, k, v)
		}
	}

;
; Function: Read
; Description:
;                Reads a value from a standard format .ini file.
; Syntax: value := CIniFile.Read(section, key [, default])
; Parameters:
;               Section - The section name in the .ini file.
;				Key - The key name in the .ini file.
;				Default - (Optional) The value to return if the requested key is not found. If omitted, it defaults to the word ERROR. To store a blank value (empty string), specify %A_Space%.
; Return value:
;				Returns the retrieved value. If the value cannot be retrieved, the variable is set to the value indicated by the Default parameter, and the ErrorLevel is set to 0 if IniRead fails or to a value greater than 0 in some other cases (see remarks).
; Remarks:
;                Sets ErrorLevel to 1 if the file does not exist, to 2 or 3 if a section or a key name is an empty string, recpectively.
; Example:
;				fname := A_ScriptDir "\test.ini"
;				; Delete the temporary file for testing purposes
;				FileDelete % fname
;				ini := new CIniFile(fname)
;				ini.WriteSection("sec1", {key11:"val11", key12:"val12"})
;				; Get a key's value
;				key11_val11 := ini.Read("sec1", "key11")
;				MsgBox, % "key11 value = " key11_val11
;

	Read(Section, Key, Default="ERROR")
	{
;     OutputDebug CIniFile.Read(%Section%, %Key%, %Default%
    
		if(Default = "ERROR")
			Default := this.defaultValue ; a value of the parameter in a function definition can not be set to the object's property value
		
		if(!this.Exists())
		{
      ErrorLevel = 1
      return Default
    }
		
		if(Section = "")
		{
      ErrorLevel = 2
      return Default
    }
		
		if(Key = "")
		{
      ErrorLevel = 3
      return Default
    }
		
;     OutputDebug % "IniRead, value, " this.FileName ", " Section ", " Key ", " Default
    
		IniRead, value, % this.FileName, %Section%, %Key%, %Default%
    
;     OutputDebug IniRead result = %value%
		return value
	}
	
;
; Function: Write
; Description:
;                Writes a value to a standard format .ini file.
; Syntax: CIniFile.Write(Value, Section, Key)
; Parameters:
;   Section - The section name in the .ini file, which is the heading phrase that appears in square brackets (do not include the brackets in this parameter).
;				Key - The key name in the .ini file.
;       Value - The string or number that will be written to the right of Key's equal sign (=). 
; Remarks:
;				Throws an exception if Section or Key is an empty string.
;                	Sets ErrorLevel to on failure to the following values:
;						1 - Could not write to the file.
;           2 - Could not create the file.
;						3 - Section is an empty string.
;						4 - Key is an empty string.
; Example:
;				fname := A_ScriptDir "\test.ini"
;				; Delete the temporary file for testing purposes
;				FileDelete % fname
;				ini := new CIniFile(fname)
;				; Write a key's value
;				ini.Write("sec1", "key11", "val11")
;       ; Get a key's value
;				key11_val11 := ini.Read("sec1", "key11")
;				MsgBox, % "key11 value = " key11_val11
;
	
	Write(Section, Key, Value)
	{
		exists := this.CreateIfNotExists()
		if(!exists)
		{
			ErrorLevel := 2
			return
		}
		
		if(Section = "")
		{
      ErrorLevel = 3
      return
    }
		
		if(Key = "")
		{
      ErrorLevel = 4
      return
    }
		
;     OutputDebug % "CIniFile.Write(" Value ", " this.FileName ", " Section ", " Key ")"
    
		IniWrite, %Value%, % this.FileName, %Section%, %Key%
	}
	
	
;
; Function: ReadAll
; Description:
;                Reads all data from a standard format .ini file.
; Syntax: settingsBySections := CIniFile.ReadAll()
; Return value:
;				Returns an associative array where keys are sectrion names and each value is an associative array as returned by CIniFile.ReadSection(). If the file is empty, an empty string is returned.
; Remarks:
;               ErrorLevel is set to that of the last ReadSection method call.
; Related: Write, WriteAll, ReadSection.
; Example:
; 				fname := A_ScriptDir "\test.ini"
; 				; Delete the temporary file for testing purposes
; 				FileDelete % fname
; 				ini := new CIniFile(fname)
; 				ini.WriteAll({sec1:{key11:"val11", key12:"val12"}, sec2:{key21:"val21", key22:"val22"}})
; 				; Get section values
; 				data := ini.ReadAll()
; 				MsgBox, % "Section 1 key 1.1 value = " data.sec1.key11 "`nsection 2 key 2.1 value = " data.sec2.key21
;
	ReadAll()
	{
		; No need to check file existence because it is checked both in GetSectionNamesArray and ReadSection methods.
		result := ""
		sections := this.GetSectionNamesArray()
; 		OutputDebug, % "ReadAll: Section count: " Count(sections)
		if(sections <> "")
		{
			result := {}
			for i, section in sections
			{
; 				OutputDebug, Reading[%i%] %section%
				result[section] := this.ReadSection(section)
			}
		}
; 		OutputDebug, Returning
; 		Dump(result)
		return result
	}

;
; Function: WriteAll
; Description:
;               Writes keys and values of sections from an associative array to the .ini file.
; Syntax: CIniFile.WriteAll(Settings)
; Parameters:
;                settings - The input array should be of the same format as returned by ReadAll method, e.g. [code]{section1:{key11:val11, key12:val12},section2:{key21:val21}}[/code].
; Return value:
;				Returns false if settings are not properly formatted or an attempt to write to the file failed.
; Remarks:
;                ErrorLevel is that of Write method. Exceptions are thrown if the data is not properly formatted. See VerifySettings.
; Related: Write, ReadAll, VerifySettings.
; Example:
; 				fname := A_ScriptDir "\test.ini"
; 				; Delete the temporary file for testing purposes
; 				FileDelete % fname
; 				ini := new CIniFile(fname)
; 				ini.WriteAll({sec1:{key11:"val11", key12:"val12"}, sec2:{key21:"val21", key22:"val22"}})
; 				; Get section values
; 				data := ini.ReadAll()
; 				MsgBox, % "Section 1 key 1.1 value = " data.sec1.key11 "`nsection 2 key 2.1 value = " data.sec2.key21
;
	WriteAll(Settings)
	{
;     OutputDebug In CIniFile.WriteAll(%Settings%)
		; Verify settings format
		
		this.VerifySettings(Settings)
		
		; No need to check file existence because it is checked in Write method.
		
		for section, setting in Settings
		{
			for key, value in setting
			{
;         OutputDebug `tWriting %section%.%key% = %value%
				this.Write(section, key, value)
			}
		}
		
		if ErrorLevel
			return false
		else
			return true
	}
	
	VerifySettings(Settings)
	{
		; Settings should be an object
		if(!IsObject(Settings))
			throw "CIniFile.VerifySettings: Settings is not an object."
		
		; Settings should be properly formatted
		for section, KeyValuePairs in Settings
		{
			if(IsObject(section))
				throw "CIniFile.VerifySettings: One of section names is an object."
			
			this.VerifyKeyValuePairs(KeyValuePairs)
		}
	}
	
	VerifyKeyValuePairs(KeyValuePairs)
	{
		; The second level should contain objects
		if(!IsObject(KeyValuePairs))
			throw "CIniFile.VerifyKeyValuePairs: KeyValuePairs is not an object."
			
		for k, v in KeyValuePairs
		{
			
			; Keys should be non-objects
			if(IsObject(k))
			{
				throw "CIniFile.VerifyKeyValuePairs: One of keys in KeyValuePairs is an object."
			}
			
			; Values should be non-objects
			if(IsObject(v))
			{
				throw "CIniFile.VerifyKeyValuePairs: One of values in KeyValuePairs is an object."
			}
		}
	}

;
; Function: Delete
; Description:
;                Deletes a value or an entire section from a standard format .ini file. 
; Syntax: CIniFile.Delete(section [, key])
; Parameters:
;                Section - The section name in the .ini file, which is the heading phrase that appears in square brackets (do not include the brackets in this parameter). 
;                Key - (Optional) The key name in the .ini file. [b]If omitted, the entire Section will be deleted[/b].
; Remarks:
;                ErrorLevel is set to 1 on failure to delete a value/section or to 2 if the Section parameter is an empty string.
; Related: MyFunc1, MyFunc2, [bbcode]some literal text with commas (`,) and backticks (`). BBCode allowed.
;                When this parameter is omitted, it defaults to linking every
;                single documentated function in the file.
; Example:
; 				fname := A_ScriptDir "\test.ini"
; 				; Delete the temporary file for testing purposes
; 				FileDelete % fname
; 				ini := new CIniFile(fname)
; 				ini.WriteAll({sec1:{key11:"val11", key12:"val12"}, sec2:{key21:"val21", key22:"val22"}})
; 				  key11_val11 := ini.Read("sec1", "key11")
; 				  MsgBox, % "key11 value before deletion = " key11_val11
;         ini.Delete("sec1")
; 				  key11_val11 := ini.Read("sec1", "key11")
; 				  MsgBox, % "key11 value after deletion = " key11_val11
;
	Delete(Section, Key="")
	{
		if(Section = "")
		{
			ErrorLevel = 1
			return
		}
		
		if(key <> "")
			IniDelete, % this.FileName, %Section%, %Key%
		else
			IniDelete, % this.FileName, %Section%
	}
	
; 	GetKeySection(key)
; 	{
; 		sections := this.GetSectionNamesString()
; 		Loop, Parse, sections, `n
; 		{
; 			section := this.ReadSection(A_LoopField)
; 			if(section.haskey(key))
; 				return section
; 		}
; 	}
}
