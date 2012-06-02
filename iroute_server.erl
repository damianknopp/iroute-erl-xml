-module(iroute_server).

-behaviour(gen_server).
-export([start/0]).
%% gen_server callbacks

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-compile(export_all).

%% define records
-record('in:happeningType', {anyAttribs, who, what, 'when', where}).
-record('out:resultType', {anyAttribs, result}).
-record('out:resultType-error', {anyAttribs, error}).
-record('out:resultType-okResult', {anyAttribs, result}).
-record('out:errorType', {anyAttribs, errorCode, errorDescription}).

start() -> io:format("starting iroute_server~n"), gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()  -> gen_server:call(?MODULE, stop).

on_message(Xml) -> io:format("recieved on_message ~p~n", [Xml]),
		   gen_server:call(?MODULE, {onmessage, Xml}).  

%% find files in the local directory
message_in_xsd() -> filename:join([codeDir(), "message_in.xsd"]).
message_out_xsd() -> filename:join([codeDir(), "message_out.xsd"]).
message_in_xml() -> filename:join([codeDir(), "sample.xml"]).
codeDir() -> filename:dirname(code:which(?MODULE)).

%%
%%
format_string(Who, What, When, Where) ->
	Tuple = { Who, What, When, Where },
	Strings = tuple_to_list(Tuple),
        io:format("as list ~p ~n", [Strings]),
	String = string:join(Strings, ":"),
        io:format("Returning string ~p ~n", [Strings]),
	String.

%% todo:
%% activate user 
	%% init users mailbox
%% deactivate user
	%% kill users mailbox

%%
%%
init([]) ->
	{ok, 0}.

%%
%%
handle_call({onmessage, _Xml}, _From, Tab) ->
	%% init xsd stuff
	%% compile xsd
	io:format("---- calling erlsom:compile_xsd_file ~n", []),
	{ok, ModelIn} = erlsom:compile_xsd_file(message_in_xsd(), [{prefix, "in"}]),
	io:format("---- done calling erlsom:compile_xsd_file ~n", []),
	{ok, ModelOut} = erlsom:compile_xsd_file(message_out_xsd(),[{prefix, "out"}]),
	io:format("---- after erlsom:compile_xsd_file ModelIn =:= ~p~n", [ModelIn]),
	io:format("handle_call for onmessage, Xml=~p From=~p Tab=~p~n", [_Xml,_From,Tab]),
	%% parse stuff, deliver message
	%% parse xml
	%{ok, Input, Anon} = erlsom:scan_file(message_in_xml(), ModelIn),
	{ok, Input, Anon} = erlsom:scan(_Xml, ModelIn),
	io:format("---- after erlsom scan file Input =:= ~p  Anon =:= ~p ~n", [Input, Anon]),
	%% do something with the content
	case Input of
		#'in:happeningType'{what = undefined} ->
			Error = #'out:errorType'{errorCode = "01", errorDescription = "No happenings provided"},
			Result = #'out:resultType-error'{error = Error};
		#'in:happeningType'{what = What, 'when' = When, where = Where, who = Who} ->
			io:format("~p ~p ~p ~p ~n", [Who, What, When, Where]),
			Result = #'out:resultType-okResult'{result = format_string(Who, What, When, Where)}
	end,
	%% generate xml.
	Response = #'out:resultType'{result=Result},
	XmlResult = erlsom:write(Response, ModelOut),
	io:format("Result: ~p~n", [XmlResult]),
	{reply, onmessage, Tab};

%%
%%
handle_call(stop, _From, Tab) ->
	{stop, normal, stopped, Tab}.

handle_cast(_Msg, State)   -> {noreply, State}.
handle_info(_Info, State)  -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVersion, State, _Extra) -> {ok, State}.
