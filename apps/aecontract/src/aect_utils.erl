%%%-------------------------------------------------------------------
%%% @copyright (C) 2017, Aeternity Anstalt
%%% @doc
%%% Utility functions for AE Contracts
%%% @end
%%%-------------------------------------------------------------------

-module(aect_utils).

-export([check_balance/3,
         check/2,
         insert_call_in_trees/2,
         insert_contract_in_trees/2
        ]).

-spec check_balance(aec_keys:pubkey(), aec_trees:trees(), non_neg_integer()) ->
        ok | {error, term()}.
check_balance(ContractKey, Trees, Amount) ->
    AccountsTree = aec_trees:accounts(Trees),
    case aec_accounts_trees:lookup(ContractKey, AccountsTree) of
        {value, Account} ->
            check(aec_accounts:balance(Account) >= Amount, insufficient_funds);
        none -> {error, contract_not_found}
    end.

check(true, _) -> ok;
check(false, Err) -> {error, Err}.

insert_call_in_trees(Call, Trees) ->
    CallsTree0 = aec_trees:calls(Trees),
    CallsTree1 = aect_call_state_tree:insert_call(Call, CallsTree0),
    aec_trees:set_calls(Trees, CallsTree1).

insert_contract_in_trees(Contract, Trees) ->
    CTrees = aec_trees:contracts(Trees),
    CTrees1 = aect_state_tree:insert_contract(Contract, CTrees),
    aec_trees:set_contracts(Trees, CTrees1).
