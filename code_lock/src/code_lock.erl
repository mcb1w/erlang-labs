-module(code_lock).
-behaviour(gen_statem).

-define(NAME, code_lock_3).

-export([start_link/2, stop/0]).
-export([button/1, set_lock_button/1, set_code/1]).
-export([init/1, callback_mode/0, terminate/3]).
-export([handle_event/4]).

start_link(Code, LockButton) ->
    gen_statem:start_link(
        {local, ?NAME},
        ?MODULE,
        {Code, LockButton},
        []
    ).

stop() ->
    gen_statem:stop(?NAME).

button(Button) ->
    gen_statem:cast(?NAME, {button, Button}).

set_lock_button(LockButton) ->
    gen_statem:call(?NAME, {set_lock_button, LockButton}).

set_code(NewCode) ->
    gen_statem:call(?NAME, {set_code, NewCode}).

init({Code, LockButton}) ->
    process_flag(trap_exit, true),
    Data = #{
        code => Code,
        length => length(Code),
        buttons => [],
        errors => 0
    },
    {ok, {locked, LockButton}, Data}.

callback_mode() ->
    [handle_event_function, state_enter].

handle_event(
    {call, From},
    {set_code, NewCode},
    {open, _LockButton},
    Data
) ->
    NewData = Data#{
        code := NewCode,
        length := length(NewCode),
        buttons := [],
        errors := 0
    },
    {keep_state, NewData, [{reply, From, ok}]};

handle_event(enter, _OldState, {suspended, _}, _Data) ->
    io:format("Suspended~n", []),
    keep_state_and_data;

handle_event(cast, {button, _}, {suspended, _}, _Data) ->
    keep_state_and_data;

handle_event(state_timeout, unlock, {suspended, LockButton}, Data) ->
    {next_state, {locked, LockButton}, Data};

handle_event(enter, _OldState, {locked, _}, Data) ->
    do_lock(),
    {keep_state, Data#{buttons := []}};

handle_event(state_timeout, button, {locked, _}, Data) ->
    {keep_state, Data#{buttons := []}};

handle_event(
    cast,
    {button, Button},
    {locked, LockButton},
    #{
        code := Code,
        length := Length,
        buttons := Buttons,
        errors := Errors
    } = Data
) ->
    NewButtons =
        if
            length(Buttons) < Length ->
                Buttons;
            true ->
                tl(Buttons)
        end ++ [Button],

    if
        NewButtons =:= Code ->
            {next_state, {open, LockButton},
             Data#{errors := 0}};

        true ->
            if
                length(NewButtons) =:= Length ->
                    NewErrors = Errors + 1,
                    if
                        NewErrors =:= 3 ->
                            {next_state, {suspended, LockButton},
                             Data#{buttons := [], errors := 0},
                             [{state_timeout, 10000, unlock}]};
                        true ->
                            {keep_state,
                             Data#{buttons := [], errors := NewErrors},
                             [{state_timeout, 30000, button}]}
                    end;
                true ->
                    {keep_state,
                     Data#{buttons := NewButtons},
                     [{state_timeout, 30000, button}]}
            end
    end;

handle_event(enter, _OldState, {open, _}, _Data) ->
    do_unlock(),
    {keep_state_and_data,
     [{state_timeout, 10000, lock}]};

handle_event(state_timeout, lock, {open, LockButton}, Data) ->
    {next_state, {locked, LockButton}, Data};

handle_event(cast, {button, LockButton}, {open, LockButton}, Data) ->
    {next_state, {locked, LockButton}, Data};

handle_event(cast, {button, _}, {open, _}, _Data) ->
    {keep_state_and_data, [postpone]};

handle_event(
    {call, From},
    {set_lock_button, NewLockButton},
    {StateName, OldLockButton},
    Data
) ->
    {next_state,
     {StateName, NewLockButton},
     Data,
     [{reply, From, OldLockButton}]}.

do_lock() ->
    io:format("Locked~n", []).

do_unlock() ->
    io:format("Open~n", []).

terminate(_Reason, _State, _Data) ->
    ok.