FindLimit(initW, incPix) {	
	return (initW/incPix - Round(initW/incPix)) = 0 ? initW/incPix : (initW/incPix-1)
}