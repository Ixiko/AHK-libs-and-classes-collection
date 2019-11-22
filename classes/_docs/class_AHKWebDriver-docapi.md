# AHKWebdriver API

Lo primero es crear una sessión. 

Al crear la sesión se abre un vetana del navegador nueva (esto puede tardar un poco). 

Todos los comandos afectan a la ventana "por defecto", o sea la actual. Podemos crear mas ventanas y activarlas cambiando la ventana actual para que las siguientes llamadas se ejecuten sobre la ventana elegida.

Una vez en la ventana podemos obtener cualquier elemento web, este elemento estará disponible mientras exista la session y la ventana que lo contenga no esté cerrada y aunque activemos otra ventana.

## Retorno de las operaciones

Aunque cada llamada devuelve su propio retorno, siempre, se llena un atributo llamado llamado "rc" dentro de la sesión o del elemento donde se encuentran todos los datos del resultado.

Para comprobar si la operación ha ido bien o mal se utiliza rc.isError (boolean).

Este objetos contiene, además, otros atributos que sirven para depurar:
- rc.status: status web devuelto
- rc.raw: cadena json conteniendo el mensaje devuelto por el driver. 

Y finalmente contiene el atributo "value" con el objeto json devuelto por el driver.

En caso de error se pueden consultar los atributos "error" y "message", o sea, rc.value.error y rc.value.message.

En caso de que no, "value" contendrá, en función de la llamada, desde "" (null) hasta objetos complejos.

## crear/finalizar Sesión

* __new WDSession(location:="http://localhost:9515/", capabilities:="")__: instancia una nueva sesión siendo location la URL del Web Driver. opcionalmente se puede pasar un objeto con las capacidades que el driver pueda necesitar. 
* __delete()__: Finaliza la sessión y cierra la ventana. La sessión queda inutilizada y no se puede volver a usar.

## Llamadas concernientes a la "ventana del navegador"

### Navegar
* __url(url)__: Cargar a una url nueva en la ventana actual. Parametro _url_ (String) conteniene la dirección a cargar. Devuelve _true/false_.
* __getUrl()__: Devuelve la _url_ (String) de la pagina actual.
* __getTitle()__: Devuelve el _título_ (String) de la ventana actual.

### Obtener elementos de la pagina
Estos elementos tienen un api propia mas abajo.

* __getElementActive()__: Devuelve un elemento web en formato de clase WDSession.WDElement.
* __element(selector, value)__: Devuelve el primer objeto que cumpla el valor dado del selector.
* __elements(selector, value)__: Devuelve todos los objetos encontrados que cumplan el valor.

### Crear, obtener ventans
* __newWindow(type)__: Añade una ventana de navegador nueva a la sesión. El parametro _type_  puede ser "tab" (por defecto) o "window", e indica si se crea una pagina o una ventana nueva. _tab/window_ dependerán de la implementación del driver. Devuelve un _hadle_ (String) de ventana.
* __window(handle)__:  Activa una ventana de navegador. Parametro _handle_ (String) es la ventana a activar siendo un valor devuelto por _getWidnowHandles_ o _newWindow_. Devuelve _true/false_.
* __getWindow()__: Devuelve el _handle_ (String) de la ventana actual.
* __getWindowHandles()__: Devuelve un array de autohotkey con todos los _handle_ (String) de las ventanas de la sesión.
* __closeWindow()__: Cierra la ventana actual, e invalida el _handle_ correspondiente. Devuelve _true/false_.

### Tamaño y posición
* __getWindowRect()__: Devuelve la posición y el tamaño de la ventana en un objeto que contiene los atributos _x_,_y_ coordenadas del origen, _width_,_height_ ancho y alto de la ventana (en pixeles). O nulo en caso de error.
* __windowMaximize()/windowMinimize()/windowFullscreen()__: Maximiza, minimiza o pasa a pantalla completa la ventana actual. Devuelven _true/false_.
* __windowRect(x:="", y:="", width:="", height:="")__: Asigna posición y/o tamaño a la ventana actual. 
_x_,_y_ coordenadas del origen, _width_,_height_ ancho y alto de la ventana (en pixeles). Si _x_ es un objeto se utilizará directamente, este objeto ha de contener los mismos atributos.

### Historial
* __back()__: Carga la pagina anterior del historial. Devuelve _true/false_.
* __forward()__: Carga la pagina siguiente del historial. Devuelve _true/false_.
* __refresh()__: Refresca la ventana actual. Devuelve _true/false_.

### Frames
* __frame(id:="")__: Activa un frame en la ventana actual. _id_ si es "" activa el frame top. si es un numero, activa dicho frame. En caso de que sea un Web Elemento activa dicho elemento (si es frame o iframe).Devuelve _true/false_.
* __frameParent()__: Activa el frame padre del actual. Devuelve _true/false_.

### Javascript
* __execute(script, args:="", sync:="sync")__: Ejecuta el cotenido de _script_ usnado un array de _args_ que luego estarán disponibles en el código como _arguments[0..n]_. El modo por defecto es _WDSession.sync_, aunque se puede ejecutar asyncronamente pasando como valor de sync _WDSession.async_.

### Cookies
* __getAllCookies()__: Devuelve la lista (Array autohotkey) de cookies. Un objeto por cada una conteniendo los atributos name, value, path, domain, secure, httpOnly, y expiry. 
* __getCookie(name)__: _name_ (String) es el nombre de la cookie. Devuelve los datos de una cookie en un objeto con los atributos anteriores.
* __cookie(name,value,path:="",domain:="",secure:="",httpOnly:="",expiry:="")__: Crea una cookie nueva, _name_,_value_ son obligatorios, el resto opcional. Devuelve _true/false_.
* __delCookie(name)__: _name_ (String) es el nombre de la cookie a borrar. Devuelve _true/false_.
* __delAllCookies()__: borra todas la cookies. Devuelve _true/false_.

### Mensaje de Alerta
* __alertDismiss()__: Si hay, cancela una alerta (boton cancelar). Devuelve _true/false_.
* __alertAccept()__: Si hay, acepta una alerta (boton aceptar). Devuelve _true/false_.
* __getAlertText()__: Si hay alerta, devuelve el texto contenido en la alerta. Devuelve _true/false_.

### Depurar
* __getSource()__: Devuelve una cadena (String) conteniendo el codigo fuente de la pagina.
* __getScreenshot()__: Devuelve en Base64 el PNG de la pantalla capturada.
