Surfaces
--------
Surfaces represent and allow the manipulation of graphics properties and data. This may include drawing, painting, and more.

Surfaces are implemented in the Canvas.Surface class.

### Canvas.Surface.__New(Width = 1,Height = 1)
Creates a surface object representing a set of graphics properties and data, having a width of `Width` (units) and height `Height` (units).

Returns the new surface object.

### Canvas.Surface.Interpolation := "None"
Represents the current interpolation mode of the surface (interpolation style). Interpolation modes define the appearance of surfaces when scaled.

Interpolation styles are one of the following values:

| Style  | Effect                                                                                                         |
|:-------|:---------------------------------------------------------------------------------------------------------------|
| None   | Pixels are sampled according to the nearest neighbor. Suitable for fast, low quality, or pixelated effects.    |
| Linear | Pixels are linearly sampled across the source values. Suitable for medium quality and reasonably fast effects. |
| Cubic  | Pixels are sampled according to a cubic spline. Suitable for high quality, slower effects.                     |

### Canvas.Surface.Smooth := "None"
Represents the current smooth mode of the surface (smooth style). Smooth modes define the appearance and antialiasing of objects drawn onto the surface.

Smooth styles are one of the following values:

| Style | Effect                                                                                          |
|:------|:------------------------------------------------------------------------------------------------|
| None  | Objects are not smoothed or antialiased. Suitable for fast, low quality, or pixelated effects.  |
| Good  | Objects are smoothed and antialiased at medium quality. Suitable for reasonably fast effects.   |
| Best  | Objects are smoothed and antialiased at high quality. Suitable for slower but smoother effects. |

### Canvas.Surface.Compositing := "Blend"
Represents the current compositing mode of the surface (compositing style). Compositing styles define how objects drawn onto the surface interact with existing data on the surface.

| Style     | Effect                                                                                              |
|:----------|:----------------------------------------------------------------------------------------------------|
| Blend     | Objects are blended with the data already on the surface, calculated using individual alpha values. |
| Overwrite | Objects are directly drawn onto the surface, without regard for what is already there.              |

### Canvas.Surface.Width
The width of the surface (units). Should not be modified.

### Canvas.Surface.Height
The height of the surface (units). Should not be modified.

### Canvas.Surface.Clone()
Creates a new, independent surface with the same properties and contents as the current surface.

Returns the new surface object.

### Canvas.Surface.Clear(Color = 0x00000000)
Clears the entire surface to a color defined by `Color` (color).

Returns the surface object.

### Canvas.Surface.Draw(Surface,X = 0,Y = 0,W = "",H = "",SourceX = 0,SourceY = 0,SourceW = "",SourceH = "") ;wip: streamline
Draws the contents of `Surface` (surface) starting from X-axis coordinate `SourceX` (units) and Y-axis coordinate `SourceY` (units), with width `SourceW` (units) and height `SourceH` (units), at X-axis coordinate `X` (units) and Y-axis coordinate `Y` (units), with width `W` (units) and height `H` (units).

Returns the surface object.

### Canvas.Surface.GetPixel(X,Y,ByRef Color)
Obtains the color value of the pixel at X-axis coordinate `X` (integer units) and Y-axis coordinate `Y` (integer units) and stores it in `Color` (color). The coordinates must represent a pixel within the bitmap.

Returns the surface object.

### Canvas.Surface.SetPixel(X,Y,Color)
Sets the color value of the pixel at X-axis coordinate `X` (integer units) and Y-axis coordinate `Y` (integer units). The coordinates must represent a pixel within the bitmap.

Returns the surface object.

### Canvas.Surface.DrawArc(Pen,X,Y,W,H,Start,Sweep)
Draws an arc of an ellipse at X-axis coordinate `X` (units) and Y-axis coordinate `Y` (units), with width `W` (units) and height `H` (units), starting at `Start` (angle) and sweeping for `Sweep` (angle). The coordinates and dimensions define the bounding rectangle of the ellipse if it were to be drawn in full.

Returns the surface object.

### Canvas.DrawCurve(Pen,Points,Closed = False,Tension = 1)
Draws a cardinal spline as a curved line with `Pen` (pen), passing through each point in `Points` (point set). If `Closed` (boolean) is set, the curve will be drawn as the outline of a closed shape. Otherwise, the curve is open. The curve's bend flexibility is denoted by `Tension` (0 to 1 inclusive), where 0 results in straight lines between points and 1 results in a Catmull-Rom/neutral spline. Tension is proportional to the length of each tangent.

Returns the surface object.

