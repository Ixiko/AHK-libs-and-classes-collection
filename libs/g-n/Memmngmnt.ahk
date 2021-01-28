
/*
HeapFunktionen:
Diese Funktionen geben Kontrolle über den Speicher den ein Programm erhält.
Man kann so z.B. einfach neuen Speicher anfordern löschen oder die Länge bestimmen.
Siehe:
http://msdn.microsoft.com/en-us/library/aa366711(v=vs.85).aspx
*/


/*
HeapAlloc(Size)
   Erstellt einen neuen Speicherbereich mit der gewünschten größe und gibt die Start Adresse zurück.
   Size: die Größe des neuen Speicherbereichs in bytes.
   Return: der Pointer auf den Speicherbereich.
Benutze Funktionen:
HeapAlloc: Die Hauptfunktion. 
http://msdn.microsoft.com/en-us/library/windows/apps/aa366597(v=vs.85).aspx
GetProcessHeap: Funktion um auf den Process Heap zugreifen zu können.
http://msdn.microsoft.com/en-us/library/windows/apps/aa366569(v=vs.85).aspx
*/


HeapAlloc(Size)
{
	return DllCall("HeapAlloc","Ptr",DllCall("GetProcessHeap"),"UInt",8,"Ptr",size,"ptr")	
}


/*
HeapReAlloc(ptr,Size)
  Funktion um die Größe eines bereits erstellten Speicherbereichs zu verändern.(Daten bleiben erhalten)
  ptr: der Pointer auf den Speicherbereich kann z.B. durch die HeapAlloc funktion zurückgegen werden.
  Size: die neue Größe des Speicherbereichs in bytes.
  Return: der Pointer auf den Speicherbereich mit der neuen größe.
Benutze Funktionen:
HeapReAlloc: Die Hauptfunktion. 
http://msdn.microsoft.com/en-us/library/windows/apps/aa366704(v=vs.85).aspx
GetProcessHeap: Funktion um auf den Process Heap zugreifen zu können.
http://msdn.microsoft.com/en-us/library/windows/apps/aa366569(v=vs.85).aspx
*/


HeapReAlloc(ptr,Size)
{
	return DllCall("HeapReAlloc","Ptr",DllCall("GetProcessHeap"),"UInt",8,"Ptr",ptr,"Ptr",Size)
}


/*
HeapSize(ptr)
  Funktion um die Größe eines bereits erstellten Speicherbereichs zu bestimmen.
  ptr: der Pointer auf den Speicherbereich kann z.B. durch die HeapAlloc funktion zurückgegen werden.
  Return: die Größe des Speicherbereichs in Bytes. 
Benutze Funktionen:
HeapSize: Die Hauptfunktion. 
http://msdn.microsoft.com/en-us/library/windows/apps/aa366706(v=vs.85).aspx
GetProcessHeap: Funktion um auf den Process Heap zugreifen zu können.
http://msdn.microsoft.com/en-us/library/windows/apps/aa366569(v=vs.85).aspx
*/


HeapSize(ptr)
{
	return a:=DllCall("HeapSize","Ptr",DllCall("GetProcessHeap"),"UInt",8,"Ptr",ptr)
}


/*
HeapFree(ptr)
  Funktion um einen Speicherbereich freizugeben.(löschen)
  ptr: der Pointer auf den Speicherbereich kann z.B. durch die HeapAlloc funktion zurückgegen werden.  
  Return: Wenn die Funktion erfolgreich ist dann 0
Benutze Funktionen:
HeapFree: Die Hauptfunktion. 
http://msdn.microsoft.com/en-us/library/windows/apps/aa366701(v=vs.85).aspx
GetProcessHeap: Funktion um auf den Process Heap zugreifen zu können.
http://msdn.microsoft.com/en-us/library/windows/apps/aa366569(v=vs.85).aspx
*/


HeapFree(ptr)
{
	return DllCall("HeapFree","Ptr",DllCall("GetProcessHeap"),"UInt",8,"Ptr",ptr)
}


/*
RtlMoveMemory(dptr,sptr,length) Diese Funktion kopiert bytes. Die Herkunft und das Ziel können sich sogar überlappen.
  dptr: die Herkunft(Pointer)
  sptr: das Ziel (Pointer)  
  Length: die Länge der zu kopierenden bytes.
  Return: nichts.
Benutze Funktionen:
RtlMoveMemory: Die Hauptfunktion.
http://msdn.microsoft.com/en-us/library/windows/desktop/aa366788(v=vs.85).aspx
*/


