/*
Title: TAB Library v0.1 (Preview)

Group: Introduction

    This library adds functionality to AutoHotkey-created tab controls.

Group: AutoHotkey Compatibility

    This library is designed to run on all versions of AutoHotkey v1.1+: ANSI,
    Unicode, and Unicode 64-bit.

Group: Common Parameters

    Common function parameters of note.

    hTab:

    The handle to a tab control.  This is the de facto first parameter for most
    of the library functions.  It is critical to the success of the library.  So
    much so, that it's value is usually not tested.  If hTab contains an invalid
    value, most of the library functions will fail.  Most tab control messages
    will set ErrorLevel to FAIL if hTab does not contain a valid handle to a tab
    control.

    If the integrity of hTab is important/critical for a particular task or
    event, use <TAB_IsTabControl> to test the value.

    iTab:

    The 1-based index of a tab in a tab control.  This is an integer value
    from 1 to the total number of tabs in the tab control.

    hIL:

    The handle to an image list.

    iIL:

    The 1-based index of the image in the image list.  This is an integer value
    from 1 to the total number of images in the image list.

Group: Terminology

    The terminology created to describe the components, characteristics, and
    conditions of the tab control is not always intuitive and can be ambigious.
    The following are a few of the terms used in this library.

    Button - If the TCS_BUTTONS style is used, tabs appear as buttons.  Also
        known as "button mode".

    Display Area - The area of each tab where the application displays the
        current page.  This area will typically contain a group of controls
        that relate to the tab name.

    Focus [Definition 1] - Input focus, also known as keyboard focus.  Keyboard
        focus determines which window or control will receive information typed
        at the keyboard.  If the tab control has keyboard focus, the Left and
        Right keys can be used to navigate between the tab pages.  See the
        <Keyboard Navigation> topic for more information.

    Focus [Definition 2] - Tab focus.  See the <Tab Focus> topic for more
        information.

    Item - This term is synonymous with "tab".  Every tab control can have
        multiple items, i.e. tabs.   This term is used frequently in this
        library.

    Label - This term is synonymous with "name" and "text".  It is used
        occasionally in this library but it is used infrequently or not at all
        in the AutoHotkey and Microsoft documentation.

    Name - AutoHotkey's term for the tab's label.  It is used sporadically
        throughout this library.  See the "Text" definition for more
        information.

    Page - This term is synonymous with "tab" and "item".

    Select(ed) - For the user, the "selected" tab is the active tab.  The
        display area will typically contain information that relates to the tab
        name.  For the developer, use <TAB_GetCurSel> to determine the selected
        tab.

    Tab - A page within a tab control.  Also known as an "item".  Each tab can
        be assigned a label and an icon.

    Text - The string of characters that each tab shows as a label.  AutoHotkey
        uses the terms "name" or "tab names" instead.

Group: Issues and Considerations

    A few issues and considerations.

    Topic: AutoHotkey Only

        Although most of the functions in this library will work on any tab
        control, this library is designed to work with the tab controls created
        by AutoHotkey.  They may not work as expected if used on other tab
        controls.

    Topic: DPI-Aware

        The functions in this library are not DPI-aware.  Specified position and
        size values are used as-is and the values returned from library
        functions are not adjusted to reflect a non-standard screen DPI.

        Starting with AutoHotkey v1.1.11, a "DPIScale" option was added for
        AutoHotkey GUIs which makes most "gui" commands DPI-aware.  Although the
        AutoHotkey "gui" commands will not interfere with with any of the
        library commands (and vice versa), the size and position used by each
        may be incompatible when used on a computer that is using a non-standard
        DPI.  The DPIScale feature is enabled by default so if necessary, it
        must be explicitly disabled for each GUI.  Ex: gui -DPIScale.

    Topic: Focus on Button Down

        Adding the TCS_FOCUSONBUTTONDOWN style to an AutoHotkey-created tab
        control provides no value because AutoHotkey overrides the effects of
        this style by setting input focus on the first control within the tab as
        soon as the tab is selected.  To get the same/similar affect as the
        TCS_FOCUSONBUTTONDOWN style, call <TAB_SetInputFocus> immediately after
        a tab has been selected with a mouse click.

    Topic: Font

        The font used by the tab control should be set before the tab control is
        created.  This will ensure that the size of each tab is set correctly.
        Small changes to the font -- small size changes or a different font with
        a similar font size -- can be made after the tab control has been
        created without any difficulty but significant changes can affect the
        number of tab rows and might require that some or all of the GUI
        controls to be repositioned.  Any changes to the font after the tab
        control is showing will require that the tab control be repositioned
        and/or resized.  See the <Reposition, Resize, and Redraw> topic for more
        information.

    Topic: Icons

        Each tab in a tab control can have an icon associated with it.  However,
        the icon is not shown if the tab control has the TCS_OWNERDRAWFIXED
        style.

        If the developer independently adds the TCS_OWNERDRAWFIXED style to the
        tab control to support other capabilities (Ex: colored tabs), code to
        draw the icon (and text if needed) must be included in the function that
        is created to monitor the WM_DRAWITEM message.  See the
        <Owner-Drawn Tabs> topic for more information.

        The TCS_OWNERDRAWFIXED style is sometimes automatically added by
        AutoHotkey to support other AutoHotkey features (Ex: text color,
        background color, etc.).  When this occurs, the developer has the
        following options:

          * Do nothing.  The icon will not be drawn.
          * Write the necessary code to independently draw the icon and text in
            each tab.
          * Remove the feature that is causing the TCS_OWNERDRAWFIXED style to
            be added (Ex: text color).  The icon will be drawn because the
            TCS_OWNERDRAWFIXED style is no longer added by AutoHotkey.
          * Remove the TCS_OWNERDRAWFIXED style immediately after the tab
            control is created.  The icon will be drawn because the
            TCS_OWNERDRAWFIXED style has been removed.  The feature that caused
            the TCS_OWNERDRAWFIXED style to be added in the first place (Ex:
            text color) will not work on the tab control but it will continue to
            be applied to the window and/or other controls.

    Topic: Image List

        If the tabs will have an icon, the image list that contains the icons
        should be associated with the tab control before GUI controls are added
        to the tab control.  See the <Icons and Image Lists> topic for more
        information.

    Topic: Keyboard Navigation

        There are a number of built-in keyboard shortcuts that can be used
        to navigate between the pages of the tab control.  These keyboards
        shortcuts are delivered in pairs.  One of the keyboard shortcuts will
        navigate to the "next" tab and the other will navigate to the "previous"
        tab.  It is unclear which of these keyboard shortcuts are native to the
        tab control and which have been added and/or have been enhanced by
        AutoHotkey.  This topic will discuss the keyboard shortcuts and issues
        that are available to the tab controls created by AutoHotkey.

        Keyboard Shortcuts:

        If a tab control has input focus (the user may have to click on the
        selected tab again to get input focus), the Left and Right keys can be
        used to navigate between the pages of the tab control.

        The Ctrl+PgDn and Ctrl+PgUp keys can be use to navigate from page to
        page in a tab control.  Unlike the Left and Right keys, navigation for
        these keys are circular.  If on the first/last tab, selection will
        continue around to the last/first tab, depending on the key.

        The Ctrl+Tab and Ctrl+Shift+Tab keys operate the same as the Ctrl+PgDn
        and Ctrl+PgUp keys except that they will not work if the currently
        focused control is a multi-line Edit control.

        Note: These keyboard shortcuts work as defined but they often work even
        if extra modifiers are being held down.  For example, Ctrl+PgDn is the
        primary keyboard shortcut but the Ctrl+Shift+PgDn, Ctrl+Win+PgDn, and
        Ctrl+Shift+Win+PgDn keyboard shortcuts will do the same thing.  If
        creating replacement hotkeys, be sure to include all possible key
        combinations or include the wildcard modifier when defining the hotkey.
        Ex: *^PgDn::

        Idiosyncrasies:

        The Ctrl+PgDn, Ctrl+PgDn, Ctrl+Tab, and Ctrl+Shift+Tab keyboard
        shortcuts will navigate from page to page in the tab control even if
        keyboard focus is on a control that does not belong to a tab control.
        If the window has more than one tab control, the first tab control will
        be navigated.

        If desired, this idiosyncrasy can be fixed by creating replacement
        hotkeys in the script.  With some additional code, the hotkeys can
        determine if and when to perform the requested action.

        Selection Notifications:

        In most cases, the TCN_SELCHANGING notification is sent immediately
        before the tab is selected and TCN_SELCHANGE notification is sent
        immediately after the tab is selected.  However, when keyboard
        navigation is used to select a tab, these notifications are not sent.
        This is usually not a problem in most cases but if the developer is
        monitoring these notifications, it quickly becomes an issue.  Creating a
        workaround to deal with the problem can be tricky.

        One approach is to stop the user from using the keyboard to select a
        tab.  The TCS_FOCUSNEVER style will stop the tab control from getting
        focus from the mouse so that the Left and Right keys cannot be used to
        select a tab.  For the other keyboard shortcuts, do-nothing replacement
        hotkeys can be added to script to ensure that the user cannot use
        keyboard shortcuts to select a tab.

        A better approach might be to create replacement hotkeys that call
        library functions to select the tabs.  The <TAB_SelectItem>,
        <TAB_SelectNext> and <TAB_SelectPrev> functions will send the the
        TCN_SELCHANGING and TCN_SELCHANGE notifications when appropriate.

    Topic: Minimum Windows Version

        The tab control is a part of the common control library (ComCtl32.dll).
        This library was introduced in Windows 3.1 but it did not come into it's
        own until Windows 95.  Most of the major changes to the tab control were
        made in v4.70 of ComCtl32.dll (Windows 95 OSR2) but small changes have
        been made here and there throughout the life of the common control
        library.

        The Microsoft documentation makes it difficult to identify when a
        feature (function, message, style, etc.) was introduced because the
        "minimum version" for the feature is actually the earliest version of a
        "supported" version of Windows which may or may not be when the feature
        was introduced.  At this writing, the minimum supported version of
        Windows for the tab control is Windows Vista.  Most, if not all, of the
        messages, styles, and notification codes used in this library "should"
        work on Windows 2000 or later but Windows Vista is officially the
        earliest version of Windows that is supported.

    Topic: Owner-Drawn Tabs

        AutoHotkey-created tab controls include a lot of built-in
        functionality.  In order to get the tab control to work with Windows
        features (Ex: themes) or other AutoHotkey features (Ex: text color),
        AutoHotkey will automatically add or remove the TCS_OWNERDRAWFIXED style
        when the tab control is created.

        If AutoHotkey automatically adds the TCS_OWNERDRAWFIXED style to support
        other AutoHotkey features (Ex: text color), only the AutoHotkey
        documented features are supported when drawing the tabs.  For example,
        the tab will show the blue text defined earlier (Ex: "gui Font,cBlue")
        but the icon added by this library is not drawn because tab control
        icons are not officially supported by AutoHotkey.

        If the TCS_OWNERDRAWFIXED style is needed for other reasons, the
        developer may need to add the style after the tab control is created.
        The developer then becomes responsible for drawing the tabs.  If the
        TCS_OWNERDRAWFIXED style was added by AutoHotkey to support other
        features (Ex: text color), the developer must duplicate those features
        (or choose to ignore them) if they wish to make other changes to the
        tab.

        The Tab3 control is especially vulnerable.  AutoHotkey includes a lot
        of theme-related features that are lost when the TCS_OWNERDRAWFIXED
        style is included.  Even then, the built-in features may interfere with
        changes made by the developer.  Thorough testing is a must.  Retesting
        is recommended when changes or bug fixes are made to the Tab3 control.

    Topic: Reset/Refresh

        Some of the functions in this library can change the appearance of the
        tab control.  The tab control will often respond automatically and no
        additional action is necessary but other times, the tab control must be
        instructed to reset/refresh.  See the <Reposition, Resize, and Redraw>
        topic for more information.

    Topic: Selection Notifications

        To aid the developer, two notifications are (or should be) sent when a
        new/different tab is selected.  The TCN_SELCHANGING notification is used
        to notify the tab control's parent window that the currently selected
        tab is about to change.  The TCN_SELCHANGE notification is used to
        notify the tab control's parent window that the currently selected tab
        has changed.

        Support for these notifications (especially TCN_SELCHANGE) is critical
        to the success of a tab control.  AutoHotkey automatically monitors
        these notifications for tab controls created using the "gui
        Add,Tab[2|3]" command.  In response to the TCN_SELCHANGE notification,
        AutoHotkey shows the controls associated with the selected tab and calls
        the subroutine or function associated with the tab control if a g-label
        has been set.

        Developer Action:

        For the script developer, the TCN_SELCHANGING and TCN_SELCHANGE
        notifications can be useful in other ways.

        When the TCN_SELCHANGING notification is sent immediately before a new
        tab is selected, the developer can save the contents of the current tab
        page or perform some other actions related to the about-to-change tab
        page.  This notification can also be used to stop the selection from
        occurring.  For example, if the contents of the tab page contain invalid
        data, the TCN_SELCHANGING notification can be rejected and the user is
        shown an error message.  See the example scripts for an example on how
        to do this.

        The TCN_SELCHANGE notification is sent immediately after a tab has been
        selected.  Monitoring for the TCN_SELCHANGE notification is usually
        unnecessary because the subroutine or function associated with the tab
        control is called when a tab is selected.  If the developer wants to
        perform action when a tab is selected, they can simply attach a
        subroutine or function to the tab control via the g-label option.
        Warning: Be careful about performing commands that change the tab
        selection from this subroutine/function.  Although unlikely, it can
        trigger an infinite loop.

        Issues:

        Although AutoHotkey responds correctly when the TCN_SELCHANGING and
        TCN_SELCHANGE notifications are sent, these notifications are not always
        sent when a tab is selected.  When this occurs, any code that is
        monitoring these notifications does not run.  This is especially
        problematic for the TCN_SELCHANGING notification.

        _Keyboard Shortcuts_

        All native and AutoHotkey-enhanced keyboard shortcuts that select the
        next or previous tabs (Left, Right, Ctrl+PgUp, Ctrl+PgDn, etc.) do not
        send the TCN_SELCHANGING and TCN_SELCHANGE notifications when a tab is
        selected.  However, if a subroutine or function is attached to the tab
        control, it is triggered correctly in all cases.

        _Choose and ChooseString_

        If the tab control does _not_ have the TCS_BUTTONS style, the Choose
        command (Ex: GUIControl Choose,%hTab%,3) and the ChooseString command
        (Ex: GUIControl ChooseString,%hTab%,MyTabName) work as expected.  The
        TCN_SELCHANGING and TCN_SELCHANGE notifications are sent and if the tab
        number or tab name is preceded with a pipe character (Ex: GUIControl
        Choose,%hTab%,|3), the subroutine or function associated with the tab
        control is called.  However, if tab control has the TCS_BUTTONS style,
        the Choose and ChooseString commands do _not_ work as expected.
        Although the tab is selected correctly, The TCN_SELCHANGING and
        TCN_SELCHANGE notifications are not sent and the subroutine or function
        associated with the tab control is not called regardless of if the tab
        number or tab name is preceded with a pipe character.

        _TabLeft and TabRight_

        The TabLeft and TabRight options of the Control command (Ex: Control
        TabLeft,1) do not work as expected.

        If the tab control does _not_ have the TCS_BUTTONS style, the tab is
        selected and the subroutine or function associated with the tab control
        is called.  However, the TCN_SELCHANGING and TCN_SELCHANGE notifications
        are not sent.

        If the tab control has the TCS_BUTTONS style, nothing works as expected.
        The tab is not selected, the TCN_SELCHANGING and TCN_SELCHANGE
        notifications are not sent, and the subroutine or function associated
        with the tab control is not called.  Hint: Never use these commands if
        the tab has the TCS_BUTTONS style.

        Workarounds:

        If the developer needs to monitor the TCN_SELCHANGING and TCN_SELCHANGE
        notifications, calling selection commands from this library instead of
        AutoHotkey commands will resolve most of the issues.

        For issues related to AutoHotkey commands, the <TAB_SelectItem> function
        is a good alternative.  This function will send the the TCN_SELCHANGING
        and TCN_SELCHANGE notifications when appropriate.  The <TAB_SelectNext>
        and <TAB_SelectPrev> functions call the <TAB_SelectItem> function so
        they can also be used.

        If only monitoring the TCN_SELCHANGE notification or
        if triggering the subroutine/function associated with the tab control is
        critical, calling <TAB_NotifySelChange> at the appropriate time may
        resolve the problem.  This function will send the TCN_SELCHANGE
        notification.  In response to this notification, AutoHotkey will trigger
        the subroutine/function associated with the tab control.

        Fixing issues related to keyboard shortcuts may just be a matter of
        creating hotkeys to override the default functionality.  See the
        <Keyboard Navigation> topic for more information.

    Topic: Tab Focus

        Preface: This topic is about "Tab Focus".  Tab focus is not the same
        thing as input focus, i.e. keyboard focus.

        "Focus" is one of two conditions a tab in a tab control can have.  The
        other is "Selected".  A tab can:

            * be selected.  Only one tab can be the currently selected tab.
            * have focus.  Only one tab can have tab focus.
            * be selected and have focus.
            * be none of the above, i.e. not selected and not have focus.

        For the developer, identifying which tab has focus and/or is selected is
        easy.  Use <TAB_GetCurFocus> to get the tab that has focus and
        <TAB_GetCurSel> to get the tab that is selected.

        To the user, there is only one condition: Selected.  A tab is either
        selected or it's not.  The user does not know (or care) that the
        selected tab also has focus.  If the tab control has the TCS_BUTTONS and
        TCS_MULTISELECT styles, selection and focus can be separated but the
        user will still not have any way to know which button has focus.

        Focus is a necessary condition of the tab control but it is rarely set
        or changed except when a tab is selected.  The Microsoft documentation
        doesn't even mention it except for the TCM_GETCURFOCUS and
        TCM_SETCURFOCUS messages.  The AutoHotkey documentation doesn't mention
        it at all.  Finding any discussion on the interwebs (other than for the
        TCM_GETCURFOCUS and TCM_SETCURFOCUS messages) is next to impossible
        because nothing exists.  Update: Nope, there's still nothing.

Group: Icons and Image Lists

    Each item in a tab control can have an icon associated with it, which is
    specified by an index in the image list for the tab control.  This library
    includes a number of functions for managing the images and image lists
    used with a tab control.

    Image List:

    When a tab control is created, it has no image list associated with it.  If
    system small or system large icons are desired, the AutoHotkey <IL_Create at
    https://autohotkey.com/docs/commands/ListView.htm#IL_Create> can be used to
    create an image list.  Otherwise, <TAB_CreateImageList> can be used to
    create an image list with icons of any size.

    Adding and Removing Images:

    Images can be added to a tab control's image list in same manner as any
    image list.  The AutoHotkey <IL_Add at
    https://autohotkey.com/docs/commands/ListView.htm#IL_Add> command works fine
    in most cases.  Other programs may work better in some cases.  However,
    images should be removed from the image list by using <TAB_RemoveImage>
    instead of the system *ImageList_Remove* function.  <TAB_RemoveImage> uses
    the TCM_REMOVEIMAGE message which will ensure that each item remains
    associated with the same image as before.  There are restrictions.  See the
    documentation in <TAB_RemoveImage> for more information.

    Assigning:

    The image list is assigned to the tab control with <TAB_SetImageList>.
    Assigning an image list to the tab control can change the size of the tabs
    which in turn can change the size of the display area.  When possible,
    <TAB_SetImageList> should be called before GUI controls are added to any of
    the tabs.

    To retrieve the handle to the image list currently associated with a tab
    control, use <TAB_GetImageList>.

    Housekeeping:

    Destroying a tab control does not destroy the image list that is associated
    with it.  The image list must be destroyed separately.  This can be useful
    if an image list is assigned to multiple tab controls.  If needed, use
    <IL_Destroy at https://autohotkey.com/docs/commands/ListView.htm#IL_Destroy>
    to destroy the image list.

Group: Reposition, Resize, and Redraw

    Tab controls are complex GUI objects.  A tab control created by AutoHotkey
    can be even more complex because additional controls and/or processing is
    included to get the control to work with other GUI controls and to help the
    developer implement the control without including a lot of extra script
    code.

    Most of the problems encountered while using a tab control have to do with
    the position, size, and/or appearance of the elements of a tab control and
    what happens when these elements are added, changed, or removed.  If the
    size of the tab/buttons change, this can include the position of the GUI
    controls that are added to each item in a tab control.

    This library includes functions that can change the position, size, and/or
    appearance of a tab control.  These changes may require the tab control to
    respond appropriately so that everything is shown correctly.  For many
    changes, the tab control responds automatically and no additional action is
    needed.  For a few library functions however, some additional action is
    needed depending on the type of tab control.

    The following are possible actions for getting the tab control to correctly
    set the position, size, and appearance of all elements.

    Redraw:

    (start code)
    WinSet Redraw,,ahk_id %hTab%
    (end)

    The standard *Redraw* command can resolve small appearance issues with the
    Tab2 control but it can cause all kinds of havoc with the Tab and Tab3
    controls.  In general, the Redraw command should be avoided.

    Reset:

    (start code)
    GUIControl,,%hTab%
    (end)

    This do-nothing command effectively informs the tab control that changes may
    have been made and so _most_ tab elements are repositioned, resized, and/or
    redrawn.  This command resolves most of the display issues may occur after
    changes are made with some of the library functions.  If the tab control is
    showing, the user may see a small flicker when this command is executed.

    Hint: This method works on all AutoHotkey-created tab controls but it is
    especially beneficial for the Tab3 control which potentially has the largest
    number of issues that can be caused by changes made by this library.

    Resize:

    (start code)
    GUIControl Move,%hTab1%,w351  ;-- Current width plus 1 pixel
    GUIControl Move,%hTab1%,w350  ;-- Restore to the original size
    (end)

    These commands change the size of a tab control forcing the control to
    reposition, resize, and redraw all elements.  This approach appears to
    resolve all of the display issues that may occur after changes are made with
    some of the library functions.  If the tab control is showing, the user may
    see a flicker when these commands are executed.

    Hint: Although very effective, this solution should only be used when the
    the other options (especially *Reset*) don't fix the problem.

    Sequence of Commands:

    Problems can occur because commands that can affect the position, size, or
    appearance of the tooltip control are not performed in the correct sequence.
    For example, assigning an image list to to a tab control can affect the size
    of the tabs and so performing this task before GUI controls are added to the
    tabs is usually recommended.  Performing tasks that can change the position,
    size, and/or appearance of things before the tab control's parent window is
    shown may also solve some of the problems.

    Hint: Even when the commands are performed in the correct sequence,
    sometimes the control (especially the Tab3 control) needs to be reset in
    order to get everything to display correctly.

Group: Tooltips

    The tab control can show a unique tooltip for each item in the tab control.
    This library includes a number of functions to help manage the tasks
    required to get this feature to work.

    Tooltip Control:

    AutoHotkey does not include the TCS_TOOLTIPS style by default when a tab
    control is created.  If the developer adds this style when the tab control
    is created, the operating system will automatically create a tooltip control
    and attach it to the tab control.  Adding or removing the TCS_TOOLTIPS style
    after the tab control has been created doesn't do anything.

    If needed, use <TAB_GetTooltips> get the handle to the tooltip control that
    is attached to the tab control.  This function can also be used to
    determine if a tooltip control is attached to a tab control.

    Custom Tooltip Control:

    To manually attach a custom tooltip control to the tab control, use
    <TAB_SetTooltips>.  This can be performed even if the TCS_TOOLTIPS style was
    included when the tab control was created.  If a custom tooltip control is
    the objective, the tab control should be created without the TCS_TOOLTIPS
    style.

    A custom tooltip control must be in a particular format in order to work
    correctly with a tab control.  The <TAB_Tooltips_Create> function can be
    used to create a custom tooltip control for a tab control or it can be used
    as a template for a custom function.

    Static vs. Dynamic:

    By default, tooltips for the tab control are designed to be dynamic.  When
    the user hovers the pointer over a tab, the tab control sends a
    TTN_GETDISPINFO notification to the parent window.  If the developer wants a
    tooltip to be displayed when this occurs, the WM_NOTIFY message must be
    monitored with a trap for the TTN_GETDISPINFO notification.  If the
    notification is for a tab that the developer wants to provide a tooltip, the
    notification is updated with the tooltip text and the user sees the tooltip.
    These type of tooltips are designed for tooltips that include dynamic text.
    For example, text that includes the current time, data from a dynamic
    database, et. al.  Otherwise, they are a pain to program and monitoring
    messages will eat up some CPU although it's minimal.  See the example
    scripts for an example on how to create and update dynamic tooltips. Hint:
    Tooltips should be shown very quickly so any request that takes more than a
    few milliseconds to build should not be used.

    Static tooltips are just that, static.  Use <TAB_Tooltips_SetText> to create
    a static tooltip for a tab.  Once set, the tooltip remains the same until it
    is changed or removed with another call to <TAB_Tooltips_SetText>.
    Monitoring for TTN_GETDISPINFO notifications is not necessary if the
    tooltips for all tabs contains static text.

    Tooltips for a tab control can be a mix of static and dynamic.  When the
    tooltip control is initially created, the tooltips for all tabs are set to
    send a TTN_GETDISPINFO notification to the parent window.  If
    <TAB_Tooltips_SetText> is used to update the tooltip for one of the tabs,
    that tooltip becomes static but the tooltips for the other tabs remain
    dynamic, i.e. the TTN_GETDISPINFO notification is still sent to the parent
    window for those tabs.  To change a static tooltip back into a dynamic
    tooltip, simply call <TAB_Tooltips_SetText> and set the p_Text parameter
    to null.

    Other Tooltip Functions:

    The <TAB_Tooltips_Deactivate> function will disable the tooltip control so
    that no tooltips are shown while the control is disabled.  The
    <TAB_Tooltips_Activate> function will (re)enable the tooltip control so that
    tooltips are shown.  The <TAB_Tooltips_SetTitle> function can be used to set
    or remove a title and icon for the tooltips.  The <TAB_Tooltips_GetText>
    function can be used to get the tooltip text for a tab.

    Other Tooltips:

    Tooltips for the controls within each item in a tab control can be added
    using a custom function.  The AutoHotkey forum has several examples.  The
    "AddTooltip" function is often used.

    Housekeeping:

    A tab control that has the TCS_TOOLTIPS style creates a tooltip control when
    it is created and destroys the tooltip control when it is destroyed.  Even
    if the tooltip control is replaced with a custom tooltip control, the
    original tooltip control is destroyed when the tab control is destroyed.

    A custom tooltip control created via the <TAB_Tooltips_Create> function is
    destroyed when the tab control's parent window is destroyed because the
    tooltip control is owned by the parent window.  Any other custom tooltip
    control may need to be destroyed independently, depending on how it was
    created.

Group: References

    Documentation:

    Tab Controls (AutoHotkey)
    * <https://autohotkey.com/docs/commands/GuiControls.htm#Tab>

    About Tab Controls
    * <https://msdn.microsoft.com/en-us/library/windows/desktop/bb760550(v=vs.85).aspx>

    Tab Control Messages
    * <https://msdn.microsoft.com/en-us/library/windows/desktop/ff486047(v=vs.85).aspx>

    Tab Control Styles
    * <https://msdn.microsoft.com/en-us/library/windows/desktop/bb760549(v=vs.85).aspx>

    Tab Control Styles (AutoHotkey)
    * <https://autohotkey.com/docs/misc/Styles.htm#Tab>
    
    Tab Control Notifications
    * <https://msdn.microsoft.com/en-us/library/windows/desktop/ff486048(v=vs.85).aspx>

    Related Libraries/Posts:

    [stdLib] better Tab control with icons etc
    * <https://autohotkey.com/board/topic/49122-stdlib-better-tab-control-with-icons-etc/>

    [LIB] TC_EX ; Some functions for AHK GUI Tab2 controls
    * <https://autohotkey.com/boards/viewtopic.php?f=6&t=1271>

Group: Credit and Thanks

    Credit and thanks to *lexikos* the development of the Tab3 control
    [v1.1.23.00] and for the help resolving some of the position and sizing
    issues and to *Chris* and everyone else involved with the development of the
    Tab and Tab2 control.  The AutoHotkey-created tab controls are far from
    perfect and there is room for improvement they have a substantial amount of
    build-in functionality that makes it easy for the developer to implement
    without a lot of extra script code.

Group: Functions
*/
;------------------------------
;
; Function: TAB_CreateImageList
;
; Description:
;
;   Create a new image list.
;
; Parameters:
;
;   p_Width, p_Height - See the *Image Size* section for more information.
;
;   p_Initial - The number of images that the image list initially contains.
;       [Optional]  If unspecified, the default is 10.
;
;   p_Grow - The number of images by which the image list can grow when the
;       system needs to make room for new images.  [Optional]  If unspecified,
;       the default is 10.
;
;   p_Flags - A set of bit flags that specify the type of image list to create.
;       This parameter can be a combination of the <Image List Creation Flags at
;       http://tinyurl.com/yd4cgowz>.  If not specified, p_Flags are set to
;       ILC_MASK|ILC_COLOR32 which are the same flags used by the AutoHotkey
;       <IL_Create at
;       https://autohotkey.com/docs/commands/ListView.htm#IL_Create> command.
;
; Returns:
;
;   The handle to the new image list (tests as TRUE) if successful, otherwise
;   FALSE.
;
; Image Size:
;
;   The p_Width and p_Height parameters are used to specify the size (in pixels)
;   of the images in the image list.  If the p_Height parameter is not specified
;   or null, it is set to the value of p_Width.
;
;   Alternatively, these parameters can be set to "Small" for the system small
;   icon size or "Large" for the system large icon size.  If an invalid string
;   is specified, the size of the system small icon is used.
;
;   Hint: If p_Width and p_Height are both set to the same size (Ex: "Large"),
;   just set p_Width to the desired size and leave p_Height undefined.  When
;   this is done, p_Height will automatically be set to the value of p_Width.
;
; Remarks:
;
;   The image list created by this function remains in memory until it is
;   destroyed.  See the <Icons and Image Lists> topic for more information.
;
;   The default values for the p_Initial and p_Grow parameters are arbitrary.
;   Be sure to set to specific values if needed.
;
;-------------------------------------------------------------------------------
TAB_CreateImageList(p_Width:="Small",p_Height:="",p_Initial:=10,p_Grow:=10,p_Flags="")
    {
    Static Dummy75976751

          ;-- Imagelist creation flags
          ,ILC_COLOR        :=0x0
          ,ILC_MASK         :=0x1
          ,ILC_COLOR4       :=0x4
          ,ILC_COLOR8       :=0x8
          ,ILC_COLOR16      :=0x10
          ,ILC_COLOR24      :=0x18
          ,ILC_COLOR32      :=0x20
          ,ILC_COLORDDB     :=0xFE
          ,ILC_PALETTE      :=0x800     ;-- Not implemented
          ,ILC_MIRROR       :=0x2000
          ,ILC_PERITEMMIRROR:=0x8000
          ,ILC_ORIGINALSIZE :=0x10000   ;-- Vista+

    ;-- Parameters
    if p_Width is not Integer
        if (p_Width="Large")
            SysGet p_Width,11       ;-- SM_CXICON: Width of the large icon, in pixels
         else  ;-- everything else
            SysGet p_Width,49       ;-- SM_CXSMICON: Width of the small icon, in pixels

    if p_Height is Space  ;-- Null/blank or unspecified
        p_Height:=p_Width
     else
        if p_Height is not Integer
            if (p_Height="Large")
                SysGet p_Height,12  ;-- SM_CYICON: Height of the large icon, in pixels
             else  ;-- everything else
                SysGet p_Height,50  ;-- SM_CYSMICON: Height of the small icon, in pixels

    if p_Initial is not Integer
        p_Initial:=10

    if p_Grow is not Integer
        p_Grow:=10

    if p_Flags is not Integer
        p_Flags:=ILC_MASK|ILC_COLOR32

    ;-- Create image list
    hIL:=DllCall("ImageList_Create"
        ,"Int",p_Width                  ;-- cx (The width, in pixels, of each image)
        ,"Int",p_Height                 ;-- cy (The height, in pixels, of each image)
        ,"UInt",p_Flags                 ;-- flags
        ,"Int",p_Initial                ;-- cInitial
        ,"Int",p_Grow                   ;-- cGrow
        ,"Ptr")                         ;-- Return type

    ;-- Return the handle to the image list
    Return hIL
    }

