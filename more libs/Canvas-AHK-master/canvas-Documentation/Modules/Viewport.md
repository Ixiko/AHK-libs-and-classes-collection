Viewports
=========
Viewports represent output displays. This may include windows, controls, or the entire screen.

A Canvas.Surface instance attached to a viewport will have its contents displayed in the viewport's window.

Viewports are implemented in the Canvas.Viewport class.

### Canvas.Viewport.__New(hWindow)
Creates a viewport object representing a window referenced by the window handle `hWindow` (hwnd).

Returns the new viewport object.

### Canvas.Viewport.Attach(Surface)
Attaches surface `Surface` (Canvas.Surface) to the viewport so that it is displayed by the viewport.

Returns the viewport object.

### Canvas.Viewport.Detach()
Detaches the currently attached surface, so that it is no longer displayed by the viewport.

Returns the viewport object.

### Canvas.Viewport.Refresh(X = 0,Y = 0,W = 0,H = 0)
Refreshes the viewport to reflect changes in a region of its attached surface defined by X-axis coordinate `X` (positive or zero units), Y-axis coordinate `Y` (positive or zero units), width `W` (positive or zero units), and height `H` (positive or zero units).

If `W` is zero, it will be interpreted as the width of the currently attached surface (Canvas.Surface.Width). If `H` is zero, it will be interpreted as the height of the currently attached surface (Canvas.Surface.Height).

Returns the viewport object.