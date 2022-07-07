/*

	Ported to AutoHotkey by RaptorX
	November 30, 2016

	Copyright 2014 Google Inc. All rights reserved.

	Licensed under the Apache License, Version 2.0 (the 'License');
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an 'AS IS' BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.

*/

/**
 * Convert locations to and from short codes.
 *
 * Open Location Codes are short, 10-11 character codes that can be used instead
 * of street addresses. The codes can be generated and decoded offline, and use
 * a reduced character set that minimises the chance of codes including words.
 *
 * Codes are able to be shortened relative to a nearby location. This means that
 * in many cases, only four to seven characters of the code are needed.
 * To recover the original code, the same location is not required, as long as
 * a nearby location is provided.
 *
 * Codes represent rectangular areas rather than points, and the longer the
 * code, the smaller the area. A 10 character code represents a 13.5x13.5
 * meter area (at the equator. An 11 character code represents approximately
 * a 2.8x3.5 meter area.
 *
 * Two encoding algorithms are used. The first 10 characters are pairs of
 * characters, one for latitude and one for latitude, using base 20. Each pair
 * reduces the area of the code by a factor of 400. Only even code lengths are
 * sensible, since an odd-numbered length would have sides in a ratio of 20:1.
 *
 * At position 11, the algorithm changes so that each character selects one
 * position from a 4x5 grid. This allows single-character refinements.
 *
 * Examples:
 *
 *   Encode a location, default accuracy:
 *   olcObj = new OpenLocationCode
 *   clipboard := olcObj.encode(47.365590, 8.524997)
 *
 *   Encode a location using one stage of additional refinement:
 *	 olcObj = new OpenLocationCode
 *   clipboard := olcObj.encode(47.365590, 8.524997, 11)
 *
 * Todo:
 *   Decode a full code
 *   Attempt to trim the first characters from a code
 *   Recover the full code from a short code
 */

class OpenLocatorCode
{

	/**
	* Provides a normal precision code, approximately 14x14 meters.
	*/
	static CODE_PRECISION_NORMAL := 10

	/**
	* Provides an extra precision code, approximately 2x3 meters.
	*/
	static CODE_PRECISION_EXTRA := 11

	/**
	 * A separator used to break the code into two parts to aid memorability.
	 *
	 */
	static SEPARATOR := "+"

	/**
	 * The number of characters to place before the separator.
	 */
	static SEPARATOR_POSITION := 8

	/**
	 * The character used to pad codes.
	 */
	static PADDING_CHARACTER := "0"

	/**
	 * The character set used to encode the values.
	 */
	static CODE_ALPHABET := "23456789CFGHJMPQRVWX"

	/**
	 * The base to use to convert numbers to/from.
	 */
	static ENCODING_BASE := strlen(CODE_ALPHABET)

	/**
	 * The maximum value for latitude in degrees.
	 */
	static LATITUDE_MAX := 90

	/**
	 * The maximum value for longitude in degrees.
	 */
	static LONGITUDE_MAX := 180

	/**
	 * Maxiumum code length using lat/lng pair encoding. The area of such a
	 * code is approximately 13x13 meters (at the equator), and should be suitable
	 * for identifying buildings. This excludes prefix and separator characters.
	 */
	static PAIR_CODE_LENGTH := 10

	/**
	 * The resolution values in degrees for each position in the lat/lng pair
	 * encoding. These give the place value of each position, and therefore the
	 * dimensions of the resulting area.
	 */
	static PAIR_RESOLUTIONS := [20.0, 1.0, 0.05, 0.0025, 0.000125]

	/**
	 * Number of columns in the grid refinement method.
	 */
	static GRID_COLUMNS := 4

	/**
	 * Number of rows in the grid refinement method.
	 */
	static GRID_ROWS := 5

	/**
	 * Size of the initial grid in degrees.
	 */
	static GRID_SIZE_DEGREES := 0.000125

	/**
	 * Minimum length of a code that can be shortened.
	 */
	static MIN_TRIMMABLE_CODE_LEN := 6

	/**
	Returns the OLC alphabet.
	*/
	getAlphabet() {
		return this.CODE_ALPHABET
	}

