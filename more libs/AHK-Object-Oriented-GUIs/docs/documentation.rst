###############
Documentation
###############



*******
GuiBase
*******

The :class:`GuiBase` class is the main class that represents a GUI.

It can either be instantiated directly, or you can extend upon it for more complicated GUIs. See the :ref:`examples`.


.. data:: GuiBase.__Version

   Contains the installed version of the library.
   
.. function:: GuiBase.GetGui(hwnd)

   :param hwnd: GUI hwnd.
   :return: A :class:`GuiBase` instance, if found.
   
.. class:: GuiBase

  Represents a GUI object.

  .. data:: Title
   
     Get or set the window title.
   
  .. data:: hwnd

     Contains the window handle.
   
  .. data:: ahk_id

     Shorthand for ``"ahk_id" . hwnd``
   
  .. data:: Visible

     Bool indicating whether the window is visible or hidden.
   
  .. data:: BackgroundColor

     Get or set the background color.
   
  .. data:: ControlColor

     Get or set the control (foreground) color.
   
  .. data:: Controls
  
     An array of all control instances the GUI instance has created.
   
  .. data:: Position

     Instance of :class:`GuiBase.WindowPosition` representing the position and size of the GUI window.

  .. function:: __New(Title := "AutoHotkey Window", Options := "")

     Creates a new instance of the class.

     .. note::
        You shouldn't call this meta-function directly, but use the ``new`` keyword.
        See the AutoHotkey documentation on `constructing and deconstructing objects <https://autohotkey.com/docs/Objects.htm#Custom_NewDelete>`_.

     :param Title: Title of the window.
     :param Options: Options string.
     :return: A :class:`GuiBase` instance.
   
  .. function:: Show(Options := "")

     Shows the GUI window.
   
     :param Options: Options string.
   
  .. function:: Hide(Options := "")

     Hides the GUI window.

     :param Options: Options string.
   
  .. function:: Destroy(Options := "")

     Destroys the GUI, and frees all ``GuiBase.ControlType`` instances related to it. It's a good idea to clear all references you have kept yourself so the GuiBase instance can be freed properly.
     
  .. function:: Options(Options)

     Change the options of the GUI.

     :param Options: Options string.
     
  .. function:: SetDefault()

     Sets this GUI as the default GUI.
     
  .. function:: SetDefaultListView(ListView)

     Sets the default ListView control.

     :param ListView: :class:`GuiBase.ListViewControl` instance.
     
  .. function:: Control(Command := "", Control := "", ControlParams := "")

     Calls GuiControl.

     :param Command: The GuiControl command to perform.
     :param Control: The control instance to apply the command on.
     :param ControlParams: The parameters for the command.
	
  .. function:: GetControl(hwnd)
  
     Gets a control instance.
     
     :param hwnd: hwnd of the control.
     :return: A control instance, if found.
     
  .. function:: Margins(x := "", y := "")

     Sets the control spacing margins for newly created controls.

     :param x: Horizontal spacing.
     :param y: Vertical spacing.
     
  .. function:: Font(Options := "", Font := "")

     Changes the font for newly created controls.

     :param Options: Options string.
     :param Font: Font name.
     
  .. function:: Focus()

     Focuses the GUI window.
     
  .. function:: Enable()

     Enables the GUI window if previously disabled.
     
  .. function:: Disable()

     Disables the GUI window if previously enabled.
     
  .. function:: SetIcon(Icon)

     Changes the GUI window icon.
     
     :param Icon: Path to an icon file.
     
  .. function:: AddText(Options := "", Text := "")
  
     Adds a text control.
     
     :param Options: Options string.
     :param Text: Text contents of the control.
     :return: :class:`GuiBase.TextControl` instance.
     
  .. function:: AddButton(Options := "", Text := "")
  
     Adds a text control.
     
     :param Options: Options string.
     :param Text: Text contents of the control.
     :return: :class:`GuiBase.ButtonControl` instance.
     
  .. function:: AddEdit(Options := "", Text := "")
  
     Adds an edit control.
     
     :param Options: Options string.
     :param Text: Text contents of the control.
     :return: :class:`GuiBase.EditControl` instance.
     
  .. function:: AddListView(Options := "", Headers := "")
  
     Adds a ListView control.
     
     :param Options: Options string.
     :param Headers: Either an array of header names, or a string of header names separated by ``|`` (pipe).
     :return: :class:`GuiBase.ListViewControl` instance.
     
  .. function:: AddStatusBar(Options := "", Text := "")
  
     Adds a statusbar.
     
     :param Options: Options string.
     :param Text: Text contents of the control.
     :return: :class:`GuiBase.StatusBarControl` instance.




