
class IDCompositionDevice extends IUnknown
{
  static iid := "{C37EA93A-E7AA-450D-B16F-9746CB0407F3}"
	__new(p=0){
		if p
			this.__:=p,this._v:=NumGet(p+0)
		else {
			DllCall("LoadLibrary","str","Dcomp.dll")
			DllCall("LoadLibrary","str","d3d11.dll")
			DllCall("D3D11.dll\D3D11CreateDevice"
				,"ptr",0
				,"int",1	; D3D_DRIVER_TYPE_HARDWARE
				,"ptr",0
				,"uint",0x20	; D3D11_CREATE_DEVICE_BGRA_SUPPORT
				,"int",0
				,"uint",0
				,"uint",7	; D3D11_SDK_VERSION
				,"ptr*",ppDevice
				,"int*",pFeatureLevel
				,"ptr*",0)
			dxgiDevice:=ComObjQuery(ppDevice,"{54ec77fa-1377-44e6-8c32-88fd5f44c84c}")	; IID_IDXGIDevice
			DllCall("Dcomp.dll\DCompositionCreateDevice"
				,"ptr",dxgiDevice
				,"ptr",GUID(iid,this.iid)
				,"ptr*",dcompositionDevice)
			if dcompositionDevice
				this.__:=dcompositionDevice,this._v:=NumGet(dcompositionDevice+0)
			else return
			ObjRelease(ppDevice),ObjRelease(dxgiDevice)
		}
	}
	
	; Commits all DirectComposition commands that are pending on this device.
	; Calls to DirectComposition methods are always batched and executed atomically as a single transaction. Calls take effect only when IDCompositionDevice::Commit is called, at which time all pending method calls for a device are executed at once.
	; An application that uses multiple devices must call Commit for each device separately. However, because the composition engine processes the calls individually, the batch of commands might not take effect at the same time.
	Commit(){
		return _Error(DllCall(this.vt(3),"ptr",this.__,"uint"),"Commit")
	}

	; Waits for the composition engine to finish processing the previous call to the IDCompositionDevice::Commit method.
	WaitForCommitCompletion(){
		return _Error(DllCall(this.vt(4),"ptr",this.__,"uint"),"WaitForCommitCompletion")
	}

	; Retrieves information from the composition engine about composition times and the frame rate.
	; This method retrieves timing information about the composition engine that an application can use to synchronize the rasterization of bitmaps with independent animations.
	GetFrameStatistics(){
		static DXGI_RATIONAL:="UINT Numerator;UINT Denominator;"
			,DCOMPOSITION_FRAME_STATISTICS:="LARGE_INTEGER lastFrameTime;DXGI_RATIONAL currentCompositionRate;LARGE_INTEGER currentTime;LARGE_INTEGER timeFrequency;LARGE_INTEGER nextEstimatedFrameTime;"
		statistics:=struct("DCOMPOSITION_FRAME_STATISTICS")
		_Error(DllCall(this.vt(5),"ptr",this.__
			,"ptr",statistics[]
			,"uint"),"GetFrameStatistics")
		return statistics
	}

	; Creates a composition target object that is bound to the window that is represented by the specified window handle ( HWND).
/*
	A Microsoft DirectComposition visual tree must be bound to a window before anything can be displayed on screen. The window can be a top-level window or a child window. In either case, the window can be a layered window, but in all cases the window must belong to the calling process. If the window belongs to a different process, this method returns DCOMPOSITION_ERROR_ACCESS_DENIED.
	When DirectComposition content is composed to the window, the content is always composed on top of whatever is drawn directly to that window through the device context ( HDC) returned by the GetDC function, or by calls to Microsoft DirectX Present methods. However, because window clipping rules apply to DirectComposition content, if the window has child windows, those child windows may clip the visual tree. The topmost parameter determines whether child windows clip the visual tree.
	Conceptually, each window consists of four layers:
		The contents drawn directly to the window handle (this is the bottommost layer). 
		An optional DirectComposition visual tree. 
		The contents of all child windows, if any. 
		Another optional DirectComposition visual tree (this is the topmost layer).
		All four layers are clipped to the window's visible region.
	At most, only two composition targets can be created for each window in the system, one topmost and one not topmost. If a composition target is already bound to the specified window at the specified layer, this method fails. When a composition target object is destroyed, the layer it composed is available for use by a new composition target object.
*/
	CreateTargetForHwnd(hwnd,topmos=1){
		_Error(DllCall(this.vt(6),"ptr",this.__
			,"ptr",hwnd
			,"int",topmost
			,"ptr*",target
			,"uint"),"CreateTargetForHwnd")
		return new IDCompositionTarget(target)
	}

	; Creates a new visual object.
	; A new visual object has a static value of zero for the OffsetX and OffsetY properties, and NULL for the Transform, Clip, and Content properties. Initially, the visual does not cause the contents of a window to change. The visual must be added as a child of another visual, or as the root of a composition target, before it can affect the appearance of a window.
	CreateVisual(){
		_Error(DllCall(this.vt(7),"ptr",this.__
			,"ptr*",visual
			,"uint"),"CreateVisual")
		return new IDCompositionVisual(visual)
	}

	; Creates an updateable surface object that can be associated with one or more visuals for composition.
/*
	A Microsoft DirectComposition surface is a rectangular array of pixels that can be associated with a visual for composition.
	A newly created surface object is in an uninitialized state. While it is uninitialized, the surface has no effect on the composition of the visual tree. It behaves exactly like a surface that has 100% transparent pixels.
	To initialize the surface with pixel data, use the IDCompositionSurface::BeginDraw method. The first call to this method must cover the entire surface area to provide an initial value for every pixel. Subsequent calls may specify smaller sub-rectangles of the surface to update.
	DirectComposition surfaces support the following pixel formats:
		DXGI_FORMAT_B8G8R8A8_UNORM 
		DXGI_FORMAT_R8G8B8A8_UNORM 
		DXGI_FORMAT_R16G16B16A16_FLOAT
*/
	CreateSurface(width,height,pixelFormat,alphaMode){
		_Error(DllCall(this.vt(8),"ptr",this.__
			,"uint",width
			,"uint",height
			,"int",pixelFormat
			,"int",alphaMode
			,"ptr*",surface
			,"uint"),"CreateSurface")
		return new IDCompositionSurface(surface)
	}

	; Creates a sparsely populated surface that can be associated with one or more visuals for composition.
	; This method fails if initialWidth or initialHeight exceeds 16,777,216 pixels.
	CreateVirtualSurface(initialWidth,initialHeight,pixelFormat,alphaMode){
		_Error(DllCall(this.vt(9),"ptr",this.__
			,"uint",initialWidth
			,"uint",initialHeight
			,"int",pixelFormat
			,"int",alphaMode
			,"ptr*",virtualSurface
			,"uint"),"CreateVirtualSurface")
		return new IDCompositionVirtualSurface(virtualSurface)
	}

	; Creates a new composition surface object that wraps an existing composition surface.
	; This method enables an application to use a shared composition surface in a composition tree.
	CreateSurfaceFromHandle(handle){
		_Error(DllCall(this.vt(10),"ptr",this.__
			,"ptr",handle
			,"ptr*",surface
			,"uint"),"CreateSurfaceFromHandle")
		return surface
	}

