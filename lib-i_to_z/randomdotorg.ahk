; v0.3 by gahks 
; Functions:
;
; randomdotorg_integer()	
; randomdotorg_string()	
; randomdotorg_password()	
; randomdotorg_randomizelist()	
; randomdotorg_lottery()	
; randomdotorg_clocktime()
; randomdotorg_sequence()	
; randomdotorg_decimalfraction()	
; randomdotorg_gaussian()	
; randomdotorg_bitmap()	
; randomdotorg_noise()
; randomdotorg_quota()
;
; http://autohotkey.net/~gahks/
; http://autohotkey.net/~gahks/doc/randomdotorg
; more info in the documentation


/*
Title: RANDOM.ORG API function library
*/

/*
   Function: randomdotorg_integer()

   It generates truly random integers in configurable intervals.

   Parameters:

        num - The number of integers requested. Possible values: [1,1e4]

        min - The smallest value allowed for each integer. Possible values: [-1e9,1e9]

        max - The largest value allowed for each integer. Possible values: [-1e9,1e9]

        base - Optional. The base that will be used to print the numbers, i.e., binary, octal, decimal or hexadecimal. Default value: 10. Possible values: 2 | 8 | 10 | 16 
        rnd - Optional. Default value: "new". Possible values: new | id.identifier | date.iso-date. For further info see: Remarks.

   Returns:

      * Success: Generated integers as comma separated values (CSV)
      * Error: The string "Error:" followed by a string with further details.
   
   Remarks:
      rnd:
      
      Determines the randomization to use to generate the numbers. If new is specified, then a new randomization will created from the truly random bitstream at RANDOM.ORG. This is probably what you want in most cases. If id.identifier is specified, the identifier is used to determine the randomization in a deterministic fashion from a large pool of pregenerated random bits. Because the numbers are produced in a deterministic fashion, specifying an id basically uses RANDOM.ORG as a pseudo-random number generator. The third (date.iso-date) form is similar to the second; it allows the randomization to be based on one of the daily pregenerated files. This form must refer to one of the dates for which files exist, so it must be the current day (according to UTC) or a day in the past. The date must be in ISO 8601  format (i.e., YYYY-MM-DD) or one of the two shorthand strings today or yesterday.
   
   Examples:
      >MsgBox, % randomdotorg_integer(10,0,9999)
      >MsgBox, % randomdotorg_integer(5,111111,121212,10,"date.2010-01-01")
      >MsgBox, % randomdotorg_integer(1,-555,555)
      >MsgBox, % randomdotorg_integer(1,0,10,2)
*/
randomdotorg_integer(num,min,max,base="10",rnd="new") {
	_url:="http://www.random.org/integers/?num=" num "&min=" min "&max=" max "&col=1&base=" base "&format=plain&rnd=" rnd
	httpQuery(_ret:="",_url), VarSetCapacity(_ret,-1)
	IfNotInString, _ret, Error:
		StringReplace, _ret, _ret, `n, `,, All
	return SubStr(_ret,0,1)="," ? SubStr(_ret,1,StrLen(_ret)-1) : _ret ;trimming the last comma
}	



/*
   Function: randomdotorg_string()

   It generates truly random strings of various length and character compositions.
   
   Parameters:
        num - The number of strings requested. Possible values:  [1,1e4]

        len - The length of the strings. All the strings produced will have the same length. Possible values: [1,20]

        digits - Optional. Determines whether digits (0-9) are allowed to occur in the strings. Default value: true. Possible values: true | false

        upperalpha - Optional. Determines whether uppercase alphabetic characters (A-Z) are allowed to occur in the strings. Default value: true. Possible values: true | false

        loweralpha - Optional. Determines whether lowercase alphabetic characters (a-z) are allowed to occur in the strings. Default value: true. Possible values: true | false

        unique - Optional. Determines whether the strings picked should be unique (as a series of raffle tickets drawn from a hat) or not (as a series of die rolls). If unique is set to on, then there is the additional constraint that the number of strings requested (num) must be less than or equal to the number of strings that exist with the selected length and characters. Default value: true. Possible values: true | false

         rnd - Optional. Default value: "new". Possible values: new | id.identifier | date.iso-date. For further info see: Remarks.

   Returns:

      * Success: Generated strings as comma separated values (CSV)
      * Error: The string "Error:" followed by a string with further details.
   
   Remarks:
      rnd:
      
      Determines the randomization to use to generate the numbers. If new is specified, then a new randomization will created from the truly random bitstream at RANDOM.ORG. This is probably what you want in most cases. If id.identifier is specified, the identifier is used to determine the randomization in a deterministic fashion from a large pool of pregenerated random bits. Because the numbers are produced in a deterministic fashion, specifying an id basically uses RANDOM.ORG as a pseudo-random number generator. The third (date.iso-date) form is similar to the second; it allows the randomization to be based on one of the daily pregenerated files. This form must refer to one of the dates for which files exist, so it must be the current day (according to UTC) or a day in the past. The date must be in ISO 8601  format (i.e., YYYY-MM-DD) or one of the two shorthand strings today or yesterday.
   
   Examples:
      >;This one generates ten unique strings. Each string is 15 characters long, 
      >;and contains lower- and uppercase letters and numbers: 
      >MsgBox, % randomdotorg_string(10,15)
      >
      >
      >;This one generates five strings. Each string is 12 characters long,
      >;and consists of lowercase letters and numbers, and the strings may be identical: 
      >MsgBox, % randomdotorg_string(5,12,true,false,true,false)
*/
randomdotorg_string(num,len,digits=true,upperalpha=true,loweralpha=true,unique=true,rnd="new") {
   _url:="http://www.random.org/strings/?num=" num "&len=" len
    . "&digits=" (digits ? "on" : "off") "&upperalpha=" (upperalpha ? "on" : "off") ;as suggested by sinkfaze. thanks ;)
    . "&loweralpha=" (loweralpha ? "on" : "off") "&unique=" (unique ? "on" : "off")
    . "&format=plain&rnd=" rnd
	httpQuery(_ret:="",_url), VarSetCapacity(_ret,-1)
	IfNotInString, _ret, Error:
		StringReplace, _ret, _ret, `n, `,, All
	return SubStr(_ret,0,1)="," ? SubStr(_ret,1,StrLen(_ret)-1) : _ret ;trimming the last comma
}



