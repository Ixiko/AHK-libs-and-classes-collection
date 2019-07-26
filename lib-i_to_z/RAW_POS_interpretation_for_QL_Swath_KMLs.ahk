;RAW_POS_interpretation_for_QL_Swath_KMLs
;This could be used for IPAS as well.  Only the IPAS interpretation needs to be done.

GPS_UTM2LatLon(UTMEast, UTMNorth, Hemisphere, Longitude_Zone) {
	b := 6356752.314
	a := 6378137
	e := 0.081819191
	e1sq := 0.00673949676
	k0 := 0.9996
   ei := (1-(1-e*e)**(1/2))/(1+(1-e*e)**(1/2))
   C1 := (3*ei/2-27*ei**3/32)
   C2 := (21*ei**2/16-55*ei**4/32)
   C3 := (151*ei**3/96)
   C4 := (1097*ei**4/512)
   If (Hemisphere = "S")
   {
      Corrected_Northing := (10000000-UTMNorth)
   }
   Else
   {
      Corrected_Northing := UTMNorth
   }
   East_Prime := (500000-UTMEast)
   Arc_Length := (Corrected_Northing / k0)
   Mu := (Arc_Length/(a*(1-e**2/4-3*e**4/64-5*e**6/256)))
   Footprint_Latitude := (Mu+C1*Sin(2*Mu)+C2*Sin(4*Mu)+C3*Sin(6*Mu)+C4*Sin(8*Mu))
   CC1 := (e1sq*Cos(Footprint_Latitude)**2)
   T1 := (Tan(Footprint_Latitude)**2)
   N1 := (a/(1-(e*Sin(Footprint_Latitude))**2)**(1/2))
   R1 := (a*(1-e*e)/(1-(e*Sin(Footprint_Latitude))**2)**(3/2))
   D := (East_Prime/(N1*k0))
   Fact1 := (N1*Tan(Footprint_Latitude)/R1)
   Fact2 := (D*D/2)
   Fact3 := ((5+3*T1+10*CC1-4*CC1*CC1-9*e1sq)*D**4/24)
   Fact4 := ((61+90*T1+298*CC1+45*T1*T1-252*e1sq-3*CC1*CC1)*D**6/720)
   LoFact1 := D
   LoFact2 := ((1+2*T1+CC1)*D**3/6)
   LoFact3 := ((5-2*CC1+28*T1-3*CC1**2+8*e1sq+24*T1**2)*D**5/120)
   Delta_Long := ((LoFact1-LoFact2+LoFact3)/Cos(Footprint_Latitude))
   Zone_CM := (6*Longitude_Zone-183)
   Raw_Latitude := (180*(Footprint_Latitude-Fact1*(Fact2+Fact3+Fact4))/(4*ATan(1)))
   If (Hemisphere = "South")
   {
      Latitude := -Raw_Latitude
   }
   Else
   {
      Latitude := Raw_Latitude
   }
   Longitude := (Zone_CM-Delta_Long*180/(4*ATan(1)))
   Return Longitude . "`," . Latitude
}
GPS_LatLon2UTM(Latitude, Longitude) {
   	b := 6356752.314
	a := 6378137
	e := 0.081819191
	e1sq := 0.00673949676
	k0 := 0.9996
   n := (a-b)/(a+b)
   A0 := a*(1-n+(5*n*n/4)*(1-n)+(81*n**4/64)*(1-n))
   B0 := (3*a*n/2)*(1 - n - (7*n*n/8)*(1-n) + 55*n**4/64)
   C0 := (15*a*n*n/16)*(1 - n +(3*n*n/4)*(1-n))
   D0 := (35*a*n**3/48)*(1 - n + 11*n*n/16)
   E0 := (315*a*n**4/512)*(1-n)
	LatDegrees := Latitude
	LonDegrees := Longitude
   If (LonDegrees/6) < 0
   {
      Longitude_Zone := 31 + Floor(LonDegrees/6)
   }
   Else
   {
      Longitude_Zone := Round(31+Substr((LonDegrees/6), 1, InStr((LonDegrees/6), ".")))
   }
   Long_Zone_CM := (6*Longitude_Zone-183)
   Delta_LonRad := (LonDegrees-Long_Zone_CM)*(4*ATan(1))/180
   LatRad := LatDegrees*((4*ATan(1))/180)
   LonRad := LonDegrees*((4*ATan(1))/180)
   rho := a*(1-e*e)/((1-(e*Sin(LatRad))**2)**(3/2))
   nu := a/((1-(e*Sin(LatRad))**2)**(1/2))
   Arc_S := A0*LatRad - B0*Sin(2*LatRad) + C0*Sin(4*LatRad) - D0*Sin(6*LatRad) + E0*Sin(8*LatRad)
   Ki := Arc_S*k0
   Kii := nu*Sin(LatRad)*Cos(LatRad)/2
   Kiii := ((nu*Sin(LatRad)*Cos(LatRad)**3)/24)*(5-Tan(LatRad)**2+9*e1sq*Cos(LatRad)**2+4*e1sq**2*Cos(LatRad)**4)*k0
   Kiv := nu*Cos(LatRad)*k0
   Kv := (Cos(LatRad))**3*(nu/6)*(1-Tan(LatRad)**2+e1sq*Cos(LatRad)**2)*k0
   A6 := ((Delta_LonRad)**6*nu*Sin(LatRad)*Cos(LatRad)**5/720)*(61-58*Tan(LatRad)**2+Tan(LatRad)**4+270*e1sq*Cos(LatRad)**2-330*e1sq*Sin(LatRad)**2)*k0
   Raw_Northing := (Ki+Kii*Delta_LonRad*Delta_LonRad+Kiii*Delta_LonRad**4)
   If (Raw_Northing < 0)
   {
      Northing := (10000000m + Raw_Northing)
   }
   Else
   {
      Northing := Raw_Northing
   }
   Easting := 500000+(Kiv*Delta_LonRad+Kv*Delta_LonRad**3)
   Return Northing . "`," . Easting . "`," . Longitude_Zone
}
GPS_LatLon2UTM_CustomZone(Latitude, Longitude, RequestedZone) {
   	b := 6356752.314
	a := 6378137
	e := 0.081819191
	e1sq := 0.00673949676
	k0 := 0.9996
   n := (a-b)/(a+b)
   A0 := a*(1-n+(5*n*n/4)*(1-n)+(81*n**4/64)*(1-n))
   B0 := (3*a*n/2)*(1 - n - (7*n*n/8)*(1-n) + 55*n**4/64)
   C0 := (15*a*n*n/16)*(1 - n +(3*n*n/4)*(1-n))
   D0 := (35*a*n**3/48)*(1 - n + 11*n*n/16)
   E0 := (315*a*n**4/512)*(1-n)
	LatDegrees := Latitude
	LonDegrees := Longitude

   Longitude_Zone := RequestedZone
   Long_Zone_CM := (6*Longitude_Zone-183)
   Delta_LonRad := (LonDegrees-Long_Zone_CM)*(4*ATan(1))/180
   LatRad := LatDegrees*((4*ATan(1))/180)
   LonRad := LonDegrees*((4*ATan(1))/180)
   rho := a*(1-e*e)/((1-(e*Sin(LatRad))**2)**(3/2))
   nu := a/((1-(e*Sin(LatRad))**2)**(1/2))
   Arc_S := A0*LatRad - B0*Sin(2*LatRad) + C0*Sin(4*LatRad) - D0*Sin(6*LatRad) + E0*Sin(8*LatRad)
   Ki := Arc_S*k0
   Kii := nu*Sin(LatRad)*Cos(LatRad)/2
   Kiii := ((nu*Sin(LatRad)*Cos(LatRad)**3)/24)*(5-Tan(LatRad)**2+9*e1sq*Cos(LatRad)**2+4*e1sq**2*Cos(LatRad)**4)*k0
   Kiv := nu*Cos(LatRad)*k0
   Kv := (Cos(LatRad))**3*(nu/6)*(1-Tan(LatRad)**2+e1sq*Cos(LatRad)**2)*k0
   A6 := ((Delta_LonRad)**6*nu*Sin(LatRad)*Cos(LatRad)**5/720)*(61-58*Tan(LatRad)**2+Tan(LatRad)**4+270*e1sq*Cos(LatRad)**2-330*e1sq*Sin(LatRad)**2)*k0
   Raw_Northing := (Ki+Kii*Delta_LonRad*Delta_LonRad+Kiii*Delta_LonRad**4)
   If (Raw_Northing < 0)
   {
      Northing := (10000000m + Raw_Northing)
   }
   Else
   {
      Northing := Raw_Northing
   }
   Easting := 500000+(Kiv*Delta_LonRad+Kv*Delta_LonRad**3)
   Return Northing . "`," . Easting
}
GRPMSGHeader() {
	Global
	GRPMSGID := "", GRPMSGBCount := ""
	GRPMSGID := RAWPOS.ReadUShort()
	GRPMSGBCount := RAWPOS.ReadUShort()
}
Bin2Hex(Var) {
	SetFormat, IntegerFast, hex
	Var += 0, Var .= ""
	SetFormat, IntegerFast, d
	Return (Var)
}
toInt(b, s = 0, c = 0) {
	Loop, % l := StrLen(b) - c
		i += SubStr(b, ++c, 1) * 1 << l - c
	Return, i - s * (1 << l)
}
toBin(i, s = 0, c = 0) {
	l := StrLen(i := Abs(i + u := i < 0))
	Loop, % Abs(s) + !s * l << 2
		b := u ^ 1 & i // (1 << c++) . b
	Return, b
}
PitchRollCorrectStrong(Pitch,Roll,Heading,FoV) {
	global
	
	FixedR := Abs(Roll)
	, FoVR := (FoV/2)+FixedR
	, Ang := sqrt(FoVR**2+Pitch**2)
	, AzCorr := (atan((abs(Pitch*0.01745329251))/(abs(FoVR*0.01745329251))))*57.2957795131
	If (Roll > 0 AND Pitch > 0)
		Az := (270+AzCorr)+Heading
	else if (Roll > 0 AND Pitch < 0)
		Az := (270-AzCorr)+Heading
	else if (Roll < 0 AND Pitch < 0)
		Az := (90+AzCorr)+Heading
	else if (Roll < 0 AND Pitch > 0)
		Az := (90-AzCorr)+Heading
	
	If (FoVR < 0)
		Az := Az-((Az-Heading)*2)
	
	If (Az > 360)
		Az := Az-360
	
	PRC = %Az%,%Ang%
	return (PRC)
}
PitchRollCorrectWeak(Pitch,Roll,Heading,FoV){
	global 
	
	FixedR := Abs(Roll), FoVR := (FoV/2)-FixedR
	Ang := sqrt(FoVR**2+Pitch**2)
	AzCorr := (atan((abs(Pitch*0.01745329251))/(abs(FoVR*0.01745329251))))*57.2957795131

	If (Roll > 0 AND Pitch > 0)
		Az := (90-AzCorr)+Heading
	else if (Roll > 0 AND Pitch < 0)
		Az := (90+AzCorr)+Heading
	else if (Roll < 0 AND Pitch < 0)
		Az := (270-AzCorr)+Heading
	else if (Roll < 0 AND Pitch > 0)
		Az := (270+AzCorr)+Heading
	
	If (FoVR < 0)
		Az := Az-((Az-Heading)*2)
	
	If (Az > 360)
		Az := Az-360
	
	PRC = %Az%,%Ang%
	return (PRC)
}
Read_FLT4Array_Object(FLTvarPATH) {
	global
	
	aSpace := A_space
	DEM := Object()
	splitpath, FLTvarPATH, FLTwEXT, FLTDir, FLTExt, FLTnoExt
	HDRpath := FLTDir . "\" . FLTnoEXT . ".hdr", FLTpath := FLTDir . "\" . FLTnoEXT . ".flt"	
	HDRobj := fileopen(HDRpath, "rw")
	FLTobj := fileopen(FLTpath, "rw")
	DEMlen := FLTobj.Length
	fltCapacity := DEMlen/4
	
	If (DEMlen > 3617587200)
	{
		msgbox, Whoa!  That's a big GRID...try a smaller one before you burn the place down.
		ExitApp
	}
	progress, R0-%DEMlen%, , Building DEM Array, INS 2 Swath
	Loop
	{
		HDRline := HDRobj.ReadLine()
		StringReplace HDRline, HDRline, %A_Space%    %A_Space%, %A_Space%, All 
		StringReplace HDRline, HDRline, %A_Space% %A_Space%, %A_Space%, All 
		StringReplace HDRline, HDRline, %A_Space%%A_Space%, %A_Space%, All 
		StringReplace HDRline, HDRline, %A_Space%%A_Space%, %A_Space%, All
		If (A_Index = 1)
		{
			StringSplit, COL, HDRline, %A_Space%
			CLMN := Round(COL2)
			continue
		}
		Else If (A_Index = 2)
		{
			StringSplit, ROW, HDRline, %A_Space%
			ROWS := Round(ROW2)
			continue
		}
		Else If (A_Index = 3)
		{
			StringSplit, XL, HDRline, %A_Space%
			XLLC := Round(XL2)
			continue
		}
		Else If (A_Index = 4)
		{
			StringSplit, YL, HDRline, %A_Space%
			YLLC := Round(YL2)
			continue
		}
		Else If (A_Index = 5)
		{
			StringSplit, CS, HDRline, %A_Space%
			CSize := Round(CS2), XURC := XLLC+(CSize*CLMN), YURC := YLLC+(CSize*ROWS)
			continue
		}
		Else If (A_Index = 6)
		{
			StringSplit, NOD, HDRline, %A_Space%
			NODATA := NOD2
			continue
		}
		If (HDRobj.AtEOF != 0)
			Break
	}
	Loop, %ROWS%
	{
		DEMpos := FLTobj.Pos
		progress, %DEMpos%
			Row := A_Index
			Loop, %CLMN%
			{
				Col += 1
				DEM[Col,Row] := FLTobj.ReadFloat()
			}
			Col = 0
	}
	DEM.SetCapacity(0)
	FLTobj.close()
	HDRobj.close()
	return DEM
}
Read_ASC4Array_Object(ASCvarPATH) {
	global
	
	aSpace := A_space
	DEM := Object()
	ASCobj := fileopen(ASCvarPATH, "rw")
	DEMlen := ASCobj.Length
	If (DEMlen > 3617587200)
	{
		msgbox, Whoa!  That's a big ASCII...try a smaller one before you burn the place down.
		ExitApp
	}
	progress, R0-%DEMlen%, , Building DEM Array, INS 2 Swath
	Loop
	{
		DEMline := ASCobj.ReadLine()
		DEMpos := ASCobj.Pos
		progress, %DEMpos%
		If (A_Index = 1)
		{
			StringSplit, COL, DEMline, %A_Space%
			CLMN := Round(COL2)
			continue
		}
		Else If (A_Index = 2)
		{
			StringSplit, ROW, DEMline, %A_Space%
			ROWS := Round(ROW2)
			continue
		}
		Else If (A_Index = 3)
		{
			StringSplit, XL, DEMline, %A_Space%
			XLLC := Round(XL2)
			continue
		}
		Else If (A_Index = 4)
		{
			StringSplit, YL, DEMline, %A_Space%
			YLLC := Round(YL2)
			continue
		}
		Else If (A_Index = 5)
		{
			StringSplit, CS, DEMline, %A_Space%
			CSize := Round(CS2), XURC := XLLC+(CSize*CLMN), YURC := YLLC+(CSize*ROWS)
			continue
		}
		Else If (A_Index = 6)
		{
			IfNotInString, DEMline, NODATA_value
			{
				Row := A_Index
				Loop, Parse, DEMline, %aSpace%
				{
					Col += 1
					DEM[Col, Row] := A_LoopField
				}
				If !First
				{
					First := True
					ColCount := Col
				}
				Col = 0, NODATA := ""
			}
			else
			{
				StringSplit, NOD, DEMline, %A_Space%
				NODATA := NOD2
				continue
			}
		}
		Else
		{
				Row := A_Index
				Loop, Parse, DEMline, %aSpace%
				{
					Col += 1
					DEM[Col, Row] := A_LoopField
				}
				If !First
				{
					First := True
					ColCount := Col
				}
				Col = 0
		}
		IsAtEOF := ASCobj.AtEOF
		If (ASCobj.AtEOF != 0)
			Break
	}

}
Bilinear_Interpolation_Point(xLeft,xRight,yLower,X,Y,yUpper,valueUL,valueLL,valueUR,valueLR) {
		
		R1 := (((xRight-X)/(xRight-xLeft))*valueLL) + (((X-xLeft)/(xRight-xLeft))*valueLR)
		R2 := (((xRight-X)/(xRight-xLeft))*valueUL) + (((X-xLeft)/(xRight-xLeft))*valueUR)
		P := ((yUpper-Y)/(yUpper-yLower))*R1 + ((Y-yLower)/(yUpper-yLower))*R2
		
		;~ stepX := (abs(xLeft-xRight)/resolution)
		;~ stepY := (abs(yLower-yUpper)/resolution)
		
		;~ xScale := 0
		;~ loop % stepX
		;~ {
			;~ ++xScale
			;~ X := (xLeft+(resolution*xScale))
			;~ R1 := (((xRight-X)/(xRight-xLeft))*valueLL) + (((X-xLeft)/(xRight-xLeft))*valueLR)
			;~ R2 := (((xRight-X)/(xRight-xLeft))*valueUL) + (((X-xLeft)/(xRight-xLeft))*valueUR)
			
			;~ yScale := 0
			;~ Loop % stepY
			;~ {
				;~ ++yScale
				;~ Y := (yLower+(resolution*yScale))
				;~ P := ((yUpper-Y)/(yUpper-yLower))*R1 + ((Y-yLower)/(yUpper-yLower))*R2
				;~ grid[xScale,yScale] := [X,Y,P]
				;~ ListVars
				;~ msgbox
			;~ }
		;~ }
		;~ grid.col := stepX
		;~ grid.row := stepY
		;~ grid.llx := xLeft
		;~ grid.lly := yLower
		;~ grid.res := resolution
		return P
	}
