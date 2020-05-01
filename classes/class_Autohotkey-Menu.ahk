; ╓───────────────────────────────────────────────────╖
; ║ Menu class for AutoHotkey                         ║
; ║ Create objects of AutoHotkey context/system menus ║
; ║ to make working withem them cleaner.              ║
; ╙───────────────────────────────────────────────────╜
;
; ╓─────────────────────────────────────────────────────────────────────────────────────╖
; ║ |                                                                                   ║
; ║ | AutoHotkey _Menu Class                                                            ║
; ║ |                                                                                   ║
; ║ |    @__New _Menu():                 Create a new Menu object                       ║
; ║ |        @USAGE:  <MENU_OBJNAME>  :=  New _Menu(  [   <MENU_NAME>                   ║
; ║ |                                                ,   <FIRST_ITEM>                   ║
; ║ |                                                ,   <FIRST_LABEL>                  ║
; ║ |                                                ,   <FIRST_OPTIONS>                ║
; ║ |                                                ,   <MENU_ICON_OPTIONS*>])         ║
; ║ |        @PARAMS:                    All PARAMS are optional and if none are        ║
; ║ |                                    provided then a "Tray" menu with a line        ║
; ║ |                                    separator is created.                          ║
; ║ |            @MENU_NAME:             The main name of the menu.                     ║
; ║ |            @FIRST_ITEM:            The first item of MENU_NAME.                   ║
; ║ |            @FIRST_LABEL:           The label or function FIRST_ITEM will call.    ║
; ║ |            @FIRST_OPTIONS:         The OPTIONS of the FIRST_ITEM's FIRST_LABEL.   ║
; ║ |            @MENU_ICON_OPTIONS:     The ICON_OPTIONS of MENU_NAME.                 ║
; ║ |                @ICON_FILE:         The icon or resource file of MENU_NAME.        ║
; ║ |                @DLL_NUMBER:        The resource number if ICON_FILE is a function ║
; ║ |                                    library file.                                  ║
; ║ |                @FREEZE_BOOL:       Freeze MENU_NAME ICON_FILE from changing on    ║
; ║ |                                    script toggle.                                 ║
; ║ |    @METHODS:                                                                      ║
; ║ |                                                                                   ║
; ║ |        @Add():                     Add ITEM_NAME along with it's corresponding    ║
; ║ |                                    LABEL_OR_MENU & any additional options &       ║
; ║ |                                    creates corresponding objects.                 ║
; ║ |            @USAGE:                 _Menu.Add(  [   <ITEM_NAME>)                   ║
; ║ |                                                ,   <LABEL_OR_MENU>                ║
; ║ |                                                ,   <OPTIONS*>  ]   )              ║
; ║ |            @PARAMS:                All PARAMS are optional & if none are          ║
; ║ |                                    passed then a normal line separator is         ║
; ║ |                                    created.                                       ║
; ║ |                @ITEM_NAME:         The menu ITEM_NAME to add to the objects menu. ║
; ║ |                @LABEL_OR_MENU:     The label, sub menu, or function that the      ║
; ║ |                                    ITEM_NAME will execute/activate.               ║
; ║ |                @OPTIONS:           Any number of options can be added. See        ║
; ║ |                                    the AutoHotkey documentation about menus.      ║
; ║ |                                                                                   ║
; ║ |        @Insert():                  Insert a NEW_ITEM above an EXISTING_ITEM.      ║
; ║ |            @USAGE:                 _Menu.Insert(   <EXISTING_ITEM>                ║
; ║ |                                                ,   <NEW_ITEM>                     ║
; ║ |                                                ,   <LABEL_OR_MENU>,[              ║
; ║ |                                                ,   <OPTIONS>   ]   )              ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @EXISTING_ITEM:     This MENU_ITEM must exist.                     ║
; ║ |                @NEW_ITEM:          Name o new MENU_ITEM to add before.            ║
; ║ |                @LABEL_OR_MENU:     The label, sub menu, or function that the      ║
; ║ |                                    MENU_ITEM will execute/activate.               ║
; ║ |                @OPTIONS:           Any number of options can be added. See        ║
; ║ |                                    the AutoHotkey documentation about menus.      ║
; ║ |                                                                                   ║
; ║ |        @Delete():                  Delete an menu ITEM_NAME & it's object.        ║
; ║ |            @USAGE:                 _Menu.Delete(   <ITEM_NAME> )                  ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @ITEM_NAME:         ITEM_NAME to delete. it delete the             ║
; ║ |                                    item and its' object.                          ║
; ║ |                                                                                   ║
; ║ |        @DeleteAll():               Delete all MENU_ITEM's & their objects.        ║
; ║ |            @USAGE:                 _Menu.DeleteAll()                              ║
; ║ |                                                                                   ║
; ║ |        @Rename():                  Rename ITEM_NAME to NEW_NAME & creates the     ║
; ║ |                                    new object & deletes the old.                  ║
; ║ |            @USAGE:                 _Menu.Rename(   <ITEM_NAME>                    ║
; ║ |                                                ,   <NEW_NAME> )                   ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @ITEM_NAME:         ITEM_NAME to rename.                           ║
; ║ |                @NEW_NAME:          NEW_NAME of the ITEM_NAME.                     ║
; ║ |                                                                                   ║
; ║ |        @Check():                   Place a check by ITEM_NAME.                    ║
; ║ |            @USAGE:                 _Menu.Check(   <ITEM_NAME> )                   ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @ITEM_NAME:         ITEM_NAME to place a check by.                 ║
; ║ |                                                                                   ║
; ║ |        @UnCheck():                 Remove check by ITEM_NAME.                     ║
; ║ |            @USAGE:                 _Menu.UnCheck(   <ITEM_NAME> )                 ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @ITEM_NAME:         ITEM_NAME to remove check from.                ║
; ║ |                                                                                   ║
; ║ |        @ToggleCheck():             Toggle check by ITEM_NAME.                     ║
; ║ |            @USAGE:                 _Menu.ToggleCheck(   <ITEM_NAME> )             ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @ITEM_NAME:         ITEM_NAME to toggle a check by.                ║
; ║ |                                                                                   ║
; ║ |        @Enable():                  Enable ITEM_NAME.                              ║
; ║ |            @USAGE:                 _Menu.Enable(   <ITEM_NAME> )                  ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @ITEM_NAME:         ITEM_NAME to enable.                           ║
; ║ |                                                                                   ║
; ║ |        @Disable():                 Disable ITEM_NAME.                             ║
; ║ |            @USAGE:                 _Menu.Disable(   <ITEM_NAME> )                 ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @ITEM_NAME:         ITEM_NAME to disable.                          ║
; ║ |                                                                                   ║
; ║ |        @TogglEnable():             Toggle enable/disable status of ITEM_NAME.     ║
; ║ |            @USAGE:                 _Menu.ToggleEnable(   <ITEM_NAME> )            ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @ITEM_NAME:         ITEM_NAME to enable/disable.                   ║
; ║ |                                                                                   ║
; ║ |        @Default():                 Set ITEM_NAME as the dfault item.              ║
; ║ |            @USAGE:                 _Menu.Default(   <ITEM_NAME> )                 ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @ITEM_NAME:         ITEM_NAME to set as default.                   ║
; ║ |                                                                                   ║
; ║ |        @NoDefault():               Remove any default ITEM_NAME.                  ║
; ║ |            @USAGE:                 _Menu.NoDefault()                              ║
; ║ |                                                                                   ║
; ║ |        @Standard():                Inserts standard menu items at the             ║
; ║ |                                    bottom of the menu.                            ║
; ║ |            @USAGE:                 _Menu.Standard()                               ║
; ║ |                                                                                   ║
; ║ |        @NoStandard():              Remove all stand menu items.                   ║
; ║ |            @USAGE:                 _Menu.Default()                                ║
; ║ |                                                                                   ║
; ║ |                                                                                   ║
; ║ |        @Icon():                    Add an icon to the menu or its' items.         ║
; ║ |            @USAGE:                 _Menu.Icon( <MENU_ITEM>                        ║
; ║ |                                            ,   <ICONV*> )                         ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @MENU_ITEM:         MENU_ITEM to add an icon to. If no             ║
; ║ |                                    MENU_ITEM is provided it defaults to           ║
; ║ |                                    TRAY.                                          ║
; ║ |                @ICONV:             Any of 1-3 possible icon params:               ║
; ║ |                    @FILE:          Icon FILE to use.                              ║
; ║ |                    @NUMBER:        Icon NUMBER of from DLL/EXE.                   ║
; ║ |                    @FRZ_WDTH:      FREEZE if TRAY (no change on script            ║
; ║ |                                    pause) or WIDTH of ICON if MENU_ITEM.          ║
; ║ |                                                                                   ║
; ║ |        @NoIcon():                  Remove ICON from MENU or MENU_ITEM.            ║
; ║ |            @USAGE:                 _Menu.NoIcon(   [<MENU_ITEM>]   )              ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @MENU_ITEM:         MENU_ITEM to remove icon from or it            ║
; ║ |                                    defaults to TRAY.                              ║
; ║ |                                                                                   ║
; ║ |        @Tip():                     ToolTip to display on main MENU hover.         ║
; ║ |            @USAGE:                 _Menu.Tip(  [<STRING>]   )                     ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @STRING:            STRING to be displayed or it is                ║
; ║ |                                    removed if no STRING is passed.                ║
; ║ |                                                                                   ║
; ║ |        @Show():                    Shows the main MENU either at the              ║
; ║ |                                    cursor or at the specified x, y                ║
; ║ |                                    coordinates.                                   ║
; ║ |            @USAGE:                 _Menu.Show( [   <X>                            ║
; ║ |                                                ,   <Y>                            ║
; ║ |                                                ,   <COORDMODE> ]   )              ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @X:                 X coordinate to show the MENU at.              ║
; ║ |                @Y:                 Y coordinate to show the MENU at.              ║
; ║ |                @COORDMODE:         Coordinates in relationship to Screen,         ║
; ║ |                                    Window, Client, or Relative.                   ║
; ║ |                                                                                   ║
; ║ |        @Color():                   Set the background COLOR of any MENU           ║
; ║ |                                    or MENU_ITEM.                                  ║
; ║ |            @USAGE:                 _Menu.Color(    [   <COLOR>                    ║
; ║ |                                                ,   <SINGLE>    ]   )              ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @COLOR:             COLOR to set. If none is given then            ║
; ║ |                                    it sets it to Windows dafault colors.          ║
; ║ |                @SINGLE:            Boolean True/1 or False/0 set the              ║
; ║ |                                    COLOR to only the first level of a             ║
; ║ |                                    MENU.                                          ║
; ║ |                                                                                   ║
; ║ |        @Click():                    Set the click COUNT of how many               ║
; ║ |                                    clicks it takes to activate/execute            ║
; ║ |                                    the MENU's default LABEL/FUNCTION.             ║
; ║ |            @USAGE:                 _Menu.Click(    [<COUNT>]   )                  ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @COUNT:             COUNT of how many clicks.                      ║
; ║ |                                                                                   ║
; ║ |        @MainWindow:                Allows TRAY click to activate the              ║
; ║ |                                    main window if the script is compiled.         ║
; ║ |            @USAGE:                 _Menu.MainWindow()                             ║
; ║ |                                                                                   ║
; ║ |        @NoMainWindow:              Disallows TRAY click to activate the           ║
; ║ |                                    main window if the script is compiled.         ║
; ║ |            @USAGE:                 _Menu.NoMainWindow()                           ║
; ║ |                                                                                   ║
; ║ |        @UseErrorLevel:             Enable/Disable throwing errors.                ║
; ║ |            @USAGE:                 _Menu.UseErrorLevel(    [<STATE>]   )          ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @STATE:             Set error throwing to "On" or "Off",           ║
; ║ |                                    defaults to "Off".                             ║
; ║ |                                                                                   ║
; ║ |        @Separator():               Create custom separator lines (like            ║
; ║ |                                    _Menu.Add() with no params, but creates        ║
; ║ |                                    it as a MENU_ITEM with a dummy label).         ║
; ║ |            @USAGE:                 _Menu.Separator(    [<OPTIONAL_STRING>]   )    ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @OPT_STRNG:         If OPTIONAL_STRING is passed it creates        ║
; ║ |                                    a MENU_ITEM with a DummyFunc; if not it        ║
; ║ |                                    a normal separator is created with             ║
; ║ |                                    _Menu.Add().                                   ║
; ║ |                                                                                   ║
; ║ |        @ArrayToString():           Returns a string from an indexed array.        ║
; ║ |            @USAGE:                 Menu.ArrayToString(    [<ARRAY_OR_STRING>] )   ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @ARRAY_STRING:      Anything passed will be returned as a string.  ║
; ║ |                                                                                   ║
; ║ |        @ThisFuncName():            Returns the last index of StrSplit with '.'.   ║
; ║ |                                    I use this to get only the method name of      ║
; ║ |                                    the object.                                    ║
; ║ |            @USAGE:                 _Menu.ThisFuncName( <METHOD_PATH>   )          ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @METHOD_PATH:       Full path of the A_ThisFunc of a class         ║
; ║ |                                    method.                                        ║
; ║ |                                                                                   ║
; ║ |        @MenuFunc_Big():            Method to execute only basic methods           ║
; ║ |                                    with a MENU_ITEM.                              ║
; ║ |            @USAGE:                 _Menu.MenuFunc_Big( <ITEM_NAME>                ║
; ║ |                                                    ,   <FUNC>)                    ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @ITEM_NAME:         MENU_ITEM to work with.                        ║
; ║ |                @FUNC:              Method to execute.                             ║
; ║ |                                                                                   ║
; ║ |        @MenuFunc_Small():          Method to execute only basic methods           ║
; ║ |                                    without a MENU_ITEM.                           ║
; ║ |            @USAGE:                 _Menu.MenuFunc_Small( <FUNC>  )                ║
; ║ |            @PARAMS:                                                               ║
; ║ |                @FUNC:              Method to execute.                             ║
; ║ |                                                                                   ║
; ║ |        @DummyFunc():               A dummy function to append to the              ║
; ║ |                                    custom separators.                             ║
; ║ |            @USAGE:                 _Menu.DummyFunc()                              ║
; ║ |                                                                                   ║
; ║ |    @OBJECTS[]:                     Ojects & keys created by this class.           ║
; ║ |        @_Menu[]:                   Objects & keys of the maine class.             ║
; ║ |            @IconObject[]:          Object of  MENUs icon.                         ║
; ║ |                @File:              Icon file path.                                ║
; ║ |                @Number:            Number of resource if file is DLL/EXE.         ║
; ║ |                @Freeze             Freeze icon from changing on script            ║
; ║ |                                    is paused.                                     ║
; ║ |            @ColorList[]:           Object of color names & their                  ║
; ║ |                                    corresponding hex values.                      ║
; ║ |                                    Find the list below at the beggining           ║
; ║ |                                    of the class.                                  ║
; ║ |            @MenuName:              Main menu name; E.g. Tray.                     ║
; ║ |            @ClickCount:            Number of clicks to activate default.          ║
; ║ |            @MenuItems[]:           Object of MENU_ITEMs & their objects.          ║
; ║ |                @Name:              MENU_ITEMs name.                               ║
; ║ |                @Label:             MENU_ITEMs LABEL_OR_MENU                       ║
; ║ |                @Options:           MENU_ITEMs OPTIONS.                            ║
; ║ |                @Checked:           State of MENU_ITEMs checked/unchecked.         ║
; ║ |                @Enabled:           State of MENU_ITEMs enabled/disabled.          ║
; ║ |                @IconObject[]:      Object of  MENU_ITEMs icon.                    ║
; ║ |                    @File:          Icon file path.                                ║
; ║ |                    @Number:        Number of resource if file is DLL/EXE.         ║
; ║ |                    @Width          Width of MENU_ITEMs icon FILE.                 ║
; ║ |            @ToolTip:               String of TRAYs ToolTip.                       ║
; ║ |            @Position[]:            Object of last position of _Menu.Show()        ║
; ║ |                @X:                 X position of last _Menu.Show() position       ║
; ║ |                @Y:                 Y position of last _Menu.Show() position       ║
; ║ |                @Mode:              CoordMode of last _Menu.Show() position        ║
; ║ |            @ColorObject[]:         Object of MENUs color settings.                ║
; ║ |                @Color:             Color value.                                   ║
; ║ |                @Level:             Single level or recurse menus.                 ║
; ║ |            @Main:                  TRAY is set to MainWindow or not.              ║
; ║ |            @UseError:              TRAY is set to UseErrorLevel or not.           ║
; ║ |                                                                                   ║
; ╙─────────────────────────────────────────────────────────────────────────────────────╜
;
; ╓───────╖
; ║ Class ║
; ╙───────╜
;
Class _Menu
{
    __New(name:="Tray",first_item:="",first_label:="",first_options:="",iconv*)
    {
        this.ColorList:=    {   Black:"0x000000" ,Silver:"0xC0C0C0" ,Gray:"0x808080" ,White:"0xFFFFFF" 
                            ,   Maroon:"0x800000" ,Red:"0xFF0000",Purple:"0x800080" ,Fuchsia:"0xFF00FF" 
                            ,   Green:"0x008000" ,Lime:"0x00FF00" ,Olive:"0x808000" ,Yellow:"0xFFFF00" 
                            ,   Navy:"0x000080" ,Blue:"0x0000FF" ,Teal:"0x008080" ,Aqua:"0x00FFFF"  }
        this.ClickCount    :=  2
        this.MenuName:=name
        if (iconv.MaxIndex())
        {   
            this.Icon(((this.MenuName!="Tray")?this.MenuName:"") ,iconv[1],iconv[2],iconv[3])
        }
        this.Add(first_item,((first_item)?first_label:""),((first_item)?first_options:""))
    }
    Add(item_name:="",label_or_menu:="",options*)
    {   
        if (! item_name)
        {
            this.MenuFunc_Small(A_ThisFunc)
            return
        }
        this.MenuItems[item_name]:= {   name:item_name
                                    ,   label:label_or_menu
                                    ,   options:this.ArrayToString(options)}
        Menu,   % this.MenuName
            ,   % this.ThisFuncName(A_ThisFunc)
            ,   % this.MenuItems[item_name].name
            ,   % this.MenuItems[item_name].label
            ,   % this.MenuItems[item_name].options
    }
    Insert(existing_item,new_item,label_or_menu,options*)
    {   
        if (this.MenuItems[existing_item].name)
        {
            this.MenuItems[new_item]:= {   name:new_item
                                            ,   label:label_or_menu
                                            ,   options:this.ArrayToString(options)}
            Menu    ,   % this.MenuName
                    ,   % this.ThisFuncName(A_ThisFunc)
                    ,   % this.MenuItems[existing_item].name
                    ,   % this.MenuItems[new_item].name
                    ,   % this.MenuItems[new_item].label
                    ,   % this.MenuItems[new_item].options         
        }

    }
    Delete(item_name)
    {
        if (this.MenuItems[item_name].name)
        {
            Menu    ,   % this.MenuName
                    ,   % this.ThisFuncName(A_ThisFunc)
                    ,   % this.MenuItems[item_name].name
            this.MenuItems[item_name]:=""
        }
    }
    DeleteAll()
    {
        Menu    ,   % this.MenuName
                ,   % this.ThisFuncName(A_ThisFunc)
    }
    Rename(item_name,new_name)
    {
        if (this.MenuItems[item_name].name)
        {
            Menu    ,   % this.MenuName
                    ,   % this.ThisFuncName(A_ThisFunc)
                    ,   % this.MenuItems[item_name].name
                    ,   % new_name
            this.MenuItems[new_name]:=this.MenuItems[item_name]
            this.MenuItems[new_name].name:=new_name
            this.MenuItems[item_name]:=""
            return this.MenuItems[item_name].name
        }
    }
    Check(item_name)
    {
        if (this.MenuItems[item_name].name)
        {
            this.MenuItems[item_name].Checked:=True
        }
        this.MenuFunc_Big(item_name,A_ThisFunc)
        return this.MenuItems[item_name].Checked
    }
    Uncheck(item_name)
    {
        if (this.MenuItems[item_name].name)
        {
            this.MenuItems[item_name].Checked:=False
        }
        this.MenuFunc_Big(item_name,A_ThisFunc)
        return this.MenuItems[item_name].Checked
    }
    ToggleCheck(item_name)
    {
        if (this.MenuItems[item_name].name)
        {
            this.MenuItems[item_name].Checked:=(!this.MenuItems[item_name].Checked)
        }
        this.MenuFunc_Big(item_name,A_ThisFunc)
        return this.MenuItems[item_name].Checked
    }
    Enable(item_name)
    {
        if (this.MenuItems[item_name].name)
        {
            this.MenuItems[item_name].Enabled:=True
        }
        this.MenuFunc_Big(item_name,A_ThisFunc)
        return this.MenuItems[item_name].Enabled
    }
    Disable(item_name)
    {
        if (this.MenuItems[item_name].name)
        {
            this.MenuItems[item_name].Enabled:=False
        }
        this.MenuFunc_Big(item_name,A_ThisFunc)
        return this.MenuItems[item_name].Enabled
    }
    ToggleEnable(item_name)
    {
        if (this.MenuItems[item_name].name)
        {
            this.MenuItems[item_name].Enabled:=(!this.MenuItems[item_name].Enabled)
        }
        this.MenuFunc_Big(item_name,A_ThisFunc)
        return this.MenuItems[item_name].Enabled
    }
    Default(item_name:="")
    {
            Menu    ,   % this.MenuName
                    ,   % this.ThisFuncName(A_ThisFunc)
                    ,   % this.MenuItems[item_name].name
    }
    NoDefault()
    {
        this.MenuFunc_Small(A_ThisFunc)
    }
    Standard()
    {
        this.MenuFunc_Small(A_ThisFunc)
    }
    NoStandard()
    {
        this.MenuFunc_Small(A_ThisFunc)
    }
    Icon(menu_item:="",iconv*)
    {   
        if (FileExist(iconv[1]))
        {   
            if (menu_item)
            {   
                if (! this.MenuItems[menu_item].name)
                {
                    return
                }
                this.MenuItems[menu_item].IconObject:={}
                this.MenuItems[menu_item].IconObject.file:=iconv[1]
                if iconv[2] is integer
                {
                    this.MenuItems[menu_item].IconObject.number:=iconv[2]    
                }
                if iconv[3] is integer
                {
                    this.MenuItems[menu_item].IconObject.width:=iconv[3]    
                }
                Menu    ,   % this.MenuName
                        ,   % this.ThisFuncName(A_ThisFunc)
                        ,   % this.MenuItems[menu_item].name
                        ,   % this.MenuItems[menu_item].IconObject.file
                        ,   % this.MenuItems[menu_item].IconObject.number
                        ,   % this.MenuItems[menu_item].IconObject.width
                return this.MenuItems[menu_item].IconObject
            }
            this.IconObject:={}
            this.IconObject   :=    {   file:iconv[1]
                                    ,   number:iconv[2]
                                    ,   freeze:iconv[3]}
            Menu    ,   % this.MenuName
                    ,   % this.ThisFuncName(A_ThisFunc)
                    ,   % this.IconObject.file
                    ,   % this.IconObject.number
                    ,   % this.IconObject.freeze
            return this.IconObject
        }     
    }
    NoIcon(menu_item:="")
    {
        if (menu_item)
        {
            if (! this.MenuItems[menu_item].name)
            {
                return
            }
            Menu    ,   % this.MenuName
                    ,   % this.ThisFuncName(A_ThisFunc)
                    ,   % this.MenuItems[menu_item].name
            this.MenuItems[menu_item].IconObject:=""
            return
        }
        this.MenuFunc_Small(A_ThisFunc)
        this.IconObject:=""
    }
    Tip(string:="")
    {
        if (string)
        {
            this.ToolTip:=string
            Menu    ,   % this.MenuName
                    ,   % this.ThisFuncName(A_ThisFunc)
                    ,   % this.ToolTip
            return this.ToolTip
        }
        this.ToolTip:=""
        this.MenuFunc_Small(A_ThisFunc)
    }
    Show(x:="",y:="",coord_mode:="Relative")
    {
        this.Position:={x:x,y:y,mode:coord_mode}
        CoordMode,Menu,% this.Position.mode
        Menu,% this.MenuName,% this.ThisFuncName(A_ThisFunc),% this.Position.x,% this.Position.y
        CoordMode,Menu,Relative
        return this.Position
    }
    Color(color:="Default",single:=False)
    {
        single:=(single?"Single":"")
        if ((color="Default" or) Or (color:=""))
        {
            this.ColorObject:=""
        }
        else if color is not xdigit
        {
            if (! this.ColorList[color])
            {
                return
            }
            this.ColorObject:=  {   color:this.ColorList[color]
                                ,   level:single}
        }
        else
        {
            this.ColorObject:=  {   color:color
                                ,   level:single}
        }
        Menu    ,   % this.MenuName
                ,   % this.ThisFuncName(A_ThisFunc)
                ,   % this.ColorObject.color
                ,   % this.ColorObject.level
        return this.ColorObject
    }
    Click(count:=2)
    {
        if count is not integer
        {
            return
        }
        if (this.MenuName!="Tray")
        {
            return
        }
        this.ClickCount:=count
        Menu    ,   % this.MenuName
                ,   % this.ThisFuncName(A_ThisFunc)
                ,   % this.ClickCount
        return this.ClickCount
    }
    MainWindow()
    {
        if (this.MenuName="Tray")
        {
            this.Main:=True
            this.MenuFunc_Small(A_ThisFunc)
            return this.Main
        }
    }
    NoMainWindow()
    {
        if (this.MenuName="Tray")
        {
            this.Main:=False
            this.MenuFunc_Small(A_ThisFunc)
            return this.Main
        }
    }
    UseErrorLevel(state:="Off")
    {
        this.UseError:=((state="Off")?"Off":"On")
        Menu    ,   % this.MenuName
                ,   % this.ThisFuncName(A_ThisFunc)
                ,   % this.UseError
        return this.UseError            
    }
    Separator(optional_string:="")
    {
        Menu    ,   % this.MenuName
                ,   Add
                ,   %optional_string%
                ,   % ((optional_string)?this.DummyFunc():"")
    }
    ArrayToString(array)
    {
        if (array.MaxIndex())
        {
            for index, item in array
            {
                string.=item A_Space
            }
        }
        return (string?string:array)
    }
    ThisFuncName(full_func_name)
    {
        fn:=StrSplit(full_func_name,".")
        return fn[fn.MaxIndex()]
    }
    MenuFunc_Big(item_name,func)
    {
        if (this.MenuItems[item_name].name)
        {
            Menu    ,   % this.MenuName
                    ,   % this.ThisFuncName(func)
                    ,   % this.MenuItems[item_name].name
        }
    }
    MenuFunc_Small(func)
    {
        Menu    ,   % this.MenuName
                ,   % this.ThisFuncName(func)
    }
    DummyFunc()
    {
        return A_ThisFunc
    }
}
;
; ╓───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╖
; ║ Excerpt information about all AutoHotkey Menu Sub Commands from the                                                                   ║
; ║ AutoHotkey Documentation.                                                                                                             ║
; ║ ;                                                                                                                                     ║
; ║ ; •Add: Adds a menu item, updates one with a new submenu or label, or converts one from a normal item into a submenu (or vice versa). ║
; ║ ; •Insert [v1.1.23+]: Inserts a new item before the specified menu item.                                                              ║
; ║ ; •Delete: Deletes the specified menu item from the menu.                                                                             ║
; ║ ; •DeleteAll: Deletes all custom menu items from the menu.                                                                            ║
; ║ ; •Rename: Renames the specified menu item.                                                                                           ║
; ║ ; •Check: Adds a visible checkmark in the menu next to the specified menu item.                                                       ║
; ║ ; •Uncheck: Removes the checkmark from the specified menu item.                                                                       ║
; ║ ; •ToggleCheck(){}: Adds a checkmark to the specified menu item; otherwise, removes it.                                               ║
; ║ ; •Enable: Enables the specified menu item if was previously disabled.                                                                ║
; ║ ; •Disable: Disables the specified menu item.                                                                                         ║
; ║ ; •ToggleEnable: Disables the specified menu item; otherwise, enables it.                                                             ║
; ║ ; •Default: Changes the menu's default item to be the specified menu item and makes its font bold.                                    ║
; ║ ; •NoDefault: Reverses setting a user-defined default menu item.                                                                      ║
; ║ ; •Standard: Inserts the standard menu items at the bottom of the menu.                                                               ║
; ║ ; •NoStandard: Removes all standard menu items from the menu.                                                                         ║
; ║ ; •Icon: Changes the script's tray icon or [in v1.0.90+] sets a icon for the specified menu item.                                     ║
; ║ ; •NoIcon: Removes the tray icon or [in v1.0.90+] removes the icon from the specified menu item.                                      ║
; ║ ; •Tip: Changes the tray icon's tooltip.                                                                                              ║
; ║ ; •Show: Displays the specified menu.                                                                                                 ║
; ║ ; •Color: Changes the background color of the menu.                                                                                   ║
; ║ ; •Click: Sets the number of clicks to activate the tray menu's default menu item.                                                    ║
; ║ ; •MainWindow: Allows the main window of a compiled script to be opened via the tray icon.                                            ║
; ║ ; •NoMainWindow: Prevents the main window of a compiled script from being opened via the tray icon.                                   ║
; ║ ; •UseErrorLevel: Skips any warning dialogs and thread terminations whenever the Menu command generates an error.                     ║
; ╙───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╜
;