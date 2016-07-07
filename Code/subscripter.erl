-module(subscripter).
-export([new/0,subscribe/3,unsubscribe/3,clientesSubscriptos/3,allChannels/1,unsubscribeAll/2]).


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

%Desuscribe el cliente del channel dado.
unsubscribe(Channel, Client, Suscripciones)->
%Buscar el channel en la lista y borrar el client del channel.
  case dict:find(Channel, Suscripciones) of
    {ok, SuscripcionesDelCanal} ->
      ClientesNuevos = lists:keydelete(Client,1,SuscripcionesDelCanal),
      dict:update(Channel, fun(ClienteViejos)-> ClientesNuevos end,ClientesNuevos, Suscripciones);
    error->Suscripciones
  end.

%Devuelve los clientes suscriptos en este channel.
clientesSubscriptos(Channel, Suscripciones, Client)->
  case dict:find(Channel, Suscripciones) of
    {ok, SuscripcionesDelCanal} ->
      lists:delete(Client,SuscripcionesDelCanal);
    error-> []
  end.

%Devuelve todos los channels disponibles.
allChannels(Suscripciones)->
  dict:fetch_keys(Suscripciones).

%TODO: Foldear para eliminar todas las suscriciones del cliente.
unsubscribeAll(Client, Suscripciones)->
  dict:fold(
    fun(Channel,Subs,NewDict) ->
      SubsNuevas = lists:delete(Client, Subs),
      dict:append(Channel,SubsNuevas ,NewDict) end,
    dict:new(),
    Suscripciones).