
#MESSY

##Comportamiento de los distintos módulos

###### Client

El client necesitara unicamente 2 datos para funcionar:
-Nombre de host
-Puerto

Sus funciones son:

-Emit: envia el mensaje al servidor.
-Subscribe: envia la peticion de suscripcion al servidor del canal deseado.
-Desubscribe: envia la peticion de revocar la suscripcion al servidor 
del canal deseado.
-Msg: procesa el mensaje recibido, depende de la implementación que se haga en cada caso puntual. En este tp se imprime el mensaje en pantalla.
-Disconect: se desconecta del server.

###### Server

-Register: se registra en el router.
-Brothers: mediante este mensaje conoce a los demas servers.
-Subscribe: subscribe al cliente en un determinado channel.
-Emit: envía mensaje del cliente, y comunica a los demás servers de este mensaje.
-Connect: el server comienza a escuchar peticiones del cliente.
-Broadcast: informa que se debe realizar un envio de un mensaje a todos los clientes conectados.


###### Router

-Register: registra al server. Esto significa que este server esta disponible para ser designado a un cliente.
-Unregister: Elimina el servidor.
-Request: mensaje por el cual un cliente se conecta al servicio. Este le asigna un server al cliente.

###### Sender

- Send: envia mensaje al cliente.

##DOCUMENTACION

###### Server

Este modulo se encarga de escuhar las peticiones de los clientes, ya sea emitir un mensaje o hacer broadcast de un mensaje. También recibe mensajes del estilo state que da a conocer el stado de subscripciones y los clientes conectados. El servidor conoce a todos los servidores conectados, de esta forma los mensajes se propagan entre los channels que se encuentra de forma distribuida en distintos servidores.
Cuando un cliente se cae, el server lo elimina de las subscripciones. El cliente debera volver a conectarse para poder seguir funcionando.

###### Client

El cliente podra Suscribirse, Revocar suscripciones y emitir a un canal especifico. Se conecta mediante el router, el cual le pide la conexion y este le asigna un server. El cliente tiene el poder desconectarse del servidor, eliminandose de las subscripcion.

###### Router

Maneja a los servidores, asignadolos a un cliente. Es el punto de unificacion entre los servers, y la interfaz para que el cliente se pueda conectar y el servidor se pueda registrar.

###### Sender

El sender es un modulo ampliable, lo que hace en esta implementacion es delegar el mensaje en el cliente, siendo un pasamanos entre el servidor y el cliente cuando este emite un mensaje.


## Diseño
<div align="center">
        <img width="50%" src="Flujo de proceso/Sistemas distribuidos.jpg" title="Diseño"</img>
        <img height="50%" width="8px">
</div>

<div align="center">
        <img width="50%" src="Flujo de proceso/pas2.jpg" title="Diseño2"</img>
        <img height="50%" width="8px">
</div>

<div align="center">
        <img width="50%" src="Flujo de proceso/pas3.jpg" title="Diseño3"</img>
        <img height="50%" width="8px">
</div>

#Como correrlo:

consola router
```erlang
erl -name router@ip -setcookie asd
R = router:start().
```
consola server
```erlang
erl -name server@ip -setcookie asd
S = server:start().
{router,'router@ip'} ! {register, S}.
```
consola cliente A
```erlang
erl -name clienteA@ip -setcookie asd
Cliente = client:start({router,'router@ip')).
Client ! {subscribe, "#"}.
```
consola cliente B
```erlang
erl -name clienteB@ip -setcookie asd
Cliente = client:start({router,'router@ip')).
Client ! {emit,"#","Mansae"}.
```

La consola del cliente A deberia imprimir:

```
(ClienteA@ip)>Mensaje recibido: Mansae
```



#Ejemplo con 2 servers y 3 clientes:

Router

