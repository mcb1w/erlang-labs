-type temp() :: float().
-type metric() :: {atom(), integer()}.
-type metrics() :: [metric()].

-record(device, {id :: integer(),
                 name :: string(),
                 address :: string(),
                 temp :: temp(),
                 metrics :: metrics()}).