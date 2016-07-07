-module(server).
-export([start/0]).


start()->
  Sender = sender:start(),
  spawn(fun() -> init(subscripter:new(),[],[],Sender) end).

init(Suscripciones, Servers, Clients, Sender)->
  loop(Suscripciones, Servers,Clients,Sender).


loop(Suscripciones, Servers,Clients, Sender)->
  receive
    {register, Router} ->
      io:format("Registering~n"),
      Router ! {register, self()},
      loop(Suscripciones, Servers, Clients , Sender);
    {brothers, ListaDeHermanos}->
      io:format("Brother List: ~p~n", [ListaDeHermanos]),
      loop(Suscripciones, ListaDeHermanos, Clients , Sender);
    {addBrother, Server}->
      io:format("Brother added: ~p~n", [Server]),
      loop(Suscripciones, [Server | Servers], Clients , Sender);
    {removeBrother, Server}->
      io:format("Brother removed: ~p~n", [Server]),
      ListaNueva = removerServer(Server, Servers),
      loop(Suscripciones, ListaNueva, Clients , Sender);
    {subscribe, {Channel, Client}}->
      io:format("Client subscripted: ~p~n", [Client]),
      NuevasSuscripciones = suscribir(Suscripciones, Channel, Client),
      loop(NuevasSuscripciones, Servers, Clients , Sender);
    {unsubscribe, {Channel, Client}}->
      io:format("Client unsubscripted: ~p~n", [Client]),
      NuevasSuscripciones = desuscribir(Suscripciones, Channel, Client),
      loop(NuevasSuscripciones, Servers, Clients , Sender);
    {emit, {Channel, Client, Message}}->
      io:format("Emitiendo ~n"),
      emitir(Channel, Suscripciones, Client, Message, Sender,Servers),
      loop(Suscripciones, Servers, Clients , Sender);
    {emit, {Channel, Client, Message, imServer}}->
      io:format("Emit recibed from another server ~n"),
      emitir(Channel, Suscripciones, Client, Message, Sender),
      loop(Suscripciones, Servers, Clients , Sender);
    {'DOWN', _ , process, Client, Info} ->
      io:format("~w Disconnected; ~w~n", [Client, Info]),
      io:format("Cleaning subscription from client ~n"),
      NuevasSuscripciones = subscripter:unsubscribeAll(Client, Suscripciones),
      NuevosClientes = lists:delete(Client,Clients),
      loop(NuevasSuscripciones, Servers,NuevosClientes,Sender);
    {connect, Client}->
      monitor(process, Client),
      loop(Suscripciones,Servers,[Client | Clients],Sender);
    {disconnect, Client}->
      io:format("Client ~w Disconnected; ~n", [Client]),
      io:format("Cleaning subscription from client ~n"),
      NuevasSuscripciones = subscripter:unsubscribeAll(Client, Suscripciones),
      NuevosClientes = lists:delete(Client,Clients),
      loop(NuevasSuscripciones,Servers,NuevosClientes,Sender);
    cleanSubs ->
      loop(subscripter:new(), Servers, Clients , Sender);
    state ->
      io:format("State ~n"),
      imprimirEstado(Suscripciones, Servers, Clients),
      loop(Suscripciones,Servers,Clients,Sender)
  end.

imprimirEstado(Suscripciones, Servers,Clients)->
  io:format("Servers disponibles: ~p~n", [length(Servers)]),
  io:format("Clientes conectados: ~p~n", [length(Clients)]),
  io:format("Suscripciones disponibles: ~p~n", [length(dict:fetch_keys(Suscripciones))]).

%Remueve el server de la lista de servers.
removerServer(Server, Servers)->
  lists:keydelete(Server, 1, Servers).

%Suscribe el cliente al channel deseado.
suscribir(Suscripciones, Channel, Client)->
  subscripter:subscribe(Channel, Client, Suscripciones).

%desuscribe el cliente del channel deseado.
desuscribir(Suscripciones, Channel, Client)->
  subscripter:unsubscribe(Channel,Client,Suscripciones).

emitir(Channel, Suscripciones, Client, Message, Sender, Servers)->
  emitirAServers(Channel, Client, Message, Sender, Servers),
  ClientesSuscriptos = obtenerClienteSuscriptos(Channel, Suscripciones,Client),
  emitirAClientes(ClientesSuscriptos,Message,Sender).

emitir(Channel, Suscripciones, Client, Message, Sender)->
  ClientesSuscriptos = obtenerClienteSuscriptos(Channel, Suscripciones,Client),
  emitirAClientes(ClientesSuscriptos,Message,Sender).

obtenerClienteSuscriptos(Channel, Suscripciones, Client)->
  subscripter:clientesSubscriptos(Channel, Suscripciones,Client).

emitirAClientes(ClientesSuscriptos,Message,Sender)->
  lists:map(fun(Cliente)-> Sender ! {send, {Cliente, Message}} end, ClientesSuscriptos).

emitirAServers(Channel,Client, Message, Sender, Servers)->
  lists:map(fun(Server)-> Server ! {emit, {Channel, Client, Message, imServer}} end, Servers).








