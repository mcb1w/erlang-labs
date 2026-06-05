%%%-------------------------------------------------------------------
%% @doc sipcall public API
%% @end
%%%-------------------------------------------------------------------

-module(sipcall_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->

    ets:new(
        users,
        [named_table, public, set]
    ),

    http_server:start(),

    sipcall_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
