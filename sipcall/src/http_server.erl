-module(http_server).

-export([start/0]).

start() ->

    Dispatch = cowboy_router:compile([
        {'_', [
            {"/api/call/:userid",
             call_handler,
             []}
        ]}
    ]),

    {ok, _} =
        cowboy:start_clear(
            http_listener,
            [{port, 8080}],
            #{env => #{dispatch => Dispatch}}
        ),

    ok.