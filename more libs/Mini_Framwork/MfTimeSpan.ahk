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
;{ Class MfTimeSpan
;{ Class Comments
/*!
	Class: MfTimeSpan
		A MfTimeSpan object represents a time interval (duration of time or elapsed time) that is measured as a positive or
		negative number of days, hours, minutes, seconds, and fractions of a second.
		The MfTimeSpan object can also be used to represent the time of day, but only if the time is unrelated to a particular date.

		The largest unit of time that the MfTimeSpan object uses to measure duration is a day.
		Time intervals are measured in days for consistency, because the number of days in larger units of time,
		such as months and years, varies.

		The value of a MfTimeSpan object is the number of ticks that equal the represented time interval.
		A tick is equal to 100 nanoseconds, or one ten-millionth of a second.
		The value of a MfTimeSpan object can range from MfTimeSpan.MinValue to MfTimeSpan.MaxValue.

	Inherits:
		MfPrimitive
*/
; End:Class Comments ;}
class MfTimeSpan extends MfPrimitive
{
;{ Constructor: ()
/*
	Constructor()
		Initializes a new instance of the MfTimeSpan structure.
	
	OutputVar := new MfTimeSpan()
	OutputVar := new MfTimeSpan(ts)
	OutputVar := new MfTimeSpan(ticks)
	OutputVar := new MfTimeSpan(hours, minutes, seconds)
	OutputVar := new MfTimeSpan(days, hours, minutes, seconds)
	OutputVar := new MfTimeSpan(days, hours, minutes, seconds, milliseconds)
	
	Parameters
		ts
			An instance of MfTimeSpan.
		ticks
			A time period expressed in 100-nanosecond units. Can be instance of MfInt64 or var containing integer.
		days
			Number of days. Can be instance of MfInteger or var containing integer.
		hours
			Number of hours. Can be instance of MfInteger or var containing integer.
		minutes
			Number of Minutes. Can be instance of MfInteger or var containing integer.
		seconds
			Number of seconds. Can be instance of MfInteger or var containing integer.
		milliseconds
			Number of milliseconds. Can be instance of MfInteger or var containing integer.
	Throws 
		Throws MfArgumentOutOfRangeException if the parameters specify a MfTimeSpan value less than MinValue or greater than MaxValue.
		Throws MfArgumentException if there is an error get a value from a parameter.
	
	Constructor()
		Initializes a new instance of the MfTimeSpan structure.
	Remarks
		This constructor initializes the MfTimeSpan
		Ticks property will have a value of 0
	
	Constructor(ts)
		Initializes a new instance of the MfTimeSpan structure to the specified number of ticks of ts.
	Remarks
		This constructor initializes the MfTimeSpan
		Ticks property will have a value of ts
		Eg: myTs := new MfTimeSpan(MfTimeSpan.Zero)
	
	Constructor(ticks)
		Initializes a new instance of the MfTimeSpan structure to the specified number of ticks.
	
	Remarks
		This constructor initializes the MfTimeSpan
		Ticks property will have a value of ticks
		A single tick represents one hundred nanoseconds or one ten-millionth of a second. There are 10,000 ticks in a millisecond.
	
	Constructor(hours, minutes, seconds)
		Initializes a new instance of the MfTimeSpan structure to a specified number of hours, minutes, and seconds.
	Remarks
		This constructor initializes the MfTimeSpan
		Ticks property will have a value of hours, minutes, and seconds.
		The specified hours, minutes, and seconds are converted to ticks, and that value initializes this instance.
	
	Constructor(days, hours, minutes, seconds)
		Initializes a new instance of the MfTimeSpan structure to a specified number of days, hours, minutes, and seconds.
	Remarks
		This constructor initializes the MfTimeSpan
		Ticks property will have a value of days, hours, minutes, and seconds.
		The specified days, hours, minutes, and seconds are converted to ticks, and that value initializes this instance.
	
	Constructor(days, hours, minutes, seconds, milliseconds)
		Initializes a new instance of the MfTimeSpan structure to a specified number of days, hours, minutes, seconds and milliseconds.
	Remarks
		This constructor initializes the MfTimeSpan
		Ticks property will have a value of days, hours, minutes, seconds and milliseconds.
		The specified days, hours, minutes, seconds and milliseconds are converted to ticks, and that value initializes this instance.
*/
	__New(args*) {
	
		objP := this._ConstructorParams(A_ThisFunc, args*)

		this.m_Ticks := Null
		_value := 0.0
		try {
			strP := objP.ToString()
			if ((strP = "MfInt64") || (strP = "MfTimeSpan"))
			{
				_value := objP.Item[0].Value
			}
			else if (strP ="MfInteger,MfInteger,MfInteger")
			{
				_value := MfTimeSpan.TimeToTicks(objP.Item[0]
													, objP.Item[1]
													, objP.Item[2]).Value
			}
			else if (strP ="MfInteger,MfInteger,MfInteger,MfInteger")
			{
				_value := new MfTimeSpan(objP.Item[0]
													, objP.Item[1]
													, objP.Item[2]
													, objP.Item[3]
													, new MfInteger(0)).Value
			}
			else if (strP = "MfInteger,MfInteger,MfInteger,MfInteger,MfInteger")
			{
				ldays :=	new MfInt64(objP.Item[0].Value)
				lhour :=	new MfInt64(objP.Item[1].Value)
				lmin := 	new MfInt64(objP.Item[2].Value)
				lsec := 	new MfInt64(objP.Item[3].Value)
				lmilli := 	new MfInt64(objP.Item[4].Value)
				result := new MfInt64()
				result.Value := ((lDays.Value * 3600 * 24) + (lhour.Value * 3600) + (lmin.Value * 60) + (lsec.Value)) * 1000 + lmilli.Value
				if ((result.Value > 922337203685477) || (result.Value < -922337203685477))
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("Overflow_TimeSpanTooLong"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				_value := result.Value * 10000
			}
			this.m_ticks := new MfInt64(_value, false, true) ; read only
		}
		catch e
		{
			if (MfObject.IsObjInstance(e, "MfArgumentOutOfRangeException"))
			{
				throw e
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		base.__New(0)
		this.m_isInherited := this.base.__Class != "MfTimeSpan" ; Do not override this property in derrived classes
	}

	_ConstructorParams(MethodName, args*) {
		p := Null
		cnt := MfParams.GetArgCount(args*)
	
		if ((cnt > 0) && MfObject.IsObjInstance(args[1], MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
			; can be up to five parameters
			; Two parameters is not a possibility
			if ((p.Count > 5) || (p.Count = 2))
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
		}
		else
		{
			p := new MfParams()
			p.AllowEmptyString := false ; no strings for parameters in this case
						
			; can be up to five parameters
			; Two parameters is not a possibility
			if ((cnt > 5) || (cnt = 2))
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}

			if (cnt = 1) ; if there is only one arg then it must be timespan or ticks
			{
				try
				{
					arg := args[1]
					if (IsObject(arg))
					{
						p.Add(arg)
					} 
					else
					{
						p.AddInt64(arg)
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", index), e)
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
			else ; if cnt is not equal to 1 then should be all integers or no values at all
			{
				for index, arg in args
				{
					try
					{
						if (IsObject(arg))
						{
							p.Add(arg)
						} 
						else
						{
							p.AddInteger(arg)
						}
					}
					catch e
					{
						ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", index), e)
						ex.SetProp(A_LineFile, A_LineNumber, MethodName)
						throw ex
					}
				}
			}
		}
		return p
	}
; End:Constructor: () ;}
;{ Method
;{ 	Add
/*
	Method: Add()

	OutputVar := MfTimeSpan.Add(ts)

	Add(ts)
		Returns a new MfTimeSpan object whose value is the sum of the specified MfTimeSpan object and this instance.
	Parameters:
		ts
			An instance of MfTimeSpan representing time interval to add.
	Returns:
		Returns a new object that represents the value of this instance plus the value of ts.
	Throws:
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentException if ts is not an instance of MfTimeSpan.
		Throws MfOverflowException if the resulting MfTimeSpan is less than MinValue or greater than MaxValue.
	Remarks:
		The return value must be between MinValue and MaxValue; Otherwise, an exception is thrown.
		The return value is a new MfTimeSpan; the original MfTimeSpan is not modified.
*/
	Add(ts) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!MfObject.IsObjInstance(ts, "MfTimeSpan")) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "ts","MfTimeSpan"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_t := new MfInt64(this.m_Ticks.Value, true)

		try {
			_t.Add(ts.Ticks.Value)
			if ((this.m_Ticks.Value >> 63 = ts.m_Ticks.Value >> 63) && (this.m_Ticks.Value >> 63 != _t.Value >> 63)) {
				throw new MfException()
			}
		} catch e {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_TimeSpanTooLong"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return new MfTimeSpan(_t)
	}
; 	End:Add ;}
;{ 	Compare
/*
	Method: Compare()

	OutputVar := MfTimeSpan.Compare(t1, t2)

	Compare(t1, t2)
		Compares two MfTimeSpan values and returns an integer that indicates whether the first value is shorter than,
		equal to, or longer than the second value.
	Parameters:
		t1
			An instance of MfTimeSpan representing the first time interval to compare.
		t2
			An instance of MfTimeSpan representing the second time interval to compare.
	Returns:
		Returns -1 if t1 is shorter than t2.
		Returns 0 if t1 is equal to t2.
		Returns 1 if t1 is longer than t2.
	Throws:
		Throws MfArgumentException if t1 or t2 is not instance of MfTimeSpan.
	Remarks:
		Static method.
*/
	Compare(t1, t2) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!MfObject.IsObjInstance(t1, "MfTimeSpan")) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "t1","MfTimeSpan"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!MfObject.IsObjInstance(t2, "MfTimeSpan")) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "t2","MfTimeSpan"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (t1.m_Ticks.GreaterThen(t2.m_Ticks))
		{
			return 1
		}
		if (t1.m_Ticks.LessThen(t2.m_Ticks))
		{
			return -1
		}
		return 0
	}
; 	End:Compare ;}
;{ 	CompareTo()						- Overrides	- MfObject
/*
	Method: CompareTo()
		Overrides MfObject.CompareTo().

	OutputVar := instance.CompareTo(obj)

	CompareTo(obj)
		Compares the current instance with another object of the same type and returns an Integer that indicates whether the
		current instance preceedes, follows, or occurs in the same position in the sort order as the other object.
		This method can be overriden in derived classes.
	Parameters:
		obj
			An MfObject derived object or instance of MfTimeSpan to compare with this instance.
	Returns:
		Returns A value that indicates the relative order of the objects being compared. The return value has these
		meanings: Value Meaning Less than zero This instance precedes obj in the sort order.
		Zero This instance occurs in the same position in the sort order as obj Greater than zero This instance follows obj in the sort order.
	Throws:
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentException if obj is not the same type as this instance.
	Remarks:
		If parameter obj is instance of MfTimeSpan then it is compared to this instance otherwise comparision is done by MfObject.CompareTo().
*/
	CompareTo(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(obj)) {
			ex := new MfArgumentNullException("obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!MfObject.IsObjInstance(ts, "MfTimeSpan")) {
			return base.CompareTo(obj)
		}
		return MfTimeSpan.Compare(this, obj)
	}
; End:CompareTo() ;}
;{ 	Duration
/*
	Method: Duration()

	OutputVar := instance.Duration()

	Duration()
		Returns a new MfTimeSpan object whose value is the absolute value of the current MfTimeSpan object.
	Returns:
		Returns a new MfTimeSpan whose Value is the absolute Value of the current MfTimeSpan object.
	Throws:
		Throws MfNullReferenceException if not as instance.
		Throws MfOverflowException if the Value of this instance is MinValue.
*/
	Duration() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.Ticks.Equals(TimeSpan.MinValue.Ticks))
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Duration"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := ""
		if (this.m_Ticks.Value >= 0) {
			retval := new MfTimeSpan(this.m_Ticks.Value)
		} else {
			retval := new MfTimeSpan(-this.m_Ticks.Value)
		}
		return retval
	}
; 	End:Duration ;}
;{ 	Equals()						- Overrides	- MfObject
/*
	Method: Equals()
		Overrides MfObject.Equals().

	OutputVar := instance.Equals(obj)
	OutputVar := MfTimeSpan.Equals(objA, objB)

	Equals(obj)
		Compares objects to see if they are the same
	Parameters:
		obj
			The MfTimeSpan instance to compare to current instance.
	Returns:
		Returns var containing Boolean value of true if the obj is equal with current instance; Otherwise false.
	Remarks:
		MfTimeSpan objects are considered to be equal if then have the same Ticks.

	MfTimeSpan.Equals(objA, objB)
		Static Method.
		Compares objects to see if they are the same.
	Parameters:
		objA
			The MfTimeSpan instance to compare with objB.
		objB
			The MfTimeSpan instance to compare to objA.
	Returns:
		Returns var containing Boolean value of true if the objects are the same; Otherwise false.
	Throws:
		Throws MfNullReferenceException if objB is omitted and current object is not an instance of MfTimeSpan.
		Throws MfArgumentException if there is an error get a value from a parameter.
		Throws MfNotSupportedException if a parameter is not an intance of MfTimeSpan.
		Throws MfException on any general exceptions are caught.
	Remarks:
		MfTimeSpan objects are considered to be equal if then have the same Ticks.
*/
	Equals(args*) {
		isInst := this.IsInstance()

		objParams := Null
		if (isInst)
		{
			objParams := this._EqualsParams(A_ThisFunc, args*)
		}
		else
		{
			objParams := MfObject._EqualsParams(A_ThisFunc, args*)
		}

		retval := false
		try {
			strP := objParams.ToString()
			if (strP = "MfTimeSpan") {
				retval := this.Ticks.Equals(objParams.Item[0].Ticks)
				return retval
			}
			else if (strP = "MfTimeSpan,MfTimeSpan") {
				retval := objParams.Item[0].Ticks.Equals(objParams.Item[1].Ticks)
				return retval
			}
			else
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} catch e {
			if (MfObject.IsObjInstance(e, MfNotSupportedException))
			{
				throw e
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}

	
; End:Equals() ;}
;{ 	FromDays
/*
	Method: FromDays()

	OutputVar := MfTimeSpan.FromDays(value)

	MfTimeSpan.FromDays(value)
		Returns a MfTimeSpan that represents a specified number of days, where the specification is accurate to the nearest millisecond.
	Parameters:
		value
			A number of days, accurate to the nearest millisecond.
			Can be var containing float or any object that matches MfType.IsNumber.
	Returns:
		Returns an instance of MfTimeSpan object that represents value.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfOverflowException if value is less than MinValue or greater than MaxValue.
		Throws MfInvalidCastException if value cannot be cast to MfFloat.
	Remarks:
		Static Method
		The value parameter is converted to milliseconds, which is converted to ticks, and that number of ticks is used to
		initialize the new MfTimeSpan. Therefore, value will only be considered accurate to the nearest millisecond.
		
		Note that, because of the loss of precision of the MfFloat data type, this conversion can cause an MfOverflowException
		for values that are near to but still in the range of either MinValue or MaxValue.
*/
	FromDays(value) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		_value := Null
		if (IsObject(value)) {
			T := new MfType(value)
			if (T.IsNumber)
			{
				_value := new MfFloat(value.Value)
			}
			else
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "value","MfFloat"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} else {
			try {
				_value := new MfFloat(MfFloat.GetValue(value))
			} catch e {
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToFloat"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		
		try {
			return MfTimeSpan.Interval(_value, new MfInteger(86400000, true))
		} catch e {
			throw e
		}
		
	}
; 	End:FromDays ;}
;{ 	FromHours
/*
	Method: FromHours()

	OutputVar := MfTimeSpan.FromHours(value)

	MfTimeSpan.FromHours(value)
		Returns a MfTimeSpan that represents a specified number of hours, where the specification is accurate to the nearest millisecond.
	Parameters:
		value
			A number of hours, accurate to the nearest millisecond.
			Can be var containing float or any object that matches MfType.IsNumber.
	Returns:
		Returns an instance of MfTimeSpan object that represents value.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfOverflowException if value is less than MinValue or greater than MaxValue.
		Throws MfInvalidCastException if value cannot be cast to MfFloat.
	Remarks:
		Static Method.
		The value parameter is converted to milliseconds, which is converted to ticks, and that number of ticks is used to initialize the new MfTimeSpan.
		Therefore, value will only be considered accurate to the nearest millisecond.

		Note that, because of the loss of precision of the MfFloat data type, this conversion can cause an MfOverflowException for values
		that are near to but still in the range of either MinValue or MaxValue.
*/
	FromHours(value) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		_value := Null
		if (IsObject(value)) {
			T := new MfType(value)
			if (T.IsNumber)
			{
				_value := new MfFloat(value.Value)
			}
			else
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "value","MfFloat"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} else {
			try {
				_value := new MfFloat(MfFloat.GetValue(value))
			} catch e {
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToFloat"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		try {
			return MfTimeSpan.Interval(_value, new MfInteger(3600000, true))
		} catch e {
			throw e
		}
		
	}
; 	End:FromHours ;}
;{ 	FromMilliseconds
/*
	Method: FromMilliseconds()

	OutputVar := MfTimeSpan.FromMilliseconds(value)

	MfTimeSpan.FromMilliseconds(value)
		Returns a MfTimeSpan that represents a specified number of milliseconds, where the specification is accurate to the nearest millisecond.
	Parameters:
		value
			A number of hours, accurate to the nearest millisecond.
			Can be var containing float or any object that matches MfType.IsNumber.
	Returns:
		Returns an instance of MfTimeSpan object that represents value.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfOverflowException if value is less than MinValue or greater than MaxValue.
		Throws MfInvalidCastException if value cannot be cast to MfFloat.
	Remarks:
		Static Method.
		The value parameter is converted to milliseconds, which is converted to ticks, and that number of ticks is used to initialize the new MfTimeSpan.
		Therefore, value will only be considered accurate to the nearest millisecond.

		Note that, because of the loss of precision of the MfFloat data type, this conversion can cause an MfOverflowException for values
		that are near to but still in the range of either MinValue or MaxValue.
*/
	FromMilliseconds(value) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		_value := Null
		if (IsObject(value)) {
			T := new MfType(value)
			if (T.IsNumber)
			{
				_value := new MfFloat(value.Value)
			}
			else
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "value","MfFloat"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} else {
			try {
				_value := new MfFloat(MfFloat.GetValue(value))
			} catch e {
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToFloat"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		try {
			return MfTimeSpan.Interval(_value, new MfInteger(1, true))
		} catch e {
			throw e
		}
		
	}
; 	End:FromMilliseconds ;}
;{ 	FromMinutes
/*
	Method: FromMinutes()

	OutputVar := MfTimeSpan.FromMinutes(value)

	MfTimeSpan.FromMinutes(value)
		Returns a MfTimeSpan that represents a specified number of minutes, where the specification is accurate to the nearest millisecond.
	Parameters:
		value
			A number of minutes, accurate to the nearest millisecond.
			Can be var containing float or any object that matches MfType.IsNumber.
	Returns:
		Returns an instance of MfTimeSpan object that represents value.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfOverflowException if value is less than MinValue or greater than MaxValue.
		Throws MfInvalidCastException if value cannot be cast to MfFloat.
	Remarks:
		Static Method.
		The value parameter is converted to milliseconds, which is converted to ticks, and that number of ticks is used to initialize the new MfTimeSpan.
		Therefore, value will only be considered accurate to the nearest millisecond.

		Note that, because of the loss of precision of the MfFloat data type, this conversion can cause an MfOverflowException for values
		that are near to but still in the range of either MinValue or MaxValue.
*/
	FromMinutes(value) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		_value := Null
		if (IsObject(value)) {
			T := new MfType(value)
			if (T.IsNumber)
			{
				_value := new MfFloat(value.Value)
			}
			else
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "value","MfFloat"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} else {
			try {
				_value := new MfFloat(MfFloat.GetValue(value))
			} catch e {
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToFloat"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		try {
			return MfTimeSpan.Interval(_value, new MfInteger(60000, true))
		} catch e {
			throw e
		}
		
	}
; 	End:FromMinutes ;}
;{ 	FromSeconds
/*
	Method: FromSeconds()

	OutputVar := MfTimeSpan.FromSeconds(value)

	MfTimeSpan.FromSeconds(value)
		Returns a MfTimeSpan that represents a specified number of seconds, where the specification is accurate to the nearest minutes.
	Parameters:
		value
			A number of hours, accurate to the nearest millisecond.
			Can be var containing float or any object that matches MfType.IsNumber.
	Returns:
		Returns an instance of MfTimeSpan object that represents value.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfOverflowException if value is less than MinValue or greater than MaxValue.
		Throws MfInvalidCastException if value cannot be cast to MfFloat.
	Remarks:
		Static Method.
		The value parameter is converted to milliseconds, which is converted to ticks, and that number of ticks is used to initialize the new MfTimeSpan.
		Therefore, value will only be considered accurate to the nearest millisecond.

		Note that, because of the loss of precision of the MfFloat data type, this conversion can cause an MfOverflowException for values
		that are near to but still in the range of either MinValue or MaxValue.
*/
	FromSeconds(value) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		_value := Null
		if (IsObject(value)) {
			T := new MfType(value)
			if (T.IsNumber)
			{
				_value := new MfFloat(value.Value)
			}
			else
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "value","MfFloat"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} else {
			try {
				_value := new MfFloat(MfFloat.GetValue(value))
			} catch e {
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToFloat"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		try {
			return MfTimeSpan.Interval(_value, new MfInteger(1000, true))
		} catch e {
			throw e
		}
		
	}
; 	End:FromSeconds ;}
;{ 	FromTicks
/*
	Method: FromTicks()

	OutputVar := MfTimeSpan.FromTicks(value)

	MfTimeSpan.FromTicks(value)
		Returns a MfTimeSpan that represents a specified time, where the specification is in units of ticks.
	Parameters:
		value
			A number of hours, accurate to the nearest millisecond.
			Can be instance of MfInt64, MfInteger or var containing integer.
	Returns:
		Returns an instance of MfTimeSpan object that represents value.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfOverflowException if value is less than MinValue or greater than MaxValue.
		Throws MfInvalidCastException if value cannot be cast to MfInt64.
	Remarks:
		Static Method.
		The value parameter is converted to milliseconds, which is converted to ticks, and that number of ticks is used to initialize the new MfTimeSpan.
		Therefore, value will only be considered accurate to the nearest millisecond.

		Note that, because of the loss of precision of the MfFloat data type, this conversion can cause an MfOverflowException for values
		that are near to but still in the range of either MinValue or MaxValue.
*/
	FromTicks(value) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		_value := Null
		if (IsObject(value)) {
			if ((!MfObject.IsObjInstance(value, "MfInt64")) && (!MfObject.IsObjInstance(value, "MfInteger"))) {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "value","MfInt64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_value := new MfInt64(MfInt64.GetValue(value), true)
		} else {
			try {
				_value := MfInt64.GetValue(value)
			} catch e {
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInt64"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		try {
			if (_value.Value = 0) {
				return MfTimeSpan.Zero
			}
			return new MfTimeSpan(_value)
		} catch e {
			throw e
		}
		
	}
; 	End:FromTicks ;}

;{	GetHashCode()					- Overrides	- MfObject
/*
	Method: GetHashCode()
		Overrides MfObject.GetHashCode()

	OutputVar := instance.GetHashCode()

	GetHashCode()
		Gets A hash code for the MfTimeSpan instance.
	Returns:
		A 32-bit signed integer hash code as var.
	Throws:
		Throws MfNullReferenceException if object is not an instance.
*/
	GetHashCode() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		return this.m_Ticks.GetHashCode()
	}
; End:GetHashCode() ;}
;{ 	Interval						- Private
/*
	Method: Interval(value, scale)
	Parameters:
		value - MfFloat instance
		scale - MfInteger instance
	Remarks:
		Private method
*/
	Interval(value, scale) {
		ws := A_FormatFloat
		SetFormat, FloatFast, 0.1
		x := value.Value * (scale.Value + 0.0)
		y := x + ((value.Value >= 0.0) ? 0.5 : -0.5)
		if (y > 922337203685477.0 || y < -922337203685477.0)
		{
			SetFormat, FloatFast, %ws%
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_TimeSpanTooLong"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		SetFormat, FloatFast, %ws%
		ts := new MfTimeSpan(new MfInt64((y > 0.0?Floor(y):Ceil(y)) * 10000))
		return ts
	}
; 	End:Interval ;}
;{ 	Negate
/*
	Method: Negate()

	OutputVar := instance.Negate()

	Negate()
		Returns a new MfTimeSpan object whose value is the negated value of this instance.
	Returns:
		Returns a new MfTimeSpan object with the same numeric value as this instance, but with the opposite sign.
	Throws:
		Throws MfNullReferenceException if called as a static method.
		Throws MfOverflowException if the negated value of this instance cannot be represented by a MfTimeSpan;
		that is, the value of this instance is MinValue.
*/
	Negate() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.Ticks.Equals(TimeSpan.MinValue.Ticks))
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_NegateTwosCompNum"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return new MfTimeSpan(new MfInt64(-this.m_ticks.Value))
	}
; 	End:Negate ;}
;{ 	Parse
/*
	Method: Parse()

	OutputVar := MfTimeSpan.Parse(str)

	MfTimeSpan.Parse(str)
		Static Method.
		Converts the string representation of a time interval to its MfTimeSpan equivalent.
	Parameters:
		str
			A string that specifies the time interval to convert. Can be instance of MfString or var containing string.
	Returns:
		Returns a time interval that corresponds to str.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfFormatException if str has an invalid format.
		Throws MfOverflowException if represents a number that is less than MinValue or greater than MaxValue or At least one
		of the days, hours, minutes, or seconds components is outside its valid range.
	Remarks:
		Static Method.
		The s parameter contains a time interval specification in the form:

		[ws][-]{ d | [d.]hh:mm[:ss[.ff]] }[ws]

		ws - Optional white space.
		- An optional minus sign, which indicates a negative MfTimeSpan.
		d - Days, ranging from 0 to 10675199.
		. - Seperator symbol.
		hh - Hours, ranging from 0 to 23.
		: - Seperator symbol.
		mm - Minutes, ranging from 0 to 59.
		ss - Optional seconds, ranging from 0 to 59.
		. - Seperator symbol that separates seconds from fractions of a second.
		ff - Optional fractional seconds, consisting of one to seven decimal digits.
		The components of s must collectively specify a time interval that is greater than or equal to MinValue and less than or equal to MaxValue.
*/
	Parse(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfObject.IsObjInstance(args[1], MfParams)) {
			objParams := args[1] ; arg 1 is a MfParams object so we will use it
		} else {
			objParams := new MfParams()
			for index, arg in args
			{
				objParams.Add(arg)
			}
		}
		retval := ""
		_neg := false
		try {
			strP := objParams.ToString()
			if (strP = "MfString") {
				strV := objParams.Item[0].Value
				if (RegExMatch(strV, "^\s*(-?\d{1,8})\s*$", match)) {
					iDays := New MfInteger(match1)
					if ((iDays.Value <= 10675199) && (iDays.Value >= -10675199)) {
						retval := MfTimeSpan.FromDays(iDays)
					}
				} else if (RegExMatch(strV, "^\s*(-?\d{1,2}):(\d{1,2})\s*$", match)) {
					iHours := new MfInteger(match1)
					iMin := new MfInteger(match2)
					if (iHours.Value < 0) {
						_neg := true
						iHours.Value := -iHours.Value
					}
					retval := MfTimeSpan._ParseBuild(0, iHours, iMin)
				} else if (RegExMatch(strV, "^\s*(-?\d{1,2}):(\d{1,2}):(\d{1,2})\s*$", match)) {
					iHours := new MfInteger(match1)
					iMin := new MfInteger(match2)
					isec := new MfInteger(match3)
					if (iHours.Value < 0) {
						_neg := true
						iHours.Value := -iHours.Value
					}
					retval := MfTimeSpan._ParseBuild(0, iHours, iMin, isec)
				} else if (RegExMatch(strV, "^\s*(-?\d{1,8})\.(\d{1,2})\s*$", match)) {
					iDays := new MfInteger(match1)
					iHours := new MfInteger(match2)
					if (iDays.Value < 0) {
						_neg := true
						iDays.Value := -iDays.Value
					}
					retval := MfTimeSpan._ParseBuild(iDays, iHours)
				} else if (RegExMatch(strV, "^\s*(-?\d{1,8})\.(\d{1,2}):(\d{1,2})\s*$", match)) {
					iDays := new MfInteger(match1)
					iHours := new MfInteger(match2)
					iMin := new MfInteger(match3)
					if (iDays.Value < 0) {
						_neg := true
						iDays.Value := -iDays.Value
					}
					retval := MfTimeSpan._ParseBuild(iDays, iHours, iMin)
				} else if (RegExMatch(strV, "^\s*(-?\d{1,8})[.:](\d{1,2}):(\d{1,2}):(\d{1,2})\s*$", match)) {
					iDays := new MfInteger(match1)
					iHours := new MfInteger(match2)
					iMin := new MfInteger(match3)
					iSec := new MfInteger(match4)
					if (iDays.Value < 0) {
						_neg := true
						iDays.Value := -iDays.Value
					}
					retval := MfTimeSpan._ParseBuild(iDays, iHours,iMin, iSec)
				} else if (RegExMatch(strV, "^\s*(-?\d{1,8})[.:](\d{1,2}):(\d{1,2}):(\d{1,2})\.(\d{1,7})\s*$", match)) {
					iDays := new MfInteger(match1)
					iHours := new MfInteger(match2)
					iMin := new MfInteger(match3)
					iSec := new MfInteger(match4)
					iFrac := new MfInteger(match5)
					if (iDays.Value < 0) {
						_neg := true
						iDays.Value := -iDays.Value
					}
					retval := MfTimeSpan._ParseBuild(iDays, iHours, iMin, iSec, iFrac, MfTimeSpan._LeadingZeros(match5))
				}
			}
		} catch e {
			if (MfObject.IsObjInstance(e, "MfOverflowException")) {
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_TimeSpanTooLong"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(retval)) {
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_neg = true) {
			retval := retval.Negate()
		}
		return retval
	}
; 	End:Parse ;}
;{ 	_ParseBuild						- private - static
	_ParseBuild(iDays=0,iHours=0, iMin=0, iSec=0, iFrac=0, iLz = 0) {
		oDays := new MfInteger(MfInteger.GetValue(idays))
		oHours := new MfInteger(MfInteger.GetValue(iHours))
		oMin := new MfInteger(MfInteger.GetValue(iMin))
		oSec := new MfInteger(MfInteger.GetValue(iSec))
		oFrac := new MfInteger(MfInteger.GetValue(iFrac))
		oLz := new MfInteger(MfInteger.GetValue(iLz))
		retval := MfNull.Null
		if ((oDays.Value >= 0)
			&& (oDays.Value <= 10675199)
			&& (oHours.Value >= 0)
			&& (oHours.Value <= 23)
			&& (oMin.Value >= 0)
			&& (oMin.Value <= 59)
			&& (oSec.Value >= 0)
			&& (oSec.Value <= 59)) {
				_ticks := ((oDays.Value * 3600 * 24) + (oHours.Value * 3600) + (oMin.Value * 60) + oSec.Value) * 1000
				_length := 5 - StrLen(oFrac.Value)
				_frac := oFrac.Value
				if (oFrac.Value > 0) {
					_m := 1000000
					if (oLz.Value > 0) {
						_p := 10 ** oLz.Value
						_m //= _p
					}
					while (_frac < _m)
					{
						_frac *= 10
					}
				}
				_TTicks := Floor(_ticks * 10000 + _frac)
				retval := new mfTimeSpan(new MfInt64(_TTicks))
		} else {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_TimeSpanTooLong"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		return retval
	}
; 	End:_ParseBuild ;}
;{ 	_LeadingZeros					- private - static
	; internal static method. counts the number of zeros at the beginning of a string and returns as var integer.
	_LeadingZeros(value) {
		ary := Mfunc.StringSplit(value)
		retval := 0
		i := 0
		while i < ary.count
		{
			i++
			if (ary[i] = "0") {
				retval++
			} else {
				break
			}
		}
		return retval
	}
; 	End:_LeadingZeros ;}
;{ 	Subtract
/*
	Method: Subtract()

	OutputVar := instance.Subtract(ts)

	Subtract(ts)
		Returns a new MfTimeSpan object whose Value is the difference between the specified MfTimeSpan instance and this instance.
	Parameters:
		ts
			ts - An instance of MfTimeSpan representing time interval to subtract.
	Returns:
		Returns a new MfTimeSpan whose Value is the result of the Value of this instance minus the Value of ts.
	Throws:
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentException if ts is not an instance of MfTimeSpan.
		Throws MfOverflowException if the resulting MfTimeSpan is less than MinValue or greater then MaxValue.
	Remarks:
		The time interval to be subtracted.
*/
	Subtract(ts) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!MfObject.IsObjInstance(ts, "MfTimeSpan")) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "ts","MfTimeSpan"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_t := new MfInt64(this.m_Ticks.Value, true)
		try {
			_t.Subtract(ts.Ticks.Value)
			if (this.m_Ticks.Value >> 63 != ts.m_Ticks.Value >> 63 && this.m_Ticks >> 63 != _t.Value >> 63) {
				throw new MfException()
			}
		} catch e {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_TimeSpanTooLong"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return new MfTimeSpan(_t)
	}
; 	End:Subtract ;}
;{ 	TimeToTicks						-internal - static
	TimeToTicks(hour, minute, second) {
		lhour := new MfInt64(MfInt64.GetValue(hour))
		lmin := new MfInt64(MfInt64.GetValue(minute))
		lsec := new MfInt64(MfInt64.GetValue(second))
		result := new MfInt64()
		result.Value := (lhour.Value * 3600) + (lmin.Value * 60) + lsec.Value
		if ((result.Value > 922337203685) || (result.Value < -922337203685)) {
			ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("Overflow_TimeSpanTooLong"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		result.Value := result.Value * 10000000
		return result
	}
; 	End:TimeToTicks ;}
;{ 	ToString()						- overrides	- MfObject
/*
	Method: ToString()
		Overrides MfObject.ToString().

	OutputVar := instance.ToString()

	ToString()
		Gets a string representation of the current instance of MfTimeSpan.
	Returns:
		Returns string var representing current instance
	Throws:
		Throws MfNullReferenceException if called as a static method.
*/
	ToString() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		ws := A_FormatInteger
		SetFormat, IntegerFast, D
		retval := new MfString()
		_Days := (this.m_Ticks.Value // 864000000000) 
		_DaysR := Mod(this.m_Ticks.Value, 864000000000)
		
		_hours := Mod((_DaysR // 36000000000), 24)
		_minutes := Mod((_DaysR // 600000000), 60)
		_seconds := Mod((_DaysR // 10000000), 60)
		_ms := Mod(_DaysR, 10000000)
		
		
		if (this.m_Ticks.Value < 0) {
			retval.Append("-")
		}
		pc := new MfChar("0")
		iPad := new MfInteger(2)
		itotal := _Days
		if (itotal <> 0) {
			retval.Append(MfString.PadLeft(Abs(_Days), iPad, pc))
			retval.Append(".")
		}
		itotal := (itotal = 0) ? _hours:itotal
		if (itotal <> 0) {
			retval.Append(MfString.PadLeft(Abs(_hours), iPad, pc))
			retval.Append(":")
		}
		itotal := (itotal = 0) ? _minutes:itotal
		if (itotal <> 0) {
			retval.Append(MfString.PadLeft(Abs(_minutes), iPad, pc))
			retval.Append(":")
		}
		
		retval.Append(MfString.PadLeft(Abs(_seconds), iPad, pc))
		if (this.Milliseconds.Value <> 0) {
			
			_frac := _ms ; this.Milliseconds.Value
			_m := 1000000
			zeroCount := 0
			while (_frac < _m)
			{
				_frac *= 10
				zeroCount++
			}
			retval.Append(".")
			Loop %zeroCount%
			{
				retval.Append(pc.ToString())
			}
			retval.Append(_ms)
		}
		SetFormat ,IntegerFast, %ws%
		;~ retval.Append(ms.ToString())
		return retval.Value
	}
;	End:ToString() ;}
;{ 	TryParse
/*
	Method: TryParse()

	OutputVar := MfTimeSpan.TryParse(result, s)

	MfTimeSpan.TryParse(result, s)
		Static Method.
		Converts the string representation of a time interval to its MfTimeSpan equivalent and
		returns a value that indicates whether the conversion succeeded.
	Parameters:
		result
			When this method returns, contains an object that represents the time interval specified by s, or Zero if the conversion failed.
		s
			A string that specifies the time interval to convert.
			Can be instance of MfString or var containing string.
	Returns:
		Static Method.
		Returns true if s was converted successfully; Otherwise, false.
		This operation returns false if the s parameter is null, has an invalid format, represents a time interval that is less
		than MinValue or greater than MaxValue, or has at least one days, hours, minutes, or seconds component outside its valid range.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
	Remarks:
		The TryParse method is like the Parse() method, except that it does not throw an exception if the conversion fails.
*/
	TryParse(byref result, args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!MfObject.IsObjInstance(result, "MfTimeSpan")) {
			return false
		}
		retval := false
		try {
			_ts := MfTimeSpan.Parse(args*)
			result.Ticks.Value := _ts.Ticks.Value
			retval := true
		} catch e {
			result.Ticks.Value := MfTimeSpan.Zero.Ticks.Value
			retval := false
		}
		return retval
	}
; 	End:TryParse ;}
; End:Method ;}
;{ Properties
;{ 	MaxMilliSeconds 		- internal 	- const
	static m_MaxMilliSeconds := ""
	MaxMilliSeconds[]
	{
		get {
			if (MfTimeSpan.m_MaxMilliSeconds = "")
			{
				MfTimeSpan.m_MaxMilliSeconds := new MfInt64(922337203685477,true, true) ; readonly
			}
			return MfTimeSpan.m_MaxMilliSeconds
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MaxMilliSeconds ;}
;{ 	MaxSeconds 				- internal 	- const
	static m_MaxSeconds	:= ""
	MaxSeconds[]
	{
		get {
			if (MfTimeSpan.m_MaxSeconds = "")
			{
				MfTimeSpan.m_MaxSeconds := new MfInt64(922337203685,true, true) ; readonly
			}
			return MfTimeSpan.m_MaxSeconds
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MaxSeconds ;}
;{ 	MillisPerDay 			- private	- const
	static m_MillisPerDay := ""
	MillisPerDay[]
	{
		get {
			if (MfTimeSpan.m_MillisPerDay = "")
			{
				MfTimeSpan.m_MillisPerDay := new MfInteger(86400000, true, true) ; readonly
			}
			return MfTimeSpan.m_MillisPerDay
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MillisPerDay ;}
;{ 	MillisPerHour 			- private	- const
	static m_MillisPerHour := ""
	MillisPerHour[]
	{
		get {
			if (MfTimeSpan.m_MillisPerHour = "")
			{
				MfTimeSpan.m_MillisPerHour := new MfInteger(3600000, true, true) ; readonly
			}
			return MfTimeSpan.m_MillisPerHour
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MillisPerHour ;}
;{ 	MillisPerMinute 		- private	- const
	static m_MillisPerMinute := ""
	MillisPerMinute[]
	{
		get {
			if (MfTimeSpan.m_MillisPerMinute = "")
			{
				MfTimeSpan.m_MillisPerMinute := new MfInteger(60000, true, true) ; readonly
			}
			return MfTimeSpan.m_MillisPerMinute
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MillisPerMinute ;}
;{ 	MillisPerSecond 		- private	- const
	static m_MillisPerSecond := ""
	MillisPerSecond[]
	{
		get {
			if (MfTimeSpan.m_MillisPerSecond = "")
			{
				MfTimeSpan.m_MillisPerSecond := new MfInteger(1000, true, true) ; readonly
			}
			return MfTimeSpan.m_MillisPerSecond
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MillisPerSecond ;}
;{ 	MinMilliSeconds 		- internal	- const
	static m_MinMilliSeconds := ""
	MinMilliSeconds[]
	{
		get {
			if (MfTimeSpan.m_MinMilliSeconds = "")
			{
				MfTimeSpan.m_MinMilliSeconds := new MfInt64(-922337203685477, true, true) ; readonly
			}
			return MfTimeSpan.m_MinMilliSeconds
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MinMilliSeconds ;}
;{ 	MinSeconds 				- internal	- const
	static m_MinSeconds := ""
	MinSeconds[]
	{
		get {
			if (MfTimeSpan.m_MinSeconds = "")
			{
				MfTimeSpan.m_MinSeconds := new MfInt64(-922337203685, true, true) ; ReadOnly
			}
			return MfTimeSpan.m_MinSeconds
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MinSeconds ;}
;{ 	TicksPerTenthSecond		- internal	- const
	static m_TicksPerTenthSecond := ""
	TicksPerTenthSecond[]
	{
		get {
			if (MfTimeSpan.m_TicksPerTenthSecond = "")
			{
				MfTimeSpan.m_TicksPerTenthSecond := new MfInt64(1000000, true, true) ; readonly
			}
			return MfTimeSpan.m_TicksPerTenthSecond
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:TicksPerTenthSecond ;}
;{ 	TypeCode				- internal	- const
	TypeCode[]
	{
		get {
			return 23
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:TypeCode ;}
;{ 	Days					- public	- property
	m_Days := Null
/*
	Property: Days [get]
		Gets the days component of the time interval represented by the current MfTimeSpan object as MfInteger object.
	Value:
		Instance of MfInteger
	Gets:
		Gets the days component of the current MfTimeSpan class as a read-only instance of MfInteger.
	Remarks:
		Read-only property.
		A MfTimeSpan value can be represented as [-]d.hh:mm:ss.ff, where the optional minus sign indicates a negative time interval,
		the d component is days, hh is hours as measured on a 24-hour clock, mm is minutes, ss is seconds, and ff is fractions of a second.
		The value of the Days property is the day component, d.
		Days represents whole days, whereas the TotalDays property represents whole and fractional days.
*/
	Days[]
	{
		get {
			if (MfNull.IsNull(this.m_Days))
			{
				d := this.m_ticks.Value // 864000000000
				this.m_Days := new MfInteger(d, true, true) ; readonly
			}
			return this.m_days
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Days ;}
;{ 	Hours					- public	- property
	m_hours := Null
/*
	Property: Hours [get]
		Gets the hours component of the time interval represented by the current MfTimeSpan object as MfInteger object.
	Value:
		Instance of MfInteger
	Gets:
		The hour component of the current MfTimeSpan class as a read-only instance of MfInteger object with value ranges from -23 through 23.
	Remarks:
		Read-only property.
		A MfTimeSpan value can be represented as [-]d.hh:mm:ss.ff, where the optional minus sign indicates a negative time interval,
		the d component is days, hh is hours as measured on a 24-hour clock, mm is minutes, ss is seconds, and ff is fractions of a second.
		The value of the Hours property is the hours component, hh.
		Hours represents whole hours, whereas the TotalHours property represents whole and fractional hours.
*/
	Hours[]
	{
		get {
			if (MfNull.IsNull(this.m_hours))
			{
				h := this.m_ticks.Value // 36000000000
				h := mod(h, 24)
				this.m_hours := new MfInteger(h, true, true) ; readonly
			}
			return this.m_hours
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Hours ;}
;{ 	MaxValue				- public	- property
	static m_MaxValue := ""
/*
	Property: MaxValue [get]
		Gets the maximum MfTimeSpan value. This field is Static Read-only.
	Value:
		Instance of MfTimeSpan.
	Gets:
		Gets Represents the maximum MfTimeSpan value.
	Remarks:
		Static read-only Field.
		The value of this field is equivalent to MfInt64.MaxValue ticks.
		The string representation of this value is positive 10675199.02:48:05.4775807, or slightly more than 10,675,199 days.
*/
	MaxValue[]
	{
		get {
			if (MfTimeSpan.m_MaxValue = "")
			{
				MfTimeSpan.m_MaxValue := new MfTimeSpan(new MfInt64(MfInt64.MaxValue, true))
			}
			return MfTimeSpan.m_MaxValue
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MaxValue ;}
;{ 	Milliseconds			- public	- property
	m_Milliseconds := Null
/*
	Property: Milliseconds [get]
		Gets the milliseconds component of the time interval represented by the current MfTimeSpan object as MfInteger object.
	Value:
		Instance of MfInteger
	Gets:
		The millisecond component of the current MfTimeSpan class as a read-only instance MfInteger object with value ranges from -999 through 999.
	Remarks:
		Read-only property.
		A MfTimeSpan value can be represented as [-]d.hh:mm:ss.ff, where the optional minus sign indicates a negative time interval, the d component is days, hh is hours as measured on a 24-hour clock, mm is minutes, ss is seconds, and ff is fractions of a second. The value of the Milliseconds property is the fractional second component, ff.
		Milliseconds represents whole milliseconds, whereas the TotalMilliseconds property represents whole and fractional milliseconds.
*/
	Milliseconds[]
	{
		get {
			if (MfNull.IsNull(this.m_Milliseconds))
			{
				i := this.m_ticks.Value // 10000
				y := mod(i, 1000)
				this.m_Milliseconds := new MfInteger(y, true, true) ; ReadOnly
			}
			return this.m_Milliseconds
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Milliseconds ;}
;{ 	Minutes					- public	- property
	m_Minutes := Null
/*
	Property: Minutes [get]
		Gets the minutes component of the time interval represented by the current MfTimeSpan class as MfInteger object.
	Value:
		Instance of MfInteger
	Gets:
		The minute component of the current MfTimeSpan class as a read-only instance of MfInteger object with value ranges from -59 through 59.
	Remarks:
		Read-only property.
		A MfTimeSpan value can be represented as [-]d.hh:mm:ss.ff, where the optional minus sign indicates a negative time interval,
		the d component is days, hh is hours as measured on a 24-hour clock, mm is minutes, ss is seconds, and ff is fractions of a second.
		The value of the Minutes property is the minute component, mm.
		Minutes represents whole minutes, whereas the TotalMinutes property represents whole and fractional minutes.
*/
	Minutes[]
	{
		get {
			if (MfNull.IsNull(this.m_Minutes))
			{
				i := this.m_ticks.Value // 600000000
				i := mod(i, 60)
				this.m_Minutes := new MfInteger(i, true, true) ; readonly
			}
			return this.m_Minutes
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End: Minutes ;}
;{ 	MinValue				- public	- const
	static m_MinValue := ""
/*
	Property: MinValue [get]
		Gets the minimum MfTimeSpan value. This field is Static Read-only.
	Value:
		Instance of MfTimeSpan.
	Gets:
		Gets Represents the minimum MfTimeSpan value.
	Remarks:
		Static read-only Field.
		The value of this field is equivalent to MfInt64.MinValue ticks.
		The string representation of this value is negative 10675199.02:48:05.4775808, or slightly more than negative 10,675,199 days.
*/
	MinValue[]
	{
		get {
			if (MfTimeSpan.m_MinValue = "")
			{
				MfTimeSpan.m_MinValue := new MfTimeSpan(new MfInt64(MfInt64.MinValue, true))
			}
			return MfTimeSpan.m_MinValue
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MinValue ;}
;{ 	Seconds					- public	- property
	m_Seconds := Null
/*
	Property: Seconds [get]
		Gets the seconds component of the time interval represented by the current MfTimeSpan object as MfInteger object.
	Value:
		Instance of MfInteger
	Gets:
		The second component of the current MfTimeSpan class as read-only instance of MfInteger object with value ranges from -59 through 59.
	Remarks:
		Read-only property.
		A MfTimeSpan value can be represented as [-]d.hh:mm:ss.ff, where the optional minus sign indicates a negative time interval, the d component is days, hh is hours as measured on a 24-hour clock, mm is minutes, ss is seconds, and ff is fractions of a second. The value of the Seconds property is the seconds component, ss.
		Seconds represents whole seconds, whereas the TotalSeconds property represents whole and fractional seconds.
		Seconds is a  read-only instance of MfInteger with ReturnAsObject set to true.
*/
	Seconds[]
	{
		get {
			if (MfNull.IsNull(this.m_Seconds))
			{
				i := this.m_ticks.Value / 10000000
				i := mod(i, 60)
				if (i >= 0.0) {
					this.m_Seconds := new MfInteger(Floor(i), true, true) ; ReadOnly
				} else {
					this.m_Seconds := new MfInteger(Ceil(i), true) ; readonly
				}
			}
			return this.m_Seconds
			}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Seconds ;}
;{ 	Ticks					- public	- property
	m_Ticks := Null
/*
	Property: Ticks [get]
		Gets the number of ticks that represent the value of the current MfTimeSpan object as MfInt64 object.
	Value:
		Instance of MfInt64
	Gets:
		The number of ticks contained in this instance as a read-only instance MfInt64 object.
	Remarks:
		The smallest unit of time is the tick, which is equal to 100 nanoseconds or one ten-millionth of a second.
		There are 10,000 ticks in a millisecond. The value of the Ticks property can be negative or positive to represent a
		negative or positive time interval.
*/
	Ticks[]
	{
		get {
			return this.m_Ticks
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Ticks ;}
;{ 	TicksPerDay				- public	- const
	static m_TicksPerDay := ""
/*
	Property: TicksPerDay [get]
		Gets the number of ticks in 1 day as instance of MfInt64. This field is constant.
	Value:
		Instance of MfInt64
	Gets:
		Gets the number of ticks in 1 day as a read-only instance of MfInt64.
	Remarks:
		Static read-only Field.
		The value of this constant is 864 billion; that is, 864,000,000,000.
		TickPerDay is a  read-only instance of MfInt64 with ReturnAsObject set to true.
*/
	TicksPerDay[]
	{
		get {
			if (MfTimeSpan.m_TicksPerDay = "")
			{
				MfTimeSpan.m_TicksPerDay := new MfInt64(864000000000, true, true) ; readonly
			}
			return MfTimeSpan.m_TicksPerDay
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:TicksPerDay ;}
;{ 	TicksPerHour			- public	- const
	static m_TicksPerHour := ""
/*
	Property: TicksPerHour [get]
		Gets the number of ticks in 1 millisecond as instance of MfInt64. This field is constant.
	Value:
		Instance of MfInt64
	Gets:
		Gets the number of ticks in 1 millisecond as a read-only instance of MfInt64.
	Remarks:
		Static read-only Field.
		The value of this constant  is 36 billion; that is, 36,000,000,000.
		TicksPerHour is a  read-only instance of MfInt64 with ReturnAsObject set to true.
*/
	TicksPerHour[]
	{
		get {
			if (MfTimeSpan.m_TicksPerHour = "")
			{
				MfTimeSpan.m_TicksPerHour := new MfInt64(36000000000, true, true) ; readonly
			}
			return MfTimeSpan.m_TicksPerHour
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:TicksPerHour ;}
;{ 	TicksPerMillisecond		- public	- const
	static m_TicksPerMillisecond := ""
/*
	Property: TicksPerMillisecond [get]
		Gets the number of ticks in 1 millisecond as instance of MfInt64. This field is constant.
	Value:
		Instance of MfInt64
	Gets:
		Gets the number of ticks in 1 millisecond as a read-only instance of MfInt64.
	Remarks:
		Static read-only Field.
		The value of this constant is 10 thousand; that is, 10,000.
		TicksPerMillisecond is a  read-only instance of MfInt64 with ReturnAsObject set to true.
*/
	TicksPerMillisecond[]
	{
		get {
			if (MfTimeSpan.m_TicksPerMillisecond = "")
			{
				MfTimeSpan.m_TicksPerMillisecond := new MfInt64(10000, true, true) ; readonly
			}
			return MfTimeSpan.m_TicksPerMillisecond
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:TicksPerMillisecond ;}
;{ 	TicksPerMinute			- public	- const
	static m_TicksPerMinute	:= ""
/*
	Property: TicksPerMinute [get]
		Gets the number of ticks in 1 minute as instance of MfInt64. This field is constant.
	Value:
		Instance of MfInt64
	Gets:
		Gets the number of ticks in 1 minute as a read-only instance of MfInt64.
	Remarks:
		Static read-only Field.
		The value of this constant is 600 million; that is, 600,000,000.
		TicksPerMinute is a  read-only instance of MfInt64 with ReturnAsObject set to true.
*/
	TicksPerMinute[]
	{
		get {
			if (MfTimeSpan.m_TicksPerMinute = "")
			{
				MfTimeSpan.m_TicksPerMinute := new MfInt64(600000000, true, true) ; readonly
			}
			return MfTimeSpan.m_TicksPerMinute
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:TicksPerMinute ;}
;{ 	TicksPerSecond			- public	- const
	static m_TicksPerSecond	:= ""
/*
	Property: TicksPerSecond [get]
		Gets the number of ticks in 1 second as instance of MfInt64. This field is constant.
	Value:
		Instance of MfInt64
	Gets:
		Gets the number of ticks in 1 second as a read-only instance of MfInt64.
	Remarks:
		Static read-only Field.
		The value of this constant is 10 million; that is, 10,000,000.
		TicksPerSecond is a  read-only instance of MfInt64 with ReturnAsObject set to true.
*/
	TicksPerSecond[]
	{
		get {
			if (MfTimeSpan.m_TicksPerSecond = "")
			{
				MfTimeSpan.m_TicksPerSecond := new MfInt64(10000000, true, true) ; readonly
			}
			return MfTimeSpan.m_TicksPerSecond
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:TicksPerSecond ;}
;{ 	TotalDays				- public	- property
	m_TotalDays := Null
/*
	Property: TotalDays [get]
		Gets the value of the current MfTimeSpan object expressed in whole and fractional days as MfFloat object.
	Value:
		Instance of MfFloat
	Gets:
		The total number of days represented by this MfTimeSpan instance as a read-only instance of MfFloat.
	Remarks:
		TotalDays converts the value of this instance from ticks to days. This number might include whole and fractional days.
		TotalDays represents whole and fractional days, whereas the Days property represents whole days.
		TotalDays is a  read-only instance of MfFloat with ReturnAsObject set to true.
*/
	TotalDays[]
	{
		get {
			if (MfNull.IsNull(this.m_TotalDays))
			{
				f := new MfFloat(1.1574074074074074E-12, true, false, "0.15E")
				_Value := this.m_Ticks.Value * f.Value
				this.m_TotalDays := new MfFloat(_Value, true,  true, "0.15E") ; ReadOnly
			}
			return this.m_TotalDays
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:TotalDays ;}
;{ 	TotalHours				- public	- property
	m_TotalHours := Null
/*
	Property: TotalHours [get]
		Gets the value of the current MfTimeSpan object expressed in whole and fractional hours as MfFloat object.
	Value:
		Instance of MfFloat
	Gets:
		The total number of hours represented by this MfTimeSpan instance as a read-only instance of MfFloat.
	Remarks:
		TotalHours converts the value of this instance from ticks to hours. This number might include whole and fractional hours.
		TotalHours represents whole and fractional days, whereas the Hours property represents whole hours.
		TotalHours is a  read-only instance of MfFloat with ReturnAsObject set to true.
*/
	TotalHours[]
	{
		get {
			if (MfNull.IsNull(this.m_TotalHours))
			{
				f := new MfFloat(2.7777777777777777E-11, true, false, "0.14E")
				_Value := this.m_Ticks.Value * f.Value
				this.m_TotalHours := new MfFloat(_Value, true, true, "0.14E") ; readonly
			}
			return this.m_TotalHours
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:TotalHours ;}
;{ 	TotalMilliseconds		- public	- property
	m_TotalMilliseconds := Null
/*
	Property: TotalMilliseconds [get]
		Gets the value of the current MfTimeSpan object expressed in whole and fractional milliseconds as MfFloat object.
	Value:
		Instance of MfFloat
	Gets:
		The total number of milliseconds represented by this MfTimeSpan instance as a read-only instance of MfFloat.
	Remarks:
		TotalMilliseconds converts the value of this instance from ticks to milliseconds. This number might include whole and fractional milliseconds.
		TotalMilliseconds represents whole and fractional milliseconds, whereas the Hours property represents whole milliseconds.
		TotalMilliseconds is a  read-only instance of MfFloat with ReturnAsObject set to true.
*/
	TotalMilliseconds[]
	{
		get {
			if (MfNull.IsNull(this.m_TotalMilliseconds))
			{
				fm := new MfFloat(0.0001)
				val := new MfFloat()
				val.ReturnAsObject := true
				val.Value := this.m_Ticks.Value * fm.Value
				fCompare := new MfFloat(922337203685477.0, true)
				if (val.GreaterThen(fCompare)) {
					this.m_TotalMilliseconds := new MfFloat(fCompare.Value, true, true) ; readonly
				}
				MfNull.IsNull(this.m_TotalMilliseconds)
				{
					fCompare.Value := -922337203685477.0
					if (val.LessThen(fCompare)) {
						this.m_TotalMilliseconds := new MfFloat(fCompare.Value, true, true) ; ReadOnly
					}
				}
				MfNull.IsNull(this.m_TotalMilliseconds)
				{
					this.m_TotalMilliseconds := new MfFloat(val.Value, true, true) ; readonly
				}
			}
			return this.m_TotalMilliseconds
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:TotalMilliseconds ;}
;{ 	TotalHours				- public	- property
	m_TotalMinutes := Null
/*
	Property: TotalMinutes [get]
		Gets the value of the current MfTimeSpan object expressed in whole and fractional minutes as MfFloat object.
	Value:
		Instance of MfFloat
	Gets:
		The total number of minutesrepresented by this MfTimeSpan instance as a read-only instance of MfFloat.
	Remarks:
		TotalMinutes converts the value of this instance from ticks to minutes. This number might include whole and fractional minutes.
		TotalMinutes represents whole and fractional minutes, whereas the Minutes property represents whole minutes.
		TotalMinutes is a  read-only instance of MfFloat with ReturnAsObject set to true.
*/
	TotalMinutes[]
	{
		get {
			if (MfNull.IsNull(this.m_TotalMinutes))
			{
				f := new MfFloat(1.6666666666666667E-09, true, , "0.11E")
				_Value := this.m_Ticks.Value * f.Value
				this.m_TotalMinutes := new MfFloat(_Value, true, true, "0.11E") ; readonly
			}
			return this.m_TotalMinutes
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:TotalMinutes ;}
;{ 	TotalSeconds			- public	- property
	m_TotalSeconds := Null
/*
	Property: TotalSeconds [get]
		Gets the value of the current MfTimeSpan object expressed in whole and fractional seconds as MfFloat object.
	Value:
		Instance of MfFloat
	Gets:
		The total number of seconds represented by this instance.
	Remarks:
		TotalSeconds converts the value of this instance from ticks to seconds. This number might include whole and fractional seconds.
		TotalSeconds represents whole and fractional seconds, whereas the Seconds property represents whole seconds.
		TotalSeconds is a  read-only instance of MfFloat with ReturnAsObject set to true.
*/
	TotalSeconds[]
	{
		get {
			if (MfNull.IsNull(this.m_TotalSeconds))
			{
				;f := new MfFloat(1E-07, true, "0.9E")
				;_Value := this.m_Ticks.Value * f.Value
				_value := this.m_Ticks.Value / MfTimeSpan.TicksPerSecond.Value
				this.m_TotalSeconds := new MfFloat(_Value, true, true, "0.3") ; ReadOnly
			}
			return this.m_TotalSeconds
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:TotalSeconds ;}
;{	Value					- public	- property
/*
	Property: Value [get]
		Gets or sets the value associated with the this instance of MfTimeSpan.
	Value:
		var as integer
	Gets:
		Value is a var containing integer representing MfInt64.
	Remarks:
		Read-only Property.
		Value gets the value part of Ticks
*/
	Value[]
	{
		get {
			return this.m_Ticks.Value
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:Value ;}
;{ 	Zero					- public	- property
	static m_Zero := ""
/*
	Property: Zero [get]
		Gets the zero MfTimeSpan value as instance of MfTimeSpan. This field is constant
	Value:
		Instance of MfTimeSpan
	Gets:
		Gets the zero MfTimeSpan value as instance of MfTimeSpan
	Remarks:
		Static read-only Field.
		Because the value of the Zero field is a MfTimeSpan object that represents a zero time value, you can compare it
		with other MfTimeSpan objects to determine whether the latter represent positive, non-zero, or negative time intervals.
		You can also use this field to initialize a MfTimeSpan object to a zero time value.
*/
	Zero[]
	{
		get {
			if (MfTimeSpan.m_Zero = "")
			{
				MfTimeSpan.m_Zero := new MfTimeSpan(new MfInt64(0, true))
			}
			return MfTimeSpan.m_Zero
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Zero ;}
; End:Properties ;}	
}
/*!
	End of class
*/
; End:Class MfTimeSpan ;}