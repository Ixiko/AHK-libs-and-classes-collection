#Include base.ahk
class IDWriteFactory extends IUnknown
{
  iid := "{b859ee5a-d838-4b5b-a2e8-1adc7d93db48}"
  __new(ptr){
    if (p=""){
      DllCall("LoadLibrary","str","dwrite.dll")
      DllCall("dwrite\DWriteCreateFactory","uint",0,"ptr",GUID(CLSID,"{b859ee5a-d838-4b5b-a2e8-1adc7d93db48}"),"ptr*",pIFactory)
      if this.__:=pIFactory
        this._v:=NumGet(this.__+0)
      else return
    }else if !p
      return
    else this.__:=p,this._v:=NumGet(this.__+0)
  }
  ; Gets an object which represents the set of installed fonts. 
  GetSystemFontCollection(checkForUpdates){
	_Error(DllCall(this.vt(3),"ptr",this.__,"ptr*",fontCollection,"int",checkForUpdates),"GetSystemFontCollection")
    return new IDWriteFontCollection(fontCollection)
  }

  ; Creates a font collection using a custom font collection loader. 
  CreateCustomFontCollection(collectionLoader,collectionKey,collectionKeySize){ ; IDWriteFontCollectionLoader
	_Error(DllCall(this.vt(4),"ptr",this.__,"ptr",collectionLoader.__,"ptr",collectionKey,"uint",collectionKeySize,"ptr*",fontCollection),"CreateCustomFontCollection")
    return new IDWriteFontCollection(fontCollection)
  }

  ; Registers a custom font collection loader with the factory object. 
  ; This function registers a font collection loader with DirectWrite. The font collection loader interface, which should be implemented by a singleton object, handles enumerating font files in a font collection given a particular type of key. A given instance can only be registered once. Succeeding attempts will return an error, indicating that it has already been registered. Note that font file loader implementations must not register themselves with DirectWrite inside their constructors, and must not unregister themselves inside their destructors, because registration and unregistraton operations increment and decrement the object reference count respectively. Instead, registration and unregistration with DirectWrite of font file loaders should be performed outside of the font file loader implementation.
  RegisterFontCollectionLoader(fontCollectionLoader){ ; IDWriteFontCollectionLoader
	return _Error(DllCall(this.vt(5),"ptr",this.__,"ptr",fontCollectionLoader.__),"RegisterFontCollectionLoader")
  }

  ; Unregisters a custom font collection loader that was previously registered using RegisterFontCollectionLoader. 
  UnregisterFontCollectionLoader(fontCollectionLoader){ ; IDWriteFontCollectionLoader
	return _Error(DllCall(this.vt(6),"ptr",this.__,"ptr",fontCollectionLoader.__),"UnregisterFontCollectionLoader")
  }

  ; Creates a font file reference object from a local font file. 
  ; Example demonstrates creating a font face from a font file's file name. http://msdn.microsoft.com/en-us/library/windows/desktop/dd368197%28v=vs.85%29.aspx
  CreateFontFileReference(filePath,lastWriteTime=0){ ; FILETIME
	_Error(DllCall(this.vt(7),"ptr",this.__,"str",filePath,"ptr",lastWriteTime,"ptr*",fontFile),"CreateFontFileReference")
    return new IDWriteFontFile(fontFile)
  }

  ; Creates a reference to an application-specific font file resource. 
  ; This function is provided for cases when an application or a document needs to use a private font without having to install it on the system. fontFileReferenceKey has to be unique only in the scope of the fontFileLoader used in this call. 
  CreateCustomFontFileReference(fontFileReferenceKey,fontFileReferenceKeySize,fontFileLoader){ IDWriteFontFileLoader
	_Error(DllCall(this.vt(8),"ptr",this.__,"ptr",fontFileReferenceKey,"uint",fontFileReferenceKeySize,"ptr",fontFileLoader.__,"ptr*",fontFile),"CreateCustomFontFileReference")
    return new IDWriteFontFile(fontFile)
  }

  ; Creates an object that represents a font face. 
  CreateFontFace(fontFaceType,numberOfFiles,fontFiles,faceIndex,fontFaceSimulationFlags){ ; DWRITE_FONT_FACE_TYPE , IDWriteFontFile , DWRITE_FONT_SIMULATIONS
	_Error(DllCall(this.vt(9),"ptr",this.__,"int",fontFaceType,"uint",numberOfFiles,"ptr",fontFiles.__,"uint",faceIndex,"uint",fontFaceSimulationFlags,"ptr*",fontFace),"CreateFontFace")
    return new IDWriteFontFace(fontFace)
  }

  ; Creates a rendering parameters object with default settings for the primary monitor. Different monitors may have different rendering parameters.
  CreateRenderingParams(){
	_Error(DllCall(this.vt(10),"ptr",this.__,"ptr*",renderingParams),"CreateRenderingParams")
    return new IDWriteRenderingParams(renderingParams)
  }

  ; Creates a rendering parameters object with default settings for the specified monitor. In most cases, this is the preferred way to create a rendering parameters object.
  CreateMonitorRenderingParams(monitor){ ; HMONITOR
	_Error(DllCall(this.vt(11),"ptr",this.__,"ptr",monitor,"ptr*",renderingParams),"CreateMonitorRenderingParams")
    return new IDWriteRenderingParams(renderingParams)
  }

  ; Creates a rendering parameters object with the specified properties. 
  CreateCustomRenderingParams(gamma,enhancedContrast,clearTypeLevel,pixelGeometry,renderingMode){ ; DWRITE_PIXEL_GEOMETRY , DWRITE_RENDERING_MODE
	_Error(DllCall(this.vt(12),"ptr",this.__,"float",gamma,"float",enhancedContrast,"float",clearTypeLevel,"int",pixelGeometry,"int",renderingMode,"ptr*",renderingParams),"CreateCustomRenderingParams")
    return new IDWriteRenderingParams(renderingParams)
  }

  ; Registers a font file loader with DirectWrite. 
  ; This function registers a font file loader with DirectWrite. The font file loader interface, which should be implemented by a singleton object, handles loading font file resources of a particular type from a key. A given instance can only be registered once. Succeeding attempts will return an error, indicating that it has already been registered. Note that font file loader implementations must not register themselves with DirectWrite inside their constructors, and must not unregister themselves inside their destructors, because registration and unregistraton operations increment and decrement the object reference count respectively. Instead, registration and unregistration with DirectWrite of font file loaders should be performed outside of the font file loader implementation. 
  RegisterFontFileLoader(fontFileLoader){ ; IDWriteFontFileLoader
	return _Error(DllCall(this.vt(13),"ptr",this.__,"ptr",fontFileLoader.__),"RegisterFontFileLoader")
  }

  ; Unregisters a font file loader that was previously registered with the DirectWrite font system using RegisterFontFileLoader. 
  UnregisterFontFileLoader(fontFileLoader){ ; IDWriteFontFileLoader
	return _Error(DllCall(this.vt(14),"ptr",this.__,"ptr",fontFileLoader.__),"UnregisterFontFileLoader")
  }

  ; Creates a text format object used for text layout. 
  CreateTextFormat(fontFamilyName,fontCollection,fontWeight,fontStyle,fontStretch,fontSize,localeName){ ; IDWriteFontCollection , DWRITE_FONT_WEIGHT , DWRITE_FONT_STYLE , DWRITE_FONT_STRETCH
	_Error(DllCall(this.vt(15),"ptr",this.__,"str",fontFamilyName,"ptr",fontCollection,"int",fontWeight,"int",fontStyle,"int",fontStretch,"float",fontSize,"str",localeName,"ptr*",textFormat),"CreateTextFormat")
    return new IDWriteTextFormat(textFormat)
  }

  ; Creates a typography object for use in a text layout. 
  CreateTypography(){
	_Error(DllCall(this.vt(16),"ptr",this.__,"ptr*",typography),"CreateTypography")
    return new IDWriteTypography(typography)
  }

  ; Creates an object that is used for interoperability with GDI. 
  GetGdiInterop(){
	_Error(DllCall(this.vt(17),"ptr",this.__,"ptr*",gdiInterop),"GetGdiInterop")
    return new IDWriteGdiInterop(gdiInterop)
  }

  ; Takes a string, text format, and associated constraints, and produces an object that represents the fully analyzed and formatted result. 
  CreateTextLayout(string,stringLength,textFormat,maxWidth,maxHeight){ ; IDWriteTextFormat
	_Error(DllCall(this.vt(18),"ptr",this.__,"str",string,"uint",stringLength,"ptr",textFormat.__,"float",maxWidth,"float",maxHeight,"ptr*",textLayout),"CreateTextLayout")
    return new IDWriteTextLayout(textLayout)
  }

  ; Takes a string, format, and associated constraints, and produces an object representing the result, formatted for a particular display resolution and measuring mode. 
  ; The resulting text layout should only be used for the intended resolution, and for cases where text scalability is desired CreateTextLayout should be used instead.
  CreateGdiCompatibleTextLayout(string,stringLength,textFormat,layoutWidth,layoutHeight,pixelsPerDip,transform,useGdiNatural){ ; IDWriteTextFormat , DWRITE_MATRIX
	_Error(DllCall(this.vt(19),"ptr",this.__,"str",string,"uint",stringLength,"ptr",textFormat.__,"float",layoutWidth,"float",layoutHeight,"float",pixelsPerDip,"ptr",transform,"int",useGdiNatural,"ptr*",textLayout),"CreateGdiCompatibleTextLayout")
    return new IDWriteTextLayout(textLayout)
  }

  ; Creates an inline object for trimming, using an ellipsis as the omission sign. 
  ; The ellipsis will be created using the current settings of the format, including base font, style, and any effects. Alternate omission signs can be created by the application by implementing IDWriteInlineObject. 
  CreateEllipsisTrimmingSign(textFormat){ ; IDWriteTextFormat
	_Error(DllCall(this.vt(20),"ptr",this.__,"ptr",textFormat,"ptr*",trimmingSign),"CreateEllipsisTrimmingSign")
    return new IDWriteInlineObject(trimmingSign)
  }

