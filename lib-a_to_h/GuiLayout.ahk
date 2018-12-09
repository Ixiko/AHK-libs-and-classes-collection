; Creates either a container or control component
;     ControlHwnd		- The Hwnd of the control to associate with this component or 0 if this component is only a container for other controls/components.
;						  A component may have an associated control and contain other components at the same time.
;						  A component's control will automatically assume the size of the component
;     ParentComponent	- The parent component that the new component will belong to
;     LayoutRules		- Defines how this component will be sized and positioned within its parent container.
;						  This must be a string with each value or rule seperated ba a single space, the following rules are recognised:
;						  - l/r/t/b	: Stands for left, right, top, and bottom. Anchors the corresponding side of the component to its parent.
;									  A value must follow directly after the the letter, the following types are recognised:
;									  - A plain pixel value, eg. r100 will anchor the component's right hand side 100 pixels from its parent's right side.
;									  - A percentage value, eg. r25% will anchor the component's right hand side 25% of its parent's width from t
;									  - For percent values an offset may also be given by using either a + or - followed be the offset, eg. r50%+5 will
;										anchor the right hand side in the middle of its parent, plus five pixels. This can be useful for adding padding between components.
;									  - You can also have the anchor automatically be calculated based on the previous component, eg. r>5 will take the r value and width
;										of the previously defined component and calculate this component's r values based on that so that it is placed just left of it plus five pixels.
;										This can be useful for quickly creating rows or columns of components without having to manually enter anchor values
;						  - w/h		: By default if a component has an associated control it will automatically assume the size of that control if needed. Using the w and h rules you can change
;									  the control's or set a size for container components that do not have associated controls. These options only support simple pixel values.
;									  the control's or set a size for container components that do not have associated controls. These options only support simple pixel values.
;									  If a component already has both an l/t and an r/b rule the w and h options will have no effect since the component's size will be calculated
;									  based on the l/t and r/b options and size of its parent 
;						  - nd		: By default when a component is moved or sized during layout it will use the GuiControl MoveDraw command, if the nd (no draw) flag is present then 
;									  the Move command will be used instead
; Return - A GuiLayout Component object
GuiLayout_Create(ControlHwnd := 0, ParentComponent := 0, LayoutRules := ""){
	static CurrentId := 1
		, PreviousComponent := 0
	
	Component := {Id: CurrentId}
	
	if(ControlHwnd)
		Component.ControlHwnd := ControlHwnd
	
	; Add this component to its parent
	
	if(ParentComponent){
		if( (Children := ParentComponent.Children) )
			Children[CurrentId] := Component
		else
			ParentComponent.Children := {}
			, ParentComponent.Children[CurrentId] := Component
	}
	
	; Parse the layout rules
	
	Loop Parse, LayoutRules, %A_Space%
	{
		; NoDraw flag
		if(A_LoopField = "nd"){
			Component.nd := 1
			continue
		}
		
		RulePosition := SubStr(A_LoopField, 1, 1)
		, RuleValue := RV := SubStr(A_LoopField, 2)
		, RuleOffset := 0
		, RuleValueIsPixels := 1
		
		; Width and height only support regular pixel values
		if(RulePosition = "w" or RulePosition = "h"){
			Component[RulePosition] := RuleValue
			continue
		}
		
		; Calculate an offset and position based on the position and size of the previous control
		if(SubStr(RuleValue, 1, 1) = ">"){
			RuleValue := SubStr(RuleValue, 2)
			
			if(RulePosition = "l" or RulePosition = "r"){
				PrevL := PreviousComponent.l
				, PrevLP := PreviousComponent.lp
				, PrevR := PreviousComponent.r
				, PrevRP := PreviousComponent.rp
				, PrevS := PreviousComponent.w
			}
			else{
				PrevL := PreviousComponent.t
				, PrevLP := PreviousComponent.tp
				, PrevR := PreviousComponent.b
				, PrevRP := PreviousComponent.bp
				, PrevS := PreviousComponent.h
			}
			
			if(PrevL != ""){
				if(PrevLP)
					RuleOffset := RuleValue + PrevS
					, RuleValue := PrevL
					, RuleValueIsPixels := 0
				else
					RuleValue += PrevL + PrevS
			}
			else if(PrevR != ""){
				if(PrevRP)
					RuleOffset := RuleValue + PrevS
					, RuleValue := PrevR
					, RuleValueIsPixels := 0
				else
					RuleValue :=  PrevR + PrevS + RuleValue
			}
		}
		
		; Check for an extra offset value eg. 50%+4
		else if( (Pos := InStr(RuleValue, "+")) )
			RuleOffset := SubStr(RuleValue, Pos + 1)
			, RuleValue := SubStr(RuleValue, 1, Pos - 1)
		; > A negative offset
		else if( (Pos := InStr(RuleValue, "-")) and Pos != 1 )
			RuleOffset := -SubStr(RuleValue, Pos + 1)
			, RuleValue := SubStr(RuleValue, 1, Pos - 1)
		
		; Check for ap percentage value instead of a pixel value
		if(SubStr(RuleValue, 0) = "%")
			RuleValueIsPixels := 0
			, RuleValue := SubStr(RuleValue, 1, -1) / 100
		
		Component[RulePosition] := RuleValue
		if(RuleOffset)
			Component[RulePosition "o"] := RuleOffset
		if(!RuleValueIsPixels)
			Component[RulePosition "p"] := 1
	}
	
	; Get the control size if needed, eg. if an "r" value is set but no "l" we will need to know the width
	; of the control so that its x position can be calculate relative to the right side of its parent
	if(ControlHwnd){
		GetSize := 0
		if(Component.HasKey("l") != Component.HasKey("r") and !Component.HasKey("w"))
			GetSize := 1, SetWidth := 1
		else
			SetWidth := 0
		if(Component.HasKey("t") != Component.HasKey("b") and !Component.HasKey("h"))
			GetSize := 1, SetHeight := 1
		else
			SetHeight := 0
		
		if(Component.HasKey("w") or Component.HasKey("h")){
			Position := (Component.HasKey("w") != "" ? "w" Component.w : "") (Component.HasKey("h") ? " h" Component.h : "")
			GuiControl Move, %ControlHwnd%, %Position%
		}
		
		if(GetSize){
			ControlGetPos, , , ControlW, ControlH, , ahk_id %ControlHwnd%
			if(SetWidth)
				Component.w := ControlW
			if(SetHeight)
				Component.h := ControlH
		}
	}
	
	CurrentId++
	return PreviousComponent := Component
}

