class ID2D1Factory extends IUnknown
{
  __new(p=""){
		if (p=""){
			DllCall("LoadLibrary","str","d2d1.dll")
			,DllCall("d2d1\D2D1CreateFactory","uint",0,"ptr",GUID(CLSID,"{06152247-6f50-465a-9245-118bfd3b6007}"),"uint*",0,"ptr*",pIFactory)
			if this.__:=pIFactory
				this._v:=NumGet(this.__+0)
			else return
		}else if !p
			return
		else this.__:=p,this._v:=NumGet(this.__+0)
	}
	
	; Forces the factory to refresh any system defaults that it might have changed since factory creation.
	; You should call this method before calling the GetDesktopDpi method, to ensure that the system DPI is current.
	ReloadSystemMetrics(){
		return D2D1_hr(DllCall(this.vt(3),"ptr",this.__,"uint"),"ReloadSystemMetrics")
	}
	
	; Retrieves the current desktop dots per inch (DPI). To refresh this value, call ReloadSystemMetrics.
	; Use this method to obtain the system DPI when setting physical pixel values, such as when you specify the size of a window.
	; Example uses the GetDesktopDpi method to obtain the system DPI and set the initial size of a window. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371316%28v=vs.85%29.aspx
	GetDesktopDpi(){
		D2D1_hr(DllCall(this.vt(4),"ptr",this.__,"Float*",dpiX,"Float*",dpiY,"uint"),"GetDesktopDpi")
		return [dpiX,dpiY] ; 96,96
	}
	
	; Creates an ID2D1RectangleGeometry. 
	CreateRectangleGeometry(rectangle){ ; D2D1_RECT_F
		D2D1_hr(DllCall(this.vt(5),"ptr",this.__
			,"ptr",IsObject(rectangle)?rectangle[]:rectangle
			,"ptr*",rectangleGeometry
			,"uint"),"CreateRectangleGeometry")
		return new ID2D1RectangleGeometry(rectangleGeometry)
	}
	
	; Creates an ID2D1RoundedRectangleGeometry. 
	CreateRoundedRectangleGeometry(roundedRectangle){ ; D2D1_ROUNDED_RECT
		D2D1_hr(DllCall(this.vt(6),"ptr",this.__
			,"ptr",IsObject(roundedRectangle)?roundedRectangle[]:roundedRectangle
			,"ptr*",roundedRectangleGeometry
			,"uint"),"CreateRoundedRectangleGeometry")
		return new ID2D1RoundedRectangleGeometry(roundedRectangleGeometry)
	}
	
	; Creates an ID2D1EllipseGeometry. 
	; Example creates two ID2D1EllipseGeometry objects and combines them using the different geometry combine modes. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371265%28v=vs.85%29.aspx
	CreateEllipseGeometry(ellipse){ ; D2D1_ELLIPSE
		D2D1_hr(DllCall(this.vt(7),"ptr",this.__
			,"ptr",IsObject(ellipse)?ellipse[]:ellipse
			,"ptr*",ellipseGeometry
			,"uint"),"CreateEllipseGeometry")
		return new ID2D1EllipseGeometry(ellipseGeometry)
	}
	
	; Creates an ID2D1GeometryGroup, which is an object that holds other geometries.
	; Geometry groups are a convenient way to group several geometries simultaneously so all figures of several distinct geometries are concatenated into one. To create a ID2D1GeometryGroup object, call the CreateGeometryGroup method on the ID2D1Factory object, passing in the fillMode with possible values of D2D1_FILL_MODE_ALTERNATE (alternate) and D2D1_FILL_MODE_WINDING, an array of geometry objects to add to the geometry group, and the number of elements in this array. 
	CreateGeometryGroup(fillMode,geometries,geometriesCount){ ; D2D1_FILL_MODE,ID2D1Geometry
		D2D1_hr(DllCall(this.vt(8),"ptr",this.__
			,"int",fillMode
			,"ptr",IsObject(geometries)?geometries.__:geometries
			,"uint",geometriesCount
			,"ptr*",geometryGroup
			,"uint"),"CreateGeometryGroup")
		return new ID2D1GeometryGroup(geometryGroup)
	}
	
	; Transforms the specified geometry and stores the result as an ID2D1TransformedGeometry object. 
	; Like other resources, a transformed geometry inherits the resource space and threading policy of the factory that created it. This object is immutable.
	; When stroking a transformed geometry with the DrawGeometry method, the stroke width is not affected by the transform applied to the geometry. The stroke width is only affected by the world transform.
	; Example creates an ID2D1RectangleGeometry, then draws it without transforming it. It produces the output shown in the following illustration. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371304%28v=vs.85%29.aspx
	CreateTransformedGeometry(sourceGeometry,transform){ ; ID2D1Geometry , D2D1_MATRIX_3X2_F
		D2D1_hr(DllCall(this.vt(9),"ptr",this.__
			,"ptr",IsObject(sourceGeometry)?sourceGeometry.__:sourceGeometry
			,"ptr",IsObject(transform)?transform[]:transform
			,"ptr*",transformedGeometry
			,"uint"),"CreateTransformedGeometry")
		return new ID2D1TransformedGeometry(transformedGeometry)
	}
	
	; Creates an empty ID2D1PathGeometry.
	CreatePathGeometry(){
	D2D1_hr(DllCall(this.vt(10),"ptr",this.__,"ptr*",pathGeometry,"uint"),"CreatePathGeometry")
	return new ID2D1PathGeometry(pathGeometry)
	}
	
	; Creates an ID2D1StrokeStyle that describes start cap, dash pattern, and other features of a stroke.
	; Example creates a stroke that uses a custom dash pattern. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371298%28v=vs.85%29.aspx
	CreateStrokeStyle(strokeStyleProperties,dashes,dashesCount){ ; D2D1_STROKE_STYLE_PROPERTIES , 
		D2D1_hr(DllCall(this.vt(11),"ptr",this.__
			,"ptr",IsObject(strokeStyleProperties)?strokeStyleProperties[]:strokeStyleProperties
			,"ptr",dashes
			,"uint",dashesCount
			,"ptr*",strokeStyle
			,"uint"),"CreateStrokeStyle")
		return new ID2D1StrokeStyle(strokeStyle)
	}
	
	; Creates an ID2D1DrawingStateBlock that can be used with the SaveDrawingState and RestoreDrawingState methods of a render target.
	CreateDrawingStateBlock(drawingStateDescription,textRenderingParams){ ; D2D1_DRAWING_STATE_DESCRIPTION , IDWriteRenderingParams , 
		D2D1_hr(DllCall(this.vt(12),"ptr",this.__
			,"ptr",IsObject(drawingStateDescription)?drawingStateDescription[]:drawingStateDescription
			,"ptr",IsObject(textRenderingParams)?textRenderingParams.__:textRenderingParams
			,"ptr*",drawingStateBlock
			,"uint"),"CreateDrawingStateBlock")
		return new ID2D1DrawingStateBlock(drawingStateBlock)
	}
	
	; Creates a render target that renders to a Microsoft Windows Imaging Component (WIC) bitmap.
	; You must use D2D1_FEATURE_LEVEL_DEFAULT for the minLevel member of the renderTargetProperties parameter with this method.
	; Your application should create render targets once and hold onto them for the life of the application or until the D2DERR_RECREATE_TARGET error is received. When you receive this error, you need to recreate the render target (and any resources it created).
	CreateWicBitmapRenderTarget(target,renderTargetProperties){ ; IWICBitmap , D2D1_RENDER_TARGET_PROPERTIES
		D2D1_hr(DllCall(this.vt(13),"ptr",this.__
			,"ptr",IsObject(target)?target.__:target
			,"ptr",IsObject(renderTargetProperties)?renderTargetProperties[]:renderTargetProperties
			,"ptr*",renderTarget
			,"uint"),"CreateWicBitmapRenderTarget")
		return new ID2D1RenderTarget(renderTarget)
	}
	
	; Creates an ID2D1HwndRenderTarget, a render target that renders to a window.
	; When you create a render target and hardware acceleration is available, you allocate resources on the computer's GPU. By creating a render target once and retaining it as long as possible, you gain performance benefits. Your application should create render targets once and hold onto them for the life of the application or until the D2DERR_RECREATE_TARGET error is received. When you receive this error, you need to recreate the render target (and any resources it created).
	CreateHwndRenderTarget(renderTargetProperties,hwndRenderTargetProperties){ ; D2D1_RENDER_TARGET_PROPERTIES , D2D1_HWND_RENDER_TARGET_PROPERTIES
		D2D1_hr(DllCall(this.vt(14),"ptr",this.__
			,"ptr",IsObject(renderTargetProperties)?renderTargetProperties[]:renderTargetProperties
			,"ptr",IsObject(hwndRenderTargetProperties)?hwndRenderTargetProperties[]:hwndRenderTargetProperties
			,"ptr*",hwndRenderTarget
			,"uint"),"CreateHwndRenderTarget")
		return new ID2D1HwndRenderTarget(hwndRenderTarget)
	}
	
	; Creates a render target that draws to a DirectX Graphics Infrastructure (DXGI) surface. 
/*
	To write to a Direct3D surface, you obtain an IDXGISurface and pass it to the CreateDxgiSurfaceRenderTarget method to create a DXGI surface render target; you can then use the DXGI surface render target to draw 2-D content to the DXGI surface.
	A DXGI surface render target is a type of ID2D1RenderTarget. Like other Direct2D render targets, you can use it to create resources and issue drawing commands.
	The DXGI surface render target and the DXGI surface must use the same DXGI format. If you specify the DXGI_FORMAT_UNKOWN format when you create the render target, it will automatically use the surface's format.
	The DXGI surface render target does not perform DXGI surface synchronization.
	For more information about creating and using DXGI surface render targets, see the Direct2D and Direct3D Interoperability Overview.
	To work with Direct2D, the Direct3D device that provides the IDXGISurface must be created with the D3D10_CREATE_DEVICE_BGRA_SUPPORT flag.
	When you create a render target and hardware acceleration is available, you allocate resources on the computer's GPU. By creating a render target once and retaining it as long as possible, you gain performance benefits. Your application should create render targets once and hold onto them for the life of the application or until the render target's EndDraw method returns the D2DERR_RECREATE_TARGET error. When you receive this error, you need to recreate the render target (and any resources it created). 
*/
	; Example obtains a DXGI surface (pBackBuffer) from an IDXGISwapChain and uses it to create a DXGI surface render target. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371264%28v=vs.85%29.aspx
	CreateDxgiSurfaceRenderTarget(dxgiSurface,renderTargetProperties){ ; IDXGISurface , D2D1_RENDER_TARGET_PROPERTIES
		D2D1_hr(DllCall(this.vt(15),"ptr",this.__
			,"ptr",IsObject(dxgiSurface)?dxgiSurface.__:dxgiSurface
			,"ptr",IsObject(renderTargetProperties)?renderTargetProperties[]:renderTargetProperties
			,"ptr*",renderTarget
			,"uint"),"CreateDxgiSurfaceRenderTarget")
		return new ID2D1RenderTarget(renderTarget)
	}
	
	; Creates a render target that draws to a Windows Graphics Device Interface (GDI) device context.
	; Before you can render with a DC render target, you must use the render target's BindDC method to associate it with a GDI DC. Do this for each different DC and whenever there is a change in the size of the area you want to draw to.
	; To enable the DC render target to work with GDI, set the render target's DXGI format to DXGI_FORMAT_B8G8R8A8_UNORM and alpha mode to D2D1_ALPHA_MODE_PREMULTIPLIED or D2D1_ALPHA_MODE_IGNORE.
	; Your application should create render targets once and hold on to them for the life of the application or until the render target's EndDraw method returns the D2DERR_RECREATE_TARGET error. When you receive this error, recreate the render target (and any resources it created).
	; Example creates a DC render target. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371248%28v=vs.85%29.aspx
	CreateDCRenderTarget(renderTargetProperties){ ; D2D1_RENDER_TARGET_PROPERTIES
		D2D1_hr(DllCall(this.vt(16),"ptr",this.__
			,"ptr",IsObject(renderTargetProperties)?renderTargetProperties[]:renderTargetProperties
			,"ptr*",dcRenderTarget
			,"uint"),"CreateDCRenderTarget")
		return new ID2D1DCRenderTarget(dcRenderTarget)
	}
}
;;
;;ID2D1Resource
;;
class ID2D1Resource extends IUnknown
{
	; Retrieves the factory associated with this resource.
	GetFactory(){
		D2D1_hr(DllCall(this.vt(3),"ptr",this.__,"ptr*",factory,"uint"),"GetFactory")
		return new ID2D1Factory(factory)
	}
}

class ID2D1RenderTarget extends ID2D1Resource
{
	; Creates a Direct2D bitmap from a pointer to in-memory source data.
	CreateBitmap(x,y,srcData,pitch,bitmapProperties){ ; D2D1_SIZE_U , D2D1_BITMAP_PROPERTIES
		D2D1_hr(DllCall(this.vt(4),"ptr",this.__
			,"uint",x,"uint",y
			,"ptr",srcData
			,"uint",pitch
			,"ptr",IsObject(bitmapProperties)?bitmapProperties[]:bitmapProperties
			,"ptr*",bitmap
			,"uint"),"CreateBitmap")
		return new ID2D1Bitmap(bitmap)
	}
	
	; Creates an ID2D1Bitmap by copying the specified Microsoft Windows Imaging Component (WIC) bitmap.
	; Before Direct2D can load a WIC image, it must be converted to a supported pixel format and alpha mode. For a list of supported pixel formats and alpha modes, see Supported Pixel Formats and Alpha Modes. 
	CreateBitmapFromWicBitmap(wicBitmapSource,bitmapProperties){ ; IWICBitmapSource
		D2D1_hr(DllCall(this.vt(5),"ptr",this.__
			,"ptr",IsObject(wicBitmapSource)?wicBitmapSource.__:wicBitmapSource
			,"ptr",IsObject(bitmapProperties)?bitmapProperties[]:bitmapProperties
			,"ptr*",bitmap
			,"uint"),"CreateBitmapFromWicBitmap")
		return new ID2D1Bitmap(bitmap)
	}
	
