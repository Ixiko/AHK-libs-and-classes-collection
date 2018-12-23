#Include %A_ScriptDir%\..\..\classes\class_gdipChart.ahk
gosub, examples
class dataField {
	; requires gdipChart.ahk by nnnik, see https://github.com/nnnik/gdiChartLib or https://autohotkey.com/boards/viewtopic.php?f=6&t=31533
	; calculates the field, [x,y,w,h] which fits the data [[x1,f(x1),...,[xn,f(xn)]] for n points in the range [x1,x2] where x1<x2.
	; Input:
	; 	range, array defining the range of the x-axis, eg, [x1,x2] where x1<x2.
	; 	f, function or function name, takes (at least) one variable x.
	; 	n, number of points in the range [x1,x2] (inclusive) to evaluate.
	; 	color, argb, for preview.
	; Methods:
	;	preview([field,]dataFields*) - plot a preview of any number of dataFields, over the field field.
	;		field, [x,y,w,h], omit this parameter to fit the plot around the largest field.
	;		dataFields, objects derived from this class, eg, df:= new dataField(...)
	;
	; Example:
	;		df:=new dataField([-3,3],"sin")
	;		dataField.preview(df)
	field:=[]
	data:=[]
	; user methods
	__new(range,f,n:=100,color:=0xFF00FF00){
		this.field[1]:=range[1]
		this.minX:=range[1]
		this.maxX:=range[2]
		this.field[3]:=range[2]-range[1]
		x:=this.eqspace(range[1],range[2],n)
		this.data:=this.evalArr(x,f)
		this.color:=color
		this.init:=1
	}
	preview(dataFields*){
		
		Gui, New, hwndGUIHWND
		bounds:=dataFields[1]
		if bounds.init {
			for k, df in dataFields
				bounds:=dataField.fieldCmp(bounds,df)
			fitField:=[bounds.minX,bounds.minY,bounds.maxX-bounds.minX,bounds.maxY-bounds.minY]
		} else {
			fitField:=bounds,dataFields.removeat(1)
		}
		chart := new gdipChart( GUIHWND, "", fitField )
		chart.getAxes().setAttached(1)
		streams:=[]
		for k, df in dataFields {
			stream := chart.addDataStream( df.data, df.color )
			stream.setVisible()
			streams.push(stream)
		}
		chart.setVisible()
		Gui, % GUIHWND ": Show", w600 h400, % "data field preview"
		; Screenshot, handle yourself.
		chart.flushToFile( "Screenshots/Function Graph.png" )
		WinWaitClose, % "ahk_id " GUIHWND
		Gui % GUIHWND ": Destroy"
	}
	; Internal methods
	eqspace(a,b,n){	; create array of n equally spaced numbers between a and b (inclusive).
		t:=(b-a)/(n-1)
		e:=object(), e.SetCapacity(n)
		loop, % n
			e.push(a+(A_Index-1)*t) 
		return e
	}
	evalArr(arr,evalFunc) { ; evaluates each entry of arr using evalFunc, returns [[x,f(x)],...]
		f:=IsObject(evalFunc)?evalFunc:Func(evalFunc)
		fofx:=[], fofx.SetCapacity(arr.length())
		minY:=f.Call(arr[1])
		maxY:=f.Call(arr[1])
		for k, x in arr {
			y:=f.Call(x)
			if (y>maxY)
				maxY:=y
			else if (y<minY)
				minY:=y
			fofx.Push([x,y])
		}
		this.field[2]:=minY
		this.field[4]:=maxY-minY
		this.minY:=minY
		this.maxY:=maxY
		return fofx
	}
	fieldCmp(f1,f2){	; for auto fit field
		minX:=dataField.min(f1.minX,f2.minX)
		maxX:=dataField.max(f1.maxX,f2.maxX)
		minY:=dataField.min(f1.minY,f2.minY)
		maxY:=dataField.max(f1.maxY,f2.maxY)
		return {minX:minX,minY:minY,maxX:maxX,maxY:maxY}
	}
	max(x,y){
		return (x>y)*x+(y>=x)*y
	}
	min(x,y){
		return (x<y)*x+(y<=x)*y
	}
}
return
; Example usage.
; Example sin
examples:
df1:= new dataField([-3.14*2,3.14*2],"sin",200,0xFF00FF00)
df2:= new dataField([-3.14*2,3.14*2],"cos",200,0xFFFF0000)
dataField.preview(df1,df2)

; Example, maclaurin polynoms for sin
df:=[]
gosub, getColor
Loop, % col.length()
	df.Push(new dataField([-6,6],Func("pnSin").Bind(A_Index),200, "0xff" col[a_index])) ; "0xff" . fire[A_Index]
dataField.preview([-6,-2,12,4],df*)
ExitApp
getColor:
; Color credits; tidit: https://github.com/acorns/Particle-System/blob/master/GUI-Toy.ahk
;col:=["FF0000","F71507","F02B0F","E94116","E2571E","E96116","F06B0F","F77507","FF7F00","FFA900","FFD400","FFFF00","AAFF00","55FF00","00FF00","00AA55","0055AA","0000FF","2E00FF","5C00FF","8B00FF"]
;col:=["783FCD","693FC5","5A40BE","4B41B6","3D42AF","2E43A7","1F44A0","114599","1E449F","2C43A6","3942AD","4741B4","5440BB","623FC2","703FC9"]
;col:=["FF0000","FF003F","FF007F","FF00BF","FF00FF","BF00FF","7F00FF","3F00FF","0000FF","0055FF","00AAFF","00FFFF","00FFAA","00FF55","00FF00","55FF00","AAFF00","FFFF00","FFAA00","FF5500","FF0000"]
col:=["FFBC00","FFA800","FF9300","FF7E00","FF6900","FF5500","FFBC00","FFA800","FF9300","FF7E00","FF6900","FF5500"] ; fire (modified)
return

; help functions for preview example
pnSin(n,x){ ; Maclaurin polynoms for sin
	s:=0
	loop, % n
		i:=A_Index, s+=(-1)**(i-1)*x**(2*i-1)/factorial(2*i-1)
	return s
}
pnCos(n,x){ ; Maclaurin polynoms for cos (use auto for the field)
	s:=0
	loop, % n
		i:=A_Index, s+=(-1)**(i)*x**(2*i)/factorial(2*i)
	return s
}
factorial(x){
	f:=1
	loop, % x-1
		f*=x-(A_Index-1)
	return f
}
