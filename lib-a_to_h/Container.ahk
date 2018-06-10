/*
	A numerically indexed object with lots of useful functionality.  You can fill containers using delimited strings, 
	lists saved to a file, or other objects.  Add, remove, split, slice, filter, sort, copy, and compare containers.  
	Export container contents back to strings, files, and objects.  Ready to be extended for your own Container-based objects.
	
	For online documentation
	See http://www.autohotkey.net/~Rapte_Of_Suzaku/Documentation/files/Container-ahk.html
	
	Release #2
	
	Joshua A. Kinnison
	2010-10-17, 12:49
*/
FileEncoding UTF-16
;=======================================================================================================================
;==== DEFAULT PREFERENCES ==============================================================================================
;=======================================================================================================================
Container_DefaultPreferences(name)
{
	static
	if !_init
	{	
		_init := true
		
		editor              			:= "G:\Workspace\Programs\Notepad++\Notepad++.exe -multiInst -notabbar -nosession"
		
		; list reading preferences
		list_delim						:= "`n"
		list_omit						:= "`r"
			
		; file reading preferences	
		file_delim						:= "`n"
		file_omit						:= "`r"
		file_encoding					:= "UTF-16"				; not used... or is it used now?  subject to change.
		file_overwrite					:= true
		file_try1200					:= true
		;file_cpi						:= 1200 ; is UTF-16		; not used
		
		; sorting preferences
		sort_type						:= "Command"			; uses the built-in AHK sort command
		sort_method						:= "__noThing__"		; built-in AHK sort command options
		;sort_method					:= "StrLen"				; sort by length, short to long
		;sort_type						:= "Split"				; bucket sorting using callbacks
		;sort_type						:= "Array"				; not used
		
		; doesn't work well...
		;method 							:= "list"				; default construction method if left blank
		;source							:= "__noThing__"		; default construction source if left blank
	}
	
	return (%name%)
}
;=======================================================================================================================
;==== SOURCE PARSING ===================================================================================================
;=======================================================================================================================
Container_COM(c,comobj,field="")
{
	return c.COMn(comobj,field,1)
}
Container_COMn(c,comobj,field="",n=1)
{
	Loop %n%
		for item in comobj
			c.add(item[field])
	return c
}