	; Creates a wrapper object that represents the rasterization of a layered window, and that can be associated with a visual for composition.
	; You can use the surface pointer in calls to the IDCompositionVisual::SetContent method to set the content of one or more visuals. After setting the content, the visuals compose the contents of the specified layered window as long as the window is layered. If the window is unlayered, the window content disappears from the output of the composition tree. If the window is later re-layered, the window content reappears as long as it is still associated with a visual. If the window is resized, the affected visuals are re-composed.
	; The contents of the window are not cached beyond the life of the window. That is, if the window is destroyed, the affected visuals stop composing the window.
	; If the window is moved off-screen or resized to zero, the system stops composing the content of visuals. You should use the DwmSetWindowAttribute function with the DWMWA_CLOAK flag to "cloak" the layered child window when you need to hide the original window while allowing the system to continue to compose the content of the visuals. 
	CreateSurfaceFromHwnd(hwnd){
		_Error(DllCall(this.vt(11),"ptr",this.__
			,"ptr",hwnd
			,"ptr*",surface
			,"uint"),"CreateSurfaceFromHwnd")
		return surface
	}
	
	; A new 2D/3D transform object has a static value of zero for the OffsetX and OffsetY properties.

	; Creates a 2D translation transform object.
	CreateTranslateTransform(){
		_Error(DllCall(this.vt(12),"ptr",this.__
			,"ptr*",translateTransform
			,"uint"),"CreateTranslateTransform")
		return new IDCompositionTranslateTransform(translateTransform)
	}

	; Creates a 2D scale transform object.
	CreateScaleTransform(){
		_Error(DllCall(this.vt(13),"ptr",this.__
			,"ptr*",scaleTransform
			,"uint"),"CreateScaleTransform")
		return new IDCompositionScaleTransform(scaleTransform)
	}

	; Creates a 2D rotation transform object.
	CreateRotateTransform(){
		_Error(DllCall(this.vt(14),"ptr",this.__
			,"ptr*",rotateTransform
			,"uint"),"CreateRotateTransform")
		return new IDCompositionRotateTransform(rotateTransform)
	}

	; Creates a 2D skew transform object.
	CreateSkewTransform(){
		_Error(DllCall(this.vt(15),"ptr",this.__
			,"ptr*",skewTransform
			,"uint"),"CreateSkewTransform")
		return new IDCompositionSkewTransform(skewTransform)
	}

	; Creates a 2D 3-by-2 matrix transform object.
	; A new matrix transform object has the identity matrix as its initial value. The identity matrix is the 3x2 matrix with ones on the main diagonal and zeros elsewhere, as shown in the following illustration.
	; When an identity transform is applied to an object, it does not change the position, shape, or size of the object. It is similar to the way that multiplying a number by one does not change the number. Any transform other than the identity transform will modify the position, shape, and/or size of objects.
	CreateMatrixTransform(){
		_Error(DllCall(this.vt(16),"ptr",this.__
			,"ptr*",matrixTransform
			,"uint"),"CreateMatrixTransform")
		return new IDCompositionMatrixTransform(matrixTransform)
	}

	; Creates a 2D transform group object that holds an array of 2D transform objects.
	; The array entries in a transform group cannot be changed. However, each transform in the array can be modified through its own property setting methods. If a transform in the array is modified, the change is reflected in the computed matrix of the transform group.
	CreateTransformGroup(transforms,elements=0){
		_Error(DllCall(this.vt(17),"ptr",this.__
			,"ptr",IsObject(transforms)?transforms[]:transforms
			,"uint",elements?elements:transforms.maxindex()
			,"ptr*",transformGroup
			,"uint"),"CreateTransformGroup")
		return new IDCompositionTransform(transformGroup) ; not completed
	}

	; Creates a 3D translation transform object.
	; A newly created 3D translation transform has a static value of 0 for the OffsetX, OffsetY, and OffsetZ properties.
	CreateTranslateTransform3D(){
		_Error(DllCall(this.vt(18),"ptr",this.__
			,"ptr*",translateTransform3D
			,"uint"),"CreateTranslateTransform3D")
		return new IDCompositionTranslateTransform3D(translateTransform3D)
	}

	; Creates a 3D scale transform object.
	; A new 3D scale transform object has a static value of 1.0 for the ScaleX, ScaleY, and ScaleZ properties.
	CreateScaleTransform3D(){
		_Error(DllCall(this.vt(19),"ptr",this.__
			,"ptr*",scaleTransform3D
			,"uint"),"CreateScaleTransform3D")
		return new IDCompositionScaleTransform3D(scaleTransform3D)
	}

	; Creates a 3D rotation transform object.
	; A new 3D rotation transform object has a default static value of zero for the Angle, CenterX, CenterY, AxisX, and AxisY properties, and a default static value of 1.0 for the AxisZ property.
	CreateRotateTransform3D(){
		_Error(DllCall(this.vt(20),"ptr",this.__
			,"ptr*",rotateTransform3D
			,"uint"),"CreateRotateTransform3D")
		return new IDCompositionRotateTransform3D(rotateTransform3D)
	}

	; Creates a 3D 4-by-4 matrix transform object.
	; The array entries in a 3D transform group cannot be changed. However, each transform in the array can be modified through its own property setting methods. If a transform in the array is modified, the change is reflected in the computed matrix of the transform group.
	; The new 3D matrix transform has the identity matrix as its value. The identity matrix is the 4-by-4 matrix with ones on the main diagonal and zeros elsewhere, as shown in the following illustration.
	; Four-by-four identity matrix
	; hen an identity transform is applied to an object, it does not change the position, shape, or size of the object. It is similar to the way that multiplying a number by one does not change the number. Any transform other than the identity transform will modify the position, shape, and/or size of objects.
	CreateMatrixTransform3D(){
		_Error(DllCall(this.vt(21),"ptr",this.__
			,"ptr*",matrixTransform3D
			,"uint"),"CreateMatrixTransform3D")
		return new IDCompositionMatrixTransform3D(matrixTransform3D)
	}

	; Creates a 3D transform group object that holds an array of 3D transform objects.
	; The array entries in a 3D transform group cannot be changed. However, each transform in the array can be modified through its own property setting methods. If a transform in the array is modified, the change is reflected in the computed matrix of the transform group.
	CreateTransform3DGroup(transforms3D,elements=0){
		_Error(DllCall(this.vt(22),"ptr",this.__
			,"ptr",IsObject(transforms3D)?transforms3D[]:transforms3D
			,"uint",elements?elements:transforms3D.maxindex()
			,"ptr*",transform3DGroup
			,"uint"),"CreateTransform3DGroup")
		return new IDCompositionTransform3D(transform3DGroup) ; not completed
	}

	; Creates an object that represents multiple effects to be applied to a visual subtree.
	; An effect group enables an application to apply multiple effects to a single visual subtree.
	; A new effect group has a default opacity value of 1.0 and no 3D transformations.
	CreateEffectGroup(){
		_Error(DllCall(this.vt(23),"ptr",this.__
			,"ptr*",effectGroup
			,"uint"),"CreateEffectGroup")
		return new IDCompositionEffectGroup(effectGroup)
	}

