Class Linear extends Lib.obj.Array.Generic{
		Clone(Arr*)	{
				For i, sArr in Arr {
					tOut:=Array()
					For index,value in sArr
						if(!Lib.obj.isMetaInfo(index,value))
							tOut.push(value)
					Arr[i]:=tOut
				}
				return this.Helper.Return_format(Arr)
		}
		join(delim:=",",Arr*) {
			this.Helper.Default_Param(Arr,",",delim)
			For i,sArr in Arr {
				For si,Val in sArr
					Out.=delim (isobject(Val)?Lib.Obj.Array.ToString(Val):Val)
				Arr[i]:=SubStr(Out,StrLen(delim) + 1), Out:=""
			}
			return this.Helper.Return_format(Arr)
		}
		/*
			trim_instruction:
				1 - Remove at beginning of array
				0 - remove value at end of array
				an array of instructions can be input and they will be cycled through
		*/
		Trim(trim_instruction,size,Arr*)	{ ;Needs updated so trim_instruction uses CSV
			if(!isobject(trim_instruction))
				trim_instruction:=[trim_instruction,trim_instruction]
			For i,sArr in Arr {
				increment:=1
				if(this.Length(sArr) > size)
					While(this.Length(sArr) > size)		{
						inst_num:=Mod(increment,trim_instruction.length()) + 1
						increment++
						if(trim_instruction[inst_num] == 1)
							remval:=sArr.RemoveAt(1)
						else
							remval:=sArr.pop()
						if(Lib.obj.isMetaInfo(remval))		{
							Random rando, 1, % sArr.Length()
							sArr.InsertAt(rando,remval)
						}
					}
				Arr[i]:=sArr
			}
			return this.Helper.Return_format(Arr)
		}
		Split(Split_Index, Arr*) {
			Arr.push("")
			Arr:=this.Clone(Arr*)
			Arr.pop()
			For i,sArr in Arr	{
				Arr[i]:=[sArr.clone(),sArr.Clone()]
				Arr[i][1].removeAt(Split_Index,sArr.Length())
				Arr[i][2].removeAt(1,Split_Index - 1)
			}
			return this.Helper.Return_format(Arr)
		}
		Length(Arr*)		{
			For i,sArr in Arr {
				length:=0
				For index,value in sArr
					if(!Lib.obj.isMetaInfo(index,value))
						length++
				Arr[i]:=Length
			}
			return this.Helper.Return_format(Arr)
		}
		removeAll(value, Arr*)		{
			For i,sArr in Arr		{
				rval_index:=""
				Loop % sArr.length()
					if(sArr[A_Index] == value)
						rval_index.="|" A_Index
				StringTrimLeft, Purge,Purge,1
				Sort rval_index, N R D|
				Loop, Parse, rval_index ,|
					Arr[i].removeAt(A_LoopField)
			}
			return this.Helper.Return_format(Arr)
		}
		toString(Arr*){
			for i,sArr in Arr	{
				Loop % sArr.length()
					if(!Lib.obj.isMetaInfo(A_Index,sArr[A_Index]))
						sOut.= ", " Lib.Obj.Array.toString(sArr[A_Index])
				StringTrimLeft,sOut,sOut,1
				Arr[i]:="[" sOut "]"
			}
			return this.Helper.Return_format(Arr)
		}
	}