;------------------------------
;
; Function: TAB_DeleteAllItems
;
; Description:
;
;   Remove all items from a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   This function will remove all items (i.e. tabs) from a tab control but it
;   does not remove the GUI sub-controls that were associated to the items.  See
;   the AutoHotkey documentation for more information.
;
;-------------------------------------------------------------------------------
TAB_DeleteAllItems(hTab)
    {
    Static TCM_DELETEALLITEMS:=0x1309                   ;-- TCM_FIRST + 9
    SendMessage TCM_DELETEALLITEMS,0,0,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? False:ErrorLevel
    }

;------------------------------
;
; Function: TAB_DeleteItem
;
; Description:
;
;   Remove an item from a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 for the first
;       tab, 2 for the second tab, and so on.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   This function will remove an item (i.e. "tab") from a tab control but it
;   does not remove the sub-controls that were associated to the item.  See the
;   AutoHotkey documentation for more information.
;
;-------------------------------------------------------------------------------
TAB_DeleteItem(hTab,iTab)
    {
    Static TCM_DELETEITEM:=0x1308                       ;-- TCM_FIRST + 8
    SendMessage TCM_DELETEITEM,iTab-1,0,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? False:ErrorLevel
    }

;------------------------------
;
; Function: TAB_DeselectAll
;
; Description:
;
;   Reset items in a tab control, clearing any that were set to the
;   TCIS_BUTTONPRESSED state.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   p_Flag - Flag that specifies the scope of the item deselection.  If set to
;       FALSE (the default), all tab items will be reset.  If set to TRUE, all
;       tab items except for the one currently selected will be reset.
;
; Returns:
;
;   No return value.
;
; Remarks:
;
;   This message is only useful if the TCS_BUTTONS style has been set.
;
;   On a tab control created by AutoHotkey, the first item is selected by
;   default.  The developer can change the default by using the "||" syntax in
;   the list of tab labels or include the Choose option.  However, there appears
;   to be no way to have no tabs selected.  For the standard tab control, this
;   makes sense but for a "buttons" tab control, this can be an issue.  The
;   TCM_DESELECTALL message is one of the few ways to change the tab control so
;   that no tabs are selected.  Note: If a button is selected when this message
;   is sent _and_ the button is unselected as a result, the TCN_SELCHANGING and
;   TCN_SELCHANGE notifications are sent to the parent window.  For tab controls
;   created by AutoHotkey, this will also trigger the subroutine that is
;   associated with the tab control if any.
;
;-------------------------------------------------------------------------------
TAB_DeselectAll(hTab,p_Flag:=False)
    {
    Static TCM_DESELECTALL:=0x1332                      ;-- TCM_FIRST + 50
    SendMessage TCM_DESELECTALL,p_Flag,0,,ahk_id %hTab%
    }

