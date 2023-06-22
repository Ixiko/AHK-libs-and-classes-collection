/*
|==================================================================================================================================|
|                                                                                                                                  |
| EVENT HOOK LIBRARY                                                                                                               |
|                                                                                                                                  |
|==================================================================================================================================|
|                                                                                                                                  |
| Rev.                    : 2.0                                                                                                    |
| Operative System        : Windows 7 x64                                                                                          |
| Language                : AutoHotkey                                                                                             |
| Language Rev.           : 1.1.33.02                                                                                              |
| Implementation date     :                                                                                                        |
| Modify date             : 04/2023                                                                                                |
| Authors                 : KuroiLight - klomb - Archimede                                                                         |
|                                                                                                                                  |
|==================================================================================================================================|
|                                                                                                                                  |
| Rev. 2.0 is no fully compatible with before rev..                                                                                |
| The last revision works better than before:                                                                                      |
| - can manage many Event Hooks, everyone based on different PID ( Process IDentifier );                                           |
| - generates, manage and return an Associative Array about all working Event Hooks;                                               |
| - it is possible to ask for return an Associative Array about all working Event Hooks;                                           |
| - it is possible to specify one or many opened Event Hooks to close;                                                             |
| - no generates Global variables or Arrays;                                                                                       |
| - there are only 2 UDF Functions, instead many function one call other that call another...                                      |
| - is well explained.                                                                                                             |
|                                                                                                                                  |
| Rev. 2.0 non è completamente compatibile con la precedente rev..                                                                 |
| Questa ultima revisione funziona meglio per i seguenti motivi:                                                                   |
| - gestisce molti Event Hooks contemporaneamente, ognuno rispetto ad un differente PID ( Process IDentifier );                    |
| - genera, gestisce e ritorna un Array associativo che riguarda tutti gli Event Hooks funzionanti;                                |
| - è possibile richiedere il solo Array associativo relativo a tutti gli Event Hook funzionanti;                                  |
| - è possibile specificare uno o più Event Hooks generati da chiudere;                                                            |
| - non genera nessuna variabile o array Global;                                                                                   |
| - ci sono solo 2 Funzioni UDF, aniché molte funzioni che si chiamano reciprocamente;                                             |
| - è spiegata accuratamente.
|                                                                                                                                  |
|==================================================================================================================================|
|                                                                                                                                  |
| This library allow to set and reset an asynchronous call to another UDF function to automatically call it when a system event    |
| event generates.                                                                                                                 |
| It is possible to generate an Event Hook ( that is an int number ) associated to a process, to generate a system message ( that  |
| is a transparent call ) for one or much specific situation ( for example every window close about that Process ), and say to     |
| automatically call another UDF function everytime generates that specific situation: that transparent message will received by   |
| the AutoHotKey program and automatically call the specified UDF function.                                                        |
| When the program closes, all Event Hook closes.                                                                                  |
| When is necessary to stop a specific asynchronous call to the UDF function is possible to close the generated Event Hook.        |
| The Function to Event Hook generation ( one or much ) is:                                                                        |
| HookEvent( ... )                                                                                                                 |
| The Function to closes one or much Event Hook generated is:                                                                      |
| UnHookEvent( ... )                                                                                                               |
| The events that is possible to assign are all defined by a constant in this library; that constant names are all beginning with  |
| WINEVENT_.                                                                                                                       |
|                                                                                                                                  |
| Questa libreria permette di settare e resettare una chiamata asincrona verso un'altra funzione UDF per ottenere una chiamata     |
| automatica a tale funzione quando si genera un evento di sistema.                                                                |
| È possibile gerare un Event Hook ( che è un numero intero ) associato ad un processo, per generare un messaggio ( che è una      |
| chiamata trasparente ) per una o più specifiche situazioni ( per esempio ad ogni chiusura window relativa a tale processo ), e   |
| dire di chiamare automaticamente un'altra funzione UDF ogni volta che si genera quella specifica situazione: il messaggio        |
| trasparente verrà ricevuto dal programma AutoHotkey che chiamerà automaticamente la funzione UDF specificata.                    |
| Quando il programma termina, tutti gli Event Hook terminano.                                                                     |
| Se è necessario terminare una specifica chiamata asincrona ad una funzione UDF è possibile chiudere l'Event Hook generato.       |
| La funzione per la generazione di uno o più Event Hook è:                                                                        |
| HookEvent( ... )                                                                                                                 |
| La funzione per la chiusura di uno o più Event Hook è:                                                                           |
| UnHookEvent( ... )                                                                                                               |
| Gli eventi che è possibile assegnare sono tutti definiti tramite una costante in questa libreria; tali costanti sono tutte       |
| quelle che iniziano con WINEVENT_.                                                                                               |
|                                                                                                                                  |
|==================================================================================================================================|
*/

Global CHILDID_SELF                                    := 0x00000000 ; Indicates that we are referring to the control rather than
                                                                     ; one of its children.

; https://learn.microsoft.com/en-us/windows/win32/procthread/thread-security-and-access-rights
Global THREAD_TERMINATE                                := 0x00000001 ; Required to terminate a thread using TerminateThread.
       , THREAD_SUSPEND_RESUME                         := 0x00000002 ; Required to suspend or resume a thread (see SuspendThread and
                                                                     ; ResumeThread).
       , THREAD_GET_CONTEXT                            := 0x00000008 ; Required to read the context of a thread using
                                                                     ; GetThreadContext.
       , THREAD_SET_CONTEXT                            := 0x00000010 ; Required to write the context of a thread using
                                                                     ; SetThreadContext.
       , THREAD_SET_INFORMATION                        := 0x00000020 ; Required to set certain information in the thread object.
       , THREAD_QUERY_INFORMATION                      := 0x00000040 ; Required to read certain information from the thread object,
                                                                     ; such as the exit code (see GetExitCodeThread).
       , THREAD_SET_THREAD_TOKEN                       := 0x00000080 ; Required to set the impersonation token for a thread using
                                                                     ; SetThreadToken.
       , THREAD_IMPERSONATE                            := 0x00000100 ; Required to use a thread's security information directly
                                                                     ; without calling it by using a communication mechanism that
                                                                     ; provides impersonation services.
       , THREAD_DIRECT_IMPERSONATION                   := 0x00000200 ; Required for a server thread that impersonates a client.
       , THREAD_SET_LIMITED_INFORMATION                := 0x00000400 ; Required to set certain information in the thread object. A
                                                                     ; handle that has the THREAD_SET_INFORMATION access right is
                                                                     ; automatically granted THREAD_SET_LIMITED_INFORMATION.Windows
                                                                     ; Server 2003 and Windows XP: This access right is not
                                                                     ; supported.
       , THREAD_QUERY_LIMITED_INFORMATION              := 0x00000800 ; Required to read certain information from the thread objects
                                                                     ; (see GetProcessIdOfThread). A handle that has the
                                                                     ; THREAD_QUERY_INFORMATION access right is automatically
                                                                     ; granted THREAD_QUERY_LIMITED_INFORMATION. Windows Server 2003
                                                                     ; and Windows XP: This access right is not supported.
       , OBJECT_WRITE_DAC                              := 0x00040000 ; Required to modify the DACL in the security descriptor for
                                                                     ; the object.
       , OBJECT_WRITE_OWNER                            := 0x00080000 ; Required to change the owner in the security descriptor for
                                                                     ; the object.
       , OBJECT_DELETE                                 := 0x00010000 ; Required to delete the object.
       , OBJECT_READ_CONTROL                           := 0x00020000 ; Required to read information in the security descriptor for
                                                                     ; the object, not including the information in the SACL. To
                                                                     ; read or write the SACL, you must request the
                                                                     ; ACCESS_SYSTEM_SECURITY access right. For more information,
                                                                     ; see SACL Access Right at this address:
                                                                     ; https://learn.microsoft.com/en-us/windows/win32/secauthz/sacl-access-right
       , OBJECT_SYNCHRONIZE                            := 0x00100000 ; The right to use the object for synchronization. This enables
                                                                     ; a thread to wait until the object is in the signaled state.

;https://learn.microsoft.com/en-us/windows/win32/winauto/object-identifiers
;https://github.com/bizzehdee/wasabi/blob/master/src/wnd/accessible.h
;https://github.com/wine-mirror/wine/blob/08b01d8271fe15c7680a957778d506221d7d94eb/include/winuser.h#L3181-L3195
Global OBJID_WINDOW                                    := 0x00000000 ; The window itself rather than a child object.
       , OBJID_NATIVEOM                                := 0xFFFFFFF0 ; In response to this object identifier, third-party
                                                                     ; applications can expose their own object model. Third-party
                                                                     ; applications can return any COM interface in response to this
                                                                     ; object identifier.
       , OBJID_QUERYCLASSNAMEIDX                       := 0xFFFFFFF4 ; An object identifier that Oleacc.dll uses internally. For
                                                                     ; more information, see OBJID_QUERYCLASSNAMEIDX.txt file.
       , OBJID_SOUND                                   := 0xFFFFFFF5 ; A sound object. Sound objects do not have screen locations or
                                                                     ; children, but they do have name and state attributes. They
                                                                     ; are children of the application that is playing the sound.
       , OBJID_ALERT                                   := 0xFFFFFFF6 ; An alert that is associated with a window or an application.
                                                                     ; System provided message boxes are the only UI elements that
                                                                     ; send events with this object identifier. Server applications
                                                                     ; cannot use the AccessibleObjectFromX functions with this
                                                                     ; object identifier. This is a known issue with Microsoft
                                                                     ; Active Accessibility.
       , OBJID_CURSOR                                  := 0xFFFFFFF7 ; The mouse pointer. There is only one mouse pointer in the
                                                                     ; system, and it is not a child of any window.
       , OBJID_CARET                                   := 0xFFFFFFF8 ; The text insertion bar (caret) in the window.
       , OBJID_SIZEGRIP                                := 0xFFFFFFF9 ; The window's size grip: an optional frame component located
                                                                     ; at the lower-right corner of the window frame.
       , OBJID_HSCROLL                                 := 0xFFFFFFFA ; The window's horizontal scroll bar.
       , OBJID_VSCROLL                                 := 0xFFFFFFFB ; The window's vertical scroll bar.
       , OBJID_CLIENT                                  := 0xFFFFFFFC ; The window's client area. In most cases, the operating system
                                                                     ; controls the frame elements and the client object contains
                                                                     ; all elements that are controlled by the application. Servers
                                                                     ; only process the WM_GETOBJECT messages in which the lParam is
                                                                     ; OBJID_CLIENT, OBJID_WINDOW, or a custom object identifier.
       , OBJID_MENU                                    := 0xFFFFFFFD ; The window's menu bar.
       , OBJID_TITLEBAR                                := 0xFFFFFFFE ; The window's title bar.
       , OBJID_SYSMENU                                 := 0xFFFFFFFF ; The window's system menu.

;https://msdn.microsoft.com/en-us/library/windows/desktop/dd373640(v=vs.85).aspx
;dwFlags: Flag values that specify the location of the hook function and of the events to be skipped.
Global WINEVENT_OUTOFCONTEXT                           := 0x0000     ; The callback function is not mapped into the address space of
                                                                     ; the process that generates the event. Because the hook
                                                                     ; function is called across process boundaries, the system must
                                                                     ; queue events. Although this method is asynchronous, events
                                                                     ; are guaranteed to be in sequential order. For more
                                                                     ; information, see Out-of-Context Hook Functions.
                                                                     ; La funzione di callback non viene mappata nello spazio
                                                                     ; indirizzi del processo che genera l'evento. Poiché la
                                                                     ; funzione hook viene chiamata attraverso i limiti del
                                                                     ; processo, il sistema deve accodare gli eventi. Anche se
                                                                     ; questo metodo è asincrono, gli eventi sono garantiti in
                                                                     ; ordine sequenziale. Per altre informazioni, vedere Funzioni
                                                                     ; hook out-of-context.
       , WINEVENT_SKIPOWNTHREAD                        := 0x0001     ; Prevents this instance of the hook from receiving the events
                                                                     ; that are generated by the thread that is registering this
                                                                     ; hook.
                                                                     ; Impedisce a questa istanza dell'hook di ricevere gli eventi
                                                                     ; generati dal thread che registra questo hook.
       , WINEVENT_SKIPOWNPROCESS                       := 0x0002     ; Prevents this instance of the hook from receiving the events
                                                                     ; that are generated by threads in this process. This flag does
                                                                     ; not prevent threads from generating events.
                                                                     ; Impedisce a questa istanza dell'hook di ricevere gli eventi
                                                                     ; generati dai thread in questo processo. Questo flag non
                                                                     ; impedisce ai thread di generare eventi.
       , WINEVENT_INCONTEXT                            := 0x0004     ; The DLL that contains the callback function is mapped into
                                                                     ; the address space of the process that generates the event.
                                                                     ; With this flag, the system sends event notifications to the
                                                                     ; callback function as they occur. The hook function must be in
                                                                     ; a DLL when this flag is specified. This flag has no effect
                                                                     ; when both the calling process and the generating process are
                                                                     ; not 32-bit or 64-bit processes, or when the generating
                                                                     ; process is a console application. For more information, see
                                                                     ; In-Context Hook Functions.
                                                                     ; La DLL che contiene la funzione di callback viene mappata
                                                                     ; nello spazio indirizzi del processo che genera l'evento. Con
                                                                     ; questo flag, il sistema invia notifiche degli eventi alla
                                                                     ; funzione di callback man mano che si verificano. Quando si
                                                                     ; specifica questo flag, la funzione hook deve trovarsi in una
                                                                     ; DLL. Questo flag non ha alcun effetto quando sia il processo
                                                                     ; chiamante che il processo di generazione non sono processi a
                                                                     ; 32 bit o a 64 bit o quando il processo di generazione è
                                                                     ; un'applicazione console. Per altre informazioni, vedere
                                                                     ; Funzioni hook nel contesto.

