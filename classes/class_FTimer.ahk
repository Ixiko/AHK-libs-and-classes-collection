; https://www.autohotkey.com/boards/viewtopic.php?f=28&t=4689&sid=f3aa50436be06d19d17c086dc44d9961

FTimer(Period,Func:="",params*){

	Static h:=[]
	if A_EventInfo && IsObject(f:=Object(A_EventInfo)) && !f.HasKey("End")	{

		if f.Times
			DllCall("KillTimer",UInt,0, PTR,f.ft)
		f.Tick.Insert(A_TickCount)
		f.Results.Insert(f.func.(f.params*))
		if f.Times
			h.Remove(&f,""),DllCall("GlobalFree", PTR,f.rc)

	}
	else	{

		if !Func		{
			b:=[]
			for i,n in h.Clone()
			(n.func=Period)?(n.Stop(1),b.Insert(n)):""
			return b
		}

		if IsFunc(Func)		{
			f := New FTimer(h,Period,Func,params)
			return f,h[&f]:=f
		}

	}
}


class FTimer {

	__New(Total, Period, Func, params) {
		this.Total   	:= Total
		this.func    	:= Func
		this.Period 	:= Period
		this.Priority	:= Priority
		this.params	:= params
		this.Times  	:= Period<0
		this.Tick     	:= [A_TickCount]
		this.Results	:= []
		this.rc        	:= RegisterCallback("FTimer","F",4,&this)
		this.ft        	:= DllCall("SetTimer", PTR,0, PTR,0, UInt,Abs(Period), PTR,this.rc, "PTR")
	}

	Stop(d:="") {

		this.Kill      	:= DllCall("KillTimer",UInt,0, PTR,this.ft)
		d ? this.__Delete() : ""

	}

	begin(Period:="",params*){
		DllCall("KillTimer", UInt,0, PTR, this.ft)
		params.MaxIndex()	? this.params:= params	                			:""
		Period	             		? this.Times	:= (this.Period:=Period)<0		:""
		this.Kill	:= ""
		this.ft	:= DllCall("SetTimer", PTR,0, PTR,0, UInt,Abs(this.Period),PTR,this.rc)
	}

	__Delete(){
		if !this.HasKey("End")
			this.Kill ? "" : DllCall("KillTimer",UInt,0, PTR,this.ft)
				,this.End := DllCall("GlobalFree", PTR,this.rc)
				,this.Total.Remove(&this,"")
	}

}