;------------------------------
;
; Function: TAB_FindText
;
; Description:
;
;   Find an item with specified text.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   p_Text - Text to search for.
;
; Returns:
;
;   The 1-based index of the first tab with the specified text (tests as TRUE),
;   otherwise 0 (tests as FALSE).
;
; Calls To Other Functions:
;
; * <TAB_GetItemCount>
;
; Remarks:
;
;   The search is successful when the text in an item matches the leading part of
;   the text in the p_Text parameter.  The search is not case sensitive.  This
;   search method is similar to the AutoHotkey "GUIControl ChooseString"
;   command.
;
;   It is possible for 2 or more tabs to have the exact same label (text) so
;   even when the exact text is provided, only first tab with specified text is
;   returned.
;
;---------------------------------------------------------------------------
TAB_FindText(hTab,p_Text)
    {
    Static Dummy88459233
          ,MAX_TEXT:=512  ;-- Size in TCHARS

          ;-- Mask
          ,TCIF_TEXT      :=0x1
          ,TCIF_IMAGE     :=0x2
          ,TCIF_PARAM     :=0x8
          ,TCIF_RTLREADING:=0x4
          ,TCIF_STATE     :=0x10

          ;-- Messages
          ,TCM_GETITEMA:=0x1305                         ;-- TCM_FIRST + 5
          ,TCM_GETITEMW:=0x133C                         ;-- TCM_FIRST + 60

    ;-- Initialize
    VarSetCapacity(TCITEM,A_PtrSize=8 ? 40:28,0)
    VarSetCapacity(l_Text,MAX_TEXT*(A_IsUnicode ? 2:1),0)
    NumPut(TCIF_TEXT,TCITEM,0,"UInt")                   ;-- mask
    NumPut(&l_Text,  TCITEM,A_PtrSize=8 ? 16:12,"Ptr")  ;-- pszText
    NumPut(MAX_TEXT, TCITEM,A_PtrSize=8 ? 24:16,"Int")  ;-- cchTextMax

    ;-- Search through the tabs until found
    Loop % TAB_GetItemCount(hTab)
        {
        SendMessage A_IsUnicode ? TCM_GETITEMW:TCM_GETITEMA,A_Index-1,&TCITEM,,ahk_id %hTab%
        VarSetCapacity(l_Text,-1)
        if (InStr(l_Text,p_Text)=1)
            Return A_Index
        }

    Return 0
    }

;------------------------------
;
; Function: TAB_GetCurFocus
;
; Description:
;
;   Get the 1-based index of the item that has the focus in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
; Returns:
;
;   The 1-based index of the tab item that has the focus (test as TRUE),
;   otherwise 0 (tests as FALSE).
;
; Remarks:
;
;   The item that has the focus may be different than the selected item.
;
;-------------------------------------------------------------------------------
TAB_GetCurFocus(hTab)
    {
    Static TCM_GETCURFOCUS:=0x132F                      ;-- TCM_FIRST + 47
    SendMessage TCM_GETCURFOCUS,0,0,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? 0:(ErrorLevel<<32>>32)+1
        ;-- Convert UInt to Int
    }

;------------------------------
;
; Function: TAB_GetCurSel
;
; Description:
;
;   Get the currently selected item in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
; Returns:
;
;   The 1-based index of the selected tab (tests as TRUE) if successful,
;   otherwise 0 (tests as FALSE) if no tabs are selected or if there was a
;   problem.
;
; Remarks:
;
;   If the +AltSubmit option was included when the tab control was created, the
;   *GUIControlGet* command can be used instead.  For example:
;
;   (start code)
;   GUIControlGet iTab,,%hTab%
;   (end)
;
;   The *ControlGet* command can also be used instead.  For example :
;
;   (start code)
;   ControlGet iTab,Tab,,,ahk_id %hTab%
;   (end)
;
;-------------------------------------------------------------------------------
TAB_GetCurSel(hTab)
    {
    Static TCM_GETCURSEL:=0x130B                        ;-- TCM_FIRST + 11
    SendMessage TCM_GETCURSEL,0,0,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? 0:(ErrorLevel<<32>>32)+1
        ;-- Convert UInt to Int
    }

;------------------------------
;
; Function: TAB_GetDisplayArea
;
; Description:
;
;   Get the position and size of the display area of the tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   X, Y, W, H - Output variables. [Optional]  See the *Remarks* section for
;       more information.
;
; Calls To Other Functions:
;
; * <TAB_GetDisplayRect>
;
; Remarks:
;
;   The X and Y output variables contain the coordinates of the display area of
;   the tab control relative to the client area of the parent window.  The W and
;   H output variables contain the size of the display area.  This information
;   can be used by the AutoHotkey "gui" commands when adding or repositioning
;   GUI controls in a tab.
;
;-------------------------------------------------------------------------------
TAB_GetDisplayArea(hTab,ByRef X:="",ByRef Y:="",ByRef W:="",ByRef H:="")
    {
    ;-- Copy RECT from TAB_GetDisplayRect to local RECT
    VarSetCapacity(RECT,16,0)
    DllCall("CopyRect"
        ,"Ptr",&RECT                                    ;-- lprcDst
        ,"Ptr",TAB_GetDisplayRect(hTab))                ;-- lprcSrc

    ;-- Convert to client-area coordinates
	DllCall("MapWindowPoints"
        ,"Ptr",hTab                                     ;-- hWndFrom
        ,"Ptr",DllCall("GetParent","Ptr",hTab,"Ptr")    ;-- hWndTo
        ,"Ptr",&RECT                                    ;-- lpPoints
        ,"UInt",2)                                      ;-- cPoints

    ;-- Populate output variables
    X:=NumGet(RECT,0,"Int")                             ;-- left
    Y:=NumGet(RECT,4,"Int")                             ;-- top
    W:=NumGet(RECT,8,"Int")-NumGet(RECT,0,"Int")        ;-- right - left
    H:=NumGet(RECT,12,"Int")-NumGet(RECT,4,"Int")       ;-- bottom - top
    return
    }

;------------------------------
;
; Function: TAB_GetDisplayRect
;
; Description:
;
;   Get the tab control's display area rectangle.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   r_Left..r_Bottom - [Optional] Output variables that contains the display
;       rectangle for the specified tab.
;
; Returns:
;
;   The address to a RECT structure that contains the rectangle for the tab
;   control's display area.
;
; Calls To Other Functions:
;
; * <TAB_GetItemRect>
; * <TAB_GetRowCount>
; * <TAB_GetStyle>
;
; Credit:
;
;   AutoHotkey source code
;
; Remarks:
;
;   In most cases, the display area values are derived from the TCM_ADJUSTRECT
;   message.  However, when the TCS_BUTTONS style is used, the TCM_ADJUSTRECT
;   message can be unreliable.  When the TCS_VERTICAL or TCS_BOTTOM styles are
;   also used, the TCM_ADJUSTRECT message is very unreliable (read: useless).
;   This function duplicates the steps used by AutoHotkey to calculate the
;   display area of the tab control.
;
;   The display area rectangle contains coordinates relative to the tab control.
;   If needed, use <TAB_GetDisplayArea> for coordinates relative to the client
;   area of the parent window.
;
;-------------------------------------------------------------------------------
TAB_GetDisplayRect(hTab,ByRef r_Left:="",ByRef r_Top:="",ByRef r_Right:="",ByRef r_Bottom:="")
    {
    Static Dummy12451202
          ,RECT

          ;-- Styles
          ,TCS_BOTTOM  :=0x2
          ,TCS_RIGHT   :=0x2
          ,TCS_VERTICAL:=0x80
          ,TCS_BUTTONS :=0x100

          ;-- Message
          ,TCM_ADJUSTRECT:=0x1328                       ;-- TCM_FIRST + 40

    ;-- Initialize
    l_Style:=TAB_GetStyle(hTab)

    ;-- Begin with the coordinates of a tab control's client area
    VarSetCapacity(RECT,16,0)
	DllCall("GetClientRect","Ptr",hTab,"Ptr",&RECT)

    ;[============]
    ;[  Standard  ]
    ;[============]
    if not (l_Style & TCS_BUTTONS)  ;-- Not button mode
        {
        ;-- Get the display area of the tab control
        SendMessage TCM_ADJUSTRECT,False,&RECT,,ahk_id %hTab%

        ;-- Extract and update values from RECT structure
        r_Left  :=NumGet(RECT,0,"Int")-2
            ;-- Testing shows that X (but not Y) is off by exactly 2.
        r_Top   :=NumGet(RECT,4,"Int")
        r_Right :=NumGet(RECT,8,"Int")
        r_Bottom:=NumGet(RECT,12,"Int")

        ;-- Update RECT strucutre
        NumPut(r_Left,RECT,0,"Int")

        ;-- Return address to RECT structure
        Return &RECT
        }

    ;[===============]
    ;[  Button mode  ]
    ;[===============]
    ;-- Extract values from RECT structure
    r_Left  :=NumGet(RECT,0,"Int")
    r_Top   :=NumGet(RECT,4,"Int")
    r_Right :=NumGet(RECT,8,"Int")
    r_Bottom:=NumGet(RECT,12,"Int")

    ;-- Get the bounding rectangle for the first button
    TAB_GetItemRect(hTab,1,ItemRECT_Left,ItemRECT_Top,ItemRECT_Right,ItemRECT_Bottom)

    l_ButtonGap:=3  ;-- The gap between buttons seems to be 3 pixels.
    if (l_Style & TCS_VERTICAL)
        {
        l_Width:=(ItemRECT_Right-ItemRECT_Left+l_ButtonGap)*TAB_GetRowCount(hTab)
        if (l_Style & TCS_RIGHT)
            r_Right-=l_Width
         else
            r_Left+=l_Width
        }
     else  ;-- not Vertical
       {
       l_Height:=(ItemRECT_Bottom-ItemRECT_Top+l_ButtonGap)*TAB_GetRowCount(hTab)
       if (l_Style & TCS_BOTTOM)
            r_Bottom-=l_Height
        else
            r_Top+=l_Height
        }

    ;-- Load output variables back to RECT structure
    NumPut(r_Left,  RECT,0,"Int")
    NumPut(r_Top,   RECT,4,"Int")
    NumPut(r_Right, RECT,8,"Int")
    NumPut(r_Bottom,RECT,12,"Int")

    ;-- Return address to RECT structure
    Return &RECT
    }

