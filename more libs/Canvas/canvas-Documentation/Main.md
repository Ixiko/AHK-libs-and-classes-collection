Canvas-AHK
==========
Canvas-AHK is a portable, high level drawing library written for AutoHotkey, designed for use in moderately graphics intensive applications outputting to screens or image files.

The source code can be found at [GitHub](https://github.com/Uberi/Canvas-AHK).

Overview
--------
* Surfaces are where things are drawn.
* Viewports display surfaces on the screen.
* Pens and brushes define what the drawn things look like.
* Fonts define what drawn text looks like.

Types
-----
In the documentation, types are denoted by parentheses. For example, `X` (units) means that `X` is a Unit type, and represents a distance or a dimension.

### Units
Units represent distances and dimensions (real number).

Each unit corresponds to one pixel on the screen.

Units are represented using a cartesian coordinate system, where an increase in the X-axis value corresponds to rightwards and an increase in the Y-axis value corresponds to downwards. The origin can be found at the top left corner.

### Angles
Angles are measured in degrees from the reference line, clockwise. The reference line is vertical and is directed towards the negative Y-axis:

    A
    |  B
    | /
    |/
    C

The reference line is AC, with the origin at C and directed towards A. Therefore, the angle is represented by ACB.

### Colors
Color references represent a specific color and transparency (integer). They are written in hexadecimal ARGB format.

Each byte of the four byte color reference forms a single component, and each component is between the range of 0x00 to 0xFF (0 to 255 in decimal):

    0x40FF0000
      AARRGGBB

| Component | Description |
|:----------|:------------|
| A         | Alpha       |
| R         | Red         |
| G         | Green       |
| B         | Blue        |

### Point Set
Point sets represent one or more 2-dimensional coordinate pairs.

Point sets are arrays of points, which are themselves 1-indexed arrays with two elements each, the first representing the X-axis coordinate (units), the second the Y-axis coordinate (units):

    [[X1,Y1],[X2,Y2]]

Exceptions
----------
There are two types of exceptions that may be thrown by this library: invalid input and internal errors.

Exceptions may be thrown when functions are called with invalid input, when properties are set to invalid values, or when the library encounters an error internally and cannot continue. Any function call or setting of a property is capable of throwing an exception.

By the time an exception is thrown, any temporary resources have already been cleaned up. It is not necessary to clean up anything manually.

### Invalid Input
Exceptions of this type take the following form:

    throw Exception("INVALID_INPUT",-1,Extra)

Invalid input exceptions represent errors in the input given to a function, such as passing a string when a number was expected, or a decimal number when an integer was expected.

This type of exception is defined by its message being the string "INVALID_INPUT" (Exception.Message). The caller of the function throwing the error will be the exception's routine (Exception.What). Detailed information about the error is available in the exception's extended information (Exception.Extra), but should be used only for debugging purposes.

### Internal Error
Exceptions of this type take the following form:

    throw Exception("INTERNAL_ERROR",A_ThisFunc,Extra)

Internal error exceptions represent errors in the operation of a function, such as a failed drawing command or an out-of-memory error.

This type of exception is defined by its message being the string "INTERNAL_ERROR" (Exception.Message). The function throwing the error will be the exception's routine (Exception.What). Detailed information about the error is available in the exception's extended information (Exception.Extra), but should be used only for debugging purposes.

Transforms
----------
Transforms are changes applied to all drawing operations on a surface done while it is in effect. They work only on the surface they are applied to.

Transforms do not affect previous drawing operations or those done when the transform is removed.

Transforms work on top of each other. Applying one transform, and then another, results in both transforms being applied, rather than the second overwriting the first. Each transform modifies the current transformation state.

Each surface has its own independent transform stack. This is a stack that can store transformation states. Using the `Canvas.Surface.Push()` and `Canvas.Surface.Pop()` functions, one can save and restore the current transformation state.

Canvas
------
The Canvas class is not to be instaniated and serves mainly to provide general initialization and cleanup functions, as well as to contain its submodules.

### Canvas.Lenient()
Disables most error checking routines in submodules. This may improve performance somewhat, though invalid input or internal errors may not be detected.

This setting applies globally to all Canvas-related objects in the program, and is recommended for use only if performance concerns outweigh reliability concerns.

Surfaces
--------
Surfaces represent and allow the manipulation of graphics properties and data. This may include drawing, painting, and more.

See the [Surface reference](Modules/Surface.md) for complete documentation about this class.

Viewports
---------
Viewports represent output displays. This may include windows, controls, or the entire screen.

See the [Viewport reference](Modules/Viewport.md) for complete documentation about this class.

Pens
----
Pens represent drawing properties such as color or width, and are used to draw the outlines of shapes in graphics operations.

See the [Pen reference](Modules/Pen.md) for complete documentation about this class.

Brushes
-------
Brushes represent fill properties such as color or texture, and are used to fill the interior of shapes in graphics operations.

See the [Brush reference](Modules/Brush.md) for complete documentation about this class.

Font
----
Fonts represent text properties such as typeface and line height, and are used to draw text in graphics operations.

See the [Font reference](Modules/Font.md) for complete documentation about this class.