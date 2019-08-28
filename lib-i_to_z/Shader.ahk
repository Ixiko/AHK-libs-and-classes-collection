MCRC := "F566D79F"
MVersion := "1.0.3"

CreateShaderBitmap(width, height, vertical:="false") {
	Global shaderObj, RLMediaPath
	Global shaderName, shaderColor, shaderTransparency, shaderChangeKey, shaderObj
	If (shaderObj){
		RLLog.Info(A_ThisFunc . " - Started")
		pBitmap_temp := Gdip_CreateBitmap(width, height)
		G_temp := Gdip_GraphicsFromImage(pBitmap_temp), Gdip_SetSmoothingMode(G_temp, 4), Gdip_SetInterpolationMode(G_temp, 7)	
		If (shaderColor){ ; priority for the color defined on RL
			transparency := ToBase( Round( (ToBase("0x" . SubStr(shaderColor,1,2),10)) * (shaderTransparency ? (shaderTransparency/255) : 1) ) , 16)
			Gdip_FillRectangle(G_temp, Gdip_BrushCreateSolid("0x" . transparency . SubStr(shaderColor,3,6)), 0, 0, width, height)
		}
		for index, element in shaderObj["overlays"]
		{	If !(element["orientation"]) or ( (element["orientation"]="horizontal") and (vertical = "false") ) or ( (element["orientation"]="vertical") and (vertical = "true") ) {
				If ((element.HasKey("solid-color")) and !(shaderColor)){ ; solid color layer
					transparency := ToBase( Round( (ToBase("0x" . SubStr(element["solid-color"],1,2),10)) * (shaderTransparency ? (shaderTransparency/255) : 1) ) , 16)
					Gdip_FillRectangle(G_temp, Gdip_BrushCreateSolid("0x" . transparency . SubStr(element["solid-color"],3,6)), 0, 0, width, height)
				} Else If (element["filename"]){ ; image layer
					alpha := element["alpha-channel"] ? element["alpha-channel"] : 255
					transparency := (element["matrix"]) ? (element["matrix"]) : ( (alpha/255) * ( shaderTransparency ? (shaderTransparency/255) : 1 ) )
					shaderBitmap_temp := Gdip_CreateBitmapFromFile(RLMediaPath . "\Shaders\" . shaderName . "\" . element["filename"])	
					If (element["size-mode"]="tile"){
						shaderBitmap_temp := RepeatBitmap(shaderBitmap_temp, width, height)
						if (shaderBitmap_temp)
							Gdip_DrawImage(G_temp, shaderBitmap_temp, 0, 0, width, height,,,,, transparency)
					} Else {
						Gdip_DrawImage(G_temp, shaderBitmap_temp, 0, 0, width, height,,,,, transparency)
					}
				} Else
					RLLog.Warning(A_ThisFunc . " - Invalid shader overlay element: index" . index . ". Each overlay must contain a key named: filename, for the case of images, or solid-color, for the case of solid background colors.")
			}
		}
		If shaderBitmap_temp ;discarding temp GDIP assets
			Gdip_DisposeImage(shaderBitmap_temp)
		Gdip_DeleteGraphics(G_temp)
		RLLog.Info(A_ThisFunc . " - Ended")
		Return pBitmap_temp
	}
	Return
}

RepeatBitmap(pBitmap, width, height, order:=4, timeout:=5000) {
	RLLog.Info(A_ThisFunc . " - Started")
	If (!(width) or !(height)){
		RLLog.Warning("Shader - width or height information missing on the code. Shader will not be displayed.")
		Return
	}
	startTime := A_TickCount
	Loop, 
	{	Gdip_GetImageDimensions(pBitmap, origW, origH)
		If ((origW=width) and (origH=height)){
			RLLog.Info("Shader - shader image is complete with width: " . width . " and height: " . height . ".")
			break
		}
		pBitmap := ImageCollage(pBitmap, width, height, order)
		If (startTime < A_TickCount - timeout) {
			RLLog.Warning("Shader - Shader will not be displayed because timeout was reached on the shader creation process.")
			Break
		}
	}
	RLLog.Info(A_ThisFunc . " - Ended")
	Return pBitmap
}

ImageCollage(pBitmap, width, height, order:=4) {
	Gdip_GetImageDimensions(pBitmap, origW, origH)
	pBitmap_temp := Gdip_CreateBitmap( If (order*origW > width) ? width : order*origW, If (order*origH > height) ? height : order*origH)
	G_temp := Gdip_GraphicsFromImage(pBitmap_temp), Gdip_SetSmoothingMode(G_temp, 4), Gdip_SetInterpolationMode(G_temp, 7)	
	Loop, %order%  
	{	i := a_index
		Loop, %order%   
		{	j := A_Index
			Gdip_DrawImage(G_temp, pBitmap, (i-1)*origW, (j-1)*origH, origW, origH)
		}
	}
	Return pBitmap_temp
}

; Converts a base 10 number to base 36
;from Laszlo : http://www.autohotkey.com/board/topic/15951-base-10-to-base-36-conversion/#entry103624
ToBase(n,b) { ; n >= 0, 1 < b <= 36
	Loop {
		d := mod(n,b), n //= b
		m := (d < 10 ? d : Chr(d+55)) . m
		IfLess n,1, Break
	}
	Return m
}
