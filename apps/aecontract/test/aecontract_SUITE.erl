%%%-------------------------------------------------------------------
%%% @copyright (C) 2017, Aeternity Anstalt
%%% @doc CT test suite for AE Contracts
%%% @end
%%%-------------------------------------------------------------------
-module(aecontract_SUITE).

%% common_test exports
-export([ all/0
        , groups/0
        ]).

%% test case exports
-export([ call_contract/1
        , call_contract_error_value/1
        , call_contract_negative_insufficient_funds/1
        , call_contract_negative_gas_price_zero/1
        , call_contract_negative/1
        , create_contract/1
        , create_contract_init_error/1
        , create_contract_negative_gas_price_zero/1
        , create_contract_negative/1
        , state_tree/1
        , sophia_identity/1
        , sophia_state/1
        , sophia_match_bug/1
        , sophia_spend/1
        , sophia_typed_calls/1
        , sophia_oracles/1
        , sophia_oracles_ttl__extend_after_expiry/1
        , sophia_oracles_ttl__fixed_rttl/1
        , sophia_oracles_ttl__qttl_too_long/1
        , sophia_oracles_ttl__answer_after_qttl/1
        , sophia_oracles_ttl__get_answer_after_rttl/1
        , sophia_oracles_ttl__happy_path/1
        , sophia_oracles_ttl__good_query_bad_extend/1
        , sophia_oracles_qfee__basic/1
        , sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_is_awarded_to_oracle/1
        , sophia_oracles_qfee__tx_value_above_qfee_in_query_is_awarded_to_oracle/1
        , sophia_oracles_qfee__qfee_in_query_below_qfee_in_oracle_errs/1
        , sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle/1
        , sophia_oracles_qfee__query_tx_value_below_qfee_does_not_take_from_poor_oracle/1
        , sophia_oracles_qfee__query_tx_value_below_qfee_does_not_take_from_rich_oracle_thanks_to_contract_check/1
        , sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_takes_from_rich_oracle/1
        , sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_does_not_take_from_poor_oracle/1
        , sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_does_not_take_from_rich_oracle_thanks_to_contract_check/1
        , sophia_oracles_qfee__error_after_primop/1
        , sophia_oracles_qfee__basic__remote/1
        , sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_is_awarded_to_oracle__remote/1
        , sophia_oracles_qfee__tx_value_above_qfee_in_query_is_awarded_to_oracle__remote/1
        , sophia_oracles_qfee__qfee_in_query_below_qfee_in_oracle_errs__remote/1
        , sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle__remote/1
        , sophia_oracles_qfee__query_tx_value_below_qfee_does_not_take_from_poor_oracle__remote/1
        , sophia_oracles_qfee__query_tx_value_below_qfee_does_not_take_from_rich_oracle_thanks_to_contract_check__remote/1
        , sophia_oracles_qfee__remote_contract_query_value_below_qfee_takes_from_rich_oracle__remote/1
        , sophia_oracles_qfee__remote_contract_query_value_below_qfee_does_not_take_from_poor_oracle__remote/1
        , sophia_oracles_qfee__remote_contract_query_value_below_qfee_does_not_take_from_rich_oracle_thanks_to_contract_check__remote/1
        , sophia_oracles_qfee__inner_error_after_primop__remote/1
        , sophia_oracles_qfee__outer_error_after_primop__remote/1
        , sophia_oracles_gas_ttl__oracle_registration/1
        , sophia_oracles_gas_ttl__oracle_extension/1
        , sophia_oracles_gas_ttl__query/1
        , sophia_oracles_gas_ttl__response/1
        , sophia_signatures_oracles/1
        , sophia_signatures_aens/1
        , sophia_maps/1
        , sophia_map_benchmark/1
        , sophia_pmaps/1
        , sophia_map_of_maps/1
        , sophia_chess/1
        , sophia_variant_types/1
        , sophia_chain/1
        , sophia_savecoinbase/1
        , sophia_fundme/1
        , sophia_aens/1
        , create_store/1
        , update_store/1
        , read_store/1
        , store_zero_value/1
        , merge_new_zero_value/1
        , merge_missing_keys/1
        ]).

-include_lib("common_test/include/ct.hrl").
-include_lib("stdlib/include/assert.hrl").

-include_lib("apps/aecore/include/blocks.hrl").
-include_lib("apps/aecontract/src/aecontract.hrl").

-define(MINER_PUBKEY, <<12345:?MINER_PUB_BYTES/unit:8>>).
-define(BENEFICIARY_PUBKEY, <<12345:?BENEFICIARY_PUB_BYTES/unit:8>>).

-define(CHAIN_RELATIVE_TTL_MEMORY_ENCODING(X), {variant, 0, [X]}).
-define(CHAIN_ABSOLUTE_TTL_MEMORY_ENCODING(X), {variant, 1, [X]}).

%%%===================================================================
%%% Common test framework
%%%===================================================================

all() ->
    [{group, all_tests}
    ].

groups() ->
    [ {all_tests, [sequence], [ {group, transactions}
                              , {group, state_tree}
                              , {group, sophia}
                              , {group, store}
                              ]}
    , {transactions, [], [ create_contract
                         , create_contract_init_error
                         , create_contract_negative_gas_price_zero
                         , create_contract_negative
                         , call_contract
                         , call_contract_error_value
                         , call_contract_negative_insufficient_funds
                         , call_contract_negative_gas_price_zero
                         , call_contract_negative
                         ]}
    , {state_tree, [sequence], [ state_tree ]}
    , {sophia,     [sequence], [ sophia_identity,
                                 sophia_state,
                                 sophia_match_bug,
                                 sophia_spend,
                                 sophia_typed_calls,
                                 sophia_oracles,
                                 {group, sophia_oracles_ttl},
                                 {group, sophia_oracles_query_fee_happy_path},
                                 {group, sophia_oracles_query_fee_happy_path_remote},
                                 {group, sophia_oracles_query_fee_unhappy_path},
                                 {group, sophia_oracles_query_fee_unhappy_path_remote},
                                 {group, sophia_oracles_gas_ttl},
                                 sophia_signatures_oracles,
                                 sophia_signatures_aens,
                                 sophia_maps,
                                 sophia_map_benchmark,
                                 sophia_variant_types,
                                 sophia_chain,
                                 sophia_savecoinbase,
                                 sophia_fundme,
                                 sophia_aens ]}
    , {sophia_oracles_ttl, [],
          %% Test Oracle TTL handling
        [ sophia_oracles_ttl__extend_after_expiry
        , sophia_oracles_ttl__fixed_rttl
        , sophia_oracles_ttl__qttl_too_long
        , sophia_oracles_ttl__answer_after_qttl
        , sophia_oracles_ttl__get_answer_after_rttl
        , sophia_oracles_ttl__happy_path
        , sophia_oracles_ttl__good_query_bad_extend ]}
    , {sophia_oracles_query_fee_happy_path, [],
       [ %% Test query fee handling from txs calling contract that calls oracle builtins.
         sophia_oracles_qfee__basic
       , sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_is_awarded_to_oracle
       , sophia_oracles_qfee__tx_value_above_qfee_in_query_is_awarded_to_oracle
       ]}
    , {sophia_oracles_query_fee_happy_path_remote, [],
       [ %% Test query fee handling from txs calling contract that calls contract that calls oracle builtins.
         sophia_oracles_qfee__basic__remote
       , sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_is_awarded_to_oracle__remote
       , sophia_oracles_qfee__tx_value_above_qfee_in_query_is_awarded_to_oracle__remote
       ]}
    , {sophia_oracles_query_fee_unhappy_path, [],
       [ %% Test query fee handling from txs calling contract that calls oracle builtins.
         sophia_oracles_qfee__qfee_in_query_below_qfee_in_oracle_errs
       , sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle
       , sophia_oracles_qfee__query_tx_value_below_qfee_does_not_take_from_poor_oracle
       , sophia_oracles_qfee__query_tx_value_below_qfee_does_not_take_from_rich_oracle_thanks_to_contract_check
       , sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_takes_from_rich_oracle
       , sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_does_not_take_from_poor_oracle
       , sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_does_not_take_from_rich_oracle_thanks_to_contract_check
       , sophia_oracles_qfee__error_after_primop
       ]}
    , {sophia_oracles_query_fee_unhappy_path_remote, [],
       [ %% Test query fee handling from txs calling contract that calls contract that calls oracle builtins.
         sophia_oracles_qfee__qfee_in_query_below_qfee_in_oracle_errs__remote
       , sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle__remote
       , sophia_oracles_qfee__query_tx_value_below_qfee_does_not_take_from_poor_oracle__remote
       , sophia_oracles_qfee__query_tx_value_below_qfee_does_not_take_from_rich_oracle_thanks_to_contract_check__remote
       , sophia_oracles_qfee__remote_contract_query_value_below_qfee_takes_from_rich_oracle__remote
       , sophia_oracles_qfee__remote_contract_query_value_below_qfee_does_not_take_from_poor_oracle__remote
       , sophia_oracles_qfee__remote_contract_query_value_below_qfee_does_not_take_from_rich_oracle_thanks_to_contract_check__remote
       , sophia_oracles_qfee__inner_error_after_primop__remote
       , sophia_oracles_qfee__outer_error_after_primop__remote
       ]}
    , {sophia_oracles_gas_ttl, [],
       [ sophia_oracles_gas_ttl__oracle_registration
       , sophia_oracles_gas_ttl__oracle_extension
       , sophia_oracles_gas_ttl__query
       , sophia_oracles_gas_ttl__response
       ]}
    , {store, [sequence], [ create_store
                          , update_store
                          , read_store
                          , store_zero_value
                          , merge_new_zero_value
                          , merge_missing_keys
                          ]}
    ].

%%%===================================================================
%%% Create contract
%%%===================================================================

create_contract_negative_gas_price_zero(_Cfg) ->
    {PubKey, S1} = aect_test_utils:setup_new_account(aect_test_utils:new_state()),
    PrivKey      = aect_test_utils:priv_key(PubKey, S1),

    Overrides = #{gas_price => 0},
    Tx        = aect_test_utils:create_tx(PubKey, Overrides, S1),
    ?assertEqual(0, aect_create_tx:gas_price(aetx:tx(Tx))),

    {error, _} = sign_and_apply_transaction(Tx, PrivKey, S1),
    Env        = aetx_env:tx_env(_Height = 1),
    {error, too_low_gas_price} = aetx:check(Tx, aect_test_utils:trees(S1), Env),
    ok.

create_contract_negative(_Cfg) ->
    {PubKey, S1} = aect_test_utils:setup_new_account(aect_test_utils:new_state()),
    Trees        = aect_test_utils:trees(S1),
    PrivKey      = aect_test_utils:priv_key(PubKey, S1),
    CurrHeight   = 1,
    Env          = aetx_env:tx_env(CurrHeight),

    %% Test creating a bogus account
    {BadPubKey, BadS} = aect_test_utils:setup_new_account(aect_test_utils:new_state()),
    BadPrivKey        = aect_test_utils:priv_key(BadPubKey, BadS),
    RTx1      = aect_test_utils:create_tx(BadPubKey, S1),
    {error, S1} = sign_and_apply_transaction(RTx1, BadPrivKey, S1),

    {error, account_not_found} = aetx:check(RTx1, Trees, Env),

    %% Insufficient funds
    S2     = aect_test_utils:set_account_balance(PubKey, 0, S1),
    Trees2 = aect_test_utils:trees(S2),
    RTx2   = aect_test_utils:create_tx(PubKey, S2),
    {error, S2} = sign_and_apply_transaction(RTx2, PrivKey, S2),
    {error, insufficient_funds} = aetx:check(RTx2, Trees2, Env),

    %% Test too high account nonce
    RTx3 = aect_test_utils:create_tx(PubKey, #{nonce => 0}, S1),
    {error, S1} = sign_and_apply_transaction(RTx3, PrivKey, S1),
    {error, account_nonce_too_high} = aetx:check(RTx3, Trees, Env),

    ok.

create_contract_init_error(_Cfg) ->
    S  = aect_test_utils:new_state(),
    S0 = aect_test_utils:setup_miner_account(?MINER_PUBKEY, S),
    {PubKey, S1} = aect_test_utils:setup_new_account(S0),
    PrivKey      = aect_test_utils:priv_key(PubKey, S1),

    Overrides = #{ call_data => make_calldata(init, {})
                 },
    Tx = aect_test_utils:create_tx(PubKey, Overrides, S1),

    %% Test that the create transaction is accepted
    {ok, S2} = sign_and_apply_transaction(Tx, PrivKey, S1),
    %% Check that the contract is not created
    ContractKey = aect_contracts:compute_contract_pubkey(PubKey, aetx:nonce(Tx)),
    {none, _} = lookup_contract_by_id(ContractKey, S2),
    %% Check that the contract init call is created
    ?assertMatch([_], aect_call_state_tree:to_list(aect_test_utils:calls(S2))),
    InitCallId = aect_call:id(PubKey, aetx:nonce(Tx), ContractKey),
    {value, InitCall} = aect_call_state_tree:lookup_call(ContractKey, InitCallId, aect_test_utils:calls(S2)),
    %% Check that the created init call has the correct details from the contract create tx
    ?assertEqual(PubKey, aect_call:caller_pubkey(InitCall)),
    ?assertEqual(aetx:nonce(Tx), aect_call:caller_nonce(InitCall)),
    ?assertEqual(aect_create_tx:gas_price(aetx:tx(Tx)), aect_call:gas_price(InitCall)),
    ?assertEqual(aect_create_tx:gas_limit(aetx:tx(Tx)), aect_call:gas_used(InitCall)), %% Gas exhausted.
    %% Check that the created init call has the correct details not from the contract create tx
    ?assertEqual(ContractKey, aect_call:contract_pubkey(InitCall)), %% Contract not created.
    ?assertEqual(error, aect_call:return_type(InitCall)),
    _ = aect_call:return_value(InitCall),

    %% Check that contract create transaction sender got charged correctly.
    %%
    %% In particular, check that amount and deposit (are positive and)
    %% returned to the miner.
    ?assertMatch(D when D > 0, aect_create_tx:deposit(aetx:tx(Tx))), %% Check on test data.
    ?assertMatch(A when A > 0, aect_create_tx:amount(aetx:tx(Tx))), %% Check on test data.
    ?assertMatch(F when F > 0, aect_create_tx:fee(aetx:tx(Tx))), %% Check on test data.
    ?assertMatch(G when G > 0, aect_create_tx:gas_limit(aetx:tx(Tx))), %% Check on test data.
    ?assertMatch(P when P > 0, aect_create_tx:gas_price(aetx:tx(Tx))), %% Check on test data.
    ?assertEqual(aec_accounts:balance(aect_test_utils:get_account(PubKey, S1))
                 - aect_create_tx:fee(aetx:tx(Tx))
                 - aect_create_tx:gas_price(aetx:tx(Tx)) * aect_call:gas_used(InitCall),
                 aec_accounts:balance(aect_test_utils:get_account(PubKey, S2))),
    ok.

create_contract(_Cfg) -> create_contract_(1).

create_contract_(ContractCreateTxGasPrice) ->
    S  = aect_test_utils:new_state(),
    S0 = aect_test_utils:setup_miner_account(?MINER_PUBKEY, S),
    {PubKey, S1} = aect_test_utils:setup_new_account(S0),
    PrivKey      = aect_test_utils:priv_key(PubKey, S1),

    IdContract   = aect_test_utils:compile_contract("contracts/identity.aes"),
    CallData     = make_calldata(init, {}),
    Overrides    = #{ code => IdContract
                    , call_data => CallData
                    , gas => 10000
                    , gas_price => ContractCreateTxGasPrice
                    },
    Tx           = aect_test_utils:create_tx(PubKey, Overrides, S1),
    ?assertEqual(ContractCreateTxGasPrice, aect_create_tx:gas_price(aetx:tx(Tx))),

    %% Test that the create transaction is accepted
    {ok, S2} = sign_and_apply_transaction(Tx, PrivKey, S1),
    %% Check that the contract is created
    ContractKey = aect_contracts:compute_contract_pubkey(PubKey, aetx:nonce(Tx)),
    {{value, Contract}, _} = lookup_contract_by_id(ContractKey, S2),
    %% Check that the created contract has the correct details from the contract create tx
    ?assertEqual(PubKey, aect_contracts:owner_pubkey(Contract)),
    ?assertEqual(aect_create_tx:vm_version(aetx:tx(Tx)), aect_contracts:vm_version(Contract)),
    ?assertEqual(aect_create_tx:code(aetx:tx(Tx)), aect_contracts:code(Contract)),
    ?assertEqual(aect_create_tx:deposit(aetx:tx(Tx)), aect_contracts:deposit(Contract)),
    %% Check that the created contract has the correct details not from the contract create tx
    _ = aect_contracts:log(Contract),
    ?assert(aect_contracts:active(Contract)),
    ?assertEqual([], aect_contracts:referrer_ids(Contract)),
    %% Check that the contract init call is created
    ?assertEqual([], aect_call_state_tree:to_list(aect_test_utils:calls(S1))),
    ?assertMatch([_], aect_call_state_tree:to_list(aect_test_utils:calls(S2))),
    InitCallId = aect_call:id(PubKey, aetx:nonce(Tx), ContractKey),
    {value, InitCall} = aect_call_state_tree:lookup_call(ContractKey, InitCallId, aect_test_utils:calls(S2)),
    %% Check that the created init call has the correct details from the contract create tx
    ?assertEqual(PubKey, aect_call:caller_pubkey(InitCall)),
    ?assertEqual(aetx:nonce(Tx), aect_call:caller_nonce(InitCall)),
    ?assertEqual(aect_create_tx:gas_price(aetx:tx(Tx)), aect_call:gas_price(InitCall)),
    %% Check that the created init call has the correct details not from the contract create tx
    ?assertEqual(ContractKey, aect_call:contract_pubkey(InitCall)),
    _ = aect_call:height(InitCall), %% Unclear if this needed.
    ?assertMatch(X when X > 0, aect_call:gas_used(InitCall)),
    ?assertEqual(ok, aect_call:return_type(InitCall)),
    _ = aect_call:return_value(InitCall), %% Value shall be the unit value.

    %% Check that contract create transaction sender got charged correctly.
    ?assertEqual(aec_accounts:balance(aect_test_utils:get_account(PubKey, S1))
                 - aect_create_tx:fee(aetx:tx(Tx))
                 - aect_create_tx:deposit(aetx:tx(Tx))
                 - aect_create_tx:amount(aetx:tx(Tx))
                 - aect_create_tx:gas_price(aetx:tx(Tx)) * aect_call:gas_used(InitCall),
                 aec_accounts:balance(aect_test_utils:get_account(PubKey, S2))),
    %% Check that created contract account got credited correctly.
    ?assertEqual(aect_create_tx:amount(aetx:tx(Tx)),
                 aec_accounts:balance(aect_test_utils:get_account(ContractKey, S2))),

    ok.

