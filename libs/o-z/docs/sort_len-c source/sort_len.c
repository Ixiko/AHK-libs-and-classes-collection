#include <stddef.h>
// functions declaration
typedef void* __cdecl (*realloc)(void*,size_t);				// realloc
typedef void __cdecl (*_free)(void*);	 					// free
typedef void* __cdecl (*memcpy)(void*,const void*,size_t);  // memccpy

// debug:
//typedef void __cdecl (*pmb)(void*, unsigned int);   // db
//int sort_len(unsigned short* src, unsigned short* del, int shortFirst, unsigned int dellen, realloc pr, _free fr, memcpy cpy, pmb mb){ // db

// compiled with gcc, -Ofast
int sort_len(unsigned short* src, unsigned short* del, int shortFirst, unsigned int dellen, int omitEmpty, realloc pr, _free fr, memcpy cpy){
	// params:
	//		src, null terminated string to sort delimited substrings in.
	//		del, any length null terminated string defining the delimiter.
	//		shortFirst, -if 1, put shortest substrings first, else longer comes first.
	//		dellen, the length of the delimiter, null terminator not included.
	//		omitEmpty, specify 1 to omit "empty" substrings, eg, 'a,,b' -> 'a,b' instead of ',a,b', set to 0 to include "empty"
	//		realloc, pointer to: https://msdn.microsoft.com/en-us/library/xbebcx7d.aspx (MSVCRT.dll realloc) 
	//		free, pointer to: https://msdn.microsoft.com/en-us/library/we1whae7.aspx (MSVCRT.dll free)
	//		memccpy, pointer to: https://msdn.microsoft.com/en-us/library/dswaw1wk.aspx (MSVCRT.dll memccpy)
	//
	// out:
	// 		-1 on fail, >= 0 on success.
	//
	if (*src == 0 || *del == 0 || dellen == 0)	// input check
		return 0;
	// variable declaration and init.	
	unsigned int j,o;													// j is loop index, o is offset in two separate parts
	unsigned int newLen;
	unsigned int so = 0;												// source offset, the offset from the source (src) start where the search is currently.
	unsigned int si = 0;												// "next" substring index. When a substring is found, si is the length of it.
											
	unsigned int maxLen = 50; 											// Maximum substr length, automatically expands if needed.
	unsigned int nEmpty = 0; 											// Number of empty substrings found, eg, del = ',' src = 'a,,b' yields nEmpty = 1;
	unsigned int done = -1;												// Main loop end criteria, break when not equal -1
											
	unsigned int min = maxLen;											// min and max substring length found.
	unsigned int max = 0;												// Needed to avoid writing outside of buffer (src).
												
	unsigned short** ss = 0;											// array of pointer to substrings, each substring is a del-delimited string of substrings of the same length.
	unsigned int* sso = 0;												// array of offset values of where the substrings in the ss array ends, i.e., where to write new substrings.
	unsigned int* sslens = 0;											// array of the allocated size of the substrings in the ss array.
																		
	unsigned short** sst = 0;											// Temporary pointer for the three arrays above, used for realloc
	unsigned int* ssot = 0;
	unsigned int* sslenst = 0;
	
	unsigned short* ssst = 0;											// Temporary string buffer for realloc substring in ss array.
	
	// allocate space for the three arrays.
	ss = pr(0, maxLen*sizeof(unsigned short*));	
	if (ss == 0)
		return 0;	
	
	sslens = pr(0, maxLen*sizeof(unsigned int));
	if (sslens == 0)
		goto cleanup;
		
	sso = pr(0, maxLen*sizeof(unsigned int));
	if (sso == 0)
		goto cleanup;
	
	// zero init the three arrays
	for (j = 0; j < maxLen; ++j) {
		ss[j] = 0;
		sslens[j] = 0;
		sso[j] = 0;
	}
	do { 																// main loop - start
		si = 0;															// length of found substring, delimiter not included.
		findSubstring:
		while(1){ 														// find next substr
			while (src[so+si] != 0 && src[so+si] != del[0]) 			// search for delimiter
				++si;
			for(j = 0; src[so+si+j] == del[j] && j < dellen && src[so+si+j] != 0; ++j);	// potentially found delimiter, continue search
			
			if (j == dellen)	                                        // delim found
				break;													
			if (src[so+si+j] == 0){ 									// end of src.
				si+=j;                                                  
				done=1;                                                 
				break;                                                  
			}                                                           
			si += j == 0 ? 1 : j;										// no delimiter, increment substring index and continue
		}
		if (si == 0) {													// found empty substring, that is, two adjacent delimiters or a delimiter at the beginning or at the end of src.
			nEmpty++;										
			if (src[so] == 0)											// found delimiter at the end of src, eg, src = 'a,' (del = ',')
				goto endOfMainLoop;
			so += dellen;
			goto findSubstring;
		}
		// Substring was found.
		// si is the length of the substring.
		if (si >= maxLen) {	// ensure space in ss array. (substring array)
			if ((sst = pr(ss, si*2*sizeof(unsigned short*))) == 0)		// realloc substring array
				goto cleanup;
			ss = sst;			   										// update pointer after successfull reallocation.
			if ((sslenst = pr(sslens, si*2*sizeof(unsigned int))) == 0)	// realloc substring lengths array
				goto cleanup;
			sslens = sslenst;      										// update pointer after successfull reallocation.
			if ((ssot = pr(sso, si*2*sizeof(unsigned int))) == 0)			// realloc substring offset array
				goto cleanup;
			sso = ssot;		      										// update pointer after successfull reallocation.
			// zero init
			for (j = maxLen; j < si*2; ++j) {							// zero fill the unused part only.
				ss[j] = 0;
				sslens[j] = 0;
				sso[j] = 0;
			}
			if (min == maxLen)											// if min wasn't set. Set it to maxLen*2
				min = si*2;						
			maxLen = si*2;												// update maxLen
		}
		min = si < min ? (si != 0 ? si : 1) : min;						// Update min / max 
		max = si > max ? si : max;
		o = sso[si-1];													// get the offset to append the found substring in the string for substrings of length si.
		if (o+si+dellen >= sslens[si-1]){								// ensure space for substring is ss array holding strings of length si
			newLen = sslens[si-1] == 0 ? (si+dellen)*(si < 50 ? 50 : 2)  : sslens[si-1]*2;	// initially, allocate space for 50 "short" or 2 "long" substrings of length si, subsequent expansions doubles. (Arbitrary choise)
			ssst = pr(ss[si-1], newLen*sizeof(unsigned short));			// allocate memory for newLen characters in the string holding substrings of length si.
			if (ssst == 0)
				goto cleanup;
			ss[si-1] = ssst;											// successful realloc, update pointers and new max length for the buffer.
			sslens[si-1] = newLen;
		}
		if (cpy(ss[si-1]+o, src+so, si*sizeof(unsigned short)) == 0)	// copy the substr.
			goto cleanup;
		for (j = 0; j < dellen; ++j) 									// write the delimiter. Presumably, the delimiter is short, manual writing should be faster than function call.
			*(ss[si-1]+o+si+j) = del[j];
		sso[si-1] += si+dellen;											// update the offset for substring of lengths si
		so += si+dellen;												// update source offset, src+so is where the search continues
	
	} while (done == -1);												// main loop - end
	// done ! Copy all substrings into the source buffer.
	endOfMainLoop:
	if (max == 0) { 													// contains only delimiters - clean up and return
		if (omitEmpty != 0)
			src[0] = 0;													// null terminate at the start of src.
		done = nEmpty;
		goto cleanup;
	}
	done = -1;
	o = 0; 																// offset to write to in source.
	if (shortFirst != 0) {												// short substrings first
		if (omitEmpty == 0) {
			while (nEmpty > 0) {										// write the delimiter nEmpty times. a,,b -> ,a,b
				for (j = 0; j < dellen; ++j) 							// delimiter copy loop		
					src[o+j] = del[j];
				o += dellen;											// increment the offset
				--nEmpty;												// decrement the empty count until all "empty" delimiters are written
			}
		}
		for (j = min-1; j < max-1; ++j){
			if (sslens[j] != 0) { 										// if there is a substring of length j+1,
				if (!cpy(src+o, ss[j], sso[j]*sizeof(unsigned short)))	// copy the full length of that substring into src+o
					goto cleanup;
				o += sso[j];											// increment the offset
			}
		}
		                                                                // write the last substring, adjust length by dellen to avoid trailing delimiter, also ensures no writes outside of buffer and the result is null terminated.
		if (!cpy(src+o, ss[max-1], (sso[max-1]-dellen)*sizeof(unsigned short))) 
			goto cleanup;
		o += sso[max-1]-dellen; 										// this is where the null terminator should be if omitting empty
	} else { 															// longer substrings first
		for (j = max-1; j > min-1; --j){
			if (sslens[j]!=0) { 										// if there is a substring of length j+1,
				if (!cpy(src+o, ss[j], sso[j]*sizeof(unsigned short)))	// copy the full length of that substring into src+o
					goto cleanup;
				o += sso[j];											// increment the offset
			}
		}
		if (!cpy(src+o, ss[min-1], (sso[min-1]-dellen)*sizeof(unsigned short))) // write the last substring, adjust length by dellen to avoid trailing delimiter, also ensures no writes outside of buffer and the result is null terminated.
			goto cleanup;
		o += sso[min-1]-dellen; 										// this is where the null terminator should be if omitting empty
		if (omitEmpty == 0) {
			while (nEmpty > 0) {										// write the delimiter nEmpty times. a,,b -> a,b,
				for (j = 0; j < dellen; ++j) 							// delimiter copy loop								
					src[o+j] = del[j];
				o += dellen;                                            // increment the offset
				--nEmpty;                                               // decrement the empty count until all "empty" delimiters are written
			}
		}
	}
	done = nEmpty; 														// return the number of empty substrings, if zero, varsetcapacity(src,-1) is not needed when omitting empty.
	if (omitEmpty != 0)
		src[o] = 0;														// null terminate if omitting empty, if no empty found, this is already 0.
		
	cleanup:; 															// cleanup - free all allocations
	for (j= 0; j < maxLen; j++)
		if (ss[j] != 0)
			fr(ss[j]);
																		// free temp pointers in case of early clean up (fail.) 
	fr(ss);
	fr(sso);
	fr(sslens);
	return done; 														// return >= 0 on success, -1 on fail.
}