-module(server).
-export([start/0]).


start()->
  Sender = sender:start(),
  spawn(fun() -> init(dict:new(),[],Sender) end).

init(Suscripciones, Servers, Sender)->
  loop(Suscripciones, Servers,Sender).


loop(Suscripciones, Servers, Sender)->
  receive
    {register, Router} ->
      io:format("Registering~n"),
      Router ! {register, self()},
      loop(Suscripciones, Servers, Sender);
    {brothers, ListaDeHermanos}->
      io:format("Brother List: ~p~n", [ListaDeHermanos]),
      loop(Suscripciones, ListaDeHermanos, Sender);
    {addBrother, Server}->
      io:format("Brother added: ~p~n", [Server]),
      loop(Suscripciones, [Server | Servers], Sender);
    {removeBrother, Server}->
      io:format("Brother removed: ~p~n", [Server]),
      ListaNueva = removerServer(Server, Servers),
      loop(Suscripciones, ListaNueva, Sender);
    {subscribe, {Channel, Client}}->
      io:format("Client subscripted: ~p~n", [Client]),
      NuevasSuscripciones = suscribir(Suscripciones, Channel, Client,Servers),
      loop(NuevasSuscripciones, Servers, Sender);
    {unsubscribe, {Channel, Client}}->
      io:format("Client unsubscripted: ~p~n", [Client]),
      NuevasSuscripciones = desuscribir(Suscripciones, Channel, Client,Servers),
      loop(NuevasSuscripciones, Servers, Sender);
    {emit, {Channel, Client, Message}}->
      io:format("Emitiendo ~n"),
      emitir(Channel, Suscripciones, Client, Message, Sender,Servers),
      loop(Suscripciones, Servers, Sender);
    {emit, {Channel, Client, Message, imServer}}->
      io:format("Emit recibed from another server ~n"),
      emitir(Channel, Suscripciones, Client, Message, Sender),
      loop(Suscripciones, Servers, Sender);
    state ->
      io:format("State ~n"),
      imprimirEstado(Suscripciones, Servers)
  end.

imprimirEstado(Suscripciones, Servers)->
  io:format("Servers disponibles: ~p~n", Servers),
  io:format("Suscripciones disponibles: ~p~n", dict:to_list(Suscripciones)).

%Remueve el server de la lista de servers.
removerServer(Server, Servers)->
  lists:keydelete(Server, 1, Servers).

%Suscribe el cliente al channel deseado.
suscribir(Suscripciones, Channel, Client, Servers)->
  %Buscar si existe la suscripcion en la lista.
  %Si existe agregarlo en la lista y si no crear el channel y ponerla.
  case dict:find(Channel, Suscripciones) of
    {ok, SuscripcionesDelCanal} ->
        case lists:keyfind(Client,1,SuscripcionesDelCanal) of
          false ->
            try
              ClientesNuevos = [Client | SuscripcionesDelCanal],
              dict:update(Channel, fun(ClienteViejos)-> ClientesNuevos end,ClientesNuevos, Suscripciones)
            catch
              badarg -> io:format("BAD ARG")
            end
        end;
    error ->
        dict:append(Channel, [Client], Suscripciones)
  end.

%desuscribe el cliente del channel deseado.
desuscribir(Suscripciones, Channel, Client, Servers)->
  %Buscar el channel en la lista y borrar el client del channel.
  case dict:find(Channel, Suscripciones) of
    {ok, SuscripcionesDelCanal} ->
      lists:keydelete(Client,1,SuscripcionesDelCanal);
    error->Suscripciones
  end.

emitir(Channel, Suscripciones, Client, Message, Sender, Servers)->
  emitirAServers(Channel, Client, Message, Sender, Servers),
  ClientesSuscriptos = obtenerClienteSuscriptos(Channel, Suscripciones,Client),
  CSuscriptos = length(ClientesSuscriptos),
  io:format("Clientes suscriptos! ~p~n",[CSuscriptos]),

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

emitirAServers(Channel,Client, Message, Sender, Servers)->
  lists:map(fun(Server)-> Server ! {emit, {Channel, Client, Message, imServer}} end, Servers).








