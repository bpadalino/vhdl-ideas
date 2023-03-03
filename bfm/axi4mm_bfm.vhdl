use work.axi4.burst_t ;
use work.axi4.lock_t ;
use work.axi4.cache_t ;
use work.axi4.resp_t ;
use work.axi4.prot_t ;
use work.axi4mm.manager ;

package axi4mm_bfm is

    type direction_t is (READ, WRITE) ;

    type transaction_t is record
        direction   :   direction_t ;
        address     :   natural ;
        length      :   natural ;
        size        :   natural range 0 to 7 ;
        burst       :   burst_t ;
        lock        :   lock_t ;
        cache       :   cache_t ;
        prot        :   prot_t ;
        data        :   bit_vector ;
    end record ;

    type response_t is record
        id          :   natural ;
        transaction :   transaction_t ;
        response    :   resp_t ;
    end record ;

    constant ID_FRONT : natural := natural'low ;
    constant ID_BACK  : natural := natural'high ;

    type transactor_t is protected
        -- Add transactions and pop responses to the queue
        impure function push(x : transaction_t) return natural ;
        impure function pop(x : natural := ID_FRONT) return response_t ;

        -- Drive the AXI4-MM bus
        procedure drive(signal x : view manager of work.axi4mm.aximm_t) ;
    end protected ;

end package ;

package body axi4mm_bfm is

    -- Need to add the ID to the pending transaction
    type pending_transaction_t is record
        id  : natural ;
        transaction : transaction_t ;
    end record ;

    -- Create list transaction_list_t from generic list
    type transaction_list_t ;

    -- Create response list from generic list
    type response_list_t ;

    type transactor_t is protected body
        variable next_id : natural := 1 ;
        variable transaction_list : transaction_list_t ;

        impure function push(x : transaction_t)return natural is
            constant pending : pending_transaction_t := ( id => next_id, transaction => x ) ;
        begin
            -- Add transaction to the list

            -- Increment ID
            next_id := next_id + 1 ;
            return pending.id ;
        end function ;

        -- Non-blocking call
        impure function response_ready(x : natural := ID_FRONT) return boolean is
            variable response : response_t ;
        begin
            if x = ID_FRONT then
                return false when response_list.size = 0 else
                       true ;
            else
                for idx in 0 to response_list.size-1 loop
                    -- Check to see if the response is ready
                    response := response_list.get(idx) ;
                    if response.id = x then
                        return true ;
                    end if ;
                end loop ;
            end if ;

            -- Made it to the end, so response isn't in the list
            return false ;
        end function ;

        -- Blocking call
        impure function pop(x : natural := ID_FRONT) return response_t is
            variable found : boolean := false ;
            variable response : response_t ;
        begin
            if response_list.size = 0 then
                -- wait for a response to come in
            end if ;
            while found = false loop
                if x = ID_FRONT then
                    response := response_list.remove(0) ;
                    found := true ;
                else
                    for idx in 0 to response_list.size-1 loop
                        response := response_list.get(idx) ;
                        if response.id = x then
                            exit ;
                        end if ;
                    end loop ;
                end if ;
                if found = false then
                    -- wait for another to get added to the list
                end if ;
            end loop ;
            return response ;
        end function ;

        procedure drive(signal x : view manager of work.axi4mm.axi4mm_t) is
        begin
            -- wait until a transaction is ready

            -- perform the transaction

            -- prepare the response

            -- Add the response to the response queue
        end procedure ;
    end protected body ;

end package body ;