	; Creates an ID2D1Bitmap whose data is shared with another resource.
/*
	The CreateSharedBitmap method is useful for efficiently reusing bitmap data and can also be used to provide interoperability with Direct3D.
	
	Sharing an ID2D1Bitmap
	By passing an ID2D1Bitmap created by a render target that is resource-compatible, you can share a bitmap with that render target; both the original ID2D1Bitmap and the new ID2D1Bitmap created by this method will point to the same bitmap data. For more information about when render target resources can be shared, see the Sharing Render Target Resources section of the Resources Overview.
	You may also use this method to reinterpret the data of an existing bitmap and specify a new DPI or alpha mode. For example, in the case of a bitmap atlas, an ID2D1Bitmap may contain multiple sub-images, each of which should be rendered with a different D2D1_ALPHA_MODE (D2D1_ALPHA_MODE_PREMULTIPLIED or D2D1_ALPHA_MODE_IGNORE). You could use the CreateSharedBitmap method to reinterpret the bitmap using the desired alpha mode without having to load a separate copy of the bitmap into memory.
	
	Sharing an IDXGISurface
	When using a DXGI surface render target (an ID2D1RenderTarget object created by the CreateDxgiSurfaceRenderTarget method), you can pass an IDXGISurface surface to the CreateSharedBitmap method to share video memory with Direct3D and manipulate Direct3D content as an ID2D1Bitmap. As described in the Resources Overview, the render target and the IDXGISurface must be using the same Direct3D device.
	Note also that the IDXGISurface must use one of the supported pixel formats and alpha modes described in Supported Pixel Formats and Alpha Modes.
	For more information about interoperability with Direct3D, see the Direct2D and Direct3D Interoperability Overview.
	
	Sharing an IWICBitmapLock
	An IWICBitmapLock stores the content of a WIC bitmap and shields it from simultaneous accesses. By passing an IWICBitmapLock to the CreateSharedBitmap method, you can create an ID2D1Bitmap that points to the bitmap data already stored in the IWICBitmapLock.
	To use an IWICBitmapLock with the CreateSharedBitmap method, the render target must use software rendering. To force a render target to use software rendering, set to D2D1_RENDER_TARGET_TYPE_SOFTWARE the type field of the D2D1_RENDER_TARGET_PROPERTIES structure that you use to create the render target. To check whether an existing render target uses software rendering, use the IsSupported method.
*/
	CreateSharedBitmap(riid,data,bitmapProperties){ ; D2D1_BITMAP_PROPERTIES
		D2D1_hr(DllCall(this.vt(6),"ptr",this.__
			,"ptr",riid
			,"ptr",data
			,"ptr",IsObject(bitmapProperties)?bitmapProperties[]:bitmapProperties
			,"ptr*",bitmap
			,"uint"),"CreateSharedBitmap")
		return new ID2D1Bitmap(bitmap)
	}
	
	; Creates an ID2D1BitmapBrush from the specified bitmap.
	CreateBitmapBrush(bitmap,bitmapBrushProperties=0,brushProperties=0){ ; ID2D1Bitmap , D2D1_BITMAP_BRUSH_PROPERTIES , D2D1_BRUSH_PROPERTIES
		D2D1_hr(DllCall(this.vt(7),"ptr",this.__
			,"ptr",IsObject(bitmap)?bitmap.__:bitmap
			,"ptr",IsObject(bitmapBrushProperties)?bitmapBrushProperties[]:bitmapBrushProperties
			,"ptr",IsObject(brushProperties)?brushProperties[]:brushProperties
			,"ptr*",bitmapBrush
			,"uint"),"CreateBitmapBrush")
		return new ID2D1BitmapBrush(bitmapBrush)
	}
	
	; Creates a new ID2D1SolidColorBrush that has the specified color and opacity. 
	CreateSolidColorBrush(color,brushProperties=0){ ; D2D1_COLOR_F , D2D1_BRUSH_PROPERTIES
		D2D1_hr(DllCall(this.vt(8),"ptr",this.__
			,"ptr",IsObject(color)?color[]:color
			,"ptr",IsObject(brushProperties)?brushProperties[]:brushProperties
			,"ptr*",solidColorBrush
			,"uint"),"CreateSolidColorBrush")
		return new ID2D1SolidColorBrush(solidColorBrush)
	}
	
	; Creates an ID2D1GradientStopCollection from the specified gradient stops that uses the D2D1_GAMMA_2_2 color interpolation gamma and the clamp extend mode.
	CreateGradientStopCollection(gradientStops,gradientStopsCount,colorInterpolationGamma,extendMode){ ; D2D1_GRADIENT_STOP , D2D1_GAMMA , D2D1_EXTEND_MODE
		D2D1_hr(DllCall(this.vt(9),"ptr",this.__
			,"ptr",gradientStops
			,"uint",gradientStopsCount
			,"uint",colorInterpolationGamma
			,"uint",extendMode
			,"ptr*",gradientStopCollection
			,"uint"),"CreateGradientStopCollection")
		return new ID2D1GradientStopCollection(gradientStopCollection)
	}
	
	; Creates an ID2D1LinearGradientBrush that contains the specified gradient stops and has the specified transform and base opacity. 
	CreateLinearGradientBrush(linearGradientBrushProperties,brushProperties,gradientStopCollection){ ; D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES , D2D1_BRUSH_PROPERTIES , ID2D1GradientStopCollection
		D2D1_hr(DllCall(this.vt(10),"ptr",this.__
			,"ptr",IsObject(linearGradientBrushProperties)?linearGradientBrushProperties[]:linearGradientBrushProperties
			,"ptr",IsObject(brushProperties)?brushProperties[]:brushProperties
			,"ptr",IsObject(gradientStopCollection)?gradientStopCollection.__:gradientStopCollection
			,"ptr*",linearGradientBrush
			,"uint"),"CreateLinearGradientBrush")
		return new ID2D1LinearGradientBrush(linearGradientBrush)
	}
	
	; Creates an ID2D1RadialGradientBrush that contains the specified gradient stops and has the specified transform and base opacity. 
	CreateRadialGradientBrush(radialGradientBrushProperties,brushProperties,gradientStopCollection){ ; D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES , D2D1_BRUSH_PROPERTIES , ID2D1GradientStopCollection
		D2D1_hr(DllCall(this.vt(11),"ptr",this.__
			,"ptr",IsObject(radialGradientBrushProperties)?radialGradientBrushProperties[]:radialGradientBrushProperties
			,"ptr",IsObject(brushProperties)?brushProperties[]:brushProperties
			,"ptr",IsObject(gradientStopCollection)?gradientStopCollection.__:gradientStopCollection
			,"ptr*",radialGradientBrush
			,"uint"),"CreateRadialGradientBrush")
		return new ID2D1RadialGradientBrush(radialGradientBrush)
	}
	
	; Creates a bitmap render target for use during intermediate offscreen drawing that is compatible with the current render target. 
/*
	This method creates a render target that can be used for intermediate offscreen drawing. The intermediate render target is created in the same location (on the same adapter or in system memory) as the original render target, which allows efficient rendering of the intermediate results to the final target. The DPI, bit depth, pixel format (with the exception of alpha mode), and color space all default to those of the original render target.
	The pixel size and DPI of the new render target can be modified by specifying values for desiredSize or desiredPixelSize:
		If desiredSize is specified but desiredPixelSize is not, the pixel size is computed from the desired size using the parent target DPI. If the desiredSize maps to a integer-pixel size, the DPI of the compatible render target is the same as the DPI of the parent target. If desiredSize maps to a fractional-pixel size, the pixel size is rounded up to the nearest integer and the DPI for the compatible render target is slightly higher than the DPI of the parent render target. In all cases, the coordinate (desiredSize.width, desiredSize.height) maps to the lower-right corner of the compatible render target.
		If the desiredPixelSize is specified and desiredSize is not, the DPI of the new render target is the same as the original render target.
		If both desiredSize and desiredPixelSize are specified, the DPI of the new render target is computed to account for the difference in scale.
		If neither desiredSize nor desiredPixelSize is specified, the new render target size and DPI match the original render target.
*/
	CreateCompatibleRenderTarget(desiredSize,desiredPixelSize,desiredFormat,options){ ; D2D1_SIZE_F , D2D1_SIZE_U , D2D1_PIXEL_FORMAT , D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS
		D2D1_hr(DllCall(this.vt(12),"ptr",this.__
			,"ptr",IsObject(desiredSize)?desiredSize[]:desiredSize
			,"ptr",IsObject(desiredPixelSize)?desiredPixelSize[]:desiredPixelSize
			,"ptr",IsObject(desiredFormat)?desiredFormat[]:desiredFormat
			,"int",options
			,"ptr*",bitmapRenderTarget
			,"uint"),"CreateCompatibleRenderTarget")
		return new ID2D1BitmapRenderTarget(bitmapRenderTarget)
	}
	
	; Creates a layer resource that can be used with this render target and its compatible render targets. The new layer has the specified initial size.
	; Regardless of whether a size is initially specified, the layer automatically resizes as needed.
	; Example uses a layer to clip a bitmap to a geometric mask. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371838%28v=vs.85%29.aspx
	CreateLayer(size){ ;D2D1_SIZE_F
		D2D1_hr(DllCall(this.vt(13),"ptr",this.__
			,"ptr",IsObject(size)?size[]:size
			,"ptr*",layer
			,"uint"),"CreateLayer")
		return new ID2D1Layer(layer)
	}
	
	; Create a mesh that uses triangles to describe a shape.
	; To populate a mesh, use its Open method to obtain an ID2D1TessellationSink. To draw the mesh, use the render target's FillMesh method.
	CreateMesh(){
		D2D1_hr(DllCall(this.vt(14),"ptr",this.__
			,"ptr*",mesh
			,"uint"),"CreateMesh")
		return new ID2D1Mesh(mesh)
	}
	
	; When method fails, it does not return an error code. To determine whether a drawing method (such as DrawRectangle) failed, check the result returned by the ID2D1RenderTarget::EndDraw or ID2D1RenderTarget::Flush method. 
	
	; Draws a line between the specified points using the specified stroke style. 
	; Example uses the DrawLine method to create a grid that spans the width and height of the render target. The width and height information is provided by the rtSize variable.
	DrawLine(point0,point1,point2,point3,brush,strokeWidth,strokeStyle){ ; D2D1_POINT_2F , ID2D1Brush , ID2D1StrokeStyle
		DllCall(this.vt(15),"ptr",this.__
			,"float",point0,"float",point1
			,"float",point2,"float",point3
			,"ptr",IsObject(brush)?brush.__:brush
			,"float",strokeWidth
			,"ptr",IsObject(strokeStyle)?strokeStyle.__:strokeStyle)
	}
	
	; Draws the outline of a rectangle that has the specified dimensions and stroke style. 
	DrawRectangle(rect,brush,strokeWidth,strokeStyle){ ; D2D1_RECT_F , ID2D1Brush , ID2D1StrokeStyle
		DllCall(this.vt(16),"ptr",this.__
			,"ptr",IsObject(rect)?rect[]:rect
			,"ptr",IsObject(brush)?brush.__:brush
			,"float",strokeWidth
			,"ptr",IsObject(strokeStyle)?strokeStyle.__:strokeStyle)
	}
	
	; Paints the interior of the specified rectangle. 
	FillRectangle(rect,brush){ ; D2D1_RECT_F , ID2D1Brush
		DllCall(this.vt(17),"ptr",this.__
			,"ptr",IsObject(rect)?rect[]:rect
			,"ptr",IsObject(brush)?brush.__:brush)
	}
	
	; Draws the outline of the specified rounded rectangle using the specified stroke style.
	DrawRoundedRectangle(roundedRect,brush,strokeWidth,strokeStyle){ ; D2D1_ROUNDED_RECT , ID2D1Brush , ID2D1StrokeStyle
		DllCall(this.vt(18),"ptr",this.__
			,"ptr",IsObject(roundedRect)?roundedRect[]:roundedRect
			,"ptr",IsObject(brush)?brush.__:brush
			,"float",strokeWidth
			,"ptr",IsObject(strokeStyle)?strokeStyle.__:strokeStyle)
	}
	
	; Paints the interior of the specified rounded rectangle.
	; Example uses the DrawRoundedRectangle and FillRoundedRectangle methods to outline and fill a rounded rectangle. This example produces the output shown in the following illustration. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371959%28v=vs.85%29.aspx
	FillRoundedRectangle(roundedRect,brush){ ; D2D1_ROUNDED_RECT , ID2D1Brush
		DllCall(this.vt(19),"ptr",this.__
			,"ptr",IsObject(roundedRect)?roundedRect[]:roundedRect
			,"ptr",IsObject(brush)?brush.__:brush)
	}
	
	; Draws the outline of the specified ellipse using the specified stroke style. 
	DrawEllipse(ellipse,brush,strokeWidth,strokeStyle){ ; D2D1_ELLIPSE , ID2D1Brush , ID2D1StrokeStyle
		DllCall(this.vt(20),"ptr",this.__
			,"ptr",IsObject(ellipse)?ellipse[]:ellipse
			,"ptr",IsObject(brush)?brush.__:brush
			,"float",strokeWidth
			,"ptr",IsObject(strokeStyle)?strokeStyle.__:strokeStyle)
	}
	
	; Paints the interior of the specified ellipse. 
	FillEllipse(ellipse,brush){ ; D2D1_ELLIPSE , ID2D1Brush
		DllCall(this.vt(21),"ptr",this.__
			,"ptr",IsObject(ellipse)?ellipse[]:ellipse
			,"ptr",IsObject(brush)?brush.__:brush)
	}
	
