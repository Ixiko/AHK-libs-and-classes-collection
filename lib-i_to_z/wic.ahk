#Include Base.ahk
;;;;;;;;;;;;;;;;;;;;;;
;;IWICImagingFactory;;
;;;;;;;;;;;;;;;;;;;;;;

class IWICImagingFactory extends IUnknown
{
  __new(){
		this.__:=ComObjCreate("{cacaf262-9370-4615-a13b-9f5539da4c0a}","{ec5ec8a9-c395-4314-9c77-54d7a935ff70}"),this._v:=NumGet(this.__+0)
	}
	; Creates a new instance of the IWICBitmapDecoder class based on the given file.
	CreateDecoderFromFilename(wzFilename,pguidVendor,dwDesiredAccess,metadataOptions){ ; WICDecodeOptions
		WIC_hr(DllCall(this.vt(3),"ptr",this.__
			,"str",wzFilename
			,"ptr",WIC_GUID(GUID,pguidVendor)
			,"uint",dwDesiredAccess
			,"int",metadataOptions
			,"ptr*",ppIDecoder
			,"uint"),"CreateDecoderFromFilename")
		return new IWICBitmapDecoder(ppIDecoder)
	}
	
	; Creates a new instance of the IWICBitmapDecoder class based on the given IStream.
	CreateDecoderFromStream(pIStream,pguidVendor,metadataOptions){
		WIC_hr(DllCall(this.vt(4),"ptr",this.__
			,"ptr",IsObject(pIStream)?pIStream.__:pIStream
			,"ptr",WIC_GUID(GUID,pguidVendor)
			,"int",metadataOptions
			,"ptr*",ppIDecoder
			,"uint"),"CreateDecoderFromStream")
		return new IWICBitmapDecoder(ppIDecoder)
	}
	
	; Creates a new instance of the IWICBitmapDecoder based on the given file handle.
	; When a decoder is created using this method, the file handle must remain alive during the lifetime of the decoder.
	CreateDecoderFromFileHandle(hFile,pguidVendor,metadataOptions){
		WIC_hr(DllCall(this.vt(5),"ptr",this.__
			,"ptr",hFile
			,"ptr",WIC_GUID(GUID,pguidVendor)
			,"int",metadataOptions
			,"ptr*",ppIDecoder
			,"uint"),"CreateDecoderFromFileHandle")
		return new IWICBitmapDecoder(ppIDecoder)
	}
	
	; Creates a new instance of the IWICComponentInfo class for the given component class identifier (CLSID).
	CreateComponentInfo(clsidComponent){
		WIC_hr(DllCall(this.vt(6),"ptr",this.__
			,"ptr",WIC_GUID(GUID,clsidComponent)
			,"ptr*",ppIInfo
			,"uint"),"CreateComponentInfo")
		return new IWICComponentInfo(ppIInfo)
	}

	; Creates a new instance of IWICBitmapDecoder.
	CreateDecoder(guidContainerFormat,pguidVendor){ ; REFGUID
		WIC_hr(DllCall(this.vt(7),"ptr",this.__
			,"ptr",WIC_GUID(GUID1,guidContainerFormat)
			,"ptr",WIC_GUID(GUID2,pguidVendor)
			,"ptr*",ppIDecoder
			,"uint"),"CreateDecoder")
		return new IWICBitmapDecoder(ppIDecoder)
	}
	
	; Creates a new instance of the IWICBitmapEncoder class.
	; Other values may be available for both guidContainerFormat and pguidVendor depending on the installed WIC-enabled encoders. The values listed are those that are natively supported by the operating system. 
	CreateEncoder(guidContainerFormat,pguidVendor){
		WIC_hr(DllCall(this.vt(8),"ptr",this.__
			,"ptr",WIC_GUID(GUID1,guidContainerFormat)
			,"ptr",WIC_GUID(GUID2,pguidVendor)
			,"ptr*",ppIEncoder
			,"uint"),"CreateEncoder")
		return new IWICBitmapEncoder(ppIEncoder)
	}
	
	; Creates a new instance of the IWICPalette class.
	CreatePalette(){
		WIC_hr(DllCall(this.vt(9),"ptr",this.__
			,"ptr*",ppIPalette
			,"uint"),"CreatePalette")
		return new IWICPalette(ppIPalette)
	}
	
	; Creates a new instance of the IWICFormatConverter class.
	CreateFormatConverter(){
		WIC_hr(DllCall(this.vt(10),"ptr",this.__
			,"ptr*",ppIFormatConverter
			,"uint"),"CreateFormatConverter")
		return new IWICFormatConverter(ppIFormatConverter)
	}
	
	; Creates a new instance of an IWICBitmapScaler.
	CreateBitmapScaler(){
		WIC_hr(DllCall(this.vt(11),"ptr",this.__
			,"ptr*",ppIBitmapScaler
			,"uint"),"CreateBitmapScaler")
		return new IWICBitmapScaler(ppIBitmapScaler)
	}
	
	; Creates a new instance of an IWICBitmapClipper object.
	CreateBitmapClipper(){
		WIC_hr(DllCall(this.vt(12),"ptr",this.__
			,"ptr*",ppIBitmapClipper
			,"uint"),"CreateBitmapClipper")
		return new IWICBitmapClipper(ppIBitmapClipper)
	}
	
	; Creates a new instance of an IWICBitmapFlipRotator object.
	CreateBitmapFlipRotator(){
		WIC_hr(DllCall(this.vt(13),"ptr",this.__
			,"ptr*",ppIBitmapFlipRotator
			,"uint"),"CreateBitmapFlipRotator")
		return new IWICBitmapFlipRotator(ppIBitmapFlipRotator)
	}
	
	; Creates a new instance of the IWICStream class.
	CreateStream(){
		WIC_hr(DllCall(this.vt(14),"ptr",this.__
			,"ptr*",ppIWICStream
			,"uint"),"CreateStream")
		return new IWICStream(ppIWICStream)
	}
	
	; Creates a new instance of the IWICColorContext class.
	CreateColorContext(){
		WIC_hr(DllCall(this.vt(15),"ptr",this.__
			,"ptr*",ppIWICColorContext
			,"uint"),"CreateColorContext")
		return new IWICColorContext(ppIWICColorContext)
	}
	
	; Creates a new instance of the IWICColorTransform class.
	CreateColorTransformer(){
		WIC_hr(DllCall(this.vt(16),"ptr",this.__
			,"ptr*",ppIWICColorTransform
			,"uint"),"CreateColorTransformer")
		return new IWICColorTransform(IWICColorTransform)
	}
	
	; Creates an IWICBitmap object.
	CreateBitmap(uiWidth,uiHeight,pixelFormat,option){ ; REFWICPixelFormatGUID , WICBitmapCreateCacheOption
		WIC_hr(DllCall(this.vt(17),"ptr",this.__
			,"uint",uiWidth,"uint",uiHeight
			,"ptr",WIC_GUID(GUID,pixelFormat)
			,"int",option
			,"ptr*",ppIBitmap
			,"uint"),"CreateBitmap")
		return new IWICBitmap(ppIBitmap) 
	}
	
	; Creates a IWICBitmap from a IWICBitmapSource.
	CreateBitmapFromSource(pIBitmapSource,option){ ; IWICBitmapSource , WICBitmapCreateCacheOption
		WIC_hr(DllCall(this.vt(18),"ptr",this.__
			,"ptr",IsObject(pIBitmapSource)?pIBitmapSource.__:pIBitmapSource
			,"int",option
			,"ptr*",ppIBitmap
			,"uint"),"CreateBitmapFromSource")
		return new IWICBitmap(ppIBitmap)
	}
	
	; Creates an IWICBitmap from a specified rectangle of an IWICBitmapSource.
	; Providing a rectangle that is larger than the source will produce undefined results.
	; This method always creates a separate copy of the source image, similar to the cache option WICBitmapCacheOnLoad.
	CreateBitmapFromSourceRect(pIBitmapSource,x,y,width,height){
		WIC_hr(DllCall(this.vt(19),"ptr",this.__
			,"ptr",IsObject(pIBitmapSource)?pIBitmapSource.__:pIBitmapSource
			,"uint",x,"uint",y
			,"uint",width,"uint",height
			,"ptr*",ppIBitmap
			,"uint"),"CreateBitmapFromSourceRect")
		return new IWICBitmap(ppIBitmap)
	}
	
	; Creates an IWICBitmap from a memory block.
	; The size of the IWICBitmap to be created must be smaller than or equal to the size of the image in pbBuffer.
	; The stride of the destination bitmap will equal the stride of the source data, regardless of the width and height specified.
	; The pixelFormat parameter defines the pixel format for both the input data and the output bitmap.
	CreateBitmapFromMemory(uiWidth,uiHeight,pixelFormat,cbStride,cbBufferSize,pbBuffer){
		WIC_hr(DllCall(this.vt(20),"ptr",this.__
			,"uint",uiWidth,"uint",uiHeight
			,"ptr",IsObject(pixelFormat)?pixelFormat[]:pixelFormat
			,"uint",cbStride
			,"uint",cbBufferSize
			,"ptr",pbBuffer
			,"ptr*",ppIBitmap
			,"uint"),"CreateBitmapFromMemory")
		return new IWICBitmap(ppIBitmap)
	}
	
	; Creates an IWICBitmap from a bitmap handle.
	; For a non-palletized bitmap, set NULL for the hPalette parameter.
	CreateBitmapFromHBITMAP(hBitmap,hPalette,options){
		WIC_hr(DllCall(this.vt(21),"ptr",this.__
			,"ptr",hBitmap
			,"ptr",hPalette
			,"int",options
			,"ptr*",ppIBitmap,"uint"),"CreateBitmapFromHBITMAP")
		return new IWICBitmap(ppIBitmap)
	}
	
	; Creates an IWICBitmap from an icon handle.
	CreateBitmapFromHICON(hIcon){
		WIC_hr(DllCall(this.vt(22),"ptr",this.__
			,"ptr",hIcon
			,"ptr*",ppIBitmap
			,"uint"),"CreateBitmapFromHICON")
		return new IWICBitmap(ppIBitmap)
	}
	
	; Creates an IEnumUnknown object of the specified component types.
	; Component types must be enumerated seperately. Combinations of component types and WICAllComponents are unsupported.
	CreateComponentEnumerator(componentTypes,options){ ; WICComponentType , WICComponentEnumerateOptions
		WIC_hr(DllCall(this.vt(23),"ptr",this.__
			,"int",componentTypes
			,"int",options
			,"ptr*",ppIEnumUnknown
			,"uint"),"CreateComponentEnumerator")
		return new IEnumUnknown(ppIEnumUnknown)
	}
	
	; Creates a new instance of the fast metadata encoder based on the given IWICBitmapDecoder.
	; The Windows provided codecs do not support fast metadata encoding at the decoder level, and only support fast metadata encoding at the frame level. To create a fast metadata encoder from a frame, see CreateFastMetadataEncoderFromFrameDecode.
	CreateFastMetadataEncoderFromDecoder(pIDecoder){ ; IWICBitmapDecoder
		WIC_hr(DllCall(this.vt(24),"ptr",this.__
			,"ptr",IsObject(pIDecoder)?pIDecoder.__:pIDecoder
			,"ptr*",ppIFastEncoder
			,"uint"),"CreateFastMetadataEncoderFromDecoder")
		return new IWICFastMetadataEncoder(ppIFastEncoder)
	}
	
