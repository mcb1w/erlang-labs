%%%-------------------------------------------------------------------
%% @doc iotserv top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(iotserv_sup).

-behaviour(supervisor).

-export([start_link/0, iotserv_child_spec/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    SupFlags = #{
        strategy => one_for_one,
        intensity => 10,
        period => 1
    },
    ChildSpecs = [iotserv_child_spec()],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
iotserv_child_spec() ->
    #{id => iotserv,
      start => {iotserv, start_link, []},
      restart => permanent,
      shutdown => 5000,
      type => worker,
      modules => [iotserv]}.