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

class MfBinaryConverter extends MfObject
{
	
;{ Methods
;{ 	BitAnd
	BitAnd(bitsA, bitsB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bitsA, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bitsA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(bitsB, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bitsB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ans := new MfBinaryList()
		if(bitsA.Count > bitsB.Count)
		{
			bitsB := MfBinaryConverter.Expand(bitsB, BitsA.Count, true)
		}
		else if(bitsB.Count > bitsA.Count)
		{
			bitsA := MfBinaryConverter.Expand(bitsA, BitsB.Count, true)
		}
		ansl := ans.m_InnerList
		la := bitsA.m_InnerList
		lb := bitsB.m_InnerList
		i := 1
		lstCount := bitsA.Count
		while (i <= lstCount)
		{
			if (la[i] && lb[i])
			{
				ansl[i] := 1
			}
			else
			{
				ansl[i] := 0
			}
			i++
		}
		ans.m_Count := lstCount
		return ans
	}
; 	End:BitAnd ;}
;{ 	BitNot
	BitNot(bits) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ans := new MfBinaryList()
		ansl := ans.m_InnerList
		la := bits.m_InnerList
		
		i := 1
		lstCount := bits.Count
		while (i <= lstCount)
		{
			if (la[i])
			{
				ansl[i] := 0
			}
			else
			{
				ansl[i] := 1
			}
			i++
		}
		ans.m_Count := lstCount
		return ans
	}
; 	End:BitNot ;}
;{ 	BitOr
	BitOr(bitsA, bitsB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bitsA, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bitsA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(bitsB, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bitsB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ans := new MfBinaryList()
		if(bitsA.Count > bitsB.Count)
		{
			bitsB := MfBinaryConverter.Expand(bitsB, BitsA.Count, true)
		}
		else if(bitsB.Count > bitsA.Count)
		{
			bitsA := MfBinaryConverter.Expand(bitsA, BitsB.Count, true)
		}
		ansl := ans.m_InnerList
		la := bitsA.m_InnerList
		lb := bitsB.m_InnerList
		i := 1
		lstCount := bitsA.Count
		while (i <= lstCount)
		{
			if (la[i] || lb[i])
			{
				ansl[i] := 1
			}
			else
			{
				ansl[i] := 0
			}
			i++
		}
		ans.m_Count := lstCount
		return ans
	}
; 	End:BitOr ;}
;{ 	BitXor
	BitXor(bitsA, bitsB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bitsA, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bitsA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(bitsB, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bitsB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ans := new MfBinaryList()
		if(bitsA.Count > bitsB.Count)
		{
			bitsB := MfBinaryConverter.Expand(bitsB, BitsA.Count, true)
		}
		else if(bitsB.Count > bitsA.Count)
		{
			bitsA := MfBinaryConverter.Expand(bitsA, BitsB.Count, true)
		}
		ansl := ans.m_InnerList
		la := bitsA.m_InnerList
		lb := bitsB.m_InnerList
		i := 1
		lstCount := bitsA.Count
		while (i <= lstCount)
		{
			if (la[i] && lb[i])
			{
				ansl[i] := 0
			}
			else if (!la[i] && !lb[i])
			{
				ansl[i] := 0
			}
			else
			{
				ansl[i] := 1
			}
			i++
		}
		ans.m_Count := lstCount
		return ans
	}
; 	End:BitXor ;}
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
		if (_MinCount > 0)
		{
			While (Mod(_MinCount, 4))
			{
				_MinCount++
			}
			_MinCount := _MinCount // 4
		}
		if (_MaxCount > 0)
		{
			While (Mod(_MaxCount, 4))
			{
				_MaxCount++
			}
			_MaxCount := _MaxCount // 4
		}
		Nibbles := MfNibConverter.FromHex(value, _MinCount, _MaxCount)
		return MfNibConverter.ToBinaryList(Nibbles, true)
	}
; 	End:FromHex ;}
;{ 	GetBits
	GetBits(obj) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!IsObject(obj))
		{
			Nibbles := MfNibConverter.GetNibbles(obj)
			return MfNibConverter.ToBinaryList(Nibbles)
		}
		ObjCheck := MfBinaryConverter._IsNotMfObj(obj)
		if (ObjCheck)
		{
			ObjCheck.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ObjCheck
		}
		if (MfObject.IsObjInstance(obj, MfBool))
		{
			if (obj.Value = true)
			{
				return MfBinaryConverter._GetBytesInt(1, 1, true)
			}
			return MfBinaryConverter._GetBytesInt(0, 1, true)
		}
		else if (MfObject.IsObjInstance(obj, MfByte))
		{
			return MfBinaryConverter._GetBytesInt(obj.Value, 8)
		}
		else if (MfObject.IsObjInstance(obj, MfSByte))
		{
			return MfBinaryConverter._GetBytesInt(obj.Value, 8)
		}
		else if (MfObject.IsObjInstance(obj, MfInt16))
		{
			return MfBinaryConverter._GetBytesInt(obj.Value, 16)
		}
		else if (MfObject.IsObjInstance(obj, MfUInt16))
		{
			return MfBinaryConverter._GetBytesInt(obj.Value, 16)
		}
		else if (MfObject.IsObjInstance(obj, MfInteger))
		{
			return MfBinaryConverter._GetBytesInt(obj.Value, 32)
		}
		else if (MfObject.IsObjInstance(obj, MfUInt32))
		{
			return MfBinaryConverter._GetBytesInt(obj.Value, 32)
		}
		else if (MfObject.IsObjInstance(obj, MfInt64))
		{
			return MfBinaryConverter._GetBytesInt(obj.Value, 64)
		}
		else if (MfObject.IsObjInstance(obj, MfFloat))
		{
			
			wf := A_FormatFloat
			
			try
			{
				fmt := obj.Format
				Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, obj.Format)
				
				int := MfByteConverter._FloatToInt64(obj.Value)
				return MfBinaryConverter._GetBytesInt(int, 64)
			}
			catch e
			{
				ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			finally
			{
				Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wf)
			}
			
		}
		else if (MfObject.IsObjInstance(obj, MfUInt64))
		{
			bigx := obj.m_bigx
			bytes := MfBinaryConverter._GetBytesBinary(bigx.ToString(2), 64)
			return bytes
			;return MfBinaryConverter._GetBytesUInt(obj.Value, 64)
		}
		else if (MfObject.IsObjInstance(obj, MfBigInt))
		{
			byteCount :=  obj.BitSize + 1 ; pad to allow for MSB
			objNeg := obj.IsNegative
			obj.IsNegative := false
			while (mod(byteCount, 4))
			{
				byteCount++
			}
			bytes := MfBinaryConverter._GetBytesBinary(obj.ToString(2), byteCount)
			if (objNeg)
			{
				; flip the bits
				bytes := MfBinaryConverter.ToComplement2(bytes)
			}
			obj.IsNegative := objNeg
			return bytes
		}

		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:GetBits ;}
