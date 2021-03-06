%%% @author Konstantin Sorokin <kvs@sigterm.ru>
%%% @doc Implementation of the IDNA part of GNU libidn library in Erlang NIFs.
%%%
%%% @copyright 2011 Konstantin V. Sorokin, All rights reserved. Open source, BSD License
%%% @version 1.0
%%%
-module(erlidna).
-version(1.0).
-on_load(init/0).
-export([encode/1, decode/1]).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

%% @doc Initialize idna NIF.
init() ->
    SoName = filename:join(case code:priv_dir(?MODULE) of
                               {error, bad_name} ->
                                   %% this is here for testing purposes
                                   filename:join(
                                     [filename:dirname(
                                        code:which(?MODULE)),"..","priv"]);
                               Dir ->
                                   Dir
                           end, atom_to_list(?MODULE) ++ "_nif"),
    erlang:load_nif(SoName, 0).

%% @spec encode(Data) -> {ok, Encoded} | {error, Reason}
%% where
%%       Data = binary()
%%       Encoded = binary()
%%       Reason = string()
%% @doc Encode domain name given in UTF-8 encoding into ASCII representation.
encode(_Data) ->
    erlang:nif_error(not_loaded).

%% @spec decode(Data) -> {ok, Decoded} | {error, Reason}
%% where
%%       Data = binary()
%%       Decoded = binary()
%%       Reason = string()
%% @doc Decode domain name from ASCII representation into UTF-8 encoding.
decode(_Data) ->
    erlang:nif_error(not_loaded).

%% ===================================================================
%% EUnit tests
%% ===================================================================
-ifdef(TEST).

read_file(Device, Acc) ->
    case io:fread(Device, "", "~ts~ts") of
        eof ->
            Acc;
        {ok, [F, L]} ->
            BF = unicode:characters_to_binary(F),
            BL = unicode:characters_to_binary(L),
            read_file(Device, [{BF, BL} | Acc])
    end.

read_test_data(FileName) ->
    {ok, Device} = file:open(FileName, [read, binary, {encoding,unicode}]),
    read_file(Device, []).

test_apply(Item) ->
    A = element(1, Item),
    B = element(2, Item),
    {ok, B} = encode(A),
    {ok, A} = decode(B).

run_normal_test() ->
    TestsData = read_test_data("../tests/data.txt"),
    lists:foreach(fun test_apply/1, TestsData).

run_badarg_test() ->
    Data = "example.com",
    try encode(Data) of
        _ -> erlang:error("Failed")
    catch
        error:badarg -> ok
    end.

-endif.
