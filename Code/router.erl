-module(router).
-export([start/0]).

start()->
  spawn(fun()-> init() end).

init()->
  loop([]).

loop(Servers)->
  receive
    {register, Server}->
      loop([Server |Servers]);%Lo meto en la lista.
    {unregister, Server}->
      ServersUpdated = quitarServer(Servers, Server),
      loop(ServersUpdated);
    {request , Who}->
      Server = getRandomServer(Servers),
      Who ! {server , Server},
      loop(Servers)
  end.

%Elimina el server de la lista.
quitarServer(Servers, Server)->
  lists:keydelete(Server,1,Servers).%Key,Cuantos,Lista.

%Devuelve un server de la lista de forma random.
getRandomServer(Servers)->
  lists:nth(random:uniform(length(Servers)), Servers).