/**
 *  @file
 *  @copyright defined in eos/LICENSE.txt
 */
#pragma once

#include <eosiolib/types.hpp>
#include <eosiolib/asset.hpp>
#include <eosiolib/eosio.hpp>
#include <eosiolib/time.hpp>
#include <eosiolib/symbol.hpp>
#include <string>

const uint32_t day = 10;

namespace tokenlock {

    using std::string;
    using namespace eosio;

    class token : public contract {
    public:
        token( account_name self ):contract(self){}

        /// @abi action
        void create( account_name   issuer,
                     asset          maximum_supply,
                     string         token_name );

        /// @abi action
        void issue( account_name    to,
                    asset           quantity,
                    string          memo );

        /// @abi action
        void issuelock( account_name    to,
                        asset           quantity_per_time,       // unlocking quantity of each time
                        uint64_t        times,          // total unlock times
                        uint64_t        interval_day,   // interval time, unit: day
                        time_point_sec  start_time,     // format: http://en.wikipedia.org/wiki/ISO_8601
                        string          memo );

        /// @abi action
        void claim( account_name owner, string symbol_name);

        /// @abi action
        void burn( asset quantity);

        /// @abi action
        void transfer( account_name from,
                       account_name to,
                       asset        quantity,
                       string       memo );

        inline asset get_supply( symbol_name sym )const;

        inline asset get_balance( account_name owner, symbol_name sym )const;

    private:

        /// @abi table accounts i64
        struct account {
            asset    balance;

            uint64_t primary_key()const { return balance.symbol.name(); }
        };

        /// @abi table stat i64
        struct currency_stat {
            asset           supply;
            asset           max_supply;
            account_name    issuer;
            string          token_name;

            uint64_t primary_key()const { return supply.symbol.name(); }
        };

        /// @abi table issues i64
        struct issue_lock{
            asset           total;
            asset           claimed;
            asset           quantity_per_time;
            uint64_t        times;
            uint64_t        interval_day;
            time_point_sec  start_time;
            bool            claimed_all;
            uint64_t primary_key()const { return total.symbol.name();}
        };

        typedef eosio::multi_index<N(accounts), account> accounts;
        typedef eosio::multi_index<N(stat), currency_stat> stats;
        typedef eosio::multi_index<N(issues), issue_lock> issues;

    private:
        void sub_balance( account_name owner, asset value );
        void add_balance( account_name owner, asset value, account_name ram_payer );
    };

    asset token::get_supply( symbol_name sym )const
    {
        stats statstable( _self, sym );
        const auto& st = statstable.get( sym );
        return st.supply;
    }

    asset token::get_balance( account_name owner, symbol_name sym )const
    {
        accounts accountstable( _self, owner );
        const auto& ac = accountstable.get( sym );
        return ac.balance;
    }

}
