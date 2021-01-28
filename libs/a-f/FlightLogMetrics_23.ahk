	PitchRollCorrectStrong(Pitch,Roll,Heading,FoV) {
		global
		
		FixedR := Abs(Roll), FoVR := (FoV/2)+FixedR
		Ang := sqrt(FoVR**2+Pitch**2)
		AzCorr := (atan((abs(Pitch*0.01745329251))/(abs(FoVR*0.01745329251))))*57.2957795131
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

	PitchRollCorrectWeak(Pitch,Roll,Heading,FoV) {
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
					DEM[Col, Row] := FLTobj.ReadFloat()
				}
				Col = 0
		}
		FLTobj.close()
		HDRobj.close()
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
		
	FindPointZ_ASCDEM(x,y,z,p,r,h,FoV,columns,rows,xllc,yllc,xurc,yurc,arrayName,Omega,Phi,Kappa,DZ,cellSize:=10,K180:=0,nodata:="") {
		global
		K := K180=180 ? -1 ? 1			;~ set up kappa rotation setting
			
		r := (r*(K))+Omega, 			;~ set up attitude with boresight rotations
		p := (p*(K))+Phi, 
		h := h+Kappa+K180
		
		If (x > xurc || x < xllc || y > yurc || y < yllc) {				;~ is this positon outside of DEM / if so, go to "NoCoord"
			progress, w500, , POS position (%x%`, %y%) is out of DEM bounds`nLL: %xllc%`, %yllc%`nUR: %xurc%`, %yurc%, INS 2 Swath
			goto, NoCoord
		}
		
		If (r > 0) {					;~ Right wing down / right side "weak"
			Corr_Right := PitchRollCorrectWeak(p,r,h,FoV)
			Corr_Left := PitchRollCorrectStrong(p,r,h,FoV)
		}
		else if (r < 0)	{				;~ Right wing up / right side "strong"
			Corr_Left := PitchRollCorrectWeak(p,r,h,FoV)
			Corr_Right := PitchRollCorrectStrong(p,r,h,FoV)
		}
		
		StringSplit, CR, Corr_Right, `,
		StringSplit, CL, Corr_Left, `,
		
		CRaz := CR1*0.01745329251, 
		CRang := CR2*0.01745329251, 
		CLaz := CL1*0.01745329251, 
		CLang := CL2*0.01745329251
		
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

		NDY := nodata="" ? 0 : 1
		
		XshiftN := "", 
		YshiftN := "",
		XshiftN := Round((x-xllc)/cellSize), 
		YshiftN := Round((rows+5+NDY)-((y-yllc)/cellSize)),
		NH := arrayName[XshiftN, YshiftN],
		NRange := z-NH
		
		Loop ; right side
		{
			Rmag := (cellSize*A_Index),
			RrayZ := z-(Rmag/tan(CRang)),
			RX := x+(((Sin(CRaz))*(Rmag))),
			RY := y+(((Cos(CRaz))*(Rmag))),
			XshiftR := Round((RX-xllc)/cellSize),
			YshiftR := Round((rows+5+NDY)-((RY-yllc)/cellSize)),
			PreRZ := RZ,
			RZ := arrayName[XshiftR, YshiftR],
			PreRZDiff := RZDiff,
			RZDiff := RrayZ-RZ
		} Until (RZDiff <= 0)
		
		Loop ; left side
		{
			Lmag := (cellSize*A_Index), 
			LrayZ := z-(Lmag/tan(CLang)), 
			LX := x+(Sin(CLaz)*Lmag), 
			LY := y+(Cos(CLaz)*Lmag),
			XshiftL := Round((LX-xllc)/cellSize), 
			YshiftL := Round((rows+5+NDY)-((LY-yllc)/cellSize)), 
			PreLZ := LZ, 
			LZ := arrayName[XshiftL, YshiftL], 
			PreLZDiff := LZDiff, 
			LZDiff := LrayZ-LZ
		} Until (LZDiff <= 0)
		
		Rslope := 3.14159265359-(Atan(cellSize/(RZ-PreRZ))+CRang)
		
		ABC_Z := RX . "," . RY . "," . "0" . " " . LX . "," . LY . "," . "0"
		return (ABC_Z)
		
		NoCoord:
		NRange := z-DZ
		Loop ; right side
		{
			Rmag := (cellSize*A_Index), 
			RrayZ := z-(Rmag/tan(CRang)), 
			RX := x+(((Sin(CRaz))*(Rmag))), 
			RY := y+(((Cos(CRaz))*(Rmag))), 
			RZ := arrayName[XshiftR, YshiftR], 
			RZDiff := RrayZ-RZ
		} Until (RZDiff <= 0)
		
		Loop ; left side
		{
			Lmag := (cellSize*A_Index), 
			LrayZ := z-(Lmag/tan(CLang)), 
			LX := x+(((Sin(CLaz))*(Lmag))), 
			LY := y+(((Cos(CLaz))*(Lmag))),
			XshiftL := Round((LX-xllc)/cellSize), 
			YshiftL := Round((rows+5+NDY)-((LY-yllc)/cellSize)), 
			LZ := arrayName[XshiftL, YshiftL], 
			LZDiff := LrayZ-LZ
		} Until (LZDiff <= 0)
		return ("No")
	}
	
	Bilinear_Interpolation(xLeft,xRight,yLower,yUpper,valueUL,valueLL,valueUR,valueLR,resolution) {
		grid := object()
		
		stepX := (abs(xLeft-xRight)/resolution)
		stepY := (abs(yLower-yUpper)/resolution)
		
		xScale := 0
		loop % stepX
		{
			++xScale
			X := (xLeft+(resolution*xScale))
			R1 := (((xRight-X)/(xRight-xLeft))*valueLL) + (((X-xLeft)/(xRight-xLeft))*valueLR)
			R2 := (((xRight-X)/(xRight-xLeft))*valueUL) + (((X-xLeft)/(xRight-xLeft))*valueUR)
			
			yScale := 0
			Loop % stepY
			{
				++yScale
				Y := (yLower+(resolution*yScale))
				P := ((yUpper-Y)/(yUpper-yLower))*R1 + ((Y-yLower)/(yUpper-yLower))*R2
				grid[xScale,yScale] := [X,Y,P]
				;~ ListVars
				;~ msgbox
			}
		}
		grid.col := stepX
		grid.row := stepY
		grid.llx := xLeft
		grid.lly := yLower
		grid.res := resolution
		return grid
	}
			
	Haversine(lat1,lat2,long1,long2) {
		If (long1 < 0)
			long1 := long1*(-1)
		If (long2 < 0)
			long2 := long2*(-1)
		dlat := (lat2-lat1)*0.01745329252
		dlong := (long2-long1)*0.01745329252
		lat1 := lat1*0.01745329252
		lat2 := lat2*0.01745329252
		
		a := sqrt((Sin(dlat/2)*Sin(dlat/2))+((Sin(dlong/2)*Sin(dlong/2))*cos(lat1)*Cos(lat2)))
		c := 2*Atan(a)
		return (6362.697*c)*1000
	}
	
	LatLongArea(lat,long,prelat,prelong,preprelat,preprelong) {
		long := sqrt(long**2)
		prelong := sqrt(prelong**2)
		preprelong := sqrt(preprelong**2)
		deg := (0.01745329251994329576923690768489*(long-prelong))*(2+sin(0.01745329251994329576923690768489*prelat)+sin(0.01745329251994329576923690768489*lat))+(0.01745329251994329576923690768489*(prelong-preprelong))*(2+sin(0.01745329251994329576923690768489*preprelat)+sin(0.01745329251994329576923690768489*prelat))+(0.01745329251994329576923690768489*(preprelong-long))*(2+sin(0.01745329251994329576923690768489*lat)+sin(0.01745329251994329576923690768489*preprelat))
		return abs(((deg*(6362697**2))/2.0)/1000000)
	}
	
	UTC2GPSWeekW(FormattedTime) {
		FormattedTime -= 19800106000000, Days
		FormattedTime := Floor(FormattedTime/7)
	
		return (FormattedTime)
	}
	
	UTC2GPSWeekS(FormattedTime)	{
		Week := FormattedTime
		Week -= 19800106000000, Days
		Week := Floor(Week/7)
		Days := Week*7
		DateTime = 19800106000000
		DateTime += Days, Days
		FormattedTime -= DateTime, Seconds
		
		return (FormattedTime)
	}
	
	simpleReplace(inputVar,Original,Replacement) {
		zero := inputVar
		, one := Original
		, two := Replacement
		StringReplace, three, zero, %one%, %two%, All
		return (three)
	}
	
	Arr_concatenate(p*) {
    res := Object()
    For each, obj in p
        For each, value in obj
            res.Insert(value)
    return res
	}
	
	PolyFromScan(ptPos,ptNeg) {
		res := object()
		j := ptNeg.maxindex()
		Loop % ptPos.maxindex()
		{
			++i
			res.Insert(ptPos[i])
		}
		Loop % ptNeg.maxindex()
		{
			res.Insert(ptNeg[j])
			--j
		}
		return (res)
	}
	
	PolyArea(xArray,yArray,numOfPoints) {
		area := 0
		, j := numOfPoints
		
		Loop
		{
			i := a_index
			area := area + ((xArray[j]+xArray[i])*(yArray[j]-yArray[i]))
			, j := i
		} Until (i >= numOfPoints)
		
		return (abs(area/2))
	}
	
	convexHull(allXArray,allYArray) {			;~ Jarvis marching or gift-wrapping convex hull.
		
		xLeft := allXArray[1]			;~ First identify left most point
		, yLeft := allYArray[1]
		loop % allXArray.MaxIndex()
		{
			If (allXArray[a_index] < xLeft) {
				xLeft := allXArray[a_index]
				, yLeft := allYArray[a_index]
			} 
		}
		
		pointOnHull := [xLeft,yLeft]
		, P := []
		
		Loop
		{
			firstLoop := a_index
			, P[firstLoop] := pointOnHull
			, endPoint := [allXArray[firstLoop],allYArray[firstLoop]]
			Loop % allXArray.MaxIndex()
			{
				turn := ((endPoint[1]-P[firstLoop][1])*(allYArray[a_index]-P[firstLoop][2])-(allXArray[a_index]-P[firstLoop][1])*(endPoint[2]-P[firstLoop][2]))>0 ? "Left" : ((endPoint[1]-P[firstLoop][1])*(allYArray[a_index]-P[firstLoop][2])-(allXArray[a_index]-P[firstLoop][1])*(endPoint[2]-P[firstLoop][2]))<0 ? "Right" : "None" ;~ ((1to2 difference in X) * (1to3 difference in Y)) - ((1to3 difference in X) * (1to2 difference in Y))
				;~ msgbox % turn . "," . endPoint[1] . "," . pointOnHull[1]
				If (endPoint = pointOnHull || turn = "Left")
					endPoint := [allXArray[a_index],allYArray[a_index]]
			}
				pointOnHull := endPoint
				
		} Until (endPoint[1] = P[1][1] && endPoint[2] = P[1][2])
		
		loop % P.maxindex()
			;~ msgbox % P.maxindex() . "," . P[a_index][1] . "," . P[a_index][2]
		
		return (P)
	}
		
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
	
	GPS_LatLon2UTM_Option(Latitude, Longitude, Option) {
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
	   
	   If (Option = "")
			Return Northing . "`," . Easting . "`," . Longitude_Zone
	   else If (Option = 1)
			Return Northing . "`," . Easting
	   else If (Option = 2)
			Return Northing
	   else If (Option = 3)
			Return Easting
	   else If (Option = 4)
			Return Longitude_Zone
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
	
	GPS_LatLon2UTM_CustomZone_Option(Latitude, Longitude, RequestedZone, Option) {
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
	   
	   If (Option = "")
			Return Northing . "`," . Easting . "`," . Longitude_Zone
	   else If (Option = 1)
			Return Northing . "`," . Easting
	   else If (Option = 2)
			Return Northing
	   else If (Option = 3)
			Return Easting
	   else If (Option = 4)
			Return Longitude_Zone
	}
	
	GPS_LatLon2UTM_Zone(Latitude, Longitude) {
		If (Longitude/6) < 0
	   {
		  Longitude_Zone := 31 + Floor(Longitude/6)
	   }
	   Else
	   {
		  Longitude_Zone := Round(31+Substr((Longitude/6), 1, InStr((Longitude/6), ".")))
	   }
	   return Longitude_Zone
	}

/*
#NoEnv
SetBatchLines, -1
#MaxMem 512
Gui, Add, GroupBox, x2 y0 w90 h130 +Disabled, Select Laser
Gui, Add, Radio, x12 y20 w70 h20 vSN094 +Disabled, SN094
Gui, Add, Radio, x12 y40 w70 h20 vSN054 +Disabled, SN054
Gui, Add, Radio, x12 y60 w70 h20 vSN105 +Disabled, SN105
Gui, Add, Radio, x12 y80 w70 h20 vSN106 +Disabled, SN106
Gui, Add, Radio, x12 y100 w70 h20 vSN7131 +Disabled, SN7131
Gui, Add, GroupBox, x102 y0 w420 h60 , Select FlightLog
Gui, Add, Edit, x122 y30 w310 h20 vSelectedFile, FlightLog
Gui, Add, Button, x452 y30 w60 h20 gBrowseF, Browse
Gui, Add, Button, x432 y390 w90 h20 gOK1, OK
Gui, Add, Button, x432 y420 w90 h20 , Cancel
Gui, Add, GroupBox, x102 y60 w420 h70 , Flight Settings
;~ Gui, Add, DropDownList, x112 y90 w90 h20 vOver +R5, 5|10|15|20|25|30|35|40|45|50|55|60||65|70|75|80|85|90|95|
Gui, Add, Text, x172 y103 w20 h20 , `%
Gui, Add, CheckBox, x392 y80 w110 h20 vDLS, Daylight Savings?
Gui, Add, Progress, x12 y390 w400 h20 vMyProgress -Smooth, 5
Gui, Add, Text, x12 y410 w400 h20 vProgressText, Setup Inputs
Gui, Add, Edit, x112 y100 w60 h20 vOver, 60.0
Gui, Add, Text, x112 y80 w90 h20 , Planned Overlap?
Gui, Add, DropDownList, x432 y250 w100 h20 vColor +R6, Red|Orange|Yellow||Green|Blue|Violet|
Gui, Add, Text, x452 y230 w60 h20 , KML Color?
Gui, Add, Edit, x212 y100 w60 h20 vPAGL +Disabled, 900
Gui, Add, Text, x272 y103 w20 h20 +Disabled, m
Gui, Add, Text, x212 y80 w80 h20 +Disabled, Planned AGL?
Gui, Add, ListBox, x12 y160 w400 h220 vFLPro +Multi , Flightlines to process...
Gui, Add, Text, x12 y140 w400 h20 , After parsing logfile`, please select flightlines for processing...
Gui, Add, Button, x432 y140 w90 h20 gParseF, Parse
Gui, Add, Button, x432 y170 w90 h20 gClearF, Clear
Gui, Add, Text, x302 y80 w80 h20 , Platform?
Gui, Add, DropDownList, x302 y100 w80 h21 +R6 vPlat, 704MD||604MD|32K|02L|0LF|801CL|
; Generated using SmartGUI Creator 4.0
Gui, Show, x127 y87 h460 w544, LogFile Metrics Setup
return

ParseF:
Gui, Submit, NoHide
GuiControl, -Redraw, FLPro 
GoSub, Parse
GuiControl, , FLPro, |%IDNumLog%
GuiControl, +Redraw, FLPro 
return

ClearF:
GuiControl, , FLPro,  |Flightlines to process...
return

BrowseF:
FileSelectFile, SelectedFile, 3, , Open LogFile TXT, TXT Document (*.txt)
if SelectedFile =
{
return
}
GuiControl, , SelectedFile, %SelectedFile%
Return

ButtonCancel:
GuiClose:
ExitApp

OK1:
Gui, Submit, NoHide

If (Color = "Yellow")
	Color = 7f00ffff
If (Color = "Red")
	Color = 7f0000ff
If (Color = "Green")
	Color = 7f00ff00
If (Color = "Orange")
	Color = 7f0096ff
If (Color = "Blue")
	Color = 7fff5500
If (Color = "Violet")
	Color = 7fff008a

cvArr := {}
, cvArr.total := 0
intCoord := object()

ReflyCount := 0
StringReplace, FLPro, FLPro, |, `n, All

SplitPath, SelectedFile, wExt, Dir, Ext, noExt
FileRead, Flog, %SelectedFile%
StringReplace, Flog, Flog, `r`n`r`n, `n, All

Loop, parse, Flog, `n, `r										; check system version / log version / system SN 
{
	sysCheck := strsplit(A_LoopField, ",")
	If InStr(sysCheck[4], "Msg 4002")
	{
		RegExMatch(sysCheck[4], "(.\..\..\..)", sysCheckM)
		sysCheckV := strsplit(sysCheckM1, ".")
		If (sysCheckV[1] >= 7) && (sysCheckV[2] = 2) {
			sysVersion := 1
			sysName := substr(sysCheck[16], 13)
			If !sysName
				continue
			else
				Break
		}
		If (sysCheckV[1] >= 7) && (sysCheckV[2] = 3) {
			sysVersion := 2
			sysName := substr(sysCheck[16], 13)
			If !sysName
				continue
			else
				Break
		}
		If (sysCheckV[1] >= 7) && (sysCheckV[2] > 3) {
			sysVersion := 3
			sysName := substr(sysCheck[16], 13)
			If !sysName
				continue
			else
				Break
		}
		else
			continue
	}
}


If (sysVersion = 1)
{

Guicontrol, , MyProgress, 30
Guicontrol, , ProgressText, Filtering Selected Lines

		
Loop, parse, Flog, `n										;~ Parse the Raw Log and create cvArr Object
{
	recArr := strsplit(A_LoopField, ",")

	If InStr(recArr[4], "Msg 2009") {
		If (recArr[6] = "NIDAQ: on") {
			++FirstRecord
			If (FirstRecord > 2) {
				Record := "on"
				, Line := strsplit(recArr[7], a_space)
				, ID := strsplit(recArr[8], a_space)
				, LineNum := Line[4]
				, IDNum := ID[4]
				, LastRecord := 0
			}
		}			
		else if (recArr[6] = "NIDAQ: off") {
			++LastRecord
			If (LastRecord > 2) {
				Record := "off"
				, FirstRecord := 0
				, logStatIndex := 0
			}
		}
	}
	

	If (Record = "on") {
		
		If !isobject(logStat)																					;~ Check if logstat is an object / if not , create an object
			logStat := object()
		If instr(recArr[4], "Msg 4005") {																		;~ If record array [4] has "Msg 4005"
			If instr(recArr[8], "FOV:") {																		;~ AND if record array [8] has "FOV:"
				recArr8 := simpleReplace(recArr[8],"   "," ")													;~ replace multi-space with single-space delimited
				recArr8 := simpleReplace(recArr8,"  "," ")
				
				4005FOV := strsplit(recArr8, a_space)															;~ new 4005FOV array from recArr8 entry
				If (4005FOV[9] != 0) {																			;~ If nadir Range from Msg 4005 != 0 , then check if it is a new round of Msg -->
																												;~ 4005's between Msg 2002 rounds and collect PR's , FOV's, and Nadir ranges for distribution to the next set of Msg 2002's.
					;~ If (FOVCount = 0) {	
																								;~ If it is a new round of Msg 4005's, reset logStat object, and fiveSec / fiveSecC counters
						;~ logStat := object()
						;~ , fiveSec := 0
						;~ , fiveSecC := 0
					;~ }
					;~ ++FOVCount
					++logStatIndex	
					logStat.PR[LineNum,logStatIndex] := 4005FOV[7]
					logStat.FOV[LineNum,logStatIndex] := 4005FOV[3]
					logStat.Nadir[LineNum,logStatIndex] := 4005FOV[9]
					logStat.pfnCount[LineNum] := logStatIndex
				}
			}
			If instr(recArr[8], "Rng Crd 1 data") {																;~ If Msg 4005 has "Rng Crd 1 Data" in the string...
				recArr8 := simpleReplace(recArr[8],"   "," ")													;~ replace multi-space with single-space delimited
				recArr8 := simpleReplace(recArr8,"  "," ")
				
				4005Range := strsplit(recArr8, a_space)														;~ split recArr8 to get Percent of ranges collected per second
				If (4005Range[8] != 0) {
					logStat.Percent[LineNum,logStatIndex] := 4005Range[8]
				}
			}
			else
				continue
		}
		If instr(recArr[4], "Msg 2002") {																		;~ If record array [4] has "Msg 2002"
			If instr(FLPro, LineNum) {																			;~ Check if the current Line number was selected in the GUI for processing.  If not, don't log it.
				logRAW := strsplit(a_loopfield, ",")															;~ Split up Msg 2002's...
					
				cvArr.total += 1
				If (cvArr.total = 1)
					utmZone := GPS_LatLon2UTM_Zone(logRAW[6], logRAW[5])
				
				cvArr.lineNum[cvArr.total] 				:= LineNum
				, cvArr.ID[cvArr.total] 				:= ID[4]
				, cvArr.tStamp[cvArr.total] 			:= logRAW[1]
				, cvArr.tWeek[cvArr.total] 				:= logRAW[2]
				, cvArr.tgpsStamp[cvArr.total] 			:= logRAW[3]
				, cvArr.Lon[cvArr.total] 				:= logRAW[5]
				, cvArr.Lat[cvArr.total] 				:= logRAW[6]
				, cvArr.Alt[cvArr.total] 				:= logRAW[7]
				, cvArr.Int[cvArr.total] 				:= logRAW[8]
				, cvArr.Angle[cvArr.total] 				:= logRAW[10]
				, cvArr.East[cvArr.total]				:= GPS_LatLon2UTM_CustomZone_Option(logRAW[6],logRAW[5],utmZone,3)
				, cvArr.North[cvArr.total]				:= GPS_LatLon2UTM_CustomZone_Option(logRAW[6],logRAW[5],utmZone,2)
				, cvArr.Zone[cvArr.total]				:= utmZone
			}	
		}
			
	}
}


loop % cvArr.total											 ;~ New set up for interpolated formatted time Object for main procedure
{
	If (A_Index = 1) {
		coordEntry := 1
		cvArr.relationship[a_index] := "First"
		cvArr.tFormatRel[a_index] := "First"
		continue
	}
	
	If (cvArr.lineNum[a_index-1] != cvArr.lineNum[a_index]) {		;~ check for individual line starts and ends / Mark them for use further on
		cvArr.relationship[a_index] := "First"
		, cvArr.relationship[a_index-1] := "Last"
	} else {
		cvArr.relationship[a_index] := "Same"
	}

	CVT := "20" . (simpleReplace(cvArr.lineNum[a_index],"_",""))		;~ convert previous line, current line, and end of line time stamps to time format
	, PreCVT := "20" . (simpleReplace(cvArr.lineNum[a_index-1],"_",""))
	, endCVT := "20" . (simpleReplace(cvArr.tStamp[a_index-1],"_",""))
		
	++coordEntry														;~ count number of coordinate pairs while online
	

	If (PreCVT != CVT OR a_index = cvArr.total) {						;~ get difference between line ID and last timestamp (giving duration of line)
		
		endCVTtemp := endCVT
		PreCVTtemp := PreCVT
		
		endCVTtemp -= PreCVTtemp, Seconds
		CVTDiv := endCVTtemp/coordEntry								;~ get rate of coordinate change by dividing duration of line by number of coordinate pairs.
		
		logStatCVTDiv := logStat.pfnCount[cvArr.lineNum[a_index-1]]/coordEntry		;~ get rate of coordinate change by dividing characteristic counts by number of coordinate pairs.
		intCoordStep := a_index-1
		
		Loop
		{
			++intCoordCount
			intCoord.lineNum[intCoordCount] := cvArr.lineNum[intCoordStep]
			, intCoord.cvtDiv[intCoordCount] := CVTDiv
			, intCoord.logStatcvtDiv[intCoordCount] := logStatCVTDiv
			, intCoord.coordEntry[intCoordCount] := coordEntry
			, --coordEntry
			;~ ListVars
			;~ msgbox % intCoord.lineNum[intCoordCount] . "`n" . intCoord.cvtDiv[intCoordCount] . "`n" . intCoord.coordEntry[intCoordCount] . "`n" . cvArr.lineNum[intCoordStep] . "`n" . cvArr.relationship[intCoordStep]
		} Until (coordEntry = 0)
	}
	
}


loop % cvArr.total											;~ New Interpolated formatted time Object for main procedure
{
	If (cvArr.lineNum[a_index-1] != cvArr.lineNum[a_index])
		TMult := 0
	
	++TMult
	AddT := Round(intCoord.cvtDiv[a_index]*TMult)												;~ Each record number times rate of time change distributes seconds across line
	;~ AddC := Round(intCoord.logStatcvtDiv[a_index]*TMult) < 1 ? 1 : Round(intCoord.logStatcvtDiv[a_index]*TMult)
	AddC := Ceil(intCoord.logStatcvtDiv[a_index]*TMult)
	
	CVar1Temp := "20" . (simpleReplace(cvArr.lineNum[a_index],"_",""))
	CVar1Temp += AddT, Seconds
	Atest := CVar1Temp
	, GPSconvertS := UTC2GPSWeekS(CVar1Temp)
	, GPSconvertW := UTC2GPSWeekW(CVar1Temp)
	
	FormatTime, CVar1Formatted, %CVar1Temp%, yyyy-MM-ddTHH:mm:ssZ
	
	cvArr.timeUTC[a_index] := CVar1Temp
	, cvArr.tFormat[a_index] := CVar1Formatted
	, cvArr.gpsW[a_index] := GPSconvertW
	, cvArr.gpsS[a_index] := GPSconvertS
	
	cvArr.PR[a_index] := logStat.PR[cvArr.lineNum[a_index],AddC]	;~ Each record number times rate of PR change distributes PR across line.
	cvArr.FOV[a_index] := logStat.FOV[cvArr.lineNum[a_index],AddC]	;~ Each record number times rate of FOV change distributes FOV across line.
	cvArr.percent[a_index] := logStat.Percent[cvArr.lineNum[a_index],AddC]	;~ Each record number times rate of percent returns change distributes percent returns across line.
	cvArr.nadir[a_index] := logStat.Nadir[cvArr.lineNum[a_index],AddC]	;~ Each record number times rate of FOV change distributes FOV across line.
	
	If (cvArr.relationship != "Last") {									;~ Generate simplistic swath center.  NOT actual trajectory!
		cvArr.aglProfileX[a_index] := (cvArr.Lon[a_index]+cvArr.Lon[a_index+1])/2
		cvArr.aglProfileY[a_index] := (cvArr.Lat[a_index]+cvArr.Lat[a_index+1])/2
	}
		
	
	If (cvArr.tFormat[a_index] != cvArr.tFormat[a_index-1]) {
		cvArr.tFormatRel[a_index-1] := "Last"
		, cvArr.tFormatRel[a_index] := "First"
	} else {
		cvArr.tFormatRel[a_index] := "Same"
	}
}
cvArr.tFormatRel[cvArr.total] := "Last"							;~ Fix last record of Array to reflect "last second" and "last record"
cvArr.relationship[cvArr.total] := "Last"


;~ Debug cvArr object ...
testFile := fileopen("array_Test.txt","rw")
loop % cvArr.total
{	
	testFile.Write(a_index . "," . cvArr.lineNum[a_index] . "," . cvArr.ID[a_index] . "," . cvArr.FOV[a_index] . "," . cvArr.PR[a_index] . "," . cvArr.percent[a_index] . "," . cvArr.nadir[a_index] . "," . cvArr.tStamp[a_index] . "," . cvArr.tWeek[a_index] . "," . cvArr.tgpsStamp[a_index] . "," . cvArr.Lon[a_index] . "," . cvArr.Lat[a_index] . "," . cvArr.Alt[a_index] . "," . cvArr.Int[a_index] . "," . cvArr.Angle[a_index] . "," . cvArr.timeUTC[a_index] . "," . cvArr.tFormat[a_index] . "," . cvArr.gpsW[a_index] . "," . cvArr.gpsS[a_index] . "," . cvArr.tFormatRel[a_index] . "," . cvArr.relationship[a_index] . "," . cvArr.PR[a_index] . "," . cvArr.FOV[a_index] . "," . cvArr.percent[a_index] . "," . cvArr.nadir[a_index] . "`n")
}
testFile.Close()
	
Guicontrol, , MyProgress, 50
Guicontrol, , ProgressText, Writing Mission KML

If fileexist(Dir . "\Metrics_" . noExt . ".kml") {
	fDelete := Dir . "\Metrics_" . noExt . ".kml"
	FileDelete, %fDelete%
}

kmlFile := fileopen(Dir . "\Metrics_" . noExt . ".kml", "rw")								;~ Open Output KML file and start forming Header and other KML variables
{
kmlHead := ""
kmlHead =
(
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>

<!-- normal track style -->
<Style id="track_n">
      <IconStyle>
        <scale>.5</scale>
        <Icon>
          <href>http://earth.google.com/images/kml-icons/track-directional/track-none.png</href>
        </Icon>
      </IconStyle>
      <LabelStyle>
        <scale>0</scale>
      </LabelStyle>
    </Style>
	
<!-- Highlighted track style -->
    <Style id="track_h">
      <IconStyle>
        <scale>1.2</scale>
        <Icon>
          <href>http://earth.google.com/images/kml-icons/track-directional/track-none.png</href>
        </Icon>
      </IconStyle>
    </Style>
	
<!-- mapped track style -->
    <StyleMap id="track">
      <Pair>
        <key>normal</key>
        <styleUrl>#track_n</styleUrl>
      </Pair>
      <Pair>
        <key>highlight</key>
        <styleUrl>#track_h</styleUrl>
      </Pair>
    </StyleMap>
	
	<StyleMap id="msn_ylw-pushpin">
		<Pair>
			<key>normal</key>
			<styleUrl>#sn_ylw-pushpin</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#sh_ylw-pushpin</styleUrl>
		</Pair>
	</StyleMap>
	<Style id="sh_ylw-pushpin">
		<IconStyle>
			<scale>1.3</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<LineStyle>
			<color>00ffffff</color>
			<width>0</width>
		</LineStyle>
		<PolyStyle>
			<color>bfffffff</color>
		</PolyStyle>
	</Style>
	<Style id="sn_ylw-pushpin">
		<IconStyle>
			<scale>1.1</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<LineStyle>
			<color>00ffffff</color>
			<width>0</width>
		</LineStyle>
		<PolyStyle>
			<color>%Color%</color>
		</PolyStyle>
	</Style>
	<Style id="check-hide-children">
		<ListStyle>
			<listItemType>checkHideChildren</listItemType>
		</ListStyle>
	</Style>

)
KMLc := ""
KMLHc =
(
<Folder>
	<name>FlightLines</name>
	
)
KMLTc := ""
KMLTc =
(
<Folder>
	<name>Swath Times</name>
)
kmlAGL := ""
kmlAGL =
(
<Folder>
	<name>AGL Profile Lines</name>
	
)
kmlALT := ""
kmlALT =
(
<Folder>
	<name>Calculated Altitude Lines</name>
	
)
kmlProfile := ""
kmlProfile =
(
<Schema id="schema">
      <gx:SimpleArrayField name="AGL Profile" type="float">
        <displayName>AGL Profile</displayName>
      </gx:SimpleArrayField>
      <gx:SimpleArrayField name="Pulse Rate" type="float">
        <displayName>Pulse Rate</displayName>
      </gx:SimpleArrayField>
      <gx:SimpleArrayField name="Density" type="float">
        <displayName>Density</displayName>
      </gx:SimpleArrayField>
</Schema>
<Folder>
	<name>Mission Profile Statistics</name>
		<Placemark>
			<name>Mission Profile</name>
			<styleUrl>#Track</styleUrl>
			<gx:Track>
			<altitudeMode>relativeToGround </altitudeMode>			
	
)
profileWhen := ""
profileCoord := ""

profileAGL := ""
profileAGL =
(
			<ExtendedData>
				<SchemaData schemaUrl="#schema">
					<gx:SimpleArrayData name="AGL Profile">
			  
)
profileDen := ""
profileDen =
(
					<gx:SimpleArrayData name="Density">
	
)
profilePR := ""
profilePR =
(
					<gx:SimpleArrayData name="Pulse Rate">
					
)
}


Loop % cvArr.total																										; Loop through cvArr object and build KML
{
	IF (A_Index = 1) {																									; Grab mission start time for full duration calculation			
		perSecCount 			:= 0
		startMissionTime 		:= cvArr.timeUTC[a_index]
		, startTime 			:= cvArr.tgpsStamp[a_index]															; GPS week time
		, startDateTime 		:= cvArr.timeUTC[a_index]																; formatted UTC time
		, startDate 			:= substr(cvArr.timeUTC[a_index], 1, 8)
		, startEndpos 			:= cvArr.Lon[a_index] . "," . cvArr.Lat[a_index] . "," . "0"	
	}
		
	If (cvArr.relationship[a_index] = "First") {																		; If a new line starts...
		lineID := cvArr.lineNum[a_index]
		, ID := cvArr.ID[a_index]
		
		If instr(idLog, ID) {																							; Check for Refly Lines
			If (ID != "BITTEST" && ID != "LASETEST") {
				reflyCount += 1
				, ID .= "---Refly"
			}
		} else {
			idLog .= ID . ","																							; If does not exist in log, add to log
		}
		
		startEndpos := cvArr.Lon[a_index] . "," . cvArr.Lat[a_index] . "," . "0"										; Grab start of line position for closing KML swath	
		
		swathPositive := ""																								; Clear appended swath data for start of new line
		, PswathPositive := object()
		, swathNegative := ""
		, PswathNegative := object()
		, endTime := ""
		, endDateTime := ""
		, fovTotal := 0
		, prTotal := 0
		, stTotal := 0
		
		KMLHc .= "<Placemark>"
		kmlAGL .= "<Placemark>`n<name>" . ID . "</name>`n<LineString>`n<tessellate>0</tessellate>`n<extrude>0</extrude>`n<altitudeMode>absolute</altitudeMode>`n<coordinates>"
		kmlALT .= "<Placemark>`n<name>" . ID . "</name>`n<LineString>`n<tessellate>0</tessellate>`n<extrude>0</extrude>`n<altitudeMode>relativeToGround </altitudeMode>`n<coordinates>"
	
		startTime := cvArr.tgpsStamp[a_index]																			; GPS week time
		, startDateTime := cvArr.timeUTC[a_index]																		; formatted UTC time
		, startDate := substr(cvArr.timeUTC[a_index], 1, 8)
	}
	
	If (cvArr.tFormatRel[a_index] = "First") {																			; Checking if new second starts in interpolated formatted time / if so, clear per-second swaths & Averaged per-second stats
		
		ProAvAGL := 0
		, ProAvPR := 0
		, ProAvDen := 0
		, ProAvSW := 0
		, ProAvPos := 0
		, ProAvFOV := 0 
		, perRecCount := 0
		, perAngleCountPOS := 0
		, perAngleCountNEG := 0
		, xAvSW := 0
		, yAvSW := 0
		xDenArr := object()
		yDenArr := object()
		xDenArrNeg := object()
		yDenArrNeg := object()
		xDenArrPos := object()
		yDenArrPos := object()
		++perSecCount
		PswathAll := ""
		
		firstXforSpeed := (cvArr.East[a_index]+cvArr.East[a_index+1])/2
		firstYforSpeed := (cvArr.North[a_index]+cvArr.North[a_index+1])/2
	}
	
	++perRecCount																						;~ Collect per-second stats for averaging using perRecCount
	ProAvAGL += cvArr.nadir[a_index],
	ProAvPR += cvArr.PR[a_index],
	ProAvFOV += cvArr.FOV[a_index]
	
	If (cvArr.Angle[a_index] >= 0) {																					; Begin to Collet raw positions on Positive and Negative scan angles, from cvArr array / Also, collect POS and NEG ortho positions for area calculations for density per second.
		swathPositive .= cvArr.Lon[a_index] . "," . cvArr.Lat[a_index] . "," . 0 . a_space . ""						
		, PswathPositive[perSecCount] .= cvArr.Lon[a_index] . "," . cvArr.Lat[a_index] . "," . 0 . a_space . ""
		, PswathPositive.lastPos[perSecCount] := cvArr.Lon[a_index] . "," . cvArr.Lat[a_index] . "," . 0 . a_space . ""
	
		++perAngleCountPOS
		xDenArrPos[perAngleCountPOS] := cvArr.East[a_index]
		yDenArrPos[perAngleCountPOS] := cvArr.North[a_index]
	} else {
		swathNegative := cvArr.Lon[a_index] . "," . cvArr.Lat[a_index] . "," . 0 . a_space . swathNegative
		, PswathNegative[perSecCount] := cvArr.Lon[a_index] . "," . cvArr.Lat[a_index] . "," . 0 . a_space . PswathNegative[perSecCount]
		, PswathNegative.lastPos[perSecCount] := a_space . cvArr.Lon[a_index] . "," . cvArr.Lat[a_index] . "," . 0
		, endTime := cvArr.gpsS[a_index]
		, endDateTime := cvArr.timeUTC[a_index]
		
		++perAngleCountNEG
		xDenArrNeg[perAngleCountNEG] := cvArr.East[a_index]
		yDenArrNeg[perAngleCountNEG] := cvArr.North[a_index]
	}
	
	If (cvArr.relationship[a_index] != "Last") {
		;~ kmlAGL .= cvArr.aglProfileX[a_index] . "," . cvArr.aglProfileY[a_index] . "," . cvArr.nadir[a_index] . a_space . "" ;~ adding agl profile coords
		;~ kmlALT .= cvArr.aglProfileX[a_index] . "," . cvArr.aglProfileY[a_index] . "," . cvArr.nadir[a_index] . a_space . "" ;~ adding calculated altitude profile coords
		xAvSW += (cvArr.Lon[a_index] + cvArr.Lon[a_index+1])/2
		yAvSW += (cvArr.Lat[a_index] + cvArr.Lat[a_index+1])/2
	} else {
		xAvSW += (cvArr.Lon[a_index] + cvArr.Lon[a_index])/2
		yAvSW += (cvArr.Lat[a_index] + cvArr.Lat[a_index])/2
	}
	
	
	
	If (cvArr.tFormatRel[a_index] = "Last") {								; Checking if new second starts in interpolated formatted time / if so, generate new per-second swaths
		PswathAll 			:= PswathPositive.lastPos[perSecCount-1] . PswathPositive[perSecCount] . PswathNegative[perSecCount] . PswathNegative.lastPos[perSecCount-1]
		, endZuluTime 		:= cvArr.tFormat[a_index]
		, startZuluTime 	:= cvArr.tFormat[a_index-1]
		, gpsWeek 			:= cvArr.gpsW[a_index]
		, gpsSeconds 		:= cvArr.gpsS[a_index]

		KMLTc =
		(
%KMLTc%<Placemark>
		<description><![CDATA[<b>UTC:</b>  %endZuluTime%<br><br><b>GPS Week:</b>  %gpsWeek%<br><b>GPS SOTW:</b>  %gpsSeconds%]]></description>
		<TimeSpan>
			<begin>%startZuluTime%</begin>
			<end>%endZuluTime%</end>
		</TimeSpan>
		<styleUrl>#msn_ylw-pushpin</styleUrl>
		<Polygon>
			<tessellate>1</tessellate>
			<outerBoundaryIs>
				<LinearRing>
					<coordinates>
						%PswathAll%
					</coordinates>
				</LinearRing>
			</outerBoundaryIs>
		</Polygon>
	</Placemark>
		)
		lastXforSpeed := (cvArr.East[a_index]+cvArr.East[a_index-1])/2
		lastYforSpeed := (cvArr.North[a_index]+cvArr.North[a_index-1])/2
		ProAvDistance := sqrt(((lastXforSpeed-firstXforSpeed)**2) + ((lastYforSpeed-firstYforSpeed)**2))
		
		ProAvAGL := ProAvAGL/perRecCount									;~ collect and write info for stats profile line
		ProAvPR := ProAvPR/perRecCount
		ProAvFOV := ProAvFOV/perRecCount
		ProAvPos := (xAvSW/perRecCount) . " " . (yAvSW/perRecCount) . " " . ProAvAGL
		xDenArr := PolyFromScan(xDenArrPos,xDenArrNeg)
		yDenArr := PolyFromScan(yDenArrPos,yDenArrNeg)
		ProAvDenA := ProAvPR/(PolyArea(xDenArr,yDenArr,perRecCount))
		ProAvDenB := ((ProAvPR/(((2*(ProAvAGL*(Tan((ProAvFOV/2)*0.01745329252)))))))/ProAvDistance)
		;~ ListVars
		If (ProAvDenA < 50) {
		If (xDenArr.maxindex() >= 6 OR yDenArr.maxindex() >= 6) {
			profileWhen .= "<when>" . cvArr.tFormat[a_index] . "</when>`n"
			profileCoord .= "<gx:coord>" . ProAvPos . "</gx:coord>`n"
			profileAGL .= "<gx:value>" . ProAvAGL . "</gx:value>`n"
			profilePR .= "<gx:value>" . ProAvPR . "</gx:value>`n"
			profileDen .= "<gx:value>" . ProAvDenA . "</gx:value>`n"
		}
		}
		;~ msgbox % "# of records x/y/counts = " . xDenArr.maxindex() . "," . yDenArr.maxindex() . "," . perRecCount "`ndensity A/B = " . ProAvDenA . "," . ProAvDenB . "`nArea of second = " . PolyArea(xDenArr,yDenArr,perRecCount) . "`nDistance of Second = " . ProAvDistance . "`nPR of second = " . ProAvPR . "`nFOV of second = " . ProAvFOV . "`nAGL of second = " . ProAvAGL
	}
		
	If (cvArr.relationship[a_index] = "Last") {																		; If the curent line ends....
		Duration := endDateTime																							; Calculate durations of Line and format accordingly
		, Duration -= startDateTime, Seconds
		, DurationO += Duration
		, DurationF := startDate . "000000" 
		, DurationF += Duration, Seconds
		FormatTime, DurationF, %DurationF%, HH:mm:ss
		FormatTime, StartF, %startDateTime%, HH:mm:ss
		FormatTime, EndF, %endDateTime%, HH:mm:ss
		FormatTime, DateF, %startDateTime%, MM/dd/yy
		
		kmlAGL .= "</coordinates>`n</LineString>`n</Placemark>`n"								;~ End agl profile section
		kmlALT .= "</coordinates>`n</LineString>`n</Placemark>`n"								;~ End altitude profile section
		
		KMLHc =
		(
		%KMLHc%
		<name>%ID%</name>
		<Snippet maxLines="0"></Snippet>	
		<description><![CDATA[<b>-------%LineID%-------</b><br><br><u>Line Statistics</u><br>Line Length..........%nmiLen% nmi<br>Coverage..............%Cover% acres<br>Start Date..............%DateF%<br>Start Time.............%StartF%<br>End Time..............%EndF%<br>Duration................%DurationF%<br><br><u>Per Line Averages:</u><br>FOV.........................%AvFOV% Deg<br>Pulse Rate............%AvPR% kHz<br>1st Ret `%...............%AvFRet% `%<br>AGL.........................%AvAGL% m<br>Speed.....................%AvSpeed% kts<br>Point Density.........%AvDen% pts/m]]>
		</description>
		<styleUrl>#msn_ylw-pushpin</styleUrl>
		<Polygon>
			<tessellate>1</tessellate>
			<outerBoundaryIs>
				<LinearRing>
					<coordinates>
						%swathPositive%%swathNegative%%A_Space%%startEndpos%
					</coordinates>
				</LinearRing>
			</outerBoundaryIs>
		</Polygon>
	</Placemark>
		)
	}
	
}



;~~~~~ Write in "AGL Elevation Profile Lines" using absolute elevations in google earth to display AGL ranges ~~~~
;~~~~~ Write in "MSL altitude Profile Lines" using absolute elevations in google earth (AGL ranges + average terrain height from msg 2002 per second)

;~~~~~ Convex Hull Code / implement with a point "densify" method to fill in ends of swaths / then use "giftwrapping" with a threshold to follow edges more closely ~~~~~

;~ cHull := convexHull(cvArr.East,cvArr.North)			;~ Generate Convex Hull / Write header portion for convex hull placemark / Loop through hull positions
;~ kmlHull =
;~ (
;~ <Folder>
	;~ <name>Convex Hull</name>
		;~ <Placemark>
		;~ <name>swath extents</name>
		;~ <Snippet maxLines="0"></Snippet>
		;~ <styleUrl>#msn_ylw-pushpin</styleUrl>
		;~ <Polygon>
			;~ <tessellate>1</tessellate>
			;~ <outerBoundaryIs>
				;~ <LinearRing>
					;~ <coordinates>
					
;~ )
;~ Loop % cHull.maxindex()
;~ {
	;~ kmlHull .= GPS_UTM2LatLon(cHull[a_index][1], cHull[a_index][2], "N", utmZone) . "," . 0 . a_space . ""
;~ }
;~ kmlHull .= "</coordinates>`n</LinearRing>`n</outerBoundaryIs>`n</Polygon>`n</Placemark>`n</Folder>"

kmlFile.Write(kmlHead)
;~ kmlFile.Write(kmlHull)
kmlFile.Write(kmlProfile)
kmlFile.Write(profileWhen)
kmlFile.Write(profileCoord)
kmlFile.Write(profileAGL . "</gx:SimpleArrayData>`n")
kmlFile.Write(profileDen . "</gx:SimpleArrayData>`n")
kmlFile.Write(profilePR . "</gx:SimpleArrayData>`n</SchemaData>`n</ExtendedData>`n</gx:Track>`n</Placemark>`n</Folder>")
kmlFile.Write(KMLHc . "</Folder>")
kmlFile.Write(KMLTc . "</Folder>")
kmlFile.Write(kmlAGL . "</Folder>")
kmlFile.Write(kmlALT . "</Folder>")
kmlFile.Write("</Document>`n</kml>")		
kmlFile.Close()
	
msgbox, It's Done!

loop, parse, coordVar, `n
{	
	PreLine := Line
	StringSplit, MyArray, A_LoopField, `,
	Line := MyArray1
	If (PreLine != Line)
	{
		If (A_Index != 1)
		{
			StringSplit, S, LineEndID, `,
			StringSplit, E, LineBegPo , `,
			
			Under = _
			StringReplace, SDateTimeStart, SDateTimeStart, %Under%
			StringReplace, SDateTimeEnd, SDateTimeEnd, %Under%
			StringLeft, SDate, SDateTimeStart, 8
			
			TAdjust := (-1)*(8 - DLS)
			SDateTimeStart += TAdjust, Hours
			SDateTimeEnd += TAdjust, Hours
			
			Duration := SDateTimeEnd
			Duration -= SDateTimeStart, Seconds
			DurationO += Duration
			DurationF = %SDate%000000
			DurationF += Duration, Seconds
			FormatTime, DurationF, %DurationF%, HH:mm:ss
			FormatTime, StartF, %SDateTimeStart%, HH:mm:ss
			FormatTime, EndF, %SDateTimeEnd%, HH:mm:ss
			FormatTime, DateF, %SDateTimeStart%, MM/dd/yy
			
			AvFOV := (Round((FOV/RecCount), 2))
			AvPR := (Round((PR/RecCount), 2))
			AvFRet := (Round((FRet/RecCount), 2))
			AvAGL := (Round((AGL/RecCount), 2))
			AvHeight := (Round((Height/(RecCount-1)), 2))
			LLen := (Round((Haversine(S2,E2,S1,E1)), 2))
			nmiLen := (Round((((Haversine(S2,E2,S1,E1))/1000)*0.539957), 2))
			Cover := (Round((((LLen*((AvAGL*Tan((AvFOV*0.01745329252)/2))*2))/1000000)*247.105), 2))
			MSpeed := (LLen/(ETime-STime))
			AvSpeed := (Round((MSpeed*1.943844), 2))
			AvDen := (Round(((AvPR/(((2*(AvAGL*(Tan((AvFOV/2)*0.01745329252)))))))/MSpeed), 2))
			SwathStr = %VarIDPos%%VarIDNeg%%A_Space%%LineEndID%
			
			If (ID != "BITTEST" AND ID != "LASETEST")
			{
				UL = UL
				Refly = Refly
				IfNotInString, ID, %UL%
				{
					;~ msgbox % TotDen
					++LineCount
					TotDen += ((AvPR/(((2*(AvAGL*(Tan((AvFOV/2)*0.01745329252)))))))/MSpeed)
					TotSpeed += (MSpeed*1.943844)
					TotLLen += ((Haversine(S2,E2,S1,E1)))
					TotAGL += (AGL/RecCount)
					TotFRet += (FRet/RecCount)
					TotPR += (PR/RecCount)
					TotFOV += (FOV/RecCount)
					IfNotInString, ID, %Refly%
					{
						TotCover += ((LLen*((AvAGL*Tan((AvFOV*0.01745329252)/2))*2))/1000000)*247.105
					}
				}
			}
			
			FileAppend, 
			(
		<name>%ID%</name>
		<Snippet maxLines="0"></Snippet>	
		<description><![CDATA[<b>-------%LineID%-------</b><br><br><u>Line Statistics</u><br>Line Length..........%nmiLen% nmi<br>Coverage..............%Cover% acres<br>Start Date..............%DateF%<br>Start Time.............%StartF%<br>End Time..............%EndF%<br>Duration................%DurationF%<br><br><u>Per Line Averages:</u><br>FOV.........................%AvFOV% Deg<br>Pulse Rate............%AvPR% kHz<br>1st Ret `%...............%AvFRet% `%<br>AGL.........................%AvAGL% m<br>Speed.....................%AvSpeed% kts<br>Point Density.........%AvDen% pts/m]]>
		</description>
		<styleUrl>#msn_ylw-pushpin</styleUrl>
		<Polygon>
			<tessellate>1</tessellate>
			<outerBoundaryIs>
				<LinearRing>
					<coordinates>
						%VarIDPos%%VarIDNeg%%A_Space%%LineEndID%
					</coordinates>
				</LinearRing>
			</outerBoundaryIs>
		</Polygon>
	</Placemark>

			), %Dir%\Metrics_%noExt%.kml
		If (PreArrayNeg != "" AND PreArrayPos != "")
		{
			Stringsplit, PrePpos, PreArrayPos, `,
			Stringsplit, PrePneg, PreArrayNeg, `,
			PrePposLat := PrePpos0-1, PrePposLat := PrePpos%PrePposLat%
			PrePposLong := PrePpos0-2, PrePposLong := PrePpos%PrePposLong%
			0check := "", 0check := SubStr(PrePposLong, 1, 1)
			If (0check = 0)
				StringTrimLeft, PrePposLong, PrePposLong, 2
			FrontPos =
(
%PrePposLong%,%PrePposLat%,0
)
			BackPos =
(
%PrePneg1%,%PrePneg2%,0
)
;~ msgbox, %FrontPos%`n%BackPos%
		}
			PArray := ""
			PArray = %PArrayPos%%PArrayNeg%
			PreArrayNeg := PArrayNeg
			PreArrayPos := PArrayPos
			StringSplit, PArrayS, PArray, `,
			StringSplit, PArrayS, PArray, `,
			KMLT =
		(
%KMLT%
<Folder>
	<name>%ID%</name>
	<styleUrl>#check-hide-children</styleUrl>
	%KMLTc%
	<Placemark>
		<description><![CDATA[<b>UTC:</b>  %MyArray18%<br><br><b>GPS Week:</b>  %MyArray19%<br><b>GPS SOTW:</b>  %MyArray20%]]></description>
		<TimeSpan>
			<begin>%PreMyArray18%</begin>
			<end>%PreMyArray18%</end>
		</TimeSpan>
		<styleUrl>#msn_ylw-pushpin</styleUrl>
		<Polygon>
			<tessellate>1</tessellate>
			<outerBoundaryIs>
				<LinearRing>
					<coordinates>
						%FrontPos%%A_Space%%PArray%%A_Space%%BackPos%
					</coordinates>
				</LinearRing>
			</outerBoundaryIs>
		</Polygon>
	</Placemark>
</Folder>
		)
		}
		PArray := ""
		PreMyArray18 := 0
		KMLTc =
		PreArrayPos := ""
		PreArrayNeg := ""
		BackPos := ""
		FrontPos := ""
		PArrayNeg := ""
		PArrayPos := ""
		Height =
		negX =
		negY =
		posX =
		posY =
		SwArea =
		RecCount =
		FOV =
		PR =
		FRet =
		AGL =
		deltaAGL =
		VarIDPos =
		VarIDNeg =

		;~ LineID := MyArray1
		;~ ID := MyArray2
		;~ IfInString, IDlog, %ID%
		;~ {
			;~ If (ID != "BITTEST")
			;~ {
				;~ ++ReflyCount
				;~ ID = %ID%---Refly
			;~ }
				
		;~ }
		;~ IDlog = %IDlog%%MyArray2%,
		
		;~ FileAppend, 
		;~ (
		;~ <Placemark>

		;~ ), %Dir%\Metrics_%noExt%.kml
		
		LineEndID = %MyArray11%,%MyArray12%,0
		STime = %MyArray9%
		SDateTimeStart = 20%MyArray7%
	}
	
	If (MyArray16 >= 0)
	{
		S := "0 "
		VarIDPos = %VarIDPos%%MyArray11%,%MyArray12%,
		VarIDPos := VarIDPos . S
		posX := MyArray11
		posY := MyArray12
		PArrayPos = %PArrayPos%%MyArray11%,%MyArray12%,
		PArrayPos := PArrayPos . S
	}
	else
	{
		VarIDNeg = %MyArray11%,%MyArray12%,0%A_Space%%VarIDNeg%
		LineBegPos = %MyArray11%,%MyArray12%,0
		ETime = %MyArray9%
		SDateTimeEnd = 20%MyArray7%
		negX := MyArray11
		negY := MyArray12
		PArrayNeg = %MyArray11%,%MyArray12%,0%A_Space%%PArrayNeg%
	}
	
	If (MyArray18 != PreMyArray18 AND PreMyArray18 != 0)
	{
		If (PreArrayNeg != "" AND PreArrayPos != "")
		{
			Stringsplit, PrePpos, PreArrayPos, `,
			Stringsplit, PrePneg, PreArrayNeg, `,
			PrePposLat := PrePpos0-1, PrePposLat := PrePpos%PrePposLat%
			PrePposLong := PrePpos0-2, PrePposLong := PrePpos%PrePposLong%
			0check := "", 0check := SubStr(PrePposLong, 1, 1)
			If (0check = 0)
				StringTrimLeft, PrePposLong, PrePposLong, 2
			FrontPos =
(
%PrePposLong%,%PrePposLat%,0
)
			BackPos =
(
%PrePneg1%,%PrePneg2%,0
)

		}
		PArray := ""
		PArray = %PArrayPos%%PArrayNeg%
		PreArrayNeg := PArrayNeg
		PreArrayPos := PArrayPos
		PArrayNeg := ""
		PArrayPos := ""
		StringSplit, PArrayS, PArray, `,



		KMLTc =
		(
%KMLTc%<Placemark>
		<description><![CDATA[<b>UTC:</b>  %MyArray18%<br><br><b>GPS Week:</b>  %MyArray19%<br><b>GPS SOTW:</b>  %MyArray20%]]></description>
		<TimeSpan>
			<begin>%PreMyArray18%</begin>
			<end>%MyArray18%</end>
		</TimeSpan>
		<styleUrl>#msn_ylw-pushpin</styleUrl>
		<Polygon>
			<tessellate>1</tessellate>
			<outerBoundaryIs>
				<LinearRing>
					<coordinates>
						%FrontPos%%A_Space%%PArray%%A_Space%%BackPos%
					</coordinates>
				</LinearRing>
			</outerBoundaryIs>
		</Polygon>
	</Placemark>
		)
	}
	
	PreMyArray18 := MyArray18
	
	If (A_Index = 1)
	{
		SMDateTime = 20%MyArray7%
		Under = _
		StringReplace, SMDateTime, SMDateTime, %Under%
	}
	++RecCount		
	FOV += MyArray3
	PR += MyArray4
	FRet += MyArray5
	AGL += MyArray6
	deltaAGL += (MyArray6-PAGL)

	If (posX = "" OR negX = "")
		continue
	else
		Height += ((Haversine(negY,posY,negX,posX))/2)/(tan(((MyArray3/2)*0.01745329251994329576923690768489)))
}
StringSplit, S, LineEndID, `,
StringSplit, E, LineBegPos, `,
Under = _
StringReplace, SDateTimeStart, SDateTimeStart, %Under%
StringReplace, SDateTimeEnd, SDateTimeEnd, %Under%
StringLeft, SDate, SDateTimeStart, 8
TAdjust := (-1)*(8 - DLS)
SDateTimeStart += TAdjust, Hours
SDateTimeEnd += TAdjust, Hours
Duration := SDateTimeEnd
Duration -= SDateTimeStart, Seconds
DurationO += Duration
DurationF = %SDate%000000
DurationF += Duration, Seconds
FormatTime, DurationF, %DurationF%, HH:mm:ss
FormatTime, StartF, %SDateTimeStart%, HH:mm:ss
FormatTime, EndF, %SDateTimeEnd%, HH:mm:ss
FormatTime, DateF, %SDateTimeStart%, MM/dd/yy
AvFOV := (Round((FOV/RecCount), 2))
AvPR := (Round((PR/RecCount), 2))
AvFRet := (Round((FRet/RecCount), 2))
AvAGL := (Round((AGL/RecCount), 2))
LLen := (Round((Haversine(S2,E2,S1,E1)), 2))
nmiLen := (Round((((Haversine(S2,E2,S1,E1))/1000)*0.539957), 2))
Cover := (Round((((LLen*((AvAGL*Tan((AvFOV*0.01745329252)/2))*2))/1000000)*247.105), 2))
MSpeed := (LLen/(ETime-STime))
AvSpeed := (Round((MSpeed*1.943844), 2))
AvDen := (Round(((AvPR/(((2*(AvAGL*(Tan((AvFOV/2)*0.01745329252)))))))/MSpeed), 2))
If (ID != "BITTEST" AND ID != "LASETEST")
{
	UL = UL
	Refly = Refly
	IfNotInString, ID, %UL%
	{
		++LineCount
		TotDen += ((AvPR/(((2*(AvAGL*(Tan((AvFOV/2)*0.01745329252)))))))/MSpeed)
		TotSpeed += (MSpeed*1.943844)
		TotLLen += ((Haversine(S2,E2,S1,E1)))
		TotAGL += (AGL/RecCount)
		TotFRet += (FRet/RecCount)
		TotPR += (PR/RecCount)
		TotFOV += (FOV/RecCount)
		IfNotInString, ID, %Refly%
		{
			TotCover += ((LLen*((AvAGL*Tan((AvFOV*0.01745329252)/2))*2))/1000000)*247.105
		}
	}
}

FileAppend, 
(
	<name>%ID%</name>
		<Snippet maxLines="0"></Snippet>	
		<description><![CDATA[<b>-------%LineID%-------</b><br><br><u>Line Statistics</u><br>Line Length..........%nmiLen% nmi<br>Coverage..............%Cover% acres<br>Start Date..............%DateF%<br>Start Time.............%StartF%<br>End Time..............%EndF%<br>Duration................%DurationF%<br><br><u>Per Line Averages:</u><br>FOV.........................%AvFOV% Deg<br>Pulse Rate............%AvPR% kHz<br>1st Ret `%...............%AvFRet% `%<br>AGL.........................%AvAGL% m<br>Speed.....................%AvSpeed% kts<br>Point Density.........%AvDen% pts/m]]>
		</description>
		<styleUrl>#msn_ylw-pushpin</styleUrl>
		<Polygon>
			<tessellate>1</tessellate>
			<outerBoundaryIs>
				<LinearRing>
					<coordinates>
						%VarIDPos%%VarIDNeg%%A_Space%%LineEndID%
					</coordinates>
				</LinearRing>
			</outerBoundaryIs>
		</Polygon>
	</Placemark>
</Folder>
%KMLT%
</Folder>
</Document>
</kml>
), %Dir%\Metrics_%noExt%.kml
KMLT := ""
Guicontrol, , MyProgress, 80
Guicontrol, , ProgressText, Done!
SMDateTime += TAdjust, Hours
Duration := SDateTimeEnd
Duration -= SMDateTime, Seconds
DurationM = %SDate%000000
DurationM += Duration, Seconds
DurationOn = %SDate%000000
DurationOn += DurationO, Seconds
FormatTime, DurationM, %DurationM%, HH:mm:ss
FormatTime, DurationOn, %DurationOn%, HH:mm:ss
LineCountDen := LineCount-ReflyCount
;~ msgbox, %LineCountDen% , %LineCount% , %ReflyCount%
TotFOV := Round((TotFOV/LineCount), 2)
TotPR := Round((TotPR/LineCount), 2)
TotFRet := Round((TotFRet/LineCount), 2)
TotAGL := Round((TotAGL/LineCount), 2)
TotLLen := Round(((TotLLen/1000)*0.539957), 2)
TotCover := Round((TotCover*(1-(Over*0.01))), 2)
TotSpeed := Round((TotSpeed/LineCount), 2)
;~ msgbox % TotDen
TotDen := Round(((TotDen/LineCountDen)/((100-Over)*0.01)), 2)
;~ msgbox % TotDen
MetVar = 
(
	<Snippet maxLines="0"></Snippet>
	<description><![CDATA[<b>---Mission Metrics---<b><br>Total Distance.........%TotLLen% nmi<br>Total Coverage.......%TotCover% acres<br>Mission Duration...%DurationM%<br>OnLine Duration....%DurationOn%<br><br><b>---Mission Averages---<b><br>Average Density.....%TotDen% pts/m<br>Average Speed.......%TotSpeed% kts<br>Average AGL...........%TotAGL% m<br>Average 1stRet`%....%TotFRet% `%<br>Average PR.............%TotPR% kHz<br>Average FOV...........%TotFOV% Deg]]></description>
	
)

FileRead, Metrics, %Dir%\Metrics_%noExt%.kml
Loop, parse, Metrics, `n
{
	If (A_Index = 4)
	{
		Met = %Met%%MetVar%%A_LoopField%
		continue
	}
	Met = %Met%%A_LoopField%
}
Guicontrol, , MyProgress, 100

SNw =
If (SN094 = 1)
	SNw := "SN094"
If (SN054 = 1)
	SNw := "SN054"
If (SN105 = 1)
	SNw := "SN105"

FormatTime, FileDate, %SMDateTime%, MM-dd-yyyy

FileDelete, %Dir%\Metrics_%noExt%.kml
FileDelete, %Dir%\%FileDate%_%SNw%_%Plat%_Metrics.kml
FileAppend, %Met%, %Dir%\%FileDate%_%SNw%_%Plat%_Metrics.kml

;~ FileDelete, %Dir%\%noExt%_filtered.csv

;~ FileDelete, %Dir%\%noExt%_Swath.csv

Guicontrol, , ProgressText, Done!
Sleep, 1000

Gosub, Clean
return
}

If (sysVersion = 2)
{
SplitPath, SelectedFile, wExt, Dir, Ext, noExt
FileRead, Flog, %SelectedFile%
StringReplace, Flog, Flog, `r`n`r`n, `n, All
Loop, parse, Flog, `n
{
	FlogLen := A_Index
}
Msg2002 := "Msg 2002"
Msg4005Range := "Rng Crd 1 data"
Msg4005FOV := "FOV:"
Msg4005 := "Msg 4005"
Msg2009 := "Msg 2009"
RangeCount := 0, PercentRaw := 0, PercentFinal := 0, FOVCount := 0, NadirRaw := 0, NadirFinal := 0, FOVRaw := 0, FOVFinal := 0, PRRaw := 0, PRFinal := 0
Guicontrol, , MyProgress, 30
Guicontrol, , ProgressText, Filtering Selected Lines
Loop, parse, Flog, `n
{
	StringSplit, MyArray, A_LoopField, `,
	;~ If (A_Index = 1)
		;~ FlogVar = %A_LoopField%`n
	IfInString, MyArray4, %Msg2009%
	{
		If (MyArray6 = "NIDAQ: on")
		{
			++FirstRecord
			If (FirstRecord > 2)
			{
				Record := "on"
				FlogVar = %FlogVar%%A_LoopField%`n
				StringSplit, Line, Myarray7, %A_Space%
				LineNum := Line4
				StringSplit, ID, MyArray8, %A_Space%
				IDNum := ID5
				LastRecord := 0
			}
		}			
		else if (MyArray6 = "NIDAQ: off")
		{
			++LastRecord
			If (LastRecord > 2)
			{
				Record := "off"
				FirstRecord := 0
			}
		}
		
	}
	If (Record = "on")
	{
		IfInString, MyArray4, %Msg4005%
		{
			IfInString, MyArray8, %Msg4005FOV%
			{
				StringReplace MyArray8, MyArray8, %A_Space%%A_Space%, %A_Space%, All
				StringSplit, 4005FOV, MyArray8, %A_Space%
				If (4005FOV9 != 0)
				{
					++FOVCount
					NadirRaw := NadirRaw+4005FOV9, NadirFinal := NadirRaw/FOVCount, FinalNadir := NadirFinal
					FOVRaw := FOVRaw+4005FOV3, FOVFinal := FOVRaw/FOVCount, FinalFOV := FOVFinal
					PRRaw := PRRaw+4005FOV7, PRFinal := PRRaw/FOVCount, FinalPR := PRFinal
				}
			}
			IfInString, MyArray8, %Msg4005Range%
			{
				StringReplace MyArray8, MyArray8, %A_Space% %A_Space%, %A_Space%, All 
				StringReplace MyArray8, MyArray8, %A_Space%%A_Space%, %A_Space%, All
				StringSplit, 4005Range, MyArray8, %A_Space%
				If (4005Range8 != 0)
				{
					++RangeCount, PercentRaw := PercentRaw+4005Range8, PercentFinal := PercentRaw/RangeCount, FinalPercent := PercentFinal 
				}
				SetVar = %SetVar%%LineNum%,%ID5%,%4005FOV3%,%4005FOV7%,%4005Range8%,%4005FOV9%`n
			}
			else
				continue
		}
		IfInString, MyArray4, %Msg2002%
			IfInString, FLPro, %LineNum%
			{
				RangeCount := 0, PercentRaw := 0, PercentFinal := 0, FOVCount := 0, NadirRaw := 0, NadirFinal := 0, FOVRaw := 0, FOVFinal := 0, PRRaw := 0, PRFinal := 0
				coordVar = %coordVar%%LineNum%,%ID5%,%FinalFOV%,%FinalPR%,%FinalPercent%,%FinalNadir%,%A_LoopField%
			}
	}
	
}

loop, parse, coordVar, `r
{
	
	PreCVT1 := CVT1
	PreCVT7 := CVT7
	StringSplit, CVT, A_LoopField, `,
	StringReplace, CVT7, CVT7, _, , All
	CVT7 = 20%CVT7%
	
	;~ msgbox % CVT7
	If (A_Index = 1)
	{
		coordEntry := 0
		continue
	}
	If (PreCVT1 = CVT1)
	{
		++coordEntry
	}
	else if (PreCVT1 != CVT1)
	{
		StringReplace, PreCVT1Temp, PreCVT1, _, , All
		PreCVT1Temp = 20%PreCVT1Temp%
		CVT7Temp := PreCVT7
		CVT7Temp -= PreCVT1Temp, Seconds
		CVTDiv := CVT7Temp/coordEntry
		INTcoord = %INTcoord%%PreCVT1%,%CVTDiv%,%coordEntry%`n
		coordEntry := 0
	}
}

loop, parse, coordVar, `r
{
	CVar_AL := A_LoopField
	PreCVar1 := CVar1
	StringSplit, CVar, A_LoopField, `,
	If (PreCVar1 != CVar1)
		TMult := 0
	loop, parse, INTcoord, `n
	{
		StringSplit, INTc, A_LoopField, `,
		If (CVar1 = INTc1)
		{
			++TMult
			AddT := Round(INTc2*TMult)
			StringReplace, CVar1Temp, CVar1, _, , All
			CVar1Temp = 20%CVar1Temp%
			CVar1Temp += AddT, Seconds
			GPSconvertS := UTC2GPSWeekS(CVar1Temp)
			GPSconvertW := UTC2GPSWeekW(CVar1Temp)
			FormatTime, CVar1Formatted, %CVar1Temp%, yyyy-MM-ddTHH:mm:ssZ
			coordVar1 = %coordVar1%%CVar_AL%,%CVar1Formatted%,%GPSconvertW%,%GPSconvertS%`n
		}
	}
}

coordVar := ""
coordVar := coordVar1

FileDelete, %Dir%\%noExt%_filtered.csv
FileAppend, %coordVar%, %Dir%\%noExt%_filtered.csv
Guicontrol, , MyProgress, 50
Guicontrol, , MyProgress, 50
Guicontrol, , ProgressText, Writing Mission KML

FileDelete, %Dir%\Metrics_%noExt%.kml
FileAppend, 
(
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<StyleMap id="msn_ylw-pushpin">
		<Pair>
			<key>normal</key>
			<styleUrl>#sn_ylw-pushpin</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#sh_ylw-pushpin</styleUrl>
		</Pair>
	</StyleMap>
	<Style id="sh_ylw-pushpin">
		<IconStyle>
			<scale>1.3</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<LineStyle>
			<color>00ffffff</color>
			<width>0</width>
		</LineStyle>
		<PolyStyle>
			<color>bfffffff</color>
		</PolyStyle>
	</Style>
	<Style id="sn_ylw-pushpin">
		<IconStyle>
			<scale>1.1</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<LineStyle>
			<color>00ffffff</color>
			<width>0</width>
		</LineStyle>
		<PolyStyle>
			<color>%Color%</color>
		</PolyStyle>
	</Style>
	<Style id="check-hide-children">
		<ListStyle>
			<listItemType>checkHideChildren</listItemType>
		</ListStyle>
	</Style>
<Folder>
	<name>FlightLines</name>

), %Dir%\Metrics_%noExt%.kml

KMLT := ""
KMLT =
(
<Folder>
	<name>Swath Times</name>
)

loop, parse, coordVar, `n
{
	PreLine := Line
	StringSplit, MyArray, A_LoopField, `,
	Line := MyArray1
		If (PreLine != Line)
	{
		If (A_Index != 1)
		{
			StringSplit, S, LineEndID, `,
			StringSplit, E, LineBegPos, `,
			Under = _
			StringReplace, SDateTimeStart, SDateTimeStart, %Under%
			StringReplace, SDateTimeEnd, SDateTimeEnd, %Under%
			StringLeft, SDate, SDateTimeStart, 8
			TAdjust := (-1)*(8 - DLS)
			SDateTimeStart += TAdjust, Hours
			SDateTimeEnd += TAdjust, Hours
			Duration := SDateTimeEnd
			Duration -= SDateTimeStart, Seconds
			DurationO += Duration
			DurationF = %SDate%000000
			DurationF += Duration, Seconds
			FormatTime, DurationF, %DurationF%, HH:mm:ss
			FormatTime, StartF, %SDateTimeStart%, HH:mm:ss
			FormatTime, EndF, %SDateTimeEnd%, HH:mm:ss
			FormatTime, DateF, %SDateTimeStart%, MM/dd/yy
			AvFOV := (Round((FOV/RecCount), 2))
			AvPR := (Round((PR/RecCount), 2))
			AvFRet := (Round((FRet/RecCount), 2))
			AvAGL := (Round((AGL/RecCount), 2))
			AvHeight := (Round((Height/(RecCount-1)), 2))
			LLen := (Round((Haversine(S2,E2,S1,E1)), 2))
			nmiLen := (Round((((Haversine(S2,E2,S1,E1))/1000)*0.539957), 2))
			Cover := (Round((((LLen*((AvAGL*Tan((AvFOV*0.01745329252)/2))*2))/1000000)*247.105), 2))
			MSpeed := (LLen/(ETime-STime))
			AvSpeed := (Round((MSpeed*1.943844), 2))
			AvDen := (Round(((AvPR/(((2*(AvAGL*(Tan((AvFOV/2)*0.01745329252)))))))/MSpeed), 2))
			SwathStr = %VarIDPos%%VarIDNeg%%A_Space%%LineEndID%
			
			If (ID != "BITTEST" AND ID != "LASETEST")
			{
				UL = UL
				Refly = Refly
				IfNotInString, ID, %UL%
				{
					++LineCount
					TotDen += ((AvPR/(((2*(AvAGL*(Tan((AvFOV/2)*0.01745329252)))))))/MSpeed)
					TotSpeed += (MSpeed*1.943844)
					TotLLen += ((Haversine(S2,E2,S1,E1)))
					TotAGL += (AGL/RecCount)
					TotFRet += (FRet/RecCount)
					TotPR += (PR/RecCount)
					TotFOV += (FOV/RecCount)
					IfNotInString, ID, %Refly%
					{
						TotCover += ((LLen*((AvAGL*Tan((AvFOV*0.01745329252)/2))*2))/1000000)*247.105
					}
				}
			}
			
			FileAppend, 
			(
		<name>%ID%</name>
		<Snippet maxLines="0"></Snippet>	
		<description><![CDATA[<b>-------%LineID%-------</b><br><br><u>Line Statistics</u><br>Line Length..........%nmiLen% nmi<br>Coverage..............%Cover% acres<br>Start Date..............%DateF%<br>Start Time.............%StartF%<br>End Time..............%EndF%<br>Duration................%DurationF%<br><br><u>Per Line Averages:</u><br>FOV.........................%AvFOV% Deg<br>Pulse Rate............%AvPR% kHz<br>1st Ret `%...............%AvFRet% `%<br>AGL.........................%AvAGL% m<br>Speed.....................%AvSpeed% kts<br>Point Density.........%AvDen% pts/m]]>
		</description>
		<styleUrl>#msn_ylw-pushpin</styleUrl>
		<Polygon>
			<tessellate>1</tessellate>
			<outerBoundaryIs>
				<LinearRing>
					<coordinates>
						%VarIDPos%%VarIDNeg%%A_Space%%LineEndID%
					</coordinates>
				</LinearRing>
			</outerBoundaryIs>
		</Polygon>
	</Placemark>

			), %Dir%\Metrics_%noExt%.kml
		If (PreArrayNeg != "" AND PreArrayPos != "")
		{
			Stringsplit, PrePpos, PreArrayPos, `,
			Stringsplit, PrePneg, PreArrayNeg, `,
			PrePposLat := PrePpos0-1, PrePposLat := PrePpos%PrePposLat%
			PrePposLong := PrePpos0-2, PrePposLong := PrePpos%PrePposLong%
			0check := "", 0check := SubStr(PrePposLong, 1, 1)
			If (0check = 0)
				StringTrimLeft, PrePposLong, PrePposLong, 2
			FrontPos =
(
%PrePposLong%,%PrePposLat%,0
)
			BackPos =
(
%PrePneg1%,%PrePneg2%,0
)
;~ msgbox, %FrontPos%`n%BackPos%
		}
			PArray := ""
			PArray = %PArrayPos%%PArrayNeg%
			PreArrayNeg := PArrayNeg
			PreArrayPos := PArrayPos
			StringSplit, PArrayS, PArray, `,
			StringSplit, PArrayS, PArray, `,
			KMLT =
		(
%KMLT%
<Folder>
	<name>%ID%</name>
	<styleUrl>#check-hide-children</styleUrl>
	%KMLTc%
	<Placemark>
		<description><![CDATA[<b>UTC:</b>  %MyArray19%<br><br><b>GPS Week:</b>  %MyArray20%<br><b>GPS SOTW:</b>  %MyArray21%]]></description>
		<TimeSpan>
			<begin>%PreMyArray19%</begin>
			<end>%PreMyArray19%</end>
		</TimeSpan>
		<styleUrl>#msn_ylw-pushpin</styleUrl>
		<Polygon>
			<tessellate>1</tessellate>
			<outerBoundaryIs>
				<LinearRing>
					<coordinates>
						%FrontPos%%A_Space%%PArray%%A_Space%%BackPos%
					</coordinates>
				</LinearRing>
			</outerBoundaryIs>
		</Polygon>
	</Placemark>
</Folder>
		)
		}
		PArray := ""
		PreMyArray19 := 0
		KMLTc =
		PreArrayPos := ""
		PreArrayNeg := ""
		BackPos := ""
		FrontPos := ""
		PArrayNeg := ""
		PArrayPos := ""
		Height =
		negX =
		negY =
		posX =
		posY =
		SwArea =
		RecCount =
		FOV =
		PR =
		FRet =
		AGL =
		VarIDPos =
		VarIDNeg =
		LineID := MyArray1
		ID := MyArray2
		IfInString, IDlog, %ID%
		{
			If (ID != "BITTEST")
			{
				++ReflyCount
				ID = %ID%---Refly
			}
				
		}
		IDlog = %IDlog%%MyArray2%,
		
		FileAppend, 
		(
	<Placemark>

		), %Dir%\Metrics_%noExt%.kml

		LineEndID = %MyArray12%,%MyArray13%,0
		STime = %MyArray9%
		SDateTimeStart = 20%MyArray7%
	}
	
	If (MyArray17 > 0)
	{
		S := "0 "
		VarIDPos = %VarIDPos%%MyArray12%,%MyArray13%,
		VarIDPos := VarIDPos . S
		posX := MyArray12
		posY := MyArray13
		PArrayPos = %PArrayPos%%MyArray12%,%MyArray13%,
		PArrayPos := PArrayPos . S
	}
	else
	{
		VarIDNeg = %MyArray12%,%MyArray13%,0%A_Space%%VarIDNeg%
		LineBegPos = %MyArray12%,%MyArray13%,0
		ETime = %MyArray9%
		SDateTimeEnd = 20%MyArray7%
		negX := MyArray12
		negY := MyArray13
		PArrayNeg = %MyArray12%,%MyArray13%,0%A_Space%%PArrayNeg%
	}
	
	If (MyArray19 != PreMyArray19 AND PreMyArray19 != 0)
	{
		If (PreArrayNeg != "" AND PreArrayPos != "")
		{
			Stringsplit, PrePpos, PreArrayPos, `,
			Stringsplit, PrePneg, PreArrayNeg, `,
			PrePposLat := PrePpos0-1, PrePposLat := PrePpos%PrePposLat%
			PrePposLong := PrePpos0-2, PrePposLong := PrePpos%PrePposLong%
			0check := "", 0check := SubStr(PrePposLong, 1, 1)
			If (0check = 0)
				StringTrimLeft, PrePposLong, PrePposLong, 2
			FrontPos =
(
%PrePposLong%,%PrePposLat%,0
)
			BackPos =
(
%PrePneg1%,%PrePneg2%,0
)
;~ msgbox, %FrontPos%`n%BackPos%
		}
		PArray := ""
		PArray = %PArrayPos%%PArrayNeg%
		PreArrayNeg := PArrayNeg
		PreArrayPos := PArrayPos
		PArrayNeg := ""
		PArrayPos := ""
		StringSplit, PArrayS, PArray, `,



		KMLTc =
		(
%KMLTc%<Placemark>
		<description><![CDATA[<b>UTC:</b>  %MyArray19%<br><br><b>GPS Week:</b>  %MyArray20%<br><b>GPS SOTW:</b>  %MyArray21%]]></description>
		<TimeSpan>
			<begin>%PreMyArray19%</begin>
			<end>%MyArray19%</end>
		</TimeSpan>
		<styleUrl>#msn_ylw-pushpin</styleUrl>
		<Polygon>
			<tessellate>1</tessellate>
			<outerBoundaryIs>
				<LinearRing>
					<coordinates>
						%FrontPos%%A_Space%%PArray%%A_Space%%BackPos%
					</coordinates>
				</LinearRing>
			</outerBoundaryIs>
		</Polygon>
	</Placemark>
		)
	}
	
	PreMyArray19 := MyArray19
	
	If (A_Index = 1)
	{
		SMDateTime = 20%MyArray7%
		Under = _
		StringReplace, SMDateTime, SMDateTime, %Under%
	}
	++RecCount		
	FOV += MyArray3
	PR += MyArray4
	FRet += MyArray5
	AGL += MyArray6
	If (posX = "" OR negX = "")
		continue
	else
		Height += ((Haversine(negY,posY,negX,posX))/2)/(tan(((MyArray3/2)*0.01745329251994329576923690768489)))
	
}
StringSplit, S, LineEndID, `,
StringSplit, E, LineBegPos, `,
Under = _
StringReplace, SDateTimeStart, SDateTimeStart, %Under%
StringReplace, SDateTimeEnd, SDateTimeEnd, %Under%
StringLeft, SDate, SDateTimeStart, 8
TAdjust := (-1)*(8 - DLS)
SDateTimeStart += TAdjust, Hours
SDateTimeEnd += TAdjust, Hours
Duration := SDateTimeEnd
Duration -= SDateTimeStart, Seconds
DurationO += Duration
DurationF = %SDate%000000
DurationF += Duration, Seconds
FormatTime, DurationF, %DurationF%, HH:mm:ss
FormatTime, StartF, %SDateTimeStart%, HH:mm:ss
FormatTime, EndF, %SDateTimeEnd%, HH:mm:ss
FormatTime, DateF, %SDateTimeStart%, MM/dd/yy
AvFOV := (Round((FOV/RecCount), 2))
AvPR := (Round((PR/RecCount), 2))
AvFRet := (Round((FRet/RecCount), 2))
AvAGL := (Round((AGL/RecCount), 2))
LLen := (Round((Haversine(S2,E2,S1,E1)), 2))
nmiLen := (Round((((Haversine(S2,E2,S1,E1))/1000)*0.539957), 2))
Cover := (Round((((LLen*((AvAGL*Tan((AvFOV*0.01745329252)/2))*2))/1000000)*247.105), 2))
MSpeed := (LLen/(ETime-STime))
AvSpeed := (Round((MSpeed*1.943844), 2))
AvDen := (Round(((AvPR/(((2*(AvAGL*(Tan((AvFOV/2)*0.01745329252)))))))/MSpeed), 2))
If (ID != "BITTEST" AND ID != "LASETEST")
{
	UL = UL
	Refly = Refly
	IfNotInString, ID, %UL%
	{
		++LineCount
		TotDen += ((AvPR/(((2*(AvAGL*(Tan((AvFOV/2)*0.01745329252)))))))/MSpeed)
		TotSpeed += (MSpeed*1.943844)
		TotLLen += ((Haversine(S2,E2,S1,E1)))
		TotAGL += (AGL/RecCount)
		TotFRet += (FRet/RecCount)
		TotPR += (PR/RecCount)
		TotFOV += (FOV/RecCount)
		IfNotInString, ID, %Refly%
		{
			TotCover += ((LLen*((AvAGL*Tan((AvFOV*0.01745329252)/2))*2))/1000000)*247.105
		}
	}
}

FileAppend, 
(
	<name>%ID%</name>
		<Snippet maxLines="0"></Snippet>	
		<description><![CDATA[<b>-------%LineID%-------</b><br><br><u>Line Statistics</u><br>Line Length..........%nmiLen% nmi<br>Coverage..............%Cover% acres<br>Start Date..............%DateF%<br>Start Time.............%StartF%<br>End Time..............%EndF%<br>Duration................%DurationF%<br><br><u>Per Line Averages:</u><br>FOV.........................%AvFOV% Deg<br>Pulse Rate............%AvPR% kHz<br>1st Ret `%...............%AvFRet% `%<br>AGL.........................%AvAGL% m<br>Speed.....................%AvSpeed% kts<br>Point Density.........%AvDen% pts/m]]>
		</description>
		<styleUrl>#msn_ylw-pushpin</styleUrl>
		<Polygon>
			<tessellate>1</tessellate>
			<outerBoundaryIs>
				<LinearRing>
					<coordinates>
						%VarIDPos%%VarIDNeg%%A_Space%%LineEndID%
					</coordinates>
				</LinearRing>
			</outerBoundaryIs>
		</Polygon>
	</Placemark>
</Folder>
%KMLT%
</Folder>
</Document>
</kml>
), %Dir%\Metrics_%noExt%.kml
KMLT := ""
Guicontrol, , MyProgress, 80
Guicontrol, , ProgressText, Done!
SMDateTime += TAdjust, Hours
Duration := SDateTimeEnd
Duration -= SMDateTime, Seconds
DurationM = %SDate%000000
DurationM += Duration, Seconds
DurationOn = %SDate%000000
DurationOn += DurationO, Seconds
FormatTime, DurationM, %DurationM%, HH:mm:ss
FormatTime, DurationOn, %DurationOn%, HH:mm:ss
LineCountDen := LineCount-ReflyCount
TotFOV := Round((TotFOV/LineCount), 2)
TotPR := Round((TotPR/LineCount), 2)
TotFRet := Round((TotFRet/LineCount), 2)
TotAGL := Round((TotAGL/LineCount), 2)
TotLLen := Round(((TotLLen/1000)*0.539957), 2)
TotCover := Round((TotCover*(1-(Over*0.01))), 2)
TotSpeed := Round((TotSpeed/LineCount), 2)
TotDen := Round(((TotDen/LineCountDen)/((100-Over)*0.01)), 2)

MetVar = 
(
	<Snippet maxLines="0"></Snippet>
	<description><![CDATA[<b>---Mission Metrics---<b><br>Total Distance.........%TotLLen% nmi<br>Total Coverage.......%TotCover% acres<br>Mission Duration...%DurationM%<br>OnLine Duration....%DurationOn%<br><br><b>---Mission Averages---<b><br>Average Density.....%TotDen% pts/m<br>Average Speed.......%TotSpeed% kts<br>Average AGL...........%TotAGL% m<br>Average 1stRet`%....%TotFRet% `%<br>Average PR.............%TotPR% kHz<br>Average FOV...........%TotFOV% Deg]]></description>
	
)

FileRead, Metrics, %Dir%\Metrics_%noExt%.kml
Loop, parse, Metrics, `n
{
	If (A_Index = 4)
	{
		Met = %Met%%MetVar%%A_LoopField%
		continue
	}
	Met = %Met%%A_LoopField%
}
Guicontrol, , MyProgress, 100

SNw =
If (SN106 = 1)
	SNw := "SN106"

FormatTime, FileDate, %SMDateTime%, MM-dd-yyyy

FileDelete, %Dir%\Metrics_%noExt%.kml
FileDelete, %Dir%\%FileDate%_%SNw%_%Plat%_Metrics.kml
FileAppend, %Met%, %Dir%\%FileDate%_%SNw%_%Plat%_Metrics.kml

;~ FileDelete, %Dir%\%noExt%_filtered.csv

FileDelete, %Dir%\%noExt%_Swath.csv

Guicontrol, , ProgressText, Done!
Sleep, 1000

Gosub, Clean
return
}

If (sysVersion = 3)
{
SplitPath, SelectedFile, wExt, Dir, Ext, noExt
FileRead, Flog, %SelectedFile%
StringReplace, Flog, Flog, `r`n`r`n, `n, All
Loop, parse, Flog, `n
{
	FlogLen := A_Index
}
Msg2002 := "Msg 2002"
Msg4005Range := "Rng Crd 1 data"
Msg4005FOV := "FOV:"
Msg4005 := "Msg 4005"
Msg2009 := "Msg 2009"
Guicontrol, , MyProgress, 30
Guicontrol, , ProgressText, Filtering Selected Lines
Loop, parse, Flog, `n
{
	StringSplit, MyArray, A_LoopField, `,
	;~ If (A_Index = 1)
		;~ FlogVar = %A_LoopField%`n
	IfInString, MyArray4, %Msg2009%
	{
		If (MyArray6 = "NIDAQ: on")
		{
			++FirstRecord
			If (FirstRecord > 2)
			{
				Record := "on"
				FlogVar = %FlogVar%%A_LoopField%`n
				StringSplit, Line, MyArray7, %A_Space%
				LineNum := Line4
				StringSplit, ID, MyArray8, %A_Space%
				IDNum := ID5
				LastRecord := 0
			}
		}			
		else if (MyArray6 = "NIDAQ: off")
		{
			++LastRecord
			If (LastRecord > 2)
			{
				Record := "off"
				FirstRecord := 0
			}
		}
	}
	If (Record = "on")
	{
		IfInString, MyArray4, %Msg4005%
		{
			IfInString, MyArray8, %Msg4005FOV%
			{
				StringReplace MyArray8, MyArray8, %A_Space%%A_Space%, %A_Space%, All
				StringSplit, 4005FOV, MyArray8, %A_Space%
				If (4005FOV9 != 0)
				{
					++FOVCount
					NadirRaw := NadirRaw+4005FOV9, NadirFinal := NadirRaw/FOVCount, FinalNadir := NadirFinal
					FOVRaw := FOVRaw+4005FOV3, FOVFinal := FOVRaw/FOVCount, FinalFOV := FOVFinal
					PRRaw := PRRaw+4005FOV7, PRFinal := PRRaw/FOVCount, FinalPR := PRFinal*2
				}
			}
			IfInString, MyArray8, %Msg4005Range%
			{
				StringReplace MyArray10, MyArray10, %A_Space% %A_Space%, %A_Space%, All 
				StringReplace MyArray10, MyArray10, %A_Space%%A_Space%, %A_Space%, All
				StringSplit, 4005Range, MyArray10, %A_Space%
				If (4005Range4 != 0)
				{
					++RangeCount, PercentRaw := PercentRaw+4005Range4, PercentFinal := PercentRaw/RangeCount, FinalPercent := PercentFinal 
				}
				SetVar = %SetVar%%LineNum%,%ID5%,%4005FOV3%,%4005FOV7%,%4005Range4%,%4005FOV9%`n
			}
			else
				continue
		}
		IfInString, MyArray4, %Msg2002%
			IfInString, FLPro, %LineNum%
			{
				StringSplit, 2002C, A_loopField, `,
				If (2002C9 = 0)
					continue				
				else
				{
					RangeCount := 0, PercentRaw := 0, PercentFinal := 0, FOVCount := 0, NadirRaw := 0, NadirFinal := 0, FOVRaw := 0, FOVFinal := 0, PRRaw := 0, PRFinal := 0
					coordVar = %coordVar%%LineNum%,%ID5%,%FinalFOV%,%FinalPR%,%FinalPercent%,%FinalNadir%,%A_LoopField%
				}
			}
	}
	
}

loop, parse, coordVar, `r
{
	
	PreCVT1 := CVT1
	PreCVT7 := CVT7
	StringSplit, CVT, A_LoopField, `,
	StringReplace, CVT7, CVT7, _, , All
	CVT7 = 20%CVT7%
	
	;~ msgbox % CVT7
	If (A_Index = 1)
	{
		coordEntry := 0
		continue
	}
	If (PreCVT1 = CVT1)
	{
		++coordEntry
	}
	else if (PreCVT1 != CVT1)
	{
		StringReplace, PreCVT1Temp, PreCVT1, _, , All
		PreCVT1Temp = 20%PreCVT1Temp%
		CVT7Temp := PreCVT7
		CVT7Temp -= PreCVT1Temp, Seconds
		CVTDiv := CVT7Temp/coordEntry
		INTcoord = %INTcoord%%PreCVT1%,%CVTDiv%,%coordEntry%`n
		coordEntry := 0
	}
}

loop, parse, coordVar, `r
{
	CVar_AL := A_LoopField
	PreCVar1 := CVar1
	StringSplit, CVar, A_LoopField, `,
	If (PreCVar1 != CVar1)
		TMult := 0
	loop, parse, INTcoord, `n
	{
		StringSplit, INTc, A_LoopField, `,
		If (CVar1 = INTc1)
		{
			++TMult
			AddT := Round(INTc2*TMult)
			StringReplace, CVar1Temp, CVar1, _, , All
			CVar1Temp = 20%CVar1Temp%
			CVar1Temp += AddT, Seconds
			GPSconvertS := UTC2GPSWeekS(CVar1Temp)
			GPSconvertW := UTC2GPSWeekW(CVar1Temp)
			FormatTime, CVar1Formatted, %CVar1Temp%, yyyy-MM-ddTHH:mm:ssZ
			coordVar1 = %coordVar1%%CVar_AL%,%CVar1Formatted%,%GPSconvertW%,%GPSconvertS%`n
		}
	}
}

coordVar := ""
coordVar := coordVar1

Guicontrol, , MyProgress, 50
Guicontrol, , ProgressText, Writing Mission KML

FileDelete, %Dir%\Metrics_%noExt%.kml
FileAppend, 
(
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<StyleMap id="msn_ylw-pushpin">
		<Pair>
			<key>normal</key>
			<styleUrl>#sn_ylw-pushpin</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#sh_ylw-pushpin</styleUrl>
		</Pair>
	</StyleMap>
	<Style id="sh_ylw-pushpin">
		<IconStyle>
			<scale>1.3</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<LineStyle>
			<color>00ffffff</color>
			<width>0</width>
		</LineStyle>
		<PolyStyle>
			<color>bfffffff</color>
		</PolyStyle>
	</Style>
	<Style id="sn_ylw-pushpin">
		<IconStyle>
			<scale>1.1</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<LineStyle>
			<color>00ffffff</color>
			<width>0</width>
		</LineStyle>
		<PolyStyle>
			<color>%Color%</color>
		</PolyStyle>
	</Style>
<Folder>
	<name>FlightLines</name>

), %Dir%\Metrics_%noExt%.kml

KMLT := ""
KMLT =
(
<Folder>
	<name>Swath Times</name>
)

loop, parse, coordVar, `n
{
	PreLine := Line
	StringSplit, MyArray, A_LoopField, `,
	Line := MyArray1
		If (PreLine != Line)
	{
		If (A_Index != 1)
		{
			StringSplit, S, LineEndID, `,
			StringSplit, E, LineBegPos, `,
			Under = _
			StringReplace, SDateTimeStart, SDateTimeStart, %Under%
			StringReplace, SDateTimeEnd, SDateTimeEnd, %Under%
			StringLeft, SDate, SDateTimeStart, 8
			TAdjust := (-1)*(8 - DLS)
			SDateTimeStart += TAdjust, Hours
			SDateTimeEnd += TAdjust, Hours
			Duration := SDateTimeEnd
			Duration -= SDateTimeStart, Seconds
			DurationO += Duration
			DurationF = %SDate%000000
			DurationF += Duration, Seconds
			FormatTime, DurationF, %DurationF%, HH:mm:ss
			FormatTime, StartF, %SDateTimeStart%, HH:mm:ss
			FormatTime, EndF, %SDateTimeEnd%, HH:mm:ss
			FormatTime, DateF, %SDateTimeStart%, MM/dd/yy
			AvFOV := (Round((FOV/RecCount), 2))
			AvPR := (Round((PR/RecCount), 2))
			AvFRet := (Round((FRet/RecCount), 2))
			AvAGL := (Round((AGL/RecCount), 2))
			AvHeight := (Round((Height/(RecCount-1)), 2))
			LLen := (Round((Haversine(S2,E2,S1,E1)), 2))
			nmiLen := (Round((((Haversine(S2,E2,S1,E1))/1000)*0.539957), 2))
			Cover := (Round((((LLen*((AvAGL*Tan((AvFOV*0.01745329252)/2))*2))/1000000)*247.105), 2))
			MSpeed := (LLen/(ETime-STime))
			AvSpeed := (Round((MSpeed*1.943844), 2))
			AvDen := (Round(((AvPR/(((2*(AvAGL*(Tan((AvFOV/2)*0.01745329252)))))))/MSpeed), 2))
			SwathStr = %VarIDPos%%VarIDNeg%%A_Space%%LineEndID%
			
			If (ID != "BITTEST" AND ID != "LASETEST")
			{
				UL = UL
				Refly = Refly
				IfNotInString, ID, %UL%
				{
					++LineCount
					TotDen += ((AvPR/(((2*(AvAGL*(Tan((AvFOV/2)*0.01745329252)))))))/MSpeed)
					TotSpeed += (MSpeed*1.943844)
					TotLLen += ((Haversine(S2,E2,S1,E1)))
					TotAGL += (AGL/RecCount)
					TotFRet += (FRet/RecCount)
					TotPR += (PR/RecCount)
					TotFOV += (FOV/RecCount)
					IfNotInString, ID, %Refly%
					{
						TotCover += ((LLen*((AvAGL*Tan((AvFOV*0.01745329252)/2))*2))/1000000)*247.105
					}
				}
			}
			
			FileAppend, 
			(
		<name>%ID%</name>
		<Snippet maxLines="0"></Snippet>	
		<description><![CDATA[<b>-------%LineID%-------</b><br><br><u>Line Statistics</u><br>Line Length..........%nmiLen% nmi<br>Coverage..............%Cover% acres<br>Start Date..............%DateF%<br>Start Time.............%StartF%<br>End Time..............%EndF%<br>Duration................%DurationF%<br><br><u>Per Line Averages:</u><br>FOV.........................%AvFOV% Deg<br>Pulse Rate............%AvPR% kHz<br>1st Ret `%...............%AvFRet% `%<br>AGL.........................%AvAGL% m<br>Speed.....................%AvSpeed% kts<br>Point Density.........%AvDen% pts/m]]>
		</description>
		<styleUrl>#msn_ylw-pushpin</styleUrl>
		<Polygon>
			<tessellate>1</tessellate>
			<outerBoundaryIs>
				<LinearRing>
					<coordinates>
						%VarIDPos%%VarIDNeg%%A_Space%%LineEndID%
					</coordinates>
				</LinearRing>
			</outerBoundaryIs>
		</Polygon>
	</Placemark>

			), %Dir%\Metrics_%noExt%.kml
		If (PreArrayNeg != "" AND PreArrayPos != "")
		{
			Stringsplit, PrePpos, PreArrayPos, `,
			Stringsplit, PrePneg, PreArrayNeg, `,
			PrePposLat := PrePpos0-1, PrePposLat := PrePpos%PrePposLat%
			PrePposLong := PrePpos0-2, PrePposLong := PrePpos%PrePposLong%
			0check := "", 0check := SubStr(PrePposLong, 1, 1)
			If (0check = 0)
				StringTrimLeft, PrePposLong, PrePposLong, 2
			FrontPos =
(
%PrePposLong%,%PrePposLat%,0
)
			BackPos =
(
%PrePneg1%,%PrePneg2%,0
)
;~ msgbox, %FrontPos%`n%BackPos%
		}
			PArray := ""
			PArray = %PArrayPos%%PArrayNeg%
			PreArrayNeg := PArrayNeg
			PreArrayPos := PArrayPos
			StringSplit, PArrayS, PArray, `,
			StringSplit, PArrayS, PArray, `,
			KMLT =
		(
%KMLT%
<Folder>
	<name>%ID%</name>
	<styleUrl>#check-hide-children</styleUrl>
	%KMLTc%
	<Placemark>
		<description><![CDATA[<b>UTC:</b>  %MyArray19%<br><br><b>GPS Week:</b>  %MyArray20%<br><b>GPS SOTW:</b>  %MyArray21%]]></description>
		<TimeSpan>
			<begin>%PreMyArray19%</begin>
			<end>%PreMyArray19%</end>
		</TimeSpan>
		<styleUrl>#msn_ylw-pushpin</styleUrl>
		<Polygon>
			<tessellate>1</tessellate>
			<outerBoundaryIs>
				<LinearRing>
					<coordinates>
						%FrontPos%%A_Space%%PArray%%A_Space%%BackPos%
					</coordinates>
				</LinearRing>
			</outerBoundaryIs>
		</Polygon>
	</Placemark>
</Folder>
		)
		}
		PArray := ""
		PreMyArray19 := 0
		KMLTc =
		PreArrayPos := ""
		PreArrayNeg := ""
		BackPos := ""
		FrontPos := ""
		PArrayNeg := ""
		PArrayPos := ""
		Height =
		negX =
		negY =
		posX =
		posY =
		SwArea =
		RecCount =
		FOV =
		PR =
		FRet =
		AGL =
		VarIDPos =
		VarIDNeg =
		LineID := MyArray1
		ID := MyArray2
		IfInString, IDlog, %ID%
		{
			If (ID != "BITTEST")
			{
				++ReflyCount
				ID = %ID%---Refly
			}
				
		}
		IDlog = %IDlog%%MyArray2%,
		
		FileAppend, 
		(
	<Placemark>

		), %Dir%\Metrics_%noExt%.kml

		LineEndID = %MyArray12%,%MyArray13%,0
		STime = %MyArray9%
		SDateTimeStart = 20%MyArray7%
	}
	
	If (MyArray17 > 0)
	{
		S := "0 "
		VarIDPos = %VarIDPos%%MyArray12%,%MyArray13%,
		VarIDPos := VarIDPos . S
		posX := MyArray12
		posY := MyArray13
		PArrayPos = %PArrayPos%%MyArray12%,%MyArray13%,
		PArrayPos := PArrayPos . S
	}
	else
	{
		VarIDNeg = %MyArray12%,%MyArray13%,0%A_Space%%VarIDNeg%
		LineBegPos = %MyArray12%,%MyArray13%,0
		ETime = %MyArray9%
		SDateTimeEnd = 20%MyArray7%
		negX := MyArray12
		negY := MyArray13
		PArrayNeg = %MyArray12%,%MyArray13%,0%A_Space%%PArrayNeg%
	}
	
	If (MyArray19 != PreMyArray19 AND PreMyArray19 != 0)
	{
		If (PreArrayNeg != "" AND PreArrayPos != "")
		{
			Stringsplit, PrePpos, PreArrayPos, `,
			Stringsplit, PrePneg, PreArrayNeg, `,
			PrePposLat := PrePpos0-1, PrePposLat := PrePpos%PrePposLat%
			PrePposLong := PrePpos0-2, PrePposLong := PrePpos%PrePposLong%
			0check := "", 0check := SubStr(PrePposLong, 1, 1)
			If (0check = 0)
				StringTrimLeft, PrePposLong, PrePposLong, 2
			FrontPos =
(
%PrePposLong%,%PrePposLat%,0
)
			BackPos =
(
%PrePneg1%,%PrePneg2%,0
)
;~ msgbox, %FrontPos%`n%BackPos%
		}
		PArray := ""
		PArray = %PArrayPos%%PArrayNeg%
		PreArrayNeg := PArrayNeg
		PreArrayPos := PArrayPos
		PArrayNeg := ""
		PArrayPos := ""
		StringSplit, PArrayS, PArray, `,



		KMLTc =
		(
%KMLTc%<Placemark>
		<description><![CDATA[<b>UTC:</b>  %MyArray19%<br><br><b>GPS Week:</b>  %MyArray20%<br><b>GPS SOTW:</b>  %MyArray21%]]></description>
		<TimeSpan>
			<begin>%PreMyArray19%</begin>
			<end>%MyArray19%</end>
		</TimeSpan>
		<styleUrl>#msn_ylw-pushpin</styleUrl>
		<Polygon>
			<tessellate>1</tessellate>
			<outerBoundaryIs>
				<LinearRing>
					<coordinates>
						%FrontPos%%A_Space%%PArray%%A_Space%%BackPos%
					</coordinates>
				</LinearRing>
			</outerBoundaryIs>
		</Polygon>
	</Placemark>
		)
	}
	
	PreMyArray19 := MyArray19
	
	If (A_Index = 1)
	{
		SMDateTime = 20%MyArray7%
		Under = _
		StringReplace, SMDateTime, SMDateTime, %Under%
	}
	++RecCount		
	FOV += MyArray3
	PR += MyArray4
	FRet += MyArray5
	AGL += MyArray6
	If (posX = "" OR negX = "")
		continue
	else
		Height += ((Haversine(negY,posY,negX,posX))/2)/(tan(((MyArray3/2)*0.01745329251994329576923690768489)))
	
}
StringSplit, S, LineEndID, `,
StringSplit, E, LineBegPos, `,
Under = _
StringReplace, SDateTimeStart, SDateTimeStart, %Under%
StringReplace, SDateTimeEnd, SDateTimeEnd, %Under%
StringLeft, SDate, SDateTimeStart, 8
TAdjust := (-1)*(8 - DLS)
SDateTimeStart += TAdjust, Hours
SDateTimeEnd += TAdjust, Hours
Duration := SDateTimeEnd
Duration -= SDateTimeStart, Seconds
DurationO += Duration
DurationF = %SDate%000000
DurationF += Duration, Seconds
FormatTime, DurationF, %DurationF%, HH:mm:ss
FormatTime, StartF, %SDateTimeStart%, HH:mm:ss
FormatTime, EndF, %SDateTimeEnd%, HH:mm:ss
FormatTime, DateF, %SDateTimeStart%, MM/dd/yy
AvFOV := (Round((FOV/RecCount), 2))
AvPR := (Round((PR/RecCount), 2))
AvFRet := (Round((FRet/RecCount), 2))
AvAGL := (Round((AGL/RecCount), 2))
LLen := (Round((Haversine(S2,E2,S1,E1)), 2))
nmiLen := (Round((((Haversine(S2,E2,S1,E1))/1000)*0.539957), 2))
Cover := (Round((((LLen*((AvAGL*Tan((AvFOV*0.01745329252)/2))*2))/1000000)*247.105), 2))
MSpeed := (LLen/(ETime-STime))
AvSpeed := (Round((MSpeed*1.943844), 2))
AvDen := (Round(((AvPR/(((2*(AvAGL*(Tan((AvFOV/2)*0.01745329252)))))))/MSpeed), 2))
If (ID != "BITTEST" AND ID != "LASETEST")
{
	UL = UL
	Refly = Refly
	IfNotInString, ID, %UL%
	{
		++LineCount
		TotDen += ((AvPR/(((2*(AvAGL*(Tan((AvFOV/2)*0.01745329252)))))))/MSpeed)
		TotSpeed += (MSpeed*1.943844)
		TotLLen += ((Haversine(S2,E2,S1,E1)))
		TotAGL += (AGL/RecCount)
		TotFRet += (FRet/RecCount)
		TotPR += (PR/RecCount)
		TotFOV += (FOV/RecCount)
		IfNotInString, ID, %Refly%
		{
			TotCover += ((LLen*((AvAGL*Tan((AvFOV*0.01745329252)/2))*2))/1000000)*247.105
		}
	}
}

FileAppend, 
(
	<name>%ID%</name>
		<Snippet maxLines="0"></Snippet>	
		<description><![CDATA[<b>-------%LineID%-------</b><br><br><u>Line Statistics</u><br>Line Length..........%nmiLen% nmi<br>Coverage..............%Cover% acres<br>Start Date..............%DateF%<br>Start Time.............%StartF%<br>End Time..............%EndF%<br>Duration................%DurationF%<br><br><u>Per Line Averages:</u><br>FOV.........................%AvFOV% Deg<br>Pulse Rate............%AvPR% kHz<br>1st Ret `%...............%AvFRet% `%<br>AGL.........................%AvAGL% m<br>Speed.....................%AvSpeed% kts<br>Point Density.........%AvDen% pts/m]]>
		</description>
		<styleUrl>#msn_ylw-pushpin</styleUrl>
		<Polygon>
			<tessellate>1</tessellate>
			<outerBoundaryIs>
				<LinearRing>
					<coordinates>
						%VarIDPos%%VarIDNeg%%A_Space%%LineEndID%
					</coordinates>
				</LinearRing>
			</outerBoundaryIs>
		</Polygon>
	</Placemark>
</Folder>
%KMLT%
</Folder>
</Document>
</kml>
), %Dir%\Metrics_%noExt%.kml
KMLT := ""
Guicontrol, , MyProgress, 80
Guicontrol, , ProgressText, Done!
SMDateTime += TAdjust, Hours
Duration := SDateTimeEnd
Duration -= SMDateTime, Seconds
DurationM = %SDate%000000
DurationM += Duration, Seconds
DurationOn = %SDate%000000
DurationOn += DurationO, Seconds
FormatTime, DurationM, %DurationM%, HH:mm:ss
FormatTime, DurationOn, %DurationOn%, HH:mm:ss
LineCountDen := LineCount-ReflyCount
TotFOV := Round((TotFOV/LineCount), 2)
TotPR := Round((TotPR/LineCount), 2)
TotFRet := Round((TotFRet/LineCount), 2)
TotAGL := Round((TotAGL/LineCount), 2)
TotLLen := Round(((TotLLen/1000)*0.539957), 2)
TotCover := Round((TotCover*(1-(Over*0.01))), 2)
TotSpeed := Round((TotSpeed/LineCount), 2)
TotDen := Round(((TotDen/LineCountDen)/((100-Over)*0.01)), 2)

MetVar = 
(
	<Snippet maxLines="0"></Snippet>
	<description><![CDATA[<b>---Mission Metrics---<b><br>Total Distance.........%TotLLen% nmi<br>Total Coverage.......%TotCover% acres<br>Mission Duration...%DurationM%<br>OnLine Duration....%DurationOn%<br><br><b>---Mission Averages---<b><br>Average Density.....%TotDen% pts/m<br>Average Speed.......%TotSpeed% kts<br>Average AGL...........%TotAGL% m<br>Average 1stRet`%....%TotFRet% `%<br>Average PR.............%TotPR% kHz<br>Average FOV...........%TotFOV% Deg]]></description>
	
)

FileRead, Metrics, %Dir%\Metrics_%noExt%.kml
Loop, parse, Metrics, `n
{
	If (A_Index = 4)
	{
		Met = %Met%%MetVar%%A_LoopField%
		continue
	}
	Met = %Met%%A_LoopField%
}
Guicontrol, , MyProgress, 100

SNw =
If (SN7131 = 1)
	SNw := "SN7131"

FormatTime, FileDate, %SMDateTime%, MM-dd-yyyy

FileDelete, %Dir%\Metrics_%noExt%.kml
FileDelete, %Dir%\%FileDate%_%SNw%_%Plat%_Metrics.kml
FileAppend, %Met%, %Dir%\%FileDate%_%SNw%_%Plat%_Metrics.kml

FileDelete, %Dir%\%noExt%_filtered.csv
FileAppend, %SetVar%, %Dir%\%noExt%_filtered.csv

FileDelete, %Dir%\%noExt%_Swath.csv
FileAppend, %coordVar%, %Dir%\%noExt%_Swath.csv

Guicontrol, , ProgressText, Done!
Sleep, 1000

Gosub, Clean
return
}

Clean:
	{
		Sleep, 1000
		Guicontrol, , MyProgress, 5
		Guicontrol, , ProgressText, Setup Inputs
		0 =
		4005FOV0 =
		4005FOV1 =
		4005FOV2 =
		4005FOV3 =
		4005FOV4 =
		4005FOV5 =
		4005FOV6 =
		4005FOV7 =
		4005FOV8 =
		4005FOV9 =
		4005Range0 =
		4005Range1 = 
		4005Range10 =
		4005Range11 =
		4005Range12 =
		4005Range13 =
		4005Range14 =
		4005Range15 =
		4005Range16 =
		4005Range2 =
		4005Range3 =
		4005Range4 =
		4005Range5 =
		4005Range6 =
		4005Range7 =
		4005Range8 =
		4005Range9 =
		AGL =
		AvAGL =
		AvDen =
		AvFOV =
		AvFRet =
		AvHeight =
		AvPR =
		AvSpeed =
		Color =
		coordVar =
		coordVar1 =
		Cover =
		DateF =
		deltaAGL =
		Dir =
		DLS =
		Duration =
		DurationF =
		DurationM =
		DurationO =
		DurationOn =
		E0 =
		E1 =
		E2 =
		E3 =
		EndF =
		ErrorLevel =
		ETime =
		Ext =
		FileDate =
		Flog =
		FlogLen =
		FlogVar =
		FOV =
		FRet =
		Height =
		ID =
		ID0 =
		ID1 =
		ID2 =
		ID3 =
		ID4 =
		ID5 = 
		IDlog =
		IDNum =
		Line =
		Line0 =
		Line1 =
		Line2 =
		Line3 =
		Line4 =
		LineBegPos =
		LineCount =
		LineCountDen =
		LineEndID =
		LineID =
		LineNum =
		LLen =
		Met =
		Metrics =
		MetVar =
		Msg2002 =
		Msg2009 =
		Msg4005 =
		Msg4005FOV =
		Msg4005Range =
		MSpeed =
		MyArray0 =
		MyArray1 =
		MyArray10 =
		MyArray11 =
		MyArray12 =
		MyArray13 =
		MyArray14 =
		MyArray15 =
		MyArray16 =
		MyArray17 =
		MyArray18 =
		MyArray19 =
		MyArray2 =
		MyArray20 =
		MyArray21 =
		MyArray22 =
		MyArray23 =
		MyArray24 =
		MyArray25 =
		MyArray3 =
		MyArray4 =
		MyArray5 =
		MyArray6 =
		Myarray7 =
		MyArray8 =
		MyArray9 =
		MyProgress =
		negX =
		negY =
		nmiLen =
		noExt =
		Over =
		PAGL =
		posX =
		posY =
		PR =
		PreLine =
		ProgressText =
		RecCount =
		Record =
		Refly =
		ReflyCount =
		S =
		S0 =
		S1 =
		S2 =
		S3 =
		SDate =
		SDateTimeEnd =
		SDateTimeStart =
		SelectedFile =
		SetVar =
		SMDateTime =
		SN054 =
		SN094 =
		SN105 =
		SN106 =
		SN7131 =
		StartF =
		STime =
		SwArea =
		SwathStr =
		TAdjust =
		TotAGL =
		TotCover =
		TotDen =
		TotFOV =
		TotFRet =
		TotLLen =
		TotPR =
		TotSpeed =
		UL =
		Under =
		VarIDNeg =
		VarIDPos =
		wExt =
		return
	}

Parse:
{
IDNumLog =
SplitPath, SelectedFile, wExt, Dir, Ext, noExt
FileRead, INlog, %SelectedFile%
StringReplace, INlog, INlog, `r`n`r`n, `n, All

Msg2002 := "Msg 2002"
Msg4005Range := "Rng Crd 1 data"
Msg4005FOV := "FOV:"
Msg4005 := "Msg 4005"
Msg2009 := "Msg 2009"
Guicontrol, , MyProgress, 20
Guicontrol, , ProgressText, Parsing Log File

Loop, parse, INlog, `n, `r										; check system version / log version / system SN 
{
	sysCheck := strsplit(A_LoopField, ",")
	If InStr(sysCheck[4], "Msg 4002")
	{
		RegExMatch(sysCheck[4], "(.\..\..\..)", sysCheckM)
		sysCheckV := strsplit(sysCheckM1, ".")
		If (sysCheckV[1] >= 7) && (sysCheckV[2] = 2) {
			sysVersion := 1
			sysName := substr(sysCheck[16], 13)
			If !sysName
				continue
			else
				Break
		}
		If (sysCheckV[1] >= 7) && (sysCheckV[2] = 3) {
			sysVersion := 2
			sysName := substr(sysCheck[16], 13)
			If !sysName
				continue
			else
				Break
		}
		If (sysCheckV[1] >= 7) && (sysCheckV[2] > 3) {
			sysVersion := 3
			sysName := substr(sysCheck[16], 13)
			If !sysName
				continue
			else
				Break
		}
		else
			continue
	}
}

Loop, parse, INlog, `n
{
	StringSplit, MyArray, A_LoopField, `,
	;~ If (A_Index = 1)
		;~ FlogVar = %A_LoopField%`n
	IfInString, MyArray4, %Msg2009%
	{
		If (MyArray6 = "NIDAQ: on")
		{
			StringSplit, Line, Myarray7, %A_Space%
			LineNum := Line4
			StringSplit, ID, MyArray8, %A_Space%
			If (sysVersion = 1)
				IDNum := ID4
			If (sysVersion = 2)
				IDNum := ID5
			If (sysVersion = 3)
				IDNum := ID5
			IfNotInString, IDNumLog, %LineNum%
			{
				IfNotInString, IDNumLog, %IDNum%
					IDNumLog = %IDNumLog%%LineNum% - %IDNum%||
				else
					IDNumLog = %IDNumLog%%LineNum% - %IDNum% --- Refly||
			}
			;~ msgbox, %IDNumLog%
		}
	}
}
return
}
*/