;{ 	GetBinaryChars
/*
	Method: GetBinaryChars()

	GetBinaryChars()
		Gets a string of only Binary chars from input.
		All non binary chars are ignored only 0-1 are returned
	Parameters:
		binInput
			The input containing the hex string
			Can be var or any supported MfObject including MfString, StringBuilder, MfCharList and MfByteList
		ReturnAsObj
			Optional. Default is false
			If true then instance of MfString is returned otherwise false
	Returns:
		Returns var string  or MfString instance of binary chars
		Returns empty string or Empty MfString if binInput has no valid hex chars
		If there valid binary char then will always return a multiple of 4,
			for intance if binInput is 11 then return will be 0011, input 10001 will return 00010001
	Remarks:
		Static Method
		If binInput is Instance of MfMemoryString then instance of MfMemoryString is returned,
		even if ReturnAsObj is true
*/
	GetBinaryChars(binInput, ReturnAsObj:=false, GroupingCount:=4) {
		ReturnAsObj := MfBool.GetValue(ReturnAsObj, true)
		GroupingCount := MfInt16.GetValue(GroupingCount,4)
		if (GroupingCount < 0)
		{
			ex := new MfArgumentOutOfRangeException("GroupingCount", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_GenericPositive"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		returnString := true
		if (MfObject.IsObjInstance(binInput, MfMemoryString))
		{
			returnString := false
		}
		mStr := MfMemoryString.FromAny(binInput)
		if (mStr.Length = 0)
		{
			if (returnString)
			{
				return ReturnAsObj? new MfString("", true) : ""
			}
			return MfMemoryString.FromAny("")
		}
		
		sb := new MfText.StringBuilder(mStr.Length + GroupingCount)
		; HasLeadingChar  will only be true when the first non-zero value char is added
		; this avoids having to trim leading zero's later
		HasLeadingChar := false
		for i, c in mStr
		{
			if (c = 48)
			{
				if (HasLeadingChar = true)
				{
					sb._AppendCharCode(c)
				}
			}
			else if (c = 49)
			{
				HasLeadingChar := true
				sb._AppendCharCode(c)
			}
		}
		; add one zero if thre are no chars
		if (HasLeadingChar = false)
		{
			;sb._AppendCharCode(48, 4)
			if (returnString)
			{
				return ReturnAsObj? new MfString("", true) : ""
			}
			return MfMemoryString.FromAny("")
		}
		str := sb.ToString()
		r := mod(sb.Length, GroupingCount)
		if (r > 0)
		{
			mStr := new MfMemoryString(r)
			mStr.AppendCharCode(48, GroupingCount - r)
			sb._InsertObjInt(0, mstr, 1)
			mStr := ""
		}
		str2 := sb.ToString()

		if (returnString)
		{
			return sb.ToString(ReturnAsObj)
		}
		return MfMemoryString.FromAny(sb)
	}
; 	End:GetBinaryChars ;}
;{ 	BinaryStringToHex
/*
	Method: BinaryStringToHex()

	BinaryStringToHex()
		Converts a binary string to hex values
	Parameters:
		str
			The String to conver from hex to binary.
			Can be string var or instance of MfString
		RetrunAsObj
			Optional; Default is false
			If true then an instance of MfString is returned containing the hex;
			Otherwise a string var is returned
	Returns:
		Returns If RetrunAsObj is true then instance of MfString; Otherwise string var
	Remarks:
		Statice Method
*/
	BinaryStringToHex(str, RetrunAsObj:=false) {
		RetrunAsObj := MfBool.GetValue(RetrunAsObj, False)
		_str := new MfString(str, true)
		if (_str.Length = 0)
		{
			if (RetrunAsObj)
			{
				return new MfString("0", true)
			}
			return "0"
		}
		_str.Value :=  MfBinaryConverter.GetBinaryChars(_str.Value,,4)
		if (_str.Length = 0)
		{
			if (RetrunAsObj)
			{
				return new MfString("0", true)
			}
			return "0"
		}
		sb := new MfText.StringBuilder(_str.Length // 4)
		enum := _str.GetEnumerator()
		iCount = 0
		while (enum.Next(i, c))
		{
			if (iCount = 0)
			{
				strbin := ""
			}
			strbin .= c
			iCount++
			if (iCount = 4)
			{
				iCount = 0
				bInfo := MfBinaryConverter.ByteTable[strBin]
				sb.AppendString(bInfo.HexValue)

			}
		}
		if (sb.Length = 0)
		{
			if (RetrunAsObj)
			{
				return new MfString("0", true)
			}
			return "0"
		}
		return sb.ToString(RetrunAsObj)
	}
; 	End:BinaryStringToHex ;}
;{ 	HexToBinaryString
/*
	Method: HexToBinaryString()

	HexToBinaryString()
		Converts a string of Hex into a binary string
	Parameters:
		str
			String containing hex values
		RetrunAsObj
			Optinal, default is false
			If true then an instance of MfString containing the binary values are returned;
			Otherwise a string var containing binary values are returned
	Returns:
		Returns string var or MfString intance containing binay values of str hex values
	Remarks:
		If hex value starts with - then complements16 is done before conversion to binary.
*/
	HexToBinaryString(str, RetrunAsObj:=false) {
		RetrunAsObj := MfBool.GetValue(RetrunAsObj, False)
		_str := new MfString(str, true)
		_str.TrimStart()

		if (_str.Length = 0)
		{
			if (RetrunAsObj)
			{
				return new MfString("0000", true)
			}
			return "0000"
		}
		if(_str.StartsWith("-"))
		{
			_str.Value := MfByteConverter.HexStringComplements16(_str, true)
		}
		else
		{
			_str.Value :=  MfByteConverter.GetHexChars(_str.Value)
		}
		if (_str.Length = 0)
		{
			if (RetrunAsObj)
			{
				return new MfString("0000", true)
			}
			return "0000"
		}
		sb := new MfText.StringBuilder(_str.Length * 4)
		enum := _str.GetEnumerator(true)
		while (enum.Next(i, c))
		{
			cInfo := MfNibConverter.CharHexBitTable[c]
			hexInfo := MfNibConverter.HexBitTable[cInfo.Char]
			sb.AppendString(hexInfo.Bin)
		}
		if (sb.Length = 0)
		{
			if (RetrunAsObj)
			{
				return new MfString("0000", true)
			}
			return "0000"
		}
		return sb.ToString(RetrunAsObj)
	}
; 	End:HexToBinaryString ;}

	;{ 	NumberComplement
	; Gets Number Complement 1. Same as C# ~10 (equals -11) or ~60 (equals -61)
	; If object is passed in then object is same type is passsed out
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
			blst := MfBinaryConverter._GetBytesInt(obj.Value, 16)
			bLstFlipped := MfBinaryConverter.ToComplement1(bLst)
			newObj := MfBinaryConverter.ToInt16(bLstFlipped,,true)
			newObj.ReturnAsObject := obj.ReturnAsObject
			return newObj
		}
		if (MfObject.IsObjInstance(obj, MfInteger))
		{
			bLst := MfBinaryConverter._GetBytesInt(obj.Value, 32)
			; MSB := blst.Item[0]
			; blst.RemoveAt(0)
			bLstFlipped := MfBinaryConverter.ToComplement1(bLst)
			; bLstFlipped.Insert(0, !MSB)
			newObj := MfBinaryConverter.ToInt32(bLstFlipped,,true)
			newObj.ReturnAsObject := obj.ReturnAsObject
			return newObj
		}
		if (MfObject.IsObjInstance(obj, MfInt64))
		{
			bLst := MfBinaryConverter._GetBytesInt(obj.Value, 64)
			bLstFlipped := MfBinaryConverter.ToComplement1(bLst)
			newObj := MfBinaryConverter.ToInt64(bLstFlipped,,true)
			newObj.ReturnAsObject := obj.ReturnAsObject
			return newObj
		}
		if (MfObject.IsObjInstance(obj, MfUInt64))
		{
			bigx := obj.m_bigx
			bLst := MfBinaryConverter._GetBytesBinary(bigx.ToString(2), 64)
			bLstFlipped := MfBinaryConverter.ToComplement1(bLst)
			newObj := MfBinaryConverter.ToUInt64(bLstFlipped,,true)
			newObj.ReturnAsObject := obj.ReturnAsObject
			return newObj
		}
		if (MfObject.IsObjInstance(obj, MfBigInt))
		{
			byteCount :=  obj.BitSize + 1 ; pad to allow for MSB
			objNeg := obj.IsNegative
			
			while (mod(byteCount, 4))
			{
				byteCount++
			}
			bytes := MfBinaryConverter._GetBytesBinary(obj.ToString(2), byteCount)
			bLstFlipped := MfBinaryConverter.ToComplement1(bytes)
			newObj := MfBinaryConverter.ToBigInt(bLstFlipped,,true)
			newobj.IsNegative := !objNeg
			return newObj
		}

		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:NumberComplement ;}
;{ 	BinaryStringComplements1
/*
	Method: BinaryStringComplements1()

	BinaryStringComplements1()
		Gets Complements1 binary string from input str
	Parameters:
		str
			string var or of MfString or hex number containing the hex value
		ReturnPureHex
			Optional, Default is False
			If True then all non binary chars are dropped and leading zeros are dropped from the output.
	Returns:
		Returns String var of hex in that represents the complements1 version of the str input
	Remarks:
		Static method
*/
	BinaryStringComplements1(str, ReturnPureBin:=false) {
		_str := MfString.GetValue(str)
		len := StrLen(_str)
		if (len = 0)
		{
			return ""
		}
		ReturnPureBin := MfBool.GetValue(ReturnPureBin, false)
		mStr := new MFMemoryString(len + 2,,"UTF-8")
		mStr.Append(_str)
		Skip := 0
		if (mStr.StartsWith("-", false) = true)
		{
			; negative hex is already complements 16 so remove one
			mStr.Remove(0,1)
			len--
			Skip := 0
			MfByteConverter._RemovOneFromBinString(mStr,,skip)
			if (ReturnPureBin)
			{
				mStr := MfBinaryConverter.GetBinaryChars(mStr)

			}
			if (mStr.Length = 0)
			{
				return "0000"
			}
			return mStr.ToString()
		}
		else if (mStr.StartsWith("+", false) = true)
		{
			mStr.Remove(0,1)
			Skip := 0
			len--
		}
		For i, c in mStr
		{
			If (i < Skip)
			{
				continue
			}
			if (c = 48)
			{
				mStr.CharCode[i] := 49
			}
			else if (c = 49)
			{
				mStr.CharCode[i] := 48
			}
		}
		mStr.CharPos := len
		if (ReturnPureBin)
		{
			mStr := MfBinaryConverter.GetBinaryChars(mStr)
		}
		if (mStr.Length = 0)
		{
			return "0000"
		}
		return mStr.ToString()
	}
; 	End:BinaryStringComplements1 ;}
;{ 	BinaryStringComplements2
/*
	Method: BinaryStringComplements2()

	BinaryStringComplements2()
		Gets Complements2 binary string from input str
	Parameters:
		str
			string var or of MfString or hex number containing the hex value
		ReturnPureHex
			Optional, Default is False
			If True then all non binary chars are dropped and leading zeros are dropped from the output.
	Returns:
		Returns String var of hex in that represents the complements1 version of the str input
	Remarks:
		Static method
*/
	BinaryStringComplements2(str, ReturnPureBin:=false) {
		_str := MfString.GetValue(str)
		len := StrLen(_str)
		if (len = 0)
		{
			return ""
		}
		ReturnPureBin := MfBool.GetValue(ReturnPureBin, false)
		mStr := new MFMemoryString(len + 2,,"UTF-8")
		mStr.Append(_str)
		Skip := 0
		if (mStr.StartsWith("-", false) = true)
		{
			; negative hex is already complements 16 so remove one
			mStr.Remove(0,1)
			len--
			Skip := 0
			if (ReturnPureBin)
			{
				mStr := MfBinaryConverter.GetBinaryChars(mStr)
			}
			if (mStr.Length = 0)
			{
				return "0000"
			}
			return mStr.ToString()
		}
		else if (mStr.StartsWith("+", false) = true)
		{
			mStr.Remove(0,1)
			Skip := 0
			len--
		}
		For i, c in mStr
		{
			If (i < Skip)
			{
				continue
			}
			if (c = 48)
			{
				mStr.CharCode[i] := 49
			}
			else if (c = 49)
			{
				mStr.CharCode[i] := 48
			}
		}
		mStr.CharPos := len
		MfBinaryConverter._AddOneToBinString(mStr,,skip)
		if (ReturnPureBin)
		{
			mStr := MfBinaryConverter.GetBinaryChars(mStr)
		}
		if (mStr.Length = 0)
		{
			return "0000"
		}
		return mStr.ToString()
	}
; 	End:BinaryStringComplements2 ;}
;{ 	Expand
	; return a copy of x with at least n elements, adding leading zeros if needed
	Expand(bits, n, UseMsb=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		n := MfInteger.GetValue(n, 0)
		UseMsb := MfBool.GetValue(UseMsb, true)
		MSB := 0
		if (UseMsb = true && bits.Count > 0)
		{
			MSB := bits.Item[0]
		}
		
		If (bits.Count >= n)
		{
			return bits.Clone()
		}
		diff := n - bits.Count
		lst := new MfBinaryList()
		nl := lst.m_InnerList
		bl := bits.m_InnerList
		i := 1
		While (i <= diff)
		{
			nl[i] := MSB
			i++
		}
		j := i
		i := 1
		while (i <= bits.Count)
		{
			nl[j] := bl[i] 
			i++
			j++
		}
		lst.m_Count := nl.Length()
		return lst
	}
; 	End:Expand ;}
;{ 	IsNegative
	IsNegative(bits, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 1 ; Number of bits needed for test
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MaxStartIndex := bits.Count - nCount
		_startIndex := MfInteger.GetValue(startIndex, 0)
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
		retval := bits.Item[_startIndex] = 1
		if (_ReturnAsObj)
		{
			return new MfBool(retval)
		}
		return retval
	}
; 	End:IsNegative ;}

	BitShiftLeft(bits, ShiftCount, Wrap=false, MaintainBitCount=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		BitCount := bits.Count
		ShiftCount := MfInteger.GetValue(ShiftCount)
		MaintainBitCount := MfBool.GetValue(MaintainBitCount, false)
		Wrap := MfBool.GetValue(Wrap, false)

		if (ShiftCount < 0)
		{
			ShiftCount := Abs(ShiftCount)
			r := mod(ShiftCount, BitCount)
			ShiftCount := BitCount - r
		}
		if (Wrap && ShiftCount >= BitCount)
		{
			ShiftCount := Mod(ShiftCount, BitCount)
		}
				
		if (ShiftCount = 0)
		{
			return bits.Clone()
		}

		
		; for signed binary list the first bit is for sign and can not shift
		; all other bits can shift

		bl := bits.m_InnerList
		i := 2
		While (i <= bits.Count && !bl[i])
		{
			i++
		}
		
		iStartIndex := i
		iEndIndex := (bits.Count - iStartIndex) + iStartIndex
		Anslen := iEndIndex - iStartIndex
		
		ans := new MfBinaryList()
		ll := ans.m_InnerList

		;len := (bl.Count - Anslen) - (Anslen + ShiftCount) - 1
		len := (iStartIndex - ShiftCount) - 2
		i := 1
		; insert any space from orignal bits list
		while (i <= len)
		{
			ll[i] := 0
			i++
		}
		j := i
		i := iStartIndex
		While (i <= iEndIndex)
		{
			ll[j] := bl[i] 
			i++
			j++
		}
		;i := ll.Length()
		i := Anslen
		iShiftAdd := i + ShiftCount
		while (i < iShiftAdd)
		{
			ll[j] := 0
			i++
			j++
		}
		ll.InsertAt(1, bl[1])
		ans.m_Count := ll.Length()
		
		if (MaintainBitCount = true)
		{
			if (ans.Count > BitCount)
			{
				StartIndex := ans.Count - BitCount ; zero based index
				ans := ans.SubList(StartIndex)
			}
		}
		else
		{
			; trim off all leading MSB except for First
			MSB := ll[1]
			i := 2
			While (ll[i] = MSB)
			{
				i++
			}
			i-- ; set to zero based index
			If ((i > 1) && (i < ans.Count))
			{
				ans := ans.SubList(i,, true)
				; insert the msb again
				ans.Insert(0, MSB)
			}
			else if (i = ans.Count)
			{
				; all elements are MSB just return the first two
				ans := ans.SubList(0,1, true)
			}

		}
		
		return ans
	}


	BitShiftLeftUnSigned(bits, ShiftCount, Wrap=false, MaintainBitCount=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		BitCount := bits.Count
		ShiftCount := MfInteger.GetValue(ShiftCount)
		MaintainBitCount := MfBool.GetValue(MaintainBitCount, false)
		Wrap := MfBool.GetValue(Wrap, false)

		if (ShiftCount < 0)
		{
			ShiftCount := Abs(ShiftCount)
			r := mod(ShiftCount, BitCount)
			ShiftCount := BitCount - r
		}
		if (Wrap && ShiftCount >= BitCount)
		{
			ShiftCount := Mod(ShiftCount, BitCount)
		}
				
		if (ShiftCount = 0)
		{
			return bits.Clone()
		}

		if (MaintainBitCount)
		{
			if (ShiftCount  >= BitCount)
			{
				return new MfBinaryList(BitCount, 0)
			}
		}

		; for unsigned binary list the first bit can shift with all others

		bl := bits.m_InnerList
		; find leading zeor count
		i := 1
		While (i <= bits.Count && !bl[i])
		{
			i++
		}
		
		iStartIndex := i
		iEndIndex := (bits.Count - iStartIndex) + iStartIndex
		Anslen := iEndIndex - iStartIndex
		; no leading zeros plut frist bit for  sign
		LenBeforeShift := iEndIndex - iStartIndex + 1 ; plus one for sign
		
		ans := new MfBinaryList()
		ll := ans.m_InnerList

		len := (iStartIndex - ShiftCount) - 1
		i := 1
		; insert any space from orignal bits list
		while (i <= len)
		{	
			ll[i] := 0
			i++
		}
		j := i
		i := iStartIndex
		While (i <= iEndIndex)
		{
			ll[j] := bl[i] 
			i++
			j++
		}

		i := Anslen
		iShiftAdd := i + ShiftCount
		while (i < iShiftAdd)
		{
			ll[j] := 0
			i++
			j++
		}
		ans.m_Count := ll.Length()
		
		
		if (LimitBits = true && ans.Count > BitCount)
		{
			StartIndex := ans.Count - BitCount ; zero based index
			ans := ans.SubList(StartIndex)
		}
		return ans
	}
;{ 	ShiftRight
	BitShiftRight(bits, ShiftCount, Wrap=false,  MaintainBitCount=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		BitCount := bits.Count
		ShiftCount := MfInteger.GetValue(ShiftCount)
		MaintainBitCount := MfBool.GetValue(MaintainBitCount, false)
		Wrap := MfBool.GetValue(Wrap, false)
		if (ShiftCount = 0)
		{
			return bits.Clone()
		}

		if (Wrap)
		{
			if (ShiftCount < 0)
			{
				ShiftCount := Abs(ShiftCount)
				r := mod(ShiftCount, bits.Count )
				ShiftCount := bits.Count - r
			}
			if (ShiftCount >= bits.Count )
			{
				ShiftCount := Mod(ShiftCount, bits.Count)
			}
			if (ShiftCount <= 0)
			{
				return bits.Clone()
			}
		}

		if (ShiftCount < 0)
		{
			return MfBinaryConverter.BitShiftLeft(bits, Abs(ShiftCount), Wrap)
		}


		MSB := bits.Item[0]
		i := 0
		ans := bits.Clone()
		ll := ans.m_InnerList
		while (i < ShiftCount)
		{
			ll.Pop()
			ll.InsertAt(1, MSB)
			i++
		}
		if (MaintainBitCount = true)
		{
			if (ans.Count > BitCount)
			{
				ans := ans.SubList(0, BitCount -1, true)
			}
		}
		else
		{
			; trim off all leading MSB except for First
			i := 2
			While (ll[i] = MSB)
			{
				i++
			}
			i-- ; set to zero based index
			If ((i > 1) && (i < ans.Count))
			{
				ans := ans.SubList(i,, true)
				; insert the msb again
				ans.Insert(0, MSB)
			}
			else if (i = ans.Count)
			{
				; all elements are MSB just return the first two
				ans := ans.SubList(0,1, true)
			}
		}
		return ans
		
	}
;{ 	ShiftRight
;{ 	ShiftRightUnsigned
	BitShiftRightUnsigned(bits, ShiftCount, Wrap=false, MaintainBitCount=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ShiftCount := MfInteger.GetValue(ShiftCount)
		Wrap := MfBool.GetValue(Wrap, false)
		MaintainBitCount := MfBool.GetValue(MaintainBitCount, false)

		if (ShiftCount = 0)
		{
			return bits.Clone()
		}
		if (Wrap)
		{
			if (ShiftCount < 0)
			{
				ShiftCount := Abs(ShiftCount)
				r := mod(ShiftCount, bits.Count )
				ShiftCount := bits.Count - r
			}
			if (ShiftCount >= bits.Count )
			{
				ShiftCount := Mod(ShiftCount, bits.Count)
			}
			if (ShiftCount <= 0)
			{
				return bits.Clone()
			}
		}

		if (ShiftCount < 0)
		{
			return MfBinaryConverter.BitShiftLeft(bits, Abs(ShiftCount), Wrap)
		}

		i := 0
		ans := bits.Clone()
		ll := ans.m_InnerList
		while (i < ShiftCount)
		{
			ll.Pop()
			ll.InsertAt(1, 0)
			i++
		}
		if (MaintainBitCount = true)
		{
			if (ans.Count > BitCount)
			{
				ans := ans.SubList(0, BitCount -1, true)
			}
		}
		else
		{
			; trim off all leading MSB except for First
			i := 1
			While (ll[i] = 0)
			{
				i++
			}
			i-- ; set to zero based index
			If ((i > 0) && (i < ans.Count -1))
			{
				ans := ans.SubList(i,, true)
			}
			else if (i = ans.Count - 1)
			{
				; all elements are 0 just return the first two
				ans := ans.SubList(0,1, true)
			}
		}
		return ans
		
	}
; 	End:ShiftRightUnsigned ;}
;{ 	ToBool
	ToBool(bits, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 1 ; Number of bits needed for test
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := bits.Count - 1
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > (bits.Count - 1)))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := bits.Item[_startIndex] = 1
		if (_ReturnAsObj)
			return new MfBool(retval)
		return retval

	}
; 	End:ToBool ;}
;{ 	ToByte
	ToByte(bits, startIndex:=-1, ReturnAsObj:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 8 ; Number of bits needed for conversion
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)

		MaxStartIndex := bits.Count  - nCount
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		
		if ((_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_EndIndex := (_startIndex + nCount) - 1
		if (_EndIndex >= bits.Count)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bits := MfBinaryConverter._GetSubList(bits, _startIndex, _EndIndex)
		iCount := 0
		i := 0
		strMsb := ""
		strLsb := ""
		While iCount < 4
		{
			strMsb .= bits.Item[i]
			i++
			iCount++
		}
		iCount := 0
		While iCount < 4
		{
			strLsb .= bits.Item[i]
			i++
			iCount++
		}
		mInfo := MfBinaryConverter.ByteTable[strMsb]
		lInfo := MfBinaryConverter.ByteTable[strLsb]
		MSB := mInfo.Int

		LSB := lInfo.Int

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
	ToSByte(bits, startIndex:=-1, ReturnAsObj:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		Byte := MfBinaryConverter.ToByte(bits, startIndex, false)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)

		retval := MfConvert._ByteToSByte(byte)
		if (_ReturnAsObj)
		{
			return new MfSByte(retval)
		}

		return retval

	}
;{ ToComplement1
	ToComplement1(bList) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bList, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if(bList.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := MfBinaryConverter._FlipBits(bList)
		return retval
	}
; End:ToComplement1 ;}
;{ ToComplement2
	ToComplement2(bList) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bList, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if(bList.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := MfBinaryConverter._FlipBits(bList)
		MfBinaryConverter._AddOneToBitsValue(retval)
		return retval
	}
; End:ToComplement2 ;}
;{ ToChar
	ToChar(bits, startIndex=-1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		result := MfBinaryConverter.ToInt16(bits, startIndex, false)
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
	ToInt16(bits, startIndex=-1, ReturnAsObj=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 16 ; Number of bits needed for conversion
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)

		MaxStartIndex := bits.Count  - nCount
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		
		if ((_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_EndIndex := (_startIndex + nCount) - 1
		if (_EndIndex >= bits.Count)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bits := MfBinaryConverter._GetSubList(bits, _startIndex, _EndIndex)

		IsNeg := MfBinaryConverter.IsNegative(bits, 0)

		val := 0
		if (IsNeg)
		{
			bits := MfBinaryConverter.ToComplement2(bits)
			bl := bits.m_InnerList
			i := bits.Count
			Num := 1
			while i >= 1
			{
				bit := bl[i]
				if (bit = 1)
				{
					val -= num
				}
				num <<= 1
				i--
			}
		}
		Else
		{
			bl := bits.m_InnerList
			i := 1
			iMax := 1
			; ignore leading zeros
			while ((i < bits.Count) && !bl[i])
			{
				iMax++
				i++
			}
			;iMax := bits.Count - iMax
			i := bits.Count
			Num := 1
			while i >= iMax
			{
				bit := bl[i]
				if (bit = 1)
				{
					val += num
				}
				Num <<= 1
				i--
			}
		}
		
		if ((val < MfInt16.MinValue) || (val > MfInt16.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int16"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfInt16(val)
		}
		return val
	}
; End:ToInt16 ;}
;{ 	ToInt32
	ToInt32(bits, startIndex=-1, ReturnAsObj=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 32 ; Number of bits needed for conversion
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)

		MaxStartIndex := bits.Count  - nCount
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		
		if ((_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_EndIndex := (_startIndex + nCount) - 1
		if (_EndIndex >= bits.Count)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bits := MfBinaryConverter._GetSubList(bits, _startIndex, _EndIndex)

		IsNeg := MfBinaryConverter.IsNegative(bits, 0)

		val := 0
		if (IsNeg)
		{
			bits := MfBinaryConverter.ToComplement2(bits)
			bl := bits.m_InnerList
			i := bits.Count
			Num := 1
			while i >= 1
			{
				bit := bl[i]
				if (bit = 1)
				{
					val -= num
				}
				num <<= 1
				i--
			}
		}
		Else
		{
			bl := bits.m_InnerList
			i := 1
			iMax := 1
			; ignore leading zeros
			while ((i < bits.Count) && !bl[i])
			{
				iMax++
				i++
			}
			;iMax := bits.Count - iMax
			i := bits.Count
			Num := 1
			while i >= iMax
			{
				bit := bl[i]
				if (bit = 1)
				{
					val += num
				}
				Num <<= 1
				i--
			}
		}
		
		if ((val < MfInteger.MinValue) || (val > MfInteger.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfInteger(val)
		}
		return val
	}
; 	End:ToInt32 ;}
	
; 	End:ToInt32 ;}
;{ 	ToInt64
	ToInt64(bits, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 64 ; Number of bits needed for conversion
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)

		MaxStartIndex := bits.Count  - nCount
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		
		if ((_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_EndIndex := (_startIndex + nCount) - 1
		if (_EndIndex >= bits.Count)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bits := MfBinaryConverter._GetSubList(bits, _startIndex, _EndIndex)

		IsNeg := MfBinaryConverter.IsNegative(bits, 0)

		val := 0
		if (IsNeg)
		{
			bits := MfBinaryConverter.ToComplement2(bits)
			bl := bits.m_InnerList
			i := bits.Count
			Num := 1
			while i >= 1
			{
				bit := bl[i]
				if (bit = 1)
				{
					val -= num
				}
				num <<= 1
				i--
			}
		}
		Else
		{
			bl := bits.m_InnerList
			i := 1
			iMax := 1
			; ignore leading zeros
			while ((i < bits.Count) && !bl[i])
			{
				iMax++
				i++
			}
			;iMax := bits.Count - iMax
			i := bits.Count
			Num := 1
			while i >= iMax
			{
				bit := bl[i]
				if (bit = 1)
				{
					val += num
				}
				Num <<= 1
				i--
			}
		}
		
		if ((val < MfInt64.MinValue) || (val > MfInt64.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int64"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfInt64(val)
		}
		return val
	}
; 	End:ToInt64 ;}
;{ 	ToUInt16
	ToUInt16(bits, startIndex=-1, ReturnAsObj=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 16 ; Number of bits needed for conversion
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)

		MaxStartIndex := bits.Count  - nCount
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		
		if ((_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_EndIndex := (_startIndex + nCount) - 1
		if (_EndIndex >= bits.Count)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bits := MfBinaryConverter._GetSubList(bits, _startIndex, _EndIndex)
		
		val := 0
		bl := bits.m_InnerList
		i := 1
		iMax := 1
		; ignore leading zeros
		while ((i < bits.m_Count) && !bl[i])
		{
			iMax++
			i++
		}
		;iMax := bits.Count - iMax
		i := bits.m_Count
		Num := 1
		while i >= iMax
		{
			bit := bl[i]
			if (bit = 1)
			{
				val += num
			}
			Num <<= 1
			i--
		}
		
		if ((val < MfUInt32.MinValue) || (val > MfUInt32.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_UInt16"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfUInt32(val)
		}
		return val
	}
; 	End:ToUInt16 ;}
;{ 	ToUInt32
	ToUInt32(bits, startIndex=-1, ReturnAsObj=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 32 ; Number of bits needed for conversion
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)

		MaxStartIndex := bits.Count  - nCount
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		
		if ((_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_EndIndex := (_startIndex + nCount) - 1
		if (_EndIndex >= bits.Count)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bits := MfBinaryConverter._GetSubList(bits, _startIndex, _EndIndex)

		
		val := 0
		bl := bits.m_InnerList
		i := 1
		iMax := 1
		; ignore leading zeros
		while ((i < bits.m_Count) && !bl[i])
		{
			iMax++
			i++
		}
		;iMax := bits.Count - iMax
		i := bits.m_Count
		Num := 1
		while i >= iMax
		{
			bit := bl[i]
			if (bit = 1)
			{
				val += num
			}
			Num <<= 1
			i--
		}
		
		if ((val < MfUInt32.MinValue) || (val > MfUInt32.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_UInt32"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfUInt32(val)
		}
		return val
	}
; 	End:ToUInt32 ;}
;{ 	ToUInt64
	ToUInt64(bits, startIndex=-1, ReturnAsObj=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 64 ; Number of bits needed for conversion
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)

		MaxStartIndex := bits.Count  - nCount
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		
		if ((_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_EndIndex := (_startIndex + nCount) - 1
		if (_EndIndex >= bits.Count)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bits := MfBinaryConverter._GetSubList(bits, _startIndex, _EndIndex)
		sBinary := MfBinaryConverter._ToBinaryString(bits)
		bigx := MfBigMathInt.Str2bigInt(sBinary, 2, 2, 2)
		bigx := MfBigMathInt.Trim(bigx, 1)
		if (_ReturnAsObj)
		{
			retval := new MfUInt64(bigx)
			return retval
		}
		return MfBigMathInt.BigInt2str(bitx, 10)
	}
; 	End:ToUInt64 ;}
;{ 	ToBigInt
	ToBigInt(bits, startIndex=0, ReturnAsObj=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 1 ; Number of bits needed for conversion
		if (bits.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		
		MaxStartIndex := bits.Count -1
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
		IsNeg := MfBinaryConverter.IsNegative(bits, startIndex)
		if (_startIndex > 0)
		{
			bits := MfBinaryConverter._GetSubList(bits, _startIndex)	
		}
		
		if (IsNeg)
		{
			
			bits := MfBinaryConverter.ToComplement2(bits)
		}
	
		sBinary := MfBinaryConverter._ToBinaryString(bits)
		
		bigx := MfBigMathInt.Str2bigInt(sBinary, 2, 2, 2)
		bigx := MfBigMathInt.Trim(bigx, 1)

		if (_ReturnAsObj)
		{
			retval := new MfBigInt(bigx)
			if ((IsNeg = true) && (MfBigMathInt.IsZero(bigx) = false))
			{
				retval.IsNegative := IsNeg
			}
			
			return retval
		}
		return MfBigMathInt.BigInt2str(bigx, 10)
	}
; 	End:ToBigInt ;}
;{ 	Trim
	Trim(bits, n=0, UseMsb=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bits, MfBinaryList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bits.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bits"))
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
			MSB := bits.Item[0]
		}
		i := 0
		j := bits.Count
		while (i >= 0 && bits.m_InnerList[i + 1] = MSB)
		{
			i++
			j--
		}
		y := new MfBinaryList(j + n, MSB)
		if (j = 0)
		{
			; if j = the we have all leading bits of 0 or all leading bits or 1
			; make sure to return at least n + 1 bits for a min of one bit
			y.Add(MSB)
			return y
		}
		
		; use MfNibConverter._copy as it is the same byte order for BinaryConverter and NibbleConveter
		MfNibConverter._copy(y, bits, MSB)
		return y
	}
; 	End:Trim ;}
;{ 	Methods

;{ Internal Methods
;{ 	_AddOneToBinString
/*
	Method: _AddOneToBinString()

	_AddOneToBinString()
		Adds 1 to a binary string no matter how long the string
	Parameters:
		binObj
			The var, MfString, MfMemoryString that contains binary values
			bin can be in most any format such as -0011 or +1101 or 110011 or 00-11-00
		AddToBin
			Optional, Default is false.
			If True then when subtracting 1 would  result in a longer string then value will be added
			This is useful for working with specific byte lengths for instance
				AddToBin = false
					11 will become 00
				AddToBin = true
					11 will become 100
		skip
			Optional, Defatul is -1 which will cause method to figure the value out automatically.
			This is the number of leading chars to ignore and is generaly used to ignore - and +
	Returns:
		If binObj is instance of MfMemoryString then null value is returned; Otherwise string var is returned
	Remarks:
		Static method
		Internal Method
		This method if fast due to it working on a a charcode level
*/
	_AddOneToBinString(binObj, AddToBin:=false, skip=-1) {
		returnString := true
		if (MfObject.IsObjInstance(binObj, MfMemoryString))
		{
			returnString := false
		}
		mStr := MfMemoryString.FromAny(binObj)
		i := mStr.Length - 1
		if (skip < 0)
		{
			Skip := 0
			if (mStr.Length > 0)
			{
				if (mStr.StartsWith("-", false) = true)
				{
					Skip := 1
				}
				else if (mStr.StartsWith("+", false) = true)
				{
					Skip := 1
				}
				
			}
		}
		if (i < skip)
		{
			if (mStr.FreeCharCapacity = 0)
			{
				mStr.Expand(2)
			}
			mStr.AppendCharCode(49)
			return returnString ? mStr.ToString() : ""
		}

		if (i = skip) {
			c := mStr.CharCode[i]
			if (c = 49)
			{
				; can't add already 1
				; 1 becomes 10
				 mStr.CharCode[i] := 48 ; 0
				 if (mStr.FreeCharCapacity = 0)
				 {
				 	mStr.Expand(2)
				 }
				 mstr.AppendCharCode(48) ; 0
			}
			else if (c = 48)
			{
				; 0 covert to 1
				mStr.CharCode[i] := 49 ; 1
			}
			return returnString ? mStr.ToString() : ""
		}
		Added := false
		While (i >= skip)
		{
			c := mStr.CharCode[i]
			if (c = 49)
			{
				; can't add already 1
				; 0 becomes 1
				mStr.CharCode[i] := 48 ; 0
				i--
				continue
			}
			else if (c = 48)
			{
				; 0 covert to 1
				mStr.CharCode[i] := 49 ; 1
				Added := true
				break
			}
			i--
		}
		if (AddToBin = true && Added = false)
		{
			if (mStr.FreeCharCapacity = 0)
			{
				mStr.Expand(2)
			}
			mStr.Insert(skip,"1")
		}
		return returnString ? mStr.ToString() : ""
	}
; 	End:_AddOneToBinString ;}
;{ 	_RemovOneFromBinString
/*
	Method: _RemovOneFromBinString()

	_RemovOneFromBinString()
		Subtracts 1 from a binary string no matter how long the string
	Parameters:
		binObj
			The var, MfString, MfMemoryString that contains binary values
			bin can be in most any format such as -0011 or +1101 or 110011 or 00-11-00
		AddToBin
			Optional, Default is false.
			If True then when subtracting 1 would  result in a longer string then value will be added
			This is useful for working with specific byte lengths for instance
				AddToBin = false
					00 will become 11
				AddToBin = true
					00 will become 111
		skip
			Optional, Defatul is -1 which will cause method to figure the value out automatically.
			This is the number of leading chars to ignore and is generaly used to ignore ignore - and +
	Returns:
		If binObj is instance of MfMemoryString then null value is returned; Otherwise string var is returned
	Remarks:
		Static method
		Internal Method
		This method if fast due to it working on a a charcode level
*/
	_RemovOneFromBinString(binObj, AddToBin:=false, skip=-1) {
		returnString := true
		if (MfObject.IsObjInstance(binObj, MfMemoryString))
		{
			returnString := false
		}
		mStr := MfMemoryString.FromAny(binObj)
		i := mStr.Length - 1
		if (skip < 0)
		{
			Skip := 0
			if (mStr.Length > 0)
			{
				if (mStr.StartsWith("-", false) = true)
				{
					Skip := 1
				}
				else if (mStr.StartsWith("+", false) = true)
				{
					Skip := 1
				}
				
			}
		}
		if (i < skip)
		{
			if (mStr.FreeCharCapacity = 0)
			{
				mStr.Expand(2)
			}
			mStr.AppendCharCode(48)
			return returnString ? mStr.ToString() : ""
		}

		if (i = skip) {
			c := mStr.CharCode[i]
			if (c = 48)
			{
				; can't remove already 0
				; 0 becomes 11
				 mStr.CharCode[i] := 49 ; 1
				 if (mStr.FreeCharCapacity = 0)
				 {
				 	mStr.Expand(2)
				 }
				 mstr.AppendCharCode(49) ; 1
			}
			else if (c = 49)
			{
				; 1 covert to 0
				mStr.CharCode[i] := 48 ; 0
			}
			return returnString ? mStr.ToString() : ""
		}
		Subtracted := false
		While (i >= skip)
		{
			c := mStr.CharCode[i]
			if (c = 48)
			{
				; can't remove already 0
				; 0 becomes 1
				mStr.CharCode[i] := 49 ; 1
				i--
				continue
			}
			else if (c = 49)
			{
				; 1 covert to 0
				mStr.CharCode[i] := 48 ; 0
				Subtracted := true
				break
			}
			i--
		}
		if (AddToBin = true && Subtracted = false)
		{
			if (mStr.FreeCharCapacity = 0)
			{
				mStr.Expand(2)
			}
			mStr.Insert(skip,"1")
		}
		return returnString ? mStr.ToString() : ""

	}
; 	End:_RemovOneFromHexString ;}
	_ToBinaryString(bits) {
		sBinary := new MfText.StringBuilder(bits.Count)
		i := 1
		iCount := bits.Count
		ll := bits.m_InnerList
		; ignore leading zeros
		while (i < iCount && !ll[i])
		{
			i++
		}
		while (i <= iCount)
		{
			sBinary.AppendString(ll[i])
			i++
		}
		if (sBinary.Length = 0)
		{
			sBinary := "0"
		}
		return sBinary.ToString()
	}
	_DecToBin(strDec) {
		lst := new MfBinaryList()
		If (MfString.IsNullOrEmpty(strDec))
		{
			lst.Add(0)
			return lst
		}
		strRev := MfString.Reverse(strDec)
		iCarry := 0
		iCount := 0
		Loop, Parse, strRev
		{

			b := A_LoopField + 0
			iCarry := b + iCarry
			
			While (iCarry > 0)
			{
				R := 0
				sum := iCarry
				iCarry := 0
				if (sum > 0)
				{
					iCarry := MfMath.DivRem(sum, 2, R)
				}
				lst.Add(R)
			}
		}
		return lst
	}
;{ 	_AddOneToBitsValue
	_AddOneToBitsValue(byref lst) {
		iCarry := 1
		i := lst.Count - 1
		while i >= 0
		{
			sum := (lst.Item[i] + 1)
			if (sum > 1)
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
; 	End:_AddOneToBitsValue ;}
;{ 	_GetByteInfo
	; get Byte Info From 4 bytes of a bit list
	_GetByteInfo(byref bits, startIndex) {
		sb := new MfText.StringBuilder((bits.m_Count - startIndex) + 4)
		i := startIndex
		iCount := 0
		; if start index is withing one of bits.Count then padd with zero
		while (i > (bits.m_Count - 1))
		{
				sb.Append("0")
			i--
			iCount++
			if (iCount = 3)
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"), "bits")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		inLst := bits.m_InnerList
		while iCount < 4
		{
			sb.Append(inLst[i + 1])
			i++
			iCount++
		}
		return MfBinaryConverter.ByteTable[sb.ToString()]
	}
; 	End:_GetByteInfo ;}
;{ 	_IsNotMfObj
	_IsNotMfObj(obj) {
		if (MfObject.IsObjInstance(obj))
		{
			return false
		}
		
		ex := new MfException(MfEnvironment.Instance.GetResourceString("NonMfObjectException_General"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		return ex
	}
; 	End:_IsNotMfObj ;}
;{ 	_GetBytesInt
	_GetBytesInt(value, bitCount = 32) {
		If (bitCount < 4 )
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Under", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Mod(bitCount, 4))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Not_Divisable_By", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (bitCount > 64)
		{
			; will handle negative and positive and convert to Little Endian
			return MfBinaryConverter._LongIntStringToByteArray(value, bitCount)
		}
		return MfBinaryConverter._IntToBinaryList(value, bitCount)

	}
	_GetBytesBinary(value, bitCount = 32) {
		If (bitCount < 4 )
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Under", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Mod(bitCount, 4))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Not_Divisable_By", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		lst := new MfBinaryList()
		ll := lst.m_InnerList
		currentBits := StrLen(value)
		iCount := 0
		while currentBits < bitCount
		{
			iCount++
			ll[iCount] := 0
			currentBits++
		}
		loop, Parse, value
		{
			iCount++
			ll[iCount] := A_LoopField
		}
		lst.m_Count := iCount
		return lst

	}
; 	End:_GetBytesInt ;}
;{ 	_LongIntStringToByteArray
	_LongIntStringToByteArray(value, bitCount = 32) {
		throw new MfNotImplementedException("_LongIntStringToByteArray not implemented")
	}
; 	End:_LongIntStringToByteArray ;}
;{ 	_GetSubList
	; returns a subset of a MfBinaryList as a new MfBinaryList instance
	; counts from Right to left so startIndex it from the end
	_GetSubList(lst, startIndex=0, endIndex="") {
		startIndex := MfInteger.GetValue(startIndex, 0)
		endIndex := MfInteger.GetValue(endIndex, "NaN", true)
		maxIndex := lst.Count - 1
		IsEndIndex := true
		if (endIndex == "NaN")
		{
			IsEndIndex := False
		}
		If (IsEndIndex = true && endIndex < 0)
		{
			endIndex := 0
		}
		if (startIndex < 0)
		{
			startIndex := 0
		}
		if ((IsEndIndex = false) && (startIndex = 0))
		{
			Return lst
		}
		if ((IsEndIndex = false) && (startIndex > maxIndex))
		{
			Return lst
		}
		if ((IsEndIndex = true) && (startIndex > endIndex))
		{
			; swap values
			tmp := startIndex
			startIndex := endIndex
			endIndex := tmp
		}
		if ((IsEndIndex = true) && (endIndex = startIndex))
		{
			return lst
		}
		if (startIndex > maxIndex)
		{
			return lst
		}
		if (IsEndIndex = true)
		{
			len :=  endIndex - startIndex
			if ((len + 1) >= lst.Count)
			{
				return lst
			}
		}
		else
		{
			len := maxIndex
		}
		

		rLst := new MfBinaryList()
		rl := rLst.m_InnerList

		i := 1
		iCount := 0
		if (IsEndIndex = true)
		{
			While ((iCount + len) < (lst.Count - 1))
			{
				iCount++
			}
		}
		else
		{
			While ((iCount + (len - startIndex)) < (lst.Count - 1))
			{
				iCount++
			}
		}
			
		ll := lst.m_InnerList
		tl := this.m_InnerList
		while iCount < lst.Count
		{
			iCount++
			;lst.Add(this.Item[i])
			rl[i] := ll[iCount]
			i++
			
		}
		rLst.m_Count := i - 1
		return rLst

	}
; 	End:_GetSubList ;}
;{ 	_FromBinaryString
	; Converts string into MfBinaryList
	; Parameters
	;	value
	;		represents a binary string.
	;		Accepts sign of - or + in front of binary string
	;		If signe is neg then all bits are flipped
	;	bitcount
	;		the bitcount to pad the MfBinaryList
	;		Bitcount in only applied if value is signed or ForcePadding is true
	;		If return list count is greater then bitcount then it will not be padded
	;	ForcePadding
	;		If true then return list will be padded even if not signed
	;		Padding will be the same bit as MSB before padding
	_FromBinaryString(value, bitCount = 64, ForcePadding=false) {
		If (bitCount < 1 )
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Under", "2"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		lst := new MfBinaryList()
		strLength := StrLen(value)
		If (strLength = 0)
		{
			while (lst.Count < bitCount)
			{
				lst.Add(0)
			}
			return lst
		}

		IsNeg := False
		IsSigned := False
		strX := ""

		If (strLength > 0)
		{
			strSign := SubStr(value, 1, 1)
			if (strSign == "-")
			{
				IsNeg := true
				IsSigned := true
				strX := SubStr(value, 2)
			}
			else if (strSign == "+")
			{
				IsSigned := true
				strX := SubStr(value, 2)
			}
			Else
			{
				strX := value
			}

		}

		iCount := 0
		Loop, Parse, strX
		{
			If (A_LoopField = 1)
			{
				If (IsSigned = false && iCount = 0)
				{
					IsNeg := True
				}
				If (IsNeg = true && IsSigned = true)
				{
					lst.Add(0)
				}
				Else
				{
					lst.Add(1)
				}
			}
			else if (A_LoopField = 0)
			{
				If (IsSigned = false && iCount = 0)
				{
					IsNeg := false
				}
				If (IsNeg = true && IsSigned = true)
				{
					lst.Add(1)
				}
				Else
				{
					lst.Add(0)
				}
			}
			iCount++
		}

		if (IsSigned = true || ForcePadding = true)
		{
			while (lst.Count) < bitCount
			{
				lst.insert(0,IsNeg?1:0)
			}
		}
		return lst
	}
; 	End:_FromBinaryString ;}
;{ _FlipBits
	_FlipBits(lst) {
		nArray := new MfBinaryList()
		; access inner list for faster processing
		nl := nArray.m_InnerList
		ll := lst.m_InnerList
		iMaxIndex := lst.Count
		i := 1
		while i <= lst.Count
		{
			nl[i] := !ll[i]
			i++
		}
		nArray.m_Count := lst.Count
		return nArray
	}
; End:_FlipBits ;}
	_IntToBinaryList(value, bitCount = 32) {
		If (bitCount < 4 )
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Under", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Mod(bitCount, 4))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Not_Divisable_By", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
			
		IsNegative := false
		bArray := new MfBinaryList()
		ActualBitCount := bitCount
		MaxMinValuCorrect := false
		if (value = 0)
		{
			while (bArray.m_Count < ActualBitCount)
			{
				bArray._Add(0)
			}
			return bArray
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
			bArray._Add(Result & 0x1)
			Result >>= 1
			i++
		}
		
				
		if (IsNegative)
		{
			while (bArray.Count < ActualBitCount)
			{
				bArray.Add(0)
			}
			bArray := MfBinaryConverter._ReverseList(bArray)
			; flip all the bits
			bArray := MfBinaryConverter._FlipBits(bArray)

			if (MaxMinValuCorrect = False)
			{
				;~ ; when negative Add 1
				IsAdded := MfBinaryConverter._AddOneToBitsValue(bArray, false)
			}
		}
		else ; if (IsNegative)
		{
			; add zero's to end of postivie array
			while (bArray.Count < ActualBitCount)
			{
				bArray.Add(0)
			}
			bArray := MfBinaryConverter._ReverseList(bArray)
		}
		return bArray
	}
;{ _ReverseList
	_ReverseList(lst) {
		iCount := lst.Count
		nArray := new MfBinaryList()
		inLst := lst.m_InnerList
		while iCount > 0
		{
			nArray._Add(inLst[iCount])
			iCount --
		}
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
;{ ByteTable
		static m_ByteTable := ""
		/*!
			Property: ByteTable [get]
				Gets the ByteTable value associated with the this instance
			Value:
				Var representing the ByteTable property of the instance
			Remarks:
				Readonly Property
		*/
		ByteTable[key]
		{
			get {
				if (MfBinaryConverter.m_ByteTable = "")
				{
					MfBinaryConverter.m_ByteTable := new MfHashTable(16)
					MfBinaryConverter.m_ByteTable.Add("0000", new MfBinaryConverter.BitInfo("0", "F", "0000","1111", 0, 15))
					MfBinaryConverter.m_ByteTable.Add("0001", new MfBinaryConverter.BitInfo("1", "E", "0001","1110", 1, 14))
					MfBinaryConverter.m_ByteTable.Add("0010", new MfBinaryConverter.BitInfo("2", "D", "0010","1101", 2, 13))
					MfBinaryConverter.m_ByteTable.Add("0011", new MfBinaryConverter.BitInfo("3", "C", "0011","1100", 3, 12))
					MfBinaryConverter.m_ByteTable.Add("0100", new MfBinaryConverter.BitInfo("4", "B", "0100","1011", 4, 11))
					MfBinaryConverter.m_ByteTable.Add("0101", new MfBinaryConverter.BitInfo("5", "A", "0101","1010", 5, 10))
					MfBinaryConverter.m_ByteTable.Add("0110", new MfBinaryConverter.BitInfo("6", "9", "0110","1001", 6, 9))
					MfBinaryConverter.m_ByteTable.Add("0111", new MfBinaryConverter.BitInfo("7", "8", "0111","1000", 7, 8))

					MfBinaryConverter.m_ByteTable.Add("1000", new MfBinaryConverter.BitInfo("8", "7", "1000","0111", 8, 7, true))
					MfBinaryConverter.m_ByteTable.Add("1001", new MfBinaryConverter.BitInfo("9", "6", "1001","0110", 9, 6, true))
					MfBinaryConverter.m_ByteTable.Add("1010", new MfBinaryConverter.BitInfo("A", "5", "1010","0101", 10, 5, true))
					MfBinaryConverter.m_ByteTable.Add("1011", new MfBinaryConverter.BitInfo("B", "4", "1011","0100", 11, 5, true))
					MfBinaryConverter.m_ByteTable.Add("1100", new MfBinaryConverter.BitInfo("C", "3", "1100","0011", 12, 3, true))
					MfBinaryConverter.m_ByteTable.Add("1101", new MfBinaryConverter.BitInfo("D", "2", "1101","0010", 13, 2, true))
					MfBinaryConverter.m_ByteTable.Add("1110", new MfBinaryConverter.BitInfo("E", "1", "1110","0001", 14, 1, true))
					MfBinaryConverter.m_ByteTable.Add("1111", new MfBinaryConverter.BitInfo("F", "0", "1111","0000", 15, 0, true))
				}
				return MfBinaryConverter.m_ByteTable.Item[key]
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "HexBitTable")
				Throw ex
			}
		}
	; End:ByteTable ;}
; End:Properties ;}
	;{ Internal Class BitInfo
	class BitInfo
	{
		__new(hv, hf, b, bf, i, iFlip, Neg = false) {
			this.HexValue := hv
			this.HexFlip := hf
			this.Bin := b
			this.BinFlip := bf
			this.Int := i
			this.IntFlip := iFlip
			this.IsNeg := Neg
		}
		HexValue := ""
		HexFlip := ""
		Bin := ""
		BinFlip := ""
		IsNeg := False
		Int := 0
		IntFlip := 0
	}
; End:Internal Class BitInfo ;}
}