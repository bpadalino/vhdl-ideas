package base64 is

    function encode(x : bit_vector) return rv_t of string ;
    function decode(x : string) return rv_t of bit_vector ;

end package ;

package body base64 is

    type alphabet_t is array(natural range <>) of character ;

    -- Map one type onto another like an alphabet
    function mapper
      generic (
        type a is (<>) ;
        type b is (<>) ;
        type array_t is array(a range <>) of b ;
      ) parameter(arange : a'range'record ; brange : b'range'record) return array_t
    is
        variable rv : array_t(arange) ;
        variable idx : a := arange.left ;
    begin
        for val in brange loop
            rv(idx) := val ;
            idx := idx'right ;
        end loop ;
        return rv ;
    end function ;

    -- Riviera doesn't do the implicit types correctly
    --function slice
    --  generic (
    --    type t_array is array(natural range<>) of t
    --  ) parameter(start : t ; stop : t) return t_array
    --is
    --    constant startidx : natural := t'pos(start) ;
    --    constant stopidx  : natural := t'pos(stop) ;
    --    variable rv : t_array(startidx to stopidx) ;
    --begin
    --    for idx in startidx to stopidx loop
    --        rv(idx) := t'val(idx) ;
    --    end loop ;
    --    return rv ;
    --end function ;

    function slice(start : character ; stop : character) return alphabet_t is
        constant startidx : natural := character'pos(start) ;
        constant stopidx  : natural := character'pos(stop) ;
        variable rv : alphabet_t(startidx to stopidx) ;
    begin
        for idx in startidx to stopidx loop
            rv(idx) := character'val(idx) ;
        end loop ;
        return rv ;
    end function ;


    constant alphabet : alphabet_t := (
        slice('A', 'Z') & slice('a', 'z') & slice('0', '9') & '+' & '/'
    ) ;

    constant alphabet_urlsafe : alphabet_t := (
        alphabet(0 to 63) & '-' & '_'
    ) ;

    constant PAD : character := '=' ;

    function to_integer(x : bit_vector) return integer is
        variable rv : integer := 0 ;
    begin
        for idx in x'high downto x'low loop
            rv := rv * 2 ;
            if x(idx) = '1' then
                rv := rv + 1 ;
            end if ;
        end loop ;
        return rv ;
    end function ;

    function encode(x : bit_vector) return rv_t of string is
        constant length : positive := (x'length+5)/6 ;
        variable rv : rv_t ;
        variable pos : natural ;
        variable rv_idx : positive := 1 ;
        alias xa : bit_vector(x'high downto 0) is x ;
    begin
        for slice_idx in rv'reverse_range loop
            pos := to_integer(xa((slice_idx-1)*6+5 downto (slice_idx-1)*6)) ;
            rv(rv_idx) := alphabet(pos) ;
            rv_idx := rv_idx + 1 ;
        end loop ;
        return rv ;
    end function ;

    function decode(x : string) return rv_t of bit_vector is
        variable rv : rv_t ;
    begin
        return rv ;
    end function ;

end package body ;

entity test is
end entity ;

architecture arch of test is

    constant val : bit_vector := B"111111_000000_110011_110110_010101_010000_101011_110001_010101_010110_101000_101010" ;

begin

    tb : process
        variable result : string(1 to val'length/6) ;
    begin
        result := work.base64.encode(val) ;
        report result ;
        std.env.stop ;
    end process ;

end architecture ;
