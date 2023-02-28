package ranges is

    -- XXX: Make generic
    function overlap
      generic (
        type array_t is array(natural range <>) of type is private ;
      ) parameter (
        l, r : array_t ;
      ) return natural'range'record ;

end package ;

package body ranges is

    function max(l, r : natural) return natural is
    begin
        return l when l > r else
               r ;
    end function ;

    function min(l, r : natural) return natural is
    begin
        return l when l < r else
               r ;
    end function ;

    function overlap
      generic (
        type array_t is array(natural range <>) of type is private ;
      ) parameter (
        l, r : array_t ;
      ) return natural'range'record
    is
        constant lrange : natural'range'record := l'range'value ;
        constant rrange : natural'range'record := r'range'value ;
        variable orange : natural'range'record := l'range'value ;
    begin
        if lrange.direction /= rrange.direction then
            -- Choosing to be ascending
            orange.direction := ascending ;
            if lrange.direction = ascending then
                -- low to high
                -- high downto low
                orange.left := max(lrange.left, rrange.right) ;
                orange.right := min(lrange.right, rrange.left) ;
            else
                -- high downto low
                -- low to high
                orange.left := max(lrange.right, rrange.left) ;
                orange.right := min(lrange.left, rrange.right) ;
            end if ;
        else
            if lrange.direction = ascending then
                orange.left := max(lrange.left, rrange.left) ;
                orange.right := min(lrange.right, rrange.right) ;
            else
                orange.left := min(lrange.left, rrange.left) ;
                orange.right := max(lrange.right, rrange.right) ;
            end if ;
        end if ;
        return orange ;
    end function ;

end package body ;

use std.textio.all ;

entity test is
end entity ;

architecture arch of test is

    signal a : bit_vector(7 downto 0) ;
    signal b : bit_vector(10 downto 0) ;
    signal c : bit_vector(20 downto 8) ;

    signal d : bit_vector(0 to 8) ;
    signal e : bit_vector(4 to 5) ;
    signal f : bit_vector(5 to 4) ;

    function overlap is new work.ranges.overlap generic map( array_t => bit_vector ) ;

    function to_string(x : natural'range'record) return string is
    begin
        return "( left: " & to_string(x.left) & ", right: " & to_string(x.right) & ", direction: " & to_string(x.direction) & ")" ;
    end function ;

begin

    tb : process
    begin
        -- A's
        report to_string(overlap(a, a)) ;
        report to_string(overlap(a, b)) ;
        report to_string(overlap(a, c)) ;
        report to_string(overlap(a, d)) ;
        report to_string(overlap(a, e)) ;
        report to_string(overlap(a, f)) ;

        -- B's
        report to_string(overlap(b, a)) ;
        report to_string(overlap(b, b)) ;
        report to_string(overlap(b, c)) ;
        report to_string(overlap(b, d)) ;
        report to_string(overlap(b, e)) ;
        report to_string(overlap(b, f)) ;

        -- C's
        report to_string(overlap(c, a)) ;
        report to_string(overlap(c, b)) ;
        report to_string(overlap(c, c)) ;
        report to_string(overlap(c, d)) ;
        report to_string(overlap(c, e)) ;
        report to_string(overlap(c, f)) ;

        -- D's
        report to_string(overlap(d, a)) ;
        report to_string(overlap(d, b)) ;
        report to_string(overlap(d, c)) ;
        report to_string(overlap(d, d)) ;
        report to_string(overlap(d, e)) ;
        report to_string(overlap(d, f)) ;

        -- E's
        report to_string(overlap(e, a)) ;
        report to_string(overlap(e, b)) ;
        report to_string(overlap(e, c)) ;
        report to_string(overlap(e, d)) ;
        report to_string(overlap(e, e)) ;
        report to_string(overlap(e, f)) ;

        -- F's
        report to_string(overlap(f, a)) ;
        report to_string(overlap(f, b)) ;
        report to_string(overlap(f, c)) ;
        report to_string(overlap(f, d)) ;
        report to_string(overlap(f, e)) ;
        report to_string(overlap(f, f)) ;

        -- Done
        std.env.stop ;
    end process ;

end architecture ;
