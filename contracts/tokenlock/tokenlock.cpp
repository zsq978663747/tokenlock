/**
 *  @file
 *  @copyright defined in eos/LICENSE.txt
 */

#include "tokenlock.hpp"

namespace tokenlock {

    void token::create( account_name issuer, asset maximum_supply, string token_name) {
        require_auth( _self );

        eosio_assert( is_account( issuer ), "issuer does not exist");

        auto sym = maximum_supply.symbol;
        eosio_assert( sym.is_valid(), "invalid symbol name" );
        eosio_assert( maximum_supply.is_valid(), "invalid supply");
        eosio_assert( maximum_supply.amount > 0, "max-supply must be positive");

        stats statstable( _self, sym.name() );
        auto existing = statstable.find( sym.name() );
        eosio_assert( existing == statstable.end(), "token with symbol already exists" );

        eosio_assert( token_name.size() <= 30, "token_name has more than 30 bytes" );

        statstable.emplace( _self, [&]( auto& s ) {
            s.supply.symbol = maximum_supply.symbol;
            s.max_supply    = maximum_supply;
            s.issuer        = issuer;
            s.token_name    = token_name;
        });
    }

    void token::issue( account_name to, asset quantity, string memo ) {
        auto sym = quantity.symbol;
        eosio_assert( sym.is_valid(), "invalid symbol name" );
        eosio_assert( memo.size() <= 256, "memo has more than 256 bytes" );

        auto sym_name = sym.name();
        stats statstable( _self, sym_name );
        auto existing = statstable.find( sym_name );
        eosio_assert( existing != statstable.end(), "token with symbol does not exist, create token before issue" );
        const auto& st = *existing;

        require_auth( st.issuer );
        eosio_assert( quantity.is_valid(), "invalid quantity" );
        eosio_assert( quantity.amount > 0, "must issue positive quantity" );

        eosio_assert( quantity.symbol == st.supply.symbol, "symbol precision mismatch" );
        eosio_assert( quantity.amount <= st.max_supply.amount - st.supply.amount, "quantity exceeds available supply");

        statstable.modify( st, 0, [&]( auto& s ) {
            s.supply += quantity;
        });

        add_balance( st.issuer, quantity, st.issuer );

        if( to != st.issuer ) {
            SEND_INLINE_ACTION( *this, transfer, {st.issuer,N(active)}, {st.issuer, to, quantity, memo} );
        }
    }

    void token::issuelock( account_name     to,
                           asset            quantity,
                           uint64_t         times,
                           uint64_t         interval_day,
                           time_point_sec   start_time,
                           string           memo )
    {
        eosio_assert( is_account( to ), "to account does not exist");

        eosio_assert( quantity.is_valid(), "invalid quantity" );
        eosio_assert( quantity.amount > 0, "must issue positive quantity" );

        auto sym = quantity.symbol;
        eosio_assert( sym.is_valid(), "invalid symbol name" );
        auto sym_name = sym.name();
        stats statstable( _self, sym_name );
        auto existing = statstable.find( sym_name );
        eosio_assert( existing != statstable.end(), "token with symbol does not exist, create token before issue" );
        const auto& st = *existing;

        eosio_assert( quantity.symbol == st.supply.symbol, "symbol precision mismatch" );

        eosio_assert( st.issuer != to, "cannot issue with locking to issuer" );

        eosio_assert( times > 0 && times < 10000  && interval_day > 0 && interval_day < 10000, "times and interval_day must greater then 0 and less then 10000" );

        uint32_t start_time_s = start_time.utc_seconds;
        eosio_assert( start_time_s > now() && (start_time_s - now() <= 3600 * 24 * 30), "start_time can't be past and can't more than a month from now" );

        eosio_assert( memo.size() <= 256, "memo has more than 256 bytes" );


        require_auth( st.issuer );

        int64_t total_amount = quantity.amount * times;
        eosio_assert( total_amount / times == quantity.amount , "quantity.amount * times calculation overflow" );
        asset total_asset = quantity * times;
        eosio_assert( total_amount <= st.max_supply.amount - st.supply.amount, "quantity exceeds available supply");

        statstable.modify( st, 0, [&]( auto& s ) {
            s.supply += total_asset;
        });

        add_balance( st.issuer, total_asset, st.issuer );
        sub_balance( st.issuer, total_asset );

        issues issues_table( _self, to );
        auto existing_i = issues_table.find( sym_name );
        eosio_assert( existing_i == issues_table.end(), "this account has been issued with locking" );

        issues_table.emplace( _self, [&]( auto& a ){
            a.total = total_asset;
            a.claimed = asset {0, sym};
            a.quantity_per_time = quantity;
            a.times = times;
            a.interval_day = interval_day;
            a.start_time = start_time;
            a.claimed_all = false;
        });
    }