.. currentmodule:: GuiBase



**********
Base types
**********

ControlType
-----------
   
.. class:: ControlType

  Represents a GUI control object.

  .. data:: Gui
   
     Reference to the GUI instance that created this instance.
     
  .. data:: hwnd
  
     Handle of the control.
     
  .. data:: Position
  
     :class:`GuiBase.ControlPosition` instance.

  .. function:: __New(Gui, Options := "", Text := "")

     Creates a new control instance.
     
     .. note::
        Don't construct control instances directly, use the methods in :class:`GuiBase`.

     :param Gui: The GUI instance that created this control.
     :param Options: Options string.
     :param Text: Inital text contents of the control, if applicable.
     :return: An indirect reference to the control instance.
     
  .. function:: Options(Options)

     Change the options/settings of the control.
     
     :param Options: Options string.
     
  .. function:: Control(Command := "", Options := "")

     Calls the `GuiControl <https://autohotkey.com/docs/commands/GuiControl.htm>`_ command.
     
     :param Command: The action to do. See documentation link above.
     :param Options: `Param3` in the documentation link above.
     
  .. function:: OnEvent(Func := "")

     Makes the control call ``Func`` when an event happens.
     
     :param Func: Function reference or boundfunc to call when events happen.
	:return: The control instance.
     
ContentControlType
-----------------
     
.. class:: ContentControlType

  This class extends :class:`GuiBase.ControlType`

  Represents a control with a singular content field, such as :class:`GuiBase.TextControl`, :class:`GuiBase.ButtonControl` and :class:`GuiBase.EditControl`
   
  .. data:: Text
     
     Get or set the contents of the control.
     
  .. function:: GetText()
  
     :return: The text contents of the control.
     
  .. function:: SetText(Text)
  
     :param Text: New contents of the control.

PositionType
------------

.. class:: PositionType

  This class handles setting and getting positions of controls and windows.
  It has four properties (X, Y, W, H) which can be get and set.
  
  .. note::
     This class has a custom enumerator that will loop through the properties.

*************
Control types
*************

TextControl
-----------

.. class:: TextControl

  This class extends :class:`GuiBase.ContentControlType`
   
  .. data:: Type
   
     The type of control, contains ``"Text"``
   
ButtonControl
-----------

.. class:: ButtonControl

  This class extends :class:`GuiBase.ContentControlType`
   
  .. data:: Type
   
     The type of control, contains ``"Button"``
   
EditControl
-----------

.. class:: EditControl

  This class extends :class:`GuiBase.ContentControlType`
   
  .. data:: Type
   
     The type of control, contains ``"Edit"``
   
ListViewControl
-----------

