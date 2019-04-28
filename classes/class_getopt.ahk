;
; AutoHotkey Version: 1.1.22.04
; Language:       English
; Platform:       Optimized for Windows 7
; Author:         Sam.
;

/*
Instance:=New getopt("a:b",["alpha=","beta"],0)

	For key, val in Instance["opts"]	; Option(s)
		{
		option:=val[1], parameter:=val[2]
		If option in -a,--alpha
			MsgBox % option " = " parameter "`r`n"
		Else If option in -b,--beta
			MsgBox % option
		}
	
	Data:=""
	For key, val in Instance["args"]	; filename(s)
		Data.=key " = " val "`r`n"
	MsgBox % Data

Instance:=""

ExitApp
*/



/* Usage syntax is as follows:
 * Instance:=New getopt("a:b", ["alpha=", "beta"],0)
 * Arguments:=Instance["args"]
 * Options:=Instance["opts"]
 * Instance:=""
 */

Class getopt{	; Updated 20170124 by Sam.
	__New(shortopts:="", longopts:="", supportslash:=0){
		;~ try {
			this.args:=this.aGetArgs(), this.opts:=[], shortopts_:=StrSplit(shortopts,"",A_Space A_Tab "`r`n"), longopts:=(!IsObject(longopts)?[longopts]:longopts), this.supportslash:=supportslash
			While (this.args[0]>0) AND ((SubStr(this.args[1],1,1)="-") OR ((SubStr(this.args[1],1,1)="/") AND (supportslash=1)) OR ((SubStr(this.args[1],1,1)="\") AND (supportslash=1))) AND (this.args[1]<>"-") {
				If (this.args[1]="--"){	; "--" is a special operator that allows subsequent arguments to be treated as filenames, even if they start with a dash.
					this.args.Remove(1), this.args[0]-=1
					Break
					}
				If (SubStr(this.args[1],1,2)="--")
					this.do_longs(SubStr(this.args[1],3), longopts)
				Else If ((SubStr(this.args[1],1,1)="\") OR (SubStr(this.args[1],1,1)="/")) AND (supportslash=1)
					this.do_longs(SubStr(this.args[1],2), longopts, SubStr(this.args[1],1,1))
				Else
					this.do_shorts(SubStr(this.args[1],2), shortopts_)
				}
			this.args.Remove(0,"")	; Remove count of files stored in key[0] from this.args
			this.ConvertRealPaths()
		;~ } catch e {
			;~ this.ThrowMsg(16,"Error!","Exception thrown!`n`nWhat	=	" e.what "`nFile	=	" e.file "`nLine	=	" e.line "`nMessage	=	" e.message "`nExtra	=	" e.extra)
			;~ Return
		;~ }
	}
	
	do_longs(opt, longopts, opts_flag:="--"){
		this.args.Remove(1), this.args[0]-=1, i:=InStr(opt,"=")
		If (i=0)	; Current option does not have attached argument
			optarg:=""
		Else		; Pull attached argument out of current option
			optarg:=SubStr(opt,i+1), opt:=SubStr(opt,1,i-1)
		has_arg:=this.long_has_args(opt,longopts, opts_flag)
		If (has_arg){
			If (optarg=""){
				If (!this.args.MaxIndex())
					throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "option " opts_flag opt " requires argument", extra: ""}
				Else
					optarg:=this.args[1], this.args.Remove(1), this.args[0]-=1
				}
			}
		Else If (optarg<>"")
			throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "option " opts_flag opt " must not have an argument", extra: "argument given was: " optarg}
		this.opts[(this.opts.MaxIndex()=""?1:this.opts.MaxIndex()+1),1]:=opts_flag opt, this.opts[this.opts.MaxIndex(),2]:=optarg
	}
	
	long_has_args(ByRef opt, longopts, opts_flag){
		possibilities:=[]
		For __key, __val in longopts
			If (InStr(__val,opt)=1)
				possibilities[(possibilities.MaxIndex()=""?1:possibilities.MaxIndex()+1)]:=__val
		If (!possibilities.MaxIndex())
			throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "option " opts_flag opt " not recognized", extra: ""}
		For __key, __val in possibilities	; Is there an exact match?
			{
			If (opt=__val)
				Return 0
			Else If (opt=RegExReplace(__val,"=$"))
				Return 1
			}
		If (possibilities.MaxIndex()>1)	; No exact match, so better be unique.
			throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "option " opts_flag opt " not a unique prefix", extra: ""}
		unique_match:=possibilities[1], has_arg:=(InStr(unique_match,"=",0,0)?1:0), unique_match:=(has_arg?RegExReplace(__val,"=$"):unique_match), opt:=unique_match
		Return has_arg
	}

	do_shorts(optstring, shortopts){
		this.args.Remove(1), this.args[0]-=1
		While (optstring<>""){
			opt:=SubStr(optstring,1,1), optstring:=SubStr(optstring,2)
			If (this.short_has_arg(opt, shortopts)){
				If (optstring=""){
					If (!this.args.MaxIndex())
						throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "option -" opt " requires argument", extra: ""}
					Else
						optstring:=this.args[1], this.args.Remove(1), this.args[0]-=1
					}
				optarg:=optstring, optstring:=""
				}
			Else
				optarg:=""
			this.opts[(this.opts.MaxIndex()=""?1:this.opts.MaxIndex()+1),1]:="-" opt, this.opts[this.opts.MaxIndex(),2]:=optarg
			}
	}

	short_has_arg(opt, shortopts){
		For __key, __val in shortopts {
			If (opt=__val) AND (__val<>":")
				Return ((shortopts[__key+1]=":"?1:0))
			}
		throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "option -" opt " not recognized", extra: ""}
	}

	ConvertRealPaths(){	; Converts existing files in "args" to long path from 8.3 (on drag&drop)
		Expanded:={}
		For __key, __val in this["args"]
			{
			If InStr(__val,"*")
				{
				Loop, %__val%, 1, 0
					Expanded.Push(A_LoopFileLongPath)
				}
			Else
				{
				IfExist, %__val%
					{
					Loop, %__val%, 1, 0
						{
						Expanded.Push(A_LoopFileLongPath)
						Break
						}
					}
				}
			}
		this.args:=Expanded
	}
	
	aGetArgs(bAll:=False){ ; http://ahkscript.org/boards/viewtopic.php?p=34892#p34892
		/*
		Based on code By SKAN,  http://goo.gl/JfMNpN,  CD:23/Aug/2014 | MD:24/Aug/2014
		Modified by:  Dougal 17Jan15 | Sam. 20Aug15
		Returns array of strings, element 0 contains array count
		Includes commandline parts if bAll = true
		Otherwise strips non-parameter parts depending on how it was called:
			Compiled script
				removes compiled script name
			Script
				removes AutoHotkey executable and script name
			SciTe4AutoHotkey
				removes AutoHotkey executable, /ErrorStdOut parameter (if present) and script name
		*/
		sCmdLine:=DllCall("GetCommandLine","Str"), pArgs:=0, nArgs:=0, aArgs:=[], pArgs:=DllCall( "Shell32\CommandLineToArgvW","WStr",sCmdLine,"PtrP",nArgs,"Ptr")
		Loop % (nArgs)						; get command line parts from memory
				aArgs.insert(StrGet(NumGet((A_Index-1)*A_PtrSize+pArgs),"UTF-16"))
		If (!bAll) { 						; remove calling program parts
			If (!A_IsCompiled)
				aArgs.remove(1), nArgs-=1	; remove AutoHotkey.exe if not compiled script
			If (aArgs[1]="/ErrorStdOut")
				aArgs.remove(1), nArgs-=1	; remove /ErrorStdOut (run within SciTE4AutoHotkey)
			aArgs.remove(1), nArgs-=1		; remove (compiled) script name
		}
		aArgs[0]:=nArgs
		DllCall("LocalFree","Ptr",pArgs)
		Return, aArgs
	}

	ThrowMsg(Options="",Title="",Text="",Timeout=""){
		Gui +OwnDialogs
		MsgBox, % Options , % Title , % Text , % Timeout
	}
}