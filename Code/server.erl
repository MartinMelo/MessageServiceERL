-module(server).
-export([start/0, start/1]).


start()->
  Configuracion = configuracionDefault(),
  Sender = sender:start(),
  spawn(fun() -> init([],[],[],0,Configuracion,Sender) end).

start(Configuracion)->
  Sender = sender:start(),
  spawn(fun() -> init([],[],[],0,Configuracion,Sender) end).

configuracionDefault()->
  [].

init(Suscripciones, Clientes, MensajesPorEnviar, IdMensajeSiguiente, Configuracion,Sender)->
  loop(Suscripciones, Clientes, MensajesPorEnviar, IdMensajeSiguiente, Configuracion,Sender).


loop(Suscripciones, Clientes, MensajesPorEnviar, IdMensajeSiguiente, Configuracion,Sender)->
  receive
    {subscribe, {Channel, Client}}->
      NuevasSuscripciones = suscribir(Suscripciones, Channel, Client),
      loop(NuevasSuscripciones, Clientes, MensajesPorEnviar, IdMensajeSiguiente, Configuracion,Sender);
    {unsubscribe, {Channel, Client}}->
      NuevasSuscripciones = suscribir(Suscripciones, Channel, Client),
      loop(NuevasSuscripciones, Clientes, MensajesPorEnviar, IdMensajeSiguiente, Configuracion,Sender);
    {emit, {Channel, Client, Message}}->
      emitir(Channel, Client, Message),
      loop(Suscripciones, Clientes, MensajesPorEnviar, IdMensajeSiguiente, Configuracion,Sender);
    {broadcast, {Client, Message}}->
      broadcastear,
      loop(Suscripciones, Clientes, MensajesPorEnviar, IdMensajeSiguiente, Configuracion,Sender)
  end.

suscribir(Suscripciones, Channel, Client)->
  %Buscar si existe la suscripcion en la lista.
  %Si existe agregarlo en la lista y si no crear el channel y ponerla.
  ok.
desuscribir(Suscripciones, Channel, Client)->
  %Buscar el channel en la lista y borrar el client del channel.
  ok.

emitir(Channel, Client, Message)->
  %Informar que hay para emitir.
  ok.