-module(call_handler).

-behaviour(cowboy_handler).

-export([init/2]).

init(Req0, State) ->

    UserId = cowboy_req:binding(userid, Req0),

    Response =
        case user_store:get_user(UserId) of
            [{_, Uri}] ->

                io:format("CALLING URI: ~p~n", [Uri]),

                Result = nksip_uac:invite(
                    sip_server,
                    Uri,
                    []
                ),

                list_to_binary(
                    io_lib:format(
                        "CALL RESULT: ~p",
                        [Result]
                    )
                );

            [] ->
                <<"User not found">>
        end,

    Req = cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"text/plain">>},
        Response,
        Req0
    ),

    {ok, Req, State}.