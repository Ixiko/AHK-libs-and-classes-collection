;This is the base class for compound controls which consist of multiple controls. Examples include a path control with an edit field and a browse button or a synchronized list
Class CCompoundControl
{
	Container := {}
	Name := "Compound Control"
	Boundaries := ""
	AddContainerControl(GUI, Type, Name, Options, Text)
    {
        this.Container.Insert(Name, GUI.AddControl(Type, "", Options, Text))
    }
	__Get(Key)
	{
		if Key in x,y,Width,Height
		{
			if(!IsObject(this.Boundaries))
				this.CalculateBoundaries()
			return this.Boundaries[Key]
		}
	}
	__Set(Key, Value)
	{
		if Key in x,y
		{
			this.CalculateBoundaries()
			if(Key = "X")
			{
				DeltaX := Value - this.Boundaries.X
				for index, Control in this.Container
					Control.X := Control.X + DeltaX
				return this.Boundaries.X += DeltaX
			}
			if(Key = "Y")
			{
				DeltaY := Value - this.Boundaries.Y
				for index, Control in this.Container
					Control.Y := Control.Y + DeltaY
				return this.Boundaries.Y += DeltaY
			}	
		}
		;Don't allow storing Width/Height keys. The implementing Compound object needs to handle these keys.
		if Key in Width,Height
			return this.Boundaries[Key]
	}
	CalculateBoundaries()
	{
		x := 0x7fFFffFF
		y := 0x7fFFffFF
		w := 0
		h := 0
		for index, control in this.Container
		{
			Position := control.Position
			Size := control.Size
			if(Position.x < x)
				x := Position.x
			if(Position.y < y)
				y := Position.y
			if(Position.x + Size.Width < w)
				w := Position.w
			if(Position.y + Size.Height < h)
				h := Position.h
		}
		this.Boundaries := {x : x, y : y, width : w, height : h}
	}
}