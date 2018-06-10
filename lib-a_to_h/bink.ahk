PlayBink(file, pddraw, pPrimary, h_win, pdSound = "", scale = True, dllpath="binkw32.dll")
{
	rct_back := RECT.clone()
	rct_primary := RECT.clone()
	
	bink := dllcall("LoadLibraryW", str, dllpath)
	printl("bink " bink)
	BinkOpen := dllcall("GetProcAddress", uint, bink, astr, "_BinkOpen@8")
	BinkGetError := dllcall("GetProcAddress", uint, bink, astr, "_BinkGetError@0")
	BinkDoFrame := dllcall("GetProcAddress", uint, bink, astr, "_BinkDoFrame@4")
	BinkCopyToBuffer := dllcall("GetProcAddress", uint, bink, astr, "_BinkCopyToBuffer@28")
	BinkNextFrame := dllcall("GetProcAddress", uint, bink, astr, "_BinkNextFrame@4")
	BinkSetSoundOnOff := dllcall("GetProcAddress", uint, bink, astr, "_BinkSetSoundOnOff@8")
	BinkWait := dllcall("GetProcAddress", uint, bink, astr, "_BinkWait@4") 
	BinkShouldSkip := dllcall("GetProcAddress", uint, bink, astr, "_BinkShouldSkip@4") 
	BinkOpenDirectSound := dllcall("GetProcAddress", uint, bink, astr, "_BinkOpenDirectSound@4") 
	BinkOpenWaveOut := dllcall("GetProcAddress", uint, bink, astr, "_BinkOpenWaveOut@4") 
	BinkSetSoundSystem := dllcall("GetProcAddress", uint, bink, astr, "_BinkSetSoundSystem@8") 
	BinkClose := dllcall("GetProcAddress", uint, bink, astr, "_BinkClose@4") 	
		
	if not bink
		return "Failed to load binkw32.dll"
	
	pDSound ? dllcall(BinkSetSoundSystem , uint, BinkOpenDirectSound, uint, pDSound)
	: dllcall(BinkSetSoundSystem , uint, BinkOpenWaveOut, uint, 0)
	HBINK := dllcall(BinkOpen, astr, file, uint, 0)
	if not HBINK
		return dllcall(BinkGetError, astr)
		
	dllcall(IDirectDrawSurface.GetAttachedSurface, uint, pPrimary
	, "uint*",  DDSCAPS_BACKBUFFER, "uint*", TrueBackbuffer, uint)	
	windowed := TrueBackbuffer ? False : True
	windowed ? scale := True
	
	dllcall(IDirectDrawSurface.Restore, uint, pPrimary)
	
	zeromem(ddSurfaceDesc)
	dllcall(IDirectDraw.GetDisplayMode, uint, pddraw, uint, ddSurfaceDesc[])
	backbuffer_w := ddSurfaceDesc.dwWidth,	backbuffer_h := ddSurfaceDesc.dwHeight		
	
	printl("Bink Surfdesc:" dllcall(IDirectDrawSurface.GetSurfaceDesc, uint, pPrimary, uint, ddSurfaceDesc[]))
	ddSurfaceDesc.dwFlags := DDSD_CAPS | DDSD_WIDTH | DDSD_HEIGHT 
	ddSurfaceDesc.ddsCaps.dwCaps := DDSCAPS_VIDEOMEMORY | DDSCAPS_3DDEVICE | DDSCAPS_TEXTURE | DDSD_PIXELFORMAT 
	DDPIXELFORMAT[] := ddSurfaceDesc.GetAddress("ddpfPixelFormat")
	setpixelformat("ARGB")
	printl("Bink pixformat " GetPixelFormat(ddSurfaceDesc))
	r := dllcall(IDirectDraw.CreateSurface, uint, pddraw, uint, ddSurfaceDesc[]
									      , "ptr*", pBackBuffer, uint, 0, uint)
	printl("Bink BackBuffer: " r " " ddraw.result[r . ""])		
	
	backbuffer_w := ddSurfaceDesc.dwWidth,	backbuffer_h := ddSurfaceDesc.dwHeight		
		
	ddSurfaceDesc.dwFlags := DDSD_CAPS | DDSD_WIDTH | DDSD_HEIGHT | DDSD_PIXELFORMAT 
	ddSurfaceDesc.dwWidth := numget(HBINK+0, "int")
	ddSurfaceDesc.dwHeight := numget(HBINK+4, "int")	
	ddSurfaceDesc.ddsCaps.dwCaps := DDSCAPS_VIDEOMEMORY | DDSCAPS_3DDEVICE | DDSCAPS_TEXTURE 
	r := dllcall(IDirectDraw.CreateSurface, uint, pddraw, uint, ddSurfaceDesc[]
									      , "ptr*", pMovieSurface, uint, 0, uint)
	printl("Bink MovieSurface: " r " " ddraw.result[r . ""])	
		
	back_ar := backbuffer_w / backbuffer_h
	movie_ar := numget(HBINK+0, "int")/numget(HBINK+4, "int")
	
	printl(back_ar " " movie_ar)
	
	if ( (scale = false) and (numget(HBINK+0, "int") < backbuffer_w) and  (numget(HBINK+4, "int") < backbuffer_h) )
		{
			rct_back.left := (backbuffer_w - numget(HBINK+0, "int"))/2
			rct_back.right := backbuffer_w - (backbuffer_w - numget(HBINK+0, "int"))/2
			rct_back.top := (backbuffer_h - numget(HBINK+4, "int"))/2
			rct_back.bottom := backbuffer_h - (backbuffer_h - numget(HBINK+4, "int"))/2
		}
	else
		{		
			x_offset := 0
			y_offset := 0			
			
			if (back_ar > movie_ar)
				x_offset := (backbuffer_w - (backbuffer_h * movie_ar))/2    
			else if (back_ar < movie_ar) 
				y_offset := (backbuffer_h - (backbuffer_w / movie_ar))/2 				
			
			rct_back.left := x_offset
			rct_back.right := backbuffer_w - x_offset
			rct_back.top := y_offset
			rct_back.bottom := backbuffer_h - y_offset
			
			;msgbox % rct_back.left " " rct_back.right " " rct_back.top " " rct_back.bottom 
		}
		
	;printl("off " dllcall(BinkSetSoundOnOff, uint, HBINK, uint, 0))	
	checkControler := XinputGetState(1) ? False : True	
			
	loop
	{	
		;printl("Bink frame " numget(HBINK+12, "int") " of " numget(HBINK+8, "int"))
		
		if GetKeyState("Esc", "P") 
		{
			KeyWait, Esc, T5
			break
		}	
		
		if checkControler
		{
			checkControler := XinputGetState(1) ? False : True	
			if XINPUT_GAMEPAD_BACK
			{
				while XINPUT_GAMEPAD_BACK 
					XinputGetState(1)
				break
			}	
		}			
		
		if ( numget(HBINK+8, "int")= numget(HBINK+12, "int") )
			break
		;if ( numget(HBINK+20, "int")= numget(HBINK+16, "int") )
			;break
			
		wait := true
		while wait
			wait := dllcall(BinkWait, uint, HBINK)
				
		printl("Bink lock " dllcall(IDirectDrawSurface.lock, uint, pMovieSurface, uint, 0, uint, ddSurfaceDesc[], uint, DDLOCK_WAIT, uint, 0))		
			
		if dllcall(BinkShouldSkip, uint, HBINK)	
		{
			printl("Bink next " dllcall(BinkNextFrame, uint, HBINK)) 
			printl("Bink Unlock " dllcall(IDirectDrawSurface.Unlock, uint, pMovieSurface, uint, ddSurfaceDesc.lpSurface))
			continue
		}
			
		printl("Bink doframe " dllcall(BinkDoFrame, uint, HBINK))		
		printl("Bink Copy2buffer " dllcall(BinkCopyToBuffer, uint, HBINK, uint, ddSurfaceDesc.lpSurface, uint, ddSurfaceDesc.lPitch
		, uint, numget(HBINK+4, "int"), uint, 0, uint, 0, uint, 3))		
		
		printl("Bink Unlock " dllcall(IDirectDrawSurface.Unlock, uint, pMovieSurface, uint, ddSurfaceDesc.lpSurface))
		DDBLTFX.dwsize := DDBLTFX.size()
		DDBLTFX.dwDDFX := DDBLTFX_NOTEARING
		
		r := dllcall(IDirectDrawSurface.Blt, uint, pBackBuffer
						 , uint, rct_back[] 
						 , uint, pMovieSurface
						 , uint, 0
						 , uint, DDBLT_DDFX
						 , uint, DDBLTFX[], uint)						 
		
		newmem(point)
		dllcall("GetClientRect", uint, h_win, uint, rct_primary[])
		dllcall("ClientToScreen", uint, h_win, uint, point[])		
		rct_primary.left += point.x
		rct_primary.top += point.y
		rct_primary.right += point.x 
		rct_primary.bottom += point.y
		
		r := dllcall(IDirectDrawSurface.Blt, uint, pPrimary
						 , uint, windowed ? rct_primary[] : 0
						 , uint, pBackBuffer
						 , uint, 0
						 , uint, DDBLTFAST_NOCOLORKEY
						 , uint, DDBLTFX[], uint)				 
						 
		printl("Bink Blt" r "-" ddraw.result[r . ""])
		printl("Bink next " dllcall(BinkNextFrame, uint, HBINK)) 
	}	
	
	dllcall(IDirectDrawSurface.Release, uint, pBackBuffer)
	dllcall(IDirectDrawSurface.Release, uint, pMovieSurface)
	dllcall(BinkClose, uint, HBINK)
	dllcall("FreeLibrary", uint, bink)	
	return	"Bink playback was successful"
	
	
}
	