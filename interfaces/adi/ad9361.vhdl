library ieee ;
use ieee.std_logic_1164.all ;

use work.io.all ;

package ad9361 is

    type lvds_t is record
        frame : diffpair.diffpair_t ;
        data  : diffpair.diffpairs_t(0 to 5) ;
    end record ;

    type lvds_if_t is record
       tx   :   lvds_t ;
       rx   :   lvds_t ;
    end record ;

    view lvds_driver of lvds_if_t is
        tx  :   out ;
        rx  :   in ;
    end view ;

    type cmos_t is record
        frame : std_ulogic ;
        data  : std_ulogic_vector(11 downto 0) ;
    end record ;

    type cmos_if_t is record
        p0  :   cmos_t ;
        p1  :   cmos_t ;
    end record ;

    view cmos_driver of cmos_if_t is
        p0  :   inout ;
        p1  :   inout ;
    end view ;

    type ad9361_t is record
        clock       :   std_ulogic ;
        resetb      :   std_ulogic ;
        sync        :   std_ulogic ;
        enable      :   std_ulogic ;
        txnrx       :   std_ulogic ;
        en_agc      :   std_ulogic ;
        ctrl_out    :   std_ulogic_vector(0 to 7) ;
        ctrl_in     :   std_ulogic_vector(0 to 4) ;
        lvds        :   lvds_if_t ;
        cmos        :   cmos_if_t ;
        spi         :   spi.spi_t ;
    end record ;

    view driver of ad9361_t is
        clock       :   out ;
        resetb      :   out ;
        sync        :   out ;
        enable      :   out ;
        txnrx       :   out ;
        en_agc      :   out ;
        ctrl_out    :   in ;
        ctrl_in     :   out ;
        lvds        :   view lvds_driver ;
        cmos        :   view cmos_driver ;
        spi         :   view spi.master ;
    end view ;

end package ;
