library ieee ;
use ieee.std_logic_1164.std_logic ;
use ieee.std_logic_1164.std_ulogic ;
use ieee.std_logic_1164.std_logic_vector ;
use ieee.std_logic_1164.std_ulogic_vector ;
use ieee.numeric_std.signed ;
use ieee.numeric_std.unsigned ;
use ieee.fixed_pkg.sfixed ;
use ieee.fixed_pkg.ufixed ;

package rand is

    -- Uniform distribution between -1.0 and 1.0
    function rand return real ;

    -- Generic Scalar
    function rand generic(type t is (<>)) return t ;
    function rand_range generic(type t is (<>) ; function rand return t is <>) parameter(min, max : t) return t ;

    -- Instantiated Scalar
    -- XXX: Riviera Pro doesn't like this
    --function rand is new rand generic map(t => bit) ;
    --function rand is new rand generic map(t => integer) ;
    --function rand is new rand generic map(t => natural) ;
    --function rand is new rand generic map(t => positive) ;
    --function rand is new rand generic map(t => std_logic) ;
    --function rand is new rand generic map(t => std_ulogic) ;

    --function rand_range is new rand_range generic map(t => real) ;
    --function rand_range is new rand_range generic map(t => integer) ;
    --function rand_range is new rand_range generic map(t => natural) ;
    --function rand_range is new rand_range generic map(t => positive) ;

    -- Generic Vector
    function rand generic (type array_t is array(type is (<>)) of type is private ; function rand return array_t'element is <>) return rv_t of array_t ;

    -- Instantiated Vector
    -- XXX: Riviera Pro doesn't like this
    --function rand is new rand generic map(array_t => std_logic_vector) ;
    --function rand is new rand generic map(array_t => std_ulogic_vector) ;
    --function rand is new rand generic map(array_t => signed) ;
    --function rand is new rand generic map(array_t => unsigned) ;
    --function rand is new rand generic map(array_t => sfixed) ;
    --function rand is new rand generic map(array_t => ufixed) ;

    procedure randomize generic (type array_t is array(type is (<>)) of type is private ; function rand return array_t'element is <>) parameter(x : out array_t) ;

end package ;

package body rand is

    function rand return real is
        variable rv : real ;
    begin
        -- TODO: Fill this in
        return rv ;
    end function ;

    function rand_range generic( type t is (<>) ; function rand return t is <>) parameter(min, max : t) return t is
        variable rv : t := rand ;
    begin
        while rv < min or rv > max loop
            rv := rand ;
        end loop ;
        return rv ;
    end function ;

    function rand generic(type t is (<>))  return t is
        -- Use 'pos and 'val and rand_range?
        variable rv : t ;
    begin
        return rv ;
    end function ;

    function rand generic(type array_t is array(type is (<>)) of type is private) return rv_t of array_t is
        variable rv : rv_t ;
    begin
        for idx in rv'range loop
            rv(idx) := rand ;
        end loop ;
        return rv ;
    end function ;

    procedure randomize generic (type array_t is array(type is (<>)) of type is private ; function rand return array_t'element is <>) parameter(x : out_array_t) is
    begin
        for idx in x'range loop
            x(idx) := rand ;
        end loop ;
    end procedure ;

end package body ;
