FileEncoding UTF-16
; the constructor is at the very end, out of the way
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; use this to set your own default preferences
GetDefaultPreferences()
{
	; only "editor" and "7zip" are working preferences right now.
	return Object(	"keep_sys",		true														; When system files are found in the source list...
																								;		true	->	just do it!
																								;		false	->	don't touch those!
																								;		""		->	ask me each time
																								
				,	"merge",		true														; When folders might be merged... [NOT YET USED]
																								;		true	->	just do it!
																								;		false	->	don't touch those!
																								;		""		->	ask me each time
																								
				,	"7zip",			"G:\Workspace\Programs\7-zip\App\7-Zip\7z.exe"				; path to 7z.exe (for 7-zip)
				
				,	"catch",		false														; set to true to automatically keep track of   [NOT YET USED]
																								; "lost" items during operations.  Otherwise,
																								; you'll have to use .enableCatch() and 
																								; .takeCatch() manually as desired (recommended way)
				
				,	"editor",		"G:\Workspace\Programs\Notepad++\Notepad++.exe -multiInst") ; path to your favorite text editor with 
																								; desired flags before where the filepath
																								; will go
				
}
FC_enableCatch(f)
{
	if !f._catch
		f._catch := FC("catch")
}
FC_disableCatch(f)
{
	f._catch := ""
}
; while catches shouldn't leak all over,
; catchability should spread quickly
FC_takeCatch(f,disable=false)
{
	ret := f._catch
	if disable
		f.disableCatch()
	return ret
}
;==== SOURCE PARSING ===================================================================================================
;=======================================================================================================================
FC_list(f, list, delimiters="`n", omit="`r")
{
	return FC_listn(f,list,1,delimiters,omit)
}
FC_listn(f,list,n,delimiters="`n", omit="`r")
{
	if delimiters contains % SubStr(list,0,1)
		list := SubStr(list,1,-1)
	Loop %n%
		Loop Parse, list, %delimiters%, %omit%
			f.add(A_LoopField)
	return f
}
FC_array(f, array)
{
	Loop % array.MaxIndex()
		f.add(array[A_Index])
	return f
}
; not satisfied with this yet
; only have to manipulate newly added items
FC_file(f, fpath, fix_dirs=false, cpi=1200) ; 1200 is UTF-16
{ ; rather than mess with line endings here...
	FileRead, list, *P%cpi% %fpath%
	f := FC_list(f,list)
	if fix_dirs
		f.manipulate("dir_fixer")
	return f
}
; only have to filter newly added items
FC_pattern(f, pattern, folders=0, recurse=0, regexp="")
{
	if folders != 2
		Loop %pattern%, 0, %recurse% 				; get the files first
			f.add(A_LoopFileFullPath)
	if folders										; then loop through folders	(to add a slash)
		Loop %pattern%, 2, %recurse%
			f.add(A_LoopFileFullPath . "\")
	if regexp
		f.filterTF("RegExMatch",true,regexp)
	return f
}
FC_regex(f,base,regexp, folders=1, recurse=1)
{
	return FC_pattern(f,base . "*.*", folders, recurse, regexp)
}
;==== BASIC CONTAINER ==================================================================================================
;=======================================================================================================================
; stuff removed
; remove returns value removed now
FC_exclude(f,indexOrValue)
{
	if indexOrValue is not digit
		return f.remove(f.find(indexOrValue))
	return f.remove(indexOrValue)
}
FC_clear(f)
{
	return f.excludeInRange(1)
}
; default to minimize catch duplication
FC_getTemplate(f,takeCatch=false)
{
	f_new := FC()
	
	; copy construction parameters
	Loop % f._params.MaxIndex()
		f_new._params[A_Index] := f._params[A_Index]
	
	; copy preferences
	enum := f._prefs.NewEnum()
	while enum[key,value]
		f_new._prefs[key] := value
	
	if takeCatch
		f_new._catch := f.takeCatch()
	return f_new
}
; default to minimize catch duplication
FC_getCopy(f,takeCatch=true)
{
	if !takeCatch
		catch := f.takeCatch()
	ret := f.getTemplate().absorb(f)
	if !takeCatch
		f._catch := catch
	return ret
}
FC_IsEqual(f,f2)
{
	if f.len() != f2.len()
		return false
	return ( f.toList()==f2.toList() )
}
; could be more efficient, but really just for testing
FC_IsEquivalent(f,f2)
{
	return !( f.len() != f2.len() or f.getWhereNotIn(f2).len() )
}
;==== SORTING ==========================================================================================================
;=======================================================================================================================
FC_sort(f,method="depthsort",f2="")
{
	if IsObject(f2)
		order := f.getOrder()
	
	split := f.getSplit(method)
	f.clear()
	enum := split._NewEnum()
	while enum[key,value]
		f.absorb(value)
	
	if IsObject(f2)
		return f.updateLinked(f2,order)
	return f
}
FC_rsort(f)
{
	return f.sort("depthrsort")
}
FC_sortLinked(f,f2)
{
	return f.sort("depthsort",f2)
}
FC_rsortLinked(f,f2)
{
	return f.sort("depthrsort",f2)
}
FC_getOrder(f)
{
	order := Object()
	Loop % f.len()
		order[f[A_Index]] := Object()
	Loop % f.len()
		order[f[A_Index]].Insert(A_Index)
	return order
}
FC_updateLinked(f,f2,order)
{
	f2_old := f2.getCopy(false)  ; don't mess with the catch
	f2.clear()
	Loop % f.len()
		f2[A_Index] := f2_old[order[f[A_Index]].Remove(1)]
	return f
}
;==== UPDATING =========================================================================================================
;=======================================================================================================================
FC_refresh(f,param="__deFault__")
{
	f.clear()
	method := f._params[1]
	source := f._params[2]
	
	if (method="catch")
	{
		; override default catch preference for catches.
		f._prefs["catch"] := false
		return f
	}
	
	; is there a better way?
	if (method="list" or method="listn" or method="array")
	{
		; no need to carry around arrays or lists
		f._params[2] := method
		
		; use given param as source if applicable
		if (param!="__deFault__")
			source := param
	}
	
	ret := f.extend(method, source, f._params[3], f._params[4], f._params[5], f._params[6], f._params[7], f._params[8])
	
	return ret ? ret : f
}
; absorb takes catches
FC_absorb(f,p1="",p2="",p3="",p4="",p5="",p6="",p7="",p8="")
{
	Loop 8 ; blank param = skip, not stop
	{	
		Loop % (fi:=p%A_Index%).len()			; Loop for regular items
			f.add(fi[A_Index])
		f._catch.absorb(fi.takeCatch())
		;Loop % (ci:=fi._catch).len()			; Loop for caught items
		;	f._catch.add(ci[A_Index])
	}
	return f
}
; will be even more usefull as long as I update other methods
FC_extend(f, method,source="", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{
	callf := CallPrep("","",p3,p4,p5,p6,p7,p8)
	return %callf%("FC_" method, f, source, p3,p4,p5,p6,p7,p8)
	;return FC_%method%(f,source,p3,p4,p5,p6,p7,p8)
	;return f.absorb(FC(method,source,p3,p4,p5,p6,p7,p8))
}
; catch is propogated if applicable
FC_become(f, p1, p2="", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{
	if isObject(p1)
		return f.clear().absorb(p1)
	else if p1
		return f.clear().extend(p1,p2,p3,p4,p5,p6,p7,p8)
	else
		return f.clear()
}
; strange, and not sure I like the name anymore
; catch is not propogated
FC_bud(f, p1, p2="", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{
	return f.getTemplate().become(p1,p2,p3,p4,p5,p6,p7,p8)
}
; consume() ? possibly faster to attach existing string buffers to current fc, then destroy consumed fc?
;==== Expanding ========================================================================================================
;=======================================================================================================================
FC_getExpansion(f,includeFolders="__deFault__",recursive="__deFault__",pattern="__deFault__",f2="__deFault__")
{
	; default to original parameters if applicable
	if (includeFolders == "__deFault__")
	{
		if (f._params[1]="pattern")
			includeFolders := f._params[3]
		else if (f._params[1]="regex")
			includeFolders := f._params[4]
		else
			includeFolders := 1
	}
	if (recursive == "__deFault__")
	{
		if (f._params[1]="pattern")
			recursive := f._params[4]
		else if (f._params[1]="regex")
			recursive := f._params[5]
		else
			recursive := 1
	}
	pattern  := (pattern!="__deFault__")	? pattern 	: "*"
	f_target := (f2!="__deFault__") 		? f2 		: f.getTemplate()
	
	Loop % (folders := f.getFolders()).len()
		f_target.extend("pattern",folders[A_Index] pattern,includeFolders,recursive)
	return f_target
}
FC_expand(f,includeFolders="__deFault__",recursive="__deFault__",pattern="__deFault__")
{
	; do any languages allow for automagically prespecifying the return variable? (instead of passing it in explicitly)
	return f.getExpansion(includeFolders,recursive,pattern,f)
	;return f.absorb(f.getExpansion(includeFolders,recursive,pattern))
}
FC_getExpanded(f,includeFolders="__deFault__",recursive="__deFault__",pattern="__deFault__")
{
	return f.getCopy().expand(includeFolders,recursive,pattern)
}
;==========================================================================================================================================================================================
;= FILTERING ==============================================================================================================================================================================
;==========================================================================================================================================================================================
/*
; generalize built-in filters and rename filter to where for a more query-like syntax
; maybe.  maybe.
FC_Where(f,func,keep_if_func_returns=false, p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{
	
}
FC_WhereTF(f,func,keep_if_func_returns=false, p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{
}
FC_getWhere(f,func,keep_if_func_returns=false, p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{
	return f.getCopy().Where(f,func,p2,p3,p4,p5,p6,p7,p8)
}
FC_getWhereTF(f,func,keep_if_func_returns=false, p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{
	return f.getCopy().WhereTF(f,func,p2,p3,p4,p5,p6,p7,p8)
}
*/

FC_getSplit(f,func, p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{
	callf := CallPrep("",p2,p3,p4,p5,p6,p7,p8)
	ret := Object()
	Loop % f.len()
	{
		key := %callf%(func,f[A_Index],p2,p3,p4,p5,p6,p7,p8)
		;key := Call(func,f[A_Index],p2,p3,p4,p5,p6,p7,p8)
		if !ret[key].add(f[A_Index])
			ret[key] := f.bud("list",f[A_Index])
	}
	return ret
}
FC_filter(f,func,keep_if_func_returns=false, p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{
	return f.become(f.getSplit(func,p2,p3,p4,p5,p6,p7,p8)[keep_if_func_returns])
}
FC_filterTF(f,func,keep_if_return_is=false, p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{
	callf := CallPrep("",p2,p3,p4,p5,p6,p7,p8)
	c := 0
	Loop % f.len()
		;if (!xor(Call(func,f[A_Index],p2,p3,p4,p5,p6,p7,p8),keep_if_return_is))
		if (!xor(%callf%(func,f[A_Index],p2,p3,p4,p5,p6,p7,p8),keep_if_return_is))
			f[++c] := f[A_Index]
	return f.excludeInRange(c+1)
}
FC_manipulate(f,func, p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{
	callf := CallPrep("",p2,p3,p4,p5,p6,p7,p8)
	c := 0
	Loop % f.len()
		if (ret := %callf%(func,f[A_Index],p2,p3,p4,p5,p6,p7,p8))
			f[++c] := ret
	return f.excludeInRange(c+1)
}
;==== BUILT-IN FILTERS =================================================================================================
;=======================================================================================================================
; callbacks are inefficient.  But so very convenient.  T_T
FC_excludeAttributes(f,attr)
{
	return f.filter("hasAttributes", false, attr)
}
FC_includeAttributes(f,attr)
{
	return f.filter("hasAttributes", true, attr)
}
FC_getWithAttributes(f,attr)
{
	return f.getCopy().includeAttributes(attr)
}
FC_getWithoutAttributes(f,attr)
{
	return f.getCopy().excludeAttributes(attr)
}
hasAttributes(item,list)
{
	FileGetAttrib, attr, %item%
	If attr contains %list%
		return true
}
FC_excludeFiles(f)
{
	return f.filter("IsFolder", true)
}
FC_excludeFolders(f)
{
	return f.filter("IsFolder", false)
}
FC_getFiles(f)
{
	return f.getCopy().excludeFolders()
}
FC_getFolders(f)
{
	return f.getCopy().excludeFiles()
}
FC_excludeNotExist(f)
{
	return f.filter("PathExist",1)
}
FC_getExist(f)
{
	return f.getCopy().excludeNotExist()
}
FC_excludeBlanks(f)
{
	c := 0
	Loop % f.len()
		if f[A_Index]
			f[++c] := f[A_Index]
	return f.excludeInRange(c+1)
}
; ?  better or worse?  !?
FC_get(f,func,p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{
	callf := CallPrep("",p2,p3,p4,p5,p6,p7,p8)
	return %callf%(func,f.getCopy(),p2,p3,p4,p5,p6,p7,p8)
}
FC_excludeDuplicates(f)
{
	c := 0, seen := Object()
	Loop % f.len()
	{
		if seen[f[A_Index]]
			continue
		
		seen[f[A_Index]] := true
		f[++c] := f[A_Index]
	}
	return f.excludeInRange(c+1)
}
;==== COMPARISON FILTERS ===============================================================================================
;=======================================================================================================================
FC_excludeWhereIn(f,f2)
{
	return f.filter("finder",false, f2)
}
FC_excludeWhereNotIn(f,f2)
{
	return f.filter("finder",true, f2)
}
FC_getWhereNotIn(f,f2)
{
	return f.getCopy().excludeWhereIn(f2)
}
FC_getWhereIn(f,f2)
{
	return f.getCopy().excludeWhereNotIn(f2)
}

; a manipulateLinked might be nice...
FC_excludeMatched(f1,f2)
{

}
FC_excludeNotMatched(f1,f2)
{
}
remove_unchanged(f1,f2)
{
	c := 0
	Loop % f1.len()
	{
		if (f1[A_Index] == f2[A_Index])
			continue
		f1[++c] := f1[A_Index]
		f2[c]   := f2[A_Index]
	}
	f1.excludeInRange(c+1)
	f2.excludeInRange(c+1)
}

;==== RANGES ===========================================================================================================
;=======================================================================================================================
; assumes the indices are sorted low to high
; assumes that indices exist (may fix this later)

; are the numbers correct here?
; need a split version... 
; should exclude return excluded instead?
; 	or rather make a take variant?

; or would a bunch of remove statements be faster?  even better if I figure out how it is faster.  something to look into
FC_excludeAt(f,indices)
{
	num := indices.MaxIndex()	
	inew := indices[1]-1
	Loop % num - 1										; for each index ('cept the last)
		Loop % indices[(c := A_Index)+1]-indices[c]-1		; for # of items between this exclusion and the next
			f[inew] := f[++inew+c]								; keep building container, selecting from an offset (= # items already excluded).
	
	; fill in the last stretch
	Loop % f.len() - indices[num]
		f[inew] := f[++inew+num]
	return f.excludeInRange(inew+1)
}
FC_excludeNotAt(f,indices)
{
	len := indices.MaxIndex()
	Loop % len
		f[A_Index] := f[indices[A_Index]]
	return f.excludeInRange(len+1)
}
FC_getAt(f,indices)
{
	return f.getCopy().excludeNotAt(indices)
}
FC_getNotAt(f,indices)
{
	return f.getCopy().excludeAt(indices)
}
FC_excludeInRange(f,start=1,end="")
{
	end := end ? end : f.len()
	if !(start < 1 or end > f.len())
		f.Remove(start, end)
	return f
}
FC_excludeNotInRange(f,start=1,end="")
{
	return f.excludeInRange(end ? end+1 : f.len()).excludeInRange(1,start-1)
}
FC_getInRange(f,start=1,end="")
{
	return f.getCopy().excludeNotInRange(start,end)
}
FC_getNotInRange(f,start=1,end="")
{
	return f.getCopy().excludeInRange(start,end)
}
;==== TWEAKING =========================================================================================================
;=======================================================================================================================
; would be very nice to generalize these.  Could be the foundation for a set of 
; array-of-FileContainer focused methods

; removes paths that are already defined implicitly
FC_simplify(f)
{
	;SetBatchLines -1 ; definitely speeds things up, but is it desirable?	
	split := f.getSplit("depthsort")
	keys := Object()
	lens := Object()
	enum := split._newEnum()
	while enum[key,fc]
	{
		keys[A_Index] := key
		lens[A_Index] := fc.len()
		num_levels := A_Index
	}
	f.clear()
	
	; for each depth (but the last)
	Loop % num_levels - 1
	{
		level := A_Index
		fc := split[keys[level]]
		; for each item in this depth
		Loop % lens[level]
		{
			vi := fc[A_Index]
			; if item is a folder
			if (SubStr(vi,0,1)=="\")
			{
				required := true
				vilen := StrLen(vi)
				; for each lower depth
				Loop % num_levels - level
				{
					level2 := A_Index + level
					fc2 := split[keys[level2]]
					; for each item in this lower depth
					Loop % lens[level2]
					{
						if (SubStr(fc2[A_Index],1,vilen)!=vi)
							continue
						required := false
						break
					}
					if !required
						break
				}
				if !required
					continue
			}
			f.add(vi)
		}	
	}
	return f.absorb(split[keys[num_levels]])
}
FC_getSimple(f)
{
	return f.getCopy().simplify()
}
; removes subitems from the list, usually to avoid conflicts
FC_reduce(f)
{
	split := f.getSplit("depthsort")
	enum := split._newEnum()
	keys := Object()
	lens := Object()
	while enum[key,fc]
	{
		keys[A_Index] := key
		lens[A_Index] := fc.len()
		num_levels := A_Index
	}
	f.clear()
	
	; for each depth (but the last)
	Loop % num_levels - 1
	{
		level := A_Index
		fc := split[keys[level]]
		f.absorb(fc)
		; for each item in this depth
		Loop % lens[level]
		{
			vi := fc[A_Index]
			; if item is a folder
			if (SubStr(vi,0,1)=="\")
			{
				vilen := StrLen(vi)
				; for each lower depth
				Loop % num_levels - level
				{
					level2 := A_Index + level
					fc2 := split[keys[level2]]
					; for each item in this lower depth
					Loop % lens[level2]
					{
						if (fc2[A_Index] and SubStr(fc2[A_Index],1,vilen)!=vi)
							continue
						fc2[A_Index]:="" ; exclude item if it is contained in another item
					}
				}
			}
		}
	}
	return f.absorb(split[keys[num_levels]]).excludeBlanks()
} 
FC_getReduced(f)
{
	return f.getCopy().reduce()
}
; get real containing would be nice too... if you don't want to accidentally affect non contained existing items
FC_getContaining(f,default="")
{
	fc := f.getReduced()
	common := Path(fc[1])
	Loop % fc.len()
	{
		target := fc[A_Index]
		while (!InStr(target,common.path))
			common := Path(common.dir)
		if common.path
			continue
		ErrorLevel := "No Common Path Found"
		break
	}
	return f.bud("list",common.path ? common.path : default)
}
;==========================================================================================================================================================================================
;= OUTPUT =================================================================================================================================================================================
;==========================================================================================================================================================================================
FC_toList(f,delim="`n")
{
	Loop % f.len()
		list .= f[A_Index] . delim
	return list
}
FC_toArray(f)
{
	ret := Object()
	Loop % f.len()
		ret.Insert(f[A_Index])
	return ret
}
FC_toFile(f,fpath="", encoding="UTF-16", delim="`n", overwrite=false)
{
	if (!fpath AND f._params[1] = "file")
		fpath := f._params[2]
	if (!fpath)
		return ( ErrorLevel:="YOU NEED TO SPECIFY A FILENAME" )
	
	file := FileOpen(fpath, overwrite ? 0x01 : 0x02, encoding)
	file.Write(f.toList(delim))
	file.Close()
	
	return fpath
}
; saves a recursive simplified list to the clipboard.  minimum text required to recreate the filestructure
; more for my own testing than anything else
FC_structureToClipboard(f)
{
	return f.getExpanded().simplify().toClipboard()
}
FC_toClipboard(f,delim="`n")
{
	return ( clipboard := f.toList(delim) )
}
FC_explore(f, base_only=false, default="", warn=10)
{
	fc := base_only ? f.getContaining(default) : f.getFolders()
	if ( ( (n := fc.len()) > warn ) and warn )
	{   ; warning + YesNo
		MsgBox, 52, Warning, This operation will open %n% folders... Would you like to continue?
		IfMsgBox No
			return
	}
	Loop %n%
		Run % "explore " fc[A_Index]
}
;==========================================================================================================================================================================================
;= FILE OPERATIONS ========================================================================================================================================================================
;==========================================================================================================================================================================================
FC_create(f)
{
	blank_file := getTemp("file", true)
	blank_dir := getTemp("folder", true)
	dest := f.getSimple()
	source := FC()
	Loop % dest.len()
		source.add(IsFolder(dest[A_Index]) ? blank_dir : blank_file)
	
	; operation -undo
	return ShFO("FO_COPY", source, dest, "FOF_SIMPLEPROGRESS|FOF_MULTIDESTFILES|FOF_NOCONFIRMMKDIR|")
}
FC_delete(f, recycle=true, prompt=false, extra_flags="")
{
	flags := (recycle ? "FOF_ALLOWUNDO|" : "") . (prompt ? "FOF_SIMPLEPROGRESS|FOF_WANTNUKEWARNING|" : "FOF_SILENT|FOF_NOCONFIRMATION|")
	return ShFO( "FO_DELETE", f.getCopy().excludeDuplicates().reduce().excludeNotExist(),f.getTemplate(), extra_flags . flags)
}
FC_moveInto(f,p1,extra_flags="")
{
	return f.move(p1,extra_flags,"into")
}
FC_moveOnto(f,p1,extra_flags="")
{
	return f.move(p1,extra_flags,"onto")
}
FC_move(f,p1, extra_flags="", dest_mode="onto")
{
	return FC_operation(f,"FO_MOVE",p1,extra_flags,dest_mode)
}
FC_copyInto(f,p1, extra_flags="")
{
	return f.copy(p1,extra_flags,"into")
}
FC_copyOnto(f,p1, extra_flags="")
{
	return f.copy(p1,extra_flags,"onto")
}
FC_copy(f,p1, extra_flags="", dest_mode="onto")
{
	return FC_operation(f,"FO_COPY",p1,extra_flags,dest_mode)
}
; maybe work quick regex stuff back into this later
FC_rename(f,p1,extra_flags="")
{
	return f.moveOnto(p1,extra_flags)
}
; need to update this for dest_mode stuff
/*
FC_moveContents(f,p1, extra_flags="")
{
	source := f.getTemplate()
	; make the mapping explicit (in case of single destination folder)
	dest := IsObject(p1) ? p1 : FC("list",p1)
	if (dest.len() < f.len())
		Loop % f.len()
			dest[A_Index] := dest[1]
	
	; expand to list contents explicitly
	Loop % f.len()
	{
		i := A_Index
		new_source := FC("pattern",f[i] "*",1,0)
		source.absorb(new_source)
		Loop % new_source.len()
			destination.add(dest[i])
	}
	return FC_operation(source,"FO_MOVE",destination,extra_flags)
}
*/
;==== Enfolder =========================================================================================================
;=======================================================================================================================
FC_enfolder(f,dest="")
{
	if (dest := promptForPath(f,dest, "Please provide a name for the new folder."))
		return f.moveInto(dest "\" )
}
;==== Spill ============================================================================================================
;=======================================================================================================================
;FC_spill(f,folders=1,recurse=0,delete=0)
FC_spill(f,folders=1,recurse=0,delete=0)
{
	flatten := folders and recurse
	folders := flatten ? 0 : folders

	source 		 := f.getTemplate(1)	; template, but with catch propogated
	for_deletion := f.getTemplate()
	for_creation := f.getTemplate()
	dest := FC()
	
	is_folder := f.getSplit("IsFolder")
	unchanged := is_folder[false] ? is_folder[false] : f.getTemplate()		; any way to do this with default constructor?
	folder_fc := is_folder[true]
	
	Loop % folder_fc.len()
	{
		folder := Path(folder_fc[A_Index])
		new_source := FC("pattern",folder.path "*.*",folders,recurse)		; obtain requested subitems of this folder
		dest.extend("listn",folder.dir,new_source.len())
		source.absorb(new_source)														; add new sources to the source FileContainer, assumed that folders don't overlap -> fast mode OK
			
		if (delete)		; at the very least, the delete flag indicates that the spilt folder should be deleted
			for_deletion.add(folder.path)
		else
			unchanged.add(folder.path)
		if (flatten)	; if flattening, the folders need to be spilt too.  But rather than moving them, just recreate them
			for_creation.absorb(FC("pattern",folder.path . "*.*",2,1).manipulate("move_helper", folder.dir))
	}
	; could move the folders last... no need to recreate them [ can't undo after merge, so no point]
	; could merge folders instead [can't undo after merge, so no point]	
	; isempty filter before rme is a bit odd, but quick way to prevent duplicates
	return source.moveInto(dest).absorb(for_creation.create(), unchanged, for_deletion.filter("IsEmpty",true).removeEmptyFolders(0))
}
FC_leak(f)
{
	return f.spill(0,0,0)
}
FC_dump(f,delete=0)
{
	return f.spill(0,1,delete)
}
FC_flatten(f,delete=0)
{
	return f.spill(1,1,delete)
}
;==== zip ==============================================================================================================
;=======================================================================================================================
; still no error handling for 7-zip stuff
FC_zip(f,destination="", prompt=true, hide=true, switches="-y")
{	
	if !(destination := promptForPath(f,destination,"Please provide a name for the new archive.", prompt))
		return
	TrayTip,, Now zipping...
	f.run7z("a """ . destination . ".zip"" @""" . f.toFile(getTemp(),"UTF-8") . """ " . switches, hide)	
	TrayTip,, Done!
	ret := f.getTemplate(1)
	ret.add(destination ".zip")
	return ret
}
; option to spill if only folders are present?  What would I call that?  Or just an option for here?
; delete option is a bit poor...  need error handling for 7zip
FC_unzip(f, spill=false, shorten=true, remove_dir_ext=true, delete=false, hide=true, switches="-o* -aou -y")
{
	new_f := f.GetTemplate(1)
	files := f.getFiles()
	TrayTip,, Now unzipping...
	Loop % files.len()
	{
		item := Path(files[A_Index])
		TrayTip,, % "Now unzipping '" item.path "'`n(" A_Index " of " files.len() ")"
		f.run7z("x" . " """ . item.path . """ " . switches,item.dir, hide)
		new_f.add(item.dir . item.nameNoExt . "\")
		
	}
	TrayTip,, Now processing...

	if remove_dir_ext
		new_f := new_f.doManip("remove_dir_ext")
	if shorten
		new_f := new_f.shorten(true,delete)
	if spill
		new_f := new_f.spill(1,0,delete)
	if delete
		new_f.absorb(files.delete())
	TrayTip,, Done!
	return new_f
}
FC_run7z(f, line, working_dir="", hide=true)
{
	return f.runWait(f._prefs["7zip"] " " line, working_dir, hide ? "hide":"")	
}
; assumes item is already known to be a folder
remove_dir_ext(item)
{
	return RegExReplace(item,"\s*[.].*","\")
}
;==== Shorten ==========================================================================================================
;=======================================================================================================================
FC_shorten(f, recursive=false, delete=true)
{
	is_folder := f.getSplit("IsFolder")	
	if recursive
		is_folder[true].expand(2)
	
	can_shorten := is_folder[true].getSplit("canShorten")	
	target_split := can_shorten[true].getSplit("depthrsort")

	;dout_o(is_folder[true],"folder targets")
	;dout_o(can_shorten[true],"shorten targets")
	;dout_o(target_split,"target split")
	
	dest := f.getTemplate(1).absorb(is_folder[false],can_shorten[false])
	
	enum := target_split._newEnum()
	while enum[depth,targets]
		dest.absorb(targets.spill(1,0,1))
	return dest.excludeNotExist()
}
shorten_helper(folder)
{
	return Path(folder).dir
}
canShorten(item)
{
	num_files := 0
	loop %item%*.*
		if (num_files := A_Index)
			break
	num_folders := 0
	if !num_files
		Loop %item%*.*,2
			if ( (num_folders := A_Index) == 2 )
				break
	return (num_folders = 1 and num_files = 0)
}
;==== Remove Empty Folders =============================================================================================
;=======================================================================================================================
; recursive mode to remove folders that only have empty folders in them too ?
; ah, the return was blank if nothing was deleted!  this is WRONG!!
FC_removeEmptyFolders(f,recursive=true)
{
	is_folder := f.getSplit("IsFolder")
	is_empty := is_folder[true].getSplit("IsEmpty")
	if recursive
		is_empty[true].absorb(f.getExpansion(2).filter("IsEmpty",true))
	
	return f.getTemplate(1).absorb(is_empty[true].delete(1,0),is_folder[0],is_empty[0])
}
;==== Up ===============================================================================================================
;=======================================================================================================================
FC_up(f)
{
	return f.doManip("up_helper")
}
up_helper(item)
{
	p := Path(item)
	return Path(p.dir).dir . p.name
}
;==== DoManip ==========================================================================================================
;=======================================================================================================================
FC_doManip(f,func, p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{
	return f.moveOnto(f.getCopy().manipulate(func,p2,p3,p4,p5,p6,p7,p8))
}
;==== SetAttributes ====================================================================================================
;=======================================================================================================================
FC_setAttributes(f,attributes,recursive=false,catch=true)
{
	c := 0
	ret := f.getTemplate(1)
	Loop % f.len()
	{
		path := f[A_Index]
		FileSetAttrib, %attributes%, %path%, 1, %recursive%
		if !ErrorLevel
			ret.add(f[A_Index])
		else if catch
			ret._catch.add(f[A_Index])
	}
	return ret
}
;==== RenameAsText =====================================================================================================
;=======================================================================================================================
FC_renameAsText(f,editor="__deFault__")
{
	if (editor == "__deFault__")
		editor := f._prefs["editor"]
	
	temp := getTemp()
	f.toFile(temp)
	
	f.runWait(editor " " temp)
	ret := f.moveOnto(FC("file",temp))
	FileDelete %temp%
	return ret
}
;==========================================================================================================================================================================================
;= INFORMATION ============================================================================================================================================================================
;==========================================================================================================================================================================================
FC_find(f,path,exclude_index=-1)
{
	Loop % f.len()
		if ( (path=f[A_Index]) and (A_Index != exclude_index) )
			return A_Index
	return -1
}
FC_isEmpty(f)
{
	return !f.len()
}
; could probably be updated... does it even work still?
FC_getStats(f, desired_units="")
{
	stats := Object()
	TotalSize := 0
	num_files := 0
	num_folders := 0
	Loop % f.len()
	{
		item := f[A_Index]
		FileGetAttrib attr, %item%
		IfInString attr, D
		{ ; recursively handle folder
			Loop %item%\*.*,1,1
			{
				TotalSize += %A_LoopFileSize%
				
				FileGetAttrib attr, %A_LoopFileFullPath%
				IfInString attr, D
					num_folders++
				else
					num_files++
			}
			num_folders++
		}
		else
		{ ; just a file
			num_files++
			FileGetSize size, %item%
			TotalSize += %size%
		}
	}
	
	; determine the appropriate units
	; if you get past YB, please contact me!
	unit_list =B KB MB GB TB PB EB ZB YB
	StringSplit, units, unit_list, %A_Space%
	Loop
	{
		unit := units%A_Index%
		if (TotalSize < 1024 OR desired_units = unit)
			break
		TotalSize := TotalSize / 1024.00
	}

	stats.size 			:= TotalSize
	stats.units 		:= unit
	stats.num_files 	:= num_files
	stats.num_folders 	:= num_folders
	
	return stats
}
;==========================================================================================================================================================================================
;= HELPER FUNCTIONS =======================================================================================================================================================================
;==========================================================================================================================================================================================
; lack of consistent naming convention here bugs me
StrSwap(item, target, replacement)
{ ; regex + unicode = bad experiences
	return (item=target) ? replacement : item
}

move_helper(item,dir)
{
	SplitPath item, name, folder
	if !name
	{
		SplitPath folder, name
		tail := "\"
	}
	return dir . name . tail
}
/*
	array unique functions (a,b,distance)
		- return false to delete b
	array sort functions (a,b,distance)
		- return > 0 to swap a and b
*/
; sort by length, short to long
sorter(a, b, c)
{
	a := StrLen(a)
	b := StrLen(b)
	return a > b ? 1 : a = b ? 0 : -1
}
; sort by length, long to short
rs(a,b)
{
	return sorter(b,a,0)
}
rsorter(a, b, c)
{
	return sorter(b,a,c)
}

depthsort(item)
{
	StringReplace, item, item, \, \, UseErrorLevel
	return ErrorLevel + (SubStr(item,0,1)!="\")
}
depthrsort(item)
{
	return -depthsort(item)
}
/*
split by -depth
for each depth
	for each item in this depth
		for each target folder in smaller depths
			remove target from list if item is substring
*/
; remove b if b is in a
; removes paths that are already defined implicitly
simplifier(a,b,c)
{	
; return false to delete b
;	return ( SubStr(a,1,StrLen(b)) != b )
	return !InStr(a,b)	
}
/*
split by depth
for each depth
	for each folder in this depth
		for each target item in bigger depths
			remove target from list if target is substring
*/
; removes paths that are hierachically contained within another listed path
reducer(a,b,c)
{	
	; return false to delete b
	return !InStr(b,a)
}
; checks if given real item is a directory or not and adds the slash where appropriate
dir_fixer(item)
{
	if IsFolder(item)
		return item
	FileGetAttrib, attr, %item%
	IfInString attr, D
		return item . "\"
	return item
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; would using Path objects be efficient enough?
; could they be more efficient!?
;		- creating and accessing would be slightly slower
;		- manipulating would take more effort too
;		+ copying and passing would be more efficient! (pointers rather than string copying)
;		... probably overall worse.
IsFolder(item)
{
	return (SubStr(item,0,1)="\")
}
IsFile(item)
{
	return !IsFolder(item)
}
IsBlank(item)
{
	return !item
}
isEmpty(folder)
{
	Loop %folder%*.*,1,0
		return false
	return true
}
PathExist(item)
{
	return FileExist(item) ? 1 : 0
}
finder(item,fc)
{
	return ( fc.find(item) != -1 )
}
getTemp(type="file", create=false, base="")
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
		ret .= "\"
	}
	return ret
}
kill_bad_spaces(path)
{
	path := RegExReplace(path,"\s*(\.|$)","$1")	; trailing spaces are bad
	path := RegExReplace(path,"^\s*")			; leading spaces are bad
	return path
}
promptForPath(list, path="", msg="", prompt=true, use_standard_dialog=false)
{
	p := Path(list[1])
	dir := p.dir
	nameNoExt := p.nameNoExt

	; ask user for path if not provided
	if !path
	{
		; generate a simple suggestion for the user
		if (SubStr(nameNoExt,0,1) = "\")						; remove trailing slash if present	
			StringTrimRight, nameNoExt, nameNoExt, 1
		StringReplace, suggestion, nameNoExt, _, %A_Space%,All	; underscores to spaces
		suggestion := kill_bad_spaces(suggestion)
		if dir not contains anime
			suggestion := RegExReplace(suggestion,".*","$T0")		; title case
		
		; allow the user to specify the path
		if prompt
		{
			if use_standard_dialog
				FileSelectFolder, path, dir,1+2+4
			else
				InputBox,path,%msg%,The path will be relative to "%dir%" unless a full path is given,,,,,,,,%suggestion%		
			if ErrorLevel
				return
		}
		else
			path := suggestion
	}
	if !path
		return
	
	if (SubStr(path,0,1) = "\")				
		StringTrimRight, path, path, 1 		; can't yet tell if this is a folder or file, so remove any backslashes now (added back later if necessary)
	IfNotInString path, :					
		path := dir . path 				; convert relative paths to absolute paths
	
	return path
}
xor(a,b)
{
	return (a || b) && !(a && b)
}
;==========================================================================================================================================================================================
;==========================================================================================================================================================================================
;==========================================================================================================================================================================================
/*
; misguided
FC_ChoosePreference(f,ByRef pref)
{
	return (pref := (pref=="__deFault__") ? f._prefs[pref : keep
}
*/
FC_SetPreference(f,name,value)
{
	return f._prefs["name"] := value
}
FC_GetPreference(f,name)
{
	return f._prefs["name"]
}
FC_runWait(f, line, working_dir="", options="")
{
	return f.run(line,working_dir,options, true)
}
FC_run(f, line, working_dir="", options="", wait=false)
{
	Run %line%, %working_dir%, %options%, pid
	if wait
	{
		f._goat := pid
		Process WaitClose, %pid%
		f._goat := ""
	}
	return pid
}
FC_RUNDELAY:
	
return
;==========================================================================================================================================================================================
;= INTERNAL STUFF =========================================================================================================================================================================
;==========================================================================================================================================================================================
; bugged me a lot
MsgBox(p1,p2="",p3="",p4="")
{
	static list="Yes|No|OK|Cancel|Abort|Ignore|Retry|Continue|TryAgain|Timeout"
	MsgBox, %p1%, %p2%, %p3%, %p4%
	Loop Parse, list, |
		IfMsgBox %A_LoopField%
			return A_LoopField
	return ErrorLevel := "!?"
}
/*
	dest.len() == 1  and is folder   -->  destination for all source items
	else 							 -->  destination-source 1-to-1 mapping
	
	to rename a single folder, make the dest name explicit (not my problem here)
	
	will force dest.len() == source.len() before passing onto ShFO
	
	multidestfiles always on by default
	
	************************
	SO, is this ready for release?
*/
FC_operation(f,operation,destination="",extra_flags="",dest_mode="onto")
{ 
	;dout_f(A_ThisFunc)
	source := f.getCopy().rsortLinked(destination)
	destination := IsObject(destination) ? destination : FC("list",destination)
	
	; expand single destination to a 1-to-1 mapping between source and destination
	dest := destination[1]
	if ( destination.len() == 1 and source.len() != 1)
		Loop % source.len()
			destination[A_Index] := dest
	
	; deal with ambiguity of destination folders
	if (dest_mode="into")
		Loop % source.len()
			If IsFolder(d:=destination[A_Index])
				destination[A_Index] := d . Path(source[A_Index]).name
	
	; avoid destination is subfolder of source problem by percolating upwards
	; mostly for enfolder and typically a rare case even then
	Loop % source.len()
	{
		; if dest is a subfolder of source
		if ( 	(SubStr(d:=destination[A_Index],0)=="\") 		; dest is a folder
			and (SubStr(s:=source[A_Index],0)=="\")				; source is a folder
			and (StrLen(d) > (slen:=StrLen(s))) 				; dest path is longer than source path
			and (s=SubStr(d,1,slen)) ) 							; dest path is contained in source path
		{
			c := s
			name := Path(c).name
			
			; remove this entry (replaced by soon to be added entries)
			source[A_Index] := ""
			destination[A_Index] := ""
			
			; keep going until there are no more conflicts
			While % FileExist(c)
			{
				subs := FC("pattern",c "*.*",1,0)
				c .= name
				Loop % subs.len()
				{
					if (subs[A_Index]=c)
						continue
					; move individual items up
					; new additions do not need to be (and aren't) processed in this loop
					source.add(subs[A_Index])
					destination.add(c Path(subs[A_Index]).name)
				}
				
			}
		}
	}
	
	return ShFO(operation, source, destination, extra_flags . "FOF_MULTIDESTFILES|FOF_ALLOWUNDO|FOF_SIMPLEPROGRESS|FOF_NOCONFIRMMKDIR")
}
/*
	source and dest will be modified.  eventually.   I'll get around to it.
	
	assumes that the operation is not order dependant.  (nonexistant source items will be excluded,
	even if they would be created during the operation)\
	
	can similar files work in the postprocessing system?
	
	need to handle lost items from ShFileOperation!!
	
*/
ShFO(op, source_in, dest_in="", flags="", keep="__deFault__",merge="__deFault__", close_when_done=true)
{ ;dout_f(A_ThisFunc)
	
	ret := source_in.getTemplate(1) ; keep propogating the catch
	
	if !IsObject(ret)
	{
		ErrorLevel := "source was not a FileContainer"
		;dout(ErrorLevel)
		return FC()
	}
	
	if !source_in.len()
	{
		ErrorLevel := "source had nothing in it"
		;dout(ErrorLevel)
		return ret
	}
	
	source := source_in.getCopy().excludeBlanks()
	dest := dest_in.getCopy().excludeBlanks()
	if ( (op != "FO_DELETE") and (source.len() != dest.len()) )
	{
		ErrorLevel := "destination list was not the same size as the source list"	
		;dout(ErrorLevel)
		ret._catch.absorb(source)
		return ret ; treat all source items as lost items
	}
	;dout_more()
	;dout_o(source_in,"source in")
	;dout_o(dest_in,"dest in")
		
	;autorename := InStr(flags,"FOF_RENAMEONCOLLISION")
	;autoyes    := InStr(flags,"FOF_NOCONFIRMATION")
	
	to_remove := Object()
	Loop % source.len()
	{
		s := source[A_Index]
		if !(s_attr := FileExist(s))
		{   ; remove nonexistant source files
			to_remove.Insert(A_Index)
			ret._catch.add(s[A_Index])
		}
		
		else if (s=dest[A_Index])
		{   ; for pointless operations, mark as successful but don't actually process them
			to_remove.Insert(A_Index)
			ret.add(s)
		}
	}
	
	; remove canceled operations
	source.excludeAt(to_remove)
	dest.excludeAt(to_remove)

	; do the main part of the requested operation
	result := ShellFileOperation(op, source.toList("|"), dest.manipulate("tricky").toList("|"), "FOF_WANTMAPPINGHANDLE|" flags)
	;dout_o(result,"result of ShFileOperation call")
	; delete operations are easy
	if (op="FO_DELETE")
		ret._catch.absorb(source.excludeNotExist())		; items caught: unable to delete
	else
	{	; postprocessing to track what actually happend during the operation
		s_ren := ret.getTemplate()
		d_ren := ret.getTemplate()
		
		mappings := result.mappings
		
		Loop % source.len()
		{
			d := dest[A_Index]
			if (r := mappings[d])
			{
				; add the trailing slash back on folder paths
				if IsFolder(d)
					r .= "\"
				else
				{
					StringReplace, tail, r, %d%
					;if ( tail and RegExMatch(tail, "^\s(\(\d+\)|- Copy)$") )
					if ( tail and ( tail=" - Copy" or RegExMatch(tail, "^\s\(\d+\)$") ) )
					{	; prep to fix ShFileOperations' buggy rename system
						s_ren.add(r)
						d_ren.add(MakeSuggestion(d))
						;dout("'" r "' to '" MakeSuggestion(d) "'")
						continue
					}
					r = %r% ; remove trailing space that was added before the operation
				}
				ret.add(r)
			}
			else	; items caught: something went wrong during ShellFileOperation	
				ret._catch.add(source[A_Index])			
		}
		;dout_o(s_ren,"s_ren")
		;dout_o(d_ren,"d_ren")
		;dout_o(ret,"ret before move")
		ret.absorb(s_ren.moveOnto(d_ren))
		;dout_o(ret,"ret after move")
	}

	;dout_o(ret,"result of operation")
	;dout_less()
	return ret
}
MakeSuggestion(path)
{
	p := Path(path)
	while FileExist(suggestion := p.dir p.namenoext " (" A_Index+1 ")." p.ext)
		continue
	return suggestion
}
; by adding a space to file paths, ShFileOperation will be tricked into adding the item to the
; mappings!  Weird stuff, but it works well.  downside is extra processing and ShFileOperation's
; inability to properly rename items afterwards ("new.txt " gets renamed to "new.txt  (2)"...),
; which requires even more effort just to fix that after the initial operation!
; but at least I finally have a solid solution for tracking file movements!
tricky(item)
{
	if IsFolder(item)
		return item
	return item A_Space
}
rts(item)
{
	return IsFolder(item) ? SubStr(item,1,-1) : item
}

; for tight loops, it is more efficient to determine the number of
; non-default parameters up front.  
CallPrep(p1="__deFault__", p2="__deFault__", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__", p9="__deFault__")
{
	Loop 9
		if (p%A_Index% == "__deFault__")
			return "Call" . (A_Index-1)
}
Call0(func){
	return %func%()
}
Call1(func,p1){
	return %func%(p1)
}
Call2(func,p1,p2){
	return %func%(p1,p2)
}
Call3(func,p1,p2,p3){
	return %func%(p1,p2,p3)
}
Call4(func,p1,p2,p3,p4){
	return %func%(p1,p2,p3,p4)
}
Call5(func,p1,p2,p3,p4,p5){
	return %func%(p1,p2,p3,p4,p5)
}
Call6(func,p1,p2,p3,p4,p5,p6){
	return %func%(p1,p2,p3,p4,p5,p6)
}
Call7(func,p1,p2,p3,p4,p5,p6,p7){
	return %func%(p1,p2,p3,p4,p5,p6,p7)
}
Call8(func,p1,p2,p3,p4,p5,p6,p7,p8){
	return %func%(p1,p2,p3,p4,p5,p6,p7,p8)
}
Call9(func,p1,p2,p3,p4,p5,p6,p7,p8,p9){
	return %func%(p1,p2,p3,p4,p5,p6,p7,p8,p9)
}

; static methods!
;FC_onArray()


; debug caller.  Even folds nicely
FC_caller(f,func,p1="__deFault__",p2="__deFault__",p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{
	static level=-1
	static  dout_f		= "dout_f"
		,	dout_v		= "dout_v"
		,	dout_offset	= "dout_offset"
		,	dout		= "dout"
	%dout_offset%(++level)
	%dout%(func " {")
	%dout_f%(A_ThisFunc,false)
	callf := CallPrep("",p1,p2,p3,p4,p5,p6,p7,p8)
	ret := %callf%("FC_" . func,f,p1,p2,p3,p4,p5,p6,p7,p8)
	%dout_v%(ret, func " returned")
	;%dout%("}")
	/*
	If !ret
	{
		if func not in extend,add,len,remove,takeCatch,toList,run,runWait,run7z,enableCatch
			MSgBox blank return for %func%
	}
	*/
	%dout_offset%(--level)
	if ret
		return ret
}
;================================================================================================================
;========================================  TODO  ================================================================
;================================================================================================================
/*
	ROADMAP:
		
		recently found that updateLinked bug... may be others like it around here somewhere.
			- definitely need to make some new test cases for this area
		
		sometimes I return a string and set errorlevel on operation errors.  Is this the best way?
			- instead return empty FC w/ full catch if enabled? (+ errorlevel)
		
		get ShFO settled
			- file names can conflict with folder names
			- use helper gui to handle all user prompts
			- probably missing other configurable things
		
		overhall of parameter system
			- some methods (like unzip) have too many parameters...
			- replace with options flag (+ centralized option interpretation system?)
		
		default preferences
			- should be queryed, not saved to every FC object
			- need to set up a good code interface
			- need to integrate system into everything
		
		Finalize Path (+integration)
			- for now, just enough so that the darn documentation examples won't get broken in the future!
		
		filter --> where ?
			- easy global get variant
			- can have a collection of built-in functions
			- much simpler setup
			- easier to add in new variants!
			- but callbacks are significantly _slower_...
				> macros?  eh, what a pain 
		
		fix examples and update documentation
		
		<<<< RELEASE # 5 >>>>  <----- can finally be considered stable
		
		replace StExBar with a separate AHK library [GetWindowsExplorerPath]
			- most of the code is already out there, but I've yet to see it all in one place
			- much easier to demo this library through explorer interactions
		
		Progress Notification [Progress / SplashImage]
			- functionalize it
			- experiment
			- FC setting for controlling this behavior
		
		make more demos, find more use cases
			- generating test areas
			- PortableApps ini situation
			- G-M cleanup?
		
		<<<< RELEASE # 6 >>>>  <----- hopefully very accessible
		
		Split project
			- generic container library
			- FileContainer extending that library
		
		richObject?
			- definitely looks good
			- will probably add in later after most of this library is finished
		
		stdlib?
		
		<<<< RELEASE # 7 >>>>  <---- container library will likely be more important than FileContainer
		
		probably focus on new features + related examples.  
		
		static methods
	
	GENERAL UNSORTED THOUGHTS:
		
		how should setAttributes catch?
		
		for catch returns, maybe also include reason why each item was lost?
		
		burn to CD using imgburn (mix it up with zip!)
		
		unzip needs error managment (did it unzip properly? can I delete it now?)
		
		split to folders
			- by size too!

		unzip should ignore part1/part2/part3...  cli doesn't seem to handle that properly
		
		improve renameAsText
			- option to align at levels for easy editing
			- option to space it out extra for easy editing
			- will be interesting to figure out how to handle operations
				- force explicit?
			
		"take"
			removed from parent container and returned
			... I really want to generalize all these convenience variants soon.
			- "do" versions of manip, filter, etc.
		excludeBlanks and excludeDuplicates and probably others
			- I would really like to hook them into a more general method
			- the patterns are so very similar... there should be a way to generalize
		
		internal undo history
			- Explorer's system is a lost cause
			- but this will probably take a lot of work
				- not all operations can be reversed (like even simple overwrites)
		
		merge folders
			- with optional shortening inside!
			- basically enfolder tehn spill enfoldered folders
	
		zip each item to a separate archive
			- makes more sense when each item is a folder, but no need to limit functionallity
	
		recursive unzipping (for annoying people who zip zips of zips)
	
		expansion methods need to be investigated
			- need more use cases
			- make them more like fromPattern?
			- should recursion and pattern default to construction settings if available?
		
		dup checking mode for certain functions
			- manipulate
			- extend
			- absorb
			- add/set
			- everything?
			- could be a FC flag
		
		name files after folders
		
		unzip folder name... why is it appended with part01 still?  I'm doing it through
		7zip, so what's the deal!?
		
				integration with programs like TeraCopy
		
		Held Operations [ MsgBox w\ timeout ? ]
			- delete zip files after unzipping, but let the user make sure first
	
		would be nice to be able to detect when the parent folder is better named while shortening...
		
		ability to operate on an array of FileContainers.  For when you have
		multiple containers on which you wish to performe the same actions.
			- FC container?
			- static method?
			- ?
		
		7zip operations manage to make foobar2000 skip if I'm doing something else too.  Very annoying.
		
		7zip operations dosen't die even if you kill the ahk process that started it.  That should be changed.
		
		for flexible methods (with lots of default params), is it faster to ByRef them all?
		
		delayed task system ?
			- when working internally, set a flag and delay all processing steps
			- doDelayedTasks or something to then go throug everything at once
				+ hopefully more efficient
				+ probably cleaner code in some areas
				- call triggered by read requests
		
		possibility of more direct building?  f.extend with a (from list + filter) !?  How would that even work syntactically?
			- might work very well as part of the delayed task system
		
		for the built-in filter methods, it would be nicer
		to just expose the functions I use for filtering, 
		at least in some cases.  They have uses
		beyond just being used with filter.
		
		run files in something
			- prompt for path?  How would this work?
			- shortcut to using in command line?  could just paste, but faster is better
		
		more small variations?
			- "blend" to flatten inside selected folders
		
		file contents manipulation should be built into this
			- apply actions to entire container
			- filter by contents
			- actions based on contents
			- spidering in general
		
		integrate Path library more fully
		
		param saving system is hardcoded, and I don't like it.  perhaps a dict would be better...
		
		lots of "get" versions... simplify those like I did with fast mode?
			- reword to make get____ work well
			- switch to appending "Copy"
			- leading underscore (...)
			- aliases and other one-liners
				- if I can get this working, it would very nice
					- dump, leak, flatten... lots of the sort operations... all of those are oneliners
					- centralization of all calls is very convenient	

					
	
	INTERNAL IMPROVEMENT IDEAS:
	
		improve efficiency in situations where FC is extended (like dir_fixer with construction methods)

		pre-operation functions
			- returns lists or FCs rather than doing the actual operation
			- operation could be done afterwards using the return values
			- would make reuse of functions more efficient
				* shorten calls spill for each depth.  create and delete don't need to be done per depth.

		how much can I reduce the need for Call?
			- for many methods, it seems easy enough to make all params __deFault__ then set them inside.
			
		more can be done for efficiency
			- but the basic structure is inefficient by choice (convenience of use vs efficiency).
			- Even if it takes longer, the user can be doing something else.
				- delays are rarely that long... more a sluggish feel than a "I'll go do something else".
			- vicious cycle:  restructure -> make more efficient -> restructure.  Focus on only functionallity for a while +20 sanity
	
		duplicate removal can be optimized probably
			- flag for "is already unique"
			- keep a dict?  meh
		
	MUCH LATER:
	
		file operations should be able to interpret implicit steps.  
				
		Really, what use would be a tree structure?
			- already lost interest in finishing that library.  so many things do for a _good_ tree
			- keeping order is a different problem
			- my level split strategy works well enough for my needs here I believe.
			+ reducer would benefit greatly from this
			+ level based selection methods
				- what would I use them for?
			+

		better duplicate checking?  Does this really matter enough to warrent the effort and added code?
			- ?
			- need a compare func with GetFileInformationByHandle()
				- http://stackoverflow.com/questions/562701/best-way-to-determine-if-two-path-reference-to-same-file-in-c-c
				- http://msdn.microsoft.com/en-us/library/aa364952%28VS.85%29.aspx
				- http://msdn.microsoft.com/en-us/library/aa363788%28v=VS.85%29.aspx
				;if ( PathsAreEquivalent(path,f[A_Index]) and A_Index != exclude_index)
	
	UNEXPLAINED:
		something breaks if I use …… instead of __deFault__.  I don't know why, either.  It is like the comparison doesn't work,
		or like it can't be passed to a function properly.
		
	NOTES:
	
	large test area (~2600 items) [already old timings, should be even faster now that arrays are gone]
		excludeDuplicates() less than a second
		sort in less than 4 seconds (could be faster, but it is already much better than before)
		simplify in about 8 seconds (way better than before.  barring radical changes, only tuning is left)
	
	structureToClipboard test on 18531 items:
	~39s for InStr method
	~35s for SubStr method
	~19s for ._array method
	~17s for no arrays anymore method
		
	array unique functions (a,b,distance)
		- return false to delete b
	array sort functions (a,b,distance)
		- return > 0 to swap a and b

	all too easy to create invalid items... use \\.\<path> syntax to fix manually with command line
	
	for callbacks vs direct code:
		- from simple tests, it seems like direct code can be up to 5 times faster.
		- try to minimize local variables in callback function
		- much of the slowdown seems to be basic function call overhead.
		- returning an expression results in a 2x slowdown (weird).  Just break up the lines
		- best I can get is 2x slower for callback.  Rather annoying.  
		- when using strings, the added complexity drops it all down to 4-5 times slower.  IsFolder filtering takes 4-5 times longer than it would were it hardcoded.
*/


Path(p1,p2="",p3="",p4="",p5="",p6="",p7="",p8="",p9="")
{ ;dout_f(A_ThisFunc)
	static base
	if !base
		base := Object("__Call", "Path_caller", "__Get", "Path_getter")
	
	while ( (part := p%A_Index%) != "" and A_Index<=9)
		path .= IsObject(part) ? part.path : part
	
	SplitPath, path, name, dir, ext, nameNoExt, drive
	if ( isFolder := !name )
	{
		StringGetPos, pos, path, \, R2
		name := nameNoExt := SubStr(path,pos+2)
		dir  := SubStr(path,1,pos)
	}
	
	return Object("base",base,"path",path,"name",name,"dir",dir . "\","ext",ext,"nameNoExt",nameNoExt,"drive",drive . "\","isFolder",isFolder,"isFile",!isFolder)
}
; only 8 params here
Path_caller(self,func,p1="__deFault__",p2="__deFault__",p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{ ;dout_f(A_ThisFunc)	
	if ! self.fileContainer
		self.fileContainer := FC("list",self.path)
	
	if ( return_fc := (SubStr(func,1,1)=="_") )
		StringTrimLeft, func, func, 1
	
	
	callf := CallPrep("",p1,p2,p3,p4,p5,p6,p7,p8)
	fc := %callf%("FC_" func, self.fileContainer,p1,p2,p3,p4,p5,p6,p7,p8)
	
	return ( return_fc ? fc : self)
}
Path_getter(self, key)
{
	if (key="_dir")
		self._dir := Path(self.dir)
	else if (key="_drive")
		self._drive := Path(self.drive)
}



; 8 total params, room for 1 more left open for extend functions
FC(method="",source="", p3="__deFault__", p4="__deFault__", p5="__deFault__", p6="__deFault__", p7="__deFault__", p8="__deFault__")
{
	static base, fcmethod
	if !base
	{
		base := Object( 	"len",						"ObjMaxIndex"
						,	"add",						"ObjInsert"
						,	"exclude",					"FC_exclude"
						,	"clear",					"FC_clear"
						,	"getCopy",					"FC_getCopy"
						,	"getTemplate",				"FC_getTemplate"
						,	"sort",						"FC_sort"
						,	"rsort",					"FC_rsort"
						,	"sortLinked",				"FC_sortLinked"
						,	"rsortLinked",				"FC_rsortLinked"
						,	"getOrder",					"FC_getOrder"
						,	"updateLinked",				"FC_updateLinked"
						,	"refresh",					"FC_refresh"
						,	"absorb",					"FC_absorb"
						,	"extend",					"FC_extend"
						,	"become",					"FC_become"
						,	"bud",						"FC_bud"
						,	"getExpansion",				"FC_getExpansion"
						,	"expand",					"FC_expand"
						,	"getExpanded",				"FC_getExpanded"
						,	"getSplit",					"FC_getSplit"
						,	"filter",					"FC_filter"
						,	"filterTF",					"FC_filterTF"
						,	"manipulate",				"FC_manipulate"
						,	"excludeFolders",			"FC_excludeFolders"
						,	"excludeFiles",				"FC_excludeFiles"
						,	"excludeNotExist",			"FC_excludeNotExist"
						,	"getFolders",				"FC_getFolders"
						,	"getFiles",					"FC_getFiles"
						,	"getExist",					"FC_getExist"
						,	"excludeAttributes",		"FC_excludeAttributes"
						,	"includeAttributes",		"FC_includeAttributes"
						,	"getWithAttributes",		"FC_getWithAttributes"
						,	"getWithoutAttributes",		"FC_getWithoutAttributes"
						,	"excludeBlanks",			"FC_excludeBlanks"
						,	"excludeDuplicates",		"FC_excludeDuplicates"
						,	"excludeWhereIn",			"FC_excludeWhereIn"
						,	"excludeWhereNotIn",		"FC_excludeWhereNotIn"
						,	"getWhereNotIn",			"FC_getWhereNotIn"
						,	"getWhereIn",				"FC_getWhereIn"
						,	"excludeAt",				"FC_excludeAt"
						,	"excludeNotAt",				"FC_excludeNotAt"
						,	"getAt",					"FC_getAt"
						,	"getNotAt",					"FC_getNotAt"
						,	"excludeInRange",			"FC_excludeInRange"
						,	"excludeNotInRange",		"FC_excludeNotInRange"
						,	"getInRange",				"FC_getInRange"
						,	"getNotInRange",			"FC_getNotInRange"
						,	"create",					"FC_create"
						,	"delete",					"FC_delete"
						,	"move",						"FC_move"
						,	"moveInto",					"FC_moveInto"
						,	"moveOnto",					"FC_moveOnto"
						,	"moveContents",				"FC_moveContents"
						,	"copy",						"FC_copy"
						,	"copyInto",					"FC_copyInto"
						,	"copyOnto",					"FC_copyOnto"
						,	"rename",					"FC_rename"
						,	"operation",				"FC_operation"
						,	"run7z",					"FC_run7z"						; more of an internal method right now
						,	"zip",						"FC_zip"
						,	"unzip",					"FC_unzip"
						,	"enfolder",					"FC_enfolder"
						,	"spill",					"FC_spill"
						,	"leak",						"FC_leak"
						,	"dump",						"FC_dump"
						,	"flatten",					"FC_flatten"
						,	"shorten",					"FC_shorten"
						,	"removeEmptyFolders",		"FC_removeEmptyFolders"
						,	"up",						"FC_up"
						,	"renameAsText",				"FC_renameAsText"
						,	"doManip",					"FC_doManip"
						,	"setAttributes",			"FC_setAttributes"
						,	"toList",					"FC_toList"
						,	"toArray",					"FC_toArray"
						,	"toFile",					"FC_toFile"
						,	"explore",					"FC_explore"
						,	"toClipboard",				"FC_toClipboard"
						,	"structureToClipboard",		"FC_structureToClipboard"
						,	"isEmpty",					"FC_isEmpty"
						,	"find",						"FC_find"
						,	"getStats",					"FC_getStats"
						,	"simplify",					"FC_simplify"
						,	"getSimple",				"FC_getSimple"
						,	"reduce",					"FC_reduce"
						,	"getReduced",				"FC_getReduced"
						,	"startWatching",			"FC_startWatching"
						,	"stopWatching",				"FC_stopWatching"
						,	"getContaining",			"FC_getContaining"
						;==================================================================================================
						;================= don't have a name for this category ============================================
						;==================================================================================================
						,	"enableCatch",				"FC_enableCatch"
						,	"disableCatch",				"FC_disableCatch"
						,	"takeCatch",				"FC_takeCatch"
						,	"IsEqual",					"FC_IsEqual"
						,	"IsEquivalent",				"FC_IsEquivalent"
						,	"promptRename",				"FC_promptRename"
						,	"__Delete",					"FC_Die"
						,	"run",						"FC_run"
						,	"runWait",					"FC_runWait"
						,	"SetPreference",			"FC_SetPreference"
						,	"GetPreference",			"FC_GetPreference"
						;,	"__Call",					"FC_caller"			; for debugging purposes
						;==================================================================================================
						;================ manually handle built-in methods ================================================
						;================ not fully satisfied with this approach ==========================================
						;==================================================================================================
						,	"Insert",					"ObjInsert"
						,	"_Insert",					"ObjInsert"
						,	"Remove",					"ObjRemove"
						,	"_Remove",					"ObjRemove"
						,	"MaxIndex",					"ObjMaxIndex"
						,	"_MaxIndex",				"ObjMaxIndex"
						,	"MinIndex",					"ObjMinIndex"
						,	"_MinIndex",				"ObjMinIndex"
						,	"SetCapacity",				"ObjSetCapacity"
						,	"_SetCapacity",				"ObjSetCapacity"
						,	"GetCapacity",				"ObjGetCapacity"
						,	"_GetCapacity",				"ObjGetCapacity"
						,	"GetAddress",				"ObjGetAddress"
						,	"_GetAddress",				"ObjGetAddress"
						,	"NewEnum",					"ObjNewEnum"
						,	"_NewEnum",					"ObjNewEnum"
						,	"AddRef",					"ObjAddRef"
						,	"_AddRef",					"ObjAddRef"
						,	"Release",					"ObjRelease"
						,	"_Release",					"ObjRelease"
						;==================================================================================================
						;================ call invalid method and get an error! ===========================================
						;==================================================================================================
						,	"base",						Object("__Call","FC_MethodDoesNotExist"))
		
		
		fcmethod := Object(	"",							Object()
						,	"catch",					Object()
						,	"list",						Object()
						,	"listn",					Object()
						,	"array",					Object()
						,	"file",						Object()
						,	"pattern",					Object()
						,	"regex",					Object())			; not much yet...  have ideas for later
		
	}
	
	; rather, make path library into FC methods that act on entire container (thus len=1 --> Path)
	; prep for future quick access to the Path library
	if !fcmethod[method]
	{
		callf := CallPrep("","",p3,p4,p5,p6,p7,p8)
		return %callf%("Path",method,source,p3,p4,p5,p6,p7,p8)
	}
	
	f := Object(		"base",						base
					,	"_catch",					""
					,	"_goat",					""
					,	"_params",					Object(1,method,2,source,3,p3,4,p4,5,p5,6,p6,7,p7,8,p8)
					,	"_prefs",					GetDefaultPreferences())
	return f.refresh()
}

; still looking for a more straightforward way to catch these without slowing things down much
FC_MethodDoesNotExist(f,method)
{
	ListLines
	MsgBox ERROR - '%method%' is not a valid FileContainer method.
}
; actually, I think this doesn't work?  
FC_Die(f)
{
	;MsgBox DIE!!!!
;	MsgBox % Object(f)
	;dout("goats!")
	;dout_o(f,"f into die")
	if (f._goat)
		Process, Close, % f._goat
}



/*
	
	
	CATCH:
		
		calling the <enableCatch> method of a FileContainer readies that container for collecting
		any items lost along the way during file manipulation.  Like if you start to <spill> your
		container and choose "don't move" for some file conflicts that arise, the items you didn't
		move will be caught if you enabled catching.  After the move operation, you can call <takeCatch>
		on the return value to obtain a new FileContainer with all the caught items.
		
		Catch isn't catchy, but catchiness is
		
		You have to go out of your way to duplicate a catch.  <getCopy> and such will move the catch
		from the original container and put it in the new copy.  
		
		(start code AHK)
		source.enableCatch()
		result := source.move(destination)
		catch := result.takeCatch()         ; this is how to get the catch
		nothing := source.takeCatch()       ; this will just get you an empty FileContainer
		; not that source is still catch enabled (it is just that the catch is blank at the moment)
		(end code)
		
		However, "catchiness" is contagious:
		(start code AHK)
		a.enableCatch()				; catching enabled
		b := a.getTemplate()		; b starts off with a fresh catch, but catching is enabled
		c := b.getTemplate()		; c starts off with a fresh catch, but catching is enabled
		a.disableCatch()			; disable catching
		d := a.getTemplate()		; d is not ready to catch
		(end code)

		
		catch only matters for file manipulation.  It is not (currently) used for filters or other container-only
		manipulation methods.

*/