;------------------------------
;
; Function: TAB_GetImageList
;
; Description:
;
;   Get the image list associated with a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
; Returns:
;
;   The handle to the image list (tests as TRUE) if successful, otherwise 0
;   (tests as FALSE).
;
;-------------------------------------------------------------------------------
TAB_GetImageList(hTab)
    {
    Static TCM_GETIMAGELIST:=0x1302                     ;-- TCM_FIRST + 2
    SendMessage TCM_GETIMAGELIST,0,0,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? 0:ErrorLevel
    }

;------------------------------
;
; Function: TAB_GetItemCount
;
; Description:
;
;   Get the number of tabs in the tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
; Returns:
;
;   The number of tab items (tests as TRUE) if successful, otherwise 0 (tests
;   as FALSE).
;
;-------------------------------------------------------------------------------
TAB_GetItemCount(hTab)
    {
    Static TCM_GETITEMCOUNT:=0x1304                     ;-- TCM_FIRST + 4
    SendMessage TCM_GETITEMCOUNT,0,0,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? 0:ErrorLevel
    }

;------------------------------
;
; Function: TAB_GetItemHeight
;
; Description:
;
;   Get the height of a tab in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 (the default)
;       for the first tab, 2 for the second tab, and so on.
;
; Returns:
;
;   The height of the specified tab.
;
;-------------------------------------------------------------------------------
TAB_GetItemHeight(hTab,iTab:=1)
    {
    Static TCM_GETITEMRECT:=0x130A                      ;-- TCM_FIRST + 10
    VarSetCapacity(RECT,16,0)
    SendMessage TCM_GETITEMRECT,iTab-1,&RECT,,ahk_id %hTab%
    Return NumGet(RECT,12,"Int")-NumGet(RECT,4,"Int")   ;-- Bottom - Top
    }

;------------------------------
;
; Function: TAB_GetItemRect
;
; Description:
;
;   Get the bounding rectangle for a tab in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 (the default)
;       for the first tab, 2 for the second tab, and so on.
;
;   r_Left..r_Bottom - [Optional] Output variables that contains the bounding
;       rectangle for the specified tab.
;
; Returns:
;
;   The address to a RECT structure that contains the bounding rectangle.
;
;-------------------------------------------------------------------------------
TAB_GetItemRect(hTab,iTab:=1,ByRef r_Left:="",ByRef r_Top:="",ByRef r_Right:="",ByRef r_Bottom:="")
    {
    Static Dummy75028900
          ,RECT

          ;-- Message
          ,TCM_GETITEMRECT:=0x130A                      ;-- TCM_FIRST + 10

    ;-- Get item RECT
    VarSetCapacity(RECT,16,0)
    SendMessage TCM_GETITEMRECT,iTab-1,&RECT,,ahk_id %hTab%

    ;-- Populate the output variables
    r_Left  :=NumGet(RECT,0,"Int")
    r_Top   :=NumGet(RECT,4,"Int")
    r_Right :=NumGet(RECT,8,"Int")
    r_Bottom:=NumGet(RECT,12,"Int")
    Return &RECT
    }

;------------------------------
;
; Function: TAB_GetItemWidth
;
; Description:
;
;   Get the width of a tab in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 (the default)
;       for the first tab, 2 for the second tab, and so on.
;
; Returns:
;
;   The width of the specified tab.
;
;-------------------------------------------------------------------------------
TAB_GetItemWidth(hTab,iTab:=1)
    {
    Static TCM_GETITEMRECT:=0x130A                      ;-- TCM_FIRST + 10
    VarSetCapacity(RECT,16,0)
    SendMessage TCM_GETITEMRECT,iTab-1,&RECT,,ahk_id %hTab%
    Return NumGet(RECT,8,"Int")-NumGet(RECT,0,"Int")    ;-- Right - Left
    }

;------------------------------
;
; Function: TAB_GetIcon
;
; Description:
;
;   Get the 1-based index of the image in the tab control's image list that is
;   assigned to the tab.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 for the first
;       tab, 2 for the second tab, and so on.
;
; Returns:
;
;   The 1-based image index (test as TRUE) or 0 (test as FALSE) if there is
;   no image for the tab.
;
;-------------------------------------------------------------------------------
TAB_GetIcon(hTab,iTab)
    {
    Static Dummy18408860

          ;-- Mask
          ,TCIF_TEXT      :=0x1
          ,TCIF_IMAGE     :=0x2
          ,TCIF_PARAM     :=0x8
          ,TCIF_RTLREADING:=0x4
          ,TCIF_STATE     :=0x10

          ;-- Messages
          ,TCM_GETITEMA:=0x1305                         ;-- TCM_FIRST + 5
          ,TCM_GETITEMW:=0x133C                         ;-- TCM_FIRST + 60

    VarSetCapacity(TCITEM,A_PtrSize=8 ? 40:28,0)
    NumPut(TCIF_IMAGE,TCITEM,0,"UInt")                  ;-- mask
    SendMessage A_IsUnicode ? TCM_GETITEMW:TCM_GETITEMA,iTab-1,&TCITEM,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? 0:NumGet(TCITEM,A_PtrSize=8 ? 28:20,"Int")+1
        ;-- iImage
    }

;------------------------------
;
; Function: TAB_GetPos
;
; Description:
;
;   Gets the position and size of the tab control.  See the *Remarks*
;   section for more information.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   X, Y, W, H - Output variables. [Optional]  If defined, these variables
;       contain the coordinates of the tab control relative to the
;       client-area of the parent window (X and Y), and the width and height of
;       the tab control (W and H).
;
; Remarks:
;
;   This function returns values similar to the AutoHotkey
;   *GUIControlGet,OutputVar,Pos* command.  The coordinates values (i.e. X and
;   Y) are relative to the parent window's client area.  However, this function
;   is not DPI-aware and so the returned values are actual values, not
;   calculated values based on the current screen DPI.  This function will
;   return the same values as the *GUIControlGet,OutputVar,Pos* command if the
;   "-DPIScale" option was specified when the GUI was created or if the computer
;   is currently using the default DPI setting, i.e. 96 DPI.
;
;   If the tab control was created using the AutoHotkey "gui Add" command
;   and the "-DPIScale" option is specified, the *GUIControlGet* command can be
;   used instead.  The <ControlGetPos at
;   https://autohotkey.com/docs/commands/ControlGetPos.htm> and <WinGetPos at
;   https://autohotkey.com/docs/commands/WinGetPos.htm> commands are not
;   DPI-aware and so if only interested in the width and/or height values, these
;   commands can be used on all tab controls.  Hint: The native AutoHotkey
;   commands are more efficient and should be used whenever possible.
;
;-------------------------------------------------------------------------------
TAB_GetPos(hTab,ByRef X:="",ByRef Y:="",ByRef W:="",ByRef H:="")
    {
    ;-- Initialize
    VarSetCapacity(RECT,16,0)

    ;-- Get the dimensions of the bounding rectangle of the tab control
    DllCall("GetWindowRect","Ptr",hTab,"Ptr",&RECT)
    W:=NumGet(RECT,8,"Int")-NumGet(RECT,0,"Int")        ;-- W=right-left
    H:=NumGet(RECT,12,"Int")-NumGet(RECT,4,"Int")       ;-- H=bottom-top

    ;-- Convert the screen coordinates of the tab control to client-area
    ;   coordinates.  Note: The API reads and updates the first 8-bytes of the
    ;   RECT structure.
    DllCall("ScreenToClient"
        ,"Ptr",DllCall("GetParent","Ptr",hTab,"Ptr")
        ,"Ptr",&RECT)

    ;-- Update output variables
    X:=NumGet(RECT,0,"Int")                             ;-- left
    Y:=NumGet(RECT,4,"Int")                             ;-- top
    }


;------------------------------
;
; Function: TAB_GetRowCount
;
; Description:
;
;   Gets the current number of rows of tabs in a tab control.
;
; Returns:
;
;   The number of rows of tabs (tests as TRUE) if successful, otherwise 0
;   (tests as FALSE).
;
; Remarks:
;
;   Only tab controls that have the TCS_MULTILINE style can have multiple rows
;   of tabs.  For tab controls created by AutoHotkey, the TCS_MULTILINE style
;   is included by default.  If needed, use the "-Wrap" option to remove this
;   style.
;
;-------------------------------------------------------------------------------
TAB_GetRowCount(hTab)
    {
    Static TCM_GETROWCOUNT:=0x132C                      ;-- TCM_FIRST + 44
    SendMessage TCM_GETROWCOUNT,0,0,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? 0:ErrorLevel
    }

;------------------------------
;
; Function: TAB_GetState
;
; Description:
;
;   Get the state of an item in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 for the first
;       tab, 2 for the second tab, and so on.
;
; Returns:
;
;   The tab state (can be 0).
;
; Remarks:
;
;   See the function's static variables for a list of possible states.
;
;-------------------------------------------------------------------------------
TAB_GetState(hTab,iTab)
    {
    Static Dummy33291926

          ;-- Mask
          ,TCIF_TEXT      :=0x1
          ,TCIF_IMAGE     :=0x2
          ,TCIF_PARAM     :=0x8
          ,TCIF_RTLREADING:=0x4
          ,TCIF_STATE     :=0x10

          ;-- States
          ,TCIS_BUTTONPRESSED:=0x1
          ,TCIS_HIGHLIGHTED  :=0x2

          ;-- Messages
          ,TCM_GETITEMA:=0x1305                         ;-- TCM_FIRST + 5
          ,TCM_GETITEMW:=0x133C                         ;-- TCM_FIRST + 60

    ;-- Initialize
    l_StateMask:=TCIS_BUTTONPRESSED|TCIS_HIGHLIGHTED

    ;-- Get state
    VarSetCapacity(TCITEM,A_PtrSize=8 ? 40:28,0)
    NumPut(TCIF_STATE, TCITEM,0,"UInt")                 ;-- mask
    NumPut(l_StateMask,TCITEM,8,"UInt")                 ;-- dwStateMask
    SendMessage A_IsUnicode ? TCM_GETITEMW:TCM_GETITEMA,iTab-1,&TCITEM,,ahk_id %hTab%
    Return NumGet(TCITEM,4,"UInt")                      ;-- dwState
    }

;------------------------------
;
; Function: TAB_GetStyle
;
; Description:
;
;   Returns an integer that represents the styles currently set for the tab
;   control.
;
; Remarks:
;
;   See <References> for a link to a complete list of tab control styles.
;
;-------------------------------------------------------------------------------
TAB_GetStyle(hTab)
    {
    ControlGet l_Style,Style,,,ahk_id %hTab%
    Return l_Style
    }

;------------------------------
;
; Function: TAB_GetText
;
; Description:
;
;   Get the text for an item in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 for the first
;       tab, 2 for the second tab, and so on.
;
; Returns:
;
;   The text of the specified tab.  This value can be null.  Null is also
;   returned if there was a problem.
;
; Remarks:
;
;   To get the text of the selected tab, use <TAB_GetCurSel> to identify the
;   selected tab.  For example :
;
;   (start code)
;   Text:=TAB_GetText(hTab,TAB_GetCurSel(hTab))
;   (end)
;
;   If the +AltSubmit option was _not_ included when the tab control was
;   created, the *GUIControlGet* command can be used get the text of the tab
;   that is currently selected.  For example:
;
;   (start code)
;   GUIControlGet Text,,%hTab%
;   (end)
;
;-------------------------------------------------------------------------------
TAB_GetText(hTab,iTab)
    {
    Static Dummy18408860
          ,MAX_TEXT:=512  ;-- Size in TCHARS

          ;-- Mask
          ,TCIF_TEXT      :=0x1
          ,TCIF_IMAGE     :=0x2
          ,TCIF_PARAM     :=0x8
          ,TCIF_RTLREADING:=0x4
          ,TCIF_STATE     :=0x10

          ;-- Messages
          ,TCM_GETITEMA:=0x1305                         ;-- TCM_FIRST + 5
          ,TCM_GETITEMW:=0x133C                         ;-- TCM_FIRST + 60

    VarSetCapacity(TCITEM,A_PtrSize=8 ? 40:28,0)
    VarSetCapacity(l_Text,MAX_TEXT*(A_IsUnicode ? 2:1),0)
    NumPut(TCIF_TEXT,TCITEM,0,"UInt")                   ;-- mask
    NumPut(&l_Text,  TCITEM,A_PtrSize=8 ? 16:12,"Ptr")  ;-- pszText
    NumPut(MAX_TEXT, TCITEM,A_PtrSize=8 ? 24:16,"Int")  ;-- cchTextMax
    SendMessage A_IsUnicode ? TCM_GETITEMW:TCM_GETITEMA,iTab-1,&TCITEM,,ahk_id %hTab%
    VarSetCapacity(l_Text,-1)
    Return l_Text
    }

