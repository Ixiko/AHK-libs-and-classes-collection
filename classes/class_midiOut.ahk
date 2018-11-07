;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MIDI (Musical Instument Digital Interface)
;; Autor: Bentschi
;; Version: 1.0
;; AutoHotkey version: 1.1
;; Minimum OS: Windows 2000
;;


;* This method can be called before creating a new instance

class MidiOut
{
  static volumeMultiplier := 100
  __new(devID=-1)
    {
      DllCall("LoadLibrary", "str", "winmm")
      if (DllCall("winmm\midiOutOpen", "ptr*", pHandle, "uint", devID, "ptr", 0, "ptr", 0, "uint", 0)!=0)
          return 0
        this._handle := pHandle
        this.channel := []
        Loop, 16
          this.channel.insert(new MidiOut.MidiOutChannel(this, A_Index-1))
        this.defaultChannel := this.channel.minIndex()
    }
    getDeviceList() ;*
    {
      DllCall("LoadLibrary", "str", "winmm")
        count := 0
        list := []
        Loop, % DllCall("winmm\midiOutGetNumDevs")
        {
          VarSetCapacity(caps, 84, 0)
          if (DllCall("winmm\midiOutGetDevCapsW", "ptr", A_Index-1, "ptr", &caps, "uint", 84)!=0)
            continue
            count += 1
            list.insert({name:StrGet(&caps+8, 32, "utf-16"), id:A_Index-1})
        }
        return (count>0) ? list : 0
    }
    __get(k)
    {
      if (k="devID" || k="deviceID")
          return this.getDeviceID()
        else if (k="devName" || k="deviceName")
          return this.getDeviceName()
      else if (k="volumeL")
          return this.getVolumeLeft()
        else if (k="volumeR")
          return this.getVolumeRight()
        else if (k="volume")
          return this.getVolume()
        else if (k="instrument")
          return this.channel[this.defaultChannel].instrument
    }
    __set(k, v)
    {
      if (k="volumeL")
          this.setVolumeLeft(v)
        else if (k="volumeR")
          this.setVolumeRight(v)
        else if (k="volume")
          this.setVolume(v)
        else if (k="instrument")
          this.channel[this.defaultChannel].instrument := v
    }
    __delete()
    {
      DllCall("winmm\midiOutClose", "ptr", this._handle)
    }
    getDeviceID()
    {
      if (DllCall("winmm\midiOutGetID", "ptr", this._handle, "uint*", devID)!=0)
          return
        return devID
    }
    getDeviceName()
    {
        VarSetCapacity(caps, 84, 0)
        if (DllCall("winmm\midiOutGetDevCapsW", "ptr", this.getDeviceID(), "ptr", &caps, "uint", 84)!=0)
            return
        return StrGet(&caps+8, 32, "utf-16")
    }
    getVolumeLeft()
    {
      if (DllCall("winmm\midiOutGetVolume", "ptr", this._handle, "uint*", vol)!=0)
          return
        return (vol&0xffff)/0xffff*this.volumeMultiplier
    }
    getVolumeRight()
    {
      if (DllCall("winmm\midiOutGetVolume", "ptr", this._handle, "uint*", vol)!=0)
          return
        return (vol>>16)/0xffff*this.volumeMultiplier
    }
    getVolume()
    {
      if (DllCall("winmm\midiOutGetVolume", "ptr", this._handle, "uint*", vol)!=0)
          return
        return ((vol>>16)+(vol&0xffff))/(2*0xffff)*this.volumeMultiplier
    }
    setVolumeLeft(vol)
    {
      if (DllCall("winmm\midiOutGetVolume", "ptr", this._handle, "uint*", volOld)!=0)
          return
        if (DllCall("winmm\midiOutSetVolume", "ptr", this._handle, "uint", (volOld&0xffff0000)|round(vol/this.volumeMultiplier*0xffff))!=0)
          return
        return 1
    }
    setVolumeRight(vol)
    {
      if (DllCall("winmm\midiOutGetVolume", "ptr", this._handle, "uint*", volOld)!=0)
          return
        if (DllCall("winmm\midiOutSetVolume", "ptr", this._handle, "uint", (volOld&0xffff)|(round(vol/this.volumeMultiplier*0xffff)<<16))!=0)
          return
        return 1
    }
    setVolume(vol)
    {
      v := round(vol/this.volumeMultiplier*0xffff)
        return (DllCall("winmm\midiOutSetVolume", "ptr", this._handle, "uint", (v<<16)|v)!=0) ? "" : 1
    }
    reset()
    {
      return (DllCall("winmm\midiOutReset", "ptr", this._handle)!=0) ? "" : 1
    }
    noteOn(note, velocity=127)
    {
      this.channel[this.defaultChannel].noteOn(note, velocity)
    }
    noteOff(note="all", velocity=127)
    {
      this.channel[this.defaultChannel].noteOff(note, velocity)
    }
    selectInstrument(instrument=0)
    {
      this.channel[this.defaultChannel].selectInstrument(instrument)
    }
    _message(msg)
    {
      return (DllCall("winmm\midiOutShortMsg", "ptr", this._handle, "uint", msg)!=0) ? "" : 1
    }
    class MidiOutChannel
    {
        __new(midiOut, channelID)
        {
            this._midiOut := midiOut
            this._channelID := channelID
            this._notes := []
            this._instrument := 0
        }
        __get(k)
        {
            if (k="instrument")
                this._instrument
        }
        __set(k, v)
        {
            if (k="instrument")
                this.selectInstrument(v)
        }
        noteOn(note, velocity=127)
        {
            note := this._noteValue(note)
            this._notes[note, velocity] := 1
            return this._midiOut._message(((velocity&0xff)<<16)|((note&0xff)<<8)|((this._channelID)|0xf)|0x90)
        }
        noteOff(note="all", velocity=127)
        {
            note := this._noteValue(note)
            if (note="all")
            {
                for note, velocities in this._notes
                {
                    for velocity, i in velocities
                        this.noteOff(note, velocity)
                }
                this._notes := []
                return 1
            }
            this._notes[note].remove(velocity)
            return this._midiOut._message(((velocity&0xff)<<16)|((note&0xff)<<8)|((this._channelID)|0xf)|0x80)
        }
        selectInstrument(instrument=0)
        {
            this._instrument := instrument
            return this._midiOut._message(((instrument&0xff)<<8)|((this._channelID)|0xf)|0xC0)
        }
        _noteValue(note)
        {
            if (regexmatch(note, "i)([CDEFGAB]|[CDFGA]#)(-[12]|[0-8])", m))
                return {C:0,"C#":1,D:2,"D#":3,E:4,F:5,"F#":6,G:7,"G#":8,A:9,"A#":10,B:11}[m1]+({-2:0,-1:1,0:2,1:3:2:4,3:5,4:6,5:7,6:8,7:9,8:10}[m2]*12)
            return note
        }
    }
}