-module(message_parser).

%% public methods for the API
-export([run/0]).

%% define records
-record('in:happeningType', {anyAttribs, who, what, 'when', where}).
-record('out:resultType', {anyAttribs, result}).
-record('out:resultType-error', {anyAttribs, error}).
-record('out:resultType-okResult', {anyAttribs, result}).
-record('out:errorType', {anyAttribs, errorCode, errorDescription}).

run() ->
  %% compile xsd
  io:format("---- calling erlsom:compile_xsd_file ~n", []),
  {ok, ModelIn} = erlsom:compile_xsd_file(message_in_xsd(), [{prefix, "in"}]),
  io:format("---- done calling erlsom:compile_xsd_file ~n", []),
  {ok, ModelOut} = erlsom:compile_xsd_file(message_out_xsd(),[{prefix, "out"}]),
  io:format("---- after erlsom:compile_xsd_file ModelIn =:= ~p~n", [ModelIn]),
  %% parse xml
  {ok, Input, Anon} = erlsom:scan_file(message_in_xml(), ModelIn),

  io:format("---- after erlsom scan file Input =:= ~p  Anon =:= ~p ~n", [Input, Anon]),

  %% do something with the content
  case Input of
    #'in:happeningType'{what = undefined} ->
      Error = #'out:errorType'{errorCode = "01", 
                               errorDescription = "No happenings provided"},
      Result = #'out:resultType-error'{error = Error};
    #'in:happeningType'{what = What, 'when' = When, where = Where, who = Who} ->
      io:format("~p ~p ~p ~p ~n", [Who, What, When, Where]),
      Result = #'out:resultType-okResult'{result = format_string(Who, What, When, Where)}
  end,
  
  %% generate xml.
  Response = #'out:resultType'{result=Result},
  XmlResult = erlsom:write(Response, ModelOut),
  io:format("Result: ~p~n", [XmlResult]),
  ok.

%%make_output(Who, What, When, Where) ->
%%        io:format("~p ~p ~p ~p ~n", [Who, What, When, Where]),
%%	Delim = ':',
%%	P1 = string:concat(Who, Delim),
%%	P2 = string:concat(What, Delim),
%%	P3 = string:concat(When, Delim),
%%	P4 = string:concat(Where, Delim),
%%	P5 = string:concat(P1, P2),
%%	P6 = string:concat(P3, P4),
%%	string:concat(P5, P6).

format_string(Who, What, When, Where) ->
	Tuple = { Who, What, When, Where },
	Strings = tuple_to_list(Tuple),
        io:format("as list ~p ~n", [Strings]),
	String = string:join(Strings, ":"),
        io:format("Returning string ~p ~n", [Strings]),
	String.


%% find files in the local directory
message_in_xsd() -> filename:join([codeDir(), "message_in.xsd"]).
message_out_xsd() -> filename:join([codeDir(), "message_out.xsd"]).
message_in_xml() -> filename:join([codeDir(), "sample.xml"]).
codeDir() -> filename:dirname(code:which(?MODULE)).
