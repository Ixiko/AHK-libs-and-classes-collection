;* 11/11/2020:
	;* Initial commit.

;=====           Function           =========================;

__Validate(vN, ByRef vNumber1 := "", ByRef vNumber2 := "", ByRef vNumber3 := "", ByRef vNumber4 := "") {
	Loop, % vN {
		If (!Math.IsNumeric(vNumber%A_Index%)) {
			vNumber%A_Index% := Round(vNumber%A_Index%)
		}
	}
}

;=====             Class            =========================;

Class Point2 {

	;-----          Constructor         -------------------------;

	;* new Point2(x, y)
	__New(vX, vY) {
		Return, ({"x": vX
			, "y": vY

			, "Base": this.__Point2})
	}

	;-----            Method            -------------------------;
	;-------------------------            General           -----;

	;* Point2.Angle(PointObject, PointObject)
	;* Description:
		;* Calculate the angle from `oPoint21` to `oPoint22`.
	Angle(oPoint21, oPoint22) {
		Return, (Math.ToDegrees(((x := -Math.ATan2({"x": oPoint22.x - oPoint21.x, "y": oPoint22.y - oPoint21.y})) < 0) ? (-x) : (Math.Tau - x)))
	}

	;* Point2.Distance(PointObject, PointObject)
	Distance(oPoint21, oPoint22) {
		Return, (Sqrt((oPoint22.x - oPoint21.x)**2 + (oPoint22.y - oPoint21.y)**2))
	}

	;* Point2.Equals(PointObject, PointObject)
	Equals(oPoint21, oPoint22) {
		Return, (oPoint21.x == oPoint22.x && oPoint21.y == oPoint22.y)
	}

	;* Point2.Slope(PointObject, PointObject)
	;* Note:
		;* Two lines are parallel if their slopes are the same.
		;* Two lines are perpendicular if their slopes are negative reciprocals of each other.
	Slope(oPoint21, oPoint22) {
		Return, ((oPoint22.y - oPoint21.y)/(oPoint22.x - oPoint21.x))
	}

	;* Point2.MidPoint(PointObject, PointObject)
	MidPoint(oPoint21, oPoint22) {
		Return, (new Point2((oPoint21.x + oPoint22.x)/2, (oPoint21.y + oPoint22.y)/2))
	}

	;* Point2.Rotate(PointObject, PointObject, Degrees)
	;* Description:
		;* Calculate the coordinates of `oPoint21` rotated around `oPoint22`.
	Rotate(oPoint21, oPoint22, vTheta) {
		a := -Math.ToRadians((vTheta >= 0) ? (Mod(vTheta, 360)) : (360 - Mod(-vTheta, -360)))
			, c := Math.Cos(a), s := Math.Sin(a)

		x := oPoint21.x - oPoint22.x, y := oPoint21.y - oPoint22.y

		Return, (new Point2(x*c - y*s + oPoint22.x, x*s + y*c + oPoint22.y))
	}

	;-------------------------           Triangle           -----;

	;* Point2.Circumcenter(PointObject, PointObject, PointObject)
	Circumcenter(oPoint21, oPoint22, oPoint23) {
		m := [this.MidPoint(oPoint21, oPoint22), this.MidPoint(oPoint22, oPoint23)]
			, s := [(oPoint22.x - oPoint21.x)/(oPoint21.y - oPoint22.y), (oPoint23.x - oPoint22.x)/(oPoint22.y - oPoint23.y)]
			, p := [m[0].y - s[0]*m[0].x, m[1].y - s[1]*m[1].x]

		Return, (s[0] == s[1] ? 0 : oPoint21.y == oPoint22.y ? new Point2(m[0].x, s[1]*m[0].x + p[1]) : oPoint22.y == oPoint23.y ? new Point2(m[1].x, s[0]*m[1].x + p[0]) : new Point2((p[1] - p[0])/(s[0] - s[1]), s[0]*(p[1] - p[0])/(s[0] - s[1]) + p[0]))
	}

	;-------------------------            Ellipse           -----;

	;* Point2.Foci(EllipseObject)
	Foci(oEllipse) {
		o := [(oEllipse.Radius.a > oEllipse.Radius.b)*(o := oEllipse.FocalLength), (oEllipse.Radius.a < oEllipse.Radius.b)*o]

		Return, ([new Point2(oEllipse.h - o[0], oEllipse.k - o[1]), new Point2(oEllipse.h + o[0], oEllipse.k + o[1])])
	}

	;* Point2.Epicycloid(EllipseObject1, EllipseObject2, Degrees)
	Epicycloid(oEllipse1, oEllipse2, vTheta := 0) {
		a := Math.ToRadians((vTheta >= 0) ? (Mod(vTheta, 360)) : (360 - Mod(-vTheta, -360)))

		Return, (new Point2(oEllipse1.h + (oEllipse1.Radius + oEllipse2.Radius)*Math.Cos(a) - oEllipse2.Radius*Math.Cos((oEllipse1.Radius/oEllipse2.Radius + 1)*a), oEllipse.k - o[2], oEllipse1.k + (oEllipse1.Radius + oEllipse2.Radius)*Math.Sin(a) - oEllipse2.Radius*Math.Sin((oEllipse1.Radius/oEllipse2.Radius + 1)*a)))
	}

	;* Point2.Hypocycloid([EllipseObject1, EllipseObject2], Degrees)
	Hypocycloid(oEllipses, vTheta := 0) {
		a := Math.ToRadians((vTheta >= 0) ? (Mod(vTheta, 360)) : (360 - Mod(-vTheta, -360)))

		Return, (new Point2(oEllipse1.h + (oEllipse1.Radius - oEllipse2.Radius)*Math.Cos(a) + oEllipse2.Radius*Math.Cos((oEllipse1.Radius/oEllipse2.Radius - 1)*a), oEllipse1.k + (oEllipse1.Radius - oEllipse2.Radius)*Math.Sin(a) - oEllipse2.Radius*Math.Sin((oEllipse1.Radius/oEllipse2.Radius - 1)*a)))
	}

	;* Point2.OnEllipse(EllipseObject, Degrees)
	;* Description:
		;* Calculate the coordinates of a point on the circumference of an ellipse.
	OnEllipse(oEllipse, vTheta := 0) {
		a := -(Math.ToRadians((vTheta >= 0) ? (Mod(vTheta, 360)) : (360 - Mod(-vTheta, -360))))

		If (IsObject(oEllipse.Radius)) {
			t := Math.Tan(a), o := [oEllipse.Radius.a*oEllipse.Radius.b, Sqrt(oEllipse.Radius.b**2 + oEllipse.Radius.a**2*t**2)], s := (90 < vTheta && vTheta <= 270) ? (-1) : (1)

			Return, (new Point2(oEllipse.h + (o[0]/o[1])*s, oEllipse.k + ((o[0]*t)/o[1])*s))
		}
		Return, (new Point2(oEllipse.h + oEllipse.Radius*Math.Cos(a), oEllipse.k + oEllipse.Radius*Math.Sin(a)))
	}

	;-----         Nested Class         -------------------------;

	Class __Point2 extends __Object {

		Clone() {
			Return, (new Point2(this.x, this.y))
		}
	}
}