  ; Returns an interface for performing text analysis. 
  ; Example shows how a text analyzer object is created. http://msdn.microsoft.com/en-us/library/windows/desktop/dd368202%28v=vs.85%29.aspx
  CreateTextAnalyzer(){
	_Error(DllCall(this.vt(21),"ptr",this.__,"ptr*",textAnalyzer),"CreateTextAnalyzer")
    return new IDWriteTextAnalyzer(textAnalyzer)
  }

  ; Creates a number substitution object using a locale name, substitution method, and an indicator whether to ignore user overrides (use NLS defaults for the given culture instead). 
  ; Example shows how to create a number substitution for traditional Arabic Egyptian digits, which always display regardless of surrounding context. http://msdn.microsoft.com/en-us/library/windows/desktop/dd368200%28v=vs.85%29.aspx
  CreateNumberSubstitution(substitutionMethod,localeName,ignoreUserOverride){ ; DWRITE_NUMBER_SUBSTITUTION_METHOD
	_Error(DllCall(this.vt(22),"ptr",this.__,"int",substitutionMethod,"str",localeName,"int",ignoreUserOverride,"ptr*",numberSubstitution),"CreateNumberSubstitution")
    return new IDWriteNumberSubstitution(numberSubstitution)
  }

  ; Creates a glyph run analysis object, which encapsulates information used to render a glyph run. 
  ; The glyph run analysis object contains the results of analyzing the glyph run, including the positions of all the glyphs and references to all of the rasterized glyphs in the font cache. 
  ; Example shows how to create a glyph run analysis object. http://msdn.microsoft.com/en-us/library/windows/desktop/dd368198%28v=vs.85%29.aspx
  CreateGlyphRunAnalysis(glyphRun,pixelsPerDip,transform,renderingMode,measuringMode,baselineOriginX,baselineOriginY){ ; DWRITE_GLYPH_RUN , DWRITE_MATRIX , DWRITE_RENDERING_MODE , DWRITE_MEASURING_MODE
	_Error(DllCall(this.vt(23),"ptr",this.__,"ptr",glyphRun,"float",pixelsPerDip,"ptr",transform,"int",renderingMode,"int",measuringMode,"float",baselineOriginX,"float",baselineOriginY,"ptr*",glyphRunAnalysis),"CreateGlyphRunAnalysis")
    return new IDWriteGlyphRunAnalysis(glyphRunAnalysis)
  }
}

class IDWriteFontCollectionLoader extends IUnknown
{
  iid := "{cca920e4-52f0-492b-bfa8-29c72ee0a468}"

  ; Creates a font file enumerator object that encapsulates a collection of font files. The font system calls back to this interface to create a font collection. 
  CreateEnumeratorFromKey(factory,collectionKey,collectionKeySize){ ; IDWriteFactory
	_Error(DllCall(this.vt(3),"ptr",this.__,"ptr",factory.__,"ptr",collectionKey,"uint",collectionKeySize,"ptr*",fontFileEnumerator),"CreateEnumeratorFromKey")
    return new IDWriteFontFileEnumerator(fontFileEnumerator)
  }
}

class IDWriteFontFile extends IUnknown
{
  iid := "{739d886a-cef5-47dc-8769-1a8b41bebbb0}"

  ; Obtains the pointer to the reference key of a font file. The returned pointer is valid until the font file object is released. 
  GetReferenceKey(){
	_Error(DllCall(this.vt(3),"ptr",this.__,"ptr*",fontFileReferenceKey,"uint*",fontFileReferenceKeySize),"GetReferenceKey")
    return [fontFileReferenceKey,fontFileReferenceKeySize]
  }

  ; Obtains the file loader associated with a font file object. 
  GetLoader(){
	_Error(DllCall(this.vt(4),"ptr",this.__,"ptr*",fontFileLoader),"GetLoader")
    return new IDWriteFontFileLoader(fontFileLoader)
  }

  ; Analyzes a file and returns whether it represents a font, and whether the font type is supported by the font system. 
  ; Important  Certain font file types are recognized, but not supported by the font system. For example, the font system will recognize a file as a Type 1 font file but will not be able to construct a font face object from it. In such situations, Analyze will set isSupportedFontType output parameter to FALSE. 
  Analyze(){ ; DWRITE_FONT_FILE_TYPE , DWRITE_FONT_FACE_TYPE
	_Error(DllCall(this.vt(5),"ptr",this.__,"int*",isSupportedFontType,"int*",fontFileType,"int*",fontFaceType,"uint*",numberOfFaces),"Analyze")
    return [isSupportedFontType,fontFileType,fontFaceType,numberOfFaces]
  }
}

class IDWriteFontFileStream extends IUnknown
{
  iid := "{6d4865fe-0ab8-4d91-8f62-5dd6be34a3e0}"

  ; Reads a fragment from a font file. 
  ; Note that ReadFileFragment implementations must check whether the requested font file fragment is within the file bounds. Otherwise, an error should be returned from ReadFileFragment. 
  ; DirectWrite may invoke IDWriteFontFileStream methods on the same object from multiple threads simultaneously. Therefore, ReadFileFragment implementations that rely on internal mutable state must serialize access to such state across multiple threads. For example, an implementation that uses separate Seek and Read operations to read a file fragment must place the code block containing Seek and Read calls under a lock or a critical section.
  ReadFileFragment(,fileOffset,fragmentSize){
	_Error(DllCall(this.vt(3),"ptr",this.__,"ptr*",fragmentStart,"uint64",fileOffset,"uint64",fragmentSize,"ptr*",fragmentContext),"ReadFileFragment")
    return [fragmentStart,fragmentContext]
  }

  ; Releases a fragment from a file. 
  ReleaseFileFragment(fragmentContext){
	return _Error(DllCall(this.vt(4),"ptr",this.__,"ptr",fragmentContext),"ReleaseFileFragment")
  }

  ; Obtains the total size of a file. 
  ; Implementing GetFileSize() for asynchronously loaded font files may require downloading the complete file contents. Therefore, this method should be used only for operations that either require a complete font file to be loaded (for example, copying a font file) or that need to make decisions based on the value of the file size (for example, validation against a persisted file size). 
  GetFileSize(){
	_Error(DllCall(this.vt(5),"ptr",this.__,"uint64*",fileSize),"GetFileSize")
    return fileSize
  }

  ; Obtains the last modified time of the file. 
  ; The "last modified time" is used by DirectWrite font selection algorithms to determine whether one font resource is more up to date than another one.
  GetLastWriteTime(){
	_Error(DllCall(this.vt(6),"ptr",this.__,"uint64*",lastWriteTime),"GetLastWriteTime")
    return lastWriteTime ; the number of 100-nanosecond intervals since January 1, 1601 (UTC).
  }
}

class IDWriteFontFileEnumerator extends IUnknown
{
  iid := "{72755049-5ff7-435d-8348-4be97cfa6c7c}"

  ; Advances to the next font file in the collection. When it is first created, the enumerator is positioned before the first element of the collection and the first call to MoveNext advances to the first file. 
  MoveNext(){
	_Error(DllCall(this.vt(3),"ptr",this.__,"int*",hasCurrentFile),"MoveNext")
    return hasCurrentFile
  }

  ; Gets a reference to the current font file. 
  GetCurrentFontFile(){
	_Error(DllCall(this.vt(4),"ptr",this.__,"ptr*",fontFile),"GetCurrentFontFile")
    return new IDWriteFontFile(fontFile)
  }
}

class IDWriteFontFace extends IUnknown
{
  iid := "{5f49804d-7024-4d43-bfa9-d25984f53849}"

  ; Obtains the file format type of a font face. 
  GetType(){
	return DllCall(this.vt(3),"ptr",this.__,"int") ; http://msdn.microsoft.com/en-us/library/windows/desktop/dd368063(v=vs.85).aspx
  }

  ; Obtains the font files representing a font face. 
  ; The IDWriteFontFace::GetFiles method should be called twice. The first time you call GetFilesfontFiles should be NULL. When the method returns, numberOfFiles receives the number of font files that represent the font face.
  ; Then, call the method a second time, passing the numberOfFiles value that was output the first call, and a non-null buffer of the correct size to store the IDWriteFontFile pointers.
  GetFiles(){
	_Error(DllCall(this.vt(4),"ptr",this.__,"uint*",numberOfFiles,"ptr*",fontFiles),"GetFiles")
    return [numberOfFiles,new IDWriteFontFile(fontFiles)]
  }

  ; Obtains the index of a font face in the context of its font files. 
  GetIndex(){
	return DllCall(this.vt(5),"ptr",this.__,"uint")
  }

  ; Obtains the algorithmic style simulation flags of a font face. 
  GetSimulations(){ ; DWRITE_FONT_SIMULATIONS
	return DllCall(this.vt(6),"ptr",this.__,"int")
  }

  ; Determines whether the font is a symbol font. 
  IsSymbolFont(){
	return DllCall(this.vt(7),"ptr",this.__,"int")
  }

  ; Obtains design units and common metrics for the font face. These metrics are applicable to all the glyphs within a font face and are used by applications for layout calculations. 
  GetMetrics(){
	DllCall(this.vt(8),"ptr",this.__,"ptr*",fontFaceMetrics)
    return fontFaceMetrics ; DWRITE_FONT_METRICS
  }

  ; Obtains the number of glyphs in the font face. 
  GetGlyphCount(){
	return DllCall(this.vt(9),"ptr",this.__,"ushort")
  }

  ; Obtains ideal (resolution-independent) glyph metrics in font design units. 
  ; Design glyph metrics are used for glyph positioning.
  GetDesignGlyphMetrics(glyphIndices,glyphCount,Byref glyphMetrics,isSideways){ ; DWRITE_GLYPH_METRICS
	_Error(DllCall(this.vt(10),"ptr",this.__,"ptr",glyphIndices,"uint",glyphCount,"ptr",glyphMetrics,"uint",isSideways),"GetDesignGlyphMetrics")
    return ; not completed
  }

