-module(router).
-export([start/0,init/0]).

start()->
  Router = spawn(fun()-> init() end),
  register(router, Router).

init()->
  loop([]).

loop(Servers)->
  receive
    {register, Server}->
      io:format("register server with PID: ~p~n", [Server]),
      Server ! {brothers , Servers},
      informarACadaServerElNuevoHermano(Servers, Server),
      loop([Server |Servers]);%Lo meto en la lista.
    {unregister, Server}->
      io:format("unregister server with PID: ~p~n", [Server]),
      ServersUpdated = quitarServer(Servers, Server),
      loop(ServersUpdated);
    {request , Who}->
      io:format("server requested from client: ~p~n", [Who]),
      Server = getRandomServer(Servers),
      Who ! {server , Server},
      io:format("Server to connect: ~p~n", [Server]),
      loop(Servers);
    cleanSubsFromServers ->
      enviarCleanSubs(Servers),
      loop(Servers)
  end.

enviarCleanSubs(Servers)->
  lists:foreach(fun(Server)-> Server ! cleanSubs end, Servers).

informarACadaServerElNuevoHermano(Servers, ServerNuevo)->
  lists:foreach(fun(Server)-> Server ! {addBrother , ServerNuevo} end, Servers).

%Elimina el server de la lista.
quitarServer(Servers, Server)->
  lists:keydelete(Server,1,Servers).%Key,Cuantos,Lista.

%Devuelve un server de la lista de forma random.
getRandomServer(Servers)->
  lists:nth(random:uniform(length(Servers)), Servers).