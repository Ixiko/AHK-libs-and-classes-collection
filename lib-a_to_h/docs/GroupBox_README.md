# AHK_GroupBox

Adds and wraps a GroupBox around a group of controls in the default Gui. Use the Gui Default command if needed.
For instance:

<code>Gui, 2:Default</code>

sets the default Gui to Gui 2.

Function definition:
```
GroupBox(GBvName		;Name for GroupBox control variable
	,Title			;Title for GroupBox
	,TitleHeight		;Height in pixels to allow for the Title
	,Margin			;Margin in pixels around the controls
	,Piped_CtrlvNames	;Pipe (|) delimited list of Controls
	,FixedWidth=""		;Optional fixed width
	,FixedHeight=""		;Optional fixed height
	,Kin=true)		;Optional include or exclude children of other included GroupBoxes
```
Add the controls you want in the GroupBox to the Gui using
the "v" option to assign a variable name to each control. *
Then immediately after the last control for the group
is added call this function. It will add a GroupBox and
wrap it around the controls.

Example:
<pre>Gui, Add, Text, vControl1, This is Control 1			;Add named Text field
Gui, Add, Text, vControl2 x+30, This is Control 2		;Add another named Text field
GroupBox("GB1", "Testing", 20, 10, "Control1|Control2")		;Create GB around "variables" Control1 and Control2 listed above
Gui, Add, Text, Section xMargin, This is Control 3		;Add an unnamed Text field
GroupBox("GB2", "Another Test", 10, 10, "This is Control 3")	;Wrap around the new text field by field text rather than control name
Gui, Add, Text, yS, This is Control 4				;Add another unnamed Text field
GroupBox("GB3", "Third Test", 10, 10, "Static4")		;Wrap around the new text field by field text rather than control name
GroupBox("GB4", "Big Wrapper", 10, 10, "GB2|GB3")		;Wrap around the previous two GroupBoxes
Gui, Show, , GroupBox Test</pre>

The "v" option to assign Control ID is not mandatory. You
may also use the ClassNN name or text of the control.

    Original Author: dmatch @ AHK forum
  
    Date: Sept. 5, 2011
  
    Additions by: digimystigi