	; Creates a clip object that can be used to restrict the rendering of a visual subtree to a rectangular area.
	; A newly created clip object has a static value of Online–FLT_MAX for the left and top properties, and a static value of –FLT_MAX for the right and bottom properties, effectively making it a no-op clip object.
	CreateRectangleClip(){
		_Error(DllCall(this.vt(24),"ptr",this.__
			,"ptr*",clip
			,"uint"),"CreateRectangleClip")
		return new IDCompositionRectangleClip(clip)
	}

	; Creates an animation object that is used to animate one or more scalar properties of one or more Microsoft DirectComposition objects.
	; A number of DirectComposition object properties can have an animation object as the value of the property. When a property has an animation object as its value, DirectComposition redraws the visual at the refresh rate to reflect the changing value of the property that is being animated.
	; A newly created animation object does not have any animation segments associated with it. An application must use the methods of the IDCompositionAnimation interface to build an animation function before setting the animation object as the property of another DirectComposition object.
	CreateAnimation(){
		_Error(DllCall(this.vt(25),"ptr",this.__
			,"ptr*",animation
			,"uint"),"CreateAnimation")
		return new IDCompositionAnimation(animation)
	}

	; Determines whether the DirectComposition device object is still valid.
	; If the Microsoft DirectX Graphics Infrastructure (DXGI) device is lost, the DirectComposition device associated with the DXGI device is also lost. When it detects a lost device, DirectComposition sends the WM_PAINT message to all windows that are composing DirectComposition content using the lost device. An application should call CheckDeviceState in response to each WM_PAINT message to ensure that the DirectComposition device object is still valid. The application must take steps to recover content if the device object becomes invalid. Steps include creating new DXGI and DirectComposition devices, and recreating all content. (It’s not possible to create just a new DXGI device and associate it with the existing DirectComposition device.) The system ensures that the device object remains valid between WM_PAINT messages.
	CheckDeviceState(){
		_Error(DllCall(this.vt(26),"ptr",this.__
			,"int*",pfValid
			,"uint"),"CheckDeviceState")
		return allpfValid
	}
}

class IDCompositionTarget extends IUnknown
{
	static iid := "{eacdd04c-117e-4e17-88f4-d1b12b0e3d89}"

	; Sets a visual object as the new root object of a visual tree.
	; A visual can be either the root of a single visual tree, or a child of another visual, but it cannot be both at the same time. This method fails if the visual parameter is already the root of another visual tree, or is a child of another visual.
	; If visual is NULL, the visual tree is empty. If there was a previous non-NULL root visual, that visual becomes available for use as the root of another visual tree, or as a child of another visual.
	SetRoot(visual){
		return _Error(DllCall(this.vt(3),"ptr",this.__
			,"ptr",IsObject(visual)?visual.__:visual
			,"uint"),"SetRoot")
	}
}

class IDCompositionVisual extends IUnknown
{
	static iid := "{4d93059d-097b-4651-9a60-f0f25116e2f3}"

	; Changes the value of the OffsetX property of this visual. The OffsetX property specifies the new offset of the visual along the x-axis, relative to the parent visual.
/*
	This method fails if the offsetX parameter is NaN, positive infinity, or negative infinity.
	Changing the OffsetX property of a visual transforms the coordinate system of the entire visual subtree that is rooted at that visual. If the Clip property of this visual is specified, the clip rectangle is also transformed.
	A transformation that is specified by the Transform property is applied after the OffsetX property. In other words, the effect of setting the Transform property and the OffsetX property is the same as setting only the Transform property on a transform group object where the first member of the group is an IDCompositionTranslateTransform object that has the same OffsetX value as offsetX. However, you should use IDCompositionVisual::SetOffsetX whenever possible because it is slightly faster.
	If the OffsetX and OffsetY properties are set to 0, and the Transform property is set to NULL, the coordinate system of the visual is the same as that of its parent.
	If the OffsetX property was previously animated, this method removes the animation and sets the property to the specified static value
	
	This method makes a copy of the specified animation. If the animation object referenced by the animation parameter is changed after this call, the change does not affect the OffsetX property unless this method is called again. If the OffsetX property was previously animated, this method replaces that animation with the new animation.
	This method fails if animation is an invalid pointer or if it was not created by the same IDCompositionDevice interface that created this visual. The interface cannot be a custom implementation; only interfaces created by Microsoft DirectComposition can be used with this method.
*/
	SetOffsetX(offset){
		return _Error(IsObject(offset)?DllCall(this.vt(4),"ptr",this.__,"ptr",offset.__,"uint"):DllCall(this.vt(3),"ptr",this.__,"float",offset,"uint"),"SetOffsetX")
	}

	; Changes or animates the value of the OffsetY property of this visual, altering the vertical position of the visual relative to its parent.
	SetOffsetY(offset){
		return _Error(IsObject(offset)?DllCall(this.vt(6),"ptr",this.__,"ptr",offset.__,"uint"):DllCall(this.vt(5),"ptr",this.__,"float",offset,"uint"),"SetOffsetY")
	}

	; Sets the Transform property of this visual to the specified 2D transform object.
/*
	Setting the Transform property transforms the coordinate system of the entire visual subtree that is rooted at this visual. If the Clip property of this visual is specified, the clip rectangle is also transformed.
	If the Transform property previously specified a transform object, the newly specified transform matrix replaces the transform object.
	A transformation specified by the Transform property is applied after the OffsetX and OffsetY properties. In other words, the effect of setting the Transform property and the OffsetX and OffsetY properties is the same as setting only the Transform property on a transform group where the first member of the group is an IDCompositionTranslateTransform object that has those same OffsetX and OffsetY values. However, you should use the IDCompositionVisual::SetOffsetX and SetOffsetY methods whenever possible because they are slightly faster.
	This method fails if transform is an invalid pointer or if it was not created by the same IDCompositionDevice interface that created this visual. The interface cannot be a custom implementation; only interfaces created by Microsoft DirectComposition can be used with this method.
	If the transform parameter is NULL, the coordinate system of this visual is transformed only by its OffsetX and OffsetY properties. Setting the Transform property to NULL is equivalent to setting it to an IDCompositionMatrixTransform object where the specified matrix is the identity matrix. However, an application should set the Transform property to NULL whenever possible because it is slightly faster.
	If the OffsetX and OffsetY properties are set to 0, and the Transform property is set to NULL, the coordinate system of the visual is the same as that of its parent.
*/
	SetTransform(matrix){
		return _Error(matrix.__?DllCall(this.vt(8),"ptr",this.__,"ptr",matrix.__,"uint"):IsObject(matrix)?DllCall(this.vt(7),"ptr",this.__,"ptr",matrix[],"uint"):DllCall(this.vt(7),"ptr",this.__,"ptr",matrix,"uint"),"SetTransform")
	}

