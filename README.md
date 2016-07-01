
#COMPORTAMIENTO DE LOS DISTINTOS MODULOS

### client:

El client necesitara unicamente 2 datos para funcionar:
-Nombre de host
-Puerto

Sus funciones son:

-Emit: Envia el mensaje al servidor.
-Subscribe: Envia la peticion de suscripcion al servidor del canal deseado.
-Desubscribe: Envia la peticion de revocar la suscripcion al servidor 
del canal deseado.88i  mmmiuikki

### server:



#DOCUMENTACION

## Server
El server recibira 4 mensajes basicos:

### Subscribe
El cual informa que quien envia el mensaje desea ser suscripto a un canal especifico.
### Unsubscribe
El cual informa que quien envia el mensaje desea revocar su suscripcion a un canal especifico.
### Emit
El cual informa que se debe realizar un envio de un mensaje a todos los "Clientes" suscriptos a ese canal.
### Broadcast
El cual informa que se debe realizar un envio de un mensaje a todos los "Clientes" conectados.

## Client
El cliente podra Suscribirse, Revocar suscripciones y emitir a un canal especifico.

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
