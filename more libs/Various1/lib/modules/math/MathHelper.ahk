class MathHelper {

	__new() {
		throw Exception("Instatiation of class '" this.__Class
				. "' ist not allowed", -1)
	}

	floorCeil(pstrType, pnFloorCeil, p*) {
		for i, v in p {
			if (v.maxIndex() != "") {
				for j, v1 in v {
					if (!IsObject(v1)) {
						if v1 is not number
						{
							throw Exception("Invalid data type", -1, "<" v1 ">")
						}
						if ((pstrType = "ceil" && v1 > pnFloorCeil)
								|| (pstrType = "floor" && v1 < pnFloorCeil)) {
							pnFloorCeil := v1
						}
					} else {
						pnFloorCeil := MathHelper.floorCeil(pstrType
								, pnFloorCeil, v1)
					}
				}
			} else {
				if v is not number
				{
					throw Exception("Invalid data type", -1, "<" v ">")
				}
				if ((pstrType = "ceil" && v > pnFloorCeil)
						|| (pstrType = "floor" && v < pnFloorCeil)) {
					pnFloorCeil := v
				}
			}
		}
		return pnFloorCeil
	}

	GCDEuklid(pnValue1, pnValue2) { ; ahklint-ignore: W007
		if (pnValue1 < pnValue2) {
			Math.swap(pnValue1, pnValue2)
		}
		return MathHelper.GCDEuklidRecursion(pnValue1, pnValue2)
	}

	GCDEuklidRecursion(pnValue1, pnValue2) { ; ahklint-ignore: W007
		_remain := Mod(pnValue1, pnValue2)
		if (_remain > 0) {
			return MathHelper.GCDEuklidRecursion(pnValue2, _remain)
		}
		return pnValue2
	}
}
