; Link:   	https://gist.github.com/tmplinshi/e438875d77ee8866aa65
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; http://www.autohotkey.com/board/topic/96129-ahk-l-custom-autocompletion-for-edit-control-with-drop-down-list/

/*	Autocompletion
	
	Function	:	Autocomplete(hwnd , action , p1=0 , p2=0)
	Parameter
		hwnd	:	hwnd of edit control
		action	:	init , enable , disable , release , option
	
	Usage:
	
	1.	Initializes the autocomplete object.
	Function	:	Autocomplete(hwnd , "init" , txt , delim)
	Parameter
		txt		:	Autocomplete list
		delim	:	delimiter seperate each item
	
	2. 	Enables autocompletion.
	Function	:	Autocomplete(hwnd , "enable" , 0 , 0)
		
	3.	Disables autocompletion.
	Function	:	Autocomplete(hwnd , "disable" , 0 , 0)
		
	4.	Release autocompletion.
	Function	:	Autocomplete(hwnd , "release" , 0 , 0)
		
	5.	Sets the current autocomplete options.
	Function	:	Autocomplete(hwnd , "option" , mode , 0)
	Parameter
		mode	:	options seperated by space
		AUTOSUGGEST			:	Enable the autosuggest drop-down list.
		AUTOAPPEND			:	Enable autoappend.
		SEARCH				:	Add a search item to the list of completed strings. When the user selects this item, it launches a search engine.
		FILTERPREFIXES		:	Do not match common prefixes, such as "www." or "http://".
		USETAB				:	Use the TAB key to select an item from the drop-down list.
		UPDOWNKEYDROPSLIST	:	Use the UP ARROW and DOWN ARROW keys to display the autosuggest drop-down list.
		RTLREADING			:	read right-to-left (RTL). 
		WORD_FILTER			:	If set, the autocompleted suggestion is treated as a phrase for search purposes.
		NOPREFIXFILTERING	:	Disable prefix filtering when displaying the autosuggest dropdown. Always display all suggestions.
	Sample:
	
	gui,new,hwndhgui
	gui,add,edit,w300 h30 hwndhedit
	gui,show
	
	txt=I'm fine;That's ok;Thank you;Oh my god
	AutoComplete(hedit,"init",txt,";")
	AutoComplete(hedit,"option","AUTOSUGGEST AUTOAPPEND",0)
	return
*/