sign_and_apply_transaction(Tx, PrivKey, S1) ->
    sign_and_apply_transaction(Tx, PrivKey, S1, 1).

sign_and_apply_transaction(Tx, PrivKey, S1, Height) ->
    SignedTx = aec_test_utils:sign_tx(Tx, PrivKey),
    Trees    = aect_test_utils:trees(S1),
    Env0     = aetx_env:tx_env(Height),
    Env      = aetx_env:set_beneficiary(Env0, ?BENEFICIARY_PUBKEY),
    {ok, AcceptedTxs, Trees1} =
        aec_block_micro_candidate:apply_block_txs([SignedTx], Trees, Env),
    S2       = aect_test_utils:set_trees(Trees1, S1),
    case AcceptedTxs of
        [SignedTx] -> {ok, S2};
        []         -> {error, S2}
    end.

sign_and_apply_transaction_strict(Tx, PrivKey, S1) ->
    sign_and_apply_transaction_strict(Tx, PrivKey, S1, 1).

sign_and_apply_transaction_strict(Tx, PrivKey, S1, Height) ->
    SignedTx = aec_test_utils:sign_tx(Tx, PrivKey),
    Trees    = aect_test_utils:trees(S1),
    Env0     = aetx_env:tx_env(Height),
    Env      = aetx_env:set_beneficiary(Env0, ?BENEFICIARY_PUBKEY),
    {ok, AcceptedTxs, Trees1} =
        aec_block_micro_candidate:apply_block_txs_strict([SignedTx], Trees, Env),
    S2       = aect_test_utils:set_trees(Trees1, S1),
    {SignedTx, AcceptedTxs, S2}.


%%%===================================================================
%%% Call contract
%%%===================================================================

call_contract_negative_insufficient_funds(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc1 = call(fun new_account/2, [1000000]),
    IdC = call(fun create_contract/4, [Acc1, identity, {}]),

    Fee = 1,
    Value = 10,
    Bal = 9 = Fee + Value - 2,
    S = aect_test_utils:set_account_balance(Acc1, Bal, state()),
    CallData = make_calldata(main, 42),
    CallTx = aect_test_utils:call_tx(Acc1, IdC,
                                     #{call_data => CallData,
                                       gas_price => 1,
                                       amount    => Value,
                                       fee       => Fee}, S),
    {error, _} = sign_and_apply_transaction(CallTx, aect_test_utils:priv_key(Acc1, S), S),
    Env = aetx_env:tx_env(_Height = 1),
    {error, insufficient_funds} = aetx:check(CallTx, aect_test_utils:trees(S), Env),
    ok.

call_contract_negative_gas_price_zero(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc1 = call(fun new_account/2, [1000000]),
    IdC  = call(fun create_contract/4, [Acc1, identity, {}]),
    S    = state(),

    Tx   = aect_test_utils:call_tx(Acc1, IdC, #{gas_price => 0}, S),
    ?assertEqual(0, aect_call_tx:gas_price(aetx:tx(Tx))),

    {error, _} = sign_and_apply_transaction(Tx, aect_test_utils:priv_key(Acc1, S), S),
    Env        = aetx_env:tx_env(_Height = 1),
    {error, too_low_gas_price} = aetx:check(Tx, aect_test_utils:trees(S), Env),
    ok.

call_contract_negative(_Cfg) ->
    %% PLACEHOLDER
    ok.

call_contract(_Cfg) -> call_contract_(2).

call_contract_(ContractCallTxGasPrice) ->
    S  = aect_test_utils:new_state(),
    S0 = aect_test_utils:setup_miner_account(?MINER_PUBKEY, S),

    {Owner,  S1}  = aect_test_utils:setup_new_account(S0),
    {Caller, S2}  = aect_test_utils:setup_new_account(S1),
    OwnerPrivKey  = aect_test_utils:priv_key(Owner, S2),
    CallerPrivKey = aect_test_utils:priv_key(Caller, S2),

    CallerBalance = aec_accounts:balance(aect_test_utils:get_account(Caller, S2)),

    IdContract   = aect_test_utils:compile_contract("contracts/identity.aes"),
    CallDataInit = make_calldata(init, {}),
    Overrides    = #{ code => IdContract
                    , call_data => CallDataInit
                    , gas => 10000
                    , gas_price => 1
                    },
    CreateTx     = aect_test_utils:create_tx(Owner, Overrides, S2),
    ?assertEqual(1, aect_create_tx:gas_price(aetx:tx(CreateTx))),

    %% Test that the create transaction is accepted
    {SignedTx, [SignedTx], S3} = sign_and_apply_transaction_strict(CreateTx, OwnerPrivKey, S2),
    ContractKey = aect_contracts:compute_contract_pubkey(Owner, aetx:nonce(CreateTx)),

    %% Now check that we can call it.
    Fee           = 107,
    Value         = 52,
    CallData = make_calldata(main, 42),
    CallTx = aect_test_utils:call_tx(Caller, ContractKey,
                                     #{call_data => CallData,
                                       gas_price => ContractCallTxGasPrice,
                                       amount    => Value,
                                       fee       => Fee}, S3),
    ?assertEqual(ContractCallTxGasPrice, aect_call_tx:gas_price(aetx:tx(CallTx))),
    {ok, S4} = sign_and_apply_transaction(CallTx, CallerPrivKey, S3),
    CallId = aect_call:id(Caller, aetx:nonce(CallTx), ContractKey),

    %% Check that it got stored and that we got the right return value
    ?assertMatch([_, _], aect_call_state_tree:to_list(aect_test_utils:calls(S4))), %% Init + Call
    Call = aect_call_state_tree:get_call(ContractKey, CallId, aect_test_utils:calls(S4)),
    ok = aect_call:return_type(Call),
    <<42:256>> = aect_call:return_value(Call),
    %% Check that the stored call has the correct rest of the details
    ?assertEqual(Caller, aect_call:caller_pubkey(Call)),
    ?assertEqual(aetx:nonce(CallTx), aect_call:caller_nonce(Call)),
    _ = aect_call:height(Call), %% Unclear if this needed.
    ?assertEqual(ContractKey, aect_call:contract_pubkey(Call)),
    ?assertEqual(aect_call_tx:gas_price(aetx:tx(CallTx)), aect_call:gas_price(Call)),
    ?assertMatch(X when X > 0, aect_call:gas_used(Call)),

    %% Check that contract call transaction sender got charged the right amount for gas and fee.
    {NewCallerBalance, NewCallerBalance} =
        {aec_accounts:balance(aect_test_utils:get_account(Caller, S4)),
         CallerBalance - Fee - aect_call_tx:gas_price(aetx:tx(CallTx)) * aect_call:gas_used(Call) - Value},
    %% Check that called account got credited correctly.
    ?assertEqual(aec_accounts:balance(aect_test_utils:get_account(ContractKey, S3))
                 + aect_call_tx:amount(aetx:tx(CallTx)),
                 aec_accounts:balance(aect_test_utils:get_account(ContractKey, S4))),

    {ok, S4}.

