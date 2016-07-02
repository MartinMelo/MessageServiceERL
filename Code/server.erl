-module(server).
-export([start/0, start/1]).


start()->
  Configuracion = configuracionDefault(),
  Sender = sender:start(),
  spawn(fun() -> init([],[],[],Sender) end).

start(Configuracion)->
  Sender = sender:start(),
  spawn(fun() -> init([],[],[],Sender) end).

configuracionDefault()->
  [].

init(Suscripciones, Clientes, MensajesPorEnviar, Sender)->
  loop(Suscripciones, Clientes, MensajesPorEnviar, Sender).


loop(Suscripciones, Clientes, Servers, MensajesPorEnviar, Sender)->
  receive
    {addServer, Server}->
      loop(Suscripciones, Clientes, [Server | Servers], MensajesPorEnviar, Sender);
    {removeServer, Server}->
      ListaNueva = removerServer(Server, Servers),
      loop(Suscripciones, Clientes, ListaNueva, MensajesPorEnviar, Sender);
    {subscribe, {Channel, Client}}->
      NuevasSuscripciones = suscribir(Suscripciones, Channel, Client,Servers),
      loop(NuevasSuscripciones, Clientes, Servers, MensajesPorEnviar, Sender);
    {unsubscribe, {Channel, Client}}->
      NuevasSuscripciones = desuscribir(Suscripciones, Channel, Client,Servers),
      loop(NuevasSuscripciones, Clientes, Servers, MensajesPorEnviar, Sender);
    {emit, {Channel, Client, Message}}->
      emitir(Channel, Suscripciones, Client, Message, Sender,Servers),
      loop(Suscripciones, Clientes, Servers, MensajesPorEnviar, Sender);
    {emit, {Channel, Client, Message, imServer}}->
      emitir(Channel, Suscripciones, Client, Message, Sender,Servers),
      loop(Suscripciones, Clientes, Servers, MensajesPorEnviar, Sender)
  end.

%Remueve el server de la lista de servers.
removerServer(Server, Servers)->
  lists:keydelete(Server, 1, Servers).

%Suscribe el cliente al channel deseado.
suscribir(Suscripciones, Channel, Client, Servers)->
  suscribirEnTodosLosServers(Suscripciones, Channel, Client,Servers),
  %Buscar si existe la suscripcion en la lista.
  %Si existe agregarlo en la lista y si no crear el channel y ponerla.
  case dict:find(Channel, Suscripciones) of
    {ok, SuscripcionesDelCanal} ->
        case lists:keyfind(Client,1,SuscripcionesDelCanal) of
          false ->
              list:append(Client, SuscripcionesDelCanal)
        end;
    error ->
        dict:append(Channel, [Client], Suscripciones)
  end.
suscribirEnTodosLosServers(Suscripciones, Channel, Client,Servers)->ok.


%desuscribe el cliente del channel deseado.
desuscribir(Suscripciones, Channel, Client, Servers)->
  desuscribirEnTodosLosServers(Suscripciones, Channel, Client,Servers),
  %Buscar el channel en la lista y borrar el client del channel.
  case dict:find(Channel, Suscripciones) of
    {ok, SuscripcionesDelCanal} ->
      list:keydelete(Client,1,SuscripcionesDelCanal);
    error->Suscripciones
  end.

desuscribirEnTodosLosServers(Suscripciones, Channel, Client,Servers)->ok.

emitir(Channel, Suscripciones, Client, Message, Sender, Servers)->
  emitirAServers(Channel, Suscripciones, Client, Message, Sender, Servers),
  ClientesSuscriptos = obtenerClienteSuscriptos(Channel, Suscripciones,Client),
  emitirAClientes(ClientesSuscriptos,Message,Sender).

emitir(Channel, Suscripciones, Client, Message, Sender)->
  ClientesSuscriptos = obtenerClienteSuscriptos(Channel, Suscripciones,Client),
  emitirAClientes(ClientesSuscriptos,Message,Sender).

obtenerClienteSuscriptos(Channel, Suscripciones, Client)->
  %Informar que hay para emitir.
  case dict:find(Channel, Suscripciones) of
    {ok, SuscripcionesDelCanal} -> SuscripcionesDelCanal;%Sacar el cliente de la lista, para no recibir lo que envio.
    error-> []
  end.

emitirAClientes(ClientesSuscriptos,Message,Sender)->ok.
emitirAServers(Channel, Suscripciones, Client, Message, Sender, Servers)->ok.