	/**
	* Determines if a code is valid.
	*
	* To be valid, all characters must be from the Open Location Code character
	* set with at most one separator. The separator can be in any even-numbered
	* position up to the eighth digit.
	*
	* @param {string} code The string to check.
	* @return {boolean} True if the string is a valid code.
	*/
	isValid(code) {

		if (!code || !regexmatch(code, "^[\w\" this.SEPARATOR "]+$")) {
		  return false
		}
		; The separator is required.
		if (!instr(code, this.SEPARATOR)) {
		  return false
		}
		/* if (code.indexOf(SEPARATOR_) != code.lastIndexOf(SEPARATOR_)) {
		  return false;
		} */
		; Is it the only character?
		if (strlen(code) == 1) {
		  return false
		}
		; Is it in an illegal position?
		if (regexmatch(code, "\Q" this.SEPARATOR "\E") > this.SEPARATOR_POSITION || mod(regexmatch(code, "\Q" this.SEPARATOR "\E"), 2) == 1) {
		  return false
		}
		/*
			We can have an even number of padding characters before the separator,
			but then it must be the final character.
		*/
		if (regexmatch(code, "\Q" this.PADDING_CHARACTER "\E") > 0) {
		  ; Not allowed to start with them!
		  if (regexmatch(code, "\Q" this.PADDING_CHARACTER "\E") == 1) {
			return false
		  }
		  ; There can only be one group and it must have even length.
		  regexmatch(code, "(\Q" this.PADDING_CHARACTER "\E+)", padMatch)
		  if (strlen(padMatch) > 1 || mod(strlen(padMatch), 2) == 1
		  || strlen(padMatch) > (this.SEPARATOR_POSITION - 2)) {
			return false
		  }
		  ; If the code is long enough to end with a separator, make sure it does.
		  if (substr(code, 0) != this.SEPARATOR) {
			return false
		  }
		}
		/*
			If there are characters after the separator, make sure there isn't just
			one of them (not legal).

			AHK Specifics: 	since regexmatch starts its position at 1, we are forced to
							subtract -1 aditional to the original code to compensate
							for the aditional position that we have in AHK
		*/
		if (strlen(code) - regexmatch(code, "\Q" this.SEPARATOR "\E") - 2 == 1) {
		  return false
		}

		; Strip the separator and any padding characters.
		code := regexreplace(regexreplace(code, "\Q" this.SEPARATOR "\E+")
											  , "\Q" this.PADDING_CHARACTER "\E+")
		; Check the code contains only valid characters.
		loop parse, code
		{

			character := format("{:U}", a_loopfield)
			if (character != this.SEPARATOR && !instr(this.CODE_ALPHABET, character))
				return false

		}

		return true

	}

	/**
	* Determines if a code is a valid short code.
	*
	* @param {string} code The string to check.
	* @return {boolean} True if the string can be produced by removing four or
	*     more characters from the start of a valid code.
	*/
	isShort(code) {
		; Check it's valid.
		if (!this.isValid(code)) {
			return false
		}
		; If there are less characters than expected before the SEPARATOR.
		if (regexmatch(code, "\Q" this.SEPARATOR "\E") >= 1
		&& instr(code, this.SEPARATOR) < this.SEPARATOR_POSITION) {
			return true
		}
		return false
	}

	/**
	* Determines if a code is a valid full Open Location Code.
	*
	* @param {string} code The string to check.
	* @return {boolean} True if the code represents a valid latitude and
	*     longitude combination.
	*/
	isFull(code) {
		if (!this.isValid(code)) {
			return false
		}
		; If it's short, it's not full.
		if (this.isShort(code)) {
			return false
		}

		/*
			Work out what the first latitude character indicates for latitude.
			o get the first char in code and convert it to UPPERCASE
			o find that character in our alphabet and get its position from the alphabet
			o multiply that location by the encoding base, this is the value that we will verify against our MAX
		 */
		firstLatValue := instr(this.CODE_ALPHABET, format("{:U}", substr(code, 1))) * this.ENCODING_BASE
		if (firstLatValue >= this.LATITUDE_MAX * 2) {
			; The code would decode to a latitude of >= 90 degrees.
			return false
		}
		if (strlen(code) > 1) {
			/*
				Work out what the first longitude character indicates for longitude.
				o get the first char in code and convert it to UPPERCASE
				o find that character in our alphabet and get its position from the alphabet
				o multiply that location by the encoding base, this is the value that we will verify against our MAX
			*/
			firstLngValue := instr(this.CODE_ALPHABET, format("{:U}", substr(code,2))) * this.ENCODING_BASE
			if (firstLngValue >= this.LONGITUDE_MAX * 2) {
			; The code would decode to a longitude of >= 180 degrees.
				return false
			}
		}
		return true
	}