;------------------------------
;
; Function: TAB_GetTooltips
;
; Description:
;
;   Get the handle to the tooltip control associated with a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
; Returns:
;
;   The handle to the tooltip control (tests as TRUE) if successful, otherwise
;   0 (tests as FALSE).
;
;-------------------------------------------------------------------------------
TAB_GetTooltips(hTab)
    {
    Static TCM_GETTOOLTIPS :=0x132D                     ;-- TCM_FIRST + 45
    SendMessage TCM_GETTOOLTIPS,0,0,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? 0:ErrorLevel
    }

;------------------------------
;
; Function: TAB_HasFocus
;
; Description:
;
;   Determines if the tab control has functional input focus, i.e. keyboard
;   focus.
;
; Returns:
;
;   TRUE if the tab control has keyboard focus, otherwise FALSE.
;
; Credit:
;
;   Adapted from an example in the AutoHotkey documentation.
;
; Remarks:
;
;   This function should not be confused with <TAB_GetCurFocus> which will
;   determine which item (i.e. tab) has the focus in a tab control.
;
;-------------------------------------------------------------------------------
TAB_HasFocus(hTab)
    {
    Static Dummy59216982
          ,GUITHREADINFO

          ;-- Create and initialize GUITHREADINFO structure
          ,sizeofGUITHREADINFO:=(A_PtrSize=8) ? 72:48
          ,Dummy1:=VarSetCapacity(GUITHREADINFO,sizeofGUITHREADINFO,0)
          ,Dummy2:=NumPut(sizeofGUITHREADINFO,GUITHREADINFO,0,"UInt")

    ;-- Collect GUI Thread Info
    if not DllCall("GetGUIThreadInfo","UInt",0,"Ptr",&GUITHREADINFO)
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            DllCall to "GetGUIThreadInfo" API failed. A_LastError=%A_LastError%
           )

        Return False
        }

    Return (hTab=NumGet(GUITHREADINFO,(A_PtrSize=8) ? 16:12,"Ptr"))
        ;-- hwndFocus
    }

;------------------------------
;
; Function: TAB_HighlightItem
;
; Description:
;
;   Set the highlight state of an item in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 for the first
;       tab, 2 for the second tab, and so on.
;
;   p_Highlight - Highlight state.  Set to TRUE (the default) to highlight the
;       tab.  Set to FALSE to set the tab to the default state.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   In Comctl32.dll version 6.0, this message has no visible effect when a theme
;   is active.
;
; Observations:
;
;   By default, the Tab and Tab2 controls do not use the desktop theme but the
;   Tab3 control does.
;
;   If the tab control does not use a theme, either by default or with the
;   -Theme option, the entire tab is is modified when highlighted.  The user
;   will notice that the tab is highlighted.
;
;   If the tab control uses a theme, either by default or with the +Theme
;   option, only the icon is modified.  The icon is blended with the system
;   highlight color so that it looks selected.  If the icon is small, the user
;   may not notice the change.  If the tab does not have an icon, the user will
;   not see any change when highlighted.
;
;-------------------------------------------------------------------------------
TAB_HighlightItem(hTab,iTab,p_Highlight:=True)
    {
    Static TCM_HIGHLIGHTITEM :=0x1333                   ;-- TCM_FIRST + 51
    SendMessage TCM_HIGHLIGHTITEM,iTab-1,p_Highlight,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? False:ErrorLevel
    }

;------------------------------
;
; Function: TAB_HitTest
;
; Description:
;
;   Determine which tab, if any, is at a specified screen position.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   X, Y - Position to hit test, in client coordinates.
;
;   r_Flags - [Output, Optional] - Variable that receives the results of a hit
;       test. See the function's static variable for a list of possible values.
;
; Returns:
;
;   If there is a tab at the specified screen position, the 1-based index of the
;   tab (tests as TRUE) is returned, otherwise 0 (tests as FALSE) is returned.
;
;-------------------------------------------------------------------------------
TAB_HitTest(hTab,X,Y,ByRef r_Flags)
    {
    Static Dummy71348165

          ;-- Hit flags
          ,TCHT_NOWHERE:=0x1
                ;-- The position is not over a tab.

          ,TCHT_ONITEMICON:=0x2
                ;-- The position is over a tab's icon.

          ,TCHT_ONITEMLABEL:=0x4
                ;-- The position is over a tab's text.

          ,TCHT_ONITEM:=TCHT_ONITEMICON|TCHT_ONITEMLABEL
                ;-- A bitwise-OR operation on TCHT_ONITEMICON and
                ;   TCHT_ONITEMLABEL.

          ;-- Message
          ,TCM_HITTEST:=0x130D                          ;-- TCM_FIRST + 13

    VarSetCapacity(TCHITTESTINFO,12,0)
    NumPut(X,TCHITTESTINFO,0,"Int")                     ;-- POINT.x
    NumPut(Y,TCHITTESTINFO,4,"Int")                     ;-- POINT.y
    SendMessage,TCM_HITTEST,0,&TCHITTESTINFO,,ahk_id %hTab%
    r_Flags:=NumGet(TCHITTESTINFO,8,"UInt")             ;-- flags
    Return ErrorLevel="FAIL" ? 0:(ErrorLevel<<32>>32)+1
        ;-- Convert UInt to Int
    }

;------------------------------
;
; Function: TAB_InsertItem
;
; Description:
;
;   Insert a new item in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of the new tab in the tab control.  Set to any
;       large number (Ex: 999) to insert the new tab at the end of the tab
;       control.
;
;   p_Text - The tab's text (label).
;
;   iIL - The 1-based index of the image in the image list that is associated
;       with the tab control.  Set to 0 for no icon.
;
; Returns:
;
;   The 1-based index of the new tab (tests as TRUE) if successful, otherwise 0
;   (tests as FALSE).
;
; Remarks:
;
;   For tab controls created by AutoHotkey, this function can interfere with the
;   operation of the tab control.  See the AutoHotkey documentation for more
;   information.
;
;-------------------------------------------------------------------------------
TAB_InsertItem(hTab,iTab:=999,p_Text:="",iIL:=0)
    {
    Static Dummy54230476

          ;-- Mask
          ,TCIF_TEXT      :=0x1
          ,TCIF_IMAGE     :=0x2
          ,TCIF_PARAM     :=0x8
          ,TCIF_RTLREADING:=0x4
          ,TCIF_STATE     :=0x10

          ;-- Messages
          ,TCM_INSERTITEMA:=0x1307                      ;-- TCM_FIRST + 7
          ,TCM_INSERTITEMW:=0x133E                      ;-- TCM_FIRST + 62

    ;-- Initialize
    l_Mask:=0

    ;-- Create and populate TCITEM structure
    VarSetCapacity(TCITEM,A_PtrSize=8 ? 40:28,0)
    if StrLen(p_Text)
        {
        l_Mask|=TCIF_TEXT
        NumPut(&p_Text,TCITEM,A_PtrSize=8 ? 16:12,"Ptr")
            ;-- pszText
        }

    if iIL  ;-- Not blank/null or 0
        {
        l_Mask|=TCIF_IMAGE
        NumPut(iIL-1,TCITEM,A_PtrSize=8 ? 28:20,"Ptr")  ;-- iImage
        }

    NumPut(l_Mask,TCITEM,0,"UInt")                      ;-- mask

    ;-- Insert item
    SendMessage A_IsUnicode ? TCM_INSERTITEMW:TCM_INSERTITEMA,iTab-1,&TCITEM,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? 0:(ErrorLevel<<32>>32)+1
        ;-- Convert UInt to Int
    }

;------------------------------
;
; Function: TAB_IsStyle
;
; Description:
;
;   Determine if a specific style has been set.
;
; Parameters:
;
;   p_Style - A style of a tab control.
;
; Returns:
;
;   TRUE if the specified style has been set, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <TAB_GetStyle>
;
;-------------------------------------------------------------------------------
TAB_IsStyle(hTab,p_Style)
    {
    Return TAB_GetStyle(hTab) & p_Style ? True:False
    }

;------------------------------
;
; Function: TAB_IsTabControl
;
; Description:
;
;   Determine if hTab contains a valid handle to a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
; Returns:
;
;   TRUE if hTab contains a valid handle to a tab control, otherwise FALSE.
;
; Remarks:
;
;   This function is rarely needed but it is available when verifying the
;   integrity of the hTab variable is important/critical.
;
;-------------------------------------------------------------------------------
TAB_IsTabControl(hTab)
    {
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On
    WinGetClass l_ClassName,ahk_id %hTab%
    DetectHiddenWindows %l_DetectHiddenWindows%
    Return l_ClassName="SysTabControl32" ? True:False
    }

;------------------------------
;
; Function: TAB_NotifySelChange
;
; Description:
;
;   Notify the parent window that the tab selection has changed.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
; Returns:
;
;   No return value.
;
; Credit:
;
;   Idea and code from *just me*.
;
; Remarks:
;
;   This function sends the TCN_SELCHANGE notifications to the parent window.
;   It was created because on occasion, the tab control does not automatically
;   send this notification when needed.  This function is called by
;   <TAB_SelectItem> if the the tab control has the TCS_BUTTONS style (button
;   mode) but it can also be called independently.
;
;   For tab controls created by AutoHotkey, the TCN_SELCHANGE notification is
;   monitored by AutoHotkey.  When received, AutoHotkey will update variables,
;   draw/redraw and enable/disable the GUI controls in the selected tab, and
;   call the subroutine associated with the tab control.
;
;   Warning: Don't call this function from the tab control's g-label subroutine.
;   It can cause an infinite loop.
;
;-------------------------------------------------------------------------------
TAB_NotifySelChange(hTab)
    {
    Static Dummy91002320

          ;-- Notification
          ,TCN_SELCHANGE:=-551

          ;-- Message
          ,WM_NOTIFY:=0x004E

    ;-- Get the tab control's identifier (control ID).
    CtrlID:=DllCall("GetDlgCtrlID","Ptr",hTab,"Int")

    ;-- Create and populate the NMHDR structure
    VarSetCapacity(NMHDR,A_PtrSize=8 ? 24:12,0)
    NumPut(hTab,  NMHDR,0,"Ptr")                        ;-- hwndFrom
    NumPut(CtrlID,NMHDR,A_PtrSize=8 ? 8:4,"Ptr")        ;-- idFrom

    ;-- Selection changed
    NumPut(TCN_SELCHANGE,NMHDR,A_PtrSize=8 ? 16:8,"Int")   ;-- code
    SendMessage WM_NOTIFY,hTab,&NMHDR,,% "ahk_id " . DllCall("GetParent","Ptr",hTab)
    }

;------------------------------
;
; Function: TAB_NotifySelChanging
;
; Description:
;
;   Notify the parent window that the tab selection is changing.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
; Returns:
;
;   TRUE if the notification was sent successfully _and_ the system will allow
;   the selection to change, otherwise FALSE.
;
; Remarks:
;
;   This function sends the TCN_SELCHANGING notification to the parent window.
;   It was created because on occasion, the tab control or AutoHotkey does not
;   automatically send this notification when needed.  This function is called
;   by <TAB_SelectItem> if the the tab control has the TCS_BUTTONS style (button
;   mode) but it can also be called independently.
;
;   In most cases, this notification is superfluous and most applications will
;   work correctly without it.  However, if the application is monitoring this
;   notification, it must be sent at the correct time.  See the example scripts
;   for an example.
;
;-------------------------------------------------------------------------------
TAB_NotifySelChanging(hTab)
    {
    Static Dummy57876824

          ;-- Notification
          ,TCN_SELCHANGING:=-552

          ;-- Message
          ,WM_NOTIFY:=0x004E

    ;-- Get the tab control's identifier (control ID).
    CtrlID:=DllCall("GetDlgCtrlID","Ptr",hTab,"Int")

    ;-- Create and populate the NMHDR structure
    VarSetCapacity(NMHDR,A_PtrSize=8 ? 24:12,0)
    NumPut(hTab,  NMHDR,0,"Ptr")                        ;-- hwndFrom
    NumPut(CtrlID,NMHDR,A_PtrSize=8 ? 8:4,"Ptr")        ;-- idFrom

    ;-- Send TCN_SELCHANGING notification
    NumPut(TCN_SELCHANGING,NMHDR,A_PtrSize=8 ? 16:8,"Int") ;-- code
    SendMessage WM_NOTIFY,hTab,&NMHDR,,% "ahk_id " . DllCall("GetParent","Ptr",hTab)
    Return ErrorLevel="FAIL" ? False:ErrorLevel ? False:True
    }

;------------------------------
;
; Function: TAB_PressButton
;
; Description:
;
;   Changes the state of a tab control item so that TCIS_BUTTONPRESSED state is
;   set or removed.  See the *Remarks* section for more information.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 for the first
;       tab, 2 for the second tab, and so on.
;
;   p_ButtonPressed - Set to TRUE (the default) to set the TCIS_BUTTONPRESSED
;       state.  Set to FALSE to remove the TCIS_BUTTONPRESSED state.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   The TCIS_BUTTONPRESSED state is only meaningful if the TCS_BUTTONS style
;   flag has been set.
;
;   When the TCIS_BUTTONPRESSED state is set, the appearance of the button is
;   changed so that the button is pressed.  When the TCIS_BUTTONPRESSED state is
;   removed, the appearance of the button is changed so that the button is
;   unpressed.
;
;   Setting the TCIS_BUTTONPRESSED state does not necessarily change the current
;   selection or current focus.  If the TCIS_BUTTONPRESSED state is set on a
;   button where the TCIS_BUTTONPRESSED state is already set, nothing happens.
;   If the TCIS_BUTTONPRESSED state is set on a button that neither has
;   selection or focus, the appearance of the button changes but selection and
;   focus do not change.  However, if the TCIS_BUTTONPRESSED state is removed on
;   a button that is selected and/or has focus, selection and/or focus will
;   change.  If selection changes, the TCN_SELCHANGING and TCN_SELCHANGE
;   notifications are sent to the parent window.  For tab controls created by
;   AutoHotkey, this will trigger the subroutine that is associated with the tab
;   control if any.
;
;-------------------------------------------------------------------------------
TAB_PressButton(hTab,iTab,p_ButtonPressed:=True)
    {
    Static Dummy31308063

          ;-- Mask
          ,TCIF_TEXT      :=0x1
          ,TCIF_IMAGE     :=0x2
          ,TCIF_PARAM     :=0x8
          ,TCIF_RTLREADING:=0x4
          ,TCIF_STATE     :=0x10

          ;-- States
          ,TCIS_BUTTONPRESSED:=0x1
          ,TCIS_HIGHLIGHTED  :=0x2

          ;-- Messages
          ,TCM_SETITEMA:=0x1306                         ;-- TCM_FIRST + 6
          ,TCM_SETITEMW:=0x133D                         ;-- TCM_FIRST + 61

    ;-- Set state
    VarSetCapacity(TCITEM,A_PtrSize=8 ? 40:28,0)
    NumPut(TCIF_STATE,        TCITEM,0,"UInt")          ;-- mask
    NumPut(TCIS_BUTTONPRESSED,TCITEM,8,"UInt")          ;-- dwStateMask
    if p_ButtonPressed
        NumPut(TCIS_BUTTONPRESSED,TCITEM,4,"UInt")      ;-- dwState

    SendMessage A_IsUnicode ? TCM_SETITEMW:TCM_SETITEMA,iTab-1,&TCITEM,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? False:ErrorLevel
    }

