;
; GUI Tree View Control Wrapper Class
;

#include <CControl>

/*!
	Class: CCtrlTreeView
		Tree view control (equivalent to `Gui, Add, TreeView`).
	Inherits: CControl
	@UseShortForm
*/

class CCtrlTreeView extends CControl
{
	static __CtrlName := "TreeView"
	Nodes := []
	
	/*!
		Constructor: (oGui, options := "")
			Creates the control.
		Parameters:
			oGui - The window in which to create the control.
			options - (Optional) Options (including positioning) to apply to the control.
				See the AutoHotkey help file for more details.
	*/
	
	__New(oGui, options := "")
	{
		base.__New(oGui, "", options)
	}
	
	_SelectTV()
	{
		this.__Gui()._SelectTV(this)
	}
	
	_InternalAddNode(name, options, parent := "")
	{
		this._SelectTV()
		if not ptr := TV_Add(name, parent ? parent.__Handle : 0, options)
			throw Exception("TV_Add()", -1) ; Short msg since so rare.
		return this.Nodes[ptr] := new CCtrlTreeView.Node(ptr, this, parent)
	}
	
	_InternalNodeDestroy(h)
	{
		this._SelectTV()
		TV_Delete(h)
		this.Nodes.Remove(h, "")
	}
	
	/*!
		Method: AddNode(text, options := "")
			Adds a root node to the tree. Analogous to `TV_Add()` with a null parent ID.
		Parameters:
			text - The text of the node.
			options - *(Optional)* The options to apply. Refer to `TV_Add()` for more details.
		Returns:
			A [node object](#Node).
	*/
	
	AddNode(name, options := "")
	{
		return this._InternalAddNode(name, options)
	}
	
	/*!
		Method: BindImageList(oList, stateIcon := false)
			Binds an image list to the control. Analogous to `TV_SetImageList()`.
		Parameters:
			oList - The [image list](CImageList.html) to bind.
			stateIcon - *(Optional)* Specify `true` to use state icons (not yet
				supported by AutoHotkey itself). Defaults to `false`.
	*/
	
	BindImageList(oList, stateIcon := false)
	{
		this._SelectTV()
		ret := TV_SetImageList(oList.__Handle, stateIcon ? 2 : 0)
		this.__ImageList := oList ; Store a reference to the image list object
		return ret
	}
	
	/*!
		Method: _NewEnum()
			Enumerates all the root elements in the tree.
		Remarks:
			Enumerate the nodes using the `for` command:
			> for position, node in treeViewCtrl ; "node" will contain a node object.
	*/
	
	_NewEnum()
	{
		return new this.Enumerator(this.FirstNode)
	}
	
	; Property getters
	class __Get extends CPropImpl
	{
		/*!
			Property: Selection [get]
				Returns the selected [node](#Node). Analogoous to `TV_GetSelection()`.
				It can return an empty string if there is no selected node.
		*/
		Selection()
		{
			this._SelectTV()
			return this.Nodes[TV_GetSelection()]
		}
		
		/*!
			Property: NodeCount [get]
				Returns the total number of [nodes](#Node) in the tree. Equivalent to `TV_GetCount()`.
		*/
		
		NodeCount()
		{
			this._SelectTV()
			return TV_GetCount()
		}
		
		/*!
			Property: FirstNode [get]
				Returns the first root [node](#Node) in the tree. Analogous to `TV_GetNext()` with no parameters.
				It can return an empty string if there are no nodes in the tree.
		*/
		
		FirstNode()
		{
			this._SelectTV()
			return this.Nodes[TV_GetNext()]
		}
	}
	
	/*!
		Class: Node
			Tree node class.
		@UseShortForm
	*/
	
	class Node
	{
		__New(ptr, oCtrl, oParent := "")
		{
			this.__Handle := ptr
			this.__CtrlPtr := &oCtrl
			this.Parent := oParent
		}
		
		__Delete()
		{
			this.Remove()
		}
		
		__Control()
		{
			return Object(this.__CtrlPtr)
		}
		
		/*!
			Method: Remove()
				Removes the node. The same effect is achieved by deleting the object. Analogous to `TV_Delete()`.
		*/
		
		Remove()
		{
			h := this.__Handle
			if h is not integer
				return
			this.__Control()._InternalNodeDestroy(h)
			this.__Handle := "<DELETED>"
		}
		
