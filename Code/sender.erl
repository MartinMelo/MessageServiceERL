-module(sender).
-export([start/0]).
%Cada Server tendra una instancia de su propio sender, el cual realiza los envios de mensajes.

start()->
  spawn(fun()-> init() end ).

init()->
  loop().

%Recibe mensajes para enviar y los publica de una.
loop()->
  receive
    {send, {Msg, Client}}->
      Client ! {msg, Msg}
  end.