	; Draws the outline of the specified geometry using the specified stroke style. 
	DrawGeometry(geometry,brush,strokeWidth,strokeStyle){ ; ID2D1Geometry , ID2D1Brush , ID2D1StrokeStyle
		DllCall(this.vt(22),"ptr",this.__
			,"ptr",IsObject(geometry)?geometry.__:geometry
			,"ptr",IsObject(brush)?brush.__:brush
			,"float",strokeWidth
			,"ptr",IsObject(strokeStyle)?strokeStyle.__:strokeStyle)
	}
	
	; Paints the interior of the specified geometry. 
	; If the opacityBrush parameter is not NULL, the alpha value of each pixel of the mapped opacityBrush is used to determine the resulting opacity of each corresponding pixel of the geometry. Only the alpha value of each color in the brush is used for this processing; all other color information is ignored. The alpha value specified by the brush is multiplied by the alpha value of the geometry after the geometry has been painted by brush. 
	FillGeometry(geometry,brush,opacityBrush=0){ ; ID2D1Geometry , ID2D1Brush
		DllCall(this.vt(23),"ptr",this.__
			,"ptr",IsObject(geometry)?geometry.__:geometry
			,"ptr",IsObject(brush)?brush.__:brush
			,"ptr",IsObject(opacityBrush)?opacityBrush.__:opacityBrush)
	}
	
	; Paints the interior of the specified mesh.
	; The current antialias mode of the render target must be D2D1_ANTIALIAS_MODE_ALIASED when FillMesh is called. To change the render target's antialias mode, use the SetAntialiasMode method.
	; FillMesh does not expect a particular winding order for the triangles in the ID2D1Mesh; both clockwise and counter-clockwise will work. 
	FillMesh(mesh,brush){ ; ID2D1Mesh , ID2D1Brush
		DllCall(this.vt(24),"ptr",this.__
			,"ptr",IsObject(mesh)?mesh.__:mesh
			,"ptr",IsObject(brush)?brush.__:brush)
	}
	
	; Applies the opacity mask described by the specified bitmap to a brush and uses that brush to paint a region of the render target. 
	; For this method to work properly, the render target must be using the D2D1_ANTIALIAS_MODE_ALIASED antialiasing mode. You can set the antialiasing mode by calling the ID2D1RenderTarget::SetAntialiasMode method.
	FillOpacityMask(opacityMask,brush,content,destinationRectangle=0,sourceRectangle=0){ ; ID2D1Bitmap , ID2D1Brush , D2D1_OPACITY_MASK_CONTENT , D2D1_RECT_F 
		DllCall(this.vt(25),"ptr",this.__
			,"ptr",IsObject(opacityMask)?opacityMask.__:opacityMask
			,"ptr",IsObject(brush)?brush.__:brush
			,"int",content
			,"ptr",IsObject(destinationRectangle)?destinationRectangle[]:destinationRectangle
			,"ptr",IsObject(sourceRectangle)?sourceRectangle[]:sourceRectangle)
	}
	
	; Draws the specified bitmap after scaling it to the size of the specified rectangle. 
	DrawBitmap(bitmap,destinationRectangle=0,opacity=1,interpolationMode=0,sourceRectangle=0){ ; ID2D1Bitmap , D2D1_RECT_F , D2D1_BITMAP_INTERPOLATION_MODE , D2D1_RECT_F
		return DllCall(this.vt(26),"ptr",this.__
			,"ptr",IsObject(bitmap)?bitmap.__:bitmap
			,"ptr",IsObject(destinationRectangle)?destinationRectangle[]:destinationRectangle
			,"float",opacity
			,"uint",interpolationMode
			,"ptr",IsObject(sourceRectangle)?sourceRectangle[]:sourceRectangle)
	}
	
	; Draws the specified text using the format information provided by an IDWriteTextFormat object. 
	; To create an IDWriteTextFormat object, create an IDWriteFactory and call its CreateTextFormat method.
	DrawText(string,stringLength,textFormat,layoutRect,defaultForegroundBrush,options,measuringMode=0){ ; IDWriteTextFormat , D2D1_RECT_F , ID2D1Brush , D2D1_DRAW_TEXT_OPTIONS , DWRITE_MEASURING_MODE
		DllCall(this.vt(27),"ptr",this.__
			,"str",string
			,"uint",stringLength
			,"ptr",IsObject(textFormat)?textFormat.__:textFormat
			,"ptr",IsObject(layoutRect)?layoutRect[]:layoutRect
			,"ptr",IsObject(defaultForegroundBrush)?defaultForegroundBrush.__:defaultForegroundBrush
			,"int",options
			,"int",measuringMode)
	}
	
	; Draws the formatted text described by the specified IDWriteTextLayout object.
	; When drawing the same text repeatedly, using the DrawTextLayout method is more efficient than using the DrawText method because the text doesn't need to be formatted and the layout processed with each call.
	DrawTextLayout(origin0,origin1,textLayout,defaultForegroundBrush,options=0){ ; D2D1_POINT_2F , IDWriteTextLayout , ID2D1Brush , D2D1_DRAW_TEXT_OPTIONS
		DllCall(this.vt(28),"ptr",this.__
			,"float",origin0,"float",origin1
			,"ptr",IsObject(textLayout)?textLayout.__:textLayout
			,"ptr",IsObject(defaultForegroundBrush)?defaultForegroundBrush.__:defaultForegroundBrush
			,"uint",options)
	}
	
	; Draws the specified glyphs. 
	DrawGlyphRun(baselineOrigin0,baselineOrigin1,glyphRun,foregroundBrush,measuringMode=0){ ; D2D1_POINT_2F , DWRITE_GLYPH_RUN , ID2D1Brush , DWRITE_MEASURING_MODE
		DllCall(this.vt(29),"ptr",this.__
			,"float",baselineOrigin0,"float",baselineOrigin1
			,"ptr",IsObject(glyphRun)?glyphRun[]:glyphRun
			,"ptr",IsObject(foregroundBrush)?foregroundBrush.__:foregroundBrush
			,"int",measuringMode)
	}
	
	; Applies the specified transform to the render target, replacing the existing transformation. All subsequent drawing operations occur in the transformed space.
	; Example uses the SetTransform method to apply a rotation to the render target. http://msdn.microsoft.com/en-us/library/windows/desktop/dd316901%28v=vs.85%29.aspx
	SetTransform(transform){ ; D2D1_MATRIX_3X2_F
		DllCall(this.vt(30),"ptr",this.__,"ptr",transform)
	}
	
	; Gets the current transform of the render target. 
	GetTransform(){ ; D2D1_MATRIX_3X2_F
		DllCall(this.vt(31),"ptr",this.__,"ptr*",transform)
		return transform
	}
	
	; Sets the antialiasing mode of the render target. The antialiasing mode applies to all subsequent drawing operations, excluding text and glyph drawing operations. 
	; To specify the antialiasing mode for text and glyph operations, use the SetTextAntialiasMode method. 
	SetAntialiasMode(antialiasMode){ ; D2D1_ANTIALIAS_MODE
		DllCall(this.vt(32),"ptr",this.__,"uint",antialiasMode)
	}
	
	; Retrieves the current antialiasing mode for nontext drawing operations.
	GetAntialiasMode(){
		DllCall(this.vt(33),"ptr",this.__) ; D2D1_ANTIALIAS_MODE
	}
	
	; Specifies the antialiasing mode to use for subsequent text and glyph drawing operations. 
	SetTextAntialiasMode(textAntialiasMode){ ; D2D1_TEXT_ANTIALIAS_MODE
		DllCall(this.vt(34),"ptr",this.__,"uint",textAntialiasMode)
	}
	
	; Gets the current antialiasing mode for text and glyph drawing operations. 
	GetTextAntialiasMode(){
		DllCall(this.vt(35),"ptr",this.__) ; D2D1_TEXT_ANTIALIAS_MODE
	}
	
	; If the settings specified by textRenderingParams are incompatible with the render target's text antialiasing mode (specified by SetTextAntialiasMode), subsequent text and glyph drawing operations will fail and put the render target into an error state.
	
	; Specifies text rendering options to be applied to all subsequent text and glyph drawing operations. 
	SetTextRenderingParams(textRenderingParams=0){ ; IDWriteRenderingParams
		return D2D1_hr(DllCall(this.vt(36),"ptr",this.__
			,"ptr",IsObject(textRenderingParams)?textRenderingParams.__:textRenderingParams
			,"uint"),"SetTextRenderingParams")
	}
	
	; Retrieves the render target's current text rendering options. 
	GetTextRenderingParams(){
		D2D1_hr(DllCall(this.vt(37),"ptr",this.__,"ptr*",textRenderingParams,"uint"),"GetTextRenderingParams")
		return new IDWriteRenderingParams(textRenderingParams)
	}
	
	; Specifies a label for subsequent drawing operations. 
	; The labels specified by this method are printed by debug error messages. If no tag is set, the default value for each tag is 0.
	SetTags(tag1,tag2){ ; D2D1_TAG
		return D2D1_hr(DllCall(this.vt(38),"ptr",this.__,"uint64",tag1,"uint64",tag2,"uint"),"SetTags")
	}
	
	; Gets the label for subsequent drawing operations. 
	; If the same address is passed for both parameters, both parameters receive the value of the second tag. 
	GetTags(){
		D2D1_hr(DllCall(this.vt(39),"ptr",this.__,"uint64*",tag1,"uint64*",tag2,"uint"),"GetTags")
		return [tag1,tag2]
	}
	
	; Adds the specified layer to the render target so that it receives all subsequent drawing operations until PopLayer is called. 
	; The PushLayer method allows a caller to begin redirecting rendering to a layer. All rendering operations are valid in a layer. The location of the layer is affected by the world transform set on the render target. 
	; Each PushLayer must have a matching PopLayer call. If there are more PopLayer calls than PushLayer calls, the render target is placed into an error state. If Flush is called before all outstanding layers are popped, the render target is placed into an error state, and an error is returned. The error state can be cleared by a call to EndDraw.
	; A particular ID2D1Layer resource can be active only at one time. In other words, you cannot call a PushLayer method, and then immediately follow with another PushLayer method with the same layer resource. Instead, you must call the second PushLayer method with different layer resources. 
	PushLayer(layerParameters,layer){ ; D2D1_LAYER_PARAMETERS , ID2D1Layer
		DllCall(this.vt(40),"ptr",this.__
			,"ptr",IsObject(layerParameters)?layerParameters[]:layerParameters
			,"ptr",IsObject(layer)?layer.__:layer)
	}
	
	; Stops redirecting drawing operations to the layer that is specified by the last PushLayer call. 
	; A PopLayer must match a previous PushLayer call.
	; Example uses a layer to clip a bitmap to a geometric mask. http://msdn.microsoft.com/en-us/library/windows/desktop/dd316852%28v=vs.85%29.aspx
	PopLayer(){
		DllCall(this.vt(41),"ptr",this.__)
	}
	
	; Executes all pending drawing commands. 
	; If the method succeeds, it returns S_OK. Otherwise, it returns an HRESULT error code and sets tag1 and tag2 to the tags that were active when the error occurred. If no error occurred, this method sets the error tag state to be (0,0).
	Flush(){
		D2D1_hr(DllCall(this.vt(42),"ptr",this.__,"uint64*",tag1,"uint64*",tag2,"uint"),"Flush")
		return [tag1,tag2]
	}
	
	; Saves the current drawing state to the specified ID2D1DrawingStateBlock.
	SaveDrawingState(drawingStateBlock){ ; ID2D1DrawingStateBlock
		DllCall(this.vt(43),"ptr",this.__,"ptr",IsObject(drawingStateBlock)?drawingStateBlock.__:drawingStateBlock)
	}
	
	; Sets the render target's drawing state to that of the specified ID2D1DrawingStateBlock.
	RestoreDrawingState(drawingStateBlock){ ; ID2D1DrawingStateBlock
		DllCall(this.vt(44),"ptr",this.__,"ptr",IsObject(drawingStateBlock)?drawingStateBlock.__:drawingStateBlock)
	}
	
	; A PushAxisAlignedClip/PopAxisAlignedClip pair can occur around or within a PushLayer/PopLayer pair, but may not overlap. For example, a PushAxisAlignedClip, PushLayer, PopLayer, PopAxisAlignedClip sequence is valid, but a PushAxisAlignedClip, PushLayer, PopAxisAlignedClip, PopLayer sequence is not.
	; PopAxisAlignedClip must be called once for every call to PushAxisAlignedClip.
	; This method doesn't return an error code if it fails. To determine whether a drawing operation (such as PopAxisAlignedClip) failed, check the result returned by the ID2D1RenderTarget::EndDraw or ID2D1RenderTarget::Flush methods. 

	; Specifies a rectangle to which all subsequent drawing operations are clipped. 
	; The clipRect is transformed by the current world transform set on the render target. After the transform is applied to the clipRect that is passed in, the axis-aligned bounding box for the clipRect is computed. For efficiency, the contents are clipped to this axis-aligned bounding box and not to the original clipRect that is passed in. 
	; More Remarks, http://msdn.microsoft.com/en-us/library/windows/desktop/dd316856%28v=vs.85%29.aspx
	PushAxisAlignedClip(clipRect,antialiasMode){ ; D2D1_RECT_F , D2D1_ANTIALIAS_MODE
		DllCall(this.vt(45),"ptr",this.__
			,"ptr",IsObject(clipRect)?clipRect[]:clipRect
			,"uint",antialiasMode)
	}
	
	; Removes the last axis-aligned clip from the render target. After this method is called, the clip is no longer applied to subsequent drawing operations. 
	; More Remarks, http://msdn.microsoft.com/en-us/library/windows/desktop/dd316850%28v=vs.85%29.aspx
	PopAxisAlignedClip(){
		DllCall(this.vt(46),"ptr",this.__)
	}
	