/*
   Function: randomdotorg_password()

   It generates truly random passwords (6-24 characters long).

   Parameters:
        num - The number of passwords requested. Possible values: [1,100]

        len - The length of passwords (in characters). Possible values: [6,24]

        rnd - Optional. Default value: "new". Possible values: new | id.identifier | date.iso-date. For further info see: Remarks.

   Returns:

      * Success: Generated passwords as comma separated values (CSV)
      * Error: The string "Error:" followed by a string with further details.
   
   Remarks:
      rnd:
      
      Determines the randomization to use to generate the numbers. If new is specified, then a new randomization will created from the truly random bitstream at RANDOM.ORG. This is probably what you want in most cases. If id.identifier is specified, the identifier is used to determine the randomization in a deterministic fashion from a large pool of pregenerated random bits. Because the numbers are produced in a deterministic fashion, specifying an id basically uses RANDOM.ORG as a pseudo-random number generator. The third (date.iso-date) form is similar to the second; it allows the randomization to be based on one of the daily pregenerated files. This form must refer to one of the dates for which files exist, so it must be the current day (according to UTC) or a day in the past. The date must be in ISO 8601  format (i.e., YYYY-MM-DD) or one of the two shorthand strings today or yesterday.
      
      About security:
      
      The passwords are transmitted securely (via SSL) and are not stored on the RANDOM.ORG server. Nevertheless, the best data security practice is not to let anyone but yourself generate your most important passwords. So, feel free to use these passwords for your wi-fi encryption or for that extra Gmail account, but you shouldn't use any online service to generate passwords for highly sensitive things, such as your online bank account.
   
   Examples:
      >MsgBox, % randomdotorg_password(10,20)
      >MsgBox, % randomdotorg_password(10,6)
*/
randomdotorg_password(num,len,rnd="new") {
   global httpQueryDwFlags
   httpQueryDwFlags := (0x00800000|0x00000100|0x00001000|0x00002000|0x00000200) ;for ssl
;   INTERNET_FLAG_SECURE                    = 0x00800000
;   SECURITY_FLAG_IGNORE_UNKNOWN_CA         = 0x00000100
;   SECURITY_FLAG_IGNORE_CERT_CN_INVALID    = 0x00001000
;   SECURITY_FLAG_IGNORE_CERT_DATE_INVALID  = 0x00002000
;   SECURITY_FLAG_IGNORE_CERT_WRONG_USAGE   = 0x00000200
	_url:="https://www.random.org/passwords/?num=" num "&len=" len "&format=plain&rnd=" rnd
	httpQuery(_ret:="",_url), VarSetCapacity(_ret,-1)
	IfNotInString, _ret, Error:
		StringReplace, _ret, _ret, `n, `,, All
	return SubStr(_ret,0,1)="," ? SubStr(_ret,1,StrLen(_ret)-1) : _ret ;trimming the last comma
}	