	; Creates a new instance of the fast metadata encoder based on the given image frame.
	; Example demonstrates how to use the CreateFastMetadataEncoderFromFrameDecode method for fast metadata encoding. http://msdn.microsoft.com/en-us/library/windows/desktop/ee690315%28v=vs.85%29.aspx
	CreateFastMetadataEncoderFromFrameDecode(pIFrameDecoder){ ; IWICBitmapFrameDecode
		WIC_hr(DllCall(this.vt(25),"ptr",this.__
			,"ptr",IsObject(pIFrameDecoder)?pIFrameDecoder.__:pIFrameDecoder
			,"ptr*",ppIFastEncoder
			,"uint"),"CreateFastMetadataEncoderFromFrameDecode")
		return new IWICFastMetadataEncoder(ppIFastEncoder)
	}
	
	; Creates a new instance of a query writer.
	CreateQueryWriter(guidMetadataFormat,pguidVendor){
		WIC_hr(DllCall(this.vt(26),"ptr",this.__
			,"ptr",WIC_GUID(GUID1,guidMetadataFormat)
			,"ptr",WIC_GUID(GUID2,pguidVendor)
			,"ptr*",ppIQueryWriter
			,"uint"),"CreateQueryWriter")
		return new IWICMetadataQueryWriter(ppIQueryWriter)
	}
	
	; Creates a new instance of a query writer based on the given query reader. The query writer will be pre-populated with metadata from the query reader.
	CreateQueryWriterFromReader(pIQueryReader,pguidVendor){
		WIC_hr(DllCall(this.vt(27),"ptr",this.__
			,"ptr",WIC_GUID(GUID1,pIQueryReader)
			,"ptr",WIC_GUID(GUID2,pguidVendor)
			,"ptr*",ppIQueryWriter
			,"uint"),"CreateQueryWriterFromReader")
		return new IWICMetadataQueryWriter(ppIQueryWriter)
	}
}

;;;;;;;;;;;;;;;;;;;
;;Bitmap Resource;;IWICBitmapSource.
;;;;;;;;;;;;;;;;;;;

class IWICBitmapSource extends IUnknown
{
	; Retrieves the pixel width and height of the bitmap.
	GetSize(){
		WIC_hr(DllCall(this.vt(3),"ptr",this.__
			,"uint*",puiWidth,"uint*",puiHeight
			,"uint"),"GetSize")
		return [puiWidth,puiHeight]
	}
	
	; Retrieves the pixel format of the bitmap source.
	; The pixel format returned by this method is not necessarily the pixel format the image is stored as. The codec may perform a format conversion from the storage pixel format to an output pixel format. 
	GetPixelFormat(ByRef pPixelFormat){
		WIC_hr(DllCall(this.vt(4),"ptr",this.__
			,"ptr",pPixelFormat
			,"uint"),"GetPixelFormat")
		return pPixelFormat ; WICPixelFormatGUID
	}
	
	; Retrieves the sampling rate between pixels and physical world measurements.
	; Some formats, such as GIF and ICO, do not have full DPI support. For GIF, this method calculates the DPI values from the aspect ratio, using a base DPI of (96.0, 96.0). The ICO format does not support DPI at all, and the method always returns (96.0,96.0) for ICO images. 
	; Additionally, WIC itself does not transform images based on the DPI values in an image. It is up to the caller to transform an image based on the resolution returned. 
	GetResolution(){
		WIC_hr(DllCall(this.vt(5),"ptr",this.__
			,"double*",pDpiX,"double*",pDpiY
			,"uint"),"GetResolution")
		return [pDpiX,pDpiY]
	}
	
	; Retrieves the color table for indexed pixel formats.
	; If the IWICBitmapSource is an IWICBitmapFrameDecode, the function may return the image's global palette if a frame-level palette is not available. The global palette may also be retrieved using the CopyPalette method. 
	CopyPalette(pIPalette){ ; IWICPalette
		return WIC_hr(DllCall(this.vt(6),"ptr",this.__
			,"ptr",IsObject(pIPalette)?pIPalette.__:pIPalette
			,"uint"),"CopyPalette")
	}
	
	; Instructs the object to produce pixels.
/*
	CopyPixels is one of the two main image processing routines (the other being Lock) triggering the actual processing. It instructs the object to produce pixels according to its algorithm - this may involve decoding a portion of a JPEG stored on disk, copying a block of memory, or even analytically computing a complex gradient. The algorithm is completely dependent on the object implementing the interface.

	The caller can restrict the operation to a rectangle of interest (ROI) using the prc parameter. The ROI sub-rectangle must be fully contained in the bounds of the bitmap. Specifying a NULL ROI implies that the whole bitmap should be returned.

	The caller controls the memory management and must provide an output buffer (pbBuffer) for the results of the copy along with the buffer's bounds (cbBufferSize). The cbStride parameter defines the count of bytes between two vertically adjacent pixels in the output buffer. The caller must ensure that there is sufficient buffer to complete the call based on the width, height and pixel format of the bitmap and the sub-rectangle provided to the copy method.

	If the caller needs to perform numerous copies of an expensive IWICBitmapSource such as a JPEG, it is recommended to create an in-memory IWICBitmap first.

	The callee must only write to the first (prc->Width*bitsperpixel+7)/8 bytes of each line of the output buffer (in this case, a line is a consecutive string of cbStride bytes). 	
*/
	CopyPixels(prc,cbStride,cbBufferSize){ ; WICRect
		WIC_hr(DllCall(this.vt(7),"ptr",this.__
			,"ptr",IsObject(prc)?prc[]:prc
			,"uint",cbStride
			,"uint",cbBufferSize
			,"ptr*",pbBuffer
			,"uint"),"CopyPixels")
		return pbBuffer
	}	
}

class IWICBitmap extends IWICBitmapSource
{
	; Provides access to a rectangular area of the bitmap.
	; Locks are exclusive for writing but can be shared for reading. You cannot call CopyPixels while the IWICBitmap is locked for writing. Doing so will return an error, since locks are exclusive.
	; Example, an IWICBitmap is created and the image data is cleared using an IWICBitmapLock. http://msdn.microsoft.com/en-us/library/windows/desktop/ee690187%28v=vs.85%29.aspx
	Lock(prcLock,flags){ ; WICRect , WICBitmapLockFlags
		WIC_hr(DllCall(this.vt(8),"ptr",this.__
			,"ptr",IsObject(prcLock)?prcLock[]:prcLock
			,"int",flags
			,"ptr*",ppILock
			,"uint"),"Lock")
		return ppILock
	}
	
	; Provides access for palette modifications.
	SetPalette(pIPalette){ ; IWICPalette
		return WIC_hr(DllCall(this.vt(9),"ptr",this.__
			,"ptr",IsObject(pIPalette)?pIPalette.__:pIPalette
			,"uint"),"SetPalette")
	}
	
	; Changes the physical resolution of the image.
	; This method has no effect on the actual pixels or samples stored in the bitmap. Instead the interpretation of the sampling rate is modified. This means that a 96 DPI image which is 96 pixels wide is one inch. If the physical resolution is modified to 48 DPI, then the bitmap is considered to be 2 inches wide but has the same number of pixels. If the resolution is less than REAL_EPSILON (1.192092896e-07F) the error code WINCODEC_ERR_INVALIDPARAMETER is returned.
	SetResolution(dpiX,dpiY){
		return WIC_hr(DllCall(this.vt(10),"ptr",this.__
			,"double",dpiX,"double",dpiY
			,"uint"),"SetResolution")
	}
}
	
class IWICBitmapScaler extends IWICBitmapSource
{
	; Initializes the bitmap scaler with the provided parameters.
	; IWICBitmapScaler can't be initialized multiple times. For example, when scaling every frame in a multi-frame image, a new IWICBitmapScaler must be created and initialized for each frame.
	Initialize(pISource,uiWidth,uiHeight,mode){ ; IWICBitmapSource , WICBitmapInterpolationMode
		return WIC_hr(DllCall(this.vt(8),"ptr",this.__
			,"ptr",IsObject(pISource)?pISource.__:pISource
			,"uint",uiWidth,"uint",uiHeight
			,"int",mode
			,"uint"),"Initialize")
	}
}

class IWICBitmapClipper extends IWICBitmapSource
{
	; Initializes the bitmap clipper with the provided parameters.
	; Example creates and initializes a clipper using the passed in parameters. http://msdn.microsoft.com/en-us/library/windows/desktop/ee719677%28v=vs.85%29.aspx
	Initialize(pISource,prc){ ; IWICBitmapSource , WICRect
		return WIC_hr(DllCall(this.vt(8),"ptr",this.__
			,"ptr",IsObject(pISource)?pISource.__:pISource
			,"ptr",IsObject(prc)?prc[]:prc
			,"uint"),"Initialize")
	}
}	

class IWICBitmapFlipRotator extends IWICBitmapSource
{
	; Initializes the bitmap flip rotator with the provided parameters.
	; Example http://msdn.microsoft.com/en-us/library/windows/desktop/ee690132%28v=vs.85%29.aspx
	Initialize(pISource,options){ ; IWICBitmapSource , WICBitmapTransformOptions
		return WIC_hr(DllCall(this.vt(8),"ptr",this.__
			,"ptr",IsObject(pISource)?pISource.__:pISource
			,"int",options
			,"uint"),"Initialize")
	}
}

class IWICColorTransform extends IWICBitmapSource
{
	; Initializes an IWICColorTransform with a IWICBitmapSource and transforms it from one IWICColorContext to another. 
	; Example performs a color transform from one IWICColorContext to another. http://msdn.microsoft.com/en-us/library/windows/desktop/ee690202%28v=vs.85%29.aspx
	Initialize(pIBitmapSource,pIContextSource,pIContextDest,pixelFmtDest){ ; IWICBitmapSource , IWICColorContext , REFWICPixelFormatGUID
		return WIC_hr(DllCall(this.vt(8),"ptr",this.__
			,"ptr",IsObject(pIBitmapSource)?pIBitmapSource.__:pIBitmapSource
			,"ptr",IsObject(pIContextSource)?pIContextSource.__:pIContextSource
			,"ptr",IsObject(pIContextDest)?pIContextDest.__:pIContextDest
			,"ptr",IsObject(pixelFmtDest)?pixelFmtDest[]:pixelFmtDest
			,"uint"),"Initialize")
	} 
}

class IWICBitmapFrameDecode extends IWICBitmapSource
{
	; Retrieves a metadata query reader for the frame.
	; For image formats with one frame (JPG, PNG, JPEG-XR), the frame-level query reader of the first frame is used to access all image metadata, and the decoder-level query reader isn’t used. For formats with more than one frame (GIF, TIFF), the frame-level query reader for a given frame is used to access metadata specific to that frame, and in the case of GIF a decoder-level metadata reader will be present. If the decoder doesn’t support metadata (BMP, ICO), this will return WINCODEC_ERR_UNSUPPORTEDOPERATION. 
	GetMetadataQueryReader(){
		WIC_hr(DllCall(this.vt(8),"ptr",this.__
			,"ptr*",ppIMetadataQueryReader
			,"uint"),"GetMetadataQueryReader")
		return new IWICMetadataQueryReader(ppIMetadataQueryReader)
	}
	