	; Sets the TransformParent property of this visual. The TransformParent property establishes the coordinate system relative to which this visual is composed.
	; The coordinate system of a visual is modified by the OffsetX, OffsetY, and Transform properties. Normally, these properties define the coordinate system of a visual relative to its immediate parent. This method specifies the visual relative to which the coordinate system for this visual is based. The specified visual must be an ancestor of the current visual. If it is not an ancestor, the coordinate system is based on this visual's immediate parent, just as if the TransformParent property were set to NULL. Because visuals can be reparented, this property can take effect again if the specified visual becomes an ancestor of the target visual through a reparenting operation.
	; If the visual parameter is NULL, the coordinate system is always transformed relative to the visual's immediate parent. This is the default behavior if this method is not used.
	; This method fails if the visual parameter is an invalid pointer or if it was not created by the same IDCompositionDevice interface as this visual. The interface cannot be a custom implementation; only interfaces created by Microsoft DirectComposition can be used with this method.
	SetTransformParent(visual){
		return _Error(DllCall(this.vt(9),"ptr",this.__
			,"ptr",IsObject(visual)?visual.__:visual
			,"uint"),"SetTransformParent")
	}

	; Sets the Effect property of this visual. The Effect property modifies how the subtree that is rooted at this visual is blended with the background, and can apply a 3D perspective transform to the visual.
	; This method creates an implicit off-screen surface to which the subtree that is rooted at this visual is composed. The surface is used as one of the inputs to the specified effect. The output of the effect is composed directly to the composition target. Some effects also use the composition target as another implicit input. This is typically the case for compositional or blend effects such as opacity, where the composition target is considered to be the "background." In that case, any visuals that are "behind" the current visual are included in the composition target when the current visual is rendered and are considered to be the "background" that this visual composes to.
	; If this visual is not the root of a visual tree and one of its ancestors also has an effect applied to it, the off-screen surface created by the closest ancestor is the composition target to which this visual's effect is composed. Otherwise, the composition target is the root composition target. As a consequence, the background for compositional and blend effects includes only the visuals up to the closest ancestor that itself has an effect. Conversely, any effects applied to visuals under the current visual use the newly created off-screen surface as the background, which may affect how those visuals ultimately compose on top of what the end user perceives as being "behind" those visuals.
	; If the effect parameter is NULL, no bitmap effect is applied to this visual. Any previous effects that were associated with this visual are removed. The off-screen surface is also removed and the visual subtree is composed directly to the parent composition target, which may also affect how compositional or blend effects under this visual are rendered.
	; This method fails if effect is an invalid pointer or if it was not created by the same IDCompositionDevice interface that created this visual. The interface cannot be a custom implementation; only interfaces created by Microsoft DirectComposition can be used with this method.
	SetEffect(effect){
		return _Error(DllCall(this.vt(10),"ptr",this.__
			,"ptr",IsObject(effect)?effect.__:effect
			,"uint"),"SetEffect")
	}

	; Sets the BitmapInterpolationMode property, which specifies the mode for Microsoft DirectComposition to use when interpolating pixels from bitmaps that are not axis-aligned and drawn exactly at scale.
	; The interpolation mode affects how a bitmap is composed when it is transformed such that there is no one-to-one correspondence between pixels in the bitmap and pixels on the screen.
	; By default, a visual inherits the interpolation mode of the parent visual, which may inherit the interpolation mode of its parent visual, and so on. A visual uses the default interpolation mode if this method is never called for the visual, or if this method is called with DCOMPOSITION_BITMAP_INTERPOLATION_MODE_INHERIT. If no visuals set the interpolation mode, the default for the entire visual tree is nearest neighbor interpolation, which offers the lowest visual quality but the highest performance.
	; If the interpolationMode parameter is anything other than DCOMPOSITION_BITMAP_INTERPOLATION_MODE_INHERIT, this visual's bitmap is composed with the specified interpolation mode, and this mode becomes the new default mode for the children of this visual. That is, if the interpolation mode of this visual's children is unchanged or explicitly set to DCOMPOSITION_BITMAP_INTERPOLATION_MODE_INHERIT, the bitmaps of the child visuals are composed using the interpolation mode of this visual.
	SetBitmapInterpolationMode(interpolationMode){
		return _Error(DllCall(this.vt(11),"ptr",this.__
			,"int",interpolationMode
			,"uint"),"SetBitmapInterpolationMode")
	}

	; Sets the BorderMode property, which specifies how to compose the edges of bitmaps and clips associated with this visual, or with visuals in the subtree rooted at this visual.
	; The border mode affects how the edges of a bitmap are composed when the bitmap is transformed such that the edges are not exactly axis-aligned and at precise pixel boundaries. It also affects how content is clipped at the corners of a clip that has rounded corners, and at the edge of a clip that is transformed such that the edges are not exactly axis-aligned and at precise pixel boundaries.
	; By default, a visual inherits the border mode of its parent visual, which may inherit the border mode of its parent visual, and so on. A visual uses the default border mode if this method is never called for the visual, or if this method is called with DCOMPOSITION_BORDER_MODE_INHERIT. If no visuals set the border mode, the default for the entire visual tree is aliased rendering, which offers the lowest visual quality but the highest performance.
	; If the borderMode parameter is anything other than DCOMPOSITION_BORDER_MODE_INHERIT, this visual's bitmap and clip are composed with the specified border mode. In addition, this border mode becomes the new default for the children of the current visual. That is, if the border mode of this visual's children is unchanged or explicitly set to DCOMPOSITION_BORDER_MODE_INHERIT, the bitmaps and clips of the child visuals are composed using the border mode of this visual.
	SetBorderMode(borderMode){
		return _Error(DllCall(this.vt(12),"ptr",this.__
			,"int",borderMode
			,"uint"),"SetBorderMode")
	}

	; Sets the Clip property of this visual to the specified rectangle. The Clip property restricts the rendering of the visual subtree that is rooted at this visual to the specified rectangular region.
/*
	Setting the Clip property clips this visual along with all visuals in the subtree that is rooted at this visual. The rectangle specified by the rect parameter is transformed by the OffsetX, OffsetY, and Transform properties.
	If the Clip property previously specified a clip object, the newly specified clip rectangle replaces the clip object.
	This method fails if any members of the rect structure are NaN, positive infinity, or negative infinity.
	If the clip rectangle is empty, the visual is fully clipped; that is, the visual is included in the visual tree, but it does not render anything. To exclude a particular visual from a composition, remove the visual from the visual tree instead of setting an empty clip rectangle. Removing the visual results in better performance.

	If the Clip property previously specified a clip rectangle, the newly specified Clip object replaces the clip rectangle.
	This method fails if clip is an invalid pointer or if it was not created by the same IDCompositionDevice interface that created this visual. The interface cannot be a custom implementation; only interfaces created by Microsoft DirectComposition can be used with this method.
	If clip is NULL, the visual is not clipped relative to its parent. However, the visual is clipped by the clip object of the parent visual, or by the closest ancestor visual that has a clip object. Setting clip to NULL is similar to specifying a clip object whose clip rectangle has the left and top sides set to negative infinity, and the right and bottom sides set to positive infinity. Using a NULL clip object results in slightly better performance.
	If clip specifies a clip object that has an empty rectangle, the visual is fully clipped; that is, the visual is included in the visual tree, but it does not render anything. To exclude a particular visual from a composition, remove the visual from the visual tree instead of setting an empty clip rectangle. Removing the visual results in better performance.
*/
	SetClip(rect){
		return _Error(rect.__?DllCall(this.vt(14),"ptr",this.__,"ptr",rect.__,"uint"):IsObject(rect)?DllCall(this.vt(13),"ptr",this.__,"ptr",rect[],"uint"):DllCall(this.vt(13),"ptr",this.__,"ptr",rect,"uint"),"SetClip")
	}

