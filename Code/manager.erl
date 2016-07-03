-module(manager).
-export([start/1]).

start(CantidadServers) ->
	Servers = crearNServers([], CantidadServers),
	Router = router:start(),
	%Num = length(Servers),
	%io:format("Hello world! ~p~n",[Num]),
  	agregarServidoresAlRouter(Servers, Router),
  	client:start(Router).

crearNServers(Servers, 0)->
	Servers;
crearNServers(Servers, CantidadServers)->
	NuevaListaDeServers = [server:start()|Servers],
	C = CantidadServers -1,
	crearNServers(NuevaListaDeServers, C).

agregarServidoresAlRouter(Servers, Router)->
  lists:foreach(fun(Server)-> Router ! {register, Server} end, Servers).



%> client = manager:start(5) % cantidad de servidores
%> client ! {"amigos"}
%> client:send("amigos", "hola que hace")