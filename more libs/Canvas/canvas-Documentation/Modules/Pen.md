Pens
----
Pens represent drawing properties such as color or width, and are used to draw the outlines of shapes in graphics operations.

Pens are implemented in the Canvas.Pen class.

### Canvas.Pen.__New(Color = 0xFFFFFFFF,Width = 1)
Creates a pen object representing a set of drawing properties, with color defined by `Color` (color) and width defined by `Width` (units).

Returns the new pen object.

### Canvas.Pen.Color
Represents the current color of the pen (color). Can be set to change the current color.

### Canvas.Pen.Width
Represents the current width of the pen (units). Can be set to change the current width.

### Canvas.Pen.Join := "Miter"
Represents the current join style of the pen (join style). Can be set to change the current join style. Join styles define how the points where lines join are displayed when drawing multiple connected lines.

Join styles are one of the following values:

| Style | Effect                                                                                      |
|:------|:--------------------------------------------------------------------------------------------|
| Miter | Extend the outer edges of the lines being joined so that they meet, forming a sharp corner. |
| Bevel | Clips the intersection of the outer edges such that it forms a cut corner.                  |
| Round | Fills the intersection of the outer edges with part of an ellipse.                          |

### Canvas.Pen.Type := "Solid"
Represents the current type of the pen (type style). Can be set to change the current type style. Type styles define the appearance of the pen, such as stippling/dashing.

| Style   | Effect                                                                      |
|:--------|:----------------------------------------------------------------------------|
| Solid   | Continuous, unbroken lines.                                                 |
| Dash    | Longer line segments divided by shorter breaks at regular intervals.        |
| Dot     | Dots spaced at regular short intervals along the line.                      |
| DashDot | Alternation between longer line segments and dots at equal short intervals. |

### Canvas.Pen.StartCap := "Flat"
Represents the start cap style of the pen (cap style). Can be set to change the current start cap style. Start cap styles define how the starting points of lines are displayed.

Cap styles are one of the following values:

| Style    | Effect                                                  |
|:---------|:--------------------------------------------------------|
| Flat     | Flat end at the point.                                  |
| Square   | Flat end past the point by half the width of the pen.   |
| Round    | Round end with center of rounding at the point.         |
| Triangle | Tapered protrusion at the point, aligned with the line. |

### Canvas.Pen.EndCap := "Flat"
Represents the end cap style of the pen (cap style). Can be set to change the current end cap style. End cap styles define how the ending points of lines are displayed.