; Recursively updates the size of the given component and all child components according to their layout rules
;   Component	- A component returned by the GuiLayout_Create function, usually the root component in a layout hierarchy
;   Width		- The new width of the component
;   Height		- The new height of the component
; Return - Nothing
GuiLayout_SetSize(Component, X, Y, Width, Height){
	static ComponentList := [], ComponentListSize := 0
	
	ComponentListSize := ComponentListIndex := 0
	
	; Use a stack to process all descendant components starting with all of the children of this component.
	; A zero indicates that the next item on the list is the parent component of all of the following items.
	ComponentList[++ComponentListSize] := 0
	ComponentList[++ComponentListSize] := Component
	for ChildId, ChildComponent in Component.Children
		ComponentList[++ComponentListSize] := ChildComponent
	
	Component.x := X, Component.y := Y
	Component.w := Width, Component.h := Height
	
	while(ComponentListIndex < ComponentListSize){
		Component := ComponentList[++ComponentListIndex]
		; 0 means that the next item is the parent component for all subsequent items on the stack
		if(!Component){
			ParentComponent := ComponentList[++ComponentListIndex]
			ParentX := ParentComponent.x, ParentY := ParentComponent.y
			ParentW := ParentComponent.w, ParentH := ParentComponent.h
			continue
		}
		
		L := R := T := B := ""
		X := Y := W := H := ""
		
		; X
		if( (Left := Component.l) != "" )
			L := (Component.lp ? ParentW * Left : Left) + (Component.lo ? Component.lo : 0)
		if( (Right := Component.r) != "" )
			R := (Component.rp ? ParentW * Right : Right) + (Component.ro ? Component.ro : 0)
		
		if(L = "" or R = "")
			X := R = "" ? L : ParentW - R - Component.w
		else
			X := L, W := ParentW - R - L
		
		; Y
		if( (Top := Component.t) != "" )
			T := (Component.tp ? ParentH * Top : Top) + (Component.to ? Component.to : 0)
		if( (Bottom := Component.b) != "" )
			B := (Component.bp ? ParentH * Bottom : Bottom) + (Component.bo ? Component.bo : 0)
		
		if(T = "" or B = "")
			Y := B = "" ? T : ParentH - B - Component.h
		else
			Y := T, H := ParentH - B - T
		
		X += ParentX, Y += ParentY
		
		if(Component.ControlHwnd){
			Position := (X != "" ? "x" X : "") (Y != "" ? " y" Y : "") (W != "" ? " w" W : "") (H != "" ? " h" H : "")
			GuiControl % Component.nd ? "Move" : "MoveDraw", % Component.ControlHwnd, %Position%
		}
		
		Component.x := X, Component.y := Y
		if(W != "")
			Component.w := W
		if(H != "")
			Component.h := H
		
		ComponentList[++ComponentListSize] := 0
		ComponentList[++ComponentListSize] := Component
		for ChildId, ChildComponent in Component.Children
			ComponentList[++ComponentListSize] := ChildComponent
		
	}
}