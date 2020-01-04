Class Angle {
	Degrees(_radians){
		Return (_radians*57.295779513082320876798154814105)
	}

	Radians(_degrees){
		Return (_degrees*0.01745329251994329576923690768489)
	}
}

Class Arc {
	Area(_ellipse, _degrees := 0) {
		If (IsObject(_ellipse.radius)) {
		}
		Return ((_degrees/360)*_ellipse.radius**2*3.1415926535897932384626433832795)
	}

	Length(_ellipse, _degrees := 0) {
		If (IsObject(_ellipse.radius)) {
		}
		Return (_ellipse.radius*_degrees*0.01745329251994329576923690768489)
	}
}

Class Point2D {
	__New(_x := 0, _y := 0) {
		Return ({"base": this.base
			, "x": _x
			, "y": _y})
	}

	;===== General
	Distance(_point1, _point2) {
		Return (Sqrt((_point1.x - _point2.x)**2 + (_point1.y - _point2.y)**2))
	}

	Slope(_point1, _point2) {
		Return ((_point2.y - _point1.y)/(_point2.x - _point1.x))
	}

	MidPoint(_point1, _point2) {
		Return (new Point2D((_point1.x + _point2.x)/2, (_point1.y + _point2.y)/2))
	}

	Rotate(_point, _degrees) {
		a := ((_degrees >= 0) ? Mod(_degrees, 360) : 360 - Mod(-_degrees, -360))*0.01745329251994329576923690768489
			, c = Cos(a), s = Sin(a)

		Return (new Point2D(c*_point.x - s*_point.y, s*_point.x + c*_point.y))
	}

	;===== Triangle
	Circumcenter(_point1, _point2, _point3) {
		m := [Point2D.MidPoint(_point1, _point2), Point2D.MidPoint(_point2, _point3)], s := [(_point2.x - _point1.x)/(_point1.y - _point2.y), (_point3.x - _point2.x)/(_point2.y - _point3.y)], p := [m[1].y - s[1]*m[1].x, m[2].y - s[2]*m[2].x]

		Return (s[1] == s[2] ? 0 : _point1.y == _point2.y ? new Point2D(m[1].x, s[2]*m[1].x + p[2]) : _point2.y == _point3.y ? new Point2D(m[2].x, s[1]*m[2].x + p[1]) : new Point2D((p[2] - p[1])/(s[1] - s[2]), s[1]*(p[2] - p[1])/(s[1] - s[2]) + p[1]))
	}

	;===== Ellipse
	Foci(_ellipse) {
		o := [(_ellipse.radius.a > _ellipse.radius.b)*(o := _ellipse.FocalLength), (_ellipse.radius.a < _ellipse.radius.b)*o]

		Return ([new Point2D(_ellipse.h - o[1], _ellipse.k - o[2]), new Point2D(_ellipse.h + o[1], _ellipse.k + o[2])])
	}

	Epicycloid(_ellipse1, _ellipse2, _degrees := 0) {
		a := ((_degrees >= 0) ? Mod(_degrees, 360) : 360 - Mod(-_degrees, -360))*0.01745329251994329576923690768489

		Return (new Point2D(_ellipse1.h + (_ellipse1.radius + _ellipse2.radius)*Cos(a) - _ellipse2.radius*Cos((_ellipse1.radius/_ellipse2.radius + 1)*a), _ellipse.k - o[2], _ellipse1.k + (_ellipse1.radius + _ellipse2.radius)*Sin(a) - _ellipse2.radius*Sin((_ellipse1.radius/_ellipse2.radius + 1)*a)))
	}

	Hypocycloid(_ellipse1, _ellipse2, _degrees := 0) {
		a := ((_degrees >= 0) ? Mod(_degrees, 360) : 360 - Mod(-_degrees, -360))*0.01745329251994329576923690768489

		Return (new Point2D(_ellipse1.h + (_ellipse1.radius - _ellipse2.radius)*Cos(a) + _ellipse2.radius*Cos((_ellipse1.radius/_ellipse2.radius - 1)*a), _ellipse1.k + (_ellipse1.radius - _ellipse2.radius)*Sin(a) - _ellipse2.radius*Sin((_ellipse1.radius/_ellipse2.radius - 1)*a)))
	}

	OnEllipse(_ellipse, _degrees := 0) {
		a := ((_degrees >= 0) ? Mod(_degrees, 360) : 360 - Mod(-_degrees, -360))*0.01745329251994329576923690768489

		If (IsObject(_ellipse.radius)) {
			t := Tan(a), o := Sqrt(_ellipse.radius.b**2 + _ellipse.radius.a**2*t**2), s := (90 < _degrees && _degrees <= 270) ? -1 : 1

			Return (new Point2D(_ellipse.h + s*_ellipse.radius.a*_ellipse.radius.b/o, _ellipse.k + s*_ellipse.radius.a*_ellipse.radius.b*t/o))
		}

		Return (new Point2D(_ellipse.h + _ellipse.radius*Cos(a), _ellipse.k + _ellipse.radius*Sin(a)))
	}
}

