library ieee ;
    use ieee.std_logic_1164.std_ulogic ;
    use ieee.std_logic_1164.std_ulogic_vector ;

use work.axi4.cache_t ;
use work.axi4.prot_t ;
use work.axi4.resp_t ;

package axi4l is

    type address_t is record
        addr    :   std_ulogic_vector(31 downto 0) ;
        prot    :   prot_t ;
        valid   :   std_ulogic ;
        ready   :   std_ulogic ;
    end record ;

    view address_manager of address_t is
        addr    :   out ;
        prot    :   out ;
        valid   :   out ;
        ready   :   in ;
    end view ;

    alias address_subordinate is address_manager'converse ;

    type bresp_t is record
        resp    :   resp_t ;
        valid   :   std_ulogic ;
        ready   :   std_ulogic ;
    end record ;

    view bresp_manager of bresp_t is
        resp    :   in ;
        valid   :   in ;
        ready   :   out ;
    end view ;

    alias bresp_subordinate is bresp_manager'converse ;

    type wdata_t is record
        data    :   std_ulogic_vector ;
        strb    :   std_ulogic_vector ;
        valid   :   std_ulogic ;
        ready   :   std_ulogic ;
    end record ;

    view wdata_manager of wdata_t is
        data    :   out ;
        strb    :   out ;
        valid   :   out ;
        ready   :   in ;
    end view ;

    type rdata_t is record
        data    :   std_ulogic_vector ;
        resp    :   resp_t ;
        valid   :   std_ulogic ;
        ready   :   std_ulogic ;
    end record ;

    view rdata_manager of rdata_t is
        data    :   in ;
        resp    :   in ;
        valid   :   in ;
        ready   :   out ;
    end view ;

    type axi4l_t is record
        aw : address_t ;
        ar : address_t ;
        b  : bresp_t ;
        w  : wdata_t ;
        r  : rdata_t ;
    end record ;

    view manager of axi4l_t is
        aw : view address_manager ;
        ar : view address_manager ;
        b  : view bresp_manager ;
        w  : view wdata_manager ;
        r  : view rdata_manager ;
    end view ;

    alias subordinate is manager'converse ;

    subtype axil32_t is axi4l_t (
        w( data(31 downto 0), strb(3 downto 0) ),
        r( data(31 downto 0) )
    ) ;

    subtype axil64_t is axi4l_t (
        w( data(63 downto 0), strb(7 downto 0) ),
        r( data(63 downto 0) )
    ) ;

end package ;
