;
; AutoHotkey Version: 1.1.30.00
; Language:       English
; Platform:       Optimized for Windows 10
; Author:         Sam.
;

;;;;;	Reference Documents	;;;;;
; http://www.leptonica.com/color-quantization.html
; https://www.codeproject.com/Articles/66341/A-Simple-Yet-Quite-Powerful-Palette-Quantizer-in-C
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;  PS_Quantization v0.0.01a ;;;;;
;;;;;  Copyright (c) 2018 Sam.  ;;;;;
;;;;;   Last Updated 20180925   ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;  Note to self:  More realistic option for minimum error is to simply take most populous X colors.
;		Won't be theoretical minimum error, but in that direction.  Posternization is expected to be severe.
;		Alternatively (more computation but still reasonable) is to sort colors by some criteria; avg, longest side, 
;			most populous side, etc and then find minimum distance from each color to the one above and below.
;			Avg those colors and repeat.  Possibly resort every so often.  Results likely dependent on sort criteria.
;			Again, minimum error expected to cause severe posternization.


Class PS_Quantization{
	__New(){
		this.Reserved:={}
		this.Pool:={}
		this.MedianPixelFactor:=0.5		; Recommended value: 0.5
		this.BoxDivisionFactor:=0.6		; Recommended value btwn 0.3 and 0.9
		this.RedPriorityFactor:=1		; Recommended value: 1
		this.GreenPriorityFactor:=1		; Recommended value: 1
		this.BluePriorityFactor:=1		; Recommended value: 1
		this.AlphaPriorityFactor:=1		; Recommended value: 1
		}
	GetReservedColorCount(){
		Return NumGet(&this.Reserved + 4*A_PtrSize)
	}
	GetPoolColorCount(){
		Return NumGet(&this.Pool + 4*A_PtrSize)
	}
	GetColorCount(){
		Return (this.GetReservedColorCount()+this.GetPoolColorCount())
	}
	GetTotalError(){
		;tic:=QPC(1)
		Error:=0
		For Key, Val in this.Reserved
			Error+=this.Reserved[Key,"Error"]*this.Reserved[Key,"Count"]
		For Key, Val in this.Pool
			Error+=this.Pool[Key,"Error"]*this.Pool[Key,"Count"]
		;Console.Send("Total Error calculated in " (QPC(1)-tic) " sec.`r`n","-I")
		Return Error
	}
	AddReservedColor(R:=0,G:=0,B:=0,A:=0){	; To have non-reserved and reserved colors that are the same, add reserved colors last.
		Key:=this._FormatHash(R,G,B,A)
		If this.Reserved.HasKey(Key)
			this.Reserved[Key,"Count"]+=1
		Else
			{
			this.Reserved[Key,"Idx"]:=this.GetReservedColorCount()+1
			this.Reserved[Key,"RR"]:=R
			this.Reserved[Key,"GG"]:=G
			this.Reserved[Key,"BB"]:=B
			this.Reserved[Key,"AA"]:=A
			this.Reserved[Key,"Count"]:=1
			}
	}
	AddColor(R:=0,G:=0,B:=0,A:=0){
		Key:=this._FormatHash(R,G,B,A)
		If this.Reserved.HasKey(Key)
			this.Reserved[Key,"Count"]+=1
		Else If this.Pool.HasKey(Key)
			this.Pool[Key,"Count"]+=1
		Else
			{
			this.Pool[Key,"RR"]:=R
			this.Pool[Key,"GG"]:=G
			this.Pool[Key,"BB"]:=B
			this.Pool[Key,"AA"]:=A
			this.Pool[Key,"Count"]:=1
			}
	}
	QuantHasColor(R:=0,G:=0,B:=0,A:=0){
		; Returns 1 for yes Reserved Color, 2 for yes non-Reserved color, 0 for color not in quant
		Key:=this._FormatHash(R,G,B,A)
		If this.Reserved.HasKey(Key)
			Return 1
		If this.Pool.HasKey(Key)
			Return 2
		Return 0
	}
	_InitializeBoxes(){
		this.Boxes:="",this.Boxes:={}
		For Key, Val in this.Reserved
			{
			Idx:=this.Reserved[Key,"Idx"]
			this.Boxes[Idx,1,"RR"]:=this.Reserved[Key,"RR"]
			this.Boxes[Idx,1,"GG"]:=this.Reserved[Key,"GG"]
			this.Boxes[Idx,1,"BB"]:=this.Reserved[Key,"BB"]
			this.Boxes[Idx,1,"AA"]:=this.Reserved[Key,"AA"]
			this._CalcPopulation(this.Boxes[Idx])
			this._CalcVolume(this.Boxes[Idx])
			}
		Idx:=this.Boxes.Length()+1
		For Key, Val in this.Pool
			{
			this.Boxes[Idx,A_Index,"RR"]:=this.Pool[Key,"RR"]
			this.Boxes[Idx,A_Index,"GG"]:=this.Pool[Key,"GG"]
			this.Boxes[Idx,A_Index,"BB"]:=this.Pool[Key,"BB"]
			this.Boxes[Idx,A_Index,"AA"]:=this.Pool[Key,"AA"]
			}
	}
	_InitializeBoxesAsPaletteObj(){
		this.Boxes:="",this.Boxes:={}
		For Key, Val in this.Reserved
			{
			Idx:=this.Reserved[Key,"Idx"]
			this.Boxes[Idx,"RR"]:=this.Reserved[Key,"RR"]
			this.Boxes[Idx,"GG"]:=this.Reserved[Key,"GG"]
			this.Boxes[Idx,"BB"]:=this.Reserved[Key,"BB"]
			this.Boxes[Idx,"AA"]:=this.Reserved[Key,"AA"]
			}
		Idx:=this.Boxes.Length()+1
		For Key, Val in this.Pool
			{
			this.Boxes[Idx,"RR"]:=this.Pool[Key,"RR"]
			this.Boxes[Idx,"GG"]:=this.Pool[Key,"GG"]
			this.Boxes[Idx,"BB"]:=this.Pool[Key,"BB"]
			this.Boxes[Idx,"AA"]:=this.Pool[Key,"AA"]
			Idx++
			}
	}
	_AverageBoxes(){	; Now uses weighted average
		Loop, % this.Boxes.Length()
			{
			Idx:=A_Index
			Len:=this.Boxes[Idx].Length()
			;If (Len>1)
				;{
				R:=G:=B:=A:=pCount:=0
				Loop, % this.Boxes[Idx].Length()
					{
					Pop:=this._GetPopulation(this.Boxes[Idx,A_Index])
					R+=this.Boxes[Idx,A_Index,"RR"]*Pop
					G+=this.Boxes[Idx,A_Index,"GG"]*Pop
					B+=this.Boxes[Idx,A_Index,"BB"]*Pop
					A+=this.Boxes[Idx,A_Index,"AA"]*Pop
					pCount+=Pop
					}
				this.Boxes[Idx]:="", this.Boxes[Idx]:={}
				this.Boxes[Idx,"RR"]:=Round(R/pCount)
				this.Boxes[Idx,"GG"]:=Round(G/pCount)
				this.Boxes[Idx,"BB"]:=Round(B/pCount)
				this.Boxes[Idx,"AA"]:=Round(A/pCount)
				;this.Boxes[Idx].RemoveAt(2,Len-1)	; Remove the colors that have been averaged
				;}
			}
	}
	_SortBox(ByRef Obj){
		;;;;;	_CalcLargestDimension() MUST be called before this function	;;;;;
		q_sort(Obj,this._tmp_DimToSplit)
	}
	_CalcPopulation(ByRef Obj){
		Pop:=0
		Loop, % Obj.Length()
			{
			Key:=this._FormatHash(Obj[A_Index,"RR"],Obj[A_Index,"GG"],Obj[A_Index,"BB"],Obj[A_Index,"AA"])
			If this.Reserved.HasKey(Key)
				Pop+=this.Reserved[Key,"Count"]
			If this.Pool.HasKey(Key)
				Pop+=this.Pool[Key,"Count"]
			}
		Obj.Population:=Pop
	}
	_GetPopulation(ByRef Obj){
		Pop:=0
		Key:=this._FormatHash(Obj["RR"],Obj["GG"],Obj["BB"],Obj["AA"])
		If this.Reserved.HasKey(Key)
			Pop+=this.Reserved[Key,"Count"]
		If this.Pool.HasKey(Key)
			Pop+=this.Pool[Key,"Count"]
		Return Pop
	}
	_CalcVolume(ByRef Obj){
		RMin:=GMin:=BMin:=AMin:=255
		RMax:=GMax:=BMax:=AMax:=0
		Loop, % Obj.Length()
			{
			RMin:=(Obj[A_Index,"RR"]<RMin?Obj[A_Index,"RR"]:RMin), RMax:=(Obj[A_Index,"RR"]>RMax?Obj[A_Index,"RR"]:RMax)
			GMin:=(Obj[A_Index,"GG"]<GMin?Obj[A_Index,"GG"]:GMin), GMax:=(Obj[A_Index,"GG"]>GMax?Obj[A_Index,"GG"]:GMax)
			BMin:=(Obj[A_Index,"BB"]<BMin?Obj[A_Index,"BB"]:BMin), BMax:=(Obj[A_Index,"BB"]>BMax?Obj[A_Index,"BB"]:BMax)
			AMin:=(Obj[A_Index,"AA"]<AMin?Obj[A_Index,"AA"]:AMin), AMax:=(Obj[A_Index,"AA"]>AMax?Obj[A_Index,"AA"]:AMax)
			}
		Obj.Volume:=(RMax-RMin=0?1:RMax-RMin)*(GMax-GMin=0?1:GMax-GMin)*(BMax-BMin=0?1:BMax-BMin)*(AMax-AMin=0?1:AMax-AMin)
	}
	_CalcLargestDimension(ByRef Obj,Rf:=1,Gf:=1,Bf:=1,Af:=1){
		RMin:=GMin:=BMin:=AMin:=255
		RMax:=GMax:=BMax:=AMax:=0
		Loop, % Obj.Length()
			{
			RMin:=(Obj[A_Index,"RR"]<RMin?Obj[A_Index,"RR"]:RMin), RMax:=(Obj[A_Index,"RR"]>RMax?Obj[A_Index,"RR"]:RMax)
			GMin:=(Obj[A_Index,"GG"]<GMin?Obj[A_Index,"GG"]:GMin), GMax:=(Obj[A_Index,"GG"]>GMax?Obj[A_Index,"GG"]:GMax)
			BMin:=(Obj[A_Index,"BB"]<BMin?Obj[A_Index,"BB"]:BMin), BMax:=(Obj[A_Index,"BB"]>BMax?Obj[A_Index,"BB"]:BMax)
			AMin:=(Obj[A_Index,"AA"]<AMin?Obj[A_Index,"AA"]:AMin), AMax:=(Obj[A_Index,"AA"]>AMax?Obj[A_Index,"AA"]:AMax)
			}
		R:=this.RedPriorityFactor*(RMax-RMin), G:=this.GreenPriorityFactor*(GMax-GMin), B:=this.BluePriorityFactor*(BMax-BMin), A:=this.AlphaPriorityFactor*(AMax-AMin)
		Largest:=R, Dim:="RR"
		If (G>Largest)
			{
			Largest:=G, Dim:="GG"
			}
		If (B>Largest)
			{
			Largest:=B, Dim:="BB"
			}
		If (A>Largest)
			{
			Dim:="AA"
			}
		this._tmp_DimToSplit:=Dim
	}
	_CalcMedianPixel(ByRef Obj){
		f:=this.MedianPixelFactor
		VarSetCapacity(Str,Obj["Population"]*6)
		Loop, % Obj.Length()
			{
			Idx:=A_Index
			Loop, % this._GetPopulation(Obj[Idx])
				Str.=Idx ","
			}
		Sort, Str, ND,
		Array:=StrSplit(Str,",")
		Val:=Array[Round(Array.Length()*f)]
		Return (Val=Obj.Length()?Val-1:Val)
	}
	_CalcMiddleColor(ByRef Obj,Dim:="RR"){
		;;;;;	Since it has already been sorted	;;;;;
		;Median:=Round((Obj[Obj.MaxIndex(),Dim]+Obj[Obj.MinIndex(),Dim])/2)
		Median:=(Obj[Obj.MaxIndex(),Dim]+Obj[Obj.MinIndex(),Dim])/2
		Loop, % Obj.Length()
			{
			If (Obj[A_Index,Dim]>Median)
				Return (A_Index-1)
			}
		Return 1
	}
	_FindNextBoxToSplit(CountOfPaletteEntries){
		f:=this.BoxDivisionFactor
		Pop:=0	; Population
		If (this.Boxes.Length()<=CountOfPaletteEntries*f)	; Population only
			{
			Next:=""
			Loop, % this.Boxes.Length()
				{
				If (this.Boxes[A_Index].Length()>1) AND (this.Boxes[A_Index,"Population"]>Pop)
					{
					Pop:=this.Boxes[A_Index,"Population"]
					Next:=A_Index
					}
				}
			}
		Else	; Population * Volume
			{
			Next:=""
			Loop, % this.Boxes.Length()
				{
				pv:=this.Boxes[A_Index,"Population"]*this.Boxes[A_Index,"Volume"]
				If (this.Boxes[A_Index].Length()>1) AND (pv>Pop)
					{
					Pop:=pv
					Next:=A_Index
					}
				}
			}
		Return Next
	}
	_SplitBox(Num){
		this._CalcLargestDimension(this.Boxes[Num])
		this._SortBox(this.Boxes[Num])
		;Median:=this._CalcMedianPixel(this.Boxes[Num])
		Median:=this._CalcMiddleColor(this.Boxes[Num],this._tmp_DimToSplit)	; Alternate to above line
		;~ Console.Send("Box " Num " which has " this.Boxes[Num].Length() " colors is being split into 2 boxes of ","I")
		
		tmp:={}, tmp.SetCapacity(Median)
		Loop, % Median
			tmp.Push(this.Boxes[Num,A_Index])
		this.Boxes.InsertAt(Num,tmp)
		this.Boxes[Num+1].RemoveAt(1,Median)
		
		this._CalcPopulation(this.Boxes[Num])
		this._CalcPopulation(this.Boxes[Num+1])
		;;;;; Begin modification to median cut	;;;;;
		;tic:=QPC(1)
		If (this.Boxes[Num].Length()>1) AND (this.Boxes[Num,"Population"]>this.Boxes[Num+1,"Population"])
			{
			;Median:=this._CalcMedianPixel(this.Boxes[Num])
			Median:=this._CalcMiddleColor(this.Boxes[Num],this._tmp_DimToSplit)
			If (Median=this.Boxes[Num].MaxIndex())
				Median--
			tmp:="", tmp:={}, tmp.SetCapacity(this.Boxes[Num].Length()-Median)
			Loop, % this.Boxes[Num].Length()-Median
				tmp.Push(this.Boxes[Num,Median+A_Index])
			this.Boxes[Num].RemoveAt(Median+1,this.Boxes[Num].Length()-Median)
			this.Boxes[Num+1].InsertAt(1,tmp*)
			this._CalcPopulation(this.Boxes[Num])
			this._CalcPopulation(this.Boxes[Num+1])
			}
		Else If (this.Boxes[Num+1].Length()>1) AND (this.Boxes[Num+1,"Population"]>this.Boxes[Num,"Population"])
			{
			;Median:=this._CalcMedianPixel(this.Boxes[Num+1])
			Median:=this._CalcMiddleColor(this.Boxes[Num+1],this._tmp_DimToSplit)
			If (Median=this.Boxes[Num+1].MaxIndex())
				Median--
			tmp:="", tmp:={}, tmp.SetCapacity(Median)
			Loop, % Median
				tmp.Push(this.Boxes[Num+1,A_Index])
			this.Boxes[Num].Push(tmp*)
			this.Boxes[Num+1].RemoveAt(1,Median)
			this._CalcPopulation(this.Boxes[Num])
			this._CalcPopulation(this.Boxes[Num+1])
			}
		this._CalcVolume(this.Boxes[Num])
		this._CalcVolume(this.Boxes[Num+1])
		;Console.Send("Modification to Median Cut took " (QPC(1)-tic) " sec.`r`n","-I")
		;~ Console.Send(this.Boxes[Num].Length() " and " this.Boxes[Num+1].Length() " colors.`r`n")
	}
	_SplitBoxRev2(Num){
		this._CalcLargestDimension(this.Boxes[Num])
		this._SortBox(this.Boxes[Num])
		Median:=this._CalcMedianPixel(this.Boxes[Num])
		;~ Console.Send("Box " Num " which has " this.Boxes[Num].Length() " colors is being split ","I")
		Count:=this.Boxes[Num].Length()
		Dim:=this._tmp_DimToSplit
		If (Count>2)
			{
			Left:=this.Boxes[Num,Median,Dim]-this.Boxes[Num,1,Dim]
			Right:=this.Boxes[Num,Count,Dim]-this.Boxes[Num,Median,Dim]
			If (Left<=Right)
				{
				MedianR:=(this.Boxes[Num,Count,Dim]+this.Boxes[Num,Median,Dim])/2
				Loop, % Count-Median
					{
					Idx:=Median+A_Index
					If (this.Boxes[Num,Idx,Dim]>MedianR)
						{
						Median:=Idx-1
						Break
						}
					}
				}
			Else
				{
				MedianL:=(this.Boxes[Num,1,Dim]+this.Boxes[Num,Median,Dim])/2
				Loop, % Median
					{
					If (this.Boxes[Num,A_Index,Dim]>MedianL)
						{
						Median:=A_Index-1
						Break
						}
					}
				}
			}
		;~ Console.Send("at color " Median " ")
		tmp:={}, tmp.SetCapacity(Median)
		Loop, % Median
			tmp.Push(this.Boxes[Num,A_Index])
		this.Boxes.InsertAt(Num,tmp)
		this.Boxes[Num+1].RemoveAt(1,Median)
		
		this._CalcPopulation(this.Boxes[Num])
		this._CalcPopulation(this.Boxes[Num+1])
		this._CalcVolume(this.Boxes[Num])
		this._CalcVolume(this.Boxes[Num+1])
		;~ Console.Send("into 2 boxes of " this.Boxes[Num].Length() " and " this.Boxes[Num+1].Length() " colors.`r`n")
	}
	_FormatHashTable(){
		For key, val in this.Pool
			{
			Dist:=0xFFFFFFFE ;0xFFFFFFFFFFFFFFF0
			Idx:=0
			Loop, % this.Boxes.Length()
				{
				If (A_Index<=this.GetReservedColorCount())	; Do not remap non-reserved colors to reserved colors
					Continue
				nDist:=(this.Boxes[A_Index,"RR"]-this.Pool[key,"RR"])**2+(this.Boxes[A_Index,"GG"]-this.Pool[key,"GG"])**2+(this.Boxes[A_Index,"BB"]-this.Pool[key,"BB"])**2+(this.Boxes[A_Index,"AA"]-this.Pool[key,"AA"])**2
				;Console.Send("Distance from this.Pool[" key "] to this.Boxes[" A_Index "] is " nDist ".`r`n","I")
				;~ If (nDist="")
					;~ Pause
				If (nDist<Dist)
					{
					Dist:=nDist
					Idx:=A_Index
					If (Dist=0)
						Break
					}
				}
			this.Pool[key,"Index"]:=Idx-1
			this.Pool[key,"Error"]:=Sqrt(Dist)
			}
		For key, val in this.Reserved
			{
			Dist:=0xFFFFFFFE ;0xFFFFFFFFFFFFFFF0
			Idx:=0
			Loop, % this.Boxes.Length()
				{
				nDist:=(this.Boxes[A_Index,"RR"]-this.Reserved[key,"RR"])**2+(this.Boxes[A_Index,"GG"]-this.Reserved[key,"GG"])**2+(this.Boxes[A_Index,"BB"]-this.Reserved[key,"BB"])**2+(this.Boxes[A_Index,"AA"]-this.Reserved[key,"AA"])**2
				If (nDist<Dist)
					{
					Dist:=nDist
					Idx:=A_Index
					If (Dist=0)
						Break
					}
				}
			this.Reserved[key,"Index"]:=Idx-1
			this.Reserved[key,"Error"]:=Sqrt(Dist)
			}
	}
	Quantize(CountOfPaletteEntries){
		If (this.GetReservedColorCount()+this.GetPoolColorCount()<=CountOfPaletteEntries)	;;;;;	Skip quantization if there are less total colors than we need.
			{
			this._InitializeBoxesAsPaletteObj()
			this._FormatHashTable()
			Return	; We are done
			}
		this._InitializeBoxes()
		If (this.Boxes.Length()=CountOfPaletteEntries)
			{
			this._AverageBoxes()
			this._FormatHashTable()
			Return	; We are done
			}
		Else If (this.Boxes.Length()>CountOfPaletteEntries)	; Too Many Boxes
			{
			this.Boxes.RemoveAt(CountOfPaletteEntries+1,this.Boxes.Length()-CountOfPaletteEntries)
			this._AverageBoxes()
			this._FormatHashTable()
			Return	; We are done
			}
		;;;;;	Begin actual median cut splits	;;;;;
		;Next:=this._FindNextBoxToSplit(CountOfPaletteEntries)
		Next:=(this.Boxes.HasKey(this.GetReservedColorCount()+1)?this.GetReservedColorCount()+1:"")
		While Next AND (this.Boxes.Length()<CountOfPaletteEntries)
			{
			this._SplitBox(Next)
			;this._SplitBoxRev2(Next)
			Next:=this._FindNextBoxToSplit(CountOfPaletteEntries)
			}
		this._AverageBoxes()
		this._FormatHashTable()
	}
	
	GetQuantizedColorIndex(R:=0,G:=0,B:=0,A:=0){
		Key:=this._FormatHash(R,G,B,A)
		If this.Reserved.HasKey(Key)
			Return this.Reserved[Key,"Index"]
		Else If this.Pool.HasKey(Key)
			Return this.Pool[Key,"Index"]
		Else	; Calc dist to nearest quantized value instead of returning 0
			{
			Dist:=0xFFFFFFFE ;0xFFFFFFFFFFFFFFF0
			Idx:=0
			Loop, % this.Boxes.Length()
				{
				nDist:=(this.Boxes[A_Index,"RR"]-R)**2+(this.Boxes[A_Index,"GG"]-G)**2+(this.Boxes[A_Index,"BB"]-B)**2+(this.Boxes[A_Index,"AA"]-A)**2
				If (nDist<Dist)
					{
					Dist:=nDist
					Idx:=A_Index
					If (Dist=0)
						Break
					}
				}
			; Add value to Pool to save on future look-up calculations.  New value will not be mixed into quantized palette unless you run Quantize() again.
			this.AddColor(R,G,B,A)
			this.Pool[Key,"Index"]:=Idx-1
			this.Pool[Key,"Error"]:=Sqrt(Dist)
			Return Idx-1
			}
	}
	
	GetPaletteSize(Format:="Raw", BitsPerChannel:=8, CountOfPaletteEntries:=256){
		If (Format="Raw")
			Return (CountOfPaletteEntries*4*Ceil(BitsPerChannel/8))
		Return -1
	}
	
	GetPaletteRaw(Address, Size, ColorFormat:="BGRA", BitsPerChannel:=8, CountOfPaletteEntries:=256){
		Bytes:={8: "UChar", 16: "UShort", 32: "UInt", 64: "Int64"}
		NumBytes:=(Bytes[BitsPerChannel]=""?"UChar":Bytes[BitsPerChannel])
		;this.Quantize(CountOfPaletteEntries)
		Fmt:={}
		Fmt[InStr(ColorFormat,"R")]:="RR", Fmt[InStr(ColorFormat,"G")]:="GG", Fmt[InStr(ColorFormat,"B")]:="BB", Fmt[InStr(ColorFormat,"A")]:="AA"
		hPal:=New MemoryFileIO(Address,Size)
		hPal.Seek(0,0)
		Loop, % this.Boxes.Length()
			{
			If Fmt.HasKey(1)
				hPal["Write" NumBytes](this.Boxes[A_Index,Fmt[1]])
			If Fmt.HasKey(2)
				hPal["Write" NumBytes](this.Boxes[A_Index,Fmt[2]])
			If Fmt.HasKey(3)
				hPal["Write" NumBytes](this.Boxes[A_Index,Fmt[3]])
			If Fmt.HasKey(4)
				hPal["Write" NumBytes](this.Boxes[A_Index,Fmt[4]])
			If (A_Index=CountOfPaletteEntries)
				Break
			}
		hPal:=""
	}
	
	GetPaletteObj(MinCountOfPaletteEntries:=""){
		PalObj:=ObjFullyClone(this.Boxes)
		PalObj.RemoveAt(0,1)
		If MinCountOfPaletteEntries AND (PalObj.Count()<MinCountOfPaletteEntries)
			{
			Loop, % MinCountOfPaletteEntries-PalObj.Count()
				{
				Idx:=PalObj.Count()
				PalObj[Idx,"RR"]:=PalObj[Idx,"GG"]:=PalObj[Idx,"BB"]:=PalObj[Idx,"AA"]:=0
				}
			}
		Return PalObj
	}
	
	_FormatHash(r:=0,g:=0,b:=0,a:=0){
		Return "#" ((r&0xFF)<<24)|((g&0xFF)<<16)|((b&0xFF)<<8)|(a&0xFF)
	}
}


/*
QPC(R:=0){ ; By SKAN, http://goo.gl/nf7O4G, CD:01/Sep/2014 | MD:01/Sep/2014
  Static P:=0, F:=0, Q:=DllCall("QueryPerformanceFrequency","Int64P",F)
  Return !DllCall("QueryPerformanceCounter","Int64P",Q)+(R?(P:=Q)/F:(Q-P)/F) 
}

st_printArr(array, depth=5, indentLevel=""){
	list:=""
   for k,v in Array
   {
      list.= indentLevel "[" k "]"
      if (IsObject(v) && depth>1)
         list.="`r`n" st_printArr(v, depth-1, indentLevel . "    ")
      Else
         list.=" => " v
      list.="`r`n"
   }
   return rtrim(list)
}

ObjFullyClone(obj){	; https://autohotkey.com/board/topic/103411-cloned-object-modifying-original-instantiation/?p=638500
    nobj:=ObjClone(obj)
    For k,v in nobj
        If IsObject(v)
            nobj[k]:=ObjFullyClone(v)
    Return nobj
}

#Include <PushLog>
#Include, lib
#Include, MemoryFileIO_v2.ahk
#Include, quick_sort_array_no_recursion.ahk
*/