Class Ellipse {
	__New(_x := 0, _y := 0, _width := 0, _height := 0, _eccentricity := 0) {
		r := [_width ? _width/2 : (_height/2)*Sqrt(1 - _eccentricity**2), _height ? _height/2 : (_width/2)*Sqrt(1 - _eccentricity**2)]

		Return {"base": this.base
			, "x": _x
			, "y": _y
			, "h": _x + r[1]
			, "k": _y + r[2]

			, "radius": r[1] == r[2] ? r[1] : {"a": r[1]
				, "b": r[2]}}
	}

	SemiMajor_Axis[] {
		Get {
			Return (IsObject(this.radius) ? Max(this.radius.a, this.radius.b) : this.radius)
		}
	}

	SemiMinor_Axis[] {
		Get {
			Return (IsObject(this.radius) ? Min(this.radius.a, this.radius.b) : this.radius)
		}
	}

	Area[] {
		Get {
			Return ((IsObject(this.radius) ? this.radius.a*this.radius.b : this.radius**2)*3.1415926535897932384626433832795)
		}
	}

	Circumference[] {  ;Approximation by Srinivasa Ramanujan.
		Get {
			Return (IsObject(this.radius) ? (3*(this.radius.a + this.radius.b) - Sqrt((3*this.radius.a + this.radius.b)*(this.radius.a + 3*this.radius.b)))*3.1415926535897932384626433832795 : this.radius*6.283185307179586476925286766559)
		}
	}

	Eccentricity[] {
		Get {
			Return (IsObject(this.radius) ? this.FocalLength/this.SemiMajor_Axis : 0)
		}
	}

	FocalLength[] {
		Get {
			Return (IsObject(this.radius) ? Sqrt(this.SemiMajor_Axis**2 - this.SemiMinor_Axis**2) : 0)
		}
	}

	Apoapsis[] {
		Get {
			Return (IsObject(this.radius) ? this.SemiMajor_Axis*(1 + this.Eccentricity) : this.radius)
		}
	}

	Periapsis[] {
		Get {
			Return (IsObject(this.radius) ? this.SemiMajor_Axis*(1 - this.Eccentricity) : this.radius)
		}
	}

	SemiLatus_Rectum[] {
		Get {
			Return (IsObject(this.radius) ? this.SemiMajor_Axis*(1 - this.Eccentricity**2) : 0)
		}
	}

	InscribeEllipse(_ellipse1, _ellipse2, _degrees := 0) {
		a := ((_degrees >= 0) ? Mod(_degrees, 360) : 360 - Mod(-_degrees, -360))*0.01745329251994329576923690768489
			, c := _ellipse1.h + (_ellipse1.radius - _ellipse2.radius)*Cos(a), s := _ellipse1.k + (_ellipse1.radius - _ellipse2.radius)*Sin(a)

		Return ({"x": c - _ellipse2.radius, "y": s - _ellipse2.radius, "h": c, "k": s, "radius": _ellipse2.radius})
	}
}