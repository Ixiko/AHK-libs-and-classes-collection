Class StringHelper
{
    IsValidName(Name)
	{
		if(Name ="") 
		{
			return false
		}
		pos := 1
		c := SubStr(Name, pos ,1)
		if(InStr("abcdefghijklmnopqrstuvwxyz_", c, false))
		{
			while(c)
			{
				if(!InStr("01234567890abcdefghijklmnopqrstuvwxyz_", c, false))
				{
					return false
				}
				pos++
				c := SubStr(Name, pos ,1)
			}
			return true
		}
		return false
	}
	RemoveWhiteChars(Text)
	{
		valid_chars := "01234567890abcdefghijklmnopqrstuvwxyz_"
		retstr := ""
		pos := 1
		c := SubStr(Text, pos ,1)
		
		while(c)
		{
			if(InStr(valid_chars, c, false))
			{
				retstr .= c
			}
			pos++
			c := SubStr(Text, pos ,1)
		}

		return retstr
		
	}
	LeadTrim(Text)
	{
		t := Text
		while(SubStr(t, 1 ,1) == " ")
		{
			t :=SubStr(t, 2)
		}
		return t
	}
	WTFAreTheInvalidChars(Text)
	{
		pos := 1
		
		ln := StrLen(Text)
		Debug.MsgBox("LENGTH: " . ln)
		loop, %ln%
		{
			c := SubStr(Text, pos ,1)
			a := asc(c)
			;if(a<32)
			{
				;Debug.MsgBox(a)
				Debug.Writenl(c . " " . a,100000)
			}
			pos++
			
		}
	}
	
}