		/*!
			Method: AddNode(text, options := "")
				Adds a sub-node to the node. Analogous to `TV_Add()` with a non-null parent ID.
			Parameters:
				text - The text of the node.
				options - *(Optional)* The options to apply. Refer to `TV_Add()` for more details.
			Returns:
				A [node object](#Node).
		*/
		
		AddNode(name, options := "")
		{
			return this.__Control()._InternalAddNode(name, options, this)
		}
		
		/*!
			Method: Select()
				Selects the node. Analogous to `TV_Modify(nodeId)`.
		*/
		
		Select()
		{
			this.__Control()._SelectTV()
			TV_Modify(this.__Handle)
		}
		
		/*!
			Method: Modify(options [, newText])
				Modifies the properties of the node in one go. Analogous to `TV_Modify()`.
			Remarks:
				The parameters are exactly the same as `TV_Modify()`'s last two parameters.
		*/
		
		Modify(options, p*)
		{
			this.__Control()._SelectTV()
			TV_Modify(this.__Handle, options, p*)
		}
		
		; Property getters
		class __Get extends CPropImpl
		{
			/*!
				Property: FirstChild [get]
					Returns the first child node. Analogous to `TV_GetChild()`.
					It can return an empty string if there are no child nodes.
			*/
			FirstChild()
			{
				oCtrl := this.__Control(), oCtrl._SelectTV()
				return oCtrl.Nodes[TV_GetChild(this.__Handle)]
			}
			
			/*!
				Property: PreviousNode [get]
					Returns the previous node inside the parent. Analogous to `TV_GetPrev()`.
					It can return an empty string if there are no previous nodes.
			*/
			PreviousNode()
			{
				oCtrl := this.__Control(), oCtrl._SelectTV()
				return oCtrl.Nodes[TV_GetPrev(this.__Handle)]
			}
			
			/*!
				Property: NextNode [get]
					Returns the next node inside the parent. Analogous to `TV_GetNext()` with one parameter.
					It can return an empty string if there are no more nodes.
			*/
			NextNode()
			{
				oCtrl := this.__Control(), oCtrl._SelectTV()
				return oCtrl.Nodes[TV_GetNext(this.__Handle)]
			}
			
			/*!
				Property: NextFlatNode [get]
					Returns the next node (with no regard to relationship). Analogous to `TV_GetNext(nodeId, "F")`.
					It can return an empty string if there are no more nodes.
			*/
			
			NextFlatNode()
			{
				oCtrl := this.__Control(), oCtrl._SelectTV()
				return oCtrl.Nodes[TV_GetNext(this.__Handle, "F")]
			}
			
			/*!
				Property: NextCheckedNode [get]
					Returns the next checked node (with no regard to relationship). Analogous to `TV_GetNext(nodeId, "C")`.
					It can return an empty string if there are no more nodes.
			*/
			
			NextCheckedNode()
			{
				oCtrl := this.__Control(), oCtrl._SelectTV()
				return oCtrl.Nodes[TV_GetNext(this.__Handle, "C")]
			}
			
			/*!
				Property: Text [get/set]
					Represents the text of the node.
			*/
			
			Text()
			{
				this.__Control()._SelectTV()
				TV_GetText(ov, this.__Handle)
				return ov
			}
			
			/*!
				Property: Expanded [get/set]
					`true` if the node is expanded, `false` otherwise.
			*/
			
			Expanded()
			{
				this.__Control()._SelectTV()
				return !!TV_Get(this.__Handle, "E")
			}
			
			/*!
				Property: Checked [get/set]
					`true` if the node's checkbox is ticked, `false` otherwise.
			*/
			
			Checked()
			{
				this.__Control()._SelectTV()
				return !!TV_Get(this.__Handle, "C")
			}
			
			/*!
				Property: Bold [get/set]
					`true` if the node's text is bold, `false` otherwise.
			*/
			
			Bold()
			{
				this.__Control()._SelectTV()
				return !!TV_Get(this.__Handle, "B")
			}
		}
		
		; Property setters
		class __Set extends CPropImpl
		{
			Text(value)
			{
				this.Modify("", value)
			}
			
			Expanded(value)
			{
				this.Modify(value ? "+Expand" : "-Expand")
			}
			
			Checked(value)
			{
				this.Modify(value ? "+Check" : "-Check")
			}
			
			Bold(value)
			{
				this.Modify(value ? "+Bold" : "-Bold")
			}
		}
		
