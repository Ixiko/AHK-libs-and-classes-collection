/*

  PCREAHK.C implements helper routines to facilitate using PCRE (see below)
  from within AutoHotkey. pcre_match() is used to search a string for a
  regex whereas pcre_replace() does a match-and-replace.

  A certain familiarity with regexes and/or PCRE would be an advantage. See
  the PCRE site (http://www.pcre.org) or else the slightly more accessible
  documentation at http://mushclient.com/pcre/.

  The two examples (MATCH.AHK and REPLACE.AHK) are exactly that: examples. They
  simply show how to call the DLL functions and provide two wrappers for that
  purpose.

  The parameters of these two wrapper functions can (and should) be changed,
  according to the requirements (this is especially true for the temp storage
  provided for the DLL calls: if this is too small all sorts of funny things
  can (and will) happen.)

  The DLL functions, on the other hand, must be called *exactly* as shown.

  The included DLL contains the complete PCRE implementation as well the
  functions shown below. It should be copied to the AHK directory or any other
  place where AHK can find it.

  The code in this file (PCREAHK.C) was hacked together by Thomas Lauer during
  a spell of bad British weather (no, this is not an oxymoron) and it is in
  the public domain. It was tested (not very extensively) with PCRE 5.0 and
  may or may not work with newer versions.

  The last time I wrote something in C must be, oh, about five years ago. It
  is therefore possible, probable even, that the code is not optimal. Hints
  are welcome.

  Comments, ideas, improvements should be directed to the AHK forum.


  -----------------------------------------------------------------------------
  More about PCRE:

  PCRE is a library of functions to support regular expressions whose syntax
  and semantics are as close as possible to those of the Perl 5 language. See
  the file Tech.Notes for some information on the internals.

  Written by: Philip Hazel <ph10@cam.ac.uk>

             Copyright (c) 1997-2004 University of Cambridge


  -----------------------------------------------------------------------------
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

      * Redistributions of source code must retain the above copyright notice,
        this list of conditions and the following disclaimer.

      * Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.

      * Neither the name of the University of Cambridge nor the names of its
        contributors may be used to endorse or promote products derived from
        this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
  -----------------------------------------------------------------------------

*/

#include "internal.h"
#include "pcreposix.h"
#include "stdlib.h"

/*

  Error codes for regcomp() and regexec() calls:

  REG_ASSERT   (1)   internal error
  REG_BADBR    (2)   invalid repeat counts in {}
  REG_BADPAT   (3)   pattern error
  REG_BADRPT   (4)   ? * + invalid
  REG_EBRACE   (5)   unbalanced {}
  REG_EBRACK   (6)   unbalanced []
  REG_ECOLLATE (7)   collation error - not relevant
  REG_ECTYPE   (8)   bad class
  REG_EESCAPE  (9)   bad escape sequence
  REG_EMPTY    (10)  empty expression
  REG_EPAREN   (11)  unbalanced ()
  REG_ERANGE   (12)  bad range inside []
  REG_ESIZE    (13)  expression too big
  REG_ESPACE   (14)  failed to get memory
  REG_ESUBREG  (15)  bad back reference
  REG_INVARG   (16)  bad argument
  REG_NOMATCH  (17)  match failed

*/

/* This code supports no more than 128 captured substrings (which should
   be enough for most applictions). */
#define RMATCH 128

/* see match.ahk for the parameters */
EXPORT int pcre_match(const char *string,int offset,const char *pattern,int options,char *result);
EXPORT int pcre_match(const char *string,int offset,const char *pattern,int options,char *result)
{
  regex_t re;
  regmatch_t rm[RMATCH];
  char temp[32]="";
  int i=regcomp(&re,pattern,options);
  if (i) {
    regfree(&re);
    return -i;
  }
  i=regexec(&re,&string[offset],RMATCH,rm,0);
  regfree(&re);
  if (i) {
    if (i==REG_NOMATCH) i=0;
    return -i;
  }
  if ((rm[0].rm_so==-1)||(rm[0].rm_eo==-1)) return 0;
  i=0;
  while ((rm[i].rm_so!=-1)) {
    sprintf(temp,"%i %i ",rm[i].rm_so+offset,rm[i].rm_eo-rm[i].rm_so);
    strcat(result,temp);
    i++;
  }
  strcat(result,"-1 -1");
  return i;
}

void get_replacement(const char *source,const char *replace,char *result,regmatch_t *rm);
void get_replacement(const char *source,const char *replace,char *result,regmatch_t *rm)
{
  int i,l;
  while (*replace) {
    if (*replace=='$') {
      replace++;
      i=*replace++;
      switch (i) {
        case '{':
          l=rm[0].rm_so;
          strncpy(result,source,l);
          result+=l;
          break;
        case '}':
          strcpy(result,&source[rm[0].rm_eo]);
          result+=strlen(&source[rm[0].rm_eo]);
          break;
        case '$':
          *result++='$';
          break;
        default:
          i-='0'; /* not overly clean but good if you know what you do */
          l=rm[i].rm_eo-rm[i].rm_so;
          strncpy(result,&source[rm[i].rm_so],l);
          result+=l;
      }
    }
    else *result++=*replace++;
  }
  *result='\0';
}

/* see replace.ahk for the parameters */
EXPORT int pcre_replace(char *string,int offset,const char *pattern,int options,const char *replace);
EXPORT int pcre_replace(char *string,int offset,const char *pattern,int options,const char *replace)
{
  regex_t re;
  regmatch_t rm[RMATCH];
  char *temp;
  int i=regcomp(&re,pattern,options);
  if (i) {
    regfree(&re);
    return -i;
  }
  i=regexec(&re,&string[offset],RMATCH,rm,0);
  regfree(&re);
  if (i) {
    if (i==REG_NOMATCH) i=0;
    return -i;
  }
  if ((rm[0].rm_so==-1)||(rm[0].rm_eo==-1)) return 0;
  i=0;
  while ((rm[i].rm_so!=-1)) {
    rm[i].rm_so+=offset;
    rm[i++].rm_eo+=offset;
  }
  temp=(char *)pcre_malloc(strlen(string)+1);
  strcpy(temp,string);
  get_replacement(temp,replace,string,rm);
  pcre_free(temp);
  return 1;
}