```erlang
Marina:Code mrivero$ erl -name router@192.168.0.104 -setcookie secret
Erlang/OTP 18 [erts-7.1] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Eshell V7.1  (abort with ^G)
(router@192.168.0.104)8> R = spawn(router, start, []).
<0.75.0>
(router@192.168.0.104)9> 
(router@192.168.0.104)9> 
(router@192.168.0.104)9> 
register server with PID: <10085.42.0>
register server with PID: <10086.42.0>
(router@192.168.0.104)9> 
(router@192.168.0.104)9> 
(router@192.168.0.104)9> 
server requested from client: <10087.41.0>
Server to connect: <10086.42.0>
server requested from client: <10091.41.0>
Server to connect: <10085.42.0>
server requested from client: <10092.41.0>
Server to connect: <10085.42.0>
```

Server 1
```erlang
Marina:Code mrivero$ erl -name server@192.168.0.104 -setcookie secret
Erlang/OTP 18 [erts-7.1] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Eshell V7.1  (abort with ^G)
(server@192.168.0.104)1> S = server:start().          
<0.42.0>
(server@192.168.0.104)2> {router, 'router@192.168.0.104'} ! {register, S}.
{register,<0.42.0>}
Brother List: []         
Brother added: <7385.42.0>
Client subscripted: <7387.41.0>
Client subscripted: <7388.41.0>
Emit recibed from another server 
Emitiendo                
Emitiendo                
Emit recibed from another server 
Emitiendo                
Emit recibed from another server 
```

Server 2
```erlang
Marina:Code mrivero$ erl -name server2@192.168.0.104 -setcookie secret
Erlang/OTP 18 [erts-7.1] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Eshell V7.1  (abort with ^G)
(server2@192.168.0.104)1> SS = server:start().
<0.42.0>
(server2@192.168.0.104)2> {router, 'router@192.168.0.104'} ! {register, SS}.
{register,<0.42.0>}
Brother List: [<7387.42.0>]
Client subscripted: <7388.41.0>
Emitiendo                 
Emit recibed from another server 
Client subscripted: <7388.41.0>
Emit recibed from another server 
Emitiendo                 
Emit recibed from another server 
Emitiendo      
```

Cliente 1
```erlang
Marina:Code mrivero$ erl -name client@192.168.0.104 -setcookie secret
Erlang/OTP 18 [erts-7.1] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Eshell V7.1  (abort with ^G)
(client@192.168.0.104)1> Soraya = client:start({router, 'router@192.168.0.104'}).
Conectando a Router {router,'router@192.168.0.104'}
<0.41.0>
(client@192.168.0.104)2> Soraya ! {subscribe, "Nandito"}.                        
{subscribe,"Nandito"}
(client@192.168.0.104)3> Soraya ! {emit, "Nandito", "Te dije que no te metieras con el, pero lo hiciste! MAldita lisiada del demonio!"}.
{emit,"Nandito",
      "Te dije que no te metieras con el, pero lo hiciste! MAldita lisiada del demonio!"}
Mensaje recibido: "Soraya nooo"
(client@192.168.0.104)4> Soraya ! {subscribe, "LaLocaSoraya"}.                                                                          
{subscribe,"LaLocaSoraya"}
Mensaje recibido: "No te metas con mi niña!"                  
(client@192.168.0.104)5> Soraya ! {emit, "LaLocaSoraya", "Sal de aqui vieja zorra"}.                                                    
{emit,"LaLocaSoraya","Sal de aqui vieja zorra"}
Mensaje recibido: "Nooo noooo"
(client@192.168.0.104)6> Soraya ! {emit, "Nandito", "Escuincla babosaaa"}.          
{emit,"Nandito","Escuincla babosaaa"}
```