;https://msdn.microsoft.com/en-us/library/windows/desktop/dd318066(v=vs.85).aspx
;eventMin/eventMax: Specifies the event constant for the lowest/highest event value in the range of events that are handled by the hook function.
;0x00000001-0x7FFFFFFF
Global EVENT_OBJECT_ACCELERATORCHANGE                  := 0x8012     ; An object's KeyboardShortcut property has changed. Server
                                                                     ; applications send this event for their accessible objects.
                                                                     ; La proprietà KeyboardShortcut di un oggetto è stata
                                                                     ; modificata. L'evento viene inviato dalle applicazioni server
                                                                     ; per i relativi oggetti accessibili.
       , EVENT_OBJECT_CLOAKED                          := 0x8017     ; Sent when a window is cloaked. A cloaked window still exists,
                                                                     ; but is invisible to the user.
                                                                     ; Inviato quando una finestra è mascherata. Esiste ancora una
                                                                     ; finestra mascherata, ma è invisibile all'utente.
       , EVENT_OBJECT_CONTENTSCROLLED                  := 0x8015     ; A window object's scrolling has ended. Unlike
                                                                     ; EVENT_SYSTEM_SCROLLEND, this event is associated with the
                                                                     ; scrolling window. Whether the scrolling is horizontal or
                                                                     ; vertical scrolling, this event should be sent whenever the
                                                                     ; scroll action is completed.
                                                                     ; The hwnd parameter of the WinEventProc callback function
                                                                     ; describes the scrolling window; the idObject parameter is
                                                                     ; OBJID_CLIENT, and the idChild parameter is CHILDID_SELF.
                                                                     ; Lo scorrimento di un oggetto finestra è terminato. A
                                                                     ; differenza di EVENT_SYSTEM_SCROLLEND, questo evento è
                                                                     ; associato alla finestra di scorrimento. Indipendentemente dal
                                                                     ; fatto che lo scorrimento sia orizzontale o verticale, questo
                                                                     ; evento deve essere inviato ogni volta che viene completata
                                                                     ; l'azione di scorrimento.
                                                                     ; Il parametro hwnd della funzione di callback WinEventProc
                                                                     ; descrive la finestra di scorrimento; il parametro idObject è
                                                                     ; OBJID_CLIENT e il parametro idChild è CHILDID_SELF.
       , EVENT_OBJECT_CREATE                           := 0x8000     ; An object has been created. The system sends this event for
                                                                     ; the following user interface elements: caret, header control,
                                                                     ; list-view control, tab control, toolbar control, tree view
                                                                     ; control, and window object. Server applications send this
                                                                     ; event for their accessible objects.
                                                                     ; Before sending the event for the parent object, servers must
                                                                     ; send it for all of an object's child objects. Servers must
                                                                     ; ensure that all child objects are fully created and ready to
                                                                     ; accept IAccessible calls from clients before the parent
                                                                     ; object sends this event.
                                                                     ; Because a parent object is created after its child objects,
                                                                     ; clients must make sure that an object's parent has been
                                                                     ; created before calling IAccessible::get_accParent,
                                                                     ; particularly if in-context hook functions are used.
                                                                     ; Un oggetto è stato creato. Il sistema invia questo evento per
                                                                     ; gli elementi dell'interfaccia utente seguenti: cursore,
                                                                     ; controllo intestazione, controllo visualizzazione elenco,
                                                                     ; controllo struttura a schede, controllo barra degli
                                                                     ; strumenti, controllo visualizzazione struttura ad albero e
                                                                     ; oggetto finestra. L'evento viene inviato dalle applicazioni
                                                                     ; server per i relativi oggetti accessibili.
                                                                     ; Prima di inviare l'evento per l'oggetto padre, i server
                                                                     ; devono inviarlo per tutti gli oggetti figlio di un oggetto.
                                                                     ; I server devono assicurarsi che tutti gli oggetti figlio
                                                                     ; siano completamente creati e pronti per accettare le chiamate
                                                                     ; IAccessible dai client prima che l'oggetto padre invii questo
                                                                     ; evento.
                                                                     ; Poiché un oggetto padre viene creato dopo gli oggetti figlio,
                                                                     ; i client devono assicurarsi che l'elemento padre di un
                                                                     ; oggetto sia stato creato prima di chiamare
                                                                     ; IAccessible::get_accParent, in particolare se vengono usate
                                                                     ; funzioni hook nel contesto.
       , EVENT_OBJECT_DEFACTIONCHANGE                  := 0x8011     ; An object's DefaultAction property has changed. The system
                                                                     ; sends this event for dialog boxes. Server applications send
                                                                     ; this event for their accessible objects.
                                                                     ; La proprietà DefaultAction di un oggetto è stata modificata.
                                                                     ; Questo evento viene inviato dal sistema per le finestre di
                                                                     ; dialogo. L'evento viene inviato dalle applicazioni server per
                                                                     ; i relativi oggetti accessibili.
       , EVENT_OBJECT_DESCRIPTIONCHANGE                := 0x800D     ; An object's Description property has changed. Server
                                                                     ; applications send this event for their accessible objects.
                                                                     ; La proprietà Description di un oggetto è stata modificata.
                                                                     ; L'evento viene inviato dalle applicazioni server per i
                                                                     ; relativi oggetti accessibili.
       , EVENT_OBJECT_DESTROY                          := 0x8001     ; An object has been destroyed. The system sends this event for
                                                                     ; the following user interface elements: caret, header control,
                                                                     ; list-view control, tab control, toolbar control, tree view
                                                                     ; control, and window object. Server applications send this
                                                                     ; event for their accessible objects.
                                                                     ; Clients assume that all of an object's children are destroyed
                                                                     ; when the parent object sends this event.
                                                                     ; After receiving this event, clients do not call an object's
                                                                     ; IAccessible properties or methods. However, the interface
                                                                     ; pointer must remain valid as long as there is a reference
                                                                     ; count on it (due to COM rules), but the UI element may no
                                                                     ; longer be present. Further calls on the interface pointer may
                                                                     ; return failure errors; to prevent this, servers create proxy
                                                                     ; objects and monitor their life spans.
                                                                     ; Un oggetto è stato eliminato. Il sistema invia questo evento
                                                                     ; per gli elementi dell'interfaccia utente seguenti: cursore,
                                                                     ; controllo intestazione, controllo visualizzazione elenco,
                                                                     ; controllo struttura a schede, controllo barra degli
                                                                     ; strumenti, controllo visualizzazione struttura ad albero e
                                                                     ; oggetto finestra. L'evento viene inviato dalle applicazioni
                                                                     ; server per i relativi oggetti accessibili.
                                                                     ; I client presuppongono che tutti gli elementi figlio di un
                                                                     ; oggetto vengano eliminati definitivamente quando l'oggetto
                                                                     ; padre invia questo evento.
                                                                     ; Dopo aver ricevuto questo evento, i client non chiamano le
                                                                     ; proprietà o i metodi IAccessible di un oggetto. Tuttavia, il
                                                                     ; puntatore all'interfaccia deve rimanere valido purché vi sia
                                                                     ; un conteggio dei riferimenti (a causa delle regole COM), ma
                                                                     ; l'elemento dell'interfaccia utente potrebbe non essere più
                                                                     ; presente. Ulteriori chiamate sul puntatore di interfaccia
                                                                     ; possono restituire errori di errore; per evitare questo
                                                                     ; problema, i server creano oggetti proxy e monitorano
                                                                     ; l'intervallo di vita.
                                                                     ; La chiusura di una window a causa della chiusura di un
                                                                     ; processo ( per esempio click per chiudere e uscire da un
                                                                     ; programma ) può generare l'eliminazione di altre window o
                                                                     ; oggetti non window: per esempio genera l'eliminazione
                                                                     ; dell'immagine sulla barra delle applicazioni, oltre
                                                                     ; all'eliminazione di tante altre window hidden proprie del
                                                                     ; programma, che provocano ognuna un evento di eliminazione:
                                                                     ; si genera quindi una serie di eventi a cascata che possono
                                                                     ; anche essere numerosi, dovuti anche ad altri processi diversi
                                                                     ; da quello che è stato chiuso.
                                                                     ; Inoltre i Window ID ( argomento hWnd della Funzione asincrona
                                                                     ; dichiarata in HookEvent( ... )) non si riferiscono
                                                                     ; necessariamente alla window aperta del processo, possono
                                                                     ; infatti riferirsi ad altre window, anche hidden, pure dello
                                                                     ; stesso processo: è quindi necessario utilizzare la Funzione
                                                                     ; WinGet... per conoscere il PID del processo oppure il nome
                                                                     ; del processo ( soluzione meno sicura poiché possono esistere
																	 ; più processi con lo stesso nome ) a cui si riferisce il
                                                                     ; Window ID hWnd.
                                                                     ; Altri eventi, inoltre, possono generare questo evento, come
                                                                     ; per esempio l'acquisizione o la perdita del focus.
       , EVENT_OBJECT_DRAGSTART                        := 0x8021     ; The user started to drag an element. The hwnd, idObject, and
                                                                     ; idChild parameters of the WinEventProc callback function
                                                                     ; identify the object being dragged.
                                                                     ; L'utente ha iniziato a trascinare un elemento. I parametri
                                                                     ; hwnd, idObject e idChild della funzione di callback
                                                                     ; WinEventProc identificano l'oggetto trascinato.
       , EVENT_OBJECT_DRAGCANCEL                       := 0x8022     ; The user has ended a drag operation before dropping the
                                                                     ; dragged element on a drop target. The hwnd, idObject, and
                                                                     ; idChild parameters of the WinEventProc callback function
                                                                     ; identify the object being dragged.
                                                                     ; L'utente ha terminato un'operazione di trascinamento prima di
                                                                     ; rilasciare l'elemento trascinato su una destinazione di
                                                                     ; rilascio. I parametri hwnd, idObject e idChild della funzione
                                                                     ; di callback WinEventProc identificano l'oggetto trascinato.
       , EVENT_OBJECT_DRAGCOMPLETE                     := 0x8023     ; The user dropped an element on a drop target. The hwnd,
                                                                     ; idObject, and idChild parameters of the WinEventProc callback
                                                                     ; function identify the object being dragged.
                                                                     ; L'utente ha rilasciato un elemento in una destinazione di
                                                                     ; rilascio. I parametri hwnd, idObject e idChild della funzione
                                                                     ; di callback WinEventProc identificano l'oggetto trascinato.
       , EVENT_OBJECT_DRAGENTER                        := 0x8024     ; The user dragged an element into a drop target's boundary.
                                                                     ; The hwnd, idObject, and idChild parameters of the
                                                                     ; WinEventProc callback function identify the drop target.
                                                                     ; L'utente ha trascinato un elemento nel limite di una
                                                                     ; destinazione di rilascio. I parametri hwnd, idObject e
                                                                     ; idChild della funzione di callback WinEventProc identificano
                                                                     ; la destinazione di rilascio.
       , EVENT_OBJECT_DRAGLEAVE                        := 0x8025     ; The user dragged an element out of a drop target's boundary.
                                                                     ; The hwnd, idObject, and idChild parameters of the
                                                                     ; WinEventProc callback function identify the drop target.
                                                                     ; L'utente ha trascinato un elemento fuori dal limite di una
                                                                     ; destinazione di rilascio. I parametri hwnd, idObject e
                                                                     ; idChild della funzione di callback WinEventProc identificano
                                                                     ; la destinazione di rilascio.
       , EVENT_OBJECT_DRAGDROPPED                      := 0x8026     ; The user dropped an element on a drop target. The hwnd,
                                                                     ; idObject, and idChild parameters of the WinEventProc callback
                                                                     ; function identify the drop target.
                                                                     ; L'utente ha rilasciato un elemento in una destinazione di
                                                                     ; rilascio. I parametri hwnd, idObject e idChild della funzione
                                                                     ; di callback WinEventProc identificano la destinazione di
                                                                     ; rilascio.
       , EVENT_OBJECT_END                              := 0x80FF     ; The highest object event value.
                                                                     ; Valore dell'evento dell'oggetto più alto.
       , EVENT_OBJECT_FOCUS                            := 0x8005     ; An object has received the keyboard focus. The system sends
                                                                     ; this event for the following user interface elements:
                                                                     ; list-view control, menu bar, pop-up menu, switch window, tab
                                                                     ; control, tree view control, and window object. Server
                                                                     ; applications send this event for their accessible objects.
                                                                     ; The hwnd parameter of the WinEventProc callback function
                                                                     ; identifies the window that receives the keyboard focus.
                                                                     ; Un oggetto ha ricevuto lo stato attivo ( focus ). Il sistema
                                                                     ; invia questo evento per gli elementi dell'interfaccia utente
                                                                     ; seguenti: controllo visualizzazione elenco, barra dei menu,
                                                                     ; menu a comparsa, finestra di opzione, controllo struttura a
                                                                     ; schede, controllo visualizzazione albero e oggetto finestra.
                                                                     ; L'evento viene inviato dalle applicazioni server per i
                                                                     ; relativi oggetti accessibili.
                                                                     ; Il parametro hwnd della funzione di callback WinEventProc
                                                                     ; identifica la finestra che riceve lo stato attivo della
                                                                     ; tastiera.
       , EVENT_OBJECT_HELPCHANGE                       := 0x8010     ; An object's Help property has changed. Server applications
                                                                     ; send this event for their accessible objects.
                                                                     ; La proprietà della Guida di un oggetto è stata modificata.
                                                                     ; L'evento viene inviato dalle applicazioni server per i
                                                                     ; relativi oggetti accessibili.
       , EVENT_OBJECT_HIDE                             := 0x8003     ; An object is hidden. The system sends this event for the
                                                                     ; following user interface elements: caret and cursor. Server
                                                                     ; applications send this event for their accessible objects.
                                                                     ; When this event is generated for a parent object, all child
                                                                     ; objects are already hidden. Server applications do not send
                                                                     ; this event for the child objects.
                                                                     ; Hidden objects include the STATE_SYSTEM_INVISIBLE flag; shown
                                                                     ; objects do not include this flag. The EVENT_OBJECT_HIDE event
                                                                     ; also indicates that the STATE_SYSTEM_INVISIBLE flag is set.
                                                                     ; Therefore, servers do not send the EVENT_STATE_CHANGE event
                                                                     ; in this case.
                                                                     ; Un oggetto è nascosto. Il sistema invia questo evento per gli
                                                                     ; elementi dell'interfaccia utente seguenti: punto di
                                                                     ; inserimento e cursore.
                                                                     ; L'evento viene inviato dalle applicazioni server per i
                                                                     ; relativi oggetti accessibili.
                                                                     ; Quando questo evento viene generato per un oggetto padre,
                                                                     ; tutti gli oggetti figlio sono già nascosti. Le applicazioni
                                                                     ; server non inviano questo evento per gli oggetti figlio.
                                                                     ; Gli oggetti nascosti includono il flag di
                                                                     ; STATE_SYSTEM_INVISIBLE; gli oggetti visualizzati non
                                                                     ; includono questo flag. L'evento EVENT_OBJECT_HIDE indica
                                                                     ; anche che il flag di STATE_SYSTEM_INVISIBLE è impostato.
                                                                     ; Pertanto, i server non inviano l'evento EVENT_STATE_CHANGE in
                                                                     ; questo caso.
       , EVENT_OBJECT_HOSTEDOBJECTSINVALIDATED         := 0x8020     ; A window that hosts other accessible objects has changed the
                                                                     ; hosted objects. A client might need to query the host window
                                                                     ; to discover the new hosted objects, especially if the client
                                                                     ; has been monitoring events from the window. A hosted object
                                                                     ; is an object from an accessibility framework (MSAA or UI
                                                                     ; Automation) that is different from that of the host. Changes
                                                                     ; in hosted objects that are from the same framework as the
                                                                     ; host should be handed with the structural change events, such
                                                                     ; as EVENT_OBJECT_CREATE for MSAA. For more info see comments
                                                                     ; within winuser.h.
                                                                     ; Una finestra che ospita altri oggetti accessibili ha
                                                                     ; modificato gli oggetti ospitati. Un client potrebbe dover
                                                                     ; eseguire una query sulla finestra host per individuare i
                                                                     ; nuovi oggetti ospitati, soprattutto se il client ha eseguito
                                                                     ; il monitoraggio degli eventi dalla finestra. Un oggetto
                                                                     ; ospitato è un oggetto di un framework di accessibilità (MSAA
                                                                     ; o Automazione interfaccia utente) diverso da quello
                                                                     ; dell'host. Le modifiche apportate agli oggetti ospitati
                                                                     ; provenienti dallo stesso framework dell'host devono essere
                                                                     ; consegnate con gli eventi di modifica strutturale, ad esempio
                                                                     ; EVENT_OBJECT_CREATE per MSAA. Per altre informazioni, vedere
                                                                     ; commenti all'interno di winuser.h.
       , EVENT_OBJECT_IME_HIDE                         := 0x8028     ; An IME window has become hidden.
                                                                     ; Una finestra IME è diventata nascosta.
       , EVENT_OBJECT_IME_SHOW                         := 0x8027     ; An IME window has become visible.
                                                                     ; Una finestra IME è diventata visibile.
       , EVENT_OBJECT_IME_CHANGE                       := 0x8029     ; The size or position of an IME window has changed.
                                                                     ; Le dimensioni o la posizione di una finestra IME sono state
                                                                     ; modificate.
       , EVENT_OBJECT_INVOKED                          := 0x8013     ; An object has been invoked; for example, the user has clicked
                                                                     ; a button. This event is supported by common controls and is
                                                                     ; used by UI Automation.
                                                                     ; For this event, the hwnd, ID, and idChild parameters of the
                                                                     ; WinEventProc callback function identify the item that is
                                                                     ; invoked.
                                                                     ; È stato richiamato un oggetto; ad esempio, l'utente ha fatto
                                                                     ; clic su un pulsante. Questo evento è supportato dai controlli
                                                                     ; comuni e viene usato da Automazione interfaccia utente.
                                                                     ; Per questo evento, i parametri hwnd, ID e idChild della
                                                                     ; funzione di callback WinEventProc identificano l'elemento
                                                                     ; richiamato.
       , EVENT_OBJECT_LIVEREGIONCHANGED                := 0x8019     ; An object that is part of a live region has changed. A live
                                                                     ; region is an area of an application that changes frequently
                                                                     ; and/or asynchronously.
                                                                     ; Un oggetto che fa parte di un'area dinamica è cambiato.
                                                                     ; Un'area live è un'area di un'applicazione che cambia spesso
                                                                     ; e/o in modo asincrono.
       , EVENT_OBJECT_LOCATIONCHANGE                   := 0x800B     ; An object has changed location, shape, or size. The system
                                                                     ; sends this event for the following user interface elements:
                                                                     ; caret and window objects. Server applications send this event
                                                                     ; for their accessible objects.
                                                                     ; This event is generated in response to a change in the
                                                                     ; top-level object within the object hierarchy; it is not
                                                                     ; generated for any children that the object might have. For
                                                                     ; example, if the user resizes a window, the system sends this
                                                                     ; notification for the window, but not for the menu bar, title
                                                                     ; bar, scroll bar, or other objects that have also changed.
                                                                     ; The system does not send this event for every non-floating
                                                                     ; child window when the parent moves. However, if an
                                                                     ; application explicitly resizes child windows as a result of
                                                                     ; resizing the parent window, the system sends multiple events
                                                                     ; for the resized children.
                                                                     ; If an object's State property is set to
                                                                     ; STATE_SYSTEM_FLOATING, the server sends
                                                                     ; EVENT_OBJECT_LOCATIONCHANGE whenever the object changes
                                                                     ; location. If an object does not have this state, servers only
                                                                     ; trigger this event when the object moves in relation to its
                                                                     ; parent. For this event notification, the idChild parameter of
                                                                     ; the WinEventProc callback function identifies the child
                                                                     ; object that has changed.
                                                                     ; È stata modificata la posizione, la forma o la dimensione di
                                                                     ; un oggetto. Il sistema invia questo evento per gli elementi
                                                                     ; dell'interfaccia utente seguenti: oggetti caret e window.
                                                                     ; L'evento viene inviato dalle applicazioni server per i
                                                                     ; relativi oggetti accessibili.
                                                                     ; Questo evento viene generato in risposta a una modifica
                                                                     ; nell'oggetto di primo livello all'interno della gerarchia di
                                                                     ; oggetti; non viene generato per alcun elemento figlio che
                                                                     ; l'oggetto potrebbe avere. Ad esempio, se l'utente
                                                                     ; ridimensiona una finestra, il sistema invia questa notifica
                                                                     ; per la finestra, ma non per la barra dei menu, la barra del
                                                                     ; titolo, la barra di scorrimento o altri oggetti che sono
                                                                     ; stati modificati.
                                                                     ; Quando si sposta l'oggetto padre, il sistema non invia questo
                                                                     ; evento per ogni finestra figlio fissa. Tuttavia, se
                                                                     ; un'applicazione ridimensiona in modo esplicito le finestre
                                                                     ; figlio a causa del ridimensionamento della finestra padre, il
                                                                     ; sistema invia più eventi per gli elementi figlio
                                                                     ; ridimensionati.
                                                                     ; Se la proprietà State di un oggetto è impostata su
                                                                     ; STATE_SYSTEM_FLOATING, il server invia
                                                                     ; EVENT_OBJECT_LOCATIONCHANGE ogni volta che l'oggetto cambia
                                                                     ; posizione. Se un oggetto non dispone di questo stato, i
                                                                     ; server attivano questo evento solo quando l'oggetto viene
                                                                     ; spostato in relazione al relativo padre. Per questa notifica
                                                                     ; evento, il parametro idChild della funzione di callback
                                                                     ; WinEventProc identifica l'oggetto figlio modificato.
       , EVENT_OBJECT_NAMECHANGE                       := 0x800C     ; An object's Name property has changed. The system sends this
                                                                     ; event for the following user interface elements: check box,
                                                                     ; cursor, list-view control, push button, radio button, status
                                                                     ; bar control, tree view control, and window object. Server
                                                                     ; applications send this event for their accessible objects.
                                                                     ; La proprietà Name di un oggetto è stata modificata. Il
                                                                     ; sistema invia questo evento per gli elementi dell'interfaccia
                                                                     ; utente seguenti: casella di controllo, cursore, controllo
                                                                     ; visualizzazione elenco, pulsante di scelta, pulsante di
                                                                     ; opzione, controllo barra di stato, controllo visualizzazione
                                                                     ; albero e oggetto finestra. L'evento viene inviato dalle
                                                                     ; applicazioni server per i relativi oggetti accessibili.
       , EVENT_OBJECT_PARENTCHANGE                     := 0x800F     ; An object has a new parent object. Server applications send
                                                                     ; this event for their accessible objects.
                                                                     ; Un oggetto ha un nuovo elemento padre. L'evento viene inviato
                                                                     ; dalle applicazioni server per i relativi oggetti accessibili.
       , EVENT_OBJECT_REORDER                          := 0x8004     ; A container object has added, removed, or reordered its
                                                                     ; children. The system sends this event for the following user
                                                                     ; interface elements: header control, list-view control,
                                                                     ; toolbar control, and window object. Server applications send
                                                                     ; this event as appropriate for their accessible objects.
                                                                     ; For example, this event is generated by a list-view object
                                                                     ; when the number of child elements or the order of the
                                                                     ; elements changes. This event is also sent by a parent window
                                                                     ; when the Z-order for the child windows changes.
                                                                     ; Sono stati aggiunti o rimossi gli oggetti figlio di un
                                                                     ; oggetto contenitore oppure ne è stato modificato l'ordine. Il
                                                                     ; sistema invia questo evento per gli elementi dell'interfaccia
                                                                     ; utente seguenti: controllo intestazione, controllo
                                                                     ; visualizzazione elenco, controllo della barra degli strumenti
                                                                     ; e oggetto finestra. Le applicazioni server trasmettono questo
                                                                     ; evento per i relativi oggetti accessibili, quando necessario.
                                                                     ; Ad esempio, questo evento viene generato da un oggetto di
                                                                     ; visualizzazione elenco quando il numero di elementi figlio o
                                                                     ; l'ordine degli elementi cambia. Questo evento viene inviato
                                                                     ; anche da una finestra padre quando cambia l'ordine Z per le
                                                                     ; finestre figlio.
       , EVENT_OBJECT_SELECTION                        := 0x8006     ; The selection within a container object has changed. The
                                                                     ; system sends this event for the following user interface
                                                                     ; elements: list-view control, tab control, tree view control,
                                                                     ; and window object. Server applications send this event for
                                                                     ; their accessible objects.
                                                                     ; This event signals a single selection: either a child is
                                                                     ; selected in a container that previously did not contain any
                                                                     ; selected children, or the selection has changed from one
                                                                     ; child to another.
                                                                     ; The hwnd and idObject parameters of the WinEventProc callback
                                                                     ; function describe the container; the idChild parameter
                                                                     ; identifies the object that is selected. If the selected child
                                                                     ; is a window that also contains objects, the idChild parameter
                                                                     ; is OBJID_WINDOW.
                                                                     ; La selezione in un oggetto contenitore ha subito modifiche.
                                                                     ; Il sistema invia questo evento per gli elementi
                                                                     ; dell'interfaccia utente seguenti: controllo elenco, controllo
                                                                     ; tabulazioni, controllo visualizzazione albero e oggetto
                                                                     ; finestra. L'evento viene inviato dalle applicazioni server
                                                                     ; per i relativi oggetti accessibili.
                                                                     ; Questo evento segnala una singola selezione: un elemento
                                                                     ; figlio è selezionato in un contenitore che in precedenza non
                                                                     ; contiene elementi figlio selezionati o la selezione è
                                                                     ; cambiata da un elemento figlio a un altro.
                                                                     ; I parametri hwnd e idObject della funzione di callback
                                                                     ; WinEventProc descrivono il contenitore; il parametro idChild
                                                                     ; identifica l'oggetto selezionato. Se l'elemento figlio
                                                                     ; selezionato è una finestra contenente anche oggetti, il
                                                                     ; parametro idChild è OBJID_WINDOW.
       , EVENT_OBJECT_SELECTIONADD                     := 0x8007     ; A child within a container object has been added to an
                                                                     ; existing selection. The system sends this event for the
                                                                     ; following user interface elements: list box, list-view
                                                                     ; control, and tree view control. Server applications send this
                                                                     ; event for their accessible objects.
                                                                     ; The hwnd and idObject parameters of the WinEventProc callback
                                                                     ; function describe the container. The idChild parameter is the
                                                                     ; child that is added to the selection.
                                                                     ; Un elemento figlio all'interno di un oggetto contenitore è
                                                                     ; stato aggiunto a una selezione esistente. Il sistema invia
                                                                     ; questo evento per gli elementi dell'interfaccia utente
                                                                     ; seguenti: casella di riepilogo, controllo visualizzazione
                                                                     ; elenco e controllo visualizzazione albero. L'evento viene
                                                                     ; inviato dalle applicazioni server per i relativi oggetti
                                                                     ; accessibili.
                                                                     ; I parametri hwnd e idObject della funzione di callback
                                                                     ; WinEventProc descrivono il contenitore. Il parametro idChild
                                                                     ; è il figlio aggiunto alla selezione.
       , EVENT_OBJECT_SELECTIONREMOVE                  := 0x8008     ; An item within a container object has been removed from the
                                                                     ; selection. The system sends this event for the following user
                                                                     ; interface elements: list box, list-view control, and tree
                                                                     ; view control. Server applications send this event for their
                                                                     ; accessible objects.
                                                                     ; This event signals that a child is removed from an existing
                                                                     ; selection.
                                                                     ; The hwnd and idObject parameters of the WinEventProc callback
                                                                     ; function describe the container; the idChild parameter
                                                                     ; identifies the child that has been removed from the
                                                                     ; selection.
                                                                     ; È stato rimosso dalla selezione un elemento all'interno di un
                                                                     ; oggetto contenitore. Il sistema invia questo evento per gli
                                                                     ; elementi dell'interfaccia utente seguenti: casella di
                                                                     ; riepilogo, controllo visualizzazione elenco e controllo
                                                                     ; visualizzazione albero. L'evento viene inviato dalle
                                                                     ; applicazioni server per i relativi oggetti accessibili.
                                                                     ; Questo evento segnala che un elemento figlio viene rimosso da
                                                                     ; una selezione esistente.
                                                                     ; I parametri hwnd e idObject della funzione di callback
                                                                     ; WinEventProc descrivono il contenitore; il parametro idChild
                                                                     ; identifica il figlio rimosso dalla selezione.
       , EVENT_OBJECT_SELECTIONWITHIN                  := 0x8009     ; Numerous selection changes have occurred within a container
                                                                     ; object. The system sends this event for list boxes; server
                                                                     ; applications send it for their accessible objects.
                                                                     ; This event is sent when the selected items within a control
                                                                     ; have changed substantially. The event informs the client that
                                                                     ; many selection changes have occurred, and it is sent instead
                                                                     ; of several EVENT_OBJECT_SELECTIONADD or
                                                                     ; EVENT_OBJECT_SELECTIONREMOVE events. The client queries for
                                                                     ; the selected items by calling the container object's
                                                                     ; IAccessible::get_accSelection method and enumerating the
                                                                     ; selected items.
                                                                     ; For this event notification, the hwnd and idObject parameters
                                                                     ; of the WinEventProc callback function describe the container
                                                                     ; in which the changes occurred.
                                                                     ; La selezione degli oggetti all'interno di un oggetto
                                                                     ; contenitore è stata modificata più volte. Il sistema invia
                                                                     ; questo evento per le caselle di riepilogo; le applicazioni
                                                                     ; server lo inviano per gli oggetti accessibili.
                                                                     ; Questo evento viene inviato quando gli elementi selezionati
                                                                     ; all'interno di un controllo sono stati modificati in modo
                                                                     ; significativo. L'evento informa il client che si sono
                                                                     ; verificate molte modifiche di selezione e viene inviato
                                                                     ; anziché diversi eventi EVENT_OBJECT_SELECTIONADD o
                                                                     ; EVENT_OBJECT_SELECTIONREMOVE. Il client esegue query per gli
                                                                     ; elementi selezionati chiamando il metodo
                                                                     ; IAccess::get_accSelection dell'oggetto contenitore ed
                                                                     ; enumerando gli elementi selezionati.
                                                                     ; Per questa notifica evento, i parametri hwnd e idObject della
                                                                     ; funzione di callback WinEventProc descrivono il contenitore
                                                                     ; in cui si sono verificate le modifiche.
       , EVENT_OBJECT_SHOW                             := 0x8002     ; A hidden object is shown. The system sends this event for the
                                                                     ; following user interface elements: caret, cursor, and window
                                                                     ; object. Server applications send this event for their
                                                                     ; accessible objects.
                                                                     ; Clients assume that when this event is sent by a parent
                                                                     ; object, all child objects are already displayed. Therefore,
                                                                     ; server applications do not send this event for the child
                                                                     ; objects.
                                                                     ; Hidden objects include the STATE_SYSTEM_INVISIBLE flag; shown
                                                                     ; objects do not include this flag. The EVENT_OBJECT_SHOW event
                                                                     ; also indicates that the STATE_SYSTEM_INVISIBLE flag is
                                                                     ; cleared. Therefore, servers do not send the
                                                                     ; EVENT_STATE_CHANGE event in this case.
                                                                     ; Viene visualizzato un oggetto nascosto. Questo evento viene
                                                                     ; inviato dal sistema per i seguenti elementi dell'interfaccia
                                                                     ; utente: punto di inserimento, cursore e oggetto finestra.
                                                                     ; L'evento viene inviato dalle applicazioni server per i
                                                                     ; relativi oggetti accessibili.
                                                                     ; I client presuppongono che quando questo evento viene inviato
                                                                     ; da un oggetto padre, tutti gli oggetti figlio sono già
                                                                     ; visualizzati. Pertanto, le applicazioni server non inviano
                                                                     ; questo evento per gli oggetti figlio.
                                                                     ; Gli oggetti nascosti includono il flag di
                                                                     ; STATE_SYSTEM_INVISIBLE ; gli oggetti visualizzati non
                                                                     ; includono questo flag. L'evento EVENT_OBJECT_SHOW indica
                                                                     ; anche che il flag di STATE_SYSTEM_INVISIBLE viene cancellato.
                                                                     ; Pertanto, i server non inviano l'evento EVENT_STATE_CHANGE in
                                                                     ; questo caso.
       , EVENT_OBJECT_STATECHANGE                      := 0x800A     ; An object's state has changed. The system sends this event
                                                                     ; for the following user interface elements: check box, combo
                                                                     ; box, header control, push button, radio button, scroll bar,
                                                                     ; toolbar control, tree view control, up-down control, and
                                                                     ; window object. Server applications send this event for their
                                                                     ; accessible objects.
                                                                     ; For example, a state change occurs when a button object is
                                                                     ; clicked or released, or when an object is enabled or
                                                                     ; disabled.
                                                                     ; For this event notification, the idChild parameter of the
                                                                     ; WinEventProc callback function identifies the child object
                                                                     ; whose state has changed.
                                                                     ; È stato modificato lo stato di un oggetto. Il sistema invia
                                                                     ; questo evento per gli elementi dell'interfaccia utente
                                                                     ; seguenti: casella di controllo, casella combinata, controllo
                                                                     ; intestazione, pulsante di scelta rapida, pulsante di opzione,
                                                                     ; barra di scorrimento, controllo barra degli strumenti,
                                                                     ; controllo visualizzazione albero, controllo di scorrimento e
                                                                     ; oggetto finestra. L'evento viene inviato dalle applicazioni
                                                                     ; server per i relativi oggetti accessibili.
                                                                     ; Ad esempio, una modifica dello stato si verifica quando si fa
                                                                     ; clic o si rilascia un oggetto pulsante oppure quando un
                                                                     ; oggetto è abilitato o disabilitato.
                                                                     ; Per questa notifica di evento, il parametro idChild della
                                                                     ; funzione di callback WinEventProc identifica l'oggetto figlio
                                                                     ; il cui stato è stato modificato.
       , EVENT_OBJECT_TEXTEDIT_CONVERSIONTARGETCHANGED := 0x8030     ; The conversion target within an IME composition has changed.
                                                                     ; The conversion target is the subset of the IME composition
                                                                     ; which is actively selected as the target for user-initiated
                                                                     ; conversions.
                                                                     ; La destinazione di conversione all'interno di una
                                                                     ; composizione IME è cambiata. La destinazione di conversione è
                                                                     ; il subset della composizione IME selezionata attivamente come
                                                                     ; destinazione per le conversioni avviate dall'utente.
       , EVENT_OBJECT_TEXTSELECTIONCHANGED             := 0x8014     ; An object's text selection has changed. This event is
                                                                     ; supported by common controls and is used by UI Automation.
                                                                     ; The hwnd, ID, and idChild parameters of the WinEventProc
                                                                     ; callback function describe the item that is contained in the
                                                                     ; updated text selection.
                                                                     ; La selezione del testo di un oggetto è cambiata. Questo
                                                                     ; evento è supportato dai controlli comuni e viene usato da
                                                                     ; Automazione interfaccia utente.
                                                                     ; I parametri hwnd, ID e idChild della funzione di callback
                                                                     ; WinEventProc descrivono l'elemento contenuto nella selezione
                                                                     ; di testo aggiornata.
       , EVENT_OBJECT_UNCLOAKED                        := 0x8018     ; Sent when a window is uncloaked. A cloaked window still
                                                                     ; exists, but is invisible to the user.
                                                                     ; Inviato quando una finestra non è chiusa. Esiste ancora una
                                                                     ; finestra mascherata, ma è invisibile all'utente.
       , EVENT_OBJECT_VALUECHANGE                      := 0x800E     ; An object's Value property has changed. The system sends this
                                                                     ; event for the user interface elements that include the scroll
                                                                     ; bar and the following controls: edit, header, hot key,
                                                                     ; progress bar, slider, and up-down. Server applications send
                                                                     ; this event for their accessible objects.
                                                                     ; La proprietà Value di un oggetto è stata modificata. Il
                                                                     ; sistema invia questo evento per gli elementi dell'interfaccia
                                                                     ; utente che includono la barra di scorrimento e i controlli
                                                                     ; seguenti: modifica, intestazione, tasto di scelta rapida,
                                                                     ; barra di stato, dispositivo di scorrimento e giù. L'evento
                                                                     ; viene inviato dalle applicazioni server per i relativi
                                                                     ; oggetti accessibili.
       , EVENT_SYSTEM_ALERT                            := 0x0002     ; An alert has been generated. Server applications should not
                                                                     ; send this event.
                                                                     ; È stato generato un avviso. Le applicazioni server non devono
                                                                     ; inviare questo evento.
       , EVENT_SYSTEM_ARRANGMENTPREVIEW                := 0x8016     ; A preview rectangle is being displayed.
                                                                     ; Viene visualizzato un rettangolo di anteprima.
       , EVENT_SYSTEM_CAPTUREEND                       := 0x0009     ; A window has lost mouse capture. This event is sent by the
                                                                     ; system, never by servers.
                                                                     ; Una finestra ha perso il mouse capture. Questo evento viene
                                                                     ; inviato dal sistema, mai dai server.
       , EVENT_SYSTEM_CAPTURESTART                     := 0x0008     ; A window has received mouse capture. This event is sent by
                                                                     ; the system, never by servers.
                                                                     ; Una finestra ha ricevuto l'acquisizione del mouse. Questo
                                                                     ; evento viene inviato dal sistema, mai dai server.
       , EVENT_SYSTEM_CONTEXTHELPEND                   := 0x000D     ; A window has exited context-sensitive Help mode. This event
                                                                     ; is not sent consistently by the system.
                                                                     ; Una finestra ha chiuso la modalità Guida sensibile al
                                                                     ; contesto. Questo evento non viene inviato in modo coerente
                                                                     ; dal sistema.
       , EVENT_SYSTEM_CONTEXTHELPSTART                 := 0x000C     ; A window has entered context-sensitive Help mode. This event
                                                                     ; is not sent consistently by the system.
                                                                     ; Una finestra ha attivato la modalità Guida sensibile al
                                                                     ; contesto. Questo evento non viene inviato in modo coerente
                                                                     ; dal sistema.
       , EVENT_SYSTEM_DESKTOPSWITCH                    := 0x0020     ; The active desktop has been switched.
                                                                     ; Il desktop attivo è stato cambiato.
       , EVENT_SYSTEM_DIALOGEND                        := 0x0011     ; A dialog box has been closed. The system sends this event for
                                                                     ; standard dialog boxes; servers send it for custom dialog
                                                                     ; boxes. This event is not sent consistently by the system.
                                                                     ; Una finestra di dialogo è stata chiusa. Il sistema invia
                                                                     ; questo evento per le finestre di dialogo standard; i server
                                                                     ; lo inviano per le finestre di dialogo personalizzate. Questo
                                                                     ; evento non viene inviato in modo coerente dal sistema.
       , EVENT_SYSTEM_DIALOGSTART                      := 0x0010     ; A dialog box has been displayed. The system sends this event
                                                                     ; for standard dialog boxes, which are created using resource
                                                                     ; templates or Win32 dialog box functions. Servers send this
                                                                     ; event for custom dialog boxes, which are windows that
                                                                     ; function as dialog boxes but are not created in the standard
                                                                     ; way.
                                                                     ; This event is not sent consistently by the system.
                                                                     ; È stata visualizzata una finestra di dialogo. Il sistema
                                                                     ; invia questo evento per le finestre di dialogo standard,
                                                                     ; create usando modelli di risorse o funzioni della finestra di
                                                                     ; dialogo Win32. I server inviano questo evento per finestre di
                                                                     ; dialogo personalizzate, ovvero finestre che funzionano come
                                                                     ; finestre di dialogo ma non vengono create nel modo standard.
                                                                     ; Questo evento non viene inviato in modo coerente dal sistema.
       , EVENT_SYSTEM_DRAGDROPEND                      := 0x000F     ; An application is about to exit drag-and-drop mode.
                                                                     ; Applications that support drag-and-drop operations must send
                                                                     ; this event; the system does not send this event.
                                                                     ; La modalità di trascinamento sta per essere disattivata in
                                                                     ; un'applicazione. Le applicazioni che supportano operazioni di
                                                                     ; trascinamento della selezione devono inviare questo evento;
                                                                     ; il sistema non invia questo evento.
       , EVENT_SYSTEM_DRAGDROPSTART                    := 0x000E     ; An application is about to enter drag-and-drop mode.
                                                                     ; Applications that support drag-and-drop operations must send
                                                                     ; this event because the system does not send it.
                                                                     ; La modalità di trascinamento sta per essere attivata in
                                                                     ; un'applicazione. Le applicazioni che supportano operazioni di
                                                                     ; trascinamento della selezione devono inviare questo evento
                                                                     ; perché il sistema non lo invia.
       , EVENT_SYSTEM_END                              := 0x00FF     ; The highest system event value.
                                                                     ; Valore dell'evento di sistema più alto.
       , EVENT_SYSTEM_FOREGROUND                       := 0x0003     ; The foreground window has changed. The system sends this
                                                                     ; event even if the foreground window has changed to another
                                                                     ; window in the same thread. Server applications never send
                                                                     ; this event.
                                                                     ; For this event, the WinEventProc callback function's hwnd
                                                                     ; parameter is the handle to the window that is in the
                                                                     ; foreground, the idObject parameter is OBJID_WINDOW, and the
                                                                     ; idChild parameter is CHILDID_SELF.
                                                                     ; La finestra in primo piano è stata modificata. Il sistema
                                                                     ; invia questo evento anche se la finestra in primo piano è
                                                                     ; stata modificata in un'altra finestra nello stesso thread.
                                                                     ; Questo evento non viene mai inviato dalle applicazioni
                                                                     ; server.
                                                                     ; Per questo evento, il parametro hwnd della funzione di
                                                                     ; callback WinEventProc è l'handle della finestra in primo
                                                                     ; piano, il parametro idObject è OBJID_WINDOW e il parametro
                                                                     ; idChild è CHILDID_SELF.
       , EVENT_SYSTEM_MENUPOPUPEND                     := 0x0007     ; A pop-up menu has been closed. The system sends this event
                                                                     ; for standard menus; servers send it for custom menus.
                                                                     ; When a pop-up menu is closed, the client receives this
                                                                     ; message, and then the EVENT_SYSTEM_MENUEND event.
                                                                     ; This event is not sent consistently by the system.
                                                                     ; È stato chiuso un menu a comparsa. Il sistema invia questo
                                                                     ; evento per i menu standard; i server lo inviano per i menu
                                                                     ; personalizzati.
                                                                     ; Quando un menu a comparsa viene chiuso, il client riceve
                                                                     ; questo messaggio e quindi l'evento EVENT_SYSTEM_MENUEND .
                                                                     ; Questo evento non viene inviato in modo coerente dal sistema.
       , EVENT_SYSTEM_MENUPOPUPSTART                   := 0x0006     ; A pop-up menu has been displayed. The system sends this event
                                                                     ; for standard menus, which are identified by HMENU, and are
                                                                     ; created using menu-template resources or Win32 menu
                                                                     ; functions. Servers send this event for custom menus, which
                                                                     ; are user interface elements that function as menus but are
                                                                     ; not created in the standard way. This event is not sent
                                                                     ; consistently by the system.
                                                                     ; È stato visualizzato un menu a comparsa. Il sistema invia
                                                                     ; questo evento per i menu standard, identificati da HMENU, e
                                                                     ; vengono creati usando le risorse del modello di menu o le
                                                                     ; funzioni di menu Win32. I server inviano questo evento per i
                                                                     ; menu personalizzati, che sono elementi dell'interfaccia
                                                                     ; utente che funzionano come menu ma non vengono creati nel
                                                                     ; modo standard. Questo evento non viene inviato in modo
                                                                     ; coerente dal sistema.
       , EVENT_SYSTEM_MENUEND                          := 0x0005     ; A menu from the menu bar has been closed. The system sends
                                                                     ; this event for standard menus; servers send it for custom
                                                                     ; menus.
                                                                     ; For this event, the WinEventProc callback function's hwnd,
                                                                     ; idObject, and idChild parameters refer to the control that
                                                                     ; contains the menu bar or the control that activates the
                                                                     ; context menu. The hwnd parameter is the handle to the window
                                                                     ; that is related to the event. The idObject parameter is
                                                                     ; OBJID_MENU or OBJID_SYSMENU for a menu, or OBJID_WINDOW for a
                                                                     ; pop-up menu. The idChild parameter is CHILDID_SELF.
                                                                     ; È stato chiuso un menu dalla barra dei menu. Il sistema invia
                                                                     ; questo evento per i menu standard; i server lo inviano per i
                                                                     ; menu personalizzati.
                                                                     ; Per questo evento, i parametri hwnd, idObject e idChild della
                                                                     ; funzione di callback WinEventProc fanno riferimento al
                                                                     ; controllo che contiene la barra dei menu o il controllo che
                                                                     ; attiva il menu di scelta rapida. Il parametro hwnd è l'handle
                                                                     ; della finestra correlata all'evento. Il parametro idObject è
                                                                     ; OBJID_MENU o OBJID_SYSMENU per un menu o OBJID_WINDOW per un
                                                                     ; menu a comparsa. Il parametro idChild è CHILDID_SELF.
       , EVENT_SYSTEM_MENUSTART                        := 0x0004     ; A menu item on the menu bar has been selected. The system
                                                                     ; sends this event for standard menus, which are identified by
                                                                     ; HMENU, created using menu-template resources or Win32 menu
                                                                     ; API elements. Servers send this event for custom menus, which
                                                                     ; are user interface elements that function as menus but are
                                                                     ; not created in the standard way.
                                                                     ; For this event, the WinEventProc callback function's hwnd,
                                                                     ; idObject, and idChild parameters refer to the control that
                                                                     ; contains the menu bar or the control that activates the
                                                                     ; context menu. The hwnd parameter is the handle to the window
                                                                     ; related to the event. The idObject parameter is OBJID_MENU or
                                                                     ; OBJID_SYSMENU for a menu, or OBJID_WINDOW for a pop-up menu.
                                                                     ; The idChild parameter is CHILDID_SELF.
                                                                     ; The system triggers more than one EVENT_SYSTEM_MENUSTART
                                                                     ; event that does not always correspond with the
                                                                     ; EVENT_SYSTEM_MENUEND event.
                                                                     ; È stata selezionata una voce di menu sulla barra dei menu.
                                                                     ; Il sistema invia questo evento per i menu standard,
                                                                     ; identificati da HMENU, creati usando le risorse del modello
                                                                     ; di menu o gli elementi DELL'API del menu Win32. I server
                                                                     ; inviano questo evento per i menu personalizzati, che sono
                                                                     ; elementi dell'interfaccia utente che funzionano come menu, ma
                                                                     ; non vengono creati nel modo standard.
                                                                     ; Per questo evento, i parametri di callback di WinEventProc,
                                                                     ; idObject e idChild fanno riferimento al controllo che
                                                                     ; contiene la barra dei menu o il controllo che attiva il menu
                                                                     ; di scelta rapida. Il parametro hwnd è l'handle della finestra
                                                                     ; correlata all'evento. Il parametro idObject è OBJID_MENU o
                                                                     ; OBJID_SYSMENUper un menu o OBJID_WINDOW per un menu a
                                                                     ; comparsa. Il parametro idChild è CHILDID_SELF.
                                                                     ; Il sistema attiva più di un evento EVENT_SYSTEM_MENUSTART che
                                                                     ; non corrisponde sempre all'evento EVENT_SYSTEM_MENUEND .
       , EVENT_SYSTEM_MINIMIZEEND                      := 0x0017     ; A window object is about to be restored. This event is sent
                                                                     ; by the system, never by servers.
                                                                     ; Un oggetto finestra sta per essere ripristinato. Questo
                                                                     ; evento viene inviato dal sistema, mai dai server.
       , EVENT_SYSTEM_MINIMIZESTART                    := 0x0016     ; A window object is about to be minimized. This event is sent
                                                                     ; by the system, never by servers.
                                                                     ; Un oggetto finestra sta per essere ridotto al minimo. Questo
                                                                     ; evento viene inviato dal sistema, mai dai server.
       , EVENT_SYSTEM_MOVESIZEEND                      := 0x000B     ; The movement or resizing of a window has finished. This event
                                                                     ; is sent by the system, never by servers.
                                                                     ; Lo spostamento o il ridimensionamento di una finestra è
                                                                     ; terminato. Questo evento viene inviato dal sistema, mai dai
                                                                     ; server.
       , EVENT_SYSTEM_MOVESIZESTART                    := 0x000A     ; A window is being moved or resized. This event is sent by the
                                                                     ; system, never by servers.
                                                                     ; È in corso lo spostamento o il ridimensionamento di una
                                                                     ; finestra. Questo evento viene inviato dal sistema, mai dai
                                                                     ; server.
       , EVENT_SYSTEM_SCROLLINGEND                     := 0x0013     ; Scrolling has ended on a scroll bar. This event is sent by
                                                                     ; the system for standard scroll bar controls and for scroll
                                                                     ; bars that are attached to a window. Servers send this event
                                                                     ; for custom scroll bars, which are user interface elements
                                                                     ; that function as scroll bars but are not created in the
                                                                     ; standard way.
                                                                     ; The idObject parameter that is sent to the WinEventProc
                                                                     ; callback function is OBJID_HSCROLL for horizontal scroll
                                                                     ; bars, and OBJID_VSCROLL for vertical scroll bars.
                                                                     ; È terminata l'operazione di scorrimento in una barra di
                                                                     ; scorrimento. Questo evento viene inviato dal sistema per i
                                                                     ; controlli barra di scorrimento standard e per le barre di
                                                                     ; scorrimento associate a una finestra. I server inviano questo
                                                                     ; evento per barre di scorrimento personalizzate, che sono
                                                                     ; elementi dell'interfaccia utente che funzionano come barre di
                                                                     ; scorrimento, ma non vengono creati nel modo standard.
                                                                     ; Il parametro idObject inviato alla funzione di callback
                                                                     ; WinEventProc è OBJID_HSCROLL per le barre di scorrimento
                                                                     ; orizzontali e OBJID_VSCROLL per le barre di scorrimento
                                                                     ; verticali.
       , EVENT_SYSTEM_SCROLLINGSTART                   := 0x0012     ; Scrolling has started on a scroll bar. The system sends this
                                                                     ; event for standard scroll bar controls and for scroll bars
                                                                     ; attached to a window. Servers send this event for custom
                                                                     ; scroll bars, which are user interface elements that function
                                                                     ; as scroll bars but are not created in the standard way.
                                                                     ; The idObject parameter that is sent to the WinEventProc
                                                                     ; callback function is OBJID_HSCROLL for horizontal scrolls
                                                                     ; bars, and OBJID_VSCROLL for vertical scroll bars.
                                                                     ; È stata avviata l'operazione di scorrimento in una barra di
                                                                     ; scorrimento. Il sistema invia questo evento per i controlli
                                                                     ; barra di scorrimento standard e per le barre di scorrimento
                                                                     ; associate a una finestra. I server inviano questo evento per
                                                                     ; barre di scorrimento personalizzate, che sono elementi
                                                                     ; dell'interfaccia utente che funzionano come barre di
                                                                     ; scorrimento, ma non vengono creati nel modo standard.
                                                                     ; Il parametro idObject inviato alla funzione di callback
                                                                     ; WinEventProc è OBJID_HSCROLL per le barre di scorrimento
                                                                     ; orizzontali e OBJID_VSCROLL per le barre di scorrimento
                                                                     ; verticale.
       , EVENT_SYSTEM_SOUND                            := 0x0001     ; A sound has been played. The system sends this event when a
                                                                     ; system sound, such as one for a menu, is played even if no
                                                                     ; sound is audible (for example, due to the lack of a sound
                                                                     ; file or a sound card). Servers send this event whenever a
                                                                     ; custom UI element generates a sound.
                                                                     ; For this event, the WinEventProc callback function receives
                                                                     ; the OBJID_SOUND value as the idObject parameter.
                                                                     ; È stato riprodotto un suono. Il sistema invia questo evento
                                                                     ; quando un suono del sistema, ad esempio uno per un menu,
                                                                     ; viene riprodotto anche se nessun suono è udibile (ad esempio,
                                                                     ; a causa della mancanza di un file audio o di una scheda
                                                                     ; audio). I server inviano questo evento ogni volta che un
                                                                     ; elemento dell'interfaccia utente personalizzato genera un
                                                                     ; suono.
                                                                     ; Per questo evento, la funzione callback WinEventProc riceve
                                                                     ; il valore di OBJID_SOUND come parametro idObject .
       , EVENT_SYSTEM_SWITCHEND                        := 0x0015     ; The user has released ALT+TAB. This event is sent by the
                                                                     ; system, never by servers. The hwnd parameter of the
                                                                     ; WinEventProc callback function identifies the window to which
                                                                     ; the user has switched.
                                                                     ; If only one application is running when the user presses
                                                                     ; ALT+TAB, the system sends this event without a corresponding
                                                                     ; EVENT_SYSTEM_SWITCHSTART event.
                                                                     ; L'utente ha rilasciato ALT+TAB. Questo evento viene inviato
                                                                     ; dal sistema, mai dai server. Il parametro hwnd della funzione
                                                                     ; di callback WinEventProc identifica la finestra a cui
                                                                     ; l'utente è cambiato.
                                                                     ; Se viene eseguita una sola applicazione quando l'utente preme
                                                                     ; ALT+TAB, il sistema invia questo evento senza un evento di
                                                                     ; EVENT_SYSTEM_SWITCHSTART corrispondente.
       , EVENT_SYSTEM_SWITCHSTART                      := 0x0014     ; The user has pressed ALT+TAB, which activates the switch
                                                                     ; window. This event is sent by the system, never by servers.
                                                                     ; The hwnd parameter of the WinEventProc callback function
                                                                     ; identifies the window to which the user is switching.
                                                                     ; If only one application is running when the user presses
                                                                     ; ALT+TAB, the system sends an EVENT_SYSTEM_SWITCHEND event
                                                                     ; without a corresponding EVENT_SYSTEM_SWITCHSTART event.
                                                                     ; L'utente ha premuto ALT+TAB, che attiva la finestra del
                                                                     ; commutatore. Questo evento viene inviato dal sistema, mai dai
                                                                     ; server. Il parametro hwnd della funzione di callback
                                                                     ; WinEventProc identifica la finestra a cui l'utente sta
                                                                     ; passando.
                                                                     ; Se viene eseguita solo un'applicazione quando l'utente preme
                                                                     ; ALT+TAB, il sistema invia un evento EVENT_SYSTEM_SWITCHEND
                                                                     ; senza un evento EVENT_SYSTEM_SWITCHSTART corrispondente.