AutoComplete(self,celt,rgelt,pceltFetched){
    static es:=[]
    if (celt="init"){ ; Initializes the autocomplete object.
        sList:=[]
        loop,parse,rgelt,%pceltFetched%,%A_Space%%A_Tab%
            sList[A_Index]:=A_LoopField
        obj:=[],obj.List:=sList,obj.CurrentElement:=1,obj.hwnd:=self
        obj.SetCapacity("EnumString",A_PtrSize*8)
        pes:=obj.GetAddress("EnumString")
        ,NumPut(pes+A_PtrSize,pes+0)
        ,NumPut(RegisterCallback("_EnumString_QueryInterface","F"),pes+A_PtrSize*1)
        ,NumPut(RegisterCallback("_EnumString_AddRef","F"),pes+A_PtrSize*2)
        ,NumPut(RegisterCallback("_EnumString_Release","F"),pes+A_PtrSize*3)
        ,NumPut(RegisterCallback(A_ThisFunc,"F"),pes+A_PtrSize*4)
        ,NumPut(RegisterCallback("_EnumString_Skip","F"),pes+A_PtrSize*5)
        ,NumPut(RegisterCallback("_EnumString_Reset","F"),pes+A_PtrSize*6)
        ,NumPut(RegisterCallback("_EnumString_Clone","F"),pes+A_PtrSize*7)
        pac2:=ComObjCreate("{00BB2763-6A77-11D0-A535-00C04FD7D062}","{EAC04BC0-3791-11d2-BB95-0060977B464C}")    ; IAutoComplete2
        obj.pac:=pac2
        DllCall(NumGet(NumGet(pac2+0)+3*A_PtrSize),"ptr",pac2,"ptr",self,"ptr",pes,"ptr",0,"ptr",0,"uint")
        es[pes]:=obj
        return 0
    }else if (celt="enable"){ ; Enables autocompletion.
        for k,v in es
        {
            if (v.hwnd=self)
                return DllCall(NumGet(NumGet(v.pac+0)+4*A_PtrSize),"ptr",v.pac,"int",1,"uint")
        }
        return
    }else if (celt="disable"){ ; Disables autocompletion.
        for k,v in es
        {
            if (v.hwnd=self)
                return DllCall(NumGet(NumGet(v.pac+0)+4*A_PtrSize),"ptr",v.pac,"int",0,"uint")
        }
        return
    }else if (celt="release"){ ; Release autocompletion.
        for k,v in es
        {
            if (v.hwnd=self)
                ObjRelease(v.pac),es.remove(k)
        }
        return
    }else if (celt="option"){ ; Sets the current autocomplete options.
        if rgelt is Integer
        {
            if rgelt<0x200
                option:=rgelt
            else return
        }else{
            mode:={AUTOSUGGEST:1    ; Enable the autosuggest drop-down list.
                ,AUTOAPPEND:2        ; Enable autoappend.
                ,SEARCH:4            ; Add a search item to the list of completed strings. When the user selects this item, it launches a search engine.
                ,FILTERPREFIXES:8    ; Do not match common prefixes, such as "www." or "http://".
                ,USETAB:0x10        ; Use the TAB key to select an item from the drop-down list.
                ,UPDOWNKEYDROPSLIST:0x20    ; Use the UP ARROW and DOWN ARROW keys to display the autosuggest drop-down list.
                ,RTLREADING:0x40    ; read right-to-left (RTL).
                ,WORD_FILTER:0x80    ; If set, the autocompleted suggestion is treated as a phrase for search purposes. The suggestion, Microsoft Office, would be treated as "Microsoft Office" (where both Microsoft AND Office must appear in the search results).
                ,NOPREFIXFILTERING:0x100}    ; Disable prefix filtering when displaying the autosuggest dropdown. Always display all suggestions.
            option:=0
            loop,parse,rgelt,%A_Space%
                if mode[A_LoopField]
                    option|=mode[A_LoopField]
        }
        for k,v in es
        {
            if (v.hwnd=self)
                return DllCall(NumGet(NumGet(v.pac+0)+5*A_PtrSize),"ptr",v.pac,"uint",option,"uint") ; IAutoComplete2::SetOptions
        }
        return
    }else if !es.haskey(self){
        return 1
    }else if (celt="reset"){ ; Resets the enumeration sequence to the beginning.
        es[self].CurrentElement:=1
    }
    
    if !celt
        celt:=1
    i:=0
    loop % celt ; IEnumString::Next method
    {
        if (es[self].CurrentElement=es[self].List.maxindex()+1)
            break
        string:=es[self].List[es[self].CurrentElement]
        NumPut(p:=DllCall("Ole32\CoTaskMemAlloc","uint",len:=2*(StrPut(string,"utf-16"))),rgelt+(A_Index-1)*A_PtrSize)
        ;DllCall("RtlMoveMemory","ptr",p,"ptr",&string,"uint",len)
        StrPut(string,p,"utf-16")
        NumPut(NumGet(pceltFetched+0,"uint")+1,pceltFetched,0,"uint")
        es[self].CurrentElement:=es[self].CurrentElement+1
        i++
    }
    return (i=celt)?0:1
}

_EnumString_QueryInterface(self,riid,pObj){
    DllCall("Ole32\StringFromCLSID","ptr",riid,"ptr*",sz),string:=StrGet(sz,"utf-16")
    if (string="{00000101-0000-0000-C000-000000000046}"){
        return NumPut(self,pObj+0)*0
    }else return 0x80004002
}

_EnumString_AddRef(self){
    return 1
}

_EnumString_Release(self){
    return 0
}

_EnumString_Skip(self,celt){
    return 0
}

_EnumString_Reset(self){
    AutoComplete(self,"reset",0,0)
    return 0
}

_EnumString_Clone(self,ppenum){
    NumPut(self,ppenum+0)
    return 0
}