  ; Returns the nominal mapping of UCS4 Unicode code points to glyph indices as defined by the font 'CMAP' table. 
  ; Note that this mapping is primarily provided for line layout engines built on top of the physical font API. Because of OpenType glyph substitution and line layout character substitution, the nominal conversion does not always correspond to how a Unicode string will map to glyph indices when rendering using a particular font face. Also, note that Unicode variant selectors provide for alternate mappings for character to glyph. This call will always return the default variant.
  ; When characters are not present in the font this method returns the index 0, which is the undefined glyph or ".notdef" glyph. If a character isn't in a font, IDWriteFont::HasCharacter returns false and GetUnicodeRanges doesn't return it in the range.
  GetGlyphIndices(codePoints,codePointCount,Byref glyphIndices){
	_Error(DllCall(this.vt(11),"ptr",this.__,"ptr",codePoints,"uint",codePointCount,"ptr*",glyphIndices),"GetGlyphIndices")
    return ; not completed
  }

  ; Finds the specified OpenType font table if it exists and returns a pointer to it. The function accesses the underlying font data through the IDWriteFontFileStream interface implemented by the font file loader. 
  ; The context for the same tag may be different for each call, so each one must be held and released separately. 
  TryGetFontTable(openTypeTableTag,tableData,Byref tableSize,Byref tableContext,Byref exists){
	_Error(DllCall(this.vt(12),"ptr",this.__,"uint",openTypeTableTag,"ptr",tableData,"uint*",tableSize,"ptr*",tableContext,"ptr*",exists),"TryGetFontTable")
    return ; not completed
  }

  ; Releases the table obtained earlier from TryGetFontTable. 
  ReleaseFontTable(tableContext){ ; A pointer to the opaque context from 
	return _Error(DllCall(this.vt(13),"ptr",this.__,"ptr",tableContext),"ReleaseFontTable") ; not completed
  }

  ; Computes the outline of a run of glyphs by calling back to the outline sink interface. 
  GetGlyphRunOutline(emSize,glyphIndices,glyphAdvances,glyphOffsets,glyphCount,isSideways,isRightToLeft,Byref geometrySink){
	_Error(DllCall(this.vt(14),"ptr",this.__,"float",emSize,"ptr",glyphIndices,"ptr",glyphAdvances,"ptr",glyphOffsets,"uint",glyphCount,"uint",isSideways,"uint",isRightToLeft,"ptr*",geometrySink),"GetGlyphRunOutline")
    return ; not completed
  }

  ; Determines the recommended rendering mode for the font, using the specified size and rendering parameters. 
  GetRecommendedRenderingMode(emSize,pixelsPerDip,measuringMode,renderingParams,Byref renderingMode){
	_Error(DllCall(this.vt(15),"ptr",this.__,"float",emSize,"float",pixelsPerDip,"uint",measuringMode,"ptr",renderingParams,"uint*",renderingMode),"GetRecommendedRenderingMode")
    return ; not completed
  }

  ; Obtains design units and common metrics for the font face. These metrics are applicable to all the glyphs within a fontface and are used by applications for layout calculations.
  GetGdiCompatibleMetrics(emSize,pixelsPerDip,transform,fontFaceMetrics=0){ ; DWRITE_MATRIX
	return _Error(DllCall(this.vt(16),"ptr",this.__,"float",emSize,"float",pixelsPerDip,"ptr",transform,"ptr",fontFaceMetrics),"GetGdiCompatibleMetrics") ; not completed
  }

  ; Obtains glyph metrics in font design units with the return values compatible with what GDI would produce.
  GetGdiCompatibleGlyphMetrics(emSize,pixelsPerDip,transform,useGdiNatural,glyphIndices,glyphCount,glyphMetrics,isSideways){ ; DWRITE_MATRIX
	return _Error(DllCall(this.vt(17),"ptr",this.__,"float",emSize,"float",pixelsPerDip,"ptr",transform,"int",useGdiNatural,"ptr",glyphIndices,"uint",glyphCount,"ptr",glyphMetrics,"int",isSideways),"GetGdiCompatibleGlyphMetrics") ; not completed
  }
}

class IDWriteRenderingParams extends IUnknown
{
  iid := "{2f0da53a-2add-47cd-82ee-d9ec34688e75}"

  ; Gets the gamma value used for gamma correction. Valid values must be greater than zero and cannot exceed 256.
  ; The gamma value is used for gamma correction, which compensates for the non-linear luminosity response of most monitors.
  GetGamma(){
	return DllCall(this.vt(3),"ptr",this.__,"float")
  }

  ; Gets the enhanced contrast property of the rendering parameters object. Valid values are greater than or equal to zero.
  ; Enhanced contrast is the amount to increase the darkness of text, and typically ranges from 0 to 1. Zero means no contrast enhancement.
  GetEnhancedContrast(){
	return DllCall(this.vt(4),"ptr",this.__,"float")
  }

  ; Gets the ClearType level of the rendering parameters object. 
  ; The ClearType level represents the amount of ClearType – that is, the degree to which the red, green, and blue subpixels of each pixel are treated differently. Valid values range from zero (meaning no ClearType, which is equivalent to grayscale anti-aliasing) to one (meaning full ClearType)
  GetClearTypeLevel(){
	return DllCall(this.vt(5),"ptr",this.__,"float")
  }

  ; Gets the pixel geometry of the rendering parameters object.
  GetPixelGeometry(){
	return DllCall(this.vt(6),"ptr",this.__,"int") ; DWRITE_PIXEL_GEOMETRY
  }

  ; Gets the rendering mode of the rendering parameters object.
  ; By default, the rendering mode is initialized to DWRITE_RENDERING_MODE_DEFAULT, which means the rendering mode is determined automatically based on the font and size. To determine the recommended rendering mode to use for a given font and size and rendering parameters object, use the IDWriteFontFace::GetRecommendedRenderingMode method.
  GetRenderingMode(){
	return DllCall(this.vt(7),"ptr",this.__) ; DWRITE_RENDERING_MODE
  }
}

class IDWriteFontCollection extends IUnknown
{
  iid := "{a84cee02-3eea-4eee-a827-87c1a02a0fcc}"

  ; Gets the number of font families in the collection. 
  GetFontFamilyCount(){
	return DllCall(this.vt(3),"ptr",this.__,"uint")
  }

  ; Creates a font family object given a zero-based font family index. 
  GetFontFamily(index){
	_Error(DllCall(this.vt(4),"ptr",this.__,"uint",index,"ptr*",FontFamily),"GetFontFamily")
    return new IDWriteFontFamily(FontFamily)
  }

  ; Finds the font family with the specified family name. 
  FindFamilyName(familyName){
	_Error(DllCall(this.vt(5),"ptr",this.__,"str",familyName,"uint*",index,"int*",exists),"FindFamilyName")
    return [index,exists]
  }

  ; Gets the font object that corresponds to the same physical font as the specified font face object. The specified physical font must belong to the font collection. 
  GetFontFromFontFace(fontFace){ ; IDWriteFontFace
	_Error(DllCall(this.vt(6),"ptr",this.__,"ptr",fontFace.__,"ptr*",font),"GetFontFromFontFace")
    return new IDWriteFont(font)
  }
}

class IDWriteFontFileLoader extends IUnknown
{
  iid := "{727cad4e-d6af-4c9e-8a08-d695b11caa49}"

  ; Creates a font file stream object that encapsulates an open file resource. 
  ; The resource is closed when the last reference to 
  CreateStreamFromKey(fontFileReferenceKey,fontFileReferenceKeySize){
	_Error(DllCall(this.vt(3),"ptr",this.__,"ptr",fontFileReferenceKey,"uint",fontFileReferenceKeySize,"ptr*",fontFileStream),"CreateStreamFromKey")
    return new IDWriteFontFileStream(fontFileStream)
  }
}
class IDWriteLocalFontFileLoader extends IDWriteFontFileLoader
{
  iid := "{b2d9f3ec-c9fe-4a11-a2ec-d86208f7c0a2}"

  ; Obtains the length of the absolute file path from the font file reference key.
  GetFilePathLengthFromKey(fontFileReferenceKey,fontFileReferenceKeySize){
	_Error(DllCall(this.vt(4),"ptr",this.__,"ptr",fontFileReferenceKey,"uint",fontFileReferenceKeySize,"uint*",filePathLength),"GetFilePathLengthFromKey")
    return filePathLength
  }

  ; Obtains the absolute font file path from the font file reference key.
  GetFilePathFromKey(fontFileReferenceKey,fontFileReferenceKeySize){
    VarSetCapacity(filePath,filePathSize:=1024)
	_Error(DllCall(this.vt(5),"ptr",this.__,"ptr",fontFileReferenceKey,"uint",fontFileReferenceKeySize,"ptr",&filePath,"uint",filePathSize),"GetFilePathFromKey")
    return StrGet(&filepath,"utf-16")
  }

  ; Obtains the last write time of the file from the font file reference key.
  GetLastWriteTimeFromKey(fontFileReferenceKey,fontFileReferenceKeySize,ByRef lastWriteTime){
	return _Error(DllCall(this.vt(6),"ptr",this.__,"ptr",fontFileReferenceKey,"uint",fontFileReferenceKeySize,"ptr",lastWriteTime),"GetLastWriteTimeFromKey")
  }
}

class IDWriteTextFormat extends IUnknown
{
  iid := "{9c906818-31d7-4fd3-a151-7c5e225db55a}"

  ; Sets the alignment of text in a paragraph, relative to the leading and trailing edge of a layout box for a IDWriteTextFormat interface.
  ; The text can be aligned to the leading or trailing edge of the layout box, or it can be centered. The following illustration shows text with the alignment set to DWRITE_TEXT_ALIGNMENT_LEADING, DWRITE_TEXT_ALIGNMENT_CENTER, and DWRITE_TEXT_ALIGNMENT_TRAILING, respectively. 
  ; Note  The alignment is dependent on reading direction, the above is for left-to-right reading direction. For right-to-left reading direction it would be the opposite.
  SetTextAlignment(textAlignment){ ; DWRITE_TEXT_ALIGNMENT
	return _Error(DllCall(this.vt(3),"ptr",this.__,"int",textAlignment),"SetTextAlignment")
  }

