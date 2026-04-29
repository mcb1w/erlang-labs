-module(iotserv).

-export([start_link/0, add/1, lookup/1, delete/1, change/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-behaviour(gen_server).

-include("iotserv.hrl").

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    iotserv_db:start(),
    {ok, #{}}.

add(Device) ->
    gen_server:call(?MODULE, {add, Device}).
lookup(Id) ->
    gen_server:call(?MODULE, {lookup, Id}).
delete(Id) ->
    gen_server:call(?MODULE, {delete, Id}).
change(Id, Value) ->
    gen_server:call(?MODULE, {change, Id, Value}).

handle_call({add, Device}, _From, State) ->
    {reply, iotserv_db:add(Device), State};
handle_call({lookup, Id}, _From, State) ->
    {reply, iotserv_db:lookup(Id), State};
handle_call({delete, Id}, _From, State) ->
    {reply, iotserv_db:delete(Id), State};
handle_call({change, Id, Value}, _From, State) ->
    {reply, iotserv_db:change(Id, Value), State};
handle_call(_Request, _From, State) ->
    {reply, error, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.
handle_info(_Info, State) ->
    {noreply, State}.
terminate(_Reason, _State) ->
    ok.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

