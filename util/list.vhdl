-- Ordered List
package list is
    -- type could be value_mirror to hold a bunch of different records?
    -- generic package or generic protected type?
    -- generic protected type makes more sense
    type list is protected generic(type t) ;
        procedure prepend(x : t) ;
        procedure append(x : t) ;
        procedure insert(x : t ; index : natural) ;
        procedure clear(r : natural'range'record) ;
        impure function size return natural ;
        impure function get(index : natural) return rv_t of t ;
        impure function iterate(from : natural := 0) return natural'range'record ;
    end protected ;
end package ;

package body list is

    type list is protected body
        variable lsize : natural ;

        procedure prepend(x : t) is
        begin
        end procedure ;

        procedure append(x : t) is
        begin
        end procedure ;

        procedure insert(x : t ; index : natural) is
        begin

        end procedure ;

        procedure clear(r : natural'range'record) is
        begin

        end procedure ;

        impure function size return natural is
        begin
            return lsize ;
        end function ;

        impure function get(index : natural) return rv_t of t is
            variable rv : rv_t ;
        begin
            return rv ;
        end function ;

        impure function iterate(from : natural := 0) return natural'range'record is
            subtype rv is natural range from to lsize-1 ;
        begin
            return rv'range'record ;
        end function ;
    end protected body ;

end package body ;