/*
|==================================================================================================================================|
|                                                                                                                                  |
| EVENT HOOK RECORD                                                                                                                |
|                                                                                                                                  |
|==================================================================================================================================|
|                                                                                                                                  |
| Rev. 2.0                                                                                                                         |
|                                                                                                                                  |
| This function sets another UDF function like asynchronous for automatically call that when a system event generates.             |
| Is possible to define one event or many events.                                                                                  |
| The UDF function defined begins to be asychronous: that will be called everytime that event is generated; to stop that           |
| automatical call, use the UnHookEvent( ... ) function.                                                                           |
| The events that can be identified are all those defined by the constants EVENT_... previous defined.                             |
| This function has an internal Associative Array about all the Event Hook generated: that Associative Array will be updated evey  |
| function call to generate other Event Hooks or every UnHook( ... ) call to delete some Event Hook.                               |
| Event Hook Associative Array structure; the value is a string like a Record with 3 Fields with Separatore " ":                   |
| Key        Value                                                                                                                 |
| EventHook: sFunctionName iEvent iPID                                                                                             |
| EventHook             : is one of the generated and working Event Hook;                                                          |
| sFunctionName         : Field 1 - Function name of the automatical call Function associated to the Event Hook; is the same       |
|                         defined in the sFunctionName argument;                                                                   |
| iEvent                : Field 2 - Event Code associated to the Event Hook, that define the automatical call to the Function      |
|                         defined in the Field 1; is one of the Event defined in the Event Array, the aiEvents Argument;           |
| iPID                  : Field 3 - PID of the process which to Event control; is one of the PID defined in the PID array, the     |
|                         aiPIDs Argument.                                                                                         |
| This Function returns the Event Hook associative Array at the end of the all Event Hook generation required, IF NO ONE GENERATES |
| ANY ERROR.                                                                                                                       |
| If one of the Event Hook building generate error:                                                                                |
| - the Event Hook generation immediately stops;                                                                                   |
| - all the before generated Event Hooks are OK;                                                                                   |
| - the internal Event Hook Associative Array is exactly updated;                                                                  |
| - the Function returns a string like a Record with 2 Fields, Separator " ":                                                      |
|   iEvent iPID                                                                                                                    |
|   iEvent              : Event Code of the Event Hook that generates error;                                                       |
|   iPID                : PID of the Event Hook that generates error;                                                              |
|   ( the function name associated is certainly what defined by sFunctionName argument );                                          |
| - it is possible to require the actual Event Hook Associative Array by the call:                                                 |
|   HookEvent( "", "", "" )                                                                                                        |
| It is possible to use the IsOject( ... ) function to identify the output like an Array or no ( in that case it is the Error      |
| Record string ).                                                                                                                 |
|                                                                                                                                  |
| Questa Funzione imposta un'altra funzione UDF come asincrona in modo che venga chiamata automaticamente quando si genera un      |
| evento di sistema.                                                                                                               |
| La funzione UDF viene definita come asincrona: verrà quindi chiamata ogni volta che viene generato quell'evento; per terminare   |
| questo automatismo utilizzare la funzione UnHookEvent( ... ).                                                                    |
| Gli eventi che possono essere identificati sono tutti quelli definiti dalle costanti il cui nome inizia con EVENT_... definite   |
| sopra.                                                                                                                           |
| Questa Funzione gestisce un Array associativo interno relativo a tutti gli Event Hook generati: tale Array associativo viene     |
| aggiornato ad ogni chiamata di questa Funzione per generare altri Event Hook, oppure ad ogni chiamata della Funzione             |
| UnHook( ... ) per eliminare Event Hooks precedentemente generati.                                                                |
| Struttura dell'Array associativo degli Event Hook; il valore è una stringa che funge da Record con 3 Campi con Separatore " ":   |
| Key        Value                                                                                                                 |
| EventHook: sFunctionName iEvent iPID                                                                                             |
| EventHook             : Uno degli Event Hook generato e funzionante;                                                             |
| sFunctionName         : Campo 1 - Nome della Funzione che verrà chiamata automaticamente, associata all'Event Hook; è lo stesso  |
|                         valore definito nell'argomento sFunctionName;                                                            |
| iEvent                : Campo 2 - Codice Evento associato all'Event Hook, che definisce la chiamata automatica alla Funzione     |
|                         definita nel Campo 1; è uno degli Eventi definiti nell'Array degli Eventi, argomento aiEvents;           |
| iPID                  : Campo 3 - PID del processo di cui si devono controllare gli Eventi; è uno dei PID specificati nell'Array |
|                         dei PID, argomento aiPIDs.                                                                               |
| Questa Funzione ritorna l'Array associativo Event Hook alla fine della generazione di tutti gli Event Hook richiesti, SE NESSUNO |
| DI QUESTI HA GENERATO ERRORE.                                                                                                    |
| Se la costruzione di un Event Hook ha generato errore:                                                                           |
| - la generazione degli Event Hook si ferma immediatamente;                                                                       |
| - tutti gli Event Hook generati prima sono validi;                                                                               |
| - l'Array associativo degli Event Hook interno è correttamente aggiornato;                                                       |
| - la Funzione ritorna una stringa come un Record composto da 2 Campi con Separatore " ":                                         |
|   iEvent iPID                                                                                                                    |
|   iEvent              : Event Code dell'Event Hook che ha generato errore;                                                       |
|   iPID                : PID dell'Event Hook che ha generato errore;                                                              |
|   ( il nome di funzione associato è sicuramente quello definito nell'argomento sFunctionName );                                  |
| - è sempre possible richiamare l'Array associativo degli Event Hook aggiornato tramite la seguente chiamata:                     |
|   HookEvent( "", "", "" )                                                                                                        |
| È possibile utilizzare la funzione IsObject( ... ) per distinguere se l'output è un Array oppure no ( in tale caso è la stringa  |
| Record di errore ).                                                                                                              |
|                                                                                                                                  |
| SYNTAX:                                                                                                                          |
|                           *           *             *         *                                                                  |
| HookEvent( sFunctionName, [EVENT[,...]] | aiEvents, [PID[,...]] | aiPIDs[, iFlags] )                                             |
| HookEvent( "", "", "" )                                                                                                          |
| Every optional argument can be omitted.                                                                                          |
| Ogni argomento opzionale può essere omesso.                                                                                      |
|                                                                                                                                  |
| ARGUMENTS:                                                                                                                       |
| sFunctionName         : The Variable name containing the UDF function name that will be called everytime an event is generated   |
|                         ( asynchronous ).                                                                                        |
|                         If the UDF function name is a constant, must be defined between "".                                      |
|                         That UDF function must be defined like ( assuming sFunctionName := "DefinedFunction" ):                  |
|                         DefinedFunction( hHook, iEvent, hWnd, iIdObject, iIdChild, iEventThread, dwmsEventTime )                 |
|                         {                                                                                                        |
|                             .                                                                                                    |
|                             .                                                                                                    |
|                             .                                                                                                    |
|                         }                                                                                                        |
|                         The 7 Input arguments are:                                                                               |
|                         hHook         : Handle to an event hook function. This value is returned by SetWinEventHook when the     |
|                                         hook function is installed and is specific to each instance of the hook function.        |
|                                         This handle can be used with with the UnhookWinEvent... API function to remove the event |
|                                         hook specified by hWinEventHook that prevents the corresponding callback function from   |
|                                         receiving further event notifications ( this is unuseful if use the UDF                  |
|                                         UnHookEvent( ... ) function to remove the event hook ).                                  |
|                         iEvent        : Specifies the event that occurred. This value is one of the event constants.             |
|                                         The event constants begins with EVENT_OBJECT_... or EVENT_SYSTEM_..., before defined.    |
|                         hWnd          : Handle to the window that generates the event, or NULL if no window is associated with   |
|                                         the event. For example, the mouse pointer is not associated with a window.               |
|                                         Can be used with ahk_id prefix, like window name, with the window AutoHotKey functions   |
|                                         like WinTitle( ... ), WinExist( ... ), WinGet( ... ) and many other.                     |
|                         iIDObject     : Identifies the object associated with the event. This is one of the object identifiers   |
|                                         or a custom object ID.                                                                   |
|                                         It identifies a system object like Menu bar, System menu, and so on; to identify a       |
|                                         specific window object it is necessary to use the Acc AutoHotkey extension.              |
|                                         The system object constants begins with OBJID_..., before defined.                       |
|                         iIDChild      : Identifies whether the event was triggered by an object or a child element of the        |
|                                         object.                                                                                  |
|                                         If this value is CHILDID_SELF, the event was triggered by the object; otherwise, this    |
|                                         value is the child ID of the element that triggered the event.                           |
|                                         This value simply defines whether the event was triggered by the object itself or a      |
|                                         child element of the object: for example, a button will be an object ( iIdChild will be  |
|                                         CHILDID_SELF ), but a selected tab item will be a child of a larger element containing   |
|                                         all the tabs.                                                                            |
|                         iEventThread  : Thread Id of the thread that generated the event, or the thread that owns the current    |
|                                         window.                                                                                  |
|                                         Thread Id is a long positive integer that is created when the thread was created. During |
|                                         the entire lifecycle of a thread, the Thread Id is unique and remains unchanged. It can  |
|                                         be reused when the thread is terminated.                                                 |
|                                         The identifiers are valid from the time the thread is created until the thread has been  |
|                                         terminated. Note that no thread identifier will ever be 0.                               |
|                                         Difference between Thread Id and Thread Handle:                                          |
|                                         - The thread is operated by a thread handle. There may be multiple threads in which each |
|                                           thread handle can have different operation goals.                                      |
|                                         - The value obtained by open thread is different from different processes.               |
|                                         - Within the scope of the windows system, thread id is a unique identification of        |
|                                           thread.                                                                                |
|                                         - The Thread Handle is process-local while the Thread Id is system-wide.                 |
|                                         - To operate processes and threads between OS and Client, the Thread Handle acts as a    |
|                                           bridge. The operating system has a form for maintaining the Thread Handle. The handle  |
|                                           contains the reference count of the handle and related attributes.                     |
|                                         - Thread Handle is used by the operating system that identifies processes and threads,   |
|                                           users can use the handle to identify processes and threads and operate on them.        |
|                                         - The Thread Id is used by the operating system to identify processes and threads. The   |
|                                           thread id is unique globally but the users can capture the Thread Handle of the        |
|                                           process thread through this Id.                                                        |
|                                         - A Thread Handle is a kernel object whereas the Thread Id is not.                       |
|                                         - For creating a Thread Id it will be automatically generated by the operating system    |
|                                           when CreateThread is used.                                                             |
|                                         - The Thread Id and handle are two different things. The Thread Id uniquely corresponds  |
|                                           in the windows system ie. if there are two threads and if they return the same Thread  |
|                                           Id they must be the same thread otherwise they must originate from different threads.  |
|                                         - The Thread Handle is a 32-bit value that is used to access a thread and it is not the  |
|                                           only identifier of the thread.                                                         |
|                                         - The same handle must identify the same thread but the same thread may have 2 open      |
|                                           handles so it cannot use the thread handle to distinguish whether the two threads are  |
|                                           alike( same thread ).                                                                  |
|                                         This API call gives the thread handle about the Thread Id in iEventThread argument:      |
|                                         hThread := DllCall( "OpenThread", "UInt", RIGHTCONSTANT[ | ... ], "Ptr", 0, "UInt", iEventThread, "Ptr" )
|                                         where:                                                                                   |
|                                         - RIGHTCONSTANT are one or much constants that begins with THREAD_... or OBJECT_...,     |
|                                           before defined.                                                                        |
|                                         - iEventThread is the iEventThread function argument.                                    |
|                                         When you are finished with the handle, be sure to close it by using the CloseHandle      |
|                                         function:                                                                                |
|                                         DllCall( "CloseHandle", "Ptr", hThread )                                                 |
|                                         where:                                                                                   |
|                                         - hThread is the Thread Handle generated before by the DllCall( "OpenThread", ... ).     |
|                                         If the function succeeds, the return value is nonzero, otherwise the return value is 0.  |
|                                         With the thread handle is possible to use many thread API functions like                 |
|                                         GetThreadDescription..., GetThreadPriority..., SuspendThread... and many other API       |
|                                         thread functions; see the link:                                                          |
|                                         https://learn.microsoft.com/en-us/windows/win32/procthread/process-and-thread-functions  |
|                         dwmsEventTime : Specifies the time, in milliseconds, that the event was generated.                       |
|                                         It has the same form and the same scale as A_TickCount variable, then it is a relative   |
|                                         time ( to the turn on machine ), not an absolute time ( it is no the event date and      |
|                                         time ).                                                                                  |
|                                         Data dimension: DOUBLE WORD.                                                             |
|                                         Because there is a bug, it is necessary apply this operation to obtain the right value:  |
|                                         dwmsEventTime &= 0xFFFFFFFF                                                              |
|                                         At this time this argument has the same form like A_TickCount language variable; then    |
|                                         the time between now and the event time can be obtained in this mode:                    |
|                                         iElapsedmS := A_TickCount - dwmsEventTime                                                |
|                                         The current time to mS can be defined in the YYYYMMDDHH24MISSmsec format:                |
|                                         tTimeNowmS := A_Now . A_MSec                                                             |
|                                         At this point the event time, to mS, can be defined like:                                |
|                                         imsNow := SubStr( tTimeNowmS, -2 ) ; mS of the actual time ( only decimal part, last 3   |
|                                                                            ; digits of the actual time, first 3 digits of the    |
|                                                                            ; decimal part )                                      |
|                                         tTimeNow := SubStr( tTimeNowmS, 1, 14 )  ; Actual time on YYYYMMDDHH24MISS format, from  |
|                                                                                  ; firsts 14 characters of the tTimeNowmS time   |
|                                         iElapsedSint := ElapsedmS // 1000  ; Seconds elapsed from the identified event to now:   |
|                                                                            ; whole part.                                         |
|                                         iElapsedSdec := ElapsedmS - iElapsedSint * 1000  ; Seconds elapsed from the identified   |
|                                                                                          ; event to now: decimal part.           |
|                                         iCarriedS := ( imsNow >= iElapsedSdec ) ? 0 : 1  ; Amount carried of the subtraction     |
|                                                                                          ; Actual_time - Spent_time_from_event   |
|                                                                                          ; for the decimal part only, to obtain  |
|                                                                                          ; the event time: for the decimal part  |
|                                                                                          ; only, if the actual time decimal part |
|                                                                                          ; >= spent time decimal part, the       |
|                                                                                          ; Actual_time - Spent_time subtraction  |
|                                                                                          ; no generate any carried ( 0 S ),      |
|                                                                                          ; otherwise it generate 1 Sec. carried. |
|                                         iRemaindermS := ( iCarriedS == 0 ) ? ( imsNow - iElapsedSdec ) : ( 1000 - iElapsedSdec ) |
|                                                                    ; Decimal part of the event time.                             |
|                                                                    ; Subtraction remainder Actual_time - Spent_time_from_event   |
|                                                                    ; for the decimal part only, defined by mS.                   |
|                                                                    ; If 0 carried, the subtraction remainder only for decimal    |
|                                                                    ; part is Actual_time_decimal_part - Spent_time_decimal_part  |
|                                                                    ; otherwise the subtraction remainder is 1000 -               |
|                                                                    ; Spent_time_decimal_part                                     |
|                                         , tEventTime := tTimeNow  ; To calculate the exact event time begin from the actual      |
|                                                                   ; time: copy the actual time into the tEventTime variable      |
|                                                                   ; using the format YYYYMMDDHH24MISS                            |
|                                         tEventTime += -( iElapsedSint + iCarriedS ), S  ; Particular syntax to time calculate    |
|                                                                                         ; to Seconds: starting from the actual   |
|                                                                                         ; time into the tEventTime variable      |
|                                                                                         ; subtract the Sec. time from the last   |
|                                                                                         ; event time and the calculated carried. |
|                                         , iRemaindermS := Format( "{:03}", iRemaindermS )                                        |
|                                                                    ; Calculate the decimal part of event time to mS with 3       |
|                                                                    ; digits format ( iRemaindermS is certainly a number, then it |
|                                                                    ; has no any 0 digit before,  then add 0 digits before to 3   |
|                                                                    ; digits length.                                              |
|                       : Nome della funzione UDF che verrà chiamata automaticamente ( in modo asincrono ) al momento in cui si    |
|                         genera l'evento.                                                                                         |
|                         Se il nome di funzione UDF è una costante deve essere definito tra "".                                   |
|                         La funzione UDF deve essere definita come segue ( si assume sFunctionName := "DefinedFunction" ):        |
|                         DefinedFunction( hHook, iEvent, hWnd, iIdObject, iIdChild, dwEventThread, dwmsEventTime )                |
|                         {                                                                                                        |
|                             .                                                                                                    |
|                             .                                                                                                    |
|                             .                                                                                                    |
|                         }                                                                                                        |
|                         I 7 argomenti di chiamata sono:                                                                          |
|                         hHook         : Handle per una funzione hook di eventi. Questo valore viene restituito da                |
|                                         SetWinEventHook quando la funzione hook è installata ed è specifica per ogni istanza     |
|                                         della funzione hook.                                                                     |
|                                         Questo handle può essere utilizzato con la funzione API UnhookWinEvent... per rimuovere  |
|                                         l'identificatore di eventi a cui si riferisce, in modo da non generare la chiamata di    |
|                                         funzione al successivo evento ( questa procedura non è utile se viene utilizzata la      |
|                                         funzione UDF UnHookEvent( ... ) per ottenere lo stesso risultato ).                      |
|                         iEvent        : Specifica l'evento che si è verificato. Questo valore è una delle costanti di evento.    |
|                                         Le costanti evento iniziano con EVENT_OBJECT_... oppure EVENT_SYSTEM_..., definite       |
|                                         sopra.                                                                                   |
|                         hWnd          : Handle relativo alla window che genera l'evento o NULL se all'evento non è associata     |
|                                         alcuna finestra. Ad esempio, il puntatore del mouse non è associato a una finestra.      |
|                                         Può essere utilizzato con il prefisso ahk_id come nome di window con le funzioni         |
|                                         AutoHotKey come WinTitle( ... ), WinExist( ... ), WinGet( ... ) e molte altre.           |
|                         iIdObject     : Specifica l'oggetto associato all'evento. Si tratta di uno degli identificatori di       |
|                                         oggetto o di un ID oggetto personalizzato.                                               |
|                                         Identifica un oggetto di sistema che appartiene alla window, come Menu bar oppure System |
|                                         menu; per identificare un oggetto specifico della window è necessario utilizzare         |
|                                         l'Estensione di AutoHotkey Acc.                                                          |
|                                         Le costanti oggetto di sistema sono tutte quelle il cui nome inizia con OBJID_...,       |
|                                         definite sopra.                                                                          |
|                         iIdChild      : Identifica se l'evento è stato attivato da un oggetto o da un elemento figlio            |
|                                         dell'oggetto. Se questo valore è CHILDID_SELF, l'evento è stato attivato dall'oggetto;   |
|                                         in caso contrario, questo valore è l'ID figlio dell'elemento che ha attivato l'evento.   |
|                                         Questo valore specifica se l'evento selezionato è un elemento singolo ( e quindi questo  |
|                                         valore corrisponde a CHILDID_SELF ), oppure se questo è l'elemento figlio di un elemento |
|                                         più grande contenente molti elementi figlio ( per esempio un Tab è un elemento figlio di |
|                                         un elemento più grande contenente molti Tab ).                                           |
|                         dwEventThread : Thread Id del thread che ha generato l'evento, oppure il thread relativo alla window     |
|                                         attualmente attiva.                                                                      |
|                                         Il Thread Id è un numero intero positivo di tipo Long che viene generato al momento      |
|                                         della generazione del thread. Durante l'intero ciclo di vita di un thread, il Thread Id  |
|                                         è univoco e rimane invariato. Può essere riutilizzato dopo che il thread è stato         |
|                                         terminato. Gli identificatori sono validi dal momento in cui il thread viene generato    |
|                                         fino a quando lo stesso thread viene terminato. Nessun identificatore di thread può      |
|                                         assumere il valore 0.                                                                    |
|                                         Differenze tra Thread Id e Thread Handle:                                                |
|                                         - Il thread viene gestito tramite un Thread Handle. Potrebbero esserci più thread ognuno |
|                                           dei quali può avere un diverso obiettivo operativo.                                    |
|                                         - Il valore di un nuovo thread aperto è diverso in ogni processo.                        |
|                                         - Nell'ambito del Sistema Operativo Windows, il Thread Id è un valore univoco.           |
|                                         - Il Thread Handle è un valore locale a livello di processo mentre il Thread Id è        |
|                                           univoco a livello di sistema.                                                          |
|                                         - Il Thread Handle funge da ponte per gestire processi e thread tra il Sistema Operativo |
|                                           e il client. Il Sistema Operativo ha un modulo per mantenere il Thread Handle. Il      |
|                                           Thread Handle contiene il numero dei riferimenti dell'handle e i relativi attributi.   |
|                                         - Il Thread Handle viene utilizzato dal Sistema Operativo per identificare processi e    |
|                                           thread; gli utenti possono utilizzare l'handle per identificare processi e thread ed   |
|                                           operare su di essi.                                                                    |
|                                         - Il Thread Id viene utilizzato dal Sistema Operativo per identificare processi e        |
|                                           thread. Il Thread Id è univoco a livello globale, ma gli utenti possono acquisire il   |
|                                           Thread Handle tramite questo Thread Id.                                                |
|                                         - Un Thread Handle è un oggetto del kernel mentre il Thread Id non lo è.                 |
|                                         - Un Thread Id può venire generato automaticamente dal Sistema Operativo quando viene    |
|                                           utilizzato CreateThread.                                                               |
|                                         - Il Thread Id e il Thread Handle sono due cose diverse. Il Thread Id ha una             |
|                                           corrispondenza univoca nel Sistema Operativo Windows, ad es. se ci sono due thread e   |
|                                           se restituiscono lo stesso Thread Id devono riferirsi allo stesso thread, altrimenti   |
|                                           si riferiscono a thread diversi.                                                       |
|                                         - Il Thread Handle è un valore a 32 bit utilizzato per accedere a un thread e non è      |
|                                           l'unico identificatore del thread.                                                     |
|                                         - Lo stesso Thread Handle deve identificare lo stesso thread ma lo stesso thread può     |
|                                           avere 2 Thread Handle aperti in questo caso non è possibile utilizzare un Thread       |
|                                           Handle per capire se entrambi si riferiscono allo stesso thread.                       |
|                                         La seguente chiamata ad una funzione API ritorna un Thread Handle relativo al Thread Id  |
|                                         specificato nell'argomento iEventThread:                                                 |
|                                         hThread := DllCall( "OpenThread", "UInt", RIGHTCONSTANT[ | ... ], "Ptr", 0, "UInt", iEventThread, "Ptr" )
|                                         in cui:                                                                                  |
|                                         - RIGHTCONSTANT corrisponde a una o più costanti il cui nome inizia con THREAD_...       |
|                                           oppure OBJECT_..., definite sopra.                                                     |
|                                         - iEventThread è l'argomento iEventThread della funzione.                                |
|                                         Quando è terminata l'utilizzazione del Thread Handle è importante chiuderlo utilizzando  |
|                                         la funzione API CloseHandle:                                                             |
|                                         DllCall( "CloseHandle", "Ptr", hThread )                                                 |
|                                         in cui:                                                                                  |
|                                         - hThread è il Thread Handle generato prima da DllCall( "OpenThread", ... ).             |
|                                         Se la funzione API ha successo, il valore restituito è diverso da zero, altrimenti il    |
|                                         valore restituito è 0.                                                                   |
|                                         Con il Thread Handle è possibile utilizzare molte funzioni API relative al thread, come  |
|                                         per esempio GetThreadDescription..., GetThreadPriority..., SuspendThread... e molte      |
|                                         altre funzioni API relative a thread; vedere il link:                                    |
|                                         https://learn.microsoft.com/en-us/windows/win32/procthread/process-and-thread-functions  |
|                         dwmsEventTime : Specifica il tempo, espresso in millisecondi, in cui è stato generato l'evento.          |
|                                         È nella stessa forma e nella stessa scala della variabile di linguaggio A_TickCount,     |
|                                         quindi è un tempo relativo ( rispetto al momento di accensione della macchina ) e non un |
|                                         tempo assoluto ( non specifica data ed ora dell'evento ).                                |
|                                         Dimensione dato: DOUBLE WORD.                                                            |
|                                         A causa di un bug, al fine di ottenere il valore esatto originale è necessario           |
|                                         effettuare come prima cosa la seguente operazione:                                       |
|                                         dwmsEventTime &= 0xFFFFFFFF                                                              |
|                                         A questo punto ha la stessa forma della variabile di linguaggio A_TickCount; quindi il   |
|                                         tempo in mS trascorso finora a partire dal momento in cui è stato generato l'evento può  |
|                                         essere calcolato così:                                                                   |
|                                         iElapsedmS := A_TickCount - dwmsEventTime                                                |
|                                         Il tempo attuale fino ai mS può essere letto così in formato YYYYMMDDHH24MISSmsec:       |
|                                         tTimeNowmS := A_Now . A_MSec                                                             |
|                                         A questo punto il calcolo del tempo preciso dell'evento fino ai mS può essere eseguito   |
|                                         come segue:                                                                              |
|                                         imsNow := SubStr( tTimeNowmS, -2 ) ; mS del tempo attuale ( solo parte decimale del      |
|                                                                            ; tempo attuale, prime 3 cifre della parte decimale ) |
|                                         tTimeNow := SubStr( tTimeNowmS, 1, 14 )  ; Tempo attuale in formato YYYYMMDDHH24MISS     |
|                                                                                  ; ricavato dai primi 14 caratteri del tempo     |
|                                                                                  ; tTimeNowmS                                    |
|                                         iElapsedSint := ElapsedmS // 1000  ; Tempo in Secondi trascorso dall'evento identificato |
|                                                                            ; fino ad adesso: parte intera.                       |
|                                         iElapsedSdec := ElapsedmS - iElapsedSint * 1000  ; Tempo in Secondi trascorso            |
|                                                                                          ; dall'evento identificato fino ad      |
|                                                                                          ; adesso: parte decimale.               |
|                                         iCarriedS := ( imsNow >= iElapsedSdec ) ? 0 : 1  ; Riporto della sottrazione             |
|                                                                                          ; Tempo_attuale -                       |
|                                                                                          ; Tempo_trascorso_dall'evento per la    |
|                                                                                          ; sola parte decimale, per ottenere il  |
|                                                                                          ; tempo dell'evento: per quanto         |
|                                                                                          ; riguarda la sola parte decimale, se   |
|                                                                                          ; parte decimale del tempo attuale >=   |
|                                                                                          ; parte decimale del tempo trascorso,   |
|                                                                                          ; la susseguente sottrazione            |
|                                                                                          ; Tempo_attuale -                       |
|                                                                                          ; Tempo_trascorso_dall'evento non       |
|                                                                                          ; genera nessun riporto ( 0 S ),        |
|                                                                                          ; altrimenti genera il riporto di       |
|                                                                                          ; 1 Sec. intero ( 1 S ).                |
|                                         iRemaindermS := ( iCarriedS == 0 ) ? ( imsNow - iElapsedSdec ) : ( 1000 - iElapsedSdec ) |
|                                                                    ; Parte decimale del tempo evento.                            |
|                                                                    ; Resto della sottrazione Tempo_attuale -                     |
|                                                                    ; Tempo_trascorso_dall'evento per la sola parte decimale      |
|                                                                    ; espresso in mS.                                             |
|                                                                    ; Se il riporto è 0, il resto della sottrazione per la sola   |
|                                                                    ; parte decimale è dato da parte_decimale_tempo_attuale -     |
|                                                                    ; parte_decimale_tempo_trascorso altrimenti il resto della    |
|                                                                    ; sottrazione è dato da 1000 - parte_decimale_tempo_trascorso |
|                                         , tEventTime := tTimeNow  ; Per calcolare il tempo preciso dell'evento inizio dal tempo  |
|                                                                   ; attuale: copio nella variabile tEventTime il tempo attuale   |
|                                                                   ; in formato YYYYMMDDHH24MISS                                  |
|                                         tEventTime += -( iElapsedSint + iCarriedS ), S  ; Forma particolare per il calcolo di    |
|                                                                                         ; tempo fino ai Secondi: a partire dal   |
|                                                                                         ; tempo attuale contenuto in tEventTime  |
|                                                                                         ; sottraggo il tempo in Sec trascorso    |
|                                                                                         ; dall'ultimo evento e l'eventuale       |
|                                                                                         ; riporto intero precedentemente         |
|                                                                                         ; calcolato.                             |
|                                         , iRemaindermS := Format( "{:03}", iRemaindermS )                                        |
|                                                                    ; Calcolo la parte decimale del tempo evento sempre in        |
|                                                                    ; formato 3 cifre ( iRemaindermS è sicuramente in formato     |
|                                                                    ; numerico, quindi non ha cifre 0 davanti, quindi             |
|                                                                    ; eventualmente aggiungo cifre 0 davanti ).                   |
| EVENT                 : Constant Array of Event Codes that will generate an asychronous call to the sFunctionName function.      |
|                         Because this is a constant arrary, the "[" and "]" characters ( with * upper identification  ) are       |
|                         literal: that, and only that, has no the syntax "optional" meaning: that MUST be everytime present, with |
|                         only one constant too, at the begin and at the end of this argument.                                     |
|                         Example ( spaces ar not influential ):                                                                   |
|                         [ EVENT_OBJECT_HIDE ]                                                                                    |
|                         The constants event are all that name begins with EVENT_..., before defined.                             |
|                         If specified much than one constant, everyone must be separed by "," character.                          |
|                         Example ( spaces ar not influential ):                                                                   |
|                         [ EVENT_OBJECT_HIDE, EVENT_OBJECT_SHOW ]                                                                 |
|                       : Costante Array di Codici Evento che generano la chiamata asincrona alla Funzione specificata             |
|                         nell'argomento sFunctionName.                                                                            |
|                         Poiché questo Argomento è un array, DEVE essere specificato tra "[" e "]" letteralmente: i 2 caratteri   |
|                         contrassegnati con * nella sintassi sono quindi letterali e DEVONO essere sempre presenti e, solo in     |
|                         questo caso, NON hanno il significato di sintassi "opzionale".                                           |
|                         Esempio ( gli spazi sono ininfluenti ) :                                                                 |
|                         [ EVENT_OBJECT_HIDE ]                                                                                    |
|                         Le costanti evento sono tutte quelle il cui nome inizia con EVENT_..., definite sopra.                   |
|                         Se sono specificate più costanti, ognuna deve essere separata dalla precedente tramite il carattere ",". |
|                         Esempio ( gli spazi sono ininfluenti ) :                                                                 |
|                         [ EVENT_OBJECT_HIDE, EVENT_OBJECT_SHOW ]                                                                 |
| aiEvents              : Array of Event Codes that will generate an asychronous call to the sFunctionName function.               |
|                         It has the same meaning like Constant Array of Event Codes, but it is a variable: it must be generated   |
|                         and loaded before, then put that name here.                                                              |
|                         This is alternative to the Constant Array of Events.                                                     |
|                       : Array di Codici Evento che generano la chiamata asincrona alla Funzione specificata nell'argomento       |
|                         sFunctionName.                                                                                           |
|                         Ha lo stesso significato della costante Array di Codici Evento, ma è una variabile: deve essere          |
|                         dichiarata e caricata prima, e quindi può essere inserito qui il suo nome.                               |
|                         Questo è alternativo alla Costante Array di Codici Evento.                                               |
| PID                   : Constant Array of PIDs of all process from which the hook function will receive events. Specify zero     |
|                         (0) to receive events from all processes on the current desktop.                                         |
|                         Because this is a constant arrary, the "[" and "]" characters ( with * upper identification  ) are       |
|                         literal: that, and only that, has no the syntax "optional" meaning: that MUST be everytime present, with |
|                         only one constant too, at the begin and at the end of this argument.                                     |
|                         It is possible to obtain it by AutoHotKey functions                                                      |
|                         WinGet, OutputVar, PID ...                                                                               |
|                         or                                                                                                       |
|                         Process, Exist, PIDOrName ...                                                                            |
|                         ( the last sets ErrorLevel to the Process ID (PID) if a matching process exists, or 0 otherwise. If the  |
|                         PIDOrName parameter is blank, the script's own PID is retrieved ).                                       |
|                         To obtain the PID of the launched process it is possible to use                                          |
|                         Run, FileExec,,, OutputVarPID                                                                            |
|                         or                                                                                                       |
|                         RunWait, FileExec,,, OutputVarPID                                                                        |
|                         An alternate, single-line method to retrieve the script's PID is                                         |
|                         sPID := DllCall( "GetCurrentProcessId" ).                                                                |
|                         The name of a process is usually the same as its executable ( without path ), e.g. notepad.exe or        |
|                         winword.exe. Since a name might match multiple running processes, only the first process will be         |
|                         operated upon. The name is not case sensitive.                                                           |
|                         0 Default value.                                                                                         |
|                         The rev. 1.0 has this argument like Optional.                                                            |
|                       : Costante Array di Process ID ( PID ) relativi ai processi di cui si deve intercettare l'evento.          |
|                         Specificare 0 ( 0 ) per intercettare gli eventi di tutti i processi del desktop attuale.                 |
|                         Poiché questo Argomento è un array, DEVE essere specificato tra "[" e "]" letteralmente: i 2 caratteri   |
|                         contrassegnati con * nella sintassi sono quindi letterali e DEVONO essere sempre presenti e, solo in     |
|                         questo caso, NON hanno il significato di sintassi "opzionale".                                           |
|                         È possibile ottenere il Process ID ( PID ) tramite le funzioni AutoHotKey                                |
|                         WinGet, OutputVar, PID ...                                                                               |
|                         oppure                                                                                                   |
|                         Process, Exist, PIDOrName ...                                                                            |
|                         ( quest'ultima setta la variabile ErrorLevel assegnandole il PID del processo, se viene identificato,    |
|                         altrimenti le assegna 0. Se PIDOrName è blank, verrà identificato il PID del programma o script che lo   |
|                         sta eseguendo ).                                                                                         |
|                         Per ottenere il PID di un processo chiamato è possibile utilizzare                                       |
|                         Run, FileExec,,, OutputVarPID                                                                            |
|                         oppure                                                                                                   |
|                         RunWait, FileExec,,, OutputVarPID                                                                        |
|                         Un modo alternativo per ottenere il PID del programma o script in esecuzione è                           |
|                         sPID := DllCall( "GetCurrentProcessId" )                                                                 |
|                         0 Valore di default.                                                                                     |
|                         Nella rev. 1.0 questo argomento è Optional.                                                              |
| aiPIDs                : Array of PIDs of all process from which the hook function will receive events.                           |
|                         It has the same meaning like Constant Array of PIDs, but it is a variable: it must be generated          |
|                         and loaded before, then put that name here.                                                              |
|                         This is alternative to the Constant Array of PIDs.                                                       |
|                         0 Default value.                                                                                         |
|                         The rev. 1.0 has this argument like Optional.                                                            |
|                       : Array di Process ID ( PID ) relativi ai processi di cui si deve intercettare l'evento.                   |
|                         Ha lo stesso significato della costante Array di PIDs, ma è una variabile: deve essere dichiarata e      |
|                         caricata prima, e quindi può essere inserito qui il suo nome.                                            |
|                         Questo è alternativo alla Costante Array di PIDs.                                                        |
|                         0 Valore di default.                                                                                     |
|                         Nella rev. 1.0 questo argomento è Optional.                                                              |
| iFlags                : Optional - Flag values that specify the location of the hook function and of the events to be skipped.   |
|                         The Flag values are all constants that name begins with "WINEVENT_", before defined.                     |
|                         Flags values can be a single value or 2 values separated by or ( | ) operator.                           |
|                         The following flags can be specified alone:                                                              |
|                         WINEVENT_INCONTEXT                                                                                       |
|                         WINEVENT_OUTOFCONTEXT ( default )                                                                        |
|                         The following Flag combinations are valid ( all before defined ):                                        |
|                         WINEVENT_INCONTEXT | WINEVENT_SKIPOWNPROCESS                                                             |
|                         WINEVENT_INCONTEXT | WINEVENT_SKIPOWNTHREAD                                                              |
|                         WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS                                                          |
|                         WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNTHREAD                                                           |
|                         WINEVENT_OUTOFCONTEXT default value.                                                                     |
|                       : Optional - Valori di flag per specificare la posizione della funzione hook e degli eventi da ignorare.   |
|                         I valori di Flag sono tutte quelle costanti il cui nome inizia con "WINEVENT_", definite sopra.          |
|                         I valori di Flag possono essere specificati singolarmente oppure come una coppia di valori uniti         |
|                         dall'operatore or ( | ).                                                                                 |
|                         I seguenti valori di Flag possono essere specificati singolarmente ( sono tutti definiti sopra ):        |
|                         WINEVENT_INCONTEXT                                                                                       |
|                         WINEVENT_OUTOFCONTEXT ( default )                                                                        |
|                         Le seguenti combinazioni di Flag sono valide:                                                            |
|                         WINEVENT_INCONTEXT | WINEVENT_SKIPOWNPROCESS                                                             |
|                         WINEVENT_INCONTEXT | WINEVENT_SKIPOWNTHREAD                                                              |
|                         WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS                                                          |
|                         WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNTHREAD                                                           |
|                         WINEVENT_OUTOFCONTEXT Valore di default.                                                                 |
| "", "", ""            : First 3 arguments like "": require the actual Event Hook Associative Array; the Function no generates    |
|                         any new Event Hook and the only thing is to return the Event Hook Associative Array.                     |
|                         It is possible to read that, but it is no possibile to modify it: every modification in only true in the |
|                         local copy of the Event Hook Associative array and has no influence on the Static associative Array into |
|                         this Function.                                                                                           |
|                         The rev. 1.0 has no this option.                                                                         |
|                         Primi 3 argomenti "": richiesta attuale Array associativo Event Hook; la Funzione non genera nessun      |
|                         Event Hook e l'unica cosa che fa è ritornare l'Array associativo Event Hook.                             |
|                         È possibile leggerla, ma non è possibile modificarla: ogni modifica è valida solo nella copia locale     |
|                         dell'Array associativo Event Hook e non ha nessuna influenza con il valore Static dell'Array associativo |
|                         all'interno di questa Funzione.                                                                          |
|                         La rev. 1.0 non ha questa opzione.                                                                       |
|                                                                                                                                  |
| RETURN:                                                                                                                          |
| The rev. 1.0 return 0 everytime.                                                                                                 |
| At the end of successful Event Hook building, or as answer at the HookEvent( "", "", "" ) call:                                  |
| - Event Hook Associative Array.                                                                                                  |
| At the end of unsuccessful Event Hook building:                                                                                  |
| - a string like a Record with 2 Fields, Separator " ":                                                                           |
|   iEvent iPID                                                                                                                    |
|   iEvent              : Event Code of the Event Hook that generates error;                                                       |
|   iPID                : PID of the Event Hook that generates error.                                                              |
|                                                                                                                                  |
| La rev. 1.0 ritorna sempre 0.                                                                                                    |
| Alla fine della generazione di Event Hooks senza errori, oppure come risposta alla chiamata HookEvent( "", "", "" ):             |
| - Array associativo Event Hook.                                                                                                  |
| Alla fine di generazione di Event Hooks con errore a causa dell'ultimo Event Hook generato:                                      |
| - stringa come un Record composto da 2 Campi con Separatore " ":                                                                 |
|   iEvent iPID                                                                                                                    |
|   iEvent              : Event Code dell'Event Hook che ha generato errore;                                                       |
|   iPID                : PID dell'Event Hook che ha generato errore.                                                              |
|                                                                                                                                  |
|==================================================================================================================================|
*/