	/**
	* Encode a location into an Open Location Code.
	*
	* @param {number} latitude The latitude in signed decimal degrees. It will
	*     be clipped to the range -90 to 90.
	* @param {number} longitude The longitude in signed decimal degrees. Will be
	*     normalised to the range -180 to 180.
	* @param {?number} codeLength The length of the code to generate. If
	*     omitted, the value OpenLocationCode.CODE_PRECISION_NORMAL will be used.
	*     For a more precise result, OpenLocationCode.CODE_PRECISION_EXTRA is
	*     recommended.
	* @return {string} The code.
	* @throws {Exception} if any of the input values are not numbers.
	*/
	encode(latitude, longitude, codeLength=10) {
		if (isNaN(latitude) || isNaN(longitude) || isNaN(codeLength)) {
		  throw "ValueError: Parameters should be numbers"
		}
		if (codeLength < 2 || (codeLength < this.SEPARATOR_POSITION && mod(codeLength, 2) == 1)) {
		  throw "IllegalArgumentException: Invalid Open Location Code length"
		}
		; Ensure that latitude and longitude are valid.
		latitude := clipLatitude(latitude)
		longitude := normalizeLongitude(longitude)
		/*
			Latitude 90 needs to be adjusted to be just less, so the returned code
			can also be decoded.
		*/
		if (latitude == 90) {
		  latitude = latitude - computeLatitudePrecision(codeLength)
		}
		code := this.encodePairs(latitude, longitude, codeLength < this.PAIR_CODE_LENGTH ? codeLength
																					: this.PAIR_CODE_LENGTH)
		/* For Future development
		; If the requested length indicates we want grid refined codes.
		if (codeLength > this.PAIR_CODE_LENGTH) {
		  code += encodeGrid(latitude, longitude, codeLength - this.PAIR_CODE_LENGTH)
		}
		*/
		return code
	}

	/**
	* Decodes an Open Location Code into its location coordinates.
	*
	* Returns a CodeArea object that includes the coordinates of the bounding
	* box - the lower left, center and upper right.
	*
	* @param {string} code The code to decode.
	* @return {OpenLocationCode.CodeArea} An object with the coordinates of the
	*     area of the code.
	* @throws {Exception} If the code is not valid.
	*/
	decode(code) {
		if (!this.isFull(code)) {
			throw "IllegalArgumentException: Passed Open Location Code is not a valid full code: " code
		}
		/*
			Strip out separator character (we've already established the code is
			valid so the maximum is one), padding characters and convert to upper
			case.
		*/
		code := regexreplace(code, "\Q" this.SEPARATOR "\E")
		code := regexreplace(code, "\Q" this.PADDING_CHARACTER "\E+")
		code := format("{:U}", code)

		; Decode the lat/lng pair component.
		codeArea := this.decodePairs(substr(code, 1, this.PAIR_CODE_LENGTH))

		; If there is a grid refinement component, decode that.
		if (strlen(code) <= this.PAIR_CODE_LENGTH) {
			return codeArea
		}
		/* For Future development
		var gridArea = decodeGrid(code.substring(PAIR_CODE_LENGTH_))
		return CodeArea(
		codeArea.latitudeLo + gridArea.latitudeLo,
		codeArea.longitudeLo + gridArea.longitudeLo,
		codeArea.latitudeLo + gridArea.latitudeHi,
		codeArea.longitudeLo + gridArea.longitudeHi,
		codeArea.codeLength + gridArea.codeLength)
		*/
	}