	; Clears the drawing area to the specified color. 
	; Direct2D interprets the clearColor as straight alpha (not premultiplied). If the render target's alpha mode is D2D1_ALPHA_MODE_IGNORE, the alpha channel of clearColor is ignored and replaced with 1.0f (fully opaque).
	; If the render target has an active clip (specified by PushAxisAlignedClip), the clear command is applied only to the area within the clip region.
	Clear(D2D1_COLOR_F=0){ ; D2D1_COLOR_F
		DllCall(this.vt(47),"ptr",this.__,"ptr",IsObject(D2D1_COLOR_F)?D2D1_COLOR_F[]:D2D1_COLOR_F)
	}
	
/*
	Drawing operations can only be issued between a BeginDraw and EndDraw call.
	BeginDraw and EndDraw are used to indicate that a render target is in use by the Direct2D system. Different implementations of ID2D1RenderTarget might behave differently when BeginDraw is called. An ID2D1BitmapRenderTarget may be locked between BeginDraw/EndDraw calls, a DXGI surface render target might be acquired on BeginDraw and released on EndDraw, while an ID2D1HwndRenderTarget may begin batching at BeginDraw and may present on EndDraw, for example.
	The BeginDraw method must be called before rendering operations can be called, though state-setting and state-retrieval operations can be performed even outside of BeginDraw/EndDraw.
	After BeginDraw is called, a render target will normally build up a batch of rendering commands, but defer processing of these commands until either an internal buffer is full, the Flush method is called, or until EndDraw is called. The EndDraw method causes any batched drawing operations to complete, and then returns an HRESULT indicating the success of the operations and, optionally, the tag state of the render target at the time the error occurred. The EndDraw method always succeeds: it should not be called twice even if a previous EndDraw resulted in a failing HRESULT.
	If EndDraw is called without a matched call to BeginDraw, it returns an error indicating that BeginDraw must be called before EndDraw. Calling BeginDraw twice on a render target puts the target into an error state where nothing further is drawn, and returns an appropriate HRESULT and error information when EndDraw is called. 
*/
	
	; Initiates drawing on this render target. 
	BeginDraw(){
		DllCall(this.vt(48),"ptr",this.__)
	}
	
	; Ends drawing operations on the render target and indicates the current error state and associated tags. 
	EndDraw(){
		D2D1_hr(DllCall(this.vt(49),"ptr",this.__,"uint64*",tag1,"uint64*",tag2,"uint"),"EndDraw")
		return [tag1,tag2]
	}
	
	; Retrieves the pixel format and alpha mode of the render target. 
	GetPixelFormat(){
		h:=DllCall(this.vt(50),"ptr",this.__,"int64") ; D2D1_PIXEL_FORMAT
		return D2D1_Struct("D2D1_PIXEL_FORMAT",&h) ; DXGI_FORMAT , D2D1_ALPHA_MODE
	}
	
	; This method specifies the mapping from pixel space to device-independent space for the render target. If both dpiX and dpiY are 0, the factory-read system DPI is chosen. If one parameter is zero and the other unspecified, the DPI is not changed.
	; For ID2D1HwndRenderTarget, the DPI defaults to the most recently factory-read system DPI. The default value for all other render targets is 96 DPI. 

	; Sets the dots per inch (DPI) of the render target. 
	SetDpi(dpiX,dpiY){
		DllCall(this.vt(51),"ptr",this.__,"float",dpiX,"float",dpiY)
	}
	
	; Return the render target's dots per inch (DPI).
	GetDpi(){
		DllCall(this.vt(52),"ptr",this.__,"float*",dpiX,"float*",dpiY)
		return [dpiX,dpiY]
	}
	
	; Returns the size of the render target in device-independent pixels.
	GetSize(){
		h:=DllCall(this.vt(53),"ptr",this.__,"int64")
		return D2D1_Struct("D2D1_SIZE_F",&h) ; float x,float y
	}
	
	; Returns the size of the render target in device pixels.
	GetPixelSize(){
	h:=D2D1_hr(DllCall(this.vt(54),"ptr",this.__,"int64","uint"),"GetPixelSize")
	return D2D1_Struct("D2D1_SIZE_U",&h) ; uint x,uint y
	}
	
	; Gets the maximum size, in device-dependent units (pixels), of any one bitmap dimension supported by the render target.
	; This method returns the maximum texture size of the Direct3D device.
	; Note  The software renderer and WARP devices return the value of 16 megapixels (16*1024*1024). You can create a Direct2D texture that is this size, but not a Direct3D texture that is this size.
	GetMaximumBitmapSize(){
		return DllCall(this.vt(55),"ptr",this.__,"uint")
	}
	
	; Indicates whether the render target supports the specified properties.
	; This method does not evaluate the DPI settings specified by the renderTargetProperties parameter.
	IsSupported(renderTargetProperties){ ; D2D1_RENDER_TARGET_PROPERTIES
		return DllCall(this.vt(56),"ptr",this.__,"ptr",IsObject(renderTargetProperties)?renderTargetProperties[]:renderTargetProperties)
	}
}
class ID2D1BitmapRenderTarget extends ID2D1RenderTarget
{
	; Retrieves the bitmap for this render target. The returned bitmap can be used for drawing operations. 
	; The DPI for the ID2D1Bitmap obtained from GetBitmap will be the DPI of the ID2D1BitmapRenderTarget when the render target was created. Changing the DPI of the ID2D1BitmapRenderTarget by calling SetDpi doesn't affect the DPI of the bitmap, even if SetDpi is called before GetBitmap. Using SetDpi to change the DPI of the ID2D1BitmapRenderTarget does affect how contents are rendered into the bitmap: it just doesn't affect the DPI of the bitmap retrieved by GetBitmap.
	; Example uses the CreateCompatibleRenderTarget method to create an ID2D1BitmapRenderTarget and uses it to draw a grid pattern. The grid pattern is used as the source of an ID2D1BitmapBrush. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371150%28v=vs.85%29.aspx
	GetBitmap(){
		D2D1_hr(DllCall(this.vt(57),"ptr",this.__,"ptr*",bitmap,"uint"),"GetBitmap")
		return new ID2D1Bitmap(bitmap)
	}
}
class ID2D1HwndRenderTarget extends ID2D1RenderTarget
{
	; Indicates whether the HWND associated with this render target is occluded. 
	; Note  If the window was occluded the last time that EndDraw was called, the next time that the render target calls CheckWindowState, it will return D2D1_WINDOW_STATE_OCCLUDED regardless of the current window state. If you want to use CheckWindowState to determine the current window state, you should call CheckWindowState after every EndDraw call and ignore its return value. This call will ensure that your next call to CheckWindowState state will return the actual window state.
	CheckWindowState(){
		return DllCall(this.vt(57),"ptr",this.__) ; D2D1_WINDOW_STATE
	}
	
	; Changes the size of the render target to the specified pixel size.
	; After this method is called, the contents of the render target's back-buffer are not defined, even if the D2D1_PRESENT_OPTIONS_RETAIN_CONTENTS option was specified when the render target was created.
	Resize(pixelSize){ ; D2D1_SIZE_U
		return D2D1_hr(DllCall(this.vt(58),"ptr",this.__,"ptr",IsObject(pixelSize)?pixelSize[]:pixelSize,"uint"),"Resize")
	}
	
	; Returns the HWND associated with this render target.
	GetHwnd(){
		return DllCall(this.vt(59),"ptr",this.__)
	}
}
class ID2D1DCRenderTarget extends ID2D1RenderTarget
{
	; Binds the render target to the device context to which it issues drawing commands.
	; Before you can render with the DC render target, you must use its BindDC method to associate it with a GDI DC. You do this each time you use a different DC, or the size of the area you want to draw to changes.
	; Example binds a DC to the ID2D1DCRenderTarget. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371214%28v=vs.85%29.aspx
	BindDC(hDC,pSubRect){ ; RECT
		return D2D1_hr(DllCall(this.vt(57),"ptr",this.__,"ptr",hDC,"ptr",IsObject(pSubRect)?pSubRect[]:pSubRect,"uint"),"BindDC")
	}
}

class ID2D1Brush extends ID2D1Resource
{
	; Sets the degree of opacity of this brush.
	SetOpacity(opacity){ ; range 0–1
		DllCall(this.vt(4),"ptr",this.__,"float",opacity)
	}
	
	; Sets the transformation applied to the brush.
	SetTransform(transform){ ; D2D1_MATRIX_3X2_F
		DllCall(this.vt(5),"ptr",this.__,"ptr",IsObject(transform)?transform[]:transform)
	}
	
	; Gets the degree of opacity of this brush. 
	GetOpacity(){
		return DllCall(this.vt(6),"ptr",this.__,"float")
	}
	
	; Gets the transform applied to this brush. 
	GetTransform(){
		transform:=D2D1_Struct("D2D1_MATRIX_3X2_F")
		DllCall(this.vt(7),"ptr",this.__,"ptr",transform[])
		return transform
	}
}
class ID2D1BitmapBrush extends ID2D1Brush
{
	; Sometimes, the bitmap for a bitmap brush doesn't completely fill the area being painted. When this happens, Direct2D uses the brush's horizontal (SetExtendModeX) and vertical (SetExtendModeY) extend mode settings to determine how to fill the remaining area.
	; More Remarks, http://msdn.microsoft.com/en-us/library/windows/desktop/dd371139%28v=vs.85%29.aspx

	; Specifies how the brush horizontally tiles those areas that extend past its bitmap. 
	SetExtendModeX(extendModeX){ ; D2D1_EXTEND_MODE
		DllCall(this.vt(8),"ptr",this.__,"int",extendModeX)
	}
	
	; Specifies how the brush vertically tiles those areas that extend past its bitmap.
	SetExtendModeY(extendModeY){
		DllCall(this.vt(9),"ptr",this.__,"int",extendModeY)
	}
	
	; Specifies the interpolation mode used when the brush bitmap is scaled or rotated.
	; This method sets the interpolation mode for a bitmap, which is an enum value that is specified in the D2D1_BITMAP_INTERPOLATION_MODE enumeration type. D2D1_BITMAP_INTERPOLATION_MODE_NEAREST_NEIGHBOR represents nearest neighbor filtering. It looks up the nearest bitmap pixel to the current rendering pixel and chooses its exact color. D2D1_BITMAP_INTERPOLATION_MODE_LINEAR represents linear filtering, and interpolates a color from the four nearest bitmap pixels.
	; The interpolation mode of a bitmap also affects subpixel translations. In a subpixel translation, bilinear interpolation positions the bitmap more precisely to the application requests, but blurs the bitmap in the process. 
	SetInterpolationMode(interpolationMode){ ; D2D1_BITMAP_INTERPOLATION_MODE
		DllCall(this.vt(10),"ptr",this.__,"int",interpolationMode)
	}
	
	; Specifies the bitmap source that this brush uses to paint. 
	; This method specifies the bitmap source that this brush uses to paint. The bitmap is not resized or rescaled automatically to fit the geometry that it fills. The bitmap stays at its native size. To resize or translate the bitmap, use the SetTransform method to apply a transform to the brush. 
	; The native size of a bitmap is the width and height in bitmap pixels, divided by the bitmap DPI. This native size forms the base tile of the brush. To tile a subregion of the bitmap, you must generate a new bitmap containing this subregion and use SetBitmap to apply it to the brush. 
	SetBitmap(bitmap){ ; ID2D1Bitmap
		DllCall(this.vt(11),"ptr",this.__,"ptr",IsObject(bitmap)?bitmap.__:bitmap)
	}
	
	; Like all brushes, ID2D1BitmapBrush defines an infinite plane of content. Because bitmaps are finite, it relies on an extend mode to determine how the plane is filled horizontally and vertically.
	
	; Gets the method by which the brush horizontally tiles those areas that extend past its bitmap. 
	GetExtendModeX(){
		return DllCall(this.vt(12),"ptr",this.__,"int") ; D2D1_EXTEND_MODE
	}
	
	; Gets the method by which the brush vertically tiles those areas that extend past its bitmap. 
	GetExtendModeY(){
		return DllCall(this.vt(13),"ptr",this.__,"int") ; D2D1_EXTEND_MODE
	}
	
	; Gets the interpolation method used when the brush bitmap is scaled or rotated. 
	GetInterpolationMode(){
		return DllCall(this.vt(A_PtrSize),"ptr",this.__,"int") ; D2D1_BITMAP_INTERPOLATION_MODE
	}
	
	; Gets the bitmap source that this brush uses to paint.
	GetBitmap(){
		DllCall(this.vt(15),"ptr",this.__,"ptr*",bitmap)
		return new ID2D1Bitmap(bitmap)
	}
}
class ID2D1SolidColorBrush extends ID2D1Brush
{
	; Specifies the color of this solid color brush. 
	; To help create colors, Direct2D provides the ColorF class. It offers several helper methods for creating colors and provides a set or predefined colors. 
	SetColor(color){ ; D2D1_COLOR_F
		return DllCall(this.vt(8),"ptr",this.__,"ptr",IsObject(color)?color[]:color)
	}
	
	; Retrieves the color of the solid color brush.
	GetColor(){
		return D2D1_Struct("D2D1_COLOR_F",DllCall(this.vt(9),"ptr",this.__))
	}
}
class ID2D1LinearGradientBrush extends ID2D1Brush
{
	; The start point and end point are described in the brush's space and are mapped to the render target when the brush is used. If there is a non-identity brush transform or render target transform, the brush's start point and end point are also transformed.

	; Sets the starting coordinates of the linear gradient in the brush's coordinate space. 
	SetStartPoint(startPoint){ ; D2D1_POINT_2F
		return DllCall(this.vt(8),"ptr",this.__,"ptr",IsObject(startPoint)?startPoint[]:startPoint)
	}
	
