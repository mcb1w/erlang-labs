-module(sip_server).

-export([
    sip_get_user_pass/4,
    sip_authorize/3,
    sip_route/5,
    sip_register/2,
    sip_invite/2
]).

-include_lib("nkserver/include/nkserver_module.hrl").

sip_get_user_pass(_, _, _, _) ->
    <<>>.

sip_authorize(_, _, _) ->
    ok.

sip_route(_, _, _, _, _) ->
    process.

sip_register(Req, _) ->
    {reply, nksip_registrar:request(Req)}.

sip_invite(Req, _) ->

    {ok, [{from_user, FromUser}]} =
        nksip_request:get_metas(
            [from_user],
            Req
        ),

    Contact =
        nksip_sipmsg:get_meta(
            contacts,
            Req
        ),

    ets:insert(
        users,
        {FromUser, Contact}
    ),

    io:format(
        "SAVED ~p => ~p~n",
        [FromUser, Contact]
    ),

    {reply, {486, []}}.