  ; Sets the alignment option of a paragraph relative to the layout box's top and bottom edge. 
  SetParagraphAlignment(paragraphAlignment){ ; DWRITE_PARAGRAPH_ALIGNMENT
	return _Error(DllCall(this.vt(4),"ptr",this.__,"int",paragraphAlignment),"SetParagraphAlignment")
  }

  ; Sets the word wrapping option. 
  SetWordWrapping(wordWrapping){ ; DWRITE_WORD_WRAPPING
	return _Error(DllCall(this.vt(5),"ptr",this.__,"int",wordWrapping),"SetWordWrapping")
  }

  ; Sets the paragraph reading direction. 
  SetReadingDirection(readingDirection){ ; DWRITE_READING_DIRECTION
	return _Error(DllCall(this.vt(6),"ptr",this.__,"int",readingDirection),"SetReadingDirection")
  }

  ; Sets the paragraph flow direction. 
  SetFlowDirection(flowDirection){ ; DWRITE_FLOW_DIRECTION
	return _Error(DllCall(this.vt(7),"ptr",this.__,"int",flowDirection),"SetFlowDirection")
  }

  ; Sets a fixed distance between two adjacent tab stops. 
  SetIncrementalTabStop(incrementalTabStop){
	return _Error(DllCall(this.vt(8),"ptr",this.__,"float",incrementalTabStop),"SetIncrementalTabStop")
  }

  ; Sets trimming options for text overflowing the layout width. 
  SetTrimming(trimmingOptions,trimmingSign){ ; DWRITE_TRIMMING , IDWriteInlineObject
	_Error(DllCall(this.vt(9),"ptr",this.__,"ptr",trimmingOptions,"ptr",trimmingSign.__),"SetTrimming")
    return 
  }

  ; Sets the line spacing. For the default method, spacing depends solely on the content. For uniform spacing, the specified line height overrides the content. 
  SetLineSpacing(lineSpacingMethod,lineSpacing,baseline){ ; DWRITE_LINE_SPACING_METHOD
	return _Error(DllCall(this.vt(10),"ptr",this.__,"int",lineSpacingMethod,"float",lineSpacing,"float",baseline),"SetLineSpacing")
  }

  ; Gets the alignment option of text relative to the layout box's leading and trailing edge. 
  GetTextAlignment(){
	return DllCall(this.vt(11),"ptr",this.__,"int") ; DWRITE_TEXT_ALIGNMENT
  }

  ; Gets the alignment option of a paragraph which is relative to the top and bottom edges of a layout box. 
  GetParagraphAlignment(){
	return DllCall(this.vt(12),"ptr",this.__,"int") ; DWRITE_PARAGRAPH_ALIGNMENT
  }

  ; Gets the word wrapping option. 
  GetWordWrapping(){
	return DllCall(this.vt(13),"ptr",this.__,"int") ; DWRITE_WORD_WRAPPING
  }

  ; Gets the current reading direction for text in a paragraph. 
  GetReadingDirection(){
	return DllCall(this.vt(14),"ptr",this.__) ; DWRITE_READING_DIRECTION
  }

  ; Gets the direction that text lines flow. 
  GetFlowDirection(){
	return DllCall(this.vt(15),"ptr",this.__) ; DWRITE_FLOW_DIRECTION
  }

  ; Gets the incremental tab stop position. 
  GetIncrementalTabStop(){
	return DllCall(this.vt(16),"ptr",this.__,"float")
  }

  ; Gets the trimming options for text that overflows the layout box. 
  GetTrimming(ByRef trimmingOptions){
	DllCall(this.vt(17),"ptr",this.__,"ptr",trimmingOptions,"ptr*",trimmingSign)
    return new IDWriteInlineObject(trimmingSign) ; not completed
  }

  ; Gets the line spacing adjustment set for a multiline text paragraph. 
  GetLineSpacing(){
	_Error(DllCall(this.vt(18),"ptr",this.__,"int*",lineSpacingMethod,"float*",lineSpacing,"float*",baseline),"GetLineSpacing")
    return [lineSpacingMethod,lineSpacing,baseline] ; DWRITE_LINE_SPACING_METHOD
  }

  ; Gets the current font collection. 
  GetFontCollection(){
	_Error(DllCall(this.vt(19),"ptr",this.__,"ptr*",fontCollection),"GetFontCollection")
    return new IDWriteFontCollection(fontCollection)
  }

  ; Gets the length of the font family name. 
  GetFontFamilyNameLength(){
	return DllCall(this.vt(20),"ptr",this.__,"uint")
  }

  ; Gets a copy of the font family name. 
  GetFontFamilyName(){
    VarSetCapacity(fontFamilyName,nameSize:=1024)
	DllCall(this.vt(21),"ptr",this.__,"ptr",&fontFamilyName,"uint",nameSize)
    return StrGet(&fontFamilyName,"utf-16")
  }

  ; Gets the font weight of the text. 
  GetFontWeight(){
	return DllCall(this.vt(22),"ptr",this.__,"int") ; DWRITE_FONT_WEIGHT
  }

  ; Gets the font style of the text.
  GetFontStyle(){
	return DllCall(this.vt(23),"ptr",this.__,"int") ; DWRITE_FONT_STYLE
  }

  ; Gets the font stretch of the text. 
  GetFontStretch(){
	return DllCall(this.vt(24),"ptr",this.__,"int") ; DWRITE_FONT_STRETCH
  }

  ; Gets the font size in DIP unites. 
  GetFontSize(){
	return DllCall(this.vt(25),"ptr",this.__,"float")
  }

  ; Gets the length of the locale name. 
  GetLocaleNameLength(){
	return DllCall(this.vt(26),"ptr",this.__,"uint")
  }

  ; Gets a copy of the locale name. 
  GetLocaleName(){
    VarSetCapacity(localeName,nameSize:=1024)
	DllCall(this.vt(27),"ptr",this.__,"ptr",&localeName,"uint",nameSize)
    return StrGet(&localeName,"utf-16")
  }
}

class IDWriteTypography extends IUnknown
{
  iid := "{55f1112b-1dc2-4b3c-9541-f46894ed85b6}"

  ; Adds an OpenType font feature. 
  AddFontFeature(nameTag,parameter){ ; DWRITE_FONT_FEATURE_TAG
	return _Error(DllCall(this.vt(3),"ptr",this.__,"int",nameTag,"uint",parameter),"AddFontFeature")
  }

  ; Gets the number of OpenType font features for the current font. 
  ; A single run of text can be associated with more than one typographic feature. The IDWriteTypography object holds a list of these font features.
  GetFontFeatureCount(){
	return _Error(DllCall(this.vt(4),"ptr",this.__,"uint"),"GetFontFeatureCount")
  }

  ; Gets the font feature at the specified index. 
  GetFontFeature(fontFeatureIndex){
	_Error(DllCall(this.vt(5),"ptr",this.__,"uint",fontFeatureIndex,"ptr*",fontFeature),"GetFontFeature")
    return fontFeature ; DWRITE_FONT_FEATURE not completed
  }
}

class IDWriteGdiInterop extends IUnknown
{
  iid := "{1edd9491-9853-4299-898f-6432983b6f3a}"

  ;  Creates a font object that matches the properties specified by the LOGFONT structure. 
  CreateFontFromLOGFONT(logFont){ ; LOGFONTW*
	_Error(DllCall(this.vt(3),"ptr",this.__,"ptr",logFont,"ptr*",font),"CreateFontFromLOGFONT")
    return new IDWriteFont(font) ; not completed
  }

  ; Initializes a LOGFONT structure based on the GDI-compatible properties of the specified font. 
  ConvertFontToLOGFONT(font){ ; IDWriteFont
	_Error(DllCall(this.vt(4),"ptr",this.__,"ptr",font.__,"ptr",logFont,"int*",isSystemFont),"ConvertFontToLOGFONT")
    return [logFont,isSystemFont] ; LOGFONTW* not completed
  }

  ; Initializes a LOGFONT structure based on the GDI-compatible properties of the specified font. 
  ConvertFontFaceToLOGFONT(font){ ; IDWriteFontFace
	_Error(DllCall(this.vt(5),"ptr",this.__,"ptr",font,"ptr",logFont),"ConvertFontFaceToLOGFONT")
    return logFont ; not completed
  }

  ; Creates an IDWriteFontFace object that corresponds to the currently selected HFONT of the specified HDC. 
  ; This function is intended for scenarios in which an application wants to use GDI and Uniscribe 1.x for text layout and shaping, but DirectWrite for final rendering. This function assumes the client is performing text output using glyph indexes.
  CreateFontFaceFromHdc(hdc){ ; HDC
	_Error(DllCall(this.vt(6),"ptr",this.__,"ptr",hdc,"ptr*",fontFace),"CreateFontFaceFromHdc")
    return new IDWriteFontFace(fontFace)
  }

  ; Creates an object that encapsulates a bitmap and memory DC (device context) which can be used for rendering glyphs. 
  CreateBitmapRenderTarget(hdc,width,height){
	_Error(DllCall(this.vt(7),"ptr",this.__,"uint",hdc,"uint",width,"uint",height,"ptr*",renderTarget),"CreateBitmapRenderTarget")
    return new IDWriteBitmapRenderTarget(renderTarget)
  }
}

class IDWriteTextLayout extends IDWriteTextFormat
{
  iid := "{53737037-6d14-410b-9bfe-0b182bb70961}"

  ; Sets the layout maximum width.
  SetMaxWidth(maxWidth){
	return _Error(DllCall(this.vt(28),"ptr",this.__,"float",maxWidth),"SetMaxWidth")
  }

