;Mimic/emulate ".gitignore", see http://git-scm.com/docs/gitignore

Ignore_GetPatterns(ignorefile)
{
	i_fp := Util_FullPath(ignorefile)
	SplitPath,i_fp,,baseDir
	StringReplace,baseDir,baseDir,\,/,All
	
	ignore_patterns:=[]
	ignore_patterns.negate:=[]
	Loop,Read,%ignorefile%
	{
		if StrLen(current_line:=Trim(A_LoopReadLine)) ;A blank line matches no files, so it can serve as a separator for readability.
		{
			tf:=SubStr(current_line,1,2) ;two first chars
			fc:=SubStr(tf,1,1) ;first char
			
			if (fc=="#") ;A line starting with # serves as a comment.
				continue
			if (fc=="!") {
				ignore_patterns.negate.Insert(SubStr(current_line,2))
				continue
			}
			if (tf=="\ ") ;escape for leading spaces
			|| (tf=="\#") ;Put a backslash ("\") in front of the first hash for patterns that begin with a hash.
			|| (tf=="\!") { ;escape for literal '!'
				ignore_patterns.Insert(SubStr(current_line,2))
				continue
			} else {
				ignore_patterns.Insert(Trim(current_line))
			}
		}
	}
	ignore_patterns.negate := Ignore_PatternTransform(ignore_patterns.negate,baseDir)
	return Ignore_PatternTransform(ignore_patterns,baseDir)
}

Ignore_PatternTransform(patterns,baseDir)
{	
	for each, pat in patterns
	{
		if each is not integer
			continue
		_tmp:=pat
		if (SubStr(_tmp,1,1)=="/")
			_tmp := chr(8) baseDir "/" SubStr(_tmp,2)
		StringReplace,_tmp,_tmp,/**/, % chr(2) ,All
		StringReplace,_tmp,_tmp,/,\\,All
		StringReplace,_tmp,_tmp,**, % chr(3),All
		StringReplace,_tmp,_tmp,\[, % chr(4),All
		StringReplace,_tmp,_tmp,\], % chr(5),All
		StringReplace,_tmp,_tmp,\?, % chr(6),All
		StringReplace,_tmp,_tmp,?, % chr(7),All
		
		;Normal "escapes", because not in Glob specs
		static _ := ".^$(){}|+"
		Loop, Parse, _
			StringReplace,_tmp,_tmp,%A_LoopField%,\%A_LoopField%,All
		
		StringReplace,_tmp,_tmp,[!,[^,All
		StringReplace,_tmp,_tmp,*,[^\\]+,All
		StringReplace,_tmp,_tmp, % chr(2) ,\\+.*\\*,All
		StringReplace,_tmp,_tmp, % chr(3) ,.*,All
		StringReplace,_tmp,_tmp, % chr(4) ,\[,All
		StringReplace,_tmp,_tmp, % chr(5) ,\],All
		StringReplace,_tmp,_tmp, % chr(7) ,.,All
		StringReplace,_tmp,_tmp, % chr(6) ,\?,All
		StringReplace,_tmp,_tmp, % chr(8) ,^,All
		
		patterns[each]:=_tmp
	}
	return patterns
}

Ignore_DirTree(dir,patterns)
{
	data := [], ldir := StrLen(dir)+1
	Loop, %dir%\*.*, 1
	{
		StringTrimLeft, name, A_LoopFileFullPath, %ldir%
		e := { name: name, fullPath: A_LoopFileLongPath }
		
		;quick-ignore the package metadata files
		if name in package.json,.aspdm_ignore
			continue
		
		;check attrib
		IfInString, A_LoopFileAttrib, D
			e.isDir := true
		
		;check ignores
		for j, pat in patterns
		{
			if j is not integer
				continue
			if (SubStr(pat,-1)=="\\") {
				if (e.isDir)
					StringTrimRight,pat,pat,2
				else
					continue
			}
			if RegExMatch(e.fullPath,"m)" pat "$") {
				; Start of confusing code
				for k, npat in patterns.negate
				{
					if (SubStr(npat,-1)=="\\") {
						if (e.isDir)
							StringTrimRight,npat,npat,2
						else
							continue
					}
					if RegExMatch(e.fullPath,"m)" npat "$") {
						break 2
					}
				}
				; End of confusing code
				continue 2
			}
		}
		
		;continue parsing inside directories
		if (e.isDir)
			e.contents := Ignore_DirTree(A_LoopFileFullPath,patterns)
		
		data.Insert(e)
	}
	return data
}