/**
 * Logger class (singleton) - Tailored to FeatShare.ahk
 *
 * FeatShare v0.2 - Text integration tool
 * Copyright (C) 2016  szapp <http://github.com/szapp>
 *
 * This file is part of FeatShare.
 * <http://github.com/szapp/FeatShare>
 *
 * FeatShare is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FeatShare is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FeatShare.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 * Third-party software:
 *
 * MPRESS v2.19, Copyright (C) 2007-2012 MATCODE Software,
 * for license information see: /mpress/LICENSE
 *
 * AutoHotkey-JSON v2.1.1, 2013-2016 cocobelgica, WTFPL <http://wtfpl.net>
 *
 * Class_RichEdit v0.1.05.00, 2013-2015 just me,
 * Unlicense <http://unlicense.org>
 *
 *
 * Info: Comments are set to C++ style. Escape character is ` e.g.: `n
 */

#CommentFlag, //
#Include, funcStrRegEx.ahk


/**
 * Logger class (singleton)
 */
class Logger {

    // Static singleton instance
    static instance = 0
    // Small hack (no static methods in AHK)
    static getInstance := Func("Logger_getInstance")

    // Instance variables
    path := ""
    instantFlush := False
    buffer := ""
    showDebug := False
    showWarn := True
    timeformat := "yyyy-MM-dd HH:mm:ss"
    history := {}

    /**
     * Create new Logger
     *
     * Don't allow creating a logger if there already exists one
     * There is no private methods in AHK
     */
    __New() {
        if this.instance
            return False
    }

    /**
     * Append string to buffer (internal method)
     *
     * str             String to add to buffer
     * type            Type of message (warn, debug,..)
     */
    add(str, type) {
        // Only log, if this message was not added so far
        if this.history.HasKey(str) && (this.history[str] == type)
            return True
        this.buffer .= this.prefix(type) str "`n"
        this.history[str] := type
        if this.instantFlush
            return this.flush()
        return True
    }

    /**
     * Logs event
     *
     * str             String to add to buffer
     */
    event(str) {
        return this.add(str, "")
    }

    /**
     * Logs debug
     *
     * str             String to add to buffer
     */
    debug(str) {
        if this.showDebug
            return this.add(str, "DEBUG")
        return False
    }

    /**
     * Logs warning
     *
     * str             String to add to buffer
     */
    warn(str) {
        if this.showWarn
            return this.add(str, "WARNING")
        return False
    }

    /**
     * Logs error
     *
     * str             String to add to buffer
     */
    error(str) {
        return this.add(str, "ERROR")
    }

    /**
     * Logs critical error
     *
     * str             String to add to buffer
     */
    critical(str) {
        return this.add(str, "CRITICAL")
    }

    /**
     * Wrapper for error and warning logging
     *
     * err             True logs an error, False logs a warning
     * str             String to add to buffer
     */
    issue(err, str) {
        if err
            return this.error(str)
        else
            return this.warn(str)
    }

    /**
     * Write buffer to file (append)
     *
     * returns         True on success, False otherwise
     */
    flush() {
        if !this.path
            return False
        if !(file := FileOpen(this.path, "a"))
            return False
        if !file.Write(this.buffer) {
            file.Close()
            return False
        }
        file.Close()
        this.buffer := "" // Clear buffer if writing was successful
        return True
    }

    /**
     * Prefix from timestamp
     *
     * type            Type of message
     *
     * returns         String with timestamp
     */
    prefix(type) {
        FormatTime, timestamp, , % this.timeformat
        return timestamp " :: " type fill(" ", 8-StrLen(type)) " :: "
    }
}

/**
 * Singleton method returning the only Logger instance
 *
 * returns         Logger instance
 */
Logger_getInstance(this) {
    if !this.instance
        this.instance := new Logger()
    return this.instance
}
