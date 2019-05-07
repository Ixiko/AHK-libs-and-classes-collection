# EntryForm
### Create custom data entry forms in [AutoHotkey](http://www.ahkscript.org/)

Requires AutoHotkey **v1.1+** or **v2.0-a053+**

**License:** [WTFPL](http://wtfpl.net/)

- - -

## Syntax:
```javascript
output := EntryForm( form, fields* )
```

## Return Value:
```javascript
out := {
    "event":  [ OK, Cancel, Close, Escape, Timeout ], // [string] either of these
    "output": [ field1, field2, ... ] // array containing the output of each input field
}
```

**Remarks:**

  * If the EntryForm has only one(1) field, ``.output`` will contain a string, the value itself


## Parameters:

Parameter | Description
----------|------------
``form [in]`` | string or associative array_(untested)_ specifying the _EntryForm_<br>window's options
``fields* [in, variadic]`` | string or associative array_(untested)_ specifying each field's<br>options

#### Form ``[in]``:

```javascript
form [-cap | -c <caption>] [-fnt | -f <fontspec>] [-ico | -i <iconspec>] [-t <period>]
     [-F <callback>] [-pos | -p <position>] [-opt | -o <options>]
```

A space-delimited string containing one or more of the following below. Options are passed in _command line-like_ syntax. _**Note:** if an argument contains a **space**, it must be enclosed in **single** quotes. Multiple arguments are separated by a **comma**_:

Option &lt;_Argument(s)_&gt;<br>_alternative syntax_ |  Description
:----------------|------------
``-cap OR -c <caption>`` | window caption / title
``-fnt OR -f <options,name>`` | window font, argument(s) is the same as in [Gui, Font](http://ahkscript.org/docs/commands/Gui.htm#Font).<br>_e.g.:_ ``-fnt 's10 cBlue,Segoe UI'``
``-ico OR -i <icon,icon-no>`` | window icon, *icon* can be a _file_, _exe_ or _dll_<br>_e.g.:_ ``-ico 'shell32.dll,25'``
``-t <period>``<br>``Tperiod`` | similar to _Timeout_ parameter of [InputBox](http://ahkscript.org/docs/commands/InputBox.htm) except<br>_period_ is in milliseconds instead of seconds.<br>_e.g.:_ ``-t 5000`` or ``t5000``
``-F <callback>``<br>``Fcallback`` | callback function. Output is passed as 1st parameter.<br>_-F_ is case sensitive when using dash ``-`` syntax. If a<br>timeout period is defined (using _-t_ option), this option<br>is ignored.<br>_e.g.:_ ``-F Callback_Function`` or ``fCallback_Function``
``-pos OR -p <Xn Yn Wn>``<br>``[ Xn Yn Wn ]`` | window position, same as in [Gui, Show](http://ahkscript.org/docs/commands/Gui.htm#Show). Default is<br>``xCenter yCenter w375`` 
``-opt OR -o <options>``<br>``[ options ... ]`` | standard Gui [options](http://ahkscript.org/docs/commands/Gui.htm#Options) ``e.g.: +ToolWindow etc.``

**Remarks:**

 * Window height must not be specified, it is calculated automatically based on the total number of input fields
 * For _-ico_, the same icon will be used for the window caption (small) and the Alt+Tab switcher (large)
 * If a callback function is defined (via _-F_ option), the function will return immediately instead of waiting for the window to close. Function must require atleast one(1) parameter. However, if a _-t_ (timeout) is defined, callback function is ignored
 
**Example Usage:**

```javascript
/* If window position is not specified, it is shown in the center
 * The '-fnt' option applies to fields(controls) whose '-fnt' option is not specified
 */
form := "-c 'Test Form' -ico 'cmd.exe,0' -fnt 's10 cBlue,Consolas' T5000 w500 +ToolWindow"
/* Optional syntax for timeout, pos and options
 * form := "-t 5000 -pos 'x0 w500' -o '+ToolWindow -Caption'"
 */
output := EntryForm(form, ...)
```
<br>

#### Fields ``[in, variadic]``:

```
field (-p <prompt>) [-d <default>] [-fnt <fontspec>] [-in <input_ctrl>] [-cb <cuebanner>]
      [-tt <tooltip>] [-ud <updown>] [-fs <fileselect>] [-ds <dirselect>] [-opt | -o <options>]
```

A space-delimited string containing one or more of the following below. Options are passed in _command line-like_ syntax. _**Note:** if an argument contains a **space**, it must be enclosed in **single** quotes. Multiple arguments are separated by a **comma**_:

-Option &lt;_Argument(s)_&gt;<br>_alternative syntax_ | Description
:----------------|------------
``-p <prompt>`` | ``Required``, similar to _Prompt_ parameter of [InputBox](http://ahkscript.org/docs/commands/InputBox.htm).
``-d <default-text>`` | similar to _Default_ parameter of [InputBox](http://ahkscript.org/docs/commands/InputBox.htm). If input<br> field control type is not an _Edit_ (default) control,<br>usage is similar to _Text_ parameter  of [Gui, Add](http://ahkscript.org/docs/commands/Gui.htm#Add).
``-fnt <p-fontargs;i-fontargs>`` | a semicolon separates the arguments for the prompt<br>_(p-fontargs)_ and the arguments for the input field<br>_(i-fontargs)_.<br>_e.g.:_ ``-fnt 's10 cBlue,Segoe UI;s9,Consolas'``
``-in <input-ctrl>``<br>``*INPUT_CTRL`` | input field control type, defaults to _Edit_(E) control.<br>_input-ctrl_ must be one of the following strings:<br>_E (Edit), CB (ComboBox), DDL (DropDownList),<br>DT (DateTime)_.<br>_e.g.:_ ``-in DDL`` _or simply_ ``*DDL``
``-cb <cuebanner>`` | textual cue, or tip, that is displayed by the _Edit_<br>control
``-tt <tooltip>`` | tooltip for the input field, shown when mouse<br>cursor is over the control
``-ud <updown-ctrl-options>`` | attaches an _UpDown_ control to the input field.<br>``updown-ctrl-options`` are the same as in<br>[Gui, Add, UpDown](http://ahkscript.org/docs/commands/GuiControls.htm#UpDown)<br>_e.g.:_ ``-ud 'Range1-100 Wrap'``
``-fs <fileselectfile-args>`` | a button is placed to the right of the input field.<br>When pressed, a [FileSelectFile](http://ahkscript.org/docs/commands/FileSelectFile.htm) dialog is shown.<br>``fileselectfile-args`` is the same as in<br>_FileSelectFile_ command.<br>_e.g.:_ ``-fs 'M3,C:\Users,Select file,Text (*.txt)'``
``-ds <fileselectfolder-args>`` | same as _File_ above, but works like [FileSelectFolder](http://ahkscript.org/docs/commands/FileSelectFolder.htm)<br>_e.g.:_ ``-ds 'C:\Users,3,Select folder'``
``-opt OR -o <options>``<br>``[ options ... ]`` | standard options that apply to the specified input<br> field control type should work.<br>_e.g.:_ ``-o 'R1 -Wrap +HScroll'`` _or_ ``R1 -Wrap +HScroll``

**Remarks:**

 * For _-fs_ and _-ds_, order of the arguments is the same as in their counterpart AHK commands
 * Input field width must not be specified, it is calculated automatically based on the EntryForm window width as specified in _form_ parameter
 * For _-fs_ and _-ds_, if the button's associated _Edit_ control is **NOT** empty, a [SplitPath](http://ahkscript.org/docs/commands/SplitPath.htm) will be performed on the text(contents), _OutDir_ will be used as the initial directory and _OutFileName_ will be used as the initial file name (latter applies to _-fs_) when the dialog is shown.
 * If input field control type is not an _Edit_ control, the following options are ignored: _-cb_, _-ud_, _-fs_, _-ds_

**Example Usage:**

```javascript
/* For options which require arguments to be enclosed in single quotes, to specify a literal
 * single quote, escape it with a backslash '\'
 */
field1 := "-p 'Enter your password:' -fnt 'Italic,Segoe UI' -cb 'Password here' R1 Password"

/* For '-fs' option, separate each argument with a comma, order of arguments is the same as
 * FileSelectFile command: [ Options, RootDir\Filename, Prompt, Filter ]
 */
field2 := "-p 'File to upload:' -fs '1,C:\Dir,Select a file,Text Document (*.txt; *.tex)'"

out := EntryForm(form, field1, field2)
```

<br>

## Screenshot:

![EntryForm-Screenshot](http://i.imgur.com/Z21cu4b.jpg)


## Remarks:

 * Behavior is similar to that of the _InputBox_ command, that is the script will  be in a _waiting state_ while the _EntryForm_ window is shown. To bypass this, the caller can use a [timer](http://ahkscript.org/docs/commands/SetTimer.htm) or define a callback function using the _-F_ option - see _Form_ options above.