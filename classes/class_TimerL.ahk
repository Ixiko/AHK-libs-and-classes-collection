; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=28&t=4444
; Author:
; Date:
; for:     	AHK_L

/*


*/

;TimerL.ahk
;RobertL AHK8.com
;http://ahk8.com/thread-5384.html
;#include V2F.ahk	;当用V1运行时需包含此文件
class Timer{
	static lt:=0
	static q:=[]
	static s:=0
	static i:={}
	class T extends Timer{
		P(){
			_d:=this.d?this.d:this
			if(ObjHasKey(_d,"r"))
				throw Exception("仅可启动，不可再次暂停")
				_r:=0,_lt:=Timer.lt
			if(_lt>0)
				_lt:=A_TickCount-_lt
			_q:=Timer.q,_ta:=-_lt
			for _in,_to in _q{
				_ta+=_to.i
				if(_to=_d)
					break
			}
			_r:=_ta,_d.r:=_r,Timer.U(_d)
			return this
		}
		S(){
			_d:=this.d?this.d:this
			if !ObjHasKey(_d,"r") || (_d.r>0)
				Timer.U(_d)
			else if(_d.r=0)
				throw Exception("仅可启动，不可再次停止。")
			_d.r:=0
			return this
		}
		B(){
			_d:=this.d?this.d:this
			if(ObjHasKey(_d,"r")){
				if(_d.r)
					_t:=_d.t,_d.t:=_d.r
				Timer.R(_d)
				if(_d.r)
					_d.t:=_t,_d.r:=0
				ObjRemove(_d,"r")
			}
			return this
		}
	}
	class o{
		__Set(_k,_v){
			return base[_k]:=_v
		}
		__Delete(){
			Timer.U(this.d)
		}
	}
	C(m:=0){
		if(m=0 && Timer.s)
			throw Exception("运行中，不应存在重复启动")
		_q:=Timer.q
		if(m=2 ^ !(ObjLength(_q)>=1))
			throw Exception("启动了定时器，但队列为空/关闭了定时器，但队列非空")
		if(m=2)
			goto Timer_C
	Timer_B:
			_at:=Abs(_q[1].i),Timer.s:=1,Timer.lt:=A_TickCount
			SetTimer,Timer_M,%_at%,-1
			return
	Timer_M:
			_q:=Timer.q,_d:=ObjRemoveAt(_q,1),_m:=_d.m,_h:=_d.h
			if(_m=1)
				gosub %_h%
			else
				%_h%()
			_t:=_d.t
			if(_t>0)
				Timer.R(_d)
			else if(ObjLength(_q)=0)
				goto Timer_C
			goto Timer_B
	Timer_C:
			SetTimer,Timer_M,Off
			Timer.s:=0,Timer.lt:=0
			return
	}
	New(ByRef _i:="",ByRef _h:="",_t:=0){
		if not (_t+0!="")
			throw Exception("无效的参数。`n需要数值")
		_m:=0
		if IsLabel(_h){
			_m:=1
		}else if IsFunc(_h){
			if IsObject(_h)
				_m:=2
			else
				_m:=3
		}else
			throw Exception("无效的参数。`n需要标签名/函数对象/函数名。")
		_d:={t:_t,m:_m,h:_h,i:0,base:Timer.T},Timer.R(_d)
		if IsByRef(_i){
			if (_i!="")
				throw Exception("传入变量非空。`n需要空变量存储实例。")
			_b:=ObjClone(Timer.o),_b.d:=_d,_b.base:=_d,_i:={base:_b},ObjRawSet(_i,"base",Timer.T)
			return _i
		}else{
			_o:=Timer.i[_i],Timer.i[_i]:=_d
			if(_o)
				Timer.U(_o)
			return _d
		}
	}
	R(_d){
		if(!IsObject(_d) || _d.base!=Timer.T)
			throw Exception("参数错误。")
		_t:=_d.t,_lt:=Timer.lt
		if(_lt>0)
			_lt:=A_TickCount-_lt
		else if (Timer.s!=0)
			throw Exception("非预期的状态。")
		_q:=Timer.q,_at:=Abs(_t),_ib:=_ia:=0,_tb:=0,_ta:=-_lt
		for _in,_to in _q{
			_ta+=_to.i
			if(_ta<_at){
				_tb:=_ta,_ib:=_in
				continue
			}else{
				_ia:=_in
				break
			}
		}
		if(_tb<0)
			_tb:=0
		_d.i:=_at-_tb
		if(_ia)
			_q[_ia].i-=_d.i
		_ii:=_ib+1
		ObjInsertAt(_q,_ii,_d)
		if(!Timer.s)
			Timer.C()
	}
	U(_d){
		_q:=Timer.q,_l:=ObjLength(_q),_i:=0
		Loop % _l{
			if (_q[A_Index]=_d){
				if(!_i)
					_i:=A_Index
				else
					throw Exception("意外的逻辑。`n多标识对应同一数据对象！")
			}
		}
		if(_i){
			ObjRemoveAt(_q,_i+0)
			if(ObjHasKey(_q,_i)){
				_q[_i].i+=_d.i
				if(_i=1)
					_q[_i].i-=A_TickCount-Timer.lt,Timer.lt:=0,Timer.C(1)
			}else if(_l=1)
				Timer.C(2)
		}else if not ObjHasKey(_d,"r")
			throw Exception("意外的逻辑。`n未找到数据对象！")
		return
	}
}


;F2V.ahk
;RobertL AHK8.com
;http://ahk8.com/thread-5384.html
ObjLength(ByRef o){
	if !IsObject(o)
		throw Exception("参数类型错误`n期望对象")
	_mi:=ObjMaxIndex(o)
	,_mi:=_mi?_mi:0
	return _mi
}
ObjRemoveAt(ByRef o,ByRef i){
	if !IsObject(o)
		throw Exception("参数类型错误`n期望对象")
	if i is not Integer
		throw Exception("参数类型错误`n数值")
	return ObjRemove(o,i)
}
ObjRawSet(ByRef o,ByRef k,ByRef v){
	if !IsObject(o)
		throw Exception("参数类型错误`n期望对象")
	if ObjHasKey(o,k)
		o[k]:=v
	else{
		if(Type(k)="Integer")
			ObjRemove(o,k)
		ObjInsert(o,k,v)
	}
}
ObjInsertAt(ByRef o,ByRef i:="",v*){
	if !IsObject(o)
		throw Exception("参数类型错误`n期望对象")
	if Type(i)!="Integer"
		throw Exception("参数类型错误`n期望数值索引")
	if i=""
		i:=((_m:=ObjMaxIndex(o))="" ? 1 : _m + 1)
	ObjInsert(o,i,v*)
}