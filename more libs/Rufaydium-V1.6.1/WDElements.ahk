; WebDriver Element class for Rufaydium
; By Xeo786

Class WDElement extends Session
{
	__new(Address)
	{
		;RegExMatch(Address,"element\/(.*)$",i)
		;this.id := i1
		This.Address := Address
	}
	
	Name()
	{
		return this.Send("name","GET")
	}
	
	Rect()
	{
		return this.Send("rect","GET")
	}
	
	Size()
	{
		return this.Send("Size","GET")
	}
	
	Location()
	{
		return this.Send("location","GET")
	}
	
	LocationInView()
	{
		return this.Send("location_in_view","GET")
	}
	
	enabled()
	{
		return this.Send("enabled","GET")
	}
	
	Selected()
	{
		return this.Send("selected","GET")
	}
	
	Displayed()
	{
		return this.Send("displayed","POST",{"":""})
	}
	
	submit()
	{
		return this.Send("submit","POST",{"":""})
	}
	
	SendKey(text)
	{
		return this.Send("value","POST", {"text":text})
	}
	
	click()
	{
		return this.Send("click","POST",{"":""})
	}
	
	Move()
	{
		return this.Send("moveto","POST",{"element_id":this.id})
	}
	
	value
	{
		get
		{
			v := this.Send("value","GET")
			if v.error
				return this.GetAttribute("value")
		}
		
		Set
		{
			this.Clear()
			return this.Send("value","POST", {"text":Value})
		}
	}
	
	InnerText
	{
		get
		{
			return  this.Send("text","GET")
		}
	}
	
	Clear()
	{
		;this.Send("ClearValue","POST"); not working for me
		obj :=  {"text": key.ctrl "a" key.delete}
		return this.Send("value","POST", obj)
	}
	
	GetAttribute(Name)
	{
		return this.Send("attribute/" Name,"GET")
	}
	
	GetProperty(Name)
	{
		return this.Send("property/" Name,"GET")
	}
	
	GetCSS(Name)
	{
		return this.Send("css/" Name,"GET")
	}
	
	ComputedRole() ; https://www.w3.org/TR/wai-aria-1.1/#usage_intro
	{
		return this.Send("computedrole","GET")
	}
	
	ComputedLable() ; https://www.w3.org/TR/wai-aria-1.1/#usage_intro
	{
		return this.Send("computedlabel","GET")
	}
	
	Uploadfile(filelocation)
	{
		return this.Send("file","POST",{})
	}
	
}

Class ShadowElement extends Session
{
	__new(Address)
	{
		This.Address := Address
	}
}

Class Key
{
	static Unidentified := "\uE000"
	static Cancel:= "\uE001"
	static Help:= "\uE002"
	static Backspace:= "\uE003"
	static Tab:= "\uE004"
	static Clear:= "\uE005"
	static Return:= "\uE006"
	static Enter:= "\uE007"
	static Shift:= "\uE008"
	static Control:= "\uE009"
	static Ctrl:= "\uE009"
	static Alt:= "\uE00A"
	static Pause:= "\uE00B"
	static Escape:= "\uE00C"
	static Space:= "\uE00D"
	static PageUp:= "\uE00E"
	static PageDown:= "\uE00F"
	static End:= "\uE010"
	static Home:= "\uE011"
	static ArrowLeft:= "\uE012"
	static ArrowUp:= "\uE013"
	static ArrowRight:= "\uE014"
	static ArrowDown:= "\uE015"
	static Insert:= "\uE016"
	static Delete:= "\uE017"
	static F1:= "\uE031"
	static F2:= "\uE032"
	static F3:= "\uE033"
	static F4:= "\uE034"
	static F5:= "\uE035"
	static F6:= "\uE036"
	static F7:= "\uE037"
	static F8:= "\uE038"
	static F9:= "\uE039"
	static F10:= "\uE03A"
	static F11:= "\uE03B"
	static F12:= "\uE03C"
	static Meta:= "\uE03D"
	static ZenkakuHankaku:= "\uE040"	
}