    void token::claim( account_name owner, string symbol_name){

        require_auth( owner );

        auto sym = symbol_type{string_to_symbol(0, symbol_name.c_str())};
        eosio_assert( sym.is_valid(), "invalid symbol name" );

        auto sym_name = sym.name();
        issues issues_table( _self, owner );
        auto existing = issues_table.find( sym_name );
        eosio_assert( existing != issues_table.end(), "this account has not been issued with locking" );
        const auto& it = *existing;

        eosio_assert( now() > it.start_time.utc_seconds, "you can not claim before issue start_time");
        eosio_assert( it.claimed_all == false && it.claimed < it.total, "you had claimed all your token already" );

        uint64_t n = ( now() - it.start_time.utc_seconds ) / ( it.interval_day * day );
        asset all_unlocked_asset = it.quantity_per_time * n;
        eosio_assert( all_unlocked_asset / n == it.quantity_per_time, "quantity.amount * times calculation overflow");

        if ( all_unlocked_asset > it.total ){
            all_unlocked_asset = it.total;
        }

        eosio_assert( all_unlocked_asset > it.claimed, "you had claimed all unlocked token" );

        asset claimable_asset = all_unlocked_asset - it.claimed;

        issues_table.modify( it, 0, [&]( auto& iss ) {
            iss.claimed += claimable_asset;
        });

        if ( all_unlocked_asset == it.total ){
            issues_table.modify( it, 0, [&]( auto& iss ) {
                iss.claimed_all = true;
            });
        }

        add_balance( owner, claimable_asset, owner );
    }

    void token::burn( asset quantity){
        auto sym = quantity.symbol;
        eosio_assert( sym.is_valid(), "invalid symbol name" );

        auto sym_name = sym.name();
        stats statstable( _self, sym_name );
        auto existing = statstable.find( sym_name );
        eosio_assert( existing != statstable.end(), "token with symbol does not exist" );
        const auto& st = *existing;

        eosio_assert( quantity.symbol == st.supply.symbol, "symbol precision mismatch" );

        require_auth( st.issuer );

        accounts acnts( _self, st.issuer );

        const auto& issuer = acnts.get( sym_name , "no balance object found" );
        eosio_assert( issuer.balance.amount >= quantity.amount, "burn amount should not greater then issuer's balance" );

        eosio_assert( quantity.symbol == st.supply.symbol, "symbol precision mismatch" );

        statstable.modify( st, 0, [&]( auto& s ) {
            s.supply -= quantity;
        });

        sub_balance( st.issuer, quantity );
    }

    void token::transfer( account_name from, account_name to, asset quantity, string memo ) {
        eosio_assert( from != to, "cannot transfer to self" );
        require_auth( from );
        eosio_assert( is_account( to ), "to account does not exist");
        auto sym = quantity.symbol.name();
        stats statstable( _self, sym );
        const auto& st = statstable.get( sym );

        require_recipient( from );
        require_recipient( to );

        eosio_assert( quantity.is_valid(), "invalid quantity" );
        eosio_assert( quantity.amount > 0, "must transfer positive quantity" );
        eosio_assert( quantity.symbol == st.supply.symbol, "symbol precision mismatch" );
        eosio_assert( memo.size() <= 256, "memo has more than 256 bytes" );


        sub_balance( from, quantity );
        add_balance( to, quantity, from );
    }

    void token::sub_balance( account_name owner, asset value ) {
        accounts from_acnts( _self, owner );

        const auto& from = from_acnts.get( value.symbol.name(), "no balance object found" );
        eosio_assert( from.balance.amount >= value.amount, "overdrawn balance" );


        if( from.balance.amount == value.amount ) {
            from_acnts.erase( from );
        } else {
            from_acnts.modify( from, owner, [&]( auto& a ) {
                a.balance -= value;
            });
        }
    }

    void token::add_balance( account_name owner, asset value, account_name ram_payer )
    {
        accounts to_acnts( _self, owner );
        auto to = to_acnts.find( value.symbol.name() );
        if( to == to_acnts.end() ) {
            to_acnts.emplace( ram_payer, [&]( auto& a ){
                a.balance = value;
            });
        } else {
            to_acnts.modify( to, 0, [&]( auto& a ) {
                a.balance += value;
            });
        }
    }

}

EOSIO_ABI( tokenlock::token, (create)(issue)(issuelock)(claim)(transfer)(burn) )
