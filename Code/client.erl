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
  io:format("escuchando..."),
  receive
    {emit, Channel, Msg}->
      Server ! {emit, {Channel, self(), Msg}},
      io:format("el mensaje se a emitido"),

      loop(Router, Server);
    {subscribe, Channel}->
      Server ! {subscribe, {Channel , self()}},
      io:format("suscripcion exitosa"),
      loop(Router, Server);
    {desubscribe, Channel}->
      Server ! {desubscribe, {Channel , self()}},
      io:format("desuscripcion exitosa"),
      loop(Router, Server);
    {msg, Msg}->
      procesarMensajeYEnviarACK(Msg, Server),
      loop(Router, Server)
  end.

procesarMensajeYEnviarACK(Msg , Server)->
  %Imprimir informacion del mensaje,
  io:format("Dice: ~p~n",[Msg]),
  IdMsg = asd,
  Server ! {ack, IdMsg}.