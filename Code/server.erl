-module(server).
-export([start/0, start/1]).


start()->
  spawnear.
start(configuracion)->
  spawnear_con_configuracion.

init()->
  loop(suscripciones, clientes, mensajes_por_enviar, id_Mensaje_siguiente, opciones).


loop(suscripciones, clientes, mensajes_por_enviar, id_Mensaje_siguiente, opciones)->
  receive
    {subscribe, {Channel, Client}}->
      suscribir;
    {unsubscribe, {Channel, Client}}->
      desuscribir;
    {emit, {Channel, Client, Message}}->
      emitir;
    {broadcast, {Client, Message}}->
      broadcastear
  end.