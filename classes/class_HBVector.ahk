; Written By: Hellbent aka CivReborn
;Date Started: June 24th, 2018
;Date of last edit: June 24th, 2018
;Name: HB_Vector Class.ahk
;Last Paste:


Class HB_Vector
	{
		__New(x:=0,y:=0)
			{
				This.X:=x
				This.Y:=y
			}
		Add(Other_HB_Vector)
			{
				This.X+=Other_HB_Vector.X
				This.Y+=Other_HB_Vector.Y
			}
		Sub(Other_HB_Vector)
			{
				This.X-=Other_HB_Vector.X
				This.Y-=Other_HB_Vector.Y
			}
		mag()
			{
				return Sqrt(This.X*This.X + This.Y*This.Y)
			}
		magsq()
			{
				return This.Mag()**2
			}	
		setMag(in1) 
			{
				m:=This.Mag()
				This.X := This.X * in1/m
				This.Y := This.Y * in1/m
				return This
			}
		mult(in1,in2:="",in3:="",in4:="",in5:="")  
			{
				if(IsObject(in1)&&in2="")	
					{
						This.X*=In1.X 
						This.Y*=In1.Y 
					}
				else if(!IsObject(In1)&&In2="")
					{
						This.X*=In1
						This.Y*=In1
					}
				else if(!IsObject(In1)&&IsObject(In2))
					{
						This.X*=In1*In2.X
						This.Y*=In1*In2.Y
					}	
				else if(IsObject(In1)&&IsObject(In2))
					{
						This.X*=In1.X*In2.X
						This.Y*=In1.Y*In2.Y
					}	
			}
		div(in1,in2:="",in3:="",in4:="",in5:="") 
			{
				if(IsObject(in1)&&in2="")	
					{
						This.X/=In1.X 
						This.Y/=In1.Y 
					}
				else if(!IsObject(In1)&&In2="")
					{
						This.X/=In1
						This.Y/=In1
					}
				else if(!IsObject(In1)&&IsObject(In2))
					{
						This.X/=In1/In2.X
						This.Y/=In1/In2.Y
					}	
				else if(IsObject(In1)&&IsObject(In2))
					{
						This.X/=In1.X/In2.X
						This.Y/=In1.Y/In2.Y
					}	
			}
		dist(in1)
			{
				return Sqrt(((This.X-In1.X)**2) + ((This.Y-In1.Y)**2))
			}
		dot(in1)
			{
				return (This.X*in1.X)+(This.Y*In1.Y)
			}
		cross(in1)
			{
				return This.X*In1.Y-This.Y*In1.X
			}
		Norm()
			{
				m:=This.Mag()
				This.X/=m
				This.Y/=m
			}
	}