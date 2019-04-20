######################
Additional information
######################

The main components of the library lives under one namespace, namely ``GuiBase``.
However the library introduces a few other namespace intrusions.

Namespace reservations
======================

.. function:: Type(cls)

   This function is just a shorthand for ``cls.__Class``

   :param cls: Any class object/instance.
   :return: ``cls.__Class``
   
.. function:: IsInstance(obj, cls*)

   Similar to Pythons function of the same name.
   It returns ``true`` if the type (or technically class name) of ``obj`` matches
   any of those specified in ``cls``.

   :param obj: A class object/instance.
   :param cls: Any variadic amount of class objects/instances.
   :return: Boolean value.
   
.. function:: IndirectReferenceDelete(this)

   This function should not be touched by the user, it's used by :class:`IndirectReferenceHolder`.
   
A real world example of ``IsInstance()``

.. code-block:: ahk

   ; assume MyGui is a gui with one text control
   
   MyControl := MyGui.Controls[1] ; gets the control
   
   msgbox % IsInstance(MyControl, GuiBase.TextControl)
   ; the line above will result to true, since the control
   ; is of type GuiBase.TextControl
   
   msgbox % IsInstance(MyControl, GuiBase.ControlType)
   ; the line above will also result to true, since the
   ; control type (GuiBase.TextControl) inherit from
   ; GuiBase.ContentControlType which in turn inherit
   ; from GuiBase.ControlType
   
   msgbox % IsInstance(MyControl, GuiBase, GuiBase.ContentControlType)
   ; also true. It'll check if MyControl is an instance
   ; of GuiBase first and since it isn't, it'll continue and
   ; check the next one, which it of course is an instance of

Only one class is bundled with the library at the moment.
Currently the only usage of this class is in the constructor
of :class:`GuiBase.ControlType`.

.. class:: IndirectReferenceHolder

   This class creates an indirect reference to an object and holds the original reference itself.
   
   It uses all five meta-functions to create a layer between the actual object and what the user has access to.