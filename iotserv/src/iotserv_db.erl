-module(iotserv_db).
-export([start/0, add/1, lookup/1, delete/1, change/2]).
-include("iotserv.hrl").

start() ->
    ets:new(iotserv_db, [named_table, public, set]),
    dets:open_file(iotserv_db, [{file, "iotserv_db.dets"}, {type, set}]),
    dets:foldl(fun({Id, Device}, Acc) ->
        ets:insert(iotserv_db, {Id, Device}), Acc
    end, ok, iotserv_db),
    ok.
add(Device) ->
    ets:insert(iotserv_db, {Device#device.id, Device}),
    dets:insert(iotserv_db, {Device#device.id, Device}).
lookup(Id) ->
    case ets:lookup(iotserv_db, Id) of
        [{_, Device}] -> Device;
        [] -> undefined
    end.
delete(Id) ->
    ets:delete(iotserv_db, Id),
    dets:delete(iotserv_db, Id).
change(Id, Value) ->
    ets:insert(iotserv_db, {Id, Value}),
    dets:insert(iotserv_db, {Id, Value}).