Class Point3 {

	;* new Point3([x, y, z])
	__New(oData := "") {
		Return, ({"x": oData[0]
			, "y": oData[1]
			, "z": oData[2]

			, "Base": this.__Point3})
	}

	Rotate(vDegrees, vMode) {
		;* Here we use Euler's matrix formula for rotating a 3D point x degrees around the x-axis:

		;? [ a  b  c ] [ x ]   [ x*a + y*b + z*c ]
		;? [ d  e  f ] [ y ] = [ x*d + y*e + z*f ]
		;? [ g  h  i ] [ z ]   [ x*g + y*h + z*i ]

		Switch (vMode) {
			Case "x":
				;? [1      0         0  ]
				;? [0    cos(a)   sin(a)]
				;? [0   -sin(a)   cos(a)]

				a := Math.ToRadians((vDegrees >= 0) ? (Mod(vDegrees, 360)) : (360 - Mod(-vDegrees, -360)))
					, c := Math.Cos(a), s := Math.Sin(a)

				Return, (new Point3([this.x, this.y*c + this.z*s, this.y*-s + this.z*c]))
			Case "y":
				;? [ cos(a)   0    sin(a)]
				;? [   0      1      0   ]
				;? [-sin(a)   0    cos(a)]

				a := Math.ToRadians((vDegrees >= 0) ? (Mod(vDegrees, 360)) : (360 - Mod(-vDegrees, -360)))
					, c := Math.Cos(a), s := Math.Sin(a)

				Return, (new Point3([this.x*c + this.z*s, this.y, this.x*-s + this.z*c]))
			Case "z":
				;? [ cos(a)   sin(a)   0]
				;? [-sin(a)   cos(a)   0]
				;? [    0       0      1]

				a := Math.ToRadians((vDegrees >= 0) ? (Mod(vDegrees, 360)) : (360 - Mod(-vDegrees, -360)))
					, c := Math.Cos(a), s := Math.Sin(a)

				Return, (new Point3([this.x*c + this.y*s, this.x*-s + this.y*c, this.z]))
		}
	}

	Class __Point3 extends __Object {

		Clone() {
			Return, (new Point3([this.x, this.y, this.z]))
		}
	}
}