  ; Sets the layout maximum height. 
  SetMaxHeight(maxHeight){
	return _Error(DllCall(this.vt(29),"ptr",this.__,"float",maxHeight),"SetMaxHeight")
  }

  ; Sets the font collection. 
  SetFontCollection(fontCollection,startPosition,length){ ; IDWriteFontCollection , DWRITE_TEXT_RANGE
	return _Error(DllCall(this.vt(30),"ptr",this.__,"ptr",fontCollection.__,"uint",startPosition,"uint",length),"SetFontCollection") 
  }

  ; Sets null-terminated font family name for text within a specified text range. 
  SetFontFamilyName(fontFamilyName,startPosition,length){ ; DWRITE_TEXT_RANGE
	return _Error(DllCall(this.vt(31),"ptr",this.__,"str",fontFamilyName,"uint",startPosition,"uint",length),"SetFontFamilyName")
  }

  ; Sets the font weight for text within a text range specified by a DWRITE_TEXT_RANGE structure. 
  ; The font weight can be set to one of the predefined font weight values provided in the DWRITE_FONT_WEIGHT enumeration or an integer from 1 to 999. Values outside this range will cause the method to fail with an E_INVALIDARG return value.
  SetFontWeight(fontWeight,startPosition,length){ ; DWRITE_FONT_WEIGHT , DWRITE_TEXT_RANGE
	return _Error(DllCall(this.vt(32),"ptr",this.__,"uint",fontWeight,"uint",startPosition,"uint",length),"SetFontWeight")
  }

  ; Sets the font style for text within a text range specified by a DWRITE_TEXT_RANGE structure.
  SetFontStyle(fontStyle,startPosition,length){ ; DWRITE_FONT_STYLE , DWRITE_TEXT_RANGE
	return _Error(DllCall(this.vt(33),"ptr",this.__,"int",fontStyle,"uint",startPosition,"uint",length),"SetFontStyle")
  }

  ; Sets the font stretch for text within a specified text range. 
  SetFontStretch(fontStretch,startPosition,length){ ; DWRITE_FONT_STRETCH , DWRITE_TEXT_RANGE
	return _Error(DllCall(this.vt(34),"ptr",this.__,"int",fontStretch,"uint",startPosition,"uint",length),"SetFontStretch")
  }

  ; Sets the font size in DIP units for text within a specified text range. 
  SetFontSize(fontSize,startPosition,length){ ; DWRITE_TEXT_RANGE
	return _Error(DllCall(this.vt(35),"ptr",this.__,"float",fontSize,"uint",startPosition,"uint",length),"SetFontSize")
  }

  ; Sets underlining for text within a specified text range. 
  SetUnderline(hasUnderline,startPosition,length){ ; DWRITE_TEXT_RANGE
	return _Error(DllCall(this.vt(36),"ptr",this.__,"int",hasUnderline,"uint",startPosition,"uint",length),"SetUnderline")
  }

  ; Sets strikethrough for text within a specified text range. 
  SetStrikethrough(hasStrikethrough,startPosition,length){ ; DWRITE_TEXT_RANGE
	return _Error(DllCall(this.vt(37),"ptr",this.__,"int",hasStrikethrough,"uint",startPosition,"uint",length),"SetStrikethrough")
  }

  ; Sets the application-defined drawing effect. 
  ; An ID2D1Brush, such as a color or gradient brush, can be set as a drawing effect if you are using the ID2D1RenderTarget::DrawTextLayout to draw text and that brush will be used to draw the specified range of text.
  ; This drawing effect is associated with the specified range and will be passed back to the application by way of the callback when the range is drawn at drawing time. 
  SetDrawingEffect(drawingEffect,startPosition,length){ ; IUnknown* , DWRITE_TEXT_RANGE
	return _Error(DllCall(this.vt(38),"ptr",this.__,"ptr",drawingEffect,"uint",startPosition,"uint",length),"SetDrawingEffect")
  }

  ; Sets the inline object. 
  SetInlineObject(inlineObject,startPosition,length){ ; IDWriteInlineObject , DWRITE_TEXT_RANGE
	return _Error(DllCall(this.vt(39),"ptr",this.__,"ptr",inlineObject.__,"uint",startPosition,"uint",length),"SetInlineObject")
  }

  ; Sets font typography features for text within a specified text range. 
  SetTypography(typography,startPosition,length){ ; IDWriteTypography , DWRITE_TEXT_RANGE
	return _Error(DllCall(this.vt(40),"ptr",this.__,"ptr",typography.__,"uint",startPosition,"uint",length),"SetTypography")
  }

  ; Sets the locale name for text within a specified text range.
  SetLocaleName(localeName,startPosition,length){
	return _Error(DllCall(this.vt(41),"ptr",this.__,"str",localeName,"uint",startPosition,"uint",length),"SetLocaleName")
  }

  ; Gets the layout maximum width. 
  GetMaxWidth(){
	return DllCall(this.vt(42),"ptr",this.__,"float")
  }

  ; Gets the layout maximum height. 
  GetMaxHeight(){
	return DllCall(this.vt(43),"ptr",this.__,"float")
  }

  ; Gets the font collection associated with the text at the specified position. 
  GetFontCollection(currentPosition){
	_Error(DllCall(this.vt(44),"ptr",this.__,"uint",currentPosition,"ptr*",fontCollection,"uint*",startPosition,"uint*",length),"GetFontCollection")
    return [new IDWriteFontCollection(fontCollection),startPosition,length]
  }

  ; Get the length of the font family name at the current position. 
  GetFontFamilyNameLength(currentPosition,nameLength){
	_Error(DllCall(this.vt(45),"ptr",this.__,"uint",currentPosition,"uint",nameLength,"uint*",startPosition,"uint*",length),"GetFontFamilyNameLength")
    return [startPosition,length]
  }

  ; Copies the font family name of the text at the specified position. 
  GetFontFamilyName(currentPosition,nameSize){
    VarSetCapacity(fontFamilyName,nameSize:=1024)
	_Error(DllCall(this.vt(46),"ptr",this.__,"uint",currentPosition,"ptr",&fontFamilyName,"uint",nameSize,"uint*",startPosition,"uint*",length),"GetFontFamilyName")
    return [StrGet(&fontFamilyName,"utf-16"),startPosition,length]
  }

  ; Gets the font weight of the text at the specified position. 
  GetFontWeight(currentPosition){
	_Error(DllCall(this.vt(47),"ptr",this.__,"uint",currentPosition,"int*",fontWeight,"uint*",startPosition,"uint*",length),"GetFontWeight")
    return [fontWeight,startPosition,length] ; DWRITE_FONT_WEIGHT
  }

  ; Gets the font style (also known as slope) of the text at the specified position. 
  GetFontStyle(currentPosition){
	_Error(DllCall(this.vt(48),"ptr",this.__,"uint",currentPosition,"uint*",fontStyle,"uint*",startPosition,"uint*",length),"GetFontStyle")
    return [fontStyle,startPosition,length] ; DWRITE_FONT_STYLE
  }

  ; Gets the font stretch of the text at the specified position. 
  GetFontStretch(currentPosition){
	_Error(DllCall(this.vt(49),"ptr",this.__,"uint",currentPosition,"int*",fontStretch,"uint*",startPosition,"uint*",length),"GetFontStretch")
    return [fontStretch,startPosition,length] ; DWRITE_FONT_STRETCH
  }

  ; Gets the font em height of the text at the specified position. 
  GetFontSize(currentPosition){
	_Error(DllCall(this.vt(50),"ptr",this.__,"uint",currentPosition,"float*",fontSize,"uint*",startPosition,"uint*",length),"GetFontSize")
    return [fontSize,startPosition,length]
  }

  ; Gets the underline presence of the text at the specified position. 
  GetUnderline(currentPosition){
	_Error(DllCall(this.vt(51),"ptr",this.__,"uint",currentPosition,"int*",hasUnderline,"uint*",startPosition,"uint*",length),"GetUnderline")
    return [hasUnderline,startPosition,length]
  }

  ; Get the strikethrough presence of the text at the specified position. 
  GetStrikethrough(currentPosition){
	_Error(DllCall(this.vt(52),"ptr",this.__,"uint",currentPosition,"int*",hasStrikethrough,"uint*",startPosition,"uint*",length),"GetStrikethrough")
    return [hasStrikethrough,startPosition,length]
  }

  ; Gets the application-defined drawing effect at the specified text position. 
  GetDrawingEffect(currentPosition){
	_Error(DllCall(this.vt(53),"ptr",this.__,"uint",currentPosition,"ptr*",drawingEffect,"uint*",startPosition,"uint*",length),"GetDrawingEffect")
    return [drawingEffect,startPosition,length] ; IUnknown**
  }

  ; Gets the inline object at the specified position. 
  GetInlineObject(currentPosition){
	_Error(DllCall(this.vt(54),"ptr",this.__,"uint",currentPosition,"ptr*",inlineObject,"uint*",startPosition,"uint*",length),"GetInlineObject")
    return [new IDWriteInlineObject(inlineObject),startPosition,length]
  }

  ; Gets the typography setting of the text at the specified position. 
  GetTypography(currentPosition){
	_Error(DllCall(this.vt(55),"ptr",this.__,"uint",currentPosition,"ptr*",typography,"uint*",startPosition,"uint*",length),"GetTypography")
    return [new IDWriteTypography(typography),startPosition,length]
  }

  ; Gets the length of the locale name of the text at the specified position. 
  GetLocaleNameLength(currentPosition){
	_Error(DllCall(this.vt(56),"ptr",this.__,"uint",currentPosition,"uint*",nameLength,"uint*",startPosition,"uint*",length),"GetLocaleNameLength")
    return [nameLength,startPosition,length]
  }

  ; Gets the locale name of the text at the specified position. 
  GetLocaleName(currentPosition){
    VarSetCapacity(localeName,nameSize:=1024)
	_Error(DllCall(this.vt(57),"ptr",this.__,"uint",currentPosition,"ptr",&localeName,"uint",nameSize,"uint*",startPosition,"uint*",length),"GetLocaleName")
    return [StrGet(&localeName,"utf-16"),startPosition,length]
  }