	; Sets the ending coordinates of the linear gradient in the brush's coordinate space.
	SetEndPoint(endPoint){ ; D2D1_POINT_2F
		return DllCall(this.vt(9),"ptr",this.__,"ptr",IsObject(endPoint)?endPoint[]:endPoint)
	}

	; Retrieves the starting coordinates of the linear gradient. 
	GetStartPoint(){
		return D2D1_Struct("D2D1_POINT_2F",DllCall(this.vt(10),"ptr",this.__))
	}
	
	; Retrieves the ending coordinates of the linear gradient. 
	GetEndPoint(){
		return D2D1_Struct("D2D1_POINT_2F",DllCall(this.vt(11),"ptr",this.__))
	}
	
	; Retrieves the ID2D1GradientStopCollection associated with this linear gradient brush.
	; ID2D1GradientStopCollection contains an array of D2D1_GRADIENT_STOP structures and information, such as the extend mode and the color interpolation mode.
	GetGradientStopCollection(){
		DllCall(this.vt(12),"ptr",this.__,"ptr*",gradientStopCollection)
		return new ID2D1GradientStopCollection(gradientStopCollection)
	}
}
class ID2D1RadialGradientBrush extends ID2D1Brush
{
	; Specifies the center of the gradient ellipse in the brush's coordinate space. 
	SetCenter(center){ ; D2D1_POINT_2F
		return DllCall(this.vt(8),"ptr",this.__,"ptr",IsObject(center)?center[]:center)
	}
	
	; Specifies the offset of the gradient origin relative to the gradient ellipse's center.
	SetGradientOriginOffset(gradientOriginOffset){ ; D2D1_POINT_2F
		return DllCall(this.vt(9),"ptr",this.__,"ptr",IsObject(gradientOriginOffset)?gradientOriginOffset[]:gradientOriginOffset)
	}
	
	; Specifies the x-radius of the gradient ellipse, in the brush's coordinate space.
	SetRadiusX(radiusX){
		return DllCall(this.vt(10),"ptr",this.__,"float",radiusX)
	}
	
	; Specifies the y-radius of the gradient ellipse, in the brush's coordinate space. 
	SetRadiusY(radiusY){
		return DllCall(this.vt(11),"ptr",this.__,"float",radiusY)
	}
	
	; Retrieves the center of the gradient ellipse. 
	GetCenter(){
		return D2D1_Struct("D2D1_POINT_2F",DllCall(this.vt(12),"ptr",this.__))
	}
	
	; Retrieves the offset of the gradient origin relative to the gradient ellipse's center. 
	GetGradientOriginOffset(){
		return D2D1_Struct("D2D1_POINT_2F",DllCall(this.vt(13),"ptr",this.__))
	}
	
	; Retrieves the x-radius of the gradient ellipse. 
	GetRadiusX(){
		return DllCall(this.vt(14),"ptr",this.ptr,"float")
	}
	
	; Retrieves the y-radius of the gradient ellipse. 
	GetRadiusY(){
		return DllCall(this.vt(15),"ptr",this.__,"float")
	}
	
	; Retrieves the ID2D1GradientStopCollection associated with this radial gradient brush object.
	; ID2D1GradientStopCollection contains an array of D2D1_GRADIENT_STOP structures and additional information, such as the extend mode and the color interpolation mode.
	GetGradientStopCollection(){
		DllCall(this.vt(16),"ptr",this.__,"ptr*",gradientStopCollection)
		return new ID2D1GradientStopCollection(gradientStopCollection)
	}
}
;;
;;ID2D1Geometry
;;
class ID2D1Geometry extends ID2D1Resource
{
	; Retrieves the bounds of the geometry.
	GetBounds(worldTransform=0){ ; D2D1_MATRIX_3X2_F
		bounds:=D2D1_Struct("D2D1_RECT_F")
		D2D1_hr(DllCall(this.vt(4),"ptr",this.__
			,"ptr",IsObject(worldTransform)?worldTransform[]:worldTransform
			,"ptr",bounds[]
			,"uint"),"GetBounds")
		return bounds
	}
	
	; Gets the bounds of the geometry after it has been widened by the specified stroke width and style and transformed by the specified matrix.
	GetWidenedBounds(strokeWidth,strokeStyle,worldTransform,flatteningTolerance){ ; ID2D1StrokeStyle , D2D1_MATRIX_3X2_F
		bounds:=D2D1_Struct("D2D1_RECT_F")
		D2D1_hr(DllCall(this.vt(5),"ptr",this.__
			,"float",strokeWidth
			,"ptr",IsObject(strokeStyle)?strokeStyle.__:strokeStyle
			,"ptr",IsObject(worldTransform)?worldTransform[]:worldTransform
			,"float",flatteningTolerance
			,"ptr",bounds[]
			,"uint"),"GetWidenedBounds")
		return bounds
	}
	
	; Determines whether the geometry's stroke contains the specified point given the specified stroke thickness, style, and transform. 
	StrokeContainsPoint(point0,point1,strokeWidth,strokeStyle,worldTransform,flatteningTolerance){ ; D2D1_POINT_2F , ID2D1StrokeStyle , D2D1_MATRIX_3X2_F
		D2D1_hr(DllCall(this.vt(6),"ptr",this.__
			,"float",point0,"float",point1
			,"float",strokeWidth
			,"ptr",IsObject(strokeStyle)?strokeStyle.__:strokeStyle
			,"ptr",IsObject(worldTransform)?worldTransform[]:worldTransform
			,"float",flatteningTolerance
			,"int*",contains
			,"uint"),"StrokeContainsPoint")
		return contains
	}
	
	; Indicates whether the area filled by the geometry would contain the specified point given the specified flattening tolerance. 
	FillContainsPoint(point0,point1,worldTransform,flatteningTolerance){ ; D2D1_POINT_2F , D2D1_MATRIX_3X2_F
		D2D1_hr(DllCall(this.vt(7),"ptr",this.__
			,"float",point0,"float",point1
			,"ptr",IsObject(worldTransform)?worldTransform[]:worldTransform
			,"float",flatteningTolerance
			,"int*",contains
			,"uint"),"FillContainsPoint")
		return contains
	}
	
	; Describes the intersection between this geometry and the specified geometry. The comparison is performed by using the specified flattening tolerance.
	; When interpreting the returned relation value, it is important to remember that the member D2D1_GEOMETRY_RELATION_IS_CONTAINED of the D2D1_GEOMETRY_RELATION enumeration type means that this geometry is contained inside inputGeometry, not that this geometry contains inputGeometry. 
	CompareWithGeometry(inputGeometry,inputGeometryTransform,flatteningTolerance){ ; ID2D1Geometry , D2D1_MATRIX_3X2_F , 
		D2D1_hr(DllCall(this.vt(8),"ptr",this.__
			,"ptr",IsObject(inputGeometry)?inputGeometry.__:inputGeometry
			,"ptr",IsObject(inputGeometryTransform)?inputGeometryTransform[]:inputGeometryTransform
			,"float",flatteningTolerance
			,"int*",relation
			,"uint"),"CompareWithGeometry")
		return relation ; D2D1_GEOMETRY_RELATION
	}
	
	; Creates a simplified version of the geometry that contains only lines and (optionally) cubic Bezier curves and writes the result to an ID2D1SimplifiedGeometrySink.
	Simplify(simplificationOption,worldTransform,flatteningTolerance){ ; D2D1_GEOMETRY_SIMPLIFICATION_OPTION , D2D1_MATRIX_3X2_F
		D2D1_hr(DllCall(this.vt(9),"ptr",this.__
			,"int",simplificationOption
			,"ptr",IsObject(worldTransform)?worldTransform[]:worldTransform
			,"float",flatteningTolerance
			,"ptr*",geometrySink
			,"uint"),"Simplify")
		return new ID2D1SimplifiedGeometrySink(geometrySink)
	}
	
	; Creates a set of clockwise-wound triangles that cover the geometry after it has been transformed using the specified matrix and flattened using the specified tolerance. 
	Tessellate(worldTransform,flatteningTolerance){ ; D2D1_MATRIX_3X2_F
		D2D1_hr(DllCall(this.vt(10),"ptr",this.__
			,"ptr",IsObject(worldTransform)?worldTransform[]:worldTransform
			,"float",flatteningTolerance
			,"ptr*",tessellationSink
			,"uint"),"Tessellate")
		return new ID2D1TessellationSink(tessellationSink)
	}
	
	; Combines this geometry with the specified geometry and stores the result in an ID2D1SimplifiedGeometrySink. 
	; Example uses each of the different combine modes to combine two ID2D1EllipseGeometry objects. http://msdn.microsoft.com/en-us/library/windows/desktop/dd316617%28v=vs.85%29.aspx
	CombineWithGeometry(inputGeometry,combineMode,inputGeometryTransform,flatteningTolerance){ ; ID2D1Geometry , D2D1_COMBINE_MODE , D2D1_MATRIX_3X2_F , ID2D1SimplifiedGeometrySink
		return D2D1_hr(DllCall(this.vt(11),"ptr",this.__
			,"ptr",IsObject(inputGeometry)?inputGeometry.__:inputGeometry
			,"int",combineMode
			,"ptr",IsObject(inputGeometryTransform)?inputGeometryTransform[]:inputGeometryTransform
			,"float",flatteningTolerance
			,"ptr",IsObject(geometrySink)?geometrySink.__:geometrySink
			,"uint"),"CombineWithGeometry")
	}
	
	; Computes the outline of the geometry and writes the result to an ID2D1SimplifiedGeometrySink.
/*
	The Outline method allows the caller to produce a geometry with an equivalent fill to the input geometry, with the following additional properties:
		The output geometry contains no transverse intersections; that is, segments may touch, but they never cross.
		The outermost figures in the output geometry are all oriented counterclockwise.
		The output geometry is fill-mode invariant; that is, the fill of the geometry does not depend on the choice of the fill mode. For more information about the fill mode, see D2D1_FILL_MODE.
	Additionally, the Outline method can be useful in removing redundant portions of said geometries to simplify complex geometries. It can also be useful in combination with ID2D1GeometryGroup to create unions among several geometries simultaneously. 
*/
	Outline(worldTransform,flatteningTolerance){ ; D2D1_MATRIX_3X2_F
		D2D1_hr(DllCall(this.vt(12),"ptr",this.__
			,"ptr",IsObject(worldTransform)?worldTransform[]:worldTransform
			,"float",flatteningTolerance
			,"ptr*",geometrySink
			,"uint"),"Outline")
		return new ID2D1SimplifiedGeometrySink(geometrySink)
	}
	
	; Computes the area of the geometry after it has been transformed by the specified matrix and flattened using the specified tolerance.
	ComputeArea(worldTransform,flatteningTolerance){ ; D2D1_MATRIX_3X2_F
		D2D1_hr(DllCall(this.vt(13),"ptr",this.__
			,"ptr",IsObject(worldTransform)?worldTransform[]:worldTransform
			,"float",flatteningTolerance
			,"float*",area
			,"uint"),"ComputeArea")
		return area
	}
	
	; Calculates the length of the geometry as though each segment were unrolled into a line. 
	ComputeLength(worldTransform,flatteningTolerance){ ; D2D1_MATRIX_3X2_F
		D2D1_hr(DllCall(this.vt(14),"ptr",this.__
			,"ptr",IsObject(worldTransform)?worldTransform[]:worldTransform
			,"float",flatteningTolerance
			,"float*",length
			,"uint"),"ComputeLength")
		return length
	}
	
	; Calculates the point and tangent vector at the specified distance along the geometry after it has been transformed by the specified matrix and flattened using the specified tolerance.
	ComputePointAtLength(length,worldTransform,flatteningTolerance){ ; D2D1_MATRIX_3X2_F
		point:=D2D1_Struct("D2D1_POINT_2F")
		unitTangentVector:=D2D1_Struct("D2D1_POINT_2F")
		D2D1_hr(DllCall(this.vt(15),"ptr",this.__
			,"float",length
			,"ptr",IsObject(worldTransform)?worldTransform[]:worldTransform
			,"float",flatteningTolerance
			,"ptr",point[]
			,"ptr",unitTangentVector[]
			,"uint"),"ComputePointAtLength")
		return [point,unitTangentVector] ; D2D1_POINT_2F 
	}
	
	; Widens the geometry by the specified stroke and writes the result to an ID2D1SimplifiedGeometrySink after it has been transformed by the specified matrix and flattened using the specified tolerance.
	Widen(strokeWidth,strokeStyle,worldTransform,flatteningTolerance,geometrySink){ ; ID2D1StrokeStyle , D2D1_MATRIX_3X2_F
		return D2D1_hr(DllCall(this.vt(16),"ptr",this.__
			,"float",strokeWidth
			,"ptr",IsObject(strokeStyle)?strokeStyle.__:strokeStyle
			,"ptr",IsObject(worldTransform)?worldTransform[]:worldTransform
			,"float",flatteningTolerance
			,"ptr",IsObject(geometrySink)?geometrySink.__:geometrySink
			,"uint"),"Widen")
	}
}
class ID2D1RectangleGeometry extends ID2D1Geometry
{
	; Retrieves the rectangle that describes the rectangle geometry's dimensions.
	GetRect(){
		rect:=D2D1_Struct("D2D1_RECT_F")
		DllCall(this.vt(17),"ptr",this.__,"ptr",rect[])
		return rect
	}
}
class ID2D1RoundedRectangleGeometry extends ID2D1Geometry
{
	; Retrieves a rounded rectangle that describes this rounded rectangle geometry. 
	GetRoundedRect(){
		roundedRect:=D2D1_Struct("D2D1_ROUNDED_RECT")
		DllCall(this.vt(17),"ptr",this.__,"ptr",roundedRect[])
		return roundedRect
	}
}
class ID2D1EllipseGeometry extends ID2D1Geometry
{
	; Gets the D2D1_ELLIPSE structure that describes this ellipse geometry. 
	GetEllipse(){
		ellipse:=D2D1_Struct("D2D1_ELLIPSE")
		DllCall(this.vt(17),"ptr",this.__,"ptr",ellipse[])
		return ellipse
	}
}
class ID2D1GeometryGroup extends ID2D1Geometry
{
	; Indicates how the intersecting areas of the geometries contained in this geometry group are combined.
	GetFillMode(){
		return DllCall(this.vt(17),"ptr",this.__) ; D2D1_FILL_MODE
	}
	