Cliente 2
```erlang
Marina:Code mrivero$ erl -name clientdos@192.168.0.104 -setcookie secret
Erlang/OTP 18 [erts-7.1] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Eshell V7.1  (abort with ^G)
(clientdos@192.168.0.104)1> Alicia = client:start({router, 'router@192.168.0.104'}). 
Conectando a Router {router,'router@192.168.0.104'}
<0.41.0>
(clientdos@192.168.0.104)2> Alicia ! {subscribe, "Nandito"}.
{subscribe,"Nandito"}
Mensaje recibido: "Te dije que no te metieras con el, pero lo hiciste! MAldita lisiada del demonio!"
(clientdos@192.168.0.104)3> Alicia ! {emit, "Nandito", "Soraya nooo"}.
{emit,"Nandito","Soraya nooo"}
(clientdos@192.168.0.104)4> Alicia ! {emit, "Nandito", "Nooo noooo"}. 
{emit,"Nandito","Nooo noooo"}
Mensaje recibido: "Escuincla babosaaa"
```

Cliente 3
```erlang
Marina:Code mrivero$ erl -name clienttres@192.168.0.104 -setcookie secret
Erlang/OTP 18 [erts-7.1] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Eshell V7.1  (abort with ^G)
(clienttres@192.168.0.104)1> LaViejaZorra = client:start({router, 'router@192.168.0.104'}).
Conectando a Router {router,'router@192.168.0.104'}
<0.41.0>
(clienttres@192.168.0.104)2> LaViejaZorra ! {subscribe, "LaLocaSoraya"}.
{subscribe,"LaLocaSoraya"}
(clienttres@192.168.0.104)3> LaViejaZorra ! {emit, "LaLocaSoraya", "No te metas con mi niña!"}.
{emit,"LaLocaSoraya","No te metas con mi niña!"}
Mensaje recibido: "Sal de aqui vieja zorra"
```




# Sobre MQTT

### What is MQTT?
MQTT stands for MQ Telemetry Transport. It is a publish/subscribe, extremely simple and lightweight messaging protocol, designed for constrained devices and low-bandwidth, high-latency or unreliable networks. The design principles are to minimise network bandwidth and device resource requirements whilst also attempting to ensure reliability and some degree of assurance of delivery. These principles also turn out to make the protocol ideal of the emerging “machine-to-machine” (M2M) or “Internet of Things” world of connected devices, and for mobile applications where bandwidth and battery power are at a premium.
### Who invented MQTT?
MQTT was invented by Dr Andy Stanford-Clark of IBM, and Arlen Nipper of Arcom (now Eurotech), in 1999.
### Where is MQTT in use?
MQTT has been widely implemented across a variety of industries since 1999. A few of the more interesting examples are listed on the Projects page.
### Is MQTT a standard?
As of March 2013, MQTT is in the process of undergoing standardisation at OASIS.
The protocol specification has been openly published with a royalty-free license for many years, and companies such as Eurotech (formerly known as Arcom) have implemented the protocol in their products.
In November 2011 IBM and Eurotech announced their joint participation in the Eclipse M2M Industry Working Group and donation of MQTT code to the proposed Eclipse Paho project.
### How does MQTT relate to SCADA protocol and MQIsdp?
The “SCADA protocol” and the “MQ Integrator SCADA Device Protocol” (MQIsdp) are both old names for what is now known as the MQ Telemetry Transport (MQTT). The protocol has also been known as “WebSphere MQTT” (WMQTT), though that name is also no longer used.
### What is WebSphere MQ Telemetry?
This is a product from IBM which implements the MQTT protocol in a very scalable manner and which interoperates directly with the WebSphere MQ family of products.
There are other implementations of MQTT listed on the Software page.
Are there standard ports for MQTT to use?
Yes. TCP/IP port 1883 is reserved with IANA for use with MQTT. TCP/IP port 8883 is also registered, for using MQTT over SSL.
### Does MQTT support security?
You can pass a user name and password with an MQTT packet in V3.1 of the protocol. Encryption across the network can be handled with SSL, independently of the MQTT protocol itself (it is worth noting that SSL is not the lightest of protocols, and does add significant network overhead). Additional security can be added by an application encrypting data that it sends and receives, but this is not something built-in to the protocol, in order to keep it simple and lightweight.
### Where can I find out more?
The specification and other documentation are available via the Documentation page.
Ask questions via one of the methods on the Community page.
Try code via one of the projects on the Software page.
Follow us on Twitter @mqttorg.