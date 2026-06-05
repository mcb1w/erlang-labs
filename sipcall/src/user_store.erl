-module(user_store).

-export([
    init/0,
    save_user/2,
    get_user/1
]).

init() ->
    case ets:info(users) of
        undefined ->
            ets:new(users, [
                named_table,
                public,
                set
            ]);
        _ ->
            ok
    end.

save_user(UserId, Uri) ->
    ets:insert(users, {UserId, Uri}).

get_user(UserId) ->
    ets:lookup(users, UserId).