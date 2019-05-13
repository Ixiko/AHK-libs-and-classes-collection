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
class MfNibConverter extends MfObject
{
	static bpe := 4
	static mask := 15
	static radix := 16
;{ Methods
;{ 	GetNibbles
	GetNibbles(obj) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!IsObject(obj))
		{
			IsNeg := False
			if(MfMath._IsStringInt(obj, IsNeg))
			{
				return MfNibConverter._LongIntStringToHexArray(obj, 64)
			}
			Else
			{
				return MfNibConverter._HexStringToNibList(obj)
			}
		}
		
		Try
		{
			if (MfObject.IsObjInstance(obj, MfBool))
			{
				if (obj.Value = true)
				{
					return MfNibConverter._GetBytesInt(1, 8, true)
				}
				return MfNibConverter._GetBytesInt(0, 8, true)
			}
			else if (MfObject.IsObjInstance(obj, MfChar))
			{
				return MfNibConverter._GetBytesInt(obj.CharCode, 16)
			}
			else if (MfObject.IsObjInstance(obj, MfByte))
			{
				return MfNibConverter._GetBytesInt(obj.Value, 8)
			}
			else if (MfObject.IsObjInstance(obj, MfSByte))
			{
				return MfNibConverter._GetBytesInt(obj.Value, 8)
			}
			else if (MfObject.IsObjInstance(obj, MfInt16))
			{
				return MfNibConverter._GetBytesInt(obj.Value, 16)
			}
			else if (MfObject.IsObjInstance(obj, MfUInt16))
			{
				return MfNibConverter._GetBytesInt(obj.Value, 16)
			}
			else if (MfObject.IsObjInstance(obj, MfInteger))
			{
				return MfNibConverter._GetBytesInt(obj.Value, 32)
			}
			else if (MfObject.IsObjInstance(obj, MfUInt32))
			{
				return MfNibConverter._GetBytesInt(obj.Value, 32)
			}
			else if (MfObject.IsObjInstance(obj, MfInt64))
			{
				return MfNibConverter._GetBytesInt(obj.Value, 64)
			}
			else if (MfObject.IsObjInstance(obj, MfUInt64))
			{
				bigx := obj.m_bigx
				nibs := MfNibConverter._HexStringToNibList("+" . bigx.ToString(16), 16)
				return nibs
			}
			else if (MfObject.IsObjInstance(obj, MfBigInt))
			{
				objNeg := obj.IsNegative
				obj.IsNegative := False
				nibs := MfNibConverter._HexStringToNibList("+" . obj.ToString(16))
				obj.IsNegative := objNeg
				if (objNeg)
				{
					
					nibs := MfNibConverter.ToComplement16(nibs)
				}
				return nibs
			}
			
			else if (MfObject.IsObjInstance(obj, MfFloat))
			{
				int := MfByteConverter._FloatToInt64(obj.Value)
				return MfNibConverter._GetBytesInt(int, 64)
			}
		}
		Catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:GetNibbles ;}
;{ 	Expand
	; return a copy of x with at least n elements, adding leading zeros if needed
	Expand(nibbles, n, UseMsb=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		n := MfInteger.GetValue(n, 0)
		UseMsb := MfBool.GetValue(UseMsb, true)
		MSB := 0
		if (UseMsb = true && nibbles.Count > 0)
		{
			Hex := Format("{:X}", nibbles.Item[0])
			bInfo := MfNibConverter.HexBitTable[Hex]
			if (bInfo.IsNeg)
			{
				MSB := 15
			}
		}
		
		
		If (nibbles.Count >= n)
		{
			return nibbles.Clone()
		}

		diff := n - nibbles.Count
		lst := new MfNibbleList()
		nl := lst.m_InnerList
		ll := nibbles.m_InnerList
		i := 1
		While (i <= diff)
		{
			nl[i] := MSB
			i++
		}
		j := i
		i := 1

		While (i <= nibbles.Count)
		{
			nl[j] := ll[i]
			i++
			j++
		}

		lst.m_Count := nl.Length()
		return lst
	}
; 	End:Expand ;}
;{ 	BitShiftLeft
	BitShiftLeft(nibbles, ShiftCount) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		ShiftCount := MfInteger.GetValue(ShiftCount)
		if (ShiftCount = 0)
		{
			return nibbles.Clone()
		}

		if (ShiftCount < 0)
		{
			return ; MfNibConverter.BitShiftRight(bits, Abs(ShiftCount), Wrap)
		}
		r := Mod(ShiftCount, 4)
		shiftAmt := ShiftCount // 4

		nibbles := nibbles.Clone()
		if (r > 0)
		{
			MfNibConverter.multInt_(nibbles, 2 ** r)
		}
		ll := nibbles.m_InnerList
		iLastIndex := nibbles.Count ; one based index
		i := 0
		while (i < shiftAmt)
		{
			ll.RemoveAt(1)
			ll[iLastIndex] := 0
			;bits.Add(0)
			i++
		}
		
		return nibbles
	}
; 	End:BitShiftLeft ;}
;{ 	ShiftRightUnsigned
	BitShiftRightUnsigned(nibbles, ShiftCount) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ShiftCount := MfInteger.GetValue(ShiftCount)
		if (ShiftCount = 0)
		{
			return nibbles.Clone()
		}

		if (ShiftCount < 0)
		{
			return MfNibConverter.BitShiftLeft(nibbles, Abs(ShiftCount), Wrap)
		}
		r := Mod(ShiftCount, 4)
		shiftAmt := ShiftCount // 4
		if (shiftAmt >= nibbles.Count) {
			lst := new MfNibbleList()
			return MfNibConverter.Expand(lst, nibbles.Count)
		}
		

		i := 0
		nibbles := nibbles.Clone()
		if (r > 0)
		{
			dr := MfNibConverter.divInt_(nibbles, 2 ** r)
		}
		; while (r > 0)
		; {
		; 	MfNibConverter.halve_(nibbles)
		; 	r--
		; }
		ll := nibbles.m_InnerList
		while (i < shiftAmt)
		{
			ll.Pop()
			ll.InsertAt(1, 0)
			i++
		}
		return nibbles
		
	}
; 	End:ShiftRightUnsigned ;}
;{ 	BitShiftRight
	BitShiftRight(nibbles, ShiftCount) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ShiftCount := MfInteger.GetValue(ShiftCount)
		if (ShiftCount = 0)
		{
			return bits.Clone()
		}

		if (ShiftCount < 0)
		{
			return MfBinaryConverter.BitShiftLeft(bits, Abs(ShiftCount), Wrap)
		}


		MSB := bits.Item[0]
		i := 0
		bits := bits.Clone()
		ll := bits.m_InnerList
		while (i < ShiftCount)
		{
			ll.Pop()
			ll.InsertAt(1, MSB)
			i++
		}
		return bits
		
	}