	/**
	* Recover the nearest matching code to a specified location.
	*
	* Given a valid short Open Location Code this recovers the nearest matching
	* full code to the specified location.
	*
	* @param {string} shortCode A valid short code.
	* @param {number} referenceLatitude The latitude to use for the reference
	*     location.
	* @param {number} referenceLongitude The longitude to use for the reference
	*     location.
	* @return {string} The nearest matching full code to the reference location.
	* @throws {Exception} if the short code is not valid, or the reference
	*     position values are not numbers.

	var recoverNearest = OpenLocationCode.recoverNearest = function(
	shortCode, referenceLatitude, referenceLongitude) {
	if (!isShort(shortCode)) {
	if (isFull(shortCode)) {
	return shortCode;
	} else {
	throw 'ValueError: Passed short code is not valid: ' + shortCode;
	}
	}
	referenceLatitude = Number(referenceLatitude);
	referenceLongitude = Number(referenceLongitude);
	if (isNaN(referenceLatitude) || isNaN(referenceLongitude)) {
	throw ('ValueError: Reference position are not numbers');
	}
	// Ensure that latitude and longitude are valid.
	referenceLatitude = clipLatitude(referenceLatitude);
	referenceLongitude = normalizeLongitude(referenceLongitude);

	// Clean up the passed code.
	shortCode = shortCode.toUpperCase();
	// Compute the number of digits we need to recover.
	var paddingLength = SEPARATOR_POSITION_ - shortCode.indexOf(SEPARATOR_);
	// The resolution (height and width) of the padded area in degrees.
	var resolution = Math.pow(20, 2 - (paddingLength / 2));
	// Distance from the center to an edge (in degrees).
	var areaToEdge = resolution / 2.0;

	// Use the reference location to pad the supplied short code and decode it.
	var codeArea = decode(
	encode(referenceLatitude, referenceLongitude).substr(0, paddingLength)
	+ shortCode);
	// How many degrees latitude is the code from the reference? If it is more
	// than half the resolution, we need to move it east or west.
	var degreesDifference = codeArea.latitudeCenter - referenceLatitude;
	if (degreesDifference > areaToEdge) {
	// If the center of the short code is more than half a cell east,
	// then the best match will be one position west.
	codeArea.latitudeCenter -= resolution;
	} else if (degreesDifference < -areaToEdge) {
	// If the center of the short code is more than half a cell west,
	// then the best match will be one position east.
	codeArea.latitudeCenter += resolution;
	}

	// How many degrees longitude is the code from the reference?
	degreesDifference = codeArea.longitudeCenter - referenceLongitude;
	if (degreesDifference > areaToEdge) {
	codeArea.longitudeCenter -= resolution;
	} else if (degreesDifference < -areaToEdge) {
	codeArea.longitudeCenter += resolution;
	}

	return encode(
	codeArea.latitudeCenter, codeArea.longitudeCenter, codeArea.codeLength);
	};
	*/

	/**
	* Encode a location into a sequence of OLC lat/lng pairs.
	*
	* This uses pairs of characters (longitude and latitude in that order) to
	* represent each step in a 20x20 grid. Each code, therefore, has 1/400th
	* the area of the previous code.
	*
	* This algorithm is used up to 10 digits.
	*
	* @param {number} latitude The location to encode.
	* @param {number} longitude The location to encode.
	* @param {number} codeLength Requested code length.
	* @return {string} The up to 10-digit OLC code for the location.
	*/
	encodePairs(latitude, longitude, codeLength) {
		; Adjust latitude and longitude so they fall into positive ranges.
		adjustedLatitude := latitude + this.LATITUDE_MAX
		adjustedLongitude := longitude + this.LONGITUDE_MAX
		/*
			Count digits - can't use string length because it may include a separator
			character.
		*/
		digitCount = 0
		while (digitCount < codeLength) {
			/*
				Provides the value of digits in this place in decimal degrees.

				AHK specifics: the index in AHK starts at 1 so we need to add it when
				getting the positiion for the PAIR_RESOLUTIONS object
			*/
			placeValue := this.PAIR_RESOLUTIONS[floor(digitCount / 2)+1]
			/*
				Do the latitude - gets the digit for this place and subtracts that for
				the next digit.
			*/
			digitValue := floor(adjustedLatitude / placeValue) + 1 ; account for AHK index difference
			adjustedLatitude -= digitValue * placeValue
			code .= substr(this.CODE_ALPHABET, digitValue, 1)
			digitCount += 1
			/*
				And do the longitude - gets the digit for this place and subtracts that
				for the next digit.
			*/
			digitValue := floor(adjustedLongitude / placeValue) +1 ; account for AHK index difference
			adjustedLongitude -= digitValue * placeValue
			code .= substr(this.CODE_ALPHABET, digitValue, 1)
			digitCount += 1

			; Should we add a separator here?
			if (digitCount == this.SEPARATOR_POSITION && digitCount < codeLength) {
				code .= this.SEPARATOR
			}
		}
		if (strlen(code) < this.SEPARATOR_POSITION) {
			loop % (this.SEPARATOR_POSITION - strlen(code) + 1)
				padding .= this.PADDING_CHARACTER
			code := code padding
		}
		if (strlen(code) == this.SEPARATOR_POSITION) {
			code := code this.SEPARATOR
		}
		return code
	}

