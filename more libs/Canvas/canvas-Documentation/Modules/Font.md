Font
----
Fonts represent text properties such as typeface and line height, and are used to draw text in graphics operations.

Fonts are implemented in the Canvas.Font class.

### Canvas.Font.__New(Typeface,Size)
Creates a font object representing a set of text properties, with typeface defined by `Typeface` (string) and font size defined by `Size` (positive real number). The typeface must exist on the current system.

Returns the new font object.

### Canvas.Font.Typeface
Represents the current typeface of the font (string). Can be set to change the current typeface.

### Canvas.Font.Size
Represents the current line height of the font (positive real number). Can be set to change the current line height.

### Canvas.Font.Bold := False
Represents whether the font is currently bold (boolean). Can be set to change whether the font is currently bold. Bold text is drawn in a heavier weight.

### Canvas.Font.Italic := False
Represents whether the font is currently italic (boolean). Can be set to change whether the font is currently italic. Italic text is drawn at an angle relative to the baseline.

### Canvas.Font.Underline := False
Represents whether the font is currently underlined (boolean). Can be set to change whether the font is currently underlined. Underlined text is drawn with a line underneath.

### Canvas.Font.Strikeout := False
Represents whether the font is currently struck out (boolean). Can be set to change whether the font is currently struck out. Struck out text is drawn with a line through the vertical center.

### Canvas.Font.Align := "Left"
Represents the current text alignment of the font (align style). Can be set to change the current text alignment.

Align styles are one of the following values:

| Style  | Effect                                                                                |
|:-------|:--------------------------------------------------------------------------------------|
| Left   | The text is drawn starting at the X-axis coordinate specified.                        |
| Center | The text is drawn with the center on the X-axis coordinate specified.                 |
| Right  | The text is drawn starting at the left and ending at the X-axis coordinate specified. |

### Canvas.Font.Measure(Value,ByRef Width,ByRef Height)
Determines the width and height of the bounding box of `Value` (text) if it were to be drawn with the font. The resulting numbers can be found in the variables passed as `Width` and `Height`.

Returns the font object.