package memory is

    type memory_t is protected
        impure function read(r : natural'range'record) return rv_t of bit_vector ;
        impure function read(address : natural ; size : natural) return bit_vector ;
        procedure write(start : natural ; data : bit_vector) ;
        procedure write(r : natural'range'record ; data : bit_vector) ;
        procedure randomize(r : natural'range'record) ;
        procedure clear(r : natural'range'record) ;
    end protected ;

end package ;

package body memory is

    -- Create a btree of flat memory with ranges?
    type memory_t is protected body
        impure function read(r : natural'range'record) return rv_t of bit_vector is
            variable rv : rv_t ;
        begin
            return rv ;
        end function ;

        impure function read(address : natural ; size : natural) return bit_vector is
            variable rv : bit_vector(size-1 downto 0) ;
        begin
            return rv ;
        end function ;

        procedure write(start : natural ; data : bit_vector) is
        begin

        end procedure ;

        procedure write(r : natural'range'record ; data : bit_vector) is
        begin

        end procedure ;

        procedure randomize(r : natural'range'record) is
        begin

        end procedure ;

        procedure clear(r : natural'range'record) is
        begin

        end procedure ;
    end protected body ;

end package body ;