  ; Draws text using the specified client drawing context.
  ; To draw text with this method, a textLayout object needs to be created by the application using IDWriteFactory::CreateTextLayout. 
  ; After the textLayout object is obtained, the application calls the IDWriteTextLayout::Draw method to draw the text, decorations, and inline objects. The actual drawing is done through the callback interface passed in as the textRenderer argument; there, the corresponding DrawGlyphRun API is called. 
  Draw(clientDrawingContext,renderer,originX,originY){
	return _Error(DllCall(this.vt(58),"ptr",this.__,"ptr",clientDrawingContext.__,"ptr",renderer.__,"float",originX,"float",originY),"Draw")
  }

  ; Retrieves the information about each individual text line of the text string. 
  ; If maxLineCount is not large enough E_NOT_SUFFICIENT_BUFFER, which is equivalent to HRESULT_FROM_WIN32(ERROR_INSUFFICIENT_BUFFER), is returned and *actualLineCount is set to the number of lines needed. 
  GetLineMetrics(lineMetrics,maxLineCount){ ; DWRITE_LINE_METRICS
	_Error(DllCall(this.vt(59),"ptr",this.__,"ptr",lineMetrics,"uint",maxLineCount,"uint*",actualLineCount),"GetLineMetrics")
    return actualLineCount ; not completed
  }

  ; Retrieves overall metrics for the formatted string. 
  GetMetrics(textMetrics){ ; DWRITE_TEXT_METRICS
	return _Error(DllCall(this.vt(60),"ptr",this.__,"ptr",textMetrics),"GetMetrics") ; not completed
  }

  ; Returns the overhangs (in DIPs) of the layout and all objects contained in it, including text glyphs and inline objects.
  ; Underlines and strikethroughs do not contribute to the black box determination, since these are actually drawn by the renderer, which is allowed to draw them in any variety of styles.
  GetOverhangMetrics(){
	_Error(DllCall(this.vt(61),"ptr",this.__,"ptr*",overhangs),"GetOverhangMetrics")
    return overhangs ; DWRITE_OVERHANG_METRICS
  }

  ; Retrieves logical properties and measurements of each glyph cluster. 
  ; If maxClusterCount is not large enough, then E_NOT_SUFFICIENT_BUFFER, which is equivalent to HRESULT_FROM_WIN32(ERROR_INSUFFICIENT_BUFFER), is returned and actualClusterCount is set to the number of clusters needed. 
  GetClusterMetrics(clusterMetrics,maxClusterCount){
	_Error(DllCall(this.vt(62),"ptr",this.__,"ptr",clusterMetrics,"uint",maxClusterCount,"uint*",actualClusterCount),"GetClusterMetrics")
    return actualClusterCount ; not completed
  }

  ; Determines the minimum possible width the layout can be set to without emergency breaking between the characters of whole words occurring.
  DetermineMinWidth(){
	_Error(DllCall(this.vt(63),"ptr",this.__,"float*",minWidth),"DetermineMinWidth")
    return minWidth
  }

  ; The application calls this function passing in a specific pixel location relative to the top-left location of the layout box and obtains the information about the correspondent hit-test metrics of the text string where the hit-test has occurred. When the specified pixel location is outside the text string, the function sets the output value *isInside to FALSE. 
  HitTestPoint(pointX,pointY){
	_Error(DllCall(this.vt(64),"ptr",this.__,"float",pointX,"float",pointY,"int*",isTrailingHit,"int*",isInside,"ptr",hitTestMetrics),"HitTestPoint")
    return [isTrailingHit,isInside,hitTestMetrics] ; not completed
  }

  ; The application calls this function to get the pixel location relative to the top-left of the layout box given the text position and the logical side of the position. This function is normally used as part of caret positioning of text where the caret is drawn at the location corresponding to the current text editing position. It may also be used as a way to programmatically obtain the geometry of a particular text position in UI automation. 
  HitTestTextPosition(textPosition,isTrailingHit){
	_Error(DllCall(this.vt(65),"ptr",this.__,"uint",textPosition,"int",isTrailingHit,"float*",pointX,"float*",pointY,"ptr",hitTestMetrics),"HitTestTextPosition")
    return [pointX,pointY,hitTestMetrics]
  }

  ; The application calls this function to get a set of hit-test metrics corresponding to a range of text positions. One of the main usages is to implement highlight selection of the text string. The function returns E_NOT_SUFFICIENT_BUFFER, which is equivalent to HRESULT_FROM_WIN32(ERROR_INSUFFICIENT_BUFFER), when the buffer size of hitTestMetrics is too small to hold all the regions calculated by the function. In this situation, the function sets the output value *actualHitTestMetricsCount to the number of geometries calculated. The application is responsible for allocating a new buffer of greater size and calling the function again. A good value to use as an initial value for maxHitTestMetricsCount may be calculated from the following equation: maxHitTestMetricsCount = lineCount * maxBidiReorderingDepth where lineCount is obtained from the value of the output argument *actualLineCount (from the function IDWriteTextLayout::GetLineLengths), and the maxBidiReorderingDepth value from the DWRITE_TEXT_METRICS structure of the output argument *textMetrics (from the function IDWriteFactory::CreateTextLayout). 
  HitTestTextRange(textPosition,textLength,originX,originY,maxHitTestMetricsCount){
	_Error(DllCall(this.vt(66),"ptr",this.__,"uint",textPosition,"uint",textLength,"float",originX,"float",originY,"ptr",hitTestMetrics,"ptr",maxHitTestMetricsCount,"uint*",actualHitTestMetricsCount),"HitTestTextRange")
    return [hitTestMetrics,actualHitTestMetricsCount] ; not completed
  }
}

class IDWriteTextAnalyzer extends IUnknown
{
  iid := "{b7e6163e-7f46-43b4-84b3-e4e6249c365d}"

  ; Analyzes a text range for script boundaries, reading text attributes from the source and reporting the Unicode script ID to the sink callback SetScript. 
  AnalyzeScript(analysisSource,textPosition,textLength,analysisSink){ ; IDWriteTextAnalysisSource , IDWriteTextAnalysisSink
	return _Error(DllCall(this.vt(3),"ptr",this.__,"ptr",analysisSource.__,"uint",textPosition,"uint",textLength,"ptr",analysisSink.__),"AnalyzeScript")
  }

  ; Analyzes a text range for script directionality, reading attributes from the source and reporting levels to the sink callback SetBidiLevel. 
  AnalyzeBidi(analysisSource,textPosition,textLength,analysisSink){ ; IDWriteTextAnalysisSource , IDWriteTextAnalysisSink
	return _Error(DllCall(this.vt(4),"ptr",this.__,"ptr",analysisSource.__,"uint",textPosition,"uint",textLength,"ptr",analysisSink.__),"AnalyzeBidi")
  }

  ; Analyzes a text range for spans where number substitution is applicable, reading attributes from the source and reporting substitutable ranges to the sink callback SetNumberSubstitution. 
  ; Although the function can handle multiple ranges of differing number substitutions, the text ranges should not arbitrarily split the middle of numbers. Otherwise, it will treat the numbers separately and will not translate any intervening punctuation. 
  AnalyzeNumberSubstitution(analysisSource,textPosition,textLength,analysisSink){
	return _Error(DllCall(this.vt(5),"ptr",this.__,"analysisSource",analysisSource.__,"textPosition",textPosition,"textLength",textLength,"analysisSink",analysisSink.__),"AnalyzeNumberSubstitution")
  }

  ; Analyzes a text range for potential breakpoint opportunities, reading attributes from the source and reporting breakpoint opportunities to the sink callback SetLineBreakpoints. 
  ; Although the function can handle multiple paragraphs, the text range should not arbitrarily split the middle of paragraphs, unless the specified text span is considered a whole unit. Otherwise, the returned properties for the first and last characters will inappropriately allow breaks. 
  AnalyzeLineBreakpoints(analysisSource,textPosition,textLength,analysisSink){
	return _Error(DllCall(this.vt(6),"ptr",this.__,"analysisSource",analysisSource.__,"textPosition",textPosition,"textLength",textLength,"analysisSink",analysisSink.__),"AnalyzeLineBreakpoints")
  }

  ; Parses the input text string and maps it to the set of glyphs and associated glyph data according to the font and the writing system's rendering rules. 
  GetGlyphs(textString,textLength,fontFace,isSideways,isRightToLeft,scriptAnalysis,localeName,numberSubstitution,features,featureRangeLengths,featureRanges,maxGlyphCount,clusterMap,textProps,glyphIndices,Byref glyphProps,actualGlyphCount){
	_Error(DllCall(this.vt(7),"ptr",this.__,"str",textString,"uint",textLength,"ptr",fontFace.__,"int",isSideways,"int",isRightToLeft,"ptr",scriptAnalysis,"str",localeName,"ptr",numberSubstitution,"ptr",features,"uint",featureRangeLengths,"uint",featureRanges,"ptr",maxGlyphCount,"ptr",clusterMap,"ptr",textProps,"ptr",glyphIndices,"uint*",glyphProps,"uint",actualGlyphCount),"GetGlyphs")
    return ; not completed
  }

  ; Places glyphs output from the GetGlyphs method according to the font and the writing system's rendering rules. 
  GetGlyphPlacements(textString,clusterMap,textProps,textLength,glyphIndices,glyphProps,glyphCount,fontFace,fontEmSize,isSideways,isRightToLeft,scriptAnalysis,localeName,features,featureRangeLengths,featureRanges,glyphAdvances,glyphOffsets){
	_Error(DllCall(this.vt(8),"ptr",this.__,"str",textString,"ptr",clusterMap,"ptr",textProps,"uint",textLength,"ptr",glyphIndices,"ptr",glyphProps,"uint",glyphCount,"ptr",fontFace,"float",fontEmSize,"int",isSideways,"int",isRightToLeft,"ptr",scriptAnalysis,"str",localeName,"ptr",features,"ptr",featureRangeLengths,"uint",featureRanges,"ptr",glyphAdvances,"ptr",glyphOffsets),"GetGlyphPlacements")
    return  ; not completed
  }