FindPointZ_ASCDEM(x,y,z,p,r,h,FoV,columns,rows,xllc,yllc,xurc,yurc,arrayName,Omega,Phi,Kappa,DZ,cellSize:=10,K180:=0,nodata:="") {
	global																;~ set function variables to GLOBAL USE! ~~~
	If (K180 = 0)														;~ Check Kappa reference-to-aircraft rotations ~~~
		K := 1
	If (K180 = 180)
		K := -1
		
	r := (r*(K))+Omega, 
	p := (p*(K))+Phi,
	h := h+Kappa+K180													;~ Set final rotations with boresight angles ~~~
	
	If (x > xurc OR x < xllc)											;~ is position outside DEM bounds ~~~
	{
		;~ progress, w500, , POS position (%x%`, %y%) is out of DEM bounds`nLL: %xllc%`, %yllc%`nUR: %xurc%`, %yurc%, INS 2 Swath
		;~ Msgbox, , ,POS position (%x%`, %y%) is out of DEM bounds`nLL: %xllc%`, %yllc%`nUR: %xurc%`, %yurc%, 0.0001
		goto, NoCoord
	}
	Else If (y > yurc OR y < yllc)										;~ is position outside DEM bounds ~~~
	{
		;~ progress, w500, , POS position (%x%`, %y%) is out of DEM bounds`nLL: %xllc%`, %yllc%`nUR: %xurc%`, %yurc%, INS 2 Swath
		;~ Msgbox, , ,POS position (%x%`, %y%) is out of DEM bounds`nLL: %xllc%`, %yllc%`nUR: %xurc%`, %yurc%, 0.0001
		goto, NoCoord
	}
	
		If (r > 0)														;~ If left wing up... ~~~
	{
		Corr_Right := PitchRollCorrectWeak(p,r,h,FoV)					;~ Get Azimuth and Angle from nadir for "weak" side (right)
		Corr_Left := PitchRollCorrectStrong(p,r,h,FoV)					;~ Get Azimuth and Angle from nadir for "strong" side (left)
		
		StringSplit, CR, Corr_Right, `,
		StringSplit, CL, Corr_Left, `,
		
		CRaz := CR1*0.01745329251
		, CRang := CR2*0.01745329251
		, CLaz := CL1*0.01745329251
		, CLang := CL2*0.01745329251
		
		If (CR1 > 180)													;~ Adjust X/Y for each corrected azimuth
			XswitchR := (-1)
		else
			XswitchR := 1
		If (CR1 > 90 AND CR1 < 270)
			YswitchR := (-1)
		else
			YswitchR := 1
		If (CL1 > 180)
			XswitchL := (-1)
		else
			XswitchL := 1
		If (CL1 > 90 AND CL1 < 270)
			YswitchL := (-1)
		else
			YswitchL := 1
	}
	else if (r < 0)
	{
		Corr_Left := PitchRollCorrectWeak(p,r,h,FoV)
		Corr_Right := PitchRollCorrectStrong(p,r,h,FoV)
		StringSplit, CR, Corr_Right, `,
		StringSplit, CL, Corr_Left, `,
		CRaz := CR1*0.01745329251, CRang := CR2*0.01745329251, CLaz := CL1*0.01745329251, CLang := CL2*0.01745329251
		If (CR1 > 180)
			XswitchR := (-1)
		else
			XswitchR := 1
		If (CR1 > 90 AND CR1 < 270)
			YswitchR := (-1)
		else
			YswitchR := 1
		If (CL1 > 180)
			XswitchL := (-1)
		else
			XswitchL := 1
		If (CL1 > 90 AND CL1 < 270)
			YswitchL := (-1)
		else
			YswitchL := 1
	}
	
	If (nodata = "")
		NDY := 0
	else if (nodata != "")
		NDY := 1
	
	XshiftN := ""
	, YshiftN := ""
	
	XshiftN := Round((x-xllc)/cellSize)
	, YshiftN := Round((rows+5+NDY)-((y-yllc)/cellSize))
	, NH := NumGet(arrayName[XshiftN, YshiftN], "Float")
	, NRange := z-NH
	
	Loop ; right side
	{
		Rmag := (cellSize*A_Index)
		, RrayZ := z-(Rmag/tan(CRang))
		, RX := x+(((Sin(CRaz))*(Rmag)))
		, RY := y+(((Cos(CRaz))*(Rmag)))
		, XshiftR := Round((RX-xllc)/cellSize)
		, YshiftR := Round((rows+5+NDY)-((RY-yllc)/cellSize))
		XshiftRup := Ceil((RX-xllc)/cellSize), ;~ Which column to shift to / left-most X
		YshiftRup := Ceil((rows+5+NDY)-((RY-yllc)/cellSize)), ;~ which row to shift to / top-most Y
		XshiftRdown := floor((RX-xllc)/cellSize), ;~ Which column to shift to / right-most X
		YshiftRDown := floor((rows+5+NDY)-((RY-yllc)/cellSize)), ;~ which row to shift to / bottom-most Y
		ulRZ := NumGet(arrayName[XshiftRdown, YshiftRup], "Float")
		urRZ := NumGet(arrayName[XshiftRup, YshiftRup], "Float")
		llRZ := NumGet(arrayName[XshiftRdown, YshiftRdown], "Float")
		lrRZ := NumGet(arrayName[XshiftRup, YshiftRdown], "Float")
		PreRZ := RZ,
		RZ := Bilinear_Interpolation_Point(XshiftRdown,XshiftRup,YshiftRDown,YshiftRup,RX,RY,ulRZ,llRZ,urRZ,lrRZ)
		;~ , RZ := NumGet(arrayName[XshiftR, YshiftR], "Float")
		PreRZDiff := RZDiff
		, RZDiff := RrayZ-RZ
	} Until (RZDiff <= 0)
	
	Loop ; left side
	{
		Lmag := (0.5*A_Index)
		, LrayZ := z-(Lmag/tan(CLang))
		, LX := x+(((Sin(CLaz))*(Lmag)))
		, LY := y+(((Cos(CLaz))*(Lmag)))
		, XshiftL := Round((LX-xllc)/cellSize)
		, YshiftL := Round((rows+5+NDY)-((LY-yllc)/cellSize))
		, PreLZ := LZ
		, LZ := NumGet(arrayName[XshiftL, YshiftL], "Float")
		, PreLZDiff := LZDiff
		, LZDiff := LrayZ-LZ
	} Until (LZDiff <= 0)
	
	Rslope := 3.14159265359-(Atan(cellSize/(RZ-PreRZ))+CRang)
	
	ABC_Z := RX . "," . RY . "," . "0" . " " . LX . "," . LY . "," . "0"
	return (ABC_Z)
	
	NoCoord:
	NRange := z-DZ
	Loop ; right side
	{
		Rmag := (cellSize*A_Index)
		, RrayZ := z-(Rmag/tan(CRang))
		, RX := x+(((Sin(CRaz))*(Rmag)))
		, RY := y+(((Cos(CRaz))*(Rmag)))
		, XshiftR := Round((RX-xllc)/cellSize)
		, YshiftR := Round((rows+5+NDY)-((RY-yllc)/cellSize))
		, RZ := NumGet(arrayName[XshiftR, YshiftR], "Float")
		, RZDiff := RrayZ-RZ
	} Until (RZDiff <= 0)
	
	Loop ; left side
	{
		Lmag := (cellSize*A_Index)
		, LrayZ := z-(Lmag/tan(CLang))
		, LX := x+(((Sin(CLaz))*(Lmag)))
		, LY := y+(((Cos(CLaz))*(Lmag)))
		, XshiftL := Round((LX-xllc)/cellSize)
		, YshiftL := Round((rows+5+NDY)-((LY-yllc)/cellSize))
		, LZ := NumGet(arrayName[XshiftL, YshiftL], "Float")
		, LZDiff := LrayZ-LZ
	} Until (LZDiff <= 0)
	return ("No")
}
						
