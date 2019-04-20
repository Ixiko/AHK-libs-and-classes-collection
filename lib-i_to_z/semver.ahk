semver_validate(version)
{
	return !!RegExMatch(version, "^(\d+)\.(\d+)\.(\d+)(\-([0-9A-Za-z\-]+\.)*[0-9A-Za-z\-]+)?(\+([0-9A-Za-z\-]+\.)*[0-9A-Za-z\-]+)?$")
}
semver_parts(version, byRef out_major, byRef out_minor, byRef out_patch, byRef out_prerelease, byRef out_build)
{
	return !!RegExMatch(version, "^(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)(\-(?P<prerelease>([0-9A-Za-z\-]+\.)*([0-9A-Za-z\-]+)))?(\+?(?P<build>([0-9A-Za-z\-]+\.)*([0-9A-Za-z\-]+)))?$", out_)
}
semver_compare(version1, version2)
{
	if (!semver_parts(version1, maj1, min1, pat1, pre1, bld1))
		throw Exception("Invalid version: " version1)
	if (!semver_parts(version2, maj2, min2, pat2, pre2, bld2))
		throw Exception("Invalid version: " version2)

	for each, part in ["maj", "min", "pat"]
	{
		%part%1 += 0, %part%2 += 0
		if (%part%1 < %part%2)
			return -1
		else if (%part%1 > %part%2)
			return +1
	}

	for each, part in ["pre", "bld"] ; { "pre" : 1, "bld" : -1 }
	{
		if (%part%1 && %part%2)
		{
			StringSplit part1_, %part%1, .
			StringSplit part2_, %part%2, .
			Loop % part1_0 < part2_0 ? part1_0 : part2_0 ; use the smaller amount of parts
			{
				if part1_%A_Index% is digit
				{
					if part2_%A_Index% is digit ; both are numeric: compare numerically
					{
						part1_%A_Index% += 0, part2_%A_Index% += 0
						if (part1_%A_Index% < part2_%A_Index%)
							return -1
						else if (part1_%A_Index% > part2_%A_Index%)
							return +1
						continue
					}
				}
				; at least one is non-numeric: compare by characters
				if (part1_%A_Index% < part2_%A_Index%)
					return -1
				else if (part1_%A_Index% > part2_%A_Index%)
					return +1
			}
			; all compared parts were equal - the longer one wins
			if (part1_0 < part2_0)
				return -1
			else if (part1_0 > part2_0)
				return +1
		}
		else if (!%part%1 && %part%2) ; only version2 has prerelease -> version1 is higher
			return (part == "pre") ? +1 : -1
		else if (!%part%2 && %part%1) ; only version1 has prerelease -> it is smaller
			return (part == "pre") ? -1 : +1
	}

	return 0
}