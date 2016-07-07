-module(test).
-export([start/0]).

start()->
  Clientes =crearClientes({router,'router@192.168.0.105'},[],0),
  correrTest(Clientes).

crearClientes(_,Clientes, 1000)-> Clientes;
crearClientes(Router,Clientes,N)->
  crearClientes(Router,[client:start(Router) | Clientes], N+1).

%%%%%%%%%%%%%%%%%%%%LOGICA DEL TEST%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
correrTest(Clientes)->
  Subs = ["chat","rp", "zaza","BO","st","multi","toty","muty","routy","detector","namy","loggy","groupy","crash","opty","rudy"],
  suscribirATodos(Clientes, Subs),
  io:format("esperando 5 segundos"),
  timer:sleep(random:uniform(5000)),
  loopear(Clientes,0, Subs).



suscribirATodos(Clientes, Subs)->
  Sub = lists:nth(random:uniform(length(Subs)), Subs),
  lists:foreach(fun(Cliente)-> Cliente ! {subscribe , Sub} end, Clientes).


loopear(_ , 100, _)->
  finished;
loopear(Clientes, N, Subs)->
  Cliente = lists:nth(random:uniform(length(Clientes)), Clientes),
  Sub = lists:nth(random:uniform(length(Subs)), Subs),
  Cliente ! {emit, Sub ,Sub},
  timer:sleep(random:uniform(1000)),
  loopear(Clientes,N+1,Subs).
