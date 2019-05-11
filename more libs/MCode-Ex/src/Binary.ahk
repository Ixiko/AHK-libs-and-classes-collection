class Binary {
	__New(endianness := "LE") {
		this.endianness	:= endianness
		this.size 		:= 0
		this.hexString		:= ""
	}
	
	getSize() {
		return this.size
	}
	
	getLength() {
		return this.size
	}
	
	getHexString() {
		return this.hexString
	}
	
	getEndianness() {
		return this.endiannes
	}
	
	resize(newByteSize) {
		if (newByteSize < this.size) {
			this.hexString := subStr(this.hexString, 1, (newByteSize*2))
		} else if (newByteSize > this.size) {
			this.hexString .= Format("{:0" . ((newByteSize-this.size)*2) . "s}", "")
		}
		this.size := newByteSize
	}
	
	appendHexString(hex, endianness := "LE") {
		hex := regexReplace(hex, "\s")
		if (!RegexMatch(hex, "^([a-fA-F0-9]{2})+$"))
			throw exception("invalid hex", -1, hex)
		if (endianness != this.endianness) {
			hex := this.invertHex(hex)
		}
		this.hexString	.= hex
		this.size		+= floor(strLen(hex)/2)
	}
	
	appendInteger(integer, byteSize, endianness := "BE") {
		if (log(integer)/log(2) > byteSize*8) { ;because the left size is the size in bits
			throw exception("provided integer is greater than the maximum number that can be encoded with", -1)
		}
		this.appendHexString(Format( "{:0" . (byteSize*2) . "x}", integer ), endianness)
	}
	
	appendBinaryObject(bin) {
		if (bin.__class != this.__class)
			throw exception("incompatible binary formats", -1)
		if (this.getEndianness() != bin.getEndianness()) {
			throw exception("incompatible endianness", -1)
		}
		this.appendHexString(bin.getHexString())
	}
	
	invertHex(byref hex) {
		outHex := ""
		len := strLen(hex)/2
		Loop % len {
			outHex .= subStr(hex, (len-A_Index)*2+1, 2)
		}
		return outHex
	}
	
	numPut(number, offsetInBytes, sizeInBytes) {
		if (offset > this.getSize())
			throw exception("trying to put a number beyond the end of the binary", -1)
		tmp := subStr(this.getHexString(), (offsetInBytes+sizeInBytes)*2+1)
		this.resize(offsetInBytes)
		this.appendInteger(number, sizeInBytes)
		this.appendHexString(tmp)
	}
}