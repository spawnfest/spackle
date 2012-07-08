Spackle
-------

This is an Erlang application designed to translate an Erlang data structure into a SQL statement.  Think of it
as kind of a thin ORM layer.

Example
=======

    {ok, Pid} = spackle_svr:start_link().
    spackle_svr:insert(Pid, "TEST", [5, bar, "foo"]).
    <<"INSERT INTO TEST VALUES (5, \"foo\", \"bar\")">>
