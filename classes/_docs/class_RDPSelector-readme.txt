About
=====

RDPSelector utility by Clive Galway
email: evilc@evilc.com
GitHub: https://github.com/evilC

Allows rapid connection / disconnection / switching to RDP sessions.
Machines to connect to and Users to connect as can be selected from a list.

Uses my RDPConnect AHK library (Not needed if using the compiled EXE)

Usage
=====
Just run the EXE, the .ahk file is the source code.
Be sure to copy the EXE, all INI files and the powershell folder to your local hard disk.
You may need to execute "Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser" in powershell for the powershell scripts to work.
Instructions included in the GUI.

Configuration
=============
Edit the INI files as follows:

credentials.ini
---------------

[Human Friendly Name]
login=mylogin
pass=mypass
domain=mydomain

environments.ini
----------------

[Environment Name]
SomeServer1=address1.domain.local
SomeServer2=address2.domain.local

Changelog
=========

1.0 - 28/08/2015
+ Inital version

1.1 - 01/09/2015
+ Fixed indexed sparse array of hwnds bug.
Using Remove() will decrement remaining indexes, making hwnds inaccurate.
+ Fixed bug preventing multiple environment trees from rendering.

1.2 - 01/09/2015
+ If logon fails, you can launch a new session (eg with different user) without having to close the old windows.
+ Added Ctrl + Shift + Tab hotkey to instantly go to Open Sessions section.
+ If connection to a machine fails, the next time you connect to that machine,
  open login dialogs for that machine will automatically be closed.

1.3 - 01/09/2015
+ Sparse array removal bug that 1.1 attempted to fix should really be fixed now.

1.4 - 03/09/2015
+ You can now double-click listview / treeview items
+ Extra tree level for machine TreeView - "Project"
+ TFS URL is now pulled from RDPSelector.ini
+ Environments.ini is now a JSON file
+ Now uses powershell script to mark TFS environments as in-use when you open an RDP session to them.
+ (RDPConnect lib update) - The "Don't ask me again for connections to this computer" checkbox in the certificate window will be automatically ticked if it appears.