	/**
	* Encode a location using the grid refinement method into an OLC string.
	*
	* The grid refinement method divides the area into a grid of 4x5, and uses a
	* single character to refine the area. This allows default accuracy OLC codes
	* to be refined with just a single character.
	*
	* This algorithm is used for codes longer than 10 digits.
	*
	* @param {number} latitude The location to encode.
	* @param {number} longitude The location to encode.
	* @param {number} codeLength Requested code length.
	* @return {string} The OLC code digits from the 11th digit on.

	var encodeGrid = function(latitude, longitude, codeLength) {
	var code = '';
	var latPlaceValue = GRID_SIZE_DEGREES_;
	var lngPlaceValue = GRID_SIZE_DEGREES_;
	// Adjust latitude and longitude so they fall into positive ranges and
	// get the offset for the required places.
	var adjustedLatitude = (latitude + LATITUDE_MAX_) % latPlaceValue;
	var adjustedLongitude = (longitude + LONGITUDE_MAX_) % lngPlaceValue;
	for (var i = 0; i < codeLength; i++) {
	// Work out the row and column.
	var row = Math.floor(adjustedLatitude / (latPlaceValue / GRID_ROWS_));
	var col = Math.floor(adjustedLongitude / (lngPlaceValue / GRID_COLUMNS_));
	latPlaceValue /= GRID_ROWS_;
	lngPlaceValue /= GRID_COLUMNS_;
	adjustedLatitude -= row * latPlaceValue;
	adjustedLongitude -= col * lngPlaceValue;
	code += CODE_ALPHABET_.charAt(row * GRID_COLUMNS_ + col);
	}
	return code;
	};
	*/


	/**
	* Decode an OLC code made up of lat/lng pairs.
	*
	* This decodes an OLC code made up of alternating latitude and longitude
	* characters, encoded using base 20.
	*
	* @param {string} code The code to decode, assumed to be a valid full code,
	*     but with the separator removed.
	* @return {OpenLocationCode.CodeArea} The code area object.
	*/
	decodePairs(code) {
	/*
		Get the latitude and longitude values. These will need correcting from
		positive ranges.
	*/
	latitude := this.decodePairsSequence(code, 0)
	longitude := this.decodePairsSequence(code, 1)

	/*
	; Correct the values and set them into the CodeArea object.
	return new CodeArea(
	latitude[0] - LATITUDE_MAX_,
	longitude[0] - LONGITUDE_MAX_,
	latitude[1] - LATITUDE_MAX_,
	longitude[1] - LONGITUDE_MAX_,
	code.length)
	*/
	}

	/**
	* Decode either a latitude or longitude sequence.
	*
	* This decodes the latitude or longitude sequence of a lat/lng pair encoding.
	* Starting at the character at position offset, every second character is
	* decoded and the value returned.
	*
	* @param {string} code A valid full OLC code, with the separator removed.
	* @param {string} offset The character to start from.
	* @return {[number]} An array of two numbers, representing the lower and
	*     upper range in decimal degrees. These are in positive ranges and will
	*     need to be corrected appropriately.
	*/
	decodePairsSequence(code, offset) {
		i := 0
		value := 0
		while (i * 2 + offset < strlen(code)) {
			value += instr(this.CODE_ALPHABET, substr(code, i * 2 + offset, 1)) * this.PAIR_RESOLUTIONS[i]
			i += 1
		}

		return [value, value + this.PAIR_RESOLUTIONS[i - 1]]
	}

