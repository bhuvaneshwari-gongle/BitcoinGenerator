%%%-------------------------------------------------------------------
%%% @author bhuva
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Sep 2022 4:17 PM
%%%-------------------------------------------------------------------
-module(test).
-author("bhuva").

%% API
-export([takeInputFromUSer/2,pingMaster/3]).

pingMaster(MasterNodeName, WorkerNodeName, KValue) ->
  Status = net_adm:ping(MasterNodeName),
  if
    Status == pong ->
      io:fwrite("connection with server established!"),
      rpc:call(MasterNodeName, master, invokeWorker, [WorkerNodeName, KValue]);
    true ->
      ok
  end.

takeInputFromUSer(K, masterPID) ->
  RandomNum = getRandomString(10,"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz"),
  GatorID = "navya.gangidi;",
  InputString = string:concat(GatorID,RandomNum),
  HashedValue = getHashedValue(InputString),
  FirstNChars_HashedValue = string:sub_string(HashedValue,1,K),
  StringTemp1 = string:concat("~",integer_to_list(K)),
  StringTemp2 = string:concat(StringTemp1,"..0B"),
  ZeroString = lists:flatten(io_lib:fwrite(StringTemp2, [0])),
  CheckValidity = string:equal(FirstNChars_HashedValue,ZeroString),
  if
    CheckValidity == true ->
      masterPID ! {valid, InputString, HashedValue};
    true ->
      ok
  end,
  takeInputFromUSer(K, masterPID).

getRandomString(Length, AllowedChars) ->
  %RandomNum = base64:encode_to_string(crypto:strong_rand_bytes(Length)),
  RandomNum = lists:foldl(fun(_, Acc) ->
    [lists:nth(rand:uniform(length(AllowedChars)),AllowedChars)] ++ Acc
                          end, [], lists:seq(1, Length)),
  RandomNum.

getHashedValue(InputString)->
  HashedOutput = io_lib:format("~64.16.0b", [binary:decode_unsigned(crypto:hash(sha256,
    InputString))]),
  HashedOutput.
