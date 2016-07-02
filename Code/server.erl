-module(server).
-export([start/0]).


start()->
  Sender = sender:start(),
  spawn(fun() -> init([],[],Sender) end).

init(Suscripciones, Servers, Sender)->
  loop(Suscripciones, Servers,Sender).


loop(Suscripciones, Servers, Sender)->
  receive
    {brothers, ListaDeHermanos}->
      loop(Suscripciones, ListaDeHermanos, Sender);
    {addBrother, Server}->
      loop(Suscripciones, [Server | Servers], Sender);
    {removeBrother, Server}->
      ListaNueva = removerServer(Server, Servers),
      loop(Suscripciones, ListaNueva, Sender);
    {subscribe, {Channel, Client}}->
      NuevasSuscripciones = suscribir(Suscripciones, Channel, Client,Servers),
      loop(NuevasSuscripciones, Servers, Sender);
    {unsubscribe, {Channel, Client}}->
      NuevasSuscripciones = desuscribir(Suscripciones, Channel, Client,Servers),
      loop(NuevasSuscripciones, Servers, Sender);
    {emit, {Channel, Client, Message}}->
      emitir(Channel, Suscripciones, Client, Message, Sender,Servers),
      loop(Suscripciones, Servers, Sender);
    {emit, {Channel, Client, Message, imServer}}->
      emitir(Channel, Suscripciones, Client, Message, Sender),
      loop(Suscripciones, Servers, Sender);
    state ->
      imprimirEstado(Suscripciones, Servers)
  end.

imprimirEstado(Suscripciones, Servers)->
  io:format("Servers disponibles: ~n", Servers),
  io:format("Suscripciones disponibles: ~n", Suscripciones).
%Remueve el server de la lista de servers.
removerServer(Server, Servers)->
  lists:keydelete(Server, 1, Servers).

%Suscribe el cliente al channel deseado.
suscribir(Suscripciones, Channel, Client, Servers)->
  suscribirEnTodosLosServers(Channel, Client,Servers),
  %Buscar si existe la suscripcion en la lista.
  %Si existe agregarlo en la lista y si no crear el channel y ponerla.
  case dict:find(Channel, Suscripciones) of
    {ok, SuscripcionesDelCanal} ->
        case lists:keyfind(Client,1,SuscripcionesDelCanal) of
          false ->
              lists:append(Client, SuscripcionesDelCanal)
        end;
    error ->
        dict:append(Channel, [Client], Suscripciones)
  end.

suscribirEnTodosLosServers(Channel, Client,Servers)->
  lists:map(fun(Server)-> Server ! {subscribe, {Channel, Client}} end, Servers).

%desuscribe el cliente del channel deseado.
desuscribir(Suscripciones, Channel, Client, Servers)->
  desuscribirEnTodosLosServers(Suscripciones, Channel, Client,Servers),
  %Buscar el channel en la lista y borrar el client del channel.
  case dict:find(Channel, Suscripciones) of
    {ok, SuscripcionesDelCanal} ->
      lists:keydelete(Client,1,SuscripcionesDelCanal);
    error->Suscripciones
  end.

desuscribirEnTodosLosServers(Suscripciones, Channel, Client,Servers)->
  lists:map(fun(Server)-> Server ! {unsubscribe, {Channel, Client}} end, Servers).

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

emitirAClientes(ClientesSuscriptos,Message,Sender)->
  lists:map(fun(Cliente)-> Sender ! {send, {Cliente, Message}} end, ClientesSuscriptos).

emitirAServers(Channel, Suscripciones, Client, Message, Sender, Servers)->
  lists:map(fun(Server)-> Server ! {emit, {Channel, Client, Message, imServer}} end, Servers).








