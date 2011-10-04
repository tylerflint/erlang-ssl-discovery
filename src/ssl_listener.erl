-module (ssl_listener).

-behaviour(gen_server).

-export([
  start_link/0,
  init/1, 
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

start_link() ->
  ssl:start(),
  {ok, ListenSocket} = 
    ssl:listen(3002, [binary,
      {certfile, "www.pagodabox.com.crt"},
      {keyfile, "www.pagodabox.com.key"},
      % {packet, http},
      {backlog, 1000},
      % {ip, {127, 0, 0, 1}},
      {ip, {192, 168, 10, 3}}, % test with ip that doesn't exist
      {reuseaddr, true},
      {active, false},
      {packet_size, 1024}
    ]),
  gen_server:start_link(?MODULE, [ListenSocket], []).

%   gen server callbacks
init([ListenSocket]) ->
  gen_server:cast(self(), accept),
  {ok, ListenSocket}.

handle_cast(accept, ListenSocket) ->
  {ok, ClientSocket} = ssl:transport_accept(ListenSocket),
  Res = ssl:ssl_accept(ClientSocket),
  io:format("got a connection!~n"),
  io:format("res: ~p~n", [Res]),
  ssl:send(ClientSocket, "foo"),
  ssl:close(ClientSocket),
  gen_server:cast(self(), accept),
  {noreply, ListenSocket}.

handle_call('_', '_', '_') ->
  ok.

handle_info('_', '_') ->
  ok.

terminate('_', '_') ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

