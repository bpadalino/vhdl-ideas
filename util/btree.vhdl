use work.list.list ;

package btree is

    type btree is protected
      generic (
        type key_t ;
        type value_t ;
        -- Just a normal type defined by the above 2 generics
        type keys_t is array(natural range <>) of key_t ;
        function "<"(l, r: key_t) return boolean is <>
      ) ;
        --procedure keys(variable k : inout list) ;
        impure function keys return keys_t ;
        impure function get(k : key_t) return rv_t of value_t ;
        impure function exists(k : key_t) return boolean ;
        procedure add(k : key_t ; v : value_t) ;
        procedure remove(k : key_t) ;
        procedure copy(variable target : inout btree) ;
    end protected ;

end package ;

package body btree is

    type btree is protected body
        variable count : natural := 0 ;

        procedure copy(variable target : inout btree) is
            variable rv : keys_t := keys ;
        begin
            for idx in rv'range loop
                target.add(rv(idx), get(rv(idx))) ;
            end loop ;
        end procedure ;

        impure function keys return keys_t is
            variable rv : keys_t(0 to count-1) ;
        begin
            return rv ;
        end function ;

        --procedure keys(variable k : inout list) is
        --    constant allkeys : keys_t := keys ;
        --begin
        --    k.clear ;
        --    k.append(allkeys) ;
        --end procedure ;

        impure function get(k : key_t) return rv_t of value_t is
            variable rv : rv_t ;
        begin
            return rv ;
        end function ;

        impure function exists(k : key_t) return boolean is
        begin
            return false ;
        end function ;

        procedure add(k : key_t ; v : value_t) is
        begin
        end procedure ;

        impure function remove(k : key_t) return rv_t of value_t is
            variable rv : rv_t ;
        begin
            return rv ;
        end function ;

        procedure remove(k : key_t) is
        begin

        end procedure ;

    end protected body ;

end package body ;
