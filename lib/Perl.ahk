;http://www.autohotkey.com/forum/topic2869.html


;Combining Perl with AHK in the same script using ActivePerl
;Notes:
;  wperl allows the script to run without opening an additional window
;  -x flag says to read from #!perl line to end of file
;------------------------------------------------------------------------------
^!r::
;---Set the input for the routine---
perl_input=42 File(s)      1,173,988 bytes

;---Set the function you want to run from your perl script---
perl_action=files_bytes
Gosub, PerlRun

;---Display the output---
MsgBox,%perl_output%
return

;==========Everything below this line is the Perl "library"====================
;---First, the AHK Perl interface---
PerlRun:
ClipBoard0=%ClipBoardAll%
ClipBoard=%perl_input%
RunWait, C:\Perl\bin\wperl -x %A_ScriptFullPath% %perl_action%
perl_action=
perl_output=%ClipBoard%
ClipBoard=%ClipBoard0%
return


;---Then, the Perl code itself---
/******************************************************************************
#!perl
# For giving Perl capability to ahk

use strict;
use Win32::Clipboard;
my $wc = Win32::Clipboard();
my $data = $wc->Get();
my $action = $ARGV[0];

if($action eq
#------------------------------------------------------------------------------
'no_whitespace'
#------------------------------------------------------------------------------
) {
  $data =~ s/\s//g;
} elsif($action eq
#------------------------------------------------------------------------------
'files_bytes'
#------------------------------------------------------------------------------
) {
  for($data) {
    $_ = join(';',split /[^\d,]+/, $data);
    s/,//g;
  }
} else {
#------------------------------------------------------------------------------
# Default action
#------------------------------------------------------------------------------
  $data =~ s/s/x/g;
}

$wc->Set($data);

__END__
*/
