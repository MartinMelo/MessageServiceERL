-module(client).
-export([start/1]).


start(Router)->
  spawn(fun()-> init(Router) end).

init(Router)->
  io:format("Conectando a Router ~p~n", [Router]),
  enviarPeticionARouter(Router),
  receive
    {server, Server}-> loop(Router, Server)
  end.


%Pido al router que me de un server.
enviarPeticionARouter(Router)->
  Router ! {request, self()}.

loop(Router, Server)->
  receive
    {emit, Channel, Msg}->
      Server ! {emit, {Channel, self(), Msg}},
      loop(Router, Server);
    {subscribe, Channel}->
      Server ! {subscribe, {Channel , self()}},
      loop(Router, Server);
    {desubscribe, Channel}->
      Server ! {desubscribe, {Channel , self()}},
      loop(Router, Server);
    {msg, Msg}->
      procesarMensaje(Msg),
      loop(Router, Server)
  end.

procesarMensaje(Msg)->
  io:format("Mensaje recibido: ~p~n",[Msg]).