/*
SetBatchLines, -1
#NoEnv
#maxmem 3500

FileSelectFile, FilePOS, M3, , Select Raw POS Files
IF (FilePOS = "")
	ExitApp

FileSelectFile, D, 3, , Select Arc GridFloat DEM, Float Grid (*.flt)
IF (D = "")
	ExitApp

;*****************************SETUP VARS*****************************
appendix := "20140813_BASF_Fargo_ND_4"

A_Omega := -0.421
A_Phi := 0.465
A_Kappa := -1.450
A_FieldofView := 25.37
A_rollSign := 1
A_pitchSign := 1
A_FOV_Offset := 0

B_Omega := -0.059
B_Phi := 0.1531
B_Kappa := -1.259
B_FieldofView := 21.6
B_rollSign := 1
B_pitchSign := 1
B_FOV_Offset := 0

C_Omega := -0.044 ;0.4033, 13.9704
C_Phi := -0.134 ;13.9704, 0.4033
C_Kappa := -0.067
C_FieldofView := 21
C_rollSign := 1
C_pitchSign := 1
C_FOV_Offset := 0

KappaRot := 180
DefaultZ := 300
UTM_Zone := 14
geoidCorrect := 26.4
filterLine := 25
subsampleRate := 0.5 ; POS record subsample interval (in seconds)

sensorA := "VNIR"
sensorB := "SWIR"
sensorC := "Orion_331"

;**********************************************************************


;~ Inputbox,  UTM_Zone, , Input UTM North Zone
loop, parse, FilePOS, `n
{
	++POScount
}

Read_FLT4Array_Object(D)
;~ Read_ASC4Array_Object(D)
KMLH =
(
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<StyleMap id="msn_ylw-pushpin_A">
		<Pair>
			<key>normal</key>
			<styleUrl>#sn_ylw-pushpin_A</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#sh_ylw-pushpin_A</styleUrl>
		</Pair>
	</StyleMap>
	<StyleMap id="msn_ylw-pushpin_B">
		<Pair>
			<key>normal</key>
			<styleUrl>#sn_ylw-pushpin_B</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#sh_ylw-pushpin_B</styleUrl>
		</Pair>
	</StyleMap>
	<StyleMap id="msn_ylw-pushpin_C">
		<Pair>
			<key>normal</key>
			<styleUrl>#sn_ylw-pushpin_C</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#sh_ylw-pushpin_C</styleUrl>
		</Pair>
	</StyleMap>
	<StyleMap id="msn_ylw-pushpin_OUT">
		<Pair>
			<key>normal</key>
			<styleUrl>#sn_ylw-pushpin_OUT</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#sh_ylw-pushpin_OUT</styleUrl>
		</Pair>
	</StyleMap>
	<Style id="sh_ylw-pushpin_A">
		<IconStyle>
			<scale>1.3</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<LineStyle>
			<color>FF0000FF</color>
			<width>0</width>
		</LineStyle>
		<PolyStyle>
			<color>90979797</color>
		</PolyStyle>
	</Style>
	<Style id="sn_ylw-pushpin_A">
		<IconStyle>
			<scale>1.1</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<LineStyle>
			<color>FF0000FF</color>
			<width>0</width>
		</LineStyle>
		<PolyStyle>
			<color>90FFFFFF</color>
		</PolyStyle>
	</Style>
	<Style id="sh_ylw-pushpin_B">
		<IconStyle>
			<scale>1.3</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<LineStyle>
			<color>FF00FF00</color>
			<width>0</width>
		</LineStyle>
		<PolyStyle>
			<color>90979797</color>
		</PolyStyle>
	</Style>
	<Style id="sn_ylw-pushpin_B">
		<IconStyle>
			<scale>1.1</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<LineStyle>
			<color>FF00FF00</color>
			<width>0</width>
		</LineStyle>
		<PolyStyle>
			<color>9000FFFF</color>
		</PolyStyle>
	</Style>
	<Style id="sh_ylw-pushpin_C">
		<IconStyle>
			<scale>1.3</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<LineStyle>
			<color>FFFF0000</color>
			<width>0</width>
		</LineStyle>
		<PolyStyle>
			<color>90979797</color>
		</PolyStyle>
	</Style>
	<Style id="sn_ylw-pushpin_C">
		<IconStyle>
			<scale>1.1</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<LineStyle>
			<color>FFFF0000</color>
			<width>0</width>
		</LineStyle>
		<PolyStyle>
			<color>90FF00FF</color>
		</PolyStyle>
	</Style>
	<Style id="sh_ylw-pushpin_OUT">
		<IconStyle>
			<scale>1.3</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/shapes/placemark_circle_highlight.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
	</Style>
	<Style id="sn_ylw-pushpin_OUT">
		<IconStyle>
			<scale>1.0</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/shapes/placemark_circle.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<LabelStyle>
			<scale>0</scale>
		</LabelStyle>
	</Style>
	<Style id="check-hide-children">
		<ListStyle>
			<listItemType>checkHideChildren</listItemType>
		</ListStyle>
	</Style>
<Folder>
	<name>FlightLine_Swaths</name>

)


progress, R0-%POScount%, POS File: %A_LoopField%, Parsing POS and Writing KML, INS 2 Swath
NoCount := 0, YesCount := 0
Loop, parse, FilePOS, `n
{
	
	If A_Index = 1
	{
		POSpath := A_LoopField
		output = %POSpath%\POS_Check_%appendix%_%sensorA%_%sensorB%_%sensorC%.kml
		FileDelete, %output%
		ProPOS := FileOpen(output, "w")
		ProPOS.Write(KMLH)
		continue
	}
	else
	{
		POSfile = %POSpath%\%A_LoopField%
		RAWPOS := FileOpen(POSfile, "rw")
		PreTimeCH := 0
		Loop
		{
			GRPMSGStart := ""
			GRPMSGStart := RAWPOS.Read(4)
			If (GRPMSGStart = "$GRP")
			{
				GRPMSGHeader()
				;~ IDlog = %IDlog%%GRPMSGID%`n
				If (GRPMSGID = 1)
				{
					GRP1Time1 := RAWPOS.ReadDouble()
					RAWPOS.Seek(18, 1)
					GRP1Lat := RAWPOS.ReadDouble()
					GRP1Lon := RAWPOS.ReadDouble()
					GRP1Alt := RAWPOS.ReadDouble()
					GRP1NVel := RAWPOS.ReadFloat()
					GRP1EVel := RAWPOS.ReadFloat()
					GRP1DVel := RAWPOS.ReadFloat()
					GRP1Roll := RAWPOS.ReadDouble()
					GRP1Pitch := RAWPOS.ReadDouble()
					GRP1Heading := RAWPOS.ReadDouble()
					GRP1Wander := RAWPOS.ReadDouble()
					GRP1Track := RAWPOS.ReadFloat()
					GRP1Speed := RAWPOS.ReadFloat()
					RAWPOS.Seek(30, 1)
					position := RAWPOS.Tell()

					TimeCH := GRP1Time1, TCheck := TimeCH-PreTimeCH
					If (TCheck >= subsampleRate)
					{
						PreTimeCH := TimeCH
						UTM := GPS_LatLon2UTM_CustomZone(GRP1Lat, GRP1Lon, UTM_Zone)
						stringsplit, U, UTM, `,
						NNorth := U1, NEast := U2
						HRate := abs((GRP1Heading-PreHeading))
						If (HRate > 100)
							HRate := HRate-360
						RRate := abs((GRP1Roll-PreRoll))
						PreRoll := GRP1Roll
						PreHeading := GRP1Heading
						;~ ListVars
						;~ msgbox,
						If (HRate > 0.6)
						{
							HcountN := 0
							++HcountY
						}
						else
						{
							HcountY := 0
							++HcountN
						}
						
						If (HcountY > 6)
							If (Go != "No")
								Go := "No", ++NoCount
						If (HcountN > 30)
							If (Go != "Yes")
								Go := "Yes", ++YesCount
						
						If (Go = "Yes")
						{
							A_FoV := FindPointZ_ASCDEM(NEast,NNorth,(GRP1Alt+geoidCorrect),(GRP1Pitch*A_pitchSign),(GRP1Roll*A_rollSign),GRP1Heading,A_FieldofView,CLMN,ROWS,XLLC,YLLC,XURC,YURC,DEM,A_Omega,A_Phi,A_Kappa,DefaultZ,CSize,KappaRot,NODATA)
							
							B_FoV := FindPointZ_ASCDEM(NEast,NNorth,(GRP1Alt+geoidCorrect),(GRP1Pitch*B_pitchSign),(GRP1Roll*B_rollSign),GRP1Heading,B_FieldofView,CLMN,ROWS,XLLC,YLLC,XURC,YURC,DEM,B_Omega,B_Phi,B_Kappa,DefaultZ,CSize,KappaRot,NODATA)
							
							C_FoV := FindPointZ_ASCDEM(NEast,NNorth,(GRP1Alt+geoidCorrect),(GRP1Pitch*C_pitchSign),(GRP1Roll*C_rollSign),GRP1Heading,C_FieldofView,CLMN,ROWS,XLLC,YLLC,XURC,YURC,DEM,C_Omega,C_Phi,C_Kappa,DefaultZ,CSize,KappaRot,NODATA)
							
								If (A_FoV != "No")
								{
									StringSplit, K, A_FoV, %A_Space%
									StringSplit, GeoAR, K1, `,
									A_Right := GPS_UTM2LatLon(GeoAR1, GeoAR2, N, UTM_Zone)
									StringSplit, GeoAL, K2, `,
									A_Left := GPS_UTM2LatLon(GeoAL1, GeoAL2, N, UTM_Zone)
									A_KML_Coord_%YesCount% := A_Right . "," . "0" . " " . A_KML_Coord_%YesCount% . " " A_Left . "," . "0"
									A_RightEnd_%YesCount% := A_Space . A_Right . "," . "0"
								}
								
								If (B_FoV != "No")
								{
									StringSplit, K, B_FoV, %A_Space%
									StringSplit, GeoBR, K1, `,
									B_Right := GPS_UTM2LatLon(GeoBR1, GeoBR2, N, UTM_Zone)
									StringSplit, GeoBL, K2, `,
									B_Left := GPS_UTM2LatLon(GeoBL1, GeoBL2, N, UTM_Zone)
									B_KML_Coord_%YesCount% := B_Right . "," . "0" . " " . B_KML_Coord_%YesCount% . " " B_Left . "," . "0"
									B_RightEnd_%YesCount% := A_Space . B_Right . "," . "0"
								}
								
								If (C_FoV != "No")
								{
								StringSplit, K, C_FoV, %A_Space%
								StringSplit, GeoCR, K1, `,
								C_Right := GPS_UTM2LatLon(GeoCR1, GeoCR2, N, UTM_Zone)
								StringSplit, GeoCL, K2, `,
								C_Left := GPS_UTM2LatLon(GeoCL1, GeoCL2, N, UTM_Zone)
								C_KML_Coord_%YesCount% := C_Right . "," . "0" . " " . C_KML_Coord_%YesCount% . " " C_Left . "," . "0"
								C_RightEnd_%YesCount% := A_Space . C_Right . "," . "0"
								}
								
								If (B_FoV != "No" OR A_FoV != "No" OR C_FoV != "No") ; Comment out A, B, or C if you are adjusting number of different swaths
									FilterCount_%YesCount% += 1
								else
								{ 
									outsidePts .= "<Placemark><name>" . GRP1Time1 . "</name><styleUrl>msn_ylw-pushpin_OUT</styleUrl><Point><coordinates>" . GRP1Lon . "," . GRP1Lat . "," . "0" . "</coordinates></Point></Placemark>" . "`r`n"
								}
						}

					}
					continue
				}
				else
					RAWPOS.Seek(GRPMSGBCount, 1)
			}
			else if (GRPMSGStart = "$MSG")
			{
				GRPMSGHeader()
				RAWPOS.Seek(GRPMSGBCount, 1)
				continue
			}
				
			If RAWPOS.AtEOF
				Break
		}
		RAWPOS.Close()
	}
	progress, %A_Index%, POS File: %A_LoopField%, Parsing POS and Writing KML, INS 2 Swath
}

Loop, %YesCount%
{
	If FilterCount_%A_Index% < %filterLine%
		continue
	A_KML_Coord := A_KML_Coord_%A_Index% . " " . A_RightEnd_%A_Index%
	, B_KML_Coord := B_KML_Coord_%A_Index% . " " . B_RightEnd_%A_Index% 
	, C_KML_Coord := C_KML_Coord_%A_Index% . " " . C_RightEnd_%A_Index%
	
	KMLA =
	(
		<Placemark>
		<name>%sensorB%_%A_Index%</name>
			<styleUrl>#msn_ylw-pushpin_A</styleUrl>
			<Polygon>
				<tessellate>1</tessellate>
				<outerBoundaryIs>
					<LinearRing>
						<coordinates>
							%A_KML_Coord%
						</coordinates>
					</LinearRing>
				</outerBoundaryIs>
			</Polygon>
		</Placemark>

	)
	
	KMLB =
	(
		<Placemark>
			<name>%sensorA%_%A_Index%</name>
			<styleUrl>#msn_ylw-pushpin_B</styleUrl>
			<Polygon>
				<tessellate>1</tessellate>
				<outerBoundaryIs>
					<LinearRing>
						<coordinates>
							%B_KML_Coord%
						</coordinates>
					</LinearRing>
				</outerBoundaryIs>
			</Polygon>
		</Placemark>
		
	)
	
	KMLC =
	(
		<Placemark>
		<name>%sensorC%_%A_Index%</name>
			<styleUrl>#msn_ylw-pushpin_C</styleUrl>
			<Polygon>
				<tessellate>1</tessellate>
				<outerBoundaryIs>
					<LinearRing>
						<coordinates>
							%C_KML_Coord%
						</coordinates>
					</LinearRing>
				</outerBoundaryIs>
			</Polygon>
		</Placemark>

	)
	
	kmlEndA .= KMLA
	kmlEndB .= KMLB
	kmlEndC .= KMLC
}

End =
(
	<Folder><name>Points Outside DEM</name>
	%outsidePts%
	</Folder>
	<Folder><name>%sensorA%_Swath</name>
	%kmlEndA%
	</Folder>
	<Folder><name>%sensorB%_Swath</name>
	%kmlEndB%
	</Folder>
	<Folder><name>%sensorC%_Swath</name>
	%kmlEndC%
	</Folder>
	</Folder>
	</Document>
	</kml>
)
ProPOS.Write(End)
ProPOS.Close()
progress, Off
progress, 100, , Done!, INS 2 Swath
sleep, 2000
Exit
*/