; 	End:BitShiftRight ;}
;{ 	CompareUnsignedList
	CompareUnsignedList(objA, objB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(objA, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(objB, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return MfNibConverter._CompareUnSignedIntegerArraysBe(objA, objB)
	}
; 	End:CompareUnsignedList ;}
;{ 	CompareSignedList
	CompareSignedList(objA, objB)	{
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(objA, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(objB, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(objA.Count = 0)
		{
			return -1
		}
		if(objB.Count = 0)
		{
			return 1
		}
		HexA := MfByteConverter._GetHexValue(objA.Item[0])
		MostSigbitInfoA :=  MfNibConverter.HexBitTable[HexA]
		
		HexB := MfByteConverter._GetHexValue(objA.Item[0])
		MostSigbitInfoB :=  MfNibConverter.HexBitTable[HexB]
		if ((MostSigbitInfoA.IsNeg = true) && (MostSigbitInfoB.IsNeg = false))
		{
			return -1
		}
		if ((MostSigbitInfoA.IsNeg = false) && (MostSigbitInfoB.IsNeg = true))
		{
			return 1
		}
		if ((MostSigbitInfoA.IsNeg = false) && (MostSigbitInfoB.IsNeg = false))
		{
			return MfNibConverter._CompareUnSignedIntegerArraysBe(objA, objB)
		}
		if (MostSigbitInfoA.IsNeg = true)
		{
			ObjA := MfByteConverter._FlipNibbles(ObjA)
		}
		if (MostSigbitInfoB.IsNeg = true)
		{
			ObjB := MfByteConverter._FlipNibbles(ObjB)
		}
		result := MfNibConverter._CompareUnSignedIntegerArraysBe(objA, objB)
		if (result > 0)
		{
			return -1
		}
		if (result < 0)
		{
			return 1
		}
		return result
	}
; 	End:CompareSignedList ;}

;{ 	FromByteList
	; converts from MfByteList to MfNibbleList
	FromByteList(bytes, startIndex=0) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		lst := new MfNibbleList()
		if (bytes.Count = 0)
		{
			return lst
		}
		_startIndex := MfInteger.GetValue(startIndex, 0)
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_startIndex >= bytes.Count)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"), "bytes")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		i := (bytes.Count - _startIndex) - 1
		while i >= 0
		{
			b := bytes.Item[i]
			lst.AddByte(b)
			i--
		}
		return lst
	}

; 	End:FromByteList ;}
;{ 	FromHex
/*
	Method: FromHex()

	FromHex()
		Converts Hex string to instance of MfNibbleList
	Parameters:
		value
			The var or MfString containing the hex value to convert
		MinCount
			Optional, the Minimum number of items in the return list
		MaxCount
			Optional, the Maximum number of hex postitions to process
	Returns:
		Returns an instance of MfNibbleList
	Remarks:
		Static Method
		Hex value can be in format of 0x00ff or -0x00ff or ffff or -ffff and is case insensitive
		Negative hex values will be returned as Complements16
		WhiteSpace and non hex char are ignored
*/
	FromHex(value, MinCount:=0,MaxCount:=0) {
		_MinCount := MfInteger.GetValue(MinCount, 0)
		_MaxCount := MfInteger.GetValue(MaxCount, 0)
		if (_MinCount < 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeCount"), "MinCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_MaxCount < 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeCount"), "MaxCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(_MaxCount < _MinCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_MinGreaterThenMax", "MaxCount", "MinCount"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return MfNibConverter._HexStringToNibList(value, _MinCount, _MaxCount, true)
	}
; 	End:FromHex ;}
;{ 	IsNegative
	IsNegative(nibbles, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 1 ; Number of nibbles needed for test
		if (nibbles.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MaxStartIndex := nibbles.Count - nCount
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := 0
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Hex := MfNibConverter._GetHexValue(nibbles.Item[_startIndex])
		bInfo := MfNibConverter.HexBitTable[Hex]
		if (_ReturnAsObj)
		{
			return new MfBool(bInfo.IsNeg)
		}
		return bInfo.IsNeg
	}
; 	End:IsNegative ;}
	NumberComplement(obj) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!IsObject(obj))
		{
			len := strLen(obj)
			if (len = 0)
			{
				return ""
			}
			mStr := new MFMemoryString(len,,,&obj)
			cc := mStr.CharCode[0]
			IsNeg := false
			if (cc = 45)
			{
				IsNeg := true
			}
			Nibbles := MfNibConverter.GetNibbles(obj)
			bLst := MfNibConverter.ToBinaryList(Nibbles)
			bLstFlipped := MfBinaryConverter.ToComplement1(bLst)
			bigx := MfBinaryConverter.ToBigInt(bLstFlipped, 0, true)
			bigx.IsNegative := !IsNeg
			return bigx.ToString()

		}
		; byte and bool are not support but byte could be converted to integer first
		if (MfObject.IsObjInstance(obj, MfInt16))
		{
			Nibbles := MfNibConverter.GetNibbles(obj)
			bLstFlipped := MfNibConverter.ToComplement15(Nibbles)
			newObj := MfNibConverter.ToInt16(bLstFlipped,,true)
			newObj.ReturnAsObject := obj.ReturnAsObject
			return newObj
		}
		if (MfObject.IsObjInstance(obj, MfUInt16))
		{
			Nibbles := MfNibConverter.GetNibbles(obj)
			bLstFlipped := MfNibConverter.ToComplement15(Nibbles)
			newObj := MfNibConverter.ToUInt16(bLstFlipped,,true)
			newObj.ReturnAsObject := obj.ReturnAsObject
			return newObj
		}
		if (MfObject.IsObjInstance(obj, MfInteger))
		{
			Nibbles :=  MfNibConverter.GetNibbles(obj)
			bLstFlipped := MfNibConverter.ToComplement15(Nibbles)
			newObj := MfNibConverter.ToInt32(bLstFlipped,,true)
			newObj.ReturnAsObject := obj.ReturnAsObject
			return newObj
		}
		if (MfObject.IsObjInstance(obj, MfUInt32))
		{
			Nibbles :=  MfNibConverter.GetNibbles(obj)
			bLstFlipped := MfNibConverter.ToComplement15(Nibbles)
			newObj := MfNibConverter.ToUInt32(bLstFlipped,,true)
			newObj.ReturnAsObject := obj.ReturnAsObject
			return newObj
		}
		if (MfObject.IsObjInstance(obj, MfInt64))
		{
			Nibbles :=  MfNibConverter.GetNibbles(obj)
			bLstFlipped := MfNibConverter.ToComplement15(Nibbles)
			newObj := MfNibConverter.ToInt64(bLstFlipped,,true)
			newObj.ReturnAsObject := obj.ReturnAsObject
			return newObj
		}
		if (MfObject.IsObjInstance(obj, MfUInt64))
		{
			Nibbles :=  MfNibConverter.GetNibbles(obj)
			bLstFlipped := MfNibConverter.ToComplement15(Nibbles)
			newObj := MfNibConverter.ToUInt64(bLstFlipped,,true)
			newObj.ReturnAsObject := obj.ReturnAsObject
			return newObj
		}
		if (MfObject.IsObjInstance(obj, MfBigInt))
		{
			Nibbles :=  MfNibConverter.GetNibbles(obj)
			bLstFlipped := MfNibConverter.ToComplement15(Nibbles)
			newObj := MfNibConverter.ToBigInt(bLstFlipped,,,true)
			newobj.IsNegative := !obj.IsNegative
			return newObj
		}

		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;{ 	ToBool
	ToBool(nibbles, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := nibbles.Count - 1
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > (nibbles.Count - 1)))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := nibbles.Item[_startIndex] != 0
		if (_ReturnAsObj)
			return new MfBool(retval)
		return retval

	}
; 	End:ToBool ;}
;{ 	ToByte
	ToByte(nibbles, startIndex:=-1, ReturnAsObj:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 2 ; Number of nibbles needed for conversion
		if (nibbles.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		
		MaxStartIndex := nibbles.Count - nCount
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MSB := nibbles.Item[_startIndex]

		LSB := nibbles.Item[_startIndex + 1]

		retval := (MSB * 16) + LSB
		if ((retval < MfByte.MinValue) || (retval > MfByte.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Byte"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfByte(retval)
		}

		return retval

	}
; 	End:ToByte ;}
	ToSByte(nibbles, startIndex:=-1, ReturnAsObj:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		byte := MfNibConverter.ToByte(nibbles,startIndex,false)
		retval := MfConvert._ByteToSByte(byte)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if (_ReturnAsObj)
		{
			return new MfSByte(retval)
		}

		return retval

	}
;{ ToChar
	ToChar(nibbles, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		result := MfNibConverter.ToInt16(nibbles, startIndex, false)
		if (result < 0)
		{
			result := Abs(result)
		}
		c := new MfChar()
		c.CharCode := result
		if (_ReturnAsObj)
		{
			return c
		}
		return c.Value
	}
; End:ToChar ;}
;{ ToInt16
	ToInt16(nibbles, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		uint := 0
		try
		{
			uint := MfNibConverter.ToUInt16(nibbles, startIndex, false)
		}
		catch e
		{
			if (MfObject.IsObjInstance(e, MfOverflowException))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int16"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			throw e
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		int := MfConvert._Int64ToInt16(uint)
		if (_ReturnAsObj)
		{
			return new MfInt16(int, true)
		}
		return int
	}
; End:ToInt16 ;}
;{ 	ToInt32
	ToInt32(nibbles, startIndex:=-1, ReturnAsObj:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		uint := 0
		try
		{
			uint := MfNibConverter.ToUInt32(nibbles, startIndex, false)
		}
		catch e
		{
			if (MfObject.IsObjInstance(e, MfOverflowException))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			throw e
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		int := MfConvert._Int64ToInt32(uint)
		if (_ReturnAsObj)
		{
			return new MfInteger(int, true)
		}
		return int
	}
; 	End:ToInt32 ;}
;{ 	ToInt64
	ToInt64(nibbles, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 16 ; Number of nibbles needed for conversion
		if (nibbles.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MaxStartIndex := nibbles.Count - nCount
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		sb := new MfText.StringBuilder(20)
		iCount := 0
		i := _startIndex
		IsNeg := false
		while iCount < nCount
		{
			HexKey := MfNibConverter._GetHexValue(nibbles.Item[i])
			if (iCount = 0)
			{
				bInfo := MfNibConverter.HexBitTable[HexKey]
				IsNeg := bInfo.IsNeg
				
			}
			sb.AppendString(MfNibConverter._GetHexValue(nibbles.Item[i]))
			iCount++
			i++
		}
		if (IsNeg)
		{
			; due to Int64 Minvalue being the smallest valid int will have to convert to Nibbles to
			; do a valid check if minvalue is within range
			negVal := new MfNibbleList()
			strHex := new MfString(sb.ToString())
			for i, c in strHex
			{
				bInfo := MfNibConverter.HexBitTable[c]
				bFlip := MfNibConverter.HexBitTable[bInfo.HexFlip]
				negVal.Add(bFlip.IntValue)
			}
			
			MfNibConverter._AddOneToNibListValue(negVal)

			retval := "-0x" . negVal.ToString()
			if (MfMath._IsValidInt64Range(retval) = false)
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			retval := retval + 0x0
		}
		else
		{
			retval := "0x" . sb.ToString()
			if (MfMath._IsValidInt64Range(retval) = false)
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			retval := retval + 0x0
		}
		
		if (_ReturnAsObj)
		{
			return new MfInt64(retval, true)
		}
		return retval
	}
; 	End:ToInt64 ;}
;{ 	ToUInt16
	ToUInt16(nibbles, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 4 ; Number of nibbles needed for conversion
		if (nibbles.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MaxStartIndex := nibbles.Count - nCount
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		sb := new MfText.StringBuilder()
		sb.AppendString("0x")
		iCount := 0
		i := _startIndex + 1
		inLst := nibbles.m_InnerList
		while iCount < nCount
		{
			HexKey := MfNibConverter._GetHexValue(inLst[i])
			sb.AppendString(HexKey)
			iCount++
			i++
		}
		retval := sb.Tostring() + 0x0
		sb := ""
		if ((retval < MfUInt16.MinValue) || (retval > MfUInt16.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_UInt16"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfUInt16(retval)
		}
		return retval
	}
; 	End:ToUInt16 ;}
;{ 	ToUInt32
	ToUInt32(nibbles, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 8 ; Number of nibbles needed for conversion
		if (nibbles.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MaxStartIndex := nibbles.Count - nCount
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		sb := new MfText.StringBuilder()
		sb.AppendString("0x")
		iCount := 0
		i := _startIndex + 1
		IsNeg := false
		inLst := nibbles.m_InnerList
		while iCount <= nCount
		{
			HexKey := MfNibConverter._GetHexValue(inLst[i])
			sb.AppendString(MfNibConverter._GetHexValue(inLst[i]))
			iCount++
			i++
		}
		retval := sb.ToString()
		retval := retval + 0x0
		if ((retval < MfUInt32.MinValue) || (retval > MfUInt32.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_UInt32"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfUInt32(retval)
		}
		return retval
	}
; 	End:ToUInt32 ;}
;{ 	ToUInt64
	ToUInt64(nibbles, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 16 ; Number of nibbles needed for conversion
		if (nibbles.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MaxStartIndex := nibbles.Count - nCount
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_startIndex > 0)
		{
			nibbles := nibbles.SubList(_startIndex, _startIndex + nCount)
		}
		;~ if (MfNibConverter.IsNegative(nibbles))
		;~ {
			;~ nibbles := MfNibConverter.ToComplement16(nibbles)
		;~ }
		
		bigInt := MfBigInt.Parse(nibbles.ToString(), 16)

		if (_ReturnAsObj)
		{
			return new MfUInt64(bigInt)
		}
		return bigInt.Value
	}
; 	End:ToUInt64 ;}
;{ 	ToBigInt
	ToBigInt(nibbles, startIndex=0 , Length=-1, ReturnAsObj=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Length := MfInteger.GetValue(Length, 1)
		if (Length < 0)
		{
			Length := nibbles.Count
		}
		_startIndex := MfInteger.GetValue(startIndex, 0)
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		;~ if (_startIndex < ((nibbles.Count - _startIndex ) - Length))
		if ((nibbles.Count - Length ) < _startIndex)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (_startIndex > 0 || Length != nibbles.m_Count)
		{
			nibbles := nibbles.SubList(startIndex, startIndex + Length)
		}
		
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		
		retval := ""
		iCount := 0
		i := _startIndex
		IsNeg := MfNibConverter.IsNegative(nibbles, 0)
		if (IsNeg)
		{
			nibbles := MfNibConverter.ToComplement16(nibbles)
		}
		strH := "0x" . nibbles.ToString()
		retval := MfBigInt.Parse(strH)
		retval.IsNegative := IsNeg
		if (_ReturnAsObj)
		{
			return retval
		}
		Return retval.Value
	}
; 	End:ToBigInt ;}
;{ 	ToBinaryList
	ToBinaryList(nList, IgnoreUneven:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		IgnoreUneven := MfBool.GetValue(IgnoreUneven, false)
		if(MfObject.IsObjInstance(nList, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if(nList.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (IgnoreUneven = false && nList.Count & 1) ; if uneven count
		{
			nList := nList.Clone()
			;SourceMaxIndex := nList.Count -1
			MSB := nList.Item[0]
			HexChar := MfNibConverter._GetHexValue(MSB)
			mInfo := MfNibConverter.HexBitTable[HexChar]
			
			if (mInfo.IsNeg)
			{
				nList.Insert(0,15)
			}
			else
			{
				nList.Insert(0,0)
			}
		}
		lst := new MfBinaryList()
		iMaxIndex := nList.Count - 1
		i := iMaxIndex
		for i , n in nList
		{
			HexChar := MfNibConverter._GetHexValue(n)
			mInfo := MfNibConverter.HexBitTable[HexChar]
			strBin := mInfo.Bin
			mStr := new MfMemoryString(4,,,&strBin)
			for i , c in mStr
			{
				lst._Add(c - 48)
			}
			;~ loop, Parse, strBin
			;~ {
				;~ lst.Add(A_LoopField)
			;~ }
		}
		return lst
	}
; 	End:ToBinaryList ;}
;{ 	ToByteList
	ToByteList(nList) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nList, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if(nList.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (nList.Count & 1) ; if uneven count
		{
			nList := nList.Clone()
			;SourceMaxIndex := nList.Count -1
			MSB := nList.Item[0]
			HexChar := MfNibConverter._GetHexValue(MSB)
			mInfo := MfNibConverter.HexBitTable[HexChar]
			if (mInfo.IsNeg)
			{
				nList.Insert(0,15)
			}
			else
			{
				nList.Insert(0,0)
			}
		}
		

		lst := new MfByteList()
		
		iMaxIndex := nList.Count - 1
		i := iMaxIndex
		;~ if (this.Count & 1) ; if uneven count
		;~ {
			;~ n := this.Item[this.Count -1]
			;~ ;n := this.Item[0]
			;~ lst.Add(n)
			;~ i--
		;~ }
		while i >= 0
		{
			j := i - 1
			LSB := nList.Item[i]
			if (j >= 0)
			{
				MSB := nList.Item[j]
				Value := (MSB * 16) + LSB
				lst.Add(Value)
			}
			
			i -= 2
		}
		; if (nList.Count & 1) ; if uneven count
		; {
		; 	MSB := nList.Item[0]
		; 	HexChar := MfByteConverter._GetHexValue(MSB)
		; 	mInfo := MfByteConverter.HexBitTable[HexChar]
		; 	if (mInfo.IsNeg)
		; 	{
		; 		value := 255 ; MSB in return Byte List will be FF
		; 		lst.Add(value)
		; 	}
		; 	else
		; 	{
		; 		lst.Add(MSB)
		; 	}
			
		; 	i--
		; }
		
		return lst
	}
; 	End:ToByteList ;}
;{ 	ToIntegerString
	ToIntegerString(nibbles, startIndex=-1, UnSigned=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		_UnSigned := MfBool.GetValue(UnSigned, false)
		if (_startIndex < 0)
		{
			_startIndex := 0 ; _HexToDecimal loops index forward
		}
		if ((_startIndex < 0) || (_startIndex >= nibbles.Count))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_UnSigned = false)
		{
			If (MfNibConverter.IsNegative(nibbles, startIndex ) = true)
			{
				if (_startIndex > 0)
				{
					subLst := MfNibConverter._GetSubList(nibbles, startIndex)
					subLst16 := MfNibConverter.ToComplement16(subLst)
					retval := "-" . MfNibConverter._HexToDecimal(subLst, 0)
					return retval
				}
				subLst16 := MfNibConverter.ToComplement16(nibbles)
				retval := "-" . MfNibConverter._HexToDecimal(subLst16, 0)
				return retval
			}
		}
		return MfNibConverter._HexToDecimal(nibbles, _startIndex)
	}
; 	End:ToIntegerString ;}
	; return a copy of nibbles with exactly n leading elements
	; if UseMsb is true then MSB is the leading element. Otherwise  0 is leading element
	Trim(nibbles, n=0, UseMsb=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		n := MfInteger.GetValue(n, 0)
		UseMsb := MfBool.GetValue(UseMsb, true)
		if (n < 0)
		{
			n = -n
		}
		MSB := 0
		if (UseMsb)
		{
			MSB := nibbles.Item[0]
		}
		i := 0
		j := nibbles.Count
		while (i >= 0 && nibbles.m_InnerList[i + 1] = MSB)
		{
			i++
			j--
		}
		y := new MfNibbleList(j + n, MSB)
		if (j = 0)
		{
			; if j = the we have all leading bits of 0 or all leading bits or 1
			; make sure to return at least n + 1 bits for a min of one bit
			y.Add(MSB)
			return y
		}
		MfNibConverter._copy(y, nibbles, MSB)
		return y
	}
;{ 	ToString
	ToString(nibbles, returnAsObj = false, startIndex = 0, length="") {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return nibbles.ToString(returnAsObj, startIndex, length, 1)
	}
; 	End:ToString ;}
;{ NibbleListsAdd
	NibbleListAdd(ListA, ListB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(ListA, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "ListA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(ListB, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "ListB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(ListA.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "ListA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(ListB.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "ListB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ListA.Count > ListB.Count)
		{
			return MfNibConverter._NibListsAdd(ListA, ListB)
		}
		return MfNibConverter._NibListsAdd(ListB, ListA)
		
	}
; End:NibbleListsAdd ;}
	NibbleListMultiply(ListA, ListB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(ListA, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "ListA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(ListB, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "ListB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(ListA.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "ListA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(ListB.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "ListB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Compare := MfNibConverter.CompareSignedNibbleArrays(ListA, ListB)
		if (Compare > 0)
		{
			return MfNibConverter._MultiplyNibList(ListA, ListB)
		}
		return MfNibConverter._MultiplyNibList(ListA, ListB)
	}
;{ 	ToComplement15
	ToComplement15(nList) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nList, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if(nList.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := MfNibConverter._FlipNibbles(nList)
		return retval
	}
; 	End:ToComplement15 ;}
;{ 	ToComplement16
	ToComplement16(nList) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nList, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if(nList.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := MfNibConverter._FlipNibbles(nList)
		MfNibConverter._AddOneToNibListValue(retval)
		return retval
	}
;{ 	ToComplement16
; End:Methods ;}
;{ 	_copy
	; do x=y on list x and y.
	; x at least as big as y (not counting the MSB Values in y).
	_copy(ByRef x, y, MSB=0) {
		if (y.Count = 0)
		{
			x.Clear()
			x.Add(MSB)
			return
		}
		xl := x.m_InnerList
		yl := y.m_InnerList
		i := 1
		yIndex := 0
		while (i <= y.Count && yl[i] = MSB)
		{
			yIndex++
			i++
		}
		yCount := y.Count - yIndex

		if (yCount > x.Count)
		{
			; set all elemets of x to MSB
			i := 1
			while (i <= yCount)
			{
				xl[i] := yl[i + yIndex]
				i++
			}
			; x and y should not be the same length

			
		}
		else
		{
			; x.Count is greater then yCount
			; assign the last items of y to the last items of x
			
			i := y.Count
			j := x.Count
			iCount := 0
			k := yCount
			while (k >= 1)
			{
				xl[j] := yl[i]
				i--
				j--
				k--
				iCount++
			}
			; not x last values are equal to y last values
			; now assign MSB to all other x values
			
			; set remainding elemets of x to MSB
			while (j >= 1 && iCount < x.Count)
			{
				xl[j] := MSB
				j--
				iCount++
			}
		}
		x.m_Count := xl.Length()
	}
; 	End:_copy ;}
;{ 	divInt_
	divInt_(byRef x, n) {
		r := 0
		i := 1
		ll := x.m_InnerList
		while (i < x.Count)
		{
			s := r * MfNibConverter.radix + ll[i]
			ll[i] := s // n
			r := Mod(s , n)
			i++
		}
		return r
	}
; 	End:divInt_ ;}
;{ multInt_
	multInt_(ByRef x, n) {
		xl := x.m_InnerList
		if (!n)
		{
			return
		}
		k := 1
		c := 0
		i := x.Count
		while (i >= k)
		{
			c += xl[i] * n
			b := 0
			if (c < 0)
			{
				b := -(c >> MfNibConverter.bpe)
				c += b * MfNibConverter.radix
			}
			xl[i] := c & MfNibConverter.mask
			c := (c >> MfNibConverter.bpe) - b
			i--
		}
		x.m_Count := xl.Length()
	}
; End:multInt_ ;}
;{ 	_AddOneToNibList
	; adds one to the value of lst only if there
	; is no carry.
	; returns true is value of one was added otherwise false
	; If AddToFront is true then value is added at the beginning Of
	; the list otherwise at the end of the list.
	_AddOneToNibList(byref lst, AddToFront=true) {
		IsAdded := false
		if (lst.Count & 1)
		{
			return false
		}
		if ( AddToFront = true)
		{
			i := 0
			While i < lst.Count
			{
				j := i + 1
				Lsb := lst.Item[j]
				Msb := lst.Item[i]
				if (Lsb < 15)
				{
					Lsb++
					lst.Item[j] := Lsb
					IsAdded := true
					break
				}
				else
				{
					lst.Item[j] := 0
				}
				
				if (Msb < 15)
				{
					Msb++
					lst.Item[i] := Msb
					IsAdded := true
					break
				}
				else
				{
					lst.Item[i] := 0
				}
				i += 2
			}
		}
		else
		{
			i := lst.Count - 1
			While i >= 0
			{
				j := i - 1
				Lsb := lst.Item[i]
				Msb := lst.Item[j]
				if (Lsb < 15)
				{
					Lsb++
					lst.Item[i] := Lsb
					IsAdded := true
					break
				}
				else
				{
					lst.Item[i] := 0
				}
				if (Msb < 15)
				{
					Msb++
					lst.Item[j] := Msb
					IsAdded := true
					break
				}
				else
				{
					lst.Item[j] := 0
				}
				i -= 2
			}
		}
		return IsAdded
	}
; 	End:_AddOneToNibList ;}
;{ 	_AddOneToNibListValue
	; adds 1 to the summ of lst
	; param lst instance of MfNibbleList
	_AddOneToNibListValue(byref lst) {
		iCarry := 1
		i := lst.Count - 1
		while i >= 0
		{
			sum := (lst.Item[i] + 1)
			if (sum > 15)
			{
				lst.Item[i] := 0
			}
			else
			{
				lst.Item[i] := sum
				iCarry := 0
				break
			}
			i--
		}
		if (iCarry = 1)
		{
			lst.Insert(0, 1)
		}
	}
; 	End:_AddOneToNibListValue ;}
;{ _CompareUnSignedIntegerArraysBe
	_CompareUnSignedIntegerArraysBe(objA, objB) {
		
		if(objA.Count = 0)
		{
			return -1
		}
		if(objB.Count = 0)
		{
			return 1
		}
		x := 0
		y := 0
		
		While ((x < objA.m_Count) && (objA.Item[x] = 0))
		{
			x++
		}
		While ((y < objB.m_Count) && (objB.Item[y] = 0))
		{
			y++
		}
		aInLst := objA.m_InnerList
		bInLst := objB.m_InnerList
		if (x = 0 && y = 0)
		{
			NumA := aInLst[x + 1]
			MumB := bInLst[y + 1]
			if (NumA > MumB)
			{
				return 1
			}
			if (NumA < MumB)
			{
				return -1
			}
			return 0
		}
		
		xOffset := objA.m_Count - x
		yOffset := objB.m_Count - y
		if (xOffset > yOffset)
		{
			return 1
		}
		if (xOffset < yOffset)
		{
			return -1
		}
		; array non zero index are the same length
		xOffset := x
		yOffset := y
		while yOffset < objB.m_Count
		{
			NumA := aInLst[xOffset + 1]
			MumB := bInLst[yOffset + 1]
			if (NumA > MumB)
			{
				return 1
			}
			if (NumA < MumB)
			{
				return -1
			}
			xOffset++
			yOffset++
		}
		return 0
	}
; End:_CompareUnSignedIntegerArraysBe ;}
;{ 	_GetSubList
	; returns a subset of a MfNibbleList as a new MfNibbleList instance
	; counts from left to right so startIndex it from the end
	_GetSubList(lst, startIndex, endIndex="") {
		return lst.SubList(startIndex, endIndex)
		
	}
; 	End:_GetSubList ;}
;{ 	_FlipNibbles
	_FlipNibbles(lst) {
		nArray := new MfNibbleList()
		iMaxIndex := lst.Count - 1
		for i, b in lst
		{
			Hex := MfNibConverter._GetHexValue(b)
			bInfo := MfNibConverter.HexBitTable[Hex]
			bInfoFlipped := MfNibConverter.HexBitTable[bInfo.HexFlip]
			
			nArray._Add(bInfoFlipped.IntValue)
		}
		return nArray
	}
; 	End:_FlipNibbles ;}
;{ 	_HexToDecimal
	_HexToDecimal(nibbles, startIndex=-1) {
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := 0
		}
		x := _startIndex
		while ((x < nibbles.Count) && (nibbles.Item[x] = 0))
		{
			x++
		}
		dec := new MfList() ; decimal result
		dec._Add(0)
		i := x
		mInLst := nibbles.m_InnerList
		while i < nibbles.m_Count
		{
			n := mInLst[i + 1]
			carry := n
			; initially holds decimal value of current hex digit;
			; subsequently holds carry-over for multiplication
			
			for j, int in dec
			{
				val := (int * 16) + carry
				valMod := Mod(val, 10)
				dec.m_InnerList[j + 1] := valMod
				carry := val // 10
			}
			while (carry > 0)
			{
				dec._Add(Mod(carry, 10))
				carry := carry // 10
			}
			i++
		}
		i := dec.Count - 1
		sb := new MfText.StringBuilder()
		while i >= 0
		{
			sb.AppendString(dec.m_InnerList[i + 1])
			i--
		}
		return sb.ToString()
	}
; 	End:_HexToDecimal ;}
;{ 	_NibListsAdd
	_NibListsAdd(lstA, lstB, TrimLeadingZeros=false, SignFinalCarry=false) {
		; lstA.Count is assumed to be greater then or equal to lstB.count
		aLong := Compare > 0
		
		ans := new MfNibbleList()
		iCarry := 0
		HasFinalCarry := false
		i := lstB.Count - 1
		offset := lstA.Count - lstB.Count
		iCount := 0
		while i >= 0
		{
			j := i + offset
			nA := lstA.Item[j]
			nB := lstB.Item[i]
			sum := (nA + nB) + iCarry
			R := 0
			if (sum > 0)
			{
				q := MfMath.DivRem(sum, 16, R)
				iCarry := q
			}
			ans.Add(R)
			i--
			iCount++
		}
		i :=  lstA.Count - 1 - iCount
		
		While (iCarry > 0)
		{
			HasFinalCarry := true
			R := 0
			if (i >= 0)
			{
				nA := lstA.Item[i]
				sum := nA  + iCarry
				iCarry := 0
				if (sum > 0)
				{
					iCarry := MfMath.DivRem(sum, 16, R)
				}
				i--
				iCount++
			}
			else
			{
				iCarry := MfMath.DivRem(iCarry, 16, R)
			}
			
			ans.Add(R)
		}
		; if there are any remainint elements in lstA add them to ans
		i := lstA.Count - 1 - iCount
		while i >= 0
		{
			ans.Add(lstA.Item[i])
			i--
			iCount++
		}
		
		; create a new list to hold the reverse nibbles
		result := new MfNibbleList()
		
		
		x := ans.Count - 1
		if (TrimLeadingZeros = true)
		{
			while ((x < 0) && (ans.Item[x] = 0))
			{
				x--
			}
		}
		i := x
		if (SignFinalCarry = true)
		{
			if (HasFinalCarry = true)
			{
				result.Add(1)
			}
			else
			{
				result.Add(0)
			}

		}
		while i >= 0
		{
			result.Add(ans.Item[i])
			i--
		}
		if (result.Count = 0)
		{
			result.Add(0)
		}
		return result
		
	}
; 	End:_NibListsAdd ;}
;{ 	_NibListMultiplyByNib
	_NibListMultiplyByNib(lst, iNib, ShiftAmount=0) {
		ans := new MfNibbleList()
		iCarry := 0
		i := lst.Count - 1
		bZero := true
		while i >= 0
		{
			n := lst.Item[i]
			p := (n * iNib) + iCarry
			R := 0
			iCarry := 0
			if (p > 0)
			{
				bZero := false
				iCarry := MfMath.DivRem(p, 16, R)
			}
			ans.Add(R)
			i--
		}
		if (bZero)
		{
			ans.Clear()
			ans.Add(0)
			return ans
		}
		While (iCarry > 0)
		{
			iCarry := MfMath.DivRem(iCarry, 16, R)
			ans.Add(R)
		}
		x := ans.count -1
		while ans.Item[x] = 0 && x >= 0
		{
			x--
		}
		result := new MfNibbleList()
		i := x
		while i >= 0
		{
			result.Add(ans.Item[i])
			i--
		}
		
		i := 0
		while i < ShiftAmount
		{
			result.Add(0)
			i++
		}
		
		return result
	}
; 	End:_NibListMultiplyByNib ;}
;{ 	_MultiplyNibList
	_MultiplyNibList(lstA, lstB){
		; Order of array is expected to be left to right making lst.Count -1 the MSB
		; in this method LstA.count is excpected to be Greater then or equal to  lstB.Count
		; lstB.Count tells us how many arrays will need to be added together in the end
		; lstA to be Multiplied by lstB
		lst := new MfList()
	
		iMaxIndexA := lstA.Count - 1
		iMaxIndexB := lstB.Count - 1
		
		x := 0
		While ((x < lstB.Count) && (lstB.Item[x] = 0))
		{
			x++
		}

		if (x >= lstB.Count)
		{
			return lstA
		}
		iStartIndexA := x
		i := iMaxIndexB
		iCount := 0
		jCount := 0
		While i >= iStartIndexA
		{
			n := lstB.Item[i]
			iResult := MfNibConverter._NibListMultiplyByNib(lstA, n, iCount)
			lst.Add(iResult)
			iCount ++
			i--
		}
		if (lst.Count = 0)
		{
			retval := new MfNibbleList()
			retval.Add(0)
			return retval
		}
		
		if (lst.Count = 1)
		{
			return lst.Item[0]
		}
		
		return MfNibConverter._AddListOfNib(lst)
		
	}
; 	End:_MultiplyNibList ;}
;{ 	_AddListOfNib
;{ 	_AddListOfNib
	; adds a list of MfNibbleList together and returns a result as MfNibbleList
	; lst is an instance of MfList containing one or more MfNibbleList
	; if AsSigned is true then each MfNibbleList in lst is treated as signed and
	; can be negative or positive
	_AddListOfNib(lst, AsSigned=true) {
		if (lst.Count = 1)
		{
			return lst.Item[0]
		}
		
		if (lst.Count = 0)
		{
			ans := new MfNibbleList()
			ans.Add(0)
			return ans
		}
		NegList := ""
		PosList := new MfList
		if (AsSigned = true)
		{
			NegList := new MfList()
			i := 0
			while i < lst.Count
			{
				nList := lst.Item[i]
				if (MfNibConverter.IsNegative(nList))
				{
					NegList.Add(nList)
				}
				else
				{
					PosList.Add(nList)
				}
				i++
			}
			if (NegList.Count = 0)
			{
				return MfNibConverter._AddListOfNibUnsigned(PosList)
			}
			if (PosList.Count = 0)
			{
				return MfNibConverter._SubTractListOfNibUnsigned(NegList)
			}
		}
		else
		{
			return MfNibConverter._AddListOfNibUnsigned(lst)
		}
		PosResult := MfNibConverter._AddListOfNibUnsigned(PosList)
		NegResult := MfNibConverter._SubTractListOfNibUnsigned(NegList)

		NegResultTwo := MfNibConverter.ToComplement16(NegResult) ; abs value
		Compare := MfNibConverter.CompareUnsignedList(PosResult, NegResultTwo)
		if (Compare = 0)
		{
			retval := new MfNibbleList()
			If (PosResult.Count > NegResultTwo.Count)
			{
				i := 0
				while i < PosResult.Count
				{
					retval.Add(0)
					i++
				}
				return retval
			}
			i := 0
			while i < NegResultTwo.Count
			{
				retval.Add(0)
				i++
			}
			return retval
		}
	
		if (Compare > 0)
		{
			return MfNibConverter._SubtractNibbles(PosResult, NegResultTwo)
		}
		; return valu must be negative
		retval := MfNibConverter._SubtractNibbles(PosResult, NegResultTwo)
		return MfNibConverter.ToComplement16(retval)
	}
; 	End:_AddListOfNib ;}
	; adds n number MfNibbleList together and returs a MfNibbleList as result
	; assumes all MfNibbleList item is lst are in positve format
	; Parameter lst - MfList of MfNibbleList
	_AddListOfNibUnsigned(lst) {
		if (lst.Count = 1)
		{
			return lst.Item[0]
		}
		ans := new MfNibbleList()
		if (lst.Count = 0)
		{
			ans.Add(0)
			return ans
		}
					
		indexLong := 0
		IndexCount := 0
		i := 0
		; find the list with the longest count
		while i < lst.Count
		{
			if (lst.Item[i].Count > IndexCount)
			{
				IndexCount := lst.Item[i].Count
				indexLong := i
			}
			i++
		}
		IndexCount := ""
		fLst := lst.RemoveAt(indexLong) ; remove the list with the highest count and capture it
		i := fLst.Count - 1
		iCount := 0
		iCarry := 0
		while i >= 0
		{
			sum := fLst.Item[i] + iCarry
			iCarry := 0
			j := 0
			while j < lst.Count
			{
				nLst := lst.Item[j]
				if (iCount >= nLst.Count)
				{
					j++
					continue
				}
				offset := fLst.Count - nLst.Count
				k := i - offset
				sum += nLst.Item[k]
				j++
			}
			iCarry := MfMath.DivRem(sum, 16, R)
			If (ans.Count > 0)
			{
				ans.Insert(0, R)
			}
			else
			{
				ans.Add(R)
			}
			i--
			iCount++
		}
		while iCarry > 0
		{
			iCarry := MfMath.DivRem(iCarry, 16, R)
			If (ans.Count > 0)
			{
				ans.Insert(0, R)
			}
			else
			{
				ans.Add(R)
			}
		}
		return ans
	}
; 	End:_AddListOfNib ;}
	_SubtractNibbles(nibsA, nibsB) {
		; assumes nibsA is larger then nibsB

		; step 1 find complement of value to be subtracted
		; step 2 add the values together
		; step 3
		;    if there is a carry just drop it and return the results
		;    if there is no carry get complement and return
		bFlip :=  MfNibConverter.ToComplement16(nibsB)
		if (nibsA.Count > bFlip.Count)
		{
			result := MfNibConverter._NibListsAdd(nibsA, bFlip, true, true)
		}
		Else
		{
			result := MfNibConverter._NibListsAdd(bFlip, nibsA, true, true)
		}
		
		

		nib := result.Item[0]
		retval := new MfNibbleList()
		if (nib = 1)
		{
			if (result.Count = 1)
			{
				retval.Add(0)
				return retval
			}
			i := 1
			while (i < result.Count)
			{
				retval.Add(result.Item[i])
				i++
			}
			return retval
		}
		if (result.Count = 1)
		{
			retval.Add(0)
			return retval
		}
		i := 1
		while (i < result.Count)
		{
			retval.Add(result.Item[i])
			i++
		}
		return MfNibConverter.ToComplement16(retval)
	}

;{ 	_SubTractListOfNibUnSigned
	; assumes all MfNibbleList item is lst are in negative format
	_SubTractListOfNibUnSigned(lst) {
		if (lst.Count = 1)
		{
			return lst.Item[0]
		}
		
		if (lst.Count = 0)
		{
			ans := new MfNibbleList()
			ans.Add(0)
			return ans
		}
		
		i := 0
		while i < lst.Count
		{
			nList := lst.Item[i]
			lst.Item[i] := MfNibConverter.ToComplement16(nList)
			i++
		}
		ans := MfNibConverter._AddListOfNibUnsigned(lst)
		
		return MfNibConverter.ToComplement16(ans)
	}
; 	End:_SubTractListOfNibUnSigned ;}
;{ _GetHexValue
	_GetHexValue(i)	{
		iChar := 0
		if (i < 10)
		{
			iChar := i + 48
		}
		else
		{
			iChar := (i - 10) + 65
		}
		return Chr(iChar)
	}
; End:_GetHexValue ;}
;{ 	_GetBytesInt
	_GetBytesInt(value, bitCount = 32) {
		If (bitCount < 2 )
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Under", "2"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Mod(bitCount, 2))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Not_Divisable_By", "2"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if (bitCount > 64)
		{
			nib := ""
			if (MfNibConverter._HexValueToHexArray(value, nib, bitCount))
			{
				; if hex value is passed in will handled in formfat of 0x or -0x
				return nib
			}
			; will handle negative and positive and convert to Little Endian
			return MfNibConverter._LongIntStringToHexArray(value, bitCount)
		}
		; this method is fast for hex or integer but is limited to Int64
		return MfNibConverter._IntToHexArray(value, bitCount)

	}
; 	End:_GetBytesInt ;}
;{ 	_LongIntStringToHexArray
	_HexValueToHexArray(value, ByRef nibs, bitCount:=64) {
		mStr := MfMemoryString.FromAny(value)
		IsNeg := false
		foundHex := false
		if (mStr.StartsWith("0x", false))
		{
			foundHex := true
			mStr.Remove(0,2)
		}
		if (foundHex = false && mStr.StartsWith("-0x", false))
		{
			foundHex := true
			IsNeg := true
			mStr.Remove(1,2)
		}
		if (!foundHex)
		{
			return false
		}
		If (bitCount < 4 )
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Under", "2"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Mod(bitCount, 4))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Not_Divisable_By", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ActualBitCount := bitCount // 4

		nibs := MfNibConverter._HexStringToNibList(mStr.ToString(), ActualBitCount,ActualBitCount, false)
		return true
		
	}
	_LongIntStringToHexArrayTest(obj, bitCount = 64) {
		If (bitCount < 4 )
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Under", "2"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Mod(bitCount, 4))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Not_Divisable_By", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ActualBitCount := bitCount // 4
		mStr := MfMemoryString.FromAny(obj)
		IsNeg := false
		if (mStr.StartsWith("-"))
		{
			IsNeg := true
			mStr.Remmove(0, 1)
		}
		bigx := MfBigMathInt.Str2bigInt(mStr.ToString(),10, 3)
		;bigx := MfBigInt.Parse(obj) ; base 10 Parse
		
		strHex := MfBigMathInt.BigInt2str(bigx, 16)
		if (IsNeg)
		{
			strHex := "-" . strHex
		}
		; if (IsNeg)
		; {
		; 	strHex := MfByteConverter.FlipHexString(strHex)
		; }
		ans := MfNibConverter._HexStringToNibList(strHex, ActualBitCount,ActualBitCount, false)
		; if (IsNeg)
		; {
		; 	MfNibConverter._AddOneToNibListValue(ans)
		; }
		return ans
	}
	_LongIntStringToHexArray(obj, bitCount = 64) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		If (bitCount < 2 )
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Under", "2"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Mod(bitCount, 2))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Not_Divisable_By", "2"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ActualBitCount := bitCount // 2

		ans := new MfNibbleList()
		if (IsObject(obj))
		{
			if(MfObject.IsObjInstance(obj, MfIntList) = false)
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "obj"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (obj.Count = 0)
			{
				ans._Add(0)
				return ans
			}
			sInt := obj.ToString()
		}
		else
		{
			sInt := obj

		}
		IsNeg := False
		if (MfMath._IsStringInt(sInt, IsNeg) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (IsNeg = true)
		{
			sInt := SubStr(sInt, 2)
		}
		else
		{
			if (SubStr(sInt, 1, 1) = "+")
			{
				sInt := SubStr(sInt, 2)
			}
		}
		stack := new MfStack()
		
		iCarry := MfMath.DivRem(sInt, 16 , R)
		stack.Push(R)
		While (MfMath.IntGreaterThen(iCarry, 0)) ; use MfMath to support long int string
		{
			iCarry := MfMath.DivRem(iCarry, 16, R)
			stack.Push(R)
		}
		iCount := stack.Count + 1
		while (iCount * 2) < ActualBitCount
		{
			ans.Add(0)
			iCount++
		}
		; push zero onto the stack as the last value
		; if value is negative then will flip to 0xf otherwise will stay 0x0
		; this is the MSB and signes negative or positive
		stack.Push(0)
		;stack.Push(0)

		
		While stack.Count > 0
		{
		   ans.Add(stack.Pop())
		}

		if (IsNeg = true)
		{
			ans :=  MfNibConverter._FlipNibbles(ans)
			MfNibConverter._AddOneToNibListValue(ans)
			return ans
		}
		return ans
	}
; 	End:_LongIntStringToHexArray ;}
;{ 	_IntToHexArray
	_IntToHexArray(value, bitCount = 64) {
		If (bitCount < 2 )
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Under", "2"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Mod(bitCount, 2))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Not_Divisable_By", "2"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		r := ""
		retval := ""
		
		IsNegative := false
		nArray := new MfNibbleList()
		ActualBitCount := bitCount // 2
		MaxMinValuCorrect := false
		if (value = 0)
		{
			while (nArray.Count * 2) < ActualBitCount
			{
				nArray._Add(0)
			}
			return nArray
		}
		if (value < 0)
		{
			IsNegative := true
			; The Absolute value of MfInt64.MinValue is 1 greater then then MfInt64.MaxValue
			; therefore Abs(MfInt64.MinValue) will return the same negative value
			; to get around this add 1 if value = MfInt64.MinValue and subtact if from the bit array
			; this is a one off case and only happens when value is max int min value.
			if (value = MfInt64.MinValue)
			{
				Result := Abs((value + 1))
				MaxMinValuCorrect := true
			}
			else
			{
				Result := Abs(value)
			}
		}
		else
		{
			Result := value
		}
		while Result > 0
		{
			
			
			i := 0
			MSB := ""
			LSB := ""
			while i < 2
			{
				byte := ""
				if (Result = 0)
				{
					break
				}
				r := Mod(Result, 16)
				Result := Result // 16
				
				if (r <= 9)
				{
					byte := r
				}
				else if (r = 10)
				{
					byte := "A"
				}
				else if (r = 11)
				{
					byte := "B"
				}
				else if (r = 12)
				{
					byte := "C"
				}
				else if (r = 13)
				{
					byte := "D"
				}
				else if (r = 14)
				{
					byte := "E"
				}
				else
				{
					byte := "F"
				}
				if (i = 0)
				{
					LSB := byte
				}
				else
				{
					MSB := byte
					MsbInfo := MfNibConverter.HexBitTable[MSB]
					LsbInfo := MfNibConverter.HexBitTable[LSB]
					nArray._Add(LsbInfo.IntValue)
					nArray._Add(MsbInfo.IntValue)
				}
				if ((Result = 0) && (i = 0))
				{
					LsbInfo := MfNibConverter.HexBitTable[LSB]
					nArray._Add(LsbInfo.IntValue)
					nArray._Add(0)
				}
				i++
			}
		}
		
				
		if (IsNegative)
		{
			while (nArray.Count * 2) < ActualBitCount
			{
				nArray._Add(0)
			}
			nArray := MfNibConverter._ReverseList(nArray)
			; flip all the bits
			nArray := MfNibConverter._FlipNibbles(nArray)

			if (MaxMinValuCorrect = False)
			{
				;~ ; when negative Add 1
				IsAdded := MfNibConverter._AddOneToNibList(nArray, false)
			}
		}
		else ; if (IsNegative)
		{
			; add zero's to end of postivie array
			while (nArray.Count * 2) < ActualBitCount
			{
				nArray.Add(0)
			}
			nArray := MfNibConverter._ReverseList(nArray)
		}
		return nArray
	}
; 	End:_IntToHexArray ;}
;{ 	_CharCodeToInt
	; gets integer value from charCode for hex values
	_CharCodeToInt(cc) {
		if (cc >= 48 && cc <= 57) ; 0 - 9
		{
			return cc - 48
		}
		if (cc >= 65 && cc <= 70) ; A - F
		{
			return cc - 55
		}
		if (cc >= 97 && cc <= 102) ; a - f
		{
			return cc - 87
		}
	}
; 	End:_CharCodeToInt ;}

;{ 	_IsValidHexChar
	; gets if a charCode is a valid hex charcode
	_IsValidHexChar(cc) {
		if ((cc >= 48 && cc <= 57) || (cc >= 65 && cc <= 70) || (cc >= 97 && cc <= 102))
		{
			return true
		}
		return false
	}
; 	End:_IsValidHexChar ;}
	_HexStringToNibList(value, NibbleCountMin:=0,NibbleCountMax:=0, DefaultSigned:=false) {
		IsNeg := False
		hStr := new MfString(value)
		hStr.TrimStart()
		IsSigned := false
		if (hStr.StartsWith("-"))
		{
			IsNeg := true
			IsSigned := true
			hstr.Remove(0,1)
		}
		else if (hStr.StartsWith("+"))
		{
			IsSigned := true
			hStr.Remove(0,1)
		}
		if (hStr.StartsWith("0x"))
		{
			IsSigned := true
			hStr.Remove(0,2)
		}
		mStr := MfMemoryString.FromAny(hStr)
		if (mStr.Length = 0)
		{
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_BadHex"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
		If (Signed = false && DefaultSigned = false)
		{
			Signed := true
		}
		If (Signed = false)
		{
			; if hex value is not sigend then get the signed value from the first nibble
			For i, c in mStr
			{
				if (MfNibConverter._IsValidHexChar(c))
				{
					info := MfNibConverter.CharHexBitTable[c]
					IsNeg := info.IsNeg
					break
				}
			}
		}
		result := new MfMemoryString(mStr.Length,, "UTF-8")

		iCount := 0
		if (IsNeg = true ) {
			For i, c in mStr
			{
				if (MfNibConverter._IsValidHexChar(c))
				{
					if (NibbleCountMax > 0 && iCount >= NibbleCountMax)
					{
						break
					}
					info := MfNibConverter.CharHexBitTable[c]
					result.AppendCharCode(info.HexFlip)
					iCount++
				}
			}
		}
		else
		{
			For i, c in mStr
			{
				if (MfNibConverter._IsValidHexChar(c))
				{
					if (NibbleCountMax > 0 && iCount >= NibbleCountMax)
					{
						break
					}
					result.AppendCharCode(c)
					iCount++
				}
			}
		}
		if (result.Length = 0)
		{
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_BadHex"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
		listLength := result.Length
		Offset := 0
		if (listLength < NibbleCountMin)
		{
			Offset := NibbleCountMin - listLength
		}
		lst := new MfNibbleList(listLength + Offset, IsNeg?15:0)
		;inLst := lst.m_InnerList
		
		i := 0
		inLst := lst.m_InnerList
		Offset++ ; move to one base index
		While (i < listLength)
		{
			inLst[i + offset] := MfNibConverter._CharCodeToInt(result.CharCode[i])
			i++
		}
		if (IsNeg)
		{
			MfNibConverter._AddOneToNibListValue(lst) ; make complements16
		}
		
		return lst
	}
	
;{ _ReverseList
	_ReverseList(lst) {
		iCount := lst.m_Count
		nArray := new MfNibbleList()
		lstIn := lst.m_InnerList
		nLst := nArray.m_InnerList
		i := 1
		While (iCount > 0)
		{
			nLst[i] := lstIn[iCount]
			i++
			iCount--
		}
		nArray.m_Count := lst.m_Count
		return nArray
	}
; End:_ReverseList ;}
; End:Internal Methods ;}
;{ Properties
	;{ IsLittleEndian
		/*!
			Property: IsLittleEndian [get]
				Indicates the byte order ("endianness") in which data is stored in this computer architecture
			Value:
				Var representing the IsLittleEndian property of the instance
			Remarks:
				Readonly Property
				Returns false
		*/
		IsLittleEndian[]
		{
			get {
				return false
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "IsLittleEndian")
				Throw ex
			}
		}
	; End:IsLittleEndian ;}
	
	;{ CharHexBitTable
		static m_CharHexBitTable := ""
		/*!
			Property: CharHexBitTable [get]
				Gets the CharHexBitTable value associated with the this instance
			Value:
				Var representing the CharHexBitTable property of the instance
			Remarks:
				Readonly Property
		*/
		CharHexBitTable[charIndex]
		{
			get {
				if (MfNibConverter.m_CharHexBitTable = "")
				{
					MfNibConverter.m_CharHexBitTable := New MfList()
					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(48, 70, "0"))
					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(49, 69, "1"))
					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(50, 68, "2"))
					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(51, 67, "3"))
					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(52, 66, "4"))
					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(53, 65, "5"))
					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(54, 57, "6"))
					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(55, 56, "7"))

					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(56, 55, "8", true))
					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(57, 54, "9", true))
					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(65, 53, "A", true))
					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(66, 52, "B", true))
					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(67, 51, "C", true))
					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(68, 50, "D", true))
					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(69, 49, "E", true))
					MfNibConverter.m_CharHexBitTable.Add(new MfNibConverter.CharHexBitInfo(70, 48, "F", true))
				}
				index := -1
				if (charIndex >= 48 && charIndex <= 57)
				{
					index := charIndex - 48
				}
				else if (charIndex >= 65 && charIndex <= 70)
				{
					index := charIndex - 55
				}
				else if (charIndex >= 97 && charIndex <= 102)
				{
					index := charIndex - 87
				}
				if (index < 0 || index > 15)
				{
					ex := new MfIndexOutOfRangeException(MfEnvironment.Instance.GetResourceString("Arg_IndexOutOfRangeException"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				index++ ; move to one base
				return MfNibConverter.m_CharHexBitTable.m_InnerList[index]
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "CharHexBitTable")
				Throw ex
			}
		}
	; End:CharHexBitTable ;}
	;{ HexBitTable
		static m_HexBitTable := ""
		/*!
			Property: HexBitTable [get]
				Gets the HexBitTable value associated with the this instance
			Value:
				Var representing the HexBitTable property of the instance
			Remarks:
				Readonly Property
		*/
		HexBitTable[key]
		{
			get {
				if (MfNibConverter.m_HexBitTable = "")
				{
					MfNibConverter.m_HexBitTable := new MfHashTable(16)
					MfNibConverter.m_HexBitTable.Add("0", new MfNibConverter.HexBitInfo("0", "F", "0000","1111", 0))
					MfNibConverter.m_HexBitTable.Add("1", new MfNibConverter.HexBitInfo("1", "E", "0001","1110", 1))
					MfNibConverter.m_HexBitTable.Add("2", new MfNibConverter.HexBitInfo("2", "D", "0010","1101", 2))
					MfNibConverter.m_HexBitTable.Add("3", new MfNibConverter.HexBitInfo("3", "C", "0011","1100", 3))
					MfNibConverter.m_HexBitTable.Add("4", new MfNibConverter.HexBitInfo("4", "B", "0100","1011", 4))
					MfNibConverter.m_HexBitTable.Add("5", new MfNibConverter.HexBitInfo("5", "A", "0101","1010", 5))
					MfNibConverter.m_HexBitTable.Add("6", new MfNibConverter.HexBitInfo("6", "9", "0110","1001", 6))
					MfNibConverter.m_HexBitTable.Add("7", new MfNibConverter.HexBitInfo("7", "8", "0111","1000", 7))

					MfNibConverter.m_HexBitTable.Add("8", new MfNibConverter.HexBitInfo("8", "7", "1000","0111", 8, true))
					MfNibConverter.m_HexBitTable.Add("9", new MfNibConverter.HexBitInfo("9", "6", "1001","0110", 9, true))
					MfNibConverter.m_HexBitTable.Add("A", new MfNibConverter.HexBitInfo("A", "5", "1010","0101", 10, true))
					MfNibConverter.m_HexBitTable.Add("B", new MfNibConverter.HexBitInfo("B", "4", "1011","0100", 11, true))
					MfNibConverter.m_HexBitTable.Add("C", new MfNibConverter.HexBitInfo("C", "3", "1100","0011", 12, true))
					MfNibConverter.m_HexBitTable.Add("D", new MfNibConverter.HexBitInfo("D", "2", "1101","0010", 13, true))
					MfNibConverter.m_HexBitTable.Add("E", new MfNibConverter.HexBitInfo("E", "1", "1110","0001", 14, true))
					MfNibConverter.m_HexBitTable.Add("F", new MfNibConverter.HexBitInfo("F", "0", "1111","0000", 15, true))
				}
				return MfNibConverter.m_HexBitTable.Item[key]
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "HexBitTable")
				Throw ex
			}
		}
	; End:HexBitTable ;}
; End:Properties ;}
;{ Internal Class HexBitInfo
	class HexBitInfo
	{
		__new(hv, hf, b, bf, int, Neg = false) {
			this.HexValue := hv
			this.HexFlip := hf
			this.Bin := b
			this.BinFlip := bf
			this.IntValue := int
			this.IsNeg := Neg
		}
		HexValue := ""
		HexFlip := ""
		Bin := ""
		BinFlip := ""
		IsNeg := False
		IntValue := ""
	}
	class CharHexBitInfo
	{
		__new(hv, hf, c,Neg = false) {
			this.HexValue := hv
			this.HexFlip := hf
			this.Char := c
			this.IsNeg := Neg
		}
		HexValue := ""
		HexFlip := ""
		IsNeg := False
		Char := ""
	}
	
; End:Internal Class HexBitInfo ;}
}