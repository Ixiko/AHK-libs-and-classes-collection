wait(byref value, timeout := "", interval := "") {
  if (timeout != "") {
    if !(type(timeout) == "Integer" && timeout >= 0)
      throw exception("Invalid timeout (param #2) specified.", -1)
  }
  else
    timeout := 0 ; default value

  if (interval != "") {
    if !(type(interval) == "Integer" && interval >= 0)
      throw exception("Invalid interval (param #3) specified.", -1)
  }
  else
    interval := 100 ; default value  

  ; Check if value is callable:
  try if (
    type(value) == "Func" ||
    type(value) == "BoundFunc" ||
    value.hasMethod("Call")
  )
    funcObj := value

  ; If timeout is specified, determine the end time:
  if (timeout > 0)
    end := A_TickCount + timeout
    
  loop {
    ; If value was considered callable, call it:
    if isSet(funcObj)
      val := funcObj.call()
    else
      val := value

    if (val)
      return val ; cannot be falsy

    ; Make sure we never exceed timeout with a sleep:
    if (isSet(end) && A_TickCount + interval > end) {
      sleep end - A_TickCount
      ; If this check is true, there is no point in continuing, so we return:
      return ; returns empty string
    }
    else
      sleep interval

    ; timeout has been exceeded:
    if (isSet(end) && A_TickCount >= end)
      return ; return empty string
  }
}
