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

end package body ;