  ; Place glyphs output from the GetGlyphs method according to the font and the writing system's rendering rules.
  GetGdiCompatibleGlyphPlacements(textString,clusterMap,textProps,textLength,glyphIndices,glyphProps,glyphCount,fontFace,fontEmSize,pixelsPerDip,transform,useGdiNatural,isSideways,isRightToLeft,scriptAnalysis,localeName,features,featureRangeLengths,featureRanges,glyphAdvances,glyphOffsets){
	_Error(DllCall(this.vt(9),"ptr",this.__,"str",textString,"ptr",clusterMap,"ptr",textProps,"uint",textLength,"ptr",glyphIndices,"ptr",glyphProps,"uint",glyphCount,"ptr",fontFace,"float",fontEmSize,"float",pixelsPerDip,"ptr",transform,"int",useGdiNatural,"int",isSideways,"int",isRightToLeft,"ptr",scriptAnalysis,"str",localeName,"ptr",features,"ptr",featureRangeLengths,"uint",featureRanges,"ptr",glyphAdvances,"ptr",glyphOffsets),"GetGdiCompatibleGlyphPlacements")
    return  ; not completed
  }
}

class IDWriteGlyphRunAnalysis extends IUnknown
{
  iid := "{7d97dbf7-e085-42d4-81e3-6a883bded118}"

  ; Gets the bounding rectangle of the physical pixels affected by the glyph run. 
  GetAlphaTextureBounds(textureType,Byref textureBounds){ ; DWRITE_TEXTURE_TYPE
	_Error(DllCall(this.vt(3),"ptr",this.__,"uint",textureType,"ptr*",textureBounds),"GetAlphaTextureBounds") ; not completed
    return 
  }

  ; Creates an alpha texture of the specified type for glyphs within a specified bounding rectangle. 
  CreateAlphaTexture(textureType,textureBounds,ByRef alphaValues,bufferSize){ ; DWRITE_TEXTURE_TYPE
	return _Error(DllCall(this.vt(4),"ptr",this.__,"int",textureType,"ptr",textureBounds,"ptr",alphaValues,"uint",bufferSize),"CreateAlphaTexture") ; not completed
  }

  ; Gets alpha blending properties required for ClearType blending. 
  GetAlphaBlendParams(renderingParams){ ; IDWriteRenderingParams
	_Error(DllCall(this.vt(5),"ptr",this.__,"ptr",renderingParams.__,"float*",blendGamma,"float*",blendEnhancedContrast,"float*",blendClearTypeLevel),"GetAlphaBlendParams")
    return [blendGamma,blendEnhancedContrast,blendClearTypeLevel ]
  }
}

class IDWriteLocalizedStrings extends IUnknown
{
  iid := "{08256209-099a-4b34-b86d-c22b110e7771}"

  ; Gets the number of language/string pairs. 
  GetCount(){
	return DllCall(this.vt(3),"ptr",this.__,"uint")
  }

  ; Gets the zero-based index of the locale name/string pair with the specified locale name. 
  FindLocaleName(localeName){
	_Error(DllCall(this.vt(4),"ptr",this.__,"wstr",localeName,"uint*",index,"int*",exists),"FindLocaleName")
    return [index,exists]
  }

  ; Gets the length in characters (not including the null terminator) of the locale name with the specified index. 
  GetLocaleNameLength(index){
	_Error(DllCall(this.vt(5),"ptr",this.__,"uint",index,"uint*",length),"GetLocaleNameLength")
    return length
  }

  ; Copies the locale name with the specified index to the specified array. 
  GetLocaleName(index,size){
    VarSetCapacity(localeName,size:=1024)
	_Error(DllCall(this.vt(6),"ptr",this.__,"uint",index,"ptr",&localeName,"uint",size),"GetLocaleName")
    return StrGet(&localeName,"utf-16")
  }

  ; Gets the length in characters (not including the null terminator) of the string with the specified index. 
  ; Use GetStringLength to get the string length before calling the IDWriteLocalizedStrings::GetString method, as shown in the following code.
  GetStringLength(index){
	_Error(DllCall(this.vt(7),"ptr",this.__,"uint",index,"uint*",length),"GetStringLength")
    return length
  }

  ; Copies the string with the specified index to the specified array. 
  ; The string returned must be allocated by the caller. You can get the size of the string by using the GetStringLength method prior to calling GetString, as shown in the following example.
  GetString(index,size){
    VarSetCapacity(stringBuffer,size:=1024)
	_Error(DllCall(this.vt(8),"ptr",this.__,"uint",index,"ptr",&stringBuffer,"uint",size),"GetString")
    return StrGet(&stringBuffer,"utf-16")
  }
}

class IDWriteFontList extends IUnknown
{
  iid := "{1a0d8438-1d97-4ec1-aef9-a2fb86ed6acb}"

  ; Gets the font collection that contains the fonts in the font list.
  GetFontCollection(){
	_Error(DllCall(this.vt(3),"ptr",this.__,"ptr*",fontCollection),"GetFontCollection")
    return new IDWriteFontCollection(fontCollection)
  }

  ; Gets the number of fonts in the font list. 
  GetFontCount(GetFont){
	return DllCall(this.vt(4),"ptr",this.__,"uint")
  }

  ; Gets a font given its zero-based index. 
  GetFont(index){
	_Error(DllCall(this.vt(5),"ptr",this.__,"uint",index,"ptr*",font),"GetFont")
    return new IDWriteFont(font)
  }
}

class IDWriteFontFamily extends IDWriteFontList
{
  iid := "{da20d8ef-812a-4c43-9802-62ec4abd7add}"

  ; Creates a localized strings object that contains the family names for the font family, indexed by locale name. 
  ; Example shows how to get the font family name from a IDWriteFontFamily object. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371047%28v=vs.85%29.aspx
  GetFamilyNames(){
	_Error(DllCall(this.vt(6),"ptr",this.__,"ptr*",names),"GetFamilyNames")
    return new IDWriteLocalizedStrings(names)
  }

  ; Gets the font that best matches the specified properties. 
  GetFirstMatchingFont(weight,stretch,style,Byref matchingFont){ ; DWRITE_FONT_WEIGHT , DWRITE_FONT_STRETCH , DWRITE_FONT_STYLE
	_Error(DllCall(this.vt(7),"ptr",this.__,"int",weight,"int",stretch,"int",style,"ptr*",matchingFont),"GetFirstMatchingFont")
    return new IDWriteFont(matchingFont)
  }

  ; Gets a list of fonts in the font family ranked in order of how well they match the specified properties. 
  GetMatchingFonts(weight,stretch,style){ ; DWRITE_FONT_WEIGHT , DWRITE_FONT_STRETCH , DWRITE_FONT_STYLE
	_Error(DllCall(this.vt(8),"ptr",this.__,"int",weight,"int",stretch,"int",style,"ptr*",matchingFonts),"GetMatchingFonts")
    return new IDWriteFontList(matchingFonts)
  }
}

class IDWriteFont extends IUnknown
{
  iid := "{acd16696-8c14-4f5d-877e-fe3fc1d32737}"

  ; Gets the font family to which the specified font belongs. 
  GetFontFamily(){
	_Error(DllCall(this.vt(3),"ptr",this.__,"ptr*",fontFamily),"GetFontFamily")
    return new IDWriteFontFamily(fontFamily)
  }

  ; Gets the weight, or stroke thickness, of the specified font. 
  GetWeight(){
	return DllCall(this.vt(4),"ptr",this.__,"int") ; DWRITE_FONT_WEIGHT
  }

  ; Gets the stretch, or width, of the specified font. 
  GetStretch(){
	return DllCall(this.vt(5),"ptr",this.__,"int") ; DWRITE_FONT_STRETCH
  }

  ; Gets the style, or slope, of the specified font. 
  GetStyle(){
	return _Error(DllCall(this.vt(6),"ptr",this.__,"int") ; DWRITE_FONT_STYLE
  }

  ; Determines whether the font is a symbol font. 
  IsSymbolFont(){
	return DllCall(this.vt(7),"ptr",this.__,"int")
  }

  ; Gets a localized strings collection containing the face names for the font (such as Regular or Bold), indexed by locale name. 
  GetFaceNames(){
	_Error(DllCall(this.vt(8),"ptr",this.__,"ptr*",names),"GetFaceNames")
    return new IDWriteLocalizedStrings(names)
  }

  ; Gets a localized strings collection containing the specified informational strings, indexed by locale name. 
  GetInformationalStrings(informationalStringID){ ; DWRITE_INFORMATIONAL_STRING_ID , IDWriteLocalizedStrings
	_Error(DllCall(this.vt(9),"ptr",this.__,"int",informationalStringID,"ptr*",informationalStrings,"int*",exists),"GetInformationalStrings")
    return [new IDWriteLocalizedStrings(informationalStrings),exists]
  }

  ; Gets a value that indicates what simulations are applied to the specified font. 
  GetSimulations(){
	return DllCall(this.vt(10),"ptr",this.__,"int") ; DWRITE_FONT_SIMULATIONS
  }

  ; Obtains design units and common metrics for the font face. These metrics are applicable to all the glyphs within a font face and are used by applications for layout calculations. 
  GetMetrics(){
	DllCall(this.vt(11),"ptr",this.__,"ptr*",fontMetrics) 
    return fontMetrics ; DWRITE_FONT_METRICS not completed
  }

  ; Determines whether the font supports a specified character. 
  HasCharacter(unicodeValue){
	_Error(DllCall(this.vt(12),"ptr",this.__,"uint",unicodeValue,"int*",exists),"HasCharacter")
    return exists
  }

  ; Creates a font face object for the font. 
  CreateFontFace(){
	_Error(DllCall(this.vt(13),"ptr",this.__,"ptr*",fontFace),"CreateFontFace")
    return new IDWriteFontFace(fontFace)
  }
}

class IDWriteInlineObject extends IUnknown
{
  iid := "{8339FDE3-106F-47ab-8373-1C6295EB10B3}"

