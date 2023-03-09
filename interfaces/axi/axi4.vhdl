library ieee ;
    use ieee.std_logic_1164.std_ulogic ;
    use ieee.std_logic_1164.std_ulogic_vector ;

package axi4 is
    type burst_t is (FIXED, INCR, WRAP, RES) ;
    type resp_t is (OKAY, EXOKAY, SLVERR, DECERR) ;
    type lock_t is (NORMAL, EXCLUSIVE) ;

    function slv(x : burst_t) return std_ulogic_vector ;
    function slv(x : resp_t) return std_ulogic_vector ;
    function sl(x : lock_t) return std_ulogic ;

    type prot_t is record
        privileged  :   std_ulogic ;
        nonsecure   :   std_ulogic ;
        instruction :   std_ulogic ;
    end record ;

    function pack(x : prot_t) return std_ulogic_vector ;
    function unpack(x : std_ulogic_vector) return prot_t ;

    type cache_t is record
        bufferable          :   std_ulogic ;
        modifiable          :   std_ulogic ;
        read_allocation     :   std_ulogic ;
        write_allocation    :   std_ulogic ;
    end record ;

    function pack(x : cache_t) return std_ulogic_vector ;
    function unpack(x : std_ulogic_vector) return cache_t ;

end package ;