	; Sets the Content property of this visual to the specified bitmap or window wrapper.
/*
	The content parameter must point to one of the following:
		An object that implements the IDCompositionSurface interface. 
		An object that implements the IDXGISwapChain1 interface. 
		A wrapper object that is returned by the CreateSurfaceFromHandle or CreateSurfaceFromHwnd method.
	The new content replaces any content that was previously associated with the visual. If the content parameter is NULL, the visual has no associated content.
	A visual can be associated with a bitmap object or a window wrapper. A bitmap is either a Microsoft DirectX swap chain or a Microsoft DirectComposition surface.
	A window wrapper is created with the CreateSurfaceFromHwnd method and is a stand-in for the rasterization of another window, which must be a top-level window or a layered child window. A window wrapper is conceptually equivalent to a bitmap that is the size of the target window on which the contents of the window are drawn. The contents include the target window's child windows (layered or otherwise), and any DirectComposition content that is drawn in the child windows.
	A DirectComposition surface wrapper is created with the CreateSurfaceFromHandle method and is a reference to a swap chain. An application might use a surface wrapper in a cross-process scenario where one process creates the swap chain and another process associates the bitmap with a visual.
	The bitmap is always drawn at position (0,0) relative to the visual's coordinate system, although the coordinate system is directly affected by the OffsetX, OffsetY, and Transform properties, as well as indirectly by the transformations on ancestor visuals. The bitmap of a visual is always drawn behind the children of that visual.
*/
	SetContent(content){
		return _Error(DllCall(this.vt(15),"ptr",this.__
			,"ptr",IsObject(content)?content.__:content
			,"uint"),"SetContent")
	}

	; Adds a new child visual to the children list of this visual.
/*
	Child visuals are arranged in an ordered list. The contents of a child visual are drawn in front of (or above) the contents of its parent visual, but behind (or below) the contents of its children.
	The referenceVisual parameter must be an existing child of the parent visual, or it must be NULL. The insertAbove parameter indicates whether the new child should be rendered immediately above the reference visual in the Z order, or immediately below it.
	If the referenceVisual parameter is NULL, the specified visual is rendered above or below all children of the parent visual, depending on the value of the insertAbove parameter. If insertAbove is TRUE, the new child visual is above no sibling, therefore it is rendered below all of its siblings. Conversely, if insertAbove is FALSE, the visual is below no sibling, therefore it is rendered above all of its siblings.
	The visual specified by the visual parameter can be either a child of a single other visual, or the root of a visual tree that is associated with a composition target. If visual is already a child of another visual, AddVisual fails. The child visual must be removed from the children list of its previous parent before adding it to the children list of the new parent. If visual is the root of a visual tree, the visual must be dissociated from that visual tree before adding it to the children list of the new parent. To dissociate the visual from a visual tree, call the IDCompositionTarget::SetRoot method and specify either a different visual or NULL as the visual parameter.
	A child visual need not have been created by the same IDCompositionDevice interface as its parent. When visuals from different devices are combined in the same visual tree, Microsoft DirectComposition composes the tree as it normally would, except that changes to a particular visual take effect only when IDCompositionDevice::Commit is called on the device object that created the visual. The ability to combine visuals from different devices enables multiple threads to create and manipulate a single visual tree while maintaining independent devices that can be used to commit changes asynchronously
	This method fails if visual or referenceVisual is an invalid pointer, or if the visual referenced by the referenceVisual parameter is not a child of the parent visual. These interfaces cannot be custom implementations; only interfaces created by DirectComposition can be used with this method.
*/
	AddVisual(visual,insertAbove,referenceVisual){
		return _Error(DllCall(this.vt(16),"ptr",this.__
			,"ptr",IsObject(visual)?visual.__:visual
			,"int",insertAbove
			,"ptr",IsObject(referenceVisual)?referenceVisual.__:referenceVisual
			,"uint"),"AddVisual")
	}

	; Removes a child visual from the children list of this visual.
	; Child visuals are arranged in an ordered list. The contents of a child visual are drawn in front of (or above) the contents of its parent visual, but behind (or below) the contents of its children.
	; This method fails if visual is not a child of the parent visual.
	RemoveVisual(visual){
		return _Error(DllCall(this.vt(17),"ptr",this.__
			,"ptr",IsObject(visual)?visual.__:visual
			,"uint"),"RemoveVisual")
	}

	; Removes all visuals from the children list of this visual.
	; This method can be called even if this visual has no children.
	RemoveAllVisuals(){
		return _Error(DllCall(this.vt(18),"ptr",this.__,"uint"),"RemoveAllVisuals")
	}

	; Sets the blending mode for this visual.
	; The composite mode determines how visual's bitmap is blended with the screen. By default, the visual is blended with "source over" semantics; that is, the colors are blended with per-pixel transparency.
	SetCompositeMode(compositeMode){
		return _Error(DllCall(this.vt(19),"ptr",this.__
			,"int",compositeMode
			,"uint"),"SetCompositeMode")
	}
}

class IDCompositionEffect extends IUnknown
{
	static iid := "{EC81B08F-BFCB-4e8d-B193-A915587999E8}"
}

class IDCompositionTransform3D extends IDCompositionEffect
{
	static iid := "{71185722-246B-41f2-AAD1-0443F7F4BFC2}"
}

class IDCompositionTransform extends IDCompositionTransform3D
{
	static iid := "{FD55FAA7-37E0-4c20-95D2-9BE45BC33F55}"
}

class IDCompositionTranslateTransform extends IDCompositionTransform
{
	static iid := "{06791122-C6F0-417d-8323-269E987F5954}"

	; Changes the value of the OffsetX property of a 2D translation transform. The OffsetX property specifies the distance to translate along the x-axis.
	SetOffsetX(offset){
		return _Error(IsObject(offset)?DllCall(this.vt(4),"ptr",this.__,"ptr",offset.__,"uint"):DllCall(this.vt(3),"ptr",this.__,"float",offset,"uint"),"SetOffsetX")
	}

	; Changes the value of the OffsetY property of a 2D translation transform. The OffsetY property specifies the distance to translate along the y-axis.
	SetOffsetY(offset){
		return _Error(IsObject(offset)?DllCall(this.vt(6),"ptr",this.__,"ptr",offset.__,"uint"):DllCall(this.vt(5),"ptr",this.__,"float",offset,"uint"),"SetOffsetY")
	}
}

class IDCompositionScaleTransform extends IDCompositionTransform
{
	static iid := "{71FDE914-40EF-45ef-BD51-68B037C339F9}"

	SetScaleX(scale){
		return _Error(IsObject(scale)?DllCall(this.vt(4),"ptr",this.__,"ptr",scale.__,"uint"):DllCall(this.vt(3),"ptr",this.__,"float",scale,"uint"),"SetScaleX")
	}

	SetScaleY(scale){
		return _Error(IsObject(scale)?DllCall(this.vt(6),"ptr",this.__,"ptr",scale.__,"uint"):DllCall(this.vt(5),"ptr",this.__,"float",scale,"uint"),"SetScaleY")
	}