### Canvas.Surface.DrawEllipse(Pen,X,Y,W,H)
Draws the outline of an ellipse at X-axis coordinate `X` (units) and Y-axis coordinate `Y` (units), with width `W` (units) and height `H` (units). The coordinates and dimensions define the bounding box of the ellipse.

Returns the surface object.

### Canvas.Surface.DrawPie(Pen,X,Y,W,H,Start,Sweep)
Draws the outline of a pie (an arc with lines leading from the end to the center) of an ellipse with `Pen` (pen) at X-axis coordinate `X` (units) and Y-axis coordinate `Y` (units), with width `W` (units) and height `H` (units), starting at `Start` (angle) and sweeping for `Sweep` (angle). The coordinates and dimensions define the bounding rectangle of the ellipse if it were to be drawn in full.

Returns the surface object.

### Canvas.Surface.DrawPolygon(Pen,Points)
Draws the outline of a closed polygon with `Pen` (pen), with the vertices defined by `Points` (point set).

Returns the surface object.

### Canvas.Surface.DrawRectangle(Pen,X,Y,W,H)
Draws the outline of a rectangle with `Pen` (pen) at X-axis coordinate `X` (units) and Y-axis coordinate `Y` (units), with width `W` (units) and height `H` (units).

Returns the surface object.

### Canvas.Surface.FillCurve(Brush,Points)
Fills the area of a closed cardinal spline with `Brush` (brush), passing through each point in `Points` (point set).

Returns the surface object.

### Canvas.Surface.FillEllipse(Brush,X,Y,W,H)
Fills the area of an ellipse with `Brush` (brush) at X-axis coordinate `X` (units) and Y-axis coordinate `Y` (units), with width `W` (units) and height `H` (units). The coordinates and dimensions define the bounding rectangle of the ellipse.

Returns the surface object.

### Canvas.Surface.FillPie(Brush,X,Y,W,H,Start,Sweep)
Fills the area of a pie (an arc with lines leading from the end to the center) of an ellipse with `Brush` (brush) at X-axis coordinate `X` (units) and Y-axis coordinate `Y` (units), with width `W` (units) and height `H` (units), starting at `Start` (angle) and sweeping for `Sweep` (angle). The coordinates and dimensions define the bounding rectangle of the ellipse if it were to be drawn in full.

Returns the surface object.

### Canvas.Surface.FillPolygon(Brush,Points)
Fills the area of a closed polygon with `Brush` (brush), with the vertices defined by `Points` (point set).

Returns the surface object.

### Canvas.Surface.FillRectangle(Brush,X,Y,W,H)
Fills the area of a rectangle with `Brush` (brush) at X-axis coordinate `X` (units) and Y-axis coordinate `Y` (units), with width `W` (units) and height `H` (units).

Returns the surface object.

### Canvas.Surface.Line(Pen,X1,Y1,X2,Y2)
Draws a single line with `Pen` (pen), starting at X-axis coordinate `X1` (units) and Y-axis coordinate `Y1` (units), ending at X-axis coordinate `X2` (units) and Y-axis coordinate `Y2` (units).

Returns the surface object.

### Canvas.Surface.Lines(Pen,Points)
Draws a series of connected lines with `Pen` (pen), at coordinates defined by `Points` (point set).

Returns the surface object.

### Canvas.Surface.Text(Brush,Font,Value,X,Y,W = "",H = "")
Draws `Text` (text) with `Brush` (brush) and `Font` (font), at X-axis coordinate `X` (units) and baseline Y-axis coordinate `Y` (units). If width `W` (units) is specified, the text is drawn with that width. If height `H` (units) is specified, the text is drawn with that height. Otherwise, both dimensions are assumed to be those of the text's bounding box.

### Canvas.Surface.Push()
Pushes the current surface state onto the state stack. The surface state includes the current translation, rotation, and scaling, as well as properties such as the smoothing mode.

Returns the surface object.

### Canvas.Surface.Pop()
Pops the top entry of the state stack off and sets the current surface state to the entry's state. The surface state includes the current translation, rotation, and scaling, as well as properties such as the smoothing mode.

Returns the surface object.

### Canvas.Surface.Translate(X,Y)
Translates the current transformation state by `X` (units) along the X-axis and `Y` (units) along the Y-axis.

Returns the surface object.

### Canvas.Surface.Rotate(Angle)
Rotates the current transformation state by `Angle` (angle).

Returns the surface object.

### Canvas.Surface.Scale(X,Y)
Scales the current transformation state by a factor of `X` (units) along the X-axis and `Y` (units) along the Y-axis.