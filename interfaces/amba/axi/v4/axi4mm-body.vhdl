package body axi4mm is

    use ieee.numeric_std.to_unsigned;

    function burst_lengths return burst_lengths_t is
        variable rv : burst_lengths_t ;
    begin
        for idx in rv'range loop
            rv(idx) := std_ulogic_vector(to_unsigned(idx-1, rv(idx)'length)) ;
        end loop ;
        return rv ;
    end function ;

    function pack(x : prot_t) return std_ulogic_vector is
        constant rv : std_ulogic_vector(2 downto 0) := (
            0 => x.privileged,
            1 => x.nonsecure,
            2 => x.instruction
        ) ;
    begin
        return rv ;
    end function ;

    function unpack(x : std_ulogic_vector) return prot_t is
        constant rv : prot_t := (
            instruction => x(2),
            nonsecure   => x(1),
            privileged  => x(0)
        ) ;
    begin
        return rv ;
    end function ;

    function pack(x : cache_t) return std_ulogic_vector is
        constant rv : std_ulogic_vector(3 downto 0) := (
            0 => x.bufferable,
            1 => x.modifiable,
            2 => x.read_allocation,
            3 => x.write_allocation
        ) ;
    begin
        return rv ;
    end function ;

    function unpack(x : std_ulogic_vector) return cache_t is
        constant rv : cache_t := (
            bufferable          => x(0),
            modifiable          => x(1),
            read_allocation     => x(2),
            write_allocation    => x(3)
        ) ;
    begin
        return rv ;
    end function ;

    use ieee.numeric_std.all ;
    use std.reflection.all ;

    --function to_string(x : address_t) return string is
    --    variable mirror : value_mirror := x'reflect ;
    --begin
    --    return to_string(mirror) ;
    --end function ;

    --function to_string(x : bresp_t) return string is
    --    variable mirror : value_mirror := x'reflect ;
    --begin
    --    return to_string(mirror) ;
    --end function ;

    --function to_string(x : wdata_t) return string is
    --    variable mirror : value_mirror := x'reflect ;
    --begin
    --    return to_string(mirror) ;
    --end function ;

    --function to_string(x : rdata_t) return string is
    --    variable mirror : value_mirro := x'reflect ;
    --begin
    --    return to_string(mirror) ;
    --end function ;

    function slv(x : burst_t) return std_ulogic_vector is
    begin
        return std_logic_vector(to_unsigned(burst_t'pos(x),2)) ;
    end function ;

    function slv(x : resp_t) return std_ulogic_vector is
    begin
        return std_logic_vector(to_unsigned(resp_t'pos(x),2)) ;
    end function ;

    function sl(x : lock_t) return std_ulogic is
    begin
        return '0' when x = NORMAL else
               '1' ;
    end function ;

end package body ;