	; Indicates the number of geometry objects in the geometry group. 
	GetSourceGeometryCount(){
		return DllCall(this.vt(18),"ptr",this.__,"uint")
	}
	
	; Retrieves the geometries in the geometry group. 
	GetSourceGeometries(geometriesCount){
		DllCall(this.vt(19),"ptr",this.__,"ptr*",geometries,"uint",geometriesCount)
		return new ID2D1Geometry(geometries)
	}
}
class ID2D1TransformedGeometry extends ID2D1Geometry
{
	; Retrieves the source geometry of this transformed geometry object. 
	GetSourceGeometry(){
		DllCall(this.vt(17),"ptr",this.__,"ptr*",sourceGeometry)
		return new ID2D1Geometry(sourceGeometry)
	}
	
	; Retrieves the matrix used to transform the ID2D1TransformedGeometry object's source geometry. 
	GetTransform(){
		transform:=D2D1_Struct("D2D1_MATRIX_3X2_F")
		D2D1_hr(DllCall(this.vt(18),"ptr",this.__,"ptr",transform[],"uint"),"GetTransform")
		return transform 
	}
}
class ID2D1PathGeometry extends ID2D1Geometry
{
	; Retrieves the geometry sink that is used to populate the path geometry with figures and segments. 
	; Because path geometries are immutable and can only be populated once, it is an error to call Open on a path geometry more than once.
	; Note that the fill mode defaults to D2D1_FILL_MODE_ALTERNATE. To set the fill mode, call SetFillMode before the first call to BeginFigure. Failure to do so will put the geometry sink in an error state. 
	; Example creates an ID2D1PathGeometry, retrieves a sink, and uses the sink to define an hourglass shape. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371522%28v=vs.85%29.aspx
	Open(){
		D2D1_hr(DllCall(this.vt(17),"ptr",this.__,"ptr*",geometrySink,"uint"),"Open")
		return new ID2D1GeometrySink(geometrySink)
	}
	
	; Copies the contents of the path geometry to the specified ID2D1GeometrySink.
	Stream(geometrySink){ ; ID2D1GeometrySink
		D2D1_hr(DllCall(this.vt(18),"ptr",this.__,"ptr",IsObject(geometrySink)?geometrySink[]:geometrySink,"uint"),"Stream")
	}
	
	; Retrieves the number of segments in the path geometry. 
	GetSegmentCount(){
		DllCall(this.vt(19),"ptr",this.__,"uint*",count)
		return count
	}
	
	; Retrieves the number of figures in the path geometry. 
	GetFigureCount(){
		DllCall(this.vt(20),"ptr",this.__,"uint*",count)
		return count
	}
}
;;
;;
;;
class ID2D1Bitmap extends ID2D1Resource
{
	; Returns the size, in device-independent pixels (DIPs), of the bitmap.
	; A DIP is 1/96 of an inch. To retrieve the size in device pixels, use the ID2D1Bitmap::GetPixelSize method.
	GetSize(){
		return D2D1_struct("D2D1_SIZE_F",DllCall(this.vt(4),"ptr",this.__))
	}
	
	; Returns the size, in device-dependent units (pixels), of the bitmap.
	GetPixelSize(){
		return D2D1_struct("D2D1_SIZE_U",DllCall(this.vt(5),"ptr",this.__))
	}
	
	; Retrieves the pixel format and alpha mode of the bitmap.
	GetPixelFormat(){
		return DllCall(this.vt(6),"ptr",this.__,"int") ; D2D1_PIXEL_FORMAT
	}
	
	; Return the dots per inch (DPI) of the bitmap.
	GetDpi(){
		DllCall(this.vt(7),"ptr",this.__,"float*",dpiX,"float*",dpiY)
		return [dpiX,dpiY]
	}
	
	; This method does not update the size of the current bitmap. If the contents of the source bitmap do not fit in the current bitmap, this method fails. Also, note that this method does not perform format conversion, and will fail if the bitmap formats do not match.
	; Calling this method may cause the current batch to flush if the bitmap is active in the batch. If the batch that was flushed does not complete successfully, this method fails. However, this method does not clear the error state of the render target on which the batch was flushed. The failing HRESULT and tag state will be returned at the next call to EndDraw or Flush.
	
	; Copies the specified region from the specified bitmap into the current bitmap. 
	CopyFromBitmap(destPoint,bitmap,srcRect=0){ ; D2D1_POINT_2U , ID2D1Bitmap , D2D1_RECT_U
		return D2D1_hr(DllCall(this.vt(8),"ptr",this.__
			,"ptr",IsObject(destPoint)?destPoint[]:destPoint
			,"ptr",IsObject(bitmap)?bitmap.__:bitmap
			,"ptr",IsObject(srcRect)?srcRect[]:srcRect
			,"uint"),"CopyFromBitmap")
	}
	
	; Copies the specified region from the specified render target into the current bitmap. 
	; All clips and layers must be popped off of the render target before calling this method. The method returns D2DERR_RENDER_TARGET_HAS_LAYER_OR_CLIPRECT if any clips or layers are currently applied to the render target.
	CopyFromRenderTarget(destPoint,renderTarget,srcRect=0){ ; D2D1_POINT_2U , ID2D1RenderTarget , D2D1_RECT_U
		return D2D1_hr(DllCall(this.vt(9),"ptr",this.__
			,"ptr",IsObject(destPoint)?destPoint[]:destPoint
			,"ptr",IsObject(renderTarget)?renderTarget.__:renderTarget
			,"ptr",IsObject(srcRect)?srcRect[]:srcRect
			,"uint"),"CopyFromRenderTarget")
	}
	
	; Copies the specified region from memory into the current bitmap. 
	; The stride, or pitch, of the source bitmap stored in srcData. The stride is the byte count of a scanline (one row of pixels in memory). The stride can be computed from the following formula: pixel width * bytes per pixel + memory padding.
	CopyFromMemory(dstRect,srcData,pitch){ ; D2D1_RECT_U
		return D2D1_hr(DllCall(this.vt(10),"ptr",this.__
			,"ptr",IsObject(dstRect)?dstRect[]:dstRect
			,"ptr",srcData
			,"uint",pitch
			,"uint"),"CopyFromMemory")
	}
}

class ID2D1GradientStopCollection extends ID2D1Resource
{
	; Retrieves the number of gradient stops in the collection.
	GetGradientStopCount(){
		return DllCall(this.vt(4),"ptr",this.__,"uint")
	}
	
	; Copies the gradient stops from the collection into an array of D2D1_GRADIENT_STOP structures.
	; Gradient stops are copied in order of position, starting with the gradient stop with the smallest position value and progressing to the gradient stop with the largest position value.
	GetGradientStops(gradientStopsCount){
		gradientStops:=StructArray(D2D1_Struct("D2D1_GRADIENT_STOP"),gradientStopsCount)
		DllCall(this.vt(5),"ptr",this.__
			,"ptr",gradientStops[]
			,"uint",gradientStopsCount)
		return gradientStops ; D2D1_GRADIENT_STOP
	}
	
	; Indicates the gamma space in which the gradient stops are interpolated. 
	GetColorInterpolationGamma(){
		return DllCall(this.vt(6),"ptr",this.__,"int") ; D2D1_GAMMA
	}
	
	; Indicates the behavior of the gradient outside the normalized gradient range. 
	GetExtendMode(){
		return DllCall(this.vt(7),"ptr",this.__,"int") ; D2D1_EXTEND_MODE
	}
}
class ID2D1StrokeStyle extends ID2D1Resource
{
	; Retrieves the type of shape used at the beginning of a stroke. 
	GetStartCap(){
		return DllCall(this.vt(4),"ptr",this.__) ; D2D1_CAP_STYLE
	}
	
	; Retrieves the type of shape used at the end of a stroke. 
	GetEndCap(){
		return DllCall(this.vt(5),"ptr",this.__) ; D2D1_CAP_STYLE
	}
	
	; Gets a value that specifies how the ends of each dash are drawn. 
	GetDashCap(){
		return DllCall(this.vt(6),"ptr",this.__) ; D2D1_CAP_STYLE
	}
	
	; Retrieves the limit on the ratio of the miter length to half the stroke's thickness. 
	GetMiterLimit(){
		return DllCall(this.vt(7),"ptr",this.__,"float")
	}
	
	; Retrieves the type of joint used at the vertices of a shape's outline. 
	GetLineJoin(){
		return DllCall(this.vt(8),"ptr",this.__) ; D2D1_LINE_JOIN
	}
	
	; Retrieves a value that specifies how far in the dash sequence the stroke will start. 
	GetDashOffset(){
		return DllCall(this.vt(9),"ptr",this.__,"float")
	}
	
	; Gets a value that describes the stroke's dash pattern. 
	; If a custom dash style is specified, the dash pattern is described by the dashes array, which can be retrieved by calling the GetDashes method.
	GetDashStyle(){
		return DllCall(this.vt(10),"ptr",this.__) ; D2D1_DASH_STYLE
	}
	
	; Retrieves the number of entries in the dashes array. 
	GetDashesCount(){
		return DllCall(this.vt(11),"ptr",this.__,"uint")
	}
	
	; Copies the dash pattern to the specified array. 
	; The dashes are specified in units that are a multiple of the stroke width, with subsequent members of the array indicating the dashes and gaps between dashes: the first entry indicates a filled dash, the second a gap, and so on. 
	GetDashes(dashesCount){
		dashes:=struct("float[" dashesCount "]")
		DllCall(this.vt(12),"ptr",this.__,"ptr",dashes[],"uint",dashesCount)
		return dashes
	}
}
class ID2D1Mesh extends ID2D1Resource
{
	; Opens the mesh for population.
	Open(){
		D2D1_hr(DllCall(this.vt(4),"ptr",this.__,"ptr*",tessellationSink,"uint"),"Open")
		return new ID2D1TessellationSink(tessellationSink)
	}
}
class ID2D1Layer extends ID2D1Resource
{
	; Gets the size of the layer in device-independent pixels. 
	GetSize(){
		return D2D1_Struct("D2D1_SIZE_F",D2D1_hr(DllCall(this.vt(4),"ptr",this.__),"GetSize"))
	}
}
class ID2D1DrawingStateBlock extends ID2D1Resource
{
	; Retrieves the antialiasing mode, transform, and tags portion of the drawing state.
	GetDescription(){
		stateDescription:=D2D1_Struct("D2D1_DRAWING_STATE_DESCRIPTION")
		DllCall(this.vt(4),"ptr",this.__,"ptr",stateDescription[])
		return stateDescription
	}
	
	; Specifies the antialiasing mode, transform, and tags portion of the drawing state.
	SetDescription(stateDescription){ ; D2D1_DRAWING_STATE_DESCRIPTION
		DllCall(this.vt(5),"ptr",this.__,"ptr",IsObject(stateDescription)?stateDescription[]:stateDescription)
	}
	
	; Specifies the text-rendering configuration of the drawing state.
	SetTextRenderingParams(textRenderingParams=0){ ; IDWriteRenderingParams
		DllCall(this.vt(6),"ptr",this.__,"ptr",IsObject(textRenderingParams)?textRenderingParams.__:textRenderingParams)
	}
	
	; Retrieves the text-rendering configuration of the drawing state.
	GetTextRenderingParams(){
		DllCall(this.vt(7),"ptr",this.__,"ptr*",textRenderingParams)
		return new IDWriteRenderingParams(textRenderingParams)
	}
}

;;
;;ID2D1GeometrySink
;;
class ID2D1SimplifiedGeometrySink extends IUnknown
{
	; Specifies the method used to determine which points are inside the geometry described by this geometry sink and which points are outside. 
	; The fill mode defaults to D2D1_FILL_MODE_ALTERNATE. To set the fill mode, call SetFillMode before the first call to BeginFigure. Not doing will put the geometry sink in an error state. 
	SetFillMode(fillMode){
		DllCall(this.vt(3),"ptr",this.__,"int",fillMode)
	}
	
	; Specifies stroke and join options to be applied to new segments added to the geometry sink. 
	SetSegmentFlags(vertexFlags){ ; D2D1_PATH_SEGMENT
		DllCall(this.vt(4),"ptr",this.__,"int",vertexFlags)
	}
	
	; Starts a new figure at the specified point. 
	; If this method is called while a figure is currently in progress, the interface is invalidated and all future methods will fail.
	BeginFigure(startPoint0,startPoint1,figureBegin){
		DllCall(this.vt(5),"ptr",this.__
			,"float",startPoint0,"float",startPoint1
			,"int",figureBegin)
	}
	
	; Creates a sequence of lines using the specified points and adds them to the geometry sink.
	AddLines(points,pointsCount){ ; D2D1_POINT_2F*
		DllCall(this.vt(6),"ptr",this.__
			,"ptr",IsObject(points)?points[]:points
			,"uint",pointsCount)
	}
	
	; Creates a sequence of cubic Bezier curves and adds them to the geometry sink. 
	AddBeziers(beziers,beziersCount){ ; D2D1_BEZIER_SEGMENT*
		DllCall(this.vt(7),"ptr",this.__
			,"ptr",IsObject(beziers)?beziers[]:beziers
			,"uint",beziersCount)
	}
	