HookEvent( sFunctionName, aiEvents, aiPIDs, iFlags := 0 )
{

    Static asHookTable := {}                                         ; Dichiarazione Array associativo che conterrà tutte le
                                                                     ; informazioni relative a tutti gli Event Hook generati.
                                                                     ; La chiave è l'Event Hook generato.
                                                                     ; Il valore associato ad ogni chiave è un Record composto da 3
                                                                     ; Campi, con separatore " " ( in pratica una stringa che funge
                                                                     ; da Record ):
                                                                     ; Campo 1: nome della funzione UDF che viene chiamata
                                                                     ;          automaticamente ( in modo asincrono ) al momento in
                                                                     ;          cui si genera l'evento;
                                                                     ; Campo 2: costante Evento che genera la chiamata asincrona
                                                                     ;          alla Funzione specificata nel Campo 1;
                                                                     ; Campo 3: Process ID ( PID ) relativo al processo di cui si
                                                                     ;          deve intercettare l'evento.

    ; CASO PARTICOLARE: RICHIESTA RITORNO EVENT HOOK TABLE =========================================================================

    If(( sFunctionName == "" ) && ( aiEvents == "" ) && ( aiPIDs == "" ))
                                                                     ; Riconoscimento questa richiesta: tutti gli Argomenti
                                                                     ; obbligatori sono ""
        Return asHookTable                                           ; Ritorno l'Array associativo che conterrà tutte le
                                                                     ; informazioni relative a tutti gli Event Hook generati.

    ; CASO PARTICOLARE: RICHIESTA CANCELLAZIONE ALCUNI ELEMENTI DALLA EVENT HOOK TABLE =============================================
    ; Questo caso particolare è adatto per la chiamata da parte della Funzione UnHookEvent( ... )
    ; Utilizza i primi 3 argomenti in modo non standard:
    ; Arg1 : " "
    ;        Specificato al posto del nome di Funzione, non può generare ambiguità perché sarebbe un nome di Funzione inesistente;
    ;        definisce la richiesta di questo caso particolare.
    ; Arg2 : Array in cui ogni elemento contiene un Event Hook eliminato dalla funzione UnHookEvent( ... ): tali valori vanno quindi
    ;        eliminati dall'Array associativo asHookTable.
    ; Arg3 : Numero di elementi presenti nell'Array passato in Arg2.

    If( sFunctionName == " " )                                       ; Riconoscimento questa richiesta: il primo Argomento è " "
    {

        Loop % aiPIDs                                                ; Ciclo lettura di ogni elemento presente nell'Array contenuto
                                                                     ; in aiEvents e cancellazione, nell'Array associativo
                                                                     ; asHookTable, del corrispondente elemento la cui chiave è
                                                                     ; l'Event Hook letto dall'Array contenuto in aiEvents.
            asHookTable.Delete( aiEvents[ A_Index - 1 ] )            ; All'interno dell'Array associativo asHookTable elimino
                                                                     ; l'elemento corrispondente all'Event Hook letto dall'Array
                                                                     ; aiEvents; la posizione in aiEvents è A_Index - 1 perché
                                                                     ; A_Index inizia da 1 mentre il primo elemento in aiEvents ha
                                                                     ; indice 0.

        Return asHookTable                                           ; Ritorno l'Array associativo che contiene tutte le
                                                                     ; informazioni relative a tutti gli Event Hook generati prima e
                                                                     ; ancora esistenti.

    }                                                                ; If( sFunctionName == " " )

    ; CASO GENERALE: COSTRUZIONE EVENT HOOKS E AGGIORNAMENTO ARRAY ASSOCIATIVO asHookTable DEGLI EVENT HOOKS =======================

    For iIdx, iPID in aiPIDs                                         ; Ciclo di lettura di ogni PID contenuto nell'Array aiPIDs;
                                                                     ; assegnazione contenuto di un elemento alla variabile iPID.
        For iCnt, iEvent in aiEvents                                 ; Ciclo di lettura di ogni Codice Evento contenuto nell'Array
        {                                                            ; aiEvents; assegnazione contenuto di un elemento alla
                                                                     ; variabile iEvent.

            DllCall( "CoInitialize", UInt, 0 )                       ; Dal sito Microsoft: Initializes the COM library on the
                                                                     ; current thread and identifies the concurrency model as
                                                                     ; single-thread apartment (STA).
            If( hHook := DllCall( "SetWinEventHook", UInt, iEvent, UInt, iEvent, UInt, 0, UInt, RegisterCallback( sFunctionName ), UInt, iPID, UInt, 0, UInt, iFlags ))
                                                                     ; Generazione Event Hook e assegnazione di tale codice alla
                                                                     ; variabile hHook; se tale codice Event Hook != 0.
                asHookTable[ hHook ] := sFunctionName . " " . iEvent . " " . iPID
                                                                     ; Nell'Array associativo asHookTable, genero la chiave
                                                                     ; costituita dal valore contenuto in hHook ( cioè codice Event
                                                                     ; Hook generato ); il valore è un Record composto da 3 Campi,
                                                                     ; con separatore " " ( in pratica una stringa che funge da
                                                                     ; da Record ):
                                                                     ; Campo 1: nome della funzione UDF che viene chiamata
                                                                     ;          automaticamente ( in modo asincrono ) al momento in
                                                                     ;          cui si genera l'evento;
                                                                     ; Campo 2: costante Evento che genera la chiamata asincrona
                                                                     ;          alla Funzione specificata nel Campo 1;
                                                                     ; Campo 3: Process ID ( PID ) relativo al processo di cui si
                                                                     ;          deve intercettare l'evento.
            Else                                                     ; Il codice Event Hook è 0 ( significa che la funzione di
                                                                     ; generazione Event Hook ha ritornato errore ).
                Break, 2                                             ; Esco da tutti e 2 i cicli For innestati.

        }                                                            ; For iCnt, iEvent in aiEvents

    Return ( hHook == 0 ) ? iEvent . " " . iPID : asHookTable        ; Ritorno:
                                                                     ; - se l'ultimo Event Hook ha generato errore ( cioè
                                                                     ;   hHook == 0 ), ritorno un Record composto da 2 Campi con
                                                                     ;   separatore " ":
                                                                     ;   Campo 1 : Codice Evento del tentativo di Event Hook;
                                                                     ;   Campo 2 : PID del tentativo di Event Hook;
                                                                     ; - altrimenti, poiché sono stati generati tutti gli Event Hook
                                                                     ;   richiesti, ritorno l'Array associativo asHookTable di tutti
                                                                     ;   gli Event Hook attualmente esistenti.

}                                                                    ; HookEvent( sFunctionName, aiEvents, aiPIDs, iFlags := 0 )




