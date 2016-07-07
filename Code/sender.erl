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
    {send, {Client, Msg}}->
      Time = erlang:system_time(),
      Client ! {msg, Msg, Time},
      loop()
  end.

