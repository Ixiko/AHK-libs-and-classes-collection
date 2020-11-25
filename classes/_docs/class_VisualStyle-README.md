# AutoHotkey Visual Style Class

**Class_VisualStyle** alows you to easily create GUIs in AutoHotkey that resemble _Aero Wizards_  
or _Task Dialog_ windows.  

<p align="center">
  <img src="https://github.com/cheshirecat1373/Class_VisualStyle/blob/master/images/Ex1.png">
</p>

It alows customization and appearance modification of controls to match the windows theme, plus much more.  

<p align="center">
  <img src="https://github.com/cheshirecat1373/Class_VisualStyle/blob/master/images/Ex2.png">
</p>  

<p align="center">
  <img src="https://github.com/cheshirecat1373/Class_VisualStyle/blob/master/images/Ex3.png">
</p>  

## Development

To get started, download or clone the repo to your computer 

**Class_VisualStyle** has two dependencies:

* UxTheme.ahk
* Const_Theme.ahk  

Both these files **must** be in the `Lib` folder along with `Class_VisualStyle.ahk`.  If done this way, you need only include the class at the top of your script without the need of including the dependencies.

<p align="center">
  <img src="https://github.com/cheshirecat1373/Class_VisualStyle/blob/master/images/CodeCloseup1.png">
</p>

### Basic Usage

The class is fairly straight forward and easy to use. View example code to get started.

```autohotkey
; Call the class
Wizard  := new VisualStyle()
; Create GUI
WizProp := Wizard.WinCreate(Caption, "Back", "Next", "ButtonCancel", icon, posX, 50, width, height, "Wiz")
```

The `WinCreate` method returns an array of handles for the GUI and its buttons. This can later be used to change the possition, appearance, and style of the window or its controls.  

<p align="center">
  <img src="https://github.com/cheshirecat1373/Class_VisualStyle/blob/master/images/Ex4.png">
</p>

### Class_VisualStyle Available Methods

The following is a list of availabe methods to use with **Class_VisualStyle**.

```text
WinCreate - (Creates either an Aero Wizard or TaskDialog style GUI)
WinShow - (Shows the Window - Same as Gui, Show)
PagingCreate - (Creates number of pages passed for an Aero Wizard)
PageAdd - (Adds a page to the Wizard)
PageChoose - (Choose the page number passed)
GetFontProperties - (Retrieves the Theme Font properties to use)
GetWinColor - (Retrieves the color for a themed window)
GetTextExtent - (Retrieves the extent of text for sizing)
DrawBackground - (Draws the theme background for window or controls)
CommandLink - (Creates a commandlink button)
CommandLinkSetNote - (Sets the commandlink button note)
CommandLinkSetText - (Sets the commandlink button caption text)
CommandLinkGetNoteLength - (Gets the commandlink button note lenth)
CommandLinkGetNote - (Gets the commandlink button note)
ButtonSetImage - (Sets the image for a button)
ButtonSetElevationRequiredState - (Sets the elevation icon for a button)
ProgBarSetState - (Sets the state of a ProgressBar control)
TVSetExtendedStyle - (Sets the extended style for a TreeView control)
TVSetIndent - (Sets the indent for nodes in a TreeView)
TVSetTextColor - (Sets the text color in a TreeView)
TVSetBKColor - (Sets the background color of a TreeView)
SetCueBannerText - (Sets the cuebanner text in an Edit control)
ContentLink - (Create a Conententlink control)
GetErrorString - (Retrieves verbose error message string for debugging)
```

### UxTheme Available Functions

The following is a list of availabe functions in the **UxTheme** library.  
For more information on these functions visit [Microsoft - UxTheme][1].

[1]: https://docs.microsoft.com/en-us/windows/win32/api/uxtheme/

```text
UxTheme_Init
UxTheme_GetCurrentThemeName
UxTheme_SetThemeAppProperties
UxTheme_OpenThemeData
UxTheme_OpenThemeDataEx
UxTheme_CloseThemeData
UxTheme_SetWindowTheme
UxTheme_GetWindowTheme
UxTheme_GetThemeSysColor
UxTheme_GetThemePartsize
UxTheme_GetThemeSysColorBrush
UxTheme_GetThemeColor
UxTheme_GetThemeTextExtent
UxTheme_GetThemeSysFont
UxTheme_GetThemeFont
UxTheme_SetWindowThemeAttribute
UxTheme_DrawThemeText
UxTheme_DrawThemeTextEx
UxTheme_DrawThemeBackground
UxTheme_DrawThemeBackgroundEx
UxTheme_DrawThemeParentBackground
UxTheme_DrawThemeParentBackgroundEx
UxTheme_DrawThemeIcon
UxTheme_BufferedPaintInit
UxTheme_BufferedPaintUnInit
UxTheme_BeginBufferedPaint
UxTheme_EndBufferedPaint
UxTheme_BufferedPaintSetAlpha
UxTheme_GetThemeBackgroundContentRect
UxTheme_GetThemeRect
UxTheme_GetThemeBackgroundExtent
UxTheme_IsThemeActive
UxTheme_IsCompositionActive
UxTheme_IsAppThemed
UxTheme_IsThemeDialogTextureEnabled
UxTheme_IsThemeBackgroundPartiallyTransparent
UxTheme_EnableThemeDialogTexture
```