	/**
	* Decode the grid refinement portion of an OLC code.
	*
	* @param {string} code The grid refinement section of a code.
	* @return {OpenLocationCode.CodeArea} The area of the code.

	var decodeGrid = function(code) {
	var latitudeLo = 0.0;
	var longitudeLo = 0.0;
	var latPlaceValue = GRID_SIZE_DEGREES_;
	var lngPlaceValue = GRID_SIZE_DEGREES_;
	var i = 0;
	while (i < code.length) {
	var codeIndex = CODE_ALPHABET_.indexOf(code.charAt(i));
	var row = Math.floor(codeIndex / GRID_COLUMNS_);
	var col = codeIndex % GRID_COLUMNS_;

	latPlaceValue /= GRID_ROWS_;
	lngPlaceValue /= GRID_COLUMNS_;

	latitudeLo += row * latPlaceValue;
	longitudeLo += col * lngPlaceValue;
	i += 1;
	}
	return CodeArea(
	latitudeLo, longitudeLo, latitudeLo + latPlaceValue,
	longitudeLo + lngPlaceValue, code.length);
	};
	*/

}

/**
* Verify if the passes variable is Not a Number
*
* @param {variable} var
* @return {boolean} true if is not a number, false if it is a number
*/
isNaN(var) {
	if (regexmatch(var, "[^0-9\-\+\.]+"))
		return true
	else
		return false
}

/**
* Clip a latitude into the range -90 to 90.
*
* @param {number} latitude
* @return {number} The latitude value clipped to be in the range.
*/
clipLatitude(latitude) {
	latitude := latitude <  90 ? latitude :  90
	latitude := latitude > -90 ? latitude : -90

	return latitude
}

/**
* Compute the latitude precision value for a given code length.
* Lengths <= 10 have the same precision for latitude and longitude, but
* lengths > 10 have different precisions due to the grid method having
* fewer columns than rows.
* @param {number} codeLength
* @return {number} The latitude precision in degrees.
*/
computeLatitudePrecision(codeLength) {
	if (codeLength <= 10) {
		pw := floor(codeLength / -2 + 2)
	  return 20**pw
	}
	return 20**-3 / this.GRID_ROWS**(codeLength - 10)
}

/**
* Normalize a longitude into the range -180 to 180, not including 180.
*
* @param {number} longitude
* @return {number} Normalized into the range -180 to 180.
*/
normalizeLongitude(longitude) {
	while (longitude < -180) {
		longitude := longitude + 360
	}
	while (longitude >= 180) {
		longitude := longitude - 360
	}
	return longitude
}

/**
* Remove characters from the start of an OLC code.
*
* This uses a reference location to determine how many initial characters
* can be removed from the OLC code. The number of characters that can be
* removed depends on the distance between the code center and the reference
* location.
*
* @param {string} code The full code to shorten.
* @param {number} latitude The latitude to use for the reference location.
* @param {number} longitude The longitude to use for the reference location.
* @return {string} The code, shortened as much as possible that it is still
*     the closest matching code to the reference location.
* @throws {Exception} if the passed code is not a valid full code or the
*     reference location values are not numbers.

var shorten = OpenLocationCode.shorten = function(
code, latitude, longitude) {
if (!isFull(code)) {
throw 'ValueError: Passed code is not valid and full: ' + code;
}
if (code.indexOf(PADDING_CHARACTER_) != -1) {
throw 'ValueError: Cannot shorten padded codes: ' + code;
}
var code = code.toUpperCase();
var codeArea = decode(code);
if (codeArea.codeLength < MIN_TRIMMABLE_CODE_LEN_) {
throw 'ValueError: Code length must be at least ' +
MIN_TRIMMABLE_CODE_LEN_;
}
// Ensure that latitude and longitude are valid.
latitude = Number(latitude);
longitude = Number(longitude);
if (isNaN(latitude) || isNaN(longitude)) {
throw ('ValueError: Reference position are not numbers');
}
latitude = clipLatitude(latitude);
longitude = normalizeLongitude(longitude);
// How close are the latitude and longitude to the code center.
var range = Math.max(
Math.abs(codeArea.latitudeCenter - latitude),
Math.abs(codeArea.longitudeCenter - longitude));
for (var i = PAIR_RESOLUTIONS_.length - 2; i >= 1; i--) {
// Check if we're close enough to shorten. The range must be less than 1/2
// the resolution to shorten at all, and we want to allow some safety, so
// use 0.3 instead of 0.5 as a multiplier.
if (range < (PAIR_RESOLUTIONS_[i] * 0.3)) {
// Trim it.
return code.substring((i + 1) * 2);
}
}
return code;
};
*/