.. class:: ListViewControl

  This class extends :class:`GuiBase.ControlType`

  .. data:: Type
   
     The type of control, contains ``"ListView"``

  .. data:: RowCount
  
     Contains the amount of rows.
     
  .. data:: ColumnCount
  
     Contains the amount of columns.
     
  .. data:: SelectedCount
  
     Contains the amount of selected rows.
     
  .. data:: ImageList
  
     Contains an :class:`GuiBase.ImageList` instance if one is assigned to the listview via ``SetImageList``.
  
  .. function:: Add(Options := "", Fields*)

     Adds a row to the listview.

     :param Options: Options string.
     :param Fields*: Variadic parameter array of field contents.

  .. function:: Insert(Row, Options := "", Fields*)

     Identical to ``Add()`` but with an additional parameter ``Row``

     :param Row: Which row to insert the new row at.
     
  .. function:: Delete(Row := "")

     Deletes one or all rows.

     :param Row: If blank all rows are deleted, otherwise the row number specified.

     :return: Selected row count of the listview.
     
  .. function:: GetSelected()

     Gets all the rows that are selected.

     :return: An array of all the row numbers that are selected.
     
  .. function:: GetChecked()

     Gets all the rows that are checked.

     :return: An array of all the row numbers that are checked.
     
  .. function:: SetImageList(ImageList)
  
     Set an imagelist for the listview.
     
     :param ImageList: An :class:`GuiBase.ImageList` instance.
     
  .. function:: GetNextSelected(Start := 0)

     Gets the next selected row after ``Start``.

     :return: Row number of the next selected row.
     
  .. function:: GetNextChecked(Start := 0)

     Gets the next checked row after ``Start``.

     :return: Row number of the next checked row.
     
  .. function:: GetNextFocused(Start := 0)

     Gets the next focused row after ``Start``.

     :return: Row number of the next focused row.

  .. function:: GetCount(Option := "")

     Calls `LV_GetCount() <https://autohotkey.com/docs/commands/ListView.htm#LV_GetCount()>`_. It is however recommended you use the methods above.
     
     :param Option: What kind of rows to count.
     :return: Amount of rows.

  .. function:: GetNext(Start := 0, Option := "")

     Calls `LV_GetNext() <https://autohotkey.com/docs/commands/ListView.htm#LV_GetNext>`_. It is however recommended you use the methods above.
     
     :param Start: Which row to start at when finding the next.
     :param Option: What kind of row to find.
     :return: Row number of the next checked or focused row.
	

StatusBarControl
-----------

.. class:: StatusBarControl

  This class extends :class:`GuiBase.ControlType`

  .. data:: Type
   
     The type of control, contains ``"StatusBar"``
  
  .. function:: SetText(NewText, PartNumber := 1, Style := "")

     Calls `SB_SetText() <https://autohotkey.com/docs/commands/GuiControls.htm#SB_SetText>`_. 

     :param NewText: New text contents.
     :param PartNumber: Which part to change to ``NewText``.
     :param Style: See the documentation link above.
	
  .. function:: SetParts(Width*)

     Calls `SB_SetParts() <https://autohotkey.com/docs/commands/GuiControls.htm#SB_SetParts>`_. 

     :param Width*: New widths of the parts.
	
  .. function:: SetParts(File, IconNumber := "", PartNumber := 1)

     Calls `SB_SetIcon() <https://autohotkey.com/docs/commands/GuiControls.htm#SB_SetIcon>`_. 

     :param File: Icon file.
     :param IconNumber: Icon number of the file.
     :param PartNumber: Which part to set the icon on.



**************
Position types
**************

WindowPosition
--------------

.. class:: WindowPosition

  This class extends :class:`GuiBase.PositionType`
  
  You can use the properties to set and get position/size of a window.
  
ControlPosition
---------------

.. class:: ControlPosition

  This class extends :class:`GuiBase.PositionType`
  
  You can use the properties to set and get position/size of a control.
  



**********
Gui events
**********

This section contains a list of all Gui events.

These methods are not supposed to be called. For a practical example of how these are used, see :doc:`examples`.

.. function:: GuiBase.Close()
   
   Called when the close button is clicked on the Gui.
   
.. function:: GuiBase.Escape()
   
   Called when the escape button is pressed while the Gui is focused.
   
.. function:: GuiBase.Size(EventInfo, Width, Height)
   
   Called when the Gui is resized.
   
   :param EventInfo: 0 if resized, 1 if minimized and 2 if maximized.
   :param Width: The new width of the Gui window.
   :param Height: The new height of the Gui window.
   
.. function:: GuiBase.DropFiles(FileArray, Control, X, Y)
   
   Called when files are dropped onto the Gui.
   
   :param FileArray: Array of files.
   :param Control: Which control the files were "dropped" onto.
   :param X: X coordinate of where the files were dropped.
   :param Y: Y coordinate.
   
.. function:: GuiBase.ContextMenu(Control, EventInfo, IsRightClick, X, Y)
   
   Called when the user right-clicks anywhere in the window except the title or menu bar.
   
   :param Control: Control which was right-clicked, if any.
   :param EventInfo: See the `documentation <https://autohotkey.com/docs/commands/Gui.htm#GuiContextMenu>`_.
   :param Height: The new height of the Gui window.



**************
Control events
**************