Container_list(c, list, delimiters="__deFault__", omit="__deFault__")
{
	return c.listn(list,1,delimiters, omit)
}
Container_listn(c,list,n,delimiters="__deFault__", omit="__deFault__")
{
	c._prefs("list_delim",delimiters,"list_omit",omit)
	if delimiters contains % SubStr(list,0,1)
		list := SubStr(list,1,-1)
	
	Loop %n%
		Loop Parse, list, %delimiters%, %omit%
			c.add(A_LoopField)
	return c
}
Container_array(c, array)
{
	return c.arrayn(array,1)
}
Container_arrayn(c,array,n)
{
	Loop %n%
		Loop % array.MaxIndex()
			c.add(array[A_Index])
	return c
}
Container_file(c, fpath, delimiters="__deFault__", omit="__deFault__")
{
	return c.filen(fpath,1,delimiters,omit)
}
Container_filen(c,fpath,n,delimiters="__deFault__", omit="__deFault__")
{
	c._prefs("file_delim",delimiters,"file_omit",omit)

	file := FileOpen(fpath,"r")
	list := file.Read()
	file.Close()
	
	; workaround for undetected unicode files
	if c._prefs("file_try1200")
	{
		FileGetSize size, %fpath%
		s1 := StrLen(list)

		; 2 bytes per char, but I'll leave lots of room for things I don't understand
		if size/s1 > 1.5	
		{
			file := FileOpen(fpath,"r",1200)
			list2 := file.Read()
			file.Close()
			s2 := 2*StrLen(list2)
			
			; keep this second attempt if it is closer to the file size
			if size/s2 < size/s1
				list := list2
		}
	}
	
	return Container_listn(c,list,n,delimiters,omit)
}
;==========================================================================================================================================================================================
;= OUTPUT =================================================================================================================================================================================
;==========================================================================================================================================================================================
Container_toList(c,delim="__deFault__")
{
	c._prefs("list_delim",delim)
	Loop % c.len()
		list .= c[A_Index] . delim
	return list
}
Container_toArray(c)
{
	ret := Object()
	Loop % c.len()
		ret.Insert(c[A_Index])
	return ret
}
Container_toFile(c,fpath="", options="")
{
	del:=enc:=ove:="__deFault__"
	Loop, Parse, options, =`,, %A_Space%
		A_Index & 1	? (  __  := SubStr(A_LoopField,1,3)) : ( %__% := A_LoopField )
	c._prefs("file_delim",del,"file_encoding",enc,"file_overwrite",ove)
	
	if (!fpath AND c._method = "file")
		fpath := c._source
	if (!fpath)
		return ( ErrorLevel:="YOU NEED TO SPECIFY A FILENAME" )
	
	file := FileOpen(fpath, ove ? 1:2, enc)
	file.Write(c.toList(del))
	file.Close()
	
	return fpath
}
Container_toClipboard(c,delim="__deFault__")
{
	return ( clipboard := c.toList(c._prefs("clip_delim",delim)) )
}
;=======================================================================================================================
;==== BASIC ============================================================================================================
;=======================================================================================================================
Container_x(c,indexOrValue)
{
	if indexOrValue is not digit
		return c.remove(c.find(indexOrValue))
	return c.remove(indexOrValue)
}
Container_clear(c)
{
	return c.xRange(1)
}
Container_makeTemplate(c)
{
	c_new := c.makeNew()
	
	; copy construction parameters
	c_new._method := c._method
	c_new._source := c._source
	c_new._params := c._params.Clone() ; should be good enough, but note the shallow copy
	; copy preferences
	enum := ObjNewEnum(c._prefs)
	while enum[key,value]
		c_new._prefs[key] := value
	
	return c_new
}
Container_makeCopy(c)
{
	return c.makeTemplate().absorb(c)
}
;=======================================================================================================================
;==== SORTING ==========================================================================================================
;=======================================================================================================================
Container_sort(c,type="__deFault__", method="__deFault__", c2="",reverse=0)
{
	c._prefs("sort_method",method,"sort_type",type)
	
	if IsObject(c2)
		order := c.makeOrder()
	
	if (type="split")
	{
		split := c.makeSplit(method)
		keys := Object()
		for key,value in split
			keys[len:=A_Index] := key
		c.clear()
		
		if reverse
			Loop % len
				c.absorb(split[keys[len+1-A_Index]])
		else
			Loop % len
				c.absorb(split[keys[A_Index]])
	}
	else if (type="command")
	{
		list := c.toList("`n")
		Sort list, % method . (reverse ? " R" : " ")
		c.become("list",list)
	}
		
	if IsObject(c2)
		return c.updateLinked(c2,order)
	return c
}
Container_rsort(c, type="__deFault__", method="__deFault__")
{
	return c.sort(type, method, "", 1)
}
Container_sortLinked(c,c2, type="__deFault__", method="__deFault__")
{
	return c.sort(type, method, c2)
}
Container_rsortLinked(c,c2, type="__deFault__", method="__deFault__")
{
	return c.sort(type, method, c2, 1)
}
Container_makeOrder(c)
{
	order := Object()
	Loop % c.len()
		order[c[A_Index]] := Object()
	Loop % c.len()
		order[c[A_Index]].Insert(A_Index)
	return order
}
; warning:  blanks can be introduced!!
; can differentiate between '' and non-existant by using GetCapacity()
Container_updateLinked(c,c2,order)
{
	c2_old := c2.makeCopy()
	c2.clear()
	Loop % c.len()
		c2[A_Index] := c2_old[order[c[A_Index]].Remove(1)]
	return c
}
;=======================================================================================================================
;==== UPDATING =========================================================================================================
;=======================================================================================================================
Container_refresh(c,param="__deFault__")
{	
	c.clear()
	method := c._method
	source := c._source
	params := c._params

	; is there a better way?  A more extensible way?
	if (method="list" or method="listn" or method="array")
	{
		; no need to carry around arrays or lists
		c._source := method
		
		; use given param as source if applicable
		if (param!="__deFault__")
			source := param
	}
	
	if method
		return c.extend(method, source, params*)
	else
		return c
}
Container_absorb(c,targets*)
{
	for i,target in targets
		Loop % target.len()
			c.add(target[A_Index])
	return c
}
Container_extend(c, method, source="", params*)
{
	if !(func := c[method])
		MsgBox % "ERROR - could not extend using method '" method "'"
		
	return %func%(c,source,params*)
}
; not meant as a shortcut to absorb w/ more than 1 container.  (works, but isn't logical)
Container_become(c, params*)
{
	if isObject(params[1])
		return c.clear().absorb(params*)
	else if params[1]
		return c.clear().extend(params*)
	else
		return c.clear()
}
; strange, and not sure I like the name anymore
Container_bud(c, params*)
{
	return c.makeTemplate().become(params*)
}
;=======================================================================================================================
;==== MANIPULATION =====================================================================================================
;=======================================================================================================================
Container_manipulate(c,func, params*)
{
	n := 0
	Loop % c.len()
		if (ret := %func%(c[A_Index],params*))
			c[++n] := ret
	return c.xRange(n+1)
}
Container_editAsText(c,editor="__deFault__")
{
	c._prefs("editor",editor)
	temp := c.makeTemp()
	c.toFile(temp)
	
	c._runWait(editor " " temp)
	
	c.become("file",temp)
	
	FileDelete %temp%
	return c
}
;==========================================================================================================================================================================================
;= FILTERING ==============================================================================================================================================================================
;==========================================================================================================================================================================================
Container_filter(c,func,keep_if_func_returns=false, params*)
{
	; faster without split?
	return c.become(c.makeSplit(func,params*)[keep_if_func_returns])
}
Container_filterTF(c,func,keep_if_return_is=false, params*)
{
	; ... braces here matter
	n := 0
	if keep_if_return_is
	{
		Loop % c.len()
			if %func%(c[A_Index],params*)
				c[++n] := c[A_Index]
	}
	else
	{
		Loop % c.len()
			if !%func%(c[A_Index],params*)
				c[++n] := c[A_Index]

	}
	return c.xRange(n+1)
}
xor(a,b)
{
	return (a || b) && !(a && b)
}
;=======================================================================================================================
;==== BUILT-IN FILTERS =================================================================================================
;=======================================================================================================================
Container_xBlanks(c)
{
	n := 0
	Loop % c.len()
		if c[A_Index]
			c[++n] := c[A_Index]
	return c.xRange(n+1)
}
Container_xDuplicates(c)
{
	n := 0, seen := Object()
	Loop % c.len()
	{
		if seen[c[A_Index]]
			continue
		
		seen[c[A_Index]] := true
		c[++n] := c[A_Index]
	}
	return c.xRange(n+1)
}
Container_xShared(c,c2)
{
	order := c.makeOrder()
	c.xIn(c2)
	c.updateLinked(c2,order)
	return c
}
Container_xIn(c,c2)
{
	return c.filter("finder",false, c2)
}
Container_iIn(c,c2)
{
	return c.filter("finder",true, c2)
}
finder(item,c)
{
	return c.find(item)
}
; a manipulateLinked might be nice...
remove_unchanged(c1,c2)
{
	n := 0
	Loop % c1.len()
	{
		if (c1[A_Index] == c2[A_Index])
			continue
		c1[++n] := c1[A_Index]
		c2[n]   := c2[A_Index]
	}
	c1.xRange(n+1)
	c2.xRange(n+1)
}
; better or worse, I had fun coding it this way...
Container_iAt(c,indices)
{
	return c.s(indices,Object(1,c),true)[1]
}
Container_xAt(c,indices)
{
	return c.s(indices,Object(0,c),true)[0]
}
Container_iRange(c,start=1,end="")
{
	return c.s(start,end,Object(1,c),0,0,true)[1]
}
Container_xRange(c,start=1,end="")
{
	return c.s(start,end,Object(0,c),0,0,true)[0]
}
;=======================================================================================================================
;==== SLICING ==========================================================================================================
;=======================================================================================================================
; assumes the indices are sorted low to high
; assumes that indices exist
Container_makeSplit(c,func,params*)
{
	ret := Object()
	Loop % c.len()
	{
		key := %func%(c[A_Index],params*)
		if !ret[key].add(c[A_Index])
			ret[key] := c.bud("list",c[A_Index])
	}
	return ret
}
Container_makeIndicesSlice(o,indices,ret="",overwrite=false)
{
	if !(n := indices.MaxIndex())
		return ret
	if ret[1]
	{
		i := overwrite ? 0 : ret[1].MaxIndex()
		Loop % n
			ret[1][++i] := indices[A_Index]
		if overwrite
			ret[1].Remove(i+1,ret[1].MaxIndex())
	}
	if ret[0]
	{
		out := Object(1,ret[0])
		if overwrite
		{
			start := 1
			off1 := 0
			;ObjInsert()
			Loop % n
			{
				end := indices[A_Index]-1
				out := o.makeRangeSlice(start, end, out, 0, off1, false)
				off1 += end-start+1
				start := indices[A_Index]+1
			}

			end := out[1].MaxIndex()
			out := o.makeRangeSlice(start,end,out,0,off1,false)
			off1 += end-start+1

			out[1].Remove(off1+1,out[1].MaxIndex())
		}
		else
			Loop % n+1
				out := o.makeRangeSlice(indices[A_Index-1]+1, indices[A_Index]-1, out)
	}
	return ret
}
Container_makeRangeSlice(o,start=1,end="",ret="",off0=-1,off1=-1,remove=true)
{
	end := (end!="") ? end : o.MaxIndex()		; o.MaxIndex() may return blank, but that still works fine
	
	if ret[1]
	{		
		i := (off1!=-1) ? off1 : ret[1].MaxIndex()
		Loop % end-start+1
			ret[1][++i] := o[A_Index+start-1]
		if (off1!=-1 and remove)
			ret[1].Remove(i+1,ret[1].MaxIndex())
	}
	
	if ret[0]
	{
		i := (off0!=-1) ? off0 : ret[0].MaxIndex()
		
		; if the given range was invalid, then all items fall into the excluded slot
		if (start > end)
		{
			; the overwrite would be pointless if source and dest are the same
			if (ret[0]==o and !off0)
				return ret
			
			start := 1
			end := 0
		}
		
		Loop % start-1
			ret[0][++i] := o[A_Index]
		Loop % o.MaxIndex()-end
			ret[0][++i] := o[A_Index+end]
		if (off0!=-1 and remove)
			ret[0].Remove(i+1,ret[0].MaxIndex())
	}
	
	return ret
}
Container_makeSlice(o,a=1,b="",c=0, off0=-1,off1=-1,remove=true)
{
	indices := IsObject(a)
	ret := indices ? b : c
	ret := ret ? ret : Object(0,Object(),1,Object())
	
	if indices
		return o.makeIndicesSlice(a,ret,c)
	else
		return o.makeRangeSlice(a,b,ret,off0,off1,remove)
}
;==========================================================================================================================================================================================
;= INFORMATION ============================================================================================================================================================================
;==========================================================================================================================================================================================
Container_isEmpty(c)
{
	return !c.len()
}
; these should be from a more general object
Container_IsEqual(c,c2,strict=true)
{
	if !IsObject(c2)
		return false
	if (c==c2)
		return true
	if c.len() != c2.len()
		return false
	
	return strict ? c.toList()==c.toList() : !c.makeCopy().xIn(c2).len()
}
; could be more efficient, but really just for testing
Container_IsEquivalent(c,c2)
{
	return c.isEqual(c2,false)
}
Container_find(c,item,x_index=0)
{
	Loop % c.len()
		if ( (item=c[A_Index]) and (A_Index != x_index) )
			return A_Index
	return 0
}
;==========================================================================================================================================================================================
;= Helpers ================================================================================================================================================================================
;==========================================================================================================================================================================================
; ...  could almost go in a separate library, but it is so tiny!  
Container_makeTemp(c,type="file", create=false, base="")
{
	if !base
		base := A_ScriptName
	
	Random rn
	ret := A_Temp "\" base rn
	if (type="file")
	{
		FileDelete %ret%
		if create
			FileAppend,,%ret%
	}
	else
	{
		FileRemoveDir %ret%, 1
		if create
			FileCreateDir %ret%
		ret .= "\"s
	}
	return ret
}
;=======================================================================================================================
;==== SPECIAL ==========================================================================================================
;=======================================================================================================================
Container__runWait(f, line, working_dir="", options="")
{
	return f._run(line,working_dir,options, true)
}
Container__run(f, line, working_dir="", options="", wait=false)
{
	Run %line%, %working_dir%, %options%, pid
	
	if wait
	{
	;	f._goat := pid
		Process WaitClose, %pid%
	;	f._goat := ""
	}
	
	return pid
}

; does this change work alright?
Container_saveParams(c,method,source,params*)
{
	c._method := method
	c._source := source
	c._params := params
	return c
}
; requires a _type member
Container_makeNew(c,params*)
{
	if !(func := c._type)
		MsgBox % "ERROR - could not make new '" c._type "' object"
	return %func%(params*)
}
Container_get(c,method,params*)
{
	if !(func := c[method])
		MsgBox % "ERROR - could not get using method '" method "'"
	return %func%(c.makeCopy(),params*)
}
/*
tricky... how to know what to do!?
Container_onEach(c,type,method,params*)
{
	If (SubStr(method,1,1)==".")
	{
		if !(method := c[SubStr(method,2)])
			MsgBox % "ERROR - could not onEach using method '" method "'"
		else
		{
			Loop % c.len()
				c[A_Index] := %method%(c.makeNew(type,c[A_Index]),params*)
		}
	}
		
	Loop % c.len()
		c[A_Index] := %method%(c[A_Index],params*)
	return c
}
*/
;==========================================================================================================================================================================================
;= CONSTRUCTOR ============================================================================================================================================================================
;==========================================================================================================================================================================================
Container(method="",source="__deFault__", params*)
{
	static base
	if !base
	{
		base := Object(		"_type",					"Container"
						;==================================================================================================
						;================= SOURCE PARSING =================================================================
						;==================================================================================================
						,	"list",						"Container_list"
						,	"listn",					"Container_listn"
						,	"array",					"Container_array"
						,	"arrayn",					"Container_arrayn"
						,	"file",						"Container_file"
						,	"filen",					"Container_filen"
						,	"COM",						"Container_COM"
						,	"COMn",						"Container_COMn"
						,	"refresh",					"Container_refresh"
						;==================================================================================================
						;================= OUTPUT =========================================================================
						;==================================================================================================						
						,	"toList",					"Container_toList"
						,	"toArray",					"Container_toArray"
						,	"toFile",					"Container_toFile"
						,	"toClipboard",				"Container_toClipboard"
						;==================================================================================================
						;================= BASIC CONTAINER ================================================================
						;==================================================================================================
						,	"add",						"ObjInsert"
						,	"x",						"Container_x"
						,	"clear",					"Container_clear"
						,	"makeCopy",					"Container_makeCopy"
						,	"makeTemplate",				"Container_makeTemplate"						
						;==================================================================================================
						;================= EXTENDING ======================================================================
						;==================================================================================================						
						,	"absorb",					"Container_absorb"
						,	"extend",					"Container_extend"
						,	"become",					"Container_become"
						,	"bud",						"Container_bud"
						;==================================================================================================
						;================= SORTING ========================================================================
						;==================================================================================================					
						,	"sort",						"Container_sort"
						,	"rsort",					"Container_rsort"
						,	"sortLinked",				"Container_sortLinked"
						,	"rsortLinked",				"Container_rsortLinked"
						,	"makeOrder",				"Container_makeOrder"
						,	"updateLinked",				"Container_updateLinked"
						;==================================================================================================
						;================= MANIPULATION ===================================================================
						;==================================================================================================						
						,	"manipulate",				"Container_manipulate"
						,	"editAsText",				"Container_editAsText"
						;==================================================================================================
						;================= FILTERING ======================================================================
						;==================================================================================================	
						,	"filter",					"Container_filter"
						,	"filterTF",					"Container_filterTF"
						;==================================================================================================
						;================= BUILT-IN FILTERS ===============================================================
						;==================================================================================================						
						,	"xBlanks",					"Container_xBlanks"
						,	"xDuplicates",				"Container_xDuplicates"
						,	"xShared",					"Container_xShared"
						,	"xIn",						"Container_xIn"
						,	"iIn",						"Container_iIn"
						,	"xAt",						"Container_xAt"
						,	"iAt",						"Container_iAt"
						,	"xRange",					"Container_xRange"
						,	"iRange",					"Container_iRange"
						;==================================================================================================
						;================= SLICING ========================================================================
						;==================================================================================================						
						,	"s",						"Container_makeSlice"
						,	"makeSlice",				"Container_makeSlice"
						,	"makeIndicesSlice",			"Container_makeIndicesSlice"
						,	"makeRangeSlice",			"Container_makeRangeSlice"
						,	"makeSplit",				"Container_makeSplit"
						;==================================================================================================
						;================= INFORMATION ====================================================================
						;==================================================================================================						
						,	"isEmpty",					"Container_isEmpty"
						,	"IsEqual",					"Container_IsEqual"
						,	"IsEquivalent",				"Container_IsEquivalent"
						,	"find",						"Container_find"
						,	"len",						"ObjMaxIndex"
						;==================================================================================================
						;================= SPECIAL ========================================================================
						;==================================================================================================
						,	"_run",						"Container__run"
						,	"_runWait",					"Container__runWait"
						,	"onEach",					"Container_onEach"
						,	"saveParams",				"Container_saveParams"
						,	"super",					"Container_super"
						,	"get",						"Container_get"
						,	"makeNew",					"Container_makeNew"
						,	"makeTemp",					"Container_makeTemp")
		Prefs_init(base,"Container_DefaultPreferences")
	}
	
	c := Object("base",base)
	;c._prefs("method",method,"source",source)
	;if (method!="__deFault__")
		c.saveParams(method,source,params*).refresh()
	return c
}
;==========================================================================================================================================================================================
;= NOTES ==================================================================================================================================================================================
;==========================================================================================================================================================================================
/*
	extend richObject

need to fix run/runwait

really easy to break functionality when overriding methods.

would be neat to have syntax:  f(3:5).manipulate()
	- easiest to do with a centralized iterator
	- what sort of slowdown would come from this?
*/