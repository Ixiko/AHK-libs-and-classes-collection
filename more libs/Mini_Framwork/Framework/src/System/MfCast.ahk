;{ License
/* This file is part of Mini-Framework For AutoHotkey.
 * 
 * Mini-Framework is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 2 of the License.
 * 
 * Mini-Framework is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Mini-Framework.  If not, see <http://www.gnu.org/licenses/>.
 */
; End:License ;}
class MfCast extends MfObject
{
;{ 	ToByte
	ToByte(obj, ReturnAsObject:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		_intResult := MfInt64.GetValue(obj,"NaN", true)
		if (!(_intResult = "NaN"))
		{
			val := MfConvert._Int64ToByte(_intResult)
			if (ReturnAsObject)
			{
				return new MfByte(val, true)
			}
			return val
		}
		if (IsObject(obj))
		{
			if (MfObject.IsObjInstance(obj, MfUInt64))
			{
				nibbles := MfNibConverter.GetNibbles(obj)
				val := MfNibConverter.ToByte(nibbles,,ReturnAsObject)
				return val
			}
		}
		else
		{
			try
			{
				bigInt := MfBigInt.Parse(obj)
				if (bigInt.LessThenOrEqual(MfUInt64.MaxValue))
				{
					uint := new MfUInt64(bigInt.ToString())
					return MfCast.ToByte(uint, ReturnAsObject)
				}
			}
			catch e
			{
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToByte"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToByte"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:ToByte ;}
;{ 	ToSByte
	ToSByte(obj, ReturnAsObject:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		_intResult := MfInt64.GetValue(obj,"NaN", true)
		if (!(_intResult = "NaN"))
		{
			val := MfConvert._Int64ToSByte(_intResult)
			if (ReturnAsObject)
			{
				return new MfSByte(val, true)
			}
			return val
		}
		if (MfObject.IsObjInstance(obj, MfUInt64))
		{
			nibbles := MfNibConverter.GetNibbles(obj)
			val := MfNibConverter.ToSByte(nibbles,,ReturnAsObject)
			return val
		}
		else
		{
			try
			{
				bigInt := MfBigInt.Parse(obj)
				if (bigInt.LessThenOrEqual(MfUInt64.MaxValue))
				{
					uint := new MfUInt64(bigInt.ToString())
					return MfCast.ToSByte(uint, ReturnAsObject)
				}
			}
			catch e
			{
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToSByte"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToSByte"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:ToSByte ;}
;{ 	ToInt16
	ToInt16(obj, ReturnAsObject:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		_intResult := MfInt64.GetValue(obj,"NaN", true)
		if (!(_intResult = "NaN"))
		{
			val := MfConvert._Int64ToInt16(_intResult)
			if (ReturnAsObject)
			{
				return new MfInt16(val, true)
			}
			return val
		}
		if (MfObject.IsObjInstance(obj, MfUInt64))
		{
			nibbles := MfNibConverter.GetNibbles(obj)
			val := MfNibConverter.ToInt16(nibbles,,ReturnAsObject)
			return val
		}
		else
		{
			try
			{
				bigInt := MfBigInt.Parse(obj)
				if (bigInt.LessThenOrEqual(MfUInt64.MaxValue))
				{
					uint := new MfUInt64(bigInt.ToString())
					return MfCast.ToInt16(uint, ReturnAsObject)
				}
			}
			catch e
			{
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInt16"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInt16"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:ToInt16 ;}
;{ 	ToUInt16
	ToUInt16(obj, ReturnAsObject:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		_intResult := MfInt64.GetValue(obj,"NaN", true)
		if (!(_intResult = "NaN"))
		{
			val := MfConvert._Int64ToUInt16(_intResult)
			if (ReturnAsObject)
			{
				return new MfUInt16(val, true)
			}
			return val
		}
		if (MfObject.IsObjInstance(obj, MfUInt64))
		{
			nibbles := MfNibConverter.GetNibbles(obj)
			val := MfNibConverter.ToUInt16(nibbles,,ReturnAsObject)
			return val
		}
		else
		{
			try
			{
				bigInt := MfBigInt.Parse(obj)
				if (bigInt.LessThenOrEqual(MfUInt64.MaxValue))
				{
					uint := new MfUInt64(bigInt.ToString())
					return MfCast.ToUInt16(uint, ReturnAsObject)
				}
			}
			catch e
			{
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToUInt16"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToUInt16"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:ToUInt16 ;}
;{ 	ToInt32
	ToInt32(obj, ReturnAsObject:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		_intResult := MfInt64.GetValue(obj,"NaN", true)
		if (!(_intResult = "NaN"))
		{
			val := MfConvert._Int64ToInt32(_intResult)
			if (ReturnAsObject)
			{
				return new MfInt32(val, true)
			}
			return val
		}
		if (MfObject.IsObjInstance(obj, MfUInt64))
		{
			nibbles := MfNibConverter.GetNibbles(obj)
			val := MfNibConverter.ToInt32(nibbles,,ReturnAsObject)
			return val
		}
		else
		{
			try
			{
				bigInt := MfBigInt.Parse(obj)
				if (bigInt.LessThenOrEqual(MfUInt64.MaxValue))
				{
					uint := new MfUInt64(bigInt.ToString())
					return MfCast.ToInt32(uint, ReturnAsObject)
				}
			}
			catch e
			{
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:ToInt32 ;}
;{ 	ToUInt32
	ToUInt32(obj, ReturnAsObject:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		_intResult := MfInt64.GetValue(obj,"NaN", true)
		if (!(_intResult = "NaN"))
		{
			val := MfConvert._Int64ToUInt32(_intResult)
			if (ReturnAsObject)
			{
				return new MfUInt32(val, true)
			}
			return val
		}
		if (MfObject.IsObjInstance(obj, MfUInt64))
		{
			nibbles := MfNibConverter.GetNibbles(obj)
			val := MfNibConverter.ToUInt32(nibbles,,ReturnAsObject)
			return val
		}
		else
		{
			try
			{
				bigInt := MfBigInt.Parse(obj)
				if (bigInt.LessThenOrEqual(MfUInt64.MaxValue))
				{
					uint := new MfUInt64(bigInt.ToString())
					return MfCast.ToUInt32(uint, ReturnAsObject)
				}
			}
			catch e
			{
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToUInt32"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToUInt32"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:ToUInt32 ;}
;{ 	ToInt64
	ToInt64(obj, ReturnAsObject:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		_intResult := MfInt64.GetValue(obj,"NaN", true)
		if (!(_intResult = "NaN"))
		{
			if (ReturnAsObject)
			{
				return new MfInt64(_intResult, true)
			}
			return _intResult
		}
		if (MfObject.IsObjInstance(obj, MfUInt64))
		{
			nibbles := MfNibConverter.GetNibbles(obj)
			val := MfNibConverter.ToInt64(nibbles,,ReturnAsObject)
			return val
		}
		else
		{
			try
			{
				bigInt := MfBigInt.Parse(obj)
				if (bigInt.LessThenOrEqual(MfUInt64.MaxValue))
				{
					uint := new MfUInt64(bigInt.ToString())
					return MfCast.ToInt64(uint, ReturnAsObject)
				}
			}
			catch e
			{
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInt64"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInt64"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:ToInt64 ;}
;{ 	ToUInt64
	ToUInt64(obj, ReturnAsObject:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		if (MfObject.IsObjInstance(obj, MfInt64))
		{
			if (obj.Value >= 0)
			{
				if (ReturnAsObject)
				{
					return new MfUInt64(obj.Value, true)
				}
				return obj.Value
			}
			nibbles := MfNibConverter.GetNibbles(obj)
			val := MfNibConverter.ToUInt64(nibbles,,ReturnAsObject)
			return val
		}
		_intResult := MfInt64.GetValue(obj,"NaN", true)
		if (!(_intResult = "NaN"))
		{
			if (_intResult < 0)
			{
				int := new MfInt64(_intResult,true)
				return MfCast.ToUInt64(int, ReturnAsObject)
			}
			if (ReturnAsObject)
			{
				return new MfUInt64(_intResult, true)
			}
			return _intResult
		}
		if (MfObject.IsObjInstance(obj, MfUInt64))
		{
			if (ReturnAsObject)
			{
				retval := obj.Clone()
				retval.ReturnAsObject := true
				return retval
			}
			return obj.ToString()
			
		}
		
		if (!IsObject(obj))
		{
			try
			{
				bigInt := MfBigInt.Parse(obj)
				if (bigInt.LessThenOrEqual(MfUInt64.MaxValue))
				{
					uint := new MfUInt64(bigInt.ToString())
					return MfCast.ToInt64(uint, ReturnAsObject)
				}
			}
			catch e
			{
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInt64"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInt64"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:ToUInt64 ;}
;{ 	ToFloat
	ToFloat(obj, ReturnAsObject:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		_intResult := MfInt64.GetValue(obj,"NaN", true)
		if (!(_intResult = "NaN"))
		{
			flt := MfFloat.Parse(format("{:i}",_intResult))
			if (ReturnAsObject)
			{
				return flt
			}
			return flt.Value
		}
		if (MfObject.IsObjInstance(obj, MfUInt64))
		{

			flt := MfFloat.Parse(obj.ToString())
			if (ReturnAsObject)
			{
				return flt
			}
			return flt.Value
		}
		else
		{
			try
			{
				bigInt := MfBigInt.Parse(obj)
				if (bigInt.LessThenOrEqual(MfUInt64.MaxValue))
				{
					flt := MfFloat.Parse(bigInt.ToString())
					if (ReturnAsObject)
					{
						return flt
					}
					return flt.Value
				}
			}
			catch e
			{
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToFloat"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToFloat"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:ToFloat ;}
}