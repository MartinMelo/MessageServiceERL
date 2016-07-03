-module(manager).
-export([start/1, suscribir/2, enviarMensaje/3]).

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

suscribir(Channel, Cliente) ->
	Cliente ! {subscribe,Channel}.

enviarMensaje(Cliente, Channel, Msg) ->
	Cliente ! {emit, Channel, Msg}.

%> Client = manager:start(5) % cantidad de servidores
%> manager:suscribir("amigos",Client).
%> manager:enviarMensaje(C, "amigos","hola").