;------------------------------
;
; Function: TAB_RemoveImage
;
; Description:
;
;   Remove an image from a tab control's image list.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iIL - The 1-based index of the image in the image list that is associated
;       with the tab control.
;
; Returns:
;
;   No return value.
;
; Remarks:
;
;   The tab control updates each tab's image index, so each tab remains
;   associated with the same image as before.  If a tab is using the image being
;   removed, the tab will be set to have no image.
;
;   This functionality should not be confused with <TAB_SetIcon> which can
;   remove an icon from a tab.
;
;   Important: Although this approach works well for one tab control that is
;   associated with one image list, it does not work if a single image list is
;   used by multiple tab controls.  Do not use this function to remove the image
;   from the image list if this is the case.
;
; Observations:
;
;   If an item is using the image being removed, the item will be set to have no
;   image.  However, unlike what occurs after <TAB_SetIcon> is used to remove an
;   icon, the size (specifically the width) of the item is not adjusted for the
;   lack of an icon.  This is not a problem but it is a bit inconsistent.  In
;   addition, the icon is sometimes not erased completely (residual traces of
;   the icon left behind at the bottom of the tab, Tab and Tab2 only).
;   Redrawing appears to resolve the residual icon problem on the Tab and Tab2
;   control but does not resolve the tab size problem.  Redraw causes other
;   problems on the Tab control and should never be used on the Tab3 control.
;   Resetting the tab control appears to resolve the residual icon problem but
;   does not resolve the tab size problem.  Resizing the tab control appears to
;   resolve all of the problems for all tab controls.  See the
;   <Reposition, Resize, and Redraw> topic for more information.
;
;-------------------------------------------------------------------------------
TAB_RemoveImage(hTab,iIL)
    {
    Static TCM_REMOVEIMAGE :=0x132A                     ;-- TCM_FIRST + 42
    SendMessage TCM_REMOVEIMAGE,iIL-1,0,,ahk_id %hTab%
    }

;------------------------------
;
; Function: TAB_SelectItem
;
; Description:
;
;   Selects an item in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 for the first
;       tab, 2 for the second tab, and so on.
;
; Returns:
;
;   The 1-based index of the previously selected tab (tests as TRUE) if
;   successful, otherwise 0 (tests as FALSE).
;
; Calls To Other Functions:
;
; * <TAB_GetCurFocus>
; * <TAB_GetCurSel>
; * <TAB_GetStyle>
; * <TAB_NotifySelChange>
; * <TAB_NotifySelChanging>
;
; Remarks:
;
;   This function was written to create a consistent method of selecting a tab.
;   It generates the same results whether the tab control has the TCS_BUTTONS
;   style (button mode) or not.  See the *Programming and Usage Notes* section
;   for more information.
;
; Programming and Usage Notes:
;
;   If the specified item is already selected, this function does nothing.  If
;   needed, call <TAB_NotifySelChange> to manually send the TCN_SELCHANGE
;   notification.  See the documentation in <TAB_NotifySelChange> for more
;   information.
;
;   If an item is selected, the TCN_SELCHANGING and TCN_SELCHANGE notifications
;   are sent to the parent window.  For tab controls created by AutoHotkey, the
;   TCN_SELCHANGE notification will trigger the g-label associated with the
;   control if any.
;
;   If the tab control does _not_ have the TCS_BUTTONS style (button mode), the
;   AutoHotkey *GUIControl,Choose* command can be used instead.  Like this
;   function, this command will do nothing if the specified tab is already
;   selected.  This command will not trigger any g-label associated with the
;   control unless the tab number is preceded by a pipe character.  For example:
;
;   (start code)
;   GUIControl Choose,%hTab%,3
;       ;-- Select the 3rd tab of the tab control.  The g-label associated with
;       ;   the control is NOT triggered.
;
;   GUIControl Choose,%hTab%,|5
;       ;-- Select the 5th tab of the tab control.  The g-label associated with
;       ;   the control is triggered.
;   (end)
;
;   Note: The AutoHotkey *GUIControl,Choose* command can be used if the tab
;   control has the TCS_BUTTONS style (button mode) but it does not trigger the
;   g-label associated with the control regardless of the syntax.
;
;-------------------------------------------------------------------------------
TAB_SelectItem(hTab,iTab)
    {
    Static Dummy76237588

          ;-- Style
          ,TCS_BUTTONS:=0x100

          ;-- Messages
          ,TCM_SETCURSEL  :=0x130C                      ;-- TCM_FIRST + 12
          ,TCM_SETCURFOCUS:=0x1330                      ;-- TCM_FIRST + 48

    ;-- Bounce if the specified tab is already selected
    ;   Note: This is standard behavior.  This test ensures that unnecessary
    ;   action is not performed but more importantly, that the TCN_SELCHANGING
    ;   and TCN_SELCHANGE notifications are not sent.
    iTabPrev:=TAB_GetCurSel(hTab)
    if (iTab=iTabPrev)
        Return 0

    ;-- Initialize
    l_Style:=TAB_GetStyle(hTab)

    ;-- If the tab control has the TCS_BUTTONS style, manually send the
    ;   TCN_SELCHANGING notification.  Bounce if TRUE is returned.  TRUE is
    ;   returned if a program monitoring the TCN_SELCHANGING notification
    ;   rejects the request.  Note: For tab controls without the TCS_BUTTONS
    ;   style, the TCN_SELCHANGING notification is automatically sent when the
    ;   TCM_SETCURFOCUS message is sent.
    if l_Style & TCS_BUTTONS
        if not TAB_NotifySelChanging(hTab)
            Return 0

    ;-- Set focus
    ;   Note: If the tab control does not have the TCS_BUTTONS style, this
    ;   message sets focus and selects the tab.  In addition, the tab control
    ;   sends the TCN_SELCHANGING and TCN_SELCHANGE notification codes to its
    ;   parent window.  If the tab control has the TCS_BUTTONS style (button
    ;   mode), this message sets the input focus to the button associated with
    ;   the specified tab but it does not change the selected tab.  The
    ;   TCN_SELCHANGING and TCN_SELCHANGE notifications are NOT sent.
    SendMessage TCM_SETCURFOCUS,iTab-1,0,,ahk_id %hTab%

    ;-- Bounce if the focus did not change
    ;   Note: Failure to change focus can occur if a program stopped the
    ;   selection from occurring.
    if (TAB_GetCurFocus(hTab)<>iTab)
        Return 0

    ;-- If the tab control has the TCS_BUTTONS style, manually select and send
    ;   the TCN_SELCHANGE notification.
    if l_Style & TCS_BUTTONS
        {
        ;-- Select
        ;   Note: For the tab control with the TCS_BUTTONS style (button mode),
        ;   this message selects the specified tab.  This step is necessary
        ;   because the TCM_SETCURFOCUS message performed earlier did not select
        ;   the tab.
        SendMessage TCM_SETCURSEL,iTab-1,0,,ahk_id %hTab%

        ;-- Send the TCN_SELCHANGE notification
        ;   Note: This is performed here because this notification was not sent
        ;   automatically when the TCM_SETCURFOCUS message was sent.  Note:
        ;   There is no return value for this notification.
        TAB_NotifySelChange(hTab)
        }

    Return iTabPrev
    }

;------------------------------
;
; Function: TAB_SelectNext
;
; Description:
;
;   Select the next item in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   p_Count - The number of positions to move the selection.  The default is 1.
;
;   p_Circular - See the *Circular* section for more information.
;
; Returns:
;
;   The 1-based index of the previously selected tab (tests as TRUE) if
;   successful, otherwise 0 (tests as FALSE).
;
; Calls To Other Functions:
;
; * <TAB_GetCurSel>
; * <TAB_GetItemCount>
; * <TAB_SelectItem>
;
; Circular:
;
;   The p_Circular parameter is used to determine what happens when the
;   selection is already on the last item.
;
;   If p_Circular is set to TRUE, the selection will circle around to the
;   beginning of the tab control if needed.  This action is similar to the
;   *Ctrl+PgDn* keyboard shortcut.
;
;   If p_Circular is set to FALSE (the default), the last item in the tab
;   control is the barrier.  If the last tab is already selected, no selection
;   is performed and 0 is returned.  If the request would select beyond the last
;   tab, the last tab is selected.  This action is similar to the Right keyboard
;   shortcut (only available if the tab control has input focus) and the
;   *Control TabRight,Count* command.
;
;-------------------------------------------------------------------------------
TAB_SelectNext(hTab,p_Count:=1,p_Circular:=False)
    {
    ;-- Bounce if there are less than 2 tabs (1 or none)
    if ((l_ItemCount:=TAB_GetItemCount(hTab))<2)
        Return 0

    ;-- Bounce if no tabs are selected.  Rare but it can happen.
    if ((iTab:=Selected_iTab:=TAB_GetCurSel(hTab))=0)
        Return 0

    ;-- Circular
    if p_Circular
        {
        Loop %p_Count%
            if (iTab=l_ItemCount)
                iTab:=1
             else
                iTab+=1

        if (iTab=Selected_iTab)
            Return 0

        Return TAB_SelectItem(hTab,iTab)
        }

    ;-- Regular (not circular)
    if (iTab=l_ItemCount)
        Return 0

    iTab+=p_Count
    iTab:=iTab>l_ItemCount ? l_ItemCount:iTab
    Return TAB_SelectItem(hTab,iTab)
    }

;------------------------------
;
; Function: TAB_SelectPrev
;
; Description:
;
;   Select the previous item in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   p_Count - The number of positions to move the selection.  The default is 1.
;
;   p_Circular - See the *Circular* section for more information.
;
; Returns:
;
;   The 1-based index of the previously selected tab (tests as TRUE) if
;   successful, otherwise 0 (tests as FALSE).
;
; Calls To Other Functions:
;
; * <TAB_GetCurSel>
; * <TAB_GetItemCount>
; * <TAB_SelectItem>
;
; Circular:
;
;   The p_Circular parameter is used to determine what happens when the
;   selection is already on the first item.
;
;   If p_Circular is set to TRUE, the selection will circle around to the end of
;   the tab control if needed.  This action is similar to the *Ctrl+PgUp*
;   keyboard shortcut.
;
;   If p_Circular is set to FALSE (the default), the first item in the tab
;   control is the barrier.  If the first tab is already selected, no selection
;   is performed and 0 is returned.  If the request would select before the
;   first tab, the first tab is selected.  This action is similar to the Left
;   keyboard shortcut (only available if the tab control has input focus) and
;   the *Control TabLeft,Count* command.
;
;-------------------------------------------------------------------------------
TAB_SelectPrev(hTab,p_Count:=1,p_Circular:=False)
    {
    ;-- Bounce if there are less than 2 tabs (1 or none)
    if ((l_ItemCount:=TAB_GetItemCount(hTab))<2)
        Return 0

    ;-- Bounce if no tabs are selected.  Rare but it can happen.
    if ((iTab:=Selected_iTab:=TAB_GetCurSel(hTab))=0)
        Return 0

    ;-- Circular
    if p_Circular
        {
        Loop %p_Count%
            if (iTab=1)
                iTab:=l_ItemCount
             else
                iTab-=1

        if (iTab=Selected_iTab)
            Return 0

        Return TAB_SelectItem(hTab,iTab)
        }

    ;-- Regular (not circular)
    if (iTab=1)
        Return 0

    iTab-=p_Count
    iTab:=iTab<1 ? 1:iTab
    Return TAB_SelectItem(hTab,iTab)
    }

;------------------------------
;
; Function: TAB_SelectText
;
; Description:
;
;   Selects an item in a tab control with a specific text (name).
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   p_Text - Text to search for.
;
;   p_CaseSensitive - [Optional] Set to TRUE for a case sensitive search.
;       The default is FALSE, i.e. case insensitive search.
;
; Returns:
;
;   The 1-based index of the previously selected tab (tests as TRUE) if
;   successful, otherwise 0 (tests as FALSE).
;
; Calls To Other Functions:
;
; * <TAB_FindText>
; * <TAB_SelectItem>
;
; Remarks:
;
;   This function uses <TAB_FindText> to determine if the text in the p_Text
;   parameter matches the text in a tab.  See the <TAB_FindText> documentation
;   for more information.
;
;-------------------------------------------------------------------------------
TAB_SelectText(hTab,p_Text)
    {
    if iTab:=TAB_FindText(hTab,p_Text)
        Return TAB_SelectItem(hTab,iTab)

    Return 0
    }

;------------------------------
;
; Function: TAB_SetCurFocus
;
; Description:
;
;   Set the focus to a specified item in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 for the first
;       tab, 2 for the second tab, and so on.
;
; Returns:
;
;   No return value.
;
; Remarks:
;
;   If the tab control has the TCS_BUTTONS style (button mode), the tab with the
;   focus may be different from the selected tab.  For example, when an item is
;   selected, the user can press the arrow keys to set the focus to a different
;   tab without changing the selected tab. (Note: Arrow keys don't work this way
;   on a tab control created by AutoHotkey).  In button mode, TCM_SETCURFOCUS
;   sets the input focus to the button associated with the specified tab, but it
;   does not change the selected tab.
;
;   If the tab control does not have the TCS_BUTTONS style, changing the focus
;   also changes the selected tab.  In this case, the tab control sends the
;   TCN_SELCHANGING and TCN_SELCHANGE notification codes to its parent window.
;
;   The TCM_SETCURFOCUS message is often used in conjunction with the
;   TCM_SETCURSEL message so that focus and selection are changed at the same
;   time (focus immediately followed by selection), regardless of whether the
;   tab control has TCS_BUTTONS style.  Hint: Use <TAB_SelectItem> instead.
;
;-------------------------------------------------------------------------------
TAB_SetCurFocus(hTab,iTab)
    {
    Static TCM_SETCURFOCUS :=0x1330                     ;-- TCM_FIRST + 48
    SendMessage TCM_SETCURFOCUS,iTab-1,0,,ahk_id %hTab%
    }

