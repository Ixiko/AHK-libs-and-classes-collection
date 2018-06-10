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

Class MfDateTime extends MfPrimitive
{
;{ static constants	
	static MinTicks := 0
	static MaxTicks := 3155378975999999999
	static TicksPerMillisecond := 10000
	static TicksPerSecond := 10000000
	static TicksPerMinute := 600000000
	static TicksPerHour := 36000000000
	static TicksPerDay := 864000000000
	static MillisPerSecond := 1000
	static MillisPerMinute := 60000
	static MillisPerHour := 3600000
	static MillisPerDay := 86400000
	static DaysPerYear := 365
	static DaysPer4Years := 1461
	static DaysPer100Years := 36524
	static DaysPer400Years := 146097
	static DaysTo1601 := 584388
	static DaysTo1899 := 693593
	static DaysTo10000 := 3652059
	static MaxMillis := 315537897600000
	static FileTimeOffset := 504911232000000000
	static DoubleDateOffset := 599264352000000000
	static OADateMinAsTicks := 31241376000000000
	static OADateMinAsDouble := -657435.0
	static OADateMaxAsDouble := 2958466.0
	static DatePartYear := 0
	static DatePartDayOfYear := 1
	static DatePartMonth := 2
	static DatePartDay := 3
	static uTicksMask := 4611686018427387903
	static uFlagsMask := 13835058055282163712
	static uLocalMask := 9223372036854775808
	static TicksCeiling := 4611686018427387904
	static uKindUnspecified := 0
	static uKindUtc := 4611686018427387904
	static uKindLocal := 9223372036854775808
	static uKindLocalAmbiguousDst := 13835058055282163712
	static KindShift := 62
	static TicksField := "ticks"
	static DateDataField := "dateData"
	Static TypeCode := 15
	static DaysToMonth365 := {31,59,90,120,151,181,212,243,273,304,334,365}
	static DaysToMonth366 := {31,60,91,121,152,182,213,244,273,305,335,366}
; End:static constants;}

	
	__New(MfDateTime, returnAsObj = false) {
		; Throws MfNotSupportedException if MfDateTime Sealed class is extended
		if (this.__Class != "MfDateTime") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfDateTime"))
		}
		_returnAsObject := MfBool.GetValue(returnAsObj)
		base.__New(MfDateTime, _returnAsObject)
		this.m_isInherited := this.__Class != "MfDateTime"
	}
	
	DateToTicks(year, month, day)
	{
		_Day := ""
		_Month := ""
		_Year := ""
		try {
			_Day := MfInteger.GetValue(day)
			_Month := MfInteger.GetValue(month)
			_Year := MfInteger.GetValue(year)
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.Source	:= A_ThisFunc
			ex.File		:= A_LineFile
			ex.Line		:= A_LineNumber
			throw ex
		}
		if (_Year >= 1 && _Year <= 9999 && _Month >= 1 && _Month <= 12)
		{
			intArray := MfDateTime.IsLeapYear(_Year) ? MfDateTime.DaysToMonth366 : MfDateTime.DaysToMonth365
			if (day >= 1 && day <= intArray[_Month] - intArray[_Month - 1])
			{
				num := _Year - 1
				num2 := num * 365 + num / 4 - num / 100 + num / 400 + intArray[_Month - 1] + day - 1
				
				return num2 * 864000000000
			}
		}
		ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_BadYearMonthDay")
			, A_ThisFunc)
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
	ToFileTimeUtc()
	{
		long num = ((this.InternalKind & 9223372036854775808uL) != 0uL) ? this.ToUniversalTime().InternalTicks : this.InternalTicks;
		num -= 504911232000000000L;
		if (num < 0L)
		{
			throw new ArgumentOutOfRangeException(null, Environment.GetResourceString("ArgumentOutOfRange_FileTimeInvalid"));
		}
		return num;
	}

;{ Base Overrides
;{ 	ToString()
	ToString()
	{
		if (!this.IsInstance()) {
			throw new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object"))
		}
		return this.GetType().ToString()
	}
;  End:ToString() ;}
;{	GetType()
	GetType() {
		if (!this.IsInstance()) {
			throw new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object"))
		}
		if (! IsObject(this.m_GetType)) {
          this.m_GetType := new MfType(MfDateTime.__Class)
        }
        return this.m_GetType
	}
;	End:GetType() ;}
; End:Base Overrides ;}
;{ Properties	
	Value[]
	{
		get {
			return Base.Value
		}
		set {
			Base.Value := value
			this.m_length := StrLen(this.m_value)
			return Base.Value
		}
	}
; End:Properties;}
}