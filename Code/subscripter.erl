-module(subscripter).
-export([new/0,subscribe/3,unsubscribe/3,clientesSubscriptos/3]).


new()->
  dict:new().

subscribe(Channel, Client, Suscripciones)->
  case dict:find(Channel, Suscripciones) of
    {ok, SuscripcionesDelCanal} ->
      case lists:keyfind(Client,1,SuscripcionesDelCanal) of
        false ->
          ClientesNuevos = [Client | SuscripcionesDelCanal],
          dict:update(Channel, fun(ClienteViejos)-> ClientesNuevos end,ClientesNuevos, Suscripciones)
      end;
    error ->
      dict:append(Channel, Client, Suscripciones)
  end.

unsubscribe(Channel, Client, Suscripciones)->
%Buscar el channel en la lista y borrar el client del channel.
  case dict:find(Channel, Suscripciones) of
    {ok, SuscripcionesDelCanal} ->
      ClientesNuevos = lists:keydelete(Client,1,SuscripcionesDelCanal);
      dict:update(Channel, fun(ClienteViejos)-> ClientesNuevos end,ClientesNuevos, Suscripciones)
    error->Suscripciones
  end.

clientesSubscriptos(Channel, Suscripciones, Client)->
  case dict:find(Channel, Suscripciones) of
    {ok, SuscripcionesDelCanal} ->
      lists:keydelete(Client,1,SuscripcionesDelCanal);
    error-> []
  end.