;------------------------------
;
; Function: TAB_SetCurSel
;
; Description:
;
;   Select an item in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 for the first
;       tab, 2 for the second tab, and so on.
;
; Returns:
;
;   The 1-based index of the previously selected tab (tests as TRUE) if
;   successful, otherwise 0 (tests as FALSE).
;
; Remarks:
;
;   A tab control does not send a TCN_SELCHANGING or TCN_SELCHANGE notification
;   code when an item is selected using the TCM_SETCURSEL message.  So the tab
;   will be selected but the controls within the tab may not be showing.  Hint:
;   Use <TAB_SelectItem> to change the focus of the control to the specified tab
;   and then select the tab.
;
;-------------------------------------------------------------------------------
TAB_SetCurSel(hTab,iTab)
    {
    Static TCM_SETCURSEL :=0x130C                       ;-- TCM_FIRST + 12
    SendMessage TCM_SETCURSEL,iTab-1,0,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? 0:(ErrorLevel<<32>>32)+1
        ;-- Convert UInt to Int
    }

;------------------------------
;
; Function: TAB_SetMinTabWidth
;
; Description:
;
;   Set the minimum width of the tabs in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   p_Width - The minimum width to set.  If set to -1, the default tab width is
;       set.
;
; Returns:
;
;   The previous minimum tab width or 0 if there was problem.
;
; Remarks:
;
;   This request may increase or decrease the number of tab rows.
;
;   The tab control may not be positioned or drawn correctly after this request.
;   See the <Reposition, Resize, and Redraw> topic for more information.
;
; Observations:
;
;   This message only works if the tab control does not have the TCS_FIXEDWIDTH
;   style.
;
;-------------------------------------------------------------------------------
TAB_SetMinTabWidth(hTab,p_Width)
    {
    Static TCM_SETMINTABWIDTH:=0x1331                   ;-- TCM_FIRST + 49
    SendMessage TCM_SETMINTABWIDTH,0,p_Width,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? 0:ErrorLevel
    }

;------------------------------
;
; Function: TAB_SetIcon
;
; Description:
;
;   Set or remove an icon for an item on a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 for the first
;       tab, 2 for the second tab, and so on.
;
;   iIL - The 1-based index of the image in the image list that is associated
;       with the tab control.  Set to 0 to remove the icon for the tab.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   The tab control may not be drawn correctly after this request.  See the
;   <Reposition, Resize, and Redraw> topic for more information.
;
; Observations:
;
;   There are no redraw issues when the icon is removed.  Your results may
;   differ.
;
;-------------------------------------------------------------------------------
TAB_SetIcon(hTab,iTab,iIL)
    {
    Static Dummy18408860

          ;-- Mask
          ,TCIF_TEXT      :=0x1
          ,TCIF_IMAGE     :=0x2
          ,TCIF_PARAM     :=0x8
          ,TCIF_RTLREADING:=0x4
          ,TCIF_STATE     :=0x10

          ;-- Messages
          ,TCM_SETITEMA:=0x1306                         ;-- TCM_FIRST + 6
          ,TCM_SETITEMW:=0x133D                         ;-- TCM_FIRST + 61

    VarSetCapacity(TCITEM,A_PtrSize=8 ? 40:28,0)
    NumPut(TCIF_IMAGE,TCITEM,0,"UInt")                  ;-- mask
    NumPut(iIL-1,TCITEM,A_PtrSize=8 ? 28:20,"Ptr")      ;-- iImage
    SendMessage A_IsUnicode ? TCM_SETITEMW:TCM_SETITEMA,iTab-1,&TCITEM,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? False:ErrorLevel
    }

;------------------------------
;
; Function: TAB_SetImageList
;
; Description:
;
;   Assigns an image list to a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   hIL - The handle to an image list.
;
; Returns:
;
;   The handle to the previous image list or 0 if there is no previous image
;   list.
;
; Remarks:
;
;   This request can affect the display area of the tab control so in most
;   cases, this function should be called before GUI controls are added to the
;   tabs.  If this request is performed after the window is showing, the tab
;   control may need to be repositioned and/or resized.  See the
;   <Reposition, Resize, and Redraw> topic for more information.
;
;-------------------------------------------------------------------------------
TAB_SetImageList(hTab,hIL)
    {
    Static TCM_SETIMAGELIST:=0x1303                     ;-- TCM_FIRST + 3
    SendMessage TCM_SETIMAGELIST,0,hIL,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? 0:ErrorLevel
    }

;------------------------------
;
; Function: TAB_SetInputFocus
;
; Description:
;
;   Sets input focus to the tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   When a tab control is shown, input focus is usually set on the first control
;   withing the selected tab.  This command moves focus to the tab control
;   itself.  It allows the user to navigate via the Left and Right keys without
;   first clicking on the selected tab with the mouse.
;
;   Note: The TCS_FOCUSNEVER style will not stop this function from setting
;   focus.  If needed, check for the TCS_FOCUSNEVER style before calling is
;   function.
;
;-------------------------------------------------------------------------------
TAB_SetInputFocus(hTab)
    {
    ControlFocus,,ahk_id %hTab%
    Return ErrorLevel ? False:True
    }

;------------------------------
;
; Function: TAB_SetItemSize
;
; Description:
;
;   Set the width and height of tabs in a fixed-width tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   p_Width, p_Height - The new width and height.  Set p_Width to -1 (the
;       default) to use the current width of the first tab (the width should be
;       the same for all tabs if the TCS_FIXEDWIDTH style is used).  Set
;       p_Height to -1 (the default) to use the current height of the tabs.  See
;       the *Observations* section for more information.
;
; Returns:
;
;   The old width and height.  The width is in the LOWORD of the return value,
;   and the height is in the HIWORD.
;
; Calls To Other Functions:
;
; * <TAB_GetItemWidth>
; * <TAB_GetItemHeight>
;
; Observations:
;
;   Note: The Microsoft documentation for this message is very limited.  This
;   section is titled "Observations" not "Remarks" because the following
;   information is based on observation, not documentation (official or
;   otherwise).
;
;   If the tab control has the TCS_FIXEDWIDTH style, the actual minimum width
;   depends on whether an image list has been assigned to the tab control or
;   not.  If an image list has been assigned, the minimum width is the width of
;   the image list icon plus ~4 pixels.  If an image list has not been assigned,
;   the minimum width is 0.
;
;   If the tab control does _not_ have the TCS_FIXEDWIDTH style, the width is
;   not changed by this function regardless of the value.
;
;   The height can be set regardless of the TCS_FIXEDWIDTH style.  The minimum
;   height is 1 and there does not appear to be a maximum height.  Setting 
;   the height to 0 will set the tabs to the default height.  The default height
;   is determined by the height of icons in the image list or the height of the
;   font.
;
;   Once the size is set by this function, changes to the tab control's image
;   list do not affect the size of the tab.  If needed, call this function again
;   after changing the size of the icons.
;
;-------------------------------------------------------------------------------
TAB_SetItemSize(hTab,p_Width:=-1,p_Height:=-1)
    {
    Static TCM_SETITEMSIZE:=0x1329                      ;-- TCM_FIRST + 41
    p_Width :=p_Width<0 ?  TAB_GetItemWidth(hTab):p_Width
    p_Height:=p_Height<0 ? TAB_GetItemHeight(hTab):p_Height
    SendMessage TCM_SETITEMSIZE,0,p_Height<<16|p_Width,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? 0:ErrorLevel
    }

;------------------------------
;
; Function: TAB_SetStyle
;
; Description:
;
;   Adds, removes, or toggles a style for an tab control.
;
; Parameters:
;
;   p_Style - Style to set.
;
;   p_Option - Use "+" (the default) to add, "-" to remove, and "^" to toggle.
;
; Returns:
;
;   TRUE if the request completed successfully, otherwise FALSE.
;
; Remarks:
;
;   For a complete list of tab control styles :
;
;   * <https://msdn.microsoft.com/en-us/library/windows/desktop/bb760549(v=vs.85).aspx>
;
;   This document includes a list of styles can be modified after the tab
;   control has been created.  Please note that some changes made after the tab
;   control has been created may not produce the desired results.
;
;   The tab control will often need to be repositioned and/or redrawn after a
;   style has been added or removed.  See the <Reposition, Resize, and Redraw>
;   topic for more information.
;
;-------------------------------------------------------------------------------
TAB_SetStyle(hTab,p_Style,p_Option:="+")
    {
    Control Style,%p_Option%%p_Style%,,ahk_id %hTab%
    Return ErrorLevel ? False:True
    }

;------------------------------
;
; Function: TAB_SetText
;
; Description:
;
;   Set the text on an item in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 for the first
;       tab, 2 for the second tab, and so on.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   In many cases, the tab control is not drawn correctly after this request.
;   See the <Reposition, Resize, and Redraw> topic for more information.
;
;-------------------------------------------------------------------------------
TAB_SetText(hTab,iTab,p_Text)
    {
    Static Dummy18408860

          ;-- Mask
          ,TCIF_TEXT      :=0x1
          ,TCIF_IMAGE     :=0x2
          ,TCIF_PARAM     :=0x8
          ,TCIF_RTLREADING:=0x4
          ,TCIF_STATE     :=0x10

          ;-- Messages
          ,TCM_SETITEMA:=0x1306                         ;-- TCM_FIRST + 6
          ,TCM_SETITEMW:=0x133D                         ;-- TCM_FIRST + 61

    VarSetCapacity(TCITEM,A_PtrSize=8 ? 40:28,0)
    NumPut(TCIF_TEXT,TCITEM,0,"UInt")                   ;-- mask
    NumPut(&p_Text,TCITEM,A_PtrSize=8 ? 16:12,"Ptr")    ;-- pszText
    SendMessage A_IsUnicode ? TCM_SETITEMW:TCM_SETITEMA,iTab-1,&TCITEM,,ahk_id %hTab%
    Return ErrorLevel="FAIL" ? False:ErrorLevel
    }

;------------------------------
;
; Function: TAB_SetTooltips
;
; Description:
;
;   Assign a tooltip control to a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   hTT - The handle to a tooltip control.
;
; Returns:
;
;   No return value.
;
; Remarks:
;
;   The tooltip control must be created with certain attributes.  See the
;   <Tooltips> topic for more information.
;
;   Use <TAB_GetTooltips> to get the tooltip control associated with a tab
;   control.
;
;-------------------------------------------------------------------------------
TAB_SetTooltips(hTab,hTT)
    {
    Static TCM_SETTOOLTIPS:=0x132E                      ;-- TCM_FIRST + 46
    SendMessage TCM_SETTOOLTIPS,hTT,0,,ahk_id %hTab%
    }

;------------------------------
;
; Function: TAB_Tooltips_Activate
;
; Description:
;
;   Activates (enables) the tooltip control that is attached to the tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
; Returns:
;
;   No return value.
;
; Calls To Other Functions:
;
; * <TAB_GetTooltips>
;
; Remarks:
;
;   The tooltip control is enabled by default.  There is no need to activate
;   (enable) the tooltip control unless it has been previously deactivated
;   (disabled).
;
;-------------------------------------------------------------------------------
TAB_Tooltips_Activate(hTab)
    {
    Static TTM_ACTIVATE:=0x401                          ;-- WM_USER + 1
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On
    SendMessage TTM_ACTIVATE,True,0,,% "ahk_id " . TAB_GetTooltips(hTab)
    DetectHiddenWindows %l_DetectHiddenWindows%
    }

;------------------------------
;
; Function: TAB_Tooltips_Create
;
; Description:
;
;   Create a tooltip control for use with a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
; Returns:
;
;   The handle to a new tooltip control.
;
; Calls To Other Functions:
;
; * <TAB_GetItemCount>
; * <TAB_GetItemRect>
;
; Remarks:
;
;   This function creates a tooltip control that can be used with the specified
;   tab control.  If needed, call <TAB_SetTooltips> to assign the tooltip
;   control created by this function to the tab control.
;
;   This function can be used as is, customized for personal use, or used as
;   a template for a custom function.
;
;-------------------------------------------------------------------------------
TAB_Tooltips_Create(hTab)
    {
    Static Dummy15715076

          ;-- Misc. constants
          ,CW_USEDEFAULT:=0x80000000

          ;-- Tooltip styles
          ,TTS_NOPREFIX:=0x2
                ;-- Prevents the system from stripping ampersand characters from
                ;   a string or terminating a string at a tab character.
                ;   Without this style, the system automatically strips
                ;   ampersand characters and terminates a string at the first
                ;   tab character.  This allows an application to use the same
                ;   string as both a menu item and as text in a tooltip control.

          ;-- TOOLINFO uFlags
          ,TTF_SUBCLASS:=0x10
                ;-- Indicates that the tooltip control should subclass the
                ;   window for the tool in order to intercept messages, such
                ;   as WM_MOUSEMOVE.

          ;-- Extended styles
          ,WS_EX_TOPMOST:=0x8

          ;-- Flags
          ,LPSTR_TEXTCALLBACK:=-1

          ;-- Messages
          ,TTM_ADDTOOLA      :=0x404                    ;-- WM_USER + 4
          ,TTM_ADDTOOLW      :=0x432                    ;-- WM_USER + 50
          ,TTM_SETMAXTIPWIDTH:=0x418                    ;-- WM_USER + 24
          ,TTM_UPDATETIPTEXTA:=0x40C                    ;-- WM_USER + 12
          ,TTM_UPDATETIPTEXTW:=0x439                    ;-- WM_USER + 57

    ;-- Save/Set DetectHiddenWindows
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On

    ;-- Create Tooltip window
    l_Style:=TTS_NOPREFIX
    hParent:=DllCall("GetParent","Ptr",hTab,"Ptr")
    hTT:=DllCall("CreateWindowEx"
        ,"UInt",WS_EX_TOPMOST                       ;-- dwExStyle
        ,"Str","TOOLTIPS_CLASS32"                   ;-- lpClassName
        ,"Ptr",0                                    ;-- lpWindowName
        ,"UInt",l_Style                             ;-- dwStyle
        ,"UInt",CW_USEDEFAULT                       ;-- x
        ,"UInt",CW_USEDEFAULT                       ;-- y
        ,"UInt",CW_USEDEFAULT                       ;-- nWidth
        ,"UInt",CW_USEDEFAULT                       ;-- nHeight
        ,"Ptr",hParent                              ;-- hWndParent
        ,"Ptr",0                                    ;-- hMenu
        ,"Ptr",0                                    ;-- hInstance
        ,"Ptr",0                                    ;-- lpParam
        ,"Ptr")                                     ;-- Return type

    ;-- Disable visual style
    ;   Note: Uncomment the following to disable the visual style, i.e.
    ;   remove the window theme, from the tooltip control.  All tooltips added
    ;   to the control created by this function will be affected.
;;;;;    DllCall("uxtheme\SetWindowTheme","Ptr",hTT,"Ptr",0,"UIntP",0)

    ;-- Set the maximum width for the tooltip window
    ;   Note: This message makes multi-line tooltips possible
    SendMessage TTM_SETMAXTIPWIDTH,0,A_ScreenWidth,,ahk_id %hTT%

    ;-- Create and populate the TOOLINFO structure
    uFlags:=TTF_SUBCLASS
    cbSize:=VarSetCapacity(TOOLINFO,(A_PtrSize=8) ? 64:44,0)
    NumPut(cbSize,TOOLINFO,0,"UInt")                    ;-- cbSize
    NumPut(uFlags,TOOLINFO,4,"UInt")                    ;-- uFlags
    NumPut(hTab,  TOOLINFO,8,"Ptr")                     ;-- hwnd
    NumPut(LPSTR_TEXTCALLBACK,TOOLINFO,(A_PtrSize=8) ? 48:36,"Ptr")
        ;-- lpszText

    ;-- Add a tool for each tab
    Loop % TAB_GetItemCount(hTab)
        {
        NumPut(A_Index-1,TOOLINFO,(A_PtrSize=8) ? 16:12,"Ptr")
            ;-- uId

        ;-- Set the appropriate bounding rectangle coordinates
        ;   Note: This information is only set once when the tool is created.
        ;   The tab control automatically updates this information if/when
        ;   needed.
        TAB_GetItemRect(hTab,A_Index,l_Left,l_Top,l_Right,l_Bottom)
        NumPut(l_Left,  TOOLINFO,A_PtrSize=8 ? 24:16,"Int")
        NumPut(l_Top,   TOOLINFO,A_PtrSize=8 ? 28:20,"Int")
        NumPut(l_Right, TOOLINFO,A_PtrSize=8 ? 32:24,"Int")
        NumPut(l_Bottom,TOOLINFO,A_PtrSize=8 ? 36:28,"Int")

        ;-- Add tool
        SendMessage
            ,A_IsUnicode ? TTM_ADDTOOLW:TTM_ADDTOOLA
            ,0
            ,&TOOLINFO
            ,,ahk_id %hTT%
        }

    ;-- Restore DetectHiddenWindows
    DetectHiddenWindows %l_DetectHiddenWindows%

    ;-- Return the handle to the tooltip control
    Return hTT
    }

