class k3DMatrix
{

	__New()
	{
		return {base:k3DMatrix,1:[1,0,0,0],2:[0,1,0,0],3:[0,0,1,0],4:[0,0,0,1]}
	}
	
	Vector(vec)
	{
		while (vec.MaxIndex()<4)
			vec.push(vec.MaxIndex()=3)
		res := [0,0,0,0]
		Loop 4
		{
			y := A_Index
			Loop 4
				res[y] += this[y,A_Index]*vec[A_Index]
		}
		return res
	}
	
	Matrix(m1)
	{
		m2 := This.Clone()
		Loop 4
		{
			y := A_Index
			This[y] := []
			Loop 4
			{
				x := A_Index
				This[y,x] := 0
				Loop 4
					This[y,x] += m2[y,A_Index]*m1[A_Index,x]
			}
		}
		return this
	}
	Matrix2(m1)
	{
		m2 := This.Clone()
		Loop 4
		{
			y := A_Index
			This[y] := []
			Loop 4
			{
				x := A_Index
				This[y,x] := 0
				Loop 4
					This[y,x] += m1[y,A_Index]*m2[A_Index,x]
			}
		}
		return this
	}
	Scale(p*)
	{
		For x, val in p
			Loop 4
				This[A_Index,x] *= val 
	}
	Translate(x,y,z)
	{
		Loop 4
			This[A_Index,4] += x*This[A_Index,1]+y*This[A_Index,2]+z*This[A_Index,3]
	}
	Rotate(angle,x,y,z)
	{
		This.Matrix(This.newRotate(angle,x,y,z))
	}
	Rotate2(angle,x,y,z)
	{
		This.Matrix2(This.newRotate(angle,x,y,z))
	}
	loadIdentity()
	{
		This.RemoveAt(1,4)
		This.InsertAt(1,[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1])
	}
	newScale(x,y,z)
	{
		return {base:k3DMatrix,1:[x,0,0,0],2:[0,y,0,0],3:[0,0,z,0],4:[0,0,0,1]}
	}
	newTranslate(x,y,z)
	{
		return {base:k3DMatrix,1:[1,0,0,x],2:[0,1,0,y],3:[0,0,1,z],4:[0,0,0,1]}
	}
	newRotate(angle,x,y,z)
	{
		t := (((x**2)+(y**2)+(z**2))**0.5)
		x := x/t
		y := y/t
		z := z/t
		s := sin(angle*((ATan(1)*4)/180))
		c := cos(angle*((ATan(1)*4)/180))
		return {base:k3DMatrix,1:[x**2*(1-c)+c,x*y*(1-c)-z*s,x*z*(1-c)+y*s,0],2:[y*x*(1-c)+z*s,y**2*(1-c)+c,y*z*(1-c)+x*s,0],3:[x*z*(1-c)-y*s,y*z*(1-c)+x*s,z**2*(1-c)+c,0],4:[0,0,0,1]}
	}
}