Class Ellipse {

	;* new Ellipse(vX, vY, Width, Height, Eccentricity)
	;* Note:
		;* Eccentricity can compensate for `Width` or `Height` but 2 of the 3 values must be provided to calculate a valid radius.
	__New(vX := "", vY := "", vWidth := "", vHeight := "", vEccentricity := 0) {
		e := Sqrt(1 - vEccentricity**2), r := [(vWidth != "") ? (vWidth/2) : ((vHeight != "") ? ((vHeight/2)*e) : (0)), (vHeight != "") ? (vHeight/2) : ((vWidth != "") ? ((vWidth/2)*e) : (0))]

		If (r[0] == r[1]) {
			Return, ({"x": vX
				, "y": vY
				, "__Radius": r[0]

				, "Base": this.__Circle})
		}

		Return, ({"x": vX
			, "y": vY
			, "__Radius": r

			, "Base": this.__Ellipse})
	}

	;*Note:
		;* To determine radius given N: vRadius := (oEllipse.Radius/(Math.Sin(Math.Pi/N) + 1))*Math.Sin(Math.Pi/N).
	InscribeEllipse(oEllipse, vRadius, vDegrees := 0, vOffset := 0) {
		a := Math.ToRadians((vDegrees >= 0) ? (Mod(vDegrees, 360)) : (360 - Mod(-vDegrees, -360)))
			, c := oEllipse.h + (oEllipse.Radius - vRadius - vOffset)*Math.Cos(a), s := oEllipse.k + (oEllipse.Radius - vRadius - vOffset)*Math.Sin(a)

		Return, (new Ellipse(c - vRadius, s - vRadius, vRadius*2, vRadius*2))
	}

	Class __Circle extends __Object {

		__Get(vKey) {
			Switch (vKey) {
				Case "h":
					Return, (this.X + this.__Radius)
				Case "k":
					Return, (this.Y + this.__Radius)
				Case "Radius":
					Return, (this.__Radius)
				Case "Diameter":
					Return, (this.__Radius*2)

				Case "SemiMajor_Axis":
					Return, (this.__Radius)
				Case "SemiMinor_Axis":
					Return, (this.__Radius)
				Case "Area":
					Return, (this.__Radius**2*Math.Pi)
				Case "Circumference":
					Return, (this.__Radius*Math.Tau)
				Case "Eccentricity":
					Return, (0)
				Case "FocalLength":
					Return, (0)
				Case "Apoapsis":
					Return, (this.__Radius)
				Case "Periapsis":
					Return, (this.__Radius)
				Case "SemiLatus_Rectum":
					Return, (0)

				Case "Width":
					Return, (this.__Radius*2)  ;* Make an EllipseObject compatible with a RectangleObject variant for GDIp methods.
				Case "Height":
					Return, (this.__Radius*2)
			}
		}

		__Set(vKey, vValue) {
			Switch (vKey) {
				Case "h":
					ObjRawSet(this, "x", vValue - this.__Radius)
				Case "k":
					ObjRawSet(this, "y", vValue - this.__Radius)
				Case "Radius":
					If (IsObject(vValue)) {
						ObjRawSet(this, "__Radius", [vValue.a, vValue.b]), ObjSetBase(this, Ellipse.__Ellipse)
					}
					Else {
						ObjRawSet(this, "__Radius", vValue)
					}
				Case "Diameter":
					If (IsObject(vValue)) {
						ObjRawSet(this, "__Radius", [vValue.a/2, vValue.b/2]), ObjSetBase(this, Ellipse.__Ellipse)
					}
					Else {
						ObjRawSet(this, "__Radius", vValue/2)
					}
			}
		}
	}

	Class __Ellipse extends __Object {

		__Get(vKey) {
			Switch (vKey) {
				Case "h":
					Return, (this.X + this.__Radius[0])
				Case "k":
					Return, (this.Y + this.__Radius[1])
				Case "Radius":
					Return, ({"a": this.__Radius[0]
						, "b": this.__Radius[1]})
				Case "Diameter":
					Return, ({"a": this.__Radius[0]*2
						, "b": this.__Radius[1]*2})

				Case "SemiMajor_Axis":
					Return, (Max(this.__Radius[0], this.__Radius[1]))
				Case "SemiMinor_Axis":
					Return, (Min(this.__Radius[0], this.__Radius[1]))
				Case "Area":
					Return, (this.__Radius[0]*this.__Radius[1]*Math.PI)
				Case "Circumference":  ;* Approximation by Srinivasa Ramanujan.
					Return, ((3*(this.__Radius[0] + this.__Radius[1]) - Sqrt((3*this.__Radius[0] + this.__Radius[1])*(this.__Radius[0] + 3*this.__Radius[1])))*Math.Pi)
				Case "Eccentricity":
					Return, (this.FocalLength/this.SemiMajor_Axis)
				Case "FocalLength":
					Return, (Sqrt(this.SemiMajor_Axis**2 - this.SemiMinor_Axis**2))
				Case "Apoapsis":
					Return, (this.SemiMajor_Axis*(1 + this.Eccentricity))
				Case "Periapsis":
					Return, (this.SemiMajor_Axis*(1 - this.Eccentricity))
				Case "SemiLatus_Rectum":
					Return, (this.SemiMajor_Axis*(1 - this.Eccentricity**2))

				Case "Width":
					Return, (this.__Radius[0]*2)
				Case "Height":
					Return, (this.__Radius[1]*2)
			}
		}

		__Set(vKey, vValue) {
			switch (vKey) {
				Case "h":
					ObjRawSet(this, "x", vValue - this.__Radius[0])
				Case "k":
					ObjRawSet(this, "y", vValue - this.__Radius[1])
				Case "Radius":
					If (IsObject(vValue)) {
						ObjRawSet(this, "__Radius", [vValue.a, vValue.b])
					}
					Else {
						ObjRawSet(this, "__Radius", vValue), ObjSetBase(this, Ellipse.__Circle)
					}
				Case "Diameter":
					If (IsObject(vValue)) {
						ObjRawSet(this, "__Radius", [vValue.a/2, vValue.b/2])
					}
					Else {
						ObjRawSet(this, "__Radius", vValue/2), ObjSetBase(this, Ellipse.__Circle)
					}
			}
		}
	}
}