	; Ends the current figure; optionally, closes it.
	EndFigure(figureEnd){
		DllCall(this.vt(8),"ptr",this.__,"uint",figureEnd)
	}
	
	; Closes the geometry sink, indicates whether it is in an error state, and resets the sink's error state. 
	Close(){
		return D2D1_hr(DllCall(this.vt(9),"ptr",this.__,"uint"),"Close")
	}
}
class ID2D1GeometrySink extends ID2D1SimplifiedGeometrySink
{
	; Creates a line segment between the current point and the specified end point and adds it to the geometry sink. 
	; Example creates an ID2D1PathGeometry, retrieves a sink, and uses it to define an hourglass shape. http://msdn.microsoft.com/en-us/library/windows/desktop/dd316604%28v=vs.85%29.aspx
	AddLine(point0,point1){ ; D2D1_POINT_2F
		return D2D1_hr(DllCall(this.vt(10),"ptr",this.__,"float",point0,"float",point1,"uint"),"AddLine")
	}
	
	; Creates a cubic Bezier curve between the current point and the specified endpoint.
	AddBezier(bezier){ ; D2D1_BEZIER_SEGMENT
		return D2D1_hr(DllCall(this.vt(11),"ptr",this.__,"ptr",IsObject(bezier)?bezier[]:bezier,"uint"),"AddBezier")
	}
	
	; Creates a quadratic Bezier curve between the current point and the specified endpoint.
	AddQuadraticBezier(bezier){ ; D2D1_QUADRATIC_BEZIER_SEGMENT
		return D2D1_hr(DllCall(this.vt(12),"ptr",this.__,"ptr",IsObject(bezier)?bezier[]:bezier,"uint"),"AddQuadraticBezier")
	}
	
	; Adds a sequence of quadratic Bezier segments as an array in a single call.
	AddQuadraticBeziers(beziers,beziersCount){ ; D2D1_QUADRATIC_BEZIER_SEGMENT
	return D2D1_hr(DllCall(this.vt(13),"ptr",this.__
		,"ptr",IsObject(beziers)?beziers[]:beziers
		,"uint",beziersCount
		,"uint"),"AddQuadraticBeziers")
	}
	
	; Adds a single arc to the path geometry.
	AddArc(arc){ ; D2D1_ARC_SEGMENT
		return D2D1_hr(DllCall(this.vt(14),"ptr",this.__,"ptr",IsObject(arc)?arc[]:arc,"uint"),"AddArc")
	}
}

;;
;;ID2D1TessellationSink
;;
class ID2D1TessellationSink extends IUnknown
{
	; Copies the specified triangles to the sink. 
	AddTriangles(triangles,trianglesCount){ ; D2D1_TRIANGLE*
		DllCall(this.vt(3),"ptr",this.__
		,"ptr",IsObject(triangles)?triangles[]:triangles
		,"uint",trianglesCount)
	}
	
	; Closes the sink and returns its error status.
	Close(){
		return D2D1_hr(DllCall(this.vt(4),"ptr",this.__,"uint"),"Close")
	}
}