	SetCenterX(center){
		return _Error(IsObject(center)?DllCall(this.vt(8),"ptr",this.__,"ptr",center.__,"uint"):DllCall(this.vt(7),"ptr",this.__,"float",center,"uint"),"SetCenterX")
	}

	SetCenterY(center){
		return _Error(IsObject(center)?DllCall(this.vt(10),"ptr",this.__,"ptr",center.__,"uint"):DllCall(this.vt(9),"ptr",this.__,"float",center,"uint"),"SetCenterY")
	}
}

class IDCompositionRotateTransform extends IDCompositionTransform
{
	static iid := "{641ED83C-AE96-46c5-90DC-32774CC5C6D5}"

	SetAngle(angle){
		return _Error(IsObject(angle)?DllCall(this.vt(4),"ptr",this.__,"ptr",angle.__,"uint"):DllCall(this.vt(3),"ptr",this.__,"float",angle,"uint"),"SetAngle")
	}

	SetCenterX(center){
		return _Error(IsObject(center)?DllCall(this.vt(6),"ptr",this.__,"ptr",center.__,"uint"):DllCall(this.vt(5),"ptr",this.__,"float",center,"uint"),"SetCenterX")
	}

	SetCenterY(center){
		return _Error(IsObject(center)?DllCall(this.vt(8),"ptr",this.__,"ptr",center.__,"uint"):DllCall(this.vt(7),"ptr",this.__,"float",center,"uint"),"SetCenterY")
	}
}

class IDCompositionSkewTransform extends IDCompositionTransform
{
	static iid := "{E57AA735-DCDB-4c72-9C61-0591F58889EE}"

	SetAngleX(angle){
		return _Error(IsObject(angle)?DllCall(this.vt(4),"ptr",this.__,"ptr",angle.__,"uint"):DllCall(this.vt(3),"ptr",this.__,"float",angle,"uint"),"SetAngleX")
	}

	SetAngleY(angle){
		return _Error(IsObject(angle)?DllCall(this.vt(6),"ptr",this.__,"ptr",angle.__,"uint"):DllCall(this.vt(5),"ptr",this.__,"float",angle,"uint"),"SetAngleY")
	}

	SetCenterX(center){
		return _Error(IsObject(center)?DllCall(this.vt(8),"ptr",this.__,"ptr",center.__,"uint"):DllCall(this.vt(7),"ptr",this.__,"float",center,"uint"),"SetCenterX")
	}

	SetCenterY(center){
		return _Error(IsObject(center)?DllCall(this.vt(10),"ptr",this.__,"ptr",center.__,"uint"):DllCall(this.vt(9),"ptr",this.__,"float",center,"uint"),"SetCenterY")
	}
}

class IDCompositionMatrixTransform extends IDCompositionTransform
{
	static iid := "{16CDFF07-C503-419c-83F2-0965C7AF1FA6}"

	; Changes all values of the matrix of this 2D transform.
	SetMatrix(matrix){
		return _Error(DllCall(this.vt(3),"ptr",this.__
			,"ptr",IsObject(matrix)?matrix[]:matrix
			,"uint"),"SetMatrix")
	}

	; Changes the value of one element of the matrix of this transform.
	SetMatrixElement(row,column,value){
		return _Error(IsObject(value)?DllCall(this.vt(5),"ptr",this.__
			,"ptr",row,"ptr",column
			,"ptr",value.__
			,"uint"):DllCall(this.vt(4),"ptr",this.__
			,"ptr",row,"ptr",column
			,"float",value
			,"uint"),"SetMatrixElement")
	}
}

class IDCompositionEffectGroup extends IDCompositionEffect
{
	static iid := "{A7929A74-E6B2-4bd6-8B95-4040119CA34D}"

	; Changes the value of the Opacity property.
	SetOpacity(opacity){
		return _Error(IsObject(opacity)?DllCall(this.vt(4),"ptr",this.__,"ptr",opacity.__,"uint"):DllCall(this.vt(3),"ptr",this.__,"float",opacity,"uint"),"SetOpacity")
	}
	
	; Sets the 3D transformation effect object that modifies the rasterization of the visuals that this effect group is applied to.
	SetTransform3D(transform3D){
		return _Error(DllCall(this.vt(5),"ptr",this.__
			,"ptr",IsObject(transform3D)?transform3D.__:transform3D
			,"uint"),"SetTransform3D")
	}
}

class IDCompositionTranslateTransform3D extends IDCompositionTransform3D
{
	static iid := "{91636D4B-9BA1-4532-AAF7-E3344994D788}"

	SetOffsetX(offset){
		return _Error(IsObject(offset)?DllCall(this.vt(4),"ptr",this.__,"ptr",offset.__,"uint"):DllCall(this.vt(3),"ptr",this.__,"float",offset,"uint"),"SetOffsetX")
	}

	SetOffsetY(offset){
		return _Error(IsObject(offset)?DllCall(this.vt(6),"ptr",this.__,"ptr",offset.__,"uint"):DllCall(this.vt(5),"ptr",this.__,"float",offset,"uint"),"SetOffsetY")
	}

	SetOffsetZ(offset){
		return  _Error(IsObject(offset)?DllCall(this.vt(6),"ptr",this.__,"ptr",offset.__,"uint"):DllCall(this.vt(5),"ptr",this.__,"float",offset,"uint"),"SetOffsetZ")
	}
}

class IDCompositionScaleTransform3D extends IDCompositionTransform3D
{
	static iid := "{2A9E9EAD-364B-4b15-A7C4-A1997F78B389}"

	SetScaleX(scale){
		return _Error(IsObject(scale)?DllCall(this.vt(4),"ptr",this.__,"ptr",scale.__,"uint"):DllCall(this.vt(3),"ptr",this.__,"float",scale,"uint"),"SetScaleX")
	}

	SetScaleY(scale){
		return _Error(IsObject(scale)?DllCall(this.vt(6),"ptr",this.__,"ptr",scale.__,"uint"):DllCall(this.vt(5),"ptr",this.__,"float",scale,"uint"),"SetScaleY")
	}

	SetScaleZ(scale){
		return _Error(IsObject(scale)?DllCall(this.vt(8),"ptr",this.__,"ptr",scale.__,"uint"):DllCall(this.vt(7),"ptr",this.__,"float",scale,"uint"),"SetScaleZ")
	}

	SetCenterX(center){
		return _Error(IsObject(center)?DllCall(this.vt(10),"ptr",this.__,"ptr",center.__,"uint"):DllCall(this.vt(9),"ptr",this.__,"float",center,"uint"),"SetCenterX")
	}

	SetCenterY(center){
		return _Error(IsObject(center)?DllCall(this.vt(12),"ptr",this.__,"ptr",center.__,"uint"):DllCall(this.vt(11),"ptr",this.__,"float",center,"uint"),"SetCenterY")
	}

	SetCenterZ(center){
		return _Error(IsObject(center)?DllCall(this.vt(14),"ptr",this.__,"ptr",center.__,"uint"):DllCall(this.vt(13),"ptr",this.__,"float",center,"uint"),"SetCenterZ")
	}
}

class IDCompositionRotateTransform3D extends IDCompositionTransform3D
{
	static iid := "{D8F5B23F-D429-4a91-B55A-D2F45FD75B18}"

