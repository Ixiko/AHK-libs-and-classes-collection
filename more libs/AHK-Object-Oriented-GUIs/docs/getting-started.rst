###############
Getting Started
###############

It is recommended you have some prior experience working with Guis in AutoHotkey, as this library builds upon existing functionality

Installation
============

1. Download or clone the repository at https://github.com/Run1e/AHK-Object-Oriented-GUIs
2. Copy the ``gui`` folder into your project
3. Include the library in your project by doing ``#Include gui\GuiBase.ahk``

Testing installation
====================

Here's a small snippet you can try to check if your installation was successful:

.. code-block:: ahk

   MyGui := new GuiBase("Title", "-MinimizeBox")
   MyGui.AddButton("w200", "Button Text")
   MyGui.Show()

It will create and show a small, simplistic GUI consisting of a single button.