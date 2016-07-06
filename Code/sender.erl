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
      io:format("Cliente ~w~n", Client),
      try
        Client ! {msg, Msg}
      catch
          badarg ->
            io:format("Se Rompio al enviar al Cliente: ~p~n" , [Client]),
            io:format("El Mensaje: ~p~n" , [Msg])

      end
  end.

