### ErrorLevel  
[ErrorLevel](http://ahkscript.org/docs/misc/ErrorLevel.htm){_blank} is set to 0 if the command succeeded.
Otherwise, it is set to one of the following phrases:
* Invalid Control Type or Component Type
* Can't Open Specified Mixer
* Mixer Doesn't Support This Component Type
* Mixer Doesn't Have That Many of That Component Type
* Component Doesn't Support This Control Type
* Can't Get Current Setting

### Throws  
Throws [MfException](MfException.html) if [Autohotkey - SoundGet](http://ahkscript.org/docs/commands/SoundGet.htm){_blank}
throw any errors with [InnerException](MfException.InnerException.html) set to the
[Autohotkey - SoundGet](http://ahkscript.org/docs/commands/SoundGet.htm){_blank} error message.

### Remarks  
Support for Windows Vista and later was added in [v1.1.10+].

To discover the capabilities of the sound devices (mixers) installed on the system -- such as the available component
types and control types -- run the [soundcard analysis script](http://ahkscript.org/docs/commands/SoundSet.htm#Ex){_blank}.

For more functionality and finer grained control over audio, consider using the
[VA library](http://www.autohotkey.com/board/topic/21984-vista-audio-control-functions/){_blank}.

Use [SoundSet](http://ahkscript.org/docs/commands/SoundSet.htm){_blank} to change a setting.