/*
   Function: randomdotorg_randomizelist()

   It arranges the items of a list in random order.

   Parameters:
        list - A list of items to randomize. The items must be separated by linebreaks (`r`n).

        rnd - Optional. Default value: "new". Possible values: new | id.identifier | date.iso-date. For further info see: Remarks.

   Returns:

      * Success: Randomized list, items separated with linebreaks.
      * Error: The string "Error:" followed by a string with further details.
   
   Remarks:
      * rnd:
      
      Determines the randomization to use to generate the numbers. If new is specified, then a new randomization will created from the truly random bitstream at RANDOM.ORG. This is probably what you want in most cases. If id.identifier is specified, the identifier is used to determine the randomization in a deterministic fashion from a large pool of pregenerated random bits. Because the numbers are produced in a deterministic fashion, specifying an id basically uses RANDOM.ORG as a pseudo-random number generator. The third (date.iso-date) form is similar to the second; it allows the randomization to be based on one of the daily pregenerated files. This form must refer to one of the dates for which files exist, so it must be the current day (according to UTC) or a day in the past. The date must be in ISO 8601  format (i.e., YYYY-MM-DD) or one of the two shorthand strings today or yesterday.
      
      * linebreaks:
      
      All three types of linebreak can be used: "`r" amd "`n" and "`r`n". After the randomization the result list will have the same linebreaks as the input list.
      
   Examples:
   (start code)
   
      ;This one loads the content of a file, randomizes it and displays the randomized list via MsgBox. 
      ;(Note: The file must exist and must contain a valid list of items separated by linebreaks for this example to work.)
      FileRead, _list, c:\list.txt
      Msgbox, % randomdotorg_randomizelist(_list)
      

      ;This one randomizes the list content of a variable.
      _list := "item1`nitem2`nitem3`nitem4`n"  ;the content of the _list variable is a list with 4 items, separated by linebreaks (`n)
      _list := randomdotorg_randomizelist(_list)
      
      
      ;This one is the same as the second example.
      _list= 
      (
      item1
      item2
      item3
      item4
      )
      _list := randomdotorg_randomizelist(_list)
      
   (end)
*/
randomdotorg_randomizelist(list,rnd="new") {
	_url := "http://www.random.org/lists/"
    _lb := (InStr(list,"`r`n") ? "`r`n" : (InStr(list,"`n") ? "`n" : "`r")) ;Compatibility with every kind of linebreak
    StringReplace, list, list, % _lb, `%0D`%0A, All 
    _post:="rnd=" new "&format=plain&list=" list
	httpQuery(_ret:="",_url,_post), VarSetCapacity(_ret,-1)
	IfNotInString, _ret, Error:
		StringReplace, _ret, _ret, `n, % _lb, All ;Restore original linebreaks
	return _ret
}	



/*
   Function: randomdotorg_lottery()

   It allows you to quick pick lottery tickets.

   Parameters:

        tickets - The number of tickets to pick. Possible values: [1,100]

        num_main - It specifies how many numbers are drawn. (Eg.: if you have to select 6 numbers from 1-49 then num_main is 6). Possible values: [1,99]

        highest_main - The highest number you can draw. (Eg.: if you have to select 6 numbers from 1-49 then highest_main is 49). Possible values: [1,99]

        num_bonus - Optional. It specifies how many bonus numbers are drawn. Default value: 0 (no bonus number is drawn). Possible values: [1,99]
        
        highest_bonus - Optional. The highest bonus number you can draw. Default value: 0 (no bonus number is drawn). Possible values: [1,99]

   Returns:

      * Success: Generated tickets as comma separated items (CSV)
      * Error: The string "Error:" followed by a string with further details.
   
   Remarks:
      If you have to select 6 numbers from 1-49 and 1 bonus number from 1-20 then: num_main is 6, highest_main is 49, num_bonus is 1, highest_bonus is 20. 
   
   Examples:
      >MsgBox, % randomdotorg_lottery(5,6,59) ;five tickets for a game where 6 numbers are drawn from 1-59
      >MsgBox, % randomdotorg_lottery(5,6,59,1,20) ;same as above, only with an additional bonus number from 1-20
*/
randomdotorg_lottery(tickets,num_main,highest_main,num_bonus="0",highest_bonus="0") {
	_url:="http://www.random.org/quick-pick/?tickets=" tickets "&lottery=" num_main "x" highest_main "." num_bonus "x" highest_bonus "&format=plain"
	httpQuery(_ret:="",_url), VarSetCapacity(_ret,-1)
	IfNotInString, _ret, Error:
		StringReplace, _ret, _ret, `n, `,, All
	return SubStr(_ret,0,1)="," ? SubStr(_ret,1,StrLen(_ret)-1) : _ret ;trimming the last comma
}	



/*
   Function: randomdotorg_clocktime()

   It generates random clock times of the day (or night).

   Parameters:

        num - The number of clock times requested. Possible values: [1,100]

        earliest - Optional. The earliest time allowed for the generated clock times, in the format of nn:nn. Default value: "00:00". For further info see: Remarks.

        latest - Optional. The latest time allowed for the generated clock times, in the format of nn:nn. Default value: "23:59". For further info see: Remarks.

        interval - Optional. Intervals between the generated clock times, in minutes. Default value: 5. Possible values: 1 | 2 | 5 | 10 | 15 | 20 | 30 | 60. For further info see: Remarks.
        
        rnd - Optional. Default value: "new". Possible values: new | id.identifier | date.iso-date. For further info see: Remarks.

   Returns:

      * Success: Generated clock times as comma separated values (CSV)
      * Error: The string "Error:" followed by a string with further details.
   
   Remarks:
      * rnd:
      
      Determines the randomization to use to generate the numbers. If new is specified, then a new randomization will created from the truly random bitstream at RANDOM.ORG. This is probably what you want in most cases. If id.identifier is specified, the identifier is used to determine the randomization in a deterministic fashion from a large pool of pregenerated random bits. Because the numbers are produced in a deterministic fashion, specifying an id basically uses RANDOM.ORG as a pseudo-random number generator. The third (date.iso-date) form is similar to the second; it allows the randomization to be based on one of the daily pregenerated files. This form must refer to one of the dates for which files exist, so it must be the current day (according to UTC) or a day in the past. The date must be in ISO 8601  format (i.e., YYYY-MM-DD) or one of the two shorthand strings today or yesterday.
      * earliest, latest, interval:
      
      Each clock time will be generated between the earliest time and the latest time with intervals specified in the interval parameter. (Limits for earliest and latest are: 00:00 and 23:59; both inclusive). Eg.: Wrong usage: earliest is "00:00" latest is "00:01" interval is "5". In this case no clock times can be generated. The difference between the earliest and the latest time should be at least 5 minutes to generate one clock time. Proper usage: earliest is "00:00" latest is "11:00" interval is "60". This will successfully generate at least 12 clock times, because the difference between 00:00 and 11:00 is 12 hours (12 x 60 minutes).
      
   Examples:
      >MsgBox, % randomdotorg_clocktimes(10)
      >MsgBox, % randomdotorg_clocktimes(10,"11:12","23:00")
      >MsgBox, % randomdotorg_clocktimes(10,"11:12","23:00",30)
*/
randomdotorg_clocktime(num,earliest="00:00",latest="23:59",interval="5",rnd="new") {
	_url:="http://www.random.org/clock-times/?num=" num "&earliest=" earliest "&latest=" latest "&interval=" interval "&format=plain&rnd=" rnd
	httpQuery(_ret:="",_url), VarSetCapacity(_ret,-1)
	IfNotInString, _ret, Error:
		StringReplace, _ret, _ret, `n, `,, All
	return SubStr(_ret,0,1)="," ? SubStr(_ret,1,StrLen(_ret)-1) : _ret ;trimming the last comma
}



/*
   Function: randomdotorg_sequence()

   It randomizes a given interval of integers, i.e., arranges them in random order.

   Parameters:
        min - The lower bound of the interval (inclusive). Possible values: [-1e9,1e9]

        max - The upper bound of the interval (inclusive). Possible values: [-1e9,1e9]

        rnd - Optional. Default value: "new". Possible values: new | id.identifier | date.iso-date. For further info see: Remarks.

   Returns:

      * Success: Generated integers as comma separated values (CSV)
      * Error: The string "Error:" followed by a string with further details.
   
   Remarks:
      rnd:
      
      Determines the randomization to use to generate the numbers. If new is specified, then a new randomization will created from the truly random bitstream at RANDOM.ORG. This is probably what you want in most cases. If id.identifier is specified, the identifier is used to determine the randomization in a deterministic fashion from a large pool of pregenerated random bits. Because the numbers are produced in a deterministic fashion, specifying an id basically uses RANDOM.ORG as a pseudo-random number generator. The third (date.iso-date) form is similar to the second; it allows the randomization to be based on one of the daily pregenerated files. This form must refer to one of the dates for which files exist, so it must be the current day (according to UTC) or a day in the past. The date must be in ISO 8601  format (i.e., YYYY-MM-DD) or one of the two shorthand strings today or yesterday.
   
   Examples:
      >MsgBox, % randomdotorg_sequence(1,144)
      >MsgBox, % randomdotorg_sequence(-10,20)
      >MsgBox, % randomdotorg_sequence(-10,20,"date.2010-01-01")
*/
randomdotorg_sequence(min,max,rnd="new") {
	_url:="http://www.random.org/sequences/?min=" min "&max=" max "&col=1&format=plain&rnd=" rnd
	httpQuery(_ret:="",_url), VarSetCapacity(_ret,-1)
	IfNotInString, _ret, Error:
		StringReplace, _ret, _ret, `n, `,, All
	return SubStr(_ret,0,1)="," ? SubStr(_ret,1,StrLen(_ret)-1) : _ret ;trimming the last comma
}	



/*
   Function: randomdotorg_decimalfraction()

   It generates random decimal fractions in the [0,1] interval.

   Parameters:
        num - The number of random decimal fractions to generate from a uniform distribution across the [0,1] interval. Possible values: [1,1e4].

        dec - Optional. The number of decimal places to use. Default value: 10. Possible values: [1,20].

        rnd - Optional. Default value: "new". Possible values: new | id.identifier | date.iso-date. For further info see: Remarks.

   Returns:

      * Success: Generated decimal fractions as comma separated values (CSV)
      * Error: The string "Error:" followed by a string with further details.
   
   Remarks:
      rnd:
      
      Determines the randomization to use to generate the numbers. If new is specified, then a new randomization will created from the truly random bitstream at RANDOM.ORG. This is probably what you want in most cases. If id.identifier is specified, the identifier is used to determine the randomization in a deterministic fashion from a large pool of pregenerated random bits. Because the numbers are produced in a deterministic fashion, specifying an id basically uses RANDOM.ORG as a pseudo-random number generator. The third (date.iso-date) form is similar to the second; it allows the randomization to be based on one of the daily pregenerated files. This form must refer to one of the dates for which files exist, so it must be the current day (according to UTC) or a day in the past. The date must be in ISO 8601  format (i.e., YYYY-MM-DD) or one of the two shorthand strings today or yesterday.
   
   Examples:
      >MsgBox, % randomdotorg_decimalfraction(10)
      >MsgBox, % randomdotorg_decimalfraction(10,2)
*/
randomdotorg_decimalfraction(num,dec=10,rnd="new") {
	_url:="http://www.random.org/decimal-fractions/?num=" num "&dec=" dec "&col=1&format=plain&rnd=" rnd
	httpQuery(_ret:="",_url), VarSetCapacity(_ret,-1)
	IfNotInString, _ret, Error:
		StringReplace, _ret, _ret, `n, `,, All
	return SubStr(_ret,0,1)="," ? SubStr(_ret,1,StrLen(_ret)-1) : _ret ;trimming the last comma
}	



/*
   Function: randomdotorg_gaussian()

   It generates random numbers from a Gaussian distribution (also known as a normal distribution).
   
   Parameters:
         num - The number of strings requested. Possible values:  [1,100]

         mean - Optional. Mean. Default value: 0.0. Possible values: [-1e6,1e6]

         stdev - Optional. Standard deviation. Default value: 1.0. Possible values: [-1e6,1e6]

         dec - Optional. Number of significant digits. Default value: 10. Possible values: [2,20]

         rnd - Optional. Default value: "new". Possible values: new | id.identifier | date.iso-date. For further info see: Remarks.

   Returns:

      * Success: Generated numbers as comma separated values (CSV)
      * Error: The string "Error:" followed by a string with further details.
   
   Remarks:
      rnd:
      
      Determines the randomization to use to generate the numbers. If new is specified, then a new randomization will created from the truly random bitstream at RANDOM.ORG. This is probably what you want in most cases. If id.identifier is specified, the identifier is used to determine the randomization in a deterministic fashion from a large pool of pregenerated random bits. Because the numbers are produced in a deterministic fashion, specifying an id basically uses RANDOM.ORG as a pseudo-random number generator. The third (date.iso-date) form is similar to the second; it allows the randomization to be based on one of the daily pregenerated files. This form must refer to one of the dates for which files exist, so it must be the current day (according to UTC) or a day in the past. The date must be in ISO 8601  format (i.e., YYYY-MM-DD) or one of the two shorthand strings today or yesterday.
   
   Examples:
      >MsgBox, % randomdotorg_gaussian(5)
*/
randomdotorg_gaussian(num,mean="0.0",stdev="1.0",dec=10,rnd="new") {
	_url:="http://www.random.org/gaussian-distributions/?num=" num "&mean=" mean "&stdev=" stdev "&dec=" dec "&col=1&notation=scientific&format=plain&rnd=" rnd
	httpQuery(_ret:="",_url), VarSetCapacity(_ret,-1)
	IfNotInString, _ret, Error:
		StringReplace, _ret, _ret, `n, `,, All
	return SubStr(_ret,0,1)="," ? SubStr(_ret,1,StrLen(_ret)-1) : _ret ;trimming the last comma
}



/*
   Function: randomdotorg_bitmap()

   It generates random bitmaps. (BETA)

   Parameters:
        save_path - Optional. If you specify this parameter, the random image will be saved to your hard disk at the specified save_path, rather than being returned as hex data. You must specify a full absolute path including file name. For further info see: Returns, Remarks, Examples.
        
        format - Optional. The format of the generated image. Default value: "gif". Possible values: "gif" | "png".

        width - Optional. Width of the generated image. Default value: 64. Possible values: [1,300]. For further info see: Remarks.
        
        height - Optional. Height of the generated image. Default value: 64. Possible values: [1,300]. For further info see: Remarks.

        zoom - Optional. Zoom factor. Default value: 1. Possible values: [1,4]. For further info see: Remarks.

   Returns:

      * Success: If the save_path parameter isn't specified (left blank: ""): The function will return the generated random image as hex data. If the save_path paraneter is specified: The function will return true/false values indicating if the saving process was successful.
      * Error: The string "Error:" will be returned followed by a string with further details. (Only if the query to RANDOM.ORG wasn't successful.)
   
   Remarks:
      The final image resolution will be (w × z) by (h × z) where w is the width, h is the height and z is the zoom factor.
      If you want to save the generated random image to the hard disk, specify a full path in the save_path parameter, eg. 
   >randomdotorg_bitmap("c:\random\images\random1.gif") ;This'll work.
    or 
    >randomdotorg_bitmap("f:\random-image.png","png") ;This'll work.
    depending on the format defined in the format parameter (gif by default). If the specified path doesn't include a file name, the function will not be able to save the image, and will return False eg.: _Wrong usage:_ 
    >randomdotorg_bitmap("c:\images") ;This WON'T work.
    If you leave the save_path parameter blank, eg.: 
    >randomdotorg_bitmap() ;This'll work.
    or 
    >randomdotorg_bitmap("",png) ;This'll work.
    etc., the function will return the image converted into hex data. This way you can store the image in text files, include in scripts, and so on. You can also write the image to hard disk yourself, but before you can do that, the hex data must be converted back into binary. For the binary<->hex conversion and the binary file writing you can use PhiLho's scripts: http://www.autohotkey.com/forum/viewtopic.php?t=7549 . Here's a small *example script* for this scenario: http://autohotkey.net/~gahks/_randomdotorg_bitmap_EXAMPLE.zip
   
   Examples:
   (start code)
      ; This example generates a 64x64 random image in gif format (default parameters), saves it as "c:\random.gif", 
      ; and displays "Successful!", if saving the image was successful, or "Error!", if the the generation or saving process failed.
      _var:=randomdotorg_bitmap("c:\random.gif")
      if (_var && !InStr(_var,"Error:"))
         MsgBox, Successful!
      else
         MsgBox, Error!
      
      
      ; This example generates a 100x100 random image with a zoom value of 2 (see Remarks) in png format,
      ; returns the image converted into hex data, and displays it in an Edit control.
      _var:=randomdotorg_bitmap("","png",100,100,2)
      if (_var && !InStr(_var,"Error:")) {
      gui, add, edit, w300 h300, % _var
      gui, show,, Image data in hex format!
      return
      }
      else
         MsgBox, Error!
      GuiClose:
      ExitApp
      
      ; A full working version of the second example (the hex data is converted back to binary
      ; and written out to an image file) can be downloaded here: 
      ; http://autohotkey.net/~gahks/_randomdotorg_bitmap_EXAMPLE.zip
   (end)
*/
randomdotorg_bitmap(save_path="",format="gif",width=64,height=64,zoom=1) {
   _url:="http://www.random.org/bitmaps/?format=" format "&width=" width "&height=" height "&zoom=" zoom
   _l:=httpQuery(_ret:="",_url)
   VarSetCapacity(_ret,-1)
   IfInString, _ret, Error:
      return _ret ;Return error string
   if (save_path != "")
      return write_bin(_ret,save_path,_l) ;Return true/false depending on the success of saving the image
   Bin2Hex(_rethex,_ret)
   return _rethex ;return the image in hex data format
}



/*
   Function: randomdotorg_noise()

   It generates random audio noise, i.e., audio files containing perfect white noise. (Detailed description in Remarks.)

   Parameters:
   
        save_path - Optional. If you specify this parameter, the generated noise will be saved to your hard disk at the specified save_path, rather than being returned as hex data. You must specify a full absolute path including file name. For further info see: Returns, Remarks, Examples.
        
        format - Optional. Audio format of the generated noise. Default value: "wav". Possible values: "wav" | "aiff" | "au".

        volume - Optional. Volume of the generated noise in percent. Default value: 100. Possible values: 100 | 80 | 60 | 40 | 20.
        
        channels - Optional. Channel type (mono/stereo). Default value: "stereo". Possible values: "mono" | "stereo".

        rate - Optional. Sample rate. Default value: 16000. Possible values: 8000 | 16000 | 32000 | 44100.

        size - Optional. Sample size (bits per sample). Default value: 8. Possible values: 8 | 16.
        
        date - Optional. Randomness generated on "date" will be used to generate random noise. The date must be in ISO 8601  format (i.e., YYYY-MM-DD) or one of the two shorthand strings "today" or "yesterday". Default value: "today". Possible values: "today" | "yesterday" | YYYY-MM-DD.


   Returns:

      * Success: If the save_path parameter isn't specified (left blank: ""): The function will return the generated random noise as hex data. If the save_path paraneter is specified: The function will return true/false values indicating if the saving process was successful.
      * Error: The string "Error:" will be returned followed by a string with further details. (Only if the query to RANDOM.ORG wasn't successful.)
   
   Remarks:
      Detailed description of random noise generator: http://www.random.org/audio-noise/description/
      For more info on the save_path parameter, and the return values and useage of this function see the Returns,Remarks,Examples sections of the function <randomdotorg_bitmap()>.
      
   Examples:
   (start code)
      ; This example generates a random noise of 16000 bits per second sample rate, 8 bits per sample sample size,
      ; with 100% volume and stereo channels in wav format based on the randomness generated today. (Default parameters),
      ; saves the generated noise as "c:\random.wav", and displays the message "Successful!", if saving the image was successful, 
      ; or "Error!", if the the generation or saving process failed.
      _var:=randomdotorg_noise("c:\noise.wav")
      if (_var && !InStr(_var,"Error:"))
         MsgBox, Successful!
      else
         MsgBox, Error!
      
      
      ; This example generates a random noise of 44100 bits per second sample rate, 16 bits per sample sample size,
      ; with 80% volume and mono channels in aiff format based on the randomness generated on 2010-01-01,
      ; returns the noise in hex data format, and displays the first 500 chars in an Edit control.
      _var:=randomdotorg_noise("","aiff",80,"mono",44100,16,"2010-01-01")
      if (_var && !InStr(_var,"Error:")) {
      gui, add, edit, w300 h300, % SubStr(_var,1,500)
      gui, show,, Audio data in hex format!
      return
      }
      else
         MsgBox, Error!
      GuiClose:
      ExitApp
      
      ; For an example on what to do with the hex data, see the Remarks and Examples section of randomdotorg_bitmap().
   (end)
*/
randomdotorg_noise(save_path="",format="wav",volume=100,channels="stereo",rate=16000,size=8,date="today") {
   _url:="http://www.random.org/audio-noise/?format=" format "&volume=" volume
   . "&channels=" (channels="mono" ? 1 : 2) "&rate=" rate "&size=" size "&date=" date "&deliver=download"
   _l:=httpQuery(_ret:="",_url)
   VarSetCapacity(_ret,-1)
   IfInString, _ret, Error:
      return _ret ;Return error string
   if (save_path != "")
      return write_bin(_ret,save_path,_l) ;Return true/false depending on the success of saving the audio
   Bin2Hex(_rethex,_ret)
   return _rethex ;return the audio data in hex format
}



/*
   Function: randomdotorg_quota()

   It allows you to examine your quota at any point in time. For further info see: Remarks.

   Parameters:

        ip - Optional. Default value: "" (blank). Possible values: "n.n.n.n". The IP address for which you wish to examine the quota. Each value for n should be an integer in the [0,255] interval. If you leave it out, it defaults to the IP address of the machine from which you are issuing the request. 

   Returns:

      * Success: The qutoa associated with the specified IP address.
      * Error: The string "Error:" followed by a string with further details.
   
   Remarks:
      The quota system works on the basis of IP addresses. Each IP address has a base quota of 1,000,000 bits. When you make a request for random numbers (or strings, etc.), the server deducts the number of bits it took to satisfy your request from the quota associated with your client's IP address. If your client issues a request for random numbers while its quota is negative, the RANDOM.ORG server will return a 503 error response. Every day, shortly after midnight UTC, all quotas with less than 1,000,000 bits receive a free top-up of 200,000 bits.
   
   Examples:
      >MsgBox, % randomdotorg_quota()
      >MsgBox, % randomdotorg_quota("134.226.36.80")
*/
randomdotorg_quota(ip="") {
    _url:="http://www.random.org/quota/?" (ip!="" ? "ip=" ip "&" : "") "format=plain"
	httpQuery(_ret:="",_url), VarSetCapacity(_ret,-1)
	IfNotInString, _ret, Error:
		StringReplace, _ret, _ret, `n, `,, All
	return SubStr(_ret,0,1)="," ? SubStr(_ret,1,StrLen(_ret)-1) : _ret ;trimming the last comma
}



/*
Title: Usage

How to use this library

Downloads:

randomdotorg.zip - Contains the library and all the dependencies (httpQuery.ahk, BinHexConvert.ahk, write_bin.ahk), and the documentation. *Recommended.*
randomdotorg.ahk - The library and the scripts the library depends on all merged together in one file.


<http://autohotkey.net/~gahks/randomdotorg.zip>

<http://autohotkey.net/~gahks/randomdotorg.ahk>


Which one to use:
The first version (randomdotorg.zip) is recommended: Every script is a separate file, and the library uses #Include to include them on runtime.

How to use this library:
There are two ways to use this library: 
* You can use the #Include command to include randomdotorg.ahk in your script, or 
* You can copy it to your Autohotkey\Lib dir, so you won't have to include it every time you want to use one of these functions.

To use it as a standard library
(start code)
1. Download randomdotorg.zip from http://autohotkey.net/~gahks/randomdotorg.zip
2. Go to your Autohotkey dir. Create a dir named "Lib" if there isn't already one. Extract randomdotorg.zip to the Lib dir.
3. Use the functions in any script.
(end)
To use the #Include command
(start code)
1. Download randomdotorg.zip from http://autohotkey.net/~gahks/randomdotorg.zip
2. Extract its content (all the files - except the html - must be exrtacted to one place).
3. Include randomdotorg.ahk via #Include in your script. Use the functions.
(end)

Title: About

About the library, about Random.org

About the library:

Name - randomdotorg.ahk
Version - 0.3
Dependencies - httpQuery.ahk, write_bin.ahk, Bin2Hex() (found in BinHexConvert.ahk)
Date - 2010-06-04
Author - gahks 
Homepage - http://autohotkey.net/~gahks/
Forum topic - http://www.autohotkey.com/forum/topic58785.html

About RANDOM.ORG:

   RANDOM.ORG offers true random numbers to anyone on the Internet. The randomness comes from atmospheric noise, which for many purposes is better than the pseudo-random number algorithms typically used in computer programs. People use RANDOM.ORG for holding drawings, lotteries and sweepstakes, to drive games and gambling sites, for scientific applications and for art and music. The service has existed since 1998 and was built and is being operated by Mads Haahr of  the School of Computer Science and Statistics at Trinity College, Dublin in Ireland. For further info check out: http://www.random.org/
   
   You can learn more about randomness at <http://www.random.org/randomness/>.
   
   If you're gonna implement one or more of these functions to your script, you'll want to read the guidelines for automated clients at <http://www.random.org/clients/>.

TODO:
   Add more functions...
   Specifically:
   >The Arts: Jazz Scales
   >Miscellany: Calendar Dates

Thanks:
   Thanks to Chris for AHK, Heresy & derRaphael for httpQuery() and write_bin(), and the owner(s) of RANDOM.org for the service, the creator of NaturalDocs and majkinetor for the NaturalDocs installer.
   
Title: License

This library is licensed under the GPL.
*/

;------------------------------
; DEPENDENCIES
;------------------------------
; httpQuery-0-3-5.ahk
; http://www.autohotkey.com/forum/topic33506.html
httpQuery(byref Result, lpszUrl, POSTDATA="", HEADERS="")
{   ; v0.3.5 (w) Sep, 8 2008 by Heresy & derRaphael / zLib-Style release
   ; updates Aug, 28 2008   
   ; currently the verbs showHeader, storeHeader, and updateSize are supported in httpQueryOps
   ; in case u need a different UserAgent, Proxy, ProxyByPass, Referrer, and AcceptType just
   ; specify them as global variables - mind the varname for referrer is httpQueryReferer [sic].
   ; Also if any special dwFlags are needed such as INTERNET_FLAG_NO_AUTO_REDIRECT or cache
   ; handling this might be set using the httpQueryDwFlags variable as global
   global httpQueryOps, httpAgent, httpProxy, httpProxyByPass, httpQueryReferer, httpQueryAcceptType
       , httpQueryDwFlags
   ; Get any missing default Values
   defaultOps =
   (LTrim Join|
      httpAgent=AutoHotkeyScript|httpProxy=0|httpProxyByPass=0|INTERNET_FLAG_SECURE=0x00800000
      SECURITY_FLAG_IGNORE_UNKNOWN_CA=0x00000100|SECURITY_FLAG_IGNORE_CERT_CN_INVALID=0x00001000
      SECURITY_FLAG_IGNORE_CERT_DATE_INVALID=0x00002000|SECURITY_FLAG_IGNORE_CERT_WRONG_USAGE=0x00000200
      INTERNET_OPEN_TYPE_PROXY=3|INTERNET_OPEN_TYPE_DIRECT=1|INTERNET_SERVICE_HTTP=3
   )
   Loop,Parse,defaultOps,|
   {
      RegExMatch(A_LoopField,"(?P<Option>[^=]+)=(?P<Default>.*)",http)
      if StrLen(%httpOption%)=0
         %httpOption% := httpDefault
   }

   ; Load Library
   hModule := DllCall("LoadLibrary", "Str", "WinINet.Dll")

   ; SetUpStructures for URL_COMPONENTS / needed for InternetCrackURL
   ; http://msdn.microsoft.com/en-us/library/aa385420(VS.85).aspx
   offset_name_length:= "4-lpszScheme-255|16-lpszHostName-1024|28-lpszUserName-1024|"
                  . "36-lpszPassword-1024|44-lpszUrlPath-1024|52-lpszExtrainfo-1024"
   VarSetCapacity(URL_COMPONENTS,60,0)
   ; Struc Size               ; Scheme Size                  ; Max Port Number
   NumPut(60,URL_COMPONENTS,0), NumPut(255,URL_COMPONENTS,12), NumPut(0xffff,URL_COMPONENTS,24)
   
   Loop,Parse,offset_name_length,|
   {
      RegExMatch(A_LoopField,"(?P<Offset>\d+)-(?P<Name>[a-zA-Z]+)-(?P<Size>\d+)",iCU_)
      VarSetCapacity(%iCU_Name%,iCU_Size,0)
      NumPut(&%iCU_Name%,URL_COMPONENTS,iCU_Offset)
      NumPut(iCU_Size,URL_COMPONENTS,iCU_Offset+4)
   }

   ; Split the given URL; extract scheme, user, pass, authotity (host), port, path, and query (extrainfo)
   ; http://msdn.microsoft.com/en-us/library/aa384376(VS.85).aspx
   DllCall("WinINet\InternetCrackUrlA","Str",lpszUrl,"uInt",StrLen(lpszUrl),"uInt",0,"uInt",&URL_COMPONENTS)

   ; Update variables to retrieve results
   Loop,Parse,offset_name_length,|
   {
      RegExMatch(A_LoopField,"-(?P<Name>[a-zA-Z]+)-",iCU_)
      VarSetCapacity(%iCU_Name%,-1)
   }
   nPort:=NumGet(URL_COMPONENTS,24,"uInt")
   
   ; Import any set dwFlags
   dwFlags := httpQueryDwFlags
   ; For some reasons using a selfsigned https certificates doesnt work
   ; such as an own webmin service - even though every security is turned off
   ; https with valid certificates works when
   if (lpszScheme = "https")
      dwFlags |= (INTERNET_FLAG_SECURE|SECURITY_FLAG_IGNORE_CERT_CN_INVALID
               |SECURITY_FLAG_IGNORE_CERT_WRONG_USAGE)

   ; Check for Header and drop exception if unknown or invalid URL
   if (lpszScheme="unknown") {
      Result := "ERR: No Valid URL supplied."
      Return StrLen(Result)
   }

   ; Initialise httpQuery's use of the WinINet functions.
   ; http://msdn.microsoft.com/en-us/library/aa385096(VS.85).aspx
   hInternet := DllCall("WinINet\InternetOpenA"
                  ,"Str",httpAgent,"UInt"
                  ,(httpProxy != 0 ?  INTERNET_OPEN_TYPE_PROXY : INTERNET_OPEN_TYPE_DIRECT )
                  ,"Str",httpProxy,"Str",httpProxyBypass,"Uint",0)

   ; Open HTTP session for the given URL
   ; http://msdn.microsoft.com/en-us/library/aa384363(VS.85).aspx
   hConnect := DllCall("WinINet\InternetConnectA"
                  ,"uInt",hInternet,"Str",lpszHostname, "Int",nPort
                  ,"Str",lpszUserName, "Str",lpszPassword,"uInt",INTERNET_SERVICE_HTTP
                  ,"uInt",0,"uInt*",0)

   ; Do we POST? If so, check for header handling and set default
   if (Strlen(POSTDATA)>0) {
      HTTPVerb:="POST"
      if StrLen(Headers)=0
         Headers:="Content-Type: application/x-www-form-urlencoded"
   } else ; otherwise mode must be GET - no header defaults needed
      HTTPVerb:="GET"   

   ; Form the request with proper HTTP protocol version and create the request handle
   ; http://msdn.microsoft.com/en-us/library/aa384233(VS.85).aspx
   hRequest := DllCall("WinINet\HttpOpenRequestA"
                  ,"uInt",hConnect,"Str",HTTPVerb,"Str",lpszUrlPath . lpszExtrainfo
                  ,"Str",ProVer := "HTTP/1.1", "Str",httpQueryReferer,"Str",httpQueryAcceptTypes
                  ,"uInt",dwFlags,"uInt",Context:=0 )

   ; Send the specified request to the server
   ; http://msdn.microsoft.com/en-us/library/aa384247(VS.85).aspx
   sRequest := DllCall("WinINet\HttpSendRequestA"
                  , "uInt",hRequest,"Str",Headers, "uInt",Strlen(Headers)
                  , "Str",POSTData,"uInt",Strlen(POSTData))

   VarSetCapacity(header, 2048, 0)  ; max 2K header data for httpResponseHeader
   VarSetCapacity(header_len, 4, 0)
   
   ; Check for returned server response-header (works only _after_ request been sent)
   ; http://msdn.microsoft.com/en-us/library/aa384238.aspx
   Loop, 5
     if ((headerRequest:=DllCall("WinINet\HttpQueryInfoA","uint",hRequest
      ,"uint",21,"uint",&header,"uint",&header_len,"uint",0))=1)
      break

   If (headerRequest=1) {
      VarSetCapacity(res,headerLength:=NumGet(header_len),32)
      DllCall("RtlMoveMemory","uInt",&res,"uInt",&header,"uInt",headerLength)
      Loop,% headerLength
         if (*(&res-1+a_index)=0) ; Change binary zero to linefeed
            NumPut(Asc("`n"),res,a_index-1,"uChar")
      VarSetCapacity(res,-1)
   } else
      res := "timeout"

   ; Get 1st Line of Full Response
   Loop,Parse,res,`n,`r
   {
      RetValue := A_LoopField
      break
   }
   
   ; No Connection established - drop exception
   If (RetValue="timeout") {
      html := "Error: timeout"
      return -1
   }
   ; Strip protocol version from return value
   RetValue := RegExReplace(RetValue,"HTTP/1\.[01]\s+")
   
    ; List taken from http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
   HttpRetCodes := "100=Continue|101=Switching Protocols|102=Processing (WebDAV) (RFC 2518)|"
              . "200=OK|201=Created|202=Accepted|203=Non-Authoritative Information|204=No"
              . " Content|205=Reset Content|206=Partial Content|207=Multi-Status (WebDAV)"
              . "|300=Multiple Choices|301=Moved Permanently|302=Found|303=See Other|304="
              . "Not Modified|305=Use Proxy|306=Switch Proxy|307=Temporary Redirect|400=B"
              . "ad Request|401=Unauthorized|402=Payment Required|403=Forbidden|404=Not F"
              . "ound|405=Method Not Allowed|406=Not Acceptable|407=Proxy Authentication "
              . "Required|408=Request Timeout|409=Conflict|410=Gone|411=Length Required|4"
              . "12=Precondition Failed|413=Request Entity Too Large|414=Request-URI Too "
              . "Long|415=Unsupported Media Type|416=Requested Range Not Satisfiable|417="
              . "Expectation Failed|418=I'm a teapot (RFC 2324)|422=Unprocessable Entity "
              . "(WebDAV) (RFC 4918)|423=Locked (WebDAV) (RFC 4918)|424=Failed Dependency"
              . " (WebDAV) (RFC 4918)|425=Unordered Collection (RFC 3648)|426=Upgrade Req"
              . "uired (RFC 2817)|449=Retry With|500=Internal Server Error|501=Not Implem"
              . "ented|502=Bad Gateway|503=Service Unavailable|504=Gateway Timeout|505=HT"
              . "TP Version Not Supported|506=Variant Also Negotiates (RFC 2295)|507=Insu"
              . "fficient Storage (WebDAV) (RFC 4918)|509=Bandwidth Limit Exceeded|510=No"
              . "t Extended (RFC 2774)"
   
   ; Gather numeric response value
   RetValue := SubStr(RetValue,1,3)
   
   ; Parse through return codes and set according informations
   Loop,Parse,HttpRetCodes,|
   {
      HttpReturnCode := SubStr(A_LoopField,1,3)    ; Numeric return value see above
      HttpReturnMsg  := SubStr(A_LoopField,5)      ; link for additional information
      if (RetValue=HttpReturnCode) {
         RetMsg := HttpReturnMsg
         break
      }
   }

   ; Global HttpQueryOps handling
   if strlen(HTTPQueryOps)>0 {
      ; Show full Header response (usefull for debugging)
      if (instr(HTTPQueryOps,"showHeader"))
         MsgBox % res
      ; Save the full Header response in a global Variable
      if (instr(HTTPQueryOps,"storeHeader"))
         global HttpQueryHeader := res
      ; Check for size updates to export to a global Var
      if (instr(HTTPQueryOps,"updateSize")) {
         Loop,Parse,res,`n
            If RegExMatch(A_LoopField,"Content-Length:\s+?(?P<Size>\d+)",full) {
               global HttpQueryFullSize := fullSize
               break
            }
         if (fullSize+0=0)
            HttpQueryFullSize := "size unavailable"
      }
   }

   ; Check for valid codes and drop exception if suspicious
   if !(InStr("100 200 201 202 302",RetValue)) {
      Result := RetValue " " RetMsg
      return StrLen(Result)
   }

   VarSetCapacity(BytesRead,4,0)
   fsize := 0
   Loop            ; the receiver loop - rewritten in the need to enable
   {               ; support for larger file downloads
      bc := A_Index
      VarSetCapacity(buffer%bc%,1024,0) ; setup new chunk for this receive round
      ReadFile := DllCall("wininet\InternetReadFile"
                  ,"uInt",hRequest,"uInt",&buffer%bc%,"uInt",1024,"uInt",&BytesRead)
      ReadBytes := NumGet(BytesRead)    ; how many bytes were received?
      If ((ReadFile!=0)&&(!ReadBytes))  ; we have had no error yet and received no more bytes
         break                         ; we must be done! so lets break the receiver loop
      Else {
         fsize += ReadBytes            ; sum up all chunk sizes for correct return size
         sizeArray .= ReadBytes "|"
      }
      if (instr(HTTPQueryOps,"updateSize"))
         Global HttpQueryCurrentSize := fsize
   }
   sizeArray := SubStr(sizeArray,1,-1)   ; trim last PipeChar
   
   VarSetCapacity(result,fSize+1,0)      ; reconstruct the result from above generated chunkblocks
   Dest := &result                       ; to a our ByRef result variable
   Loop,Parse,SizeArray,|
      DllCall("RtlMoveMemory","uInt",Dest,"uInt",&buffer%A_Index%,"uInt",A_LoopField)
      , Dest += A_LoopField
     
   DllCall("WinINet\InternetCloseHandle", "uInt", hRequest)   ; close all opened
   DllCall("WinINet\InternetCloseHandle", "uInt", hInternet)
   DllCall("WinINet\InternetCloseHandle", "uInt", hConnect)
   DllCall("FreeLibrary", "UInt", hModule)                    ; unload the library
   return fSize                          ; return the size - strings need update via VarSetCapacity(res,-1)
}

write_bin(byref bin,filename,size){
; by derRaphael in the httpQuery thread
   h := DllCall("CreateFile","str",filename,"Uint",0x40000000
            ,"Uint",0,"UInt",0,"UInt",4,"Uint",0,"UInt",0)
   IfEqual h,-1, SetEnv, ErrorLevel, -1
   IfNotEqual ErrorLevel,0,return False ; couldn't create the file
   r := DllCall("SetFilePointerEx","Uint",h,"Int64",0,"UInt *",p,"Int",0)
   IfEqual r,0, SetEnv, ErrorLevel, -3
   IfNotEqual ErrorLevel,0, {
      t = %ErrorLevel%              ; save ErrorLevel to be returned
      DllCall("CloseHandle", "Uint", h)
      ErrorLevel = %t%              ; return seek error
   }
   result := DllCall("WriteFile","UInt",h,"Str",bin,"UInt"
               ,size,"UInt *",Written,"UInt",0)
   h := DllCall("CloseHandle", "Uint", h)
   return, True
}

/*
// by PhiLho 
// http://www.autohotkey.com/forum/viewtopic.php?t=7549
// Convert raw bytes stored in a variable to a string of hexa digit pairs.
// Convert either byteNb bytes or, if null, the whole content of the variable.
//
// Return the number of converted bytes, or -1 if error (memory allocation)
*/
Bin2Hex(ByRef @hex, ByRef @bin, _byteNb=0)
{
   local intFormat, dataSize, dataAddress, granted, x

   ; Save original integer format
   intFormat = %A_FormatInteger%
   ; For converting bytes to hex
   SetFormat Integer, Hex

   ; Get size of data
   dataSize := VarSetCapacity(@bin)
   If (_byteNb < 1 or _byteNb > dataSize)
   {
      _byteNb := dataSize
   }
   dataAddress := &@bin
   ; Make enough room (faster)
   granted := VarSetCapacity(@hex, _byteNb * 2)
   if (granted < _byteNb * 2)
   {
      ; Cannot allocate enough memory
      ErrorLevel = Mem=%granted%
      Return -1
   }
   Loop %_byteNb%
   {
      ; Get byte in hexa
      x := *dataAddress + 0x100
      StringRight x, x, 2   ; 2 hex digits
      StringUpper x, x
      @hex = %@hex%%x%
      dataAddress++   ; Next byte
   }
   ; Restore original integer format
   SetFormat Integer, %intFormat%

   Return _byteNb
} 