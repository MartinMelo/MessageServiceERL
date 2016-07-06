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
      io:format("Registrando"),
      Server ! {brothers , Servers},
      io:format("se ha registrado el server"),
      informarACadaServerElNuevoHermano(Servers, Server),
      loop([Server |Servers]);%Lo meto en la lista.
    {unregister, Server}->
      ServersUpdated = quitarServer(Servers, Server),
      loop(ServersUpdated);
    {request , Who}->
      io:format("obteniendo servidor"),
      Server = getRandomServer(Servers),
      io:format("servidor encontrado!"),
      Who ! {server , Server},
      io:format("El servidor se ha regitrado"),
      loop(Servers)
  end.

informarACadaServerElNuevoHermano(Servers, ServerNuevo)->
  lists:foreach(fun(Server)-> Server ! {addBrother , ServerNuevo} end, Servers).

%Elimina el server de la lista.
quitarServer(Servers, Server)->
  lists:keydelete(Server,1,Servers).%Key,Cuantos,Lista.

%Devuelve un server de la lista de forma random.
getRandomServer(Servers)->
  lists:nth(random:uniform(length(Servers)), Servers).