	; Retrieves the IWICColorContext associated with the image frame.
	; If NULL is passed for ppIColorContexts, and 0 is passed for cCount, this method will return the total number of color contexts in the image in pcActualCount. 
	; The ppIColorContexts array must be filled with valid data: each IWICColorContext* in the array must have been created using IWICImagingFactory::CreateColorContext. 
	GetColorContexts(cCount){
		ppIColorContexts:=Struct("ptr[" cCount "]")
		WIC_hr(DllCall(this.vt(9),"ptr",this.__
			,"uint",cCount
			,"ptr",ppIColorContexts[]
			,"uint*",pcActualCount
			,"uint"),"GetColorContexts")
		return [ppIColorContexts,pcActualCount]
	}
	
	; Retrieves a small preview of the frame, if supported by the codec.
	; Not all formats support thumbnails. Joint Photographic Experts Group (JPEG), Tagged Image File Format (TIFF), and Microsoft Windows Digital Photo (WDP) support thumbnails.
	; If the codec does not support thumbnails, return WINCODEC_ERROR_CODECNOTHUMBNAIL rather than E_NOTIMPL.
	GetThumbnail(){
		WIC_hr(DllCall(this.vt(10),"ptr",this.__
			,"ptr*",ppIThumbnail
			,"uint"),"GetThumbnail")
		return new IWICBitmapSource(ppIThumbnail)
	}
}

;;;;;;;;;;;;;;;;;;;;
;;Format Converter;;Used to convert from one pixel format to another.
;;;;;;;;;;;;;;;;;;;;

class IWICFormatConverter extends IWICBitmapSource
{
	; Initializes the format converter.
	Initialize(pISource,dstFormat,dither,pIPalette,alphaThresholdPercent,paletteTranslate){ ; 
		return WIC_hr(DllCall(this.vt(8),"ptr",this.__
			,"ptr",IsObject(pISource)?pISource.__:pISource
			,"ptr",IsObject(dstFormat)?dstFormat[]:dstFormat
			,"uint",dither
			,"ptr",IsObject(pIPalette)?pIPalette.__:pIPalette
			,"double",alphaThresholdPercent
			,"uint",paletteTranslate
			,"uint"),"Initialize")
	}

	; Determines if the source pixel format can be converted to the destination pixel format.
/*
	If you do not have a predefined palette, you must first create one. Use InitializeFromBitmap to create the palette object, then pass it in along with your other parameters.

	dither, pIPalette, alphaThresholdPercent, and paletteTranslate are used to mitigate color loss when converting to a reduced bit-depth format. For conversions that do not need these settings, the following parameters values should be used: dither set to WICBitmapDitherTypeNone, pIPalette set to NULL, alphaThresholdPercent set to 0.0f, and paletteTranslate set to WICBitmapPaletteTypeCustom.

	The basic algorithm involved when using an ordered dither requires a fixed palette, found in the WICBitmapPaletteType enumeration, in a specific order. Often, the actual palette provided for the output may have a different ordering or some slight variation in the actual colors. This is the case when using the Microsoft Windows palette which has slight differences among versions of Windows. To provide for this, a palette and a palette translation are given to the format converter. The pIPalette is the actual destination palette to be used and the paletteTranslate is a fixed palette. Once the conversion is complete, the colors are mapped from the fixed palette to the actual colors in pIPalette using a nearest color matching algorithm.

	If colors in pIPalette do not closely match those in paletteTranslate, the mapping may produce undesireable results.

	WICBitmapDitherTypeOrdered4x4 can be useful in format conversions from 8-bit formats to 5- or 6-bit formats as there is no way to accurately convert color data.

	WICBitmapDitherTypeErrorDiffusion selects the error diffusion algorithm and may be used with any palette. If an arbitrary palette is provided, WICBitmapPaletteCustom should be passed in as the paletteTranslate. Error diffusion often provides superior results compared to the ordered dithering algorithms especially when combined with the optimized palette generation functionality on the IWICPalette.

	When converting a bitmap which has an alpha channel, such as a Portable Network Graphics (PNG), to 8bpp, the alpha channel is normally ignored. Any pixels which were transparent in the original bitmap show up as black in the final output because both transparent and black have pixel values of zero in the respective formats.

	Some 8bpp content can contains an alpha color; for instance, the Graphics Interchange Format (GIF) format allows for a single palette entry to be used as a transparent color. For this type of content, alphaThresholdPercent specifies what percentage of transparency should map to the transparent color. Because the alpha value is directly proportional to the opacity (not transparency) of a pixel, the alphaThresholdPercent indicates what level of opacity is mapped to the fully transparent color. For instance, 9.8% implies that any pixel with an alpha value of less than 25 will be mapped to the transparent color. A value of 100% maps all pixels which are not fully opaque to the transparent color. Note that the palette should provide a transparent color. If it does not, the 'transparent' color will be the one closest to zero - often black. 
*/
	CanConvert(srcPixelFormat,dstPixelFormat){
		WIC_hr(DllCall(this.vt(9),"ptr",this.__
			,"ptr",IsObject(srcPixelFormat)?srcPixelFormat[]:srcPixelFormat
			,"ptr",IsObject(dstPixelFormat)?dstPixelFormat[]:dstPixelFormat
			,"int*",pfCanConvert
			,"uint"),"CanConvert")
		return pfCanConvert
	}
}

;;;;;;;;;;;
;;Decoder;;Used to decode image data from a stream into a format that is useful for image processing.
;;;;;;;;;;;

class IWICBitmapDecoder extends IUnknown
{
	; Retrieves the capabilities of the decoder based on the specified stream.
	; Custom decoder implementations should save the current position of the specified IStream, read whatever information is necessary in order to determine which capabilities it can provide for the supplied stream, and restore the stream position.
	QueryCapability(pIStream){
		WIC_hr(DllCall(this.vt(3),"ptr",this.__
			,"ptr",IsObject(pIStream)?pIStream.__:pIStream
			,"int*",pdwCapability
			,"uint"),"QueryCapability")
		return pdwCapability ; WICBitmapDecoderCapabilities
	}

	; Initializes the decoder with the provided stream.
	Initialize(pIStream,cacheOptions){ ; WICDecodeOptions
		return WIC_hr(DllCall(this.vt(4),"ptr",this.__,"ptr"
			,IsObject(pIStream)?pIStream.__:pIStream
			,"uint",cacheOptions
			,"uint"),"Initialize")
	}

	; Retrieves the image's container format.
	GetContainerFormat(){
		WIC_hr(DllCall(this.vt(5),"ptr",this.__
			,"ptr*",pguidContainerFormat
			,"uint"),"GetContainerFormat")
		return pguidContainerFormat
	}

	; Retrieves an IWICBitmapDecoderInfo for the image.
	GetDecoderInfo(){
		WIC_hr(DllCall(this.vt(6),"ptr",this.__
			,"ptr*",ppIDecoderInfo
			,"uint"),"GetDecoderInfo")
		return new IWICBitmapDecoderInfo(ppIDecoderInfo)
	}

	; Copies the decoder's IWICPalette.
	; CopyPalette returns a global palette (a palette that applies to all the frames in the image) if there is one; otherwise, it returns WINCODEC_ERR_PALETTEUNAVAILABLE. If an image doesn't have a global palette, it may still have a frame-level palette, which can be retrieved using IWICBitmapFrameDecode::CopyPalette.
	CopyPalette(pIPalette){
		return WIC_hr(DllCall(this.vt(7),"ptr",this.__
			,"ptr",IsObject(pIPalette)?pIPalette.__:pIPalette
			,"uint"),"CopyPalette")
	}

	; Retrieves the metadata query reader from the decoder.
	; If an image format does not support container-level metadata, this will return WINCODEC_ERR_UNSUPPORTEDOPERATION. The only Windows provided image format that supports container-level metadata is GIF. Instead, use IWICBitmapFrameDecode::GetMetadataQueryReader.
	GetMetadataQueryReader(){
		WIC_hr(DllCall(this.vt(8),"ptr",this.__
			,"ptr*",ppIMetadataQueryReader
			,"uint"),"GetMetadataQueryReader")
		return new IWICMetadataQueryReader(ppIMetadataQueryReader)
	}

	; Retrieves a preview image, if supported.
	; Not all formats support previews. Only the native Microsoft Windows Digital Photo (WDP) codec support previews.
	GetPreview(){
		WIC_hr(DllCall(this.vt(9),"ptr",this.__
			,"ptr*",ppIBitmapSource
			,"uint"),"GetPreview")
		return new IWICBitmapSource(ppIBitmapSource)
	}

	; Retrieves the IWICColorContext objects of the image.
	GetColorContexts(cCount){
		ppIColorContexts:=Struct("ptr[" cCount "]")
		WIC_hr(DllCall(this.vt(10),"ptr",this.__
			,"uint",cCount
			,"ptr",ppIColorContexts[]
			,"uint*",pcActualCount
			,"uint"),"GetColorContexts")
		return [ppIColorContexts,pcActualCount] ; IWICColorContext
	}

	; Retrieves a bitmap thumbnail of the image, if one exists
	; The returned thumbnail can be of any size, so the caller should scale the thumbnail to the desired size. The only Windows provided image formats that support thumbnails are JPEG, TIFF, and JPEG-XR. If the thumbnail is not available, this will return WINCODEC_ERR_CODECNOTHUMBNAIL.
	GetThumbnail(){
		WIC_hr(DllCall(this.vt(11),"ptr",this.__
			,"ptr*",ppIThumbnail
			,"uint"),"GetThumbnail")
		return new IWICBitmapSource(ppIThumbnail)
	}

	; Retrieves the total number of frames in the image.
	GetFrameCount(){
		WIC_hr(DllCall(this.vt(12),"ptr",this.__
			,"uint*",pCount
			,"uint"),"GetFrameCount")
		return pCount
	}

	; Retrieves the specified frame of the image.
	GetFrame(index){
		WIC_hr(DllCall(this.vt(13),"ptr",this.__
			,"uint",index
			,"ptr*",ppIBitmapFrame
			,"uint"),"GetFrame")
		return new IWICBitmapFrameDecode(ppIBitmapFrame)
	}
}

;;;;;;;;;;;
;;Encoder;;Writes image data to a stream.
;;;;;;;;;;;

class IWICBitmapEncoder extends IUnknown
{
	; Initializes the encoder with an IStream which tells the encoder where to encode the bits.
	Initialize(pIStream,cacheOption){ ; WICBitmapEncoderCacheOption
		return WIC_hr(DllCall(this.vt(3),"ptr",this.__
			,"ptr",IsObject(pIStream)?pIStream.__:pIStream
			,"int",cacheOption
			,"uint"),"Initialize")
	}

	; Retrieves the encoder's container format.
	GetContainerFormat(){
		WIC_hr(DllCall(this.vt(4),"ptr",this.__
			,"ptr*",pguidContainerFormat
			,"uint"),"GetContainerFormat")
		return pguidContainerFormat
	}

	; Retrieves an IWICBitmapEncoderInfo for the encoder.
	GetEncoderInfo(){
		WIC_hr(DllCall(this.vt(5),"ptr",this.__
			,"ptr*",ppIEncoderInfo
			,"uint"),"GetEncoderInfo")
		return new IWICBitmapEncoderInfo(ppIEncoderInfo)
	}