;;
;;wrapped function
;;
; 
/*
class D2D1_Struct{
	__new(){
	 this.D2D1_COLOR_F:=struct("FLOAT r;FLOAT g;FLOAT b;FLOAT a")
	,this.D2D1_POINT_2U:=struct("UINT x;UINT y")
	,this.D2D1_POINT_2F:=struct("FLOAT x;FLOAT y")
	,this.D2D1_RECT_F:=struct("FLOAT left;FLOAT top;FLOAT right;FLOAT bottom")
	,this.D2D1_RECT_U:=struct("UINT left;UINT top;UINT right;UINT bottom")
	,this.D2D1_SIZE_F:=struct("FLOAT width;FLOAT height")
	,this.D2D1_SIZE_U:=struct("UINT width;UINT height")
	,this.D2D1_MATRIX_3X2_F:=struct("FLOAT _11;FLOAT _12;FLOAT _21;FLOAT _22;FLOAT _31;FLOAT _32")
			
	 this.D2D1_PIXEL_FORMAT:=struct("int format;int alphaMode")
	,this.D2D1_BITMAP_PROPERTIES:=struct("D2D1_PIXEL_FORMAT pixelFormat;FLOAT dpiX;FLOAT dpiY")
	,this.D2D1_GRADIENT_STOP:=struct("FLOAT position;D2D1_COLOR_F color")
	,this.D2D1_BRUSH_PROPERTIES:=struct("FLOAT opacity;D2D1_MATRIX_3X2_F transform")
	,this.D2D1_BITMAP_BRUSH_PROPERTIES:=struct("int extendModeX;int extendModeY;int interpolationMode")
	,this.D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES:=struct("D2D1_POINT_2F startPoint;D2D1_POINT_2F endPoint")
	,this.D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES:=struct("D2D1_POINT_2F center;D2D1_POINT_2F gradientOriginOffset;FLOAT radiusX;FLOAT radiusY")
	,this.D2D1_BEZIER_SEGMENT:=struct("D2D1_POINT_2F point1;D2D1_POINT_2F point2;D2D1_POINT_2F point3")
	,this.D2D1_TRIANGLE:=struct("D2D1_POINT_2F point1;D2D1_POINT_2F point2;D2D1_POINT_2F point3")
	,this.D2D1_ARC_SEGMENT:=struct("D2D1_POINT_2F point;D2D1_SIZE_F size;FLOAT rotationAngle;int sweepDirection;int arcSize")
	 this.D2D1_QUADRATIC_BEZIER_SEGMENT:=struct("D2D1_POINT_2F point1;D2D1_POINT_2F point2")
	,this.D2D1_ELLIPSE:=struct("D2D1_POINT_2F point;FLOAT radiusX;FLOAT radiusY")
	,this.D2D1_ROUNDED_RECT:=struct("D2D1_RECT_F rect;FLOAT radiusX;FLOAT radiusY")
	,this.D2D1_STROKE_STYLE_PROPERTIES:=struct("int startCap;int endCap;int dashCap;int lineJoin;FLOAT miterLimit;int dashStyle;FLOAT ashOffset")
	,this.D2D1_LAYER_PARAMETERS:=struct("D2D1_RECT_F contentBounds;ptr geometricMask;int maskAntialiasMode;D2D1_MATRIX_3X2_F maskTransform;FLOAT opacity;ptr opacityBrush;int layerOptions")
	,this.D2D1_RENDER_TARGET_PROPERTIES:=struct("int type;struct {int format;int alphaMode};FLOAT dpiX;FLOAT dpiY;int usage;int minLevel")
	,this.D2D1_HWND_RENDER_TARGET_PROPERTIES:=struct("HWND hwnd;UINT width;UINT height;int presentOptions")
	,this.D2D1_DRAWING_STATE_DESCRIPTION:=struct("int antialiasMode;int textAntialiasMode;uint64 tag1;uint64 tag2;D2D1_MATRIX_3X2_F transform")
	,this.D2D1_FACTORY_OPTIONS:=struct("int debugLevel")
	}
	__call(aName,p*){
		return this[aName].clone(p.1)
	}
}
D2D1_Struct(){
	global
	 D2D1_COLOR_F:=struct("FLOAT r;FLOAT g;FLOAT b;FLOAT a",{r:10})
	,D2D1_POINT_2U:=struct("UINT x;UINT y")
	,D2D1_POINT_2F:=struct("FLOAT x;FLOAT y")
	,D2D1_RECT_F:=struct("FLOAT left;FLOAT top;FLOAT right;FLOAT bottom")
	,D2D1_RECT_U:=struct("UINT left;UINT top;UINT right;UINT bottom")
	,D2D1_SIZE_F:=struct("FLOAT width;FLOAT height")
	,D2D1_SIZE_U:=struct("UINT width;UINT height")
	,D2D1_MATRIX_3X2_F:=struct("FLOAT _11;FLOAT _12;FLOAT _21;FLOAT _22;FLOAT _31;FLOAT _32")
		
	 D2D1_PIXEL_FORMAT:=struct("int format;int alphaMode")
	,D2D1_BITMAP_PROPERTIES:=struct("D2D1_PIXEL_FORMAT pixelFormat;FLOAT dpiX;FLOAT dpiY")
	,D2D1_GRADIENT_STOP:=struct("FLOAT position;D2D1_COLOR_F color")
	,D2D1_BRUSH_PROPERTIES:=struct("FLOAT opacity;D2D1_MATRIX_3X2_F transform")
	,D2D1_BITMAP_BRUSH_PROPERTIES:=struct("int extendModeX;int extendModeY;int interpolationMode")
	,D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES:=struct("D2D1_POINT_2F startPoint;D2D1_POINT_2F endPoint")
	,D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES:=struct("D2D1_POINT_2F center;D2D1_POINT_2F gradientOriginOffset;FLOAT radiusX;FLOAT radiusY")
	,D2D1_BEZIER_SEGMENT:=struct("D2D1_POINT_2F point1;D2D1_POINT_2F point2;D2D1_POINT_2F point3")
	,D2D1_TRIANGLE:=struct("D2D1_POINT_2F point1;D2D1_POINT_2F point2;D2D1_POINT_2F point3")
	,D2D1_ARC_SEGMENT:=struct("D2D1_POINT_2F point;D2D1_SIZE_F size;FLOAT rotationAngle;int sweepDirection;int arcSize")
	 D2D1_QUADRATIC_BEZIER_SEGMENT:=struct("D2D1_POINT_2F point1;D2D1_POINT_2F point2")
	,D2D1_ELLIPSE:=struct("D2D1_POINT_2F point;FLOAT radiusX;FLOAT radiusY")
	,D2D1_ROUNDED_RECT:=struct("D2D1_RECT_F rect;FLOAT radiusX;FLOAT radiusY")
	,D2D1_STROKE_STYLE_PROPERTIES:=struct("int startCap;int endCap;int dashCap;int lineJoin;FLOAT miterLimit;int dashStyle;FLOAT ashOffset")
	,D2D1_LAYER_PARAMETERS:=struct("D2D1_RECT_F contentBounds;ptr geometricMask;int maskAntialiasMode;D2D1_MATRIX_3X2_F maskTransform;FLOAT opacity;ptr opacityBrush;int layerOptions")
	,D2D1_RENDER_TARGET_PROPERTIES:=struct("int type;struct {int format;int alphaMode};FLOAT dpiX;FLOAT dpiY;int usage;int minLevel")
	,D2D1_HWND_RENDER_TARGET_PROPERTIES:=struct("HWND hwnd;struct {UINT width;UINT height};int presentOptions")
	,D2D1_DRAWING_STATE_DESCRIPTION:=struct("int antialiasMode;int textAntialiasMode;uint64 tag1;uint64 tag2;D2D1_MATRIX_3X2_F transform")
	,D2D1_FACTORY_OPTIONS:=struct("int debugLevel")
}
*/
D2D1_Struct(name,p=0){
	static init:=1,_:=[]
	if init{
		init:=0
		 _.D2D1_COLOR_F:=struct("FLOAT r;FLOAT g;FLOAT b;FLOAT a",{r:10})
		,_.D2D1_POINT_2U:=struct("UINT x;UINT y")
		,_.D2D1_POINT_2F:=struct("FLOAT x;FLOAT y")
		,_.D2D1_RECT_F:=struct("FLOAT left;FLOAT top;FLOAT right;FLOAT bottom")
		,_.D2D1_RECT_U:=struct("UINT left;UINT top;UINT right;UINT bottom")
		,_.D2D1_SIZE_F:=struct("FLOAT width;FLOAT height")
		,_.D2D1_SIZE_U:=struct("UINT width;UINT height")
		,_.D2D1_MATRIX_3X2_F:=struct("FLOAT _11;FLOAT _12;FLOAT _21;FLOAT _22;FLOAT _31;FLOAT _32")
		
		 _.D2D1_PIXEL_FORMAT:=struct("int format;int alphaMode")
		,_.D2D1_BITMAP_PROPERTIES:=struct("D2D1_PIXEL_FORMAT pixelFormat;FLOAT dpiX;FLOAT dpiY")
		,_.D2D1_GRADIENT_STOP:=struct("FLOAT position;D2D1_COLOR_F color")
		,_.D2D1_BRUSH_PROPERTIES:=struct("FLOAT opacity;D2D1_MATRIX_3X2_F transform")
		,_.D2D1_BITMAP_BRUSH_PROPERTIES:=struct("int extendModeX;int extendModeY;int interpolationMode")
		,_.D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES:=struct("D2D1_POINT_2F startPoint;D2D1_POINT_2F endPoint")
		,_.D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES:=struct("D2D1_POINT_2F center;D2D1_POINT_2F gradientOriginOffset;FLOAT radiusX;FLOAT radiusY")
		,_.D2D1_BEZIER_SEGMENT:=struct("D2D1_POINT_2F point1;D2D1_POINT_2F point2;D2D1_POINT_2F point3")
		,_.D2D1_TRIANGLE:=struct("D2D1_POINT_2F point1;D2D1_POINT_2F point2;D2D1_POINT_2F point3")
		,_.D2D1_ARC_SEGMENT:=struct("D2D1_POINT_2F point;D2D1_SIZE_F size;FLOAT rotationAngle;int sweepDirection;int arcSize")
		 _.D2D1_QUADRATIC_BEZIER_SEGMENT:=struct("D2D1_POINT_2F point1;D2D1_POINT_2F point2")
		,_.D2D1_ELLIPSE:=struct("D2D1_POINT_2F point;FLOAT radiusX;FLOAT radiusY")
		,_.D2D1_ROUNDED_RECT:=struct("D2D1_RECT_F rect;FLOAT radiusX;FLOAT radiusY")
		,_.D2D1_STROKE_STYLE_PROPERTIES:=struct("int startCap;int endCap;int dashCap;int lineJoin;FLOAT miterLimit;int dashStyle;FLOAT ashOffset")
		,_.D2D1_LAYER_PARAMETERS:=struct("D2D1_RECT_F contentBounds;ptr geometricMask;int maskAntialiasMode;D2D1_MATRIX_3X2_F maskTransform;FLOAT opacity;ptr opacityBrush;int layerOptions")
		,_.D2D1_RENDER_TARGET_PROPERTIES:=struct("int type;int format;int alphaMode;FLOAT dpiX;FLOAT dpiY;int usage;int minLevel")
		,_.D2D1_HWND_RENDER_TARGET_PROPERTIES:=struct("HWND hwnd;UINT width;UINT height;int presentOptions")
		,_.D2D1_DRAWING_STATE_DESCRIPTION:=struct("int antialiasMode;int textAntialiasMode;uint64 tag1;uint64 tag2;D2D1_MATRIX_3X2_F transform")
		,_.D2D1_FACTORY_OPTIONS:=struct("int debugLevel")
	}
	return _.haskey(name)?_[name].clone(p=0?[]:p):"Struct not exists."
}
D2D1_Constants(type){
	static init:=1,_
	if init{
		init:=0
		 _.D2D1_ALPHA_MODE_UNKNOWN:=0
		,_.D2D1_ALPHA_MODE_PREMULTIPLIED:=1
		,_.D2D1_ALPHA_MODE_STRAIGHT:=2
		,_.D2D1_ALPHA_MODE_IGNORE:=3
		,_.D2D1_ALPHA_MODE_FORCE_DWORD:=0xffffffff
		,_.D2D1_GAMMA_2_2:=0
		,_.D2D1_GAMMA_1_0:=1
		,_.D2D1_GAMMA_FORCE_DWORD:=0xffffffff
		,_.D2D1_OPACITY_MASK_CONTENT_GRAPHICS:=0
		,_.D2D1_OPACITY_MASK_CONTENT_TEXT_NATURAL:=1
		 _.D2D1_OPACITY_MASK_CONTENT_TEXT_GDI_COMPATIBLE:=2
		,_.D2D1_OPACITY_MASK_CONTENT_FORCE_DWORD:=0xffffffff
		,_.D2D1_EXTEND_MODE_CLAMP:=0
		,_.D2D1_EXTEND_MODE_WRAP:=1
		,_.D2D1_EXTEND_MODE_MIRROR:=2
		,_.D2D1_EXTEND_MODE_FORCE_DWORD:=0xffffffff
		,_.D2D1_ANTIALIAS_MODE_PER_PRIMITIVE:=0
		,_.D2D1_ANTIALIAS_MODE_ALIASED:=1
		,_.D2D1_ANTIALIAS_MODE_FORCE_DWORD:=0xffffffff
		,_.D2D1_TEXT_ANTIALIAS_MODE_DEFAULT:=0
		 _.D2D1_TEXT_ANTIALIAS_MODE_CLEARTYPE:=1
		,_.D2D1_TEXT_ANTIALIAS_MODE_GRAYSCALE:=2
		,_.D2D1_TEXT_ANTIALIAS_MODE_ALIASED:=3
		,_.D2D1_TEXT_ANTIALIAS_MODE_FORCE_DWORD:=0xffffffff
		,_.D2D1_BITMAP_INTERPOLATION_MODE_NEAREST_NEIGHBOR:=0
		,_.D2D1_BITMAP_INTERPOLATION_MODE_LINEAR:=1
		,_.D2D1_BITMAP_INTERPOLATION_MODE_FORCE_DWORD:=0xffffffff
		,_.D2D1_DRAW_TEXT_OPTIONS_NO_SNAP:=0x00000001
		,_.D2D1_DRAW_TEXT_OPTIONS_CLIP:=0x00000002
		,_.D2D1_DRAW_TEXT_OPTIONS_NONE:=0x00000000
		 _.D2D1_DRAW_TEXT_OPTIONS_FORCE_DWORD:=0xffffffff
		,_.D2D1_ARC_SIZE_SMALL:=0
		,_.D2D1_ARC_SIZE_LARGE:=1
		,_.D2D1_ARC_SIZE_FORCE_DWORD:=0xffffffff
		,_.D2D1_CAP_STYLE_FLAT:=0
		,_.D2D1_CAP_STYLE_SQUARE:=1
		,_.D2D1_CAP_STYLE_ROUND:=2
		,_.D2D1_CAP_STYLE_TRIANGLE:=3
		,_.D2D1_CAP_STYLE_FORCE_DWORD:=0xffffffff
		,_.D2D1_DASH_STYLE_SOLID:=0
		 _.D2D1_DASH_STYLE_DASH:=1
		,_.D2D1_DASH_STYLE_DOT:=2
		,_.D2D1_DASH_STYLE_DASH_DOT:=3
		,_.D2D1_DASH_STYLE_DASH_DOT_DOT:=4
		,_.D2D1_DASH_STYLE_CUSTOM:=5
		,_.D2D1_DASH_STYLE_FORCE_DWORD:=0xffffffff
		,_.D2D1_LINE_JOIN_MITER:=0
		,_.D2D1_LINE_JOIN_BEVEL:=1
		,_.D2D1_LINE_JOIN_ROUND:=2
		,_.D2D1_LINE_JOIN_MITER_OR_BEVEL:=3
		 _.D2D1_LINE_JOIN_FORCE_DWORD:=0xffffffff
		,_.D2D1_COMBINE_MODE_UNION:=0
		,_.D2D1_COMBINE_MODE_INTERSECT:=1
		,_.D2D1_COMBINE_MODE_XOR:=2
		,_.D2D1_COMBINE_MODE_EXCLUDE:=3
		,_.D2D1_COMBINE_MODE_FORCE_DWORD:=0xffffffff
		,_.D2D1_GEOMETRY_RELATION_UNKNOWN:=0
		,_.D2D1_GEOMETRY_RELATION_DISJOINT:=1
		,_.D2D1_GEOMETRY_RELATION_IS_CONTAINED:=2
		,_.D2D1_GEOMETRY_RELATION_CONTAINS:=3
		 _.D2D1_GEOMETRY_RELATION_OVERLAP:=4
		,_.D2D1_GEOMETRY_RELATION_FORCE_DWORD:=0xffffffff
		,_.D2D1_GEOMETRY_SIMPLIFICATION_OPTION_CUBICS_AND_LINES:=0
		,_.D2D1_GEOMETRY_SIMPLIFICATION_OPTION_LINES:=1
		,_.D2D1_GEOMETRY_SIMPLIFICATION_OPTION_FORCE_DWORD:=0xffffffff
		,_.D2D1_FIGURE_BEGIN_FILLED:=0
		,_.D2D1_FIGURE_BEGIN_HOLLOW:=1
		,_.D2D1_FIGURE_BEGIN_FORCE_DWORD:=0xffffffff
		,_.D2D1_FIGURE_END_OPEN:=0
		,_.D2D1_FIGURE_END_CLOSED:=1
		 _.D2D1_FIGURE_END_FORCE_DWORD:=0xffffffff
		,_.D2D1_PATH_SEGMENT_NONE:=0x00000000
		,_.D2D1_PATH_SEGMENT_FORCE_UNSTROKED:=0x00000001
		,_.D2D1_PATH_SEGMENT_FORCE_ROUND_LINE_JOIN:=0x00000002
		,_.D2D1_PATH_SEGMENT_FORCE_DWORD:=0xffffffff
		,_.D2D1_SWEEP_DIRECTION_COUNTER_CLOCKWISE:=0
		,_.D2D1_SWEEP_DIRECTION_CLOCKWISE:=1
		,_.D2D1_SWEEP_DIRECTION_FORCE_DWORD:=0xffffffff
		,_.D2D1_FILL_MODE_ALTERNATE:=0
		,_.D2D1_FILL_MODE_WINDING:=1
		 _.D2D1_FILL_MODE_FORCE_DWORD:=0xffffffff
		,_.D2D1_LAYER_OPTIONS_NONE:=0x00000000
		,_.D2D1_LAYER_OPTIONS_INITIALIZE_FOR_CLEARTYPE:=0x00000001
		,_.D2D1_LAYER_OPTIONS_FORCE_DWORD:=0xffffffff
		,_.D2D1_WINDOW_STATE_NONE:=0x0000000
		,_.D2D1_WINDOW_STATE_OCCLUDED:=0x0000001
		,_.D2D1_WINDOW_STATE_FORCE_DWORD:=0xffffffff
		,_.D2D1_RENDER_TARGET_TYPE_DEFAULT:=0
		,_.D2D1_RENDER_TARGET_TYPE_SOFTWARE:=1
		,_.D2D1_RENDER_TARGET_TYPE_HARDWARE:=2
		 _.D2D1_RENDER_TARGET_TYPE_FORCE_DWORD:=0xffffffff
		,_.D2D1_FEATURE_LEVEL_DEFAULT:=0
		,_.D2D1_FEATURE_LEVEL_9:=D3D10_FEATURE_LEVEL_9_1
		,_.D2D1_FEATURE_LEVEL_10:=D3D10_FEATURE_LEVEL_10_0
		,_.D2D1_FEATURE_LEVEL_FORCE_DWORD:=0xffffffff
		,_.D2D1_RENDER_TARGET_USAGE_NONE:=0x00000000
		,_.D2D1_RENDER_TARGET_USAGE_FORCE_BITMAP_REMOTING:=0x00000001
		,_.D2D1_RENDER_TARGET_USAGE_GDI_COMPATIBLE:=0x00000002
		,_.D2D1_RENDER_TARGET_USAGE_FORCE_DWORD:=0xffffffff
		,_.D2D1_PRESENT_OPTIONS_NONE:=0x00000000
		 _.D2D1_PRESENT_OPTIONS_RETAIN_CONTENTS:=0x00000001
		,_.D2D1_PRESENT_OPTIONS_IMMEDIATELY:=0x00000002
		,_.D2D1_PRESENT_OPTIONS_FORCE_DWORD:=0xffffffff
		,_.D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_NONE:=0x00000000
		,_.D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_GDI_COMPATIBLE:=0x00000001
		,_.D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_FORCE_DWORD:=0xffffffff
		,_.D2D1_DC_INITIALIZE_MODE_COPY:=0
		,_.D2D1_DC_INITIALIZE_MODE_CLEAR:=1
		,_.D2D1_DC_INITIALIZE_MODE_FORCE_DWORD:=0xffffffff
		,_.D2D1_DEBUG_LEVEL_NONE:=0
		 _.D2D1_DEBUG_LEVEL_ERROR:=1
		,_.D2D1_DEBUG_LEVEL_WARNING:=2
		,_.D2D1_DEBUG_LEVEL_INFORMATION:=3
		,_.D2D1_DEBUG_LEVEL_FORCE_DWORD:=0xffffffff
		,_.D2D1_FACTORY_TYPE_SINGLE_THREADED:=0
		,_.D2D1_FACTORY_TYPE_MULTI_THREADED:=1
		,_.D2D1_FACTORY_TYPE_FORCE_DWORD:=0xffffffff
	}
	return _[type]
}

D2D1_hr(a,ByRef b){
	static init:=1,_:=[]
	if init{
		init:=0
		 _[0x88990001]:="D2DERR_WRONG_STATE"
		,_[0x88990002]:="D2DERR_NOT_INITIALIZED"
		,_[0x88990003]:="D2DERR_UNSUPPORTED_OPERATION"
		,_[0x88990004]:="D2DERR_SCANNER_FAILED"
		,_[0x88990005]:="D2DERR_SCREEN_ACCESS_DENIED"
		,_[0x88990006]:="D2DERR_DISPLAY_STATE_INVALID"
		,_[0x88990007]:="D2DERR_ZERO_VECTOR"
		,_[0x88990008]:="D2DERR_INTERNAL_ERROR"
		,_[0x88990009]:="D2DERR_DISPLAY_FORMAT_NOT_SUPPORTED"
		,_[0x8899000A]:="D2DERR_INVALID_CALL"
		 _[0x8899000B]:="D2DERR_NO_HARDWARE_DEVICE"
		,_[0x8899000C]:="D2DERR_RECREATE_TARGET"
		,_[0x8899000D]:="D2DERR_TOO_MANY_SHADER_ELEMENTS"
		,_[0x8899000E]:="D2DERR_SHADER_COMPILE_FAILED"
		,_[0x8899000F]:="D2DERR_MAX_TEXTURE_SIZE_EXCEEDED"
		,_[0x88990010]:="D2DERR_UNSUPPORTED_VERSION"
		,_[0x88990011]:="D2DERR_BAD_NUMBER"
		,_[0x88990012]:="D2DERR_WRONG_FACTORY"
		,_[0x88990013]:="D2DERR_LAYER_ALREADY_IN_USE"
		,_[0x88990014]:="D2DERR_POP_CALL_DID_NOT_MATCH_PUSH"
		 _[0x88990015]:="D2DERR_WRONG_RESOURCE_DOMAIN"
		,_[0x88990016]:="D2DERR_PUSH_POP_UNBALANCED"
		,_[0x88990017]:="D2DERR_RENDER_TARGET_HAS_LAYER_OR_CLIPRECT"
		,_[0x88990018]:="D2DERR_INCOMPATIBLE_BRUSH_TYPES"
		,_[0x88990019]:="D2DERR_WIN32_ERROR"
		,_[0x8899001A]:="D2DERR_TARGET_NOT_GDI_COMPATIBLE"
		,_[0x8899001B]:="D2DERR_TEXT_EFFECT_IS_WRONG_TYPE"
		,_[0x8899001C]:="D2DERR_TEXT_RENDERER_NOT_RELEASED"
		,_[0x8899001D]:="D2DERR_EXCEEDS_MAX_BITMAP_SIZE"
	}
	if a && (a&=0xFFFFFFFF)
		msgbox, % b " : " (err.haskey(a)?err[a]:_error(a,b))
	return a
}
