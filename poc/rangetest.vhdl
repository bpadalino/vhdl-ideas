use std.textio.all ;

entity test is
end entity ;

architecture arch of test is


    function generic_overlap
      generic (
        type array_t is array(natural range <>) of type is private ;
      ) parameter (
        l, r : array_t ;
      ) return natural'range'record
    is
        constant lrange : natural'range'record := l'range'value when l'ascending = true else l'reverse_range'value ;
        constant rrange : natural'range'record := r'range'value when r'ascending = true else r'reverse_range'value ;
        variable orange : natural'range'record := lrange ;
    begin
        -- All directions are ascending so we just need to take
        -- the minimum of the maximum of the left and the minimum
        -- of the right, and that should give us our overlap
        orange.left := maximum(lrange.left, rrange.left) ;
        orange.right := minimum(lrange.right, rrange.right) ;
        return orange ;
    end function ;


/*
    -- Riviera-PRO can't figure out how to map the array types
    function generic_overlap
      generic (
        type array_t is array(type is (<>)) of type is private ;
        function maximum(l, r : array_t'index) return boolean is <> ;
        function minimum(l, r : array_t'index) return boolean is <> ;
      ) parameter (
        l, r : array_t ;
      ) return array_t'index'range'record
    is
        constant lrange : array_t'index'range'record := l'range'value when l'ascending = true else l'reverse_range'value ;
        constant rrange : array_t'index'range'record := r'range'value when r'ascending = true else r'reverse_range'value ;
        variable orange : array_t'index'range'record := lrange ;
    begin
        -- All directions are ascending so we just need to take
        -- the minimum of the maximum of the left and the minimum
        -- of the right, and that should give us our overlap
        orange.left := maximum(lrange.left, rrange.left) ;
        orange.right := minimum(lrange.right, rrange.right) ;
        return orange ;
    end function ;
*/

    -- Riviera-PRO doesn't like overloaded generic and instantiated functions
    -- function overlap is new overlap generic map( array_t => bit_vector ) ;
    function overlap is new generic_overlap generic map( array_t => bit_vector ) ;

    signal a : bit_vector(7 downto 0) ;
    signal b : bit_vector(10 downto 0) ;
    signal c : bit_vector(20 downto 8) ;

    signal d : bit_vector(0 to 8) ;
    signal e : bit_vector(4 to 5) ;
    signal f : bit_vector(5 to 4) ;

    function to_string(x : natural'range'record) return string is
    begin
        return "(left: " & to_string(x.left) & ", right: " & to_string(x.right) & ", direction: " & to_string(x.direction) & ")" ;
    end function ;

begin

    tb : process
        variable l : std.textio.line ;
    begin
        -- A's
        std.textio.write(l, to_string(overlap(a, a)) & LF) ;
        std.textio.write(l, to_string(overlap(a, b)) & LF) ;
        std.textio.write(l, to_string(overlap(a, c)) & LF) ;
        std.textio.write(l, to_string(overlap(a, d)) & LF) ;
        std.textio.write(l, to_string(overlap(a, e)) & LF) ;
        std.textio.write(l, to_string(overlap(a, f)) & LF) ;

        -- B's
        std.textio.write(l, to_string(overlap(b, a)) & LF) ;
        std.textio.write(l, to_string(overlap(b, b)) & LF) ;
        std.textio.write(l, to_string(overlap(b, c)) & LF) ;
        std.textio.write(l, to_string(overlap(b, d)) & LF) ;
        std.textio.write(l, to_string(overlap(b, e)) & LF) ;
        std.textio.write(l, to_string(overlap(b, f)) & LF) ;

        -- C's
        std.textio.write(l, to_string(overlap(c, a)) & LF) ;
        std.textio.write(l, to_string(overlap(c, b)) & LF) ;
        std.textio.write(l, to_string(overlap(c, c)) & LF) ;
        std.textio.write(l, to_string(overlap(c, d)) & LF) ;
        std.textio.write(l, to_string(overlap(c, e)) & LF) ;
        std.textio.write(l, to_string(overlap(c, f)) & LF) ;

        -- D's
        std.textio.write(l, to_string(overlap(d, a)) & LF) ;
        std.textio.write(l, to_string(overlap(d, b)) & LF) ;
        std.textio.write(l, to_string(overlap(d, c)) & LF) ;
        std.textio.write(l, to_string(overlap(d, d)) & LF) ;
        std.textio.write(l, to_string(overlap(d, e)) & LF) ;
        std.textio.write(l, to_string(overlap(d, f)) & LF) ;

        -- E's
        std.textio.write(l, to_string(overlap(e, a)) & LF) ;
        std.textio.write(l, to_string(overlap(e, b)) & LF) ;
        std.textio.write(l, to_string(overlap(e, c)) & LF) ;
        std.textio.write(l, to_string(overlap(e, d)) & LF) ;
        std.textio.write(l, to_string(overlap(e, e)) & LF) ;
        std.textio.write(l, to_string(overlap(e, f)) & LF) ;

        -- F's
        std.textio.write(l, to_string(overlap(f, a)) & LF) ;
        std.textio.write(l, to_string(overlap(f, b)) & LF) ;
        std.textio.write(l, to_string(overlap(f, c)) & LF) ;
        std.textio.write(l, to_string(overlap(f, d)) & LF) ;
        std.textio.write(l, to_string(overlap(f, e)) & LF) ;
        std.textio.write(l, to_string(overlap(f, f)) & LF) ;

        std.textio.writeline(std.textio.output, l) ;

        -- Done
        std.env.stop ;
    end process ;

end architecture ;
