-module(code_lock_tests).

-include_lib("eunit/include/eunit.hrl").

start_stop_test() ->
    {ok, _Pid} = code_lock:start_link([1,2,3], 0),
    ?assert(is_pid(whereis(code_lock_3))),
    ok = code_lock:stop().

open_correct_code_test() ->
    {ok, _Pid} = code_lock:start_link([1,2,3], 0),

    code_lock:button(1),
    code_lock:button(2),
    code_lock:button(3),

    timer:sleep(100),

    ok = code_lock:stop().

change_code_test() ->
    {ok, _Pid} = code_lock:start_link([1,2,3], 0),

    code_lock:button(1),
    code_lock:button(2),
    code_lock:button(3),
    timer:sleep(100),

    ok = code_lock:set_code([9,9,9]),

    code_lock:button(0),
    timer:sleep(100),

    ok = code_lock:stop().

suspended_test() ->
    {ok, _Pid} = code_lock:start_link([1,2,3], 0),

    %% First wrong attempt
    code_lock:button(9),
    code_lock:button(9),
    code_lock:button(9),

    %% Second wrong attempt
    code_lock:button(8),
    code_lock:button(8),
    code_lock:button(8),

    %% Third wrong attempt
    code_lock:button(7),
    code_lock:button(7),
    code_lock:button(7),

    timer:sleep(100),

    {{suspended, _}, _} = sys:get_state(code_lock_3),

    ok = code_lock:stop().