	; Sets the IWICColorContext objects for the encoder.
	SetColorContexts(cCount,ppIColorContext){
		return WIC_hr(DllCall(this.vt(6),"ptr",this.__
			,"uint",cCount
			,"ptr",IsObject(ppIColorContext)?ppIColorContext[]:ppIColorContext
			,"uint"),"SetColorContexts")
	}

	; Sets the global palette for the image.
	; Only GIF images support an optional global palette, and you must set the global palette before adding any frames to the image. You only need to set the palette for indexed pixel formats. 
	SetPalette(pIPalette){ ; IWICPalette
		return WIC_hr(DllCall(this.vt(7),"ptr",this.__
			,"ptr",IsObject(pIPalette)?pIPalette.__:pIPalette
			,"uint"),"SetPalette")
	}

	; Sets the global thumbnail for the image.
	SetThumbnail(pIThumbnail){ ; IWICBitmapSource
		return WIC_hr(DllCall(this.vt(8),"ptr",this.__
			,"ptr",IsObject(pIThumbnail)?pIThumbnail.__:pIThumbnail
			,"uint"),"SetThumbnail")
	}

	; Sets the global preview for the image.
	SetPreview(pIPreview){
		return WIC_hr(DllCall(this.vt(9),"ptr",this.__
			,"ptr",IsObject(pIPreview)?pIPreview.__:pIPreview
			,"uint"),"SetPreview")
	}

	; Creates a new IWICBitmapFrameEncode instance.
	; The parameter ppIEncoderOptions can be used to receive an IPropertyBag2 that can then be used to specify encoder options. This is done by passing a pointer to a NULL IPropertyBag2 pointer in ppIEncoderOptions. The returned IPropertyBag2 is initialized with all encoder options that are available for the given format, at their default values. To specify non-default encoding behavior, set the needed encoder options on the IPropertyBag2 and pass it to IWICBitmapFrameEncode::Initialize.
	; Note  Do not pass in a pointer to an initialized IPropertyBag2. The pointer will be overwritten, and the original IPropertyBag2 will not be freed.
	; Otherwise, you can pass NULL in ppIEncoderOptions if you do not intend to specify encoder options.
	; See Encoding Overview for an example of how to set encoder options.
	; For formats that support encoding multiple frames (for example, TIFF, JPEG-XR), you can work on only one frame at a time. This means that you must call IWICBitmapFrameEncode::Commit before you call CreateNewFrame again. 
	CreateNewFrame(ppIEncoderOptions=0){
		WIC_hr(DllCall(this.vt(10),"ptr",this.__
			,"ptr*",ppIFrameEncode
			,"ptr*",ppIEncoderOptions
			,"uint"),"CreateNewFrame")
		return new IWICBitmapFrameEncode(ppIFrameEncode)
	}

	; Commits all changes for the image and closes the stream.
	; To finalize an image, both the frame Commit and the encoder Commit must be called. However, only call the encoder Commit method after all frames have been committed.
	; After the encoder has been committed, it can't be re-initialized or reused with another stream. A new encoder interface must be created, for example, with IWICImagingFactory::CreateEncoder. 
	; For the encoder Commit to succeed, you must at a minimum call IWICBitmapEncoder::Initialize and either IWICBitmapFrameEncode::WriteSource or IWICBitmapFrameEncode::WritePixels. 
	; IWICBitmapFrameEncode::WriteSource specifies all parameters needed to encode the image data. IWICBitmapFrameEncode::WritePixels requires that you also call IWICBitmapFrameEncode::SetSize, IWICBitmapFrameEncode::SetPixelFormat, and IWICBitmapFrameEncode::SetPalette (if the pixel format is indexed). 
	Commit(){
		return WIC_hr(DllCall(this.vt(11),"ptr",this.__,"uint"),"Commit")
	}

	; Retrieves a metadata query writer for the encoder.
	GetMetadataQueryWriter(){
		WIC_hr(DllCall(this.vt(12),"ptr",this.__
			,"ptr*",ppIMetadataQueryWriter
			,"uint"),"GetMetadataQueryWriter")
		return new IWICMetadataQueryWriter(ppIMetadataQueryWriter)
	}
}

;;;;;;;;;;
;;Stream;;Used to read and write data from a file, network resource, a block of memory, and so on.
;;;;;;;;;;

class IWICStream extends IStream
{
	; Initializes a stream from another stream. Access rights are inherited from the underlying stream.
	InitializeFromIStream(pIStream){
		return WIC_hr(DllCall(this.vt(14),"ptr",this.__
			,"ptr",IsObject(pIStream)?pIStream.__:pIStream
			,"uint"),"InitializeFromIStream")
	}

	; Initializes a stream from a particular file.
	; The IWICStream interface methods do not enable you to provide a file sharing option. To create a shared file stream for an image, use the SHCreateStreamOnFileEx function. This stream can then be used to create an IWICBitmapDecoder using the CreateDecoderFromStream method. 
	; Example demonstrates the use of the InitializeFromFilename to create an image decoder. msdn.microsoft.com/en-us/library/windows/desktop/ee719788(v=vs.85).aspx
	InitializeFromFilename(wzFileName,dwDesiredAccess){
		return WIC_hr(DllCall(this.vt(15),"ptr",this.__
			,"str",wzFileName
			,"uint",dwDesiredAccess
			,"uint"),"InitializeFromFilename")
	}

	; Initializes a stream to treat a block of memory as a stream. The stream cannot grow beyond the buffer size. 
	; This method should be avoided whenever possible. The caller is responsible for ensuring the memory block is valid for the lifetime of the stream when using InitializeFromMemory. A workaround for this behavior is to create an IStream and use InitializeFromIStream to create the IWICStream.
	; If you require a growable memory stream, use CreateStreamOnHGlobal.
	InitializeFromMemory(pbBuffer,cbBufferSize){
		return WIC_hr(DllCall(this.vt(16),"ptr",this.__
			,"ptr",pbBuffer
			,"uint",cbBufferSize
			,"uint"),"InitializeFromMemory")
	}