  ; The application implemented rendering callback (IDWriteTextRenderer::DrawInlineObject) can use this to draw the inline object without needing to cast or query the object type. The text layout does not call this method directly. 
  Draw(clientDrawingContext,renderer,originX,originY,isSideways,isRightToLeft,clientDrawingEffect){
	return _Error(DllCall(this.vt(3),"ptr",this.__,"ptr",clientDrawingContext.__,"ptr",renderer.__,"float",originX,"float",originY,"int",isSideways,"int",isRightToLeft,"ptr",clientDrawingEffect.__),"Draw")
  }

  ; IDWriteTextLayout calls this callback function to get the measurement of the inline object. 
  GetMetrics(){
	_Error(DllCall(this.vt(4),"ptr",this.__,"ptr",metrics),"GetMetrics")
    return metrics ; DWRITE_INLINE_OBJECT_METRICS not completed
  }

  ; IDWriteTextLayout calls this callback function to get the visible extents (in DIPs) of the inline object. In the case of a simple bitmap, with no padding and no overhang, all the overhangs will simply be zeroes.
  ; The overhangs should be returned relative to the reported size of the object (see DWRITE_INLINE_OBJECT_METRICS), and should not be baseline adjusted.
  GetOverhangMetrics(){
	_Error(DllCall(this.vt(5),"ptr",this.__,"ptr",overhangs),"GetOverhangMetrics")
    return overhangs ; DWRITE_OVERHANG_METRICS
  }

  ; Layout uses this to determine the line-breaking behavior of the inline object among the text. 
  GetBreakConditions(){
	_Error(DllCall(this.vt(6),"ptr",this.__,"int*",breakConditionBefore,"int*",breakConditionAfter),"GetBreakConditions")
    return [breakConditionBefore,breakConditionAfter]
  }
}

class IDWritePixelSnapping extends IUnknown
{
  iid := "{eaf3a2da-ecf4-4d24-b644-b34f6842024b}"

  ; Determines whether pixel snapping is disabled. The recommended default is FALSE, unless doing animation that requires subpixel vertical placement. 
  IsPixelSnappingDisabled(clientDrawingContext){
	_Error(DllCall(this.vt(3),"ptr",this.__,"ptr",clientDrawingContext.__,"int*",isDisabled),"IsPixelSnappingDisabled")
    return isDisabled
  }

  ; Gets a transform that maps abstract coordinates to DIPs. 
  GetCurrentTransform(clientDrawingContext){
	_Error(DllCall(this.vt(4),"ptr",this.__,"ptr",clientDrawingContext.__,"ptr",transform),"GetCurrentTransform")
    return transform ; DWRITE_MATRIX not completed
  }

  ; Gets the number of physical pixels per DIP. 
  ; Because a DIP (device-independent pixel) is 1/96 inch, the pixelsPerDip value is the number of logical pixels per inch divided by 96.
  GetPixelsPerDip(clientDrawingContext){
	_Error(DllCall(this.vt(5),"ptr",this.__,"ptr",clientDrawingContext.__,"float*",pixelsPerDip),"GetPixelsPerDip")
    return pixelsPerDip
  }
}

class IDWriteTextRenderer extends IDWritePixelSnapping
{
  iid := "{ef8a8135-5cc6-45fe-8825-c5a0724eb819}"

  ; IDWriteTextLayout::Draw calls this function to instruct the client to render a run of glyphs. 
  ; The IDWriteTextLayout::Draw function calls this callback function with all the information about glyphs to render. The application implements this callback by mostly delegating the call to the underlying platform's graphics API such as Direct2D to draw glyphs on the drawing context. An application that uses GDI can implement this callback in terms of the IDWriteBitmapRenderTarget::DrawGlyphRun method.
  DrawGlyphRun(clientDrawingContext,baselineOriginX,baselineOriginY,measuringMode,glyphRun,glyphRunDescription,clientDrawingEffect){
	return _Error(DllCall(this.vt(6),"ptr",this.__,"ptr",clientDrawingContext.__,"float",baselineOriginX,"float",baselineOriginY,"int",measuringMode,"ptr",glyphRun,"ptr",glyphRunDescription,"ptr",clientDrawingEffect.__),"DrawGlyphRun")
  }

  ; IDWriteTextLayout::Draw calls this function to instruct the client to draw an underline. 
  ; A single underline can be broken into multiple calls, depending on how the formatting changes attributes. If font sizes/styles change within an underline, the thickness and offset will be averaged weighted according to characters. To get an appropriate starting pixel position, add underline::offset to the baseline. Otherwise there will be no spacing between the text. The x coordinate will always be passed as the left side, regardless of text directionality. This simplifies drawing and reduces the problem of round-off that could potentially cause gaps or a double stamped alpha blend. To avoid alpha overlap, round the end points to the nearest device pixel. 
  DrawUnderline(clientDrawingContext,baselineOriginX,baselineOriginY,underline,clientDrawingEffect){
	return _Error(DllCall(this.vt(7),"ptr",this.__,"ptr",clientDrawingContext.__,"float",baselineOriginX,"float",baselineOriginY,"ptr",underline,"ptr",clientDrawingEffect.__),"DrawUnderline")
  }

  ; IDWriteTextLayout::Draw calls this function to instruct the client to draw a strikethrough. 
  ; A single strikethrough can be broken into multiple calls, depending on how the formatting changes attributes. Strikethrough is not averaged across font sizes/styles changes. To get an appropriate starting pixel position, add strikethrough::offset to the baseline. Like underlines, the x coordinate will always be passed as the left side, regardless of text directionality. 
  DrawStrikethrough(clientDrawingContext,baselineOriginX,baselineOriginY,strikethrough,clientDrawingEffect){
	return _Error(DllCall(this.vt(8),"ptr",this.__,"ptr",clientDrawingContext.__,"float",baselineOriginX,"float",baselineOriginY,"ptr",strikethrough,"ptr",clientDrawingEffect.__),"DrawStrikethrough")
  }

  ; IDWriteTextLayout::Draw calls this application callback when it needs to draw an inline object. 
  DrawInlineObject(clientDrawingContext,originX,originY,inlineObject,isSideways,isRightToLeft,clientDrawingEffect){
	return _Error(DllCall(this.vt(9),"ptr",this.__,"ptr",clientDrawingContext.__,"float",originX,"float",originY,"ptr",inlineObject.__,"int",isSideways,"int",isRightToLeft,"ptr",clientDrawingEffect.__),"DrawInlineObject")
  }
}

class IDWriteBitmapRenderTarget extends IUnknown
{
  iid := "{5e5a32a3-8dff-4773-9ff6-0696eab77267}"

  ; Draws a run of glyphs to a bitmap target at the specified position.
  ; You can use the IDWriteBitmapRenderTarget::DrawGlyphRun to render to a bitmap from a custom text renderer that you implement. The custom text renderer should call this method from within the IDWriteTextRenderer::DrawGlyphRun callback method as shown in the following code.
  ; The baselineOriginX, baslineOriginY, measuringMethod, and glyphRun parameters are provided (as arguments) when the callback method is invoked. The renderingParams, textColor and blackBoxRect are not.
  ; Default rendering params can be retrieved by using the IDWriteFactory::CreateMonitorRenderingParams method.
  DrawGlyphRun(baselineOriginX,baselineOriginY,measuringMode,glyphRun,renderingParams,textColor){
	_Error(DllCall(this.vt(3),"ptr",this.__,"float",baselineOriginX,"float",baselineOriginY,"int",measuringMode,"ptr",glyphRun,"ptr",renderingParams.__,"ptr",textColor,"ptr*",blackBoxRect),"DrawGlyphRun")
    return blackBoxRect ; not completed
  }

  ; Gets a handle to the memory device context. 
  ; An application can use the device context to draw using GDI functions. An application can obtain the bitmap handle (HBITMAP) by calling GetCurrentObject. An application that wants information about the underlying bitmap, including a pointer to the pixel data, can call GetObject to fill in a DIBSECTION structure. The bitmap is always a 32-bit top-down DIB. 
  ; The HDC returned here is still owned by the bitmap render targer object and should not be released or deleted by the client.
  GetMemoryDC(){
	return DllCall(this.vt(4),"ptr",this.__,"ptr")
  }

  ; Gets the number of bitmap pixels per DIP. 
  ; A DIP (device-independent pixel) is 1/96 inch. Therefore, this value is the number if pixels per inch divided by 96.
  GetPixelsPerDip(){
	return DllCall(this.vt(5),"ptr",this.__,"float")
  }

  ; Sets the number of bitmap pixels per DIP (device-independent pixel). A DIP is 1/96 inch, so this value is the number if pixels per inch divided by 96. 
  SetPixelsPerDip(pixelsPerDip){
	return _Error(DllCall(this.vt(6),"ptr",this.__,"float",pixelsPerDip),"SetPixelsPerDip")
  }

  ; Gets the transform that maps abstract coordinates to DIPs. By default this is the identity transform. Note that this is unrelated to the world transform of the underlying device context. 
  GetCurrentTransform(){
	_Error(DllCall(this.vt(7),"ptr",this.__,"ptr*",transform),"GetCurrentTransform")
    return transform
  }

  ; Sets the transform that maps abstract coordinate to DIPs (device-independent pixel). This does not affect the world transform of the underlying device context. 
  SetCurrentTransform(transform){
	return _Error(DllCall(this.vt(8),"ptr",this.__,"ptr",transform),"SetCurrentTransform")
  }

  ; Gets the dimensions of the target bitmap. 
  GetSize(){
	_Error(DllCall(this.vt(9),"ptr",this.__,"ptr*",size),"GetSize")
    return size
  }

  ; Resizes the bitmap. 
  Resize(width,height){
	return _Error(DllCall(this.vt(10),"ptr",this.__,"uint",width,"uint",height),"Resize")
  }
}



