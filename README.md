iroute-erl-xml
==============

sampling erlang and xml processing

You will need to install erlsom. http://erlsom.sourceforge.net/


Also here is my ~/.erlang file.  It loads the lib path.

>
	io:format("-----Loading .erlang config v1.0------~n").
	Cwd= ".".
	Erlsom = "/Users/dmknopp/erlang-install/erlsom/ebin".
	Dmklib = "/Users/dmknopp/erlang-dmk/ebin".
	io:format("Adding cwd and erlsom to the path~n").
	code:add_patha(Cwd).
	code:add_patha(Erlsom).
	code:add_patha(Dmklib).
	Home = init:get_argument(home).
	{ok, Home1} = Home.
	io:format("Your home is ~s ~n", [Home1]).