	; Initializes the stream as a substream of another stream.
	; The stream functions with its own stream position, independent of the underlying stream but restricted to a region. All seek positions are relative to the sub region. It is allowed, though not recommended, to have multiple writable sub streams overlapping the same range.
	InitializeFromIStreamRegion(pIStream,ulOffset,ulMaxSize){
		return WIC_hr(DllCall(this.vt(17),"ptr",this.__
			,"ptr",IsObject(pIStream)?pIStream.__:pIStream
			,"uint64",ulOffset
			,"uint64",ulMaxSize
			,"uint"),"InitializeFromIStreamRegion")
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;
;;Metadata Query Reader;;Used to read metadata of an image or image frame.
;;Metadata Query Writer;;Used to write metadata to an image or image frame.
;;;;;;;;;;;;;;;;;;;;;;;;;

class IWICMetadataQueryReader extends IUnknown
{
	; Gets the metadata query readers container format.
	GetContainerFormat(){
		WIC_hr(DllCall(this.vt(3),"ptr",this.__
			,"ptr*",pguidContainerFormat
			,"uint"),"GetContainerFormat")
		return pguidContainerFormat
	}

	; Retrieves the current path relative to the root metadata block.
	; If you pass NULL to wzNamespace, GetLocation ignores cchMaxLength and returns the required buffer length to store the path in the variable that pcchActualLength points to. 
	; If the query reader is relative to the top of the metadata hierarchy, it will return a single-char string.
	; If the query reader is relative to a nested metadata block, this method will return the path to the current query reader.
	GetLocation(cchMaxLength,wzNamespace){
		WIC_hr(DllCall(this.vt(4),"ptr",this.__
			,"uint",cchMaxLength
			,"wstr",wzNamespace
			,"uint*",pcchActualLength
			,"uint"),"GetLocation")
		return pcchActualLength
	}

	; For more information on the metadata query language, see the Metadata Query Language Overview. http://msdn.microsoft.com/en-us/library/windows/desktop/ee719796%28v=vs.85%29.aspx

	; Retrieves the metadata block or item identified by a metadata query expression. 
	; GetMetadataByName uses metadata query expressions to access embedded metadata.
	; If multiple blocks or items exist that are expressed by the same query expression, the first metadata block or item found will be returned.
	GetMetadataByName(wzName){ 
		WIC_hr(DllCall(this.vt(5),"ptr",this.__
			,"wstr",wzName
			,"ptr",PROPVARIANT(pvarValue)
			,"uint"),"GetMetadataByName")
		return GetVariantValue(pvarValue) ; PROPVARIANT 
	}

	; Gets an enumerator of all metadata items at the current relative location within the metadata hierarchy.
	; The retrieved enumerator only contains query strings for the metadata blocks and items in the current level of the hierarchy. 
	GetEnumerator(){
		WIC_hr(DllCall(this.vt(6),"ptr",this.__
			,"ptr*",ppIEnumString
			,"uint"),"GetEnumerator")
		return new IEnumString(ppIEnumString) ; IEnumString
	}
}
class IWICMetadataQueryWriter extends IWICMetadataQueryReader
{	
	; Sets a metadata item to a specific location.
	; SetMetadataByName uses metadata query expressions to remove metadata.
	; If the value set is a nested metadata block then use variant type VT_UNKNOWN and pvarValue pointing to the IWICMetadataQueryWriter of the new metadata block. The ordering of metadata items is at the discretion of the query writer since relative locations are not specified. 
	SetMetadataByName(wzName,pvarValue){ ; PROPVARIANT not completed see Metadata Query Language Overview
		return WIC_hr(DllCall(this.vt(7),"ptr",this.__
			,"str",wzName
			,"ptr",pvarValue
			,"uint"),"SetMetadataByName")
	}

	; Removes a metadata item from a specific location using a metadata query expression.
	; RemoveMetadataByName uses metadata query expressions to remove metadata.
	; If the metadata item is a metadata block, it is removed from the metadata hierarchy.
	RemoveMetadataByName(wzName){
		return WIC_hr(DllCall(this.vt(8),"ptr",this.__
			,"str",wzName
			,"uint"),"RemoveMetadataByName")
	}
}

;;;;;;;;;;;;;;;;;
;;WIC Constants;;
;;;;;;;;;;;;;;;;;
WIC_Struct(name,p=0){
	static init:=1,_:=[]
	if init{
		init:=0
		,_["WICRect"]:=struct("INT X;INT Y;INT Width;INT Height;")
		,_["WICBitmapPattern"]:=struct("ULARGE_INTEGER Position;ULONG Length;BYTE *Pattern;BYTE *Mask;BOOL EndOfStream;")
		,_["WICRawCapabilitiesInfo"]:=struct("UINT cbSize;UINT CodecMajorVersion;UINT CodecMinorVersion;int ExposureCompensationSupport;int ContrastSupport;int RGBWhitePointSupport;int NamedWhitePointSupport;UINT NamedWhitePointSupportMask;int KelvinWhitePointSupport;int GammaSupport;int TintSupport;int SaturationSupport;int SharpnessSupport;int NoiseReductionSupport;int DestinationColorProfileSupport;int ToneCurveSupport;WICRawRotationCapabilities RotationSupport;int RenderModeSupport;")
		,_["WICRawToneCurvePoint"]:=struct("double Input;double Output;")
		,_["WICRawToneCurve"]:=struct("UINT cPoints;WICRawToneCurvePoint aPoints[1];")
	}
	return _.haskey(name)?_[name].clone(p=0?[]:p):"Struct not exists."
}
WIC_Constant(){
		static init:=1,_:=[]
	if init{
		init:=0
		 _["WICColorContextUninitialized"]:=0
		,_["WICColorContextProfile"]:=0x1
		,_["WICColorContextExifColorSpace"]:=0x2
		,_["WICBitmapNoCache"]:=0
		,_["WICBitmapCacheOnDemand"]:=0x1
		,_["WICBitmapCacheOnLoad"]:=0x2
		,_["WICBITMAPCREATECACHEOPTION_FORCE_DWORD"]:=0x7fffffff
		,_["WICDecodeMetadataCacheOnDemand"]:=0
		,_["WICDecodeMetadataCacheOnLoad"]:=0x1
		,_["WICMETADATACACHEOPTION_FORCE_DWORD"]:=0x7fffffff
		 _["WICBitmapEncoderCacheInMemory"]:=0
		,_["WICBitmapEncoderCacheTempFile"]:=0x1
		,_["WICBitmapEncoderNoCache"]:=0x2
		,_["WICBITMAPENCODERCACHEOPTION_FORCE_DWORD"]:=0x7fffffff
		,_["WICDecoder"]:=0x1
		,_["WICEncoder"]:=0x2
		,_["WICPixelFormatConverter"]:=0x4
		,_["WICMetadataReader"]:=0x8
		,_["WICMetadataWriter"]:=0x10
		,_["WICPixelFormat"]:=0x20
		 _["WICAllComponents"]:=0x3f
		,_["WICCOMPONENTTYPE_FORCE_DWORD"]:=0x7fffffff
		,_["WICComponentEnumerateDefault"]:=0
		,_["WICComponentEnumerateRefresh"]:=0x1
		,_["WICComponentEnumerateDisabled"]:=0x80000000
		,_["WICComponentEnumerateUnsigned"]:=0x40000000
		,_["WICComponentEnumerateBuiltInOnly"]:=0x20000000
		,_["WICCOMPONENTENUMERATEOPTIONS_FORCE_DWORD"]:=0x7fffffff
		,_["WICBitmapInterpolationModeNearestNeighbor"]:=0
		,_["WICBitmapInterpolationModeLinear"]:=0x1
		 _["WICBitmapInterpolationModeCubic"]:=0x2
		,_["WICBitmapInterpolationModeFant"]:=0x3
		,_["WICBITMAPINTERPOLATIONMODE_FORCE_DWORD"]:=0x7fffffff
		,_["WICBitmapPaletteTypeCustom"]:=0
		,_["WICBitmapPaletteTypeMedianCut"]:=0x1
		,_["WICBitmapPaletteTypeFixedBW"]:=0x2
		,_["WICBitmapPaletteTypeFixedHalftone8"]:=0x3
		,_["WICBitmapPaletteTypeFixedHalftone27"]:=0x4
		,_["WICBitmapPaletteTypeFixedHalftone64"]:=0x5
		,_["WICBitmapPaletteTypeFixedHalftone125"]:=0x6
		 _["WICBitmapPaletteTypeFixedHalftone216"]:=0x7
		,_["WICBitmapPaletteTypeFixedWebPalette"]:=WICBitmapPaletteTypeFixedHalftone216
		,_["WICBitmapPaletteTypeFixedHalftone252"]:=0x8
		,_["WICBitmapPaletteTypeFixedHalftone256"]:=0x9
		,_["WICBitmapPaletteTypeFixedGray4"]:=0xa
		,_["WICBitmapPaletteTypeFixedGray16"]:=0xb
		,_["WICBitmapPaletteTypeFixedGray256"]:=0xc
		,_["WICBITMAPPALETTETYPE_FORCE_DWORD"]:=0x7fffffff
		,_["WICBitmapDitherTypeNone"]:=0
		,_["WICBitmapDitherTypeSolid"]:=0
		 _["WICBitmapDitherTypeOrdered4x4"]:=0x1
		,_["WICBitmapDitherTypeOrdered8x8"]:=0x2
		,_["WICBitmapDitherTypeOrdered16x16"]:=0x3
		,_["WICBitmapDitherTypeSpiral4x4"]:=0x4
		,_["WICBitmapDitherTypeSpiral8x8"]:=0x5
		,_["WICBitmapDitherTypeDualSpiral4x4"]:=0x6
		,_["WICBitmapDitherTypeDualSpiral8x8"]:=0x7
		,_["WICBitmapDitherTypeErrorDiffusion"]:=0x8
		,_["WICBITMAPDITHERTYPE_FORCE_DWORD"]:=0x7fffffff
		,_["WICBitmapUseAlpha"]:=0
		 _["WICBitmapUsePremultipliedAlpha"]:=0x1
		,_["WICBitmapIgnoreAlpha"]:=0x2
		,_["WICBITMAPALPHACHANNELOPTIONS_FORCE_DWORD"]:=0x7fffffff
		,_["WICBitmapTransformRotate0"]:=0
		,_["WICBitmapTransformRotate90"]:=0x1
		,_["WICBitmapTransformRotate180"]:=0x2
		,_["WICBitmapTransformRotate270"]:=0x3
		,_["WICBitmapTransformFlipHorizontal"]:=0x8
		,_["WICBitmapTransformFlipVertical"]:=0x10
		,_["WICBITMAPTRANSFORMOPTIONS_FORCE_DWORD"]:=0x7fffffff
		 _["WICBitmapLockRead"]:=0x1
		,_["WICBitmapLockWrite"]:=0x2
		,_["WICBITMAPLOCKFLAGS_FORCE_DWORD"]:=0x7fffffff
		,_["WICBitmapDecoderCapabilitySameEncoder"]:=0x1
		,_["WICBitmapDecoderCapabilityCanDecodeAllImages"]:=0x2
		,_["WICBitmapDecoderCapabilityCanDecodeSomeImages"]:=0x4
		,_["WICBitmapDecoderCapabilityCanEnumerateMetadata"]:=0x8
		,_["WICBitmapDecoderCapabilityCanDecodeThumbnail"]:=0x10
		,_["WICBITMAPDECODERCAPABILITIES_FORCE_DWORD"]:=0x7fffffff
		,_["WICProgressOperationCopyPixels"]:=0x1
		 _["WICProgressOperationWritePixels"]:=0x2
		,_["WICProgressOperationAll"]:=0xffff
		,_["WICPROGRESSOPERATION_FORCE_DWORD"]:=0x7fffffff
		,_["WICProgressNotificationBegin"]:=0x10000
		,_["WICProgressNotificationEnd"]:=0x20000
		,_["WICProgressNotificationFrequent"]:=0x40000
		,_["WICProgressNotificationAll"]:=0xffff0000
		,_["WICPROGRESSNOTIFICATION_FORCE_DWORD"]:=0x7fffffff
		,_["WICComponentSigned"]:=0x1
		,_["WICComponentUnsigned"]:=0x2
		 _["WICComponentSafe"]:=0x4
		,_["WICComponentDisabled"]:=0x80000000
		,_["WICCOMPONENTSIGNING_FORCE_DWORD"]:=0x7fffffff
		,_["WICGifLogicalScreenSignature"]:=0x1
		,_["WICGifLogicalScreenDescriptorWidth"]:=0x2
		,_["WICGifLogicalScreenDescriptorHeight"]:=0x3
		,_["WICGifLogicalScreenDescriptorGlobalColorTableFlag"]:=0x4
		,_["WICGifLogicalScreenDescriptorColorResolution"]:=0x5
		,_["WICGifLogicalScreenDescriptorSortFlag"]:=0x6
		,_["WICGifLogicalScreenDescriptorGlobalColorTableSize"]:=0x7
		 _["WICGifLogicalScreenDescriptorBackgroundColorIndex"]:=0x8
		,_["WICGifLogicalScreenDescriptorPixelAspectRatio"]:=0x9
		,_["WICGifLogicalScreenDescriptorProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICGifImageDescriptorLeft"]:=0x1
		,_["WICGifImageDescriptorTop"]:=0x2
		,_["WICGifImageDescriptorWidth"]:=0x3
		,_["WICGifImageDescriptorHeight"]:=0x4
		,_["WICGifImageDescriptorLocalColorTableFlag"]:=0x5
		,_["WICGifImageDescriptorInterlaceFlag"]:=0x6
		,_["WICGifImageDescriptorSortFlag"]:=0x7
		 _["WICGifImageDescriptorLocalColorTableSize"]:=0x8
		,_["WICGifImageDescriptorProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICGifGraphicControlExtensionDisposal"]:=0x1
		,_["WICGifGraphicControlExtensionUserInputFlag"]:=0x2
		,_["WICGifGraphicControlExtensionTransparencyFlag"]:=0x3
		,_["WICGifGraphicControlExtensionDelay"]:=0x4
		,_["WICGifGraphicControlExtensionTransparentColorIndex"]:=0x5
		,_["WICGifGraphicControlExtensionProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICGifApplicationExtensionApplication"]:=0x1
		,_["WICGifApplicationExtensionData"]:=0x2
		 _["WICGifApplicationExtensionProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICGifCommentExtensionText"]:=0x1
		,_["WICGifCommentExtensionProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICJpegCommentText"]:=0x1
		,_["WICJpegCommentProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICJpegLuminanceTable"]:=0x1
		,_["WICJpegLuminanceProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICJpegChrominanceTable"]:=0x1
		,_["WICJpegChrominanceProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WIC8BIMIptcPString"]:=0
		 _["WIC8BIMIptcEmbeddedIPTC"]:=0x1
		,_["WIC8BIMIptcProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WIC8BIMResolutionInfoPString"]:=0x1
		,_["WIC8BIMResolutionInfoHResolution"]:=0x2
		,_["WIC8BIMResolutionInfoHResolutionUnit"]:=0x3
		,_["WIC8BIMResolutionInfoWidthUnit"]:=0x4
		,_["WIC8BIMResolutionInfoVResolution"]:=0x5
		,_["WIC8BIMResolutionInfoVResolutionUnit"]:=0x6
		,_["WIC8BIMResolutionInfoHeightUnit"]:=0x7
		,_["WIC8BIMResolutionInfoProperties_FORCE_DWORD"]:=0x7fffffff
		 _["WIC8BIMIptcDigestPString"]:=0x1
		,_["WIC8BIMIptcDigestIptcDigest"]:=0x2
		,_["WIC8BIMIptcDigestProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICPngGamaGamma"]:=0x1
		,_["WICPngGamaProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICPngBkgdBackgroundColor"]:=0x1
		,_["WICPngBkgdProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICPngItxtKeyword"]:=0x1
		,_["WICPngItxtCompressionFlag"]:=0x2
		,_["WICPngItxtLanguageTag"]:=0x3
		 _["WICPngItxtTranslatedKeyword"]:=0x4
		,_["WICPngItxtText"]:=0x5
		,_["WICPngItxtProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICPngChrmWhitePointX"]:=0x1
		,_["WICPngChrmWhitePointY"]:=0x2
		,_["WICPngChrmRedX"]:=0x3
		,_["WICPngChrmRedY"]:=0x4
		,_["WICPngChrmGreenX"]:=0x5
		,_["WICPngChrmGreenY"]:=0x6
		,_["WICPngChrmBlueX"]:=0x7
		 _["WICPngChrmBlueY"]:=0x8
		,_["WICPngChrmProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICPngHistFrequencies"]:=0x1
		,_["WICPngHistProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICPngIccpProfileName"]:=0x1
		,_["WICPngIccpProfileData"]:=0x2
		,_["WICPngIccpProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICPngSrgbRenderingIntent"]:=0x1
		,_["WICPngSrgbProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICPngTimeYear"]:=0x1
		 _["WICPngTimeMonth"]:=0x2
		,_["WICPngTimeDay"]:=0x3
		,_["WICPngTimeHour"]:=0x4
		,_["WICPngTimeMinute"]:=0x5
		,_["WICPngTimeSecond"]:=0x6
		,_["WICPngTimeProperties_FORCE_DWORD"]:=0x7fffffff
		,_["WICSectionAccessLevelRead"]:=0x1
		,_["WICSectionAccessLevelReadWrite"]:=0x3
		,_["WICSectionAccessLevel_FORCE_DWORD"]:=0x7fffffff
		,_["WICPixelFormatNumericRepresentationUnspecified"]:=0
		 _["WICPixelFormatNumericRepresentationIndexed"]:=0x1
		,_["WICPixelFormatNumericRepresentationUnsignedInteger"]:=0x2
		,_["WICPixelFormatNumericRepresentationSignedInteger"]:=0x3
		,_["WICPixelFormatNumericRepresentationFixed"]:=0x4
		,_["WICPixelFormatNumericRepresentationFloat"]:=0x5
		,_["WICPixelFormatNumericRepresentation_FORCE_DWORD"]:=0x7fffffff
		,_["WICTiffCompressionDontCare"]:=0
		,_["WICTiffCompressionNone"]:=0x1
		,_["WICTiffCompressionCCITT3"]:=0x2
		,_["WICTiffCompressionCCITT4"]:=0x3
		 _["WICTiffCompressionLZW"]:=0x4
		,_["WICTiffCompressionRLE"]:=0x5
		,_["WICTiffCompressionZIP"]:=0x6
		,_["WICTiffCompressionLZWHDifferencing"]:=0x7
		,_["WICTIFFCOMPRESSIONOPTION_FORCE_DWORD"]:=0x7fffffff
		,_["WICJpegYCrCbSubsamplingDefault"]:=0
		,_["WICJpegYCrCbSubsampling420"]:=0x1
		,_["WICJpegYCrCbSubsampling422"]:=0x2
		,_["WICJpegYCrCbSubsampling444"]:=0x3
		,_["WICJPEGYCRCBSUBSAMPLING_FORCE_DWORD"]:=0x7fffffff
		 _["WICPngFilterUnspecified"]:=0
		,_["WICPngFilterNone"]:=0x1
		,_["WICPngFilterSub"]:=0x2
		,_["WICPngFilterUp"]:=0x3
		,_["WICPngFilterAverage"]:=0x4
		,_["WICPngFilterPaeth"]:=0x5
		,_["WICPngFilterAdaptive"]:=0x6
		,_["WICPNGFILTEROPTION_FORCE_DWORD"]:=0x7fffffff
		,_["WICWhitePointDefault"]:=0x1
		,_["WICWhitePointDaylight"]:=0x2
		 _["WICWhitePointCloudy"]:=0x4
		,_["WICWhitePointShade"]:=0x8
		,_["WICWhitePointTungsten"]:=0x10
		,_["WICWhitePointFluorescent"]:=0x20
		,_["WICWhitePointFlash"]:=0x40
		,_["WICWhitePointUnderwater"]:=0x80
		,_["WICWhitePointCustom"]:=0x100
		,_["WICWhitePointAutoWhiteBalance"]:=0x200
		,_["WICWhitePointAsShot"]:=WICWhitePointDefault
		,_["WICNAMEDWHITEPOINT_FORCE_DWORD"]:=0x7fffffff
		 _["WICRawCapabilityNotSupported"]:=0
		,_["WICRawCapabilityGetSupported"]:=0x1
		,_["WICRawCapabilityFullySupported"]:=0x2
		,_["WICRAWCAPABILITIES_FORCE_DWORD"]:=0x7fffffff
		,_["WICRawRotationCapabilityNotSupported"]:=0
		,_["WICRawRotationCapabilityGetSupported"]:=0x1
		,_["WICRawRotationCapabilityNinetyDegreesSupported"]:=0x2
		,_["WICRawRotationCapabilityFullySupported"]:=0x3
		,_["WICRAWROTATIONCAPABILITIES_FORCE_DWORD"]:=0x7fffffff
		,_["WICAsShotParameterSet"]:=0x1
		 _["WICUserAdjustedParameterSet"]:=0x2
		,_["WICAutoAdjustedParameterSet"]:=0x3
		,_["WICRAWPARAMETERSET_FORCE_DWORD"]:=0x7fffffff
		,_["WICRawRenderModeDraft"]:=0x1
		,_["WICRawRenderModeNormal"]:=0x2
		,_["WICRawRenderModeBestQuality"]:=0x3
		,_["WICRAWRENDERMODE_FORCE_DWORD"]:=0x7fffffff
	}
	return _[type]
}

WIC_GUID(ByRef GUID,name){
	static init:=1,_:={}
	if init {
	init:=0
	; Decoders
	 _.CLSID_WICBmpDecoder:=[0x6b462062, 0x7cbf, 0x400d, 0x9f, 0xdb, 0x81, 0x3d, 0xd1, 0xf, 0x27, 0x78]
	,_.CLSID_WICPngDecoder:=[0x389ea17b, 0x5078, 0x4cde, 0xb6, 0xef, 0x25, 0xc1, 0x51, 0x75, 0xc7, 0x51]
	,_.CLSID_WICIcoDecoder:=[0xc61bfcdf, 0x2e0f, 0x4aad, 0xa8, 0xd7, 0xe0, 0x6b, 0xaf, 0xeb, 0xcd, 0xfe]
	,_.CLSID_WICJpegDecoder:=[0x9456a480, 0xe88b, 0x43ea, 0x9e, 0x73, 0xb, 0x2d, 0x9b, 0x71, 0xb1, 0xca]
	,_.CLSID_WICGifDecoder:=[0x381dda3c, 0x9ce9, 0x4834, 0xa2, 0x3e, 0x1f, 0x98, 0xf8, 0xfc, 0x52, 0xbe]
	,_.CLSID_WICTiffDecoder:=[0xb54e85d9, 0xfe23, 0x499f, 0x8b, 0x88, 0x6a, 0xce, 0xa7, 0x13, 0x75, 0x2b]
	,_.CLSID_WICWmpDecoder:=[0xa26cec36, 0x234c, 0x4950, 0xae, 0x16, 0xe3, 0x4a, 0xac, 0xe7, 0x1d, 0x0d]
	; Encoders
	 _.CLSID_WICBmpEncoder:=[0x69be8bb4, 0xd66d, 0x47c8, 0x86, 0x5a, 0xed, 0x15, 0x89, 0x43, 0x37, 0x82]
	,_.CLSID_WICPngEncoder:=[0x27949969, 0x876a, 0x41d7, 0x94, 0x47, 0x56, 0x8f, 0x6a, 0x35, 0xa4, 0xdc]
	,_.CLSID_WICJpegEncoder:=[0x1a34f5c1, 0x4a5a, 0x46dc, 0xb6, 0x44, 0x1f, 0x45, 0x67, 0xe7, 0xa6, 0x76]
	,_.CLSID_WICGifEncoder:=[0x114f5598, 0xb22, 0x40a0, 0x86, 0xa1, 0xc8, 0x3e, 0xa4, 0x95, 0xad, 0xbd]
	,_.CLSID_WICTiffEncoder:=[0x0131be10, 0x2001, 0x4c5f, 0xa9, 0xb0, 0xcc, 0x88, 0xfa, 0xb6, 0x4c, 0xe8]
	,_.CLSID_WICWmpEncoder:=[0xac4ce3cb, 0xe1c1, 0x44cd, 0x82, 0x15, 0x5a, 0x16, 0x65, 0x50, 0x9e, 0xc2]
	; Container Formats
	 _.GUID_ContainerFormatBmp:=[0xaf1d87e, 0xfcfe, 0x4188, 0xbd, 0xeb, 0xa7, 0x90, 0x64, 0x71, 0xcb, 0xe3]
	,_.GUID_ContainerFormatPng:=[0x1b7cfaf4, 0x713f, 0x473c, 0xbb, 0xcd, 0x61, 0x37, 0x42, 0x5f, 0xae, 0xaf]
	,_.GUID_ContainerFormatIco:=[0xa3a860c4, 0x338f, 0x4c17, 0x91, 0x9a, 0xfb, 0xa4, 0xb5, 0x62, 0x8f, 0x21]
	,_.GUID_ContainerFormatJpeg:=[0x19e4a5aa, 0x5662, 0x4fc5, 0xa0, 0xc0, 0x17, 0x58, 0x2, 0x8e, 0x10, 0x57]
	,_.GUID_ContainerFormatTiff:=[0x163bcc30, 0xe2e9, 0x4f0b, 0x96, 0x1d, 0xa3, 0xe9, 0xfd, 0xb7, 0x88, 0xa3]
	,_.GUID_ContainerFormatGif:=[0x1f8a5601, 0x7d4d, 0x4cbd, 0x9c, 0x82, 0x1b, 0xc8, 0xd4, 0xee, 0xb9, 0xa5]
	,_.GUID_ContainerFormatWmp:=[0x57a37caa, 0x367a, 0x4540, 0x91, 0x6b, 0xf1, 0x83, 0xc5, 0x09, 0x3a, 0x4b]
	; Component Identifiers
	 _.CLSID_WICImagingCategories:=[0xfae3d380, 0xfea4, 0x4623, 0x8c, 0x75, 0xc6, 0xb6, 0x11, 0x10, 0xb6, 0x81]
	,_.CATID_WICBitmapDecoders:=[0x7ed96837, 0x96f0, 0x4812, 0xb2, 0x11, 0xf1, 0x3c, 0x24, 0x11, 0x7e, 0xd3]
	,_.CATID_WICBitmapEncoders:=[0xac757296, 0x3522, 0x4e11, 0x98, 0x62, 0xc1, 0x7b, 0xe5, 0xa1, 0x76, 0x7e]
	,_.CATID_WICPixelFormats:=[0x2b46e70f, 0xcda7, 0x473e, 0x89, 0xf6, 0xdc, 0x96, 0x30, 0xa2, 0x39, 0x0b]
	,_.CATID_WICFormatConverters:=[0x7835eae8, 0xbf14, 0x49d1, 0x93, 0xce, 0x53, 0x3a, 0x40, 0x7b, 0x22, 0x48]
	,_.CATID_WICMetadataReader:=[0x05af94d8, 0x7174, 0x4cd2, 0xbe, 0x4a, 0x41, 0x24, 0xb8, 0x0e, 0xe4, 0xb8]
	,_.CATID_WICMetadataWriter:=[0xabe3b9a4, 0x257d, 0x4b97, 0xbd, 0x1a, 0x29, 0x4a, 0xf4, 0x96, 0x22, 0x2e]
	; Format Converters
	 _.CLSID_WICDefaultFormatConverter:=[0x1a3f11dc, 0xb514, 0x4b17, 0x8c, 0x5f, 0x21, 0x54, 0x51, 0x38, 0x52, 0xf1]
	,_.CLSID_WICFormatConverterHighColor:=[0xac75d454, 0x9f37, 0x48f8, 0xb9, 0x72, 0x4e, 0x19, 0xbc, 0x85, 0x60, 0x11]
	,_.CLSID_WICFormatConverterNChannel:=[0xc17cabb2, 0xd4a3, 0x47d7, 0xa5, 0x57, 0x33, 0x9b, 0x2e, 0xfb, 0xd4, 0xf1]
	,_.CLSID_WICFormatConverterWMPhoto:=[0x9cb5172b, 0xd600, 0x46ba, 0xab, 0x77, 0x77, 0xbb, 0x7e, 0x3a, 0x00, 0xd9]
	; Metadata Handlers
	 _.GUID_MetadataFormatUnknown:=[0xA45E592F, 0x9078, 0x4A7C, 0xAD, 0xB5, 0x4E, 0xDC, 0x4F, 0xD6, 0x1B, 0x1F]
	,_.GUID_MetadataFormatIfd:=[0x537396C6, 0x2D8A, 0x4BB6, 0x9B, 0xF8, 0x2F, 0x0A, 0x8E, 0x2A, 0x3A, 0xDF]
	,_.GUID_MetadataFormatSubIfd:=[0x58A2E128, 0x2DB9, 0x4E57, 0xBB, 0x14, 0x51, 0x77, 0x89, 0x1E, 0xD3, 0x31]
	,_.GUID_MetadataFormatExif:=[0x1C3C4F9D, 0xB84A, 0x467D, 0x94, 0x93, 0x36, 0xCF, 0xBD, 0x59, 0xEA, 0x57]
	,_.GUID_MetadataFormatGps:=[0x7134AB8A, 0x9351, 0x44AD, 0xAF, 0x62, 0x44, 0x8D, 0xB6, 0xB5, 0x02, 0xEC]
	,_.GUID_MetadataFormatInterop:=[0xED686F8E, 0x681F, 0x4C8B, 0xBD, 0x41, 0xA8, 0xAD, 0xDB, 0xF6, 0xB3, 0xFC]
	,_.GUID_MetadataFormatApp0:=[0x79007028, 0x268D, 0x45d6, 0xA3, 0xC2, 0x35, 0x4E, 0x6A, 0x50, 0x4B, 0xC9]
	,_.GUID_MetadataFormatApp1:=[0x8FD3DFC3, 0xF951, 0x492B, 0x81, 0x7F, 0x69, 0xC2, 0xE6, 0xD9, 0xA5, 0xB0]
	,_.GUID_MetadataFormatApp13:=[0x326556A2, 0xF502, 0x4354, 0x9C, 0xC0, 0x8E, 0x3F, 0x48, 0xEA, 0xF6, 0xB5]
	,_.GUID_MetadataFormatIPTC:=[0x4FAB0914, 0xE129, 0x4087, 0xA1, 0xD1, 0xBC, 0x81, 0x2D, 0x45, 0xA7, 0xB5]
	,_.GUID_MetadataFormatIRB:=[0x16100D66, 0x8570, 0x4BB9, 0xB9, 0x2D, 0xFD, 0xA4, 0xB2, 0x3E, 0xCE, 0x67]
	,_.GUID_MetadataFormat8BIMIPTC:=[0x0010568c, 0x0852, 0x4e6a, 0xb1, 0x91, 0x5c, 0x33, 0xac, 0x5b, 0x04, 0x30]
	,_.GUID_MetadataFormat8BIMResolutionInfo:=[0x739F305D, 0x81DB, 0x43CB, 0xAC, 0x5E, 0x55, 0x01, 0x3E, 0xF9, 0xF0, 0x03]
	 _.GUID_MetadataFormat8BIMIPTCDigest:=[0x1CA32285, 0x9CCD, 0x4786, 0x8B, 0xD8, 0x79, 0x53, 0x9D, 0xB6, 0xA0, 0x06]
	,_.GUID_MetadataFormatXMP:=[0xBB5ACC38, 0xF216, 0x4CEC, 0xA6, 0xC5, 0x5F, 0x6E, 0x73, 0x97, 0x63, 0xA9]
	,_.GUID_MetadataFormatThumbnail:=[0x243dcee9, 0x8703, 0x40ee, 0x8e, 0xf0, 0x22, 0xa6, 0x0, 0xb8, 0x5, 0x8c]
	,_.GUID_MetadataFormatChunktEXt:=[0x568d8936, 0xc0a9, 0x4923, 0x90, 0x5d, 0xdf, 0x2b, 0x38, 0x23, 0x8f, 0xbc]
	,_.GUID_MetadataFormatXMPStruct:=[0x22383CF1, 0xED17, 0x4E2E, 0xAF, 0x17, 0xD8, 0x5B, 0x8F, 0x6B, 0x30, 0xD0]
	,_.GUID_MetadataFormatXMPBag:=[0x833CCA5F, 0xDCB7, 0x4516, 0x80, 0x6F, 0x65, 0x96, 0xAB, 0x26, 0xDC, 0xE4]
	,_.GUID_MetadataFormatXMPSeq:=[0x63E8DF02, 0xEB6C,0x456C, 0xA2, 0x24, 0xB2, 0x5E, 0x79, 0x4F, 0xD6, 0x48]
	,_.GUID_MetadataFormatXMPAlt:=[0x7B08A675, 0x91AA, 0x481B, 0xA7, 0x98, 0x4D, 0xA9, 0x49, 0x08, 0x61, 0x3B]
	,_.GUID_MetadataFormatLSD:=[0xE256031E, 0x6299, 0x4929, 0xB9, 0x8D, 0x5A, 0xC8, 0x84, 0xAF, 0xBA, 0x92]
	,_.GUID_MetadataFormatIMD:=[0xBD2BB086, 0x4D52, 0x48DD, 0x96, 0x77, 0xDB, 0x48, 0x3E, 0x85, 0xAE, 0x8F]
	,_.GUID_MetadataFormatGCE:=[0x2A25CAD8, 0xDEEB, 0x4C69, 0xA7, 0x88, 0xE, 0xC2, 0x26, 0x6D, 0xCA, 0xFD]
	,_.GUID_MetadataFormatAPE:=[0x2E043DC2, 0xC967, 0x4E05, 0x87, 0x5E, 0x61, 0x8B, 0xF6, 0x7E, 0x85, 0xC3]
	 _.GUID_MetadataFormatJpegChrominance:=[0xF73D0DCF, 0xCEC6, 0x4F85, 0x9B, 0x0E, 0x1C, 0x39, 0x56, 0xB1, 0xBE, 0xF7]
	,_.GUID_MetadataFormatJpegLuminance:=[0x86908007, 0xEDFC, 0x4860, 0x8D, 0x4B, 0x4E, 0xE6, 0xE8, 0x3E, 0x60, 0x58]
	,_.GUID_MetadataFormatJpegComment:=[0x220E5F33, 0xAFD3, 0x474E, 0x9D, 0x31, 0x7D, 0x4F, 0xE7, 0x30, 0xF5, 0x57]
	,_.GUID_MetadataFormatGifComment:=[0xC4B6E0E0, 0xCFB4, 0x4AD3, 0xAB, 0x33, 0x9A, 0xAD, 0x23, 0x55, 0xA3, 0x4A]
	,_.GUID_MetadataFormatChunkgAMA:=[0xF00935A5, 0x1D5D, 0x4CD1, 0x81, 0xB2, 0x93, 0x24, 0xD7, 0xEC, 0xA7, 0x81]
	,_.GUID_MetadataFormatChunkbKGD:=[0xE14D3571, 0x6B47, 0x4DEA, 0xB6, 0xA, 0x87, 0xCE, 0xA, 0x78, 0xDF, 0xB7]
	,_.GUID_MetadataFormatChunkiTXt:=[0xC2BEC729, 0xB68, 0x4B77, 0xAA, 0xE, 0x62, 0x95, 0xA6, 0xAC, 0x18, 0x14]
	,_.GUID_MetadataFormatChunkcHRM:=[0x9DB3655B, 0x2842, 0x44B3, 0x80, 0x67, 0x12, 0xE9, 0xB3, 0x75, 0x55, 0x6A]
	,_.GUID_MetadataFormatChunkhIST:=[0xC59A82DA, 0xDB74, 0x48A4, 0xBD, 0x6A, 0xB6, 0x9C, 0x49, 0x31, 0xEF, 0x95]
	,_.GUID_MetadataFormatChunkiCCP:=[0xEB4349AB, 0xB685, 0x450F, 0x91, 0xB5, 0xE8, 0x2, 0xE8, 0x92, 0x53, 0x6C]
	,_.GUID_MetadataFormatChunksRGB:=[0xC115FD36, 0xCC6F, 0x4E3F, 0x83, 0x63, 0x52, 0x4B, 0x87, 0xC6, 0xB0, 0xD9]
	,_.GUID_MetadataFormatChunktIME:=[0x6B00AE2D, 0xE24B, 0x460A, 0x98, 0xB6, 0x87, 0x8B, 0xD0, 0x30, 0x72, 0xFD]
	; Vendor Identification
	 _.GUID_VendorMicrosoft:=[0x69fd0fdc, 0xa866, 0x4108, 0xb3, 0xb2, 0x98, 0x44, 0x7f, 0xa9, 0xed, 0xd4]
	,_.GUID_VendorMicrosoftBuiltIn:=[0x257a30fd, 0x6b6, 0x462b, 0xae, 0xa4, 0x63, 0xf7, 0xb, 0x86, 0xe5, 0x33]
	; WICBitmapPaletteType
	 _.GUID_WICPixelFormatDontCare:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x00]
	,_.GUID_WICPixelFormat1bppIndexed:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x01]
	,_.GUID_WICPixelFormat2bppIndexed:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x02]
	,_.GUID_WICPixelFormat4bppIndexed:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x03]
	,_.GUID_WICPixelFormat8bppIndexed:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x04]
	,_.GUID_WICPixelFormatBlackWhite:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x05]
	,_.GUID_WICPixelFormat2bppGray:=[  0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x06]
	,_.GUID_WICPixelFormat4bppGray:=[  0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x07]
	,_.GUID_WICPixelFormat8bppGray:=[  0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x08]
	,_.GUID_WICPixelFormat8bppAlpha:=[0xe6cd0116, 0xeeba, 0x4161, 0xaa, 0x85, 0x27, 0xdd, 0x9f, 0xb3, 0xa8, 0x95]
	,_.GUID_WICPixelFormat16bppBGR555:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x09]
	,_.GUID_WICPixelFormat16bppBGR565:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0a]
	,_.GUID_WICPixelFormat16bppBGRA5551:=[0x05ec7c2b, 0xf1e6, 0x4961, 0xad, 0x46, 0xe1, 0xcc, 0x81, 0x0a, 0x87, 0xd2]
	 _.GUID_WICPixelFormat16bppGray:=[  0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0b]
	,_.GUID_WICPixelFormat24bppBGR:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0c]
	,_.GUID_WICPixelFormat24bppRGB:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0d]
	,_.GUID_WICPixelFormat32bppBGR:=[  0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0e]
	,_.GUID_WICPixelFormat32bppBGRA:=[ 0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0f]
	,_.GUID_WICPixelFormat32bppPBGRA:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x10]
	,_.GUID_WICPixelFormat32bppGrayFloat:=[ 0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x11]
	,_.GUID_WICPixelFormat32bppRGBA:=[0xf5c7ad2d, 0x6a8d, 0x43dd, 0xa7, 0xa8, 0xa2, 0x99, 0x35, 0x26, 0x1a, 0xe9]
	,_.GUID_WICPixelFormat32bppPRGBA:=[0x3cc4a650, 0xa527, 0x4d37, 0xa9, 0x16, 0x31, 0x42, 0xc7, 0xeb, 0xed, 0xba]
	,_.GUID_WICPixelFormat48bppRGB:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x15]
	,_.GUID_WICPixelFormat48bppBGR:=[0xe605a384, 0xb468, 0x46ce, 0xbb, 0x2e, 0x36, 0xf1, 0x80, 0xe6, 0x43, 0x13]
	,_.GUID_WICPixelFormat64bppRGBA:=[ 0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x16]
	,_.GUID_WICPixelFormat64bppBGRA:=[ 0x1562ff7c, 0xd352, 0x46f9, 0x97, 0x9e, 0x42, 0x97, 0x6b, 0x79, 0x22, 0x46]
	 _.GUID_WICPixelFormat64bppPRGBA:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x17]
	,_.GUID_WICPixelFormat64bppPBGRA:=[0x8c518e8e, 0xa4ec, 0x468b, 0xae, 0x70, 0xc9, 0xa3, 0x5a, 0x9c, 0x55, 0x30]
	,_.GUID_WICPixelFormat16bppGrayFixedPoint:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x13]
	,_.GUID_WICPixelFormat32bppBGR101010:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x14]
	,_.GUID_WICPixelFormat48bppRGBFixedPoint:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x12]
	,_.GUID_WICPixelFormat48bppBGRFixedPoint:=[0x49ca140e, 0xcab6, 0x493b, 0x9d, 0xdf, 0x60, 0x18, 0x7c, 0x37, 0x53, 0x2a]
	,_.GUID_WICPixelFormat96bppRGBFixedPoint:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x18]
	,_.GUID_WICPixelFormat128bppRGBAFloat:=[ 0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x19]
	,_.GUID_WICPixelFormat128bppPRGBAFloat:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x1a]
	,_.GUID_WICPixelFormat128bppRGBFloat:=[  0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x1b]
	,_.GUID_WICPixelFormat32bppCMYK:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x1c]
	,_.GUID_WICPixelFormat64bppRGBAFixedPoint:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x1d]
	,_.GUID_WICPixelFormat64bppBGRAFixedPoint:=[0x356de33c, 0x54d2, 0x4a23, 0xbb, 0x4, 0x9b, 0x7b, 0xf9, 0xb1, 0xd4, 0x2d]
	 _.GUID_WICPixelFormat64bppRGBFixedPoint:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x40]
	,_.GUID_WICPixelFormat128bppRGBAFixedPoint:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x1e]
	,_.GUID_WICPixelFormat128bppRGBFixedPoint:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x41]
	,_.GUID_WICPixelFormat64bppRGBAHalf:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x3a]
	,_.GUID_WICPixelFormat64bppRGBHalf:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x42]
	,_.GUID_WICPixelFormat48bppRGBHalf:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x3b]
	,_.GUID_WICPixelFormat32bppRGBE:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x3d]
	,_.GUID_WICPixelFormat16bppGrayHalf:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x3e]
	,_.GUID_WICPixelFormat32bppGrayFixedPoint:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x3f]
	,_.GUID_WICPixelFormat32bppRGBA1010102:=[0x25238D72, 0xFCF9, 0x4522, 0xb5, 0x14, 0x55, 0x78, 0xe5, 0xad, 0x55, 0xe0]
	,_.GUID_WICPixelFormat32bppRGBA1010102XR:=[0x00DE6B9A, 0xC101, 0x434b, 0xb5, 0x02, 0xd0, 0x16, 0x5e, 0xe1, 0x12, 0x2c]
	,_.GUID_WICPixelFormat64bppCMYK:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x1f]
	,_.GUID_WICPixelFormat24bpp3Channels:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x20]
	 _.GUID_WICPixelFormat32bpp4Channels:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x21]
	,_.GUID_WICPixelFormat40bpp5Channels:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x22]
	,_.GUID_WICPixelFormat48bpp6Channels:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x23]
	,_.GUID_WICPixelFormat56bpp7Channels:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x24]
	,_.GUID_WICPixelFormat64bpp8Channels:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x25]
	,_.GUID_WICPixelFormat48bpp3Channels:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x26]
	,_.GUID_WICPixelFormat64bpp4Channels:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x27]
	,_.GUID_WICPixelFormat80bpp5Channels:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x28]
	,_.GUID_WICPixelFormat96bpp6Channels:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x29]
	,_.GUID_WICPixelFormat112bpp7Channels:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x2a]
	,_.GUID_WICPixelFormat128bpp8Channels:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x2b]
	,_.GUID_WICPixelFormat40bppCMYKAlpha:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x2c]
	,_.GUID_WICPixelFormat80bppCMYKAlpha:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x2d]
	,_.GUID_WICPixelFormat32bpp3ChannelsAlpha:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x2e]
	 _.GUID_WICPixelFormat40bpp4ChannelsAlpha:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x2f]
	,_.GUID_WICPixelFormat48bpp5ChannelsAlpha:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x30]
	,_.GUID_WICPixelFormat56bpp6ChannelsAlpha:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x31]
	,_.GUID_WICPixelFormat64bpp7ChannelsAlpha:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x32]
	,_.GUID_WICPixelFormat72bpp8ChannelsAlpha:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x33]
	,_.GUID_WICPixelFormat64bpp3ChannelsAlpha:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x34]
	,_.GUID_WICPixelFormat80bpp4ChannelsAlpha:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x35]
	,_.GUID_WICPixelFormat96bpp5ChannelsAlpha:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x36]
	,_.GUID_WICPixelFormat112bpp6ChannelsAlpha:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x37]
	,_.GUID_WICPixelFormat128bpp7ChannelsAlpha:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x38]
	,_.GUID_WICPixelFormat144bpp8ChannelsAlpha:=[0x6fddc324, 0x4e03, 0x4bfe, 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x39]

	}
	if _.haskey(name){
		p:=_[name]
		VarSetCapacity(GUID,16)
		,NumPut(p.1+(p.2<<32)+(p.3<<48),GUID,0,"int64")
		,NumPut(p.4+(p.5<<8)+(p.6<<16)+(p.7<<24)+(p.8<<32)+(p.9<<40)+(p.10<<48)+(p.11<<56),GUID,8,"int64")
		return &GUID
	}else return name
}

