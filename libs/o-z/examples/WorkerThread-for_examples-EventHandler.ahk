class EventHandler
{
   registeredHandlers := []
   
   Register(handler){
      this.registeredHandlers.Insert(handler)
   }
   
   UnRegister(handler){
      for k, h in this.registeredHandlers
      {
         if(h == handler)
            this.registeredHandlers.Remove(k)
      }
   }
   
   Clear(){
      registeredHandlers := []
   }
   
   __Call(target, params*)
    {
      if(target == ""){
         for each, handler in this.registeredHandlers
         {
            handler.(params*)
         }
      }
    }
   
   __Set(name, value){
      if(name){
         if(name = "Handler"){
            this.Register(value)
            return ""
         }
      }
   }

   __New(){
      this.registeredHandlers := []
   }
}