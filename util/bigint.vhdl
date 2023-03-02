library ieee ;
use ieee.numeric_std.all ;

package bigint is

        function from_string(x : string ; base : positive := 10) return rv_t of signed ;
        function from_hstring(x : string) return rv_t of signed ;
        function from_ostring(x : string) return rv_t of signed ;
        function from_bstring(x : string) return rv_t of signed ;

        function from_string(x : string ; base : positive := 10) return rv_t of unsigned ;
        function from_hstring(x : string) return rv_t of unsigned ;
        function from_ostring(x : string) return rv_t of unsigned ;
        function from_bstring(x : string) return rv_t of unsigned ;

        function modpow(base : unsigned ; exp : unsigned ; modulus : unsigned) return rv_t of unsigned ;

end package ;

package body bigint is

        use ieee.std_logic_1164.all ;

        -- Get the numerical value of the character, regardless of base
        function to_integer(x : character) return integer is
            constant rv : natural := character'pos(x) - character'pos('0') when character'pos(x) < 58 else
                                     character'pos(x) - character'pos('A') + 10 when character'pos(x) < 71 else
                                     character'pos(x) - character'pos('a') + 10 ;
        begin
            return rv ;
        end function ;

        function modpow(base : unsigned ; exp : unsigned ; modulus : unsigned) return rv_t of unsigned is
            variable lbase : base'subtype := base ;
            variable lexp : exp'subtype := exp ;
            variable rv : rv_t ;
        begin
            if modulus = 1 then
                return to_unsigned(0, rv'length) ;
            end if ;
            rv := to_unsigned(1, rv'length) ;
            lbase := lbase mod modulus ;
            while lexp > 0 loop
                if lexp(0) = '1' then
                    rv := (rv * lbase) mod modulus ;
                end if ;
                lexp := shift_right(lexp, 1) ;
                lbase := (lbase * lbase) mod modulus ;
            end loop ;
            return rv ;
        end function ;

        -- Function knows return size
        function to_signed(x : integer) return rv_t of signed is
        begin
            return to_signed(x, rv_t'length) ;
        end function ;

        -- Function knows return size
        function to_unsigned(x : integer) return rv_t of unsigned is
        begin
            return to_unsigned(x, rv_t'length) ;
        end function ;

        function gen_from_string
          generic(
            type t ;
            function "*"(l : integer ;  r : t) return t is <> ;
            function "+"(l : integer ;  r : t) return t is <> ;
            function "-"(l, r : t) return t is <> ;
            function convert(x : integer) return t is <> ;
            function resize(x : t) return t is <> ;
        ) parameter(x : string ; base : positive := 10) return rv_t of t is
            variable rv : rv_t := convert(0) ;
            constant negate : boolean := true when x(1) = '-' else false ;
            variable idx    : positive := 2 when negate = true else 1 ;
        begin
            assert base = 10 or base = 8 or base = 2 or base = 16
                report "from_string: Unsupported base (" & to_string(base) & ")"
                severity failure ;
            while idx < x'length loop
                rv := resize(base * rv) ;
                rv := to_integer(x(idx)) + rv ;
                idx := idx + 1 ;
            end loop ;
            return rv when negate = false else convert(0)-rv ;
        end function ;

        function resize(x : signed) return rv_t of signed is
            constant rv : rv_t := resize(x, rv_t'length) ;
        begin
            return rv ;
        end function ;

        function resize(x : unsigned) return rv_t of unsigned is
            constant rv : rv_t := resize(x, rv_t'length) ;
        begin
            return rv ;
        end function ;

        -- Riviera-PRO ambiguous function if generic is also from_string?
        function from_string is new gen_from_string generic map(t => signed,   convert => to_signed ) ;
        function from_string is new gen_from_string generic map(t => unsigned, convert => to_unsigned ) ;

        function from_xstring generic(type t ; base : natural) parameter (x : string) return rv_t of t is
            -- Riviera-PRO Assignment arget incompatible with right side?
            --constant rv : rv_t := from_string(x, base) ;
            -- Placeholder for now
            variable rv : rv_t ;
        begin
            return rv ;
        end function ;

        -- Riviera-PRO: This doesn't satisfy the package requirements?
        --function from_bstring is new from_xstring generic map(t => signed,   base =>  2) ;
        --function from_bstring is new from_xstring generic map(t => unsigned, base =>  2) ;

        --function from_ostring is new from_xstring generic map(t => signed,   base =>  8) ;
        --function from_ostring is new from_xstring generic map(t => unsigned, base =>  8) ;

        --function from_hstring is new from_xstring generic map(t => signed,   base => 16) ;
        --function from_hstring is new from_xstring generic map(t => unsigned, base => 16) ;

        --Individual versions since Riviera-PRO can't seem to handle these cases?
        alias fs is from_string[string, positive return signed] ;
        alias fu is from_string[string, positive return unsigned] ;

        function from_string(x : string ; base : positive := 10) return rv_t of signed is
            constant rv : rv_t := fs(x,base) ;
        begin
            return rv ;
        end function ;

        function from_string(x : string ; base : positive := 10) return rv_t of unsigned is
            constant rv : rv_t := fu(x,base) ;
        begin
            return rv ;
        end function ;

        function from_hstring(x : string) return rv_t of signed is
            constant rv : rv_t := fs(x, 16) ;
        begin
            return rv ;
        end function ;

        function from_ostring(x : string) return rv_t of signed is
            alias f is from_string[string, positive return signed] ;
            constant rv : rv_t := fs(x, 8) ;
        begin
            return rv ;
        end function ;

        function from_bstring(x : string) return rv_t of signed is
            constant rv : rv_t := fs(x, 2) ;
        begin
            return rv ;
        end function ;

        function from_hstring(x : string) return rv_t of unsigned is
            constant rv : rv_t := fu(x, 16) ;
        begin
            return rv ;
        end function ;

        function from_ostring(x : string) return rv_t of unsigned is
            constant rv : rv_t := fu(x, 8) ;
        begin
            return rv ;
        end function ;

        function from_bstring(x : string) return rv_t of unsigned is
            constant rv : rv_t := fu(x, 2) ;
        begin
            return rv ;
        end function ;

end package body ;

use std.textio.all ;

library ieee ;
    use ieee.numeric_std.all ;

entity test is
end entity ;

architecture arch of test is

    constant x : signed(1023 downto 0) := work.bigint.from_hstring("998734573947534875349857345973598347534897538945739485734985734598347589347597") ;

begin

    tb : process
        variable l : line ;
    begin
        write(l, to_hstring(x)) ;
        writeline(output, l) ;
        std.env.stop ;
    end process ;

end architecture ;
