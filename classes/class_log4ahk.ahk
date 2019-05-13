; *******************************************************************
;   log4ahk.ahk
; *******************************************************************


; -------------------------------------------------------------------
;   log4ahk
; -------------------------------------------------------------------

class log4ahk
{
  static loggers := []
  static RootLogger := new log4ahk.logger
  static logger_builder := new log4ahk.default_logger_builder
   
  getLogger(name = "")
  {
    if (name == "")
    {
      return this.RootLogger
    }
    loggers := this.loggers
    if (loggers.HasKey(name))
    {
      return loggers[name]
    }
    else
    {
      loggers.Insert(name, this.logger_builder.create(name))
      return loggers[name]
    }
  }


  ; -----------------------------------------------------------------
  ;   logger
  ; -----------------------------------------------------------------
  
  class logger 
  {
    static LevelTrace := 12000
    static LevelDebug := 14000
    static LevelInfo  := 16000
    static LevelWarn  := 18000
    static LevelError := 20000
    static LevelFatal := 22000
    
    level     := ""
    name      := ""
    appenders := []
    parent    := ""
  
    __New(name = "")
    {
      this.name  := name
      appender := new log4ahk.appender
      this.appenders.Insert(appender)
    }
    
    trace(message)
    {
      this.log(this.LevelTrace, message)
    }     
    
    debug(message)
    {
      this.log(this.LevelDebug, message)
    } 
    
    info(message)
    {
      this.log(this.LevelInfo, message)
    }
    
    warn(message)
    {
      this.log(this.LevelWarn, message)
    }
    
    error(message)
    {
      this.log(this.LevelError, message)
    }
    
    fatal(message)
    {
      this.log(this.LevelFatal, message)
    }
  
    log(level, message) 
    {
      if (level >= this.EffectiveLevel())
      {
        ev := new log4ahk.event(this, level, message)
        this.callAppenders(ev)
      }
    }
    
    callAppenders(event)
    {
      for k, appender in this.appenders
      {
        appender.doAppend(event)
      }
      if IsObject(this.parent)
      {
        this.parent.callAppenders(event)
      }
    }
  
    EffectiveLevel() 
    {
      logger := this
      while IsObject(logger)
        if (logger.level != "")
        	return logger.level
        else
          logger := logger.parent
    }

    
    ; ******************************************
    ; *** Configuration methods              ***
    ; ******************************************
      
    addAppender(appender)
    {
      appenderName := appender.name
      this.appenders[appenderName] := appender
    }
    
    removeAllAppenders()
    {
      this.appenders := {}
    } 
    
    removeAppender(appender)
    {
      appenderName := appender.name
      this.appenders.Remove(appenderName)
    }
    
    isAttached(appender)
    {
      appenderName := appender.name
      return this.appenders.HasKey(appenderName)
    }
  }

  ; -----------------------------------------------------------------
  ;   default_logger_builder
  ; -----------------------------------------------------------------
  
  class default_logger_builder
  {
    create(name)
    {
      return new log4ahk.logger(name)
    }
  }

  class hierarchical_logger_builder
  {
    create(name)
    {
      logger := new log4ahk.logger(name)
      pos := InStr(name, ".", true, 0)
      if (pos > 1)
      {
      	parent := SubStr(name, 1, pos - 1)
        logger.parent := log4ahk.getLogger(parent)
      }
      return logger
    }
  }

  ; -----------------------------------------------------------------
  ;   event
  ; -----------------------------------------------------------------
  
  class event
  {
    time     := A_Now 
    logger   := ""
    level    := ""
    message  := ""
    
    __New(logger, level, message)
    {
      this.logger  := logger
      this.level   := level
      this.message := message
    }
  }

  ; -----------------------------------------------------------------
  ;   appender
  ; -----------------------------------------------------------------
  
  class appender
  {
    closed         := false
    filter         := ""
    layout         := ""
    name           := ""
    threshold      := ""
    requiresLayout := true
    
    __New(name = "")
    {
      this.name  := name
      if (this.requiresLayout)
      {
        this.layout := new log4ahk.layout
      }
    }
  
    doAppend(event)
    {
      if (this.closed)
      {
        return
      }
      if ((this.threshold != "") && (event.level < this.threshold))
      {
        return
      }
      this.append(event)
    }
  
    append(event)
    {
      this.text .= this.layout.format(event) . "`n"
    }
  }

  ; -----------------------------------------------------------------
  ;   file_appender
  ; -----------------------------------------------------------------
  
  class file_appender extends log4ahk.appender
  {
    locking := true
    file    := ""
    fp      := ""
    
    __New(name = "")
    {
      base.__New(name)
    }
  
    openFile()
    {
      this.fp := FileOpen(this.file,"a")
    }
    
    write(s)
    {
      if (!IsObject(this.fp))
      {
        this.OpenFile()
      }
      this.fp.WriteLine(s)
      this.fp.read(0)
    }
    
    append(event)
    {
      this.write(this.layout.format(event))
    }
    
    close()
    {
      this.fp.close()
      this.fp := "" 
    }
  }

  ; -----------------------------------------------------------------
  ;   event_appender
  ; -----------------------------------------------------------------
  
  class event_appender extends log4ahk.appender
  {
    events := []

    __New(name = "")
    {
      this.name  := name
    }
  
    append(event)
    {
      this.events.insert(event)
    }
  }

  ; -----------------------------------------------------------------
  ;   layout
  ; -----------------------------------------------------------------
  
  class layout
  {
    format(event)
    {
      levelStr := this.Level2Name(event.level)
      time     := event.time
      tf       := "d. MMMM yyyy, HH:mm:ss"
      FormatTime ftime, %time%, %tf%
      msg := "LOG: " . ftime . " " . levelStr . " " . event.message
      return msg
    }

    Level2Name(level)
    {
      static LevelNames := { (log4ahk.logger.LevelTrace) : "TRACE"
                            ,(log4ahk.logger.LevelDebug) : "DEBUG"
                            ,(log4ahk.logger.LevelInfo)  : "INFO"
                            ,(log4ahk.logger.LevelWarn)  : "WARN"
                            ,(log4ahk.logger.LevelError) : "ERROR"
                            ,(log4ahk.logger.LevelFatal) : "FATAL"}
      return LevelNames[level]
    }
  }
}


