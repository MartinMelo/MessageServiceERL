-module(client).
-export([start/1]).


start(Router)->
  spawn(fun()-> init(Router) end).

init(Router)->
  io:format("Conectando a Router ~n~p", [Router]),
  enviarPeticionARouter(Router),
  receive
    {server, Server}-> loop(Router, Server)
  end.


%Pido al router que me de un server.
enviarPeticionARouter(Router)->
  Router ! {request, self()}.

loop(Router, Server)->
  receive
    {emit, Msg}->
      Server ! {emit, Msg , self()},
      loop(Router, Server);
    {subscribe, Channel}->
      Server ! {subscribe, Channel , self()},
      loop(Router, Server);
    {desubscribe, Channel}->
      Server ! {desubscribe, Channel , self()},
      loop(Router, Server);
    {msg, Msg}->
      procesarMensajeYEnviarACK(Msg, Server),
      loop(Router, Server)
  end.

procesarMensajeYEnviarACK(Msg , Server)->
  %Imprimir informacion del mensaje,
  IdMsg = asd,
  Server ! {ack, IdMsg}.