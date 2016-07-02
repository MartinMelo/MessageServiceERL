-module(basic).
-export([start/0]).

start()->
  Servers = crearServidores(),
  Router = router:start(),
  agregarServidoresAlRouter(Servers, Router),
  Clientes =crearClientes(Router),
  correrTest(Clientes).


agregarServidoresAlRouter(Servers, Router)->
  lists:foreach(fun(Server)-> Router ! {addBrother, Server} end, Servers).

crearClientes(Router)->
[client:start(Router),client:start(Router),client:start(Router)].

%Crea 4 Servers.
crearServidores() ->
  [server:start(),server:start(),server:start(),server:start()].

%%%%%%%%%%%%%%%%%%%%LOGICA DEL TEST%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
correrTest(Clientes)->
  lists:foreach(fun(Cliente)-> Cliente ! {subscribe , "#"} end, Clientes).

