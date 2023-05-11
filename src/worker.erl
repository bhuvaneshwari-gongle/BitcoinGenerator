%%%-------------------------------------------------------------------
%%% @author bhuva
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Sep 2022 8:15 PM
%%%-------------------------------------------------------------------
-module(worker).
-author("bhuva").

-import(rand,[uniform/1]).
-import(string,[concat/2, sub_string/3, equal/2]).
-import(crypto,[hash/2]).
-import(lists,[nth/2]).

%% API
-export([enableReceiverOfMaster/0, receiverMaster/0, startGeneration/2, startSpawn/2,invokeWorker/2,takeInputFromUSer/2]).

startSpawn(NumOfZeros, masterPID) ->
  io:fwrite("started spawning ~n"),
  spawn(master, startGeneration, [NumOfZeros, masterPID]),
  spawn(master, startGeneration, [NumOfZeros, masterPID]),
  spawn(master, startGeneration, [NumOfZeros, masterPID]),
  spawn(master, startGeneration, [NumOfZeros, masterPID]).

takeInputFromUSer(K, Pid) ->
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
      Pid ! {valid, InputString, HashedValue};
    true ->
      ok
  end.
%%  takeInputFromUSer(K, masterPID).

invokeWorker(WorkerNodeName, KValue) ->
  io:fwrite("Invoke WOrker started"),
  spawn(WorkerNodeName, worker, takeInputFromUSer, [KValue, self()]).

startGeneration(NumOfZeros, masterPID) ->
  %{ok, NumOfZeros} = io:read("Enter a number: ")
  RandomNum = getRandomString(10,"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz"),
  GatorID = "navya.gangidi;",
  InputString = string:concat(GatorID,RandomNum),
  HashedValue = getHashedValue(InputString),
  FirstNChars_HashedValue = string:sub_string(HashedValue,1,NumOfZeros),
  StringTemp1 = string:concat("~",integer_to_list(NumOfZeros)),
  StringTemp2 = string:concat(StringTemp1,"..0B"),
  ZeroString = lists:flatten(io_lib:fwrite(StringTemp2, [0])),
  CheckValidity = string:equal(FirstNChars_HashedValue,ZeroString),
  if
    CheckValidity == true ->
      %io:format("~p This is here true \n",[HashedValue]),
      masterPID ! {valid, InputString, HashedValue};
  %%pId of receiver of Master process
    true ->
      %{master_node, 'master@LAPTOP-9VUQRFG7' } ! {InputString, HashedValue},
      ok
  end,
  startGeneration(NumOfZeros, masterPID).

receiverMaster() ->
  receive
    {valid, InputString, HashedString} ->
      io:fwrite("Input String:  ~s \t",[InputString]),
      io:fwrite("Valid Hashed Output:  ~s \n", [HashedString]),
      receiverMaster()
  end.

%1st function to start execution.
enableReceiverOfMaster() ->
  register(masterPID, spawn(master, receiverMaster, [])),
  {ok, NumOfZeros} = io:read("Enter a number K: ").
%register(kValue, NumOfZeros),
%startSpawn(NumOfZeros, masterPID).

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