/*
Function: Args_Process
processes the command line arguments

Parameters:
	byRef command - receives the passed command
	byRef subcommand - receives the passed subcommand
	byref options - receives an array of passed options. if it's a value option, it's an object
	byRef values - receives an array of additional values passed
*/
Args_Process(byRef command, byRef subcommand, byRef options, byRef values)
{
	; --------------------------------------------------------------
	; parsing arguments into an array
	local args := []
	Loop %0%
	{
		args[A_Index] := Trim(%A_Index%, " `t""'")
	}
	; everything in this method up to here is obsolete in AHK v2
	; --------------------------------------------------------------

	; initializing variables
	options := [], values := []
	local finished_option_parsing := false

	; loop through arguments
	for each, arg in args
	{
		if (A_Index == 1 && CommandHandler.IsValidCommand(arg))
		{
			command := arg
			continue
		}
		else if (A_Index == 2 && CommandHandler.IsValidSubcommand(command, arg))
		{
			; todo: default subcommand
			subcommand := arg
			continue
		}

		if (arg == "--")
		{
			finished_option_parsing := true
			continue
		}
		finished_option_parsing := finished_option_parsing || (!Args_IsOption(args, A_Index) && !Args_IsOptionValue(args, A_Index))

		if (!finished_option_parsing) ; parsing options
		{
			if Args_IsOptionValue(args, A_Index)
				continue ; skip, was already included with its option (see 2 lines below)
			else if Args_IsValueOption(arg)
				options.Insert( { (arg) : args[A_Index + 1] } ) ; include value option and its value in the array
			else
				options.Insert(arg) ; include simple option in the array
		}
		else ; parsing values
		{
			values.Insert(arg)
		}
	}
}

/*
Function: Args_HasOption()
checks if the command line includes the specified option

Paramters:
	args - the argument array as returned by <Args_Parse()>
	option - an option string to find, typically a field from the OPT class

Returns:
	true if found, false otherwise
*/
Args_HasOption(args, option)
{
	return Args_FindOption(args, option) > 0
}

/*
Function: Args_HasOptions()
checks if the command line includes any of the specified options

Parameters:
	args - the argument array as returned by <Args_Parse()>
	options* - a variadic list of options to check for

Returns:
	true if any of the options was found, false if none was found
*/
Args_HasOptions(args, options*)
{
	for each, option in options
		if Args_HasOption(args, option)
			return true
	return false
}

/*
Function: Args_HasAllOptions
checks if the command line includes all of the specified options

Parameters:
	args - the argument array as returned by <Args_Parse()>
	options* - a variadic list of options to check for

Returns:
	true if all of the options was found, false if one ore more were not found
*/
Args_HasAllOptions(args, options*)
{
	bool := false
	for each, option in options
		bool := bool && Args_HasOption(args, option)
	return bool
}

/*
Function: Args_FindOption()
finds a specified option

Parameters:
	args - the argument array as returned by <Args_Parse()>
	option - the option string to search for

Returns:
	the index of the option in the argument array or -1 if not found
*/
Args_FindOption(args, option)
{
	Loop
	{
		index := Args_FindValue(args, option)
	} Until (index == -1 || Args_IsOption(args, index))
	return index
}

/*
Function: Args_IsOption()
[for internal use] checks if the specified argument is an option argument or not

Parameters:
	args - the argument array as returned by <Args_Parse()>
	index - the index of the argument within the array

Returns:
	true if it is an option, false otherwise
*/
Args_IsOption(args, index)
{
	end := Args_FindValue(args, "--")
	return Args_FindValue(OPT, args[index]) > -1 && (end > index || end == -1)
}

Args_IsValueOption(arg)
{
	return Args_FindValue(OPT_HANDLER.VALUE_OPTIONS, arg) != -1
}

/*
Function: Args_IsOptionValue()
[for internal use] checks if a specified argument is the value for an option or not

Parameters:
	args - the argument array as returned by <Args_Parse()>
	index - the index of the argument within the array

Returns:
	true if it is a value for an option, false otherwise
*/
Args_IsOptionValue(args, index)
{
	return Args_IsOption(args, index - 1) && Args_IsValueOption(args[index - 1])
}

/*
Function: Args_GetOptionValue()
gets the value of a option which has a parameter

Parameters:
	args - the argument array as returned by <Args_Parse()>
	options* - a variadic list of options to check for

Returns:
	the value of the first occurence of one of the specified options
*/
Args_GetOptionValue(args, options*)
{
	for each, option in options
	{
		index := Args_FindOption(args, option)
		if (index > 0)
			return args[index+1]
	}
}

/*
Function: Args_HasOnlyOneOption()
checks if one and only one of the specified options is present

Parameters:
	args - the argument array as returned by <Args_Parse()>
	options* - a variadic list of options to check for

Returns:
	false if 0 or > 1 occurrences of any of the options were found, true if there's just 1
*/
Args_HasOnlyOneOption(args, options*)
{
	found := false, temp_found := false
	for each, option in options
	{
		temp_found := Args_HasOption(args, option)
		if (found)
			return false
		found := temp_found
	}
	return found
}

; ===========================================================================================================
/*
Function: Args_GetValueParam()
gets the value of a parameter which is *not an option*

Parameters:
	args - the argument array as returned by <Args_Parse()>
	index - the index of the value parameter ("search for the %index%st value param")

Returns:
	the value of that parameter
*/
Args_GetValueParam(args, index)
{
	return args[Args_FindValueParam(args, index)]
}

/*
Function: Args_CountValueParams()
counts the number of parameters that are not options

Parameters:
	args - the argument array as returned by <Args_Parse()>

Returns:
	the count (0 if none were specified)
*/
Args_CountValueParams(args)
{
	count := 0
	while (Args_FindValueParam(args, A_Index) > -1)
		count++
	return count
}

/*
Function: Args_FindValueParam()
[for internal use] finds a parameter which is not an option

Parameters:
	args - the argument array as returned by <Args_Parse()>
	index - the index of the value parameter ("search for the %index%st value param")

Returns:
	the index of the parameter, if found. -1 if none is found.
*/
Args_FindValueParam(args, index)
{
	foundIndex := 0
	for each, arg in args
	{
		if (A_Index == 1 || A_Index < index)
			continue
		if (!Args_IsOption(args, A_Index) && !Args_IsOptionValue(args, A_Index) && arg != "--")
			foundIndex++
		if (foundIndex == index)
			return A_Index
	}
	return -1
}

; ===========================================================================================================
/*
Function: Args_FindValue
[for internal use] finds a value in the argument array

Parameters:
	args - the argument array as returned by <Args_Parse()>
	value - the value to find

Returns:
	the index if found, -1 otherwise
*/
Args_FindValue(args, value)
{
	for each, arg in args
		if (arg == value)
			return A_Index
	return -1
}