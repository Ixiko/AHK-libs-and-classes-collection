class CDataBase
{
  fileName := ""
  ini := ""
  
  result := ""
  data := {}
  
  __New(fileName)
  {
    this.fileName := fileName
    this.Create()
  }
  
  Create()
  {
;     OutputDebug In CDataBase.Create()
    this.ini := new CIniFile(this.fileName)
    if(!this.ini.Exists())
    {
      if(!this.ini.CreateIfNotExists())
      {
        ErrorLevel := 1
;         OutputDebug Could not create
        return
      }
    }
    data := this.ini.readAll()
    this.data := {}
    for hsKey, hsString in data.hotstrings
    {
      StringSplit, hsFields, hsString, |
      hs := CHotstringOptions.ToHotstring(hsFields3)
      hs.Abbreviation := hsFields1
      StringReplace, hsFields2, hsFields2, <r>, `r
      StringReplace, hsFields2, hsFields2, <n>, `n
      hs.Phrase := hsFields2
      this.AddHotstring(hs)
;       OutputDebug Added HS %hsKey%
    }
  }
  
  ; Adds a hotstring to the hotstring list.
	; If the string's StartAnywhere parameter is set to true, the hotstring is indexed to fasten the search.
	; Returns the hotstring key on success or false if a hotstring with the respective key exists/is invalid.
	; The key is equal to the abbreviation if the hotstring is case sensitive,
	; otherwise it is equal to uppercased abbreviation.
	AddHotstring(hs, write = false)
	{
; 		OutputDebug % "In CLangBase.AddHotstring(" hs.Abbreviation ", "DefaultOptions ", " write ")"
;     dump(hs)
;     OutputDebug % "`tOEC = " hs.OmitEndChar
		; Return false if hs is invalid
		if(!hs.HasKey("Abbreviation") or hs.Abbreviation = "")
    {
;       OutputDebug % "`tAn abbreviation is empty or no Abbreviation field:" hs.Abbreviation
			return false
		}
    
		; Set default options
		if(hs.HasKey("CaseSensitive") = false)
			hs.CaseSensitive := DefaultOptions.CaseSensitive
		if(hs.HasKey("RequireEndChar") = false)
			hs.RequireEndChar := DefaultOptions.RequireEndChar
		if(hs.HasKey("ConformToTypedCase") = false)
			hs.ConformToTypedCase := DefaultOptions.ConformToTypedCase
		if(hs.HasKey("OmitEndChar") = false)
			hs.OmitEndChar := DefaultOptions.OmitEndChar
		if(hs.HasKey("StartAnywhere") = false)
			hs.StartAnywhere := DefaultOptions.StartAnywhere
		if(hs.HasKey("DeleteHotstring") = false)
			hs.DeleteHotstring := DefaultOptions.DeleteHotstring
		if(hs.HasKey("Raw") = false)
			hs.Raw := DefaultOptions.Raw
		
    if(!this.data.hotstrings)
      this.data.hotstrings := {}
    
		key := hs.Abbreviation
;     OutputDebug `tInitially set key to abbreviation: %key%
		if(hs.CaseSensitive = true)
		{
			if(!this.data.hotstrings.HasKey(key))
			{
        
        ; ******* adding hs here *******
				this.data.hotstrings[key] := hs.clone()
        if(write)
        {
          escPhrase :=  hs.Phrase
          StringReplace, escPhrase, escPhrase, `r, <r>
          StringReplace, escPhrase, escPhrase, `n, <n>
          abbrString := hs.Abbreviation "|" escPhrase "|" CHotstringOptions.ToOptions(hs)
        
          this.ini.Write("hotstrings", key, abbrString)
        }
        
;         OutputDebug Added HS with key %key%
;         OutputDebug % "`thotstrings:"
;         dump(this.data.hotstrings)
        
				if(hs.StartAnywhere = true)
				{
;           OutputDebug Adding hs %key% to index
					StringLen, len, key
          if(!this.data.hasKey("HotstringIndex"))
          {
            this.data.HotstringIndex := {}
          }
					if(!this.data.HotstringIndex.HasKey(len))
					{
						this.data.HotstringIndex[len] := []
					}
					this.data.HotstringIndex[len].Insert(key)
				}
				return key
			}
			else
				return false
		}
		else
		{
			StringUpper, key, key
;       OutputDebug `tCase insensitive: uppercase key = %key%
			if(!this.data.hotstrings.HasKey(key))
			{          
        ; ******* adding hs here *******
;         OutputDebug, % "AddHotstring:Adding hs:"
;         OutputDebug this.data.hotstrings[%key%] :=
;         dump(hs)
				this.data.hotstrings[key] := hs.clone()
        
        if(write)
        {
          escPhrase :=  hs.Phrase
          StringReplace, escPhrase, escPhrase, `r, <r>
          StringReplace, escPhrase, escPhrase, `n, <n>
          abbrString := hs.Abbreviation "|" escPhrase "|" CHotstringOptions.ToOptions(hs)
        
          this.ini.Write("hotstrings", key, abbrString)
        }

;         OutputDebug Added HS with key %key%
;         OutputDebug % "`thotstrings:"
;         dump(this.data.hotstrings)

				if(hs.StartAnywhere = true)
				{
					StringLen, len, key
;           OutputDebug Adding hs %key% to index
          if(!this.data.hasKey("HotstringIndex"))
          {
            this.data.HotstringIndex := {}
          }
					if(this.data.HotstringIndex.HasKey(len) = false)
					{
						this.data.HotstringIndex[len] := []
					}
					this.data.HotstringIndex[len].Insert(key)
				}
				return key
			}
			else
				return false
		}
	}
  
  RemoveHotstring(abbr)
  {
    hs := this.data.hotstrings[abbr]
    if(!hs)
    {
      StringUpper, abbr, abbr
      hs := this.data.hotstrings[abbr]
    }
    if(!hs)
      return false
      
    this.data.hotstrings.remove(abbr)
    this.ini.Delete("hotstrings", abbr)
    return true
  }
  
  findAll(s)
  {
    this.FindAbbreviation(s)
    return this.result
  }
  
  FindAbbreviation(s)
  {
    global
    
    this.result := {}
    this.result.foundHs := ""
  
		; Determine full case-sensitive match
		
; 		OutputDebug, FindHotstring(), Dump
		
;  		Dump(this.data)
		
		if(this.data.hotstrings.HasKey(s))
		{
; 			OutputDebug, Found full match %s%
			this.result.foundHs := this.data.hotstrings[$Buffer]
      this.result.foundHs.abbrKey := s
		}
		else
		{
; 			OutputDebug, NO full match
			StringUpper, sUpper, s
;       OutputDebug Searching match for %sUpper%
			if(this.data.hotstrings.HasKey(sUpper))
			{
; 				OutputDebug, Found uppercase match %sUpper%
				if(this.data.hotstrings[sUpper].CaseSensitive = false)
				{
					;~ OutputDebug, Found uppercase case-insensitive match
          this.result.foundHs := this.data.hotstrings[sUpper]
          this.result.foundHs.abbrKey := sUpper
				}
			}
		}
		
		; Find the shortest hotstring abbreviation matching the tail of the input buffer
	local len, keys, index, key
		;StartAnywhere

	; Get the right part of the buffer of the same length as the abbreviation
	for len, keys in this.data.HotstringIndex
	{
; 				OutputDebug, length: %len%
		StringRight, right, $Buffer, %len%
		for index, key in keys ;this.data.HotstringIndex[len]
		{
			if(right = key && this.data.hotstrings[key].StartAnywhere)
			{
; 						OutputDebug, Found partial match %right%
        this.result.foundHs := this.data.hotstrings[key]
        this.result.foundHs.abbrKey := key
			}
			else
			{
				StringUpper, URIGHT, right
				if(this.data.hotstrings.HasKey(URIGHT) && this.data.hotstrings[URIGHT].StartAnywhere)
				{
; 							OutputDebug, Found uppercase match %URIGHT%
					if(this.data.hotstrings[URIGHT].CaseSensitive = false)
					{
; 								OutputDebug, Found uppercase case-insensitive match %URIGHT%
						this.result.foundHs := this.data.hotstrings[URIGHT]
						this.result.foundHs.abbrKey := URIGHT
					}
				}
			}
		}
			
	}

;     dump(this.result.foundHs)
  if(!this.result.foundHs)
    this.result := ""
	}
  
  GetPhraseHotstring(phrase)
  {
    for k, hs in this.data.hotstrings
    {
      String_CaseSense_Remember()
      StringCaseSense, Off
      if(hs.phrase = phrase)
      {
;         OutputDebug Found hs for phrase %phrase%
        String_CaseSense_Restore()
        return hs
      }
    }
;     OutputDebug NOT Found hs for phrase %phrase%
    return false
  }
  
  HasAbbreviation(abbr)
  {
    if(this.data.hotstrings.haskey(abbr))
    {
;       OutputDebug Found abbr %abbr%
      return this.data.hotstrings[abbr]
    }
    else
    {
      StringUpper, uAbbr, abbr
      if(this.data.hotstrings.haskey(uAbbr))
      {
;         OutputDebug Found ucase abbr %uAbbr%
        return this.data.hotstrings[uAbbr]
      }
    }
;     OutputDebug NOT Found abbr %abbr%
    return false
  }
  
  Reset()
  {
    this.result := ""
  }
}
