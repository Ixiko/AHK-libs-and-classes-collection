Gaussian(lower = 0.0, upper = 1.0) {
	Static x := 0x7FFFFFF
	return lower + (upper - lower)
	* (Random(-x, x) + Random(-x, x) + Random(-x, x) + Random(-x, x)
	+ Random(-x, x) + Random(-x, x) + Random(-x, x) + Random(-x, x)
	+ Random(-x, x) + Random(-x, x) + Random(-x, x) + Random(-x, x)
	+ 12 * x) / (24 * x)
}