	SetAngle(angle){
		return _Error(IsObject(angle)?DllCall(this.vt(4),"ptr",this.__,"ptr",angle.__,"uint"):DllCall(this.vt(3),"ptr",this.__,"float",angle,"uint"),"SetAngle")
	}

	SetAxisX(axis){
		return _Error(IsObject(axis)?DllCall(this.vt(6),"ptr",this.__,"ptr",axis.__,"uint"):DllCall(this.vt(5),"ptr",this.__,"float",axis,"uint"),"SetAxisX")
	}

	SetAxisY(axis){
		return _Error(IsObject(axis)?DllCall(this.vt(8),"ptr",this.__,"ptr",axis.__,"uint"):DllCall(this.vt(7),"ptr",this.__,"float",axis,"uint"),"SetAxisY")
	}

	SetAxisZ(axis){
		return _Error(IsObject(axis)?DllCall(this.vt(10),"ptr",this.__,"ptr",axis.__,"uint"):DllCall(this.vt(9),"ptr",this.__,"float",axis,"uint"),"SetAxisZ")
	}

	SetCenterX(center){
		return _Error(IsObject(center)?DllCall(this.vt(12),"ptr",this.__,"ptr",center.__,"uint"):DllCall(this.vt(11),"ptr",this.__,"float",center,"uint"),"SetCenterX")
	}

	SetCenterY(center){
		return _Error(IsObject(center)?DllCall(this.vt(14),"ptr",this.__,"ptr",center.__,"uint"):DllCall(this.vt(13),"ptr",this.__,"float",center,"uint"),"SetCenterY")
	}

	SetCenterZ(center){
		return _Error(IsObject(center)?DllCall(this.vt(16),"ptr",this.__,"ptr",center.__,"uint"):DllCall(this.vt(15),"ptr",this.__,"float",center,"uint"),"SetCenterZ")
	}
}

class IDCompositionMatrixTransform3D extends IDCompositionTransform3D
{
	static iid := "{4B3363F0-643B-41b7-B6E0-CCF22D34467C}"

	SetMatrix(matrix){
		return _Error(DllCall(this.vt(3),"ptr",this.__
			,"ptr",matrix
			,"uint"),"SetMatrix")
	}

	SetMatrixElement(row,column,value){
		return _Error(IsObject(value)?DllCall(this.vt(5),"ptr",this.__
			,"ptr",row,"ptr",column
			,"ptr",value.__
			,"uint"):DllCall(this.vt(4),"ptr",this.__
			,"ptr",row,"ptr",column
			,"float",value
			,"uint"),"SetMatrixElement")
	}
}

class IDCompositionClip extends IUnknown
{
	static iid := "{64AC3703-9D3F-45ec-A109-7CAC0E7A13A7}"
}

class IDCompositionRectangleClip extends IDCompositionClip
{
	static iid := "{9842AD7D-D9CF-4908-AED7-48B51DA5E7C2}"

	SetLeft(left){
		return _Error(IsObject(left)?DllCall(this.vt(4),"ptr",this.__,"ptr",left.__,"uint"):DllCall(this.vt(3),"ptr",this.__,"float",left,"uint"),"SetLeft")
	}

	SetTop(top){
		return _Error(IsObject(top)?DllCall(this.vt(6),"ptr",this.__,"ptr",top.__,"uint"):DllCall(this.vt(5),"ptr",this.__,"float",top,"uint"),"SetTop")
	}

	SetRight(right){
		return _Error(IsObject(right)?DllCall(this.vt(8),"ptr",this.__,"ptr",right.__,"uint"):DllCall(this.vt(7),"ptr",this.__,"float",right,"uint"),"SetRight")
	}

	SetBottom(bottom){
		return _Error(IsObject(bottom)?DllCall(this.vt(10),"ptr",this.__,"ptr",bottom.__,"uint"):DllCall(this.vt(9),"ptr",this.__,"float",bottom,"uint"),"SetCenterZ")
	}

	SetTopLeftRadiusX(radius){
		return _Error(IsObject(radius)?DllCall(this.vt(12),"ptr",this.__,"ptr",radius.__,"uint"):DllCall(this.vt(11),"ptr",this.__,"float",radius,"uint"),"SetTopLeftRadiusX")
	}

	SetTopLeftRadiusY(radius){
		return _Error(IsObject(radius)?DllCall(this.vt(14),"ptr",this.__,"ptr",radius.__,"uint"):DllCall(this.vt(13),"ptr",this.__,"float",radius,"uint"),"SetTopLeftRadiusY")
	}

	SetTopRightRadiusX(radius){
		return _Error(IsObject(radius)?DllCall(this.vt(16),"ptr",this.__,"ptr",radius.__,"uint"):DllCall(this.vt(15),"ptr",this.__,"float",radius,"uint"),"SetTopRightRadiusX")
	}

	SetTopRightRadiusY(radius){
		return _Error(IsObject(radius)?DllCall(this.vt(18),"ptr",this.__,"ptr",radius.__,"uint"):DllCall(this.vt(17),"ptr",this.__,"float",radius,"uint"),"SetTopRightRadiusY")
	}

	SetBottomLeftRadiusX(radius){
		return _Error(IsObject(radius)?DllCall(this.vt(20),"ptr",this.__,"ptr",radius.__,"uint"):DllCall(this.vt(19),"ptr",this.__,"float",radius,"uint"),"SetBottomLeftRadiusX")
	}

	SetBottomLeftRadiusY(radius){
		return _Error(IsObject(radius)?DllCall(this.vt(22),"ptr",this.__,"ptr",radius.__,"uint"):DllCall(this.vt(21),"ptr",this.__,"float",radius,"uint"),"SetBottomLeftRadiusY")
	}

	SetBottomRightRadiusX(radius){
		return _Error(IsObject(radius)?DllCall(this.vt(24),"ptr",this.__,"ptr",radius.__,"uint"):DllCall(this.vt(23),"ptr",this.__,"float",radius,"uint"),"SetBottomRightRadiusX")
	}

	SetBottomRightRadiusY(radius){
		return _Error(IsObject(radius)?DllCall(this.vt(26),"ptr",this.__,"ptr",radius.__,"uint"):DllCall(this.vt(25),"ptr",this.__,"float",radius,"uint"),"SetBottomRightRadiusY")
	}
}

class IDCompositionSurface extends IUnknown
{
	static iid := "{BB8A4953-2C99-4F5A-96F5-4819027FA3AC}"