/*
|==================================================================================================================================|
|                                                                                                                                  |
| EVENT HOOK REMOVE                                                                                                                |
|                                                                                                                                  |
|==================================================================================================================================|
|                                                                                                                                  |
| Rev. 2.0                                                                                                                         |
|                                                                                                                                  |
| Removes one, much or all Event Hook function call for one or much events, created by a previous call to HookEvent( ... ); and    |
| update the Event Hook associative Array.                                                                                         |
|                                                                                                                                  |
| Rimuove una, più di una o tutte le chiamate a funzione Event Hook per uno o più eventi, generata precedentemente da              |
| HookEvent( ... ) e aggiorna l'Array associativo Event Hook.                                                                      |
|                                                                                                                                  |
| SYNTAX:                                                                                                                          |
|                                 *           *               *         *                                                          |
| UnHookEvent( [sFunctionName][, [[EVENT[,...]] | aiEvents][, [PID[,...]] | aiPIDs]] )                                             |
| Every optional argument can be omitted.                                                                                          |
| Ogni argomento opzionale può essere omesso.                                                                                      |
|                                                                                                                                  |
| ARGUMENTS:                                                                                                                       |
| sFunctionName         : Optional - The UDF asynchronous function name previously defined by HookEvent( ... ).                    |
|                         If the value is "" the meaning is "all function names previously defined".                               |
|                         Default value : ""                                                                                       |
|                       : Opzionale - Nome della funzione UDF oggetto della chiamata asincrona precedentemente definita da         |
|                         HookEvent( ... ).                                                                                        |
|                         Se il valore è "" significa "tutti i nomi di funzione precedentemente definiti".                         |
| EVENT                 : Optional - Constant Array of Event Codes previously defined by HookEvent( ... ).                         |
|                         Because this is a constant arrary, the "[" and "]" characters ( with * upper identification  ) are       |
|                         literal: that, and only that, has no the syntax "optional" meaning: that MUST be everytime present, with |
|                         only one constant too, at the begin and at the end of this argument.                                     |
|                         Example ( spaces ar not influential ):                                                                   |
|                         [ EVENT_OBJECT_HIDE ]                                                                                    |
|                         The constants event are all that name begins with EVENT_..., before defined.                             |
|                         If specified much than one constant, everyone must be separed by "," character.                          |
|                         Example ( spaces ar not influential ):                                                                   |
|                         [ EVENT_OBJECT_HIDE, EVENT_OBJECT_SHOW ]                                                                 |
|                       : Opzionale - Costante Array di Codici Evento precedentemente definiti da HookEvent( ... ).                |
|                         Poiché questo Argomento è un array, DEVE essere specificato tra "[" e "]" letteralmente: i 2 caratteri   |
|                         contrassegnati con * nella sintassi sono quindi letterali e DEVONO essere sempre presenti e, solo in     |
|                         questo caso, NON hanno il significato di sintassi "opzionale".                                           |
|                         Esempio ( gli spazi sono ininfluenti ) :                                                                 |
|                         [ EVENT_OBJECT_HIDE ]                                                                                    |
|                         Le costanti evento sono tutte quelle il cui nome inizia con EVENT_..., definite sopra.                   |
|                         Se sono specificate più costanti, ognuna deve essere separata dalla precedente tramite il carattere ",". |
|                         Esempio ( gli spazi sono ininfluenti ) :                                                                 |
|                         [ EVENT_OBJECT_HIDE, EVENT_OBJECT_SHOW ]                                                                 |
| aiEvents              : Optional - Array of Event Codes previously defined by HookEvent( ... ).                                  |
|                         It has the same meaning like Constant Array of Event Codes, but it is a variable: it must be generated   |
|                         and loaded before, then put that name here.                                                              |
|                         This is alternative to the Constant Array of Events.                                                     |
|                         If the value is 0 the meaning is "all event previously defined".                                         |
|                         Default value: 0                                                                                         |
|                       : Opzionale - Array di Codici Evento precedentemente definiti da HookEvent( ... ).                         |
|                         Ha lo stesso significato della costante Array di Codici Evento, ma è una variabile: deve essere          |
|                         dichiarata e caricata prima, e quindi può essere inserito qui il suo nome.                               |
|                         Questo è alternativo alla Costante Array di Codici Evento.                                               |
|                         Se il valore è 0 significa "tutti gli eventi precedentemente definiti".                                  |
|                         Valore di default: 0                                                                                     |
| PID                   : Optional - Constant Array of PIDs previously defined by HookEvent( ... ).                                |
|                         Because this is a constant arrary, the "[" and "]" characters ( with * upper identification  ) are       |
|                         literal: that, and only that, has no the syntax "optional" meaning: that MUST be everytime present, with |
|                         only one constant too, at the begin and at the end of this argument.                                     |
|                         0 Default value.                                                                                         |
|                         The rev. 1.0 has no this argument like Optional.                                                         |
|                       : Opzionale - Costante Array di Process ID ( PID ) precedentemente definiti da HookEvent( ... ).           |
|                         Poiché questo Argomento è un array, DEVE essere specificato tra "[" e "]" letteralmente: i 2 caratteri   |
|                         contrassegnati con * nella sintassi sono quindi letterali e DEVONO essere sempre presenti e, solo in     |
|                         questo caso, NON hanno il significato di sintassi "opzionale".                                           |
|                         If the value is 0 the meaning is "all PID previously defined".                                           |
|                         0 Valore di default.                                                                                     |
|                         Nella rev. 1.0 questo argomento non è presente.                                                          |
| aiPIDs                : Optional - Array of PIDs previously defined by HookEvent( ... ).                                         |
|                         It has the same meaning like Constant Array of PIDs, but it is a variable: it must be generated          |
|                         and loaded before, then put that name here.                                                              |
|                         This is alternative to the Constant Array of PIDs.                                                       |
|                         0 Default value.                                                                                         |
|                         The rev. 1.0 has no this argument like Optional.                                                         |
|                       : Opzionale - Array di Process ID ( PID ) precedentemente definiti da HookEvent( ... ).                    |
|                         Ha lo stesso significato della costante Array di PIDs, ma è una variabile: deve essere dichiarata e      |
|                         caricata prima, e quindi può essere inserito qui il suo nome.                                            |
|                         Questo è alternativo alla Costante Array di PIDs.                                                        |
|                         Se il valore è 0 significa "tutti i PID precedentemente definiti".                                       |
|                         0 Valore di default.                                                                                     |
|                         Nella rev. 1.0 questo argomento non è presente.                                                          |
|                                                                                                                                  |
| RETURN:                                                                                                                          |
|  0 : No error, all OK.                                                                                                           |
| -1 : It was no possible to execute any UnHook; the much probable motive is that this fuction is called before any                |
|      HookEvent( ... ) call.                                                                                                      |
| >0 : Any number > 0 specify the number of UnHook error generated ( the function correctly set the Event Hook Associative         |
|      Array ); it is possible to call HookEvent( "", "", "" ) to obtain the actual Event Hook Associative Array to know what      |
|      Event Hook are working now.                                                                                                 |
|                                                                                                                                  |
|  0 : Nessun errore, tutto OK.                                                                                                    |
| -1 : Indica che per qualche motivo non è stato effettuato nessun tentativo di UnHook; la causa più probabile è che questa        |
|      funzione è stata chiamata prima della corrispondente funzione HookEvent( ... ).                                             |
| >0 : Qualsiasi numero > 0 indica il numero di errori che si sono generati durante tutti gli UnHook eseguiti ( la funzione ha     |
|      1mantenuto correttamente aggiornato l'Array associativo Event Hook ); è possibile chiamare HookEvent( "", "", "" ) per      |
|      ottenere l'Array associativo Event Hook e capire quali Event Hook sono attualmente attivi.                                  |
|                                                                                                                                  |
|==================================================================================================================================|
*/

