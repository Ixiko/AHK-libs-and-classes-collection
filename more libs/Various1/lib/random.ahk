class Random {

	static N := 624
	static M := 397
	static MATRIX_A := 0x9908b0df
	static UPPER_MASK := 0x80000000
	static LOWER_MASK := 0x7fffffff

	mt := []
	mti := Random.N + 1

	__new(p1, p2="") {
		if (IsObject(p1) && p1.minIndex() != "") {
			if (p2 = "" || p2 = 0) {
				p2 := p1.maxIndex()
			}
			this.initializeRandomGeneratorByArray(p1, p2)
		} else {
			this.initializeRandomGenerator(p1)
		}

		return this
	}

	init_genrand(pSeed) { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated. Use initializeRandomGenerator() instead. ; ahklint-ignore: W002
		return this.initializeRandomGenerator(speed)
	} ; notest-end

	initializeRandomGenerator(pSeed) {
		this.mt[0] := pSeed & 0xffffffff
		this.mti := 1
		while (this.mti < Random.N) {
			this.mt[this.mti] := 1812433253
					* (this.mt[this.mti-1] ^ (this.mt[this.mti-1] >> 30))
					+ this.mti
			this.mt[this.mti] &= 0xffffffff
			this.mti++
		}
	}

	init_by_array(paInit_key, piKey_length) { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated. Use initializeRandomGeneratorByArray() instead. ; ahklint-ignore: W002
		return this.initializeRandomGeneratorByArray(paInit_key, piKey_length)
	} ; notest-end

	initializeRandomGeneratorByArray(initialKeyArray, keyLength) {
		this.initializeRandomGenerator(19650218)
		i := 1, j := 0
		k := (Random.N > keyLength ? Random.N : keyLength)
		while (k) {
			this.mt[i] := (this.mt[i] ^ ((this.mt[i-1] ^ (this.mt[i-1] >> 30))
					* 1664525)) + initialKeyArray[j+1] + j
			this.mt[i] &= 0xffffffff
			i++, j++
			if (i >= Random.N) {
				this.mt[0] := this.mt[Random.N-1]
				i := 1
			}
			if (j >= keyLength) {
				j := 0
			}
			k--
		}
		k := Random.N - 1
		while (k) {
			this.mt[i] := (this.mt[i] ^ ((this.mt[i-1] ^ (this.mt[i-1] >> 30))
					* 1566083941)) - i
			this.mt[i] &= 0xffffffff
			i++
			if (i >= Random.N) {
				this.mt[0] := this.mt[Random.N-1]
				i := 1
			}
			k--
		}
		this.mt[0] := 0x80000000
	}

	genrand_int32() { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated. Use generateRandomInt32() instead. ; ahklint-ignore: W002
		return this.generateRandomInt32()
	} ; notest-end
	generateRandomInt32() {
		mag01 := []
		mag01[0] := 0x0
		mag01[1] := Random.MATRIX_A

		if (this.mti >= Random.N) {
			if (this.mti == Random.N + 1) {
				this.initializeRandomGenerator(5489)
			}
			kk := 0
			while (kk < Random.N - Random.M) {
				y := (this.mt[kk] & Random.UPPER_MASK)
						| (this.mt[kk+1] & Random.LOWER_MASK)
				this.mt[kk] := this.mt[kk+Random.M] ^ (y >> 1) ^ mag01[y & 0x1]
				kk++
			}
			while (kk < Random.N - 1) {
				y := (this.mt[kk] & Random.UPPER_MASK)
						| (this.mt[kk+1] & Random.LOWER_MASK)
				this.mt[kk] := this.mt[kk+(Random.M-Random.N)]
						^ (y >> 1) ^ mag01[y & 0x1]
				kk++
			}
			y := (this.mt[Random.N-1] & Random.UPPER_MASK)
					| (this.mt[0] & Random.LOWER_MASK)
			this.mt[Random.N-1] := this.mt[Random.M-1]
					^ (y >> 1) ^ mag01[y & 0x1]
			this.mti := 0
		}

		y := this.mt[this.mti++]

		y ^= (y >> 11)
		y ^= (y << 7) & 0x9d2c5680
		y ^= (y << 15) & 0xefc60000
		y ^= (y >> 18)

		return y
	}

	genrand_real1() { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated. Use generateRandomReal1() instead. ; ahklint-ignore: W002
		return this.generateRandomReal1()
	} ; notest-end
	generateRandomReal1() {
		a := this.generateRandomInt32() * (1.0 / 4294967295.0)
		return a
	}

	genrand_real2() { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated. Use generateRandomReal2() instead. ; ahklint-ignore: W002
		return this.generateRandomReal2()
	} ; notest-end
	generateRandomReal2() {
		a := this.generateRandomInt32() * (1.0 / 4294967296.0)
		return a
	}

	genrand_int31() { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated. Use generateRandomInt31() instead. ; ahklint-ignore: W002
		return this.generateRandomInt31()
	} ; notest-end
	generateRandomInt31() {
		a := this.generateRandomInt32() >> 1
		return a
	}

	genrand_real3() { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated. Use generateRandomReal3() instead. ; ahklint-ignore: W002
		return this.generateRandomReal3()
	} ; notest-end
	generateRandomReal3() {
		a := (this.generateRandomInt32() + 0.5) * (1.0 / 4294967296.0)
		return a
	}

	genrand_res53() { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated. Use generateRes53() instead. ; ahklint-ignore: W002
		return this.generateRes53()
	} ; notest-end
	generateRes53() {
		a := this.generateRandomInt32() >> 5
		b := this.generateRandomInt32() >> 6
		return (a * 67108864.0 + b) * (1.0 / 9007199254740992.0)
	}
}
