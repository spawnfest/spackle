-module(spackle_svr).

-behaviour(gen_server).

%% API
-export([start_link/0, insert/3, select/4]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

insert(Pid, TableName, What) ->
    gen_server:call(Pid, {insert, TableName, What}).

select(Pid, TableName, What, Where) ->
    gen_server:call(Pid, {select, TableName, What, Where}).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    {ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call({insert, TableName, What}, _From, State) ->
    Reply = do_insert(TableName, What),
    {reply, Reply, State};

handle_call({select, TableName, What, Where}, _From, State) ->
    Reply = do_select(TableName, What, Where),
    {reply, Reply, State}.
%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast(Msg, State) ->
    io:format("Unexpected message: ~p~n", [Msg]),
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(Info, State) ->
    io:format("Unexpected message: ~p~n", [Info]),
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
do_insert(TableName, What) ->
    {Fields, Values} = seperate_elements(What, [], []),
    FieldString = if
        Fields =:= [] ->
            "";
        true ->
            " (" ++ [ "\'" ++ F ++ "\'" || F <- Fields ] ++ ")"
    end,
    ValueString = " VALUES (" ++ string:join(Values, ", ") ++ ")",
    list_to_binary(
        "INSERT INTO " 
        ++ TableName 
        ++ FieldString
        ++ ValueString
    ).
    
do_select(_TableName, _What, _Where) ->
    list_to_binary("SELECT").

seperate_elements([H|T], Fields, Values) ->
    {Field, Value} = seperate(H),
    seperate_elements(T, [Field|Fields], [Value|Values]);

seperate_elements([], Fields, Values) ->
    {lists:reverse(Fields), lists:reverse(Values)}.

seperate([]) -> {[], []};
        
seperate({Field, Value} = _Element) ->
    {make_string(Field), make_value_string(Value)};

seperate(Element) -> 
    {[], make_string(Element)}.

make_value_string(Thing) ->
    case Thing of
        _ when is_list(Thing) ->
            "\\\"" ++ Thing ++ "\\\"";
        _ when is_integer(Thing) ->
            integer_to_list(Thing);
        _ when is_float(Thing) ->
            float_to_list(Thing);
        _ when is_binary(Thing) ->
            binary_to_list(Thing);
        _ when is_atom(Thing) ->
            atom_to_list(Thing);
        _ ->
            erlang:error(badarg)
    end. 

make_string(Thing) ->
    case Thing of
        _ when is_list(Thing) ->
            Thing;
        _ when is_integer(Thing) ->
            integer_to_list(Thing);
        _ when is_float(Thing) ->
            float_to_list(Thing);
        _ when is_binary(Thing) ->
            binary_to_list(Thing);
        _ when is_atom(Thing) ->
            atom_to_list(Thing);
        _ ->
            erlang:error(badarg)
    end.