UnHookEvent( sFunctionName := "", iEvent := 0 , iPID := 0 )
{

    iIdx := -1                                                       ; Inizializzazione puntatore dell'Array aiDeletedList.
                                                                     ; Viene inizializzato -1 perché la prima operazione che lo
                                                                     ; utilizza lo incrementa ++iIdx come indice dell'Array, che
                                                                     ; quindi in quel caso punta a partire da 0.
    , aiDeletedList := []                                            ; Dichiarazione Array che conterrà tutti gli hook eliminati
                                                                     ; tramite UnHook; serve alla fine per cancellare i
                                                                     ; corrispondenti elementi nell'Array associativo asHookTable.
    , asHookTable := HookEvent( "", "", "" )                         ; Chiamata funzione HookEvent( ... ) con tutti gli Argomenti
                                                                     ; obbligatori "" in modo che restituisca l'array associativo
                                                                     ; asHookTable.
    , iUnHookFails := -1                                             ; Inizializzazione variabile conteggio numero di errori di
                                                                     ; UnHook.
                                                                     ; Il valore iniziale -1 indica che per ora non è stato ancora
                                                                     ; eseguito nessun tentativo di UnHook.
    For hHook, sDefinedEvent in asHookTable                          ; Ciclo di UnHook per tutti gli Event Hook che corrispondono
    {                                                                ; alle caratteristiche specificate dagli Argomenti di chiamata
                                                                     ; sFunctionName, iEvent, iPID.
                                                                     ; Inserisco nella variabile hHook la chiave successiva
                                                                     ; dell'Array associativo asHookTable; inserisco nella variabile
                                                                     ; sDefinedEvent il vaore associato alla chiave: tale valore è
                                                                     ; un Record composto da 3 campi con separatore " ":
                                                                     ; Campo 1: nome della funzione UDF che viene chiamata
                                                                     ;          automaticamente ( in modo asincrono ) al momento in
                                                                     ;          cui si genera l'evento;
                                                                     ; Campo 2: costante Evento che genera la chiamata asincrona
                                                                     ;          alla Funzione specificata nel Campo 1;
                                                                     ; Campo 3: Process ID ( PID ) relativo al processo di cui si
                                                                     ;          deve intercettare l'evento.

        iUnHookFails := ( iUnHookFails == -1 ) ? 0 : iUnHookFails    ; Se iUnHookFails == -1 significa che sono appena entrato in
                                                                     ; questo ciclo di UnHook; set valore iniziale numero di errori
                                                                     ; di UnHook. Se iUnHookFails != -1 significa che il conteggio
                                                                     ; degli errori di UnHook è già iniziato, quindi non lo
                                                                     ; modifico.
        , iFirstSepPos := InStr( sDefinedEvent, " " )                ; Posizione primo separatore di campo all'interno del Record
                                                                     ; contenuto in sDefinedEvent.
        , iSecondSepPos := InStr( sDefinedEvent, " ",,, 2 )          ; Posizione secondo separatore di campo all'interno del Record
                                                                     ; contenuto in sDefinedEvent.
        , sFunctionNameAssigned := SubStr( sDefinedEvent, 1, iFirstSepPos - 1 )
                                                                     ; Nome della funzione UDF corrispondente a questo Event Hook;
                                                                     ; estratto dal Campo 1 del Record contenuto in sDefinedEvent.
        , iEventAssigned := SubStr( sDefinedEvent, iFirstSepPos + 1, iSecondSepPos - iFirstSepPos - 1 )
                                                                     ; Codice dell'Evento che genera la chiamata asincrona alla
                                                                     ; Funzione specificata nel Campo 1; estratto dal Campo 2 del
                                                                     ; Record contenuto in sDefinedEvent.
        , iPIDAssigned := SubStr( sDefinedEvent, iSecondSepPos + 1 ) ; Process ID ( PID ) relativo al processo di cui si deve
                                                                     ; intercettare l'evento; estratto dal Campo 2 del Record
                                                                     ; contenuto in sDefinedEvent.
        If((( sFunctionName == "" ) || ( sFunctionName = sFunctionNameAssigned )) && (( iEvent == 0 ) || ( iEvent == iEventAssigned )) && (( iPID == 0 ) || ( iPID == iPIDAssigned )))
                                                                     ; Se, per quanto riguarda gli Argomenti specificati nella
                                                                     ; chiamata, che definiscono le condizioni di ricerca per
                                                                     ; effettuare UnHook, cioè la chiusura dell'Event Hook
                                                                     ; precedentemente generato:
                                                                     ; - il nome di Funzione UDF è "" ( e quindi non è stato
                                                                     ;   definito ) oppure, se è stato definito corrisponde al nome
                                                                     ;   di Funzione UDF corrispondente a questo Event Hook
                                                                     ;   ( confronto Case Insensitive );
                                                                     ; E
                                                                     ; - il codice di Evento è 0 ( e quindi non è stato definito )
                                                                     ;   oppure, se è stato definito corrisponde al Codice di Evento
                                                                     ;   che genera la chiamata asincrona alla Funzione specificata
                                                                     ;   nel Campo 1;
                                                                     ; E
                                                                     ; - il Process ID ( PID ) è 0 ( e quindi non è stato definito )
                                                                     ;   oppure, se è stato definito corrisponde al PID relativo al
                                                                     ;   processo di cui si deve intercettare l'evento.
            ( DllCall( "UnhookWinEvent", UInt, hHook ) == 1 ) ? ( aiDeletedList[ ++iIdx ] := hHook ) : ++iUnHookFails
                                                                     ; Chiamo la funzione di UnHook per questo Event Hook, leggo il
                                                                     ; risultato della funzione ( che può essere 0 oppure 1 ) e:
                                                                     ; - se è 1, cioè la funzione ha funzionato senza errori,
                                                                     ;   aggiungo questo Event Hook nell'Array di tutti gli Event
                                                                     ;   Hook eliminati;
                                                                     ; - se è 0, cioè la funzione ha riportato errore, incremento di
                                                                     ;   1 il conteggio degli errori di UnHook.

    }                                                                ; For hHook, sDefinedEvent in asHookTable
    asHookTable := HookEvent( " ", aiDeletedList, ++iIdx )           ; Chiamata funzione HookEvent( ... ) con sFunctionName
                                                                     ; assegnato " " ( che è un nome di funzione non valido ) per
                                                                     ; richiedere di effettuare la cancellazione degli elementi
                                                                     ; dell'Array associativo asHookTable che sono stati oggetto di
                                                                     ; UnHook ( l'Array associativo asHookTable presente in questa
                                                                     ; Funzione è solo una copia locale dell'Array vero, dichiarato
                                                                     ; Static all'interno della Funzione HookEvent( ... )); l'Array
                                                                     ; aiDeletedList contenente tutti gli Event Hook da eliminare lo
                                                                     ; passo come secondo Argomento; il numero di elementi presenti
                                                                     ; in aiDeletedList lo passo come terzo Argomento ( incremento
                                                                     ; di 1 il puntatore iIdx perché è l'indirizzo dell'Array e
                                                                     ; inizia da 0; il valore che devo passare invece è il numero di
                                                                     ; elementi presenti nell'Array, che inizia da 1 ).

    Return iUnHookFails                                              ; Ritorno il numero di errori di UnHook che si sono verificati.
                                                                     ; 0  indica nessun errore, quindi tutto OK;
                                                                     ; -1 indica che per qualche motivo non è stato effettuato
                                                                     ;    nessun tentativo di UnHook; la causa più probabile è che
                                                                     ;    questa funzione è stata chiamata prima della
                                                                     ;    corrispondente funzione HookEvent( ... ).
                                                                     ; Qualsiasi altro numero intero indica il numero di errori di
                                                                     ; UnHook che si sono verificati, e per i quali non è stato
                                                                     ; effettuato il corrispondente UnHook.

}                                                                    ; UnHookEvent( sFunctionName := "", iEvent := 0 , iPID := 0 )
