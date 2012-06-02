-module(lcs).

-compile(export_all).

%%
%%	Nink in the sink. Bofa on the sofa. Nink in the sink.
%%
%% longest common prefix
lcp(Text1, Text2) ->
	Len1 = string:len(Text1),
	Len2 = string:len(Text2),
	Min = min(Len1, Len2),
	longest_prefix(Text1, Text2, 1, Min)
.

%% check each char in the 2 strings, up to MaxIndex,
%% 	return "a" and not "the" longest prefixed substring
longest_prefix(Text1, Text2, CurIndex, MaxIndex) ->
	if
	  CurIndex > MaxIndex ->
		%io:format("calling substr w/ maxchars!n". []),
		string:substr(Text1, 1, MaxIndex);
	  true ->
		C1 = string:substr(Text1, CurIndex, 1),
		C2 = string:substr(Text2, CurIndex, 1),
		Eql = string:equal(C1, C2),
		%io:format("checking ~p and ~p~n, [C1, C2]),
		if
		   Eql =:= false ->
			%io:format("calling substr w/ curIndex = ~p~n", [CurIndex]),
			string:substr(Text1, 1, CurIndex - 1);
		   true ->
			%io:format("Equals. Checking next char~n", []),
			longest_prefix(Text1, Text2, CurIndex + 1, MaxIndex)
		end
	end
.

%% longest repeated string
lrs(Text) ->
	Lol0 = substr_loop(Text, 1, []),
	io:format("List of Strings == ~p~n", [Lol0]),
	Lol1 = lists:sort(fun(El1, El2) -> El1 < El2 end, Lol0),
	% call lcp and check he cur max
	io:format("List of Strings == ~p~n", [Lol1]),
	lcp_recur(Lol1, "")
.

lrs(Text, ListenerPid) ->
	Lol0 = substr_loop(Text, 1, []),
	Lol1 = lists:sort(fun(El1, El2) -> El1 < El2 end, Lol0),
	% call lcp and check the cur max
	io:format("List of Strings == ~p~n", [Lol1]),
	Result = lcp_recur(Lol1, ""),
	io:format("Found result == ~p~n", [Result]),
	ListenerPid ! { result, Result}
.

%% compare 2 elements in a list
%% Todo: maybe compute CurLcs Len once and pass that thru every method, rather then recompute everytime
lcp_recur([H1,H2|T], CurLcs) ->
	io:format("lcp_recur. H1==~p H2==~p Lcs==~p~n", [H1, H2, CurLcs]),
	SubString = lcp(H1, H2),
	CurMaxLen = string:len(CurLcs),
	InspectLen = string:len(SubString),
	if
	   InspectLen > CurMaxLen ->
		lcp_recur([H2|T], SubString);
	   true ->
		lcp_recur([H2|T], CurLcs)
	end
; 	%% replace the . w/ a ; the definiton of lcp continues
	
%% nothing left to compare against, or is it only 1 element to compare against? TODO: make sure this isnt a bug
%%lcp_recur([_Any], CurLcs) ->
%%	io:format("lcp_recur with Any matched, Any = ~p~n", [~Any]),
%%	CurLcs
%%.

lcp_recur([H1|T], CurLcs) ->
	io:format("lcp_recur. H1==~p T==~p Lcs==~p~n", [H1, T, CurLcs]),
	SubString = lcp(H1, T),
	CurMaxLen = string:len(CurLcs),
	InspectLen = string:len(SubString),
	if
	  InspectLen > CurMaxLen ->
		SubString;
	  true ->
		CurLcs
	end
.

%% lcp_recur([], CurLcs) ->
%%	io:format("lcp_recur with [] matched~n", [])
%%	CurLcs
%%.

substr_loop(Text, StartIndex, Lol) ->
	io:format("Text == ~p StartIndex == ~p ~n", [Text, StartIndex]),
	N = string:len(Text),
	if
	   StartIndex > N ->
		Lol;
	   true ->
	     Substring = string:substr(Text, StartIndex),
	     io:format("found substr==~p~n", [Substring]),
	     [ Substring | substr_loop(Text, StartIndex + 1, Lol) ]
	end
.

%% return min of 2 nums
min(Num1, Num2) ->
	if
		Num1 < Num2 ->
			Num1;
		true ->
			Num2
	end
.
