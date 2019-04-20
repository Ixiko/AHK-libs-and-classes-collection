========================================================================

 p_List, p_Pick [, p_InputD, p_InputO, p_OutputDin, p_OutputDout,
                   p_Reverse, p_Offset, p_Count, p_Func, p_Valid]

 + Required parameters:
 - p_List        Input list of elements (optionally delimited)
 - p_Pick        Number of elements for each tuple

 + Optional parameters:
 - p_InputD      Delimiters of the input list* (default: blank)
 - p_InputO      OmitChars for each input element* (default: space and tab)
 - p_OutputDin   Output delimiter between elements (default: space)
 - p_OutputDout  Output delimiter between tuples (default: newline)
 - p_Reverse     Boolean for tuples in the reverse order (default: 0)
 - p_Offset      Starting offset for computing tuples (default: 0)
 - p_Count       Number of tuples to compute (default: 0, means all)
 - p_Func        Function to execute on each tuple (default: blank)
 - p_Valid       Number of valid outputs to compute (default: 0, means all)

 The function will compute each tuple of p_Pick elements, which may have
 repetition. See http://en.wikipedia.org/wiki/Tuple for more information.

 * Both p_InputD and p_InputO are lists of single characters. Check
 http://www.autohotkey.com/docs/commands/StringSplit.htm for more info.

 A blank string will be returned if at least one of the following happens:
 - p_List is blank
 - p_Pick is not greater than 0

 If p_Func is blank, GetTuples will output all tuples at once (delimited by
 p_OutputDout). This option may fail when computing too many tuples, due to
 some issues regarding maximum memory and output size.

 If p_Func is the name [literal string] of another function, it will be
 executed for each tuple right away and its returned value (if any) will be
 concatenated to the output of GetTuples (still delimited by p_OutputDout).
 The p_Func function must have one required parameter (to receive the tuple).

 When using p_Func as described above, any non-blank string returned by the
 custom function is considered "valid". The p_Valid parameter can be used to
 force GetTuples to stop after a certain number of valid custom outputs has
 been reached.

========================================================================