%% Check behaviour of contract call error - especially re value / amount.
call_contract_error_value(_Cfg) ->
    F = 1,
    G = 60000,
    DefaultOpts = #{fee => F, gas_price => 1, gas => G, amount => 0},
    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,
    %% Initialization.
    state(aect_test_utils:new_state()),
    Acc1 = call(fun new_account/2, [1000000]),
    IdC = call(fun create_contract/5, [Acc1, value_on_err, {}, DefaultOpts#{deposit => 0}]),
    RemC = call(fun create_contract/5, [Acc1, remote_value_on_err, {}, DefaultOpts#{deposit => 0}]),
    0 = call(fun account_balance/2, [IdC]),
    0 = call(fun account_balance/2, [RemC]),
    %% Sanity check: value is transferred as expected in calls that do not err.
    S0 = state(),
    {{11, GasUsed1}, S1} = call_contract(Acc1, IdC, ok, word, {}, DefaultOpts#{amount := 3, return_gas_used => true}, S0),
    ?assertMatch(U when U < G, GasUsed1),
    ?assertEqual(Bal(Acc1, S0) - (F + GasUsed1 + 3), Bal(Acc1, S1)),
    ?assertEqual(Bal(RemC, S0), Bal(RemC, S1)),
    ?assertEqual(Bal(IdC, S0) + 3, Bal(IdC, S1)),
    {{11, GasUsed2}, S2} = call_contract(Acc1, RemC, callOk, word, {IdC, 10}, DefaultOpts#{amount := 14, return_gas_used => true}, S1),
    ?assertEqual(Bal(Acc1, S1) - (F + GasUsed2 + 14), Bal(Acc1, S2)),
    ?assertEqual(Bal(RemC, S1) + (14 - 10), Bal(RemC, S2)),
    ?assertEqual(Bal(IdC, S1) + 10, Bal(IdC, S2)),
    %% Check tranfer of value in calls that err.
    {{{error, <<"out_of_gas">>}, GasUsed3}, S3} = call_contract(Acc1, IdC, err, word, {}, DefaultOpts#{amount := 5, return_gas_used => true}, S2),
    ?assertEqual(G, GasUsed3),
    ?assertEqual(Bal(Acc1, S2) - (F + G + 5), Bal(Acc1, S3)),
    ?assertEqual(Bal(RemC, S2), Bal(RemC, S3)),
    ?assertEqual(Bal(IdC, S2) + 5, Bal(IdC, S3)),
    {{{error, <<"out_of_gas">>}, GasUsed4}, S4} = call_contract(Acc1, RemC, callErr, word, {IdC, 7}, DefaultOpts#{amount := 13, return_gas_used => true}, S3),
    ?assertEqual(G, GasUsed4),
    ?assertEqual(Bal(Acc1, S3) - (F + G + 13), Bal(Acc1, S4)),
    ?assertEqual(Bal(RemC, S3) + 13, Bal(RemC, S4)),
    ?assertEqual(Bal(IdC, S3), Bal(IdC, S4)),
    ok.

%%%===================================================================
%%% State trees
%%%===================================================================

make_contract(PubKey, Code, S) ->
    Tx = aect_test_utils:create_tx(PubKey, #{ vm_version => 2,
                                              code => Code }, S),
    {contract_create_tx, CTx} = aetx:specialize_type(Tx),
    aect_contracts:new(CTx).

make_call(PubKey, ContractKey,_Call,_S) ->
    aect_call:new(aec_id:create(account, PubKey), 0,
                  aec_id:create(contract, ContractKey), 1, 1).

state()  -> get(the_state).
state(S) -> put(the_state, S).

get_contract_state(Contract) ->
    S = state(),
    {{value, C}, _} = lookup_contract_by_id(Contract, S),
    aect_contracts:state(C).

call(Name, Fun, Xs) ->
    Fmt = string:join(lists:duplicate(length(Xs), "~p"), ", "),
    Xs1 = [ case X of
                <<Pre:32, _:28/unit:8>> -> <<Pre:32>>;
                _ -> X
            end || X <- Xs ],
    io:format("~p(" ++ Fmt ++ ") ->\n", [Name | Xs1]),
    R = call(Fun, Xs),
    io:format("  ~p\n", [R]),
    R.

call(Fun, Xs) when is_function(Fun, 1 + length(Xs)) ->
    S = state(),
    {R, S1} = try apply(Fun, Xs ++ [S])
              catch _:Reason -> {{'EXIT', Reason, erlang:get_stacktrace()}, S}
              end,
    state(S1),
    R.

-define(call(Fun, X),                call(Fun, fun Fun/2, [X])).
-define(call(Fun, X, Y),             call(Fun, fun Fun/3, [X, Y])).
-define(call(Fun, X, Y, Z),          call(Fun, fun Fun/4, [X, Y, Z])).
-define(call(Fun, X, Y, Z, U),       call(Fun, fun Fun/5, [X, Y, Z, U])).
-define(call(Fun, X, Y, Z, U, V),    call(Fun, fun Fun/6, [X, Y, Z, U, V])).
-define(call(Fun, X, Y, Z, U, V, W), call(Fun, fun Fun/7, [X, Y, Z, U, V, W])).

perform_pre_transformations(Height, S) ->
    Trees = aec_trees:perform_pre_transformations(aect_test_utils:trees(S), Height),
    {ok, aect_test_utils:set_trees(Trees, S)}.

new_account(Balance, S) ->
    aect_test_utils:setup_new_account(Balance, S).

insert_contract(Account, Code, S) ->
    Contract  = make_contract(Account, Code, S),
    Contracts = aect_state_tree:insert_contract(Contract, aect_test_utils:contracts(S)),
    {Contract, aect_test_utils:set_contracts(Contracts, S)}.

insert_call(Sender, Contract, Fun, S) ->
    ContractPubkey = aect_contracts:pubkey(Contract),
    Call           = make_call(Sender, ContractPubkey, Fun, S),
    CallTree       = aect_call_state_tree:insert_call(Call, aect_test_utils:calls(S)),
    {Call, aect_test_utils:set_calls(CallTree, S)}.

get_contract(Contract0, S) ->
    ContractPubkey = aect_contracts:pubkey(Contract0),
    Contracts      = aect_test_utils:contracts(S),
    Contract       = aect_state_tree:get_contract(ContractPubkey, Contracts),
    {Contract, S}.

lookup_contract_by_id(ContractKey, S) ->
    Contracts = aect_test_utils:contracts(S),
    X         = aect_state_tree:lookup_contract(ContractKey, Contracts),
    {X, S}.

get_call(Contract0, Call0, S) ->
    CallId         = aect_call:id(Call0),
    ContractPubkey = aect_contracts:pubkey(Contract0),
    CallTree       = aect_test_utils:calls(S),
    Call           = aect_call_state_tree:get_call(ContractPubkey, CallId, CallTree),
    {Call, S}.

state_tree(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc1  = ?call(new_account, 100),
    Ct1   = ?call(insert_contract, Acc1, <<"Code for C1">>),
    Ct1   = ?call(get_contract, Ct1),
    Acc2  = ?call(new_account, 50),
    Acc3  = ?call(new_account, 30),
    Ct2   = ?call(insert_contract, Acc2, <<"Code for C2">>),
    Ct2   = ?call(get_contract, Ct2),
    Ct1   = ?call(get_contract, Ct1),
    Call1 = ?call(insert_call, Acc3, Ct1, <<"Ct1.foo">>),
    Call2 = ?call(insert_call, Acc2, Ct1, <<"Ct1.bar">>),
    Call1 = ?call(get_call, Ct1, Call1),
    Call2 = ?call(get_call, Ct1, Call2),
    Ct1   = ?call(get_contract, Ct1),
    <<"Code for C1">> = aect_contracts:code(Ct1),
    ok.

%%%===================================================================
%%% More elaborate Sophia contracts
%%%===================================================================

create_contract(Owner, Name, Args, S) ->
    create_contract(Owner, Name, Args, #{}, S).

create_contract(Owner, Name, Args, Options, S) ->
    Nonce       = aect_test_utils:next_nonce(Owner, S),
    Code        = aect_test_utils:compile_contract(lists:concat(["contracts/", Name, ".aes"])),
    CallData    = make_calldata(init, Args),
    CreateTx    = aect_test_utils:create_tx(Owner,
                    maps:merge(
                    #{ nonce      => Nonce
                     , vm_version => ?AEVM_01_Sophia_01
                     , code       => Code
                     , call_data  => CallData
                     , fee        => 1
                     , deposit    => 0
                     , amount     => 0
                     , gas        => 10000 }, maps:without([height, return_gas_used], Options)), S),
    Height   = maps:get(height, Options, 1),
    PrivKey  = aect_test_utils:priv_key(Owner, S),
    {ok, S1} = sign_and_apply_transaction(CreateTx, PrivKey, S, Height),
    ContractKey = aect_contracts:compute_contract_pubkey(Owner, Nonce),
    CallKey     = aect_call:id(Owner, Nonce, ContractKey),
    CallTree    = aect_test_utils:calls(S1),
    Call        = aect_call_state_tree:get_call(ContractKey, CallKey, CallTree),
    case maps:get(return_gas_used, Options, false) of
        false -> {ContractKey, S1};
        true  -> {{ContractKey, aect_call:gas_used(Call)}, S1}
    end.

call_contract(Caller, ContractKey, Fun, Type, Args, S) ->
    call_contract(Caller, ContractKey, Fun, Type, Args, #{}, S).

call_contract(Caller, ContractKey, Fun, Type, Args, Options, S) ->
    Nonce    = aect_test_utils:next_nonce(Caller, S),
    Calldata = make_calldata(Fun, Args),
    CallTx   = aect_test_utils:call_tx(Caller, ContractKey,
                maps:merge(
                #{ nonce      => Nonce
                 , vm_version => ?AEVM_01_Sophia_01
                 , call_data  => Calldata
                 , fee        => 1
                 , amount     => 0
                 , gas        => 50000
                 }, maps:remove(height, Options)), S),
    Height   = maps:get(height, Options, 1),
    PrivKey  = aect_test_utils:priv_key(Caller, S),
    {ok, S1} = sign_and_apply_transaction(CallTx, PrivKey, S, Height),
    CallKey  = aect_call:id(Caller, Nonce, ContractKey),
    CallTree = aect_test_utils:calls(S1),
    Call     = aect_call_state_tree:get_call(ContractKey, CallKey, CallTree),
    Result   =
        case aect_call:return_type(Call) of
            ok     -> {ok, Res} = aeso_data:from_binary(Type, aect_call:return_value(Call)),
                      Res;
            error  -> {error, aect_call:return_value(Call)};
            revert -> revert
        end,
    case maps:get(return_gas_used, Options, false) of
        false -> {Result, S1};
        true  -> {{Result, aect_call:gas_used(Call)}, S1}
    end.

account_balance(PubKey, S) ->
    Account = aect_test_utils:get_account(PubKey, S),
    {aec_accounts:balance(Account), S}.

make_calldata(Fun, Args0) ->
    Args         = translate_pubkeys(if is_tuple(Args0) -> Args0; true -> {Args0} end),
    CalldataType = {tuple, [string, aeso_abi:get_type(Args)]},
    aeso_data:to_binary({CalldataType, {list_to_binary(atom_to_list(Fun)), Args}}).

translate_pubkeys(<<N:256>>) -> N;
translate_pubkeys([H|T]) ->
  [translate_pubkeys(H) | translate_pubkeys(T)];
translate_pubkeys(T) when is_tuple(T) ->
  list_to_tuple(translate_pubkeys(tuple_to_list(T)));
translate_pubkeys(M) when is_map(M) ->
  maps:from_list(translate_pubkeys(maps:to_list(M)));
translate_pubkeys(X) -> X.

sophia_identity(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc1 = ?call(new_account, 1000000),
    %% Remote calling the identity contract
    IdC   = ?call(create_contract, Acc1, identity, {}),
    RemC  = ?call(create_contract, Acc1, remote_call, {}, #{amount => 100}),
    42    = ?call(call_contract,   Acc1, IdC, main, word, 42),
    99    = ?call(call_contract,   Acc1, RemC, call, word, {IdC, 99}),
    RemC2 = ?call(create_contract, Acc1, remote_call, {}, #{amount => 100}),
    77    = ?call(call_contract,   Acc1, RemC2, staged_call, word, {IdC, RemC, 77}),
    ok.

sophia_state(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc1         = ?call(new_account, 1000000),
    InitStack    = [<<"top">>, <<"middle">>, <<"bottom">>],
    Stack        = ?call(create_contract, Acc1, stack, InitStack),
    3            = ?call(call_contract,   Acc1, Stack, size, word, {}),
    InitStack    = ?call(call_contract, Acc1, Stack, all, {list, string}, {}),
    4            = ?call(call_contract, Acc1, Stack, push, word, <<"foo">>),
    <<"foo">>    = ?call(call_contract, Acc1, Stack, pop, string, {}),
    <<"top">>    = ?call(call_contract, Acc1, Stack, pop, string, {}),
    <<"middle">> = ?call(call_contract, Acc1, Stack, pop, string, {}),
    <<"bottom">> = ?call(call_contract, Acc1, Stack, pop, string, {}),
    {error, <<"out_of_gas">>} = ?call(call_contract, Acc1, Stack, pop, string, {}),
    ok.

%% There was a bug matching on _::_.
sophia_match_bug(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc1      = ?call(new_account, 1000000),
    Poly      = ?call(create_contract, Acc1, polymorphism_test, {}),
    [5, 7, 9] = ?call(call_contract, Acc1, Poly, foo, {list, word}, {}),
    [1, 0, 3] = ?call(call_contract, Acc1, Poly, bar, {list, word}, {}),
    %% invalid_jumpdest
    ok.

sophia_spend(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc1         = ?call(new_account, 1000000),
    Acc2         = ?call(new_account, 2000000),
    Ct1          = ?call(create_contract, Acc1, spend_test, {}, #{amount => 10000}),
    Ct2          = ?call(create_contract, Acc1, spend_test, {}, #{amount => 20000}),
    10000        = ?call(call_contract, Acc1, Ct1, get_balance, word, {}),
    20000        = ?call(call_contract, Acc1, Ct2, get_balance, word, {}),
    5000         = ?call(call_contract, Acc1, Ct2, spend, word, {Acc2, 15000}),
    5000         = ?call(call_contract, Acc1, Ct1, get_balance_of, word, Ct2),
    10000        = ?call(call_contract, Acc1, Ct1, get_balance, word, {}),
    5000         = ?call(call_contract, Acc1, Ct2, get_balance, word, {}),
    2015000      = ?call(call_contract, Acc1, Ct1, get_balance_of, word, Acc2),
    %% Spend in nested call
    2021000      = ?call(call_contract, Acc1, Ct2, spend_from, word, {Ct1, Acc2, 6000}),
    2021000      = ?call(call_contract, Acc1, Ct1, get_balance_of, word, Acc2),
    4000         = ?call(call_contract, Acc1, Ct1, get_balance_of, word, Ct1),
    5000         = ?call(call_contract, Acc1, Ct1, get_balance_of, word, Ct2),
    ok.

sophia_typed_calls(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc    = ?call(new_account, 1000000),
    Server = ?call(create_contract, Acc, multiplication_server, {}),
    Client = ?call(create_contract, Acc, contract_types, Server, #{amount => 1000}),
    2      = ?call(call_contract, Acc, Client, get_n, word, {}),
    {}     = ?call(call_contract, Acc, Client, square, {tuple, []}, {}),
    4      = ?call(call_contract, Acc, Client, get_n, word, {}),
    {}     = ?call(call_contract, Acc, Client, square, {tuple, []}, {}),
    16     = ?call(call_contract, Acc, Client, get_n, word, {}),
    {}     = ?call(call_contract, Acc, Client, square, {tuple, []}, {}),
    256    = ?call(call_contract, Acc, Client, get_n, word, {}),
    {}     = ?call(call_contract, Acc, Client, tip_server, {tuple, []}, {}, #{amount => 100}),
    400    = ?call(account_balance, Server),
    ok.

%% Oracles tests

%% TODO:
%%  - signatures (when oracle is different from contract)
%%  - Failing calls
sophia_oracles(_Cfg) ->
    state(aect_test_utils:new_state()),
    RelativeTTL       = fun(Delta)  -> ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(Delta) end,
    FixedTTL          = fun(Height) -> ?CHAIN_ABSOLUTE_TTL_MEMORY_ENCODING(Height) end,
    Acc               = ?call(new_account, 1000000),
    Ct = <<CtId:256>> = ?call(create_contract, Acc, oracles, {}, #{amount => 100000}),
    QueryFee          = 100,
    TTL               = 15,
    CtId              = ?call(call_contract, Acc, Ct, registerOracle, word, {CtId, 0, QueryFee, FixedTTL(TTL)}),
    Question          = <<"Manchester United vs Brommapojkarna">>,
    QId               = ?call(call_contract, Acc, Ct, createQuery, word,
                                {Ct, Question, QueryFee, RelativeTTL(5), RelativeTTL(5)}, #{amount => QueryFee}),
    Question          = ?call(call_contract, Acc, Ct, getQuestion, string, {CtId, QId}),
    QueryFee          = ?call(call_contract, Acc, Ct, queryFee, word, Ct),
    none              = ?call(call_contract, Acc, Ct, getAnswer, {option, word}, {CtId, QId}),
    {}                = ?call(call_contract, Acc, Ct, respond, {tuple, []}, {CtId, QId, 0, 4001}),
    {some, 4001}      = ?call(call_contract, Acc, Ct, getAnswer, {option, word}, {CtId, QId}),
    {}                = ?call(call_contract, Acc, Ct, extendOracle, {tuple, []}, {Ct, 0, RelativeTTL(10)}),

    %% Test complex answers
    Ct1 = ?call(create_contract, Acc, oracles, {}, #{amount => 100000}),
    QuestionType = {variant_t, [{why, [word]}, {how, [string]}]},
    AnswerType   = {variant_t, [{noAnswer, []}, {yesAnswer, [QuestionType, string, word]}]},
    Question1    = {1, <<"birds fly?">>},
    Answer       = {yesAnswer, {how, <<"birds fly?">>}, <<"magic">>, 1337},
    {some, Answer} = ?call(call_contract, Acc, Ct1, complexOracle, {option, AnswerType}, {Question1, 0}),
    ok.

%% Oracle TTL tests

%% Tests are checked by a little state machine keeping track of a single oracle
%% and query.
interpret_ttl(St, Cmds) ->
    interpret_ttl(St, 0, Cmds).

interpret_ttl(St, _, []) -> St;
interpret_ttl(St, H, [{H, Cmd} | Rest]) ->
    ?call(perform_pre_transformations, H),
    St1 = step_ttl(St, H, Cmd),
    interpret_ttl(St1, H + 1, Rest);
interpret_ttl(St, H, Cmds) ->
    ?call(perform_pre_transformations, H),
    interpret_ttl(St, H + 1, Cmds).

ttl_height(H, {delta, D}) -> D + H;
ttl_height(_, {block, H}) -> H.

%% Run a single transaction from an Oracle TTL scenario and check the results.
step_ttl(St = #{ account := Acc, contract := Ct }, Height, Cmd) ->
    Enc = fun({delta, D}) -> ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(D);
             ({block, H}) -> ?CHAIN_ABSOLUTE_TTL_MEMORY_ENCODING(H) end,
    QFee = 10,
    Error = {error, <<"out_of_gas">>},
    io:format("-- At height ~p --\nState ~p\nTransaction: ~p\n", [Height, St, Cmd]),
    case Cmd of
        {create, TTL} ->
            Oracle = ?call(call_contract, Acc, Ct, registerOracle, word, {Ct, 0, QFee, Enc(TTL)}, #{ height => Height }),
            St#{ oracle => Oracle, oracle_ttl => ttl_height(Height, TTL) };
        {extend, TTL} ->
            #{ oracle := Oracle, oracle_ttl := TTLo } = St,
            Res = ?call(call_contract, Acc, Ct, extendOracle, {tuple, []}, {Oracle, 0, Enc(TTL)}, #{ height => Height }),
            NewTTLo = ttl_height(TTLo, TTL),
            %% Can't extend if expired, and new expiry must be > old expiry,
            %% and TTL must be relative.
            case TTLo >= Height andalso NewTTLo > TTLo andalso element(1, TTL) == delta of
                true  -> {} = Res, St#{ oracle_ttl => NewTTLo }; %% Extend relative to previous expiry
                false -> Error = Res, St
            end;
        {query, TTLq, TTLr} ->
            #{ oracle := Oracle, oracle_ttl := TTLo } = St,
            Res = ?call(call_contract, Acc, Ct, createQuery, word, {Oracle, <<"?">>, QFee, Enc(TTLq), Enc(TTLr)},
                                         #{ height => Height, amount => QFee }),
            AbsTTLq = ttl_height(Height, TTLq),
            AbsTTLr = ttl_height(AbsTTLq, TTLr),
            %% Latest possible response expiry must be before oracle expiry and
            %% response TTL must be relative.
            case TTLo >= AbsTTLr andalso element(1, TTLr) == delta of
                true ->
                    true = is_integer(Res),
                    St#{ query => Res, query_ttl => AbsTTLq, reply_ttl => TTLr };
                _ -> Error = Res, St
            end;
        respond ->
            #{ oracle := Oracle, query := Query, query_ttl := TTLq, reply_ttl := TTLr } = St,
            Res = ?call(call_contract, Acc, Ct, respond, {tuple, []}, {Oracle, Query, 0, 42}, #{ height => Height }),
            case TTLq >= Height of  %% Query must not have expired
                true  -> St#{ reply_ttl => ttl_height(Height, TTLr) };
                false -> Error = Res, St
            end;
        getAnswer ->
            #{ oracle := Oracle, query := Query, reply_ttl := TTLr } = St,
            ExpectedRes = case TTLr >= Height of   %% Response must not have expired,
                            true  -> {some, 42};   %% and we only ask after responding.
                            false -> none
                          end,
            ExpectedRes = ?call(call_contract, Acc, Ct, getAnswer, {option, word}, {Oracle, Query}, #{ height => Height }),
            St
    end.

ttls(Now, Ts) ->
    [{block, T} || T <- Ts] ++
    [{delta, T - Now} || T <- Ts, T > Now].

%% Base scenario for setting up and possibly extending an oracle.
ttl_scenario_create_and_extend(Start0, Extend0, Stop0) ->
    List = fun(X) when is_list(X) -> X; (X) -> [X] end,
    [ [ {Start,  {create, TTLo}} ] ++
      [ {Extend, {extend, TTLe}} || Extend /= false ]
      || Start <- List(Start0), Extend <- List(Extend0), Stop <- List(Stop0),
         TTLo <- [ T || Extend == false, T <- ttls(Start, [Stop]) ] ++
                 [ T || Extend /= false, T <- ttls(Start, [Extend + 5]) ],
         TTLe = {delta, _} <- [ {delta, 0} || Extend == false ] ++
                              [ T || Extend /= false, T <- ttls(ttl_height(Start, TTLo), [Stop]) ] ].

%% Base scenario for failing or unnecessary extends.
ttl_scenario_bad_extend(Start0, Extend0, Stop0) ->
    List = fun(X) when is_list(X) -> X; (X) -> [X] end,
    [ [ {Start,  {create, TTLo}},
        {Extend, {extend, TTLe}} ]
    || Start <- List(Start0), Extend <- List(Extend0), Stop <- List(Stop0),
       TTLo  <- ttls(Start, [Stop]),
       TTLe  <- ttls(ttl_height(Start, TTLo),
                     [Extend - 5,   %% Try to extend before current height
                      Extend,       %% Equal to current height
                      Extend + 5,   %% Between now and planned expiry
                      Stop]) ++     %% Same as previous expiry
                [{block, ttl_height(Start, TTLo) + 5}] %% After previous, but absolute TTL
    ].

%% Base scenario for setting up a query
ttl_scenario_create_query(Start0, Extend0, Query0, QTTL0, RTTL0, Stop0) ->
    List = fun(X) when is_list(X) -> X; (X) -> [X] end,
    [ combine_ttl_scenarios(Setup, [{Query, {query, QTTL, {delta, RTTL}}}])
    || Setup <- ttl_scenario_create_and_extend(Start0, Extend0, Stop0),
       Query <- List(Query0),
       QTTL  <- ttls(Query, List(QTTL0)),
       RTTL  <- List(RTTL0) ].

%% Extending an oracle must be done before expiry.
ttl_scenario_extend_after_expiry() ->
    [ [ {10, {create, TTLo}},
        {20, {extend, TTLe}} ]
    || TTLo <- ttls(10, [15]),
       TTLe <- ttls(20, [25]) ].

%% Absolute RTTLs are not allowed.
ttl_scenario_fixed_rttl() ->
    [ combine_ttl_scenarios(Setup, [{20, {query, QTTL, {block, 40}}}])
    || Setup <- ttl_scenario_create_and_extend(10, false, 100),
       QTTL  <- ttls(20, [30]) ].

%% Query TTL too long
ttl_scenario_qttl_too_long() ->
    [ combine_ttl_scenarios(Setup, [{25, {query, QTTL, {delta, RTTL}}}])
    || Setup <- ttl_scenario_create_and_extend(10, [false, 20], 50),
       QTTL  <- ttls(25, [40, 60]),
       RTTL  <- [15]
    ].

%% Answer after QTTL
ttl_scenario_answer_after_qttl() ->
    [ combine_ttl_scenarios(Setup, [{45, respond}])
    || Setup <- ttl_scenario_create_query(10, [false, 20], 25, 40, 10, 70)
    ].

%% Get answer after RTTL
ttl_scenario_get_answer_after_rttl() ->
    [ combine_ttl_scenarios(Setup, [{35, respond}, {50, getAnswer}])
    || Setup <- ttl_scenario_create_query(10, [false, 20], 25, 40, 10, 70)
    ].

%% Oracle TTL happy path
ttl_scenario_happy_path() ->
    [ combine_ttl_scenarios(Setup, [{30, respond}, {Ans, getAnswer}])
    || Setup <- ttl_scenario_create_query(10, [false, 20], 25, 40, 20, 70),
       Ans   <- [35, 45] ].

%% Oracle TTL successful query, bad extend.
ttl_scenario_good_query_bad_extend() ->
    [ combine_ttl_scenarios(Setup,
        [{25,  {query, QTTL, {delta, 10}}},
         {30,  respond},
         {Ans, getAnswer}])
    || Setup <- ttl_scenario_bad_extend(10, 20, 50),
       QTTL  <- ttls(25, [40]),
       Ans   <- [35, 40, 45] ].

combine_ttl_scenarios(Cmds1, Cmds2) ->
    lists:keymerge(1, Cmds1, Cmds2).

run_ttl_scenario(Scenario) ->
    state(aect_test_utils:new_state()),
    Acc = ?call(new_account, 10000000000),
    [ begin
        Ct = ?call(create_contract, Acc, oracles, {}, #{amount => 10000}),
        io:format("Testing ~p\n", [Cmds]),
        interpret_ttl(#{contract => Ct, account => Acc}, Cmds)
      end || Cmds <- Scenario ],
    ok.

sophia_oracles_ttl__extend_after_expiry(_Cfg) ->
    run_ttl_scenario(ttl_scenario_extend_after_expiry()).

sophia_oracles_ttl__fixed_rttl(_Cfg) ->
    run_ttl_scenario(ttl_scenario_fixed_rttl()).

sophia_oracles_ttl__qttl_too_long(_Cfg) ->
    run_ttl_scenario(ttl_scenario_qttl_too_long()).

sophia_oracles_ttl__answer_after_qttl(_Cfg) ->
    run_ttl_scenario(ttl_scenario_answer_after_qttl()).

sophia_oracles_ttl__get_answer_after_rttl(_Cfg) ->
    run_ttl_scenario(ttl_scenario_get_answer_after_rttl()).

sophia_oracles_ttl__happy_path(_Cfg) ->
    run_ttl_scenario(ttl_scenario_happy_path()).

sophia_oracles_ttl__good_query_bad_extend(_Cfg) ->
    run_ttl_scenario(ttl_scenario_good_query_bad_extend()).

%% -- End TTL tests --

oracle_init_from_contract(OperatorAcc, InitialOracleContractBalance, S) ->
    {{OCt, GasUsed}, S1} = create_contract(OperatorAcc, oracles, {},
        #{amount          => InitialOracleContractBalance,
          return_gas_used => true}, S),
    {{OCt, OCt, GasUsed}, S1}.

oracle_init_from_remote_contract(OperatorAcc, InitialOracleContractBalance, S) ->
    {{OCt, GasUsed}, S1} = create_contract(OperatorAcc, oracles, {}, #{
          amount          => InitialOracleContractBalance,
          return_gas_used => true}, S),
    {RCt, S2} = create_contract(OperatorAcc, remote_oracles, {}, #{amount => 0}, S1),
    {{OCt, RCt, GasUsed}, S2}.

oracle_register_from_contract(OperatorAcc, OCt, OCt, Opts, TxOpts0, S) ->
    QueryFee = maps:get(qfee, Opts),
    OTtl = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(maps:get(ottl, Opts, 15)),
    TxOpts = TxOpts0#{return_gas_used => true},
    call_contract(OperatorAcc, OCt, registerOracle, word, {OCt, 0, QueryFee, OTtl}, TxOpts, S).

oracle_register_from_remote_contract(OperatorAcc, RCt, OCt, Opts, TxOpts0, S) ->
    QueryFee = maps:get(qfee, Opts),
    OTtl = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(maps:get(ottl, Opts, 15)),
    TxOpts = TxOpts0#{return_gas_used => true},
    call_contract(OperatorAcc, RCt, callRegisterOracle, word, {OCt, OCt, 0, QueryFee, OTtl}, TxOpts, S).

oracle_query_from_contract(UserAcc, OCt, OCt, Opts, TxOpts, S) ->
    oracle_query_from_contract_(createQuery, UserAcc, OCt, OCt, Opts, TxOpts, S).
oracle_unsafe_query_from_contract(UserAcc, OCt, OCt, Opts, TxOpts, S) ->
    oracle_query_from_contract_(unsafeCreateQuery, UserAcc, OCt, OCt, Opts, TxOpts, S).
oracle_query_from_contract_(Fun, UserAcc, OCt, OCt, Opts, TxOpts0, S) ->
    QueryFee = maps:get(qfee, Opts),
    Question = maps:get(question, Opts, <<"why?">>),
    ?assertMatch(_ when is_binary(Question), Question),
    QTtl = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(maps:get(qttl, Opts, 5)),
    RTtl = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(maps:get(rttl, Opts, 5)),
    TxOpts = TxOpts0#{return_gas_used => true},
    call_contract(UserAcc, OCt, Fun, word, {OCt, Question, QueryFee, QTtl, RTtl}, TxOpts, S).

oracle_query_from_remote_contract(UserAcc, RCt, OCt, Opts, TxOpts, S) ->
    oracle_query_from_remote_contract_(callCreateQuery, UserAcc, RCt, OCt, Opts, TxOpts, S).
oracle_unsafe_query_from_remote_contract(UserAcc, RCt, OCt, Opts, TxOpts, S) ->
    oracle_query_from_remote_contract_(callUnsafeCreateQuery, UserAcc, RCt, OCt, Opts, TxOpts, S).
oracle_query_from_remote_contract_(Fun, UserAcc, RCt, OCt, Opts, TxOpts, S) ->
    oracle_query_from_remote_contract_(Fun, UserAcc, RCt, OCt, OCt, Opts, TxOpts, S).
oracle_query_from_remote_contract_(Fun, UserAcc, RCt, OCt, OAcc, Opts, TxOpts0, S) ->
    QueryFee = maps:get(qfee, Opts),
    Question = maps:get(question, Opts, <<"why?">>),
    QTtl = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(maps:get(qttl, Opts, 5)),
    RTtl = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(maps:get(rttl, Opts, 5)),
    Value = case maps:find(remote_value, Opts) of
                {ok, V} -> V;
                error -> maps:get(amount, TxOpts0)
            end,
    TxOpts = TxOpts0#{return_gas_used => true},
    call_contract(UserAcc, RCt, Fun, word, {OCt, Value, OAcc, Question, QueryFee, QTtl, RTtl}, TxOpts, S).

oracle_check_and_respond_from_contract(OperatorAcc, OCt, OCt, QueryId, Opts, TxOpts0, S) ->
    ?assertMatch({Question, _} when is_binary(Question), call_contract(OperatorAcc, OCt, getQuestion, string, {OCt, QueryId}, S)),
    Response = maps:get(response, Opts, 4001),
    ?assertMatch(_ when is_integer(Response), Response),
    TxOpts = TxOpts0#{return_gas_used => true},
    {{R, GasUsed}, S1} = call_contract(OperatorAcc, OCt, respond, {tuple, []}, {OCt, QueryId, 0, Response}, TxOpts, S),
    ?assertMatch({{some, Response}, _}, call_contract(OperatorAcc, OCt, getAnswer, {option, word}, {OCt, QueryId}, S1)),
    {{R, GasUsed}, S1}.

oracle_check_and_respond_from_remote_contract(OperatorAcc, RCt, OCt, QueryId, Opts, TxOpts0, S) ->
    ?assertMatch({Question, _} when is_binary(Question), call_contract(OperatorAcc, OCt, getQuestion, string, {OCt, QueryId}, S)),
    Response = maps:get(response, Opts, 4001),
    TxOpts = TxOpts0#{return_gas_used => true},
    {{R, GasUsed}, S1} = call_contract(OperatorAcc, RCt, callRespond, {tuple, []}, {OCt, OCt, QueryId, 0, Response}, TxOpts, S),
    ?assertMatch({{some, Response}, _}, call_contract(OperatorAcc, OCt, getAnswer, {option, word}, {OCt, QueryId}, S1)),
    {{R, GasUsed}, S1}.

-record(oracle_cbs, {init, register, query, respond}).
%%
-define(ORACLE_SAFE_CBS,
        #oracle_cbs{
           init = fun oracle_init_from_contract/3,
           register = fun oracle_register_from_contract/6,
           query = fun oracle_query_from_contract/6,
           respond = fun oracle_check_and_respond_from_contract/7
          }).
-define(ORACLE_UNSAFE_CBS, ?ORACLE_SAFE_CBS#oracle_cbs{query = fun oracle_unsafe_query_from_contract/6}).
-define(ORACLE_SAFE_REMOTE_CBS,
        #oracle_cbs{
           init = fun oracle_init_from_remote_contract/3,
           register = fun oracle_register_from_remote_contract/6,
           query = fun oracle_query_from_remote_contract/6,
           respond = fun oracle_check_and_respond_from_remote_contract/7
          }).
-define(ORACLE_UNSAFE_REMOTE_CBS, ?ORACLE_SAFE_REMOTE_CBS#oracle_cbs{query = fun oracle_unsafe_query_from_remote_contract/6}).

-record(gas_used, {init = 0, register = 0, query = 0, respond = 0}).
gu_register(#gas_used{register = R}) -> R.
gu_query   (#gas_used{query    = Q}) -> Q.
gu_respond (#gas_used{respond  = R}) -> R.

%%
closed_oracle_cbs(Cbs,
                  OperatorAcc, UserAcc,
                  InitialOracleCtBalance,
                  RegisterOpts, RegisterTxOpts,
                  QueryOpts   , QueryTxOpts,
                  RespondOpts , RespondTxOpts) ->
    #oracle_cbs{
       init =
           fun(S) -> (Cbs#oracle_cbs.init)(OperatorAcc, InitialOracleCtBalance, S) end,
       register =
           fun(CallingCt, OracleAcc, S) -> (Cbs#oracle_cbs.register)(OperatorAcc, CallingCt, OracleAcc, RegisterOpts, RegisterTxOpts, S) end,
       query =
           fun(CallingCt, OracleAcc, S) -> (Cbs#oracle_cbs.query)(UserAcc, CallingCt, OracleAcc, QueryOpts, QueryTxOpts, S) end,
       respond =
           case {RespondOpts, RespondTxOpts} of
               {no_response, no_response} ->
                   no_respond_cb;
               _ when is_map(RespondOpts), is_map(RespondTxOpts) ->
                   fun(CallingCt, OracleAcc, QId, S) -> (Cbs#oracle_cbs.respond)(OperatorAcc, CallingCt, OracleAcc, QId, RespondOpts, RespondTxOpts, S) end
           end
      }.
%%
sophia_oracles_qfee__init_and_register_and_query_(Init, RegisterOracle, CreateQuery) ->
    {OracleAcc, CallingCt, GasUsedInit} = call(Init, []),
    S0 = state(),

    {RegisterRes, GasUsedRegister} = call(RegisterOracle, [CallingCt, OracleAcc]),
    OracleAcc = <<(RegisterRes):256>>,
    S1 = state(),

    {R, GasUsedQuery} = call(CreateQuery, [CallingCt, OracleAcc]),
    S2 = state(),
    {R,
     {OracleAcc, CallingCt},
     [S0, S1, S2],
     #gas_used{init = GasUsedInit, register = GasUsedRegister, query = GasUsedQuery}}.
%%
sophia_oracles_qfee__init_and_register_and_query_and_respond_(Init, RegisterOracle, CreateQuery, RespondQuery) ->
    {QId,
     {OracleAcc, CallingCt},
     [S0,  %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2], %% State after query.
     GasUsed
    } = sophia_oracles_qfee__init_and_register_and_query_(Init, RegisterOracle, CreateQuery),
    {{}, GasUsedRespond} = call(RespondQuery, [CallingCt, OracleAcc, QId]),
    {{OracleAcc, CallingCt},
     [S0, S1, S2, state()], GasUsed#gas_used{respond = GasUsedRespond}}.

sophia_oracles_qfee__flow_up_to_respond_(Cbs,
                                         TxFee,
                                         GasPrice,
                                         InitialOracleCtBalance,
                                         RegisterOpts,
                                         QueryOpts, QueryTxValue,
                                         RespondOpts) ->
    RegisterTxOpts = #{fee => TxFee, gas_price => GasPrice, amount => 0},
    QueryTxOpts    = #{fee => TxFee, gas_price => GasPrice, amount => QueryTxValue},
    RespondTxOpts  = #{fee => TxFee, gas_price => GasPrice, amount => 0},

    state(aect_test_utils:new_state()),
    OperatorAcc = call(fun new_account/2, [1000000]),
    UserAcc = call(fun new_account/2, [1000000]),
    CCbs = closed_oracle_cbs(Cbs,
                             OperatorAcc, UserAcc,
                             InitialOracleCtBalance,
                             RegisterOpts, RegisterTxOpts,
                             QueryOpts   , QueryTxOpts,
                             RespondOpts , RespondTxOpts),
    {{OracleAcc, CallingCt},
     [S0,  %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2,  %% State after query.
      S3], %% State after oracle respond.
     GasUsed
    } = sophia_oracles_qfee__init_and_register_and_query_and_respond_(
          CCbs#oracle_cbs.init,
          CCbs#oracle_cbs.register,
          CCbs#oracle_cbs.query,
          CCbs#oracle_cbs.respond),
    {{OperatorAcc, UserAcc}, {OracleAcc, CallingCt}, [S0, S1, S2, S3], GasUsed}.
%%
sophia_oracles_qfee__flow_up_to_query_(Cbs,
                                       TxFee,
                                       GasPrice,
                                       InitialOracleCtBalance,
                                       RegisterOpts,
                                       QueryOpts, QueryTxValue) ->
    sophia_oracles_qfee__flow_up_to_query_(aect_test_utils:new_state(),
                                           Cbs,
                                           TxFee,
                                           GasPrice,
                                           InitialOracleCtBalance,
                                           RegisterOpts,
                                           QueryOpts, QueryTxValue).
sophia_oracles_qfee__flow_up_to_query_(InitialState,
                                       Cbs,
                                       TxFee,
                                       GasPrice,
                                       InitialOracleCtBalance,
                                       RegisterOpts,
                                       QueryOpts, QueryTxValue) ->
    RegisterTxOpts = #{fee => TxFee, gas_price => GasPrice, amount => 0},
    QueryTxOpts    = #{fee => TxFee, gas_price => GasPrice, amount => QueryTxValue},

    state(InitialState),
    OperatorAcc = call(fun new_account/2, [1000000]),
    UserAcc = call(fun new_account/2, [1000000]),
    CCbs = closed_oracle_cbs(Cbs,
                             OperatorAcc, UserAcc,
                             InitialOracleCtBalance,
                             RegisterOpts, RegisterTxOpts,
                             QueryOpts   , QueryTxOpts,
                             no_response , no_response),
    {{error, <<"out_of_gas">>},
     {OracleAcc, CallingCt},
     [S0,  %% State before oracle init.
      S1,  %% State after oracle registration.
      S2], %% State after oracle query.
     GasUsed
    } = sophia_oracles_qfee__init_and_register_and_query_(
          CCbs#oracle_cbs.init,
          CCbs#oracle_cbs.register,
          CCbs#oracle_cbs.query),
    {{OperatorAcc, UserAcc}, {OracleAcc, CallingCt}, [S0, S1, S2], GasUsed}.

%% Reference case i.e. all of the following items are equal:
%% * Query fee specified when registering oracle
%% * Query fee specified when creating query
%% * Value specified in call tx creating query
sophia_oracles_qfee__basic__data_() ->
    RegisterTxQFee = 100,
    {_InitialOracleCtBalance = 0,
     RegisterTxQFee,
     _QueryTxValue = RegisterTxQFee,
     _QueryTxQFee = RegisterTxQFee}.
%%
sophia_oracles_qfee__basic(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__basic__data_(),

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    RespondOpts = #{},
    {{OperatorAcc, UserAcc},
     {OracleAcc, OracleAcc = _CallingCt},
     [S0,  %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2,  %% State after query.
      S3], %% State after oracle respond.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_respond_(
          ?ORACLE_UNSAFE_CBS, %% Safe or unsafe query does not matter here.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue,
          RespondOpts),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(OperatorAcc, S0) - (TxFee + GasPrice * gu_register(GasUsed)),
                 Bal(OperatorAcc, S1)),
    ?assertEqual(Bal(OracleAcc, S0), Bal(OracleAcc, S1)),
    ?assertEqual(Bal(UserAcc, S0)  , Bal(UserAcc, S1)),

    ?assertEqual(Bal(OperatorAcc, S1), Bal(OperatorAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1)  , Bal(OracleAcc, S2)),
    ?assertEqual(Bal(UserAcc, S1) - (TxFee + RegisterTxQFee + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)),

    ?assertEqual(Bal(OperatorAcc, S2) - (TxFee + GasPrice * gu_respond(GasUsed)),
                 Bal(OperatorAcc, S3)),
    ?assertEqual(Bal(OracleAcc, S2) + RegisterTxQFee, Bal(OracleAcc, S3)),
    ?assertEqual(Bal(UserAcc, S2)                   , Bal(UserAcc, S3)),

    ?assertEqual([], aect_test_utils:get_oracle_queries(OracleAcc, S1)),
    ?assertMatch([_], aect_test_utils:get_oracle_queries(OracleAcc, S2)),
    ?assertMatch([_], aect_test_utils:get_oracle_queries(OracleAcc, S3)).
%%
sophia_oracles_qfee__basic__remote(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__basic__data_(),

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    RespondOpts = #{},
    {{OperatorAcc, UserAcc},
     {OracleAcc, CallingCt},
     [S0,  %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2,  %% State after query.
      S3], %% State after oracle respond.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_respond_(
          ?ORACLE_UNSAFE_REMOTE_CBS, %% Safe or unsafe query does not matter here.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue,
          RespondOpts),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(OperatorAcc, S0) - (TxFee + GasPrice * gu_register(GasUsed)),
                 Bal(OperatorAcc, S1)),
    ?assertEqual(Bal(OracleAcc, S0), Bal(OracleAcc, S1)),
    ?assertEqual(Bal(CallingCt, S0), Bal(CallingCt, S1)),
    ?assertEqual(Bal(UserAcc, S0)  , Bal(UserAcc, S1)),

    ?assertEqual(Bal(OperatorAcc, S1), Bal(OperatorAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1)  , Bal(OracleAcc, S2)),
    ?assertEqual(Bal(CallingCt, S1)  , Bal(CallingCt, S2)),
    ?assertEqual(Bal(UserAcc, S1) - (TxFee + RegisterTxQFee + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)),

    ?assertEqual(Bal(OperatorAcc, S2) - (TxFee + GasPrice * gu_respond(GasUsed)), Bal(OperatorAcc, S3)),
    ?assertEqual(Bal(OracleAcc, S2) + RegisterTxQFee, Bal(OracleAcc, S3)),
    ?assertEqual(Bal(CallingCt, S2)                 , Bal(CallingCt, S3)),
    ?assertEqual(Bal(UserAcc, S2)                   , Bal(UserAcc, S3)),

    ?assertEqual([], aect_test_utils:get_oracle_queries(OracleAcc, S1)),
    ?assertMatch([_], aect_test_utils:get_oracle_queries(OracleAcc, S2)),
    ?assertMatch([_], aect_test_utils:get_oracle_queries(OracleAcc, S3)).

%% Excessive query fee (covered by call tx value) is awarded to oracle
%% contract after respond.
sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_is_awarded_to_oracle__data_() ->
    QFeeExcess = 1,
    RegisterTxQFee = 100,
    QueryTxQFee = QFeeExcess + RegisterTxQFee,
    {_InitialOracleCtBalance = 0,
     RegisterTxQFee,
     _QueryTxValue = QueryTxQFee,
     QueryTxQFee}.
%%
sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_is_awarded_to_oracle(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_is_awarded_to_oracle__data_(),

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    RespondOpts = #{},
    {{OperatorAcc, UserAcc},
     {OracleAcc, OracleAcc = _CallingCt},
     [_S0,  %% State before oracle registration.
      S1,   %% State after oracle registration.
      S2,   %% State after query.
      S3],  %% State after oracle respond.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_respond_(
          ?ORACLE_UNSAFE_CBS, %% Safe or unsafe query does not matter here.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue,
          RespondOpts),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxQFee + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1)  , Bal(OracleAcc, S2)),
    ?assertEqual(Bal(OperatorAcc, S1), Bal(OperatorAcc, S2)),

    ?assertEqual(Bal(UserAcc, S2)                , Bal(UserAcc, S3)),
    ?assertEqual(Bal(OracleAcc, S2) + QueryTxQFee, Bal(OracleAcc, S3)),
    ?assertEqual(Bal(OperatorAcc, S2) - (TxFee + GasPrice * gu_respond(GasUsed)),
                 Bal(OperatorAcc, S3)).

%%
sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_is_awarded_to_oracle__remote(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_is_awarded_to_oracle__data_(),

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    RespondOpts = #{},
    {{OperatorAcc, UserAcc},
     {OracleAcc, CallingCt},
     [_S0,  %% State before oracle registration.
      S1,   %% State after oracle registration.
      S2,   %% State after query.
      S3],  %% State after oracle respond.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_respond_(
          ?ORACLE_UNSAFE_REMOTE_CBS, %% Safe or unsafe query does not matter here.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue,
          RespondOpts),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxQFee + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1)  , Bal(OracleAcc, S2)),
    ?assertEqual(Bal(CallingCt, S1)  , Bal(CallingCt, S2)),
    ?assertEqual(Bal(OperatorAcc, S1), Bal(OperatorAcc, S2)),

    ?assertEqual(Bal(UserAcc, S2)                , Bal(UserAcc, S3)),
    ?assertEqual(Bal(OracleAcc, S2) + QueryTxQFee, Bal(OracleAcc, S3)),
    ?assertEqual(Bal(CallingCt, S2)              , Bal(CallingCt, S3)),
    ?assertEqual(Bal(OperatorAcc, S2) - (TxFee + GasPrice * gu_respond(GasUsed)),
                 Bal(OperatorAcc, S3)).

%% Call tx value in excess of query fee specified in same query call
%% tx ends up in oracle contract (at query creation).
sophia_oracles_qfee__tx_value_above_qfee_in_query_is_awarded_to_oracle__data_() ->
    QFeeExcess = 1,
    RegisterTxQFee = 100,
    {_InitialOracleCtBalance = 0,
     RegisterTxQFee,
     _QueryTxValue = QFeeExcess + RegisterTxQFee,
     _QueryTxQFee = RegisterTxQFee}.
%%
sophia_oracles_qfee__tx_value_above_qfee_in_query_is_awarded_to_oracle(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__tx_value_above_qfee_in_query_is_awarded_to_oracle__data_(),

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    RespondOpts = #{},
    {{OperatorAcc, UserAcc},
     {OracleAcc, OracleAcc = _CallingCt},
     [_S0,  %% State before oracle registration.
      S1,   %% State after oracle registration.
      S2,   %% State after query.
      S3],  %% State after oracle respond.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_respond_(
          ?ORACLE_UNSAFE_CBS, %% Safe or unsafe query does not matter here.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue,
          RespondOpts),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1) + (QueryTxValue - QueryTxQFee), Bal(OracleAcc, S2)),
    ?assertEqual(Bal(OperatorAcc, S1)                             , Bal(OperatorAcc, S2)),

    ?assertEqual(Bal(UserAcc, S2)                , Bal(UserAcc, S3)),
    ?assertEqual(Bal(OracleAcc, S2) + QueryTxQFee, Bal(OracleAcc, S3)),
    ?assertEqual(Bal(OperatorAcc, S2) - (TxFee + GasPrice * gu_respond(GasUsed)),
                 Bal(OperatorAcc, S3)).

%%
sophia_oracles_qfee__tx_value_above_qfee_in_query_is_awarded_to_oracle__remote(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__tx_value_above_qfee_in_query_is_awarded_to_oracle__data_(),

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    RespondOpts = #{},
    {{OperatorAcc, UserAcc},
     {OracleAcc, CallingCt},
     [_S0,  %% State before oracle registration.
      S1,   %% State after oracle registration.
      S2,   %% State after query.
      S3],  %% State after oracle respond.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_respond_(
          ?ORACLE_UNSAFE_REMOTE_CBS, %% Safe or unsafe query does not matter here.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue,
          RespondOpts),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1) + (QueryTxValue - QueryTxQFee), Bal(OracleAcc, S2)),
    ?assertEqual(Bal(CallingCt, S1)                               , Bal(CallingCt, S2)),
    ?assertEqual(Bal(OperatorAcc, S1)                             , Bal(OperatorAcc, S2)),

    ?assertEqual(Bal(UserAcc, S2)                , Bal(UserAcc, S3)),
    ?assertEqual(Bal(OracleAcc, S2) + QueryTxQFee, Bal(OracleAcc, S3)),
    ?assertEqual(Bal(CallingCt, S2)              , Bal(CallingCt, S3)),
    ?assertEqual(Bal(OperatorAcc, S2) - (TxFee + GasPrice * gu_respond(GasUsed)),
                 Bal(OperatorAcc, S3)).

%% Attempt to create query with query fee smaller than the one
%% requested by the oracle fails.
%%
%% Call tx value is assigned to recipient of (i.e. first contract
%% called from) query call tx.
sophia_oracles_qfee__qfee_in_query_below_qfee_in_oracle_errs__data_() ->
    RegisterTxQFee = 100,
    QueryTxQFee = RegisterTxQFee - 1,
    {_InitialOracleCtBalance = 0,
     RegisterTxQFee,
     _QueryTxValue = QueryTxQFee,
     QueryTxQFee}.
%%
sophia_oracles_qfee__qfee_in_query_below_qfee_in_oracle_errs(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__qfee_in_query_below_qfee_in_oracle_errs__data_(),

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    {{OperatorAcc, UserAcc},
     {OracleAcc, OracleAcc = _CallingCt},
     [_S0, %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2], %% State after oracle query.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_query_(
          ?ORACLE_UNSAFE_CBS, %% Safe or unsafe query does not matter here.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1) + QueryTxValue, Bal(OracleAcc, S2)),
    ?assertEqual(Bal(OperatorAcc, S1)             , Bal(OperatorAcc, S2)).
%%
sophia_oracles_qfee__qfee_in_query_below_qfee_in_oracle_errs__remote(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__qfee_in_query_below_qfee_in_oracle_errs__data_(),

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    {{OperatorAcc, UserAcc},
     {OracleAcc, CallingCt},
     [_S0, %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2], %% State after oracle query.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_query_(
          ?ORACLE_UNSAFE_REMOTE_CBS, %% Safe or unsafe query does not matter here.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1)               , Bal(OracleAcc, S2)),
    ?assertEqual(Bal(CallingCt, S1) + QueryTxValue, Bal(CallingCt, S2)),
    ?assertEqual(Bal(OperatorAcc, S1)             , Bal(OperatorAcc, S2)).

%% Attempt to create query with call tx value smaller than query fee
%% uses oracle contract balance: oracle contract should implement
%% safety mechanism.
sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle__data_() ->
    ValueLack = 1,
    RegisterTxQFee = 100,
    {_InitialOracleCtBalance = 10 + ValueLack,
     RegisterTxQFee,
     _QueryTxValue = RegisterTxQFee - ValueLack,
     _QueryTxQFee = RegisterTxQFee}.
%%
sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle__data_(),

    TxFee = 2,
    GasPrice = 1,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    RespondOpts = #{},
    {{OperatorAcc, UserAcc},
     {OracleAcc, OracleAcc = _CallingCt},
     [_S0,  %% State before oracle registration.
      S1,   %% State after oracle registration.
      S2,   %% State after query.
      _S3], %% State after oracle respond.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_respond_(
          ?ORACLE_UNSAFE_CBS, %% Unsafe query.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue,
          RespondOpts),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(OperatorAcc, S1)                             , Bal(OperatorAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1) - (QueryTxQFee - QueryTxValue), Bal(OracleAcc, S2)),
    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)).

%%
sophia_oracles_qfee__query_tx_value_below_qfee_does_not_take_from_poor_oracle(_Cfg) ->
    {_InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle__data_(),
    InitialOracleCtBalance = 0,

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    {{OperatorAcc, UserAcc},
     {OracleAcc, OracleAcc = _CallingCt},
     [_S0, %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2], %% State after oracle query.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_query_(
          ?ORACLE_UNSAFE_CBS, %% Unsafe query.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(OperatorAcc, S1)                     , Bal(OperatorAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1) + QueryTxValue        , Bal(OracleAcc, S2)),
    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)).
%%
sophia_oracles_qfee__query_tx_value_below_qfee_does_not_take_from_rich_oracle_thanks_to_contract_check(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle__data_(),

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    {{OperatorAcc, UserAcc},
     {OracleAcc, OracleAcc = _CallingCt},
     [_S0, %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2], %% State after oracle query.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_query_(
          ?ORACLE_SAFE_CBS, %% Safe query.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(OperatorAcc, S1)                     , Bal(OperatorAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1) + QueryTxValue        , Bal(OracleAcc, S2)),
    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)).
%%
sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle__remote(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle__data_(),

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    RespondOpts = #{},
    {{OperatorAcc, UserAcc},
     {OracleAcc, CallingCt},
     [_S0,  %% State before oracle registration.
      S1,   %% State after oracle registration.
      S2,   %% State after query.
      _S3], %% State after oracle respond.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_respond_(
          ?ORACLE_UNSAFE_REMOTE_CBS, %% Unsafe query.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue,
          RespondOpts),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(OperatorAcc, S1)                             , Bal(OperatorAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1) - (QueryTxQFee - QueryTxValue), Bal(OracleAcc, S2)),
    ?assertEqual(Bal(CallingCt, S1)                               , Bal(CallingCt, S2)),
    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)).
%%
sophia_oracles_qfee__query_tx_value_below_qfee_does_not_take_from_poor_oracle__remote(_Cfg) ->
    {_InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle__data_(),
    InitialOracleCtBalance = 0,

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    {{OperatorAcc, UserAcc},
     {OracleAcc, CallingCt},
     [_S0, %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2], %% State after oracle query.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_query_(
          ?ORACLE_UNSAFE_REMOTE_CBS, %% Unsafe query.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(OperatorAcc, S1)             , Bal(OperatorAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1)               , Bal(OracleAcc, S2)),
    ?assertEqual(Bal(CallingCt, S1) + QueryTxValue, Bal(CallingCt, S2)),
    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)).
%%
sophia_oracles_qfee__query_tx_value_below_qfee_does_not_take_from_rich_oracle_thanks_to_contract_check__remote(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle__data_(),

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    {{OperatorAcc, UserAcc},
     {OracleAcc, CallingCt},
     [_S0, %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2], %% State after oracle query.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_query_(
          ?ORACLE_SAFE_REMOTE_CBS, %% Safe query.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(OperatorAcc, S1)             , Bal(OperatorAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1)               , Bal(OracleAcc, S2)),
    ?assertEqual(Bal(CallingCt, S1) + QueryTxValue, Bal(CallingCt, S2)),
    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)).
%%
sophia_oracles_qfee__remote_contract_query_value_below_qfee_takes_from_rich_oracle__remote(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue0, QueryTxQFee} =
        sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle__data_(),
    QueryTxValue = RegisterTxQFee,
    QueryRemoteCtValue = QueryTxValue0,

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee, remote_value => QueryRemoteCtValue},
    RespondOpts = #{},
    {{OperatorAcc, UserAcc},
     {OracleAcc, CallingCt},
     [_S0,  %% State before oracle registration.
      S1,   %% State after oracle registration.
      S2,   %% State after query.
      _S3], %% State after oracle respond.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_respond_(
          ?ORACLE_UNSAFE_REMOTE_CBS, %% Unsafe query.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue,
          RespondOpts),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(OperatorAcc, S1)                                    , Bal(OperatorAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1) - (QueryTxValue - QueryRemoteCtValue), Bal(OracleAcc, S2)),
    ?assertEqual(Bal(CallingCt, S1) + (QueryTxValue - QueryRemoteCtValue), Bal(CallingCt, S2)),
    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)).
%%
sophia_oracles_qfee__remote_contract_query_value_below_qfee_does_not_take_from_poor_oracle__remote(_Cfg) ->
    {_InitialOracleCtBalance, RegisterTxQFee, QueryTxValue0, QueryTxQFee} =
        sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle__data_(),
    InitialOracleCtBalance = 0,
    QueryTxValue = RegisterTxQFee,
    QueryRemoteCtValue = QueryTxValue0,

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee, remote_value => QueryRemoteCtValue},
    {{OperatorAcc, UserAcc},
     {OracleAcc, CallingCt},
     [_S0, %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2], %% State after oracle query.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_query_(
          ?ORACLE_UNSAFE_REMOTE_CBS, %% Unsafe query.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(OperatorAcc, S1)             , Bal(OperatorAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1)               , Bal(OracleAcc, S2)),
    ?assertEqual(Bal(CallingCt, S1) + QueryTxValue, Bal(CallingCt, S2)),
    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)).
%%
sophia_oracles_qfee__remote_contract_query_value_below_qfee_does_not_take_from_rich_oracle_thanks_to_contract_check__remote(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue0, QueryTxQFee} =
        sophia_oracles_qfee__query_tx_value_below_qfee_takes_from_rich_oracle__data_(),
    QueryTxValue = RegisterTxQFee,
    QueryRemoteCtValue = QueryTxValue0,

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee, remote_value => QueryRemoteCtValue},
    {{OperatorAcc, UserAcc},
     {OracleAcc, CallingCt},
     [_S0, %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2], %% State after oracle query.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_query_(
          ?ORACLE_SAFE_REMOTE_CBS, %% Safe query.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(OperatorAcc, S1)             , Bal(OperatorAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1)               , Bal(OracleAcc, S2)),
    ?assertEqual(Bal(CallingCt, S1) + QueryTxValue, Bal(CallingCt, S2)),
    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)).

%% Attempt to create query with query fee larger than the one
%% requested by the oracle but not covered by call tx value uses
%% oracle contract balance: oracle contract should implement safety
%% mechanism.
sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_takes_from_rich_oracle__data_() ->
    QFeeExcess = 1,
    RegisterTxQFee = 100,
    {_InitialOracleCtBalance = 10 + QFeeExcess,
     RegisterTxQFee,
     _QueryTxValue = RegisterTxQFee,
     _QueryTxQFee = QFeeExcess + RegisterTxQFee}.

%%
sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_takes_from_rich_oracle(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_takes_from_rich_oracle__data_(),

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    RespondOpts = #{},
    {{OperatorAcc, UserAcc},
     {OracleAcc, OracleAcc = _CallingCt},
     [_S0,  %% State before oracle registration.
      S1,   %% State after oracle registration.
      S2,   %% State after query.
      _S3], %% State after oracle respond.
      GasUsed
    } = sophia_oracles_qfee__flow_up_to_respond_(
          ?ORACLE_UNSAFE_CBS, %% Unsafe query.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue,
          RespondOpts),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(OperatorAcc, S1)                               , Bal(OperatorAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1) - (QueryTxQFee - RegisterTxQFee), Bal(OracleAcc, S2)),
    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)).
%%
sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_does_not_take_from_poor_oracle(_Cfg) ->
    {_InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_takes_from_rich_oracle__data_(),
    InitialOracleCtBalance = 0,

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    {{OperatorAcc, UserAcc},
     {OracleAcc, OracleAcc = _CallingCt},
     [_S0, %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2], %% State after oracle query.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_query_(
          ?ORACLE_UNSAFE_CBS, %% Unsafe query.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(OperatorAcc, S1)                     , Bal(OperatorAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1) + QueryTxValue        , Bal(OracleAcc, S2)),
    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)).
%%
sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_does_not_take_from_rich_oracle_thanks_to_contract_check(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__qfee_in_query_above_qfee_in_oracle_takes_from_rich_oracle__data_(),

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    {{OperatorAcc, UserAcc},
     {OracleAcc, OracleAcc = _CallingCt},
     [_S0, %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2], %% State after oracle query.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_query_(
          ?ORACLE_SAFE_CBS, %% Safe query.
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(OperatorAcc, S1)             , Bal(OperatorAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1) + QueryTxValue, Bal(OracleAcc, S2)),
    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)).

%% Failure after query creation primop succeeds.
sophia_oracles_qfee__error_after_primop(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__basic__data_(),

    Cbs =
        ?ORACLE_UNSAFE_CBS#oracle_cbs{
           query =
               fun(UserAcc, OCt, OCt, Opts, TxOpts, S) ->
                       oracle_query_from_contract_(unsafeCreateQueryThenErr, UserAcc, OCt, OCt, Opts, TxOpts, S)
               end},

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    {{OperatorAcc, UserAcc},
     {OracleAcc, OracleAcc = _CallingCt},
     [_S0, %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2], %% State after oracle query.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_query_(
          Cbs,
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue),

    ?assertEqual([], aect_test_utils:get_oracle_queries(OracleAcc, S1)),
    ?assertEqual([], aect_test_utils:get_oracle_queries(OracleAcc, S2)),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1) + QueryTxValue, Bal(OracleAcc, S2)),
    ?assertEqual(Bal(OperatorAcc, S1)             , Bal(OperatorAcc, S2)).
%%
sophia_oracles_qfee__inner_error_after_primop__remote(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__basic__data_(),

    InitialState0 = aect_test_utils:new_state(),
    {TmpAcc, InitialState1} = new_account(1000000, InitialState0),
    {OracleErrCt, InitialState} = create_contract(TmpAcc, oracles_err, {}, #{amount => 0}, InitialState1),

    Cbs =
        ?ORACLE_UNSAFE_REMOTE_CBS#oracle_cbs{
           query =
               fun(UserAcc, RCt, OCt, Opts, TxOpts, S) ->
                       oracle_query_from_remote_contract_(callUnsafeCreateQueryThenErr, UserAcc, RCt, OracleErrCt, OCt, Opts, TxOpts, S)
               end},

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    {{OperatorAcc, UserAcc},
     {OracleAcc, CallingCt},
     [_S0, %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2], %% State after oracle query.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_query_(
          InitialState,
          Cbs,
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue),

    ?assertEqual([], aect_test_utils:get_oracle_queries(OracleAcc, S1)),
    ?assertEqual([], aect_test_utils:get_oracle_queries(OracleAcc, S2)),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1)               , Bal(OracleAcc, S2)),
    ?assertEqual(Bal(CallingCt, S1) + QueryTxValue, Bal(CallingCt, S2)),
    ?assertEqual(Bal(OperatorAcc, S1)             , Bal(OperatorAcc, S2)),
    ?assertEqual(Bal(TmpAcc, S1)                  , Bal(TmpAcc, S2)).
%%
sophia_oracles_qfee__outer_error_after_primop__remote(_Cfg) ->
    {InitialOracleCtBalance, RegisterTxQFee, QueryTxValue, QueryTxQFee} =
        sophia_oracles_qfee__basic__data_(),

    Cbs =
        ?ORACLE_UNSAFE_REMOTE_CBS#oracle_cbs{
           query =
               fun(UserAcc, RCt, OCt, Opts, TxOpts, S) ->
                       oracle_query_from_remote_contract_(callUnsafeCreateQueryAndThenErr, UserAcc, RCt, OCt, Opts, TxOpts, S)
               end},

    TxFee = 2,
    GasPrice = 2,
    RegisterOpts = #{qfee => RegisterTxQFee},
    QueryOpts = #{qfee => QueryTxQFee},
    {{OperatorAcc, UserAcc},
     {OracleAcc, CallingCt},
     [_S0, %% State before oracle registration.
      S1,  %% State after oracle registration.
      S2], %% State after oracle query.
     GasUsed
    } = sophia_oracles_qfee__flow_up_to_query_(
          Cbs,
          TxFee, GasPrice, InitialOracleCtBalance, RegisterOpts, QueryOpts, QueryTxValue),

    ?assertEqual([], aect_test_utils:get_oracle_queries(OracleAcc, S1)),
    ?assertEqual([], aect_test_utils:get_oracle_queries(OracleAcc, S2)),

    Bal = fun(A, S) -> {B, S} = account_balance(A, S), B end,

    ?assertEqual(Bal(UserAcc, S1) - (TxFee + QueryTxValue + GasPrice * gu_query(GasUsed)),
                 Bal(UserAcc, S2)),
    ?assertEqual(Bal(OracleAcc, S1)               , Bal(OracleAcc, S2)),
    ?assertEqual(Bal(CallingCt, S1) + QueryTxValue, Bal(CallingCt, S2)),
    ?assertEqual(Bal(OperatorAcc, S1)             , Bal(OperatorAcc, S2)).

%% Oracle gas TTL tests

-record(oracles_gas_ttl_scenario,
        {register_ttl :: ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(non_neg_integer())
                       | ?CHAIN_ABSOLUTE_TTL_MEMORY_ENCODING(non_neg_integer()),
         extend_ttl   :: ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(non_neg_integer()),
         query_ttl    :: ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(non_neg_integer())
                       | ?CHAIN_ABSOLUTE_TTL_MEMORY_ENCODING(non_neg_integer()),
         respond_ttl  :: ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(non_neg_integer())}).
sophia_oracles_gas_ttl__measure_gas_used(Sc, Height, Gas) ->
    state(aect_test_utils:new_state()),
    Caller = call(fun new_account/2, [100000000000]),
    Ct = call(fun create_contract/4, [Caller, oracles_gas, {}]),
    QFee=1,
    Args = {QFee,
            Sc#oracles_gas_ttl_scenario.register_ttl,
            Sc#oracles_gas_ttl_scenario.extend_ttl,
            Sc#oracles_gas_ttl_scenario.query_ttl,
            Sc#oracles_gas_ttl_scenario.respond_ttl,
            _Signature=0},
    Opts = #{height => Height,
             return_gas_used => true,
             gas_price => 1,
             gas => Gas,
             amount => QFee},
    {_Result, _GasUsed} = call(fun call_contract/7, [Caller, Ct, happyPathWithAllBuiltinsAtSameHeight, {tuple, []}, Args, Opts]).

%% Test that gas charged by oracle primop depends on TTL of state object.
%% Test approach: run primop with low and high TTLs, then compare consumed gas. This proves that TTL-related gas computation kicks in without relying on absolute minimum value of gas used.
sophia_oracles_gas_ttl__oracle_registration(_Cfg) ->
    {Part, Whole} = aec_governance:state_gas_cost_per_block(oracle_registration),
    ?assertMatch(X when X > 0, Whole), %% Hardcoded expectation on governance - for test readability.
    ?assertMatch(X when X > 0, Part), %% Hardcoded expectation on governance - for test readability.
    MM = fun(H, Ttl, Gas) ->
                sophia_oracles_gas_ttl__measure_gas_used(
                  #oracles_gas_ttl_scenario{
                     register_ttl = Ttl,
                     extend_ttl   = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(1),
                     query_ttl    = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(1),
                     respond_ttl  = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(1)},
                  H, Gas)
        end,
    M = fun(H, Ttl) -> MM(H, Ttl, 1234567890) end,
    Rel = fun(H, Ttl) -> M(H, ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(Ttl)) end,
    H = 1,
    %% Smoke test.
    ?assertMatch({{}, _}, Rel(H, 1)),
    G = fun({{}=_Result, GasUsed}) -> GasUsed end,
    %% TTL increases gas used.
    ?assertEqual(Part + G(Rel(H, 1        )), G(Rel(H, 1 +   Whole))),
    ?assertEqual(Part + G(Rel(H, 1 + Whole)), G(Rel(H, 1 + 2*Whole))),
    %% Gas used for absolute TTL is same(ish) as relative.
    Abs = fun(He, Ttl) -> M(He, ?CHAIN_ABSOLUTE_TTL_MEMORY_ENCODING(Ttl)) end,
    RelGas = G(Rel(H, 1 + Whole)),
    AbsGas = G(Abs(H, H + 1 + Whole)),
    ?assert(RelGas < AbsGas + 10),
    ?assert(AbsGas < RelGas + 10),
    %% Enough gas for base cost though not enough for all TTL causes out-of-gas.
    ?assertMatch(
       {{error, <<"out_of_gas">>}, _},
       MM(H,
          ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(1 + Whole),
          G(Rel(H, 1))
         )
      ),
    ok.

sophia_oracles_gas_ttl__oracle_extension(_Cfg) ->
    {Part, Whole} = aec_governance:state_gas_cost_per_block(oracle_extension),
    ?assertMatch(X when X > 0, Whole), %% Hardcoded expectation on governance - for test readability.
    ?assertMatch(X when X > 0, Part), %% Hardcoded expectation on governance - for test readability.
    MM = fun(H, Ttl, Gas) ->
                 sophia_oracles_gas_ttl__measure_gas_used(
                   #oracles_gas_ttl_scenario{
                      register_ttl = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(1),
                      extend_ttl   = Ttl,
                      query_ttl    = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(1),
                      respond_ttl  = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(1)},
                   H, Gas)
         end,
    M = fun(H, Ttl) -> MM(H, Ttl, 1234567890) end,
    Rel = fun(H, Ttl) -> M(H, ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(Ttl)) end,
    H = 1,
    %% Smoke test.
    ?assertMatch({{}, _}, Rel(H, 1)),
    G = fun({{}=_Result, GasUsed}) -> GasUsed end,
    %% TTL increases gas used.
    ?assertEqual(Part + G(Rel(H, 1        )), G(Rel(H, 1 +   Whole))),
    ?assertEqual(Part + G(Rel(H, 1 + Whole)), G(Rel(H, 1 + 2*Whole))),
    %% Enough gas for base cost though not enough for all TTL causes out-of-gas.
    ?assertMatch(
       {{error, <<"out_of_gas">>}, _},
       MM(H,
          ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(1 + Whole),
          G(Rel(H, 1))
         )
      ),
    ok.

sophia_oracles_gas_ttl__query(_Cfg) ->
    {Part, Whole} = aec_governance:state_gas_cost_per_block(oracle_query),
    ?assertMatch(X when X > 0, Whole), %% Hardcoded expectation on governance - for test readability.
    ?assertMatch(X when X > 0, Part), %% Hardcoded expectation on governance - for test readability.
    MM = fun(H, Ttl, Gas) ->
                 sophia_oracles_gas_ttl__measure_gas_used(
                   #oracles_gas_ttl_scenario{
                      register_ttl = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(10 + 10 * Whole), %% Fixed, though enough room for playing with query/response TTL.
                      extend_ttl   = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(1),
                      query_ttl    = Ttl,
                      respond_ttl  = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(1)},
                   H, Gas)
         end,
    M = fun(H, Ttl) -> MM(H, Ttl, 1234567890) end,
    Rel = fun(H, Ttl) -> M(H, ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(Ttl)) end,
    H = 1,
    %% Smoke test.
    ?assertMatch({{}, _}, Rel(H, 1)),
    G = fun({{}=_Result, GasUsed}) -> GasUsed end,
    %% TTL increases gas used.
    ?assertEqual(Part + G(Rel(H, 1        )), G(Rel(H, 1 +   Whole))),
    ?assertEqual(Part + G(Rel(H, 1 + Whole)), G(Rel(H, 1 + 2*Whole))),
    %% Gas used for absolute TTL is same(ish) as relative.
    Abs = fun(He, Ttl) -> M(He, ?CHAIN_ABSOLUTE_TTL_MEMORY_ENCODING(Ttl)) end,
    RelGas = G(Rel(H, 1 + Whole)),
    AbsGas = G(Abs(H, H + 1 + Whole)),
    ?assert(RelGas < AbsGas + 10),
    ?assert(AbsGas < RelGas + 10),
    %% Enough gas for base cost though not enough for all TTL causes out-of-gas.
    ?assertMatch(
       {{error, <<"out_of_gas">>}, _},
       MM(H,
          ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(1 + Whole),
          G(Rel(H, 1))
         )
      ),
    ok.

sophia_oracles_gas_ttl__response(_Cfg) ->
    {Part, Whole} = aec_governance:state_gas_cost_per_block(oracle_response),
    ?assertMatch(X when X > 0, Whole), %% Hardcoded expectation on governance - for test readability.
    ?assertMatch(X when X > 0, Part), %% Hardcoded expectation on governance - for test readability.
    MM = fun(H, Ttl, Gas) ->
                 sophia_oracles_gas_ttl__measure_gas_used(
                   #oracles_gas_ttl_scenario{
                      register_ttl = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(10 + 10 * Whole), %% Fixed, though enough room for playing with query/response TTL.
                      extend_ttl   = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(1),
                      query_ttl    = ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(1),
                      respond_ttl  = Ttl},
                   H, Gas)
         end,
    M = fun(H, Ttl) -> MM(H, Ttl, 1234567890) end,
    Rel = fun(H, Ttl) -> M(H, ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(Ttl)) end,
    H = 1,
    %% Smoke test.
    ?assertMatch({{}, _}, Rel(H, 1)),
    G = fun({{}=_Result, GasUsed}) -> GasUsed end,
    %% TTL increases gas used.
    ?assertEqual(Part + G(Rel(H, 1        )), G(Rel(H, 1 +   Whole))),
    ?assertEqual(Part + G(Rel(H, 1 + Whole)), G(Rel(H, 1 + 2*Whole))),
    %% Enough gas for base cost though not enough for all TTL causes out-of-gas.
    ?assertMatch(
       {{error, <<"out_of_gas">>}, _},
       MM(H,
          ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(1 + Whole),
          G(Rel(H, 1))
         )
      ),
    ok.

%% -- End oracle gas TTL tests --

%% Testing external oracles, with provided Signatures
sophia_signatures_oracles(_Cfg) ->
    state(aect_test_utils:new_state()),
    RelativeTTL         = fun(Delta)  -> ?CHAIN_RELATIVE_TTL_MEMORY_ENCODING(Delta) end,
    FixedTTL            = fun(Height) -> ?CHAIN_ABSOLUTE_TTL_MEMORY_ENCODING(Height) end,
    Acc                 = ?call(new_account, 1000000000),
    Orc                 = ?call(new_account, 1000000000),
    Ct                  = ?call(create_contract, Acc, oracles, {}),
    QueryFee            = 13,
    TTL                 = 50,
    <<OrcId:256>>       = Orc,

    BadSig              = sign(<<Ct/binary, Orc/binary>>, Orc),
    {error, <<"out_of_gas">>} = ?call(call_contract, Acc, Ct, registerOracle, word,
                                      {Orc, BadSig, QueryFee, FixedTTL(TTL)}, #{amount => 1}),

    RegSig              = sign(<<Orc/binary, Ct/binary>>, Orc),
    OrcId               = ?call(call_contract, Acc, Ct, registerOracle, word, {Orc, RegSig, QueryFee, FixedTTL(TTL)},
                                #{amount => 1}),

    Question          = <<"Manchester United vs Brommapojkarna">>,
    QId               = ?call(call_contract, Acc, Ct, createQuery, word,
                                {Orc, Question, QueryFee, RelativeTTL(5), RelativeTTL(5)}, #{amount => QueryFee}),
    Question          = ?call(call_contract, Acc, Ct, getQuestion, string, {Orc, QId}),
    QueryFee          = ?call(call_contract, Acc, Ct, queryFee, word, Orc),
    none              = ?call(call_contract, Acc, Ct, getAnswer, {option, word}, {Orc, QId}),

    RespSign                  = sign(<<QId:256, Ct/binary>>, Orc),
    {error, <<"out_of_gas">>} = ?call(call_contract, Acc, Ct, respond, {tuple, []}, {Orc, QId, BadSig, 4001}),
    {}                        = ?call(call_contract, Acc, Ct, respond, {tuple, []}, {Orc, QId, RespSign, 4001}),
    {some, 4001}              = ?call(call_contract, Acc, Ct, getAnswer, {option, word}, {Orc, QId}),
    {}                        = ?call(call_contract, Acc, Ct, extendOracle, {tuple, []}, {Orc, RegSig, RelativeTTL(10)}),

    ok.

sophia_signatures_aens(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc      = ?call(new_account, 1000000),
    Ct       = ?call(create_contract, Acc, aens, {}, #{ amount => 100000 }),
    Name     = <<"foo.test">>,
    APubkey  = 1,
    OPubkey  = <<2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2>>,
    %% TODO: Improve checks in aens_unpdate_tx
    Pointers = [aens_pointer:new(<<"account_pubkey">>, aec_id:create(account, <<APubkey:256>>)),
                aens_pointer:new(<<"oracle_pubkey">>, aec_id:create(oracle, OPubkey))],

    Salt  = ?call(aens_preclaim, Acc, Name),
    Hash  = ?call(aens_claim, Acc, Name, Salt),
    ok    = ?call(aens_update, Acc, Hash, Pointers),

    {some, APubkey} = ?call(call_contract, Acc, Ct, resolve_word,   {option, word},   {Name, <<"account_pubkey">>}),
    {some, OPubkey} = ?call(call_contract, Acc, Ct, resolve_string, {option, string}, {Name, <<"oracle_pubkey">>}),
    none            = ?call(call_contract, Acc, Ct, resolve_string, {option, string}, {Name, <<"name">>}),
    ok              = ?call(aens_revoke, Acc, Hash),
    none            = ?call(call_contract, Acc, Ct, resolve_string, {option, string}, {Name, <<"name">>}),

    %% AENS transactions from contract - using 3rd party account
    NameAcc         = ?call(new_account, 10000000),
    Name1           = <<"bla.test">>,
    Salt1           = rand:uniform(10000),
    {ok, NameAscii} = aens_utils:to_ascii(Name1),
    CHash           = aens_hash:commitment_hash(NameAscii, Salt1),
    NHash           = aens_hash:name_hash(NameAscii),
    NameAccSig      = sign(<<NameAcc/binary, Ct/binary>>, NameAcc),
    {ok, NameHash} = aens:get_name_hash(<<"bla.test">>),
    NameSig         = sign(<<NameAcc/binary, NameHash/binary, Ct/binary>>, NameAcc),
    AccSig          = sign(<<Acc/binary, NameHash/binary, Ct/binary>>, Acc),

    {error, <<"out_of_gas">>} = ?call(call_contract, Acc, Ct, preclaim, {tuple, []}, {NameAcc, CHash, AccSig}, #{ height => 10 }),
    {} = ?call(call_contract, Acc, Ct, preclaim, {tuple, []}, {NameAcc, CHash, NameAccSig},        #{ height => 10 }),
    {error, <<"out_of_gas">>} = ?call(call_contract, Acc, Ct, claim,    {tuple, []}, {NameAcc, Name1, Salt1, AccSig}, #{ height => 11 }),
    {} = ?call(call_contract, Acc, Ct, claim,    {tuple, []}, {NameAcc, Name1, Salt1, NameSig}, #{ height => 11 }),
    {error, <<"out_of_gas">>} = ?call(call_contract, Acc, Ct, transfer, {tuple, []}, {NameAcc, Acc, NHash, AccSig},   #{ height => 12 }),
    {} = ?call(call_contract, Acc, Ct, transfer, {tuple, []}, {NameAcc, Acc, NHash, NameSig},   #{ height => 12 }),
    ok = ?call(aens_update, Acc, NHash, Pointers),

    {some, OPubkey} = ?call(call_contract, Acc, Ct, resolve_string, {option, string}, {Name1, <<"oracle_pubkey">>}),

    {error, <<"out_of_gas">>} = ?call(call_contract, Acc, Ct, revoke, {tuple, []}, {NameAcc, NHash, NameSig}, #{ height => 13 }),
    {} = ?call(call_contract, Acc, Ct, revoke, {tuple, []}, {Acc, NHash, AccSig}, #{ height => 13 }),
    ok.

sign(Material, KeyHolder) ->
    PrivKey  = aect_test_utils:priv_key(KeyHolder, state()),
    <<Word1:256, Word2:256>> = enacl:sign_detached(Material, PrivKey),
    {Word1, Word2}.

%% Testing map functions and primitives
sophia_maps(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc = ?call(new_account, 1000000000),
    Ct  = ?call(create_contract, Acc, maps, {}),

    Call = fun(Fn, Type, Args) -> ?call(call_contract, Acc, Ct, Fn, Type, Args) end,

    Pt     = {tuple, [word, word]},
    IntMap = {map, word,   Pt},
    StrMap = {map, string, Pt},
    IntList = {list, {tuple, [word,   Pt]}},
    StrList = {list, {tuple, [string, Pt]}},
    Unit   = {tuple, []},
    State  = {tuple, [IntMap, StrMap]},

    MapI     = #{1 => {1, 2}, 2 => {3, 4}, 3 => {5, 6}},
    MapS     = #{<<"one">> => {1, 2}, <<"two">> => {3, 4}, <<"three">> => {5, 6}},
    EmptyMap = #{},

    MapI = Call(map_i, IntMap, {}),
    MapS = Call(map_s, StrMap, {}),

    {} = Call(map_state_i, Unit, {}),
    {} = Call(map_state_s, Unit, {}),

    {MapI, MapS} = Call(get_state, State, {}),

    MkOption = fun(undefined) -> none; (X) -> {some, X} end,

    OogErr = {error, <<"out_of_gas">>},
    Calls = lists:append(
        %% get
        [ [{Fn,  Pt, {K, Map}, maps:get(K, Map, OogErr)},
           {FnS, Pt, K,        maps:get(K, Map, OogErr)}]
         || {Fn, FnS, Map, Err} <- [{get_i, get_state_i, MapI, 4},
                                    {get_s, get_state_s, MapS, <<"four">>}],
            K <- maps:keys(Map) ++ [Err] ] ++
        %% lookup
        [ [{Fn,  {option, Pt}, {K, Map}, MkOption(maps:get(K, Map, undefined))},
           {FnS, {option, Pt}, K,        MkOption(maps:get(K, Map, undefined))}]
         || {Fn, FnS, Map, Err} <- [{lookup_i, lookup_state_i, MapI, 4},
                                    {lookup_s, lookup_state_s, MapS, <<"four">>}],
            K <- maps:keys(Map) ++ [Err] ] ++
        %% member
        [ [{Fn,  bool, {K, Map}, maps:is_key(K, Map)},
           {FnS, bool, K,        maps:is_key(K, Map)}]
         || {Fn, FnS, Map, Err} <- [{member_i, member_state_i, MapI, 4},
                                    {member_s, member_state_s, MapS, <<"four">>}],
            K <- maps:keys(Map) ++ [Err] ] ++
        %% size
        [ [{Fn,  word, Map, maps:size(Map)},
           {FnS, word, {},  maps:size(Map)}]
         || {Fn, FnS, Map} <- [{size_i, size_state_i, MapI},
                               {size_s, size_state_s, MapS}] ] ++
        %% set (not set_state)
        [ [{Fn, Type, {K, V, Map}, Map#{K => V}}]
         || {Fn, Type, Map, New, V} <- [{set_i, IntMap, MapI, 4, {7, 8}},
                                        {set_s, StrMap, MapS, <<"four">>, {7, 8}}],
            K <- maps:keys(Map) ++ [New] ] ++
        %% setx (not setx_state)
        [ [{Fn, Type, {K, V, Map}, case Map of #{K := {_, Y}} -> Map#{K => {V, Y}}; _ -> OogErr end}]
         || {Fn, Type, Map, New, V} <- [{setx_i, IntMap, MapI, 4, 7},
                                        {setx_s, StrMap, MapS, <<"four">>, 7}],
            K <- maps:keys(Map) ++ [New] ] ++
        %% addx (not addx_state)
        [ [{Fn, Type, {K, V, Map}, case Map of #{K := {X, Y}} -> Map#{K => {X + V, Y}}; _ -> OogErr end}]
         || {Fn, Type, Map, New, V} <- [{addx_i, IntMap, MapI, 4, 7},
                                        {addx_s, StrMap, MapS, <<"four">>, 7}],
            K <- maps:keys(Map) ++ [New] ] ++
        %% delete (not delete_state)
        [ [{Fn, Type, {K, Map}, maps:remove(K, Map)}]
         || {Fn, Type, Map, New} <- [{delete_i, IntMap, MapI, 4},
                                     {delete_s, StrMap, MapS, <<"four">>}],
            K <- maps:keys(Map) ++ [New] ] ++
        %% fromlist (not fromlist_state)
        [ [{Fn, Type, maps:to_list(Map), Map}]
         || {Fn, Type, Map} <- [{fromlist_i, IntMap, MapI},
                                {fromlist_s, StrMap, MapS}] ] ++
        []),

    _ = [ begin
            io:format("Applying ~p.\nArgs = ~p\nType = ~p\nExpected = ~p\n", [Fn, Args, Type, Result]),
            Result = Call(Fn, Type, Args)
          end || {Fn, Type, Args, Result} <- Calls ],

    %% to_list (not tolist_state)
    _ = [ {Xs, Xs} = {lists:keysort(1, Call(Fn, Type, Map)), maps:to_list(Map)}
            || {Fn, Type, Map} <- [{tolist_i, IntList, MapI},
                                   {tolist_s, StrList, MapS}] ],

    %% Reset the state
    Call(fromlist_state_i, Unit, []),
    Call(fromlist_state_s, Unit, []),
    {EmptyMap, EmptyMap} = Call(get_state, State, {}),

    %% fromlist_state
    Call(fromlist_state_i, Unit, maps:to_list(MapI)),
    Call(fromlist_state_s, Unit, maps:to_list(MapS)),
    {MapI, MapS} = Call(get_state, State, {}),

    %% tolist_state
    _ = [ {Xs, Xs} = {lists:keysort(1, Call(Fn, Type, {})), maps:to_list(Map)}
            || {Fn, Type, Map} <- [{tolist_state_i, IntList, MapI},
                                   {tolist_state_s, StrList, MapS}] ],

    %% set_state
    DeltaI1 = #{ 3 => {100, 200}, 4 => {300, 400} },
    DeltaS1 = #{ <<"three">> => {100, 200}, <<"four">> => {300, 400} },
    MapI1 = maps:merge(MapI, DeltaI1),
    MapS1 = maps:merge(MapS, DeltaS1),
    _ = [ {} = Call(Fn, Unit, {K, V})
            || {Fn, Delta} <- [{set_state_i, DeltaI1}, {set_state_s, DeltaS1}],
               {K, V} <- maps:to_list(Delta) ],
    {MapI1, MapS1} = Call(get_state, State, {}),

    %% setx_state/addx_state
    DeltaI2 = [{set, 4, 50}, {set, 5, 300}, {add, 2, 10}, {add, 5, 10}],
    DeltaS2 = [{set, <<"four">>, 50}, {set, <<"five">>, 300}, {add, <<"one">>, 100}, {add, <<"...">>, 1}],
    Upd = fun({Op, K, V}, M) ->
            case maps:get(K, M, undefined) of
                undefined -> M;
                {X, Y}    -> M#{K := {case Op of set -> V; add -> X + V end, Y}} end end,
    MapI2 = lists:foldr(Upd, MapI1, DeltaI2),
    MapS2 = lists:foldr(Upd, MapS1, DeltaS2),
    _ = [ begin
            T   = if is_integer(K) -> i; true -> s end,
            Fn  = list_to_atom(lists:concat([Op, "x_state_", T])),
            Res = case maps:is_key(K, Map) of true -> {}; false -> OogErr end,
            Res = Call(Fn, Unit, {K, V})
          end || {Map, Delta} <- [{MapI1, DeltaI2}, {MapS1, DeltaS2}],
               {Op, K, V} <- Delta ],
    {MapI2, MapS2} = Call(get_state, State, {}),

    %% delete_state
    DeltaI3 = [2, 5],
    DeltaS3 = [<<"four">>, <<"five">>],
    MapI3 = lists:foldr(fun maps:remove/2, MapI2, DeltaI3),
    MapS3 = lists:foldr(fun maps:remove/2, MapS2, DeltaS3),
    _ = [ {} = Call(Fn, Unit, K)
            || {Fn, Ks} <- [{delete_state_i, DeltaI3}, {delete_state_s, DeltaS3}],
               K <- Ks ],
    {MapI3, MapS3} = Call(get_state, State, {}),
    ok.

sophia_map_benchmark(Cfg) ->
    state(aect_test_utils:new_state()),
    Acc  = ?call(new_account, 100000000),
    N    = proplists:get_value(n, Cfg, 10),
    Map  = maps:from_list([{I, list_to_binary(integer_to_list(I))} || I <- lists:seq(1, N) ]),
    Code = aect_test_utils:compile_contract("contracts/maps_benchmark.aes"),
    Opts = #{ gas => 1000000, return_gas_used => true },
    {Ct, InitGas}   = ?call(create_contract, Acc, maps_benchmark, {777, Map}, Opts),
    {{}, SimpleGas} = ?call(call_contract, Acc, Ct, set_updater, {tuple, []}, Ct, Opts),
    Map1 = Map#{ 5 => <<"five">> },
    {Map1, Gas} = ?call(call_contract, Acc, Ct, benchmark, {map, word, string}, {5, <<"five">>}, Opts),
    io:format("Bytecode size: ~p\nInit   gas used: ~p\nSimple gas used: ~p\nBench  gas used: ~p\n", [byte_size(Code), InitGas, SimpleGas, Gas]),

    %% Before any optimisations:
    %%
    %%  Code size: 1,746 bytes
    %%
    %%  Gas:
    %%    N    init  set_updater  benchmark
    %%    0     599          976      5,253
    %%   10   6,283        9,758     42,102
    %%   20  12,024       18,626     80,524
    %%   40  32,673       36,619    165,544
    %%   80  47,648       73,638    343,217
    %%  160  98,296      151,799    736,808
    %%
    %%  Memory (words) - recorded by instrumenting the VM
    %%    N    init  set_updater  benchmark (remote)
    %%    0      13           18         61     (30)
    %%   10     133          178        419    (320)
    %%   20     253          338        799    (600)
    %%   40     493          658      1,559  (1,240)
    %%   80     973        1,298      3,079  (2,480)
    %%  160   1,933        2,578      6,119  (4,920)

    %% Read return values off the heap (with encoded typereps on the heap)
    %%
    %%  Code size: 1,859 bytes
    %%
    %%  Gas:
    %%    N    init  set_updater  benchmark
    %%    0     726          982      4,456
    %%   10   1,100        9,656     31,330
    %%   20   1,488       18,416     58,424
    %%   40   2,306       36,193    119,874
    %%   80   4,111       72,779    246,881
    %%  160   8,395      150,075    525,113
    %%         -91%          -1%       -29%
    %%
    %%  Memory (words)
    %%    N    init  set_updater  benchmark (remote)
    %%    0      29           21         66     (35)
    %%   10      89          181        370    (271)
    %%   20     149          341        690    (491)
    %%   40     269          661      1,330  (1,011)
    %%   80     509        1,301      2,610  (2,011)
    %%  160     989        2,581      5,170  (3,971)

    %% Read updated states from the heap (with encoded typereps on the heap)
    %%
    %%  Code size: 1,907 bytes
    %%
    %%  Gas:
    %%    N    init  set_updater  benchmark
    %%    0     726        1,099      4,161
    %%   10   1,100        4,564     20,974
    %%   20   1,488        8,052     37,263
    %%   40   2,306       15,106     76,353
    %%   80   4,111       29,514    155,792
    %%  160   8,395       59,527    327,558
    %%          -0%         -60%       -38%
    %%
    %%  Memory (words)
    %%    N    init  set_updater  benchmark (remote)
    %%    0      29           36         75     (50)
    %%   10      89          136        325    (226)
    %%   20     149          236        585    (386)
    %%   40     269          436      1,105    (786)
    %%   80     509          836      2,145  (1,546)
    %%  160     989        1,636      4,225  (3,026)

    %% Load calldata before starting the VM. This makes calling functions with
    %% big arguments *a lot* cheaper.
    %%
    %%  Code size: 1,901 bytes
    %%
    %%  Gas:
    %%    N    init  set_updater  benchmark
    %%    0     673        1,070      4,082
    %%   10     678        4,535     20,715
    %%   20     683        8,023     36,824
    %%   40     693       15,077     75,554
    %%   80     713       29,485    154,273
    %%  160     752       59,498    324,599
    %%         -99%          -0%        -1%
    %%
    %%  Memory (words)
    %%    N    init  set_updater  benchmark (remote)
    %%    0      29           36         75     (50)
    %%   10      89          136        325    (226)
    %%   20     149          236        585    (386)
    %%   40     269          436      1,105    (786)
    %%   80     509          836      2,145  (1,546)
    %%  160     989        1,636      4,225  (3,026)
    %%          -0%          -0%        -0%

    %% No decoding of input state.
    %%
    %%  Code size: 1,961 bytes
    %%
    %%  Gas:
    %%    N    init  set_updater  benchmark
    %%    0   1,193          781      3,503
    %%   10   1,204          786     13,064
    %%   20   1,215          792     21,970
    %%   40   1,237          803     45,891
    %%   80   1,282          826     93,461
    %%  160   1,370          871    195,447
    %%         +40%         -99%       -40%
    %%
    %%  Memory (words)
    %%    N    init  set_updater  benchmark (remote)
    %%    0      55           33         72     (47)
    %%   10     115           93        282    (183)
    %%   20     175          153        502    (303)
    %%   40     295          273        942    (623)
    %%   80     535          513      1,822  (1,223)
    %%  160   1,015          993      3,582  (2,383)
    %%          +3%         -40%       -15%

    %% No decoding of contract call return values (only affects benchmark).
    %%
    %%  Code size: 1,874 bytes
    %%
    %%  Gas:
    %%    N    init  set_updater  benchmark
    %%    0                           3,262
    %%   10                           9,802
    %%   20                          15,290
    %%   40                          32,190
    %%   80                          64,967
    %%  160                         134,365
    %%                                 -31%     delta cost
    %%          x72         x174       x5.5     total improvement
    %%
    %%  Memory (words)
    %%    N    init  set_updater  benchmark (remote)
    %%    0                              77     (47)
    %%   10                             251    (183)
    %%   20                             431    (303)
    %%   40                             791    (623)
    %%   80                           1,511  (1,223)
    %%  160                           2,951  (2,383)
    %%                                 -18%     delta cost
    %%         x1.9         x2.6       x2.1     total improvement

    %% No decoding of contract call arguments (only affects benchmark).
    %%
    %%  Code size: 1,710 bytes      -36 bytes (yay!)
    %%
    %%  Gas:
    %%    N    init  set_updater  benchmark
    %%    0                           2,938
    %%   10                           4,363
    %%   20                           4,668
    %%   40                          10,988
    %%   80                          21,763
    %%  160                          43,782
    %%                                 -67%     delta cost
    %%          x72         x174        x17     total improvement
    %%
    %%  Memory (words)
    %%    N    init  set_updater  benchmark (remote)
    %%    0                              94     (47)
    %%   10                             208    (183)
    %%   20                             328    (303)
    %%   40                             568    (623)
    %%   80                           1,048  (1,223)
    %%  160                           2,008  (2,383)
    %%                                 -32%     delta cost
    %%         x1.9         x2.6       x3.0     total improvement

    %% Primitive maps
    %%
    %%  Code size: 1,417 bytes
    %%
    %%  Gas:
    %%    N    init  set_updater  benchmark
    %%    _     991          683      2,607         -- really need to pay gas for calldata sizes etc
    %%
    %%  Memory (words)
    %%    N    init  set_updater  benchmark (remote)
    %%    _      64           41         84 (75)    -- all data stored in maps off the heap

    ok.

sophia_pmaps(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc = ?call(new_account, 1000000000),
    Ct  = ?call(create_contract, Acc, primitive_map, 0),
    {} = ?call(call_contract, Acc, Ct, set_remote, {tuple, []}, Ct),

    %% Using maps locally
    {Result, _Gas} = ?call(call_contract, Acc, Ct, test, {list, {option, string}}, {}, #{return_gas_used => true}),
    Result = [none,                      none,
              {some,<<"value_of_foo">>}, {some,<<"value_of_bla">>},
              none,                      {some,<<"value_of_bla">>},
              none,                      {some,<<"new_value_of_bla">>}],

    %% Returning maps from contracts
    FooBar = #{<<"foo">> => <<"bar">>},
    FooBar = ?call(call_contract, Acc, Ct, return_map, {map, string, string}, {}),

    %% Passing maps as contract arguments
    <<"bar">> = ?call(call_contract, Acc, Ct, argument_map, string, FooBar),

    %% Passing maps between contracts
    FooBarXY = FooBar#{<<"xxx">> => <<"yyy">>},
    FooBarXY = ?call(call_contract, Acc, Ct, remote_insert, {map, string, string}, {<<"xxx">>, <<"yyy">>, FooBar}),
    XY       = maps:remove(<<"foo">>, FooBarXY),
    XY       = ?call(call_contract, Acc, Ct, remote_delete, {map, string, string}, {<<"foo">>, FooBarXY}),

    %% Storing maps in the state
    GetState = fun() -> ?call(call_contract, Acc, Ct, get_state_map, {map, string, string}, {}) end,
    Empty = #{},
    Empty = GetState(),
    {} = ?call(call_contract, Acc, Ct, insert_state, {tuple, []}, {<<"foo">>, <<"bar">>}),
    FooBar = GetState(),
    {} = ?call(call_contract, Acc, Ct, insert_state, {tuple, []}, {<<"xxx">>, <<"yyy">>}),
    {some, <<"bar">>} = ?call(call_contract, Acc, Ct, lookup_state, {option, string}, <<"foo">>),
    FooBarXY = GetState(),
    {} = ?call(call_contract, Acc, Ct, delete_state, {tuple, []}, {<<"foo">>}),
    XY = GetState(),
    {} = ?call(call_contract, Acc, Ct, set_state_map, {tuple, []}, FooBarXY),
    FooBarXY = GetState(),
    {} = ?call(call_contract, Acc, Ct, clone_state, {tuple, []}, {}),
    {} = ?call(call_contract, Acc, Ct, double_insert_state, {tuple, []}, {<<"side">>, <<"left">>, <<"right">>}),
    ok.

sophia_chess(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc = ?call(new_account, 1000000000),
    {Ct, _Gas} = ?call(create_contract, Acc, chess, {}, #{gas => 1000000, return_gas_used => true}),
    {some, <<"black king">>}  = ?call(call_contract, Acc, Ct, piece, {option, string}, {8, 5}),
    {some, <<"white queen">>} = ?call(call_contract, Acc, Ct, piece, {option, string}, {1, 4}),
    {some, <<"black pawn">>}  = ?call(call_contract, Acc, Ct, piece, {option, string}, {7, 2}),
    {}                        = ?call(call_contract, Acc, Ct, move_piece, {tuple, []}, {1, 4, 7, 2}),
    {some, <<"white queen">>} = ?call(call_contract, Acc, Ct, piece, {option, string}, {7, 2}),
    {some, <<"black pawn">>}  = ?call(call_contract, Acc, Ct, piece, {option, string}, {7, 1}),
    {}                        = ?call(call_contract, Acc, Ct, delete_row, {tuple, []}, 7),
    none                      = ?call(call_contract, Acc, Ct, piece, {option, string}, {7, 1}),
    ok.

sophia_map_of_maps(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc = ?call(new_account, 1000000000),
    {Ct, _Gas} = ?call(create_contract, Acc, map_of_maps, {}, #{gas => 1000000, return_gas_used => true}),
    {}         = ?call(call_contract, Acc, Ct, setup_state, {tuple, []}, {}),

    %% Test 1 - garbage collection of inner map when outer map is garbage collected
    Empty = #{},
    {}    = ?call(call_contract, Acc, Ct, test1_setup, {tuple, []}, {}),
    {}    = ?call(call_contract, Acc, Ct, test1_execute, {tuple, []}, {}),
    Empty = ?call(call_contract, Acc, Ct, test1_check, {map, string, string}, {}),
    ok.

sophia_variant_types(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc = <<AccId:256>> = ?call(new_account, 1000000),
    Ct  = ?call(create_contract, Acc, variant_types, {}),
    Call = fun(Fn, Type, Args) -> ?call(call_contract, Acc, Ct, Fn, Type, Args) end,
    Color  = {variant_t, [{red, []}, {green, []}, {blue, []}, {grey, [word]}]},
    StateR = {tuple, [word, word, Color]},
    State  = {variant_t, [{started, [StateR]}, {stopped, []}]},
    Unit   = {tuple, []},
    stopped   = Call(get_state, State, {}),
    {}        = Call(start, Unit, {123}),
    {grey, 0} = Call(get_color, Color, {}),
    {}        = Call(set_color, Unit, {{1}}),   %% green has tag 1
    {started, {AccId, 123, green}} = Call(get_state, State, {}),
    ok.


sophia_chain(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc         = ?call(new_account, 1000000),
    <<Beneficiary:?BENEFICIARY_PUB_BYTES/unit:8>> = ?BENEFICIARY_PUBKEY,
    Ct1         = ?call(create_contract, Acc, chain, {}, #{amount => 10000}),
    Beneficiary = ?call(call_contract, Acc, Ct1, miner, word, {}),
    ok.

sophia_savecoinbase(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc = ?call(new_account, 1000000),
    <<Beneficiary:?BENEFICIARY_PUB_BYTES/unit:8>> = ?BENEFICIARY_PUBKEY,

    %% Create chain contract and check that address is stored.
    Ct1 = ?call(create_contract, Acc, chain, {}, #{amount => 10000}),
    #{<<0>> := Val1} = get_contract_state(Ct1),
    {ok, {LastBf}} = aeso_data:from_binary({tuple, [word]}, Val1),
    <<LastBf:?BENEFICIARY_PUB_BYTES/unit:8>> = Ct1,

    %% Call chain.save_coinbase() and make sure beneficiary is stored.
    ?call(call_contract, Acc, Ct1, save_coinbase, word, {}),
    #{<<0>> := Val2}  = get_contract_state(Ct1),
    {ok, {LastBf2}} = aeso_data:from_binary({tuple, [word]}, Val2),
    Beneficiary = LastBf2,
    ok.



%% The crowd funding example.

-record(fundme_scenario,
    { name
    , goal
    , deadline
    , events }).

run_scenario(#fundme_scenario
             { name     = Scenario
             , goal     = Goal
             , deadline = Deadline
             , events   = Events }) ->

    state(aect_test_utils:new_state()),
    Denomination  = 1000 * 1000,
    StartingFunds = 1000 * 1000 * Denomination,
    InvestorNames = [ Investor || {contribute, Investor, _Amount, _Height} <- Events ],

    %% Set up accounts
    Beneficiary   = ?call(new_account, StartingFunds),
    Organiser     = ?call(new_account, StartingFunds),
    Investors     = maps:from_list([ {Name, ?call(new_account, StartingFunds)} || Name <- InvestorNames ]),

    %% Create the contract
    Contract      = ?call(create_contract, Organiser, fundme, {Beneficiary, Deadline, Goal * Denomination}),

    %% Run the events
    Account = fun(beneficiary) -> Beneficiary; (Name) -> maps:get(Name, Investors) end,
    RunEvent = fun({contribute, Name, Amount, Height}) ->
                    ?call(call_contract, Account(Name), Contract, contribute, bool, {},
                                #{amount => Amount * Denomination, height => Height});
                  ({withdraw, Name, Height, _}) ->
                    ?call(call_contract, Account(Name), Contract, withdraw, {tuple, []}, {},
                          #{height => Height})
               end,

    Results = [ {E, RunEvent(E)} || E <- Events ],

    %% Analyse scenario
    Contributed = fun(By) ->
        lists:sum([ Amount || {contribute, Name, Amount, Height} <- Events,
                              By == any orelse By == Name, Height < Deadline ]) end,

    TotalFunds    = Contributed(any),
    Funded        = TotalFunds >= Goal,

    Withdrawn = fun(By) ->
            [] /= [ w || {withdraw, Name, Height, _} <- Events,
                         Name == By, Height >= Deadline, not Funded ]
        end,

    Contributions = maps:map(fun(Name, _) ->
        case Withdrawn(Name) of
            true  -> 0;
            false -> Contributed(Name)
        end end, Investors),

    GasDelta = 100000,
    Is = fun(_, Expect, Actual) when Expect - GasDelta =< Actual, Actual =< Expect -> true;
            (Tag, Expect, Actual) -> {Scenario, Tag, Actual, is_not, Expect, minus_gas} end,

    BeneficiaryWithdraw = [] /= [ w || {withdraw, beneficiary, Height, _} <- Events,
                                       Funded, Height >= Deadline ],

    io:format("TotalFunds = ~p\n", [TotalFunds]),

    %% Check results
    ExpectedResult =
        fun({withdraw, _, _, ok})       -> {};
           ({withdraw, _, _, error})    -> {error, <<"out_of_gas">>};
           ({contribute, _, _, Height}) -> Height < Deadline end,
    lists:foreach(fun({E, Res}) ->
        Expect = ExpectedResult(E),
        case Expect == Res of
            true -> ok;
            _    -> exit({Scenario, E, expected, Expect, got, Res})
        end end, Results),

    %% Check beneficiary balance
    BalanceB = ?call(account_balance, Beneficiary),
    true = Is(beneficiary,
              if BeneficiaryWithdraw -> TotalFunds * Denomination;
                 true                -> 0 end, BalanceB - StartingFunds),

    %% Check investor balances
    lists:foreach(fun({Name, Acc}) ->
            Bal    = ?call(account_balance, Acc),
            Expect = -maps:get(Name, Contributions),
            true = Is(Name, Expect * Denomination, Bal - StartingFunds)
        end, maps:to_list(Investors)),

    ok.

sophia_fundme(_Cfg) ->
    Funded = #fundme_scenario{
        name     = funded_scenario,
        goal     = 10,
        deadline = 2000,
        events   =
            [{contribute, {investor, I}, I, 1000 + 100 * I} || I <- lists:seq(1, 5)] ++
            [{contribute, {investor, 2}, 5, 1900},
             {withdraw, beneficiary, 2100,   ok},
             {contribute, {investor, 1}, 3, 2150},
             {withdraw, beneficiary, 2200,   error},
             {withdraw, {investor, 5}, 2200, error} ] },

    NotFunded = #fundme_scenario{
        name     = not_funded_scenario,
        goal     = 25,
        deadline = 2000,
        events   =
            [{contribute, {investor, I}, I, 1000 + 100 * I} || I <- lists:seq(1, 5)] ++
            [{contribute, {investor, 2}, 5, 1900},
             {withdraw, beneficiary, 2100, error},
             {contribute, {investor, 2}, 3, 2150}] ++
            [{withdraw, {investor, I}, 2200 + I, ok} || I <- lists:seq(1, 4)] ++
            [{withdraw, {investor, 3}, 2300, error}] },

    run_scenario(Funded),
    run_scenario(NotFunded),
    ok.

%% AENS tests

aens_preclaim(PubKey, Name, S) ->
    aens_preclaim(PubKey, Name, #{}, S).

aens_preclaim(PubKey, Name, Options, S) ->
    Salt   = rand:uniform(10000),
    Nonce  = aect_test_utils:next_nonce(PubKey, S),
    Height = maps:get(height, Options, 1),
    Fee    = maps:get(fee, Options, 1),
    TTL    = maps:get(ttl, Options, 1000),
    {ok, NameAscii} = aens_utils:to_ascii(Name),
    CHash = aens_hash:commitment_hash(NameAscii, Salt),
    {ok, Tx} = aens_preclaim_tx:new(#{ account_id    => aec_id:create(account, PubKey),
                                       nonce         => Nonce,
                                       commitment_id => aec_id:create(commitment, CHash),
                                       fee => Fee,
                                       ttl => TTL }),
    PrivKey  = aect_test_utils:priv_key(PubKey, S),
    {ok, S1} = sign_and_apply_transaction(Tx, PrivKey, S, Height),
    {Salt, S1}.

aens_claim(PubKey, Name, Salt, S) ->
    aens_claim(PubKey, Name, Salt, #{}, S).

aens_claim(PubKey, Name, Salt, Options, S) ->
    Nonce  = aect_test_utils:next_nonce(PubKey, S),
    Height = maps:get(height, Options, 2),
    Fee    = maps:get(fee, Options, 1),
    TTL    = maps:get(ttl, Options, 1000),
    {ok, NameAscii} = aens_utils:to_ascii(Name),
    NameHash = aens_hash:name_hash(NameAscii),
    {ok, Tx} = aens_claim_tx:new(#{ account_id => aec_id:create(account, PubKey),
                                    nonce      => Nonce,
                                    name       => Name,
                                    name_salt  => Salt,
                                    fee        => Fee,
                                    ttl        => TTL }),
    PrivKey  = aect_test_utils:priv_key(PubKey, S),
    {ok, S1} = sign_and_apply_transaction(Tx, PrivKey, S, Height),
    {NameHash, S1}.

aens_revoke(PubKey, Hash, S) ->
    aens_revoke(PubKey, Hash, #{}, S).

aens_revoke(PubKey, Hash, Options, S) ->
    Nonce  = aect_test_utils:next_nonce(PubKey, S),
    Height = maps:get(height, Options, 3),
    Fee    = maps:get(fee, Options, 1),
    TTL    = maps:get(ttl, Options, 1000),
    {ok, Tx} = aens_revoke_tx:new(#{ account_id => aec_id:create(account, PubKey),
                                     nonce      => Nonce,
                                     name_id    => aec_id:create(name, Hash),
                                     fee        => Fee,
                                     ttl        => TTL }),
    PrivKey  = aect_test_utils:priv_key(PubKey, S),
    {ok, S1} = sign_and_apply_transaction(Tx, PrivKey, S, Height),
    {ok, S1}.

aens_update(PubKey, NameHash, Pointers, S) ->
    aens_update(PubKey, NameHash, Pointers, #{}, S).

aens_update(PubKey, NameHash, Pointers, Options, S) ->
    Nonce     = aect_test_utils:next_nonce(PubKey, S),
    Height    = maps:get(height, Options, 2),
    Fee       = maps:get(fee, Options, 1),
    TTL       = maps:get(ttl, Options, 1000),
    ClientTTL = maps:get(client_ttl, Options, 1000),
    NameTTL   = maps:get(name_ttl, Options, 1000),
    {ok, Tx}  = aens_update_tx:new(#{ account_id  => aec_id:create(account, PubKey),
                                      nonce       => Nonce,
                                      name_id     => aec_id:create(name, NameHash),
                                      name_ttl    => NameTTL,
                                      pointers    => Pointers,
                                      client_ttl  => ClientTTL,
                                      fee         => Fee,
                                      ttl         => TTL }),
    PrivKey  = aect_test_utils:priv_key(PubKey, S),
    {ok, S1} = sign_and_apply_transaction(Tx, PrivKey, S, Height),
    {ok, S1}.

sophia_aens(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc      = ?call(new_account, 1000000),
    Ct       = ?call(create_contract, Acc, aens, {}, #{ amount => 100000 }),
    Name     = <<"foo.test">>,
    APubkey  = 1,
    OPubkey  = <<2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2>>,
    %% TODO: Improve checks in aens_unpdate_tx
    Pointers = [aens_pointer:new(<<"account_pubkey">>, aec_id:create(account, <<APubkey:256>>)),
                aens_pointer:new(<<"oracle_pubkey">>, aec_id:create(oracle, OPubkey))],

    Salt  = ?call(aens_preclaim, Acc, Name),
    Hash  = ?call(aens_claim, Acc, Name, Salt),
    ok    = ?call(aens_update, Acc, Hash, Pointers),

    {some, APubkey} = ?call(call_contract, Acc, Ct, resolve_word,   {option, word},   {Name, <<"account_pubkey">>}),
    {some, OPubkey} = ?call(call_contract, Acc, Ct, resolve_string, {option, string}, {Name, <<"oracle_pubkey">>}),
    none            = ?call(call_contract, Acc, Ct, resolve_string, {option, string}, {Name, <<"name">>}),
    ok              = ?call(aens_revoke, Acc, Hash),
    none            = ?call(call_contract, Acc, Ct, resolve_string, {option, string}, {Name, <<"name">>}),

    %% AENS transactions from contract

    Name1           = <<"bla.test">>,
    Salt1           = rand:uniform(10000),
    {ok, NameAscii} = aens_utils:to_ascii(Name1),
    CHash           = aens_hash:commitment_hash(NameAscii, Salt1),
    NHash           = aens_hash:name_hash(NameAscii),
    {} = ?call(call_contract, Acc, Ct, preclaim, {tuple, []}, {Ct, CHash, 0},        #{ height => 10 }),
    {} = ?call(call_contract, Acc, Ct, claim,    {tuple, []}, {Ct, Name1, Salt1, 0}, #{ height => 11 }),
    {} = ?call(call_contract, Acc, Ct, transfer, {tuple, []}, {Ct, Acc, NHash, 0},   #{ height => 12 }),
    ok = ?call(aens_update, Acc, NHash, Pointers),
    {some, OPubkey} = ?call(call_contract, Acc, Ct, resolve_string, {option, string}, {Name1, <<"oracle_pubkey">>}),
    {error, <<"out_of_gas">>} = ?call(call_contract, Acc, Ct, revoke, {tuple, []}, {Ct, NHash, 0}, #{ height => 13 }),
    ok.


%%%===================================================================
%%% Store
%%%===================================================================

create_store(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc1  = ?call(new_account, 100),
    Ct1   = ?call(insert_contract, Acc1, <<"Code for C1">>),
    Ct1   = ?call(get_contract, Ct1),
    #{}   = aect_contracts:state(Ct1),
    ok.

update_store(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc1   = ?call(new_account, 100),
    Ct1    = ?call(insert_contract, Acc1, <<"Code for C1">>),
    Ct1    = ?call(get_contract, Ct1),
    Store1 = #{ <<0>> => <<42>> },
    Ct2    = aect_contracts:set_state(Store1, Ct1),
    Ct2    = ?call(enter_contract, Ct2),
    Ct2    = ?call(get_contract, Ct2),
    ok.

read_store(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc1   = ?call(new_account, 100),
    Ct1    = ?call(insert_contract, Acc1, <<"Code for C1">>),
    Ct1    = ?call(get_contract, Ct1),
    Store1 = #{ <<0>> => <<42>> },
    Ct2    = aect_contracts:set_state(Store1, Ct1),
    Ct2    = ?call(enter_contract, Ct2),
    Ct2    = ?call(get_contract, Ct2),
    Store1 = aect_contracts:state(Ct2),
    ok.


store_zero_value(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc1   = ?call(new_account, 100),
    Ct1    = ?call(insert_contract, Acc1, <<"Code for C1">>),
    Ct1    = ?call(get_contract, Ct1),
    Store1 = #{ <<0>> => <<42>>
              , <<1>> => <<0>>
              , <<2>> => <<>> },
    Ct2    = aect_contracts:set_state(Store1, Ct1),
    Ct2    = ?call(enter_contract, Ct2),
    %% Empty values are removed in state tree.
    Ct3    = ?call(get_contract, Ct2),
    Store2 = #{ <<0>> => <<42>>
              , <<1>> => <<0>>},
    Store2 = aect_contracts:state(Ct3),
    ok.

merge_new_zero_value(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc1   = ?call(new_account, 100),
    Ct1    = ?call(insert_contract, Acc1, <<"Code for C1">>),
    Ct1    = ?call(get_contract, Ct1),
    Store1 = #{ <<0>> => <<42>>
              , <<1>> => <<0>>
              , <<2>> => <<>> },
    Ct2    = aect_contracts:set_state(Store1, Ct1),
    Ct2    = ?call(enter_contract, Ct2),
    %% Empty values are removed in state tree.
    Ct3    = ?call(get_contract, Ct2),
    Store2 = #{ <<0>> => <<0>>
              , <<1>> => <<>>
              , <<2>> => <<42>> },
    Ct4    = aect_contracts:set_state(Store2, Ct3),
    Ct4    = ?call(enter_contract, Ct4),
    Ct5    = ?call(get_contract, Ct4),
    Store3 = #{ <<0>> => <<0>>
              , <<2>> => <<42>>},
    Store3 = aect_contracts:state(Ct5),
    ok.


merge_missing_keys(_Cfg) ->
    state(aect_test_utils:new_state()),
    Acc1   = ?call(new_account, 100),
    Ct1    = ?call(insert_contract, Acc1, <<"Code for C1">>),
    Ct1    = ?call(get_contract, Ct1),
    Store1 = #{ <<0>> => <<42>>
              , <<1>> => <<17>>
              , <<2>> => <<>> },
    Ct2    = aect_contracts:set_state(Store1, Ct1),
    Ct2    = ?call(enter_contract, Ct2),
    %% Empty values are removed in state tree.
    Ct3    = ?call(get_contract, Ct2),
    Store2 = #{ <<3>> => <<1,2,3,4>>
              , <<2>> => <<42>> },
    Ct4    = aect_contracts:set_state(Store2, Ct3),
    Ct4    = ?call(enter_contract, Ct4),
    Ct5    = ?call(get_contract, Ct4),
    Store3 = #{ <<2>> => <<42>>
              , <<3>> => <<1,2,3,4>>},
    Store3 = aect_contracts:state(Ct5),
    ok.


enter_contract(Contract, S) ->
    Contracts = aect_state_tree:enter_contract(Contract, aect_test_utils:contracts(S)),
    {Contract, aect_test_utils:set_contracts(Contracts, S)}.