;------------------------------
;
; Function: TAB_Tooltips_Deactivate
;
; Description:
;
;   Deactivates (disables) the tooltip control that is attached to the tab
;   control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
; Returns:
;
;   No return value.
;
; Calls To Other Functions:
;
; * <TAB_GetTooltips>
;
; Remarks:
;
;   This command will stop all of tooltips from showing on a tab control.  Use
;   <TAB_Tooltips_Activate> to reverse this action.
;
;-------------------------------------------------------------------------------
TAB_Tooltips_Deactivate(hTab)
    {
    Static TTM_ACTIVATE:=0x401                          ;-- WM_USER + 1
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On
    SendMessage TTM_ACTIVATE,False,0,,% "ahk_id " . TAB_GetTooltips(hTab)
    DetectHiddenWindows %l_DetectHiddenWindows%
    }

;------------------------------
;
; Function: TAB_Tooltips_GetText
;
; Description:
;
;   Get the tooltip text for an item in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 for the first
;       tab, 2 for the second tab, and so on.
;
; Returns:
;
;   The text for tooltip.  The value can be null.
;
; Calls To Other Functions:
;
; * <TAB_GetTooltips>
;
; Programming notes :
;
;   To support Windows XP and earlier, the value of the wParam parameter
;   for the TTM_GETTEXT message is set to zero.  There is no way to predetermine
;   the required buffer size.
;
;   Due to a bug or a design restriction, the TTM_GETTEXTA message is never
;   used because it returns a maximum of 80 characters.
;
; Observations:
;
;   If the text for tooltip tool contains the LPSTR_TEXTCALLBACK flag (set by
;   default and when the text is set to null by <TAB_Tooltips_SetText>), the
;   tooltip control will send the TTN_GETDISPINFO notification when the
;   TTM_GETTEXTW message is sent.  If the notification is being monitored, the
;   text returned by this function will be whatever the code that is monitoring
;   the TTN_GETDISPINFO notification sets the text to, otherwise the text is
;   returned as null.
;
;-------------------------------------------------------------------------------
TAB_Tooltips_GetText(hTab,iTab)
    {
    Static Dummy75922473
          ,MaxTCHARs:=0xFFFF  ;-- 64K
          ,sizeofTOOLINFO:=(A_PtrSize=8) ? 64:44

          ;-- Message
          ,TTM_GETTEXTW:=0x438                          ;-- WM_USER + 56

    ;-- Create, initialize, and populate TOOLINFO structure
    VarSetCapacity(TOOLINFO,sizeofTOOLINFO,0)
    NumPut(sizeofTOOLINFO,TOOLINFO,0,"UInt")            ;-- cbSize
    NumPut(hTab,          TOOLINFO,8,"Ptr")             ;-- hwnd
    NumPut(iTab-1,        TOOLINFO,(A_PtrSize=8) ? 16:12,"Ptr")
        ;-- uId

    VarSetCapacity(l_Text,MaxTCHARs*2,0)
    NumPut(&l_Text,TOOLINFO,(A_PtrSize=8) ? 48:36,"Ptr")
        ;-- lpszText

    ;-- Get text
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On
    SendMessage TTM_GETTEXTW,0,&TOOLINFO,,% "ahk_id " . TAB_GetTooltips(hTab)
    DetectHiddenWindows %l_DetectHiddenWindows%

    ;-- Return text
    if A_IsUnicode
        {
        VarSetCapacity(l_Text,-1)
        Return l_Text
        }
     else
        Return StrGet(&l_Text,-1,"UTF-16")
    }

;------------------------------
;
; Function: TAB_Tooltips_SetText
;
; Description:
;
;   Set the tooltip text for an item in a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   iTab - The 1-based index of a tab in a tab control.  Set to 1 for the first
;       tab, 2 for the second tab, and so on.
;
;   p_Text - The tooltip text.  Ex: "My tooltip".  Set to null to remove the
;       tooltip.
;
; Returns:
;
;   The handle to the tooltip control (tests as TRUE) if successful, otherwise
;   0 (tests as FALSE).
;
; Calls To Other Functions:
;
; * <TAB_GetItemRect>
; * <TAB_GetTooltips>
; * <TAB_IsTabControl>
; * <TAB_SetTooltips>
; * <TAB_Tooltips_Create>
;
; Remarks:
;
;   To improve usability, this function will automatically call
;   <TAB_Tooltips_Create> and <TAB_SetTooltips> before setting the tooltip text
;   if a tooltip control is not associated with the tab control.
;
;-------------------------------------------------------------------------------
TAB_Tooltips_SetText(hTab,iTab,p_Text)
    {
    Static Dummy40370454

          ;-- TOOLINFO uFlags
          ,TTF_SUBCLASS:=0x10
                ;-- Indicates that the tooltip control should subclass the
                ;   window for the tool in order to intercept messages, such
                ;   as WM_MOUSEMOVE.

          ;-- Tooltip icons
          ,TTI_NONE         :=0
          ,TTI_INFO         :=1
          ,TTI_WARNING      :=2
          ,TTI_ERROR        :=3
          ,TTI_INFO_LARGE   :=4
          ,TTI_WARNING_LARGE:=5
          ,TTI_ERROR_LARGE  :=6

          ;-- Flags
          ,LPSTR_TEXTCALLBACK:=-1

          ;-- Messages
          ,TTM_ADDTOOLA      :=0x404                    ;-- WM_USER + 4
          ,TTM_ADDTOOLW      :=0x432                    ;-- WM_USER + 50
          ,TTM_GETTOOLINFOA  :=0x408                    ;-- WM_USER + 8
          ,TTM_GETTOOLINFOW  :=0x435                    ;-- WM_USER + 53
          ,TTM_UPDATETIPTEXTA:=0x40C                    ;-- WM_USER + 12
          ,TTM_UPDATETIPTEXTW:=0x439                    ;-- WM_USER + 57

    ;-- Save/Set DetectHiddenWindows
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On

    ;-- Get the handle to the tooltip control
    if not hTT:=TAB_GetTooltips(hTab)
        {
        ;-- Check the veracity of hTab.  This will help to ensure that when a
        ;   new tooltip control is created, it can be associated to a tab
        ;   control.  This will avoid a memory leak that could become
        ;   problematic if this function is called many times in the life a
        ;   script.
        if not TAB_IsTabControl(hTab)
            {
            outputdebug,
               (ltrim join`s
                Function: %A_ThisFunc% - hTab does not contain a valid handle.
                Tooltip control not created.  Function aborted.
                hTab: %hTab%
               )

            Return 0
            }

        ;-- Create a new tooltip control and attach to the tab control
        hTT:=TAB_Tooltips_Create(hTab)
        TAB_SetTooltips(hTab,hTT)
        }

    ;-- Create/Populate the TOOLINFO structure
    uFlags:=TTF_SUBCLASS
    cbSize:=VarSetCapacity(TOOLINFO,(A_PtrSize=8) ? 64:44,0)
    NumPut(cbSize,TOOLINFO,0,"UInt")                    ;-- cbSize
    NumPut(uFlags,TOOLINFO,4,"UInt")                    ;-- uFlags
    NumPut(hTab,  TOOLINFO,8,"Ptr")                     ;-- hwnd
    NumPut(iTab-1,TOOLINFO,(A_PtrSize=8) ? 16:12,"Ptr") ;-- uId

    ;-- Check if a tool has already been registered for the specified tab
    SendMessage
        ,A_IsUnicode ? TTM_GETTOOLINFOW:TTM_GETTOOLINFOA
        ,0
        ,&TOOLINFO
        ,,ahk_id %hTT%

    l_RegisteredTool:=ErrorLevel

    ;-- Update the TOOLTIP structure
    NumPut(p_Text="" ? LPSTR_TEXTCALLBACK:&p_Text,TOOLINFO,(A_PtrSize=8) ? 48:36,"Ptr")
        ;-- lpszText

    ;-- Update or add tool
    if l_RegisteredTool
        SendMessage
            ,A_IsUnicode ? TTM_UPDATETIPTEXTW:TTM_UPDATETIPTEXTA
            ,0
            ,&TOOLINFO
            ,,ahk_id %hTT%
     else
        {
        ;-- Add tool with the appropriate bounding rectangle coordinates
        ;   Note: This information is only set when the tool is created.
        ;   The tab control updates this information if/when needed.
        TAB_GetItemRect(hTab,iTab,l_Left,l_Top,l_Right,l_Bottom)
        NumPut(l_Left,  TOOLINFO,A_PtrSize=8 ? 24:16,"Int")
        NumPut(l_Top,   TOOLINFO,A_PtrSize=8 ? 28:20,"Int")
        NumPut(l_Right, TOOLINFO,A_PtrSize=8 ? 32:24,"Int")
        NumPut(l_Bottom,TOOLINFO,A_PtrSize=8 ? 36:28,"Int")
        SendMessage
            ,A_IsUnicode ? TTM_ADDTOOLW:TTM_ADDTOOLA
            ,0
            ,&TOOLINFO
            ,,ahk_id %hTT%
        }

    ;-- Restore DetectHiddenWindows
    DetectHiddenWindows %l_DetectHiddenWindows%

    ;-- Return the handle to the tooltip control
    Return hTT
    }

;------------------------------
;
; Function: TAB_Tooltips_SetTitle
;
; Description:
;
;   Set or remove the title for the tooltips of a tab control.
;
; Parameters:
;
;   hTab - The handle to a tab control.
;
;   p_Title - The title.  See the *Title & Icon* section for more information.
;
;   p_Icon - Tooltip icon.  See the *Title & Icon* section for more information.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <TAB_GetTooltips>
;
; Title & Icon:
;
;   To set a title for the tooltips, set the p_Title parameter to the desired
;   tooltip title.  Ex: TAB_Tooltips_SetTitle(hTab,"Bob's Tooltips"). To remove
;   the title, set the p_Title parameter to null.  Ex:
;   TAB_Tooltips_SetTitle(hTab,"").
;
;   The p_Icon parameter determines the icon to be displayed along with the
;   title, if any.  If not specified or if set to 0, no icon is shown.  To show
;   a standard icon, specify one of the standard icon identifiers.  See the
;   function's static variables for a list of possible values.  Ex:
;   TAB_Tooltips_SetTitle(hTab,"My Title",4).  To show a custom icon, specify a
;   handle to an image (bitmap, cursor, or icon).  When a custom icon is
;   specified, a copy of the icon is created by the tooltip control so if
;   needed, the original icon can be destroyed any time after the title and icon
;   are set.
;
;   Please note that an icon is only shown if a title has been set.  The title
;   is only shown if the text has been set for the tooltip.
;
;   Setting a tooltip title may not produce a desirable result in many cases.
;   The title (and icon if specified) is shown on every tooltip.
;
;-------------------------------------------------------------------------------
TAB_Tooltips_SetTitle(hTab,p_Title,p_Icon:="")
    {
    Static Dummy12754852

          ;-- Tooltip icons
          ,TTI_NONE         :=0
          ,TTI_INFO         :=1
          ,TTI_WARNING      :=2
          ,TTI_ERROR        :=3
          ,TTI_INFO_LARGE   :=4
          ,TTI_WARNING_LARGE:=5
          ,TTI_ERROR_LARGE  :=6

          ;-- Messages
          ,TTM_SETTITLEA:=0x420                         ;-- WM_USER + 32
          ,TTM_SETTITLEW:=0x421                         ;-- WM_USER + 33

    ;-- If needed, truncate the title
    if (StrLen(p_Title)>99)
        p_Title:=SubStr(p_Title,1,99)

    ;-- Icon
    if p_Icon is not Integer
        p_Icon:=TTI_NONE

    ;-- Set title
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On
    SendMessage A_IsUnicode ? TTM_SETTITLEW:TTM_SETTITLEA,p_Icon,&p_Title,,% "ahk_id " . TAB_GetTooltips(hTab)
    DetectHiddenWindows %l_DetectHiddenWindows%
    Return ErrorLevel="FAIL" ? False:ErrorLevel
    }