	; Initiates drawing on this Microsoft DirectComposition surface object.
/*
	This method enables an application to incrementally update the contents of a DirectComposition surface object. The application must use the following sequence:
		Call BeginDraw to initiate the incremental update, and to retrieve a DXGI surface and an offset. 
		Use the retrieved surface as a render target and draw the updated contents at the retrieved offset. 
		Call the IDCompositionSurface::EndDraw method to finish the update.
	The update rectangle must be within the boundaries of the surface; otherwise, this method fails.
	The retrieved offset is not necessarily the same as the top-left corner of the requested update rectangle. The application must transform its rendering primitives to draw within a rectangle of the same width and height as the input rectangle, but at the given offset. The application should not draw outside of this rectangle.
	If the updateRectangle parameter is NULL, the entire surface is updated. In that case, because the retrieved offset still might not be (0,0), the application still needs to transform its rendering primitives accordingly.
	The first time the application calls this method for a particular non-virtual surface, the update rectangle must cover the entire surface, either by specifying the full surface in the requested update rectangle, or by specifying NULL as the updateRectangle parameter. For virtual surfaces, the first call may be any sub-rectangle of the surface.
	Because each call to this method might retrieve a different DXGI surface, the application should not cache the retrieved surface pointer. The application should release the retrieved pointer as soon as it finishes drawing.
	The retrieved surface rectangle does not contain the previous contents of the bitmap. The application must update every pixel in the update rectangle, either by first clearing the render target, or by issuing enough rendering primitives to fully cover the update rectangle. Because the initial contents of the update surface are undefined, failing to update every pixel leads to undefined behavior.
	Only one DirectComposition surface can be updated at a time. An application must suspend drawing on one surface before beginning or resuming to draw on another surface. If the application calls BeginDraw twice without an intervening call to IDCompositionSurface::EndDraw, either for the same surface or for another surface belonging to the same DirectComposition device, the second call fails. If the application calls IDCompositionDevice::Commit without calling EndDraw, the update remains pending. The update takes effect only after the application calls EndDraw and then calls the IDCompositionDevice::Commit method. If any surfaces are in the drawing or suspended state when IDCompositionDevice::Commit is called, DCOMPOSITION_ERROR_SURFACE_BEING_RENDERED is returned.
*/
	BeginDraw(updateRect,iid){
		updateOffset:=struct("long x;long y")
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"ptr",IsObject(updateRect)?updateRect[]:updateRect
			,"ptr",iid
			,"ptr*",surface
			,"ptr",updateOffset[]
			,"uint"),"BeginDraw")
		return [surface,updateOffset]
	}

	; Marks the end of drawing on this Microsoft DirectComposition surface object.
	; This method completes an update that was begun by a previous call to the IDCompositionSurface::BeginDraw method. After this method returns, the application can start another update on the same surface object or on a different one.
	; The update takes effect the next time the application calls the IDCompositionDevice::Commit method.
	EndDraw(){
		return _Error(DllCall(this.vt(4),"ptr",this.__,"uint"),"EndDraw")
	}

	; Suspends the drawing on this Microsoft DirectComposition surface object.
	; Because only one surface can be open for drawing at a time, calling SuspendDraw allows the user to call IDCompositionSurface::BeginDraw on a different surface.
	SuspendDraw(){
		return _Error(DllCall(this.vt(5),"ptr",this.__,"uint"),"SuspendDraw")
	}

	; Resumes drawing on this Microsoft DirectComposition surface object.
	ResumeDraw(){
		return _Error(DllCall(this.vt(6),"ptr",this.__,"uint"),"ResumeDraw")
	}

	; Scrolls a rectangular area of a Microsoft DirectComposition logical surface.
/*
	This method allows an application to blt/copy a sub-rectangle of a DirectComposition surface object. This avoids re-rendering content that is already available.
	The scrollRect rectangle must be contained in the boundaries of the surface. If the scrollRect rectangle goes outside the bounds of the surface, this method fails.
	The bits copied by the scroll operation (source) are defined by the intersection of the scrollRect and clipRect rectangles.
	The bits shown on the screen (destination) are defined by the intersection of the source rectange and clipRect.
	Scroll operations can only be called before calling BeginDraw or after calling EndDraw. Suspended or resumed surfaces are not candidates for scrolling because they are still being updated.
	The application is responsible for ensuring that the scrollable area for an IDCompositionVirtualSurface is limited to valid pixels. DirectComposition scrolls invalid pixels if they are part of the scrollRect rectangle.
	Virtual surface sub-rectangular areas that were discarded by a trim or a resize operation can't be scrolled even if the trim or resize is applied in the same batch. Trim and Resize are applied immediately.
*/
	Scroll(scrollRect,clipRect,offsetX,offsetY){
		return _Error(DllCall(this.vt(7),"ptr",this.__
			,"ptr",IsObject(scrollRect)?scrollRect[]:scrollRect
			,"ptr",IsObject(clipRect)?clipRect[]:clipRect
			,"int",offsetX
			,"int",offsetY
			,"uint"),"Scroll")
	}
}

class IDCompositionVirtualSurface extends IDCompositionSurface
{
	static iid := "{AE471C51-5F53-4A24-8D3E-D0C39C30B3F0}"

	; Changes the logical size of this virtual surface object.
	; When a virtual surface is resized, its contents are preserved up to the new boundaries of the surface. If the surface is made smaller, any previously allocated pixels that fall outside of the new width or height are discarded. In other words, the method performs an implicit IDCompositionVirtualSurface::Trim operation with the new surface size as the trim rectangle.
	Resize(width,height){
		return _Error(DllCall(this.vt(8),"ptr",this.__
			,"uint",width
			,"uint",height
			,"uint"),"Resize")
	}

	; Trims the memory allocated for this virtual surface to the size necessary to hold the specified rectangles.
	; A virtual surface might not have enough storage for every pixel in the surface. An application instructs the composition engine to allocate memory for the surface by calling the IDCompositionSurface::BeginDraw method, and to release memory for the surface by calling the IDCompositionVirtualSurface::Trim method. The array of rectangles represents the regions of the virtual surface that should remain allocated after this method returns. Any pixels that are outside the specified set of rectangles are no longer used for texturing, and their memory may be reclaimed.
	; If the count parameter is zero, no pixels are kept, and all of the memory allocated for the virtual surface may be reclaimed. The rectangles parameter can be NULL only if the count parameter is zero. This method fails if IDCompositionSurface::BeginDraw was called for this bitmap without a corresponding call to IDCompositionSurface::EndDraw. However, it is valid to call this method for one surface while another surface has a pending update.
	Trim(rectangles,count){
		return _Error(DllCall(this.vt(9),"ptr",this.__
			,"ptr",IsObject(rectangles)?rectangles[]:rectangles
			,"uint",count
			,"uint"),"Trim")
	}
}

/*	enum and struct
  DCOMPOSITION_BITMAP_INTERPOLATION_MODE_NEAREST_NEIGHBOR  = 0,
  DCOMPOSITION_BITMAP_INTERPOLATION_MODE_LINEAR            = 1,
  DCOMPOSITION_BITMAP_INTERPOLATION_MODE_INHERIT           = 0xffffffff
  DCOMPOSITION_BORDER_MODE_SOFT     = 0,
  DCOMPOSITION_BORDER_MODE_HARD     = 1,
  DCOMPOSITION_BORDER_MODE_INHERIT  = 0xffffffff
  DCOMPOSITION_COMPOSITE_MODE_SOURCE_OVER         = 0,
  DCOMPOSITION_COMPOSITE_MODE_DESTINATION_INVERT  = 1,
  DCOMPOSITION_COMPOSITE_MODE_INHERIT             = 0xffffffff
  
  DXGI_RATIONAL := struct("UINT Numerator;UINT Denominator;")
  DCOMPOSITION_FRAME_STATISTICS := struct("  LARGE_INTEGER lastFrameTime;DXGI_RATIONAL currentCompositionRate;LARGE_INTEGER currentTime;LARGE_INTEGER timeFrequency;LARGE_INTEGER nextEstimatedFrameTime;")
*/