; wic error code
WIC_hr(a,b){
	static init:=1,err:={0x8000FFFF:"Catastrophic failure error.",0x80004001:"Not implemented error.",0x8007000E:"Out of memory error.",0x80070057:"One or more arguments are not valid error.",0x80004002:"Interface not supported error.",0x80004003:"Pointer not valid error.",0x80070006:"Handle not valid error.",0x80004004:"Operation aborted error.",0x80004005:"Unspecified error.",0x80070005:"General access denied error.",0x800401E5:"The object identified by this moniker could not be found."}
	if init{
		init:=0
		 err[0x80004005]:="WINCODEC_ERR_GENERIC_ERROR"
		,err[0x80070057]:="WINCODEC_ERR_INVALIDPARAMETER"
		,err[0x8007000E]:="WINCODEC_ERR_OUTOFMEMORY"
		,err[0x80004001]:="WINCODEC_ERR_NOTIMPLEMENTED"
		,err[0x80004004]:="WINCODEC_ERR_ABORTED"
		,err[0x80070005]:="WINCODEC_ERR_ACCESSDENIED"
		,err[0x88982f04]:="WINCODEC_ERR_WRONGSTATE"
		,err[0x88982f05]:="WINCODEC_ERR_VALUEOUTOFRANGE"
		,err[0x88982f07]:="WINCODEC_ERR_UNKNOWNIMAGEFORMAT"
		,err[0x88982f0B]:="WINCODEC_ERR_UNSUPPORTEDVERSION"
		,err[0x88982f0C]:="WINCODEC_ERR_NOTINITIALIZED"
		,err[0x88982f0D]:="WINCODEC_ERR_ALREADYLOCKED"
		,err[0x88982f40]:="WINCODEC_ERR_PROPERTYNOTFOUND"
		,err[0x88982f41]:="WINCODEC_ERR_PROPERTYNOTSUPPORTED"
		,err[0x88982f42]:="WINCODEC_ERR_PROPERTYSIZE"
		,err[0x88982f43]:="WINCODEC_ERR_CODECPRESENT"
		,err[0x88982f44]:="WINCODEC_ERR_CODECNOTHUMBNAIL"
		,err[0x88982f45]:="WINCODEC_ERR_PALETTEUNAVAILABLE"
		,err[0x88982f46]:="WINCODEC_ERR_CODECTOOMANYSCANLINES"
		,err[0x88982f48]:="WINCODEC_ERR_INTERNALERROR"
		,err[0x88982f49]:="WINCODEC_ERR_SOURCERECTDOESNOTMATCHDIMENSIONS"
		,err[0x88982f50]:="WINCODEC_ERR_COMPONENTNOTFOUND"
		 err[0x88982f51]:="WINCODEC_ERR_IMAGESIZEOUTOFRANGE"
		,err[0x88982f52]:="WINCODEC_ERR_TOOMUCHMETADATA"
		,err[0x88982f60]:="WINCODEC_ERR_BADIMAGE"
		,err[0x88982f61]:="WINCODEC_ERR_BADHEADER"
		,err[0x88982f62]:="WINCODEC_ERR_FRAMEMISSING"
		,err[0x88982f63]:="WINCODEC_ERR_BADMETADATAHEADER"
		,err[0x88982f70]:="WINCODEC_ERR_BADSTREAMDATA"
		,err[0x88982f71]:="WINCODEC_ERR_STREAMWRITE"
		,err[0x88982f72]:="WINCODEC_ERR_STREAMREAD"
		,err[0x88982f73]:="WINCODEC_ERR_STREAMNOTAVAILABLE"
		,err[0x88982f80]:="WINCODEC_ERR_UNSUPPORTEDPIXELFORMAT"
		,err[0x88982f81]:="WINCODEC_ERR_UNSUPPORTEDOPERATION"
		,err[0x88982f8A]:="WINCODEC_ERR_INVALIDREGISTRATION"
		,err[0x88982f8B]:="WINCODEC_ERR_COMPONENTINITIALIZEFAILURE"
		,err[0x88982f8C]:="WINCODEC_ERR_INSUFFICIENTBUFFER"
		,err[0x88982f8D]:="WINCODEC_ERR_DUPLICATEMETADATAPRESENT"
		,err[0x88982f8E]:="WINCODEC_ERR_PROPERTYUNEXPECTEDTYPE"
		,err[0x88982f8F]:="WINCODEC_ERR_UNEXPECTEDSIZE"
		,err[0x88982f90]:="WINCODEC_ERR_INVALIDQUERYREQUEST"
		,err[0x88982f91]:="WINCODEC_ERR_UNEXPECTEDMETADATATYPE"
		,err[0x88982f92]:="WINCODEC_ERR_REQUESTONLYVALIDATMETADATAROOT"
		,err[0x88982f93]:="WINCODEC_ERR_INVALIDQUERYCHARACTER"
	}	
	if a && (a&=0xFFFFFFFF)
		msgbox, % b " : " (err.haskey(a)?err[a]:_error(a,b))
	return a
}