Class Rectangle {

	;* new Rectangle(x, y, Width, Height)
	__New(vX, vY, vWidth, vHeight) {
		Return, {"x": vX
			, "y": vY
			, "Width": vWidth
			, "Height": vHeight

			, "Base": this.__Rectangle}
	}

	Scale(oRectangle1, oRectangle2) {
		r1 := oRectangle2.Width/oRectangle1.Width, r2 := oRectangle2.Height/oRectangle1.Height

		If (r1 > r2) {
			h := oRectangle2.Height//r1

			Return, (new Rectangle(0, (oRectangle1.Height - h)//2, oRectangle1.Width, h))
		}
		Else {
			w := oRectangle2.Width//r2

			Return, (new Rectangle((oRectangle1.Width - w)//2, 0, 2, oRectangle1.Height))
		}
	}

	Class __Rectangle extends __Object {

		Clone() {
			Return, (new Rectangle(this.x, this.y, this.Width, this.Height))
		}
	}
}

Class Vector2 {

	;* new Vector2(x [Number || Vector2], (y [Number]))
	__New(x := 0, y := "") {
		Local
		Global Math

		If (Math.IsNumeric(x)) {
			If (Math.IsNumeric(y)) {
				Return, ({"x": x
					, "y": y

					, "Base": this.__Vector2})
			}

			Return, ({"x": x
				, "y": x

				, "Base": this.__Vector2})
		}

		Return, ({"x": x.x
			, "y": x.y

			, "Base": this.__Vector2})
	}

	;* Vector2.Multiply(vector1 [Vector2], vector2 [Vector2 || Number])
	;* Description:
		;* Multiply a vector by another vector or a scalar.
	Multiply(vector1, vector2) {
		Local

		If (IsObject(vector2)) {
			Return, (new this(vector1.x*vector2.x, vector1.y*vector2.y))
		}

		Return, (new this(vector1.x*vector2, vector1.y*vector2))
	}

	;* Vector2.Divide(vector1 [Vector2], vector2 [Vector2 || Number])
	;* Description:
		;* Divide a vector by another vector or a scalar.
	Divide(vector1, vector2) {
		Local

		If (IsObject(vector2)) {
			Return, (new this(vector1.x/vector2.x, vector1.y/vector2.y))
		}

		Return, (new this(vector1.x/vector2, vector1.y/vector2))
	}

	;* Vector2.Add(vector1 [Vector2], vector2 [Vector2 || Number])
	;* Description:
		;* Add to a vector another vector or a scalar.
	Add(vector1, vector2) {
		Local

		If (IsObject(vector2)) {
			Return, (new this(vector1.x + vector2.x, vector1.y + vector2.y))
		}

		Return, (new this(vector1.x + vector2, vector1.y + vector2))
	}

	;* Vector2.Subtract(vector1 [Vector2], vector2 [Vector2 || Number])
	;* Description:
		;* Subtract from a vector another vector or scalar.
	Subtract(vector1, vector2) {
		Local

		If (IsObject(vector2)) {
			Return, (new this(vector1.x - vector2.x, vector1.y - vector2.y))
		}

		Return, (new this(vector1.x - vector2, vector1.y - vector2))
	}

	;* Vector2.Clamp(vector1 [Vector2], vector2 [Vector2 || Number], vector3 [Vector2 || Number])
	;* Description:
		;* Clamp a vector to the given minimum and maximum vectors or values.
	;* Note:
		;* Assumes `vector2 < vector3`.
	;* Parameters:
		;* vector1:
			;* Input vector.
		;* vector2:
			;* Minimum vector or number.
		;* vector3:
			;* Maximum vector or number.
	Clamp(vector1, vector2, vector3) {
		Local

		If (IsObject(vector2) && IsObject(vector3)) {
			Return, (new this(Max(vector2.x, Min(vector3.x, vector1.x)), Max(vector2.y, Min(vector3.y, vector1.y))))
		}

		Return, (new this(Max(vector2, Min(vector3, vector1.x)), Max(vector2, Min(vector3, vector1.y))))
	}

	;* Vector2.Cross(vector1 [Vector2], vector2 [Vector2])
	;* Description:
		;* Calculate the cross product (vector) of two vectors (greatest yield for perpendicular vectors).
	Cross(vector1, vector2) {
		Local

		Return, (vector1.x*vector2.y - vector1.y*vector2.x)
	}

	;* Vector2.Distance(vector1 [Vector2], vector2 [Vector2])
	;* Description:
		;* Calculate the distance between two vectors.
	Distance(vector1, vector2) {
		Local

		Return, (Sqrt((vector1.x - vector2.x)**2 + (vector1.y - vector2.y)**2))
	}

	;* Vector2.DistanceSquared(vector1 [Vector2], vector2 [Vector2])
	DistanceSquared(vector1, vector2) {
		Local

		Return, ((vector1.x - vector2.x)**2 + (vector1.y - vector2.y)**2)
	}

	;* Vector2.Dot(vector1 [Vector2], vector2 [Vector2])
	;* Description:
		;* Calculate the dot product (scalar) of two vectors (greatest yield for parallel vectors).
	Dot(vector1, vector2) {
		Local

		Return, (vector1.x*vector2.x + vector1.y*vector2.y)
	}

	;* Vector2.Equals(vector1 [Vector2], vector2 [Vector2])
	;* Description:
		;* Indicates whether two vectors are equal.
	Equals(vector1, vector2) {
		Local

		Return, (vector1.x == vector2.x && vector1.y == vector2.y)
	}

	;* Vector2.Lerp(vector1 [Vector2], vector2 [Vector2], a [Number])
	;* Description:
		;* Returns a new vector that is the linear blend of the two given vectors.
	;* Parameters:
		;* vector1:
			;* The starting vector.
		;* vector2:
			;* The vector to interpolate towards.
		;* a:
			;* Interpolation factor, typically in the closed interval [0, 1].
	Lerp(vector1, vector2, alpha) {
		Local

		Return, (new this(vector1.x + (vector2.x - vector1.x)*alpha, vector1.y + (vector2.y - vector1.y)*alpha))
	}

	;* Vector2.Min(vector1 [Vector2], vector2 [Vector2])
	Min(vector1, vector2) {
		Local

		Return, (new this(Min(vector1.x, vector2.x), Min(vector1.y, vector2.y)))
	}

	;* Vector2.Max(vector1 [Vector2], vector2 [Vector2])
	Max(vector1, vector2) {
		Local

		Return, (new this(Max(vector1.x, vector2.x), Max(vector1.y, vector2.y)))
	}

	;* Vector2.Transform(vector [Vector2], matrix [Matrix3])
	Transform(vector, matrix) {
		Local

		x := vector.x, y := vector.y
			, m := matrix.Elements

		Return, (new this(m[0]*x + m[3]*y + m[6], m[1]*x + m[4]*y + m[7]))
	}

	Class __Vector2 extends __Object {

		__Get(key) {
			Local
			Global Math

			Switch (key) {

				;* Vector2.Length
				;* Description:
					;* Calculates the length (magnitude) of the vector.
				Case "Length":
					Return, (Sqrt(this.x**2 + this.y**2))

				;* Vector2.LengthSquared
				Case "LengthSquared":
					Return, (this.x**2 + this.y**2)

				;* Vector2[n]
				Default:
					If (Math.IsInteger(key)) {
						Return, ([this.x, this.y][key])
					}
			}
		}

		__Set(key, value) {
			Local

			Switch (key) {

				;* Vector2.Length := n
				Case "Length":
					Return, (this.Normalize().Multiply(value))

				;* Vector2[n] := n
				Default:
					switch (key) {
						Case 0:
							this.x := value
						Case 1:
							this.y := value
					}
					Return
			}
		}

        Multiply(vector) {
			Local

			If (IsObject(vector)) {
				this.x *= vector.x, this.y *= vector.y
			}
			Else {
				this.x *= vector, this.y *= vector
			}

			Return, (this)
        }

        Divide(vector) {
			Local

			If (IsObject(vector)) {
				this.x /= vector.x, this.y /= vector.y
			}
			Else {
				this.x /= vector, this.y /= vector
			}

			Return, (this)
        }

		Add(vector) {
			Local

			If (IsObject(vector)) {
				this.x += vector.x, this.y += vector.y
			}
			Else {
				this.x += vector, this.y += vector
			}

			Return, (this)
		}

		Subtract(vector) {
			Local

			If (IsObject(vector)) {
				this.x -= vector.x, this.y -= vector.y
			}
			Else {
				this.x -= vector, this.y -= vector
			}

			Return, (this)
		}

		Clamp(vector1, vector2) {
			Local

			If (IsObject(vector1) && IsObject(vector2)) {
				this.x := Max(vector1.x, Min(vector2.x, this.x)), this.y := Max(vector1.y, Min(vector2.y, this.y))
			}
			Else {
				this.x := Max(vector1, Min(vector2, this.x)), this.y := Max(vector1, Min(vector2, this.y))
			}

			Return, (this)
		}

		;* Vector2.Negate()
		;* Description:
			;* Inverts this vector.
		Negate() {
			Local

			this.x *= -1, this.y *= -1

			Return, (this)
		}

		;* Vector2.Normalize()
		;* Description:
			;* This method normalises the vector such that it's length/magnitude is 1. The result is called a unit vector.
        Normalize() {
			Local

			m := this.Length

			If (m) {
				this.x /= m, this.y /= m
			}

			Return, (this)
        }

		Transform(matrix) {
			Local

			x := this.x, y := this.y
				, m := matrix.Elements

			this.x := m[0]*x + m[3]*y + m[6], this.y := m[1]*x + m[4]*y + m[7]

			Return, (this)
		}

		Copy(vector) {
			Local

			this.x := vector.x, this.y := vector.y

			Return, (this)
		}

		Clone() {
			Local
			Global Vector2

			Return, (new Vector2(this))
		}
	}
}

Class Vector3 {

	;* new Vector3(x [Number || Vector3], (y [Number]), (z [Number]))
	__New(x := 0, y := "", z := "") {
		Local
		Global Math

		If (Math.IsNumeric(x)) {
			If (Math.IsNumeric(y)) {
				Return, ({"x": x
					, "y": y
					, "z": z

					, "Base": this.__Vector3})
			}

			Return, ({"x": x
				, "y": x
				, "z": x

				, "Base": this.__Vector3})
		}

		Return, ({"x": x.x
			, "y": x.y
			, "z": x.z

			, "Base": this.__Vector3})
	}

	;* Vector3.Multiply(vector1 [Vector3], vector2 [Vector3 || Number])
	;* Description:
		;* Multiply a vector by another vector or a scalar.
	Multiply(vector1, vector2) {
		Local

		If (IsObject(vector2)) {
			Return, (new this(vector1.x*vector2.x, vector1.y*vector2.y, vector1.z*vector2.z))
		}

		Return, (new this(vector1.x*vector2, vector1.y*vector2, vector1.z*vector2))
	}

	;* Vector3.Divide(vector1 [Vector3], vector2 [Vector3 || Number])
	;* Description:
		;* Divide a vector by another vector or a scalar.
	Divide(vector1, vector2) {
		Local

		If (IsObject(vector2)) {
			Return, (new this(vector1.x/vector2.x, vector1.y/vector2.y, vector1.z/vector2.z))
		}

		Return, (new this(vector1.x/vector2, vector1.y/vector2, vector1.z/vector2))
	}

	;* Vector3.Add(vector1 [Vector3], vector2 [Vector3 || Number])
	;* Description:
		;* Add to a vector another vector or a scalar.
	Add(vector1, vector2) {
		Local

		If (IsObject(vector2)) {
			Return, (new this(vector1.x + vector2.x, vector1.y + vector2.y, vector1.z + vector2.z))
		}

		Return, (new this(vector1.x + vector2, vector1.y + vector2, vector1.z + vector2))
	}

	;* Vector3.Subtract(vector1 [Vector3], vector2 [Vector3 || Number])
	;* Description:
		;* Subtract from a vector another vector or scalar.
	Subtract(vector1, vector2) {
		Local

		If (IsObject(vector2)) {
			Return, (new this(vector1.x - vector2.x, vector1.y - vector2.y, vector1.z - vector2.z))
		}

		Return, (new this(vector1.x - vector2, vector1.y - vector2, vector1.z - vector2))
	}

	;* Vector3.Clamp(vector1 [Vector3], vector2 [Vector3 || Number], vector3 [Vector3 || Number])
	;* Description:
		;* Clamp a vector to the given minimum and maximum vectors or values.
	;* Note:
		;* Assumes `vector2 < vector3`.
	;* Parameters:
		;* vector1:
			;* Input vector.
		;* vector2:
			;* Minimum vector or number.
		;* vector3:
			;* Maximum vector or number.
	Clamp(vector1, vector2, vector3) {
		Local

		If (IsObject(vector2) && IsObject(vector3)) {
			Return, (new this(Max(vector2.x, Min(vector3.x, vector1.x)), Max(vector2.y, Min(vector3.y, vector1.y)), Max(vector2.z, Min(vector3.z, vector1.z))))
		}

		Return, (new this(Max(vector2, Min(vector3, vector1.x)), Max(vector2, Min(vector3, vector1.y)), Max(vector2, Min(vector3, vector1.z))))
	}

	;* Vector3.Cross(vector1 [Vector3], vector2 [Vector3])
	;* Description:
		;* Calculate the cross product (vector) of two vectors (greatest yield for perpendicular vectors).
	Cross(vector1, vector2) {
		Local

		a1 := vector1.x, a2 := vector1.y, a3 := vector1.z
			, b1 := vector2.x, b2 := vector2.y, b3 := vector2.z

		;[a2*b3 - a3*b2]
		;[a3*b1 - a1*b3]
		;[a1*b2 - a2*b1]

		Return, (new this(a2*b3 - a3*b2, a3*b1 - a1*b3, a1*b2 - a2*b1))
	}

	;* Vector3.Distance(vector1 [Vector3], vector2 [Vector3])
	;* Description:
		;* Calculate the distance between two vectors.
	Distance(vector1, vector2) {
		Local

		Return, (Sqrt((vector1.x - vector2.x)**2 + (vector1.y - vector2.y)**2 + (vector1.z - vector2.z)**2))
	}

	;* Vector3.DistanceSquared(vector1 [Vector3], vector2 [Vector3])
	DistanceSquared(vector1, vector2) {
		Local

		Return, ((vector1.x - vector2.x)**2 + (vector1.y - vector2.y)**2 + (vector1.z - vector2.z)**2)
	}

	;* Vector3.Dot(vector1 [Vector3], vector2 [Vector3])
	;* Description:
		;* Calculate the dot product (scalar) of two vectors (greatest yield for parallel vectors).
	Dot(vector1, vector2) {
		Local

		Return, (vector1.x*vector2.x + vector1.y*vector2.y + vector1.z*vector2.z)  ;? Math.Abs(a.Length)*Math.Abs(b.Length)*Math.Cos(AOB)
	}

	;* Vector3.Equals(vector1 [Vector3], vector2 [Vector3])
	;* Description:
		;* Indicates whether two vectors are equal.
	Equals(vector1, vector2) {
		Local

		Return, (vector1.x == vector2.x && vector1.y == vector2.y && vector1.z == vector2.z)
	}

	;* Vector3.Lerp(vector1 [Vector3], vector2 [Vector3], a [Number])
	;* Description:
		;* Returns a new vector that is the linear blend of the two given vectors.
	;* Parameters:
		;* vector1:
			;* The starting vector.
		;* vector2:
			;* The vector to interpolate towards.
		;* a:
			;* Interpolation factor, typically in the closed interval [0, 1].
	Lerp(vector1, vector2, alpha) {
		Local

		Return, (new this(vector1.x + (vector2.x - vector1.x)*alpha, vector1.y + (vector2.y - vector1.y)*alpha, vector1.z + (vector2.z - vector1.z)*alpha))
	}

	;* Vector3.Min(vector1 [Vector3], vector2 [Vector3])
	Min(vector1, vector2) {
		Local

		Return, (new this(Min(vector1.x, vector2.x), Min(vector1.y, vector2.y), Min(vector1.z, vector2.z)))
	}

	;* Vector3.Max(vector1 [Vector3], vector2 [Vector3])
	Max(vector1, vector2) {
		Local

		Return, (new this(Max(vector1.x, vector2.x), Max(vector1.y, vector2.y), Max(vector1.z, vector2.z)))
	}

	;* Vector3.Transform(vector [Vector3], matrix [Matrix3])
	Transform(vector, matrix) {
		Local

		x := vector.x, y := vector.y, z := vector.z
			, m := matrix.Elements

		Return, (new this(m[0]*x + m[3]*y + m[6]*z, m[1]*x + m[4]*y + m[7]*z, m[2]*x + m[5]*y + m[8]*z))
	}

	Class __Vector3 extends __Object {

		__Get(key) {
			Local
			Global Math

			Switch (key) {

				;* Vector3.Length
				;* Description:
					;* Calculates the length (magnitude) of the vector.
				Case "Length":
					Return, (Sqrt(this.x**2 + this.y**2 + this.z**2))

				;* Vector3.LengthSquared
				Case "LengthSquared":
					Return, (this.x**2 + this.y**2 + this.z**2)

				;* Vector3[n]
				Default:
					If (Math.IsInteger(key)) {
						Return, ([this.x, this.y, this.z][key])
					}
			}
		}

		__Set(key, value) {
			Local

			Switch (key) {

				;* Vector3.Length := n
				Case "Length":
					Return, (this.Normalize().Multiply(value))

				;* Vector3[n] := n
				Default:
					switch (key) {
						Case 0:
							this.x := value
						Case 1:
							this.y := value
						Case 2:
							this.z := value
					}
					Return
			}
		}

        Multiply(vector) {
			Local

			If (IsObject(vector)) {
				this.x *= vector.x, this.y *= vector.y, this.z *= vector.z
			}
			Else {
				this.x *= vector, this.y *= vector, this.z *= vector
			}

			Return, (this)
        }

        Divide(vector) {
			Local

			If (IsObject(vector)) {
				this.x /= vector.x, this.y /= vector.y, this.z /= vector.z
			}
			Else {
				this.x /= vector, this.y /= vector, this.z /= vector
			}

			Return, (this)
        }

		Add(vector) {
			Local

			If (IsObject(vector)) {
				this.x += vector.x, this.y += vector.y, this.z += vector.z
			}
			Else {
				this.x += vector, this.y += vector, this.z += vector
			}

			Return, (this)
		}

		Subtract(vector) {
			Local

			If (IsObject(vector)) {
				this.x -= vector.x, this.y -= vector.y, this.z -= vector.z
			}
			Else {
				this.x -= vector, this.y -= vector, this.z -= vector
			}

			Return, (this)
		}

		Clamp(vector1, vector2) {
			Local

			If (IsObject(vector1) && IsObject(vector2)) {
				this.x := Max(vector1.x, Min(vector2.x, this.x)), this.y := Max(vector1.y, Min(vector2.y, this.y)), this.z := Max(vector1.z, Min(vector2.z, this.z))
			}
			Else {
				this.x := Max(vector1, Min(vector2, this.x)), this.y := Max(vector1, Min(vector2, this.y)), this.z := Max(vector1, Min(vector2, this.z))
			}

			Return, (this)
		}

		;* Vector3.Negate()
		;* Description:
			;* Inverts this vector.
		Negate() {
			Local

			this.x *= -1, this.y *= -1, this.z *= -1

			Return, (this)
		}

		;* Vector3.Normalize()
		;* Description:
			;* This method normalises the vector such that it's length/magnitude is 1. The result is called a unit vector.
        Normalize() {
			Local

			m := this.Length

			If (m) {
				this.x /= m, this.y /= m, this.z /= m
			}

			Return, (this)
        }

		Transform(matrix) {
			Local

			x := this.x, y := this.y, z := this.z
				, m := matrix.Elements

			this.x := m[0]*x + m[3]*y + m[6]*z, this.y := m[1]*x + m[4]*y + m[7]*z, this.z := m[2]*x + m[5]*y + m[8]*z

			Return, (this)
		}

		Copy(vector) {
			Local

			this.x := vector.x, this.y := vector.y, this.z := vector.z

			Return, (this)
		}

		Clone() {
			Local
			Global Vector3

			Return, (new Vector3(this))
		}
	}
}

Class Matrix3 {

	__New() {
		Local

		Return, ({"Elements": [1, 0, 0, 0, 1, 0, 0, 0, 1]
			, "Base": this.__Matrix3})
	}

	;* Matrix3.Equals(matrix1 [Matrix3], matrix2 [Matrix3])
	;* Description:
		;* Indicates whether two matrices are the same.
	Equals(matrix1, matrix2) {
		Local

		m1 := matrix1.Elements
			, m2 := matrix2.Elements

		While (A_Index < 9) {
			i := A_Index - 1

			If (m1[i] != m2[i]) {
				Return, (0)
			}
		}

		Return, (1)
	}

	Multiply(matrix1, matrix2) {
		Local

		m1 := matrix1.Elements, a11 := m1[0], a12 := m1[1], a13 := m1[2], a21 := m1[3], a22 := m1[4], a23 := m1[5], a31 := m1[6], a32 := m1[7], a33 := m1[8]
			, m2 := matrix2.Elements, b11 := m2[0], b12 := m2[1], b13 := m2[2], b21 := m2[3], b22 := m2[4], b23 := m2[5], b31 := m2[6], b32 := m2[7], b33 := m2[8]

		;[a11*b11 + a12*b21 + a13*b31   a11*b12 + a12*b22 + a13*b32   a11*b13 + a12*b23 + a13*b33]
		;[a21*b11 + a22*b21 + a23*b31   a21*b12 + a22*b22 + a23*b32   a21*b13 + a22*b23 + a23*b33]
		;[a31*b11 + a32*b21 + a33*b31   a31*b12 + a32*b22 + a33*b32   a31*b13 + a32*b23 + a33*b33]

		Return, ({"Elements": [a11*b11 + a12*b21 + a13*b31, a11*b12 + a12*b22 + a13*b32, a11*b13 + a12*b23 + a13*b33
							 , a21*b11 + a22*b21 + a23*b31, a21*b12 + a22*b22 + a23*b32, a21*b13 + a22*b23 + a23*b33
							 , a31*b11 + a32*b21 + a33*b31, a31*b12 + a32*b22 + a33*b32, a31*b13 + a32*b23 + a33*b33]

			, "Base": this.__Matrix3})
	}

	;* Matrix3.RotateX(theta [Radians])
	;* Description:
		;* Creates a x-rotation matrix.
	RotateX(theta) {
		Local

		c := Cos(theta), s := Sin(theta)

		;[1      0         0  ]
		;[0    cos(θ)   sin(θ)]
		;[0   -sin(θ)   cos(θ)]

		Return, ({"Elements": [1, 0, 0, 0, c, s, 0, -s, c]
			, "Base": this.__Matrix3})
	}

	;* Matrix3.RotateY(theta [Radians])
	;* Description:
		;* Creates a y-rotation matrix.
	RotateY(theta) {
		Local

		c := Cos(theta), s := Sin(theta)

		;[cos(θ)   0   -sin(θ)]
		;[  0      1      0   ]
		;[sin(θ)   0    cos(θ)]

		Return, ({"Elements": [c, 0, -s, 0, 1, 0, s, 0, c]
			, "Base": this.__Matrix3})
	}

	;* Matrix3.RotateZ(theta [Radians])
	;* Description:
		;* Creates a z-rotation matrix.
	RotateZ(theta) {
		Local

		c := Cos(theta), s := Sin(theta)

		;[ cos(θ)   sin(θ)   0]
		;[-sin(θ)   cos(θ)   0]
		;[    0       0      1]

		Return, ({"Elements": [c, s, 0, -s, c, 0, 0, 0, 1]
			, "Base": this.__Matrix3})
	}

	Class __Matrix3 extends __Object {

		Set(elements) {
			Local

			this.Elements := elements

			Return, (this)

		}

		RotateX(theta) {
			Local

			c := Cos(theta), s := Sin(theta)
				, m := this.Elements, a12 := m[1], a13 := m[2], a22 := m[4], a23 := m[5], a32 := m[7], a33 := m[8]

			this.Elements[1] := a12*c + a13*-s, this.Elements[2] := a12*s + a13*c, this.Elements[4] := a22*c + a23*-s, this.Elements[5] := a22*s + a23*c, this.Elements[7] := a32*c + a33*-s, this.Elements[8] := a32*s + a33*c

			Return, (this)
		}

		RotateY(theta) {
			Local

			c := Cos(theta), s := Sin(theta)
				, m := this.Elements, a11 := m[0], a13 := m[2], a21 := m[3], a23 := m[5], a31 := m[6], a33 := m[8]

			this.Elements[0] := a11*c + a13*s, this.Elements[2] := a11*-s + a13*c, this.Elements[3] := a21*c + a23*s, this.Elements[5] := a21*-s + a23*c, this.Elements[6] := a31*c + a33*s, this.Elements[8] := a31*-s + a33*c

			Return, (this)
		}

		RotateZ(theta) {
			Local

			c := Cos(theta), s := Sin(theta)
				, m := this.Elements, a11 := m[0], a12 := m[1], a21 := m[3], a22 := m[4], a31 := m[6], a32 := m[7]

			this.Elements[0] := a11*c + a12*-s, this.Elements[1] := a11*s + a12*c, this.Elements[3] := a21*c + a22*-s, this.Elements[4] := a21*s + a22*c, this.Elements[6] := a31*c + a32*-s, this.Elements[7] := a31*s + a32*c

			Return, (this)
		}

;		Print() {
;			Local
;
;			e := this.Elements
;
;			Loop, % 9 {
;				i := A_Index - 1
;					, r .= ((A_Index == 1) ? ("[") : (["`n "][Mod(i, 3)])) . [" "][!(e[i] >= 0)] . e[i] . ((i < 8) ? (", ") : (" ]"))
;			}
;
;			Return, (r)
;		}
	}
}
