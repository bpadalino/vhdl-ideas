-- Unordered Dictionary
package dict is
    type dict is protected
      generic(
        type keys_t is array(natural range <>) of type is private ;
        type value_t ;
        function "<"(l, r : keys_t'element) return boolean is <> ;
        function "="(l, r : keys_t'element) return boolean is <> ;
      ) ;
        procedure put(k : keys_t'element ; v : value_t) ;
        impure function keys return keys_t ;
        impure function get(key : keys_t'element) return value_t ;
        impure function exists(key : keys_t'element) return boolean ;
        impure function size return natural ;
    end protected ;
end package ;

package body dict is

    type dict is protected body
        variable lsize : natural ;
        procedure put(k : keys_t'element ; v : value_t) is
        begin

        end procedure ;

        impure function keys return keys_t is
            variable rv : keys_t(0 to lsize-1) ;
        begin
            return rv ;
        end function ;

        impure function get(key : keys_t'element) return value_t is
            variable rv : value_t ;
        begin
            return rv ;
        end function ;

        impure function exists(key : keys_t'element) return boolean is
        begin
            return false ;
        end function ;

        impure function size return natural is
        begin
            return lsize ;
        end function ;
    end protected body ;

end package body ;

