-module(client).
-export([start/1]).


start(Router)->
  spawn(fun()-> init(Router) end).

init(Router)->
  io:format("Conectando a Router ~p~n", [Router]),
  enviarPeticionARouter(Router),
  receive
    {server, Server}->
      Server ! {connect, self()},
      loop(Router, Server)
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
    {unsubscribe, Channel}->
      Server ! {unsubscribe, {Channel , self()}},
      loop(Router, Server);
    {msg, Msg}->
      procesarMensaje(Msg),
      loop(Router, Server);
    disconnect->
      Server ! {disconnect , self()},
      closeMessage()
  end.

closeMessage()->io:format("Connection closed.~n Good bye!!!!~n").

procesarMensaje(Msg)->
  io:format("Mensaje recibido: ~p~n",[Msg]).