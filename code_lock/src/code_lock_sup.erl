-module(code_lock_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    SupFlags = #{
        strategy => one_for_one,
        intensity => 10,
        period => 1
    },

    ChildSpec = #{
        id => code_lock,
        start => {code_lock, start_link, [[1,2,3], 0]},
        restart => permanent,
        shutdown => 5000,
        type => worker,
        modules => [code_lock]
    },

    {ok, {SupFlags, [ChildSpec]}}.