RtlMoveMemory(dptr,sptr,length)
{
	DllCall("RtlMoveMemory","ptr",dptr,"ptr",sptr,"ptr",length)
}


/*
HeapCreateCopy(srcptr)
  Funktion um eine Kopie eines Speicherbereichs zu erstellen.
  srcptr: der Pointer auf den Speicherbereich kann z.B. durch die HeapAlloc funktion zurückgegen werden.  
  Return: der Pointer auf den neuen Speicherbereich mit dem selben Inhalt wie der alte.
Benutze Funktionen:
HeapSize: Um die Größe des zu kopierenden Speicherbereichs zu ermitteln.
HeapAlloc: Um einen neuen SpeicherBereich mit der selben Größe zu erstellen
RtlMoveMemory: Um die Daten des alten SpeicherBereichs in den neuen zu verschieben. 
*/


HeapCreateCopy(srcptr)
{
	ptr:=HeapAlloc(size:=HeapSize(srcptr))
	RtlMoveMemory(ptr,sourceptr,size)
	return ptr
}


/*
HeapInsert(ptr,val,type="ptr")
  Funktion um neue Daten an einen Speicherbereich anzuhängen. Es wird ein enuer erstellt falls noch kein Pointer angegeben wurde.
  ptr: der Pointer auf den Speicherbereich kann z.B. durch die HeapAlloc funktion zurückgegen werden.  
  val: die Daten
  type="ptr": der Typ der Daten (DllCall typen). Standardmäßig ist ptr vorgegeben.
  Return: der Pointer auf den neuen erweitereten Speicherbereich.
Benutze Funktionen:
HeapSize: Um die Größe des Speicherbereichs zu ermitteln.
HeapAlloc: Um einen neuen Speicherbereich zu erstellen, wenn noch keiner vorhanden ist.
HeapReAlloc: Um den Speicherbereich vergrößern.
NumPut: Um die Daten am Ende des vergrößerten Speicherbereich einzufügen.
*/


HeapInsert(ptr,val,type="ptr")
{
static f:={UInt:4,Int:4,UPtr:A_PtrSize,Ptr:A_PtrSize,Float:4,Double:8,UChar:1,Char:1,UShort:2,Short:2,Int64:8}
    If (ptr)
    {
	size:=HeapSize(ptr)
	ptr:=HeapReAlloc(ptr,size+f[type])	
	}
	Else
	ptr:=HeapAlloc(f[type]),size:=0
	numput(val,(ptr+0),size,type)
	return ptr
}


/*
HeapRemove(ptr,offset=0,type="ptr")
  Funktion um ein Stück Daten aus einem Speicherbereich zu entfernen. Wenn das letzte Stück Daten entfernt wird, wird der Speicherbereich freigegeben (gelöscht).
  ptr: der Pointer auf den Speicherbereich kann z.B. durch die HeapAlloc funktion zurückgegen werden.  
  val: offset Startpunkt der Daten
  type="ptr": der Typ der Daten (DllCall typen). Standardmäßig ist ptr vorgegeben.
  Return: der Pointer auf den neuen verkürzten Speicherbereich./0 Wenn dieser nicht mehr vorhanden ist
Benutze Funktionen:
HeapSize: Um die Größe des Speicherbereichs zu ermitteln.
RtlMoveMemory: Um die Daten die hinter den Daten liegen, die entfernt werden sollen weiter nach vorne zu Bewegen.
HeapFree: um den Speicherbereich eventuell freizugeben.
HeapReAlloc: Um den Speicherbereich verkleinern.
*/


HeapRemove(ptr,offset=0,type="ptr")
{
static f:={UInt:4,Int:4,UPtr:A_PtrSize,Ptr:A_PtrSize,Float:4,Double:8,UChar:1,Char:1,UShort:2,Short:2,Int64:8}
	size:=HeapSize(ptr)
	If (size-(offset+f[type]))
	    RtlMoveMemory(ptr+offset,ptr+offset+f[type],size-(offset+f[type]))
	If !(size-f[type])
		return HeapFree(ptr)
	return HeapReAlloc(ptr,size-f[type])
}]