		/*!
			Method: _NewEnum()
				Enumerates all the children belonging to the node.
			Remarks:
				Enumerate the nodes using the `for` command:
				> for position, node in parentNode ; "node" will contain a node object.
		*/
		
		_NewEnum()
		{
			return new CCtrlTreeView.Enumerator(this.FirstChild)
		}
	}
	
	/*!
		End of class
	*/
	
	/*!
		Method: OnDoubleClick(oCtrl, node)
			Called when the user double-clicks a node.
		Parameters:
			oCtrl - The control that fired the event.
			node - The [node object](#Node).
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnDrag(oCtrl, node, isRightClick)
			Called when the user begins or ends dragging a node.
		Parameters:
			oCtrl - The control that fired the event.
			node - The [node object](#Node).
			isRightClick - `true` if the user *right-click-dragged* the node, `false` otherwise.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnEdit(oCtrl, node, isEnd)
			Called when the user begins or ends editing the node.
		Parameters:
			oCtrl - The control that fired the event.
			node - The [node object](#Node).
			isEnd - `true` if the user finished dragging, `false` otherwise.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive edit start events, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnSelect(oCtrl, node)
			Called when the user (or the script) selects a node.
		Parameters:
			oCtrl - The control that fired the event.
			node - The [node object](#Node).
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnClick(oCtrl, node, isRightClick)
			Called when the user clicks a node.
		Parameters:
			oCtrl - The control that fired the event.
			node - The [node object](#Node).
			isRightClick - `true` if the user right-clicked the node, `false` otherwise.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive this event, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnKeybdFocus(oCtrl, hasFocus)
			Called when the user gives or removes keyboard focus to the control.
		Parameters:
			oCtrl - The control that fired the event.
			hasFocus - `true` if the control gained focus, `false` otherwise.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive edit start events, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnKeyPress(oCtrl, keyVK)
			Called when the user presses a key.
		Parameters:
			oCtrl - The control that fired the event.
			keyVK - The virtual key code of the key.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive this event, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnExpand(oCtrl, node)
			Called when a node is expanded.
		Parameters:
			oCtrl - The control that fired the event.
			node - The [node object](#Node).
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive this event, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnCollapse(oCtrl, isBegin)
			Called when a node is collapsed.
		Parameters:
			oCtrl - The control that fired the event.
			node - The [node object](#Node).
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			In order to receive this event, use the `AltSubmit` control option.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	OnEvent(oCtrl, guiEvent, eventInfo)
	{
		if IsLabel(lbl := "__CCtrlTreeView_OnEvent_" guiEvent)
			goto %lbl%
		return
		
		__CCtrlTreeView_OnEvent_DoubleClick:
		return oCtrl.OnDoubleClick.(this, oCtrl, oCtrl.Nodes[eventInfo])
		
		__CCtrlTreeView_OnEvent_D:
		return oCtrl.OnDrag.(this, oCtrl, oCtrl.Nodes[eventInfo], guiEvent == "d")
		
		__CCtrlTreeView_OnEvent_e:
		return oCtrl.OnEdit.(this, oCtrl, oCtrl.Nodes[eventInfo], guiEvent == "e")
		
		__CCtrlTreeView_OnEvent_S:
		return oCtrl.OnSelect.(this, oCtrl, oCtrl.Nodes[eventInfo])
		
		__CCtrlTreeView_OnEvent_Normal:
		__CCtrlTreeView_OnEvent_RightClick:
		return oCtrl.OnClick.(this, oCtrl, oCtrl.Nodes[eventInfo], !!InStr(guiEvent, "R"))
		
		__CCtrlTreeView_OnEvent_F:
		return oCtrl.OnKeybdFocus.(this, oCtrl, eventInfo == "F")
		
		__CCtrlTreeView_OnEvent_K:
		return oCtrl.OnKeyPress.(this, oCtrl, eventInfo)
		
		__CCtrlTreeView_OnEvent_+:
		return oCtrl.OnExpand.(this, oCtrl, oCtrl.Nodes[eventInfo])
		
		__CCtrlTreeView_OnEvent_-:
		return oCtrl.OnCollapse.(this, oCtrl, oCtrl.Nodes[eventInfo])
	}
	
	class Enumerator
	{
		__New(baseNode)
		{
			this.cur := baseNode
			this.i := 0
		}
		
		Next(ByRef k, ByRef v)
		{
			if not v := this.cur
				return false
			k := ++this.i
			this.cur := this.cur.NextNode
			return true
		}
	}
}

/*!
	End of class
*/
